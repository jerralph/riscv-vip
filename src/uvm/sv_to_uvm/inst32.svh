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

`ifndef _INST32_INCLUDE_
`define _INST32_INCLUDE_ 

//-----------------------------------------------------------------------------
// Class: inst32
// Base class for representing 32 bit instructions in OOP
//-----------------------------------------------------------------------------
virtual class inst32 extends uvm_sequence_item;
  `uvm_object_utils(inst32)

  // Variable: m_cycle
  // The clock cycle associated with retirement of the instruction
  int unsigned m_cycle;  

  // Variable: rv_addr_t m_addr
  // 32bit address value
  rv_addr_t m_addr;

  // Variable: inst_t m_inst
  // Stores the 32bit instruction value
  rand inst_t  m_inst;

  // Variable: rvg_format_t m_rvg_format 
  // Stores the RiscV General format for the instruction
  rvg_format_t m_rvg_format  = UNKNOWN;

  // Variable: inst_enum_t m_inst_enum
  // Stores the enumerated value of the instruction
  protected inst_enum_t  m_inst_enum;

  // Variable: m_decode_cycle
  // The value of the cycle CSR when instruction decoded
  bit [63:0] m_decode_cycle;  
  
  // Variable: xlen_t m_rs1_val 
  // Stores the value of register pointed to by the rs1 fields.
  // It is relevant for instructions that have rs1
  protected xlen_t       m_rs1_val = 'x;

  // Variable: xlen_t m_rs1_val 
  // Stores the value of register pointed to by the rs2 fields.
  // It is relevant for instructions that have rs2
  protected xlen_t       m_rs2_val = 'x;
  
  // Variable: m_rs1_val_set
  // A value '1' indicates the rs1 value has been set
  bit m_rs1_val_set = 0;

  // Variable: m_rs2_val_set
  // A value '1' indicates the rs2 value has been set
  bit m_rs2_val_set = 0;

  // Variable: m_inst_enum_set
  // A value '1' indicates the enum value has been set
  bit m_inst_enum_set = 0;

  //-------------------------------------------------------
  // Externally defined tasks and functions
  //-------------------------------------------------------
  extern function new(string name = "inst32", inst_t inst=0);
  //extern function new(string name = "inst32");
  //extern virtual function void set_inst_value(inst_t inst);
  extern virtual function opcode_t get_opcode();
  extern virtual function rvg_major_opcode_t get_rvg_major_opcode();
  extern virtual function bit is_i_format();
  extern virtual function bit is_u_format();
  extern virtual function bit is_j_format();
  extern virtual function bit is_b_format();
  extern virtual function bit is_s_format();
  extern virtual function bit is_r_format();
  extern virtual function bit has_rd();
  extern virtual function reg_id_t get_rd();
  extern virtual function bit has_rs1();
  extern virtual function reg_id_t get_rs1();
  extern virtual function void set_rs1_val(xlen_t val);
  extern virtual function bit has_rs1_val_set();
  extern virtual function xlen_t get_rs1_val();
  extern virtual function bit has_rs2();
  extern virtual function reg_id_t get_rs2();
  extern virtual function void set_rs2_val(xlen_t val);
  extern virtual function bit has_rs2_val_set();
  extern virtual function xlen_t get_rs2_val();
  extern virtual function bit has_imm();
  extern static function string format_hex_string(bit[31:0] bits);
  extern virtual function inst_enum_t get_inst_enum();
  extern virtual function string get_name_string();
  extern protected function string string_base();
  extern virtual function string to_string();
  extern virtual function void do_print(uvm_printer printer);

  pure virtual function void sample_cov();
  extern virtual protected function void sample_from_subclass();
  pure virtual function string get_imm_string();
  
  //-------------------------------------------------------
  // Covergroup: rd_bins_cg 
  // Creates the coverpoints and cross coverpoints
  //-------------------------------------------------------
  covergroup rd_bins_cg();
    rd_inst_cp : coverpoint m_inst_enum {
      ignore_bins ignore_has_no_rd = {`INSTS_W_NO_RD_LIST};
    }
    rd_bins_cp : coverpoint get_rd() iff ( has_rd() ) {
      bins zero = {X0};
      bins middle = {
        X1,  X2,  X3,  X4,  X5,  X6,  X7,  X8,  X9,  X10,
        X11, X12, X13, X14, X15, X16, X17, X18, X19, X20,
        X21, X22, X23, X24, X25, X26, X27, X28, X29, X30
      };
      bins thirty1 = {X31};
    }
    rd_inst_x_bins : cross rd_inst_cp, rd_bins_cp;            
  endgroup // rd_bins_cg

  //-------------------------------------------------------
  // Covergroup: rs1_bins_cg 
  // Creates the coverpoints and cross coverpoints
  //-------------------------------------------------------
  covergroup rs1_bins_cg();
    rs1_inst_cp : coverpoint m_inst_enum {
      ignore_bins ignore_has_no_rs1 = {`INSTS_WITH_NO_RS_LIST};
    }
    rs1_bins_cp : coverpoint get_rs1() iff ( has_rs1() ){
      bins zero = {X0};
      bins middle = {
        X1,  X2,  X3,  X4,  X5,  X6,  X7,  X8,  X9,  X10,
        X11, X12, X13, X14, X15, X16, X17, X18, X19, X20,
        X21, X22, X23, X24, X25, X26, X27, X28, X29, X30
      };
      bins thirty1 = {X31};
    }
    rs1_inst_x_bins : cross rs1_inst_cp, rs1_bins_cp;            
  endgroup // rs1_bins_cg

  //-------------------------------------------------------
  // Covergroup: rs2_bins_cg 
  // Creates the coverpoints and cross coverpoints
  //-------------------------------------------------------
  covergroup rs2_bins_cg();
    rs2_inst_cp : coverpoint m_inst_enum {
      bins ignore_has_no_rs2 = {`INSTS_W_RS2_LIST};
    }
    rs2_bins_cp : coverpoint get_rs2() iff ( has_rs2() ){
      bins zero = {X0};
      bins middle = {
        X1,  X2,  X3,  X4,  X5,  X6,  X7,  X8,  X9,  X10,
        X11, X12, X13, X14, X15, X16, X17, X18, X19, X20,
        X21, X22, X23, X24, X25, X26, X27, X28, X29, X30
      };
      bins thirty1 = {X31};
    }
    rs2_inst_x_bins : cross rs2_inst_cp, rs2_bins_cp;            
  endgroup // rs2_bins_cg
  
  //-------------------------------------------------------
  // Covergroup: inst_same_regs_cg
  // Creates the coverpoints and cross coverpoints
  //-------------------------------------------------------
  covergroup inst_same_regs_cg ();
    inst_cp : coverpoint m_inst_enum;
    same_rd_rs1_cp : coverpoint 1 iff(
      has_rd()  && 
      has_rs1() && 
      (get_rd() == get_rs1())  &&
      (!has_rs2() || has_rs2() && get_rs2() != get_rs1()) &&
      (get_rd()  != X0) ){
        option.weight =0; //only count the cross
      }
    same_rd_rs2_cp : coverpoint 1 iff(
      has_rd()  && 
      has_rs2() && 
      (get_rd() != get_rs1()) &&
      (get_rd() == get_rs2()) &&
      (get_rd()  != X0) ){
        option.weight =0; //only count the cross
      }
    same_rd_rs1_rs2_cp : coverpoint 1 iff(
      has_rd()  && 
      has_rs1() && 
      has_rs2() && 
      (get_rd() == get_rs1()) &&
      (get_rd() == get_rs2()) &&
      (get_rd()  != X0)){
        option.weight =0; //only count the cross
      }
    inst_x_same_rd_rs1 : cross inst_cp, same_rd_rs1_cp {
      ignore_bins ignore_has_no_rs_rd_insts = inst_x_same_rd_rs1 with 
      (inst_cp inside {`INSTS_WITH_NO_RS_LIST, `INSTS_W_NO_RD_LIST} );     
    }
    inst_x_same_rd_rs2 : cross inst_cp, same_rd_rs2_cp {
      ignore_bins ignore_has_no_rs2_rd_insts = inst_x_same_rd_rs2 with 
      (inst_cp inside {`INSTS_W_NO_RD_LIST} || !(inst_cp inside {`INSTS_W_RS2_LIST}) );     
    }    
    inst_x_same_rd_rs1_rs2 : cross inst_cp, same_rd_rs1_rs2_cp {
      ignore_bins ignore_has_no_rs1_rs2_rd_insts = inst_x_same_rd_rs1_rs2 with
      ( !(inst_cp inside {`INSTS_W_RD_RS1_RS2_LIST}) );
    }

  endgroup // inst_same_regs_cg 

endclass: inst32 

//-----------------------------------------------------------------------------
// Constructor: new
// Initializes the inst32 class object
//
// Parameters:
//  name - instance name of the inst32
//  inst - 32bit instruction value
//-----------------------------------------------------------------------------
// Note: every argument in new must have a default value
function inst32::new(string name = "inst32", inst_t inst=0);
  super.new(name);
  m_inst = inst;
  // Creating the covergroups
  inst_same_regs_cg = new();
  rd_bins_cg = new();
  rs1_bins_cg = new();
  rs2_bins_cg = new();
endfunction: new

////-----------------------------------------------------------------------------
//// Constructor: new
//// Initializes the inst32 class object
////
//// Parameters:
////  name - instance name of the inst32
////-----------------------------------------------------------------------------
//function inst32::new(string name = "inst32");
//  super.new(name);
//  // Create the covergroup
//  inst_cg = new();
//endfunction: new
//
////-----------------------------------------------------------------------------
//// Function: set_inst_value
//// Sets the instruction value 
////
//// Parameters:
////  inst - 32bit instruction value
////-----------------------------------------------------------------------------
//function void inst32::set_inst_value(inst_t inst);
//  m_inst = inst;
//endfunction: set_inst_value

//-----------------------------------------------------------------------------
// Function: get_opcode
// Gets the opcode bits of the instruction
//
// Returns: 
//  The opcode bits 
//-----------------------------------------------------------------------------
function opcode_t inst32::get_opcode();
  return m_inst.i_inst.op;      
endfunction: get_opcode 

//-----------------------------------------------------------------------------
// Function: get_rvg_major_opcode
// Gets the map of major opcode for RiscV General (RVG)
//
// Returns: 
//  An enumerated type value of major opcode
//-----------------------------------------------------------------------------
function rvg_major_opcode_t inst32::get_rvg_major_opcode();
  return rvg_major_opcode_t'(get_opcode());    
endfunction: get_rvg_major_opcode

//-----------------------------------------------------------------------------
// Function: is_i_format
// Checks if the instruction is of I format
//
// Returns: 
//  '1' for instruction of I format
//-----------------------------------------------------------------------------
function bit inst32::is_i_format();
  return (m_rvg_format == I);    
endfunction: is_i_format

//-----------------------------------------------------------------------------
// Function: is_u_format
// Checks if the instruction is of U format
//
// Returns: 
//  '1' for instruction of U format
//-----------------------------------------------------------------------------
function bit inst32::is_u_format();
  return (m_rvg_format == U);    
endfunction: is_u_format

//-----------------------------------------------------------------------------
// Function: is_j_format 
// Checks if the instruction is of J format
//
// Returns: 
//  '1' for instruction of J format
//-----------------------------------------------------------------------------
function bit inst32::is_j_format();
  return (m_rvg_format == J);    
endfunction: is_j_format

//-----------------------------------------------------------------------------
// Function: is_b_format 
// Checks if the instruction is of B format
//
// Returns: 
//  '1' for instruction of B format
//-----------------------------------------------------------------------------
function bit inst32::is_b_format();
  return (m_rvg_format == B);    
endfunction: is_b_format

//-----------------------------------------------------------------------------
// Function: is_s_format 
// Checks if the instruction is of S format
//
// Returns: 
//  '1' for instruction of S format
//-----------------------------------------------------------------------------
function bit inst32::is_s_format();
  return (m_rvg_format == S);    
endfunction: is_s_format

//-----------------------------------------------------------------------------
// Function: is_r_format 
// Checks if the instruction is of R format
//
// Returns: 
//  '1' for instruction of R format
//-----------------------------------------------------------------------------
function bit inst32::is_r_format();
  return (m_rvg_format == R);    
endfunction: is_r_format   
 
//-----------------------------------------------------------------------------
// Function: has_rd 
// Checks if the instruction has destination register
//
// Returns: 
//  '1' if instruction has rd register
//-----------------------------------------------------------------------------
function bit inst32::has_rd();
  return (!(m_rvg_format inside {B,S}));      
endfunction: has_rd

//-----------------------------------------------------------------------------
// Function: get_rd 
// Gets the destination register of the instruction
//
// Returns: 
//  The register id of the rd register
//-----------------------------------------------------------------------------
function reg_id_t inst32::get_rd();
  assert(has_rd()) 
  else `uvm_fatal(get_type_name(),$sformatf("Doesn't have rd register\n"));

  return reg_id_t'(m_inst.i_inst.rd);
endfunction: get_rd

//-----------------------------------------------------------------------------
// Function: has_rs1 
// Checks if the instruction has source register1
//
// Returns: 
//  '1' if instruction has rs1 register
//-----------------------------------------------------------------------------
function bit inst32::has_rs1();
  return ( !(get_inst_enum() inside {`INSTS_WITH_NO_RS_LIST}) );
endfunction: has_rs1

//-----------------------------------------------------------------------------
// Function: get_rs1 
// Gets the source register1 of the instruction 
//
// Returns: 
//  The register id of the rs1 register
//-----------------------------------------------------------------------------
function reg_id_t inst32::get_rs1();
  assert(has_rs1()) 
  else `uvm_fatal(get_type_name(),$sformatf("Doesn't have rs1 register\n"));

  return reg_id_t'(m_inst.b_inst.rs1);      
endfunction: get_rs1    

//-----------------------------------------------------------------------------
// Function: set_rs1_val 
// Set the value of the rs1 register referenced by the instruction
//
// Parameters: 
//  val - Value to be stored into the rs1 register
//-----------------------------------------------------------------------------
function void inst32::set_rs1_val(xlen_t val);
  assert(has_rs1()) 
  else `uvm_fatal(get_type_name(),$sformatf(to_string()));

  m_rs1_val_set = 1;
  m_rs1_val = val;    
endfunction: set_rs1_val   

//-----------------------------------------------------------------------------
// Function: has_rs1_val_set
// Checks if the rs1 value is set for the instruction
//
// Returns: 
//  '1' if rs1 value is set in the instruction
//-----------------------------------------------------------------------------
function bit inst32::has_rs1_val_set();
  return m_rs1_val_set;
endfunction: has_rs1_val_set

//-----------------------------------------------------------------------------
// Function: get_rs1_val
// Get the value of the x[rs1] as referenced by the rs1 field of the instruction
//
// Returns: 
//  The value of the rs1 register
//-----------------------------------------------------------------------------
function xlen_t inst32::get_rs1_val();
  assert(has_rs1() && has_rs1_val_set() ) 
  else `uvm_fatal(get_type_name(),$sformatf(to_string()));

  return m_rs1_val;  
endfunction: get_rs1_val   
    
//-----------------------------------------------------------------------------
// Function: has_rs2 
// Checks if the instruction has source register2
//
// Returns: 
//  '1' if instruction has rs2 register
//-----------------------------------------------------------------------------
function bit inst32::has_rs2();
  return (m_rvg_format inside {B,S,R});
endfunction: has_rs2

//-----------------------------------------------------------------------------
// Function: get_rs2 
// Gets the source register2 of the instruction 
//
// Returns: 
//  The register id of the rs2 register
//-----------------------------------------------------------------------------
function reg_id_t inst32::get_rs2();
  assert(has_rs2()) 
  else `uvm_fatal(get_type_name(),$sformatf("Doesn't have rs2 register\n"));

  return reg_id_t'(m_inst.b_inst.rs2);
endfunction: get_rs2    

//-----------------------------------------------------------------------------
// Function: set_rs2_val 
// Set the value of the rs2 register referenced by the instruction
// Beware using this with data hazards.  For a 2 stage pipeline with this
// set at retirement of the instruction the value from the regfile should
// be good.
//
// Parameters: 
//  val - Value to be stored into the rs2 register
//-----------------------------------------------------------------------------
function void inst32::set_rs2_val(xlen_t val);
  assert(has_rs2())
  else `uvm_fatal(get_type_name(),$sformatf(to_string()));

  m_rs2_val_set = 1;
  m_rs2_val = val;    
endfunction: set_rs2_val   

//-----------------------------------------------------------------------------
// Function: has_rs2_val_set
// Checks if the rs2 value is set for the instruction
//
// Returns: 
//  '1' if rs2 value is set in the instruction
//-----------------------------------------------------------------------------
function bit inst32::has_rs2_val_set();
  return m_rs2_val_set;
endfunction: has_rs2_val_set

//-----------------------------------------------------------------------------
// Function: get_rs2_val
// Get the value of the x[rs2] as referenced by the rs1 field of the instruction
// This is the value of x[rs2] from the reg file at decode stage and may be 
// different than the x[rs2] in the case of data pipeline hazards - beware! 
//
// Returns: 
//  The value of the rs2 register
//-----------------------------------------------------------------------------
function xlen_t inst32::get_rs2_val();
  assert(has_rs2() && has_rs2_val_set() )
  else `uvm_fatal(get_type_name(),$sformatf(to_string()));

  return m_rs2_val;  
endfunction   

//-----------------------------------------------------------------------------
// Function: has_imm
// Checks to see if the instruction has immediate value
// 
// Returns: 
//  '1' if the instruction has immediate value
//-----------------------------------------------------------------------------
function bit inst32::has_imm();
  return (m_rvg_format != R);      
endfunction: has_imm

//-----------------------------------------------------------------------------
// Function: format_hex_string
// Converts the data into corresponding string 
//
// Parameters: 
//  bits - 32bit value to be converted
//
// Returns:
//  String corresponding to the input data
//-----------------------------------------------------------------------------
function string inst32::format_hex_string(bit[31:0] bits);
  return $psprintf("0x%0H",bits);
endfunction: format_hex_string
                                            
//-----------------------------------------------------------------------------
// Function: get_inst_enum
// Get the RV32I unique enum for this instruction
// 
// Returns:
//  The enum value for the instruction
//-----------------------------------------------------------------------------
function inst_enum_t inst32::get_inst_enum();
  
  if (!m_inst_enum_set) begin
    inst_enum_t inst = UNKNOWN_INST;

    case (m_rvg_format)
      R: begin
        r_inst_t r = m_inst.r_inst;
        inst  = r_inst_by_funct7funct3major[{r.funct7,r.funct3,get_opcode()}];
        if (inst == UNKNOWN_INST ) begin
          `uvm_info(get_type_name(),$sformatf("UNKNOWN_INST {r.funct7,r.funct3,get_opcode()} = {%7b,%3b,%7b}", 
                                                  r.funct7,r.funct3,get_opcode()),UVM_LOW);
        end
      end
      I,S,B: begin
        //$display("ISB Decode 0b%b m_inst.b_inst.funct3 = 0b%b",m_inst, m_inst.b_inst.funct3);
        inst  = isb_inst_by_funct3major[{m_inst.b_inst.funct3,get_opcode()}];

        //Deal with some special cases for I insts, where the immediate field
        //decides on the instruction
        case (inst)
          SRLI,SRAI: begin
            i_shamt_inst_t shamt_inst = i_shamt_inst_t'(m_inst.i_inst);          
            case (shamt_inst.imm_code)
              SRLI_IMM_31_25 : inst = SRLI;
              SRAI_IMM_31_25 : inst = SRAI;
              default : inst = UNKNOWN_INST;
            endcase // case (shamt_inst.imm_code)
          end
          ECALL, EBREAK: begin
            case (m_inst.i_inst.imm)
              0: inst = ECALL;
              1: inst = EBREAK;
              default : inst = UNKNOWN_INST;
            endcase // case(m_inst.i_inst.imm)
          end
        endcase // case(inst)
      end
      U,J: begin
        inst  = uj_inst_by_major[get_rvg_major_opcode()];
      end
    endcase // case (m_rvg_format)

    //set the member variable 
    m_inst_enum = inst;
    m_inst_enum_set = 1;
  end

  return m_inst_enum;    
  
endfunction: get_inst_enum    
    
//-----------------------------------------------------------------------------
// Function: get_name_string
// Get the name of the corresponding instruction enum value
//
// Returns:
//  String corresponding to the instruction enum value
//-----------------------------------------------------------------------------
function string inst32::get_name_string();
  inst_enum_t iet = get_inst_enum();    
  return iet.name();
endfunction: get_name_string

//-----------------------------------------------------------------------------
// Function: string_base
// Gives the base - m_cycle, inst value and rvg format of instruction
//
// Returns:
//  String equivalent of the base
//-----------------------------------------------------------------------------
function string inst32::string_base();
  string rvg_format_str;
  rvg_format_str = m_rvg_format.name();
  return $psprintf("%0d    %08H     %s ", m_cycle, m_inst, rvg_format_str);
endfunction: string_base

//-----------------------------------------------------------------------------
// Function: to_string
// Converts the entire instructions into an equivalent string
//
// Returns:
//  String equivalent of the instruction 
//-----------------------------------------------------------------------------
function string inst32::to_string();
  //string str = $psprintf("%032b %s ", m_inst, rvg_format_str);
  string str;
  string rs_vals ="";

  reg_id_t rd, rs1, rs2;
  xlen_t rs1_val, rs2_val;

  //common string chunk used by specialized overrides 
  str = string_base();
  
  str={str,"  ",get_name_string()," "};
  if (has_rd())  begin
    rd = get_rd();      
    str={str, rd.name() ,", "};
  end
  if (has_rs1()) begin
    rs1 = get_rs1();

    str={str, rs1.name(),", "};
    if (has_rs1_val_set()) begin
      //Check that rs val is set first since not all deployments will white box monitor the regfile values
      rs_vals = $psprintf(" |  rf.%s = %0d",rs1.name(),m_rs1_val);
    end
  end
  if (has_rs2()) begin
    rs2 = get_rs2();      
    str={str, rs2.name()," "};
    if (has_rs2_val_set()) begin
      //Check that rs val is set first since not all deployments will white box monitor the regfile values
      rs_vals = $psprintf("%s, rf.%s = %0d",rs_vals, rs2.name(),m_rs2_val);
    end
  end
  if (has_imm()) begin
    str={str, get_imm_string()};
  end

  str = $psprintf("%-40s %s", str,rs_vals); 
  // MSHA: str = {str, rs_vals};
  
  return str;      
endfunction: to_string
  
//-----------------------------------------------------------------------------
// Function: do_print
// This function implements the do_print. This will
// be invoked when print() function is called.
//
// Parameters:
//  printer - uvm_printer object
//-----------------------------------------------------------------------------
function void inst32::do_print(uvm_printer printer);
  printer.print_int("address",m_addr,$bits(m_addr));
  printer.print_string("instruction",to_string());    
endfunction: do_print

//-----------------------------------------------------------------------------
// Function: sample_from_subclass 
// This function facilitates the sampling of the covergroups.
// sample_from_subclass() is called from abstract sample_cov(),
// defined in the specific class for b,i,j,r,s,u formats
//-----------------------------------------------------------------------------
function void inst32::sample_from_subclass();
  inst_same_regs_cg.sample();
  rd_bins_cg.sample();
  rs1_bins_cg.sample();
  rs2_bins_cg.sample();
endfunction: sample_from_subclass

`endif 
