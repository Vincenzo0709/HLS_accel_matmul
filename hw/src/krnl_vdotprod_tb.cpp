#include <iostream>
#include "krnl_vdotprod.h"
using namespace std;

bool check_value(uint32_t *A, uint32_t *B, const int expctd, const int size) {

    uint32_t outsum = 0;
    for (int i=0; i<size; i++) {
        outsum += A[i] * B[i];
    }

    if (expctd!=outsum) {
        cout << endl << "[ERROR] Not expected result!" << endl;
        return false;
    } else return true;
}

int main(int argc, const char **argv) {

    uint32_t A[DATA_SIZE];
    uint32_t B[DATA_SIZE];
    uint32_t out = 0;
    const int size = DATA_SIZE;
    const int expctd = DATA_SIZE;

    for (int i=0; i<size; i++) {
        A[i] = 1;
        B[i] = 1;
    }


    krnl_vdotprod(A, B, &out, size);

    return !check_value(A, B, expctd, size);
}