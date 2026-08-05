# Guida Architetturale e Mappa del Codice: TARDIS-TSO Tectree

Il presente documento fornisce una mappa strutturata per agevolare la revisione del codice sorgente relativo all'integrazione della topologia **Tectree** nel protocollo di coerenza **TARDIS-TSO** (implementato in gem5 Ruby).
L'intervento architetturale si divide in tre macro-aree: la gestione asincrona degli stalli nella Directory (State Bouncing), l'introduzione di policy MRU topology-aware nella Cache LLC e lo stress testing automatizzato.

Per facilitare la navigazione nel repository, i punti chiave del codice sono stati marcati con dei tag di ricerca specifici (es. `[REF: NOME_TAG]`). È sufficiente cercare il tag all'interno del file indicato per individuare l'esatta implementazione.

----------------------------------------------------------------------------------------------------------

## 1. Modifiche al Protocollo SLICC (Macchina a Stati)
Il nucleo dell'innovazione risiede nella fusione concettuale tra LLC e Directory, con particolare focus sulla gestione dei metadati crittografici (Counter).

**File di riferimento:** `src/learning_gem5/tardis_tso_tectree/TARDISTSO_TECTREE-dir.sm`

### A. Gestione Asincrona degli Stalli (State Bouncing)
Per prevenire il deadlock della pipeline causato dall'assenza di un contatore crittografico genitore (Event:Auth Miss), è stata introdotta la tabella delle transazioni pendenti `AuthTBEs` accoppiata a stati di stallo transitori.

***[REF: STATE_BOUNCING]**: Implementazione degli stati `I_Fetch_Auth`, `S_Fetch_Auth` e `I_Evict_Auth`. Quando la dipendenza viene risolta, il sistema C++ risveglia la coda riattivando la transizione originale e completando il ciclo in modo asincrono.

### B. Aggiornamento dei Metadati (Minimizzazione del Traffico)
I counterChunk non vengono modificati ad ogni scrittura del dato in cache, ma esclusivamente al momento del suo writeback in memoria.
***[REF: METADATA_UPDATE]**: L'azione `incrementCounter` viene richiamata selettivamente solo durante le transizioni di sfratto (es. `LLC_Repl_Dirty`), forzando il cambio di stato da `C_V`(Contatore Allocato) a `C_M`(Counter Modified) in un'unica operazione cumulativa.

### C. Implementazione Root Array On-Chip
La Root globale è stata trasformata in un costrutto architetturale realistico basato su tre registri indipendenti concatenati.
*   **[REF: ROOT_ARRAY_LOGIC]**: La funzione `getL6Index` e l'azione `incrementRootCounter` implementano il partizionamento matematico dello spazio di indirizzamento, garantendo un aggiornamento bilanciato della Root.


## 2. Estensioni C++ Core (Policy e WakeUp)
Le modifiche al backend C++ di Ruby permettono l'interfacciamento con SLICC e l'iniezione delle politiche di sostituzione modificate.

### A. WakeUp Bridge
📍 **File di riferimento:** `src/learning_gem5/tardis_tso_tectree/TARDISTSO_TECTREE_DirController.cc`
*   **[REF: WAKEUP_BRIDGE]**: Implementazione delle chiamate di sblocco (wakeUp and stall) della message queue che innescano il risveglio degli stati di parcheggio (State Bouncing) in SLICC.

### B. Policy di Rimpiazzo MRU (Topology-Aware)
📍 **File di riferimento:** `src/mem/ruby/structures/CacheMemory.cc`
*   **[REF: TECTREE_MRU_POLICY]**: All'interno del metodo `setMRU()`, la logica è stata differenziata in base al flag `mru_policy`:
    *   `0`: Protezione Strict (Baseline teorica).
    *   `1`: Policy Standard (LRU tradizionale senza priorità).
    *   `2`: Policy Tectree Ottimizzata, che utilizza un approccio probabilistico basato su modulo per proteggere statisticamente i contatori in base alla loro criticità nell'albero crittografico.

### C. Topologia e Matematica dell'Albero (Tree Math)
📍 **File di riferimento:** `src/mem/ruby/slicc_interface/RubySlicc_Util.hh` (e `src/mem/ruby/protocol/RubySlicc_Types.sm`)
*   **[REF: TREE_MATH]**: Per far sì che la macchina a stati comprenda la complessa geometria dell'albero crittografico, sono state implementate delle funzioni matematiche in C++ (come `getParentAddr`, `isMetadataAddr`, e i calcolatori di offset per i livelli L1-L7). Queste funzioni calcolano "al volo" l'indirizzo fisico del contatore genitore partendo da un blocco Dati. Sono poi interfacciate al protocollo tramite `RubySlicc_Types.sm` e vengono usate estensivamente dalle funzioni interne di SLICC `getFirstMissingParent()` e `getL6Index()` (definite nell'header di `TARDISTSO_TECTREE-dir.sm`).

**NOTA: Attivare qualsiasi test automatizzato con il flag mru_policy=2 potrebbe introdurre all interno del sistema una fonte di non determinismo, si consigliano pertanto per questa particolare policy prove ripetute**

----------------------------------------------------------------------------------------------------------

## 3. Configurazione e Validazione

### A. Iniezione Topologica (Python)
📍 **File di riferimento:** `configs/ruby/TARDISTSO_TECTREE.py`
*   **[REF: PYTHON_CONFIGS]**: Inserimento dei registri Root fisici e del binding del parametro `mru_policy` a livello di simulatore per permettere diversi esperimenti con diverse dimensioni del componente LLC e della policy senza dover ricompilare tutto il progetto.

### B. Metodologia di Microbenchmarking e Test
I carichi di lavoro (workload) per validare l'architettura sono contenuti sotto la directory `tests/test-progs/tardis_tso/x86/`. Per eseguire questi test in gem5, il binario cross-compilato viene passato come argomento (tramite flag `--cmd`) agli script di configurazione Python (che caricheranno a loro volta `TARDISTSO_TECTREE.py`). I grafici finali vengono poi generati dagli script `plot_radix.py` e `plot_l2_thrashing.py`.

📍 **Thrashing / Force Eviction:** `tests/test-progs/tardis_tso/x86/microbenchmarks/src/force_eviction.c`
*   **[REF: TEST_THRASHING]**: Questo esperimento C è stato ingegnerizzato per allocare grandi array (es. 64MB) con un pattern di accesso a stride di 512 Byte (allineato alla granularità dei contatori L1). Generando migliaia di accessi distruttivi, il microbenchmark satura deliberatamente la LLC innescando un fenomeno di "Thrashing" severo. Questo approccio isola e quantifica matematicamente l'efficienza delle 3 policy di rimpiazzo (MRU) sotto stress estremo.

📍 **Radix Benchmark (radix_bm):** `tests/test-progs/tardis_tso/x86/radix_bm/`
*   **[REF: TEST_RADIX]**: Benchmark più complesso (ispirato alle suite classiche SPLASH) che implementa un algoritmo di Radix Sort multi-thread. A differenza del test sintetico precedente, questo fornisce un traffico di memoria realistico ed eterogeneo, fondamentale per valutare il tasso di successo del *Lazy Metadata Update* e l'efficacia dello *State Bouncing* quando il Tectree è sotto pressione da carichi di elaborazione reali.
