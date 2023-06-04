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

    int frame = 0, x, y;
    unsigned int index = 0;

    while (1) {
        x = (x - (x >> 24)) - y + (frame >> 4);
		y = (y - (x >> 22)) + (x - (y >> 28)) - ((frame >> 10) & (x << 10));
		x = (x - (x >> 22)) - y + (frame >> 4);

        index = (((WIDTH >> 1) + (x >> 14)) + (y >> 14) * WIDTH) * 4;

        if (index < FRAMEBUFFER_LENGTH) {
            // SIMD saturated arithmetic
            // color
            int r = 1;
            int c = 2 & frame;
            int c2 = (r << 16) + (c << 8) + c;
            __m128i fv = _mm_set_epi32(c2, c2, c2, c2);

            // saturated add
            __m128i t = _mm_load_si128((const __m128i *)&b[index]);
            __m128i v = _mm_adds_epu8(fv, t);
            _mm_storeu_si32((unsigned char*)&b[index], v);
        }

        frame += 1;
    }
}
