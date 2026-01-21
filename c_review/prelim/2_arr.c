#include <stdio.h>

int main() {
    char s[] = {'h', 'i', '\0'};
    printf("%s\n", s);

    int xs[10] = {0};
    for (int i = 0; i < 10; ++i) {
        printf("%d ", xs[i]);
    }
    putchar('\n');
}
