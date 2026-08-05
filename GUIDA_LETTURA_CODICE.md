# Guida Architetturale e Mappa del Codice: TARDIS-TSO Tectree

Il presente documento fornisce una mappa strutturata per agevolare la revisione del codice sorgente relativo all'integrazione della topologia **Tectree** nel protocollo di coerenza **TARDIS-TSO** (implementato in gem5 Ruby).
L'intervento architetturale si divide in tre macro-aree: la gestione asincrona degli stalli nella Directory (State Bouncing), l'introduzione di policy MRU topology-aware nella Cache LLC e lo stress testing automatizzato.

Per facilitare la navigazione nel repository, i punti chiave del codice sono stati marcati con dei tag di ricerca specifici (es. `[REF: NOME_TAG]`). È sufficiente cercare il tag all'interno del file indicato per individuare l'esatta implementazione.

----------------------------------------------------------------------------------------------------------

## 1. Matematica del Tectree e Topologia (Tree Math)
La base architetturale del progetto è la modellazione matematica dell'albero crittografico, indispensabile per permettere alla macchina a stati di navigare la complessa geometria del Tectree.

### A. Funzioni di Supporto C++
**File di riferimento:** `src/mem/ruby/slicc_interface/RubySlicc_Util.hh` (e `src/mem/ruby/protocol/RubySlicc_Types.sm`)
***[REF: TREE_MATH]**: Sono state implementate funzioni matematiche in C++ (come `getParentAddr`, `isMetadataAddr`, e i calcolatori di offset per i livelli L1-L7). Queste funzioni calcolano "al volo" l'indirizzo fisico del contatore genitore partendo da un blocco Dati. Vengono esposte al protocollo tramite `RubySlicc_Types.sm` per essere utilizzate da SLICC.

### B. Implementazione Root Array On-Chip
**File di riferimento:** `src/learning_gem5/tardis_tso_tectree/TARDISTSO_TECTREE-dir.sm`
***[REF: ROOT_ARRAY_LOGIC]**: La Root globale è stata trasformata in un costrutto architetturale realistico basato su tre registri indipendenti concatenati. Le funzioni `getFirstMissingParent()` e `getL6Index()` (definite nell'header) assieme all'azione `incrementRootCounter` implementano il partizionamento matematico dello spazio di indirizzamento, garantendo un aggiornamento realistico della Root.

----------------------------------------------------------------------------------------------------------

## 2. Modifiche al Protocollo SLICC (Macchina a Stati)
Il nucleo dell'innovazione risiede nella gestione avanzata e asincrona dei metadati crittografici (Counter) tra LLC e Directory.

**File di riferimento:** `src/learning_gem5/tardis_tso_tectree/TARDISTSO_TECTREE-dir.sm`

### A. Gestione Asincrona degli Stalli (State Bouncing)
Per prevenire il deadlock della pipeline causato dall'assenza di un contatore crittografico genitore (Event:Auth Miss), è stata introdotta la tabella delle transazioni pendenti `AuthTBEs` accoppiata a stati di stallo transitori.
***[REF: STATE_BOUNCING]**: Implementazione degli stati `I_Fetch_Auth`, `S_Fetch_Auth` e `I_Evict_Auth`. Quando la dipendenza viene risolta, il sistema C++ risveglia la coda riattivando la transizione originale e completando il ciclo in modo asincrono.

### B. Aggiornamento dei Metadati (Minimizzazione del Traffico)
I counterChunk non vengono modificati ad ogni scrittura del dato in cache, ma esclusivamente al momento del suo writeback in memoria principale.
*   **[REF: METADATA_UPDATE]**: L'azione `incrementCounter` viene richiamata selettivamente solo durante le transizioni di sfratto (es. `LLC_Repl_Dirty`), forzando il cambio di stato da `C_V`(Contatore Allocato) a `C_M`(Counter Modified) in un'unica operazione cumulativa (Lazy Update).

----------------------------------------------------------------------------------------------------------

## 3. Estensioni C++ Core (Policy)
Le modifiche al backend C++ di Ruby permettono l'iniezione delle politiche di sostituzione modificate.

### A. Policy di Rimpiazzo MRU (Topology-Aware)
- **File di riferimento:** `src/mem/ruby/structures/CacheMemory.cc`
*   **[REF: TECTREE_MRU_POLICY]**: All'interno del metodo `setMRU()`, la logica è stata differenziata in base al flag `mru_policy`:
    *   `0`: Protezione Strict (Baseline teorica).
    *   `1`: Policy Standard (LRU tradizionale senza priorità).
    *   `2`: Policy Tectree Ottimizzata, che utilizza un approccio probabilistico basato su modulo per proteggere statisticamente i contatori in base alla loro criticità nell'albero crittografico.

**NOTA: Attivare qualsiasi test automatizzato con il flag mru_policy=2 potrebbe introdurre all'interno del sistema una fonte di non determinismo, si consigliano pertanto per questa particolare policy prove ripetute.**

----------------------------------------------------------------------------------------------------------

## 4. Configurazione e Validazione

### A. Iniezione Topologica (Python)
- **File di riferimento:** `configs/ruby/TARDISTSO_TECTREE.py`
*   **[REF: PYTHON_CONFIGS]**: Inserimento dei registri Root fisici e del binding del parametro `mru_policy` a livello di simulatore per permettere diversi esperimenti con diverse dimensioni del componente LLC e della policy senza dover ricompilare tutto il progetto.

### B. Metodologia di Microbenchmarking e Test (Automazione)
I carichi di lavoro (workload) per validare l'architettura sono contenuti sotto la directory `tests/test-progs/tardis_tso/x86/`. Per agevolare l'estrazione e il confronto dei dati statistici generati da gem5 (come i miss rate o il traffico di rete), l'esecuzione dei test è stata completamente automatizzata tramite una suite di script bash numerati all'interno della cartella `script_run/`.

Tutti i risultati e le metriche di simulazione verranno salvati nei file `stats.txt` generati automaticamente dal simulatore, localizzabili all'interno della cartella `m5out/` di gem5 (i percorsi esatti dipendono dallo script eseguito).

Di seguito il dettaglio dei 4 script di test:

#### 1. Stress Test: Radix Sweep (Size)
- **Cosa fa:** Esegue il benchmark **[REF: TEST_RADIX]** (un algoritmo di Radix Sort multi-thread ispirato a SPLASH) variando la dimensione dell'array dati (Piccolo 16k, Medio 64k, Grande 131k). Fornisce un traffico di memoria realistico ed eterogeneo per valutare la resilienza del Tectree.
- **Comando di esecuzione:** `./script_run/4.run_radix_sweep.sh`
- **Risultati:** Le statistiche vengono salvate in `gem5/m5out/radix_sweep_<DIMENSIONE>/stats.txt`.

#### 2. Stress Test: Radix Sweep (Policy)
- **Cosa fa:** Esegue lo stesso benchmark Radix, ma questa volta spazzola le **3 Policy MRU** sviluppate in questo progetto (0 = Strict Baseline, 1 = Standard LRU, 2 = Randomizzato Tectree Ottimizzato) incrociandole con le dimensioni dell'array.
- **Comando di esecuzione:** `./script_run/5.run_policies_sweep.sh`
- **Risultati:** Le statistiche vengono salvate in `gem5/m5out/radix_sweep_policy_<POLICY>_size_<DIMENSIONE>/stats.txt`.

#### 3. Stress Test Estremo: Thrashing (Cache L2 Sweep)
- **Cosa fa:** Esegue il microbenchmark sintetico **[REF: TEST_THRASHING]** (`force_eviction.c`). Questo test alloca un array da 4MB e lo accede con un pattern a stride (64 Byte) per forzare l'evizione sistematica dei dati e dei contatori crittografici (essendo più grande della LLC). Lo script varia la dimensione della Cache L2 (da 64kB a 1MB) e incrocia le 3 Policy MRU per misurare le performance di ritenzione sotto stress estremo.
- **Comando di esecuzione:** `./script_run/6.run_l2_sweep.sh`
- **Risultati:** Le statistiche vengono salvate in `gem5/m5out/thrashing_l2_<DIMENSIONE_L2>_policy_<POLICY>/stats.txt`.

#### 4. Validazione: Microbenchmarks (Ping Pong, Streaming)
- **Cosa fa:** Esegue una suite di microbenchmarks C più piccoli (`ping_pong`, `sweet_spot`, `streaming`) studiati per validare scenari di sharing specifici (es. due core che si rimbalzano una singola cache line) e verificare l'assenza di deadlock.
- **Comando di esecuzione:** `./script_run/7.run_microbenchmarks.sh`
- **Risultati:** Le statistiche vengono salvate singolarmente in `gem5/m5out/<NOME_BENCHMARK>/stats.txt`.
