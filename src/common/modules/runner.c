#include <stdint.h>
#include "../include/runner.h"

// this uses a 
extern void fast_call(void (*fn)(void));

// External module function declarations
extern void mod_legacy_hosts_devices(void);
extern void mod_init(void);
// extern void mod_hosts(void);
// extern void mod_devices(void);
// extern void mod_wifi(void);
// extern void mod_info(void);
// extern void mod_boot(void);
// extern void mod_files(void);
// extern void mod_sel_host_slot(void);
// extern void mod_select_device_slot(void);

// Function pointer type for modules
typedef void (*mod_func_t)(void);

// Module function table
static const mod_func_t mod_table[] = {
    mod_init,      // MOD_INIT
    mod_legacy_hosts_devices,
    // mod_hosts,     // MOD_HOSTS
    // mod_devices,   // MOD_DEVICES  
    // mod_wifi,      // MOD_WIFI
    // mod_info,      // MOD_INFO
    // mod_files,     // MOD_FILES
    // mod_boot       // MOD_BOOT
};

// Current module index
uint8_t mod_current = MOD_INIT;

// Main module runner function
void run_module(void)
{
    // Bounds check to ensure we don't exceed the table
    if (mod_current < (sizeof(mod_table) / sizeof(mod_table[0]))) {
        // Call the appropriate module function via function pointer
        fast_call(mod_table[mod_current]);
    }
}
