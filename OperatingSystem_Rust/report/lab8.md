## Lab8 实验报告

2017012289 李岱轩 计72

### 1 实现sys_pipe

我的实现思路是，**新建一个Pipe类**作为管道。管道类包含**data（采用VecDeque作为数据结构）表示共享数据**，用Mutex和Arc封装，来实现同步；管道类同时包含**direction来辨明是写管道还是读管道**。

**对管道类实现INode trait**，这样就可以复用之前的sys_read来进行读写了。值得一提的是INode Trait中的read_at接口，在没有数据时采用阻塞策略，即使用yield_now，等待直到有数据产生，来避免死锁的发生。

**在原来的sys_fork中，添加对所有INode的复制**。由于使用Arc对Pipe进行了封装，因此指针被复制，实现了线程间的共享变量。

具体代码和部分注释如下所示：

```rust
// pipe.rs
use alloc::{collections::vec_deque::VecDeque, sync::Arc};
use crate::process::{yield_now};
use crate::sync::condvar::Condvar;
use spin::Mutex;
use xmas_elf::header::Data;
//use core::intrinsics::atomic_cxchg_acq_failrelaxed;
use rcore_fs::vfs::{INode, PollStatus, FsError};
use core::any::Any;
use alloc::string::String;


#[derive(Clone)]
pub enum PipeEnd {
    Read,
    Write,
}

pub struct PipeData {
    buf: VecDeque<u8>,
    new_data: Condvar, // 本来想仿照rcore用Condvar来写，但是由于调度器使用时间片算法，导致这样做会引发不可预知的线程行为，因此最终改为了yield_now。
}

pub struct Pipe {
    data: Arc<Mutex<PipeData>>,
    direction: PipeEnd,
}

impl Pipe {
    pub fn create_pair() -> (Pipe, Pipe) {
        let inner = PipeData {
            buf: VecDeque::new(),
            new_data: Condvar::new(),
        };
        let data = Arc::new(Mutex::new(inner));
        (
            Pipe {
                data: data.clone(),
                direction: PipeEnd::Read,
            },
            Pipe {
                data: data.clone(),
                direction: PipeEnd::Write,
            }
        )
    }

    fn can_read(&self) -> bool {
        if let PipeEnd::Read = self.direction {
            self.data.lock().buf.len() > 0 || self.is_broken() //这里的is_broken代表当写端口全部消失后可以直接读
        } else {
            false
        }
    }

    fn can_write(&self) -> bool {
        if let PipeEnd::Write = self.direction {
            !self.is_broken()
        } else {
            false
        }
    }

    fn is_broken(&self) -> bool {
        Arc::strong_count( &self.data) < 2
    }

    fn add_to_condvar(&self) {
        let mut data = & self.data.lock().new_data;
        data.prepare_wait();
    }
}

impl INode for Pipe {
    fn read_at(&self, _offset: usize, buf: &mut [u8]) -> Result<usize,FsError> {
        while !self.can_read() {
            yield_now(); // 没有数据则yield
        }
        if let PipeEnd::Read = self.direction {
            let mut data = self.data.lock();
            if let Some(ch) = data.buf.pop_front() {
                buf[0] = ch;
                Ok(1 as usize)
            } else {
                Ok(0 as usize)
            }
        } else {
            Ok(0 as usize)
        }
    }

    fn write_at(&self, _offset: usize, buf: &[u8]) -> Result<usize,FsError> {
        //println!("Pipe in write!");
        if let PipeEnd::Write = self.direction {
            if buf.len() > 0 {
                let mut data = self.data.lock();
                data.buf.push_back(buf[0]);
                Ok(1)
            } else {
                Ok(0)
            }
        } else {
            Ok(0)
        }
    }

    fn poll(&self) -> Result<PollStatus,FsError> {
        Ok(PollStatus{
            read: self.can_read(),
            write: self.can_write(),
            error:false,
        })
    }

    fn as_any_ref(&self) -> &dyn Any {
        self
    }
}
```

### 2 思考题

#### 如果父进程还没写数据，子进程就开始读数据会怎么样？应如何解决？

会无法读到数据。在本实现中，子进程会一直放弃资源（yield_now()）直到有数据可以被读出。

#### 简要说明你是如何保证读者和写者对于管道 `Pipe` 的访问不会触发 race condition 的？

对管道Pipe使用Arc和Mutex进行封装。这样在一个线程访问Data时获得锁，另一个线程只有等待锁的释放才能进行访问，因此不会出现race condition。

#### 在实现中是否曾遇到死锁？如果是，你是如何解决它的？

是的。使用Condvar来写，首先会出现获得锁之后yield，这样另一个进程无法获得锁。解决办法是，获得锁，加入等待队列之后，放弃锁再yield。

这样带来新的问题：在读者判定没有可读字符，还没有获得锁时，此时还没有将tid放入等待队列，写者完成写操作，notify并退出。这样再次进入读者时就会出现线程永远等待（没有notify）的情况。 最终我们采用了如果无法读直接yield的方式解决了这个问题。