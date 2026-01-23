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

- Whole modular <pre>Hyprland</pre> base configuration.
- Hypr-Ecosystem! <pre>hypridle</pre>, <pre>hyprlock</pre> and <pre>hyprpaper</pre>.
- <pre>nvim</pre> files editor with <pre>lazy.nvim</pre>.
- <pre>kitty</pre> terminal emulator.
- <pre>waybar</pre> config.
- <pre>wofi</pre> configuration for applitacion manager.
- <pre>fuzzel</pre> configuration to work as clipboard.
- <pre>starship</pre> prompt.
- <pre>eww</pre> custom widgets.
- <pre>theme</pre> directory.
- Necessary <pre>icons</pre> collection for the theme.
- Necessary custom <pre>shell scripts</pre> for updating environments.

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

When managing dotfiles with a bare repository, you cannot use normal <pre>git</pre> commands **directly**, because the working directory is not inside a repository.

To solve this, we create a Git alias that tells Git two things every time it runs:

1. Where the bare repository (usually, the <pre>.git</pre> directory) lives. <pre>--git-dir=$HOME/.dotfiles/</pre>
2. Where the working tree (your real files) is. <pre>--work-tree=$HOME</pre>
