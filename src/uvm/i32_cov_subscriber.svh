
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

`ifndef _I32_COV_SUB_INCLUDED_
`define _I32_COV_SUB_INCLUDED_


class i32_cov_subscriber extends uvm_subscriber#(i32_item);


  `uvm_component_utils_begin(i32_cov_subscriber)
  `uvm_component_utils_end

  //----------------------------------------------------------------------------
  // new
  //------------------------------------------------------------------
  function new(string name, uvm_component parent = null); 
    super.new(name,parent); 
  endfunction 

  //----------------------------------------------------------------------------
  // write
  //------------------------------------------------------------------
  function void write(i32_item t); 
    string inst_str;
    inst_str = (t.m_inst) ? 
               t.m_inst.to_string() :
               $psprintf("%08H unknown",t.m_inst_bits);

    `uvm_info(get_full_name(), $sformatf("receiving %s",inst_str), UVM_HIGH) 

     if (t.m_inst) begin
       t.m_inst.sample_cov();
     end

  endfunction 

endclass : i32_cov_subscriber

`endif // *_INCLUDED_
