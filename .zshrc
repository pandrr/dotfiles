alias teamops="cd /Users/tom/cables_dev/cables/src/ops/teams"
alias c="cd /Users/tom/cables_dev/"
alias cc="cd /Users/tom/cables_dev/cables"
alias ui="cd /Users/tom/cables_dev/cables_ui"
alias api="cd /Users/tom/cables_dev/cables_api"
alias ext="cd /Users/tom/cables_dev/cables/src/ops/extensions"

alias d="cd"
alias gs="git status"
alias gsr="gitr status"
alias gc="git checkout"
alias gps="git push"
alias gpl="git pull"
alias g="lazygit"

alias ..="cd .."
alias ls="ls -G"
alias h="hx"
alias vi="nvim"

export GIT_EDITOR=hx
export EDITOR=hx


source <(fzf --zsh)

export FZF_DEFAULT_COMMAND='find . -type d \( -name node_modules -o -name .git \) -prune -o -type f -print'

function git_branch()
{
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'

}

#yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}


setopt PROMPT_SUBST

PROMPT='%F{#FFFFFF}%K{#8888AA} horst6 %k%F{#888888} %5/%F{cyan}$(git_branch) %F{yellow}›%f%k'
#alias python=/opt/homebrew/bin/python3

#export VBCC=~/dev/vbcc
#export PATH=/Users/tom/dev/vbcc/bin:$PATH

#export NDK=~/dev/vbcc/NDK_3.2
#export NDK_INC=$NDK/include/include_h
#export NDK_LIB=$NDK/linker_libs



# pnpm
export PNPM_HOME="/Users/tom/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end


gitr () {
  for f in $(find . -type d -name .git | awk -F"/.git$" '{print $1}');  do
    echo
    echo "................................ (cd $f && git $*) ........................................."
    echo
    (cd $f && git $*)
  done
}



# Added by Windsurf
export PATH="/Users/tom/.codeium/windsurf/bin:/Users/tom/bin/:$PATH"




#set history size
export HISTSIZE=10000
#save history after logout
export SAVEHIST=10000
#history file
export HISTFILE=~/.zhistory
#append into history file
setopt INC_APPEND_HISTORY
#save only one command if 2 common are same and consistent
setopt HIST_IGNORE_DUPS
#add timestamp for each entry
setopt EXTENDED_HISTORY
#//alias history='history 1'

export PODMAN_COMPOSE_PROVIDER="/opt/homebrew/bin/podman-compose"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/tom/.cache/lm-studio/bin"
# End of LM Studio CLI section

