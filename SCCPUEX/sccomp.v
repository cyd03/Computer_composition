module sccomp(clk, rstn, reg_sel, reg_data);
   input          clk;
   input          rstn;
   input [4:0]    reg_sel;
   output [31:0]  reg_data;
   
   wire [31:0]    instr;
   wire [31:0]    PC;
   wire           MemWrite;
   wire [31:0]    dm_addr, dm_din, dm_dout;
   wire [1:0]     choice;
   wire rst = ~rstn;

   reg [31:0] reg_position;
   wire[31:0] wire_position;
//get position
always @(dm_addr)
begin
    if (dm_addr%4 ==0) reg_position = 1;
    if (dm_addr%4 ==1) reg_position = 2;
    if (dm_addr%4 ==2) reg_position = 3;
    if (dm_addr%4 ==3) reg_position = 4;
end
assign wire_position = reg_position;
  // instantiation of single-cycle CPU   
   sccpu U_SCCPU(
         .clk(clk),                 // input:  cpu clock
         .rst(rst),                 // input:  reset
         .instr(instr),             // input:  instruction
         .readdata(dm_dout),        // input:  data to cpu  
         .MemWrite(MemWrite),       // output: memory write signal
         .PC(PC),                   // output: PC
         .aluout(dm_addr),          // output: address from cpu to memory
         .writedata(dm_din),        // output: data from cpu to memory
         .reg_sel(reg_sel),         // input:  register selection
         .reg_data(reg_data),        // output: register data
         .choice(choice)
         );
         
  // instantiation of data memory  
   dm    U_DM(
         .clk(clk),           // input:  cpu clock
         .DMWr(MemWrite),     // input:  ram write
         .addr(dm_addr[8:2]), // input:  ram address
         .din(dm_din),        // input:  data to ram
         .dout(dm_dout),       // output: data from ram
         .choice(choice),
         .position(wire_position)
         );
         
  // instantiation of intruction memory (used for simulation)
   im    U_IM ( 
      .addr(PC[8:2]),     // input:  rom address
      .dout(instr)        // output: instruction
   );
        
endmodule

