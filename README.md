# yambo-gcc_openmpi_mkl_slepc
Docker container for Yambo code v5.0.1 compiled with gcc@9.3 openmpi@4.0.2 mkl@2020

In this Docker container the OS Ubuntu v20.04 is used as starting point for the installation of the Yambo code compiled with gcc@9.3. 
As parallelization strategies are enabled OpenMP and MPI with openmpi@4.0.2.
The library used are: IOTK, HDF5, NetCDF, Intel MKL, FFTW, LibXC, PETSc, SLEPc.

## How to use it in a x86_64 personal computer

In order to run the container in a personal computer first pull the container:

```
docker pull nicspalla/yambo-gcc_openmpi_mkl_slepc
```

To run Yambo into the container:

```
docker run -ti --user $(id -u):$(id -g) \
   --mount type=bind,source="$(pwd)",target=/tmpdir \
   -e OMP_NUM_THREADS=2  \
   nicspalla/yambo-gcc_openmpi_mkl_slepc \
   yambo -F yambo.in -J yambo.out
```

Otherwise (suggested!), copy and paste the code below in a file, i.e called drun.sh:

```
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
```

then give the file execute privileges:

```
chmod +x drun.sh
```

Move (or copy) this file in the directory where you want to use Yambo and use it as prefix of your Yambo calculation:

```
./drun.sh yambo -F yambo.in -J yambo.out
```

This script gives you the possibility to choose the container's name with the option `-c`, to set the environment variable `OMP_NUM_THREADS` with the option `-t` and the number of MPI tasks with the option `-np`. Here an example:

```
./drun.sh -c nicspalla/yambo-gcc_openmpi_mkl_slepc -t 2 -np 4 yambo -F yambo.in -J yambo.out
```

If the yambo container is working correctly you should obtain:

```
./drun.sh yambo
yambo: cannot access CORE database (SAVE/*db1 and/or SAVE/*wf)
```

```
./drun.sh yambo -h
```

should provide in output the help for yambo usage.
