
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


`ifndef _RISCV_VIP_UVC_PKG_SV_
`define _RISCV_VIP_UVC_PKG_SV_

`include "riscv_vip_inst_if.sv"
`include "riscv_vip_regfile_if.sv"
`include "riscv_vip_csr_if.sv"

package riscv_vip_uvc_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import riscv_vip_pkg::*;
  import riscv_vip_class_pkg::*;

  `include "i32_item.svh"
  `include "i32_monitor.svh"
  `include "i32_agent.svh"
  `include "i32_cov_subscriber.svh"
  `include "inst_history_subscriber.svh"
  `include "uvc_env.svh"
   
endpackage

`endif

