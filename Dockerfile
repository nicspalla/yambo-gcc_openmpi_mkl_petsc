ARG container_version=20.04
FROM ubuntu:${container_version}

LABEL author="Nicola Spallanzani - nicola.spallanzani@nano.cnr.it - S3 centre, CNR-NANO"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -yqq update \
 && apt-get -yqq install --no-install-recommends \
        build-essential ca-certificates curl file \
        make gcc g++ gfortran \
        git gnupg2 iproute2 lmod \
        locales lua-posix python2 \
	openmpi-bin openmpi-common libopenmpi-dev \
        tcl unzip m4 wget git zlib1g-dev ssh \
	libmkl-gnu-thread libmkl-avx libmkl-avx2 libmkl-avx512 \
	libmkl-core libmkl-def libmkl-dev libmkl-gf-ilp64 libmkl-gf-lp64 \
 && apt-get clean \
 && locale-gen en_US.UTF-8 

WORKDIR /tmpdir

### YAMBO ###
ARG yambo_version=5.0.1
RUN wget https://github.com/yambo-code/yambo/archive/${yambo_version}.tar.gz -O yambo-${yambo_version}.tar.gz \
 && tar zxf yambo-${yambo_version}.tar.gz && cd yambo-${yambo_version} \
 && ./configure --enable-open-mp --enable-msgs-comps --enable-time-profile --enable-memory-profile --enable-netcdf-hdf5 --enable-slepc-linalg \
    --with-blas-libs="-L${MKLROOT}/lib/intel64 -Wl,--no-as-needed -lmkl_gf_lp64 -lmkl_gnu_thread -lmkl_core -lgomp -lpthread -lm -ldl" \
    --with-lapack-libs="-L${MKLROOT}/lib/intel64 -Wl,--no-as-needed -lmkl_gf_lp64 -lmkl_gnu_thread -lmkl_core -lgomp -lpthread -lm -ldl" \
 && make -j4 ext-libs && make -j4 yambo && make -j4 interfaces && make -j4 ypp \
 && mkdir -p /usr/local/yambo-${yambo_version}/lib \
 && cp -r bin /usr/local/yambo-${yambo_version}/. \
 && cp -r lib/external/*/*/lib/*.* /usr/local/yambo-${yambo_version}/lib/. \
 && cp -r lib/external/*/*/v*/serial/lib/*.* /usr/local/yambo-${yambo_version}/lib/. \
 && cd .. && rm -rf yambo-${yambo_version} yambo-${yambo_version}.tar.gz

ENV PATH=/usr/local/yambo-${yambo_version}/bin:/opt/openmpi/bin:$PATH \
    LD_LIBRARY_PATH=/usr/local/yambo-${yambo_version}/lib:$LD_LIBRARY_PATH