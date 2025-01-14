
f1 = open("../instruction_mem.txt","w")
f2 = open("instruction_describe.txt","r")

R_OPCODE = "0110011"
ADD_FUNC = "000"

for line in f2:
    linedata = line.split("\n")[0]
    if(linedata == "noop"):
        f1.write("0"*32+"\n")
    elif((linedata.split(" ")[0] == "add")):
        contents = linedata.split(" ")
        f1.write("0000000"+bin(int(contents[1]))[2:].zfill(5)+bin(int(contents[2]))[2:].zfill(5)+ADD_FUNC+bin(int(contents[3]))[2:].zfill(5)+R_OPCODE+"\n")
    elif((linedata.split(" ")[0] == "jalr")): 
        contents = linedata.split(" ")
        f1.write(bin(int(contents[1]))[2:].zfill(12)+bin(int(contents[2]))[2:].zfill(5)+"000"+bin(int(contents[3]))[2:].zfill(5)+"1100111"+"\n")
        



f1.close()
f2.close()