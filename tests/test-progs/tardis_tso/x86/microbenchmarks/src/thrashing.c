#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <gem5/m5ops.h>

// 64 MegaByte Array
#define ARRAY_SIZE (64 * 1024 * 1024) 
// Salto di 512 Byte (Esattamente lo spazio coperto da un singolo Counter L1)
// Questo costringe la LLC a caricare un L1 Counter DIVERSO a ogni singolo accesso!
#define STRIDE 512 

int main() {
    printf("Allocating 64MB array for Thrashing Test...\n");
    // Usiamo calloc per forzare l'allocazione delle pagine in memoria fisica
    uint8_t *array = (uint8_t*)calloc(ARRAY_SIZE, sizeof(uint8_t));
    
    if (array == NULL) {
        printf("Memory allocation failed!\n");
        return 1;
    }

    printf("Starting Thrashing ROI...\n");
    
    // ================= REGION OF INTEREST (ROI) =================
    m5_dump_reset_stats(0, 0); // Inizio ROI

    // Scriviamo sull'array saltando di 512 byte alla volta.
    // Una Cache LLC da 2MB può contenere al massimo 32.768 blocchi.
    // Noi faremo 131.072 accessi distruttivi, spazzando via tutto!
    for (int i = 0; i < ARRAY_SIZE; i += STRIDE) {
        // Un'operazione di Scrittura sporca il Dato e innesca la catena crittografica (C_M)
        array[i] = (uint8_t)(i % 255); 
    }

    m5_dump_reset_stats(0, 0); // Fine ROI
    // ============================================================

    printf("Thrashing Test Completed.\n");
    free(array);
    return 0;
}
