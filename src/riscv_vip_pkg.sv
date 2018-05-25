//###############################################################
//
//  Licensed to the Apache Software Foundation (ASF) under one
//  or more contributor license agreements.  See the NOTICE file
//  distributed with this work for additional information
//  regarding copyright ownership.  The ASF licenses this file
//  to you under the Apache License, Version 2.0 (the
//  "License"); you may not use this file except in compliance
//  with the License.  You may obtain a copy of the License at
//  
//  http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the License is distributed on an
//  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
//  KIND, either express or implied.  See the License for the
//  specific language governing permissions and limitations
//  under the License.
//
//###############################################################

// This package contains useful parameters, typedefs, and constants
// for encoding/decoding RISC-V instructions. Initially, only the RV32I base 
// instructions are supported. This file is used throughout the riscv-vip 
// project

`ifndef _RISCV_VIP_PKG_SV_
`define _RISCV_VIP_PKG_SV_

package riscv_vip_pkg;     
   
  //Instruction bit width parameters.
  //based off Table 19.2 of Waterman and Asnovic 2017
  //Fig 2.3, in Patterson and Waterman, RISC-V reader
  parameter int unsigned OPCODE_W    = 7;
  parameter int unsigned FUNCT7_W    = 31-25+1;
  parameter int unsigned REGSEL_W    = 5;
  parameter int unsigned FUNCT3_W    = 14-12+1;
  parameter int unsigned IMM_LOW_W   = 31-20+1;
  parameter int unsigned IMM_HIGH_W  = 31-12+1;
  parameter int unsigned IMM_J_W     = (31-12+1)+1;          //+1 since J drops bit 0
  parameter int unsigned IMM_B_W     = (31-25+1)+(11-7+1)+1; //+1 since B drops bit 0   
  parameter int unsigned SHAMT_W     = 24-20+1;              //shift amount

  parameter int unsigned RV_ADDR_W = 32;   

  //Instruction Common bit/logic types
  typedef logic [OPCODE_W-1   :0] opcode_t;
  typedef logic [FUNCT7_W-1   :0] funct7_t;   //funct7 instruction field  
  typedef logic [REGSEL_W-1   :0] regsel_t;   //type for register rd, rs1/2
  typedef logic [FUNCT3_W-1   :0] funct3_t;   //
  //Immediates 
  typedef logic [IMM_LOW_W-1  :0] imm_low_t; 
  typedef logic [IMM_HIGH_W-1 :0] imm_high_t;
  typedef logic [IMM_J_W-1    :0] j_imm_t;     //J immediate, includes bit 0
  typedef logic [IMM_B_W-1    :0] b_imm_t;     //B immediate, includes bit 0
  typedef logic [SHAMT_W-1    :0] shamt_t;     //I type's shift amount field
   
  typedef logic  [RV_ADDR_W-1  :0] rv_addr_t;
   
   
  //R instruciton type (reg/reg ops)
  typedef struct packed {
    funct7_t  	        funct7;
    regsel_t  	        rs2;
    regsel_t  	        rs1;
    funct3_t  	        funct3;
    regsel_t  	        rd;
    opcode_t  	        op;
  } r_inst_t;

   
  //I instruction format (short immediate)
  typedef struct packed {
    imm_low_t 	        imm;
    regsel_t  	        rs1;
    funct3_t  	        funct3;
    regsel_t            rd;
    opcode_t            op;
  } i_inst_t;

  //Special/different I instruction shift immediate
  //format
  typedef struct packed {
    logic [31:25]	imm_code;
    shamt_t             shamt;
    regsel_t  	        rs1;
    funct3_t  	        funct3;
    regsel_t            rd;
    opcode_t            op;
  } i_shamt_inst_t;

  
  //S instruction format (stores)
  typedef struct packed {
    logic [31-25:0]    imm_11_5;
    regsel_t           rs2;
    regsel_t           rs1;
    funct3_t           funct3;
    logic [11-07:0]    imm_4_0;
    opcode_t           op;
  } s_inst_t;

  //B instruction format (conditional branches)
  typedef struct packed {
    logic              imm_12;
    logic [30-25:0]    imm_10_5;
    regsel_t           rs2;
    regsel_t           rs1;
    funct3_t           funct3;
    logic [11-08:0]    imm_4_1;
    logic              imm_11;      
    opcode_t           op;
  } b_inst_t;

  //U instruction format (long immediate)
  typedef struct packed {
    logic [31-12:0]    imm_31_12;
    regsel_t           rd;
    opcode_t           op;
  } u_inst_t;

  //J instruction format (unconditional jumps)
  typedef struct packed {
    logic              imm_20;
    logic [30-21:0]    imm_10_1;
    logic              imm_11;
    logic [19-12:0]    imm_19_12;
    regsel_t           rd;
    opcode_t           op;
  } j_inst_t;

  //union of all instruction formats
  typedef union packed {
    logic [31:0]       raw_bits;
    r_inst_t           r_inst;
    i_inst_t           i_inst;
    s_inst_t           s_inst;
    b_inst_t           b_inst;      
    u_inst_t           u_inst;
    j_inst_t           j_inst;            
  } inst_t;

  
  //Below enum is derived from riscv-spec-v2.2.pdf p103
  //Map of major opcode for RiscV General (RVG)
  typedef enum opcode_t {                         
    //ROW 0
    LOAD        = 7'b00_000_11,
    LOAD_FP     = 7'b00_001_11,
    CUSTOM_0    = 7'b00_010_11,
    MISC_MEM    = 7'b00_011_11,
    OP_IMM      = 7'b00_100_11,
    AUIPC_MAP   = 7'b00_101_11,
    OP_IMM_32   = 7'b00_110_11,
    //ROW 1
    STORE       = 7'b01_000_11,
    STORE_FP    = 7'b01_001_11,
    CUST_1      = 7'b01_010_11,
    AMO         = 7'b01_011_11,
    OP          = 7'b01_100_11,
    LUI_MAP     = 7'b01_101_11,
    OP_32       = 7'b01_110_11,
    //ROW 2
    MADD        = 7'b10_000_11,
    MSUB        = 7'b10_001_11,
    NMSUB       = 7'b10_010_11,
    NMADD       = 7'b10_011_11,
    OP_FP       = 7'b10_100_11,
    RESERVED_0  = 7'b10_101_11,
    CUSTOM_2    = 7'b10_110_11,
    //ROW 3
    BRANCH      = 7'b11_000_11,
    JALR_MAP    = 7'b11_001_11,
    RESERVED_1  = 7'b11_010_11,
    JAL_MAP     = 7'b11_011_11,
    SYSTEM      = 7'b11_100_11,
    RESERVED_2  = 7'b11_101_11,
    CUSTOM_3    = 7'b11_110_11
  }rvg_major_opcode_t;

  
  //RV32I Instructions 
  typedef enum {
    LUI,
    AUIPC,
    JAL,
    JALR,
    BEQ,
    BNE,
    BLT,
    BGE,
    BLTU,
    BGEU,
    LB,
    LH,
    LW,
    LBU,
    LHU,
    SB,
    SH,
    SW,
    ADDI,
    SLTI,
    SLTIU,
    XORI,
    ORI,
    ANDI,
    SLLI,
    SRLI,
    SRAI,
    ADD,
    SUB,
    SLL,
    SLT,            //Set if Less Than
    SLTU,
    XOR,
    SRL,
    SRA,
    OR,
    AND,
    FENCE,
    FENCE_I,
    ECALL,
    EBREAK,
    CSRRW,
    CSRRS,
    CSRRC,
    CSRRWI,
    CSRRSI,
    CSRRCI,
    UNKNOWN_INST
  } inst_enum_t;

  //Lookup a unique instruction enum for R format instructions,
  //keyed by {funct7_t,funct3_t,rvg_major_opcode_t}  
  const inst_enum_t r_inst_by_funct7funct3major[bit[FUNCT7_W+FUNCT3_W+OPCODE_W-1:0]]  = '{
    {7'b0000000,3'b000,OP} : ADD,
    {7'b0100000,3'b000,OP} : SUB,
    {7'b0000000,3'b001,OP} : SLL,
    {7'b0000000,3'b010,OP} : SLT,
    {7'b0000000,3'b011,OP} : SLTU,
    {7'b0000000,3'b100,OP} : XOR,
    {7'b0000000,3'b101,OP} : SRL,
    {7'b0100000,3'b101,OP} : SRA,
    {7'b0000000,3'b110,OP} : OR,
    {7'b0000000,3'b111,OP} : AND
  };

  //List of all U format instructions
  inst_enum_t U_INSTS[] = '{LUI,AUIPC}; 

  //List of all J format instructions
  inst_enum_t J_INSTS[] = '{JAL};

  //Lookup a inst_enum_t by inst opcode in bits [6:0]
  const inst_enum_t uj_inst_by_major[rvg_major_opcode_t] = '{
    LUI_MAP   : LUI,
    AUIPC_MAP : AUIPC,
    JAL_MAP   : JAL,
    default   : UNKNOWN_INST                                                       
  };


  
  //Lookup a HW unique instruction enum for I,S,B formats,
  //keyed by {funct3_t,rvg_major_opcode_t}, some instructions
  //like SRLI, SRAI,  ECALL, EBREAK need bits from the typical
  //imm field to differentiate 
  const bit [31-25:0] SRLI_IMM_31_25 = 7'b0000000;
  const bit [31-25:0] SRAI_IMM_31_25 = 7'b0100000;
  const inst_enum_t I_SHAMT_INSTS[] = '{SLLI, SRLI, SRAI};
  const inst_enum_t I_NONSPECIAL_INSTS[] = '{JALR, 
                                            LB, 
                                            LH, 
                                            LW, 
                                            LBU, 
                                            LHU, 
                                            ADDI, 
                                            SLTI, 
                                            SLTIU, 
                                            XORI, 
                                            ANDI
                                            };

  //List of all S format instructions
  const inst_enum_t S_INSTS[] = '{SB,SH,SW};

  //List of all B format instructions
  const inst_enum_t B_INSTS[] = '{BEQ, BNE, BLT, BGE, BLTU, BGEU};


  //typedef for I,S,B format intructions, for looking up inst enum 
  //by {funct3,opcode} from isb_inst_by_funct3major associative array
  typedef  bit[FUNCT3_W+OPCODE_W-1:0] funct3op_t;   
  const inst_enum_t isb_inst_by_funct3major[funct3op_t] = '{
    {3'b000, JALR_MAP }  : JALR, 
    {3'b000, BRANCH   }  : BEQ,
    {3'b001, BRANCH   }  : BNE,
    {3'b100, BRANCH   }  : BLT,
    {3'b101, BRANCH   }  : BGE,
    {3'b110, BRANCH   }  : BLTU,
    {3'b111, BRANCH   }  : BGEU,
    {3'b000, LOAD     }  : LB,
    {3'b001, LOAD     }  : LH,
    {3'b010, LOAD     }  : LW,
    {3'b100, LOAD     }  : LBU,
    {3'b101, LOAD     }  : LHU,
    {3'b000, STORE    }  : SB,
    {3'b001, STORE    }  : SH,
    {3'b010, STORE    }  : SW,
    {3'b000, OP_IMM   }  : ADDI,
    {3'b010, OP_IMM   }  : SLTI,
    {3'b011, OP_IMM   }  : SLTIU,
    {3'b100, OP_IMM   }  : XORI,
    {3'b110, OP_IMM   }  : ORI,
    {3'b111, OP_IMM   }  : ANDI,
    {3'b001, OP_IMM   }  : SLLI,
    {3'b101, OP_IMM   }  : SRLI, //special... requires imm[31:25] to differentiate 
    {3'b101, OP_IMM   }  : SRAI, //special... requires imm[31:25] to differentiate
    {3'b000, MISC_MEM }  : FENCE,
    {3'b001, MISC_MEM }  : FENCE_I,
    {3'b000, SYSTEM   }  : ECALL,   //special... requires imm to differentiate
    {3'b000, SYSTEM   }  : EBREAK,  //special... requires imm to differentiate
    {3'b001, SYSTEM   }  : CSRRW,   
    {3'b010, SYSTEM   }  : CSRRS,
    {3'b011, SYSTEM   }  : CSRRC,
    {3'b101, SYSTEM   }  : CSRRWI,
    {3'b110, SYSTEM   }  : CSRRSI,
    {3'b111, SYSTEM   }  : CSRRCI,
    default              : UNKNOWN_INST
  };

  //reverse lookup of the above table to get the funct3 of an instruction
  //useful for unit testing, etc.
  function automatic funct3op_t funct3op_from_isb_inst(inst_enum_t inst);
    funct3op_t keys[$];
    keys = isb_inst_by_funct3major.find_index with (item == inst);
    assert(keys.size() == 1);
    return keys[0];    
  endfunction

  //Enum for the instruction formats.   
  typedef enum {
    R,   //Reg to reg
    I,   //Short immediate		
    S,   //Store
    B,   //Branch
    U,   //Long immediate
    J,   //Jump
    UNKNOWN
  } rvg_format_t;

  //Given the risc-v general major opcode ( bits 6:0] of the instruction
  //look up if the format is R, V, or G
  const rvg_format_t rvg_format_by_major[rvg_major_opcode_t] = '{
    LOAD         :I,    
    //LOAD_FP     
    //CUSTOM_0    
    MISC_MEM     :I,
    OP_IMM       :I,   
    AUIPC_MAP    :U,
    OP_IMM_32    :I,
    STORE        :S,
    //STORE_FP    
    //CUST_1      
    //AMO         
    OP           :R,     
    LUI_MAP      :U,        
    //OP_32       
    //ROW 2
    //MADD        
    //MSUB        
    //NMSUB       
    //NMADD       
    //OP_FP       
    //RESERVED_0  
    //CUSTOM_2    
    BRANCH       :B,
    JALR_MAP     :I,  
    //RESERVED_1  
    JAL_MAP      :J,
    SYSTEM       :I,
    //RESERVED_2  
    //CUSTOM_3    
    default      :UNKNOWN 
  };


  //Enumerated type for the different registers
  //Xn_<specialized_name> notation is used
  typedef enum regsel_t {
    X0_ZERO,      //Hardwired zero
    X1_RA,        //Return addr
    X2_SP,        //Stack pointer
    X3_GP,        //Global pointer
    X4_TP,        //Thread pointer
    X5_T0,        //Temp
    X6_T1,        //Temp
    X7_T2,        //Temp
    X8_S0_FP,     //Saved reg / Frame Pointer
    X9_S1,        //Saved reg 
    X10_A0,       //Function arg, return value
    X11_A1,       //Function arg, return value
    X12_A2,       //Function arg
    X13_A3,       //Function arg
    X14_A4,       //Function arg
    X15_A5,       //Function arg
    X16_A6,       //Function arg
    X17_A7,       //Function arg
    X18_S2,       //Saved reg
    X19_S3,       //Saved reg
    X20_S4,       //Saved reg      
    X21_S5,       //Saved reg
    X22_S6,       //Saved reg
    X23_S7,       //Saved reg
    X24_S8,       //Saved reg
    X25_S9,       //Saved reg
    X26_S10,      //Saved reg
    X27_S11,      //Saved reg
    X28_T3,       //Temp
    X29_T4,       //Temp
    X30_T5,       //Temp
    X31_T6        //Temp
  } reg_id_t;
   
endpackage 

`endif 
