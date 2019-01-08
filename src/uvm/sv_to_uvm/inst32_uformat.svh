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

`ifndef _INST32_UFORMAT_INCLUDE_
`define _INST32_UFORMAT_INCLUDE_

//-----------------------------------------------------------------------------
// Class: inst32_uformat
// Class for RV32 U format instructions 
//-----------------------------------------------------------------------------
class inst32_uformat extends inst32;
  `uvm_object_utils(inst32_uformat)

  //-------------------------------------------------------
  // Externally defined tasks and functions
  //-------------------------------------------------------
  extern function new(string name = "inst32", inst_t inst=0);
  //extern function new(string name = "inst32_uformat");
  //extern virtual function void set_inst_value(inst_t inst);
  extern static function inst32_uformat new_from_op_imm(decoder my_decoder,
                                                        opcode_t op,
                                                        imm_high_t imm
                                                        );
  extern protected static function u_inst_t set_imm(u_inst_t in, imm_high_t imm);
  extern virtual function void sample_cov();
  extern virtual function real get_imm_cov();
  extern virtual function imm_high_t get_imm();
  extern virtual function string get_imm_string();

  //-------------------------------------------------------
  // Covergroup: imm_cg 
  // Creates the coverpoints and cross coverpoints
  //-------------------------------------------------------
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
  endgroup // imm_cg

endclass: inst32_uformat

//-----------------------------------------------------------------------------
// Constructor: new
//// Initializes the inst32_uformat class object and creates the covergroup
//
// Parameters:
//  name - instance name of the inst32
//  inst - 32bit instruction value
//-----------------------------------------------------------------------------
function inst32_uformat::new(string name = "inst32", inst_t inst=0);
  super.new(name);
  m_inst = inst;
  m_rvg_format = U;
  imm_cg = new(get_imm(),get_inst_enum());    
endfunction: new

////-----------------------------------------------------------------------------
//// Constructor: new
//// Initializes the inst32_uformat class object and creates the covergroup
////
//// Parameters:
////  name - instance name of the inst32_uformat
////-----------------------------------------------------------------------------
//function inst32_uformat::new(string name = "inst32_uformat");
//  super.new(name);
//  m_rvg_format = U;
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
//function void inst32_uformat::set_inst_value(inst_t inst);
//  m_inst = inst;
//endfunction: set_inst_value

//-----------------------------------------------------------------------------
// Function: new_from_op_imm
// Creates a U format instruction from the opcode and immediate value
// TODO: Used for unit testing. Need to revisit 
//-----------------------------------------------------------------------------
function inst32_uformat inst32_uformat::new_from_op_imm(decoder my_decoder,
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
endfunction: new_from_op_imm

//-----------------------------------------------------------------------------
// Function: u_inst_t
// Set the immediate value in the instruction
// TODO: Used for unit testing. Need to revisit 
//-----------------------------------------------------------------------------
function u_inst_t inst32_uformat::set_imm(u_inst_t in, imm_high_t imm);
  u_inst_t ret = in;
  ret.imm_31_12 = imm;
  return ret;    
endfunction: set_imm

//-----------------------------------------------------------------------------
// Function: sample_cov
// Facilitates the sampling of the covergroups 
//-----------------------------------------------------------------------------
function void inst32_uformat::sample_cov();
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
function real inst32_uformat::get_imm_cov();
  return imm_cg.i32u_imm_cp.get_coverage();
endfunction: get_imm_cov

//-----------------------------------------------------------------------------
// Function: get_imm
// Get the immediate value from the U format instruction
//
// Returns:
//  20bit high immediate value
//-----------------------------------------------------------------------------
function imm_high_t inst32_uformat::get_imm();
  return m_inst.u_inst.imm_31_12;      
endfunction: get_imm   

//-----------------------------------------------------------------------------
// Function: get_imm_string
// Get the string equivalent of the immediate value in the instruction
//
// Returns:
//  String representation of the immediate value
//-----------------------------------------------------------------------------
function string inst32_uformat::get_imm_string();
  int  sint = signed'(get_imm());        
  return $psprintf("%0d",sint);
endfunction: get_imm_string      

`endif
