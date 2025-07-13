{inputs, ...}: [
  (final: prev: {
    roslyn-ls = import ./mods/roslyn-ls-net8-compatible {inherit prev;};
  })
]
