alias jl=" jj log -r 'fork_point(@ | trunk())::@'"
alias jll=" jj log"
alias je=' jj edit'
alias jd=' jj describe'
alias jc=' jj commit'
alias jb=' jj bookmark'
alias jbl=" jj bookmark list"
alias jbl-untracking=" comm -23  <(jj bookmark list -T 'name ++ \"\n\"' | sort -u)  <(jj bookmark list --tracked -T 'name ++ \"\n\"' | sort -u)"
alias js=" jj st"
alias jl-unmerged=" jj log -r 'mine() & ~::trunk()'"
alias jl-unpushed=" jj log -r 'mine() & ~::remote_bookmarks()'"
alias jl-heads-mine=" jj log -r 'heads(mine())'"
alias jl-heads-all=" jj log -r 'heads(all())'"
alias jj-abandon-empty=" jj abandon -r 'empty() & mutable() & ~@'"

jn() {
    if (( $# == 0 )); then
      jj new
    else
      local msg="$1"; shift
      jj new -m "$msg" "$@"
    fi
  }


_jj_bookmarks_local() {
    local -a bookmarks
    bookmarks=(${(f)"$(jj bookmark list -T 'name ++ "\n"' 2>/dev/null)"})
    _arguments "1:bookmark:($bookmarks)"
  }

_jj_bookmarks_all() {
  local -a bookmarks
  bookmarks=(${(f)"$(jj bookmark list --all-remotes -T 'if(remote == "git", "", if(remote, name ++ "@" ++ remote, name) ++ "\n")' 2>/dev/null)"})
  _arguments "1:bookmark:($bookmarks)"
}

jj-push() {
    local bookmark="$1"
    if [[ -z "$bookmark" ]]; then
      echo "usage: jj-push <bookmark>" >&2
      return 1
    fi
    jj bookmark set "$bookmark" -r @ && jj git push -b "$bookmark"
}
compdef _jj_bookmarks_local jj-push

jl-bookmark() {
  local b="${1:?bookmark name required}"
  jj log -r "fork_point($b | trunk())::$b"
}
compdef _jj_bookmarks_all jl-bookmark

jl-origin() {
  local b="${1:?bookmark required}"
  echo "─ closest bookmarks containing fork point ─"
  jj bookmark list -r "roots(bookmarks() & fork_point($b | trunk())::)"
  echo
  echo "─ all bookmarks containing fork point ─"
  jj bookmark list -r "fork_point($b | trunk())::"
}
compdef _jj_bookmarks_all jl-origin

jl-contains() {
  local c="${1:?commit/revision required}"
  echo "─ closest bookmarks containing $c ─"
  jj bookmark list -r "roots(bookmarks() & $c::)"
  echo
  echo "─ all bookmarks containing $c ─"
  jj bookmark list -r "$c::"
}

# creates a PR for an already-pushed jj bookmark, linked to a CLT issue
# accepted issue forms:
#   123                       -> classiclearning/issues#123
#   tigger#123                -> classiclearning/tigger#123
#   issues#123                -> classiclearning/issues#123
#   someorg/somerepo#123      -> someorg/somerepo#123
ghpr() {
    local input="$1"
    local target="${2:-staging}"

    if [[ -z "$input" ]]; then
      echo "usage: ghpr [<repo>#]<issue-number> [target=staging]" >&2
      return 1
    fi

    local repo issue
    if [[ "$input" == *"#"* ]]; then
      repo="${input%#*}"
      issue="${input#*#}"
      [[ "$repo" != */* ]] && repo="classiclearning/$repo"
    else
      repo="classiclearning/issues"
      issue="$input"
    fi

    local bookmark
    bookmark=$(jj bookmark list -T 'self.name() ++ "\n"' | rg -- "$issue")
    if [[ -z "$bookmark" ]]; then
      echo "error: no bookmark found for issue $issue" >&2
      return 1
    fi
    if [[ $(echo "$bookmark" | wc -l) -gt 1 ]]; then
      echo "error: multiple bookmarks match issue $issue:" >&2
      echo "$bookmark" >&2
      return 1
    fi

    local description
    description=$(gh issue view "$issue" --repo "$repo" --json title -q .title) ||
  return 1
    if [[ -z "$description" ]]; then
      echo "error: could not fetch title for issue $issue" >&2
      return 1
    fi

    gh pr create \
      -B "$target" \
      -H "$bookmark" \
      -t "$repo#$issue: $description" \
      -b "closes $repo#$issue"
}

_jj_prompt() {
    local info upstream_status output nearest distance

    # Single jj call: walk from nearest bookmark ancestor up to @.
    # Bookmark commit renders its name (with "*" suffix if ahead of remote);
    # intermediate commits render "·" so we can count lines reliably.
    # latest(..., 1) keeps it deterministic when multiple bookmarks sit at the
    # same DAG level on parallel branches.
    output=$(jj log -r 'latest(::@ & bookmarks(), 1)::@' \
        --no-graph --ignore-working-copy --reversed \
        -T 'if(local_bookmarks, local_bookmarks, "·") ++ "\n"' 2>/dev/null) || return

    if [ -n "$output" ]; then
        local -a lines=("${(@f)output}")
        distance=$((${#lines} - 1))
        nearest="${lines[1]}"
        case "$nearest" in
            *\*) upstream_status=" ↑"; nearest="${nearest%\*}" ;;
            *)   upstream_status="" ;;
        esac
        if [ "$distance" -eq 0 ]; then
            info="$nearest"
        else
            info="$nearest +$distance"
        fi
    else
        # No bookmark ancestor; show change_id + state indicators
        info=$(jj log -r @ --no-graph --ignore-working-copy \
            -T 'change_id.shortest() ++ if(empty, " ∅") ++ if(conflict, " ⚠") ++ if(divergent, " ⑂")' \
            2>/dev/null) || return
        upstream_status=""
    fi

    printf '[%s%s]' "$info" "$upstream_status"
}
