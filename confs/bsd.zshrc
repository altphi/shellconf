GIT_EDITOR=vi
unset PAGER
alias -r sroot='sudo su -c /bin/zsh -c 'cd $PWD''
# eval `dircolors -z`
# LS_COLORS=`echo ${LS_COLORS} | sed -e 's/di\=01\;34\:ln\=01\;36/di\=01\;36\:ln\=44\;37/'`;
LS_OPTIONS='-F -b -T 0 --color=auto'
alias b='git branch -av'
alias l='ls'
alias ls='ls -G'
alias la='ls -lah'
alias grep='grep --color=auto'
alias lg='ls -lah | grep'
alias psg='ps ax | grep'
alias g='ls -a | xargs grep --color=auto'
alias e='emacs'
alias ip_list="ifconfig | grep 'inet addr:' | perl -p -e 's/^.*?://g' | perl -p -e 's/ .*$//g'"

w=/www/html
c=/coptix/admin/config
r=/var/radmind/client
q=/home/qfilter/domains
d=/home/dnsrep/data

setopt AUTO_CD
#setopt CDABLE_VARS

DIRSTACKSIZE=30
setopt AUTO_PUSHD
setopt PUSHD_MINUS
setopt PUSHD_SILENT
setopt PUSHD_TO_HOME
setopt PUSHD_IGNOREDUPS
alias -- +='pushd +0'
alias -- -='pushd -1'

watch=( all )
WATCHFMT="%S%n@%m %a %l at %T on %W%s"
LOGCHECK=0

#case $TERM in
#	xterm*)
#	precmd () {print -Pn "\e]0;%m"}
#	;;
#esac

# fun from zshguide


zmodload -i zsh/complist
bindkey '^i' expand-or-complete
zstyle ':completion:*' menu select=2
bindkey -M menuselect '^o' accept-and-infer-next-history

setopt SHARE_HISTORY
setopt nohup

zstyle ':completion:*' list-colors '${LSCOLORS}'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

autoload -U incremental-complete-word 
zle -N incremental-complete-word

#autoload -U  predict-on
#zle -N predict-on
#zle -N predict-off
#predict-on
#bindkey '^Z'   predict-on
#bindkey '^Xz' predict-off
#zstyle ':predict' toggle true
#zstyle ':predict' verbose true
#zle-line-init() { predict-on }
#zle -N zle-line-init

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
