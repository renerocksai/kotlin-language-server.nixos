# kotlin-language-server for NixOs

This repo contains a pre-built version of [kotlin-language-server](https://github.com/fwcd/kotlin-language-server),
ready for use on NixOS.

Yes, I should somehow package it nix-style but the way it is now works for me (tm) 🤠!

## Why

The reasons I've packaged it up and put it here are:

- `kotlin_language_server` needs JDK11+ for building (seems to run on older JDKs like JDK8 though)
- I, however, have JDK8 installed system-wide, for use with the Furhat robot SDK
- `gradle`, even when launched in a `nix-shell` like the one used for building [here](./shell-for-building.nix) gets
  confused and refuses to find its toolchain because of stuff in my `~/.gradle` folder.
  - hence, in order to build the kotlin-language-server, I had to `rm -fr ~/.gradle` before building it.
- I want to spare myself from this experience in the future and on other machines like my laptop

## Using it

- clone this repo
- use `/path/to/this/repo/kotlin_language_server` as Kotlin language server executable in your preferred editor.

The wrapper script will run the `kotlin_language_server` in a `nix-shell` **with JDK11** installed.

Here is how I configure it in neovim with my custom `on_attach` function and `capabilities`, using `lspconfig`:

```lua
require'lspconfig'.kotlin_language_server.setup{
cmd = {'/home/rs/code/github.com/renerocksai/kotlin_language_server/kotlin-language-server'},
    on_attach = on_attach,
    capabilities = capabilities,
    flags = {
      debounce_text_changes = 150,
    }
}
```

## Packaging it yourself

```console
# Path to shell-for-building.nix:
# (depends on where you checked out this repo)
SHNIX=/home/rs/code/github.com/renerocksai/kotlin_language_server.nixos/shell-for-building.nix

# example destination in this repo
# the ./bin and ./lib dirs will be copied into $DESTINATION
DESTINATION=/home/rs/code/github.com/renerocksai/kotlin_language_server.nixos

# git clone the language server: to ~/code/github.com/fwcd/kotlin-language-server
cd ~/code/github.com && mkdir fwcd
git clone https://github.com/fwcd/kotlin-language-server.git
cd kotlin_language_server

# copy in shell-for-building.nix
cp $SHNIX .

# save current ~/.gradle dir
mv ~/.gradle ~/.gradle.bak

# build it
nix-shell shell-for-building.nix
./gradlew :server:installDist

# "install" it
cp -pr server/build/install/server/* $DESTINATION

# restore ~/.gradle dir
rm -fr ~/.gradle
mv ~/.gradle.bak ~/.gradle
```
