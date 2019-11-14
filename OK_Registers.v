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
		