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

`ifndef _REG_FETCHER_INCLUDED_
`define _REG_FETCHER_INCLUDED_

//-----------------------------------------------------------------------------
// Class: reg_fetcher
// This fetches the general purpose reg values for a given instruction 
// from the regfile
//-----------------------------------------------------------------------------
class reg_fetcher extends uvm_component;
  `uvm_component_utils(reg_fetcher)

  // Variable: regfile m_regfile
  // regfile object handle
  protected regfile m_regfile; 

  // Variable: put_port
  // Blocking put implementation port
  uvm_blocking_put_imp#(inst32,reg_fetcher) put_port;   

  //-------------------------------------------------------
  // Externally defined tasks and functions
  //-------------------------------------------------------
  extern function new(string name, uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual protected function void fetch_regs(inst32 i32);
  extern virtual task put(inst32 t); 

endclass: reg_fetcher

//-----------------------------------------------------------------------------
// Constructor: new
// Initializes the reg_fetcher class object
//
// Parameters:
//  name - instance name of the reg_fetcher 
//  parent - parent under which this component is created
//-----------------------------------------------------------------------------
function reg_fetcher::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction: new

//-----------------------------------------------------------------------------
// Function: build_phase
// Gets the required objects from the config_db 
//
// Parameters:
//  phase - stores the current phase 
//-----------------------------------------------------------------------------
function void reg_fetcher::build_phase(uvm_phase phase);
  super.build_phase(phase);
  put_port = new("put_port",this);
   if(! (uvm_config_db #(regfile)::get(this, "", "regfile", m_regfile)))
     `uvm_fatal(get_type_name(),$sformatf("Not able to get regfile handle"));
endfunction: build_phase

//-----------------------------------------------------------------------------
// Function: fetch_regs
// Fetches the correesponding register value and 
// stores into the instruction
//
// Parameters: 
//  i32 - 32bit instruction verif object
//-----------------------------------------------------------------------------
function void reg_fetcher::fetch_regs(inst32 i32);

  if (i32.has_rs1()) begin
    i32.set_rs1_val(m_regfile.get_x(i32.get_rs1()));      
  end 
  if (i32.has_rs2()) begin
    i32.set_rs2_val(m_regfile.get_x(i32.get_rs2()));
  end
endfunction: fetch_regs

//-----------------------------------------------------------------------------
// Task: put
// Put port implementation
// Fetches the register values and updates the input instruction object 
//
// Parameters:
//  t - input inst32 instruction verif object
//-----------------------------------------------------------------------------
task reg_fetcher::put(inst32 t); 
  `uvm_info(get_type_name(), $sformatf("Inside the fetcher_put method"), UVM_HIGH) 
  // Updates the input instruction 't' with register values
  fetch_regs(t);
endtask: put 

`endif
