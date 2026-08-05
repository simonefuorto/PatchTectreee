#!/bin/bash

DEST="gem5"
ARCH="X86"
PROTOCOL=""
WORKLOAD=""

VALID_PROTOCOL=("TARDISTSO" "MESI_Two_Level" "TARDISTSO_TECTREE")
VALID_WORKLOAD=("radix_bm" "fft_bm" "lu_bm" "ocean_bm" "false_sharing")

usage() {
    echo "Usage: $0 -p PROTOCOL -w WORKLOAD"
    echo "Valid PROTOCOL values: ${VALID_PROTOCOL[*]}"
    echo "Valid WORKLOAD values: ${VALID_WORKLOAD[*]}"
    exit 1
}

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -p|--protocol)
            PROTOCOL="$2"
            shift 2
            ;;
        -w|--workload)
            WORKLOAD="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

is_valid_protocol=false
for p in "${VALID_PROTOCOL[@]}"; do
    if [ "$p" == "$PROTOCOL" ]; then
        is_valid_protocol=true
        break
    fi
done
if [ "$is_valid_protocol" == false ]; then
    echo "Error: Invalid PROTOCOL value. Must be one of: ${VALID_PROTOCOL[*]}"
    usage
fi

is_valid_workload=false
for w in "${VALID_WORKLOAD[@]}"; do
    if [ "$w" == "$WORKLOAD" ]; then
        is_valid_workload=true
        break
    fi
done
if [ "$is_valid_workload" == false ]; then
    echo "Error: Invalid WORKLOAD value. Must be one of: ${VALID_WORKLOAD[*]}"
    usage
fi

if [ ! -d "$DEST" ]; then
  echo "Gem5 directory not found!"
  exit 1
fi

cd "$DEST"

echo "=========================================================="
echo "Avvio Test Bare-Metal: $WORKLOAD su protocollo $PROTOCOL"
echo "=========================================================="

if [ "$WORKLOAD" == "radix_bm" ]; then
    ./build/${ARCH}_${PROTOCOL}/gem5.opt configs/deprecated/example/se.py -c tests/test-progs/tardis_tso/${ARCH}/${WORKLOAD}/bin/${WORKLOAD} --options="-p 4 -n 65536 -t" -n 5 --cpu-type ${ARCH}TimingSimpleCPU --ruby --mem-size=4GB
elif [ "$WORKLOAD" == "fft_bm" ]; then
    ./build/${ARCH}_${PROTOCOL}/gem5.opt configs/deprecated/example/se.py -c tests/test-progs/tardis_tso/${ARCH}/${WORKLOAD}/bin/${WORKLOAD} --options="-p 4 -m 10 -t" -n 5 --cpu-type ${ARCH}TimingSimpleCPU --ruby --mem-size=4GB
elif [ "$WORKLOAD" == "lu_bm" ]; then
    ./build/${ARCH}_${PROTOCOL}/gem5.opt configs/deprecated/example/se.py -c tests/test-progs/tardis_tso/${ARCH}/${WORKLOAD}/bin/${WORKLOAD} --options="-p 4 -n 32 -t" -n 5 --cpu-type ${ARCH}TimingSimpleCPU --ruby --mem-size=4GB
elif [ "$WORKLOAD" == "ocean_bm" ]; then
    ./build/${ARCH}_${PROTOCOL}/gem5.opt configs/deprecated/example/se.py -c tests/test-progs/tardis_tso/${ARCH}/${WORKLOAD}/bin/${WORKLOAD} --options="-p 4 -n 18" -n 5 --cpu-type ${ARCH}TimingSimpleCPU --ruby --mem-size=4GB
elif [ "$WORKLOAD" == "false_sharing" ]; then
    ./build/${ARCH}_${PROTOCOL}/gem5.opt configs/deprecated/example/se.py -c tests/test-progs/tardis_tso/${ARCH}/${WORKLOAD}/bin/${WORKLOAD} -n 5 --cpu-type ${ARCH}TimingSimpleCPU --ruby --mem-size=4GB
fi

echo "=========================================================="
echo "Simulazione completata! Statistiche in gem5/m5out/stats.txt"
echo "=========================================================="
 
