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

`ifndef _DECODER_INCLUDE_
`define _DECODER_INCLUDE_

//-----------------------------------------------------------------------------
// Class: decoder
// Decode bits into a verif object model
//-----------------------------------------------------------------------------
class decoder extends uvm_component;
  `uvm_component_utils(decoder)

  // Variable: trans_export_inst32 
  // Bi-directional implementation transport 
  uvm_transport_imp#( .REQ( bit[31:0] ),
                       .RSP( inst32 ),
                       .IMP( decoder ) ) trans_export_inst32;  
                       
  // TODO: 
  // For inst16 and other need to create separate trans_export

  // Variable: m_parcels
  // Dynamic array for storing the parcels 
  bit[15:0] m_parcels[];

  // Variable: m_parcel_index
  // Stores the current index of the m_parcels array
  int unsigned m_parcel_index;

  // Variable: m_num_parcels
  // Stores the number of parcels required 
  // for the instruction length
  int unsigned m_num_parcels;

  // Variable: m_strict
  // If '1' then unsupported features are exited
  // using fatal else if '0' do nothing
  static bit m_strict = 0;

  // Variable: m_enable_c_type
  // Enable [C]ompressed instruction set 
  static bit m_enable_c_type = 0;  
 
  //-------------------------------------------------------
  // Externally defined tasks and functions
  //-------------------------------------------------------
  extern function new(string name, uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern static function int unsigned calc_num_parcels(bit[15:0] parcel0);
  extern virtual function int unsigned decode_len(bit[15:0] parcel0);
  extern virtual function bit need_next_parcel();
  extern virtual function void set_next_parcel(bit[15:0] parcel);
  extern virtual function inst16 decode_inst16(bit[15:0] inst_arg);
  extern virtual function inst32 decode_inst32(bit[31:0] inst_arg);
  extern virtual task transport(input bit[31:0] curr_inst, output inst32 inst_t);
  extern virtual function bit nb_transport(input bit[31:0] curr_inst, output inst32 inst_t);

endclass: decoder

//-----------------------------------------------------------------------------
// Constructor: new
// Initializes the decoder class object
//
// Parameters:
//  name - instance name of the decoder
//  parent - parent under which this component is created
//-----------------------------------------------------------------------------
function decoder::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction: new

//-----------------------------------------------------------------------------
// Function: build_phase
// Creating the transport implementation port
//
// Parameters:
//  phase - stores the current phase 
//-----------------------------------------------------------------------------
function void decoder::build_phase(uvm_phase phase);
  super.build_phase(phase);
  trans_export_inst32 = new( "trans_export_inst32", this );
endfunction: build_phase

//-----------------------------------------------------------------------------
// Function: calc_num_parcels
// Calculates the number of parcels required based on the instruction length encoding 
//
// Parameters: 
//  parcel0 - The 16bit instruction (parcel)
//
// Returns:
//  Number of parcels 
//-----------------------------------------------------------------------------
function int unsigned decoder::calc_num_parcels(bit[15:0] parcel0);
  // indicates a 16bit instruction
  if (parcel0[1:0] != 2'b11) begin
    return 1;
  // indicates a 32bit instruction 
  end 
  else if (parcel0[4:2] != 3'b111) begin
    return 2;
  end 
  else if (m_strict) begin
    // The `uvm_fatal cannot be used in satic method because 
    // uvm_report_fatal is a non-static method. Hence, using $fatal instead.
    //`uvm_fatal(get_type_name(),$sformatf("UNUSPPORTED -- FUTURE, %016h",parcel0))
    $fatal("decoder - UNUSPPORTED -- FUTURE, %016h",parcel0);
  end
endfunction: calc_num_parcels 

//-----------------------------------------------------------------------------
// Function: decode_len
// Decode how many parcels need to be fetched from the instruction length encoding
//
// Parameters: 
//  parcel0 - The 16bit instruction (parcel)
//
// Returns:
//  The number of remaining parcels that need to be fetched 
//-----------------------------------------------------------------------------
function int unsigned decoder::decode_len(bit[15:0] parcel0);
  m_num_parcels = decoder::calc_num_parcels(parcel0);
  m_parcels= new[m_num_parcels];
  m_parcel_index = 0;
  m_parcels[m_parcel_index++] = parcel0;
  return m_num_parcels-1;
endfunction: decode_len

//-----------------------------------------------------------------------------
// Function: need_next_parcel
// Checks to see if more parcels are t be fetched
// 
// Returns: 
//  '1' if more parcels are to be fetched
//-----------------------------------------------------------------------------
function bit decoder::need_next_parcel();
  return (m_parcel_index < m_num_parcels);
endfunction: need_next_parcel 

//-----------------------------------------------------------------------------
// Function: set_next_parcel
// Stores the next parcel into the m_parcels array
//
// Parameters:
//  parcel - The 16bit instruction
//-----------------------------------------------------------------------------
function void decoder::set_next_parcel(bit[15:0] parcel);
  m_parcels[m_parcel_index++] = parcel;
endfunction: set_next_parcel 

//-----------------------------------------------------------------------------
// Function: decode_inst16
// Decodes a 16bit instruction
//
// Parameters:
//  inst_arg - a 16bit instruction
//
// Returns:
//  A 16bit instruction verif object
//-----------------------------------------------------------------------------
function inst16 decoder::decode_inst16(bit[15:0] inst_arg);
  int more = decode_len(inst_arg);
  inst16 inst_item;

  //All zeros isn't an instruction, return null
  if (inst_arg == 0) begin 
    return null;
  end

  if (more != 0) begin
    if (m_strict) begin
      `uvm_fatal(get_type_name(),$sformatf("undecodable inst"));
    end else begin
      return null;
    end
  end

  begin
    // TODO:
    inst16_ciformat  ci = new();
    inst_item = ci;
  end
  return inst_item;  //Null now..

endfunction: decode_inst16 

//-----------------------------------------------------------------------------
// Function: decode_inst32
// Decodes a 32bit instruction
//
// Parameters:
//  inst_arg - a 32bit instruction
//
// Returns:
//  A 32bit instruction verif object
//-----------------------------------------------------------------------------
function inst32 decoder::decode_inst32(bit[31:0] inst_arg);

  // Stores the remaining parcels
  int  remaining_parcels;
  // Stores the 32bit instruction
  inst_t inst;
  // Map of major opcode for RiscV General (RVG)
  rvg_major_opcode_t rvg_major_opcode;
  // Instruction format
  rvg_format_t rvg_format;
  // Instruction object
  inst32 inst_item;

  //All zeros or F's isn't an instruction
  if (inst_arg == 0 || inst_arg == 'hffffffff) return null;

  //decode_len sets a bunch of m_ fields, remaining_parcels != 0 if
  //there are remaining_parcels parcels to the instruction
  remaining_parcels = decode_len(inst_arg[15:0]);

  if (remaining_parcels != 1) begin
    // this is not a 32 bit instruction...
    if (m_strict) begin
      `uvm_fatal(get_type_name(),$sformatf("undecodable inst %h",inst_arg));
    end else begin
      return null;
    end
  end
 
  // Get more parcels if required 
  while(need_next_parcel()) begin
    // TODO: will need an update for >32 bit
    set_next_parcel(inst_arg[31:16]);   
  end

  // For a 32bit instruction there needs to be 2 parcels
  if (m_num_parcels != 2) begin
    if (m_strict) begin
      `uvm_fatal(get_type_name(),$sformatf("num_parcels != 2"));
    end else begin
      return null;
    end
  end

  inst = {m_parcels[1],m_parcels[0]};
  rvg_major_opcode = rvg_major_opcode_t'(inst[6:0]);
  rvg_format = rvg_format_by_major[rvg_major_opcode];

  if (rvg_format == UNKNOWN) begin 
     return null;
  end

  // Based on the instruction format the corresponding
  // instruction verif object is created
  case (rvg_format)
    R: begin
      //inst32_rformat r = inst32_rformat::type_id::create("inst32_rformat",this);
      //r.set_inst_value(inst);
      inst32_rformat r = new("inst32_rformat",inst);
      inst_item = r;
    end
    I: begin
      //inst32_iformat i = inst32_iformat::type_id::create("inst32_iformat",this);
      //i.set_inst_value(inst);
      inst32_iformat i = new("inst32_iformat",inst);
      inst_item = i;
    end
    S: begin
      //inst32_sformat s = inst32_sformat::type_id::create("inst32_sformat",this);
      //s.set_inst_value(inst);
      inst32_sformat s = new("inst32_sformat",inst);
      inst_item = s;
    end
    B: begin
      //inst32_bformat b = inst32_bformat::type_id::create("inst32_bformat",this);
      //b.set_inst_value(inst);
      inst32_bformat b = new("inst32_bformat",inst);
      inst_item = b;
    end
    U: begin
      //inst32_uformat u = inst32_uformat::type_id::create("inst32_uformat",this);
      //u.set_inst_value(inst);
      inst32_uformat u = new("inst32_uformat",inst);
      inst_item = u;
    end
    J: begin
      //inst32_jformat j = inst32_jformat::type_id::create("inst32_jformat",this);
      //j.set_inst_value(inst);
      inst32_jformat j = new("inst32_jformat",inst);
      inst_item = j;
    end

  endcase

  return inst_item;

endfunction: decode_inst32

//-----------------------------------------------------------------------------
// Task: transport
// Its a bidirectional transport implementation
// Every transport Task must have a nb_transport function implementation
//
// Parameters: 
//  curr_inst - input, current instruction
//  inst_t    - output, inst32 verif object
//-----------------------------------------------------------------------------
task decoder::transport(input bit[31:0] curr_inst, output inst32 inst_t);
  `uvm_info(get_type_name(),$sformatf("Inside the transport task"),UVM_HIGH);

  assert( nb_transport(curr_inst, inst_t) );
endtask: transport

//-----------------------------------------------------------------------------
// Function: nb_transport
// Its a non-blocking transport implementation
//
// Parameters: 
//  curr_inst - input, current instruction
//  inst_t    - output, inst32 verif object
//
// Returns:
//  '1' if inst32 verif object is successfully created
//-----------------------------------------------------------------------------
function bit decoder::nb_transport(input bit[31:0] curr_inst, output inst32 inst_t);
  `uvm_info(get_type_name(),$sformatf("Inside the nb_transport function"),UVM_HIGH);

  // Call the function
  inst_t = decode_inst32(curr_inst);
  `uvm_info(get_type_name(),$sformatf("After the decode_inst32 - %s", inst_t.to_string()),UVM_NONE);
 
  if(inst_t == null) return 0;
  else               return 1;

endfunction: nb_transport  

`endif
