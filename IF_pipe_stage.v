`timescale 1ns / 1ps


module IF_pipe_stage(
    input clk, reset,
    input en,
    input [9:0] branch_address,
    input [9:0] jump_address,
    input branch_taken,
    input jump,
    output [9:0] pc_plus4,
    output [31:0] instr
    );
    
// write your code here
    reg [9:0] pc; //Does this have to be 10 bits?
    wire [9:0] w2,w3; //assumed to be 10 bit, could be a different value
    mux2#(10) m1(.a(pc_plus4), .b(branch_address), .sel(branch_taken), .y(w2));
    mux2#(10) m2(.a(w2), .b(jump_address), .sel(jump), .y(w3));
    
    // account for en, which comes from Data Hazard ****
    always @(posedge clk or posedge reset)  
    begin   
        if(reset)   
           pc <= 10'b0000000000;  
        else if (en)
           pc <= w3;
    end  
    
    assign pc_plus4 = pc + 10'b0000000100;
        
    // insert instruction memory module or merge code
   instruction_mem instrct_mem(
    .read_addr(pc), // pc i think
    .data(instr)
    );
    
endmodule
