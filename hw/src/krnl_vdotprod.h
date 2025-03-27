#ifndef __KRNL_VDOTPROD_H__
#define __KRNL_VDOTPROD_H__

#include <stdint.h>
#include <hls_stream.h>

#define DATA_SIZE 4

void krnl_vdotprod(const uint32_t *, const uint32_t *, uint32_t *, const int);

#endif