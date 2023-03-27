`timescale 1ns / 1ps


module ID_pipe_stage(
    input  clk, reset,
    input  [9:0] pc_plus4,
    input  [31:0] instr,
    input  mem_wb_reg_write,
    input  [4:0] mem_wb_write_reg_addr,
    input  [31:0] mem_wb_write_back_data,
    input  Data_Hazard,
    input  Control_Hazard,
    output [31:0] reg1, reg2,
    output [31:0] imm_value,
    output [9:0] branch_address,
    output [9:0] jump_address,
    output branch_taken,
    output [4:0] destination_reg, 
    output mem_to_reg,
    output [1:0] alu_op,
    output mem_read,  
    output mem_write,
    output alu_src,
    output reg_write,
    output jump
    );
    
    // write your code here 
    // Remember that we test if the branch is taken or not in the decode stage.
    
    //mux for control signals 
    wire [6:0] cntrlOut1;
    wire [6:0] cntrlOut2;

    mux2#(7) m3(   
    .a(cntrlOut1), .b(7'b000000),
    .sel((!Data_Hazard) || Control_Hazard),
    .y(cntrlOut2)
    );

    assign mem_to_reg = cntrlOut2[6];
    assign alu_op = cntrlOut2[5:4];
    assign mem_read = cntrlOut2[3];
    assign mem_write = cntrlOut2[2];
    assign alu_src = cntrlOut2[1];
    assign reg_write = cntrlOut2[0];

    // control module
   wire regDst, brnch;
   control control(
   .reset(reset),
   .opcode(instr[31:26]), 
   .reg_dst(regDst), .mem_to_reg(cntrlOut1[6]), 
   .alu_op(cntrlOut1[5:4]),  
   .mem_read(cntrlOut1[3]), 
   .mem_write(cntrlOut1[2]),
   .alu_src(cntrlOut1[1]), 
   .reg_write(cntrlOut1[0]),
   .branch(brnch), .jump(jump) 
    );

   
    
    // destination reg mux
    mux2#(5) m132(
    .a(instr[20:16]),
    .b(instr[15:11]),
    .sel(regDst),
    .y(destination_reg)
    );


    // register 
    register_file regFile(
    .clk(clk), .reset(reset),  
    .reg_write_en(mem_wb_reg_write), //not sure****  
    .reg_write_dest(mem_wb_write_reg_addr),  
    .reg_write_data(mem_wb_write_back_data),
    .reg_read_addr_1(instr[25:21]), //might be switched 
    .reg_read_addr_2(instr[20:16]),  
    .reg_read_data_1(reg1),  
    .reg_read_data_2(reg2) 
    );
        
    // branch taken
    wire eqTest;
    assign eqTest = (reg1 ^ reg2) == 32'd0;
    assign branch_taken = brnch && eqTest ? 1'b1 : 1'b0;
    
    // sign extend
    sign_extend signEx(
    .sign_ex_in(instr[15:0]),
    .sign_ex_out(imm_value)
    );
    
    // branch address
    assign branch_address = pc_plus4 + (imm_value << 2); 

    // jump address
    assign jump_address = instr[25:0] << 2;
    
    
    
    
endmodule


