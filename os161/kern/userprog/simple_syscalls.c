#include <types.h>
#include <syscall.h>
#include <thread.h>
#include <lib.h>

void sys__exit(int exitCode) {
    kprintf("sys__exit exitCode: %d\n", exitCode);
    thread_exit(exitCode);
}