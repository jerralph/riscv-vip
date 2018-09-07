


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

`ifndef _REG_FETCHER_INCLUDED_
`define _REG_FETCHER_INCLUDED_

// This fetches the general purpose reg values for a given instruction 
// from the regfile
class reg_fetcher;  

  protected  regfile m_regfile; 

  virtual function void set_m_regfile(regfile rf);
    this.m_regfile = rf;
  endfunction : set_m_regfile  

  virtual function void fetch_regs(inst32 i32);
    if (i32.has_rs1()) begin
      i32.set_rs1_val(m_regfile.get_x(i32.get_rs1()));      
    end 
    if (i32.has_rs2()) begin
      i32.set_rs2_val(m_regfile.get_x(i32.get_rs2()));
    end

  endfunction

endclass 

`endif
 


