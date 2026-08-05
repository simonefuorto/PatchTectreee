#!/bin/bash

DEST="gem5"

ARCH=""
PROTOCOL=""
WORKLOAD=""

VALID_ARCH=("X86" "ARM")
VALID_PROTOCOL=("TARDISTSO" "MI" "MSI")
VALID_WORKLOAD=("mfence" "spinlock" "false_sharing" "random_array")

usage() {
    echo "Usage: $0 -a ARCH -p PROTOCOL -w WORKLOAD"
    echo "Valid ARCH values: ${VALID_ARCH[*]}"
    echo "Valid PROTOCOL values: ${VALID_PROTOCOL[*]}"
    echo "Valid WORKLOAD values: ${VALID_WORKLOAD[*]}"
    exit 1
}

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -a|--arch)
            ARCH="$2"
            shift 2
            ;;
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

if [[ ! " ${VALID_ARCH[@]} " =~ " $ARCH " ]]; then
    echo "Error: Invalid ARCH value. Must be one of: ${VALID_ARCH[*]}"
    usage
fi

if [[ ! " ${VALID_PROTOCOL[@]} " =~ " $PROTOCOL " ]]; then
    echo "Error: Invalid PROTOCOL value. Must be one of: ${VALID_PROTOCOL[*]}"
    usage
fi

if [[ ! " ${VALID_WORKLOAD[@]} " =~ " $WORKLOAD " ]]; then
    echo "Error: Invalid WORKLOAD value. Must be one of: ${VALID_WORKLOAD[*]}"
    usage
fi


if [ ! -d "$DEST" ]; then
  echo "Gem5 directory not found!"
  exit 1
fi

cd "$DEST"

./build/${ARCH}_${PROTOCOL}/gem5.opt configs/deprecated/example/se.py -c tests/test-progs/tardis_tso/${ARCH}/${WORKLOAD}/bin/${WORKLOAD} -n 5 --cpu-type ${ARCH}TimingSimpleCPU --ruby