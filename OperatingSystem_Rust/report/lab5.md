## Lab5 实验报告

2017012289 李岱轩 计72

### 1 为rcore增加`sys_fork`

fork实现的主要思路是，保存所有相关的寄存器，将内存整体复制并复制页表，构造所有进程需要的资源，最终通过trapframe来构造目标进程，将进程方如调度器中，之后进程就可以得到执行。

具体增加的代码主要为：

建立系统调用的通路，使用ecall在user mode中调用syscall，并且在os中：

```rust
// 在usr mode中增加sys_fork的代码
// syscall.rs
pub fn sys_fork() -> Tid {
    sys_call(SyscallId::Fork, 0, 0, 0, 0)
}
enum SyscallId {
    Fork = 220,
  	...
}

// 对应的在core中的增加的代码
// syscall.rs
pub const SYS_FORK: usize = 220;
fn sys_fork(tf: &mut TrapFrame) -> isize {
    let new_thread = process::current_thread_fork(tf);
    let tid = process::add_thread(new_thread);
    tid as isize
}

// processor.rs
pub fn current_tid(&self) -> usize {
        self.inner().current.as_mut().unwrap().0 as usize
}

pub fn current_thread_fork(&self,tf: &mut TrapFrame) -> Box<Thread> { 		   self.inner().current.as_mut().unwrap().1.fork(tf)  }
}
```

在线程中fork，关键点是复制所有的MemorySet并重新使用页表进行映射，代码为：

```rust
//struct.rs
pub struct Thread {
    ...
    pub vm: Arc<Mutex<MemorySet>>,
}
impl Thread {
	pub fn fork(&mut self, tf: &mut TrapFrame) -> Box<Thread> {
        unsafe {
            let vm = self.vm.lock().clone();
            let vm_token = vm.token();
            let vm = Arc::new(Mutex::new(vm));
            let kstack_ = KernelStack::new();
            Box::new(Thread {
                context: Context::new_forked_thread(tf, vm_token,kstack_.top()),
                kstack: kstack_,
                wait: None,
                vm: vm.clone(),
            })
        }
    }
}
// paging.rs
pub fn get_page_slice_mut<'a>(&mut self, vaddr: usize) -> &'a mut [u8] {
        let frame = self
            .page_table
            .translate_page(Page::of_addr(VirtAddr::new(vaddr)))
            .unwrap();
        let vaddr = frame.start_address().as_usize() + PHYSICAL_MEMORY_OFFSET;
        unsafe { core::slice::from_raw_parts_mut(vaddr as *mut u8, 0x1000) }
    }
// 其中的clone函数在memory_set/mod.rs中定义
pub fn clone(&mut self) -> Self {

        let new_page_table = Arc::new(Mutex::new(PageTableImpl::new_bare()));
        let Self {
            ref mut page_table,
            ref areas,
            ..
        } = self;
        for area in areas.iter() {
            for page in PageRange::new(area.start, area.end) {
                area.handler.clone_map(
                    new_page_table.clone(),
                    page_table.clone(),
                    page,
                    &area.attr,
                );
            }
        }
        MemorySet {
            areas: areas.clone(),
            page_table: new_page_table,
        }
   }
```

最终使用给定的脚本运行文件，即可以得到预期结果。

```
I am child
ret tid is: 0
thread 2 exited, exit code = 0
I am father
ret tid is: 2
thread 1 exited, exit code = 0
I am child
ret tid is: 0
thread 3 exited, exit code = 0
I am father
ret tid is: 3
thread 0 exited, exit code = 0
```

