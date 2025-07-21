#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "fujinet-fuji.h"
#include "preferences.h"

#define CFG_CREATOR_ID 0xfe0c		// fenrock
#define CFG_APP_ID     0x02			// id for this app
#define CFG_KEY_ID     0x01			// the config values are key id 01

void write_defaults() {
	// set the latest version here, and give each field a default value
	prefs.version = 0;
	prefs.colour = 0;
	prefs.brightness = 0xd;
	prefs.shade = 0;
	prefs.bar_conn = 0xb4;
	prefs.bar_disconn = 0x33;
	prefs.bar_copy = 0x66;
	prefs.anim_delay = 0x04;
	prefs.date_format = 0x00;
	prefs.use_banks = 0x01;
	write_prefs();
}

void upgrade(uint8_t from) {
	switch(from) {
	case 0:
		// nothing to do for v0 upgrade, it's the base
		break;

	// case n+1:
	//  these will have to copy old data correctly from old key structure to the new one...

	default:
		break;
	}
}

void set_appkey_details(void) {
	fuji_set_appkey_details(CFG_CREATOR_ID, CFG_APP_ID, DEFAULT);
}

bool read_appkeys(uint16_t *count) {
	set_appkey_details();
	return fuji_read_appkey(CFG_KEY_ID, count, keys_buffer);
}

void write_prefs(void) {
	set_appkey_details();
	fuji_write_appkey(CFG_KEY_ID, sizeof(prefs), &prefs);
}

void read_prefs(void) {
	bool r;
	uint16_t read_count = 0;

	memset(keys_buffer, 0, 66);
	r = read_appkeys(&read_count);
	if (!r) {
		// couldn't find a key, so set and write defaults
		write_defaults();
		return;
	}

	// the first byte is the version of the config being loaded, so we can future proof our appkeys
	prefs.version = keys_buffer[0];
	switch(prefs.version) {
	case 0:
		// values can be copied directly from buffer to the config object
		memcpy(&prefs, keys_buffer, sizeof(PREFS_DATA));
		break;
	default:
		// if we get here, we have an unknown version, so write defaults
		write_defaults();
		break;
	}

}