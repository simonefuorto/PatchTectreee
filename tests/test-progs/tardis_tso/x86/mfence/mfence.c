/** Simple program to test mfence for X86
 */

#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

#define N_THREADS 4

// Variabili condivise tra i thread
int shared_variable = 0;

// Funzione eseguita dai thread
void *thread_function(void *arg) {
    int thread_id = *(int *)arg;

    for (int i = 0; i < 10; ++i) {
		__asm__ __volatile__ ("mfence" ::: "memory");
		shared_variable += thread_id;
	}
	
    printf("Thread %d ha completato l'incremento.\n", thread_id);
    pthread_exit(NULL);
}

int main() {
	pthread_t threads[N_THREADS];
	for(int i=0; i<N_THREADS; i++){
		if(pthread_create(&threads[i], NULL, thread_function, (void *)&i) != 0){
			printf("Failed to create thread\n");
            return 1;
		}
	}
	
	for(int i=0; i<N_THREADS; i++){
		if (pthread_join(threads[i], NULL) != 0) {
            printf("Failed to join thread\ns");
            return 1;
        }
	}
	
    // Stampa il valore finale della variabile condivisa
    printf("Valore finale della variabile condivisa: %d\n", shared_variable);

    return 0;
}