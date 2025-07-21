#ifndef PREFS_H
#define PREFS_H

#include <stdbool.h>
#include <stdint.h>

typedef struct
{
    uint8_t version;
    uint8_t colour;
    uint8_t brightness;
    uint8_t shade;
    uint8_t bar_conn;
    uint8_t bar_disconn;
    uint8_t bar_copy;
    uint8_t anim_delay;
    uint8_t date_format;
    uint8_t use_banks;
} PREFS_DATA;

extern PREFS_DATA prefs;

// keysize + 2
extern uint8_t keys_buffer[66];


void set_appkey_details(void);
bool read_appkeys(uint16_t *count);
void write_prefs(void);
void read_prefs(void);

#endif // PREFS_H