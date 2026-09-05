@echo off
mkdir build
cd build
echo:
echo =============================== Running Bin2BCD Testbench ===============================
echo:
vsim -c -do "do ../scripts/bin2bcd_tb.do"