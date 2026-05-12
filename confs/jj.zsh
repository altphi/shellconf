alias jl=" jj log -r 'fork_point(@ | trunk())::@'"
alias jll=" jj log"
alias jlll=" jj log -r 'all()'"
alias je=' jj edit'
unalias jbl 2>/dev/null
jbl() {
  jj --color=always bookmark list -a -T '
    if(remote,
      if(tracked && remote != "git",
        " → " ++ label("bookmark remote_bookmark", "@" ++ remote),
        ""
      ),
      "\n" ++ label("bookmark local_bookmark", name) ++ ": "
        ++ separate(" ",
          normal_target.change_id().shortest(8),
          normal_target.commit_id().shortest(8),
          normal_target.description().first_line()
        )
    )
  ' "$@" | awk 'NF'
}
alias jbl-untracking=" comm -23  <(jj bookmark list -T 'name ++ \"\n\"' | sort -u)  <(jj bookmark list --tracked -T 'name ++ \"\n\"' | sort -u)"
alias js=" jj st"
alias jl-unmerged=" jj log -r 'mine() & ~::trunk()'"
alias jl-unpushed=" jj log -r 'mine() & ~::(remote_bookmarks() | tags())'"
alias jl-heads-mine=" jj log -r 'heads(mine())'"
alias jl-heads-all=" jj log -r 'heads(all())'"
alias jl-wip=" jj log -r 'mine() & mutable()'"
alias jj-abandon-empty=" jj abandon -r 'empty() & mutable() & ~@'"

jj-abandon-unowned-orphan-revs() {
  local revset='~mine() & ~::remote_bookmarks()'
  local preview
  preview=$(jj log -r "$revset" --no-graph --ignore-working-copy \
            -T 'change_id.shortest() ++ "\n"' 2>/dev/null)
  if [[ -z "$preview" ]]; then
      echo "nothing to abandon."
      return 0
  fi
  jj log -r "$revset"
  local reply
  read "reply?abandon these commits? [y/N] "
  if [[ "$reply" == (y|Y|yes|YES) ]]; then
      jj abandon -r "$revset"
  else
      echo "aborted."
      return 1
  fi
}

jj-abandon-revs-for-untracking-bookmark() {
  local b="${1:?bookmark name required}"

  if jj bookmark list --tracked | grep -q "$b" ; then
    echo "bookmark $b is tracked."
    return 1
  fi

  local revset="::${b} & mutable() & ~::trunk()"
  jj log -r "$revset"

  local reply
  read "reply?abandon these commits and bookmark ${b}? [y/N] "
  if [[ "$reply" == (y|Y|yes|YES) ]]; then
    jj abandon -r "$revset"
  else
    echo "aborted."
    return 1
  fi
}
compdef _jj_push jj-abandon-revs-for-untracking-bookmark

_jj_bookmark_names() {
  jj bookmark list --all-remotes \
    -T 'if(remote == "git", "", if(remote, name ++ "@" ++ remote, name) ++ "\n")' \
    2>/dev/null
}

_jj_bookmarks_all() {
  local -a bookmarks
  bookmarks=(${(f)"$(_jj_bookmark_names)"})
  _arguments "1:bookmark:($bookmarks)"
}

_jj_push() {
    local -a bookmarks
    bookmarks=(${(f)"$(jj bookmark list -T 'name ++ "\n"' 2>/dev/null)"})
    _arguments \
      "1:bookmark:($bookmarks)" \
      "2::revision: "
  }

jj-push() {
    local bookmark="$1"
    local rev="${2:-@}"
    if [[ -z "$bookmark" ]]; then
      echo "usage: jj-push <bookmark> [revision]" >&2
      return 1
    fi
    jj bookmark set "$bookmark" -r "$rev" && jj git push -b "$bookmark"
}
compdef _jj_push jj-push

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

# creates a PR for an already-pushed jj bookmark.
# opens $EDITOR pre-populated with concatenated commit descriptions and any
# detected "closes <org>/<repo>#<n>" lines. first non-comment line becomes the
# PR title; everything after the first blank line becomes the body.
# target = repo's GitHub default branch unless overridden.
unalias ghpr-create 2>/dev/null
ghpr-create() {
    local bookmark="$1"
    local target="$2"

    if [[ -z "$bookmark" ]]; then
      echo "usage: ghpr-create <bookmark> [target]" >&2
      return 1
    fi

    if [[ -z "$(jj bookmark list "$bookmark" -T 'name ++ "\n"' 2>/dev/null)" ]]; then
      echo "error: bookmark '$bookmark' not found" >&2
      return 1
    fi

    if [[ -z "$target" ]]; then
      target=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name) || return 1
    fi

    local revset="fork_point($bookmark | trunk())..$bookmark"
    local descriptions
    descriptions=$(jj log -r "$revset" --no-graph -T 'description ++ "\n"' 2>/dev/null)
    if [[ -z "$descriptions" ]]; then
      echo "error: no commits found in $revset" >&2
      return 1
    fi

    local refs
    refs=$(echo "$descriptions" \
        | grep -oE '[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+#[0-9]+' \
        | sort -u)

    local tmpfile
    tmpfile=$(mktemp --suffix=.PR_EDITMSG) || return 1
    {
      echo "$descriptions"
      if [[ -n "$refs" ]]; then
        echo
        echo "$refs" | sed 's/^/closes /'
      fi
      echo
      echo "# Editing PR for bookmark '$bookmark' -> $target"
      echo "# First non-empty, non-comment line is the PR title."
      echo "# Everything after the first blank line is the body."
      echo "# Lines starting with '#' are stripped. Save empty title to abort."
      echo "#"
      echo "# Commits in this branch:"
      jj log -r "$revset" --no-graph \
        -T 'commit_id.shortest(8) ++ " " ++ description.first_line() ++ "\n"' 2>/dev/null \
        | sed 's/^/# /'
    } > "$tmpfile"

    "${EDITOR:-vi}" "$tmpfile" || { rm -f "$tmpfile"; return 1; }

    local title body
    title=$(awk '!/^#/ && NF { print; exit }' "$tmpfile")
    body=$(awk '
        /^#/ { next }
        !title_seen { if (NF) title_seen=1; next }
        { print }
    ' "$tmpfile" | sed '/./,$!d')
    rm -f "$tmpfile"

    if [[ -z "$title" ]]; then
      echo "aborted: empty title" >&2
      return 1
    fi

    gh pr create \
      -B "$target" \
      -H "$bookmark" \
      -t "$title" \
      -b "$body"
}
alias ghpr-create='noglob ghpr-create'
_ghpr_create() {
    local -a bookmarks
    bookmarks=(${(f)"$(jj bookmark list -T 'name ++ "\n"' 2>/dev/null)"})
    _arguments \
      "1:bookmark:($bookmarks)" \
      "2:target branch: "
}
compdef _ghpr_create ghpr-create

# merges the open PR associated with a jj bookmark, if it's approved and clean.
# defaults to --squash; pass a different method (--merge, --rebase) as the 2nd arg.
ghpr-merge() {
    local bookmark="$1"
    local method="${2:---squash}"

    if [[ -z "$bookmark" ]]; then
      echo "usage: ghpr-merge <bookmark> [--squash|--merge|--rebase]" >&2
      return 1
    fi

    local pr_info
    pr_info=$(gh pr list --state open --head "$bookmark" \
        --json number,title,reviewDecision,mergeable,mergeStateStatus,isDraft \
        --jq '.[0]') || return 1

    if [[ -z "$pr_info" || "$pr_info" == "null" ]]; then
      echo "error: no open PR found with head branch '$bookmark'" >&2
      return 1
    fi

    local number title review mergeable state is_draft
    number=$(echo "$pr_info" | jq -r '.number')
    title=$(echo "$pr_info" | jq -r '.title')
    review=$(echo "$pr_info" | jq -r '.reviewDecision')
    mergeable=$(echo "$pr_info" | jq -r '.mergeable')
    state=$(echo "$pr_info" | jq -r '.mergeStateStatus')
    is_draft=$(echo "$pr_info" | jq -r '.isDraft')

    echo "PR #$number: $title"
    echo "  review:    ${review:-none}"
    echo "  mergeable: $mergeable"
    echo "  state:     $state"
    echo "  draft:     $is_draft"

    if [[ "$is_draft" == "true" ]]; then
      echo "error: PR is a draft" >&2
      return 1
    fi
    if [[ "$review" != "APPROVED" ]]; then
      echo "error: PR is not approved (reviewDecision=${review:-none})" >&2
      return 1
    fi
    if [[ "$mergeable" != "MERGEABLE" ]]; then
      echo "error: PR is not mergeable (mergeable=$mergeable)" >&2
      return 1
    fi
    case "$state" in
      CLEAN|UNSTABLE|HAS_HOOKS) ;;
      *)
        echo "error: PR merge state is '$state' (need CLEAN/UNSTABLE/HAS_HOOKS)" >&2
        return 1
        ;;
    esac

    case "$method" in
      --squash|--merge)
        gh pr merge "$number" "$method" --subject "$title" || return 1
        ;;
      *)
        gh pr merge "$number" "$method" || return 1
        ;;
    esac
    gh api --silent -X DELETE "repos/{owner}/{repo}/git/refs/heads/$bookmark"
}
compdef _jj_bookmarks_all ghpr-merge

# lists tracked jj bookmarks alongside any matching open PR (yours, current repo),
# and surfaces open PRs whose head branch doesn't match a tracked bookmark.
ghpr-list() {
    local bookmarks prs
    bookmarks=$(jj bookmark list --tracked -T 'name ++ "\n"' 2>/dev/null | sort -u) || return 1
    prs=$(gh pr list --author @me --state open \
        --json number,title,headRefName,baseRefName \
        --jq '.[] | [.headRefName, .number, .baseRefName, .title] | @tsv') || return 1

    echo "─ tracked bookmarks ─"
    local b pr_line
    while IFS= read -r b; do
        [[ -z "$b" ]] && continue
        pr_line=$(echo "$prs" | awk -F'\t' -v b="$b" '$1 == b {print; exit}')
        if [[ -n "$pr_line" ]]; then
            printf '%s\t→ #%s\t→ %s\t%s\n' \
                "$b" \
                "$(echo "$pr_line" | cut -f2)" \
                "$(echo "$pr_line" | cut -f3)" \
                "$(echo "$pr_line" | cut -f4)"
        else
            printf '%s\t—\n' "$b"
        fi
    done <<< "$bookmarks" | column -t -s$'\t'

    local orphans
    orphans=$(echo "$prs" | awk -F'\t' -v bm="$bookmarks" '
        BEGIN { n = split(bm, a, "\n"); for (i = 1; i <= n; i++) tracked[a[i]] = 1 }
        !($1 in tracked) { print }
    ')
    if [[ -n "$orphans" ]]; then
        echo
        echo "─ open PRs without a tracked bookmark ─"
        echo "$orphans" | awk -F'\t' '{ printf "#%s\t%s\t→ %s\t%s\n", $2, $1, $3, $4 }' \
            | column -t -s$'\t'
    fi
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
