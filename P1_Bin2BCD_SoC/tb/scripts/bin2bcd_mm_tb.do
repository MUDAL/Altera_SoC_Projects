# Create libraries
if {[file exists work]} {
    vdel -lib work -all
}
vlib work
vmap work work

# Compile SystemVerilog design and testbench files
vlog -work work -sv -stats=none ../../rtl/pkg.sv
vlog -work work -sv -stats=none ../../rtl/counter.sv
vlog -work work -sv -stats=none ../../rtl/bin2bcd.sv
vlog -work work -sv -stats=none ../../rtl/bin2bcd_mm.sv
vlog -work work -sv -stats=none ../bin2bcd_mm_tb.sv

# Load design
vsim work.bin2bcd_mm_tb

# Run simulation
run -all