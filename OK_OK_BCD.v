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
