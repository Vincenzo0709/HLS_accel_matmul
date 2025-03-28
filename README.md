# Vitis HLS dot product
This repository automates IP building for Vitis HLS dot product component.
You can clone all git repository or copy only fetch_sources.sh.

### Hardware build
To compile HLS and package the IP:

    make syn
    make package

from hw/ directory.

Or you can call

    ./scripts/fetch_sources.sh

To extract only rtl sources (in Verilog), ip directory for Vivado and ip zip.
Outputs will be located in build/ directory.

### Application