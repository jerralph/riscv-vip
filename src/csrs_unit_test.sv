
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

module csrs_unit_test;
  import svunit_pkg::svunit_testcase;
  import riscv_vip_pkg::*;
  import riscv_vip_class_pkg::*;
   

  string name = "csrs_ut";
  svunit_testcase svunit_ut;

  logic clk;
  logic rstn; 
  riscv_vip_csr_if csr_if(.*);


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  csrs my_csrs;  


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
    /* Place Setup Code Here */
    
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
      //Test that the interface to class works
      monitored_csrs uut = new();      

      uut.set_m_vif(csr_if);
      uut.run_monitor();
      csr_if.csrs = {$bits(csr_if.csrs){1'bX}};

      csr_if.csrs.cycle = 0;
      toggle_clock();

      csr_if.csrs.cycle++;      
      toggle_clock();
  
      `FAIL_IF(uut.get_cycle() !== 1 ); 

      csr_if.csrs.cycle++;      
      toggle_clock();
      `FAIL_IF(uut.get_cycle() !== 2 ); 

      csr_if.csrs.cycle++;      
      toggle_clock();
      `FAIL_IF(uut.get_cycle() !== 3 ); 

    `SVTEST_END


  `SVUNIT_TESTS_END

  task toggle_clock();
    repeat (2) #5 clk = ~clk;
  endtask


endmodule
