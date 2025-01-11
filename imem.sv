module imem(

    input [9:0] addr,
    output [31:0] data

);


logic [31:0] instruction_mem [0:1023];

assign data = instruction_mem[addr];


endmodule