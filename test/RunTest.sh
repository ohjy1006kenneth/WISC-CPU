#!/bin/bash

iverilog -o CPU_Test -c Test_Files.txt 2>&1 | tee compile.log

if ! grep -qi "error" compile.log; then
    ./CPU_Test
else
    echo "Compilation failed. Skipping execution."
fi