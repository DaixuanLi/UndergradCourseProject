## Lab3 实验报告

2017012289 李岱轩 计72

#### 1 现有页面替换算法框架的实现存在问题与解决方案

**问题：**

**1.** Rv39PageTable在解除映射时没有回收内存并释放，导致frame内存泄漏；

**2.** 没有设计访问非法地址的trap。在do_pgfault函数中，如果访问的是非法地址，则会进入下一个访问非法地址循环，swap会无限进行下去；

**3.** do_pgfault函数没有将交换的页放在fifo队列中，使得下一次交换将没有页可以交换。

**解决方案：**

对于1，修改Rv39PageTable的unmap接口，加入allocator作为传入参数。在判定合法的前提下，将对应物理帧回收即可。 这样在进行页表删除的时候不会出现内存泄露。

对于2，增加一层判断，在访问非法地址时进行判断并进入panic即可；

对于3，在do_pgfault中把新的页放入fifo队列即可。

#### 2 时钟页面替换算法的实现

我直接在fifo的接口基础上实现了时钟页面替换算法。仍然使用rust的vecdeque数据结构，使用一个usize变量代替指针。由于程序中使用了default初始化，指正会被初始化为0。

插入新的页面时，在指针前插入。找可以替换的牺牲者页面时，从当前指针向后找（找到最后则返回最开始），如果access属性为0则选定，为1则改为0后继续寻找，最终选定牺牲者页面。

在这里，我们发现一个选定victim 的操作并不一定紧跟着一个push操作，这引出了上文中的**问题3**。

代码如下：

```rust
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
```





