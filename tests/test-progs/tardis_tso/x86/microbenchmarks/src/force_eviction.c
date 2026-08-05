#include <stdio.h>
#include <stdlib.h>

// [REF: TEST_THRASHING]
// Scriviamo 4 MB di dati (65536 blocchi da 64 byte).
// Questo supererà non solo la L1 (1kB), ma anche la LLC (che è hardcoded a 2MB),
// forzando lo sfratto (LLC_Repl_Dirty) verso la MEMORIA e scatenando l'aggiornamento a cascata!
#define NUM_BLOCKS 65536
#define BLOCK_SIZE 64

int main() {
    volatile char* array = (volatile char*)malloc(NUM_BLOCKS * BLOCK_SIZE);
    if (!array) return -1;

    printf("Inizio ROI: Scrittura massiva per forzare sfratti da L1 e da LLC...\n");

    // Eseguiamo scritture
    for(int i = 0; i < NUM_BLOCKS; i++) {
        array[i * BLOCK_SIZE] = (char)(i % 256);
    }
    
    // Eseguiamo letture
    volatile char temp = 0;
    for(int i = 0; i < NUM_BLOCKS; i++) {
        temp += array[i * BLOCK_SIZE];
    }

    printf("Fine ROI. Dati letti: %d\n", temp);

    free((void*)array);
    return 0;
}
