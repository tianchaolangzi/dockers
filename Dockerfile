FROM nvidia/cuda:10.1-devel-ubuntu18.04

ARG OPENFST_VERSION=1.6.7
ARG NUM_BUILD_CORES=32
ENV OPENFST_VERSION ${OPENFST_VERSION}
ENV NUM_BUILD_CORES ${NUM_BUILD_CORES}
ENV LANG=C.UTF-8
RUN apt-get update \
    && apt-get install -y sudo git apt-utils gawk vim sox python2.7 \
                       libtool python libtool-bin \
    && git clone https://github.com/kaldi-asr/kaldi.git /kaldi \
    && rm /kaldi/tools/install_srilm.sh
RUN bash /kaldi/tools/extras/check_dependencies.sh | grep "sudo apt-get" | \
        while read -r cmd; do \
            $cmd -y --fix-missing ; \
        done

COPY srilm.tgz /kaldi/tools/srilm.tgz
COPY install_srilm.sh /kaldi/tools/install_srilm.sh

RUN cd /kaldi/tools \
    && make OPENFST_VERSION=${OPENFST_VERSION} -j${NUM_BUILD_CORES} \
    && bash ./install_srilm.sh \
    && bash extras/install_mkl.sh \
    && cd /kaldi/src \
    && ./configure --shared \
    && make depend \
    && make -j${NUM_BUILD_CORES}

ENTRYPOINT ["/bin/bash"]
