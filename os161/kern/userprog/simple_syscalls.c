#include <types.h>
#include <syscall.h>
#include <thread.h>
#include <lib.h>

void _exit(int exitCode) {
    kprintf("_exit exitCode: %d\n", exitCode);
    thread_exit(exitCode);
    panic("_exit failed to kill thread\n");
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