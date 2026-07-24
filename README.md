# TARDISTSO_TECTREE: Implementazione in gem5

Questa repository contiene la patch per il simulatore architetturale **gem5** che integra il protocollo di integrità della memoria **TEC-Tree** all'interno del protocollo di coerenza **Tardis TSO**.
L'obiettivo è valutare l'impatto prestazionale, la gestione asincrona e i trade-off architetturali (Capacity Misses vs MSHR Bouncing) dei CounterChunks in LLC.

## 🚀 Progress Tracker (Checklist di Implementazione)

### FASE 1: Architettura Base e Bouncing Asincrono (COMPLETATA)
- [x] **STEP 1: Architettura CounterChunk in SLICC**
  - [x] Modifica dei tipi base e scalabilità memoria (Chunk da 64 byte).
  - [x] Adattamento di `CacheMemory` in `TARDISTSO_TECTREE-dir.sm`.
  - [x] Creazione azione `allocateCounterLLC` per bypassare l'inserimento in L1.
- [x] **STEP 2: Valutazione Prestazionale (Baseline)**
  - [x] Esecuzione microbenchmark: `ping_pong`, `sweet_spot`, `streaming`.
  - [x] Estrazione statistiche e comparazione con Tardis standard.
  - [x] Analisi architetturale: crollo dell'Hit Rate in LLC causato da *Capacity Misses* dovuti alla contesa di spazio tra Dati e CounterChunks.
- [x] **STEP 3: Gestione Asincrona e Non-Bloccante (State Bouncing)**
  - [x] Creazione struttura temporanea dedicata (`AuthTBE` / `AuthTBETable`) per mappare le letture asincrone dalla RAM senza bloccare la LLC.
  - [x] Definizione degli stati transitori di attesa (`I_Fetch_Auth`, `S_Fetch_Auth`, `E_Fetch_Auth`).
  - [x] Implementazione del "State Bouncing": `wakeUpAll` + `recycleRequestQueue` per gestire il raggruppamento (coalescing) dei duplicati e svuotare le code MSHR in modo deadlock-free.

### FASE 2: Writeback e Compressione (IN CORSO)
- [ ] **STEP 4: Cascading Writebacks (Evictions)**
  - [ ] Intercettazione degli eventi `LLC_Replacement` per lo stato `I` (Counter Valid / Counter Dirty).
  - [ ] Implementazione logica di Writeback asincrono verso la RAM per non perdere il valore aggiornato dei contatori.
- [ ] **STEP 5: Estensione alla Ricorsione Multilivello (L1 -> L2 -> L3)**
  - [ ] Implementazione del vero "Tree" per aumentare il rapporto di compressione dei metadati in LLC e mitigare i Capacity Misses scoperti nello Step 2.

### FASE 3: Verifica e Convalida Finale (DA FARE)
- [ ] **STEP 6: Analisi Statistica Finale**
  - [ ] Esecuzione finale dei benchmark.
  - [ ] Confronto conclusivo di Hit/Miss, latenza e traffico di rete tra Baseline, Tectree a 1 Livello e Tectree Multilivello.
  - [ ] Analisi di sensibilità alla Latenza Crittografica (AES-ECB nativo vs ideal-CTR).

