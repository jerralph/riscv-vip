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

`ifndef _INST32_JFORMAT_INCLUDE_
`define _INST32_JFORMAT_INCLUDE_

//-----------------------------------------------------------------------------
// Class: inst32_jformat
// Class for RV32 J format instructions 
//-----------------------------------------------------------------------------
class inst32_jformat extends inst32;
  `uvm_object_utils(inst32_jformat)

  //-------------------------------------------------------
  // Externally defined tasks and functions
  //-------------------------------------------------------
  extern function new(string name = "inst32", inst_t inst=0);
  //extern function new(string name = "inst32_jformat");
  //extern virtual function void set_inst_value(inst_t inst);
  extern static function inst32_jformat new_from_imm(decoder my_decoder,
                                                     j_imm_t imm);
  extern protected static function j_inst_t set_imm(j_inst_t in, j_imm_t imm);
  extern virtual function void sample_cov();
  extern virtual function real get_imm_cov();
  extern virtual function j_imm_t get_imm();
  extern virtual function string get_imm_string();

  //-------------------------------------------------------
  // Covergroup: imm_cg 
  // Creates the coverpoints and cross coverpoints
  //-------------------------------------------------------
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
  endgroup // imm_cg

endclass: inst32_jformat

//-----------------------------------------------------------------------------
// Constructor: new
// Initializes the inst32_jformat class object and creates the covergroup
//
// Parameters:
//  name - instance name of the inst32
//  inst - 32bit instruction value
//-----------------------------------------------------------------------------
function inst32_jformat::new(string name = "inst32", inst_t inst=0);
  super.new(name);
  m_inst = inst;
  m_rvg_format = J;   
  imm_cg = new(get_imm(),get_inst_enum());       
endfunction: new

////-----------------------------------------------------------------------------
//// Constructor: new
//// Initializes the inst32_jformat class object and creates the covergroup
////
//// Parameters:
////  name - instance name of the inst32_jformat
////-----------------------------------------------------------------------------
//function inst32_jformat::new(string name = "inst32_jformat");
//  super.new(name);
//  m_rvg_format = J;   
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
//function void inst32_jformat::set_inst_value(inst_t inst);
//  m_inst = inst;
//endfunction: set_inst_value

//-----------------------------------------------------------------------------
// Function: new_from_imm
// Creates the J format instruction from immediate value 
// TODO: Used for unit testing. Need to revisit 
//-----------------------------------------------------------------------------
function inst32_jformat inst32_jformat::new_from_imm(decoder my_decoder,
                                                      j_imm_t imm);
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
endfunction: new_from_imm
  
//-----------------------------------------------------------------------------
// Function: set_imm
// Set the immediate value in the instruction 
// TODO: Used for unit testing. Need to revisit 
//-----------------------------------------------------------------------------
function j_inst_t inst32_jformat::set_imm(j_inst_t in, j_imm_t imm);
  j_inst_t ret = in;
  {ret.imm_20,ret.imm_19_12,ret.imm_11,ret.imm_10_1} = (imm>>>1); //sign extend
  return ret;    
endfunction: set_imm

//-----------------------------------------------------------------------------
// Function: sample_cov
// Facilitates the sampling of the covergroups 
//-----------------------------------------------------------------------------
function void inst32_jformat::sample_cov();
  super.sample_from_subclass();
  imm_cg.sample();
endfunction: sample_cov

//-----------------------------------------------------------------------------
// Function: get_imm_cov
// Get the coverage value of immediate covergroup
//
// Returns:
//  Real precision coverage value 
//-----------------------------------------------------------------------------
function real inst32_jformat::get_imm_cov();
  return imm_cg.i32j_imm_cp.get_coverage();
endfunction: get_imm_cov

//-----------------------------------------------------------------------------
// Function: get_imm
// Get the immediate value associated with the instruction 
// The J format imm has 20:1 in inst.. this method adds back the 0 lsb
//
// Returns:
//  20bit immediate value of the J format Instruction
//-----------------------------------------------------------------------------
function j_imm_t inst32_jformat::get_imm();
  j_inst_t j = m_inst.j_inst;            
  return {j.imm_20,j.imm_19_12,j.imm_11,j.imm_10_1,1'b0};      
endfunction: get_imm   

//-----------------------------------------------------------------------------
// Function: get_imm_string
// Get the string equivalent of the immediate value in the instruction
//
// Returns
//  String representation of the immediate value
//-----------------------------------------------------------------------------
function string inst32_jformat::get_imm_string();
  int sint = signed'(get_imm());
  return $psprintf("%0d",sint);
endfunction: get_imm_string      

`endif
