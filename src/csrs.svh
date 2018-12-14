
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


`ifndef _CSRS_INCLUDED_
`define _CSRS_INCLUDED_

class csrs;
  
  protected csrs_t m_csrs;
  
  // Get m_csrs
  virtual function csrs_t get_m_csrs();
    return m_csrs;
  endfunction : get_m_csrs

  // Set m_csrs
  virtual function void set_m_csrs(csrs_t m_csrs);
    this.m_csrs = m_csrs;
  endfunction : set_m_csrs
 
  virtual function csr_t get_cycle();
    return m_csrs.cycle;
  endfunction
 
endclass 

//This class monitors the whitebox csrs and updates the model class.  This 
//is intended for non UVM agent csr implementations and will be updated when/if
//things change to full uvm.  Keep it simple for now 'caus it's going to change
class monitored_csrs extends csrs;
  typedef virtual riscv_vip_csr_if vif_t; 
  virtual riscv_vip_csr_if m_vif;  
  //protected mailbox#(.T(csr_id_t)) assigned_ids;  //future, if needed
  
  virtual function void set_m_vif(vif_t csr_vif);
    m_vif = csr_vif;
  endfunction
 
 
 
  //task wait_for_csr_update(ref csr_id_t updated_ids[$])  //future, if needed... 
    
  virtual task run_monitor();
    do_monitor_thread : fork
      do_monitor();
    join_none
  endtask 

  virtual protected task do_monitor();
    @(posedge m_vif.rstn);
    forever begin
      @(posedge m_vif.clk iff ( m_vif.csrs !== m_csrs));        
      m_csrs = m_vif.csrs;      
    end      
  endtask // do_monitor


endclass
 
`endif