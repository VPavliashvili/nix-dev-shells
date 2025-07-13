##### NOTE: This repo is WIP
I am going to add more language/framework support depending on my needs in future

#### Instructions
Clone the repo and `cd` into directory named after your preffered .net version</br>
`cp -r ./*` into the directory you are gonna create your real solution file into</br>
run `nix flake update` (not neccessary tho)</br>
run `nix develop`</br>

#### Example
```
git clone https://github.com/VPavliashvili/nix-dev-shells.git
cd nix-dev-shells/dotnet_8
cp -r ./* ~/source/csharp/my-project/
nix flake update
nix develop
```

and you are good to go

debugger and lsp functionality tested on neovim and works well</br>
you can see related neovim config in my [dotfiles](https://github.com/VPavliashvili/.dotfiles) [here](https://github.com/VPavliashvili/.dotfiles/blob/master/nvim/.config/nvim/lua/plugins/coding/languages/csharp/init.lua)
