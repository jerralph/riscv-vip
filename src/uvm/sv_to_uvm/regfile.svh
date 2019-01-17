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

`ifndef _REGFILE_INCLUDED_
`define _REGFILE_INCLUDED_

//-----------------------------------------------------------------------------
// Class: regfile
// Contains the regfile array for storing 
// the 32 internal general purpose registers
//-----------------------------------------------------------------------------
class regfile extends uvm_object;    
  `uvm_object_utils(regfile)

  // Variable: x_regfile_array_t m_x_regfile_array
  // Array for storing the register values
  x_regfile_array_t m_x_regfile_array;
 
  //-------------------------------------------------------
  // Externally defined tasks and functions
  //-------------------------------------------------------
  extern function new(string name = "regfile");
  extern virtual function void set_m_x_regfile_array(x_regfile_array_t x);
  extern virtual function x_regfile_array_t get_m_x_regfile_array();
  extern virtual function xlen_t get_x(int unsigned i);

endclass: regfile 

//-----------------------------------------------------------------------------
// Constructor: new
// Initializes the regfile class object 
//
// Parameters:
//  name - instance name of the regfile 
//-----------------------------------------------------------------------------
function regfile::new(string name = "regfile");
  super.new(name);
endfunction: new

//-----------------------------------------------------------------------------
// Function: set_m_x_regfile_array
// Set the regfile array with the input regfile_array
//
// Parameters:
//  x - regfile_array 
//-----------------------------------------------------------------------------
function void regfile::set_m_x_regfile_array(x_regfile_array_t x);
  this.m_x_regfile_array = x;
endfunction: set_m_x_regfile_array 

//-----------------------------------------------------------------------------
// Function: get_m_x_regfile_array
// Get the regfile array
//
// Returns:
//  regfile_array
//-----------------------------------------------------------------------------
function x_regfile_array_t regfile::get_m_x_regfile_array();
  return m_x_regfile_array;
endfunction: get_m_x_regfile_array

//-----------------------------------------------------------------------------
// Function: get_x
// Get the value of a particular register
//
// Parameters: 
//  i - id value of the register
//
// Returns:
//  32bit value of the register
//-----------------------------------------------------------------------------
function xlen_t regfile::get_x(int unsigned i);
  //x[0] is always 0
  return ( i==0 ) ? 0 : m_x_regfile_array[i];  
endfunction: get_x 

`endif
