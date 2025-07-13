# creating this overlay because even unstable does not
# offer latest version of roslyn-ls as of 02/09/2025
# https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/ro/roslyn-ls/package.nix
# uses vsVersion = "2.62.18" which on its part means VSCode-CSharp-2.62.18
# but due to latest changes in roslyn.nvim plugin
# commit: https://github.com/seblyng/roslyn.nvim/commit/ffd26b6e993b86c0f653cdf356eed14647bd2f14
# because of this at least revision is needed VSCode-CSharp-2.63.31
# here is the actual change on roslyn-ls side
# commit: https://github.com/dotnet/roslyn/pull/76437/commits/b7bce03f91fee99cb631cd0947339599feb02be5
# i am pulling roslyn tag VSCode-CSharp-2.64.7 which is latest at this moment
{prev}:
let
  pinnedPkgs = import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/3101df32cf53cfa4b3b931fad1cdc239c227bc4e.tar.gz";
    sha256 = "1makqyhvj9q083zmh3721kwwdi32yc31lmj715rlwhldvphb4jg4";
  }) {
    # system = "x86_64-linux";
    system = prev.system;
  };
in 
pinnedPkgs.roslyn-ls.overrideAttrs (oldAttrs: rec {
  vsVersion = "2.64.7";
  version = "4.14.0-2.25106.12";
  project = "Microsoft.CodeAnalysis.LanguageServer";

  src = pinnedPkgs.fetchFromGitHub {
    owner = "dotnet";
    repo = "roslyn";
    rev = "VSCode-CSharp-${vsVersion}";
    hash = "sha256-HWcVb2vpZxZWSxvWYRc91iUNaNGYDGEgKzHtD3yoyXs=";
  };

  dotnet-sdk = with pinnedPkgs.dotnetCorePackages;
    sdk_9_0
    // {
      inherit
        (combinePackages [
          sdk_9_0
          sdk_8_0
        ])
        packages
        targetPackages
        ;
    };

  dotnet-runtime = pinnedPkgs.dotnetCorePackages.sdk_9_0;
  nugetDeps = ./deps.json;
  projectFile = "src/LanguageServer/${project}/${project}.csproj";

  inherit
    (oldAttrs)
    nativeBuildInputs
    dotnetFlags
    installPhase
    ;

  patches = [
    ./force-sdk_8_0.patch
    ./cachedirectory.patch
  ];

  postPatch = oldAttrs.postPatch;
})
