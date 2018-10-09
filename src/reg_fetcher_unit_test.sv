
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

module reg_fetcher_unit_test;
  import svunit_pkg::svunit_testcase;
  import riscv_vip_pkg::*;
  import riscv_vip_class_pkg::*;
   

  string name = "reg_fetcher_ut";
  svunit_testcase svunit_ut;

  logic clk;
  logic rstn; 
  
  //regfile interface
  riscv_vip_regfile_if regfile_if(.*);
  monitored_regfile my_regfile = new();

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
    my_regfile.set_m_vif(regfile_if);    
    my_regfile.run_monitor();

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

    `SVTEST(test_rs1_fetch)
      
      reg_fetcher uut = new();
      uut.set_m_regfile(my_regfile);


      //X out everything
      for(int i=1; i< 32; i++) begin
        regfile_if.x[i] = 'x;
      end

      //set reg 1 to all 1s
      regfile_if.x[1] = xlen_t'(-1);
      toggle_clock();      

      //set reg 31 and check it's what was set
      regfile_if.x[31] = xlen_t'('hCCCC_CCCC);
      toggle_clock();

      begin        
        decoder decoder0 = new();
        opcode_t op = OP_IMM;   
        funct3_t funct3 = 0;   
        inst32 addi = inst32_iformat::new_nonspecial_from_funct3_op_imm(decoder0,funct3,op,-1);
        xlen_t rs1_val;
        bit rs1_val_matches;
        string string_val;
        bit string_match;
        
        addi.m_inst.i_inst.rs1 = 31;
        addi.m_inst.i_inst.rd  = 3;
        uut.fetch_regs(addi);
        
        //Print the instruction string.  This should include the rf.rs1/2 values
        string_val = addi.to_string(); 
        $display(string_val);
        string_match = (string_val == "0 ffff8193 I ADDI X3_GP, X31_T6, -1 |  rf.X31_T6 = 3435973836");                
        `FAIL_UNLESS(string_match)        
                
        rs1_val = addi.get_rs1_val();
        rs1_val_matches = (rs1_val == 'hCCCC_CCCC);
        `FAIL_UNLESS_LOG( rs1_val_matches, $psprintf("rsq val 0x%h != 0xCCCCCCCC",rs1_val))
        
      end
            
    `SVTEST_END

    `SVTEST(test_rs2_fetch)
      
      reg_fetcher uut = new();
      uut.set_m_regfile(my_regfile);

      //X out everything
      for(int i=1; i< 32; i++) begin
        regfile_if.x[i] = 'x;
      end

      //set reg 1 to all 1s
      regfile_if.x[1] = xlen_t'(-1);
      toggle_clock();      

      //set reg 31 and check it's what was set
      regfile_if.x[1] = xlen_t'('h1);
      regfile_if.x[2] = xlen_t'('h2);
      toggle_clock();

      begin

        inst_t inst  = r_inst_t'{funct7:0, rs2:2, rs1:1, funct3:0, rd:31, op:OP };

        decoder decoder0 = new();
        inst32 add = decoder0.decode_inst32(inst);

        xlen_t rs1_val;
        xlen_t rs2_val;
        bit rs1_val_matches;
        bit rs2_val_matches;
        string string_val;
        bit string_match;

        //Used the following to debug a weird error... that was due to the way
        //the internal m_inst_enum is calculated/used...  Fixed the bug 
        //but left the testing here in case it pops up again.
        `FAIL_UNLESS_LOG(add.get_inst_enum() == ADD, add.get_inst_enum().name() );


        uut.fetch_regs(add);
        
        `FAIL_UNLESS( !(ADD inside {`INSTS_WITH_NO_RS_LIST}));
        `FAIL_UNLESS(add.has_rs1());
        `FAIL_UNLESS(add.has_rs1_val_set());
        `FAIL_UNLESS(add.get_rs1_val() === 1);


        //Print the instruction string.  This should include the rf.rs1/2 values
        string_val = add.to_string(); 
        $display(string_val);

        string_match = (string_val == "0 00208fb3 R ADD X31_T6, X1_RA, X2_SP  |  rf.X1_RA = 1, rf.X2_SP = 2");                
        `FAIL_UNLESS(string_match)        


        rs1_val = add.get_rs1_val();
        rs1_val_matches = (rs1_val == 'h1);
        `FAIL_UNLESS_LOG( rs1_val_matches, $psprintf("rs1 val 0x%h != 0x1",rs1_val))

        rs2_val = add.get_rs2_val();
        rs2_val_matches = (rs2_val == 'h2);
        `FAIL_UNLESS_LOG( rs2_val_matches, $psprintf("rs2 val 0x%h != 0x2",rs2_val))

        regfile_if.x[1] = xlen_t'('hBB);
        regfile_if.x[2] = xlen_t'('hCC);
        toggle_clock();

        uut.fetch_regs(add);

        rs1_val = add.get_rs1_val();
        rs1_val_matches = (rs1_val == 'hBB);
        `FAIL_UNLESS_LOG( rs1_val_matches, $psprintf("rs1 val 0x%h != 0xBB",rs1_val))

        rs2_val = add.get_rs2_val();
        rs2_val_matches = (rs2_val == 'hCC);
        `FAIL_UNLESS_LOG( rs2_val_matches, $psprintf("rs2 val 0x%h != 0xCC",rs2_val))



      end
            
    `SVTEST_END



  `SVUNIT_TESTS_END

  task toggle_clock();
    repeat (2) #5 clk = ~clk;
  endtask


endmodule
