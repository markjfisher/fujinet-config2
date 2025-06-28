#include <conio.h>
#include <stdbool.h>
#include <stdint.h>
#include <string.h>

/*
  This is the C version of the conio library.
  It is used for prototyping the functions before porting them to assembly.
  Unit tests are written against both versions to compare performance.
 */


extern bool lower;

enum htype {TOP, MID, BOTTOM, SIZE};

#ifdef SIMPLE_GFX
const char hchar[true+1][SIZE] = {{'=', '-' , '_'},
                                  {'%', '+', '~'}};
const char vchar[true+1][true+1] = {{'[' , ']' },
                                    {'{', '}'}};
#else
const char hchar[true+1][SIZE] = {{0xA0, '-' , '_'},
                                  {0xDC, 0xD3, '_'}};
const char vchar[true+1][true+1] = {{'!' , '!' },
                                    {0xDA, 0xDF}};
#endif


extern void hlinexy(uint8_t x, uint8_t y, uint8_t len, enum htype type);
extern void vlinexy(uint8_t x, uint8_t y, uint8_t len, bool right);
extern void iputsxy_c(uint8_t x, uint8_t y, const char* s);

void hlinexy_c(uint8_t x, uint8_t y, uint8_t len, enum htype type)
{
  uint8_t v;
  gotoxy(x, y);
  // checking len == 0 adds 35 cycles to all normal cases (6), only saving 180 if len == 0, which is unlikely. 
  v = hchar[lower][type];
  while (len--) {
    cputc(v);
  }
}

void vlinexy_c(uint8_t x, uint8_t y, uint8_t len, bool right)
{
  uint8_t v;
  v = vchar[lower][right];
  while (len--) {
    cputcxy(x, y++, v);
  }
}

void iputsxy_c(uint8_t x, uint8_t y, const char* s)
{
  gotoxy(x, y);
  if (lower) {
    char c;
    while (c = *s++) {
      if (c >= 0x40 && c <= 0x5F) {
        c += 0x40;
      } else {
        c += 0x80;
      }
      cputc(c);
    }
  } else {
    revers(true);
    cputs(s);
    revers(false);
  }
}

struct draw_window_params {
  uint8_t x_v;
  uint8_t y_v;
  uint8_t width;
  uint8_t height;
  const char* title;
};

// In testing against the ASM version:
//  C:   4 windows takes 60369 cycles -> 119,871 with blanking
//  ASM: 4 windows takes 33109 cycles ->  59,317 with blanking
// almost 2x slower.

void draw_window_c(struct draw_window_params* params)
{
  uint8_t x = params->x_v;
  uint8_t y = params->y_v;
  uint8_t width = params->width;
  uint8_t height = params->height;
  const char* title = params->title;
  uint8_t title_len;
  uint8_t title_start;
  uint8_t i;

  // Draw top border with title
  hlinexy_c(x + 1, y, width - 2, TOP);
  
  // Center the title in the top border
  if (title && *title) {
    // Calculate title length
    title_len = 0;
    for (i = 0; title[i]; i++) {
      title_len++;
    }
    
    // Calculate starting position to center title
    if (title_len < width - 2) {  // Leave space for borders
      title_start = x + 1 + (width - 2 - title_len) / 2;
      gotoxy(title_start, y);
      cputs(title);
    }
  }
  
  // Draw left and right borders
  vlinexy_c(x, y, height, false);           // left border
  vlinexy_c(x + width - 1, y, height, true); // right border  
  
  // Clear window interior (blank out contents)
  for (i = 1; i < height - 1; i++) {
    uint8_t j;
    gotoxy(x + 1, y + i);
    for (j = 0; j < width - 2; j++) {
      cputc(' ');
    }
  }
  
  // Draw bottom border
  hlinexy_c(x+1, y + height - 1, width-2, BOTTOM);
}
