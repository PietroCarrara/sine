{ stdenv
, lib
, fetchFromGitHub
, fetchurl
, wget
, lua
, sile
, inkscape
}:

let
  silex = lua.pkgs.buildLuarocksPackage {
    pname = "silex.sile";
    version = "0.2.0-1";
    src = fetchurl {
      url = "https://github.com/Omikhleia/silex.sile/archive/refs/tags/v0.2.0.zip";
      hash = "sha256-Zo/a9Fr0a0bomgka2sA+c33rpzVlwJSTfjAa9aPYS5k=";
    };
  };
  ptable = lua.pkgs.buildLuarocksPackage {
    pname = "ptable.sile";
    version = "2.0.0-1";
    knownRockspec = "ptable.sile-2.0.0-1.rockspec";
    src = fetchFromGitHub {
      owner = "Omikhleia";
      repo = "ptable.sile";
      rev = "v2.0.0";
      sha256 = "sha256-H1HTcMgfj2aWrOzmt4I26gM6G7pGsNNtDDyF+t0X154=";
    };
    propagatedBuildInputs = [
      wget
      silex
    ];
  };
  lua-pkgs = [ silex ptable ];
in

stdenv.mkDerivation
rec {
  version = "0.0.1";
  pname = "sine";

  src = ./.;

  buildInputs = [
    lua
    inkscape
    sile
  ];

  shellHook = ''
    export LUA_CPATH="${lib.strings.concatStringsSep ";" ((map lua.pkgs.getLuaCPath lua-pkgs) ++ lua.LuaCPathSearchPaths)}"
    export LUA_PATH="${lib.strings.concatStringsSep ";" ((map lua.pkgs.getLuaPath lua-pkgs) ++ lua.LuaPathSearchPaths)}"
  '';

  buildPhase = ''
    ${shellHook}

    sile examples/sixthworld/dronejockey.sil
    sile examples/sixthworld/implants.sil
    sile examples/sixthworld/moves.sil
    sile examples/sixthworld/razorgirl.sil
    sile examples/sixthworld/rules.sil
    sile examples/sixthworld/sciencemaster.sil
    sile examples/sixthworld/spellbook.sil
    sile examples/sixthworld/spellweaver.sil
  '';

  installPhase = ''
    mkdir -p "$out/pdf"
    cp examples/**/*.pdf "$out/pdf"
  '';

  meta = {
    description = "A SILE package to make zines";
    homepage = "https://github.com/PietroCarrara/sine";
    platforms = lib.platforms.all;
  };
}
