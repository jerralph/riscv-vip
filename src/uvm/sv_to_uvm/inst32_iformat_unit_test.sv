
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


module inst32_iformat_unit_test;
  import svunit_pkg::svunit_testcase;

  string name = "inst32_iformat_ut";
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

    `SVTEST(ug_example1)
       opcode_t op = OP_IMM;   
       funct3_t funct3 = 0;   
       inst32 addi = inst32_iformat::new_nonspecial_from_funct3_op_imm(my_decoder_wrapper,funct3,op,-1);
       addi.m_inst.i_inst.rs1 = 1;
       addi.m_inst.i_inst.rd  = 3;       
       //$display("My addi from code is [ %s ]", addi.to_string());      
    `SVTEST_END

    `SVTEST(ug_example2)

       //TODO move this into an examples unit test so it doesn't mess with the overall per type coverage
       //for now sample() commented... also eventually coverage will be changed to all per instance...
       real cov;    
       bit[31:0] inst_bits = 32'hfff08193;    
       inst32 i32 = my_decoder_wrapper.decode_inst32(inst_bits);
       //$display("decode of 0x%0H is [ %s ]", inst_bits, i32.to_string());

       begin     
        //Cast the general inst32 into the more specific inst32_iformat once we're sure it
        //really is an I format.  The coverage should be 0 before sampling then
        //have one bin hit after sampling
        inst32_iformat i32i;         
        assert(i32.is_i_format());
        $cast(i32i,i32);
        cov = i32i.get_nonspecial_imm_cov(); 
        assert(cov == 0);         
        //i32i.sample_cov();
        cov = i32i.get_nonspecial_imm_cov();
        //$display("after sample_cov of 0x%0H get_nonspecial_imm_cov() yields %0f", inst_bits, cov);
      end    
               
    `SVTEST_END
   
  `SVTEST(inst32_iformat_cov)    
    begin 
      int bins_hit = 0;
      const int NS_TOT_IMM_BINS = 7;  //nonspecial
      const int NS_IMM_BITS = 12;
      const int NS_MIN_NEG = -(2**NS_IMM_BITS)/2;
      const int NS_MAX_POS = (2**NS_IMM_BITS)/2-1;
      real cov = 0;
      real exp_cov;   
      
      foreach(I_NONSPECIAL_INSTS[i]) begin
        bit first = (i == 0);
        funct3_t f3;
        opcode_t op;
        {f3,op} = funct3op_from_isb_inst(I_NONSPECIAL_INSTS[i]); 
      
        exp_cov = (!first) ? 100.0 : 100.0*  bins_hit/NS_TOT_IMM_BINS;   
        test_i_ns_imm(f3,op,      10, exp_cov); //imm of        10, 0/7 bins hit
        exp_cov = (!first) ? 100.0 : 100.0*  ++bins_hit/NS_TOT_IMM_BINS;   
        test_i_ns_imm(f3,op,        0, exp_cov); //imm of         0, 1/7 bins hit  
        exp_cov = (!first) ? 100.0 : 100.0*  ++bins_hit/NS_TOT_IMM_BINS;   
        test_i_ns_imm(f3,op,       -1, exp_cov); //imm of  all ones, 2/7 bins hit  
        exp_cov = (!first) ? 100.0 : 100.0*  bins_hit/NS_TOT_IMM_BINS;   
        test_i_ns_imm(f3,op,       -1, exp_cov); //imm of  all ones, 2/7 bins hit  
        exp_cov = (!first) ? 100.0 : 100.0*  ++bins_hit/NS_TOT_IMM_BINS;   
        test_i_ns_imm(f3,op,        1, exp_cov); //imm of         1, 3/7 bins hit  
        exp_cov = (!first) ? 100.0 : 100.0*  ++bins_hit/NS_TOT_IMM_BINS;   
        test_i_ns_imm(f3,op,        2, exp_cov); //imm of         2, 4/7 bins hit  
        exp_cov = (!first) ? 100.0 : 100.0*  ++bins_hit/NS_TOT_IMM_BINS;   
        test_i_ns_imm(f3,op,        4, exp_cov); //imm of         4, 5/7 bins hit  
        exp_cov = (!first) ? 100.0 : 100.0*  ++bins_hit/NS_TOT_IMM_BINS;   
        test_i_ns_imm(f3,op,  NS_MIN_NEG, exp_cov); //imm of   min neg, 6/7 bins hit  
        exp_cov = (!first) ? 100.0 : 100.0*  ++bins_hit/NS_TOT_IMM_BINS;   
        test_i_ns_imm(f3,op,  NS_MAX_POS, exp_cov); //imm of   max pos, 7/7 bins hit  
      
        begin   
          inst32_iformat i32i = inst32_iformat::new_nonspecial_from_funct3_op_imm(
            my_decoder_wrapper,
            f3,
            op, 
            0
          );
          real exp_cov = 100.0*(i+1)/$size(I_NONSPECIAL_INSTS);   
          cov = i32i.get_nonspecial_inst_x_imm_cov();
          begin
            string fail_msg = $psprintf("I nonspecial_inst_x_imm_cov = %d, expect %d" , cov, exp_cov);
            `FAIL_UNLESS_LOG(int'(cov) == int'(exp_cov), fail_msg);
          end
        end
        
      end // foreach (I_NONSPECIAL_INSTS[i])
    end

    begin
       int bins_hit = 0;     
      const int SHAMT_TOT_BINS = 6;
      real cov = 0;
      real exp_cov;   
      
      //for looking up fields for the SHAMT_INSTS...
      const bit [31-25+1+FUNCT3_W-1:0] shamt_imm_code_funct3_by_inst[inst_enum_t] = '{
         SLLI : {7'b0000000,3'b001},
         SRLI : {7'b0000000,3'b101},
         SRAI : {7'b0100000,3'b101}       
      };
      
      foreach(I_SHAMT_INSTS[i]) begin
        bit first;
        funct3_t f3;
        bit [31-25:0] imm_code;  // the higher bits of typical imm, higher than the shamt field

        first = (i == 0);
                
        {imm_code,f3} = shamt_imm_code_funct3_by_inst[I_SHAMT_INSTS[i]];

        test_i_shamt_imm(imm_code,f3,     9, exp_cov); //0/6 bins hit
        exp_cov = (!first) ? 100.0 : 100.0*  ++bins_hit/SHAMT_TOT_BINS;   
        test_i_shamt_imm(imm_code,f3,      0, exp_cov); //1/6 bins hit
        exp_cov = (!first) ? 100.0 : 100.0*  ++bins_hit/SHAMT_TOT_BINS;        
        test_i_shamt_imm(imm_code,f3,      1, exp_cov); //2/6 bins hit
        exp_cov = (!first) ? 100.0 : 100.0*  ++bins_hit/SHAMT_TOT_BINS;   
        test_i_shamt_imm(imm_code,f3,      2, exp_cov); //3/6 bins hit
        exp_cov = (!first) ? 100.0 : 100.0*  ++bins_hit/SHAMT_TOT_BINS;   
        test_i_shamt_imm(imm_code,f3,      4, exp_cov); //4/6 bins hit
        exp_cov = (!first) ? 100.0 : 100.0*  ++bins_hit/SHAMT_TOT_BINS;   
        test_i_shamt_imm(imm_code,f3,      10, exp_cov); //5/6 bins hit
        exp_cov = (!first) ? 100.0 : 100.0*  ++bins_hit/SHAMT_TOT_BINS;   
        test_i_shamt_imm(imm_code,f3,      15, exp_cov);//6/6 bins hit
      
        begin   
          string fail_msg;          
          inst32_iformat i32i_shamt = inst32_iformat::new_from_funct3_shamt_imm(my_decoder_wrapper,f3,0, 3'b001);
          real exp_cov = 100.0*(i+1)/$size(I_SHAMT_INSTS);   
          cov = i32i_shamt.get_shamt_inst_x_shamt_cov();
          fail_msg = $psprintf("shamt_inst_x_shamt_cov = %f, expect %f" , cov, exp_cov);
          `FAIL_UNLESS_LOG(int'(cov) == int'(exp_cov), fail_msg);
        end
      end  
    end
  
  `SVTEST_END

  `SVUNIT_TESTS_END

  task automatic test_i_ns_imm(
                               funct3_t f3,
                               opcode_t op,  
                               imm_low_t imm, 
                               real exp_cov
                               );
    inst32_iformat i32i; 
    imm_low_t gotten_imm; 
    real cov;

    i32i = inst32_iformat::new_nonspecial_from_funct3_op_imm(my_decoder_wrapper,f3,op,imm);    

    gotten_imm = i32i.get_imm();    
    `FAIL_UNLESS_LOG(gotten_imm == imm, $psprintf("gotten_imm = %d, exp imm=%d", gotten_imm, imm));   

    //Sample and check coverage
    i32i.sample_cov();          
    cov = i32i.get_nonspecial_imm_cov();
    `FAIL_UNLESS_LOG(int'(cov) == int'(exp_cov), $psprintf("I imm_cov() = %d, expect %d",cov,exp_cov))
    
  endtask // test_i_ns_imm

  task automatic test_i_shamt_imm(
                                  bit [31-25:0] imm_code,
                                  funct3_t f3,
                                  shamt_t shamt, 
                                  real exp_cov); 

    inst32_iformat i32i; 
    imm_low_t gotten_shamt; 
    real cov;

    i32i = inst32_iformat::new_from_funct3_shamt_imm(my_decoder_wrapper,f3,shamt,imm_code);    
    
    gotten_shamt = i32i.get_shamt();
    `FAIL_UNLESS_LOG(gotten_shamt == shamt, $psprintf("gotten_shamt = %d, exp shamt=%d", gotten_shamt, shamt));   
    
    //Sample and check coverage
    i32i.sample_cov();          
    cov = i32i.get_shamt_cov();
    `FAIL_UNLESS_LOG(int'(cov) == int'(exp_cov), $psprintf("SHAMT imm_cov() = %d, expect %d",cov,exp_cov))

  endtask      

endmodule
