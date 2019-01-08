// ############################################################################
//
// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//
// ############################################################################ 

`ifndef _INST32_SFORMAT_INCLUDE_
`define _INST32_SFORMAT_INCLUDE_

//-----------------------------------------------------------------------------
// Class: inst32_sformat 
// Class for RV32 S format store instructions {SB, SH, SW}
//-----------------------------------------------------------------------------
class inst32_sformat extends inst32;
  `uvm_object_utils(inst32_sformat)

  //-------------------------------------------------------
  // Externally defined tasks and functions
  //-------------------------------------------------------
  extern function new(string name = "inst32", inst_t inst=0);
  //extern function new(string name = "inst32_sformat");
  //extern virtual function void set_inst_value(inst_t inst);
  extern virtual function void sample_cov();
  extern virtual function real get_imm_cov();
  extern virtual function real get_sinst_x_imm_cov();
  extern virtual function imm_low_t get_imm();
  extern virtual function string get_imm_string();
  extern virtual function funct3_t get_funct3();
  extern virtual function string to_string();
  // TODO: Below 2 functions are used only for unit testing 
  extern static function inst32_sformat new_from_funct3_imm(decoder my_decoder, 
                                                            funct3_t funct3,
                                                            imm_low_t imm);
  extern protected static function s_inst_t set_imm(s_inst_t in, imm_low_t imm);
  
  //-------------------------------------------------------
  // Covergroup: imm_cg 
  // Creates the coverpoints and cross coverpoints
  //-------------------------------------------------------
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
  endgroup // imm_cg

  //-------------------------------------------------------
  // Covergroup: mem_cg 
  // Creates the coverpoints and cross coverpoints.
  // This is very similar to the Store inst32_iformat::mem_cg 
  // but the immediates are encoded differently.  
  // Ideally some of the similarities could be used to
  // generalize the code. 
  //-------------------------------------------------------
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
        
  endgroup // mem_cg
  
endclass: inst32_sformat

//-----------------------------------------------------------------------------
// Constructor: new
//// Initializes the inst32_sformat class object and creates the covergroup
//
// Parameters:
//  name - instance name of the inst32
//  inst - 32bit instruction value
//-----------------------------------------------------------------------------
function inst32_sformat::new(string name = "inst32", inst_t inst=0);
  super.new(name);
  m_inst = inst;
  m_rvg_format = S; 
  imm_cg = new(get_imm(),get_inst_enum());
endfunction: new

////-----------------------------------------------------------------------------
//// Constructor: new
//// Initializes the inst32_sformat class object and creates the covergroup
//// Note the lifecycle of this is only meant for one instruction at a time
//// Each instruction should be new()
////
//// Parameters:
////  name - instance name of the inst32_sformat
////-----------------------------------------------------------------------------
//function inst32_sformat::new(string name = "inst32_sformat");
//  super.new(name);
//  m_rvg_format = S; 
//  imm_cg = new(get_imm(),get_inst_enum());
//endfunction: new
//
////-----------------------------------------------------------------------------
//// Function: set_inst_value
//// Sets the instruction value 
////
//// Parameters:
////  inst - 32bit instruction value
////-----------------------------------------------------------------------------
//function void inst32_sformat::set_inst_value(inst_t inst);
//  m_inst = inst;
//endfunction: set_inst_value

//-----------------------------------------------------------------------------
// Function: sample_cov
// This function facilitates the sampling of the covergroups 
//-----------------------------------------------------------------------------
function void inst32_sformat::sample_cov();
  super.sample_from_subclass();
  imm_cg.sample();
endfunction: sample_cov

//-----------------------------------------------------------------------------
// Function: get_imm_cov
// Get the coverage value of the immediate covergroup 
//
// Returns:
//  Real precision coverage value 
//-----------------------------------------------------------------------------
function real inst32_sformat::get_imm_cov();
  return imm_cg.i32s_imm_cp.get_coverage();
endfunction: get_imm_cov

//-----------------------------------------------------------------------------
// Function: get_sinst_x_imm_cov
// Get the coverage value of the immediates cross coverpoint
//
// Returns:
//  Real precision coverage value 
//-----------------------------------------------------------------------------
function real inst32_sformat::get_sinst_x_imm_cov();
  return imm_cg.i32s_inst_x_imm.get_coverage();
endfunction: get_sinst_x_imm_cov 

//-----------------------------------------------------------------------------
// Function: get_imm
// Get the low immediate value
//
// Returns:
//  Returns the 12bit low immediate value
//-----------------------------------------------------------------------------
function imm_low_t inst32_sformat::get_imm();
  return {m_inst.s_inst.imm_11_5,m_inst.s_inst.imm_4_0};      
endfunction: get_imm   

//-----------------------------------------------------------------------------
// Function: get_imm_string
// Converts the low immediate value into the string format
//
// Returns:
//  String format equivalent to low immediate value
//-----------------------------------------------------------------------------
function string inst32_sformat::get_imm_string();
  // immediates can be negative
  int sint = signed'(get_imm());
  return $psprintf("%0d",sint);
endfunction: get_imm_string     

//-----------------------------------------------------------------------------
// Function: get_funct3
// Get the function3 embedded in the instruction 
//
// Returns:
//  Returns the 3bit funct3 of the instruction
//-----------------------------------------------------------------------------
function funct3_t inst32_sformat::get_funct3();
  return m_inst.s_inst.funct3;
endfunction: get_funct3 

//-----------------------------------------------------------------------------
// Function: to_string
// Converts the entire instructions into an equivalent string
// Store instructions are a bit non-standard in assembly representation
// Assembly is: sh rs2, offset(rs1)
//
// Returns:
//  String equivalent of the S format instruction
//-----------------------------------------------------------------------------
function string inst32_sformat::to_string();
  string str = string_base();

  reg_id_t rs1 = get_rs1();
  reg_id_t rs2 = get_rs2();    
  str={str,get_name_string()," "};
  if (has_rs2()) str={str, rs2.name(),", "};
  if (has_imm()) str={str, get_imm_string()};
  if (has_rs1()) str={str, "(",rs1.name(),")"};
  return str;      
endfunction: to_string

//-----------------------------------------------------------------------------
// Function: new_from_funct3_imm
// This is useful for unit testing
// TODO: Need to revisit as this has decoder class handle
//-----------------------------------------------------------------------------
function inst32_sformat inst32_sformat::new_from_funct3_imm(decoder my_decoder, 
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

endfunction: new_from_funct3_imm

//-----------------------------------------------------------------------------
// Function: new_from_funct3_imm
// This is useful for unit testing
// TODO: Need to revisit as this has decoder class handle
//-----------------------------------------------------------------------------
function s_inst_t inst32_sformat::set_imm(s_inst_t in, imm_low_t imm);
  s_inst_t ret = in;    
  {ret.imm_11_5,ret.imm_4_0} = imm;
  return ret;    
endfunction: set_imm

`endif 
