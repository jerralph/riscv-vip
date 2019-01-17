//  ###########################################################################
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
//  ########################################################################### 

`ifndef _RISCV_VIP_BASE_TEST_INCLUDED_
`define _RISCV_VIP_BASE_TEST_INCLUDED_

//-----------------------------------------------------------------------------
// Class: riscv_vip_base_test
// Base test for the RISCV vip project
//-----------------------------------------------------------------------------
class riscv_vip_base_test extends uvm_test;
  `uvm_component_utils(riscv_vip_base_test)

  //------------------------------------------------------------------
  // component sub-items / fields
  //--------------------------------------------------------
  riscv_vip_uvc_pkg::uvc_env m_uvc_env;

  //---------------------------------------------
  // Externally defined tasks and functions
  //---------------------------------------------
  extern function new(string name, uvm_component parent=null);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void end_of_elaboration(); 
  extern virtual task run_phase(uvm_phase phase);

endclass: riscv_vip_base_test

//-----------------------------------------------------------------------------
// Constructor: new
// Initializes the riscv_vip_base_test class object
//
// Parameters:
//  name - instance name of the riscv_vip_base_test
//  parent - parent under which this component is created
//-----------------------------------------------------------------------------
function riscv_vip_base_test::new(string name, uvm_component parent=null);
  super.new(name, parent);
endfunction:new

//-----------------------------------------------------------------------------
// Function: build_phase
// Constructs the TB env component
//
// Parameters:
//  phase - stores the current phase 
//-----------------------------------------------------------------------------
function void riscv_vip_base_test::build_phase(uvm_phase phase);
  super.build_phase(phase);
  m_uvc_env = uvc_env::type_id::create("m_uvc_env",this); 
endfunction: build_phase

//-----------------------------------------------------------------------------
// Function: end_of_elaboration
// Prints the topology
//-----------------------------------------------------------------------------
function void riscv_vip_base_test::end_of_elaboration();

  uvm_report_info(get_type_name(),"end_of_elaboration", UVM_LOW); 
  print(); 
endfunction: end_of_elaboration 

//-----------------------------------------------------------------------------
// Task: run_phase
// Raises the objection, provides some time and drops the objection
//
// Parameters:
//  phase - stores the current phase 
//-----------------------------------------------------------------------------
task riscv_vip_base_test::run_phase(uvm_phase phase);
 phase.raise_objection(this);
 #5000000; 
 phase.drop_objection(this);
endtask: run_phase

`endif 
