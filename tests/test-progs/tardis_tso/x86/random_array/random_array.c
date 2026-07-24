#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

#define ARRAY_SIZE   (256*256)  // Dimensione dell'array
#define NUM_THREADS  4            // Numero di thread
#define ITERATIONS   100        // Numero di iterazioni del loop esterno

// Array condiviso: dichiarato volatile per evitare ottimizzazioni eccessive.
volatile int *shared_array;

typedef struct {
    int thread_id;
    int start_index;
    int end_index;
} thread_arg_t;

void* workload_array(void *arg) {
    thread_arg_t *targ = (thread_arg_t *) arg;
    int tid = targ->thread_id;
    int start = targ->start_index;
    int end = targ->end_index;

    for (int iter = 0; iter < ITERATIONS; iter++) {
        // Ogni thread aggiorna la propria porzione dell'array
        for (int i = start; i < end; i++) {
            shared_array[i]++;  // Incremento semplice
        }

        // Accesso a porzioni globali per forzare trasferimenti/cache line invalidation:
        // Ad esempio, si legge ogni 256-esimo elemento.
        volatile int dummy = 0;
        for (int i = 0; i < ARRAY_SIZE; i += 256) {
            dummy += shared_array[i];
        }

        // Stampa periodica (solo thread 0) per monitorare l'andamento
        if (tid == 0 && iter % 1000 == 0) {
            printf("Thread %d: Iterazione %d, dummy=%d\n", tid, iter, dummy);
        }
    }
    return NULL;
}

int main() {
    pthread_t threads[NUM_THREADS];
    thread_arg_t thread_args[NUM_THREADS];

    // Allocazione e inizializzazione dell'array condiviso
    shared_array = malloc(sizeof(int) * ARRAY_SIZE);
    if (shared_array == NULL) {
        perror("malloc");
        exit(EXIT_FAILURE);
    }
    for (int i = 0; i < ARRAY_SIZE; i++) {
        shared_array[i] = 0;
    }

    // Calcolo del range per ogni thread
    int chunk_size = ARRAY_SIZE / NUM_THREADS;
    for (int t = 0; t < NUM_THREADS; t++) {
        thread_args[t].thread_id   = t;
        thread_args[t].start_index = t * chunk_size;
        // L'ultimo thread prende anche eventuali elementi in più
        thread_args[t].end_index   = (t == NUM_THREADS - 1) ? ARRAY_SIZE : (t + 1) * chunk_size;
        pthread_create(&threads[t], NULL, workload_array, &thread_args[t]);
    }

    // Attesa della terminazione di tutti i thread
    for (int t = 0; t < NUM_THREADS; t++) {
        pthread_join(threads[t], NULL);
    }

    free((void *)shared_array);
    return 0;
}
