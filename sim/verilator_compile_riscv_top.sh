rm -rf obj_dir
verilator --trace --binary -f verilog_filelist_riscv_top
./obj_dir/Vtb_riscv_top