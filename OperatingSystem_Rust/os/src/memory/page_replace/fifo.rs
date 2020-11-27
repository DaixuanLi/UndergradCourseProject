use {
    super::*,
    alloc::{collections::VecDeque, sync::Arc},
    spin::Mutex,
};

#[derive(Default)]
pub struct FifoPageReplace {
    frames: VecDeque<(usize, Arc<Mutex<PageTableImpl>>)>,
    pointer: usize,
}

impl PageReplace for FifoPageReplace {
    fn push_frame(&mut self, vaddr: usize, pt: Arc<Mutex<PageTableImpl>>) {
        //println!("push pointer: {}",self.pointer);
        //println!("push vaddr: {:#x?}", vaddr);
        self.frames.insert(self.pointer,(vaddr, pt));
        self.pointer = self.pointer + 1;
        if self.pointer == self.frames.len() {
            self.pointer = 0;
        }
    }

    fn choose_victim(&mut self) -> Option<(usize, Arc<Mutex<PageTableImpl>>)> {
        // 选择一个已经分配的物理页帧
        while true {
            //println!("pop check pointer: {}",self.pointer);
            let mut pt = self.frames.get(self.pointer).unwrap();
            let mut ptl = pt.1.lock().get_entry(pt.0).unwrap().accessed();
            if ptl {
                pt.1.lock().get_entry(pt.0).unwrap().clear_accessed();
            } else {
                break
            }
            self.pointer = self.pointer + 1;
            if self.pointer == self.frames.len() {
                self.pointer = 0;
            }
        }
        //println!("pop pointer: {}",self.pointer);
        let popid = self.pointer;
        if self.pointer == self.frames.len() - 1 {
            self.pointer = 0;
        }
        self.frames.remove(popid)
    }

    fn tick(&self) {}
}
