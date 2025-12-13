FROM python:3.9-slim

# Установка зависимостей
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

# 1. СКАЧИВАЕМ ИСХОДНИКИ ДВИЖКА (Zinnia 0.06)
# Используем архив Debian, так как там гарантированно лежит оригинал исходников
RUN wget https://deb.debian.org/debian/pool/main/z/zinnia/zinnia_0.06.orig.tar.gz \
    && tar -xvf zinnia_0.06.orig.tar.gz \
    && rm zinnia_0.06.orig.tar.gz

WORKDIR /app/zinnia-0.06

# 2. ПАТЧИМ ИСХОДНЫЙ КОД (Все накопленные исправления)
# zinnia.h - добавляем забытые инклюды
RUN sed -i '1i#include <cstdio>\n#include <cstdlib>\n#include <cstring>' zinnia.h
# mmap.h - добавляем fcntl.h и unistd.h для open/close
RUN sed -i '1i#include <fcntl.h>\n#include <unistd.h>\n#include <cstdio>\n#include <cstring>' mmap.h
# param.cpp
RUN sed -i '1i#include <cstring>\n#include <cstdio>' param.cpp
# trainer.cpp - исправление для C++11 (std::make_pair)
RUN sed -i 's/std::make_pair<std::string, FeatureNode \*>/std::make_pair/' trainer.cpp

# 3. ПЕРЕСОЗДАЕМ СИСТЕМУ СБОРКИ (Autotools Fix)
# Пишем новый configure.ac с нуля, чтобы избежать ошибок версий
RUN echo 'AC_INIT([zinnia], [0.06])' > configure.ac && \
    echo 'AM_INIT_AUTOMAKE([foreign])' >> configure.ac && \
    echo 'AC_CONFIG_SRCDIR([zinnia.h])' >> configure.ac && \
    echo 'AC_CONFIG_HEADERS([config.h])' >> configure.ac && \
    echo 'AC_PROG_CXX' >> configure.ac && \
    echo 'AC_PROG_CC' >> configure.ac && \
    echo 'AC_PROG_LIBTOOL' >> configure.ac && \
    echo 'AC_CONFIG_FILES([Makefile zinnia.pc])' >> configure.ac && \
    echo 'AC_OUTPUT' >> configure.ac

# 4. СБОРКА C++ БИБЛИОТЕКИ
RUN mkdir -p m4
RUN autoreconf -f -i
RUN ./configure --prefix=/usr && make && make install

# 5. СБОРКА PYTHON BINDINGS
WORKDIR /app/zinnia-0.06/python

# Ищем zinnia.i (он может быть в папке swig или корне)
RUN SWIG_FILE=$(find /app -name "zinnia.i" | head -n 1) && \
    swig -python -c++ -I/app/zinnia-0.06 -o zinnia_wrap.cxx "$SWIG_FILE"

# Компилируем модуль _zinnia.so
# ВАЖНО:
# -I/usr/local/include/python3.9 : Здесь лежат заголовки Python в docker-образе
# -L/usr/local/lib : Здесь лежат библиотеки Python
RUN g++ -fPIC -shared zinnia_wrap.cxx -o _zinnia.so \
    -I/usr/local/include/python3.9 \
    -I.. \
    -L/usr/local/lib \
    -lpython3.9 \
    -lzinnia

# Копируем результаты в корень приложения
RUN cp _zinnia.so /app/ && cp zinnia.py /app/

# 6. СКАЧИВАЕМ МОДЕЛЬ (С GitHub Releases - Ваша ссылка)
WORKDIR /app/models

RUN wget https://github.com/tegaki/tegaki/releases/download/v0.3/tegaki-zinnia-japanese-0.3.zip
RUN unzip tegaki-zinnia-japanese-0.3.zip

# Перемещаем файл модели handwriting-ja.model в текущую папку
# (Обычно архив распаковывается в папку с именем архива)
RUN mv tegaki-zinnia-japanese-0.3/handwriting-ja.model .

# Удаляем лишнее
RUN rm -rf tegaki-zinnia-japanese-0.3 tegaki-zinnia-japanese-0.3.zip

# 7. ЗАПУСК СЕРВЕРА
WORKDIR /app
RUN pip install flask requests

COPY server.py .

# Указываем путь к библиотекам (Zinnia устанавливается в /usr/lib)
ENV LD_LIBRARY_PATH=/usr/lib:/usr/local/lib

EXPOSE 5000
CMD ["python", "server.py"]