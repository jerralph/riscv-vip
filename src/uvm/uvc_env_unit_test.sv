
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
import riscv_vip_uvc_pkg::*;
import svunit_uvm_mock_pkg::*;

class uvc_env_uvm_wrapper extends riscv_vip_uvc_pkg::uvc_env;

  `uvm_component_utils(uvc_env_uvm_wrapper)
  function new(string name = "uvc_env_uvm_wrapper", uvm_component parent);
    super.new(name, parent);
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
    /* Place Connection Code Here */
  endfunction
endclass

module uvc_env_unit_test;
  import svunit_pkg::svunit_testcase;

  string name = "uvc_env_ut";
  svunit_testcase svunit_ut; 


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  uvc_env_uvm_wrapper my_uvc_env;

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

    my_uvc_env = uvc_env_uvm_wrapper::type_id::create("my_uvm_env", null);

    uvm_config_db#(virtual riscv_vip_inst_if)::set(my_uvc_env, "m_i32_agent[0]", "m_vi",my_if);
    uvm_config_db#(virtual riscv_vip_regfile_if)::set(uvm_root::get(), "", "m_rf_vi",regfile_if);
    uvm_config_db#(int)::set(my_uvc_env, "m_i32_agent[0]", "m_core_id",199);     
    
    my_csrs.set_m_vif(csr_if);
    my_regfile.set_m_vif(regfile_if);    
    
    
    svunit_deactivate_uvm_component(my_uvc_env);
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    svunit_ut.setup();
    /* Place Setup Code Here */
    clk = 0;
    rstn = 0;
    #1
    rstn = 1;

    svunit_activate_uvm_component(my_uvc_env);

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
    svunit_uvm_test_finish();

    /* Place Teardown Code Here */

    svunit_deactivate_uvm_component(my_uvc_env);
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

  //Test that the agent and cov are  instantiated and working by checking for some
  //non-zero instruction coverage.  This utilize the fact that type-based coverage
  //is used rather than per-instance.  Once per instance is used this will need to
  //be updated
  `SVTEST(see_some_coverage)    


    inst32_iformat i32i = new(0);     
   
    const logic [31:0] pc_insts [][2] = '{
         {4,  	          i_inst_t'{imm:'hFF  ,rs1:1,   funct3:2,   rd:5, op:SYSTEM}}	// I CSRRS	
         };


   //Expect no coverage
   `FAIL_UNLESS(i32i.inst_same_regs_cg.inst_cp.get_coverage() == 0)

   
    // Toggle interface pins
   foreach(pc_insts[i,]) begin
     my_if.curr_pc = pc_insts[i][0];
     my_if.curr_inst = pc_insts[i][1];
     toggle_clock();
   end

   //Expect some coverage
   `FAIL_UNLESS(i32i.inst_same_regs_cg.inst_cp.get_coverage() > 0)
   
   
  `SVTEST_END

  `SVUNIT_TESTS_END


  task toggle_clock();
    repeat (2) #5 clk = ~clk;
  endtask



endmodule
