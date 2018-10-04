
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


SIMR ?= modelsim  # default, can be overriden at runtime: make inst_ut SIMR=ius
#SIMR ?= ius

ifeq ($(SIMR), modelsim)
SVUNIT_SIMR_ARGS := -c_arg +cover -r "-do riscv_vip.do"
endif
ifeq ($(SIMR), ius)
SIMR_ARGS := -c_arg "-coverage all -covoverwrite"
endif


inst_ut:
	runSVUnit -t instruction_unit_test.sv -s $(SIMR) -f riscv_vip.f $(SIMR_ARGS)

hex_ut:
	runSVUnit -t hex_file_analyzer_unit_test.sv -s $(SIMR) -f riscv_vip.f $(SIMR_ARGS)

csrs_ut:
	runSVUnit -t csrs_unit_test.sv -s $(SIMR) -f riscv_vip.f $(SIMR_ARGS)

rf_ut:
	runSVUnit -t regfile_unit_test.sv -s $(SIMR) -f riscv_vip.f $(SIMR_ARGS)

rfet_ut:
	runSVUnit -t reg_fetcher_unit_test.sv -s $(SIMR) -f riscv_vip.f $(SIMR_ARGS)

ihist_ut:
	runSVUnit -t inst_history_unit_test.sv -s $(SIMR) -f riscv_vip.f $(SIMR_ARGS)



cov:
	vsim -viewcov riscv_vip.ucdb

doc:
	NaturalDocs 

clean:
	rm -Rf work/*
	rm -Rf riscv_vip



