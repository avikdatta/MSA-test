FROM imperialgenomicsfacility/base-notebook-image:release-v0.0.3
LABEL maintainer="avikdatta"
LABEL version="0.0.1"
LABEL description="Docker image for running MSA based analysis"
ENV NB_USER vmuser
ENV NB_UID 1000
USER root
WORKDIR /
RUN apt-get -y update
USER $NB_USER
WORKDIR /home/$NB_USER
ENV TMPDIR=/home/$NB_USER/.tmp
ENV PATH=$PATH:/home/$NB_USER/miniconda3/bin/
RUN rm -f /home/$NB_USER/environment.yml && \
    rm -f /home/$NB_USER/Dockerfile && \
    mkdir /home/$NB_USER/examples
COPY examples/* /home/$NB_USER/examples/
COPY Dockerfile /home/$NB_USER/Dockerfile
USER root
RUN chown -R ${NB_UID} /home/$NB_USER/examples
USER $NB_USER
WORKDIR /home/$NB_USER
RUN mkdir -p /home/$NB_USER/bin && \
    wget -q -O bin/clustalo http://www.clustal.org/omega/clustalo-1.2.4-Ubuntu-x86_64 && \
    chmod a+x bin/clustalo && \
    . /home/$NB_USER/miniconda3/etc/profile.d/conda.sh && \
    conda activate notebook-env && \
    jupyter labextension install @jupyterlab/fasta-extension && \
    jupyter labextension install jupyterlab-drawio && \
    jupyter labextension install jupyterlab_tensorboard && \
    jupyter serverextension enable --sys-prefix nbserverproxy
EXPOSE 8888
CMD [ "notebook" ]

