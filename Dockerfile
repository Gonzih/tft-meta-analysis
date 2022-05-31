FROM ubuntu:20.04

ARG USER_ID=1000
ARG JULIA_VER=1.7.3
ARG JULIA_URL=https://julialang-s3.julialang.org/bin/linux/x64/1.7
ARG USER_NAME=julia

EXPOSE 8888
EXPOSE 1234
EXPOSE 2345
USER root
WORKDIR /

# ==== Install system dependencies ====

RUN apt update && apt upgrade -y && apt install -y \
    curl tar supervisor

# ==== Install python crap ====

# Install Miniconda
RUN curl -LO https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -p /miniconda -b && \
    rm Miniconda3-latest-Linux-x86_64.sh
ENV PATH=/miniconda/bin:${PATH}

# Install Jupyter
RUN conda update -y conda && \
conda install -y -c conda-forge jupyterlab numpy scipy matplotlib
RUN mkdir /.local && \
chown ${USER_ID} /.local

# ========== Install Julia ==========

RUN curl -LO ${JULIA_URL}/julia-${JULIA_VER}-linux-x86_64.tar.gz && \
	  tar -xf julia-${JULIA_VER}-linux-x86_64.tar.gz && \
	  rm -rf julia-${JULIA_VER}-linux-x86_64.tar.gz && \
	  ln -s /julia-${JULIA_VER}/bin/julia /usr/local/bin/julia
RUN mkdir /.julia && chown ${USER_ID} /.julia

# ========== Add application user ==========

RUN useradd --no-log-init --system --uid ${USER_ID} \
	  --create-home --shell /bin/bash ${USER_NAME}

# ========== Install IJulia as application user ==========

ADD notebooks/src/pkgs.jl /tmp/pkgs.jl
USER ${USER_NAME}
RUN julia /tmp/pkgs.jl

WORKDIR /notebooks

USER root
RUN rm /tmp/pkgs.jl
COPY supervisord.conf.dev /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord"]
