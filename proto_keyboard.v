module keyboard(
input wire clk, // Clock pin form keyboard
input wire data, //Data pin form keyboard
output reg [2:0] instruction 
);
reg [7:0] data_curr;
reg [7:0] led;
reg [7:0] data_pre;
reg [3:0] b;
reg flag;
reg [2:0] state;
wire [2:0] next_state;


initial
begin
b<=4'h1;
flag<=1'b0;
data_curr<=8'hf0;
data_pre<=8'hf0;
led<=8'hf0;
end

parameter clr = 8'b01110000, add = 8'b01101001, sub = 8'b01110010, disp = 8'b01111010, load = 8'b01101011;
parameter CLEAR = 3'b000, ADD = 3'b001, SUB = 3'b010, DISP = 3'b011, LOAD = 3'b100, IDLE = 3'b101;

assign next_state = fsm_function (state, data_curr);

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

function [2:0] fsm_function;
input [2:0] state;
input [2:0] data_curr;

case(state)
	IDLE: 
	if(data_curr == clr)begin
			fsm_function = CLEAR;
	end else if (data_curr == add) begin 
			fsm_function = ADD;
	end else if (data_curr == sub) begin
			fsm_function = SUB;
	end else if (data_curr == disp) begin 
			fsm_function = DISP;
	end else if (data_curr == load) begin
			fsm_function = LOAD;
	end else begin
			fsm_function = IDLE;
	end
	ADD:
	if(data_curr == add) begin 
			fsm_function = ADD;
	end else begin
			fsm_function = IDLE;
	end
	SUB:
	if(data_curr == sub) begin
			fsm_function = SUB;
	end else begin 
			fsm_function = IDLE;
	end
	DISP:
	if(data_curr == disp) begin
			fsm_function = DISP;
	end else begin
			fsm_function = IDLE;
	end
	LOAD:
	if(data_curr == load) begin
			fsm_function = LOAD;
	end else begin 
			fsm_function = IDLE;
	end
	default:
	fsm_function = IDLE;
endcase
endfunction


always @ (posedge flag)
begin
	state <= next_state;
end

always@(posedge flag) // Printing data obtained to led
begin
 case(state)
	CLEAR:
	instruction <= 3'b000;
	ADD:
	instruction <= 3'b001;
	SUB:
	instruction <= 3'b010;
	DISP:
	instruction <= 3'b011;
	LOAD:
	instruction <= 3'b100;
	IDLE:
	instruction <= 3'b101;
	default:
	instruction <= 3'b101;
endcase
end 
endmodule
