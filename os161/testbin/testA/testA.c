#include <stdio.h>

int main() {
    int ret = printint(5);
    printint(ret);

    ret = reversestring("hello", 5);
    printint(ret);

    _exit(0);
}