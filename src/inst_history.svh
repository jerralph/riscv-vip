
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

`ifndef _INST_HISTORY_INCLUDED_
`define _INST_HISTORY_INCLUDED_

//Read after write (RAW) data hazard. Latest instruction
//gets its rs1 or rs2 from earlier instruction's rd
//rather than from the regfile value.  This is use for coverage
class raw_hazard_examiner;
  typedef enum {RS1_ONLY, RS2_ONLY, RS1AND2, NONE} raw_rs_case_enum_t;
  static const int unsigned MAX_CYCLES_APART_OF_INTEREST = 3;
  int unsigned m_cycles_apart;
  inst32 m_rd_inst;  //younger
  inst32 m_wr_inst;  //older
  raw_rs_case_enum_t raw_rs_case = NONE;  //raw register source case
  
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
//for now, keep it simple. 
//    wr_inst_cp : coverpoint m_rd_inst.get_inst_enum(){
//    }

  endgroup
  
  function new();
    raw_cg = new();
  endfunction
  
  virtual function void examine( inst32 curr_inst, inst32 older_inst );

    m_cycles_apart = curr_inst.cycle - older_inst.cycle; 

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
        {1'b1,1'b0} : begin
          raw_rs_case = RS1_ONLY;
        end
        {1'b0,1'b1} : begin
          raw_rs_case = RS2_ONLY;
        end
        {1'b1,1'b1} : begin
          raw_rs_case = RS1AND2;
        end
        default : begin
          raw_rs_case = NONE;
        end
      endcase
      post_examine(); 
    end
  endfunction  

  //Override post_examine to gate based on passing checking before cov, 
  //for no check keep it as is.  Beware of moving the sample out of this
  //method.  Sample is be called multiple times per cycle as the current 
  //instruction is scanned against historical instructions.
  virtual function post_examine();
      raw_cg.sample();  
  endfunction


  virtual function real get_cross_cov();
    return raw_cg.inst_x_rs_case_x_cyc_apart.get_coverage();
  endfunction
  
endclass
  


//This is a delayed version of the pipeline.  Essentially this 
//is a queue of completed instructions...
class inst_history#(int DEPTH = 5);  
  raw_hazard_examiner m_raw_hazard_examiner = new();
  protected inst32 m_inst_fifo [$:DEPTH-1] = {};  //oldest is at higher index
  
  
  virtual function void commit_inst(inst32 inst);
    if (m_inst_fifo.size() == DEPTH) begin
      m_inst_fifo.delete(DEPTH-1);
    end
    m_inst_fifo.push_front(inst);
    analyze_new_inst();
  endfunction 
  
  
  virtual protected function void analyze_new_inst();
    inst32 new_inst = peek_newest();

    for( int i=1; i < m_inst_fifo.size(); i++ ) begin
      inst32 older_inst = m_inst_fifo[i];
      m_raw_hazard_examiner.examine(new_inst, older_inst);
    end
    
  endfunction

  virtual function inst32 peek_newest();
    return peek_age(0);
  endfunction
  
  virtual function inst32 peek_oldest();
    return m_inst_fifo[$];
  endfunction
  
  //Age is 0 to DEPTH-1
  virtual function inst32 peek_age(int age);
    assert(m_inst_fifo.size()>age);
    return m_inst_fifo[age];    
  endfunction
    
  virtual function int size();
    return m_inst_fifo.size();
  endfunction
  
endclass 
 
`endif