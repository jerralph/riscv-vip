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

`ifndef _RISCV_VIP_INST_IF_INCLUDED_
`define _RISCV_VIP_INST_IF_INCLUDED_

//-----------------------------------------------------------------------------
// Interface: riscv_vip_inst_if
// This is an interface for getting the values of the PC and instruction.
//
// Parameters:
//  clk - Input clock
//  rstn - Input reset
//-----------------------------------------------------------------------------
interface riscv_vip_inst_if (input clk, input rstn);
    
  // Variable: curr_pc
  // Stores the current prrgram counter value
  logic [31:0]  curr_pc;

  // Variable: curr_inst
  // Stores the current instruction value
  logic [31:0] curr_inst;
   
  //-------------------------------------------------------
  // Clocking block
  //-------------------------------------------------------
  clocking mon_cb @(posedge clk);
      default input #1;
      
      input curr_pc;
      input curr_inst;
  endclocking: mon_cb

  //-------------------------------------------------------
  // Declaring the modports
  //-------------------------------------------------------
  modport MON (clocking mon_cb, input rstn);

endinterface: riscv_vip_inst_if

`endif
