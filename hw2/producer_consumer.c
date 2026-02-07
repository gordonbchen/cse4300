#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

void die(char* str) {
    perror(str);
    exit(1);
}


int N_PACKETS, N_PRODUCERS, N_CONSUMERS;

int avail_packets;
int curr_producer_id;

int* packets;
int packet_head;
int packet_tail;

pthread_mutex_t packet_mutex = PTHREAD_MUTEX_INITIALIZER;
pthread_cond_t not_full = PTHREAD_COND_INITIALIZER;
pthread_cond_t not_empty = PTHREAD_COND_INITIALIZER;

void* producer(void* arg) {
    int id = *(int*)arg;
    usleep(10000 + 10000*(id*1000 % 5));

    // Wait until there is an available packet and it is the thread's turn to produce.
    pthread_mutex_lock(&packet_mutex);
    while (avail_packets == 0 || curr_producer_id != id) {
        printf("No packet available or not my turn to produce, user level thread %d going to sleep\n", id);
        pthread_cond_wait(&not_full, &packet_mutex);
    }

    // Put an item into the packet.
    printf("User level thread %d is going to put data in a packet\n", id);
    packets[packet_tail] = id;
    packet_tail = (packet_tail + 1) % N_PACKETS;
    --avail_packets;
    ++curr_producer_id;

    // Wake up consumers.
    pthread_cond_broadcast(&not_empty);
    pthread_mutex_unlock(&packet_mutex);
    return NULL;
}

void* consumer(void* arg) {
    int id = *(int*)arg;

    while (1) {
        usleep(10000 + 10000*(id*1000 % 5));

        // Wait for data (not every packet is available).
        pthread_mutex_lock(&packet_mutex);
        while (avail_packets == N_PACKETS) {
            // Terminate if no more producers.
            if (curr_producer_id == N_PRODUCERS + 1) {
                pthread_mutex_unlock(&packet_mutex);
                return NULL;
            }

            printf("No data available, Going to sleep kernel thread %d\n", id);
            pthread_cond_wait(&not_empty, &packet_mutex);
        }

        // Get an item from a packet.
        int served_id = packets[packet_head];
        printf("user thread %d getting served\n", served_id);
        packet_head = (packet_head + 1) % N_PACKETS;
        ++avail_packets;

        // Wake up producers.
        pthread_cond_broadcast(&not_full);
        pthread_mutex_unlock(&packet_mutex);
    }
}

int main(int argc, char* argv[]) {
    // Parse args.
    if (argc != 4) {
        printf("Usage: %s (# packets) (# producers) (# consumers)\n", argv[0]);
        exit(1);
    }
    N_PACKETS = atoi(argv[1]);
    N_PRODUCERS = atoi(argv[2]);
    N_CONSUMERS = atoi(argv[3]);

    // Init packets.
    avail_packets = N_PACKETS;
    curr_producer_id = 1;

    packets = malloc(sizeof(int) * N_PACKETS);
    if (packets == NULL) die("malloc");
    packet_head = 0;
    packet_tail = 0;

    // Create producers.
    pthread_t *producers = malloc(sizeof(pthread_t) * N_PRODUCERS);
    if (producers == NULL) die("malloc");

    int *producer_ids = malloc(sizeof(int) * N_PRODUCERS);
    if (producer_ids == NULL) die("malloc");

    for (int i = 0; i < N_PRODUCERS; ++i) {
        producer_ids[i] = i+1;
        if (pthread_create(producers+i, NULL, producer, producer_ids+i) != 0) die("pthread_create");
    }

    // Create consumers.
    pthread_t *consumers = malloc(sizeof(pthread_t) * N_CONSUMERS);
    if (consumers == NULL) die("malloc");

    int *consumer_ids = malloc(sizeof(int) * N_CONSUMERS);
    if (consumer_ids == NULL) die("malloc");

    for (int i = 0; i < N_CONSUMERS; ++i) {
        consumer_ids[i] = i+1;
        if (pthread_create(consumers+i, NULL, consumer, consumer_ids+i) != 0) die("pthread_create");
    }

    // Terminate producers and consumers.
    for (int i = 0; i < N_PRODUCERS; ++i) {
        if (pthread_join(producers[i], NULL) != 0) die("pthread_join");
    }
    for (int i = 0; i < N_CONSUMERS; ++i) {
        if (pthread_join(consumers[i], NULL) != 0) die("pthread_join");
    }

    free(packets);
    free(producers);
    free(producer_ids);
    free(consumers);
    free(consumer_ids);
}
