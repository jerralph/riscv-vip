
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

module inst32_unit_test;
  import svunit_pkg::svunit_testcase;
  import riscv_vip_pkg::*;
  import riscv_vip_class_pkg::*;
   

  string name = "inst32_ut";
  svunit_testcase svunit_ut;


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  inst32 my_inst32;
  decoder my_decoder;   
   

  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);

    my_decoder = new();     
    //my_inst32  = new(/* New arguments if needed */);
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    svunit_ut.setup();
    /* Place Setup Code Here */

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

    `SVTEST(ug_example1)
       decoder decoder0 = new();
       opcode_t op = OP_IMM;   
       funct3_t funct3 = 0;   
       inst32 addi = inst32_iformat::new_nonspecial_from_op_funct3_imm(decoder0,funct3,op,-1);
       addi.m_inst.i_inst.rs1 = 1;
       addi.m_inst.i_inst.rd  = 3;       
       $display("My addi from code is [ %s ]", addi.to_string());      
    `SVTEST_END

    `SVTEST(ug_example2)

       //TODO move this into an examples unit test so it doesn't mess with the overall per type coverage
       //for now sample() commented... also eventually coverage will be changed to all per instance...
       real cov;    
       decoder decoder0 = new();
       bit[31:0] inst_bits = 32'hfff08193;    
       inst32 i32 = decoder0.decode_inst32(inst_bits);
       $display("decode of 0x%0H is [ %s ]", inst_bits, i32.to_string());

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

   
    `SVTEST(test1)

      inst32 i32;

      //create some instructions to decode
      inst_t insts[3];
      insts[0] = create_i_inst(._imm(99), ._rs1(2), ._funct3(3), ._rd(1), ._op(LOAD));
      insts[1] = create_i_inst(._imm('hFF), ._rs1(1), ._funct3(2), ._rd(5), ._op(SYSTEM));
      insts[2] = create_r_inst(._funct7(0), ._rs2(1), ._rs1(1), ._funct3(2), ._rd(2), ._op(OP));

      //decode instructions and make sure they decoded into the classes the way expected       
      i32 = my_decoder.decode_inst32(insts[0]);
      assert(i32 != null);   
      //$display(i32.to_string());
     `FAIL_UNLESS_EQUAL(i32.m_rvg_format,I);   
     `FAIL_UNLESS_EQUAL(i32.get_rd(),1);
      //$display("%b %s", i32.m_inst, i32.to_string());

      i32 = my_decoder.decode_inst32(insts[1]);
      $display(i32.to_string());
     `FAIL_UNLESS_EQUAL(i32.m_rvg_format,I);   
     `FAIL_UNLESS_EQUAL(i32.get_rd(),5);

      i32 = my_decoder.decode_inst32(insts[2]);
      $display(i32.to_string());
     `FAIL_UNLESS_EQUAL(i32.m_rvg_format,R);   
     `FAIL_UNLESS_EQUAL(i32.get_rd(),2);

   `SVTEST_END


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
         inst32_sformat i32s = inst32_sformat::new_from_funct3_imm(my_decoder,i,0);          
         real exp_cov = 100.0*(i+1)/$size(S_INSTS);   
         cov = i32s.get_sinst_x_imm_cov();
         fail_msg = $psprintf("sinst_x_imm_cov = %g, expect %g" , cov, exp_cov);
         `FAIL_UNLESS_LOG(int'(cov) == int'(exp_cov), fail_msg);             
       end

     end
  
  `SVTEST_END

  `SVTEST(inst32_uformat_cov)
    int bins_hit = 0;
    const int TOT_BINS = 7;
    const int IMM_BITS = 20;   
    const int MIN_NEG = -(2**IMM_BITS)/2;
    const int MAX_POS = (2**IMM_BITS)/2-1;

    test_u_imm(      10, 100.0*  bins_hit/TOT_BINS); //imm of        10, 0/7 bins hit
    test_u_imm(       0, 100.0*++bins_hit/TOT_BINS); //imm of         0, 1/7 bins hit  
    test_u_imm(      -1, 100.0*++bins_hit/TOT_BINS); //imm of  all ones, 2/7 bins hit  
    test_u_imm(      -1, 100.0*  bins_hit/TOT_BINS); //imm of  all ones, 2/7 bins hit  
    test_u_imm(       1, 100.0*++bins_hit/TOT_BINS); //imm of         1, 3/7 bins hit  
    test_u_imm(       2, 100.0*++bins_hit/TOT_BINS); //imm of         2, 4/7 bins hit  
    test_u_imm(       4, 100.0*++bins_hit/TOT_BINS); //imm of         4, 5/7 bins hit  
    test_u_imm( MIN_NEG, 100.0*++bins_hit/TOT_BINS); //imm of   min neg, 6/7 bins hit  
    test_u_imm( MAX_POS, 100.0*++bins_hit/TOT_BINS); //imm of   max pos, 7/7 bins hit  

    //TODO: test cross
  
  `SVTEST_END


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

 `SVTEST(inst32_bformat_cov)

   int bins_hit = 0;
   const int TOT_BINS = 6;
   const int IMM_BITS = 13;  
   const int MIN_NEG = -(2**IMM_BITS)/2;
   const int MAX_POS = (2**IMM_BITS)/2-2;  //LSB always 0 for B type


   funct3_t f3 = 0;
      
   test_b_imm(f3,      10, 100.0*  bins_hit/TOT_BINS); //imm of        10, 0/7 bins hit

   test_b_imm(f3,      0, 100.0*++bins_hit/TOT_BINS); //imm of  all ones, 2/7 bins hit  
  
   test_b_imm(f3,      -2, 100.0*++bins_hit/TOT_BINS); //imm of  all ones, 2/7 bins hit  
   test_b_imm(f3,      -2, 100.0*  bins_hit/TOT_BINS); //imm of  all ones, 2/7 bins hit  
   test_b_imm(f3,       2, 100.0*++bins_hit/TOT_BINS); //imm of         2, 4/7 bins hit
   test_b_imm(f3,       4, 100.0*++bins_hit/TOT_BINS); //imm of         4, 5/7 bins hit
   test_b_imm(f3, MIN_NEG, 100.0*++bins_hit/TOT_BINS); //imm of   min neg, 6/7 bins hit  
   test_b_imm(f3, MAX_POS, 100.0*++bins_hit/TOT_BINS); //imm of   max pos, 7/7 bins hit  

   //TODO Test cross
   
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
          inst32_iformat i32i = inst32_iformat::new_nonspecial_from_op_funct3_imm(
            my_decoder,
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
          inst32_iformat i32i_shamt = inst32_iformat::new_from_funct3_shamt_imm(my_decoder,f3,0, 3'b001);
          real exp_cov = 100.0*(i+1)/$size(I_SHAMT_INSTS);   
          cov = i32i_shamt.get_shamt_inst_x_shamt_cov();
          fail_msg = $psprintf("shamt_inst_x_shamt_cov = %f, expect %f" , cov, exp_cov);
          `FAIL_UNLESS_LOG(int'(cov) == int'(exp_cov), fail_msg);
        end
      end  
    end
  
  `SVTEST_END

  `SVTEST(store_to_string)
     //Prove out a fix to the way store instructions are printed
     inst32 i32 = my_decoder.decode_inst32(32'h0055a023);
     string obs = i32.to_string();
     string   expected = "0055a023 S SW X5_T0, 0(X11_A1)";   
     `FAIL_UNLESS_LOG(obs == expected  ,$psprintf("obs %s, expected %s",obs,expected))

     i32 = inst32_sformat::new_from_funct3_imm(my_decoder, 3'b001, -9);
     obs = i32.to_string();
     expected = "fe001ba3 S SH X0_ZERO, -9(X0_ZERO)";   
     `FAIL_UNLESS_LOG( obs == expected  ,$psprintf("obs %s, expected %s",obs,expected))
   
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
    
    i32s = inst32_sformat::new_from_funct3_imm(my_decoder,funct3,imm);

    gotten_imm = i32s.get_imm();
    `FAIL_UNLESS_LOG(gotten_imm == imm, $psprintf("gotten_imm = %d, exp imm=%d", gotten_imm, imm));   

    //Sample and check coverage
    i32s.sample_cov();          
    cov = i32s.get_imm_cov();
    `FAIL_UNLESS_LOG(int'(cov) == int'(exp_cov), $psprintf("S imm_cov = %f, expect %f",cov,exp_cov))
    
  endtask

  task automatic test_u_imm(
                      imm_high_t imm,
                      real exp_cov
                      );

    inst32_uformat i32u; 
    imm_high_t gotten_imm; 
    real cov;
      
    i32u = inst32_uformat::new_from_op_imm(my_decoder,LUI_MAP,imm);    
    
    gotten_imm = i32u.get_imm();
    `FAIL_UNLESS_LOG(gotten_imm == imm, $psprintf("gotten_imm = %d, exp imm=%d", gotten_imm, imm));   

    //Sample and check coverage
    i32u.sample_cov();          
    cov = i32u.get_imm_cov();
    `FAIL_UNLESS_LOG(int'(cov) == int'(exp_cov), $psprintf("U imm_cov = %d, expect %d",cov,exp_cov))

  endtask
   
  task automatic test_j_imm(
                      j_imm_t imm,
                      real exp_cov
                      );
    inst32_jformat i32j; 
    j_imm_t gotten_imm; 
    real cov;
    bit pass = 0;
    
    i32j = inst32_jformat::new_from_imm(my_decoder,imm);    

    gotten_imm = i32j.get_imm();
    `FAIL_UNLESS_LOG(gotten_imm == imm, $psprintf("gotten_imm = %d, exp imm=%d", gotten_imm, imm));   
    
    //Sample and check coverage
    i32j.sample_cov();          
    cov = i32j.get_imm_cov();
    `FAIL_UNLESS_LOG(int'(cov) == int'(exp_cov), $psprintf("J imm_cov() = %d, expect %d",cov,exp_cov))

  endtask

  task automatic test_b_imm(
                      funct3_t f3,
                      b_imm_t imm,
                      real exp_cov
                      );
    inst32_bformat i32b; 
    b_imm_t gotten_imm; 
    real cov;

    i32b = inst32_bformat::new_from_funct3_imm(my_decoder,f3, imm);    

    gotten_imm = i32b.get_imm();
    `FAIL_UNLESS_LOG(gotten_imm == imm, $psprintf("gotten_imm = %d, exp imm=%d", gotten_imm, imm));   
    
    //Sample and check coverage
    i32b.sample_cov();          
    cov = i32b.get_imm_cov();
    `FAIL_UNLESS_LOG(int'(cov) == int'(exp_cov), $psprintf("B imm_cov() = %d, expect %d",cov,exp_cov))

  endtask

   
  task automatic test_i_ns_imm(
                               funct3_t f3,
                               opcode_t op,  
                               imm_low_t imm, 
                               real exp_cov
                               );
    inst32_iformat i32i; 
    imm_low_t gotten_imm; 
    real cov;

    i32i = inst32_iformat::new_nonspecial_from_op_funct3_imm(my_decoder,f3,op,imm);    

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

    i32i = inst32_iformat::new_from_funct3_shamt_imm(my_decoder,f3,shamt,imm_code);    
    
    gotten_shamt = i32i.get_shamt();
    `FAIL_UNLESS_LOG(gotten_shamt == shamt, $psprintf("gotten_shamt = %d, exp shamt=%d", gotten_shamt, shamt));   
    
    //Sample and check coverage
    i32i.sample_cov();          
    cov = i32i.get_shamt_cov();
    `FAIL_UNLESS_LOG(int'(cov) == int'(exp_cov), $psprintf("SHAMT imm_cov() = %d, expect %d",cov,exp_cov))

  endtask      

  function i_inst_t create_i_inst(imm_low_t _imm,
                                  regsel_t _rs1,
                                  funct3_t _funct3,
                                  regsel_t _rd,
                                  opcode_t _op);
    i_inst_t _i_inst;

    _i_inst.imm = _imm;
    _i_inst.rs1 = _rs1;
    _i_inst.funct3 = _funct3;
    _i_inst.rd = _rd;
    _i_inst.op = _op;

    return _i_inst;
  endfunction

  function i_inst_t create_r_inst(funct7_t _funct7,
                                  regsel_t _rs2,
                                  regsel_t _rs1,
                                  funct3_t _funct3,
                                  regsel_t _rd,
                                  opcode_t _op);
    r_inst_t _r_inst;

    _r_inst.funct7 = _funct7;
    _r_inst.rs2 = _rs2;
    _r_inst.rs1 = _rs1;
    _r_inst.funct3 = _funct3;
    _r_inst.rd = _rd;
    _r_inst.op = _op;

    return _r_inst;
  endfunction

endmodule
