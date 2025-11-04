@echo off
mkdir bin
mkdir bin\release
odin build src -strict-style -debug -out:bin/release/GameBarer.exe -target:windows_amd64 -o:speed -show-timings -show-system-calls