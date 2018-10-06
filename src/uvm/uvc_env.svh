
//###############################################################
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
//###############################################################


`ifndef _UVC_ENV_INCLUDED_
`define _UVC_ENV_INCLUDED_

`ifndef NUM_CORES
`define NUM_CORES 1
`endif

class uvc_env extends uvm_env;

  i32_agent          	m_i32_agent[`NUM_CORES];
  i32_cov_subscriber 	m_cov; 
  inst_history_subscriber m_hist;  //need to eventually be per core
   
  //------------------------------------------------------------------
  // environment UVM components
  //--------------------------------------------------------
  uvm_table_printer                     printer;

  //------------------------------------------------------------------
  // UVM macros
  //--------------------------------------------------------
  `uvm_component_utils_begin(uvc_env)
    `uvm_field_sarray_object(m_i32_agent, UVM_ALL_ON)
    `uvm_field_object(m_cov, UVM_ALL_ON)
    `uvm_field_object(m_hist, UVM_ALL_ON)
  `uvm_component_utils_end

  //----------------------------------------------------------------------------
  // new
  //------------------------------------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
    printer = new();
  endfunction

  //----------------------------------------------------------------------------
  // externally defined tasks and functions
  //------------------------------------------------------------------
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);

endclass : uvc_env

//==============================================================================
// externally defined tasks and functions
//====================================================================
function void uvc_env::build_phase(uvm_phase phase);

  super.build_phase(phase);
  //Create coverage instantiation
  m_cov = i32_cov_subscriber::type_id::create("cov",this);
  m_hist = inst_history_subscriber::type_id::create("m_hist",this);
  for (int i = 0; i < `NUM_CORES; i++) begin : gen_cores
    //RISCV_VIP
    begin
      string i32_name = $psprintf("m_i32_agent[%0d]",i);      
      if(uvm_config_db#(virtual riscv_vip_inst_if)::exists(this, i32_name, "m_vi")) begin
        m_i32_agent[i] = i32_agent::type_id::create(i32_name,this);
        `uvm_info("UVC_ENV", $sformatf("At Path: %s - Build Phase: Created i32 interface instance",get_full_name()), UVM_NONE)
      end else begin
        `uvm_error("build_phase", "Failed to find riscv_vip_if in factory")
      end
    end

  end : gen_cores

    
endfunction : build_phase

//====================================================================
function void uvc_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    for (int i = 0; i < `NUM_CORES; i++) begin : gen_cores
         m_i32_agent[i].m_monitor.m_ap.connect(m_cov.analysis_export);
         m_i32_agent[i].m_monitor.m_ap.connect(m_hist.analysis_export);
     end : gen_cores
endfunction : connect_phase


//====================================================================
task uvc_env::run_phase(uvm_phase phase);
    super.run_phase(phase);
endtask : run_phase


`endif // _UVC_ENV_INCLUDED_
