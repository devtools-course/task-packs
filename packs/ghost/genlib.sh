#! /usr/bin/env bash

case "$1" in
    1)
        vers=1
        ;;
    2)
        vers=2
        ;;
    *)
        echo "Unknown version" >&2
        exit 8869
        ;;
esac

mkdir -p build lib

musl-gcc -c -O2 "lihtar$vers.c" -o build/lihtar.o
ar rcs lib/liblihtar.a build/lihtar.o
