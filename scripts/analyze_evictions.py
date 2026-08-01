import sys
import re

def main():
    if len(sys.argv) < 2:
        print("Uso: python3 analyze_evictions.py <percorso_trace_file>")
        sys.exit(1)

    trace_file = sys.argv[1]
    
    # Inizializza i contatori
    data_evictions = 0
    l1 = 0
    l2 = 0
    l3 = 0
    l4 = 0
    l5 = 0
    l6 = 0
    l7 = 0

    # Pattern Regex per intercettare gli indirizzi sfrattati nel log
    pattern_diretta = re.compile(r"La vittima (0x[0-9a-fA-F]+)")
    pattern_cascata = re.compile(r"Il blocco (0x[0-9a-fA-F]+) ha tutto il ramo pronto!")

    try:
        with open(trace_file, "r") as f:
            for line in f:
                match1 = pattern_diretta.search(line)
                match2 = pattern_cascata.search(line)
                
                addr_str = None
                if match1:
                    addr_str = match1.group(1)
                elif match2:
                    addr_str = match2.group(1)
                    
                if addr_str:
                    addr = int(addr_str, 16)
                    # Classificazione basata sull'offset in memoria (Arity = 15)
                    if addr < 0x80000000:
                        data_evictions += 1
                    elif addr < 0x888888C0:
                        l1 += 1
                    elif addr < 0x891A6C00:
                        l2 += 1
                    elif addr < 0x89242140:
                        l3 += 1
                    elif addr < 0x8924C700:
                        l4 += 1
                    elif addr < 0x8924D240:
                        l5 += 1
                    elif addr < 0x8924D300:
                        l6 += 1
                    else:
                        l7 += 1 # Root
    except FileNotFoundError:
        print(f"Errore: Impossibile trovare il file '{trace_file}'.")
        sys.exit(1)

    # Calcolo dei totali
    counter_evictions = l1 + l2 + l3 + l4 + l5 + l6 + l7
    total_evictions = data_evictions + counter_evictions

    # Prevenzione divisione per zero
    if total_evictions == 0:
        print("Nessuno sfratto trovato nel file di trace.")
        sys.exit(0)

    # Calcolo Percentuali
    perc_data = (data_evictions / total_evictions) * 100
    perc_counters = (counter_evictions / total_evictions) * 100

    # Stampa Report
    print("==================================================")
    print("       ANALISI DEGLI SFRATTI (EVICTIONS)")
    print("==================================================")
    print(f"Totale Sfratti:        {total_evictions}")
    print(f" - Sfratti Dati:       {data_evictions} ({perc_data:.2f}%)")
    print(f" - Sfratti Metadati:   {counter_evictions} ({perc_counters:.2f}%)")
    print("--------------------------------------------------")
    print(" BREAKDOWN DEI METADATI PER LIVELLO (CounterChunks)")
    print("--------------------------------------------------")
    print(f" L1 Counters:  {l1}")
    print(f" L2 Counters:  {l2}")
    print(f" L3 Counters:  {l3}")
    print(f" L4 Counters:  {l4}")
    print(f" L5 Counters:  {l5}")
    print(f" L6 Counters:  {l6}")
    print(f" L7 Counters:  {l7} (Root/Higher)")
    print("==================================================")

if __name__ == "__main__":
    main()
