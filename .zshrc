eval "$(starship init zsh)"
eval "$(gh completion -s zsh)"

alias ls='ls --color=auto -ahF'
alias ll='ls -lh'
alias cat='bat --paging=never'
alias find='fd'
alias update='sudo pacman -Syu'
alias hour="/usr/bin/date +'%H:%M:%S.%N (UTC%:z)'"
alias datenow="date +'%A, %B %d of %Y - %H:%M:%S'"
alias battery='cat /sys/class/power_supply/BAT1/capacity'
alias wifi1='ping -c 3 192.168.1.254'
alias wifi2='ping -c 3 1.1.1.1'
alias wifi3='ping -c 3 archlinux.org'
alias restartWifi='sudo systemctl restart wpa_supplicant@wlp3s0.service'
alias whatsapp='chromium --app=https://web.whatsapp.com --enable-features=UseOzonePlatform --ozone-platform=wayland &'
alias webSpotify='chromium --app=https://open.spotify.com/intl-es --enable-features=UseOzonePlatform --ozone-platform=wayland &'
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt hist_ignore_dups
setopt share_history
setopt append_history

setfont ter-m22n

export KITTY_ENABLE_WAYLAND=1
export QT_QPA_PLATFORMTHEME=qt6ct

neofetch
