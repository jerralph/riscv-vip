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

`ifndef _I32_AGENT_INCLUDED_
`define _I32_AGENT_INCLUDED_

//-----------------------------------------------------------------------------
// Class: i32_agent
// Instruction_32 agent
//-----------------------------------------------------------------------------
class i32_agent extends uvm_agent;
  `uvm_component_utils(i32_agent)

  // Variable: uvm_active_passive_enum m_is_active
  // Defines whether the agent is passive or active component
  protected uvm_active_passive_enum m_is_active = UVM_PASSIVE;
  
  // Variable: i32_monitor m_monitor
  // Instruction_32 Monitor
  i32_monitor m_monitor;

  // Variable: riscv_vip_inst_if m_vi
  // Virtual handle for instruction interface
  virtual riscv_vip_inst_if m_vi;

  // Variable: riscv_vip_regfile_if m_rf_vi
  // Virtual handle for regfile interface
  virtual riscv_vip_regfile_if m_rf_vi;

  // Variable: riscv_vip_csr_if m_csr_vi
  // Virtual handle for csr interface
  virtual riscv_vip_csr_if m_csr_vi;

  // Variable: regfile_monitor m_rf
  // Register_file monitor component
  regfile_monitor m_rf;  //this is not a proper UVM monitor... whitebox... kind of hacked in for now

  // Variable: monitored_csrs m_csr
  // CSR monitor component
  monitored_csrs m_csr; //future... not really used (yet)

  // Variable: m_core_id
  // Id of the core
  int m_core_id = -1;    

  // Variable: m_mon_ap
  // UVM analysis port
  uvm_analysis_port #(inst32) m_mon_ap;

  //---------------------------------------------
  // Externally defined tasks and functions
  //---------------------------------------------
  extern function new(string name, uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);

endclass: i32_agent

//-----------------------------------------------------------------------------
// Constructor: new
// Initializes the i32_agent class object
//
// Parameters:
//  name - instance name of the i32_agent 
//  parent - parent under which this component is created
//-----------------------------------------------------------------------------
function i32_agent::new(string name, uvm_component parent);
  super.new(name,parent);
  // Creating the analysis port
  m_mon_ap = new("m_mon_ap", this); 
endfunction: new

//-----------------------------------------------------------------------------
// Function: build_phase
// Creates regfile_monitor and gets the required items from
// the configuration database
//
// Parameters:
//  phase - stores the current phase 
//-----------------------------------------------------------------------------
function void i32_agent::build_phase(uvm_phase phase);
  super.build_phase(phase);

  `uvm_info(get_type_name(),"i32_agent build_phase() called",UVM_LOW);

  // Getting from the config_db
  if(! (uvm_config_db#(virtual riscv_vip_inst_if)::get(this, "", "m_vi", m_vi)) )
    `uvm_fatal(get_type_name(),"Not able to get m_vi from config_db")

  if(! (uvm_config_db#(virtual riscv_vip_regfile_if)::get(this, "", "m_rf_vi", m_rf_vi)) )
    `uvm_fatal(get_type_name(),"Not able to get m_rf_vi from config_db")

  if(! (uvm_config_db#(virtual riscv_vip_csr_if)::get(this, "", "m_csr_vi", m_csr_vi)) )
    `uvm_fatal(get_type_name(),"Not able to get m_csr_vi from config_db")

  if(! (uvm_config_db#(int)::get(this, "", "m_core_id", m_core_id)) )
    `uvm_fatal(get_type_name(),"Not able to get m_core_id from config_db")

  // Creating the components
  m_monitor = i32_monitor::type_id::create("m_monitor",this);    
  m_rf = regfile_monitor::type_id::create("m_rf",this); 
  m_csr = monitored_csrs::type_id::create("m_csr",this);

  m_monitor.m_core_id = m_core_id;        
endfunction: build_phase

//-----------------------------------------------------------------------------
// Function: connect_phase
// Connects the required ports and interfaces
//
// Parameters:
//  phase - stores the current phase 
//-----------------------------------------------------------------------------
function void i32_agent::connect_phase(uvm_phase phase);

  m_monitor.m_vi = m_vi; 
  m_rf.m_vif = m_rf_vi; 
  m_csr.m_vif = m_csr_vi;

  // Stop the simulation if the m_mon_ap ia not created
  assert(m_mon_ap) 
  else `uvm_fatal(get_type_name(),"missing m_mon_ap");    

  m_monitor.m_ap.connect(m_mon_ap);
endfunction: connect_phase

//-----------------------------------------------------------------------------
// Task: run_phase
// Task which consumes time 
//
// Parameters:
//  phase - stores the current phase 
//-----------------------------------------------------------------------------
task i32_agent::run_phase(uvm_phase phase);
  `uvm_info(get_type_name(),"i32_agent run_phase() called",UVM_LOW);
endtask: run_phase

`endif
