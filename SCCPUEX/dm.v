
// data memory
module dm(clk, DMWr, addr, din, dout,choice,position);
   input          clk;
   input          DMWr;
   input  [8:2]   addr;
   input  [31:0]  din;
   input  [1:0]   choice;
   input  [31:0]  position;
   output [31:0]  dout;
     
   reg [31:0] dmem[127:0];
   wire [31:0] addrByte;

   assign addrByte = addr<<2;
      
   assign dout = dmem[addrByte[8:2]];
   
   always @(posedge clk)
   begin
      if (DMWr) begin
        if(choice[0] ==1)
        begin
            if(position == 1) dmem[addrByte[8:2]][ 7: 0] <= din[7:0];
            if(position == 2) dmem[addrByte[8:2]][15: 8] <= din[7:0];
            if(position == 3) dmem[addrByte[8:2]][23:16] <= din[7:0];
            if(position == 4) dmem[addrByte[8:2]][31:24] <= din[7:0];
        end
        else if(choice[1] ==1)
        begin
            if(position == 1) dmem[addrByte[8:2]][ 15:  0] <= din[15:0];
            if(position == 3) dmem[addrByte[8:2]][ 31: 16] <= din[15:0];
        end
        else
        begin
        dmem[addrByte[8:2]] <= din;
        //$display("dmem[0x%8X] = 0x%8X,", addrByte, din); 
        end
        $display("dmem[0x%8X] = 0x%8X,", addrByte, din); 
      end
   end
      
   
endmodule    
