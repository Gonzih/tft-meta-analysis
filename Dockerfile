FROM ubuntu:20.04

EXPOSE 8888
WORKDIR /

ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}
USER ${NB_USER}

USER root

# ==== Install system dependencies ====

RUN apt update \
    && apt install -y curl tar supervisor make \
    && apt-get clean

# ========== Install Julia ==========

ARG JULIA_VER=1.7.3
ARG JULIA_URL=https://julialang-s3.julialang.org/bin/linux/x64/1.7

RUN curl -LO ${JULIA_URL}/julia-${JULIA_VER}-linux-x86_64.tar.gz && \
	  tar -xf julia-${JULIA_VER}-linux-x86_64.tar.gz && \
	  rm -rf julia-${JULIA_VER}-linux-x86_64.tar.gz && \
	  ln -s /julia-${JULIA_VER}/bin/julia /usr/local/bin/julia
RUN mkdir /.julia && chown ${NB_UID} /.julia

# ========== Add application user ==========

RUN useradd --no-log-init --system --uid ${NB_UID} \
	  --create-home --shell /bin/bash ${NB_USER}

# ========== Install IJulia as application user ==========

ADD ./notebooks /app/notebooks
ADD ./data.tar.bz2 /app
RUN chown ${NB_UID} /app -R

USER ${NB_USER}
RUN julia /app/notebooks/src/pkgs.jl
WORKDIR /app/notebooks
CMD julia /app/notebooks/scripts/pluto.jl
