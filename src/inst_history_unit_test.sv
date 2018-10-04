
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

module inst_history_unit_test;
  import svunit_pkg::svunit_testcase;
  import riscv_vip_pkg::*;
  import riscv_vip_class_pkg::*;
   

  string name = "inst_history_ut";
  svunit_testcase svunit_ut;

  logic clk;
  logic rstn; 

  decoder my_decoder;   
  
  //simulator doesn't like a null virtual interfaces
  //this solves this...
  riscv_vip_regfile_if regfile_if(.*);
  monitored_regfile my_regfile = new();
  riscv_vip_csr_if csr_if(.*);
  monitored_csrs my_csrs = new();

  //UUT
  parameter int DEPTH = 5;
  inst_history#(.DEPTH(DEPTH)) my_inst_history;

  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);    
    my_decoder = new();
    my_inst_history = new();  //The UUT    
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    svunit_ut.setup();   
    my_csrs.set_m_vif(csr_if);
    my_regfile.set_m_vif(regfile_if);    

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

    `SVTEST(test_queue)
      inst32 i32;
      inst32_rformat i32r;
      regsel_t rd, rs1, rs2;
      int size;
      rd = 1;
      rs1 = 1;
      rs2 = 1;

      //Pump in instruction to fill the fifo and one more
      for (int i=0; i<DEPTH+1; i++) begin
        rd  = i+1;
        rs1 = i+1;
        rs2 = i+1;
        i32 = inst32_rformat::new_rformat(my_decoder, ADD, rd , rs1, rs2);
        `FAIL_UNLESS(i32);  //fail on null
        i32.cycle = i;
        //`BREADCRUMB(i32.to_string());
        my_inst_history.commit_inst(i32);
      end

      //queue should be full and the inst with rd,rs1,rs2=1,1,1 should be gone
      size =  my_inst_history.size();     
      `FAIL_UNLESS_LOG( size == DEPTH, $psprintf("size is %0d",size));
      i32 = my_inst_history.peek_oldest();
      rd = i32.get_rd();
      `FAIL_UNLESS_LOG( rd == 2, $psprintf("rd = %0d, not 2 as expected",rd));           
      i32 = my_inst_history.peek_newest();
      `FAIL_UNLESS(i32.get_rd() == ( DEPTH +1));           

    `SVTEST_END


  `SVUNIT_TESTS_END

endmodule
