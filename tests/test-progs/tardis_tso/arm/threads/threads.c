/** Simple program to test ARM's dsb
 */
#include <stdio.h>
#include <pthread.h>


typedef struct ThreadData {
    int *a;
    int *b;
    int *c;
    int tid;
    int threads;
    int num_values;
}ThreadData_t;

/*
 * c = a + b
 */
void *array_add(void *arg)
{
    ThreadData_t *data = (ThreadData_t *)arg;

    // Calcolo dell'indice di partenza e lo step per il thread corrente
    int start_index = data->tid;
    int step = data->threads;

    // Somma gli elementi degli array a e b e scrivi il risultato in c
    for (int i = start_index; i < data->num_values; i += step) {
        data->c[i] = data->a[i] + data->b[i];
    }

    pthread_exit(NULL);
}


int main(int argc, char *argv[])
{
	const int num_values = 10;
	pthread_t thread1, thread2;
    int thread_id1 = 1, thread_id2 = 2;
	
	int a[num_values];
	int b[num_values];
	int c[num_values];
	
    for (int i = 0; i < num_values; i++) {
        a[i] = i;
        b[i] = num_values - i;
        c[i] = 0;
    }
	
	ThreadData_t data1 = {a, b, c, 0, 2, num_values};
    ThreadData_t data2 = {a, b, c, 1, 2, num_values};
	
    // Crea due thread
    pthread_create(&thread1, NULL, array_add, (void *)&data1);
    pthread_create(&thread2, NULL, array_add, (void *)&data2);

    // Attendi la terminazione dei thread
    pthread_join(thread1, NULL);
    pthread_join(thread2, NULL);
    
	return 0;
}
