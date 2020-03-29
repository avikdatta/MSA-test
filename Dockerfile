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
      gcc \
      g++ \
      make \
      libgcc-5-dev \
      gfortran \
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
RUN mkdir -p /home/$NB_USER/bin && \
    wget -q -O bin/clustalo http://www.clustal.org/omega/clustalo-1.2.4-Ubuntu-x86_64 && \
    chmod a+x bin/clustalo && \
    . /home/$NB_USER/miniconda3/etc/profile.d/conda.sh && \
    conda deactivate && \
    conda update -n base -c defaults conda && \
    conda env update -q -n notebook-env --file /home/$NB_USER/environment.yml && \
    conda activate notebook-env && \
    jupyter labextension install @jupyterlab/fasta-extension && \
    jupyter labextension install jupyterlab-drawio && \
    jupyter serverextension enable --sys-prefix nbserverproxy
EXPOSE 8888
EXPOSE 33001
CMD [ "notebook" ]
