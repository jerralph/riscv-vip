
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
`include "riscv_vip_pkg.sv"

module regfile_unit_test;
  import svunit_pkg::svunit_testcase;
  import riscv_vip_pkg::*;
  import riscv_vip_class_pkg::*;
   

  string name = "regfile_ut";
  svunit_testcase svunit_ut;

  logic clk;
  logic rstn; 
  
  //UUT interface
  riscv_vip_regfile_if regfile_if(.*);

  //CSR interface
  //simulator for some reason doesn't like a null virtual interface in the csrs class
  //this solves this...
  riscv_vip_csr_if csr_if(.*);
  monitored_csrs my_csrs = new();


  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    svunit_ut.setup();
    my_csrs.set_m_vif(csr_if);
    //Toggle reset
    clk = 0;
    rstn = 1;
    #1
    rstn = 0;

  endtask


  //===================================
  // Here we deconstruct anything we 
  // need after running the Unit Tests
  //===================================
  task teardown();
    svunit_ut.teardown();
    /* Place Teardown Code Here */

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

    `SVTEST(test_interface)
      
      //Test that the wire interface to uut.get_x(i) works
      monitored_regfile uut = new();

      uut.set_m_vif(regfile_if);
  
  
      uut.run_monitor();
  
      //X out everything
      for(int i=1; i< 32; i++) begin
        regfile_if.x[i] = 'x;
      end

      //set reg 0 to all 1s... should fail at build time since this doesn't exist
      //Strangely with some simulators this seems a no-op...
      //regfile_if.x[0] = xlen_t'(-1);
      //toggle_clock();
      
      `FAIL_IF(uut.get_x(0) !== 0); 


      //set reg 1 to all 1s
      regfile_if.x[1] = xlen_t'(-1);
      toggle_clock();
      
      `FAIL_IF(uut.get_x(1) !== {XLEN{1'b1}})


      //set reg 31 and check it's what was set
      regfile_if.x[31] = xlen_t'('hCCCC_CCCC);
      toggle_clock();
      
      `FAIL_IF(uut.get_x(31) !== 'hCCCC_CCCC); 
      `FAIL_IF(uut.get_x(1) !== {XLEN{1'b1}}); 

      for(int i=1; i< 32; i++) begin
        regfile_if.x[i] = i;
        toggle_clock();
      end

      for(int i=1; i< 32; i++) begin
        `FAIL_IF_LOG(uut.get_x(i) !== i,$psprintf("x[%d]=%d",i,uut.get_x(i))) 
      end

    `SVTEST_END


  `SVUNIT_TESTS_END

  task toggle_clock();
    repeat (2) #5 clk = ~clk;
  endtask


endmodule
