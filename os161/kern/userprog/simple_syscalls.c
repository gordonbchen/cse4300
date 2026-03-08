#include <types.h>
#include <syscall.h>
#include <thread.h>
#include <lib.h>

void sys__exit(int exitCode) {
    kprintf("sys__exit exitCode: %d\n", exitCode);
    thread_exit(exitCode);
    panic("sys__exit failed to kill thread]n");
}

int printint(int c) {
    kprintf("%d\n", c);
    return (c % 5 != 0);
}

int reversestring(const char *str, int len) {
    --len;
    while (len >= 0) {
        kprintf("%c", *(str+len));
        --len;
    }
    kprintf("\n");
    return (len % 2 == 0);
}