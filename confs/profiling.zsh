# Optional zsh startup profiling. Load this near the top of .zshrc.

zmodload zsh/zprof || return

_zsh_profile_report() {
  emulate -L zsh
  zprof
}

autoload -Uz add-zsh-hook
add-zsh-hook zshexit _zsh_profile_report
