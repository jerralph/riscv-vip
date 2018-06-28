
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

`ifndef _HEX_FILE_ANALYZER_INCLUDE_
`define _HEX_FILE_ANALYZER_INCLUDE_

/**
 * CLASS: hex_file_analyzer
 * 
 * This class processes a RISCV HEX file or list of files. It decodes each 
 * instruction in the file, prints out the derived instruction and samples 
 * coverage for each instruction.
 * 
 * This helps with testing/debugging the riscv-vip instruction and decode classes 
 * (since the reverse decoded assembly can be compared to the *dump for the file).
 * This also provides an oportunity to analyze what is not possibly covered in the 
 * execution of a hex file or a set of hex files.  
 * 
 * The coverage generated is more than what would be observed from the coverage of
 * executing the program since not every instruction in a hex file would normally
 * be executed.  None-the-less, what is not covered using this analysis would not be
 * covered in the execution of the HEX file.
 *
 */
class hex_file_analyzer;
  parameter int unsigned NUM_MEM_BYTES = 2**20;  
  logic [7:0] m_mem  [0:NUM_MEM_BYTES-1];  //memory for the hex file
  decoder m_decoder;
    
  function new();
    m_decoder = new();    
  endfunction // new

  //Zero the memory and load it from the given file name
  function automatic void load_mem_from_hex_file(string fn);    
    m_mem = '{NUM_MEM_BYTES{'0}};
    //$display("reading %s", fn);	   
    $readmemh(fn,m_mem);
  endfunction 
  
  //file_list_fn is a list of space separatated paths to hex files 
  virtual function void analyze_files(string file_list_fn);
    int unsigned file = $fopen(file_list_fn,"r");
    int fscan_result;

    assert(file) else $fatal("bad file");
    m_decoder.m_strict = 0;  //Don't fatal on unsupported insts, get null instead
 
    while(!$feof(file)) begin        	
      string hex_fn;
      fscan_result = $fscanf(file, "%s ", hex_fn);
      if(hex_fn.len()>0) begin
        analyze_file(hex_fn);        
      end
    end    
  endfunction // analyze_files
  

  //Analyze a hex file
  virtual function void analyze_file(string hex_fn);
    load_mem_from_hex_file(hex_fn);

    for (int i=0;i<$size(m_mem);) begin	   
      bit [15:0] parcel;
      int unsigned rp; //remaining parcels
      inst32 i32;
      inst16 i16;	   
      int unsigned addr;

      parcel[7:0] = m_mem[i++];
      parcel[15:8] = m_mem[i++];
      rp = m_decoder.decode_len(parcel);

      if (rp == 0) begin
        i16= m_decoder.decode_inst16(parcel);
        addr = i-2;
        if (i16) begin
    	    $display("%H %04H 16bit instruction",addr,parcel);
        end
      end else if (rp == 1) begin
        inst_t inst_bits = {m_mem[i+1],m_mem[i],parcel};
        addr = i-2;
        i+=2;	      
        i32 = m_decoder.decode_inst32(inst_bits);	      
        if (i32) begin
          $display("%H %s",addr, i32.to_string());
          i32.sample_cov();
        end
      end
    end           
  endfunction // analyze_file

  
endclass
      


`endif
