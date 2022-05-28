FROM ubuntu:20.04

ARG USER_ID=1000
ARG JULIA_VER=1.7.3
ARG JULIA_URL=https://julialang-s3.julialang.org/bin/linux/x64/1.7
ARG USER_NAME=julia

EXPOSE 8888
USER root
WORKDIR /

# ==== Install system dependencies ====

RUN apt update && apt upgrade -y && apt install -y \
    curl tar

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

USER ${USER_NAME}

RUN julia -e 'using Pkg; Pkg.add("Pluto")'

WORKDIR /nodebooks

CMD ["julia", "-e", "usping Pluto; Pluto.run()"]
