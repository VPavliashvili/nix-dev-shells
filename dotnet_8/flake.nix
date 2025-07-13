{
  description = "A .NET development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ self, nixpkgs, unstable, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = (import ../overlays { inherit inputs; });
        };
        unstable-pkgs = import unstable { 
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            # packages related to runtime and build process
            pkgs.dotnet-sdk_8
            pkgs.dotnet-runtime_8
            pkgs.dotnet-aspnetcore_8
            pkgs.dotnet-ef


            # below are ide related packages(lsp, debugger and such)

            # installing roslyn ls for separated lsp support
            # to avoid conflicts between other roslyn lsp process
            # which may(or not) running different dotnet version
            # and might have different path for decompiled assemblies
            pkgs.roslyn-ls
            pkgs.netcoredbg
          ];

          shellHook = ''
            # Set DOTNET_ROOT to the correct location
            export DOTNET_ROOT="${pkgs.dotnet-sdk_8}"

            # Set the ASPNETCORE environment to Development
            export DOTNET_ENVIRONMENT=Development
            
            # Disable telemetry
            export DOTNET_CLI_TELEMETRY_OPTOUT=1
            
            # Set up temp directory for .NET
            export DOTNET_CLI_HOME="/tmp/dotnet-cli-home"
            mkdir -p $DOTNET_CLI_HOME
            chmod 755 $DOTNET_CLI_HOME
            
            # Add dotnet tools to PATH
            export PATH=$PATH:$DOTNET_CLI_HOME/.dotnet/tools 

            # specify certs
            export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
            
            # Welcome message
            echo "Welcome to .NET $(dotnet --version) development environment!"
            echo "dotnet SDK version: $(dotnet --version)"
          '';
        };
      });
}
