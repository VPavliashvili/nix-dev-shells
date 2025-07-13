# creating this overlay because current roslyn-ls package does not(as of version 25.05)
# properly support roslyn.nvim lsp integration for neovim
# (I suspect its generally broken for .net8, For .net9 works fine without this overlay tho)
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
