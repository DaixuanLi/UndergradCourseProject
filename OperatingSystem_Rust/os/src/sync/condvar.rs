use crate::process::{current_tid, wake_up, yield_now, Tid, park};
use alloc::collections::VecDeque;
use spin::Mutex;

#[derive(Default)]
pub struct Condvar {
    wait_queue: Mutex<VecDeque<Tid>>,
}

impl Condvar {
    pub fn new() -> Self {
        Condvar::default()
    }

    pub fn wait(&self) {
        self.wait_queue.lock().push_back(current_tid());
        println!("Condvar push back {}",current_tid());
        park();
    }

    pub fn prepare_wait(&self) {
        self.wait_queue.lock().push_back(current_tid());
        println!("Condvar only push back {}", current_tid());
    }

    pub fn notify(&self) {
        println!("Condvar pop working:");
        let tid = self.wait_queue.lock().pop_front();
        if let Some(tid) = tid {
            println!("Condvar pop {}", tid);
            wake_up(tid);
        } else {
            println!("Condvar no tid to pop!! current: {}", current_tid());
        }
        /* yield_now(); */
    }
}
