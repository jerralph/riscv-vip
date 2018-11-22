
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

  inst32 i32;
  regsel_t rd, rs1, rs2;
  int size;
  real obs_cov, exp_cov;



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
      rd = 1;
      rs1 = 1;
      rs2 = 1;

      //Pump in instructions to fill the fifo and then add one more
      for (int i=0; i<DEPTH+1; i++) begin
        rd  = i+1;
        rs1 = i+1;
        rs2 = i+1;
        i32 = inst32_rformat::new_rformat(my_decoder, ADD, rd , rs1, rs2);
        `FAIL_UNLESS(i32);  //fail on null
        i32.m_cycle = i;
        //`BREADCRUMB(i32.to_string());
        my_inst_history.commit_inst(i32);
      end

      //queue should be full and the inst from cycle 0 with rd,rs1,rs2=1,1,1 should be gone
      size =  my_inst_history.size();     
      `FAIL_UNLESS_LOG( size == DEPTH, $psprintf("size is %0d",size));
      i32 = my_inst_history.peek_oldest();
      rd = i32.get_rd();
      `FAIL_UNLESS_LOG( rd == 2, $psprintf("rd = %0d, not 2 as expected",rd));           
      i32 = my_inst_history.peek_newest();
      `FAIL_UNLESS(i32.get_rd() == ( DEPTH +1));           

    `SVTEST_END

    `SVTEST(test_cov)
      real cov_per_bin;
      int cycle;

      //Work to hit one bin in the cross coverage
      //ADD that uses r1 from a SUB 2 cycles ago 

      //Put DEPTH-1 subs into the FIFO, with the regs derived from the cycle
      for ( cycle=0; cycle<DEPTH-1; cycle++) begin
        rd  = cycle+1;
        rs1 = cycle+1;
        rs2 = cycle+1;
        i32 = inst32_rformat::new_rformat(my_decoder, SUB, rd , rs1, rs2);
        i32.m_cycle = cycle;
        commit_inst(i32);
        //`BREADCRUMB(i32.to_string());
      end

      //put an add into the FIFO that has a RAW hazard w/ a previous sub        
      rd  = cycle+1;
      rs1 = cycle+1-3; //RAW w/ the the SUB 3 cycles ago
      rs2 = cycle+1;
      i32 = inst32_rformat::new_rformat(my_decoder, ADD, rd , rs1, rs2);
      i32.m_cycle = cycle;
      commit_inst(i32);
      //`BREADCRUMB(i32.to_string());                      

      obs_cov = my_inst_history.m_raw_hazard_examiner.get_cross_cov();
      cov_per_bin = obs_cov; //this is the coverage of hitting one bin in the giant cross.
                             //on Questa, verify this via view->coverage->covergroups 

      //put an add into the FIFO which should not effect coverage since it's the same as 
      //already scored         
      cycle++;
      rd  = cycle+1;
      rs1 = cycle+1-3; //RAW w/ the the SUB 3 cycles ago
      rs2 = cycle+1;
      i32 = inst32_rformat::new_rformat(my_decoder, ADD, rd , rs1, rs2);
      i32.m_cycle = cycle;
      commit_inst(i32);
      
      obs_cov = my_inst_history.m_raw_hazard_examiner.get_cross_cov();
      `FAIL_UNLESS(int'(obs_cov) == int'(cov_per_bin));


      //rack up another atom of the cross cov
      cycle++;
      rd  = cycle+1;
      rs1 = cycle+1-2; //RAW w/ the ADD 2 cycles ago
      rs2 = cycle+1-2; //RAW w/ the ADD 2 cycles ago
      i32 = inst32_rformat::new_rformat(my_decoder, XOR, rd , rs1, rs2);
      i32.m_cycle = cycle;
      commit_inst(i32);
      
      obs_cov = my_inst_history.m_raw_hazard_examiner.get_cross_cov();
      exp_cov = 2.0 * cov_per_bin;
      `FAIL_UNLESS_LOG(obs_cov == exp_cov, $psprintf("obs,exp=%e,%e",obs_cov,exp_cov));

    `SVTEST_END



  `SVUNIT_TESTS_END

  function void commit_inst(inst32 inst);
    my_inst_history.commit_inst(inst);
    `BREADCRUMB(inst.to_string());
  endfunction

endmodule
