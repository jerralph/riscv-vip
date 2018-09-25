`include "svunit_defines.svh"

module hex_file_analyzer_unit_test;
  import svunit_pkg::svunit_testcase;
  import riscv_vip_class_pkg::*;
   

  string name = "hex_file_analyzer_ut";
  svunit_testcase svunit_ut;


  //simulator for some reason doesn't like a null virtual interfaces is classes at inital runtime.
  //this solves this...
  //regfile interface
  logic clk;
  logic rstn; 

  riscv_vip_regfile_if regfile_if(.*);
  monitored_regfile my_regfile = new();
  //CSR interface
  riscv_vip_csr_if csr_if(.*);
  monitored_csrs my_csrs = new();


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  hex_file_analyzer my_hex_file_analyzer;


  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);

    my_hex_file_analyzer = new(/* New arguments if needed */);
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    svunit_ut.setup();
    /* Place Setup Code Here */
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

    `SVTEST(analyze_hex_files)

      // Analyze all the HEX files generated from the RV32UI p assembly tests from the
      // RISC Foundation's riscv-tests project from github.  The Makefile at 
      // ../riscv_tests_hexgen generates these HEX files and also the DUMP files
      string HEX_FILES_FN = "../riscv_tests_hexgen/build/hex_files.txt";
      my_hex_file_analyzer.analyze_files(HEX_FILES_FN);

    `SVTEST_END
   

  `SVUNIT_TESTS_END

endmodule
