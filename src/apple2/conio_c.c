#include <conio.h>
#include <stdbool.h>
#include <stdint.h>

extern bool lower;

enum htype {TOP, MID, BOTTOM, SIZE};

const char hchar[true+1][SIZE] = {{0xA0, '-' , '_'},
                                  {0xDC, 0xD3, '_'}};
const char vchar[true+1][true+1] = {{'!' , '!' },
                                    {0xDA, 0xDF}};

// in unit tests, this is 807 cycles, asm is 356
void hlinexy_c(unsigned char x, unsigned char y, unsigned char len, enum htype type)
{
  uint8_t v;
  gotoxy(x, y);
  // checking len == 0 adds 35 cycles to all normal cases (6), only saving 180 if len == 0, which is unlikely. 
  v = hchar[lower][type];
  while (len--) {
    cputc(v);
  }
}

// in unit tests, this is 1027 cycles, asm is 513
void vlinexy_c(unsigned char x, unsigned char y, unsigned char len, bool right)
{
  uint8_t v;
  while (len--) {
    cputcxy(x, y++, vchar[lower][right]);
  }
}
