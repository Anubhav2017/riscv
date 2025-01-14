iverilog -g2012 -o riscv.vvp riscv_top.sv tb.sv imem.sv instruction_fetch.sv decode.sv data_mem.sv
vvp riscv.vvp
