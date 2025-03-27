#include "krnl_vdotprod.h"

const int c_size = DATA_SIZE;

static void load_input( const uint32_t *in,
                        hls::stream<uint32_t> &inStream,
                        const int size) {

    for (int i=0; i<size; i++) {
        #pragma HLS LOOP_TRIPCOUNT min = c_size max = c_size
        inStream << in[i];
    }

}

static void store_output(uint32_t *out, hls::stream<uint32_t> &outStream, const int size) {

    *out = outStream.read(); 
    
}

static void execute(hls::stream<uint32_t> &inStream_A,
                    hls::stream<uint32_t> &inStream_B,
                    hls::stream<uint32_t> &outStream,
                    const int size) {

    uint32_t outsum = 0;
    for (int i=0; i<size; i++) {
        #pragma HLS LOOP_TRIPCOUNT min = c_size max = c_size
        outsum += inStream_A.read() * inStream_B.read();
    }

    outStream << outsum;

}

void krnl_vdotprod(const uint32_t *A, const uint32_t *B, uint32_t *out, const int size) {
    
    #pragma HLS INTERFACE m_axi port = A depth = DATA_SIZE bundle = gmem0 
    #pragma HLS INTERFACE m_axi port = B depth = DATA_SIZE bundle = gmem1
    #pragma HLS INTERFACE m_axi port = out depth = DATA_SIZE bundle = gmem2
    
    static hls::stream<uint32_t> inStream_A("input_stream1");
    static hls::stream<uint32_t> inStream_B("input_stream2");
    static hls::stream<uint32_t> outStream("output_stream");

    #pragma HLS DATAFLOW
    load_input(A, inStream_A, size);
    load_input(B, inStream_B, size);
    execute(inStream_A, inStream_B, outStream, size);
    store_output(out, outStream, size);

}