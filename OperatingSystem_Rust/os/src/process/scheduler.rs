use super::Tid;
use alloc::vec::Vec;
use core::cmp::Ordering;
use alloc::collections::BinaryHeap;

pub trait Scheduler {
    fn push(&mut self, tid: Tid);
    fn pop(&mut self) -> Option<Tid>;
    fn tick(&mut self) -> bool;
    fn exit(&mut self, tid: Tid);
    fn set_priority(&mut self, tid: Tid, pri:usize);
}

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
        // println!("push tid {}",tid);
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
            println!("pop tid {}",ret-1);
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




#[derive(Default)]
struct RRInfo {
    valid: bool,
    time: usize,
    prev: usize,
    next: usize,
}

pub struct RRScheduler {
    threads: Vec<RRInfo>,
    max_time: usize,
    current: usize,
}

impl RRScheduler {
    pub fn new(max_time_slice: usize) -> Self {
        let mut rr = RRScheduler {
            threads: Vec::default(),
            max_time: max_time_slice,
            current: 0,
        };
        rr.threads.push(RRInfo {
            valid: false,
            time: 0,
            prev: 0,
            next: 0,
        });
        rr
    }
}
impl Scheduler for RRScheduler {
    fn push(&mut self, tid: Tid) {
        let tid = tid + 1;
        if tid + 1 > self.threads.len() {
            self.threads.resize_with(tid + 1, Default::default);
        }

        if self.threads[tid].time == 0 {
            self.threads[tid].time = self.max_time;
        }

        let prev = self.threads[0].prev;
        self.threads[tid].valid = true;
        self.threads[prev].next = tid;
        self.threads[tid].prev = prev;
        self.threads[0].prev = tid;
        self.threads[tid].next = 0;
    }

    fn pop(&mut self) -> Option<Tid> {
        let ret = self.threads[0].next;
        if ret != 0 {
            let next = self.threads[ret].next;
            let prev = self.threads[ret].prev;
            self.threads[next].prev = prev;
            self.threads[prev].next = next;
            self.threads[ret].prev = 0;
            self.threads[ret].next = 0;
            self.threads[ret].valid = false;
            self.current = ret;
            Some(ret - 1)
        } else {
            None
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

    }
}
