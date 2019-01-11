
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
  
  int unsigned m_cycle;  //The clock cycle associated with retirement of the instruction
  rand inst_t  m_inst;
  rvg_format_t m_rvg_format  = UNKNOWN;
  protected inst_enum_t  m_inst_enum;

  bit [63:0] m_decode_cycle;  //The value of the cycle CSR when instruction decoded
  
  //Member fields for the values of the register pointed to by the rs1/2 fields.
  //These are only relevant for instructions that that have rs1 and/or rs2
  protected xlen_t       m_rs1_val = 'x;
  protected xlen_t       m_rs2_val = 'x;
  
  bit m_rs1_val_set = 0;
  bit m_rs2_val_set = 0;
  bit m_inst_enum_set = 0;
  
  covergroup rd_bins_cg();
    rd_inst_cp : coverpoint m_inst_enum {
      ignore_bins ignore_has_no_rd = {`INSTS_W_NO_RD_LIST};
    }
    rd_bins_cp : coverpoint get_rd() iff ( has_rd() ) {
      bins zero = {X0};
      bins middle = {
        X1,  X2,  X3,  X4,  X5,  X6,  X7,  X8,  X9,  X10,
        X11, X12, X13, X14, X15, X16, X17, X18, X19, X20,
        X21, X22, X23, X24, X25, X26, X27, X28, X29, X30
      };
      bins thirty1 = {X31};
    }
    rd_inst_x_bins : cross rd_inst_cp, rd_bins_cp;            
  endgroup

  covergroup rs1_bins_cg();
    rs1_inst_cp : coverpoint m_inst_enum {
      ignore_bins ignore_has_no_rs1 = {`INSTS_WITH_NO_RS_LIST};
    }
    rs1_bins_cp : coverpoint get_rs1() iff ( has_rs1() ){
      bins zero = {X0};
      bins middle = {
        X1,  X2,  X3,  X4,  X5,  X6,  X7,  X8,  X9,  X10,
        X11, X12, X13, X14, X15, X16, X17, X18, X19, X20,
        X21, X22, X23, X24, X25, X26, X27, X28, X29, X30
      };
      bins thirty1 = {X31};
    }
    rs1_inst_x_bins : cross rs1_inst_cp, rs1_bins_cp;            
  endgroup

  covergroup rs2_bins_cg();
    rs2_inst_cp : coverpoint m_inst_enum {
      bins has_rs2_bins[] = {`INSTS_W_RS2_LIST};
    }
    rs2_bins_cp : coverpoint get_rs2() iff ( has_rs2() ){
      bins zero = {X0};
      bins middle = {
        X1,  X2,  X3,  X4,  X5,  X6,  X7,  X8,  X9,  X10,
        X11, X12, X13, X14, X15, X16, X17, X18, X19, X20,
        X21, X22, X23, X24, X25, X26, X27, X28, X29, X30
      };
      bins thirty1 = {X31};
    }
    rs2_inst_x_bins : cross rs2_inst_cp, rs2_bins_cp;            
  endgroup
  
  covergroup inst_same_regs_cg ();
    inst_cp : coverpoint m_inst_enum;
    same_rd_rs1_cp : coverpoint 1 iff(
      has_rd()  && 
      has_rs1() && 
      (get_rd() == get_rs1())  &&
      (!has_rs2() || has_rs2() && get_rs2() != get_rs1()) &&
      (get_rd()  != X0) ){
        option.weight =0; //only count the cross
      }
    same_rd_rs2_cp : coverpoint 1 iff(
      has_rd()  && 
      has_rs2() && 
      (get_rd() != get_rs1()) &&
      (get_rd() == get_rs2()) &&
      (get_rd()  != X0) ){
        option.weight =0; //only count the cross
      }
    same_rd_rs1_rs2_cp : coverpoint 1 iff(
      has_rd()  && 
      has_rs1() && 
      has_rs2() && 
      (get_rd() == get_rs1()) &&
      (get_rd() == get_rs2()) &&
      (get_rd()  != X0)){
        option.weight =0; //only count the cross
      }
    inst_x_same_rd_rs1 : cross inst_cp, same_rd_rs1_cp {
      ignore_bins ignore_has_no_rs_rd_insts = inst_x_same_rd_rs1 with 
      (inst_cp inside {`INSTS_WITH_NO_RS_LIST, `INSTS_W_NO_RD_LIST} );     
    }
    inst_x_same_rd_rs2 : cross inst_cp, same_rd_rs2_cp {
      ignore_bins ignore_has_no_rs2_rd_insts = inst_x_same_rd_rs2 with 
      (inst_cp inside {`INSTS_W_NO_RD_LIST} || !(inst_cp inside {`INSTS_W_RS2_LIST}) );     
    }    
    inst_x_same_rd_rs1_rs2 : cross inst_cp, same_rd_rs1_rs2_cp {
      ignore_bins ignore_has_no_rs1_rs2_rd_insts = inst_x_same_rd_rs1_rs2 with
      ( !(inst_cp inside {`INSTS_W_RD_RS1_RS2_LIST}) );
    }

  endgroup
    
  function new(inst_t inst);
    m_inst = inst;      
    inst_same_regs_cg = new();
    rd_bins_cg = new();
    rs1_bins_cg = new();
    rs2_bins_cg = new();
  endfunction // new        


  pure virtual function void  sample_cov();

  //sample_from_subclass() is called from abstract sample_cov(),
  //defined in the specific class for b,i,j,r,s,u formats
  protected virtual function void sample_from_subclass();
      inst_same_regs_cg.sample();
      rd_bins_cg.sample();
      rs1_bins_cg.sample();
      rs2_bins_cg.sample();
  endfunction
  
  
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
    return ( !(get_inst_enum() inside {`INSTS_WITH_NO_RS_LIST}) );
  endfunction // has_rs1

  virtual function reg_id_t get_rs1();
    assert(has_rs1()) else $fatal(1);      
    return reg_id_t'(m_inst.b_inst.rs1);      
  endfunction    

  //Set the value of the rs1 register referenced by the instruction.
  virtual function void set_rs1_val(xlen_t val);
    assert(has_rs1()) else $fatal(1,to_string());
    m_rs1_val_set = 1;
    m_rs1_val = val;    
  endfunction   

  virtual function bit has_rs1_val_set();
    return m_rs1_val_set;
  endfunction

  //Get the value of the x[rs1] as referenced by the rs1 field of the instruction
  virtual function xlen_t get_rs1_val();
    assert(has_rs1() && has_rs1_val_set() ) else $fatal(1,to_string());      
    return m_rs1_val;  
  endfunction   
      
  virtual function bit has_rs2();
    return (m_rvg_format inside {B,S,R});
  endfunction // has_rs2

  virtual function reg_id_t get_rs2();
    assert(has_rs2()) else $fatal(1);      
    return reg_id_t'(m_inst.b_inst.rs2);
  endfunction    

  //Set the value of the rs2 register referenced by the instruction.
  //Beware using this with data hazards.  For a 2 stage pipeline with this
  //set at retirement of the instruction the value from the regfile should
  //be good.
  virtual function void set_rs2_val(xlen_t val);
    assert(has_rs2()) else $fatal(1);      
    m_rs2_val_set = 1;
    m_rs2_val = val;    
  endfunction   

  virtual function bit has_rs2_val_set();
    return m_rs2_val_set;
  endfunction

  //Get the value of the x[rs2] as referenced by the rs2 field of the instruction
  //This is the value of x[rs2] from the reg file at decode stage and may be different than the 
  //x[rs2] in the case of data pipeline hazards - beware! 
  virtual function xlen_t get_rs2_val();
    assert(has_rs2() && has_rs2_val_set() ) else $fatal(1);      
    return m_rs2_val;  
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
    
    if (!m_inst_enum_set) begin
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
      endcase // case (m_rvg_format)
  
      //set the member variable 
      m_inst_enum = inst;
      m_inst_enum_set = 1;
    end
    return m_inst_enum;    
    
  endfunction    
      
  virtual function string get_name_string();
    inst_enum_t iet = get_inst_enum();    
    return iet.name();
  endfunction

  protected function string string_base();
    string rvg_format_str;
    rvg_format_str = m_rvg_format.name();
    return $psprintf("%0d %08H %s ", m_cycle, m_inst, rvg_format_str);	
  endfunction


  virtual function string to_string();
    //string str = $psprintf("%032b %s ", m_inst, rvg_format_str);
    string str = string_base();
    string rs_vals ="";
    reg_id_t rd, rs1, rs2;
    xlen_t rs1_val, rs2_val;

    str = string_base();  //common string chunk used by specialized overrides 

    str={str,get_name_string()," "};
    if (has_rd())  begin
      rd = get_rd();      
      str={str, rd.name() ,", "};
    end
    if (has_rs1()) begin
      rs1 = get_rs1();

      str={str, rs1.name(),", "};
      if (has_rs1_val_set()) begin
        //Check that rs val is set first since not all deployments will white box monitor the regfile values
        rs_vals = $psprintf(" |  rf.%s = %0d",rs1.name(),m_rs1_val);
      end
    end
    if (has_rs2()) begin
      rs2 = get_rs2();      
      str={str, rs2.name()," "};
      if (has_rs2_val_set()) begin
        //Check that rs val is set first since not all deployments will white box monitor the regfile values
        rs_vals = $psprintf("%s, rf.%s = %0d",rs_vals, rs2.name(),m_rs2_val);
      end
    end
    if (has_imm()) begin
      str={str, get_imm_string()};
    end
    str = {str, rs_vals};
    
    
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

  //This is useful for unit testing
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
      bins s_insts[] = {`S_INSTS_LIST};
    }
    i32s_inst_x_imm :cross i32s_insts_cp, i32s_imm_cp;
    //TODO VR to cross the value of the register with the offset...
  endgroup


  //This is very similar to the Store inst32_iformat::mem_cg but the immediates
  //are encoded differently.  Ideally some of the similarities could be used to
  //generalize the code. 
  covergroup mem_cg();
    byte_inst_cp : coverpoint 1 iff (m_inst_enum == SB){
      option.weight =0; //only count the cross      
    }
    halfw_inst_cp : coverpoint 1 iff (m_inst_enum == SH){
      bins insts[] = {LH, LHU};
      option.weight =0; //only count the cross
    }
    word_inst_cp : coverpoint 1 iff (m_inst_enum == LW){
      option.weight =0; //only count the cross      
    } 
    byte_offset_align_cp : coverpoint (get_imm() & 'b11) iff (m_inst_enum == SB) {
      bins basics[] = {0,1,2,3}; 
      option.weight =0; //only count the cross
    }
    halfw_offset_align_cp : coverpoint (get_imm() & 'b11) iff (m_inst_enum == SH) {
      bins basics[] = {0,2}; 
      option.weight =0; //only count the cross      
    }
    neg_offset_cp : coverpoint 1 iff (signed'(get_imm() < 0)){
      option.weight =0; //only count the cross            
    }
    neg_base_cp : coverpoint 1 iff (has_rs1_val_set() && (signed'(get_rs1_val()) < 0)){
      option.weight =0; //only count the cross      
    } 
    unaligned_base_cp : coverpoint (get_rs1_val() & 'b11) iff (has_rs1_val_set()) {
      bins basics[] = {1,3}; 
      option.weight =0; //only count the cross      
    }    
    byte_offsets_cross : cross byte_inst_cp, byte_offset_align_cp, neg_offset_cp {
      ignore_bins ignore_neg_zero = binsof(byte_offset_align_cp) intersect {0} && binsof(neg_offset_cp);                        
    }
    halfw_offsets_cross : cross halfw_inst_cp, halfw_offset_align_cp, neg_offset_cp {
      ignore_bins ignore_neg_zero = binsof(halfw_offset_align_cp) intersect {0} && binsof(neg_offset_cp);                        
    }
    word_offset_cross : cross word_inst_cp, neg_offset_cp;
    byte_neg_base_cross : cross byte_inst_cp, neg_base_cp;
    halfw_neg_base_cross : cross halfw_inst_cp, neg_base_cp;
    word_neg_base_cross : cross word_inst_cp, neg_base_cp;
    byte_unaligned_base_cross : cross byte_inst_cp, unaligned_base_cp;
    halfw_unaligned_base_cross : cross halfw_inst_cp, unaligned_base_cp;
    word_unaligned_base_cross : cross word_inst_cp, unaligned_base_cp;    

  endgroup


  //Note the lifecycle of this is only meant for one instruction at a time.
  //Each instruction should be new()
  function new(inst_t inst);     
    super.new(inst);  
    m_rvg_format = S; 
    imm_cg = new(get_imm(),get_inst_enum());
  endfunction // new

  virtual function void sample_cov();
    super.sample_from_subclass();
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


  //Store instructions are a bit non-standard in assembly representation
  //override the base class's defintion
  //Assembly is: sh rs2, offset(rs1)
  virtual function string to_string();
	string str = string_base();
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

  //Create an r type instruction object given the enum, and regs
  static function inst32_rformat new_rformat(
    decoder my_decoder,
    inst_enum_t inst_enum, 
    regsel_t rd, 
    regsel_t rs1, 
    regsel_t rs2
    );
    funct7funct3op_t f7f3o;
    funct7_t f7;
    funct3_t f3;
    opcode_t op;
    r_inst_t inst_bits;
    inst32 i32;
    inst32_rformat i32r;


    f7f3o = funct7funct3op_from_r_inst(inst_enum);
    {f7,f3,op} = f7f3o;
    inst_bits.funct3 = f3;
    inst_bits.funct7 = f7;
    inst_bits.op = op;
    inst_bits.rd = rd;
    inst_bits.rs1 = rs1;
    inst_bits.rs2 = rs2;
    
    i32 = my_decoder.decode_inst32(inst_bits);
    $cast(i32r,i32);
    return i32r;
    
  endfunction

  function new(inst_t inst);     
    super.new(inst);  
    m_rvg_format = R;      
  endfunction	

  virtual function string get_imm_string();
    $fatal(1,"rformat get_imm_string(), r format has no imm.  should not get called");
    return "DEADBEEF";    //make the compiler happy
  endfunction // get_imm_string

  virtual function void sample_cov();
    super.sample_from_subclass();
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

  //useful for unit testing
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

  //useful for unit testing
  static function inst32_iformat new_nonspecial_from_funct3_op_imm(
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
      bins i_nonspecial_insts[] = {`I_NONSPECIAL_INSTS_LIST};
    }
    i32i_shamt_insts_cp : coverpoint inst {
      bins i_shamt_insts[] = {`I_SHAMT_INSTS_LIST};            
    }
    i32i_inst_x_imm :cross i32i_nonspecial_insts_cp, i32i_imm_cp;
    i32i_shamt_inst_x_shamt : cross i32i_shamt_insts_cp, i32i_shamt_cp;
    //TODO fence, ecall/break, csr insts    
    //TODO VR to cross the value of the register with the offset...
  endgroup


  //This is very similar to the Store inst32_sformat::mem_cg but the immediates
  //are encoded differently.  Ideally some of the similarities could be used to
  //generalize the code. 
  covergroup mem_cg();
    byte_inst_cp : coverpoint m_inst_enum iff (m_inst_enum inside {LB, LBU}){
      bins insts[] = {LB, LBU};
      option.weight =0; //only count the cross      
    }
    halfw_inst_cp : coverpoint m_inst_enum iff (m_inst_enum inside {LH, LHU}){
      bins insts[] = {LH, LHU};
      option.weight =0; //only count the cross
    }
    word_inst_cp : coverpoint 1 iff (m_inst_enum == LW){
      option.weight =0; //only count the cross      
    } 
    byte_offset_align_cp : coverpoint (get_imm() & 'b11) iff (m_inst_enum inside {LB, LBU}) {
      bins basics[] = {0,1,2,3}; 
      option.weight =0; //only count the cross
    }
    halfw_offset_align_cp : coverpoint (get_imm() & 'b11) iff (m_inst_enum inside {LH, LHU}) {
      bins basics[] = {0,2}; 
      option.weight =0; //only count the cross      
    }
    neg_offset_cp : coverpoint 1 iff (m_inst_enum inside {LB,LBU,LH,LHU,LW} && signed'(get_imm() < 0)){
      option.weight =0; //only count the cross            
    }
    neg_base_cp : coverpoint 1 iff (m_inst_enum inside {LB,LBU,LH,LHU,LW} && has_rs1_val_set() && (signed'(get_rs1_val()) < 0)){
      option.weight =0; //only count the cross      
    } 
    unaligned_base_cp : coverpoint (get_rs1_val() & 'b11) iff (has_rs1_val_set() && m_inst_enum inside {LB,LBU,LH,LHU,LW}) {
      bins basics[] = {1,3}; 
      option.weight =0; //only count the cross      
    }    
    byte_offsets_cross : cross byte_inst_cp, byte_offset_align_cp, neg_offset_cp {
      ignore_bins ignore_neg_zero = binsof(byte_offset_align_cp) intersect {0} && binsof(neg_offset_cp);                        
    }
    halfw_offsets_cross : cross halfw_inst_cp, halfw_offset_align_cp, neg_offset_cp {
      ignore_bins ignore_neg_zero = binsof(halfw_offset_align_cp) intersect {0} && binsof(neg_offset_cp);                        
    }
    word_offset_cross : cross word_inst_cp, neg_offset_cp;
    byte_neg_base_cross : cross byte_inst_cp, neg_base_cp;
    halfw_neg_base_cross : cross halfw_inst_cp, neg_base_cp;
    word_neg_base_cross : cross word_inst_cp, neg_base_cp;
    byte_unaligned_base_cross : cross byte_inst_cp, unaligned_base_cp;
    halfw_unaligned_base_cross : cross halfw_inst_cp, unaligned_base_cp;
    word_unaligned_base_cross : cross word_inst_cp, unaligned_base_cp;    

  endgroup
  
  
  
  function new(inst_t inst);     
    super.new(inst);  
    m_rvg_format = I;   
    imm_cg = new(get_imm(), get_inst_enum());
    mem_cg = new();
  endfunction			   

  virtual function void sample_cov();
    super.sample_from_subclass();    
    imm_cg.sample();
    mem_cg.sample();
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

  //useful for unit testing
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
      bins b_insts[] = {`B_INSTS_LIST};
    }
    i32b_inst_x_imm :cross i32b_insts_cp, i32b_imm_cp;
    ///i32b_inst_x_val_offset: cross /// TODO
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
    super.sample_from_subclass();
    imm_cg.sample();
  endfunction
  
  virtual function real get_imm_cov();
   return imm_cg.i32b_imm_cp.get_coverage();    
  endfunction
  
endclass // inst32_bformat

class inst32_uformat extends inst32;

  //useful for unit testing
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
      bins u_insts[] = {`U_INSTS_LIST};
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
    super.sample_from_subclass();    
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

  //useful for unit testing
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
      bins j_insts[] = {`J_INSTS_LIST};
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
    super.sample_from_subclass();
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
