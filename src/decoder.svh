
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


`ifndef _DECODER_INCLUDE_
`define _DECODER_INCLUDE_


//Decode bits into a verif object model
class decoder;

  bit[15:0]            	m_parcels[];
  int       unsigned 	m_parcel_index;
  int       unsigned 	m_num_parcels; 
  static bit 	        m_strict = 0;
  static bit 	        m_enable_c_type = 0;  //Enable [C]ompressed instruction set     
  
  static function int unsigned calc_num_parcels(bit[15:0] parcel0);
    if (parcel0[1:0] != 2'b11) 
      return 1;
    else if (parcel0[5:2] != 3'b111) 
      return 2;
    else if (m_strict) 
      $fatal(1, $psprintf("UNUSPPORTED -- FUTURE, %016h",parcel0));      
  endfunction // get_len

  //Decode how many parcels need to be fetched from the instruction length encoding 
  //Returns the number of remaining parcels that need to be fetched and set (or use the
  //need_next_parcel())
  virtual    function int unsigned decode_len(bit[15:0] parcel0);
    m_num_parcels = decoder::calc_num_parcels(parcel0);      
    m_parcels= new[m_num_parcels];
    m_parcel_index = 0;      
    m_parcels[m_parcel_index++] = parcel0;
    return m_num_parcels-1;      
  endfunction

  virtual    function bit need_next_parcel();
    return (m_parcel_index < m_num_parcels);
  endfunction // has_next_parcel

  virtual    function void set_next_parcel(bit[15:0] parcel);
    m_parcels[m_parcel_index++] = parcel;      
  endfunction // set_next_parcel   

  virtual function inst16 decode_inst16(bit[15:0] inst_arg);
    int more = decode_len(inst_arg);
    inst16 inst_item;
    
    //All zeros isn't an instruction, return null
    if (inst_arg == 0) return null;      
        
    if (more != 0)
	if (m_strict) 
	  $fatal(1,"undecodable inst");
	else 
	  return null; 

    begin
	 inst16_ciformat  ci = new();
	 inst_item = ci;	 
    end
    return inst_item;  //Null now..
      
  endfunction // decode_inst16

   
   virtual function inst32 decode_inst32(bit[31:0] inst_arg);
      int  remaining_parcels;
      inst_t inst;
      rvg_major_opcode_t rvg_major_opcode;
      rvg_format_t rvg_format;
      inst32 inst_item;      

      //All zeros or F's isn't an instruction
      if (inst_arg == 0 || inst_arg == 'hffffffff) return null;      

     //decode_len sets a bunch of m_ fields, remaining_parcels != 0 if 
     //there are remaining_parcels parcels to the instruction     
      remaining_parcels = decode_len(inst_arg[15:0]);  

      if (remaining_parcels != 1)  
        // this is not a 32 bit instruction...
	if (m_strict) 
	  $fatal(1,$psprintf("undecodable inst %h",inst_arg));
	else 
	  return null;      
      
      while(need_next_parcel()) begin
	 set_next_parcel(inst_arg[31:16]);	 //will need an update for >32 bit
      end

      if (m_num_parcels != 2)
	if (m_strict)
	  $fatal(1,"num_parcels != 2");
	else
	  return null;
      
      inst = {m_parcels[1],m_parcels[0]}; 
      rvg_major_opcode = rvg_major_opcode_t'(inst[6:0]);      
      rvg_format = rvg_format_by_major[rvg_major_opcode];

      if (rvg_format == UNKNOWN) return null;      
	   
      case (rvg_format)
	R: begin
	   inst32_rformat r = new(inst);
	   inst_item = r;	   
	end
	I: begin
	   inst32_iformat i = new(inst);
	   inst_item = i;	   
	end
	S: begin
	   inst32_sformat s = new(inst);
	   inst_item = s;	   
	end
	B: begin
	   inst32_bformat b = new(inst);
	   inst_item = b;	   
	end
	U: begin
	   inst32_uformat u = new(inst);
	   inst_item = u;	   
	end
	J: begin
	   inst32_jformat j = new(inst);
	   inst_item = j;	   
	end

      endcase
      
      return inst_item;

   endfunction // decode_inst
      
endclass // decode

`endif
