alias ls='ls --color=auto -ahF'
alias cat='bat --paging=never'

eval "$(starship init zsh)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# --- dotfiles (bare repo, work tree = $HOME) ---
dotfiles() {
  case "$1" in
    clean) print -u2 "dotfiles clean is forbidden in a \$HOME work tree"; return 1 ;;
    add)
      for arg in "${@:2}"; do
        [[ "$arg" == "-A" || "$arg" == "--all" || "$arg" == "." ]] && \
          { print -u2 "refusing bulk add in \$HOME — name paths explicitly"; return 1; }
      done
      ;;
    checkout|switch)
      [[ "$*" == *main* ]] && { print -u2 "refusing: main is the Arch branch"; return 1; }
      ;;
  esac
  git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"
}
