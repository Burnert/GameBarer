@echo off
mkdir bin
mkdir bin\debug
odin build src -strict-style -debug -out:bin/debug/GameBarer.exe -target:windows_amd64 -o:none -show-timings -show-system-calls