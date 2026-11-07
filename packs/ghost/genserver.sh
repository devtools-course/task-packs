#! /usr/bin/env bash

mkdir -p bin

musl-gcc -O2 "server.c" -Llib -llihtar -o bin/ghost
