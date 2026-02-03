# Dotfiles

Personal dotfiles repository for my Arch Linux (I use Arch, btw) setup.

This repo manages my whole custom environment using a **bare Git repository** with '$HOME' as the working tree.

---

## Overview

The general system where this is running:

- OS: Arch Linux
- Shell: zsh
- WM: Hyprland
- Notification center: Sway.

All the elements this repo manages (that could be also considered as requisites) can be listed as follows:

- Whole modular `Hyprland` base configuration.
- Hypr-Ecosystem! `hypridle`, `hyprlock` and `hyprpaper`.
- `nvim` files editor with `lazy.nvim`.
- `kitty` terminal emulator.
- `waybar` config.
- `wofi` configuration for applitacion manager.
- `fuzzel` configuration to work as clipboard.
- `starship` prompt.
- `eww` custom widgets.

Other necessary things involved in the environment:

- `xpdf` pdf viewer.
- `feathernotes` note application.
- `.fnx` feathernotes template. (Documents/Notas/template.fnx)
- `theme` directory. (.config/theme/)
- Necessary `icons` collection for the theme. (.config/icons/)
- Necessary custom `shell scripts` for updating environments. (.config/sh-scripts/)

---

## Installation

Clone the repository as a **bare repo**:

```bash
git clone --bare https://github.com/Oscar-Cabr/Dotfiles.git $HOME/.dotfiles
```

Define the alias.

```bash
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
```

Hide untracked files:

```bash
dotfiles config --local status.showUntrackedFiles no
```

---

## Usage

Once the alias is set up, you can replace the *git* word to *dotfiles* in your workflow and use it as you would usually do:

*dotfiles status*, *dotfiles add file*, *dotfile commit -m "my commit"*, *dotfile push*...

> [!WARNING]  
> Do never use *dotfiles add .* since this' a bare repository.

### To restore the system

In the new machine:

```bash
git clone --bare git@github.com:TUUSUARIO/dotfiles.git $HOME/.dotfiles
```

Define alias:

```bash
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
```

Hide untracked:

```bash
dotfiles config --local status.showUntrackedFiles no
```

Finally, chekcout:

```bash
dotfiles checkout
```

If there's any conflict while doing so:

```bash
dotfiles checkout -b laptop
dotfiles add ~/.config/hypr/monitors.conf
dotfiles commit -m "Laptop monitor layout"
```

---

## Info. about bare repos

When managing dotfiles with a bare repository, you cannot use normal `git` commands **directly**, because the working directory is not inside a repository.

To solve this, we create a Git alias that tells Git two things every time it runs:

1. Where the bare repository (usually, the `.git` directory) lives. `--git-dir=$HOME/.dotfiles/`
2. Where the working tree (your real files) is. `--work-tree=$HOME`
