#include <stdio.h>
#include "../include/runner.h"
#include "../include/preferences.h"
#include "../include/host.h"

void mod_init(void) {
    // Read stored app state from appkeys
    read_prefs();

    // Call global host specific initialization, modules will still need to setup any screen specific to itself.
    // Previously this was to setup DLIs etc, as they never changed during life of the app, but freeing up each module
    // to control its own fate means they will have to do it themselves.
    host_init();

    // Initialise some module values

    // Start getting information from FN to decide what module to load next
    // If wifi is enabled, get wifi status
    // If wifi is connected, change to the next module (MOD_HOSTS, or MOD_LEGACY_HOSTS_DEVICES)
    // Otherwise change to MOD_WIFI


    // change to the next module as an example for now
    mod_current = MOD_LEGACY_HOSTS_DEVICES;
}