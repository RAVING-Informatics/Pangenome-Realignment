# Base image from Biocontainers with Ubuntu 16.04
FROM ubuntu:16.04

# Maintainer information
LABEL maintainer="Chiara Folland <cfolland32@gmail.com>"

# Labels
LABEL extra.identifiers.biotools="SAM" \
      about.tags="Genomics, Proteomics, Transcriptomics, General, Metabolomics" \
      about.license="SPDX:MIT" \
      about.license_file="https://github.com/samtools/samtools/blob/develop/LICENSE" \
      about.documentation="https://github.com/samtools/samtools" \
      about.home="https://github.com/samtools/samtools" \
      about.summary="Tools for manipulating next-generation sequencing data" \
      software.version="1.3" \
      software="Samtools" \
      version="3" \
      base_image="biocontainers:v1.0.0_cv4"

# Set working directory
WORKDIR /data

# Install necessary tools and dependencies
RUN apt-get update && \
    apt-get install -y wget openjdk-8-jre-headless build-essential \
    autotools-dev automake cmake curl grep sed dpkg fuse git zip \
    python python-dev python-pip bzip2 ca-certificates libglib2.0-0 \
    libxext6 libsm6 libxrender1 git mercurial subversion zlib1g-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Download Picard
RUN wget https://github.com/broadinstitute/picard/releases/download/2.20.4/picard.jar

# Configure environment for Conda and install Samtools
# Download and install Miniconda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    export PATH="/opt/conda/bin:$PATH" && \
    conda config --set ssl_verify false && \
    conda config --add channels bioconda && \
    conda config --add channels r && \
    conda install samtools=1.3 && \
    conda upgrade conda

# Set environment variables for Conda and PATH
ENV HOME=/home/biodocker
ENV PATH=/opt/conda/bin:$PATH

# Create directories for data and config
RUN mkdir /data /config

# Set permissions and create user biodocker
RUN groupadd fuse && \
    useradd --create-home --shell /bin/bash --user-group --uid 1000 --groups sudo,fuse biodocker && \
    chown biodocker:biodocker /data /config && \
    chmod 777 -R /opt/conda/

# Switch to user biodocker
USER biodocker

# Add tini for better container management
RUN TINI_VERSION=$(curl -s https://github.com/krallin/tini/releases/latest | grep -oP "/v.*\"" | sed 's:^..\(.*\).$:\1:') && \
    wget https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb && \
    dpkg -i tini_${TINI_VERSION}.deb && rm tini_${TINI_VERSION}.deb

# Clean up apt sources to reduce image size
RUN mv /etc/apt/sources.list /etc/apt/sources.list.bkp && \
    echo -e "deb mirror://mirrors.ubuntu.com/mirrors.txt xenial main restricted universe multiverse\n\
    deb mirror://mirrors.ubuntu.com/mirrors.txt xenial-updates main restricted universe multiverse\n\
    deb mirror://mirrors.ubuntu.com/mirrors.txt xenial-backports main restricted universe multiverse\n\
    deb mirror://mirrors.ubuntu.com/mirrors.txt xenial-security main restricted universe multiverse\n" \
    > /etc/apt/sources.list

# Set entry point for Tini (process management)
ENTRYPOINT ["/usr/sbin/tini", "--"]

# Default command to bash
CMD ["/bin/bash"]

# Volumes for data and config
VOLUME ["/data", "/config"]
