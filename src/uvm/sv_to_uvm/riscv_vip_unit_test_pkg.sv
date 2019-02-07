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

`ifndef _RISCV_VIP_UNIT_TEST_PKG_SV_
`define _RISCV_VIP_UNIT_TEST_PKG_SV_

//-----------------------------------------------------------------------------
// Package: riscv_vip_unit_test_pkg
//-----------------------------------------------------------------------------
package riscv_vip_unit_test_pkg;     

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import riscv_vip_class_pkg::*;
 


//-----------------------------------------------------------------------------
// Class: decoder_wrapper
// Use the decoder to create the inst32 classes to test. Ideally a unit test
// should be purely of the class getting tested, stand-alone; however there
// is quite a bit of coupling between the decoder and the instruction objects
// the decoder produces. 
//-----------------------------------------------------------------------------

class decoder_wrapper extends decoder;
  `uvm_component_utils(decoder_wrapper)  
  //uvm_analysis_imp#(inst32,i32_agent_wrapper) m_imp;
  reg_fetcher         m_reg_fetcher; 
  regfile             m_rf; 

  
  function new(string name = "i32_agent_wrapper", uvm_component parent);
    super.new(name, parent);
    //m_imp = new("m_imp",this);
  endfunction

  //===================================
  // Build
  //===================================
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_reg_fetcher = reg_fetcher::type_id::create("m_reg_fetcher",this);
    //m_decoder = decoder::type_id::create("m_decoder",this);
    m_rf = regfile::type_id::create("rf");
    uvm_config_db#(regfile)::set(this, "*", "regfile",m_rf);
  endfunction

  //==================================
  // Connect
  //=================================
  function void connect_phase(uvm_phase phase);
     super.connect_phase(phase);

     //m_mon_ap.connect(m_imp);

     //Don't worry about the reg-fetcher stuff for this test
     //m_monitor.put_port.connect(m_reg_fetcher.put_port);
     //m_monitor.trans_port_inst32.connect(m_decoder.trans_export_inst32);
  endfunction // connect_phase

endclass

   
endpackage: riscv_vip_unit_test_pkg 

`endif 
