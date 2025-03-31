#include "xil_io.h"
#include <stdbool.h>
#include "xkrnl_vdotprod_hw.h"

#define Xkrnl_BASE                  __peripheral_HLS_Accelerator_Control_start
#define Xkrnl_Control               (Xkrnl_BASE + XKRNL_VDOTPROD_CONTROL_ADDR_AP_CTRL)
#define Xkrnl_GIE                   (Xkrnl_BASE + XKRNL_VDOTPROD_CONTROL_ADDR_GIE)
#define Xkrnl_IER                   (Xkrnl_BASE + XKRNL_VDOTPROD_CONTROL_ADDR_IER)
#define Xkrnl_ISR                   (Xkrnl_BASE + XKRNL_VDOTPROD_CONTROL_ADDR_ISR)
#define Xkrnl_A_ADDR                (Xkrnl_BASE + XKRNL_VDOTPROD_CONTROL_ADDR_A_DATA)
#define Xkrnl_B_ADDR                (Xkrnl_BASE + XKRNL_VDOTPROD_CONTROL_ADDR_B_DATA)
#define Xkrnl_OUT_ADDR              (Xkrnl_BASE + XKRNL_VDOTPROD_CONTROL_ADDR_OUT_R_DATA)
#define Xkrnl_SIZE_ADDR             (Xkrnl_BASE + XKRNL_VDOTPROD_CONTROL_ADDR_SIZE_DATA)

#define AP_START                    (0x00000001)
#define AP_DONE                     (0x00000002)
#define AP_IDLE                     (0x00000004)
#define AP_READY                    (0x00000008)
#define AP_CONTINUE                 (0x00000010)
#define AP_INTERRUPT                (0x00000020)

#define DATA_SIZE 4
#define EXPCTD DATA_SIZE

void initialize_data(uint32_t *A, uint32_t *B, uint32_t *out, uint32_t size) {
    for (int i = 0; i < size; i++) {
        A[i] = i;
        B[i] = i;
    }
    *out = 0;
}

// Starts kernel execution
void start_kernel(uint32_t *A, uint32_t *B, uint32_t *out, uint32_t size) {

    // Writing input/output addresses
    Xil_Out64(Xkrnl_A_ADDR, (uint64_t)A);
    Xil_Out64(Xkrnl_B_ADDR, (uint64_t)B);
    Xil_Out64(Xkrnl_OUT_ADDR, (uint64_t)out);
    Xil_Out32(Xkrnl_SIZE_ADDR, size);

    // Raising ap_start to start the kernel
    Xil_Out32(Xkrnl_Control, AP_START);

    // Waiting for the kernel to finish (polling the ap_done control bit)
    while ( (Xil_In32(Xkrnl_Control) && AP_DONE) != AP_DONE ) {}
}

// Checks the idle status of the kernel
bool is_kernel_idle() {
    return ( (Xil_In32(Xkrnl_Control) && AP_IDLE) == AP_IDLE );
}

// Checks the ready status of the kernel
bool is_kernel_ready() {
    return ( (Xil_In32(Xkrnl_Control) && AP_READY) == AP_READY );
}

bool check_results(uint32_t out) {
    return (out == EXPCTD);
}

int main() {

    uint32_t A[DATA_SIZE];
    uint32_t B[DATA_SIZE];
    uint32_t out;
    uint32_t size = DATA_SIZE;

    // Initializing input/output data
    initialize_data(A, B, &out, size);

    // Starting the kernel
    start_kernel(A, B, &out, size);

    // Checking results
    // if (check_results(out))
    //     return 0;
    // else return 1;
    while(1);

    return 0;

}