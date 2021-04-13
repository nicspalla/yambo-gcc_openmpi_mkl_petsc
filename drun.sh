#!/bin/bash

threads=1
mpirun_wrapper=""
container="nicspalla/yambo-gcc_openmpi_mkl_slepc"

while [[ $1 == -* ]]; do
    case $1 in
        -t | --threads ) threads=$2
			 shift 2
			 ;;
	-c | --container) container=$2
			  shift 2
			  ;;
	-np | --nprocess ) mpirun_wrapper="mpirun --use-hwthread-cpus -np $2"
	      shift 2
	      ;;
        * ) echo "Error: \"$1\" unrecognized argument."
	    exit 1
    esac
done

docker run -ti --user $(id -u):$(id -g) \
    --mount type=bind,source="$(pwd)",target=/tmpdir \
    -e OMP_NUM_THREADS=${threads} \
    ${container} ${mpirun_wrapper} $@
