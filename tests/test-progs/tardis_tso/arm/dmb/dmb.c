/** Simple program to test ARM's coherence protocol
 */
#include <stdio.h>
#include <pthread.h>

#define N_THREADS 16

int shared_variable = 0;

void *thread_function(void *arg) {
    int thread_id = *((int *)arg);

    // Incrementa la variabile condivisa
    for (int i = 0; i < 10; ++i) {
		
        shared_variable++;
        __asm__ __volatile__("dmb sy");
    }

    printf("Thread %d ha completato l'incremento.\n", thread_id);
    pthread_exit(NULL);
}

int main() {
	pthread_t threads[N_THREADS];
	
	for(int i=0; i<N_THREADS; i++){
		pthread_create(&threads[i], NULL, thread_function, (void *)&i);
	}
	
	for(int i=0; i<N_THREADS; i++){
		pthread_join(threads[i], NULL);
	}
	
    // Stampa il valore finale della variabile condivisa
    printf("Valore finale della variabile condivisa: %d\n", shared_variable);

    return 0;
}