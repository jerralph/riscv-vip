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

`ifndef _I32_COV_SUB_INCLUDED_
`define _I32_COV_SUB_INCLUDED_

//-----------------------------------------------------------------------------
// Class: i32_cov_subscriber
// Facilitates the sampling of instruction coverage
//-----------------------------------------------------------------------------
class i32_cov_subscriber extends uvm_subscriber#(inst32);
  `uvm_component_utils(i32_cov_subscriber)

  //---------------------------------------------
  // Externally defined tasks and functions
  //---------------------------------------------
  extern function new(string name, uvm_component parent = null); 
  extern virtual function void write(inst32 t); 

endclass: i32_cov_subscriber

//-----------------------------------------------------------------------------
// Constructor: new
// Initializes the i32_cov_subscriber class object
//
// Parameters:
//  name - instance name of the i32_cov_subscriber 
//  parent - parent under which this component is created
//-----------------------------------------------------------------------------
function i32_cov_subscriber::new(string name, uvm_component parent = null); 
  super.new(name,parent); 
endfunction: new 

//-----------------------------------------------------------------------------
// Function: write
// Write implementation method for the analysis port 
// 
// Parameters: 
//  t - input inst32 instruction verif object
//-----------------------------------------------------------------------------
function void i32_cov_subscriber::write(inst32 t); 

  string inst_str;
  inst_str = (t) ? 
             t.to_string() :
             $psprintf("%08H unknown",t.m_inst);

  `uvm_info(get_type_name(), $sformatf("receiving %s",inst_str), UVM_HIGH); 

  // Sampling the coverage
  if(t) begin
    t.sample_cov();
  end
endfunction: write 

`endif 
