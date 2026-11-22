# dotfiles

My shell and tool configuration, managed declaratively with [Nix](https://nixos.org) and [Home Manager](https://github.com/nix-community/home-manager). One flake, one config per machine type, pinned versions via `flake.lock`.


## Machine entries

Defined in `flake.nix`. Each entry needs the right `system` and `username` for the machine.

| Entry | System | Notes |
| --- | --- | --- |
| `mac` | `aarch64-darwin` | macOS (Apple Silicon). Use `x86_64-darwin` on Intel. |
| `linux` | `aarch64-linux` | Debian. Use `x86_64-linux` on x86 machines. |

Check a machine with `uname -m` and `whoami`. If a machine's username or architecture differs, add a new entry instead of editing an existing one.

## Setup on a new machine

### 1. Install Nix

**macOS / Linux with systemd (multi-user install):**

```sh
curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh
```

**Linux without systemd or without seccomp support (single-user install):**

```sh
sudo mkdir -m 0755 /nix && sudo chown "$USER" /nix
mkdir -p ~/.config/nix
echo "filter-syscalls = false" >> ~/.config/nix/nix.conf
NIX_CONFIG='filter-syscalls = false' sh <(curl -L https://nixos.org/nix/install) --no-daemon
```

Needs `curl` and `xz-utils` (`sudo apt install curl xz-utils`).

Open a new terminal, or load Nix into the current one:

```sh
# multi-user
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
# single-user
. ~/.nix-profile/etc/profile.d/nix.sh
```

Verify with `nix --version`.

### 2. Enable flakes

```sh
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### 3. Clone the repo

```sh
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
```

### 4. First apply

Run from inside the repo. Use `.#mac` or `.#linux`.

```sh
nix run home-manager/master -- switch --flake .#linux -b backup
```

`-b backup` renames any existing file in the way (for example `~/.zshrc`) to `*.backup` instead of failing.

The first run downloads a lot (the nixpkgs snapshot plus packages). Later runs only fetch what changed.

### 5. Make zsh the login shell

macOS: the system zsh works, nothing to do.

Linux:

```sh
echo ~/.nix-profile/bin/zsh | sudo tee -a /etc/shells
chsh -s ~/.nix-profile/bin/zsh
```

If `chsh` has no effect on a given system, add `exec zsh` to the end of `~/.bashrc`.

### 6. Secrets and per-machine overrides

Secrets never go in this repo. Put API keys, tokens and machine-specific exports in `~/.zshrc.local`, which `zsh.nix` sources if it exists.

## Day-to-day workflow

```sh
cd ~/dotfiles
# edit the .nix files or starship.toml
git add -A                                        # flakes only see git-tracked files
home-manager switch --flake ~/dotfiles#<entry>    # mac or linux
exec zsh                                          # reload the shell
git commit -am "..." && git push
```

On the other machines:

```sh
cd ~/dotfiles && git pull
home-manager switch --flake ~/dotfiles#<entry>
```

`~/.config/starship.toml` is a read-only symlink into the Nix store. Edit `starship.toml` in this repo, then run `switch`.

## Updating packages

```sh
cd ~/dotfiles
nix flake update
home-manager switch --flake .#<entry>
git add flake.lock && git commit -m "Update flake.lock" && git push
```

## Rollback

```sh
home-manager generations     # list previous states
# run the activate script printed next to the generation you want
```

## Adding things

- **A package:** add it to `home.packages` in `home.nix`.
- **A zsh plugin:** built-in omz plugins go in `programs.zsh.oh-my-zsh.plugins`. Custom ones need `programs.zsh.plugins` with `pkgs.fetchFromGitHub`, or a nixpkgs package.
- **Another program** (git, tmux, editor): add a module with `programs.<name>` and import it from `home.nix`.
- **A new machine type:** add an entry to `homeConfigurations` in `flake.nix`.

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| `nix: command not found` | Source the Nix profile script (see step 1). If it keeps happening on macOS, a system update removed the snippet from `/etc/zshrc`; re-run the installer. |
| `home-manager: command not found` | Make sure `programs.home-manager.enable = true;` is in `home.nix` and the Nix profile is on `PATH`. Until then use `nix run home-manager/master -- switch ...`. |
| `could not find a flake.nix` | You're not in the repo. `cd ~/dotfiles` or pass `--flake ~/dotfiles#<entry>`. |
| `file not found` inside the flake | The file isn't tracked yet: `git add -A`. |
| `Existing file ... is in the way` | Re-run with `-b backup`. |
| `unexpected '='` or other syntax error in a `.nix` file | Check the block sits inside the outer `{ ... }` of the file. |
| `[oh-my-zsh] plugin '...' not found` | The plugin was a hand-cloned custom plugin. Remove it from the list or package it through Nix. |
| `unable to load seccomp BPF program` | Kernel has no seccomp. Set `filter-syscalls = false` in `~/.config/nix/nix.conf`. |
| Downloads stall or time out | Retry (partial downloads resume). Add `http2 = false` and `stalled-download-timeout = 600` to `~/.config/nix/nix.conf`. Avoid `--fallback` unless the cache stays unreachable, since it builds from source. |
| Starship `git timed out` warning | Add `command_timeout = 2000` at the top of `starship.toml`. |
| `stdenv.isDarwin is deprecated` | Use `stdenv.hostPlatform.isDarwin` in `flake.nix`. |
| `Git tree is dirty` | Harmless. Commit your changes to silence it. |

## Notes

- `home.stateVersion` is set once per machine and should not be changed afterwards.
- `flake.lock` is committed so every machine gets identical package versions.
- Old pre-Nix configs are kept as `~/.zshrc.backup` and `~/.config/starship.toml.backup` on migrated machines; delete them once nothing is missing.
