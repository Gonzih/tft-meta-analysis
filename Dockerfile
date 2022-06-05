FROM ubuntu:20.04

EXPOSE 8888
WORKDIR /

ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

# ==== Install system dependencies ====

RUN apt update \
    && apt install -y curl tar supervisor make git \
    && apt-get clean

# ==== Install python crap ====

# Install Miniconda
RUN curl -LO https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -p /miniconda -b && \
    rm Miniconda3-latest-Linux-x86_64.sh
ENV PATH=/miniconda/bin:${PATH}

# Install Jupyter
RUN conda update -y conda && \
    conda install -y -c conda-forge jupyterlab numpy scipy matplotlib pip git && \
    pip install 'jupyter-server-proxy @ git+http://github.com/fonsp/jupyter-server-proxy@3a58aa5005f942d0c208eab9a480f6ab171142ef'
    # jupyter-server-proxy
RUN mkdir /.local && \
    chown ${NB_UID} /.local

# ========== Install Julia ==========

ARG JULIA_VER=1.7.3
ARG JULIA_URL=https://julialang-s3.julialang.org/bin/linux/x64/1.7

RUN curl -LO ${JULIA_URL}/julia-${JULIA_VER}-linux-x86_64.tar.gz && \
	  tar -xf julia-${JULIA_VER}-linux-x86_64.tar.gz && \
	  rm -rf julia-${JULIA_VER}-linux-x86_64.tar.gz && \
	  ln -s /julia-${JULIA_VER}/bin/julia /usr/local/bin/julia
RUN mkdir ${HOME}/.julia && chown ${NB_UID} ${HOME}/.julia

# ========== Add application user ==========

RUN useradd --no-log-init --system --uid ${NB_UID} \
	  --create-home --shell /bin/bash ${NB_USER}
RUN chown ${NB_UID} /home/${NB_USER} -R

# ========== Install IJulia as application user ==========

ADD ./notebooks /app/notebooks
ADD ./data.tar.bz2 /app
RUN chown ${NB_UID} /app -R
ADD jupyter_notebook_config.py ${HOME}/.jupyter/jupyter_notebook_config.py
RUN chown ${NB_UID} ${HOME}/.jupyter -R

USER ${NB_USER}
RUN julia /app/notebooks/src/pkgs.jl
WORKDIR /app/notebooks
CMD ["julia", "--optimize=0", "-e", "import Pluto; Pluto.run(host=\"0.0.0.0\", port=8888, launch_browser=false, require_secret_for_open_links=false, require_secret_for_access=false)"]
