#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

// Spinlock definition
typedef struct {
    volatile int flag;
} spinlock_t;

// Spinlock initialization
void spinlock_init(spinlock_t *lock) {
    lock->flag = 0;
}

// Spinlock acquire
void spinlock_acquire(spinlock_t *lock) {
    while (__sync_lock_test_and_set(&lock->flag, 1)) {
        // Spin-wait (busy-wait) until the lock is acquired
    }
}

// Spinlock release
void spinlock_release(spinlock_t *lock) {
    __sync_lock_release(&lock->flag);
}

#define NUM_THREADS 4
#define NUM_ITERATIONS 1000

spinlock_t lock;
int counter = 0;

// Thread function to increment the counter
void* thread_function(void* arg) {
    for (int i = 0; i < NUM_ITERATIONS; ++i) {
        spinlock_acquire(&lock);
        ++counter;
        spinlock_release(&lock);
    }
    return NULL;
}

int main() {
    pthread_t threads[NUM_THREADS];

    // Initialize the spinlock
    spinlock_init(&lock);

    // Create threads
    for (int i = 0; i < NUM_THREADS; ++i) {
        if (pthread_create(&threads[i], NULL, thread_function, NULL) != 0) {
            printf("Failed to create thread");
            return 1;
        }
    }

    // Wait for all threads to finish
    for (int i = 0; i < NUM_THREADS; ++i) {
        if (pthread_join(threads[i], NULL) != 0) {
            printf("Failed to join thread");
            return 1;
        }
    }

    // Print the final value of the counter
    printf("Final counter value: %d\n", counter);

    return 0;
}
