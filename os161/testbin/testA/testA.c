#include <stdio.h>

int main() {
    int ret = printint(5);
    printint(ret);  // 0 (divisible by 5).

    ret = printint(6);
    printint(ret);  // 1.

    ret = reversestring("hello", 5);
    printint(ret);  // 0 (not divisible by 2).

    ret = reversestring("hell", 4);
    printint(ret);  // 1.

    _exit(0);
}