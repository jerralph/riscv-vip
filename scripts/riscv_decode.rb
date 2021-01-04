


################################################################
#
#  Licensed to the Apache Software Foundation (ASF) under one
#  or more contributor license agreements.  See the NOTICE file
#  distributed with this work for additional information
#  regarding copyright ownership.  The ASF licenses this file
#  to you under the Apache License, Version 2.0 (the
#  "License"); you may not use this file except in compliance
#  with the License.  You may obtain a copy of the License at
#  
#  http://www.apache.org/licenses/LICENSE-2.0
#  
#  Unless required by applicable law or agreed to in writing,
#  software distributed under the License is distributed on an
#  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#  KIND, either express or implied.  See the License for the
#  specific language governing permissions and limitations
#  under the License.
#
################################################################


class InstBase
  attr_accessor :u32
  attr_accessor :op

  def get_field(ubit,lbit)
    raise 'ubit < lbit' if ubit < lbit
    width = ubit - lbit + 1
    res = @u32 >> lbit
    mask = (0...width).inject(0){ |m,i| m = (m << 1) | 1 }
    res &= mask
    return res
  end

  def get_rd()
    raise "no get_rd() available" unless has_rd?
    get_field(11,7)
  end

  def get_rs1()
    raise "no get_rs1() available" unless has_rs1?
    get_field(19,15)
  end

  def get_rs2()
    raise "no get_rs2() available" unless has_rs2?
    get_field(24,20)
  end

  def get_func7()
    get_field(31,25)
  end

  def get_func3()
    get_field(14,12)
  end

  def get_op()
    ret = get_field(6,0)
    raise "op bits issue" unless ret == op.bits
  end

  def to_s
    str = "#{inst_name} "
    str += "r#{get_rd.to_s} "         if has_rd?
    str += "r#{get_rs1.to_s} "        if has_rs1?
    str += "r#{get_rs2.to_s} "        if has_rs2?
    str += "#{"0x%06x" % get_imm}"    if has_imm?
    return str
  end
  
end

class RInst < InstBase
  RLUT = {
      (0b0000000 << 3) + 0b000 => :ADD,
      (0b0100000 << 3) + 0b000 => :SUB,
      (0b0000000 << 3) + 0b001 => :SLL,
      (0b0000000 << 3) + 0b010 => :SLT,
      (0b0000000 << 3) + 0b011 => :SLTU,
      (0b0000000 << 3) + 0b100 => :XOR,
      (0b0000000 << 3) + 0b101 => :SRL,
      (0b0100000 << 3) + 0b101 => :SRA,
      (0b0000000 << 3) + 0b110 => :OR,
      (0b0000000 << 3) + 0b111 => :AND,
  }
  def has_rd?;  true;  end
  def has_rs1?; true;  end  
  def has_rs2?; true;  end
  def has_imm?; false; end
  def inst_name()
    raise "bad op" unless op.major == :OP
    key = (get_func7 << 3) + get_func3
    raise "can't find inst" unless RLUT.has_key? key
    RLUT[key]
  end
end


class IInst < InstBase
  def has_rd?;  true;  end
  def has_rs1?; true;  end
  def has_rs2?; false; end    
  def has_imm?; true;  end
  def get_imm
    get_field(31,20)
  end
  def inst_name
    case op.major
    when :JALR; :JALR
    when :OP_IMM
      f3 = get_func3
      case f3
      when 0b000;  :ADDI
      when 0b001;  :SLLI
      when 0b010;  :SLTI
      when 0b011;  :SLTIU
      when 0b100;  :XORI
      when 0b101
        diff = get_field(31,25)
        if diff == 0
          :SRLI
        elsif diff == 0b0100000
          :SRAI
        else
          raise "bad SRLI, SRAI decode"
        end 
      when 0b110;  :ORI
      when 0b111;  :ANDI
      else
        raise "bad OP_IMM func3 #{f3}"
      end
    when :MISC_MEM
      case get_func3
      when 0b000; :FENCE
      when 0b001; :FENCE_I
      else
        raise "bad MISC_MEM"
      end
    when :SYSTEM
      case get_func3
      when 0b000
        diff = get_field(31,20)
        if diff == 0
          :ECALL
        elsif diff == 1
          :EBREAK
        else
          raise "bad ECALL,EBREAK"
        end
      when 0b001; :CSRRW
      when 0b010; :CSRRS
      when 0b011; :CSRRC
      when 0b101; :CSRRWI
      when 0b110; :CSRRSI
      when 0b111; :CSRRCI
      else 
        raise "bad SYSTEM"
      end
    else
      raise "no op.majory match"
    end
  end #def inst_name
end


class SInst < InstBase
  def has_rd?;  false; end
  def has_rs1?; true;  end    
  def has_rs2?; true;  end    
  def has_imm?; true;  end
  def get_imm
    (get_field(31,25) << 4) + get_field(4,0)    
  end
  def inst_name
    case get_func3
    when 0b000; :SB
    when 0b001; :SH
    when 0b010; :SW
    else
      raise "bad store"
    end
  end
end

class BInst < InstBase
  BLUT = {
    0b000 => :BEQ,
    0b001 => :BNE,
    0b100 => :BLT,
    0b101 => :BGE,
    0b110 => :BLTU,
    0b111 => :BGEU,
  }  
  def has_rd?; false;  end
  def has_rs1?; true;  end
  def has_rs2?; true;  end
  def has_imm?; true;  end
  def get_imm
    b12    = get_field(31,31)
    b10to5 = get_field(30,25)
    b4to1  = get_field(11,8)
    b11    = get_field(7,7)
    imm = (b12 << 12) + (b11 << 11) + (b10to5 << 5) + (b4to1 << 1) 
    return imm
  end
  def inst_name()
    raise "bad op" unless op.major == :BRANCH
    BLUT[get_func3]
  end 
end

class UInst < InstBase
  def has_rd?;  true;   end
  def has_rs1?; false;  end
  def has_rs2?; false;  end
  def has_imm?; true;   end
  def get_imm
    get_field(31,12)
  end
  def inst_name
    raise "bad op" unless [:AUIPC, :LUI].include? @op.major
    @op.major
  end
end

class JInst < InstBase
  def has_rd?;  true;   end
  def has_rs1?; false;  end
  def has_rs2?; false;  end
  def has_imm?; true;   end
  def get_imm
    b20 = get_field(31,31)
    b10to1 = get_field(30,21)
    b11 = get_field(20,20)
    b19_12 = get_field(19,12)
    imm = (b20 << 20) + (b19_12 << 12) + (b11 << 11) + (b10to1 << 1) 
    return imm    
  end
  def inst_name
    raise "bad op" unless op.major == :JAL
    :JAL
  end
end

class Opcode
  attr_accessor :major     #RISC-V general major opcode name
  attr_accessor :clazz     #RISC-V general format class
  attr_accessor :bits      #bits [6:0]
  def initialize(major,clazz,bits)
    @major,@clazz,@bits = major,clazz,bits
  end
end

class Decoder
  #Below enum is derived from riscv-spec-v2.2.pdf p103
  #Map of major opcode for RiscV General (RVG)
  OPCODES = [                         
    Opcode.new( :LOAD        , IInst , 0b00_000_11),
    Opcode.new( :MISC_MEM    , IInst , 0b00_011_11),
    Opcode.new( :OP_IMM      , IInst , 0b00_100_11),
    Opcode.new( :AUIPC       , UInst , 0b00_101_11),
    Opcode.new( :OP_IMM_32   , IInst , 0b00_110_11),
    Opcode.new( :STORE       , SInst , 0b01_000_11),
    Opcode.new( :OP          , RInst , 0b01_100_11),
    Opcode.new( :LUI         , UInst , 0b01_101_11),
    Opcode.new( :BRANCH      , BInst , 0b11_000_11),
    Opcode.new( :JALR        , IInst , 0b11_001_11),
    Opcode.new( :JAL         , JInst , 0b11_011_11),
    Opcode.new( :SYSTEM      , IInst , 0b11_100_11),
  ]
  def self.decode(u32)
    op_bits = 0b11_111_11 & u32
    opcode = OPCODES.select{ |o| o.bits == op_bits }
    if !opcode
      raise "unable to find opcode for #{u32}, op bits are #{"0b%07b" %op_bits}."
    elsif opcode.size != 1
      raise "Multiple opcodes for #{u32} should not happen. Op bits are #{"0b%07b" %op_bits}."
    end
    opcode = opcode[0]
    inst = opcode.clazz.new()
    inst.u32 = u32
    inst.op = opcode
    return inst    
  end
end


if __FILE__ == $0

  unless ARGV.size == 1 && ARGV[0].upcase =~ /^[A-F0-9]+$/
    puts "usage: #{$0} <32-bit-rv32i-instruction-in-hex>"
    exit 1
  end

  
  #if we get here, then this is being used a script and not a lib
  u32 = Integer(ARGV[0],16)
  inst = Decoder::decode(u32)


  #inst = InstBase.new
  #inst.u32 = 0b11110000
  #f = inst.get_field(7,4)
  #puts "f is #{"0b%0b" % f}"

  #puts "bits #{"%032b" % inst.u32}"
  #puts "rs1 #{"%0b" % inst.get_rs1}"
  puts inst
  
  
end

