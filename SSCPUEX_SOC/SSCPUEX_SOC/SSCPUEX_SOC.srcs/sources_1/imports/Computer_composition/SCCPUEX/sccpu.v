module sccpu( clk, rst, instr, readdata, PC, MemWrite, aluout, writedata, reg_sel, reg_data,choice);
         
   input      clk;          // clock
   input      rst;          // reset
   
   input [31:0]  instr;     // instruction
   input [31:0]  readdata;  // data from data memory
   
   output [31:0] PC;        // PC address
   output        MemWrite;  // memory write
   output [31:0] aluout;    // ALU output
   output [31:0] writedata; // data to data memory

   output [1:0]  choice;
   
   input  [4:0] reg_sel;    // register selection (for debug use)
   output [31:0] reg_data;  // selected register data (for debug use)
   
   wire        RegWrite;    // control signal to register write
   wire        EXTOp;       // control signal to signed extension
   wire [4:0]  ALUOp;       // ALU opertion
   wire [1:0]  NPCOp;       // next PC operation

   wire [2:0]  WDSel;       // (register) write data selection
   wire [1:0]  GPRSel;      // general purpose register selection
   
   wire        ALUSrc;      // ALU source for B
   wire        ALU_A;       // ALU source for A
   wire        Zero;        // ALU ouput zero

   wire [31:0] NPC;         // next PC

   wire [4:0]  rs;          // rs
   wire [4:0]  rt;          // rt
   wire [4:0]  rd;          // rd
   wire [5:0]  Op;          // opcode
   wire [5:0]  Funct;       // funct
   wire [31:0] shamt;	    // shamt
   wire [15:0] Imm16;       // 16-bit immediate
   wire [31:0] Imm32;       // 32-bit immediate
   wire [25:0] IMM;         // 26-bit immediate (address)
   wire [4:0]  A3;          // register address for write
   wire [31:0] WD;          // register write data
   wire [31:0] RD1;         // register data specified by rs
   wire [31:0] A;           // operator for ALU A
   wire [31:0] B;           // operator for ALU B

   wire [31:0] lb_data;     //  data for lb
   wire [31:0] lh_data;	    //  data for lh
   wire [31:0] lbu_data;    //  data for lbu
   wire [31:0] lhu_data;    //  data for lhu
   
   assign Op = instr[31:26];  // instruction
   assign Funct = instr[5:0]; // funct
   assign rs = instr[25:21];  // rs
   assign rt = instr[20:16];  // rt
   assign rd = instr[15:11];  // rd
   assign shamt = {27'b0, instr[10:6]}; //shamt
   assign Imm16 = instr[15:0];// 16-bit immediate
   assign IMM = instr[25:0];  // 26-bit immediate
   
   reg [31:0] tmp_lb_data;
   reg [31:0] tmp_lbu_data;
   always@(aluout)
   begin
	if(aluout%4==0)begin tmp_lb_data = {{24{readdata[ 7]}}, readdata[ 7: 0]}; tmp_lbu_data = {24'b0, readdata[ 7: 0]};end
        if(aluout%4==1)begin tmp_lb_data = {{24{readdata[15]}}, readdata[15:8 ]}; tmp_lbu_data = {24'b0, readdata[15: 8]};end
	if(aluout%4==2)begin tmp_lb_data = {{24{readdata[23]}}, readdata[23:16]}; tmp_lbu_data = {24'b0, readdata[23:16]};end
	if(aluout%4==3)begin tmp_lb_data = {{24{readdata[31]}}, readdata[31:24]}; tmp_lbu_data = {24'b0, readdata[31:24]};end
   end
   assign lb_data = tmp_lb_data; //data for lb's readdata
   assign lh_data = (aluout%4==2)?{{16{readdata[31]}}, readdata[31:16]}:{{16{readdata[15]}}, readdata[15:0]};//data for lh's readdata
   assign lbu_data = tmp_lbu_data;//data for lbu's readdata
   assign lhu_data = (aluout%4==2)?{16'b0, readdata[31:16]}:{16'b0, readdata[15:0]}; //data for lhu's readdata

   // instantiation of control unit
   ctrl U_CTRL ( 
      .Op(Op), .Funct(Funct), .Zero(Zero),
      .RegWrite(RegWrite), .MemWrite(MemWrite),
      .EXTOp(EXTOp), .ALUOp(ALUOp), .NPCOp(NPCOp), 
      .ALUSrc(ALUSrc), .GPRSel(GPRSel), .WDSel(WDSel),.ALU_A(ALU_A),.choice(choice)
   );
   
   // instantiation of PC
   PC U_PC (
      .clk(clk), .rst(rst), .NPC(NPC), .PC(PC)
   ); 
   
   // instantiation of NPC
   NPC U_NPC ( 
      .PC(PC), .NPCOp(NPCOp), .IMM(IMM), .NPC(NPC),.PCJR(RD1)
   );
   
   // instantiation of register file
   RF U_RF (
      .clk(clk), .rst(rst), .RFWr(RegWrite), 
      .A1(rs), .A2(rt), .A3(A3), 
      .WD(WD),
      .RD1(RD1), .RD2(writedata),
      .reg_sel(reg_sel),
      .reg_data(reg_data) 
   );
   
   // mux for register data to write
   mux4 #(5) U_MUX4_GPR_A3 (
      .d0(rd), .d1(rt), .d2(5'b11111), .d3(5'b0), .s(GPRSel), .y(A3)
   );
   
   // mux for register address to write
   mux8 #(32) U_MUX4_GPR_WD (
      .d0(aluout), .d1(readdata), .d2(PC + 4), .d3(lb_data), .d4(lh_data), .d5(lbu_data), .d6(lhu_data), .d7(32'b0),.s(WDSel), .y(WD)
   );

   // mux for signed extension or zero extension
   EXT U_EXT ( 
      .Imm16(Imm16), .EXTOp(EXTOp), .Imm32(Imm32) 
   );
      // mux for ALU A
   mux2 #(32) U_MUX_ALU_A (
      .d0(RD1), .d1(shamt), .s(ALU_A), .y(A)
   );

   // mux for ALU B
   mux2 #(32) U_MUX_ALU_B (
      .d0(writedata), .d1(Imm32), .s(ALUSrc), .y(B)
   );   
   
   // instantiation of alu
   alu U_ALU ( 
      .A(A), .B(B), .ALUOp(ALUOp), .C(aluout), .Zero(Zero)
   );

endmodule