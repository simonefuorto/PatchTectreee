#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

#define NUM_THREADS 4
#define ITERATIONS 1000

typedef struct {
    volatile int a;
    volatile int b;
} shared_data_t;

shared_data_t shared_data;

void* workload_false_sharing(void* arg) {
    int thread_id = *(int*)arg;

    for (int i = 0; i < ITERATIONS; i++) {
        if (thread_id % 2 == 0) {
            __atomic_fetch_add(&shared_data.a, 1, __ATOMIC_SEQ_CST);
        } else {
            __atomic_fetch_add(&shared_data.b, 1, __ATOMIC_SEQ_CST);
        }
    }

    return NULL;
}

int main() {
    pthread_t threads[NUM_THREADS];
    int thread_ids[NUM_THREADS];

    for (int i = 0; i < NUM_THREADS; i++) {
        thread_ids[i] = i;
        pthread_create(&threads[i], NULL, workload_false_sharing, &thread_ids[i]);
    }

    for (int i = 0; i < NUM_THREADS; i++) {
        pthread_join(threads[i], NULL);
    }

    printf("Risultati: a=%d, b=%d\n", shared_data.a, shared_data.b);
    return 0;
}
