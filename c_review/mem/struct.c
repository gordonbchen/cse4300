#include <stdio.h>
#include <string.h>

struct coord {
    int x;
    int y;
};

void print_coord(struct coord* c) {
    printf("(%d, %d)\n", c->x, c->y);
}

typedef struct Person {
    char name[32];
    int age;
    char gender;
} TPerson;

void bday(TPerson* p) {
    ++(p->age);
}

void print_person(TPerson* p) {
    printf("%s, %d, %c\n", p->name, p->age, p->gender);
}

int main() {
    struct coord c;
    c.x = 10;
    c.y = 20;
    print_coord(&c);

    struct coord c2 = {1, 2};
    print_coord(&c2);

    TPerson p = {"Gordon", 19, 'M'};
    print_person(&p);
    bday(&p);
    print_person(&p);

    TPerson p2;
    strncpy(p2.name, "Gordon", sizeof(p2.name));
    p2.name[sizeof(p2.name) - 1] = '\0';
    p2.age = 69;
    p2.gender = 'M';
    print_person(&p2);
}
