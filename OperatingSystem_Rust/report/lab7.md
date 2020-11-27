## Lab7 实验报告

2017012289 李岱轩 计72

### 1 Mutex代码完善与测试

在需要完善的代码（即获取锁与释放锁），我的代码添加如下：

```rust
impl<T: ?Sized> Mutex<T> {
    fn obtain_lock(&self) {
        // TODO
        // try to get lock
        // what to do if get fail?
        unsafe {
            while *self.lock.get() == true {  yield_now();  }
            // println!("_______________{} acquire lock successful.",current_tid());
            let val = self.lock.get();
            *val = true;
        }
    }
}

impl<'a, T: ?Sized> Drop for MutexGuard<'a, T> {
    /// The dropping of the MutexGuard will release the lock it was created from.
    fn drop(&mut self) {
        // TODO
        *self.lock = false;
    }
}
```

主要思路是：在尝试获取锁时，如果获取失败则线程yield之后等待调度再次尝试获取锁。在MutexGuard超出作用域后，直接释放锁。经过测试，这样的设计可以正确通过哲学家就餐问题。如下所示：

```rust
philosophers using mutex
thread 0 exited, exit code = 0
1 is thinking.
2 is thinking.
3 is thinking.
4 is thinking.
5 is thinking.
1 is eating, using forks: 0, 1
3 is eating, using forks: 2, 3

...
3 is eating, using forks: 2, 3
5 iter 3 end.
5 is thinking.
1 is eating, using forks: 0, 1
3 iter 4 end.
thread 3 exited, exit code = 0
4 is eating, using forks: 3, 4
1 iter 4 end.
thread 1 exited, exit code = 0
2 is eating, using forks: 1, 2
4 iter 4 end.
thread 4 exited, exit code = 0
5 is eating, using forks: 0, 4
2 iter 4 end.
thread 2 exited, exit code = 0
5 iter 4 end.
thread 5 exited, exit code = 0
```

**本题哲学家就餐问题的死锁是通过应用层面的"资源编号"进行解决的。哲学家先拿起编号低的叉子。因此程序可以正确运行。**

### 2 思考题的回答

#### 2.1 为什么需要引入`MutexGuard`？

MutexGuard的作用是，在超出参数作用域时，自动释放产生MutexGuard的锁。常用的用法是，在需要锁时申请一个MutexGuard，在作用域结束时MutexGuard自动调用Drop。

需要引入MutexGuard的原因是可以不用显式的进行解锁操作，从而简化代码的书写。

#### 2.2 为什么需要修改 `yield_now` 并增加 `park` ，如果都仍然使用旧的 `yield_now` 会出现什么问题？

事实上，改之前的yield和改之后的park作用相同：

```rust
pub fn yield_now(&self) {
        let inner = self.inner();
        if !inner.current.is_none() {
            unsafe{
                ...
                let thread_info = inner.pool.threads[tid]
                    .as_mut()
                    .expect("thread not existed when yielding");// 拿取了线程的
                thread_info.status = Status::Sleeping;
                inner
                    .current
                    .as_mut()
                    .unwrap()
                    .1
                    .switch_to(&mut *inner.idle);
                ...
            }
        }
    }
```

这里也进行了进程设定为sleep的切换。修改yield并增加park的原因是**功能分离**。新的yield可以直接将线程变为Ready状态并参与下一次调度，这个功能可以再Mutex锁中进行应用。

#### 2.3 为什么需要在 `idle_main` 中增加一瞬间的中断开启，不增加这部分会出现什么问题？

sleep的唤醒是依赖于时钟中断进行的。如果在idle线程中的前半部分不加入瞬间的中断开启，则在线程池非空的情况下，idle线程中都不会允许时钟中断。**尤其是在本题目中，kernel_thread 的中断使能全部关闭（我们修改了spie），此时如果不在idle中开启中断使能，则会出现线程死锁。在哲学家就餐的1s内，无法被唤醒，而其他线程进入轮流sleep的循环。**

#### 2.4 为什么需要修改 `spie` ，如果不进行修改可能会出现什么问题？

如果不修改SPIE，本题目中不会对正确性造成影响，但是影响了线程的性能和执行时间的公平性。具体讲，在新建的kernel_thread进入执行阶段时（trapret之后）中断开启，kernel_thread一定会被1/100秒执行一次的时钟中断打断，影响性能，拖慢后续线程的执行。具体来说本题目中，如果开启spie，则第3个kernel_thread还没有开始执行（还没有开始think）的时候，第一个哲学家已经开始进食了(think了1s)，影响了线程执行时间的公平性。

如图所示，TICK代表时钟中断：

**开启SPIE**

![pic_lab7_1](/Users/li-dx/Desktop/Code/OS/Lab/os/report/pic_lab7_1.png)

**关闭SPIE**

![pic_lab7_2](/Users/li-dx/Desktop/Code/OS/Lab/os/report/pic_lab7_2.png)