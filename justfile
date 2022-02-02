build-command := "zig build-lib zf/src/libzf.zig -O ReleaseFast -dynamic"

# library filenames
linux := "libzf-linux-x64"
linux-arm := "libzf-linux-arm64"
macos := "libzf-osx-x64"
macos-arm := "libzf-osx-arm64"
windows := "libzf-windows-x64"

_list:
    @just --list

# remove all shared libraries
clean:
    rm -f lib/*

# build ./lib/libzf.so for the native architecture
build:
    {{build-command}} -femit-bin=lib/libzf.so

# build libzf for all supported targets for distribution
build-all:
    {{build-command}} -target x86_64-linux   -femit-bin=lib/{{linux}}.so
    {{build-command}} -target aarch64-linux  -femit-bin=lib/{{linux-arm}}.so
    {{build-command}} -target x86_64-macos   -femit-bin=lib/{{macos}}.so
    {{build-command}} -target aarch64-macos  -femit-bin=lib/{{macos-arm}}.so
    {{build-command}} -target x86_64-windows -femit-bin=lib/{{windows}}.dll

    @# Remove windows files that aren't needed
    rm lib/*.pdb lib/*.lib
