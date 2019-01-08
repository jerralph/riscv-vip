//  ###########################################################################
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
//  ########################################################################### 

`ifndef _INST_HISTORY_COV_SUB_INCLUDED_
`define _INST_HISTORY_COV_SUB_INCLUDED_

//-----------------------------------------------------------------------------
// Class: inst_history_subscriber
// Facilitates RAW hazard evaluation
//-----------------------------------------------------------------------------
class inst_history_subscriber extends uvm_subscriber#(inst32);
  `uvm_component_utils(inst_history_subscriber)

  // Variable: inst_history#(5) inst_hist
  // Insturction history component for RAW evaluation
  typedef inst_history#(5) inst_hist;
  inst_hist m_inst_history;

  //---------------------------------------------
  // Externally defined tasks and functions
  //---------------------------------------------
  extern function new(string name, uvm_component parent = null); 
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void write(inst32 t); 

endclass: inst_history_subscriber

//-----------------------------------------------------------------------------
// Constructor: new
// Initializes the inst_history_subscriber class object
//
// Parameters:
//  name - instance name of the inst_history_subscriber 
//  parent - parent under which this component is created
//-----------------------------------------------------------------------------
function inst_history_subscriber::new(string name, uvm_component parent = null); 
  super.new(name,parent); 
endfunction: new 

//-----------------------------------------------------------------------------
// Function: build_phase
// Creates the inst_history component
//
// Parameters:
//  phase - stores the current phase 
//-----------------------------------------------------------------------------
function void inst_history_subscriber::build_phase(uvm_phase phase);
  super.build_phase(phase);
  m_inst_history = inst_hist::type_id::create("m_inst_history",this);
endfunction: build_phase

//-----------------------------------------------------------------------------
// Function: write 
// Write implementation method for the analysis port 
// 
// Parameters: 
//  t - input inst32 instruction verif object
//-----------------------------------------------------------------------------
function void inst_history_subscriber::write(inst32 t); 

  string inst_str;

  inst_str = (t) ? 
             t.to_string() :
             $psprintf("%08H unknown",t.m_inst);

  `uvm_info(get_type_name(), $sformatf("receiving %s",inst_str), UVM_HIGH); 
  
  // Evaluation of the instruction for RAW hazard  
  if (t) begin
    m_inst_history.commit_inst(t);
  end
endfunction: write 

`endif 
