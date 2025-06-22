// https://retrocomputing.stackexchange.com/questions/8652/why-did-the-original-apple-e-have-two-sets-of-inverse-video-characters:
// $00..$1F Inverse  Uppercase Letters
// $20..$3F Inverse  Symbols/Numbers
// $40..$5F Normal   MouseText
// $60..$7F Inverse  Lowercase Letters (the reason why flashing got dropped)
// $80..$9F Normal   Uppercase Letters
// $A0..$BF Normal   Symbols/Numbers   (like ASCII + $80)
// $C0..$DF Normal   Uppercase Letters (like ASCII + $80)
// $E0..$FF Normal   Lowercase Letters (like ASCII + $80)

// Because cputc() does an EOR #$80 internally:
// $00..$1F Normal   Uppercase Letters
// $20..$3F Normal   Symbols/Numbers   (like ASCII)
// $40..$5F Normal   Uppercase Letters (like ASCII)
// $50..$7F Normal   Lowercase Letters (like ASCII)
// $80..$9F Inverse  Uppercase Letters
// $A0..$BF Inverse  Symbols/Numbers
// $C0..$DF Normal   MouseText
// $E0..$FF Inverse  Lowercase Letters

#include <conio.h>
#include <stdbool.h>
#include <peekpoke.h>

bool lower;

enum htype {TOP, MID, BOTTOM, SIZE};

const char hchar[true+1][SIZE] = {{0xA0, '-' , '_'},
                                  {0xDC, 0xD3, '_'}};
const char vchar[true+1][true+1] = {{'!' , '!' },
                                    {0xDA, 0xDF}};

void hlinexy(unsigned char x, unsigned char y, unsigned char len, enum htype type)
{
  gotoxy(x, y);
  while (len--) {
    cputc(hchar[lower][type]);
  }
}

void vlinexy(unsigned char x, unsigned char y, unsigned char len, bool right)
{
  while (len--) {
    cputcxy(x, y++, vchar[lower][right]);
  }
}

void iputsxy(unsigned char x, unsigned char y, const char* s)
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

void main(void)
{
  clrscr();

  if (get_ostype() >= APPLE_IIE) {
    allow_lowercase(true);
    POKE(0xC00F, 0);
    lower = true;
  }

  hlinexy( 1,  0, 38, TOP);
  hlinexy( 1,  5, 38, MID);
  hlinexy( 1, 22, 38, BOTTOM);
  vlinexy( 0,  0, 24, false);
  vlinexy( 39, 0, 24, true);

  iputsxy( 13, 0, " DISK IMAGES ");
  iputsxy( 1, 23, " <>      TAB      Ret        ESC ");
  cputsxy( 5, 23,     "Move");
  cputsxy(14, 23,              "Next");
  cputsxy(23, 23,                       "Choose");
  cputsxy(34, 23,                                  "Exit");

  cputsxy( 1,  2, "Host:tnfs.fujinet.online");
  cputsxy( 1,  3, "Fltr:");
  cputsxy( 1,  4, "Path:");
  cputsxy( 2,  6, "CHAT");
  cputsxy( 2,  7, "COVi");
  cputsxy( 2,  8, "elec");
  cputsxy( 2,  9, "fn-c");
  cputsxy( 2, 10, "fuji");
  cputsxy( 2, 11, "fuji");
  cputsxy( 2, 12, "ling");
  cputsxy( 2, 13, "neon");
  cputsxy( 2, 14, "WC22");
  cputsxy( 2, 15, "weat");
  cputsxy( 2, 16, "wiki");
  cputsxy( 2, 17, "www.");
  cputsxy( 2, 18, "YAIL");

  hlinexy( 7,  6, 26, TOP);
  hlinexy( 7, 18, 26, BOTTOM);
  vlinexy( 6,  6, 13, false);
  vlinexy( 33, 6, 13, true);

  iputsxy(10,  6, " Select Device Slot ");
  cputsxy( 9,  8, "1 <Empty>");
  cputsxy( 9,  9, "2 <Empty>");
  cputsxy( 9, 10, "3 <Empty>");
  cputsxy( 9, 11, "4 <Empty>");
  cputsxy( 9, 12, "5 <Empty>");
  cputsxy( 9, 13, "6");
  iputsxy(11, 13,  "<Empty>              ");
  if (lower) {
    cputcxy(10, 13, 0xD5);
    cputcxy(32, 13, 0xC8);
  }
  cputsxy( 9, 14, "7 <Empty>");
  cputsxy( 9, 15, "8 <Empty>");
  cputsxy( 7, 17, "Mode:              R/W");
  iputsxy(18, 17, " R/O ");

  cgetc();
  clrscr();
}
