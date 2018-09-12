
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


`ifndef _I32_MONITOR_INCLUDED_
`define _I32_MONITOR_INCLUDED_


class i32_monitor extends uvm_monitor;

  const static string         TRACKER_FN = "riscv_tracker_%0d.log";
  int                         m_core_id = -1;    
  virtual riscv_vip_inst_if   m_vi;
  decoder                     m_decoder;  
  reg_fetcher                 m_reg_fetcher;
  int                         m_tracker_file;
  logic [31:0]                m_last_pc = 'hFFFFFFFE;  
  i32_item                    m_item;
  
  uvm_analysis_port#(i32_item) m_ap;
  
  `uvm_component_utils_begin(i32_monitor)
  `uvm_component_utils_end

  function new(string name, uvm_component parent);
    super.new(name,parent);
    m_ap = new("m_item_aport", this);    
  endfunction // new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_decoder = new();
    m_reg_fetcher = new();
    init_tracker();    
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    fork
      do_monitor();
    join_none     
  endtask // run_phase

  virtual protected task do_monitor();

    @(negedge m_vi.rstn);
    forever begin
      @(posedge m_vi.clk && m_vi.curr_pc !== m_last_pc);
      transact();
      m_last_pc = m_vi.curr_pc;      
    end      
  endtask // do_monitor

  virtual function void report_phase(uvm_phase phase);
    end_tracker();    
  endfunction

  virtual protected task transact();
    i32_item item = i32_item::type_id::create("item",this);     
    item.m_inst = m_decoder.decode_inst32(m_vi.curr_inst);

    //race condition possible here since this transact() 
    //proc is run off same clock edge as reg_fetcher's regfile monitor    
    //TODO: layer this in a more elegant way.  instruction monitor feeds
    //into a higher level monitor that adds on the register values to the item 
    //perhaps
    #0  //yield to the regfile monitor to update its values...  
    m_reg_fetcher.fetch_regs(item.m_inst);  //associate the reg values w/ instruction

    item.m_addr = m_vi.curr_pc;
    item.m_inst_bits = m_vi.curr_inst;    
    m_item = item;    
    track_item();
    m_ap.write(item); 
  endtask // transact


   virtual function void init_tracker();
     string tracker_fn;
     assert(m_core_id != -1) else `uvm_fatal("MON","m_core_id not set");
     tracker_fn = $psprintf(TRACKER_FN,m_core_id);     
     m_tracker_file = $fopen(tracker_fn);     
   endfunction // init_tracker

   virtual function void end_tracker();
     $fclose(m_tracker_file);
   endfunction

   virtual function void track_item();
     string inst_str;
     inst_str = (m_item.m_inst) ? 
                m_item.m_inst.to_string() :
                $psprintf("%08H unknown",m_item.m_inst_bits);     
     $fdisplay(m_tracker_file, $psprintf("%08H %s", m_item.m_addr, inst_str));
   endfunction

endclass 
  
`endif
