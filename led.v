module led(input [3:0]data,
			  input clk,
			  output reg [6:0]hex
			  );
			  
	always@ (posedge clk)
	begin
	case(data)
		 0:hex<=7'b1000000;
		 1:hex<=7'b1111001;
		 2:hex<=7'b0100100;
		 3:hex<=7'b0110000;
		 4:hex<=7'b0011001;
		 5:hex<=7'b0010010;
		 6:hex<=7'b0000010;
		 7:hex<=7'b1111000;
		 8:hex<=7'b0000000;
		 9:hex<=7'b0010000;
		 default:hex<=7'b0000001;
	endcase
	end
endmodule