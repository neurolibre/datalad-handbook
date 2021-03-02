FROM ubuntu:18.04

USER root

# initial configuration
ARG DEBIAN_FRONTEND="noninteractive"

ENV LANG="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8" 
RUN apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           apt-utils \
           bzip2 \
           ca-certificates \
           curl \
           locales \
           unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG="en_US.UTF-8" \
    && chmod 777 /opt && chmod a+s /opt

RUN apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           bc \
           dc \
           file \
           libfontconfig1 \
           libfreetype6 \
           libgl1-mesa-dev \
           libgl1-mesa-dri \
           libglu1-mesa-dev \
           libgomp1 \
           libice6 \
           libxcursor1 \
           libxft2 \
           libxinerama1 \
           libxrandr2 \
           libxrender1 \
           libxt6 \
           sudo \
           wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* 

# install git-annex and datalad
RUN wget -O- http://neuro.debian.net/lists/bionic.us-nh.full | sudo tee /etc/apt/sources.list.d/neurodebian.sources.list
RUN apt-key adv --recv-keys --keyserver hkp://pool.sks-keyservers.net:80 0xA5D32F012649A5A9
RUN apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           git-annex-standalone \
           datalad \	
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

#binderhub specific https://mybinder.readthedocs.io/en/latest/tutorials/dockerfile.html
RUN apt-get update -qq && apt-get install -y -q python3-pip
RUN pip3 install --no-cache-dir \
	Cython==0.29.20 \
	notebook==5.7.10 \
	nilearn==0.7.0 \
	matplotlib==3.3.0

ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

# Make sure the contents of our repo are in ${HOME}
COPY . ${HOME}
USER root
RUN chown -R ${NB_UID} ${HOME}
WORKDIR ${HOME}
USER ${NB_USER}

# disinherit previous entrypoints
ENTRYPOINT []
