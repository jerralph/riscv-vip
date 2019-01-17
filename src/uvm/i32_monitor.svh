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

`ifndef _I32_MONITOR_INCLUDED_
`define _I32_MONITOR_INCLUDED_

//-----------------------------------------------------------------------------
// Class: i32_monitor
// Instruction_32 Monitor
// Samples the current instruction and PC values and 
// initiates recording, tracking and sampling
//-----------------------------------------------------------------------------
class i32_monitor extends uvm_monitor;
  `uvm_component_utils(i32_monitor)

  // Constant: TRACKER_FN
  // Constaints the tracker log file name template
  const static string TRACKER_FN = "riscv_tracker_%0d.log";

  // Variable: m_core_id
  // Useful for creating separate tracker files
  // for each core used
  int m_core_id = -1;    

  // Variable: riscv_vip_inst_if m_vi
  // Virtual handle for instruction interface
  virtual riscv_vip_inst_if.MON m_vi;

  // Variable: m_tracker_file
  // For storing the tracker file handle
  int m_tracker_file;
  
  // Variable: m_last_pc
  // Stores the last Program Counter value
  logic [31:0] m_last_pc = 'hFFFFFFFE;  

  // Variable: inst32 m_item
  // Instruction 32 verif object
  inst32 m_item;

  // Variable: m_cycle
  // Keep a count of the number of cycles
  int unsigned m_cycle = 0;
 
  // Variable: event_pool
  // UVM event pool of all the events 
  uvm_event_pool event_pool;

  // Variable: ev_regfile_updated
  // UVM event for waiting on regfile updation
  uvm_event ev_regfile_updated;
    
  // Variable: m_ap
  // UVM analysis port
  uvm_analysis_port#(inst32) m_ap;

  // Variable: put_port
  // Blocking put port 
  uvm_blocking_put_port#(inst32) put_port; 

  // Variable: trans_port_inst32
  // Bi-directional transport
  uvm_transport_port#(.REQ( bit[31:0] ),
                      .RSP( inst32 ) ) trans_port_inst32; 

  //---------------------------------------------
  // Externally defined tasks and functions
  //---------------------------------------------
  extern function new(string name, uvm_component parent); 
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual protected task do_monitor();
  extern virtual protected task transact();
  extern virtual function void init_tracker();
  extern virtual function void track_item();
  extern virtual function void report_phase(uvm_phase phase);
  extern virtual function void end_tracker();

endclass: i32_monitor

//-----------------------------------------------------------------------------
// Constructor: new
// Initializes the i32_monitor class object
//
// Parameters:
//  name - instance name of the i32_monitor
//  parent - parent under which this component is created
//-----------------------------------------------------------------------------
function i32_monitor::new(string name, uvm_component parent); 
  super.new(name,parent); 
endfunction: new 

//-----------------------------------------------------------------------------
// Function: build_phase
// Creates the required ports and initiates the tracker
//
// Parameters:
//  phase - stores the current phase 
//-----------------------------------------------------------------------------
function void i32_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);

  // Creating the ports
  m_ap = new("m_item_aport",this);    
  put_port = new("put_port",this); 
  trans_port_inst32 = new("trans_port_inst32",this);

  // Creating the uvm pool
  event_pool = new();
  // Get the uvm global pool 
  event_pool = event_pool.get_global_pool();
  // Get the required event from the pool
  ev_regfile_updated = event_pool.get("regfile_updated");

  // Starting the tracker
  init_tracker();    
endfunction: build_phase

//-----------------------------------------------------------------------------
// Task: run_phase
// Waits for reset and initiates the main montoring task 
//
// Parameters:
//  phase - stores the current phase 
//-----------------------------------------------------------------------------
task i32_monitor::run_phase(uvm_phase phase);

  // Wait for active-high reset
  @(posedge m_vi.rstn);
  do_monitor();
endtask: run_phase

//-----------------------------------------------------------------------------
// Task: do_monitor
// Performs the main monitoring task
//-----------------------------------------------------------------------------
task i32_monitor::do_monitor();

  //Two processes synced with an event to overcome race possibility
  //between posedge clk for i32_monitor and monitored_regfile in
  //grabbing register file values for decoded instruction using wait_ptrigger()

  fork
    // Keeps a count of positive clock edges
    forever begin: T1
      @(m_vi.mon_cb);
      m_cycle++;
    end
    // Samples the curr_inst and curr_pc and decodes the instruction
    forever begin: T2
      @(m_vi.mon_cb iff m_vi.mon_cb.curr_pc !== m_last_pc);
      // wait for the regfile updation trigger
      ev_regfile_updated.wait_ptrigger();
      m_last_pc = m_vi.mon_cb.curr_pc;      
      transact();
    end 
  join_none
endtask: do_monitor

//-----------------------------------------------------------------------------
// Task: transact
// Based on current instruction the corresponding verif object is created.
// The instruction is updated with the register values from regfile 
// and later sent via the analysis port
//-----------------------------------------------------------------------------
task i32_monitor::transact();
  inst32 item; 

  // Based on the current instruction the instruction verif object 
  // is created accordingly 
  trans_port_inst32.transport(m_vi.mon_cb.curr_inst,item);
  `uvm_info(get_type_name(),$sformatf("Created item - %s", item.to_string()),UVM_HIGH);
 
  // Update the instruction with the register values from the regfile                                                              
  if(item != null) begin
    put_port.put(item); 
    `uvm_info(get_type_name(),$sformatf("Updated item - %s", item.to_string()),UVM_HIGH);

    //needed by the inst_history
    item.m_cycle = m_cycle;  
  end
   
  // Storing the required info
  item.m_addr = m_vi.mon_cb.curr_pc;
  item.m_inst = m_vi.mon_cb.curr_inst;    

  m_item = item;    

  // Write the instruction info into the tracker file
  track_item();

  // Send the instruction via the analysis port
  m_ap.write(item); 
endtask: transact

//-----------------------------------------------------------------------------
// Function: init_tracker
// Opens a tracker file based on the core_id
//-----------------------------------------------------------------------------
function void i32_monitor::init_tracker();

  string tracker_fn;
  assert(m_core_id != -1) else `uvm_fatal(get_type_name(),"m_core_id not set");

  // tracker file name
  tracker_fn = $psprintf(TRACKER_FN,m_core_id);     

  // Open the file and return the handle
  m_tracker_file = $fopen(tracker_fn);    

  // Track file header
  $fdisplay(m_tracker_file, $psprintf("T(ns) Addr('h) Cycle Instruction  Type  Assembly_inst        Register_values"));

endfunction: init_tracker

//-----------------------------------------------------------------------------
// Function: track_item
// Prints the info into the tracker file
//-----------------------------------------------------------------------------
function void i32_monitor::track_item();

  string inst_str;
  inst_str = (m_item) ? 
            m_item.to_string() :
            $psprintf("%08H unknown",m_item.m_inst);     

  // Writing into the file
  $fdisplay(m_tracker_file, $psprintf("%-5t %08H   %s", $time, m_item.m_addr, inst_str));
endfunction: track_item

//-----------------------------------------------------------------------------
// Function: report_phase
// Performs the reporting functions 
//
// Parameters:
//  phase - stores the current phase 
//-----------------------------------------------------------------------------
function void i32_monitor::report_phase(uvm_phase phase);
  end_tracker();    
endfunction

//-----------------------------------------------------------------------------
// Function: end_tracker
// Closes the tracker file
//-----------------------------------------------------------------------------
function void i32_monitor::end_tracker();
  $fclose(m_tracker_file);
endfunction: end_tracker

`endif
