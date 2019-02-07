
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
`include "riscv_vip_pkg.sv"
import uvm_pkg::*;
`include "riscv_vip_uvc_pkg.sv"
`include "riscv_vip_unit_test_pkg.sv"
import riscv_vip_pkg::*;
import riscv_vip_class_pkg::*;
import svunit_pkg::*;
import riscv_vip_uvc_pkg::*;
import svunit_uvm_mock_pkg::*;
import riscv_vip_unit_test_pkg::*;


module inst32_sformat_unit_test;
  import svunit_pkg::svunit_testcase;
   

  string name = "inst32_ut";
  svunit_testcase svunit_ut;


  //simulator for some reason doesn't like a null virtual interfaces is classes at inital runtime.
  //this solves this...
  //regfile interface
  logic clk;
  logic rstn; 

  riscv_vip_inst_if my_if(.*);
  riscv_vip_regfile_if regfile_if(.*);
  riscv_vip_csr_if csr_if(.*);

  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  inst32 my_inst32;
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


    /* Place Setup Code Here */
//    my_csrs.set_m_vif(csr_if);
//    my_regfile.set_m_vif(regfile_if);    

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

   `SVTEST(inst32_sformat_cov)     
     int bins_hit = 0;
     const int TOT_IMM_BINS = 7;
     const int IMM_BITS = 12;
     const int MIN_NEG = -(2**IMM_BITS)/2;
     const int MAX_POS = (2**IMM_BITS)/2-1;
     real cov = 0;
     real exp_cov;   
 
     foreach(S_INSTS[i]) begin
       bit first = (i == 0);        
       exp_cov = (!first) ? 100.0 : 100.0*  bins_hit/TOT_IMM_BINS;   
       test_s_imm(i,      10, exp_cov); //imm of        10, 0/7 bins hit
       exp_cov = (!first) ? 100.0 : 100.0*  ++bins_hit/TOT_IMM_BINS;   
       test_s_imm(i,        0, exp_cov); //imm of         0, 1/7 bins hit  
       exp_cov = (!first) ? 100.0 : 100.0*  ++bins_hit/TOT_IMM_BINS;   
       test_s_imm(i,       -1, exp_cov); //imm of  all ones, 2/7 bins hit  
       exp_cov = (!first) ? 100.0 : 100.0*  bins_hit/TOT_IMM_BINS;   
       test_s_imm(i,       -1, exp_cov); //imm of  all ones, 2/7 bins hit  
       exp_cov = (!first) ? 100.0 : 100.0*  ++bins_hit/TOT_IMM_BINS;   
       test_s_imm(i,        1, exp_cov); //imm of         1, 3/7 bins hit  
       exp_cov = (!first) ? 100.0 : 100.0*  ++bins_hit/TOT_IMM_BINS;   
       test_s_imm(i,        2, exp_cov); //imm of         2, 4/7 bins hit  
       exp_cov = (!first) ? 100.0 : 100.0*  ++bins_hit/TOT_IMM_BINS;   
       test_s_imm(i,        4, exp_cov); //imm of         4, 5/7 bins hit  
       exp_cov = (!first) ? 100.0 : 100.0*  ++bins_hit/TOT_IMM_BINS;   
       test_s_imm(i,  MIN_NEG, exp_cov); //imm of   min neg, 6/7 bins hit  
       exp_cov = (!first) ? 100.0 : 100.0*  ++bins_hit/TOT_IMM_BINS;   
       test_s_imm(i,  MAX_POS, exp_cov); //imm of   max pos, 7/7 bins hit  

       begin
         string fail_msg;         
         inst32_sformat i32s = inst32_sformat::new_from_funct3_imm(my_decoder_wrapper,i,0);          
         real exp_cov = 100.0*(i+1)/$size(S_INSTS);   
         cov = i32s.get_sinst_x_imm_cov();
         fail_msg = $psprintf("sinst_x_imm_cov = %g, expect %g" , cov, exp_cov);
         `FAIL_UNLESS_LOG(int'(cov) == int'(exp_cov), fail_msg);             
       end

     end
  
  `SVTEST_END

  `SVUNIT_TESTS_END

  task automatic test_s_imm(
                      funct3_t funct3,                       
                      imm_low_t imm,
                      real exp_cov
                      );
    inst32_sformat i32s; 
    imm_low_t gotten_imm; 
    real cov;
    
    i32s = inst32_sformat::new_from_funct3_imm(my_decoder_wrapper,funct3,imm);

    gotten_imm = i32s.get_imm();
    `FAIL_UNLESS_LOG(gotten_imm == imm, $psprintf("gotten_imm = %d, exp imm=%d", gotten_imm, imm));   

    //Sample and check coverage
    i32s.sample_cov();          
    cov = i32s.get_imm_cov();
    `FAIL_UNLESS_LOG(int'(cov) == int'(exp_cov), $psprintf("S imm_cov = %f, expect %f",cov,exp_cov))
    
  endtask

endmodule
