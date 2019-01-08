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

`ifndef _INST32_RFORMAT_INCLUDE_
`define _INST32_RFORMAT_INCLUDE_

//-----------------------------------------------------------------------------
// Class: inst32_sformat 
// Class for RV32 R format instructions
//-----------------------------------------------------------------------------
class inst32_rformat extends inst32;
  `uvm_object_utils(inst32_rformat)

  //-------------------------------------------------------
  // Externally defined tasks and functions
  //-------------------------------------------------------
  extern function new(string name = "inst32", inst_t inst=0);
  //extern function new(string name = "inst32_rformat");
  //extern virtual function void set_inst_value(inst_t inst);
  extern virtual function string get_imm_string();
  extern virtual function void sample_cov();
  extern virtual function funct7_t get_funct7();
  extern virtual function funct3_t get_funct3();
  extern static function inst32_rformat new_rformat( decoder my_decoder,
                                                      inst_enum_t inst_enum, 
                                                      regsel_t rd, 
                                                      regsel_t rs1, 
                                                      regsel_t rs2
                                                      );
  
endclass: inst32_rformat

//-----------------------------------------------------------------------------
// Constructor: new
//// Initializes the inst32_rformat class object
//
// Parameters:
//  name - instance name of the inst32
//  inst - 32bit instruction value
//-----------------------------------------------------------------------------
function inst32_rformat::new(string name = "inst32", inst_t inst=0);
  super.new(name);
  m_inst = inst;
  m_rvg_format = R;      
endfunction: new

////-----------------------------------------------------------------------------
//// Constructor: new
//// Initializes the inst32_rformat class object
////
//// Parameters:
////  name - instance name of the inst32_rformat
////-----------------------------------------------------------------------------
//function inst32_rformat::new(string name = "inst32_rformat");
//  super.new(name);
//  m_rvg_format = R;      
//endfunction: new
//
////-----------------------------------------------------------------------------
//// Function: set_inst_value
//// Sets the instruction value 
////
//// Parameters:
////  inst - 32bit instruction value
////-----------------------------------------------------------------------------
//function void inst32_rformat::set_inst_value(inst_t inst);
//  m_inst = inst;
//endfunction: set_inst_value
//
//-----------------------------------------------------------------------------
// Function: get_imm_string
// The R format of the instruction should not have immediate value
//
// Returns:
//  String DEADBEEF if this function is called 
//-----------------------------------------------------------------------------
function string inst32_rformat::get_imm_string();
  `uvm_fatal(get_type_name(),$sformatf("rformat get_imm_string(), r format has no imm. should not get called"));
  //make the compiler happy
  return "DEADBEEF";    
endfunction: get_imm_string

//-----------------------------------------------------------------------------
// Function: sample_cov
// This function samples the covergroup
//-----------------------------------------------------------------------------
function void inst32_rformat::sample_cov();
  super.sample_from_subclass();
endfunction: sample_cov 

//-----------------------------------------------------------------------------
// Function: get_funct7
// Get the funct7 embedded in the instruction of R format
//
// Returns:
//  The 7bit funct7 of the instruction
//-----------------------------------------------------------------------------
function funct7_t inst32_rformat::get_funct7();
  return m_inst.r_inst.funct7;
endfunction: get_funct7

//-----------------------------------------------------------------------------
// Function: get_funct3
// Get the funct3 embedded in the instruction of R format
//
// Returns:
//  The 3bit funct3 of the instruction
//-----------------------------------------------------------------------------
function funct3_t inst32_rformat::get_funct3();
  return m_inst.r_inst.funct3;
endfunction: get_funct3

//-----------------------------------------------------------------------------
// Function: new_rformat
// Create an R type instruction object given the enum, and regs
// TODO: Mostly used for unit testing. Need to revisit this. 
//
// Returns:
//  The rformat instructions verif object
//-----------------------------------------------------------------------------
function inst32_rformat inst32_rformat::new_rformat( decoder my_decoder,
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
  
endfunction: new_rformat

`endif
