## Lab2 实验报告

2017012289 李岱轩

### 1 如果 OS 无法提前知道当前硬件的可用物理内存范围，请问你有何办法让 OS 获取可用物理内存范围？

在Risc-V中，需要解析OpenSBI扫描所有物理地址后的结果DTB(Device Tree Blob)。具体来说，需要访问a1寄存器所保存的地址，从而进入设备树表，在设备树表中描述了所有外设和对应的物理地址空间，这些物理地址空间就是可用的物理地址空间。

### 2 实现 `FirstFitAllocator`

实现思路为，维护一个代表所有页面的数组a，a的第k位为1/0，表示页面空闲/被占用。

alloc数目为n的页面时遍历数组，当找到第一个连续的n个空闲页面时，将这n个页面设置为占用并返回页面起始地址。否则返回None。

dealloc（m,n）时，从数组的第m个开始，将之后的k个都设置为空闲即可。

具体代码见附录。

此次的commit id 为 e9c8dbb20abf47907c5f7754e2bbcf9d6baf219f。

#### 附录

```rust
// memory/mod.rs
mod frame_allocator;
mod fit_allocator;
use fit_allocator::FIT_ALLOCATOR as FRAME_ALLOCATOR;
use riscv::addr::{
    // 分别为虚拟地址、物理地址、虚拟页、物理页帧
    // 非常方便，之后会经常用到
    // 用法可参见 https://github.com/rcore-os/riscv/blob/master/src/addr.rs
    VirtAddr,
    PhysAddr,
    Page,
    Frame
};
use buddy_system_allocator::LockedHeap;

pub fn init_allocator(l: usize, r: usize) {
    FRAME_ALLOCATOR.lock().init(l, r);
}

pub fn alloc_frame() -> Option<Frame> {
    alloc_frames(1)
}

// 分配 cnt 块连续的帧
pub fn alloc_frames(cnt: usize) -> Option<Frame> {
    if let Some(frame) = FRAME_ALLOCATOR.lock().alloc(cnt) {
        return Some(Frame::of_ppn(frame));
    }
    return None;
}

pub fn dealloc_frame(f: Frame) {
    dealloc_frames(f, 1)
}

// 释放以 f 为起始地址，cnt 块连续的帧
pub fn dealloc_frames(f: Frame, cnt: usize) {
    FRAME_ALLOCATOR.lock().dealloc(f.number(), cnt)
}

pub fn init(l: usize, r: usize) {
    FRAME_ALLOCATOR.lock().init(l, r);     
    // init_heap();
    //println!("++++ setup memory!    ++++");
}

#[global_allocator]
static DYNAMIC_ALLOCATOR: LockedHeap = LockedHeap::empty();
//
#[alloc_error_handler]
fn alloc_error_handler(_: core::alloc::Layout) -> ! {
     panic!("alloc_error_handler do nothing but panic!");
}

// memory/fit_allocator.rs

use crate::consts::MAX_PHYSICAL_PAGES;
use core::panicking::panic;

use spin::Mutex;

pub struct FitAllocator {
    a: [u8; MAX_PHYSICAL_PAGES << 1],
    n: usize,
    offset: usize
}

pub static FIT_ALLOCATOR: Mutex<FitAllocator> = Mutex::new(FitAllocator {
    a: [0; MAX_PHYSICAL_PAGES << 1],
    n: 0,
    offset: 0
});

impl FitAllocator {
    pub fn init(&mut self, l: usize,r: usize) {
        self.offset = l - 1;
        self.n = r - l;
        for i in (1..(self.n + 1)) { self.a[i] = 1; }
        //println!("init with offset {} and n {}",self.offset,self.n);
    }
    // 分配k个连续的物理页
    // 自上而下寻找可用的最小物理页号
    // 注意，我们假定永远不会出现物理页耗尽的情况
    pub fn alloc(&mut self, k: usize) -> Option<usize> {
        // assume that we never run out of physical memory
        let mut p = 1;
        let mut found:usize = 0;
        let mut count:usize = 0;
        while p <= self.n {
            if self.a[p] == 1 { count = count + 1; } else { count = 0; }
            if count >= k {found = 1; break;}
            p = p + 1;
        }
        let mut result = Some(0);
        if found == 0 {
            result = None;
        } else {
            result = Some(p - k + 1 + self.offset);
            while count > 0 {
                count = count - 1;
                self.a[p] = 0;
                p = p - 1;
            }
        }
        result
    }
    // 回收物理页号为 n 的物理页
    // 自下而上进行更新
    pub fn dealloc(&mut self, n: usize, cnt: usize) {
        //println!("dealloc {} ; {}",n,cnt);
        let mut p = n - self.offset;
        let mut count = cnt;
        while count > 0 {
            assert!(self.a[p] == 0);
            self.a[p] = 1;
            p = p + 1;
            count = count - 1;
        }
    }
}
```



