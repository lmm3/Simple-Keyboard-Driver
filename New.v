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
initial
begin
b<=4'h1;
flag<=1'b0;
data_curr<=8'hf0;
data_pre<=8'hf0;
led<=8'hf0;
end
parameter clr = 8'b01110000, add = 8'b01101001, sub = 8'b01110010, disp = 8'b01111010, load = 8'b01101011;
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
led<= 8'd0;
 else
 led<=data_curr;
 case(led)
	clr:
	instruction <= 3'b000;
	add:
	instruction <= 3'b001;
	sub:
	instruction <= 3'b010;
	disp:
	instruction <= 3'b011;
	load:
	instruction <= 3'b100;
	default:
	instruction <= 3'b101;
endcase
end 
endmodule
