module controle(nova_instrucao, instrucao, clk, ready, tx, ty, tz, tula);
	input wire nova_instrucao, clk;
	input wire [2:0] instrucao;
	output reg ready, tula;
	output reg[1:0] tx, ty, tz;
	
	parameter IDLE = 3'b101, CLRLD = 3'b000, ADD = 3'b001, SUB = 3'b010, DISP = 3'b011, LOAD = 3'b100;
	parameter clear = 2'b00, load = 2'b01, hold = 2'b10;
	

	always @ (*)
	begin
	if (nova_instrucao == 0)
		begin
			tx <= hold;
			ty <= hold;
			tz <= hold;
		end
	else begin
		case(instrucao)		
		CLRLD:
		begin
			ready <= 1'b0;
			tx <=  2'b00; 
			ty <=  2'b00;
			tz <=  2'b00;
			ready <= 1'b1;
		end
		ADD:
		begin
			ready <= 1'b0;
			tula <= 1'b0;
			ty <= load;
			tx <= clear;
			tz <= hold;			
			ready <= 1'b1;
		end
		SUB:
		begin
			ready <= 1'b0;
			tula <= 1'b1;
			ty <= load;
			tx <= clear;
			tz <= hold;			
			ready <= 1'b1;
		end
		DISP:
		begin
			ready <= 1'b0;
			tx <= hold;
			ty <= hold;
			tz <= load;
			ready <= 1'b1;
		end
		LOAD:
		begin 
			ready <= 1'b0;
			tx <= load;
			ty <= hold;
			tz <= hold;
			ready <= 1'b1;
		end
		endcase
	end
	end
endmodule

module keyboard(
input wire clk, // Clock pin form keyboard
input wire data,
output reg [2:0] led,
output reg inst,//nova instrucao
input wire ready
 //Printing input data to led
);
reg [7:0] data_curr;
reg [7:0] data_pre;
reg [3:0] b;
reg flag;
integer contador;
initial
begin
b<=4'h1;
flag<=1'b0;
data_curr<=8'hf0;
data_pre<=8'hf0;
led<=3'b000;
inst <= 1'b0;
contador<=0;
end
always @(negedge clk) //Activating at negative edge of clock from keyboard
begin
case(b)
1:; //first bit
2:data_curr[0]<=data;
3:data_curr[1]<=data;
4:data_curr[2]<=data;
5:data_curr[3]<=data;
6:data_curr[4]<=data;
7:data_curr[5]<=data;
8:data_curr[6]<=data;
9:data_curr[7]<=data;
10:flag<=1'b1; //Parity bit
11:flag<=1'b0; //Ending bit
endcase
 if(b<=10)
 b<=b+1;
 else if(b==11)
 b<=1;
end
always@(posedge flag) // Printing data obtained to led
begin
	if(data_curr==8'hf0)
	begin
			if(ready) begin
				inst <= 1'b1;
				case(data_pre)
					8'h70: led<=3'b000;
					8'h69: led<=3'b001;
					8'h72: led<=3'b010;
					8'h7a: led<=3'b011;
					8'h6b: led<=3'b100;
					8'hf0: led<=3'b101;
				endcase
			end
	end

	 else
	 begin
		 inst <= 1'b0;
		 data_pre<=data_curr;
	 end
end 
endmodule

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

module special_register (data_in, tn, clk, data_out);
	input wire [7:0] data_in;
	input wire [1:0] tn;
	input wire clk;
	
	output reg [7:0] data_out;
	
	parameter clear = 2'b00, load = 2'b01, hold = 2'b10;
	reg [7:0]data_aux;
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
		begin
		data_out <= data_in;
		data_aux <= data_in;
		end
		clear:
		data_out <= 8'd0;
		hold:
		data_out <= data_aux;
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
		

module top(A,PS2_Data, PS2_Clock, clk, Y, tz, overflow);
input [7:0] A;
input PS2_Data;
input PS2_Clock;
input clk;
output [7:0] Y;
output [1:0] tz;
output overflow;
wire tula, new_instruction, ready;
wire [7:0] X, data_ula;
wire [1:0] tx, ty;
wire [2:0] instruction;

keyboard m0 (PS2_Clock, PS2_Data, instruction, new_instruction, ready);
controle m1 (new_instruction, instruction, clk, ready, tx, ty, tz, tula);
special_register x  (A, tx, clk, X);
register y  (data_ula, ty, clk, Y);
ula m2(X, Y, tula, data_ula, overflow);

endmodule
