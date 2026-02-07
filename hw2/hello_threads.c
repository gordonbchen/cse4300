#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define N_THREADS 1000

pthread_mutex_t sum_mutex = PTHREAD_MUTEX_INITIALIZER;
int sum = 0;

void die(char* str) {
    perror(str);
    exit(1);
}

void* worker(void* arg) {
    int id = *(int*)arg;
    for (int i = 0; i < 1000; ++i) {
        usleep(1);
        pthread_mutex_lock(&sum_mutex);
        ++sum;
        pthread_mutex_unlock(&sum_mutex);
    }
    return NULL;
}

int main() {
    pthread_t threads[N_THREADS];
    int ids[N_THREADS];

    for (int i = 0; i < N_THREADS; ++i) {
        ids[i] = i;
        if (pthread_create(threads+i, NULL, worker, ids+i) != 0) die("pthread_create");
    }

    for (int i = 0; i < N_THREADS; ++i) {
        if (pthread_join(threads[i], NULL) != 0) die("pthread_join");
    }

    printf("sum = %d\n", sum);
}
