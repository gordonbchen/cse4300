#include <stdio.h>
#include <stdlib.h>

size_t get_size(int xs[]) {
    // Wrong b/c xs is a pointer.
    return sizeof(xs);
}

int main() {
    int x = 0;
    printf("%ld %ld %ld %ld\n", sizeof(int), sizeof(x), sizeof(char), sizeof(&x));

    int xs[10] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
    printf("%ld %ld\n", sizeof(xs), get_size(xs));

    printf("%ld\n", sizeof(xs)/sizeof(xs[0]));

    int* nums = malloc(sizeof(int) * 8);
    if (nums == NULL) {
        exit(1);
    }
    for (int i = 0; i < 8; ++i) {
        printf("%d ", nums[i]);
    }
    putchar('\n');

    free(nums);
    nums = NULL;

    for (int i = 0; i < 10; ++i) {
        printf("%d ", *(xs+i));
    }
    putchar('\n');
}

// Memory diagram
// Stack (growing down), stack frames (memory for function calls, ie locals, destroyed after function)
// Heap (growing up), dynamically allocated memory (malloc)
// Data segment: globals and statics
// Program code
