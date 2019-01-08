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

`ifndef _REGFILE_MONITOR_INCLUDE_
`define _REGFILE_MONITOR_INCLUDE_

//-----------------------------------------------------------------------------
// Class: regfile_monitor
// This class monitors the whitebox regfile and updates the model class. 
//-----------------------------------------------------------------------------
class regfile_monitor extends uvm_monitor;
  `uvm_component_utils(regfile_monitor)

  // Variable: m_vif
  // Virtual interface handle of riscv_vip_regfile_if 
  typedef virtual riscv_vip_regfile_if.MON vif_t;
  vif_t m_vif;  
  
  // Variable: regfile m_regfile
  // regfile object handle
  protected regfile m_regfile;

  // Variable: event_pool
  // UVM event pool of all the events 
  uvm_event_pool event_pool;

  // Variable: ev_regfile_updated
  // UVM event for waiting on regfile updation
  uvm_event ev_regfile_updated;

  //-------------------------------------------------------
  // Externally defined tasks and functions
  //-------------------------------------------------------
  extern function new(string name, uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual protected task do_monitor();

endclass: regfile_monitor

//-----------------------------------------------------------------------------
// Constructor: new
// Initializes the regfile_monitor class object
//
// Parameters:
//  name - instance name of the regfile_monitor 
//  parent - parent under which this component is created
//-----------------------------------------------------------------------------
function regfile_monitor::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction: new

//-----------------------------------------------------------------------------
// Function: build_phase
// Gets the required objects from the config_db 
//
// Parameters:
//  phase - stores the current phase 
//-----------------------------------------------------------------------------
function void regfile_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);

  // Creating the uvm pool
  event_pool = new();
  // Get the uvm global pool 
  event_pool = event_pool.get_global_pool();
  // Get the required event from the pool
  ev_regfile_updated = event_pool.get("regfile_updated");

  if(! (uvm_config_db #(regfile)::get(this, "", "regfile", m_regfile)))
    `uvm_fatal(get_type_name(),$sformatf("Not able to get regfile handle"));
endfunction: build_phase

//-----------------------------------------------------------------------------
// Task: run_phase
// Samples the register values and stores into the regfile 
//
// Parameters:
//  phase - stores the current phase 
//-----------------------------------------------------------------------------
task regfile_monitor::run_phase(uvm_phase phase);
  super.run_phase(phase);

  // Wait for active-high reset
  @(posedge m_vif.rstn);

  forever begin
    do_monitor();
  end
endtask: run_phase

//-----------------------------------------------------------------------------
// Task: do_monitor
// Monitors for the change in the register values in the interface and
// samples the reg values and stores them into the regfile array
//-----------------------------------------------------------------------------
task regfile_monitor::do_monitor();

  @(m_vif.mon_cb);

  if(m_regfile.m_x_regfile_array !== m_vif.mon_cb.x) begin         
    //could just assign m_x_regfile_array to m_vif.x but may at some point
    //want to know exactly what changed..
    foreach(m_vif.mon_cb.x[i]) begin
      if(m_regfile.m_x_regfile_array[i] !== m_vif.mon_cb.x[i]) begin
        m_regfile.m_x_regfile_array[i] = m_vif.mon_cb.x[i];
        //do not break early, need to check change in all registers
      end
    end
  end

  // This is done to prevent others from using the values
  // from the regfile before it is stored
  ev_regfile_updated.trigger();
  
endtask: do_monitor

`endif
