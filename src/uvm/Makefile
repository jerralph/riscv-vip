
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



SIMR := modelsim
#SIMR := ius

ifeq ($(SIMR), modelsim)
SIMR_ARGS := -c_arg +cover -r "-do riscv_vip.do"
endif
ifeq ($(SIMR), ius)
SIMR_ARGS := -c_arg "-coverage all -covoverwrite"
endif


agent_ut:
	runSVUnit -uvm -t i32_agent_unit_test.sv -s $(SIMR) -f riscv_vip_uvc.f $(SIMR_ARGS)

env_ut:
	runSVUnit -uvm -t uvc_env_unit_test.sv -s $(SIMR) -f riscv_vip_uvc.f $(SIMR_ARGS)

i32s_ut:
	runSVUnit -uvm -t sv_to_uvm/inst32_sformat_unit_test.sv -s $(SIMR) -f riscv_vip_uvc.f $(SIMR_ARGS)

i32i_ut:
	runSVUnit -uvm -t sv_to_uvm/inst32_iformat_unit_test.sv -s $(SIMR) -f riscv_vip_uvc.f $(SIMR_ARGS)

clean:
	rm -Rf work/*
