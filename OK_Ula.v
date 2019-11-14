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