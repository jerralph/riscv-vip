
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



`include "svunit_defines.svh"
`include "svunit_uvm_mock_pkg.sv"
import uvm_pkg::*;
`include "riscv_vip_uvc_pkg.sv"
import riscv_vip_pkg::*;
import riscv_vip_class_pkg::*;
import svunit_pkg::*;
import riscv_vip_uvc_pkg::*;
import svunit_uvm_mock_pkg::*;


class i32_agent_wrapper extends i32_agent;
  `uvm_component_utils(i32_agent_wrapper)  
  uvm_analysis_imp#(i32_item,i32_agent_wrapper) m_imp;

  int m_write_cnt = 0;
  i32_item m_item;
  
  function new(string name = "i32_agent_wrapper", uvm_component parent);
    super.new(name, parent);
    m_imp = new("m_imp",this);
  endfunction

  //===================================
  // Build
  //===================================
  function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     /* Place Build Code Here */

  endfunction

  //==================================
  // Connect
  //=================================
  function void connect_phase(uvm_phase phase);
     super.connect_phase(phase);

     m_mon_ap.connect(m_imp);

  endfunction // connect_phase

  // Mock write method that simply captures the pkt
  function void write(i32_item item);
    m_write_cnt++;
    m_item = item;
  endfunction

endclass


module i32_agent_unit_test;
  import svunit_pkg::svunit_testcase;

  string name = "i32_agent_ut";
  svunit_testcase svunit_ut;


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  i32_agent_wrapper my_i32_agent_wrapper;

  logic clk;
  logic rstn; 
  riscv_vip_inst_if my_if(.*);

  //CSR and regfile stuff
  riscv_vip_regfile_if regfile_if(.*);
  monitored_regfile my_regfile = new();
  riscv_vip_csr_if csr_if(.*);
  monitored_csrs my_csrs = new();


  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);
    my_i32_agent_wrapper = i32_agent_wrapper::type_id::create("", null);

    assert(my_i32_agent_wrapper.m_mon_ap) else $fatal("null m_mon_ap");
    
    uvm_config_db#(virtual riscv_vip_inst_if)::set(uvm_root::get(), "", "m_vi",my_if);
    uvm_config_db#(virtual riscv_vip_regfile_if)::set(uvm_root::get(), "", "m_rf_vi",regfile_if);

    uvm_config_db#(int)::set(uvm_root::get(), "", "m_core_id",99);     
        
    svunit_deactivate_uvm_component(my_i32_agent_wrapper);
  endfunction


  //===================================			
  // Setup for running the Unit Tests
  //===================================
  task setup();
    svunit_ut.setup();

    my_csrs.set_m_vif(csr_if);
    my_regfile.set_m_vif(regfile_if);    


    uvm_top.print_topology();
    /* Place Setup Code Here */
    clk = 0;
    rstn = 1;
    #1
    rstn = 0;
    svunit_activate_uvm_component(my_i32_agent_wrapper);

    //-----------------------------
    // start the testing phase
    //-----------------------------
    svunit_uvm_test_start();

  endtask


  //===================================
  // Here we deconstruct anything we 
  // need after running the Unit Tests
  //===================================
  task teardown();
    svunit_ut.teardown();
    //-----------------------------
    // terminate the testing phase 
    //-----------------------------
    //svunit_uvm_test_finish();

    /* Place Teardown Code Here */

    svunit_deactivate_uvm_component(my_i32_agent_wrapper);
  endtask


  //===================================
  // All tests are defined between the
  // SVUNIT_TESTS_BEGIN/END macros
  //
  // Each individual test must be
  // defined between `SVTEST(_NAME_)
  // `SVTEST_END
  //
  // i.e.
  //   `SVTEST(mytest)
  //     <test code>
  //   `SVTEST_END
  //===================================
  `SVUNIT_TESTS_BEGIN

  `SVTEST(some_insts)    
    i32_item i32, last_i32;
    int item_cnt;
   
    const logic [31:0] pc_insts [][2] = '{
	 {0,		  i_inst_t'{imm:99    ,rs1:2,   funct3:3,   rd:1, op:LOAD}},
         {4,  	          i_inst_t'{imm:'hFF  ,rs1:1,   funct3:2,   rd:5, op:SYSTEM}},		
         {8,         	  r_inst_t'{funct7:0, rs2:1, rs1:1, funct3:2, rd:2, op:OP}}
                                          };
    

       // Toggle interface pins and check that the ap gets the expected
       foreach(pc_insts[i,]) begin

         //toggle interface
         my_if.curr_pc = pc_insts[i][0];
         my_if.curr_inst = pc_insts[i][1];
         toggle_clock();

         //Check the ap
         i32 = my_i32_agent_wrapper.m_item;
         item_cnt = my_i32_agent_wrapper.m_write_cnt;         
         i32.print();       
         `FAIL_UNLESS(i32 != last_i32);    //ensure a fresh item is created by the monitor
         `FAIL_UNLESS(i32.m_addr == pc_insts[i][0]);
         `FAIL_UNLESS(i32.m_inst_bits == pc_insts[i][1]);
         `FAIL_UNLESS(i32.m_inst.m_inst == pc_insts[i][1]);
         `FAIL_UNLESS(item_cnt == i+1);
         last_i32 = i32;         
       end

       repeat(5) toggle_clock();  //burn some cycles
       `FAIL_UNLESS(item_cnt == 3);    
     
  `SVTEST_END
  `SVUNIT_TESTS_END


  task toggle_clock();
    repeat (2) #5 clk = ~clk;
  endtask


endmodule
