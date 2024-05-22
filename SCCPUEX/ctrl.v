// `include "ctrl_encode_def.v"


module ctrl(Op, Funct, Zero, 
            RegWrite, MemWrite,
            EXTOp, ALUOp, NPCOp, 
            ALUSrc, GPRSel, WDSel,ALU_A,choice
            );
            
   input  [5:0] Op;       // opcode
   input  [5:0] Funct;    // funct
   input        Zero;
   
   output       RegWrite; // control signal for register write
   output       MemWrite; // control signal for memory write
   output       EXTOp;    // control signal to signed extension
   output [4:0] ALUOp;    // ALU opertion
   output [1:0] NPCOp;    // next pc operation
   output       ALUSrc;   // ALU source for B
   output       ALU_A;    // ALU source for A
   output [1:0] choice;   // choice for sb or sh
   output [1:0] GPRSel;   // general purpose register selection
   output [2:0] WDSel;    // (register) write data selection
   
  // r format
   wire rtype  = ~|Op;
   wire i_add  = rtype& Funct[5]&~Funct[4]&~Funct[3]&~Funct[2]&~Funct[1]&~Funct[0]; // add
   wire i_sub  = rtype& Funct[5]&~Funct[4]&~Funct[3]&~Funct[2]& Funct[1]&~Funct[0]; // sub
   wire i_and  = rtype& Funct[5]&~Funct[4]&~Funct[3]& Funct[2]&~Funct[1]&~Funct[0]; // and
   wire i_or   = rtype& Funct[5]&~Funct[4]&~Funct[3]& Funct[2]&~Funct[1]& Funct[0]; // or
   wire i_slt  = rtype& Funct[5]&~Funct[4]& Funct[3]&~Funct[2]& Funct[1]&~Funct[0]; // slt
   wire i_sltu = rtype& Funct[5]&~Funct[4]& Funct[3]&~Funct[2]& Funct[1]& Funct[0]; // sltu
   wire i_addu = rtype& Funct[5]&~Funct[4]&~Funct[3]&~Funct[2]&~Funct[1]& Funct[0]; // addu
   wire i_subu = rtype& Funct[5]&~Funct[4]&~Funct[3]&~Funct[2]& Funct[1]& Funct[0]; // subu
   wire i_sll  = rtype&~Funct[5]&~Funct[4]&~Funct[3]&~Funct[2]&~Funct[1]&~Funct[0]; // sll
   wire i_nor  = rtype& Funct[5]&~Funct[4]&~Funct[3]& Funct[2]& Funct[1]& Funct[0]; // nor
   wire i_srl  = rtype&~Funct[5]&~Funct[4]&~Funct[3]&~Funct[2]& Funct[1]&~Funct[0]; // srl
   wire i_sllv = rtype&~Funct[5]&~Funct[4]&~Funct[3]& Funct[2]&~Funct[1]&~Funct[0]; // sllv
   wire i_srlv = rtype&~Funct[5]&~Funct[4]&~Funct[3]& Funct[2]& Funct[1]&~Funct[0]; // srlv
   wire i_jr   = rtype&~Funct[5]&~Funct[4]& Funct[3]&~Funct[2]&~Funct[1]&~Funct[0]; // jr
   wire i_jalr = rtype&~Funct[5]&~Funct[4]& Funct[3]&~Funct[2]&~Funct[1]& Funct[0]; // jalr
   wire i_xor  = rtype& Funct[5]&~Funct[4]&~Funct[3]& Funct[2]& Funct[1]&~Funct[0]; // xor
   wire i_sra  = rtype&~Funct[5]&~Funct[4]&~Funct[3]&~Funct[2]& Funct[1]& Funct[0]; // sra
   wire i_srav = rtype&~Funct[5]&~Funct[4]&~Funct[3]& Funct[2]& Funct[1]& Funct[0]; // srav

  // i format
   wire i_addi = ~Op[5]&~Op[4]& Op[3]&~Op[2]&~Op[1]&~Op[0]; // addi
   wire i_ori  = ~Op[5]&~Op[4]& Op[3]& Op[2]&~Op[1]& Op[0]; // ori
   wire i_lw   =  Op[5]&~Op[4]&~Op[3]&~Op[2]& Op[1]& Op[0]; // lw
   wire i_sw   =  Op[5]&~Op[4]& Op[3]&~Op[2]& Op[1]& Op[0]; // sw
   wire i_beq  = ~Op[5]&~Op[4]&~Op[3]& Op[2]&~Op[1]&~Op[0]; // beq
   wire i_lui  = ~Op[5]&~Op[4]& Op[3]& Op[2]& Op[1]& Op[0]; // lui
   wire i_slti = ~Op[5]&~Op[4]& Op[3]&~Op[2]& Op[1]&~Op[0]; // slti
   wire i_bne  = ~Op[5]&~Op[4]&~Op[3]& Op[2]&~Op[1]& Op[0]; // bne
   wire i_andi = ~Op[5]&~Op[4]& Op[3]& Op[2]&~Op[1]&~Op[0]; // andi
   wire i_lb   =  Op[5]&~Op[4]&~Op[3]&~Op[2]&~Op[1]&~Op[0]; // lb  
   wire i_lh   =  Op[5]&~Op[4]&~Op[3]&~Op[2]&~Op[1]& Op[0]; // lh
   wire i_lbu  =  Op[5]&~Op[4]&~Op[3]& Op[2]&~Op[1]&~Op[0]; // lbu
   wire i_lhu  =  Op[5]&~Op[4]&~Op[3]& Op[2]&~Op[1]& Op[0]; // lhu 
   wire i_sb  =   Op[5]&~Op[4]& Op[3]&~Op[2]&~Op[1]&~Op[0]; // lsb  
   wire i_sh  =   Op[5]&~Op[4]& Op[3]&~Op[2]&~Op[1]& Op[0]; // lsh     
  // j format
   wire i_j    = ~Op[5]&~Op[4]&~Op[3]&~Op[2]& Op[1]&~Op[0];  // j
   wire i_jal  = ~Op[5]&~Op[4]&~Op[3]&~Op[2]& Op[1]& Op[0];  // jal

  // generate control signals
  assign RegWrite   = (rtype&~i_jr) | i_lw | i_addi | i_ori | i_jal | i_lui | i_slti | i_andi | i_lb | i_lh | i_lbu | i_lhu; // register write

  assign ALU_A      = i_sll | i_srl | i_sra;                  // ALU A is from rs or shamt


  assign MemWrite   = i_sw | i_sb | i_sh;                           // memory write
  assign ALUSrc     = i_lw | i_sw | i_addi | i_ori | i_lui | i_slti | i_andi | i_lb | i_lh | i_lbu | i_lhu | i_sb | i_sh;   // ALU B is from instruction immediate
  assign EXTOp      = i_addi | i_lw | i_sw | i_slti | i_lb | i_lh | i_lbu | i_lhu | i_sb | i_sh;           // signed extension

  // GPRSel_RD   2'b00
  // GPRSel_RT   2'b01
  // GPRSel_31   2'b10
  assign GPRSel[0] = i_lw | i_addi | i_ori | i_lui | i_slti | i_andi | i_lb | i_lh | i_lbu | i_lhu;
  assign GPRSel[1] = i_jal;
  
  // WDSel_FromALU 3'b000
  // WDSel_FromMEM 3'b001
  // WDSel_FromPC  3'b010
  // WDSel_for lb  3'b011
  // WDSel_for lh  3'b100
  // WDSel_for lbu  3'b101
  // WDSel_for lhu  3'b110
  assign WDSel[0] = i_lw | i_lb | i_lbu;
  assign WDSel[1] = i_jal | i_jalr | i_lb | i_lhu;
  assign WDSel[2] = i_lh | i_lbu | i_lhu;
  // NPC_PLUS4   2'b00
  // NPC_BRANCH  2'b01
  // NPC_JUMP    2'b10
  // NPC_JR      2'b11  jr | jalr
  assign NPCOp[0] = (i_beq & Zero) | (i_bne & ~Zero) | i_jr | i_jalr;
  assign NPCOp[1] = i_j | i_jal | i_jr | i_jalr;
  
  // ALU_NOP   5'b00000
  // ALU_ADD   5'b00001
  // ALU_SUB   5'b00010
  // ALU_AND   5'b00011
  // ALU_OR    5'b00100
  // ALU_SLT   5'b00101
  // ALU_SLTU  5'b00110
  // ALU_SLL   5'b01000
  // ALU_LUI   5'b01001
  // ALU_SRL   5'b01010
  // ALU_XOR   5'b01011
  // ALU_SRA   5'b01100 
  assign ALUOp[0] = i_add | i_lw | i_sw | i_addi | i_and | i_slt | i_addu | i_nor | i_lui | i_slti | i_andi | i_xor | i_lb | i_lh | i_lbu | i_lhu | i_sb | i_sh;
  assign ALUOp[1] = i_sub | i_beq | i_and | i_sltu | i_subu| i_nor | i_bne | i_andi | i_srl | i_srlv | i_xor;
  assign ALUOp[2] = i_or | i_ori | i_slt | i_sltu | i_nor | i_slti | i_sra | i_srav;
  assign ALUOp[3] = i_sll | i_lui | i_srl | i_sllv | i_srlv | i_xor | i_sra | i_srav;
  assign ALUOp[4] = 0;

  assign choice[0] = i_sb;
  assign choice[1] = i_sh;
endmodule
