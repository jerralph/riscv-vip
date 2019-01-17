// ############################################################################
//
// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//
// ############################################################################ 

`ifndef _RISCV_VIP_CLASS_PKG_SV_
`define _RISCV_VIP_CLASS_PKG_SV_

//-----------------------------------------------------------------------------
// Package: riscv_vip_class_pkg
// Contains all the required files to compile
//-----------------------------------------------------------------------------
package riscv_vip_class_pkg;     

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "riscv_vip_defines.svh"
  import riscv_vip_pkg::*;   

  //Forward class definitions
  typedef class decoder;   
     
  // Instruction Classes
  `include "inst16.svh"
  `include "inst32.svh"
  `include "inst32_rformat.svh"
  `include "inst32_iformat.svh"
  `include "inst32_sformat.svh"
  `include "inst32_bformat.svh"
  `include "inst32_uformat.svh"
  `include "inst32_jformat.svh"

  `include "regfile.svh"
  `include "regfile_monitor.svh"
  `include "reg_fetcher.svh"

  `include "csrs.svh"

  `include "decoder.svh"
  `include "inst_history.svh"
   
endpackage: riscv_vip_class_pkg 

`endif 
