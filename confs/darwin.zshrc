[[ $EMACS = t ]] && unsetopt zle
bindkey -v

j=~/Documents/notes/journal
s=~/Documents/notes-scholarly
n=~/Documents/notes
sc=~/Documents/scripts
d=~/Documents/scripts/sh/dns
gsl=~/Sites/gsl.local/www
b=/Library/WebServer/Documents/blosxom
bd=/Library/WebServer/Data/Blosxom
cgi=/Users/stephen/Sites/cgi-bin
w=/Library/WebServer/Documents

#alias vim='mvim --remote-tab '
#alias vi='mvim --remote-tab '
#alias ssh='ssh -R 38383:localhost:38383'
alias b='git branch -av'
alias s='git status'
alias -r sroot='sudo su -c /bin/zsh -c 'cd $PWD''
alias ls='ls -GF'
alias la='ls -lahGF'
alias ll='ls -lhGF'
alias rm='rm -i'
alias grep='grep --color=auto'
alias lg='ls -lah | grep -i'
alias psg='ps aux | grep -i'
#alias g='ls -a | xargs grep --color=auto ';
alias g='cat LatinVocab.txt | grep -i'
alias p='/Applications/MacVim.app/Contents/Resources/vim/runtime/macros/less.sh'

alias emacs='/Applications/Emacs.app/Contents/MacOS/bin/emacs -nw'
alias e='emacs'

# for black background
# LSCOLORS=gxxecxdxcxegedabagacad
# for white/gray bg
LSCOLORS=exxxcxdxcxegedabagacad

GREP_OPTIONS='--binary-files=without-match --directories=skip'

export MAGICK_HOME="/opt/local/ImageMagick-6.3.4"
export DYLD_LIBRARY_PATH="$MAGICK_HOME/lib"
export PATH="$MAGICK_HOME/bin:$PATH"
export PATH="/usr/texbin:$HOME/bin:$PATH"
export PATH="$PATH:/opt/local/bin:/opt/local/sbin:/Applications/DjView.app/Contents/bin"


export MGIT_PATH="/Users/stephen/cx/mgit"

#PS1=$(print '%{\e[0;32m%}%/ %% %{\e[0m%}')
#RPS1=$(print '%{\e[0;32m%}%n@%m %? %{\e[0m%}')
PS1=$(print '%{\e[0;0m%}%/ %% %{\e[0m%}')
RPS1=$(print '%{\e[0;0m%}%n@%m %? %{\e[0m%}')
TERM=xterm-color
unset MANPATH

#case $TERM in
#	xterm*)
#	 precmd () { echo -n -e "\033k\033\\" }
#	;;
#esac

setopt AUTO_CD
# setopt CDABLE_VARS

DIRSTACKSIZE=30
setopt AUTO_PUSHD
setopt PUSHD_MINUS
setopt PUSHD_SILENT
setopt PUSHD_TO_HOME
setopt PUSHD_IGNOREDUPS
alias -- +='pushd +0'
alias -- -='pushd -1'

pman()
{
man -t "${1}" | open -f -a /Applications/Preview.app/
}


# fun from zshguide
zmodload -i zsh/complist
bindkey '^i' expand-or-complete
zstyle ':completion:*' menu select=2
bindkey -M menuselect '^o' accept-and-infer-next-history
setopt AUTO_MENU

setopt SHARE_HISTORY
setopt nohup

zstyle ':completion:*' list-colors '${LSCOLORS}'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

autoload -U incremental-complete-word
zle -N incremental-complete-word

# autoload -U  predict-on
# zle -N predict-on
# zle -N predict-off
# predict-on
# bindkey '^Z'   predict-on
# bindkey '^Xz' predict-off
# zstyle ':predict' toggle true
# zstyle ':predict' verbose true

function beginning-incremental-search {
	if [[ $LASTWIDGET == $WIDGET ]]
	then zle .$WIDGET
	else zle .$WIDGET $LBUFFER
	fi
}
zle -N history-incremental-search-backward beginning-incremental-search
zle -N history-incremental-search-forward beginning-incremental-search

#bindkey '^;' insert-last-word
bindkey '^x^n' infer-next-history

# complete SSH hosts
local _myhosts
_myhosts=( ${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[0-9]*}%%\ *}%%,*} )
zstyle ':completion:*' hosts $_myhosts

#export MANPAGER="col -b | view -c 'set ft=man nomod nolist' -"
export RLWRAP_EDITOR="vim +%L"


bindkey -v

bindkey "^[_" insert-last-word
bindkey "^[b" backward-word
bindkey "^[c" capitalize-word
bindkey "^[d" kill-word
bindkey "^[f" forward-word
bindkey "^[l" down-case-word
bindkey "^[u" up-case-word
bindkey "^[w" copy-region-as-kill

bindkey "^_" undo
bindkey "^?" backward-delete-char

bindkey "^[^H" backward-kill-word
bindkey "^[D" kill-word
bindkey "^[F" forward-word
bindkey "^[B" backward-word
bindkey "^[C" capitalize-word

bindkey "^[OA" up-line-or-history
bindkey "^[OB" down-line-or-history
bindkey "^[OC" forward-char
bindkey "^[OD" backward-char
bindkey "^[U" up-case-word
bindkey "^[W" copy-region-as-kill
bindkey "^[[A" up-line-or-history
bindkey "^[[B" down-line-or-history
bindkey "^[[C" forward-char
bindkey "^[[D" backward-char

bindkey "^A" beginning-of-line
bindkey "^B" backward-char
bindkey "^D" delete-char-or-list
bindkey "^E" end-of-line
bindkey "^G" send-break
bindkey "^H" backward-delete-char
bindkey "^I" expand-or-complete
bindkey "^L" clear-screen
bindkey "^K" kill-line
bindkey "^P" up-line-or-history
bindkey "^R" history-incremental-search-backward
bindkey "^Y" yank

