#include <stdio.h>

void change_fail(int x) {
    x = 69;
}

void real_change(int* x) {
    *x = 69;
}

int main() {
    int x = 0;
    printf("x=%d\n", x);
    change_fail(x);
    printf("x=%d\n", x);
    real_change(&x);
    printf("x=%d\n", x);

    printf("&x=%p\n", (void*)&x);
}
