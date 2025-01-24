
f1 = open("../instruction_mem.txt","w")
f2 = open("instruction_describe.txt","r")


for line in f2:
    linedata = line.split("\n")[0]
    if(linedata == "noop"):
        f1.write("0"*32+"\n")

    elif((linedata.split(" ")[0] == "lui")):
        contents = linedata.split(" ")
        imm = int(contents[1])
        if(imm < 0):
            if(imm < -2**19):
                imm = -2**19
            imm_pos = int(imm+ 2**19)
            imm_u = "1"+bin(imm_pos)[2:].zfill(19)
        else:
            if(imm > (2**19-1)):
                imm = 2**19-1
            imm_pos = imm
            imm_u = "0"+bin(imm_pos)[2:].zfill(19)

        f1.write(imm_u+bin(int(contents[2]))[2:].zfill(5)+"0110111"+"\n")
    
    elif((linedata.split(" ")[0] == "auipc")):
        contents = linedata.split(" ")
        imm = int(contents[1])
        if(imm < 0):
            if(imm < -2**19):
                imm = -2**19
            imm_pos = int(imm+ 2**19)
            imm_u = "1"+bin(imm_pos)[2:].zfill(19)
        else:
            if(imm > (2**19-1)):
                imm = 2**19-1
            imm_pos = imm
            imm_u = "0"+bin(imm_pos)[2:].zfill(19)
        f1.write(imm_u+bin(int(contents[2]))[2:].zfill(5)+"0010111"+"\n")

    elif(linedata.split(" ")[0]=="jal"):
        contents = linedata.split(" ")
        imm = (int(contents[1]))
        if(imm<-1048576):#imm is 13 bit signed
            imm = -1048576
        elif(imm > 1048575):
            imm = 1048575

        imm_div2 = int(imm/2) #imm is even
        imm_div2_pos = 0
        if(imm_div2<0):
            imm_div2_pos += imm_div2+524288
            imm_j = '1'+bin(imm_div2_pos)[2:].zfill(19)+'0'
        else:
            imm_div2_pos = imm_div2
            imm_j = '0'+bin(imm_div2_pos[2:]).zfill(19)+'0'

        f1.write(imm_j[0]+imm_b[10:20]+imm_b[9]+imm_b[1:9]+bin(int(contents[2]))[2:]+"1101111")

    elif((linedata.split(" ")[0] == "jalr")): 
        contents = linedata.split(" ")
        imm = int(contents[1])
        if(imm < -2048):
            imm = -2048
        elif(imm > 2047):
            imm = 2047
        
        if(imm >= 0):
            imm_i = "0"+bin(imm)[2:].zfill(11)
        else:
            imm_pos = imm+2048
            imm_i = "1"+bin(imm_pos)[2:].zfill(11)
        f1.write(imm_i+bin(int(contents[2]))[2:].zfill(5)+"000"+bin(int(contents[3]))[2:].zfill(5)+"1100111"+"\n")

    elif((linedata.split(" ")[0] == "beq")):
        contents = linedata.split(" ")
        imm = (int(contents[1]))
        if(imm<-4096):#imm is 13 bit signed
            imm = -4096
        elif(imm > 4095):
            imm = 4094

        imm_div2 = int(imm/2) #imm is even
        imm_div2_pos = 0
        imm_b = ""
        if(imm_div2<0):
            imm_div2_pos += imm_div2+2048
            imm_b = "1"+bin(imm_div2_pos)[2:].zfill(11)+"0"
        else:
            imm_div2_pos = imm_div2
            imm_b = "0"+bin(imm_div2_pos)[2:].zfill(11)+"0"
        f1.write(imm_b[0]+imm_b[2:8]+bin(int(contents[2]))[2:].zfill(5)+bin(int(contents[3]))[2:].zfill(5)+"000"+imm_b[8:12]+imm_b[1]+"1100011"+"\n")
    elif((linedata.split(" ")[0] == "bne")):
        contents = linedata.split(" ")
        imm = (int(contents[1]))
        if(imm<-4096):#imm is 13 bit signed
            imm = -4096
        elif(imm > 4095):
            imm = 4094

        imm_div2 = int(imm/2) #imm is even
        imm_div2_pos = 0
        imm_b = ''
        if(imm_div2<0):
            imm_div2_pos += imm_div2+2048
            imm_b = '1'+bin(imm_div2_pos)[2:].zfill(11)+'0'
        else:
            imm_div2_pos = imm_div2
            imm_b = '0'+bin(imm_div2_pos)[2:].zfill(11)+'0'

        f1.write(imm_b[0]+imm_b[2:8]+bin(int(contents[2]))[2:].zfill(5)+bin(int(contents[3]))[2:].zfill(5)+"001"+imm_b[8:12]+imm_b[1]+"1100011"+"\n")

    elif((linedata.split(" ")[0] == "blt")):
        contents = linedata.split(" ")
        
        imm = (int(contents[1]))
        if(imm<-4096):#imm is 13 bit signed
            imm = -4096
        elif(imm > 4095):
            imm = 4094

        imm_div2 = int(imm/2) #imm is even
        imm_div2_pos = 0
        imm_b = ''
        if(imm_div2<0):
            imm_div2_pos += imm_div2+2048
            imm_b = '1'+bin(imm_div2_pos)[2:].zfill(11)+'0'
        else:
            imm_div2_pos = imm_div2
            imm_b = '0'+bin(imm_div2_pos)[2:].zfill(11)+'0'

        f1.write(imm_b[0]+imm_b[2:8]+bin(int(contents[2]))[2:].zfill(5)+bin(int(contents[3]))[2:].zfill(5)+"100"+imm_b[8:12]+imm_b[1]+"1100011"+"\n")
        
    elif((linedata.split(" ")[0] == "bge")):
        contents = linedata.split(" ")
        
        imm = (int(contents[1]))
        if(imm<-4096):#imm is 13 bit signed
            imm = -4096
        elif(imm > 4095):
            imm = 4094

        imm_div2 = int(imm/2) #imm is even
        imm_div2_pos = 0
        imm_b = ''
        if(imm_div2<0):
            imm_div2_pos += imm_div2+2048
            imm_b = '1'+bin(imm_div2_pos)[2:].zfill(11)+'0'
        else:
            imm_div2_pos = imm_div2
            imm_b = '0'+bin(imm_div2_pos)[2:].zfill(11)+'0'

        f1.write(imm_b[0]+imm_b[2:8]+bin(int(contents[2]))[2:].zfill(5)+bin(int(contents[3]))[2:].zfill(5)+"101"+imm_b[8:12]+imm_b[1]+"1100011"+"\n")
        
        
    elif((linedata.split(" ")[0] == "bltu")):
        contents = linedata.split(" ")
        
        imm = (int(contents[1]))
        if(imm<-4096):#imm is 13 bit signed
            imm = -4096
        elif(imm > 4095):
            imm = 4094

        imm_div2 = int(imm/2) #imm is even
        imm_div2_pos = 0
        imm_b = ''
        if(imm_div2<0):
            imm_div2_pos += imm_div2+2048
            imm_b = '1'+bin(imm_div2_pos)[2:].zfill(11)+'0'
        else:
            imm_div2_pos = imm_div2
            imm_b = '0'+bin(imm_div2_pos)[2:].zfill(11)+'0'

        f1.write(imm_b[0]+imm_b[2:8]+bin(int(contents[2]))[2:].zfill(5)+bin(int(contents[3]))[2:].zfill(5)+"110"+imm_b[8:12]+imm_b[1]+"1100011"+"\n")
        
        
    elif((linedata.split(" ")[0] == "bgeu")):
        contents = linedata.split(" ")
        
        imm = (int(contents[1]))
        if(imm<-4096):#imm is 13 bit signed
            imm = -4096
        elif(imm > 4095):
            imm = 4094

        imm_div2 = int(imm/2) #imm is even
        imm_div2_pos = 0
        imm_b = ''
        if(imm_div2<0):
            imm_div2_pos += imm_div2+2048
            imm_b = '1'+bin(imm_div2_pos)[2:].zfill(11)+'0'
        else:
            imm_div2_pos = imm_div2
            imm_b = '0'+bin(imm_div2_pos[2:]).zfill(11)+'0'

        f1.write(imm_b[0]+imm_b[2:8]+bin(int(contents[2]))[2:].zfill(5)+bin(int(contents[3]))[2:].zfill(5)+"111"+imm_b[8:12]+imm_b[1]+"1100011"+"\n")

    elif((linedata.split(" ")[0] == "lb")):
        contents = linedata.split(" ")
        imm = int(contents[1])
        if(imm < -2048):
            imm = -2048
        elif(imm > 2047):
            imm = 2047
        
        if(imm >= 0):
            imm_i = "0"+bin(imm)[2:].zfill(11)
        else:
            imm_pos = imm+2048
            imm_i = "1"+bin(imm_pos)[2:].zfill(11)

        f1.write(imm_i+bin(contents[2])[2:].zfill(5)+"000"+bin(contents[3])[2:].zfill(5)+"0000011")
    
    elif((linedata.split(" ")[0] == "lh")):
        contents = linedata.split(" ")
        imm = int(contents[1])
        if(imm < -2048):
            imm = -2048
        elif(imm > 2047):
            imm = 2047
        
        if(imm >= 0):
            imm_i = "0"+bin(imm)[2:].zfill(11)
        else:
            imm_pos = imm+2048
            imm_i = "1"+bin(imm_pos)[2:].zfill(11)
        f1.write(imm_i+bin(contents[2])[2:].zfill(5)+"001"+bin(contents[3])[2:].zfill(5)+"0000011")
        
    elif((linedata.split(" ")[0] == "lw")):
        contents = linedata.split(" ")
        imm = int(contents[1])
        if(imm < -2048):
            imm = -2048
        elif(imm > 2047):
            imm = 2047
        
        if(imm >= 0):
            imm_i = "0"+bin(imm)[2:].zfill(11)
        else:
            imm_pos = imm+2048
            imm_i = "1"+bin(imm_pos)[2:].zfill(11)
        f1.write(imm_i+bin(contents[2])[2:].zfill(5)+"010"+bin(contents[3])[2:].zfill(5)+"0000011")
        
    elif((linedata.split(" ")[0] == "lbu")):
        contents = linedata.split(" ")
        imm = int(contents[1])
        if(imm < -2048):
            imm = -2048
        elif(imm > 2047):
            imm = 2047
        
        if(imm >= 0):
            imm_i = "0"+bin(imm)[2:].zfill(11)
        else:
            imm_pos = imm+2048
            imm_i = "1"+bin(imm_pos)[2:].zfill(11)
        f1.write(imm_i+bin(contents[2])[2:].zfill(5)+"100"+bin(contents[3])[2:].zfill(5)+"0000011")
    
    elif((linedata.split(" ")[0] == "lhu")):
        contents = linedata.split(" ")
        imm = int(contents[1])
        if(imm < -2048):
            imm = -2048
        elif(imm > 2047):
            imm = 2047
        
        if(imm >= 0):
            imm_i = "0"+bin(imm)[2:].zfill(11)
        else:
            imm_pos = imm+2048
            imm_i = "1"+bin(imm_pos)[2:].zfill(11)
        f1.write(imm_i+bin(contents[2])[2:].zfill(5)+"101"+bin(contents[3])[2:].zfill(5)+"0000011")
    
    elif((linedata.split(" ")[0] == "addi")):
        contents = linedata.split(" ")
        imm = int(contents[1])
        if(imm < -2048):
            imm = -2048
        elif(imm > 2047):
            imm = 2047
        
        if(imm >= 0):
            imm_i = "0"+bin(imm)[2:].zfill(11)
        else:
            imm_pos = imm+2048
            imm_i = "1"+bin(imm_pos)[2:].zfill(11)
        f1.write(imm_i+bin(contents[2])[2:].zfill(5)+"000"+bin(contents[3])[2:].zfill(5)+"0010011")
    elif((linedata.split(" ")[0] == "slti")):
        contents = linedata.split(" ")
        imm = int(contents[1])
        if(imm < -2048):
            imm = -2048
        elif(imm > 2047):
            imm = 2047
        
        if(imm >= 0):
            imm_i = "0"+bin(imm)[2:].zfill(11)
        else:
            imm_pos = imm+2048
            imm_i = "1"+bin(imm_pos)[2:].zfill(11)
        f1.write(imm_i+bin(contents[2])[2:].zfill(5)+"010"+bin(contents[3])[2:].zfill(5)+"0010011")

    elif((linedata.split(" ")[0] == "sltiu")):
        contents = linedata.split(" ")
        imm = int(contents[1])
        if(imm < -2048):
            imm = -2048
        elif(imm > 2047):
            imm = 2047
        
        if(imm >= 0):
            imm_i = "0"+bin(imm)[2:].zfill(11)
        else:
            imm_pos = imm+2048
            imm_i = "1"+bin(imm_pos)[2:].zfill(11)
        f1.write(imm_i+bin(contents[2])[2:].zfill(5)+"011"+bin(contents[3])[2:].zfill(5)+"0010011")

    elif((linedata.split(" ")[0] == "xori")):
        contents = linedata.split(" ")
        imm = int(contents[1])
        if(imm < -2048):
            imm = -2048
        elif(imm > 2047):
            imm = 2047
        
        if(imm >= 0):
            imm_i = "0"+bin(imm)[2:].zfill(11)
        else:
            imm_pos = imm+2048
            imm_i = "1"+bin(imm_pos)[2:].zfill(11)
        f1.write(imm_i+bin(contents[2])[2:].zfill(5)+"100"+bin(contents[3])[2:].zfill(5)+"0010011")

    elif((linedata.split(" ")[0] == "ori")):
        contents = linedata.split(" ")
        imm = int(contents[1])
        if(imm < -2048):
            imm = -2048
        elif(imm > 2047):
            imm = 2047
        
        if(imm >= 0):
            imm_i = "0"+bin(imm)[2:].zfill(11)
        else:
            imm_pos = imm+2048
            imm_i = "1"+bin(imm_pos)[2:].zfill(11)
        f1.write(imm_i+bin(contents[2])[2:].zfill(5)+"110"+bin(contents[3])[2:].zfill(5)+"0010011")

    elif((linedata.split(" ")[0] == "andi")):
        contents = linedata.split(" ")
        imm = int(contents[1])
        if(imm < -2048):
            imm = -2048
        elif(imm > 2047):
            imm = 2047
        
        if(imm >= 0):
            imm_i = "0"+bin(imm)[2:].zfill(11)
        else:
            imm_pos = imm+2048
            imm_i = "1"+bin(imm_pos)[2:].zfill(11)
        f1.write(imm_i+bin(contents[2])[2:].zfill(5)+"111"+bin(contents[3])[2:].zfill(5)+"0010011")

    elif((linedata.split(" ")[0] == "add")):
        contents = linedata.split(" ")
        f1.write("0000000"+bin(int(contents[1]))[2:].zfill(5)+bin(int(contents[2]))[2:].zfill(5)+"000"+bin(int(contents[3]))[2:].zfill(5)+"0110011"+"\n")
    elif((linedata.split(" ")[0] == "sub")):
        contents = linedata.split(" ")
        f1.write("0100000"+bin(int(contents[1]))[2:].zfill(5)+bin(int(contents[2]))[2:].zfill(5)+"000"+bin(int(contents[3]))[2:].zfill(5)+"0110011"+"\n")
    elif((linedata.split(" ")[0] == "sll")):
        contents = linedata.split(" ")
        f1.write("0000000"+bin(int(contents[1]))[2:].zfill(5)+bin(int(contents[2]))[2:].zfill(5)+"001"+bin(int(contents[3]))[2:].zfill(5)+"0110011"+"\n")
    elif((linedata.split(" ")[0] == "slt")):
        contents = linedata.split(" ")
        f1.write("0000000"+bin(int(contents[1]))[2:].zfill(5)+bin(int(contents[2]))[2:].zfill(5)+"010"+bin(int(contents[3]))[2:].zfill(5)+"0110011"+"\n")
    elif((linedata.split(" ")[0] == "sltu")):
        contents = linedata.split(" ")
        f1.write("0000000"+bin(int(contents[1]))[2:].zfill(5)+bin(int(contents[2]))[2:].zfill(5)+"011"+bin(int(contents[3]))[2:].zfill(5)+"0110011"+"\n")
    elif((linedata.split(" ")[0] == "xor")):
        contents = linedata.split(" ")
        f1.write("0000000"+bin(int(contents[1]))[2:].zfill(5)+bin(int(contents[2]))[2:].zfill(5)+"100"+bin(int(contents[3]))[2:].zfill(5)+"0110011"+"\n")
    elif((linedata.split(" ")[0] == "srl")):
        contents = linedata.split(" ")
        f1.write("0000000"+bin(int(contents[1]))[2:].zfill(5)+bin(int(contents[2]))[2:].zfill(5)+"101"+bin(int(contents[3]))[2:].zfill(5)+"0110011"+"\n")
    elif((linedata.split(" ")[0] == "sra")):
        contents = linedata.split(" ")
        f1.write("0100000"+bin(int(contents[1]))[2:].zfill(5)+bin(int(contents[2]))[2:].zfill(5)+"101"+bin(int(contents[3]))[2:].zfill(5)+"0110011"+"\n")
    elif((linedata.split(" ")[0] == "or")):
        contents = linedata.split(" ")
        f1.write("0000000"+bin(int(contents[1]))[2:].zfill(5)+bin(int(contents[2]))[2:].zfill(5)+"110"+bin(int(contents[3]))[2:].zfill(5)+"0110011"+"\n")
    elif((linedata.split(" ")[0] == "and")):
        contents = linedata.split(" ")
        f1.write("0000000"+bin(int(contents[1]))[2:].zfill(5)+bin(int(contents[2]))[2:].zfill(5)+"111"+bin(int(contents[3]))[2:].zfill(5)+"0110011"+"\n")
f1.close()
f2.close()