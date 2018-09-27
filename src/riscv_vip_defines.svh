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

//Some macros to limit duplicate code in creating coverage bins
`define IMM_MAX_POS(x)  {1'b0,{($bits(x)-1){1'b1}}}
`define IMM_ALL_ONES(x) {$bits(x){1'b1}}
`define IMM_MIN_NEG(x)  {1'b1,{($bits(x)-1){1'b0}}}

//Some defines to reduce duplicate code for a work around 
//wrt simulator support for set_covergroup_expression 
//(IEEE 1800-2012, 19.5.1.2)
`define S_INSTS_LIST            SB,SH,SW
`define I_NONSPECIAL_INSTS_LIST JALR,LB,LH,LW,LBU,LHU,ADDI,SLTI,SLTIU,XORI,ANDI
`define I_SHAMT_INSTS_LIST      SLLI, SRLI, SRAI
`define B_INSTS_LIST            BEQ, BNE, BLT, BGE, BLTU, BGEU
`define U_INSTS_LIST            LUI,AUIPC
`define J_INSTS_LIST            JAL