#include <sys/mman.h>
#include <fcntl.h>

#include <x86intrin.h>

#ifdef __x86_64
    #include <asm/unistd_64.h>
#else
    #include <asm/unistd_32.h>
#endif

#define FRAMEBUFFER_COMPONENTS 4
#define FRAMEBUFFER_LENGTH (WIDTH * HEIGHT * FRAMEBUFFER_COMPONENTS)

void _start() {
    register unsigned char *b __asm__("eax");

    int frame = 0, f, x, y;
    unsigned int index = 0, index2 = 0;

    while (1) {
        x = (x - (x >> 12)) - (y >> 0) + (frame >> 7);
        y = (y + (x >> 0)) + (x >> 1 - (y >> 23)) + ((frame >> 7) & (x >> 2));

        index = (((WIDTH >> 1) + (x >> 13)) + (y >> 13) * WIDTH) * 4;
        index2 = (((WIDTH >> 1) + ~(x >> 13)) + (y >> 13) * WIDTH) * 4;

        if (index >= FRAMEBUFFER_LENGTH) { index = 0; index2 = 0; }
        if (index2 >= FRAMEBUFFER_LENGTH) { index2 = 0; }

        // SIMD saturated arithmetic
        // color
        int r = 1;
        int c = 1 & f;
        int c2 = (r << 16) + (c << 8) + c;
        __m128i fv = _mm_set_epi32(c2, c2, c2, c2);

        // saturated add
        __m128i t = _mm_load_si128((const __m128i *)&b[index]);
        __m128i v = _mm_adds_epu8(fv, t);
        _mm_storeu_si32((unsigned char*)&b[index], v);
        __m128i t2 = _mm_load_si128((const __m128i *)&b[index2]);
        __m128i v2 = _mm_adds_epu8(fv, t2);
        _mm_storeu_si32((unsigned char*)&b[index2], v2);

        frame += 16;
        f += 1;
    }
}
