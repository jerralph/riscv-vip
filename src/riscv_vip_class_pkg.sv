

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

`ifndef _RISCV_VIP_CLASS_PKG_SV_
`define _RISCV_VIP_CLASS_PKG_SV_

package riscv_vip_class_pkg;     

  import riscv_vip_pkg::*;   
 `include "riscv_vip_defines.svh"


  //Forward class definitions
  typedef class decoder;   
  typedef class inst16;
  typedef class inst16_ciformat;  
  typedef class inst32;
  typedef class inst32_rformat;
  typedef class inst32_iformat;
  typedef class inst32_sformat;
  typedef class inst32_bformat;
  typedef class inst32_uformat;         
  typedef class inst32_jformat;         
     
  `include "instruction.svh"
  `include "decoder.svh"
  `include "regfile.svh"
  `include "reg_fetcher.svh"
  `include "csrs.svh"
  `include "inst_history.svh"
  `include "hex_file_analyzer.svh"
   
endpackage 

`endif 

