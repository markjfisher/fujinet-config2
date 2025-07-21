#include <stdio.h>
#include "../include/host.h"

void mod_legacy_hosts_devices(void) {
    printf("mod_legacy_hosts_devices\n");

    // allow host to setup appropriate display
    host_display_legacy_hosts_devices();

    while (1) {
    }
}
