# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    zsh-syntax-highlighting
    zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# fzf
source <(fzf --zsh)
alias f=fzf
# preview with bat
alias fp='fzf --preview="bat --color=always {}"'
# open neovim with select file by tab
alias fv='nvim $(fzf -m --preview="bat --color=always {}")'


# my alias for an easier life
alias v=nvim
alias vim=nvim
alias nv=nvim
alias ovim=vim
alias os='nvim ~/.zshrc'
alias ss='source ~/.zshrc'
alias k='kubectl'
alias kp="kubectl port-forward"
alias kaf="kubectl apply -f"
alias kdf="kubectl delete -f"
alias kcc="kubectl config current-context"
alias kctx="kubectl config use-context"
alias kctxs="kubectl config get-contexts"
alias kctxl="kubectl config list-contexts"
alias kctxd="kubectl config delete-context"
alias kctxu="kubectl config use-context"
alias hi='helm install'
alias hu='helm update'
alias h='helm'
alias hg='helm get'
alias hgs='helm get status'
alias hgd='helm get delete'
alias hgp='helm get pods'
alias hgns='helm get nodes'
alias hgns='helm get nodes'

alias gr=./gradlew
# source tmux
alias stm='tmux source-file ~/.tmux.conf \;'
# confirm before remove something... fk.
alias rm="rm -i"
# PATH
export PATH="/opt/homebrew/share/android-commandlinetools/cmdline-tools/latest/bin:$PATH"
export JAVA_HOME=$(/usr/libexec/java_home -v 23)
export PATH=$JAVA_HOME/bin:$PATH
alias vcf="cd ~/.config/nvim && nvim"
alias python=python3
alias dc=docker-compose
alias lzd=lazydocker
# fetch then allow to fuzzy finding branches
alias gcof='git fetch && git checkout $(git branch | fzf | sed "s/^..//")'
# push with set upstream for the current branch
gpup() {
  branch=$(git rev-parse --abbrev-ref HEAD)
  git push --set-upstream origin "$branch"
}
opg() {
  local base="$HOME/Documents/git"
  local dir
  dir=$(find "$base" -mindepth 1 -maxdepth 1 \( -type d -o -type l \) -exec test -d {} \; -print | fzf)
  if [[ -n "$dir" ]]; then
    cd "$dir"
  else
    cd "$base"
  fi
}
op() {
  local user_dir="$HOME"
  local dir
  dir=$(find "$user_dir" -mindepth 1 -maxdepth 1 -type d  ! -name '.*' | fzf) && cd "$dir"
}
# quick session
qss() {
  local dotfiles_dir="$HOME/dotfiles"
  local git_base="$HOME/Documents/git"

  if ! tmux has-session -t setting 2>/dev/null; then
    tmux new-session -d -s setting -c "$dotfiles_dir"
  fi

  local dir
  local base="$HOME/Documents/git"

  dir=$(find "$base" -mindepth 1 -maxdepth 1 -type d ! -name '.*' | fzf)

  local name="$(basename "$dir")"

  if ! tmux has-session -t "$name" 2>/dev/null; then
    tmux new-session -d -s "$name" -c "$dir"
  fi
   if [[ -n "$TMUX" ]]; then
    tmux switch-client -t "$name"
  else
    tmux attach-session -t "$name"
  fi       
}
bindkey -v


. "$HOME/.cargo/env"
eval "$(atuin init zsh)"
export PATH=/usr/local/bin:$PATH