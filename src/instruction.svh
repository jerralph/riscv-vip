
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

`ifndef _INSTRUCTION_INCLUDED_
`define _INSTRUCTION_INCLUDED_

//Some macros to limit duplicate code in creating coverage bins
`define IMM_MAX_POS(x)  {1'b0,{($bits(x)-1){1'b1}}}
`define IMM_ALL_ONES(x) {$bits(x){1'b1}}
`define IMM_MIN_NEG(x)  {1'b1,{($bits(x)-1){1'b0}}}
 

virtual class inst16;
endclass // inst16

class inst16_ciformat extends inst16;
endclass // inst16
          
/**
 * CLASS: inst32
 * 
 * Base class for representing 32 bit instructions in OOP
 *
 */
virtual class inst32;
  
  rand inst_t  m_inst;
  rvg_format_t m_rvg_format  = UNKNOWN;
  inst_enum_t  m_inst_enum;
  
  covergroup inst_cg ();
    inst_cp : coverpoint m_inst_enum;
  endgroup
  
  function new(inst_t inst);
    m_inst = inst;      
    inst_cg = new();
  endfunction // new        

  pure virtual function void  sample_cov();
  
  //returns bits
  virtual function opcode_t get_opcode();
    return m_inst.i_inst.op;      
  endfunction // opcode_t

  //This returns an enumerated type
  virtual function rvg_major_opcode_t get_rvg_major_opcode();
    return rvg_major_opcode_t'(get_opcode());    
  endfunction
     
  virtual function bit is_i_format();
    return (m_rvg_format == I);    
  endfunction
  virtual function bit is_u_format();
    return (m_rvg_format == U);    
  endfunction
  virtual function bit is_j_format();
    return (m_rvg_format == J);    
  endfunction
  virtual function bit is_b_format();
    return (m_rvg_format == B);    
  endfunction
  virtual function bit is_s_format();
    return (m_rvg_format == S);    
  endfunction
  virtual function bit is_r_format();
    return (m_rvg_format == R);    
  endfunction
     
   
  virtual function bit has_rd();
    return (!(m_rvg_format inside {B,S}));      
  endfunction // has_rd
  
  virtual function reg_id_t get_rd();
    assert(has_rd()) else $fatal(1);      
    return reg_id_t'(m_inst.i_inst.rd);
  endfunction // get_rd

  virtual function bit has_rs1();
    return (!(m_rvg_format inside {U,J}));
  endfunction // has_rs1

  virtual function reg_id_t get_rs1();
    assert(has_rs1()) else $fatal(1);      
    return reg_id_t'(m_inst.b_inst.rs1);      
  endfunction    

  virtual function bit has_rs2();
    return (m_rvg_format inside {B,S,R});
  endfunction // has_rs2

  virtual function reg_id_t get_rs2();
    assert(has_rs2()) else $fatal(1);      
    return reg_id_t'(m_inst.b_inst.rs2);
  endfunction    

  virtual function bit has_imm();
    return (m_rvg_format != R);      
  endfunction // has_imm

  static function string format_hex_string(bit[31:0] bits);
    return $psprintf("0x%0H",bits);
  endfunction // format_hex_string
                                              
  pure virtual function string get_imm_string();

  //get the inst_enum_t for this inst, the RV32I unique enum. see risc_vip_pkg.sv
  virtual function inst_enum_t get_inst_enum();
    inst_enum_t inst = UNKNOWN_INST;
    case (m_rvg_format)
      R: begin
        r_inst_t r = m_inst.r_inst;
        inst  = r_inst_by_funct7funct3major[{r.funct7,r.funct3,get_opcode()}];
        if (inst == UNKNOWN_INST ) begin
          $display("UNKNOWN_INST {r.funct7,r.funct3,get_opcode()} = {%7b,%3b,%7b}", r.funct7,r.funct3,get_opcode());
        end
      end
      I,S,B: begin
        //$display("ISB Decode 0b%b m_inst.b_inst.funct3 = 0b%b",m_inst, m_inst.b_inst.funct3);
        inst  = isb_inst_by_funct3major[{m_inst.b_inst.funct3,get_opcode()}];

        //Deal with some special cases for I insts, where the immediate field
        //decides on the instruction
        case (inst)
          SRLI,SRAI: begin
            i_shamt_inst_t shamt_inst = i_shamt_inst_t'(m_inst.i_inst);          
            case (shamt_inst.imm_code)
              SRLI_IMM_31_25 : inst = SRLI;
              SRAI_IMM_31_25 : inst = SRAI;
              default : inst = UNKNOWN_INST;
            endcase // case (shamt_inst.imm_code)
          end
          ECALL, EBREAK: begin
            case (m_inst.i_inst.imm)
              0: inst = ECALL;
              1: inst = EBREAK;
              default : inst = UNKNOWN_INST;
            endcase
          end
        endcase
      end
      U,J: begin
        inst  = uj_inst_by_major[get_rvg_major_opcode()];
      end
    endcase
    m_inst_enum = inst;
    return inst;
  endfunction    
      
  virtual function string get_name_string();
    inst_enum_t iet = get_inst_enum();    
    return iet.name();
  endfunction
  
  virtual function string to_string();
    string rvg_format_str = m_rvg_format.name();
    //string str = $psprintf("%032b %s ", m_inst, rvg_format_str);
    string str = $psprintf("%08H %s ", m_inst, rvg_format_str);

    //Some of the below can be condensed with certian simulators, but
    //not with others... 
    reg_id_t rd, rs1, rs2;
    
    str={str,get_name_string()," "};
    if (has_rd())  begin
      rd = get_rd();      
      str={str, rd.name() ,", "};
    end
    if (has_rs1()) begin
      rs1 = get_rs1();      
      str={str, rs1.name(),", "};
    end
    if (has_rs2()) begin
      rs2 = get_rs2();      
      str={str, rs2.name()," "};
    end
    if (has_imm()) str={str, get_imm_string()};
    return str;      
  endfunction // to_string
  
endclass // instruction



/**
 * CLASS: inst32_sformat
 * 
 * Class for RV32 S format store instructions {SB, SH, SW}
 *
 */ 
class inst32_sformat extends inst32;

  static function inst32_sformat new_from_funct3_imm(decoder my_decoder, 
                                                     funct3_t funct3, 
                                                     imm_low_t imm
                                                     );
    s_inst_t inst_bits;    
    inst32 inst;
    inst32_sformat i32s; 

    //work on the bits
    inst_bits = inst32_sformat::set_imm(inst_bits,imm);  
    inst_bits.funct3 = funct3;
    inst_bits.op = STORE;

    //make an object
    inst = my_decoder.decode_inst32(inst_t'(inst_bits));

    //get specific
    assert(inst.m_rvg_format == S);
    $cast(i32s,inst);   

    return i32s;    

  endfunction // new_from_funct3_imm
  
  protected static function s_inst_t set_imm(s_inst_t in, imm_low_t imm);
    s_inst_t ret = in;    
    {ret.imm_11_5,ret.imm_4_0} = imm;
    return ret;    
  endfunction
  
  covergroup imm_cg (imm_low_t imm, inst_enum_t inst);
     //TODO: cover the different fields in isolation (since there is a weird combining)
    
    i32s_imm_cp : coverpoint imm {
      bins basics[] = {0,1,2,4};
      bins max_pos =  {`IMM_MAX_POS(imm)};
      bins all_ones = {`IMM_ALL_ONES(imm)};
      bins min_neg =  {`IMM_MIN_NEG(imm)}; 
    }
    i32s_insts_cp : coverpoint inst {
      bins s_insts[] = S_INSTS;
    }
    i32s_inst_x_imm :cross i32s_insts_cp, i32s_imm_cp;
    //TODO VR to cross the value of the register with the offset...
  endgroup

  //Note the lifecycle of this is only meant for one instruction at a time.
  //Each instruction should be new()
  function new(inst_t inst);     
    super.new(inst);  
    m_rvg_format = S; 
    imm_cg = new(get_imm(),get_inst_enum());
  endfunction // new

  virtual function void sample_cov();
    super.inst_cg.sample();
    imm_cg.sample();
  endfunction

  virtual function real get_imm_cov();
    return imm_cg.i32s_imm_cp.get_coverage();
  endfunction

  virtual function real get_sinst_x_imm_cov();
    return imm_cg.i32s_inst_x_imm.get_coverage();
  endfunction
  
  virtual function imm_low_t get_imm();
    return {m_inst.s_inst.imm_11_5,m_inst.s_inst.imm_4_0};      
  endfunction   

  //store immediates can be negative
  virtual function string get_imm_string();
       int sint = signed'(get_imm());
       return $psprintf("%0d",sint);
  endfunction     

  
  virtual function funct3_t get_funct3();
    return m_inst.s_inst.funct3;
  endfunction

  //Store's are a bit non-standard in assembly representation
  //override the base class's defintion
  //Assembly is: sh rs2, offset(rs1)
  virtual function string to_string();
    string rvg_format_str = m_rvg_format.name();
    string str = $psprintf("%08H %s ", m_inst, rvg_format_str);
    reg_id_t rs1 = get_rs1();
    reg_id_t rs2 = get_rs2();    
    str={str,get_name_string()," "};
    if (has_rs2()) str={str, rs2.name(),", "};
    if (has_imm()) str={str, get_imm_string()};
    if (has_rs1()) str={str, "(",rs1.name(),")"};
    return str;      
  endfunction
  
endclass

  
class inst32_rformat extends inst32;

  function new(inst_t inst);     
    super.new(inst);  
    m_rvg_format = R;      
  endfunction	

  virtual function string get_imm_string();
    $fatal(1,"rformat get_imm_string(), r format has no imm.  should not get called");
    return "DEADBEEF";    //make the compiler happy
  endfunction // get_imm_string

  virtual function void sample_cov();
    super.inst_cg.sample();
  endfunction 

  virtual function funct7_t get_funct7();
    return m_inst.r_inst.funct7;
  endfunction

  virtual function funct3_t get_funct3();
    return m_inst.r_inst.funct3;
  endfunction
  
endclass // inst32_rformat




/**
 * CLASS: inst32_iformat
 * 
 * Class for RV32 I format immediate instructions {JALR, LB, ..., ADDI, ...}
 *
 */    
class inst32_iformat extends inst32;

  static function inst32_iformat new_from_funct3_shamt_imm(
                                                           decoder my_decoder,
                                                           funct3_t funct3,
                                                           shamt_t shamt,
                                                           bit[31:25] imm_code
                                                           );
    i_inst_t inst_bits;    
    inst32 inst;
    inst32_iformat i32i;

    //work on the bits
    inst_bits = inst32_iformat::set_imm(inst_bits,{imm_code,shamt});  
    inst_bits.funct3 = funct3;
    inst_bits.op = OP_IMM;

    //make an object
    inst = my_decoder.decode_inst32(inst_t'(inst_bits));

    //get specific
    assert(inst.m_rvg_format == I);
    $cast(i32i,inst);   

    return i32i;    

  endfunction
   
  static function inst32_iformat new_nonspecial_from_op_funct3_imm(
                                                                   decoder my_decoder, 
                                                                   funct3_t funct3,
                                                                   opcode_t op,
                                                                   imm_low_t imm
                                                                   );
    i_inst_t inst_bits;    
    inst32 inst;
    inst32_iformat i32i; 

    //work on the bits
    inst_bits = inst32_iformat::set_imm(inst_bits,imm);  
    inst_bits.funct3 = funct3;
    inst_bits.op = op;

    //make an object
    inst = my_decoder.decode_inst32(inst_t'(inst_bits));

    //get specific
    assert(inst.m_rvg_format == I);
    $cast(i32i,inst);   

    return i32i;    

  endfunction
 
  
  static function shamt_t get_shamt_from_imm(imm_low_t imm);
    return imm[SHAMT_W-1:0];    
  endfunction    

  
  protected static function i_inst_t set_imm(i_inst_t in, imm_low_t imm);
    i_inst_t ret = in;
    ret.imm = imm;
    return ret;        
  endfunction  

  covergroup imm_cg(imm_low_t imm, inst_enum_t inst);
    
    i32i_imm_cp : coverpoint imm iff ((inst inside {I_NONSPECIAL_INSTS})) {
      bins basics[] = {0,1,2,4};
      bins max_pos =  {`IMM_MAX_POS(imm)};
      bins all_ones = {`IMM_ALL_ONES(imm)};
      bins min_neg =  {`IMM_MIN_NEG(imm)}; 
    }
    //SHAMT is for immediate shifts
    i32i_shamt_cp : coverpoint get_shamt_from_imm(imm) iff ((inst inside {I_SHAMT_INSTS})) {
      bins basics[]      = {0,1,2,4};
      wildcard bins big  = {5'b01??0};                                                                    
      bins max_legal     = {5'b01111};
    } 
    i32i_nonspecial_insts_cp : coverpoint inst {
      bins i_nonspecial_insts[] = I_NONSPECIAL_INSTS;
    }
    i32i_shamt_insts_cp : coverpoint inst {
      bins i_shamt_insts[] = I_SHAMT_INSTS;            
    }
    i32i_inst_x_imm :cross i32i_nonspecial_insts_cp, i32i_imm_cp;
    i32i_shamt_inst_x_shamt : cross i32i_shamt_insts_cp, i32i_shamt_cp;
    //TODO fence, ecall/break, csr insts    
    //TODO VR to cross the value of the register with the offset...
  endgroup

  
  function new(inst_t inst);     
    super.new(inst);  
    m_rvg_format = I;   
    imm_cg = new(get_imm(), get_inst_enum());    
  endfunction			   

  virtual function void sample_cov();
    super.inst_cg.sample();    
    imm_cg.sample();
  endfunction

  virtual function bit is_shamt();
    return get_inst_enum() inside {I_SHAMT_INSTS};
  endfunction
     
  virtual function real get_nonspecial_imm_cov();
    assert(get_inst_enum() inside {I_NONSPECIAL_INSTS});    
    return imm_cg.i32i_imm_cp.get_coverage();
  endfunction

  virtual function real get_nonspecial_inst_x_imm_cov();
    return imm_cg.i32i_inst_x_imm.get_coverage();
  endfunction

  virtual function real get_shamt_cov();
    assert(is_shamt()) else $display("get_shamt_cov() for non shamt inst");
    return imm_cg.i32i_shamt_cp.get_coverage();    
  endfunction
     
  virtual function real get_shamt_inst_x_shamt_cov();
    return imm_cg.i32i_shamt_inst_x_shamt.get_coverage();    
  endfunction
 
  virtual function shamt_t get_shamt();     
    assert(is_shamt()) else $display("get_shamt() for non shamt inst");
    return get_shamt_from_imm(get_imm());
  endfunction
     
  virtual function imm_low_t get_imm();
    return m_inst.i_inst.imm;      
  endfunction // get_imm

  virtual function string get_imm_string();
    if (is_shamt()) begin
       return $psprintf("%0d",get_imm());
    end else begin
       int sint = signed'(get_imm());
       return $psprintf("%0d",sint);
    end
  endfunction      
  
endclass


/**
 * CLASS: inst32_bformat
 * 
 * Class for RV32 B format branch instructions {BEQ, BNE, BLT, BGE, BLTU, BGEU}
 *
 */    
class inst32_bformat extends inst32;

  
  static function inst32_bformat new_from_funct3_imm(decoder my_decoder, 
                                                     funct3_t funct3, 
                                                     b_imm_t imm
                                                     );
    b_inst_t inst_bits;    
    inst32 inst;
    inst32_bformat i32b; 

    //work on the bits
    inst_bits = inst32_bformat::set_imm(inst_bits,imm);  
    inst_bits.funct3 = funct3;
    inst_bits.op = BRANCH;

    //make an object
    inst = my_decoder.decode_inst32(inst_t'(inst_bits));

    //get specific
    assert(inst.m_rvg_format == B);
    $cast(i32b,inst);   

    return i32b;    

  endfunction // new_from_funct3_imm
 
  protected static function b_inst_t set_imm(b_inst_t in, b_imm_t imm);
    b_inst_t ret = in;
    {ret.imm_12,ret.imm_11,ret.imm_10_5, ret.imm_4_1} = (imm>>>1); //sign extend
    return ret;    
  endfunction

  covergroup imm_cg (b_imm_t imm, inst_enum_t inst);
     //TODO: cover the different fields in isolation (since there is a weird combining)
    
    i32b_imm_cp : coverpoint imm {
      bins basics[] = {0,2,4};
      bins max_pos =  {`IMM_MAX_POS(imm)-1};  //LSB is always 0
      bins all_ones = {`IMM_ALL_ONES(imm)-1}; //LSB is always 0
      bins min_neg =  {`IMM_MIN_NEG(imm)}; 
    }
    i32b_insts_cp : coverpoint inst {
      bins b_insts[] = B_INSTS;
    }
    i32b_inst_x_imm :cross i32b_insts_cp, i32b_imm_cp;
    //TODO VR to cross the value of the register with the offset...
  endgroup
  
  //TODO: cover the different fields in isolation (since there is a weird combining)

  function new(inst_t inst);     
    super.new(inst);    
    m_rvg_format = B;
    imm_cg = new(get_imm(),get_inst_enum());        
  endfunction			   
  //The B format imm has 12:1 in inst.. this method adds back the 0 lsb
  virtual function b_imm_t get_imm();
    b_inst_t b = m_inst.b_inst;      
    return {b.imm_12, b.imm_11, b.imm_10_5, b.imm_4_1,1'b0};      
  endfunction // get_imm
  virtual function string get_imm_string();
    int  sint = signed'(get_imm());    
    return $psprintf("%0d",sint);
  endfunction      

  virtual function void sample_cov();
    super.inst_cg.sample();    
    imm_cg.sample();
  endfunction
  
  virtual function real get_imm_cov();
   return imm_cg.i32b_imm_cp.get_coverage();    
  endfunction
  
endclass // inst32_bformat




   
class inst32_uformat extends inst32;

  static function inst32_uformat new_from_op_imm(decoder my_decoder,
                                                 opcode_t op,
                                                 imm_high_t imm
                                                 );
    u_inst_t inst_bits;    
    inst32 inst;
    inst32_uformat i32u;

    //work the bits
    inst_bits = inst32_uformat::set_imm(inst_bits,imm);
    inst_bits.op = op; //not to be confused with ENUM for LUI... other op is AUIPC

    //make an object
    inst = my_decoder.decode_inst32(inst_t'(inst_bits));   

    //get specific
    assert(inst.m_rvg_format == U);
    $cast(i32u,inst);   
    
    return i32u;    
  endfunction
  
  protected static function u_inst_t set_imm(u_inst_t in, imm_high_t imm);
    u_inst_t ret = in;
    ret.imm_31_12 = imm;
    return ret;    
  endfunction

  covergroup imm_cg(imm_high_t imm, inst_enum_t inst);
    //TODO: cover the different fields in isolation (since there is a weird combining)
    
    i32u_imm_cp: coverpoint imm {
      bins basics[] = {0,1,2,4};
      bins max_pos =  {`IMM_MAX_POS(imm)};
      bins all_ones = {`IMM_ALL_ONES(imm)};
      bins min_neg =  {`IMM_MIN_NEG(imm)}; 
    }
    i32u_insts_cp : coverpoint inst {
      bins u_insts[] = U_INSTS;
    }
    i32u_inst_x_imm :cross i32u_insts_cp, i32u_imm_cp;
    //TODO VR for dest reg
  endgroup

  function new(inst_t inst);     
    super.new(inst);  
    m_rvg_format = U;
    imm_cg = new(get_imm(),get_inst_enum());    
  endfunction		

  virtual function void sample_cov();
    super.inst_cg.sample();
    imm_cg.sample();
  endfunction

  virtual function real get_imm_cov();
    return imm_cg.i32u_imm_cp.get_coverage();
  endfunction
  
  virtual function imm_high_t get_imm();
    return m_inst.u_inst.imm_31_12;      
  endfunction   
  virtual function string get_imm_string();
    int  sint = signed'(get_imm());        
    return $psprintf("%0d",sint);
  endfunction      
endclass // inst32_uformat



   
class inst32_jformat extends inst32;

  static function inst32_jformat new_from_imm(decoder my_decoder,
                                              j_imm_t imm
                                              );
    j_inst_t inst_bits;    
    inst32 inst;
    inst32_jformat i32j;

    //work the bits
    inst_bits = inst32_jformat::set_imm(inst_bits,imm);
    inst_bits.op = JAL_MAP; //the one and only RV32I Jump op
    
    //make an object
    inst = my_decoder.decode_inst32(inst_t'(inst_bits));   

    //get specific
    assert(inst.m_rvg_format == J);
    $cast(i32j,inst);   
    
    return i32j;    
  endfunction
    
 
  protected static function j_inst_t set_imm(j_inst_t in, j_imm_t imm);
    j_inst_t ret = in;
    {ret.imm_20,ret.imm_19_12,ret.imm_11,ret.imm_10_1} = (imm>>>1); //sign extend
    return ret;    
  endfunction
  
  covergroup imm_cg(j_imm_t imm, inst_enum_t inst);
    i32j_imm_cp: coverpoint imm {
      bins basics[] = {0,2,4};
      //TODO: cover the different fields in isolation (since there is a weird combining)
      bins max_pos =  {`IMM_MAX_POS(imm)-1};   //LSB is always 0...
      bins all_ones = {`IMM_ALL_ONES(imm)-1};  //LSB is always 0...
      bins min_neg =  {`IMM_MIN_NEG(imm)}; 
    }
    i32j_insts_cp : coverpoint inst {
      bins j_insts[] = J_INSTS;
    }
    i32j_uinst_x_imm :cross i32j_insts_cp, i32j_imm_cp;
    //TODO VR for dest reg
  endgroup


  function new(inst_t inst);     
    super.new(inst);  
    m_rvg_format = J;   
    imm_cg = new(get_imm(),get_inst_enum());       
  endfunction

  virtual function void sample_cov();
    super.inst_cg.sample();
    imm_cg.sample();
  endfunction // sample_cov

  virtual function real get_imm_cov();
    return imm_cg.i32j_imm_cp.get_coverage();
  endfunction
  
	
   //The J format imm has 20:1 in inst.. this method adds back the 0 lsb
  virtual function j_imm_t get_imm();
    j_inst_t j = m_inst.j_inst;            
    return {j.imm_20,j.imm_19_12,j.imm_11,j.imm_10_1,1'b0};      
  endfunction   
  virtual function string get_imm_string();
    int sint = signed'(get_imm());
    return $psprintf("%0d",sint);
  endfunction      
endclass // inst32_jformat
   
	      
`endif //_*INCLUDE_
