Run:

```
nix run github:zSuperx/tmux
```

Install:

```nix
{ inputs, ... }: {
    environment.systemPackages = [
        inputs.tmux.packages.x86_64-linux.tmux
    ];
}
```
