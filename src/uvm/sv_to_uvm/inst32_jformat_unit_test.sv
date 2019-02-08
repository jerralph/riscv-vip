
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
import uvm_pkg::*;
`include "riscv_vip_unit_test_pkg.sv"
import riscv_vip_pkg::*;
import riscv_vip_class_pkg::*;
import svunit_pkg::*;
import riscv_vip_unit_test_pkg::*;


module inst32_jformat_unit_test;
  import svunit_pkg::svunit_testcase;
   
  string name = "inst32_jformat_ut";
  svunit_testcase svunit_ut;

  //Interface and clock stuff
  logic clk;
  logic rstn; 
  riscv_vip_inst_if my_if(.*);
  riscv_vip_regfile_if regfile_if(.*);
  riscv_vip_csr_if csr_if(.*);

  //decoder for creating instructions
  decoder_wrapper my_decoder_wrapper;   
   
  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);
    my_decoder_wrapper = decoder_wrapper::type_id::create("", null);
    uvm_config_db#(virtual riscv_vip_inst_if)::set(uvm_root::get(), "", "m_vi",my_if);
    uvm_config_db#(virtual riscv_vip_regfile_if)::set(uvm_root::get(), "", "m_rf_vi",regfile_if);
    uvm_config_db#(virtual riscv_vip_csr_if)::set(uvm_root::get(), "", "m_csr_vi",csr_if);   
  endfunction

  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    svunit_ut.setup();
  endtask

  //===================================
  // Here we deconstruct anything we 
  // need after running the Unit Tests
  //===================================
  task teardown();
    svunit_ut.teardown();
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

  `SVTEST(inst32_jformat_cov)

   int bins_hit = 0;
   const int TOT_BINS = 6;
   const int IMM_BITS = 21;  
   const int MIN_NEG = -(2**IMM_BITS)/2;
   const int MAX_POS = (2**IMM_BITS)/2-2;  //LSB always 0 for J type

   test_j_imm(      10, 100.0*  bins_hit/TOT_BINS); //imm of        10, 0/7 bins hit
   test_j_imm(       0, 100.0*++bins_hit/TOT_BINS); //imm of         0, 1/7 bins hit  
   test_j_imm(      -2, 100.0*++bins_hit/TOT_BINS); //imm of  all ones, 2/7 bins hit  
   test_j_imm(      -2, 100.0*  bins_hit/TOT_BINS); //imm of  all ones, 2/7 bins hit  
   test_j_imm(       2, 100.0*++bins_hit/TOT_BINS); //imm of         2, 4/7 bins hit
   test_j_imm(       4, 100.0*++bins_hit/TOT_BINS); //imm of         4, 5/7 bins hit
   test_j_imm( MIN_NEG, 100.0*++bins_hit/TOT_BINS); //imm of   min neg, 6/7 bins hit  
   test_j_imm( MAX_POS, 100.0*++bins_hit/TOT_BINS); //imm of   max pos, 7/7 bins hit  

   //TODO test cross
    
  `SVTEST_END     


  `SVUNIT_TESTS_END

  task automatic test_j_imm(
                      j_imm_t imm,
                      real exp_cov
                      );
    inst32_jformat i32j; 
    j_imm_t gotten_imm; 
    real cov;
    bit pass = 0;
    
    i32j = inst32_jformat::new_from_imm(my_decoder_wrapper,imm);    

    gotten_imm = i32j.get_imm();
    `FAIL_UNLESS_LOG(gotten_imm == imm, $psprintf("gotten_imm = %d, exp imm=%d", gotten_imm, imm));   
    
    //Sample and check coverage
    i32j.sample_cov();          
    cov = i32j.get_imm_cov();
    `FAIL_UNLESS_LOG(int'(cov) == int'(exp_cov), $psprintf("J imm_cov() = %d, expect %d",cov,exp_cov))

  endtask


endmodule
