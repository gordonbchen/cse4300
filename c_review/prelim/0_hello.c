#include <stdio.h>

#define MIN(x,y) (x<y ? x : y)

int main() {
    printf("Hello world!\n");

    for (int i = 0; i < 10; ++i) {
        printf("%d", i);
    }
    putchar('\n');

    char s[] = "hello";
    printf("%s%c\n", s, 'w');

    if (s[0] == 'h') {
        printf("starts with h\n");
    }
    else {
        printf("doesn't start with h\n");
    }

    int i = 5;
    while (i != 1) {
        printf("%d ", i);
        if (i % 2 == 0) {
            i = i / 2;
        }
        else {
            i = 3 * i + 1;
        }
    }
    printf("%d \n", i);

    switch (i) {
        case 0: {
            printf("its a me a 0!");
            break;
        }
        default: {
            printf("%d\n", i);
        }
    }

    printf("%d\n", MIN(2, 1));

    printf("%d\n", (int) 3.14);
    return 0;
}
