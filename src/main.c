#include <stdint.h>
#include <stdbool.h>

#include "common/include/runner.h"

extern void cleanup_host(void);

int main(void)
{
	// mod_current starts as MOD_INIT, which is the first module it will load
	// and modules then dictate what next module to load if any, until MOD_EXIT is set
    while (mod_current != MOD_EXIT)
    {
        run_module();
    }

    // fix up for the current host
    cleanup_host();
    return 0;
}