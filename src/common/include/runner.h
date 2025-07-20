#ifndef RUNNER_H
#define RUNNER_H

#include <stdint.h>

// Module enumeration
typedef enum {
    MOD_LEGACY_HOSTS_DEVICES = 0,
    MOD_HOSTS,      // show the host slots, and allow drilling into them to pick a device to mount
    MOD_DEVICES,        // show device list from hosts files navigated to  
    MOD_WIFI,           // view/pick wifi
    MOD_INFO,           // show various information about FN, e.g. version, memory, help, ...
    MOD_FILES,          // file selection screen when browsing chosen host
    MOD_INIT,           // the initial module to load, runs all module initialisation
    MOD_BOOT,           // boot options, either lobby or mount current devices
    MOD_EXIT            // this is a marker to exit application
} mod_t;

// External declarations (equivalent to .export in assembly)
extern uint8_t mod_current;
extern void run_module(void);

#endif // RUNNER_H 