FROM python:3.9-slim

RUN apt-get update && apt-get install -y \
    build-essential \
    automake \
    libtool \
    wget \
    swig \
    pkg-config \
    unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN wget https://deb.debian.org/debian/pool/main/z/zinnia/zinnia_0.06.orig.tar.gz \
    && tar -xvf zinnia_0.06.orig.tar.gz \
    && rm zinnia_0.06.orig.tar.gz

WORKDIR /app/zinnia-0.06

RUN sed -i '1i#include <cstdio>\n#include <cstdlib>\n#include <cstring>' zinnia.h
RUN sed -i '1i#include <fcntl.h>\n#include <unistd.h>\n#include <cstdio>\n#include <cstring>' mmap.h
RUN sed -i '1i#include <cstring>\n#include <cstdio>' param.cpp
RUN sed -i 's/std::make_pair<std::string, FeatureNode \*>/std::make_pair/' trainer.cpp

RUN echo 'AC_INIT([zinnia], [0.06])' > configure.ac && \
    echo 'AM_INIT_AUTOMAKE([foreign])' >> configure.ac && \
    echo 'AC_CONFIG_SRCDIR([zinnia.h])' >> configure.ac && \
    echo 'AC_CONFIG_HEADERS([config.h])' >> configure.ac && \
    echo 'AC_PROG_CXX' >> configure.ac && \
    echo 'AC_PROG_CC' >> configure.ac && \
    echo 'AC_PROG_LIBTOOL' >> configure.ac && \
    echo 'AC_CONFIG_FILES([Makefile zinnia.pc])' >> configure.ac && \
    echo 'AC_OUTPUT' >> configure.ac

RUN mkdir -p m4
RUN autoreconf -f -i
RUN ./configure --prefix=/usr && make && make install

WORKDIR /app/zinnia-0.06/python

RUN SWIG_FILE=$(find /app -name "zinnia.i" | head -n 1) && \
    swig -python -c++ -I/app/zinnia-0.06 -o zinnia_wrap.cxx "$SWIG_FILE"

RUN g++ -fPIC -shared zinnia_wrap.cxx -o _zinnia.so \
    -I/usr/local/include/python3.9 \
    -I.. \
    -L/usr/local/lib \
    -lpython3.9 \
    -lzinnia

RUN cp _zinnia.so /app/ && cp zinnia.py /app/

WORKDIR /app/models

RUN wget https://github.com/tegaki/tegaki/releases/download/v0.3/tegaki-zinnia-japanese-0.3.zip
RUN unzip tegaki-zinnia-japanese-0.3.zip

RUN mv tegaki-zinnia-japanese-0.3/handwriting-ja.model .

RUN rm -rf tegaki-zinnia-japanese-0.3 tegaki-zinnia-japanese-0.3.zip

WORKDIR /app
RUN pip install flask requests

COPY server.py .

ENV LD_LIBRARY_PATH=/usr/lib:/usr/local/lib

EXPOSE 5200
CMD ["python", "server.py"]