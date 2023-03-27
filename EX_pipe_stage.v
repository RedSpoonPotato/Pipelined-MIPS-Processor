`timescale 1ns / 1ps

module EX_pipe_stage(
    input [31:0] id_ex_instr,
    input [31:0] reg1, reg2,
    input [31:0] id_ex_imm_value,
    input [31:0] ex_mem_alu_result,
    input [31:0] mem_wb_write_back_result,
    input id_ex_alu_src,
    input [1:0] id_ex_alu_op,
    input [1:0] Forward_A, Forward_B,
    output [31:0] alu_in2_out,
    output [31:0] alu_result
    );
    
    // Write your code here
    wire [3:0] ALU_Contrl;
    wire zero;
    ALUControl ALUCntrol(
    .ALUOp(id_ex_alu_op), 
    .Function(id_ex_instr[5:0]),
    .ALU_Control(ALU_Contrl)
    );
    
    wire [31:0] m0_out, m2_out;
    
    mux4#(.mux_width(32)) m0(
    .a(reg1),.b(mem_wb_write_back_result),.c(ex_mem_alu_result),.d(32'h0000),
    .sel(Forward_A),
    .y(m0_out)
    );
    
    mux4#(32) m1(
    .a(reg2),.b(mem_wb_write_back_result),.c(ex_mem_alu_result),.d(32'h0000),
    .sel(Forward_B),
    .y(alu_in2_out)
    );
    
    mux2#(32) m2 (
    .a(alu_in2_out),.b(id_ex_imm_value),
    .sel(id_ex_alu_src),
    .y(m2_out)
    );
    
    ALU ALU(
    .a(m0_out),   
    .b(m2_out), 
    .alu_control(ALU_Contrl),
    .zero(zero), //not sure what to do with this 
    .alu_result(alu_result));
       
endmodule
