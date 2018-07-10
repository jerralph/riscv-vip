

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

`ifndef _RISCV_VIP_TEST_PKG_INCLUDED_
`define _RISCV_VIP_TEST_PKG_INCLUDED_

package riscv_vip_test_pkg;

  //------------------------------------------------------------------
  // UVM packages and macros
  //--------------------------------------------------------
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  //------------------------------------------------------------------
  // Packages used
  //--------------------------------------------------------
  // design packages
  import riscv_vip_uvc_pkg::*;

  //--------------------------------------------------------
  //System level components.

  //------------------------------------------------------------------
  // Package components
  //--------------------------------------------------------
  `include "riscv_vip_base_test.svh"
   

endpackage : riscv_vip_test_pkg

`endif // _RISCV_VIP_TEST_PKG_INCLUDED_
