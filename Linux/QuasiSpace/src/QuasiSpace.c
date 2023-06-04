#include <sys/mman.h>
#include <fcntl.h>

#ifdef __x86_64
    #include <asm/unistd_64.h>
#else
    #include <asm/unistd_32.h>
#endif

void _start() {
    register unsigned int *b __asm__("eax");
    b += WIDTH / 2 + HEIGHT / 2 * WIDTH;

    unsigned int f;
    int x, y, i;

    while (1) {
	    x = x - y + (f + (i << 7));
	    y = y + x + (f - (x >> 1));

        i = (x >> 22) + (y >> 22) * WIDTH;
        b[i] += 0x010101;

        f += 1;
    }
}
