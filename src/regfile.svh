
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


`ifndef _REGFILE_INCLUDED_
`define _REGFILE_INCLUDED_

class regfile;    
  
  protected x_regfile_array_t m_x_regfile_array;
  
  virtual function void set_m_x_regfile_array(x_regfile_array_t x);
    this.m_x_regfile_array = x;
  endfunction 

  // Get m_reg_struct
  virtual function x_regfile_array_t get_m_x_regfile_array();
    return m_x_regfile_array;
  endfunction
  
  virtual function  xlen_t get_x(int unsigned i);
    //x[0] is always 0
    return ( i==0 ) ? 0 :  m_x_regfile_array[i];  
  endfunction 

endclass 

//This class monitors the whitebox regfile and updates the model class.  This 
//is intended for non UVM agent regfile implementations and will be updated when/if
//things change to full uvm.  Keep it simple for now 'caus it's going to change
class monitored_regfile extends regfile;
  typedef virtual riscv_vip_regfile_if vif_t;

  vif_t m_vif;  
  
  virtual function void set_m_vif(vif_t vif);
    m_vif = vif;
  endfunction
     
  virtual task run_monitor();
    do_monitor_thread : fork
      do_monitor();
    join_none
  endtask 

  virtual protected task do_monitor();
    @(negedge m_vif.rstn);
    forever begin
      @(posedge m_vif.clk iff m_x_regfile_array !== m_vif.x);         
      //could just assign m_x_regfile_array to m_vif.x but may at some point
      //want to know exactly what changed..
      foreach(m_vif.x[i]) begin
        if (m_x_regfile_array[i] !== m_vif.x[i]) begin
          m_x_regfile_array[i] = m_vif.x[i];
          //do not break early, need to check all for changes
        end
      end
    end      
  endtask // do_monitor


endclass


`endif