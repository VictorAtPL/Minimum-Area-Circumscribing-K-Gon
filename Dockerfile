FROM ubuntu:20.10

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt install -y git python3-pip cmake libncurses-dev libgsl0-dev xorg-dev libreadline-gplv2-dev \
    libpng-dev libgsl0-dev libplplot-dev libnetcdf-dev libfftw3-dev libeigen3-dev \
    libhdf4-alt-dev libhdf5-dev pslib-dev libgraphicsmagick++-dev libudunits2-dev libproj-dev libantlr-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/code

ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/local/lib"

ENV PYTHONPATH=/opt/code

COPY requirements.txt .

RUN /usr/bin/python3 -m pip install --upgrade pip && \
    /usr/bin/python3 -m pip install -r requirements.txt && \
    rm -rf ~/.cache/pip && \
    rm -f requirements.txt

RUN git clone https://github.com/gnudatalanguage/gdl && \
    cd gdl && \
    mkdir build && \
    cd build && \
    cmake -DWXWIDGETS=OFF -DGEOTIFF=OFF -DGRIB=OFF -DGLPK=OFF -DPYTHON=YES -DPYTHON_MODULE=YES .. && \
    make -j $(cat /proc/cpuinfo | grep processor | wc -l) && \
    make install && \
    cd ../../ && \
    rm -rf gdl

ENV GDL_PATH="/usr/local/share/gnudatalanguage/lib/:/opt/code"

COPY . /opt/code

EXPOSE 8000

ENTRYPOINT gunicorn main:app \
    --timeout 20 \
    --reload \
    --workers $(cat /proc/cpuinfo | grep processor | wc -l) \
    --bind 0.0.0.0:8000 \
    --log-level debug