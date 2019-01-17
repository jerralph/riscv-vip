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

`ifndef _UVC_ENV_INCLUDED_
`define _UVC_ENV_INCLUDED_

// Defining the number of cores
`ifndef NUM_CORES
  `define NUM_CORES 1
`endif

//-----------------------------------------------------------------------------
// Class: uvc_env
// Environment of the Testbench
//-----------------------------------------------------------------------------
class uvc_env extends uvm_env;
  `uvm_component_utils(uvc_env)

  // Variable: regfile rg
  // Regfile data-structure
  regfile rg; 
  
  //---------------------------------------------
  // Environment UVM components
  //---------------------------------------------

  // Variable: i32_agent m_i32_agent
  // Agent array based on number of cores
  i32_agent m_i32_agent[`NUM_CORES];

  // Variable: i32_cov_subscriber m_cov
  // Coverage subscriber
  i32_cov_subscriber m_cov; 

  // Variable: inst_history_subscriber m_hist
  // Instruction history subscriber
  // need to eventually be per core
  inst_history_subscriber m_hist; 

  // Variable: reg_fetcher m_reg_fetcher
  // Regfile fetcher 
  reg_fetcher m_reg_fetcher; 

  // Variable: decoder m_decoder
  // Decoder component
  decoder m_decoder;  

  // Variable: printer
  // UVM table printer
  uvm_table_printer printer;

  //---------------------------------------------
  // Externally defined tasks and functions
  //---------------------------------------------
  extern function new (string name, uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual function void end_of_elaboration_phase(uvm_phase phase);

endclass: uvc_env

//-----------------------------------------------------------------------------
// Constructor: new
// Initializes the uvc_env class object
//
// Parameters:
//  name - instance name of the uvc_env 
//  parent - parent under which this component is created
//-----------------------------------------------------------------------------
function uvc_env::new (string name, uvm_component parent);
  super.new(name, parent);
  printer = new();
endfunction: new

//-----------------------------------------------------------------------------
// Function: build_phase
// Constructs all the required components and 
// set the required data into the config_db
//
// Parameters:
//  phase - stores the current phase 
//-----------------------------------------------------------------------------
function void uvc_env::build_phase(uvm_phase phase);
  super.build_phase(phase);

  // Create coverage instantiation
  m_cov = i32_cov_subscriber::type_id::create("cov",this);
  m_hist = inst_history_subscriber::type_id::create("m_hist",this);

  // Create the components
  m_reg_fetcher = reg_fetcher::type_id::create("m_reg_fetcher",this);
  m_decoder = decoder::type_id::create("m_decoder",this);

  // regfile data-structure creation
  rg = regfile::type_id::create("rg");
  uvm_config_db#(regfile)::set(this, "*", "regfile",rg);

  // Construction of agents based on cores  
  for (int i = 0; i < `NUM_CORES; i++) begin : gen_cores
    //RISCV_VIP
    begin
      string i32_name = $psprintf("m_i32_agent[%0d]",i);      
      if(uvm_config_db#(virtual riscv_vip_inst_if)::exists(this, i32_name, "m_vi")) begin
        m_i32_agent[i] = i32_agent::type_id::create(i32_name,this);
        `uvm_info(get_type_name(), $sformatf("At Path: %s - Build Phase: Created i32 interface instance",
                                                                        get_full_name()), UVM_NONE)
      end 
      else begin
        `uvm_error(get_type_name(), "Failed to find riscv_vip_if in factory")
      end
    end
  end: gen_cores
    
endfunction: build_phase

//-----------------------------------------------------------------------------
// Function: connect_phase
// Performs the required connections between the components
//
// Parameters:
//  phase - stores the current phase 
//-----------------------------------------------------------------------------
function void uvc_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    for (int i = 0; i < `NUM_CORES; i++) begin : gen_cores
         m_i32_agent[i].m_monitor.m_ap.connect(m_cov.analysis_export);
         m_i32_agent[i].m_monitor.m_ap.connect(m_hist.analysis_export);
         m_i32_agent[i].m_monitor.put_port.connect(m_reg_fetcher.put_port);
         m_i32_agent[i].m_monitor.trans_port_inst32.connect(m_decoder.trans_export_inst32);
     end: gen_cores
endfunction: connect_phase

//-----------------------------------------------------------------------------
// Function: end_of_elaboration_phase
// Printing the topology of the UVM TB
//
// Parameters:
//  phase - stores the current phase
//-----------------------------------------------------------------------------
function void uvc_env::end_of_elaboration_phase(uvm_phase phase);
  `uvm_info(get_type_name(),"end_of_elaboration", UVM_LOW);
    
  // To print the entire TB hierarchical structure
  uvm_top.print_topology();

  // Gives the info about what components/objects 
  // are registered with the factory. Also, provide 
  // info on what were overridden
  //factory.print(); 
endfunction: end_of_elaboration_phase 

`endif
