# Vitis HLS dot product
This repository automates IP building for Vitis HLS dot product component.
You can clone all git repository or copy only fetch_sources.sh.
It is all arranged to be UninaSoC directories-compliant.

### Hardware build
To compile HLS and package the IP:

    make syn
    make package

from hw/ directory.

Or you can call

    ./scripts/fetch_sources.sh

To extract only rtl sources (in Verilog), ip directory for Vivado and ip zip.
Outputs will be located in build/ directory.

### Application build
The bare-metal application is already arranged to be UninaSoC directories-compliant.
You can test if it compiles by using Makefile (you need riscv bare-metal toolchain).

After importing on UninaSoC some files must be deleted:
* startup/ dir 
* Makefile_test is not needed for UninaSoC

To test compilation:

    make -f Makefile_test