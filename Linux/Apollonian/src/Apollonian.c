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
    register unsigned char *buffer __asm__("eax");

    int frame = 15000000, x, y;
    unsigned int index = 0;

    while (1) {
        x = (x + (x >> 28)) - (y << 2) + (frame >> 24);
		y = (y - (x >> 5)) + ((x >> 1) - (y >> 12)) - ((frame >> 6) & (x << 18));
		x = (x + (x >> 12)) - (y << 2) + (frame >> 24);

        index = (((WIDTH >> 1) + (x >> 22)) + ((HEIGHT >> 1) + (y >> 22)) * WIDTH) * 4;

        // SIMD saturated arithmetic
        // color
        int r = (frame >> 23) & 3;
        int g = (frame >> 22) & 3;
        int b = (frame >> 24) & 3;
        int c2 = (r << 16) + (g << 8) + b;
        __m128i fv = _mm_set_epi32(c2, c2, c2, c2);

        // saturated add
        __m128i t = _mm_load_si128((const __m128i *)&buffer[index]);
        __m128i v = _mm_adds_epu8(fv, t);
        _mm_storeu_si32((unsigned char*)&buffer[index], v);

        frame += 1;
    }
}
