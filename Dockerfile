FROM ubuntu:20.04

ARG NB_USER=jovyan
ARG NB_UID=1000
ARG JULIA_VER=1.7.3
ARG JULIA_URL=https://julialang-s3.julialang.org/bin/linux/x64/1.7

EXPOSE 8888
USER root
WORKDIR /

# ==== Install system dependencies ====

RUN apt update && apt upgrade -y && apt install -y \
    curl tar supervisor make

# ========== Install Julia ==========

RUN curl -LO ${JULIA_URL}/julia-${JULIA_VER}-linux-x86_64.tar.gz && \
	  tar -xf julia-${JULIA_VER}-linux-x86_64.tar.gz && \
	  rm -rf julia-${JULIA_VER}-linux-x86_64.tar.gz && \
	  ln -s /julia-${JULIA_VER}/bin/julia /usr/local/bin/julia
RUN mkdir /.julia && chown ${NB_UID} /.julia

# ========== Add application user ==========

RUN useradd --no-log-init --system --uid ${NB_UID} \
	  --create-home --shell /bin/bash ${NB_USER}

# ========== Install IJulia as application user ==========

ADD . /app
USER ${NB_USER}
RUN julia /app/notebooks/src/pkgs.jl
RUN cd /app && make unpack-data

WORKDIR /app/notebooks

USER root
COPY supervisord.conf.prod /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord"]
