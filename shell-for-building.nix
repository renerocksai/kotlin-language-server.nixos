# h/t: https://discourse.nixos.org/t/problem-with-gradle-building-kotlin-native/7272/2?u=r-k-b
# initially written for hacking on https://github.com/klazuka/intellij-elm

# Note that certain gradle tasks may still fail, if `GRADLE_USER_HOME` contains files downloaded
# by a previous gradle instance run outside of the FHS environment this nix file provides.
# (that is, if something weird happens, `rm -rf ~/.gradle` and try again)

{ pkgs ? import <nixpkgs> { } }:
let
  fhs = pkgs.buildFHSUserEnv {
    name = "gradle-env";
    targetPkgs = pkgs:
      (with pkgs; [
        gradle
        kotlin
        jdk
        zlib
        ncurses
        freetype # for missing libfreetype.so.6
      ]);
  };
in pkgs.stdenv.mkDerivation {
  name = "gradle-env-shell";
  nativeBuildInputs = [ fhs ];

  shellHook = "exec gradle-env";
}
