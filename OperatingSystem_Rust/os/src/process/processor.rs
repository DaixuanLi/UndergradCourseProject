use crate::context::{ContextContent, TrapFrame};
use crate::interrupt::*;
use crate::process::structs::*;
use crate::process::thread_pool::ThreadPool;
use crate::process::{Tid, current_tid};
use alloc::boxed::Box;
use core::cell::UnsafeCell;

pub struct ProcessorInner {
    pool: Box<ThreadPool>,
    idle: Box<Thread>,
    current: Option<(Tid, Box<Thread>)>,
}

pub struct Processor {
    inner: UnsafeCell<Option<ProcessorInner>>,
}

unsafe impl Sync for Processor {}


impl Processor {
    pub fn park(&self) {
        self.inner().pool.set_sleep(self.current_tid());
        println!("thread {} sleep and yield.",current_tid());
        self.yield_now();
    }
}


impl Processor {
    pub const fn new() -> Processor {
        Processor {
            inner: UnsafeCell::new(None),
        }
    }

    pub fn init(&self, idle: Box<Thread>, pool: Box<ThreadPool>) {
        unsafe {
            *self.inner.get() = Some(ProcessorInner {
                pool,
                idle,
                current: None,
            });
        }
    }

    fn inner(&self) -> &mut ProcessorInner {
        unsafe { &mut *self.inner.get() }
            .as_mut()
            .expect("Processor is not initialized!")
    }

    pub fn add_thread(&self, thread: Box<Thread>) -> Tid {
        self.inner().pool.add(thread)
    }

    pub fn idle_main(&self) -> ! {
        let inner = self.inner();
        disable_and_store();
        loop {
            if let Some(thread) = inner.pool.acquire() {
                inner.current = Some(thread);
                //println!("____________idle get thread {}", inner.current.as_mut().unwrap().0 );
                inner
                    .idle
                    .switch_to(&mut *inner.current.as_mut().unwrap().1);
                let (tid, thread) = inner.current.take().unwrap();
                inner.pool.retrieve(tid, thread);
                enable();
                disable_and_store();
            } else {
                enable_and_wfi();
                disable_and_store();
            }
        }
    }

    pub fn tick(&self) {
        let inner = self.inner();
        if !inner.current.is_none() {
            if inner.pool.tick() {
                let flags = disable_and_store();

                inner.current.as_mut().unwrap().1.switch_to(&mut inner.idle);

                restore(flags);
            }
        }
    }

    pub fn exit(&self, code: usize) -> ! {
        disable_and_store();
        let inner = self.inner();
        let tid = inner.current.as_ref().unwrap().0;

        inner.pool.exit(tid);
        println!("thread {} exited, exit code = {}", tid, code);

        if let Some(wait) = inner.current.as_ref().unwrap().1.wait {
            inner.pool.wakeup(wait);
        }

        inner.current.as_mut().unwrap().1.switch_to(&mut inner.idle);

        loop {}
    }

    pub fn run(&self) {
        Thread::get_boot_thread().switch_to(&mut self.inner().idle);
    }

    pub fn yield_now(&self) {
        //println!("thread called yield {}",current_tid());
        let inner = self.inner();
        if !inner.current.is_none() {
            unsafe {
                let flags = disable_and_store();
                let current_thread = &mut inner.current.as_mut().unwrap().1;
                current_thread.switch_to(&mut *inner.idle);
                restore(flags);
                //println!("thread restore from yield {}",current_tid());
            }
        }
    }

    pub fn wake_up(&self, tid: Tid) {
        let inner = self.inner();
        inner.pool.wakeup(tid);
    }

    pub fn current_tid(&self) -> usize {
        self.inner().current.as_mut().unwrap().0 as usize
    }

    pub fn current_thread_fork(&self,tf: &mut TrapFrame) -> Box<Thread> { self.inner().current.as_mut().unwrap().1.fork(tf)  }

    pub fn current_thread_set_priority(&self, pri:usize) {
        let inner = self.inner();
        inner.pool.scheduler.set_priority(current_tid(),pri);
    }

    pub fn current_thread_mut(&self) -> &mut Thread {
        self.inner().current.as_mut().unwrap().1.as_mut()
    }
}
