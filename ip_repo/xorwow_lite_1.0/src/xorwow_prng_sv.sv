`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/07/2021 04:06:49 PM
// Design Name: 
// Module Name: xorwow_prng
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: This random number generator is the default in Nvidia's CUDA toolkit.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module xorwow_prng_sv(
    input clk,
    input p,
    input l,
    input rst,
    input [31:0] x0,
    input [31:0] x1,
    input [31:0] x2,
    input [31:0] x3,
    input [31:0] x4,
    output [31:0] out
    );
typedef enum {pause, load, gnrate} state_type;
state_type current_state, next_state;

typedef struct packed
{
  logic [31:0] counter;
  logic [31:0] x0;
  logic [31:0] x1;
  logic [31:0] x2;
  logic [31:0] x3;
  logic [31:0] x4;
  logic [31:0] s;
  logic [31:0] t;
} my_rng_struct;

my_rng_struct current_rng_state, next_rng_state;
logic [31:0] temp_t, temp_t1, temp_t2, temp_t3, temp_s;

always_ff @(posedge clk)
begin
    current_state <= next_state;
    current_rng_state <= next_rng_state;
end

always_comb
begin
temp_t = 0;
temp_t1 = 0;
temp_t2 = 0;
temp_t3 = 0;
temp_s = 0;
next_rng_state = current_rng_state;
case(current_state)
    pause:
        begin
            next_rng_state = current_rng_state;
            if (rst == 1'b0)
                next_state = load;
            else if (p == 1'b1 & l == 1'b0)
                next_state = pause;
            else if (p == 1'b1 & l == 1'b1)
                next_state = load;
            else
                next_state = gnrate;
        end
    load:
        begin
            next_rng_state.counter = 0;
            next_rng_state.s = 0;
            next_rng_state.t = 0;
            next_rng_state.x0 = x0;
            next_rng_state.x1 = x1;
            next_rng_state.x2 = x2;
            next_rng_state.x3 = x3;
            next_rng_state.x4 = x4;
            if (rst == 1'b0)
                next_state = load;
            else if (p == 1'b1 & l == 1'b0)
                next_state = pause;
            else if (p == 1'b1 & l == 1'b1)
                next_state = load;
            else
                next_state = gnrate;
        end
    gnrate:
        begin
            next_rng_state.t = current_rng_state.x4;
            next_rng_state.s = current_rng_state.x0;
            next_rng_state.x4 = current_rng_state.x3;
            next_rng_state.x3 = current_rng_state.x2;
            next_rng_state.x2 = current_rng_state.x1;
            next_rng_state.x1 = current_rng_state.s;
            temp_t = next_rng_state.t << 2;
            temp_t1 = next_rng_state.t ^ temp_t;
            temp_t2 = temp_t1 << 1;
            temp_t3 = temp_t1 ^ temp_t2;
            temp_s = next_rng_state.s << 4;
            next_rng_state.t = temp_s ^ temp_t3;
            next_rng_state.x0 = next_rng_state.t;
            next_rng_state.counter = next_rng_state.counter + 362437;
            if (rst == 1'b0)
                next_state = load;
            else if (p == 1'b1 & l == 1'b0)
                next_state = pause;
            else if (p == 1'b1 & l == 1'b1)
                next_state = load;
            else
                next_state = gnrate;
        end
    default:
        begin
            next_rng_state = current_rng_state;
            next_state = pause;
        end
endcase
end
assign out = current_rng_state.t + current_rng_state.counter;
endmodule