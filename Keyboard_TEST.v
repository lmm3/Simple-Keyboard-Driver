module keyboard(
input wire clk, // Clock pin form keyboard
input wire data,
input wire ready //Data pin form keyboard
output reg [2:0] instruction 
output reg new_instruction
);

reg [7:0] data_curr;
reg [7:0] out;
reg [7:0] data_pre;
reg [3:0] b;
reg flag;
reg [2:0] state;
wire next_state;

initial
	begin
		b<=4'h1;
		flag<=1'b0;
		data_curr<=8'hf0;
		data_pre<=8'hf0;
		out<=8'hf0;
	end

parameter CLRLD = 8'b01110000, ADD = 8'b01101001, SUB = 8'b01110010, DISP = 8'b01111010, LOAD = 8'b01101011, IDLE;

assign next_state = fsm_function(state,out);

	function [2:0] fsm_function;
		input [2:0] state, out; 
		case(state)
			IDLE:
			if (out == CLRLD) begin
				fsm_function = CLRLD;
				end else if (instruction == ADD) begin
				fsm_function = ADD;
				end else if (out == SUB) begin
				fsm_function = SUB;
				end else if (out == DISP) begin 
				fsm_function = DISP;
				end else if (out == LOAD) begin
				fsm_function = LOAD;
				end else begin
				fsm_function = IDLE;
			end		
			CLRLD: 
			if (out == CLRLD) begin
				fsm_function = CLRLD;
				end else begin 
				fsm_function = IDLE;
			end			
			ADD:
			if (out == ADD) begin
				fsm_function = ADD;
				end else begin 
				fsm_function = IDLE;
			end
			SUB:
			if (out == SUB) begin
				fsm_function = SUB;
				end else begin 
				fsm_function = IDLE;
			end
			DISP:
			if (out == DISP) begin
				fsm_function = DISP;
				end else begin 
				fsm_function = IDLE;
			end
			LOAD:if (out == LOAD) begin
				fsm_function = LOAD;
				end else begin 
				fsm_function = IDLE;
			end
		default: fsm_function = IDLE;
		endcase
	endfunction
	
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
	
	always @ (posedge clk)
	begin
	if (ready == 1'b1) begin
		state <= next_state;
	end else begin
		state <= IDLE;
	end
	end
		
always@(posedge flag) // Printing data obtained to out
	begin
		if(data_curr==8'hf0)
			out<=data_pre;
		else
			data_pre<=data_curr;
		 case(state)
			CLRLD: begin
			instruction <= 3'b000;
			new_instruction <= 1'b1;
			end
			ADD:
			instruction <= 3'b001;
			new_instruction <= 1'b1;
			SUB:
			instruction <= 3'b010;
			new_instruction <= 1'b1;
			DISP:
			instruction <= 3'b011;
			new_instruction <= 1'b1;
			LOAD:
			instruction <= 3'b100;
			new_instruction <= 1'b1;
			IDLE:
			instruction <= 3'b101;
			new_instruction <= 1'b0;
			default:
			instruction <= 3'b101;
			new_instruction <= 1'b0;
		endcase
	end 
endmodule
