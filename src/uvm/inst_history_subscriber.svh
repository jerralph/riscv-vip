
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

`ifndef _INST_HISTORY_COV_SUB_INCLUDED_
`define _INST_HISTORY_COV_SUB_INCLUDED_


class inst_history_subscriber extends uvm_subscriber#(i32_item);

  inst_history m_inst_history;

  `uvm_component_utils_begin(inst_history_subscriber)
  `uvm_component_utils_end

  //----------------------------------------------------------------------------
  // new
  //------------------------------------------------------------------
  function new(string name, uvm_component parent = null); 
    super.new(name,parent); 
  endfunction 

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_inst_history = new();
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
       m_inst_history.commit_inst(t.m_inst);
     end

  endfunction 

endclass : inst_history_subscriber

`endif // *_INCLUDED_
