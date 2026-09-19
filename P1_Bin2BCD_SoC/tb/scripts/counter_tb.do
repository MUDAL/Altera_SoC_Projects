# Create libraries
if {[file exists work]} {
    vdel -lib work -all
}
vlib work
vmap work work

# Compile SystemVerilog design and testbench files
vlog -work work -sv -stats=none ../../rtl/counter.sv
vlog -work work -sv -stats=none ../counter_tb.sv

# Load design
vsim work.counter_tb

# Run simulation
run -all