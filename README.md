# Dotfiles

Personal dotfiles repository for my MacOS setup.

## Requirements

If home brew isn't installed:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Necessary and recommended packages to have installed `brew install`:

- `neovim`
- `--cask kitty` 
- `starship`
- `--cask font-roboto-mono-nerd-font`
- `anomalyco/tap/opencode`
- `bat`
- `glow`
- `TeX distribution`

## To recover the system

Unsure `git` is installed and ssh git key.

```bash
ssh-keygen -t ed25519 -C "mac-2"
# accept the default path; set a passphrase if you want one

eval "$(ssh-agent -s)"
ssh-add --apple-use-keychain ~/.ssh/id_ed25519

pbcopy < ~/.ssh/id_ed25519.pub
# paste at github.com/settings/keys → New SSH key
```

Check if its alright:

```bash
ssh -T git@github.com
# → Hi Oscar-Cabr! You've successfully authenticated...
```

```bash
git clone --bare --single-branch --branch macos \
    git@github.com:Oscar-Cabr/Dotfiles.git $HOME/.dotfiles
```

### Per-clone settings

Define temporal alias:

```bash
dotfiles() { git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"; }
```

```bash
dotfiles config --local status.showUntrackedFiles no
dotfiles config --local push.default current
dotfiles config --local --replace-all remote.origin.fetch '+refs/heads/macos:refs/remotes/origin/macos'
dotfiles checkout macos
```
