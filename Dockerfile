FROM imperialgenomicsfacility/base-notebook-image:release-v0.0.3
LABEL maintainer="avikdatta"
LABEL version="0.0.1"
LABEL description="Docker image for running MSA based analysis"
ENV NB_USER vmuser
ENV NB_UID 1000
USER root
WORKDIR /
RUN apt-get -y update && \
    apt-get install --no-install-recommends -y \
      libfontconfig1 \
      libxrender1 \
      libreadline6-dev \
      libreadline6 \
      libicu-dev \
      libc6-dev \
      icu-devtools \
      libjpeg-dev \
      libxext-dev \
      libcairo2 \
      libicu55 \
      libicu-dev \
      cmake \
      gcc \
      g++ \
      make \
      libgcc-5-dev \
      gfortran \
      openjdk-8-jre-headless \
      ca-certificates-java \
      openssl \
      openssh-client \
      libssl-dev \
      libgl1-mesa-glx \
      git  && \
    apt-get purge -y --auto-remove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
USER $NB_USER
WORKDIR /home/$NB_USER
ENV TMPDIR=/home/$NB_USER/.tmp
ENV PATH=$PATH:/home/$NB_USER/miniconda3/bin/
RUN rm -f /home/$NB_USER/environment.yml && \
    rm -f /home/$NB_USER/Dockerfile && \
    rm -rf /home/$NB_USER/examples && \
    mkdir /home/$NB_USER/examples
COPY examples/* /home/$NB_USER/examples/
COPY Dockerfile /home/$NB_USER/Dockerfile
COPY environment.yml /home/$NB_USER/environment.yml
USER root
RUN chown -R ${NB_UID} /home/$NB_USER/examples && \
    chown ${NB_UID} /home/$NB_USER/environment.yml
USER $NB_USER
WORKDIR /home/$NB_USER
RUN . /home/$NB_USER/miniconda3/etc/profile.d/conda.sh && \
    conda update -n base -c defaults conda && \
    conda activate notebook-env && \
    conda env update -q -n notebook-env --file /home/$NB_USER/environment.yml && \
    jupyter labextension install @jupyterlab/fasta-extension && \
    jupyter labextension install jupyterlab-drawio
RUN mkdir -p /home/$NB_USER/bin && \
    wget -q -O /home/$NB_USER/bin/fastv http://opengene.org/fastv/fastv  && \
    chmod a+x /home/$NB_USER/bin/fastv && \
    wget -q -O /tmp/MEGAHIT-1.2.9-Linux-x86_64-static.tar.gz https://github.com/voutcn/megahit/releases/download/v1.2.9/MEGAHIT-1.2.9-Linux-x86_64-static.tar.gz && \
    tar -zxf /tmp/MEGAHIT-1.2.9-Linux-x86_64-static.tar.gz && \
    mv MEGAHIT-1.2.9-Linux-x86_64-static /home/$NB_USER/bin/ && \
    wget -q -O /tmp/BBMap_35.34.tar.gz http://downloads.sourceforge.net/project/bbmap/BBMap_35.34.tar.gz && \
    tar -zxf /tmp/BBMap_35.34.tar.gz && \
    mv bbmap /home/$NB_USER/bin/ && \
    wget -q -O /tmp/bowtie2-2.4.1-linux-x86_64.zip https://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.4.1/bowtie2-2.4.1-linux-x86_64.zip/download && \
    unzip /tmp/bowtie2-2.4.1-linux-x86_64.zip && \
    mv bowtie2-2.4.1-linux-x86_64 /home/$NB_USER/bin/ && \
    wget -O /tmp/mauve_linux_snapshot_2015-02-13.tar.gz http://darlinglab.org/mauve/snapshots/2015/2015-02-13/linux-x64/mauve_linux_snapshot_2015-02-13.tar.gz && \
    tar -zxf /tmp/mauve_linux_snapshot_2015-02-13.tar.gz && \
    mv mauve_snapshot_2015-02-13 /home/$NB_USER/bin/
ENV PATH /home/$NB_USER/bin:${PATH}
ENV PATH /home/$NB_USER/bin/MEGAHIT-1.2.9-Linux-x86_64-static/bin/:${PATH}
EXPOSE 8888
EXPOSE 33001
CMD [ "notebook" ]
