rm -rf obj_dir
verilator --trace --binary -f verilog_filelist_mmu_top
./obj_dir/Vtb_mmu