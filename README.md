
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.


[ riscv-vip ] 
======================

About
----------------------------
This repository hosts RISC-V related SystemVerilog Verification IP.

See the riscv-vip users' guide for important user details.  https://jerralph.github.io/riscv-vip/doc/index.html 

Find the release notes in the RELEASE.txt file.

Get riscv-vip
----------------------------
```
   $ git clone https://github.com/jerralph/riscv-vip.git
   $ cd riscv-vip
```

Poke around the code and docs.


Run a unit test
----------------------------

1. Download and install SVUnit from https://github.com/nosnhojn/svunit-code.  Follow the instructions posted there to install.
2. Run the Hex file analyzer in the riscv-vip/src directory.

 * using the Mentor Questa Simulator.
 ```
      $ make hex_ut
```

 * Using the Cadence IUS Simulator
```
        $make hex_ut SIMR=ius
```
Integrate into your verification environment
-----------------------------------
See the Users' Guide for information on how to integrate into your own verification environment. 

