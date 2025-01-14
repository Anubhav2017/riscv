module imem(

    input [9:0] addr,
    output [31:0] data

);


logic [31:0] instruction_mem [0:1023];

initial begin
    $readmemb("instruction_mem.txt",instruction_mem);
end

assign data = instruction_mem[addr];


endmodule