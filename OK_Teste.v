module register (data_in, tn, clk, data_out);
	input wire [7:0] data_in;
	input wire [1:0] tn;
	input wire clk;
	
	output reg [7:0] data_out;
	
	parameter clear = 2'b00, load = 2'b01, hold = 2'b10;
	
	reg [1:0] state;
	wire [1:0] next_state;
	
	assign next_state = fsm_function(state, tn);
	
	function [1:0] fsm_function;
		input [1:0] state;
		input [1:0] tn;
		case (state)
			hold: 
			if (tn == clear) begin
			fsm_function = clear;
			end else if (tn == load) begin 
			fsm_function = load;
			end else begin 
			fsm_function = hold;
			end
			load:
			if (tn == load) begin
			fsm_function = load;
			end else begin
			fsm_function = hold;
			end
			clear:
			if (tn == clear) begin
			fsm_function =  clear;
			end else begin
			fsm_function = hold;
			end
		endcase
	endfunction
	
	always @ (posedge clk)
	begin
		state <= next_state;
	end
	
	always @ (posedge clk)
	begin
	case(state)
		load:
		data_out <= data_in;
		clear:
		data_out <= 8'd0;
		hold:
		data_out <= data_out;
	endcase
	end
endmodule

module controle(new_instruction, instruction, clk, ready, tx, ty, tz, tula);
	input wire new_instruction, clk;
	input wire [2:0] instruction;
	output reg ready, tula;
	output reg[1:0] tx, ty, tz;
	
	parameter IDLE = 3'b101, CLRLD = 3'b000, ADD = 3'b001, SUB = 3'b010, DISP = 3'b011, LOAD = 3'b100;
	parameter clear = 2'b00, load = 2'b01, hold = 2'b10;
	
	reg [2:0] state;
	wire [2:0] next_state;
	
	assign next_state = fsm_function(state, instruction);
	
	function [2:0] fsm_function;
		input [2:0] state, instruction; 
		case(state)
			IDLE:
			if (instruction == CLRLD) begin
				fsm_function = CLRLD;
				end else if (instruction == ADD) begin
				fsm_function = ADD;
				end else if (instruction == SUB) begin
				fsm_function = SUB;
				end else if (instruction == DISP) begin 
				fsm_function = DISP;
				end else if (instruction == LOAD) begin
				fsm_function = LOAD;
				end else begin
				fsm_function = IDLE;
			end		
			CLRLD: 
			if (instruction == CLRLD) begin
				fsm_function = CLRLD;
				end else begin 
				fsm_function = IDLE;
			end			
			ADD:
			if (instruction == ADD) begin
				fsm_function = ADD;
				end else begin 
				fsm_function = IDLE;
			end
			SUB:
			if (instruction == SUB) begin
				fsm_function = SUB;
				end else begin 
				fsm_function = IDLE;
			end
			DISP:
			if (instruction == DISP) begin
				fsm_function = DISP;
				end else begin 
				fsm_function = IDLE;
			end
			LOAD:if (instruction == LOAD) begin
				fsm_function = LOAD;
				end else begin 
				fsm_function = IDLE;
			end
		default: fsm_function = IDLE;
		endcase
	endfunction
	
	always @ (posedge clk)
	begin
	if (new_instruction == 1'b1) begin
		state <= next_state;
	end else begin
		state <= IDLE;
	end
	end
	
	always @ (posedge clk)
	begin
	case(state)
	IDLE:
	begin
		tx <= hold;
		ty <= hold;
		tz <= hold;
		ready <= 1'b1;
	end
	CLRLD:
	begin
		tx <= clear; 
		ty <= clear;
		tz <= clear;
		ready <= 1'b0;
	end
	ADD:
	begin
		tx <= hold;
		ty <= load;
		tz <= hold;
		tula <= 1'b0;
		ready <= 1'b0;
	end
	SUB:
	begin
		tx <= hold;
		ty <= load;
		tz <= hold;
		tula <= 1'b1;
		ready <= 1'b0;
	end
	DISP:
	begin
		tx <= hold;
		ty <= hold;
		tz <= load;
		ready <= 1'b0;
	end
	LOAD:
	begin 
		tx <= load;
		ty <= hold;
		tz <= hold;
		ready <= 1'b0;
	end
	endcase
	end
endmodule

module ula(data_x, data_y, tula, data_ula, overflow);
		input signed [7:0] data_x, data_y;
		input tula;
		output reg signed [7:0] data_ula;
		output reg overflow;
		integer a, b;
		
		always @ (*)
		begin		
			a <= data_x;
			b <= data_y;
			
			if(tula)
				begin
				data_ula <= data_y - data_x;
				if((a-b) < -128 || (a-b) > 127)
				begin
					overflow <= 1'b1;
					end
				else
					begin
					overflow <= 1'b0;
					end
				end
			else 
				begin
				data_ula <= data_y + data_x;
				if((a+b) < -128 || (a+b) > 127)
					begin
					overflow <= 1'b1;
					end
				else
					begin
					overflow <= 1'b0;
					end
				end
			
		end
endmodule

module projeto (clk, data, new_instruction, instruction, data_out, overflow, sinal, ready);
	input clk;
	input [7:0] data;
	input new_instruction;
	input [2:0] instruction;
	
	output [7:0] data_out;
	output overflow, sinal, ready;

	wire [1:0] tx, ty, tz, tula;
	wire [7:0] data_x, data_y, data_z, data_ula;
	
	controle m1(new_instruction, instruction, clk, ready, tx, ty, tz, tula);
	register x(data, tx, clk, data_x);
	register y(data_ula, ty, clk, data_y);
	register z(data_y, tz, clk, data_out);
	ula m2(data_x, data_y, tula, data_ula, overflow);
	
endmodule
		