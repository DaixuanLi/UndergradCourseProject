enum SyscallId {
    Open = 56,
    Close = 57,
    Pipe = 59,
    Read = 63,
    Write = 64,
    Exit = 93,
    SetPriorty = 140,
    GetTime = 153,
    Fork = 220,
    Exec = 221,
}

pub type Tid = i64;

#[inline(always)]
fn sys_call(syscall_id: SyscallId, arg0: usize, arg1: usize, arg2: usize, arg3: usize) -> i64 {
    let id = syscall_id as usize;
    let mut ret: i64;
    unsafe {
        asm!(
            "ecall"
            : "={x10}"(ret)
            : "{x17}"(id), "{x10}"(arg0), "{x11}"(arg1), "{x12}"(arg2), "{x13}"(arg3)
            : "memory"
            : "volatile"
        );
    }
    ret
}

pub fn sys_open(path: *const u8, flags: i32) -> i64 {
    sys_call(SyscallId::Open, path as usize, flags as usize, 0, 0)
}

pub fn sys_close(fd: i32) -> i64 {
    sys_call(SyscallId::Close, fd as usize, 0, 0, 0)
}

pub fn sys_write(fd:usize, base: *const u8, len: usize) -> i64 {
    sys_call(SyscallId::Write, fd, base as usize, len, 0)
}

pub fn sys_exit(code: usize) -> ! {
    sys_call(SyscallId::Exit, code, 0, 0, 0);
    loop {}
}

pub fn sys_read(fd: usize, base: *const u8, len: usize) -> i64 {
    sys_call(SyscallId::Read, fd, base as usize, len, 0)
}

pub fn sys_exec(path: *const u8) {
    sys_call(SyscallId::Exec, path as usize, 0, 0, 0);
}

pub fn sys_fork() -> Tid {
    sys_call(SyscallId::Fork, 0, 0, 0, 0)
}

pub fn set_priority(pri:usize) {
    sys_call(SyscallId::SetPriorty,pri,0,0,0);
}

pub fn sys_gettime() -> usize {
    sys_call(SyscallId::GetTime,0,0,0,0) as usize
}

pub fn sys_pipe(pipefd: &mut[i32; 2]) -> i64 {
    let result = sys_call(SyscallId::Pipe,0,0,0,0) as u64;
    pipefd[0] = ((result & (((-1 as i32) as u32 as u64) << 32)) >> 32) as i32;
    pipefd[1] = (result & ((-1 as i32) as u32 as u64)) as i32;
    result as i64
}

