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

`ifndef _INST16_INCLUDE_
`define _INST16_INCLUDE_

//-----------------------------------------------------------------------------
// Class: inst16
// Base class for representing 32 bit instructions in OOP
//-----------------------------------------------------------------------------
virtual class inst16 extends uvm_sequence_item;
  `uvm_object_utils(inst16)

endclass: inst16

class inst16_ciformat extends inst16;
  `uvm_object_utils(inst16_ciformat)

endclass: inst16_ciformat

`endif
