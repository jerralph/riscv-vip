
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

`ifndef _I32_ITEM_INCLUDED_
`define _I32_ITEM_INCLUDED_


class i32_item extends uvm_sequence_item;
  inst32    m_inst;
  rv_addr_t m_addr;
  inst_t    m_inst_bits;  //31:0  
  
  `uvm_object_utils_begin(i32_item)
  `uvm_object_utils_end

  function new(string name ="i32_item");
    super.new(name);
  endfunction // new

  virtual function void do_print(uvm_printer printer);
    printer.print_int("m_addr",m_addr,$bits(m_addr));
    printer.print_string("m_inst",m_inst.to_string());    
  endfunction
     
  
endclass
    
  
`endif
