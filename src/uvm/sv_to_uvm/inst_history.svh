// ############################################################################
//
// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//
// ############################################################################ 

`ifndef _INST_HISTORY_INCLUDED_
`define _INST_HISTORY_INCLUDED_

//-----------------------------------------------------------------------------
// This file has the following classes definition:
// 1) raw_hazard_examiner
// 2) inst_history
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Class: raw_hazard_examiner
// Read after write (RAW) data hazard. Latest instruction
// gets its rs1 or rs2 from earlier instruction's rd
// rather than from the regfile value. This is use for coverage
//-----------------------------------------------------------------------------
class raw_hazard_examiner extends uvm_sequence_item;
  `uvm_object_utils(raw_hazard_examiner)

  // Enumerated datatype for RAW case
  typedef enum {RS1_ONLY, RS2_ONLY, RS1AND2, NONE} raw_rs_case_enum_t;

  // Constant: MAX_CYCLES_APART_OF_INTEREST
  // Number of cycles of intereset 
  static const int unsigned MAX_CYCLES_APART_OF_INTEREST = 3;
  
  // Variable: m_cycles_apart
  // Stores the number of cycles the current instruction and
  // the older instruction are apart
  int unsigned m_cycles_apart;

  // Variable: inst32 m_rd_inst
  // Younger instruction
  inst32 m_rd_inst;  

  // Variable: inst32 m_wr_inst
  // Older instruction
  inst32 m_wr_inst; 

  // Variable: raw_rs_case_enum_t raw_rs_case
  // raw register source case 
  raw_rs_case_enum_t raw_rs_case = NONE;  
  
  //-------------------------------------------------------
  // Covergroup: raw_cg
  // Creates the coverpoints and cross coverpoints
  //-------------------------------------------------------
  covergroup raw_cg;
    read_inst_cp : coverpoint m_rd_inst.get_inst_enum(){
      option.weight = 0; //only count the cross
      ignore_bins ignore_has_no_rs_insts = {`INSTS_WITH_NO_RS_LIST};
      ignore_bins unknown_inst = {UNKNOWN_INST};
    } 

    rs_case_cp : coverpoint raw_rs_case iff(raw_rs_case != NONE){
      option.weight = 0; //only count the cross
      ignore_bins ignore_none = {NONE};
    }

    cyc_apart_cp : coverpoint m_cycles_apart {
      option.weight = 0; //only count the cross
      bins cycs[] = {[1:MAX_CYCLES_APART_OF_INTEREST]}; 
    }
    inst_x_rs_case_x_cyc_apart : cross read_inst_cp, rs_case_cp, cyc_apart_cp{
      //for insts w/o rs2 fields, only look at the RS1 case (ignore rs2 cases). 
      ignore_bins ignore_rs2_for_non_rs2_insts = inst_x_rs_case_x_cyc_apart with 
        ( !(read_inst_cp inside {`INSTS_W_RS2_LIST}) && (rs_case_cp != RS1_ONLY) );
    }
    
    //FUTURE: consider bringing the instruction type of the older/write into the cross... 
    //for now, keep it simple. At very least may want to ensure the write is of the different L,R,... types. 
    //    wr_inst_cp : coverpoint m_rd_inst.get_inst_enum(){
    //    }
  endgroup // raw_cg
 
  //-------------------------------------------------------
  // Externally defined tasks and functions
  //-------------------------------------------------------
  extern function new(string name = "raw_hazard_examiner");
  extern virtual function void examine(inst32 curr_inst, inst32 older_inst);
  extern virtual function void post_examine();
  extern virtual function real get_cross_cov();

endclass: raw_hazard_examiner

//-----------------------------------------------------------------------------
// Constructor: new
// Initializes the raw_hazard_examiner class object
//
// Parameters:
//  name - instance name of the raw_hazard_examiner
//-----------------------------------------------------------------------------
function raw_hazard_examiner::new(string name = "raw_hazard_examiner");
  super.new(name);
  // Create the covergroup
  raw_cg = new();
endfunction: new

//-----------------------------------------------------------------------------
// Function: examine
// Examines the instructions in the pipeline for RAW condition
//
// Parameters:
//  curr_inst - Current inst32 instruction
//  older_inst - Older inst32 instruction
//-----------------------------------------------------------------------------
function void raw_hazard_examiner::examine(inst32 curr_inst, inst32 older_inst);

  m_cycles_apart = curr_inst.m_cycle - older_inst.m_cycle; 

  if (m_cycles_apart <= MAX_CYCLES_APART_OF_INTEREST) begin

    //source reg 1 read after write condition?
    bit rs1_raw = 
      curr_inst.has_rs1() && 
      (curr_inst.get_rs1() != X0) &&
      older_inst.has_rd() &&
      (curr_inst.get_rs1() == older_inst.get_rd());

    //source reg 2 read after write condition?
    bit rs2_raw = 
      curr_inst.has_rs2() && 
      (curr_inst.get_rs2() != X0) &&
      older_inst.has_rd() &&
      (curr_inst.get_rs2() == older_inst.get_rd());

    m_rd_inst = curr_inst;
    m_wr_inst = older_inst;
    
    //set the read after write (RAW) register source case
    //used for the coverage cross
    case ({rs1_raw,rs2_raw})
      {2'b10} : begin
        raw_rs_case = RS1_ONLY;
      end
      {2'b01} : begin
        raw_rs_case = RS2_ONLY;
      end
      {2'b11} : begin
        raw_rs_case = RS1AND2;
      end
      default : begin
        raw_rs_case = NONE;
      end
    endcase
    post_examine(); 
  end
endfunction: examine 

//-----------------------------------------------------------------------------
// Function: post_examine
// Samples the RAW covergroup
// Override post_examine to gate based on passing checking before cov, 
// for no check keep it as is.  Beware of moving the sample out of this
// method.  Sample is be called multiple times per cycle as the current 
// instruction is scanned against historical instructions.
//-----------------------------------------------------------------------------
function void raw_hazard_examiner::post_examine();
    raw_cg.sample();  
endfunction: post_examine

//-----------------------------------------------------------------------------
// Function: get_cross_cov
// Get the cross coverage value of RAW covergroup
//
// Returns:
//  Real precision cross coverage value 
//-----------------------------------------------------------------------------
function real raw_hazard_examiner::get_cross_cov();
  return raw_cg.inst_x_rs_case_x_cyc_apart.get_coverage();
endfunction: get_cross_cov


//-----------------------------------------------------------------------------
// Class: inst_history
// This is a delayed version of the pipeline. Essentially this 
// is a queue of completed instructions...
//-----------------------------------------------------------------------------
class inst_history#(int DEPTH = 5) extends uvm_component;
  `uvm_component_utils(inst_history#(DEPTH))

  // Variable: raw_hazard_examiner m_raw_hazard_examiner
  // RAW hazard examiner object handle
  raw_hazard_examiner m_raw_hazard_examiner;

  // Variable: inst32 m_inst_fifo
  // FIFO for storing the instructions
  // Oldest is at higher index 
  protected inst32 m_inst_fifo [$:DEPTH-1] = {};  

  //-------------------------------------------------------
  // Externally defined tasks and functions
  //-------------------------------------------------------
  extern function new(string name, uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void commit_inst(inst32 inst);
  extern virtual protected function void analyze_new_inst();
  extern virtual function inst32 peek_newest();
  extern virtual function inst32 peek_oldest();
  extern virtual function inst32 peek_age(int age);
  extern virtual function int size();

endclass: inst_history
//-----------------------------------------------------------------------------
// Constructor: new
// Initializes the inst_history class object
//
// Parameters:
//  name - instance name of the inst_history
//  parent - parent under which this component is created
//-----------------------------------------------------------------------------
function inst_history::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction: new

//-----------------------------------------------------------------------------
// Function: build_phase
// Creates the raw_hazard_examiner verif object
//
// Parameters:
//  phase - stores the current phase 
//-----------------------------------------------------------------------------
function void inst_history::build_phase(uvm_phase phase);
  super.build_phase(phase);
  m_raw_hazard_examiner = raw_hazard_examiner::type_id::create("m_raw_hazard_examiner",this);
endfunction: build_phase

//-----------------------------------------------------------------------------
// Function: commit_inst
// Commit the instruction in the queue and analyzes the new instruction
//
// Parameters: 
//  inst - inst32 instruction
//-----------------------------------------------------------------------------
function void inst_history::commit_inst(inst32 inst);
  if (m_inst_fifo.size() == DEPTH) begin
    m_inst_fifo.delete(DEPTH-1);
  end
  m_inst_fifo.push_front(inst);
  analyze_new_inst();
endfunction: commit_inst

//-----------------------------------------------------------------------------
// Function: analyze_new_inst
// Analyzes the new instruction
//-----------------------------------------------------------------------------
function void inst_history::analyze_new_inst();
  inst32 new_inst = peek_newest();

  for( int i=1; i < m_inst_fifo.size(); i++ ) begin
    inst32 older_inst = m_inst_fifo[i];
    m_raw_hazard_examiner.examine(new_inst, older_inst);
  end
endfunction: analyze_new_inst

//-----------------------------------------------------------------------------
// Function: peek_newest
// Peek the newest instruction from the queue
//
// Returns:
//  The newest instruction inst32 verif object
//-----------------------------------------------------------------------------
function inst32 inst_history::peek_newest();
  return peek_age(0);
endfunction: peek_newest

//-----------------------------------------------------------------------------
// Function: peek_oldest
// Peek the oldest instruction from the queue
//
// Returns:
//  The oldest instruction inst32 verif object
//-----------------------------------------------------------------------------
function inst32 inst_history::peek_oldest();
  return m_inst_fifo[$];
endfunction: peek_oldest

//-----------------------------------------------------------------------------
// Function: peek_age
// Get the instruction from the queue based on its age
// 
// Parameters:
//  age - Its 0 to DEPTH-1
//
// Returns:
//  The inst32 instruction from the queue
//-----------------------------------------------------------------------------
function inst32 inst_history::peek_age(int age);
  assert(m_inst_fifo.size()>age);
  return m_inst_fifo[age];    
endfunction: peek_age
  
//-----------------------------------------------------------------------------
// Function: size
// Get the size of the fifo
//
// Returns:
//  The total fifo size
//-----------------------------------------------------------------------------
function int inst_history::size();
  return m_inst_fifo.size();
endfunction: size

`endif
