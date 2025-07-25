# fujinet-config2

This is a new conio based multi-platform config app in the style of config-ng.
It's inspired from Oliver Schmidt's poc rerendering a config-ng screen with apple2 graphics using mouse font text with cross-apple2 support.

Things to consider:

- we want to make this efficient as possible, so generated asm from C should be checked for bloat, e.g. runner.c uses a small amount of asm (via fast_call) to remove lots of pointless code cc65 generates
- we want to be as C-like as possible in the core logic, but utility functions (user input, caching of dirs, etc) can be asm where strongly tested
- should write good unit tests around complex logic/functionality, particularly when writing directly as asm
- in atari, cc65's conio does a lot of cursor tracking, which we just don't need. it slows the drawing down, and we will consider a cursor-less atari implementation

Features we will build:
- legacy mode to look like original config is just another module type
- we can use device specific display and common functions, e.g. drawing windows and displaying data

## building

To build the application ensure you have the correct compiler/linker for your platform (e.g. cc65), and
make on your path, then simply run make.

```shell
# to clean all artifacts, run this on its own
make clean

# to generate the application for all targets
make release

# to generate a "disk" (e.g. PO/ATR/D64)
make disk
```

As per normal cc65 rules, you can add `TARGETS=...` value to the command to only affect the named target(s) if you
are building a cross compiled application:

```shell
# just the apple2enh, and c64 targets
make TARGETS="apple2enh c64" release
```

The default list of targets can be edit in [Makefile](Makefile). Remove any entries for targets you do not
wish to build.

## Makefile breakdown

The build uses a Makefile which delegates to other mk files for compiling and building disks etc.
The sources for these files are in the [makefiles](makefiles) subdirectory.

The first file that Makefile loads is [build.mk](makefiles/build.mk), which loads other makefiles as required if
they exist, and then creates the `release` task which is the main build task. There is also an `all` task which
is default and will do the same thing as release.

If your application needs to add some custom configuration, this can be done in `application.mk` in the root dir.

This will be sourced during compilation and allows you to shape the build how you want, for instance
you could add a `src/include` dir to the C and ASM paths so that you can place all header files in one location,
if this is your desire.

```make
ASFLAGS += --asm-include-dir $(SRCDIR)/include
CFLAGS += --include-dir $(SRCDIR)/include
```

Alternatively you are free to hack the build.mk file at your pleasure.
