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

`ifndef _RISCV_VIP_CSR_IF_INCLUDED_
`define _RISCV_VIP_CSR_IF_INCLUDED_

`include "riscv_vip_pkg.sv"

//-----------------------------------------------------------------------------
// Interface: riscv_vip_csr_if
// This is an interface for getting the value of the CSR.
//
// Parameters:
//  clk - Input clock
//  rstn - Input reset
//-----------------------------------------------------------------------------
interface riscv_vip_csr_if (input clk, input rstn);

  riscv_vip_pkg::csrs_t csrs;
   
endinterface

`endif
