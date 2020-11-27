use alloc::sync::Arc;
use rcore_fs::vfs::INode;
use rcore_fs_sfs::INodeImpl;
use crate::fs::ROOT_INODE;
use crate::fs::pipe::Pipe;


// 文件描述符类型
#[derive(Copy,Clone,Debug)]
pub enum FileDescriptorType {
    FD_NONE,    // 空类型
    FD_INODE,    // INode 类型
    FD_DEVICE,    // 设备类型
    FD_PIPE,    // 管道类型
}

// 进程内打开的文件
#[derive(Clone)]
pub struct File {
    fdtype: FileDescriptorType,
    // 进程对该文件的权限
    readable: bool,
    writable: bool,
    // 该文件的 INode 指针，用于进行实际读写
    pub inode: Option<Arc<dyn INode>>,
    // 进程中该文件的偏移量指针
    offset: usize,
}

impl File {
    // 初始化
    pub fn default() -> Self {
        File {
            fdtype: FileDescriptorType::FD_NONE,
            readable: false,
            writable: false,
            inode: None,
            offset: 0,
        }
    }
    // get/set 函数
    pub fn set_readable(&mut self, v: bool) { self.readable = v; }
    pub fn set_writable(&mut self, v: bool) { self.writable = v; }
    pub fn get_readable(&self) -> bool { self.readable }
    pub fn get_writable(&self) -> bool { self.writable }
    pub fn set_fdtype(&mut self, t: FileDescriptorType) { self.fdtype = t; }
    pub fn get_fdtype(&self) -> FileDescriptorType { self.fdtype }
    pub fn set_offset(&mut self, o: usize) { self.offset = o; }
    pub fn get_offset(&self) -> usize { self.offset }

    pub fn open_file(&mut self, path: &'static str, flags: i32) {
        self.set_fdtype(FileDescriptorType::FD_INODE);
        self.set_readable(true);
        if (flags & 1) > 0 {
            self.set_readable(false);
        }
        if (flags & 3) > 0 {
            self.set_writable(true);
        }
        unsafe {
            self.inode = Some(ROOT_INODE.lookup(path).unwrap().clone());
        }
        self.set_offset(0);
    }

    pub fn open_pipe(&mut self, pipeIns: Pipe, flags: i32){
        self.set_fdtype(FileDescriptorType::FD_INODE);
        self.set_readable(true);
        if (flags & 1) > 0 {
            self.set_readable(false);
        }
        if (flags & 3) > 0 {
            self.set_writable(true);
        }
        unsafe {
            self.inode = Some(Arc::new(pipeIns));
        }
        self.set_offset(0);
    }
}



