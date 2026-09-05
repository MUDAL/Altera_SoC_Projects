@echo off
mkdir build
cd build
echo:
echo =============================== Running Bin2BCD-MM Testbench ===============================
echo:
vsim -c -do "do ../scripts/bin2bcd_mm_tb.do"