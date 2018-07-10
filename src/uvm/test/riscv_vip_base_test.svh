
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

`ifndef _RISCV_VIP_BASE_TEST_INCLUDED_
`define _RISCV_VIP_BASE_TEST_INCLUDED_

class riscv_vip_base_test extends uvm_test;

  //------------------------------------------------------------------
  // component sub-items / fields
  //--------------------------------------------------------
  riscv_vip_uvc_pkg::uvc_env   m_uvc_env;

  //------------------------------------------------------------------
  // UVM macros
  //--------------------------------------------------------
  `uvm_component_utils_begin(riscv_vip_base_test)
     `uvm_field_object(m_uvc_env, UVM_ALL_ON)
  `uvm_component_utils_end


  //----------------------------------------------------------------------------
  // new
  //------------------------------------------------------------------
  function new(string name, uvm_component parent=null);
    super.new(name, parent);
  endfunction

  //----------------------------------------------------------------------------
  // build_phase
  //------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_uvc_env = uvc_env::type_id::create("m_uvc_env",this); 
  endfunction : build_phase

  
  function void end_of_elaboration(); 
    uvm_report_info(get_full_name(),"end_of_elaboration", UVM_LOW); 
    print(); 
  endfunction 

 
  task run_phase(uvm_phase phase);
   phase.raise_objection(this);
   #5000000; 
   phase.drop_objection(this);
  endtask : run_phase

endclass : riscv_vip_base_test

`endif // _RISCV_VIP_BASE_TEST_INCLUDED_
