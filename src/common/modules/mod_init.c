#include <stdio.h>
#include "../include/runner.h"

void mod_init(void) {
    printf("mod_init\n");
    mod_current = MOD_LEGACY_HOSTS_DEVICES;
}