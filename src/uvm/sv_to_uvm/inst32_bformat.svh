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

`ifndef _INST32_BFORMAT_INCLUDE_
`define _INST32_BFORMAT_INCLUDE_

//-----------------------------------------------------------------------------
// Class: inst32_bformat
// Class for RV32 B format branch instructions {BEQ, BNE, BLT, BGE, BLTU, BGEU}
//-----------------------------------------------------------------------------
class inst32_bformat extends inst32;
  `uvm_object_utils(inst32_bformat)

  //-------------------------------------------------------
  // Externally defined tasks and functions
  //-------------------------------------------------------
  extern function new(string name = "inst32", inst_t inst=0);
  //extern function new(string name = "inst32_bformat");
  //extern virtual function void set_inst_value(inst_t inst);
  extern static function inst32_bformat new_from_funct3_imm(decoder my_decoder, 
                                                            funct3_t funct3, 
                                                            b_imm_t imm
                                                            );
  extern protected static function b_inst_t set_imm(b_inst_t in, b_imm_t imm);
  extern virtual function b_imm_t get_imm();
  extern virtual function string get_imm_string();
  extern virtual function void sample_cov();
  extern virtual function real get_imm_cov();

  //-------------------------------------------------------
  // Covergroup: imm_cg
  // Creates the coverpoints and cross coverpoints
  //-------------------------------------------------------
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
  endgroup: imm_cg
  //TODO: cover the different fields in isolation (since there is a weird combining)

endclass: inst32_bformat

//-----------------------------------------------------------------------------
// Constructor: new
// Initializes the inst32_bformat class object and creates the covergroup
//
// Parameters:
//  name - instance name of the inst32
//  inst - 32bit instruction value
//-----------------------------------------------------------------------------
function inst32_bformat::new(string name = "inst32", inst_t inst=0);
  super.new(name);
  m_inst = inst;
  m_rvg_format = B;
  imm_cg = new(get_imm(),get_inst_enum());        
endfunction: new

////-----------------------------------------------------------------------------
//// Constructor: new
//// Initializes the inst32_bformat class object and creates the covergroup
////
//// Parameters:
////  name - instance name of the inst32_bformat
////-----------------------------------------------------------------------------
//function inst32_bformat::new(string name = "inst32_bformat");
//  super.new(name);
//  m_rvg_format = B;
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
//function void inst32_bformat::set_inst_value(inst_t inst);
//  m_inst = inst;
//endfunction: set_inst_value

//-----------------------------------------------------------------------------
// Function: new_from_funct3_imm
// Creates the B format instruction from funct3 immediate 
// TODO: Used for unit testing. Need to revisit 
//-----------------------------------------------------------------------------
function inst32_bformat inst32_bformat::new_from_funct3_imm(decoder my_decoder, 
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
endfunction: new_from_funct3_imm

//-----------------------------------------------------------------------------
// Function: set_imm
// Set the immediate value in the instruction 
// TODO: Used for unit testing. Need to revisit 
//-----------------------------------------------------------------------------
function b_inst_t inst32_bformat::set_imm(b_inst_t in, b_imm_t imm);
  b_inst_t ret = in;
  {ret.imm_12,ret.imm_11,ret.imm_10_5, ret.imm_4_1} = (imm>>>1); //sign extend
  return ret;    
endfunction: set_imm

//-----------------------------------------------------------------------------
// Function: get_imm
// Get the immediate value associated with the instruction 
// The B format imm has 12:1 in inst.. this method adds back the 0 lsb
//
// Returns:
//  Immediate value of 13bits
//-----------------------------------------------------------------------------
function b_imm_t inst32_bformat::get_imm();
  b_inst_t b = m_inst.b_inst;      
  return {b.imm_12, b.imm_11, b.imm_10_5, b.imm_4_1,1'b0};      
endfunction: get_imm

//-----------------------------------------------------------------------------
// Function: get_imm_string
// Get the string equivalent of the immediate value
//
// Returns:
//  String representation of the immediate value
//-----------------------------------------------------------------------------
function string inst32_bformat::get_imm_string();
  int  sint = signed'(get_imm());    
  return $psprintf("%0d",sint);
endfunction: get_imm_string      

//-----------------------------------------------------------------------------
// Function: sample_cov
// Facilitates the sampling of the covergroups 
//-----------------------------------------------------------------------------
function void inst32_bformat::sample_cov();
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
function real inst32_bformat::get_imm_cov();
 return imm_cg.i32b_imm_cp.get_coverage();    
endfunction: get_imm_cov
  
`endif
