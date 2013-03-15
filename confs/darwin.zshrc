export PATH="$PATH:$HOME/bin:$HOME/bin/osx-bin"
export ANSIBLE_TRANSPORT='ssh'

#{{{ misc
# fun from zshguide
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
autoload -U compinit && compinit
setopt share_history

#}}}

#{{{ directory shortcuts
p=~/proj/clojure-sandbox/src/clojure_sandbox
j=~/Documents/notes/journal
s=~/Documents/notes-scholarly
n=~/Documents/notes
sc=~/Documents/scripts
d=~/Documents/scripts/sh/dns
gsl=~/Sites/gsl.local/www
b=~/quickcue-bucket
w=/Library/WebServer/Documents
c=~/proj/clojure-sandbox
#}}}

#{{{ alii
alias clj='rlwrap clj'
alias mvim='mvim --remote-tab '
alias vi='mvim'
alias vim='vi'
#alias ssh='ssh -R 38383:localhost:22'
alias b='git branch -avv'
alias s='git status'
alias gc='git checkout'
alias gl='git log --date=local --pretty=format:"%Cblue%s%Creset / %Cred%h%Creset%n    son of %p / on tree %t / %ad%n    author: %an%n    committer: %cn%n"'
#alias -r sroot='sudo su -c /bin/zsh -c 'cd $PWD''
alias ls='ls -GF'
alias la='ls -lahGF'
alias ll='ls -lhGF'
alias l='la'
alias rm='rm -i'
alias grep='grep --color=auto'
alias lg='ls -lah | grep -i'
alias pg='ps aux | grep -i'
alias g='ls -a | xargs grep --color=auto ';
alias p='/Applications/MacVim.app/Contents/Resources/vim/runtime/macros/less.sh'
#}}}

# {{{ colors
# for black background
# LSCOLORS=gxxecxdxcxegedabagacad
# for white/gray bg
LSCOLORS=exxxcxdxcxegedabagacad
export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lz=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36:'

# for /bin/less
export LESS_TERMCAP_us=$'\e[32m'  
export LESS_TERMCAP_ue=$'\e[0m'  
export LESS_TERMCAP_md=$'\e[1;31m'  
export LESS_TERMCAP_me=$'\e[0m'  
export LESS=-R

# }}}

#{{{ Dir Push/Pop
DIRSTACKSIZE=30
setopt AUTO_PUSHD
setopt PUSHD_MINUS
setopt PUSHD_SILENT
setopt PUSHD_TO_HOME
setopt PUSHD_IGNOREDUPS
alias -- +='pushd +0'
alias -- -='pushd -1'
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
bindkey "^[b" vi-backward-word
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

# {{{ prompt/tab-title
# PS1=$(print '%{\e[0;32m%}%/ %% %{\e[0m%}')
# RPS1=$(print '%{\e[0;32m%}%n@%m %? %{\e[0m%}')
PS1=$(print '%{\e[0;0m%}%/ %% %{\e[0m%}')
RPS1=$(print '%{\e[0;0m%}%n@%m %? %{\e[0m%}')
TERM=xterm-256color
HOSTNAME=`hostname`;
 function precmd {
     printf "\e]1;${HOSTNAME}\a";
 }
# }}}

#{{{ extract function
extract () {
   if [ -f $1 ] ; then
       case $1 in
	*.tar.bz2)	tar xvjf $1 && cd $(basename "$1" .tar.bz2) ;;
	*.tar.gz)	tar xvzf $1 && cd $(basename "$1" .tar.gz) ;;
	*.tar.xz)	tar Jxvf $1 && cd $(basename "$1" .tar.xz) ;;
	*.bz2)		bunzip2 $1 && cd $(basename "$1" /bz2) ;;
	*.rar)		unrar x $1 && cd $(basename "$1" .rar) ;;
	*.gz)		gunzip $1 && cd $(basename "$1" .gz) ;;
	*.tar)		tar xvf $1 && cd $(basename "$1" .tar) ;;
	*.tbz2)		tar xvjf $1 && cd $(basename "$1" .tbz2) ;;
	*.tgz)		tar xvzf $1 && cd $(basename "$1" .tgz) ;;
	*.zip)		unzip $1 && cd $(basename "$1" .zip) ;;
	*.Z)		uncompress $1 && cd $(basename "$1" .Z) ;;
	*.7z)		7z x $1 && cd $(basename "$1" .7z) ;;
	*)		echo "don't know how to extract '$1'..." ;;
       esac
   else
       echo "'$1' is not a valid file!"
   fi
 }
#}}}
