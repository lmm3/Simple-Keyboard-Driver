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