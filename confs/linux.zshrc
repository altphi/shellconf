PATH=$PATH:/usr/local/sbin:$HOME/bin

export EDITOR=vi
export GIT_EDITOR=vi

#{{{ misc
zmodload -i zsh/complist
bindkey '^i' expand-or-complete
zstyle ':completion:*' menu select=2
bindkey -M menuselect '^o' accept-and-infer-next-history
setopt AUTO_MENU
setopt AUTO_CD
setopt CDABLE_VARS
setopt SHARE_HISTORY
setopt nohup
GREP_OPTIONS='--binary-files=without-match --directories=skip'
unset MANPATH
unset PAGER
autoload -U compinit && compinit
#}}} 

#{{{ alii
alias ls='ls -F -b -T 0 --color=auto'
alias ll='ls -F -b -T 0 --color=auto -la'
alias b='git branch -avv'
alias s='git status'
alias gc='git checkout'
alias gl='git log --date=local --pretty=format:"%Cblue%s%Creset / %Cred%h%Creset%n    son of %p / on tree %t / %ad%n    author: %an%n    committer: %cn%n"'
alias la='ls -lah'
alias l='la'
alias grep='grep --color=auto'
alias lg='ls -lah | grep'
alias psg='ps ax | grep'
alias g='ls -a | xargs grep --color=auto'
alias e='emacs'
#alias ip_list="ifconfig | grep 'inet addr:' | perl -p -e 's/^.*?://g' | perl -p -e 's/ .*$//g'"
#}}}

#{{{ directory shortcuts
b=/content/quickcue-bucket
w=/www/html
c=/coptix/admin/config
r=/var/radmind/client
q=/home/qfilter/domains
d=/home/dnsrep/data
#}}}


#{{{ colors
eval `dircolors`
#}}}

#{{{ completion
zstyle ':completion:*' list-colors '${LSCOLORS}'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

autoload -U incremental-complete-word
zle -N incremental-complete-word

function beginning-incremental-search {
    if [[ $LASTWIDGET == $WIDGET ]]
    then zle .$WIDGET
    else zle .$WIDGET $LBUFFER
    fi
}
zle -N history-incremental-search-backward beginning-incremental-search
zle -N history-incremental-search-forward beginning-incremental-search

# complete SSH hosts
local _myhosts
_myhosts=( ${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[0-9]*}%%\ *}%%,*} )
zstyle ':completion:*' hosts $_myhosts
#}}}

#{{{ key bindings                                                                                        
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
#}}}

#{{{ watch settings
watch=( all )
WATCHFMT="%S%n@%m %a %l at %T on %W%s"
LOGCHECK=0
#}}}

#{{{ prompt/tab-title
PS1=$(print '%{\e[0;0m%}%/ %% %{\e[0m%}')
RPS1=$(print '%{\e[0;0m%}%n@%m %? %{\e[0m%}')
HOSTNAME=`hostname`
function precmd {
	printf "\e]1;${HOSTNAME}\a";
}
TERM=xterm-256color
#}}}
