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

`ifndef _CSRS_INCLUDED_
`define _CSRS_INCLUDED_

//-----------------------------------------------------------------------------
// This file has the following classes definition:
// 1) csrs
// 2) monitored_csrs
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// ClassL csrs
// This class is used for storing the CSRs
//-----------------------------------------------------------------------------
class csrs extends uvm_object;
  `uvm_object_utils(csrs)
  
  // Variable: csrs_t m_csrs
  // struct for storing the csrs
  protected csrs_t m_csrs;
  
  //-------------------------------------------------------
  // Externally defined tasks and functions
  //-------------------------------------------------------
  extern function new(string name = "csrs");
  extern virtual function csrs_t get_m_csrs();
  extern virtual function void set_m_csrs(csrs_t m_csrs);
  extern virtual function csr_t get_cycle();

endclass: csrs

//-----------------------------------------------------------------------------
// Constructor: new
// Initializes the csrs class object 
//
// Parameters:
//  name - instance name of the csrs 
//-----------------------------------------------------------------------------
function csrs::new(string name = "csrs");
  super.new(name);
endfunction: new

//-----------------------------------------------------------------------------
// Function: get_m_csrs
// Get the csrs
//
// Returns:
//  return the m_csrs
//-----------------------------------------------------------------------------
function csrs_t csrs::get_m_csrs();
  return m_csrs;
endfunction : get_m_csrs

// Set m_csrs
//-----------------------------------------------------------------------------
// Function: set_m_csrs
// Set the csrs
//
// Parameters:
//  m_csrs - input csrs
//-----------------------------------------------------------------------------
function void csrs::set_m_csrs(csrs_t m_csrs);
  this.m_csrs = m_csrs;
endfunction : set_m_csrs

//-----------------------------------------------------------------------------
// Function: get_cycle
// Get the cycle associated with the csr
//
// Returns: 
//  cycle count of the csr
//-----------------------------------------------------------------------------
function csr_t csrs::get_cycle();
  return m_csrs.cycle;
endfunction
 

//-----------------------------------------------------------------------------
// Class: monitored_csrs
// This class monitors the whitebox csrs and updates the model class. 
//-----------------------------------------------------------------------------
class monitored_csrs extends uvm_monitor;
  `uvm_component_utils(monitored_csrs)
  
  // Variable: m_vif
  // Virtual interface handle of riscv_vip_csr_if 
  // TODO: Need to use Corresponding Modport
  typedef virtual riscv_vip_csr_if vif_t; 
  vif_t m_vif; 

  //protected mailbox#(.T(csr_id_t)) assigned_ids;  //future, if needed
 
  // TODO: This need to be done via congif_db and connect_phase  
  //virtual function void set_m_vif(vif_t csr_vif);
  //  m_vif = csr_vif;
  //endfunction
 
  //task wait_for_csr_update(ref csr_id_t updated_ids[$])  //future, if needed... 

  //-------------------------------------------------------
  // Externally defined tasks and functions
  //-------------------------------------------------------
  extern function new(string name, uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual protected task do_monitor();
  
endclass: monitored_csrs

//-----------------------------------------------------------------------------
// Constructor: new
// Initializes the monitored_csrs class object
//
// Parameters:
//  name - instance name of the monitored_csrs 
//  parent - parent under which this component is created
//-----------------------------------------------------------------------------
function monitored_csrs::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction: new

//-----------------------------------------------------------------------------
// Function: build_phase
// Gets the required objects from the config_db 
//
// Parameters:
//  phase - stores the current phase 
//-----------------------------------------------------------------------------
function void monitored_csrs::build_phase(uvm_phase phase);
  super.build_phase(phase);
  // TODO: Need to get the csrs object from the config_db 
  // so that other component of interest can interact
  // if(! (uvm_config_db #(csrs)::get(this, "", "csrs", m_csrs)))
  //   `uvm_fatal(get_type_name(),$sformatf("Not able to get csrs handle"));
endfunction: build_phase

//-----------------------------------------------------------------------------
// Task: run_phase
// Samples the csrs values and stores into the csrs verif object  
//
// Parameters:
//  phase - stores the current phase 
//-----------------------------------------------------------------------------
task monitored_csrs::run_phase(uvm_phase phase);
  super.run_phase(phase);

  // TODO: Need future support
  //@(posedge m_vif.rstn);
  //do_monitor();
endtask: run_phase

//-----------------------------------------------------------------------------
// Task: do_monitor
// Monitors for the change in the csrs values in the interface and
// samples the csrs values and stores them into the csrs verif object
//-----------------------------------------------------------------------------
task monitored_csrs::do_monitor();

  // TODO: Need future support
  //forever begin
  //  @(posedge m_vif.clk iff ( m_vif.csrs !== m_csrs));        
  //  m_csrs = m_vif.csrs;      
  //end      
endtask: do_monitor

`endif
