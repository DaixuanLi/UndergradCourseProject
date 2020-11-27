## Lab6 实验报告

2017012289 李岱轩 计72

### 1 将rcore中的Round Robin算法替换为Stride算法

#### 1.1 Stride算法原理与简要证明

Stride替换算法的主要实现思路是，在时间片分配的基础上，为每一个线程增加了优先级属性（priority），增加了stride属性来标定调度的顺序，增加了具体调度规则为：

* 一开始初始化所有线程的stride为0。为所有线程设定好priority；
* 选择stride最小的线程进行调度，线程时间片进行完之后，为线程的stride加上pass=BIGSTRIDE/priority。其中BIGSTRIDE是预先提供的大常数；
* 反复执行上一条，知道所有线程结束。

Stride算法可以保证线程分配到的时间大致与priority成正比。其证明非常显然：线程分配到的时间片与每一次的pass成反比，而pass与priority成反比，于是线程分配到的时间片数量，也即线程分配到的时间与priority成正比。

Stride算法还有一个有趣的现象是，在实现中，如果适当选择BIGSTRIDE，可以使得最大和最小STRTDE的差不超过有符号整数正最大值。这是由于：
$$
MAX\_STRIDE - MIN\_STRIDE \geq MAX\_PASS
$$
证明依然非常显然：首先考虑**两个**stride的差值的产生，只能由一个Stride增加PASS产生。而一个Strde在另一个增加到比这个stride大之前不能连续增加PASS，否则不符合定义。因此最大差值即是两个PASS的最大值。**应用到全体**，最大差值就是最大PASS。

#### 1.2 实现简述与结果

接下来简述实现。我增加了StrideScheduler，其中设定BIG_STRIDE为i64::max_value()-2。我再其中维护了一个数组来存储stride，是因为rust的官方库中的BinaryHeap没有提供删除其中的一个数据的接口，因此难以直接使用。考虑到测例的规模，采用数组也可以完成任务。

在增加scheduler之外，我还增加了gettime系统调用（取得TICK的值）和set_priority系统调用（直接在Scheduler中设定priority）。

具体代码如下：

**系统调用**

```rust
// usr 中
pub fn set_priority(pri:usize) {
    sys_call(SyscallId::SetPriorty,pri,0,0,0);
}

pub fn sys_gettime() -> usize {
    sys_call(SyscallId::GetTime,0,0,0,0) as usize
}

// os core中
pub const SYS_SETPRIORITY: usize = 140;
pub const SYS_TIMES: usize = 153;
fn set_priority(pri:usize) -> isize{
    process::current_thread_set_priority(pri);
    0
}

fn sys_gettime() -> isize {
    unsafe {
        TICKS as isize
    }
}

// scheduler中
fn set_priority(&mut self, tid: Tid, pri:usize) {
        let tid = tid + 1;
        if tid + 1 > self.threads.len() {
            self.threads.resize_with(tid + 1, Default::default);
            self.threads[tid].stride = 0;
            self.threads[tid].priority = pri as i64;
        } else {
            self.threads[tid].priority = pri as i64;
        }
    }
```

**Scheduler实现**

```rust
// 其实不减都可以，这里出于个性减个2（
static BIG_STRIDE:i64 = i64::max_value() - 2;

#[derive(Default)]
struct StrideInfo {
    valid : bool,
    stride : i64,
    priority : i64,
    time : usize,
}

pub struct StrideScheduler {
    threads: Vec<StrideInfo>,
    max_time: usize,
    current: usize,
}

impl StrideScheduler {
    pub fn new(max_time_slice: usize) -> Self {
        let mut ss = StrideScheduler {
            threads:Vec::new(),
            max_time:max_time_slice,
            current:0
        };
        ss.threads.push(StrideInfo {
            valid : false,
            stride : 0,
            priority : 1,
            time : 0,
        });
        ss
    }
}

impl Scheduler for StrideScheduler {
    fn push(&mut self, tid: Tid) {
        //println!("push tid {}",tid);
        let tid = tid + 1;
        if tid + 1 > self.threads.len() {
            self.threads.resize_with(tid + 1, Default::default);
            self.threads[tid].stride = 0;
            self.threads[tid].priority = 1;
        }

        if self.threads[tid].time == 0 {
            self.threads[tid].time = self.max_time;
        }
        self.threads[tid].valid = true;
    }

    fn pop(&mut self) -> Option<Tid> {
        let mut ret = 0;
        let mut min_stride:i64 = 0;
        for n in 1..self.threads.len() {
            if self.threads[n].valid {
                min_stride = self.threads[n].stride;
                ret = n;
                break;
            }
        }
        if ret == 0 {
            None
        } else {
            for n in 2..self.threads.len() {
                if self.threads[n].valid && self.threads[n].stride.wrapping_sub(min_stride) < 0 {
                    min_stride = self.threads[n].stride;
                    ret = n;
                }
            }
            self.threads[ret].valid = false;
            self.threads[ret].stride = self.threads[ret].stride.wrapping_add(BIG_STRIDE / self.threads[ret].priority);
            self.current = ret;
            //println!("pop tid {}",ret-1);
            Some(ret - 1)
        }
    }

    // 当前线程的可用时间片 -= 1
    fn tick(&mut self) -> bool {
        let tid = self.current;
        if tid != 0 {
            self.threads[tid].time -= 1;
            if self.threads[tid].time == 0 {
                return true;
            } else {
                return false;
            }
        }
        return true;
    }

    fn exit(&mut self, tid: Tid) {
        let tid = tid + 1;
        if self.current == tid {
            self.current = 0;
        }
    }

    fn set_priority(&mut self, tid: Tid, pri:usize) {
        let tid = tid + 1;
        if tid + 1 > self.threads.len() {
            self.threads.resize_with(tid + 1, Default::default);
            self.threads[tid].stride = 0;
            self.threads[tid].priority = pri as i64;
        } else {
            self.threads[tid].priority = pri as i64;
        }
    }
}
```

最终，得到了预期的结果，优先级与所用时间大致成正比：

```
main: fork ok.
thread 0 exited, exit code = 0
thread 5 exited, exit code = 656800
thread 4 exited, exit code = 531200
thread 3 exited, exit code = 400000
thread 2 exited, exit code = 266000
thread 1 exited, exit code = 135200
```



