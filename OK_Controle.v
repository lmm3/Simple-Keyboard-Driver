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
