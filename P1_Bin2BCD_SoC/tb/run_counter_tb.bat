@echo off
mkdir build
cd build
echo:
echo =============================== Running Counter Testbench ===============================
echo:
vsim -c -do "do ../scripts/counter_tb.do"