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

`ifndef _INST32_IFORMAT_INCLUDE_
`define _INST32_IFORMAT_INCLUDE_

//-----------------------------------------------------------------------------
// Class: inst32_iformat
// Class for RV32 I format immediate instructions {JALR, LB, ..., ADDI, ...}
//-----------------------------------------------------------------------------
class inst32_iformat extends inst32;    
  `uvm_object_utils(inst32_iformat)

  //-------------------------------------------------------
  // Externally defined tasks and functions
  //-------------------------------------------------------
  extern function new(string name = "inst32", inst_t inst=0);
  //extern function new(string name = "inst32_iformat");
  //extern virtual function void set_inst_value(inst_t inst);
  extern static function inst32_iformat new_from_funct3_shamt_imm(decoder my_decoder,
                                                                  funct3_t funct3,
                                                                  shamt_t shamt,
                                                                  bit[31:25] imm_code
                                                                  );
  extern static function inst32_iformat new_nonspecial_from_funct3_op_imm(decoder my_decoder, 
                                                                          funct3_t funct3,
                                                                          opcode_t op,
                                                                          imm_low_t imm
                                                                          );
  extern static function shamt_t get_shamt_from_imm(imm_low_t imm);
  extern protected static function i_inst_t set_imm(i_inst_t in, imm_low_t imm);
  extern virtual function void sample_cov();
  extern virtual function bit is_shamt();
  extern virtual function real get_nonspecial_imm_cov();
  extern virtual function real get_nonspecial_inst_x_imm_cov();
  extern virtual function real get_shamt_cov();
  extern virtual function real get_shamt_inst_x_shamt_cov();
  extern virtual function shamt_t get_shamt();     
  extern virtual function imm_low_t get_imm();
  extern virtual function string get_imm_string();
  
  //-------------------------------------------------------
  // Covergroup: imm_cg 
  // Creates the coverpoints and cross coverpoints
  //-------------------------------------------------------
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
  endgroup // imm_cg

  //-------------------------------------------------------
  // Covergroup: mem_cg
  // Creates the coverpoints and cross coverpoints.
  // This is very similar to the Store inst32_sformat::mem_cg 
  // but the immediates are encoded differently.  
  // Ideally some of the similarities could be used to
  // generalize the code. 
  //-------------------------------------------------------
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
endclass: inst32_iformat

//-----------------------------------------------------------------------------
// Constructor: new
// Initializes the inst32_iformat class object and creates the covergroup
//
// Parameters:
//  name - instance name of the inst32
//  inst - 32bit instruction value
//-----------------------------------------------------------------------------
function inst32_iformat::new(string name = "inst32", inst_t inst=0);
  super.new(name);
  m_inst = inst;
  m_rvg_format = I;   
  // Creating the covergroups
  imm_cg = new(get_imm(), get_inst_enum());    
  mem_cg = new();
endfunction: new

////-----------------------------------------------------------------------------
//// Constructor: new
//// Initializes the inst32_iformat class object and creates the covergroup
////
//// Parameters:
////  name - instance name of the inst32_iformat
////-----------------------------------------------------------------------------
//function inst32_iformat::new(string name = "inst32_iformat");
//  super.new(name);
//  m_rvg_format = I;   
//  imm_cg = new(get_imm(), get_inst_enum());    
//endfunction: new
//
////-----------------------------------------------------------------------------
//// Function: set_inst_value
//// Sets the instruction value 
////
//// Parameters:
////  inst - 32bit instruction value
////-----------------------------------------------------------------------------
//function void inst32_iformat::set_inst_value(inst_t inst);
//  m_inst = inst;
//endfunction: set_inst_value

//-----------------------------------------------------------------------------
// Function: new_from_funct3_shamt_imm
// Creates the I format instruction from shamt imm 
// TODO: Mostly used for unit testing. Need to revisit this. 
//-----------------------------------------------------------------------------
function inst32_iformat inst32_iformat::new_from_funct3_shamt_imm(decoder my_decoder,
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

endfunction: new_from_funct3_shamt_imm

//-----------------------------------------------------------------------------
// Function: new_nonspecial_from_funct3_op_imm
// Creates the I format instruction from op imm 
// TODO: Mostly used for unit testing. Need to revisit this. 
//-----------------------------------------------------------------------------
function inst32_iformat inst32_iformat::new_nonspecial_from_funct3_op_imm(decoder my_decoder, 
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

endfunction: new_nonspecial_from_funct3_op_imm

//-----------------------------------------------------------------------------
// Function: get_shamt_from_imm
// Get the shift amount from the immediate value of the instruction
// 
// Parameters:
//  imm - lower 12bit immediate value
//
// Returns:
//  5bit shift value derived from immediate value
//-----------------------------------------------------------------------------
function shamt_t inst32_iformat::get_shamt_from_imm(imm_low_t imm);
  return imm[SHAMT_W-1:0];    
endfunction: get_shamt_from_imm    

//-----------------------------------------------------------------------------
// Function: set_imm
// Stores the low immediate value in the I format instruction
//
// Parameters:
//  in - I format instruction value
//  imm - lower 12bit immediate value
// 
// Returns:
//  I format instruction verif object
//-----------------------------------------------------------------------------
function i_inst_t inst32_iformat::set_imm(i_inst_t in, imm_low_t imm);
  i_inst_t ret = in;
  ret.imm = imm;
  return ret;        
endfunction: set_imm  

//-----------------------------------------------------------------------------
// Function: sample_cov
// Samples the covergroups
//-----------------------------------------------------------------------------
function void inst32_iformat::sample_cov();
  super.sample_from_subclass();    
  imm_cg.sample();
  mem_cg.sample();
endfunction: sample_cov

//-----------------------------------------------------------------------------
// Function: is_shamt
// Check to see if shift-amount exist in the instruction
// 
// Returns:
//  '1' if shift-amount is present in the I format instruction
//-----------------------------------------------------------------------------
function bit inst32_iformat::is_shamt();
  return get_inst_enum() inside {I_SHAMT_INSTS};
endfunction: is_shamt

//-----------------------------------------------------------------------------
// Function: get_nonspecial_imm_cov
// Get the coverage value of immediate covergroup
//
// Returns:
//  Real precision coverage value 
//-----------------------------------------------------------------------------
function real inst32_iformat::get_nonspecial_imm_cov();
  assert(get_inst_enum() inside {I_NONSPECIAL_INSTS});    
  return imm_cg.i32i_imm_cp.get_coverage();
endfunction: get_nonspecial_imm_cov

//-----------------------------------------------------------------------------
// Function: get_nonspecial_inst_x_imm_cov
// Get the coverage value of immediate cross coverpoint
//
// Returns:
//  Real precision cross coverage value 
//-----------------------------------------------------------------------------
function real inst32_iformat::get_nonspecial_inst_x_imm_cov();
  return imm_cg.i32i_inst_x_imm.get_coverage();
endfunction: get_nonspecial_inst_x_imm_cov

//-----------------------------------------------------------------------------
// Function: get_shamt_cov
// Get the shift-amount coverage value 
//
// Returns:
//  Real precision coverage value 
//-----------------------------------------------------------------------------
function real inst32_iformat::get_shamt_cov();
  assert(is_shamt()) 
  else 
    `uvm_info(get_type_name(),$sformatf("get_shamt_cov() for non shamt inst"),UVM_NONE);

  return imm_cg.i32i_shamt_cp.get_coverage();    
endfunction: get_shamt_cov
   
//-----------------------------------------------------------------------------
// Function: get_shamt_inst_x_shamt_cov
// Get the shift-amount cross coverage value 
//
// Returns:
//  Real precision coverage value 
//-----------------------------------------------------------------------------
function real inst32_iformat::get_shamt_inst_x_shamt_cov();
  return imm_cg.i32i_shamt_inst_x_shamt.get_coverage();    
endfunction: get_shamt_inst_x_shamt_cov

//-----------------------------------------------------------------------------
// Function: get_shamt
// Get the shift-amount value of the I format instruction
//
// Returns:
//  5bit shift value derived from immediate value
//-----------------------------------------------------------------------------
function shamt_t inst32_iformat::get_shamt();     
  assert(is_shamt())
  else 
    `uvm_info(get_type_name(),$sformatf("get_shamt() for non shamt inst"),UVM_NONE);

  return get_shamt_from_imm(get_imm());
endfunction: get_shamt
   
//-----------------------------------------------------------------------------
// Function: get_imm
// Get the immediate value from the I format instruction
//
// Returns:
//  Lower 12bit immediate value
//-----------------------------------------------------------------------------
function imm_low_t inst32_iformat::get_imm();
  return m_inst.i_inst.imm;      
endfunction: get_imm

//-----------------------------------------------------------------------------
// Function: get_imm_string
// Get the string equivalent of the immediate value in the instruction
//
// Returns:
//  String equivalent for the immediate value
//-----------------------------------------------------------------------------
function string inst32_iformat::get_imm_string();
  if (is_shamt()) begin
     return $psprintf("%0d",get_imm());
  end else begin
     int sint = signed'(get_imm());
     return $psprintf("%0d",sint);
  end
endfunction: get_imm_string

`endif
