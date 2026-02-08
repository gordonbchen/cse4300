#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

void die(char* str) {
    perror(str);
    exit(1);
}

int randint(int min, int max) {
    return (rand() % (max - min)) + min;
}

typedef struct {
    int id;
    int n_sleeps;
    int n_contribs;
} thread_info_t;


int N_PRODUCERS, N_CONSUMERS, N_ITEMS, QUEUE_SIZE;

int n_produced;
int n_consumed;

int* queue;
int queue_head;
int queue_tail;
int queue_len;

pthread_mutex_t queue_mutex = PTHREAD_MUTEX_INITIALIZER;
pthread_cond_t not_full = PTHREAD_COND_INITIALIZER;
pthread_cond_t not_empty = PTHREAD_COND_INITIALIZER;

void* producer(void* arg) {
    thread_info_t *thread_info = (thread_info_t*)arg;

    while (1) {
        usleep(randint(100, 1000));

        // Wait until queue has space.
        pthread_mutex_lock(&queue_mutex);
        while (queue_len == QUEUE_SIZE && n_produced < N_ITEMS) {
            ++(thread_info->n_sleeps);
            pthread_cond_wait(&not_full, &queue_mutex);
        }

        // Terminate if produced enough items.
        if (n_produced >= N_ITEMS) {
            pthread_cond_broadcast(&not_full);
            pthread_mutex_unlock(&queue_mutex);
            return NULL;
        }

        // Put item in queue.
        queue[queue_tail] = thread_info->id;
        queue_tail = (queue_tail + 1) % QUEUE_SIZE;
        ++queue_len;
        ++n_produced;
        ++(thread_info->n_contribs);

        // Wake up consumers.
        pthread_cond_broadcast(&not_empty);
        pthread_mutex_unlock(&queue_mutex);
    }
}

void* consumer(void* arg) {
    thread_info_t *thread_info = (thread_info_t*)arg;

    while (1) {
        usleep(randint(100, 1000));

        // Wait until item in queue.
        pthread_mutex_lock(&queue_mutex);
        while (queue_len == 0 && n_consumed < N_ITEMS) {
            ++(thread_info->n_sleeps);
            pthread_cond_wait(&not_empty, &queue_mutex);
        }

        // Terminate if consumed enough items.
        if (n_consumed >= N_ITEMS) {
            pthread_cond_broadcast(&not_empty);
            pthread_mutex_unlock(&queue_mutex);
            return NULL;
        }

        // Get item from queue.
        int producer_id = queue[queue_head];
        queue_head = (queue_head + 1) % QUEUE_SIZE;
        --queue_len;
        ++n_consumed;
        ++(thread_info->n_contribs);

        // Wake up producers.
        pthread_cond_broadcast(&not_full);
        pthread_mutex_unlock(&queue_mutex);
    }
}

int main(int argc, char* argv[]) {
    // Parse args.
    if (argc != 5) {
        printf("Usage: %s (# producers) (# consumers) (# items) (queue size) \n", argv[0]);
        exit(1);
    }
    N_PRODUCERS = atoi(argv[1]);
    N_CONSUMERS = atoi(argv[2]);
    N_ITEMS = atoi(argv[3]);
    QUEUE_SIZE = atoi(argv[4]);

    // Init queue.
    queue = malloc(sizeof(int) * QUEUE_SIZE);
    if (queue == NULL) die("malloc");
    queue_head = 0;
    queue_tail = 0;
    queue_len = 0;

    n_produced = 0;
    n_consumed = 0;

    // Create producers.
    pthread_t *producers = malloc(sizeof(pthread_t) * N_PRODUCERS);
    if (producers == NULL) die("malloc");

    thread_info_t *producer_info = malloc(sizeof(thread_info_t) * N_PRODUCERS);
    if (producer_info == NULL) die("malloc");

    for (int i = 0; i < N_PRODUCERS; ++i) {
        producer_info[i].id = i;
        producer_info[i].n_sleeps = 0;
        producer_info[i].n_contribs = 0;
        if (pthread_create(producers+i, NULL, producer, producer_info+i) != 0) die("pthread_create");
    }

    // Create consumers.
    pthread_t *consumers = malloc(sizeof(pthread_t) * N_CONSUMERS);
    if (consumers == NULL) die("malloc");

    thread_info_t *consumer_info = malloc(sizeof(thread_info_t) * N_CONSUMERS);
    if (consumer_info == NULL) die("malloc");

    for (int i = 0; i < N_CONSUMERS; ++i) {
        consumer_info[i].id = i;
        consumer_info[i].n_sleeps = 0;
        consumer_info[i].n_contribs = 0;
        if (pthread_create(consumers+i, NULL, consumer, consumer_info+i) != 0) die("pthread_create");
    }

    // Terminate producers and consumers.
    for (int i = 0; i < N_PRODUCERS; ++i) {
        if (pthread_join(producers[i], NULL) != 0) die("pthread_join");
    }
    for (int i = 0; i < N_CONSUMERS; ++i) {
        if (pthread_join(consumers[i], NULL) != 0) die("pthread_join");
    }

    for (int i = 0; i < N_PRODUCERS; ++i) {
        printf("producer %d: %d sleeps, %d contribs\n", producer_info[i].id, producer_info[i].n_sleeps, producer_info[i].n_contribs);
    }
    for (int i = 0; i < N_CONSUMERS; ++i) {
        printf("consumer %d: %d sleeps, %d contribs\n", consumer_info[i].id, consumer_info[i].n_sleeps, consumer_info[i].n_contribs);
    }

    free(queue);
    free(producers);
    free(producer_info);
    free(consumers);
    free(consumer_info);
}
