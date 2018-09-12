
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


`ifndef _I32_AGENT_INCLUDED_
`define _I32_AGENT_INCLUDED_


class i32_agent extends uvm_agent;

  protected uvm_active_passive_enum m_is_active = UVM_PASSIVE;
  i32_monitor m_monitor;
  virtual riscv_vip_inst_if m_vi;
  virtual riscv_vip_regfile_if m_rf_vi;
  monitored_regfile m_rf;  //this is not a proper UVM monitor... whitebox... kind of hacked in for now
  int    m_core_id = -1;    

  uvm_analysis_port #(i32_item) m_mon_ap;

  `uvm_component_utils_begin(i32_agent)
  `uvm_component_utils_end

  function new(string name, uvm_component parent);
    super.new(name,parent);
    m_mon_ap = new("m_mon_ap", this); 
    m_rf = new();
  endfunction // new

  virtual function void build_phase(uvm_phase phase);
    bit has_vi;
    bit has_rf_vi;
    bit has_core_id;    
    super.build_phase(phase);
    has_vi = uvm_config_db#(virtual riscv_vip_inst_if)::get(this, "", "m_vi", m_vi);
    has_rf_vi = uvm_config_db#(virtual riscv_vip_regfile_if)::get(this, "", "m_rf_vi", m_rf_vi);
    has_core_id = uvm_config_db#(int)::get(this, "", "m_core_id", m_core_id);
    `uvm_info("i32_agent"," build_phase() called",UVM_LOW);
    m_monitor = i32_monitor::type_id::create("m_monitor",this);    
    assert(has_vi && has_rf_vi && has_core_id) else `uvm_fatal("has_vi && has_rf_vi && has_core_id","m_vi, m_rf_vi, or m_core_id not in config_db");    
    m_monitor.m_core_id = m_core_id;        
    m_monitor.m_vi = m_vi;
    m_rf.set_m_vif(m_rf_vi);
  endfunction // build_phase

  virtual function void connect_phase(uvm_phase phase);
    assert(m_mon_ap) else $fatal("missing m_mon_ap");    
    m_monitor.m_ap.connect(m_mon_ap);
    m_monitor.m_reg_fetcher.set_m_regfile(m_rf);
  endfunction // connect_phase

  virtual task run_phase(uvm_phase phase);
    `uvm_info("i32_agent"," run_phase() called",UVM_LOW);
    m_rf.run_monitor();
  endtask // run_phase



endclass  

  
`endif
