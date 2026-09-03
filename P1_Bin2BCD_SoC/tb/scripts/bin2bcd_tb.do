# Execute Python script to generate test vectors and status report files
cd ../scripts
if {$tcl_platform(os) eq "Windows NT"} {
    exec python bin2bcd_tb.py
} else {
    exec python3 bin2bcd_tb.py
}

# Ensure you're in the build directory before compiling sources and running simulation
# Reason: ModelSim auto-generated files will be dumped here
cd ../build

# Create libraries
if {[file exists work]} {
    vdel -lib work -all
}
vlib work
vmap work work

# Compile SystemVerilog design and testbench files
vlog -work work -sv -stats=none ../../rtl/pkg.sv
vlog -work work -sv -stats=none ../../rtl/rdc.sv
vlog -work work -sv -stats=none ../../rtl/counter.sv
vlog -work work -sv -stats=none ../../rtl/bin2bcd.sv
vlog -work work -sv -stats=none ../bin2bcd_tb.sv

# Load design
vsim work.bin2bcd_tb

# Run simulation
run -all