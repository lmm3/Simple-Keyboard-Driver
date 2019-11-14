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

module register_overflow (data_in, tn, clk, data_out, overflow_in, overflow_out);
	input wire [7:0] data_in;
	input wire [1:0] tn;
	input wire clk;
	input wire overflow_in;
	
	output reg [7:0] data_out;
	output reg overflow_out;
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
		begin
		data_out <= data_in;
		overflow_out <= overflow_in;
		end
		clear:
		begin
		data_out <= 8'd0;
		overflow_out <= 1'b0;
		end
		hold:
		data_out <= data_out;
	endcase
	end
endmodule

module ula(data_x, data_y, tula, data_ula, overflow, new_instruction);
		input signed [7:0] data_x, data_y;
		input tula, new_instruction;
		output reg signed [7:0] data_ula;
		output reg overflow;
		integer aux;
		
		initial aux = 0;
		
		always @ (negedge new_instruction)
		begin		
			if(aux < -128 || aux > 127)
				begin
					overflow <= 1'b1;
					end
				else
					begin
					overflow <= 1'b0;
					end
			
			if(tula)
				begin
				data_ula <= data_y - data_x;
				aux <= data_y - data_x;
				end
			else 
				begin
				data_ula <= data_y + data_x;
				aux <= data_y + data_x;
				end
			
		end
endmodule

	

module complemento (data, data_out, sinal);
input [7:0] data;
output reg [6:0] data_out;
output reg sinal;
always @ (*)
begin
	if(data[6:0] == 0)
	begin 
	sinal <= 1'b0;
	end
	else begin
	sinal <= data [7];
	end
	if (sinal)
	begin
	data_out = ~data[6:0] + 1;
	end
	else begin
	data_out = data[6:0];
	end
end 
endmodule

module add3(in,out);
input [3:0] in;
output [3:0] out;
reg [3:0] out;
always @ (in)
 case (in)
 4'b0000: out <= 4'b0000;
 4'b0001: out <= 4'b0001;
 4'b0010: out <= 4'b0010;
 4'b0011: out <= 4'b0011;
 4'b0100: out <= 4'b0100;
 4'b0101: out <= 4'b1000;
 4'b0110: out <= 4'b1001;
 4'b0111: out <= 4'b1010;
 4'b1000: out <= 4'b1011;
 4'b1001: out <= 4'b1100;
 default: out <= 4'b0000;
 endcase
endmodule

module binary_to_BCD(data,seg1, seg2, seg3, sinal_out);
input [7:0] data;
wire [6:0]A;
output reg [6:0] seg1, seg2, seg3;
output reg sinal_out;
wire sinal;
wire [3:0] ONES, TENS;
wire [1:0] HUNDREDS;
wire [3:0] c1,c2,c3,c4,c5,c6,c7;
wire [3:0] d1,d2,d3,d4,d5,d6,d7;
complemento m0(data, A, sinal);
assign d1 = {2'b0,A[6:5]};
assign d2 = {c1[2:0],A[4]};
assign d3 = {c2[2:0],A[3]};
assign d4 = {c3[2:0],A[2]};
assign d5 = {c4[2:0],A[1]};
assign d6 = {1'b0,c1[3],c2[3],c3[3]};
assign d7 = {c6[2:0],c4[3]};
add3 m1(d1,c1);
add3 m2(d2,c2);
add3 m3(d3,c3);
add3 m4(d4,c4);
add3 m5(d5,c5);
add3 m6(d6,c6);
add3 m7(d7,c7);
assign ONES = {c5[2:0],A[0]};
assign TENS = {c7[2:0],c5[3]};
assign HUNDREDS = {c6[3],c7[3]};
always @ (*)
		 begin
		 sinal_out <= ~sinal;
		  case(ONES)
		   4'd0 : seg1 = 7'b1000000; //to display 0
		   4'd1 : seg1 = 7'b1111001; //to display 1
		   4'd2 : seg1 = 7'b0100100; //to display 2
		   4'd3 : seg1 = 7'b0110000; //to display 3
		   4'd4 : seg1 = 7'b0011001; //to display 4
		   4'd5 : seg1 = 7'b0010010; //to display 5
		   4'd6 : seg1 = 7'b0000010; //to display 6
		   4'd7 : seg1 = 7'b1111000; //to display 7
		   4'd8 : seg1 = 7'b0000000; //to display 8
		   4'd9 : seg1 = 7'b0010000; //to display 9
		   default : seg1 = 7'b0111111; //dash
		  endcase
		 case(TENS)
		   4'd0 : seg2 = 7'b1000000; //to display 0
		   4'd1 : seg2 = 7'b1111001; //to display 1
		   4'd2 : seg2 = 7'b0100100; //to display 2
		   4'd3 : seg2 = 7'b0110000; //to display 3
		   4'd4 : seg2 = 7'b0011001; //to display 4
		   4'd5 : seg2 = 7'b0010010; //to display 5
		   4'd6 : seg2 = 7'b0000010; //to display 6
		   4'd7 : seg2 = 7'b1111000; //to display 7
		   4'd8 : seg2 = 7'b0000000; //to display 8
		   4'd9 : seg2 = 7'b0010000; //to display 9
		   default : seg2 = 7'b0111111; //dash
		  endcase
		  case(HUNDREDS)
		   4'd0 : seg3 = 7'b1000000; //to display 0
		   4'd1 : seg3 = 7'b1111001; //to display 1
		   4'd2 : seg3 = 7'b0100100; //to display 2
		   4'd3 : seg3 = 7'b0110000; //to display 3
		   4'd4 : seg3 = 7'b0011001; //to display 4
		   4'd5 : seg3 = 7'b0010010; //to display 5
		   4'd6 : seg3 = 7'b0000010; //to display 6
		   4'd7 : seg3 = 7'b1111000; //to display 7
		   4'd8 : seg3 = 7'b0000000; //to display 8
		   4'd9 : seg3 = 7'b0010000; //to display 9
		   default : seg3 = 7'b0111111; //dash
		  endcase
		end
endmodule
		

module top(A,PS2_Data, PS2_Clock, clk, seg1, seg2, seg3, overflow, sinal);
input [7:0] A;
input PS2_Data;
input PS2_Clock;
input clk;
output [6:0] seg1, seg2, seg3;
output sinal, overflow;
wire tula, new_instruction, ready, overflow_in;
wire [7:0] Z, Y, X, data_ula;
wire [1:0] tx, ty, tz;
wire [2:0] instruction;

keyboard m0 (PS2_Clock, PS2_Data, instruction, new_instruction, ready);
controle m1 (new_instruction, instruction, clk, ready, tx, ty, tz, tula);
special_register x  (A, tx, clk, X);
register y  (data_ula, ty, clk, Y);
ula m2(X, Y, tula, data_ula, overflow_in, new_instruction);
register_overflow z (Y, tz, clk, Z, overflow_in, overflow);
binary_to_BCD m3 (Z, seg1, seg2, seg3, sinal);

endmodule


