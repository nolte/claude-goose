#!/usr/bin/env sh
#
# render-bindings.sh — render every host binding from the host-neutral sources.
#
# A binding is a function of constraints.md, invocation-contract.md, and its own
# template. This tool computes that function. It is what makes "the binding
# contributes nothing of its own" a mechanical fact rather than a convention.
#
#   render-bindings.sh              render every binding, writing in place
#   render-bindings.sh --check      render to a temporary location and compare
#   render-bindings.sh <host>       render one binding
#
# Exit codes:
#   0  every binding matches its sources (--check), or was written (default)
#   1  drift, an undeclared template line, or normative voice in a
#      HOST-SPECIFIC region. --check only.
#   2  usage error, missing source, unreadable template, malformed markers, or
#      a template that fails a region check in the default mode.
#
# Dependencies: POSIX sh and awk. Nothing else. The tree this lives in has no
# other runtime dependency and this tool must not be the one that gives it one.

set -u

ME=$(basename -- "$0")
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd) || exit 2

CONSTRAINTS="$ROOT/constraints.md"
CONTRACT="$ROOT/invocation-contract.md"
BINDINGS="$ROOT/bindings"

CHECK=0
ONLY_HOST=""

# ---------------------------------------------------------------- diagnostics

die() {
  printf '%s: %s\n' "$ME" "$1" >&2
  exit "${2:-2}"
}

# --------------------------------------------------------------------- usage

case "${1:-}" in
"") ;;
--check) CHECK=1 ;;
-h | --help)
  sed -n '3,25p' -- "$0" | sed 's/^# \{0,1\}//'
  exit 0
  ;;
-*) die "unknown option: $1" ;;
*) ONLY_HOST="$1" ;;
esac
[ "$#" -le 1 ] || die "at most one argument: --check, or a host name"

[ -r "$CONSTRAINTS" ] || die "missing or unreadable source: $CONSTRAINTS"
[ -r "$CONTRACT" ] || die "missing or unreadable source: $CONTRACT"
[ -d "$BINDINGS" ] || die "missing bindings directory: $BINDINGS"

# ------------------------------------------------------------------ scratch

if command -v mktemp >/dev/null 2>&1; then
  TMPDIR_RUN=$(mktemp -d) || die "cannot create a temporary directory"
else
  TMPDIR_RUN="${TMPDIR:-/tmp}/$ME.$$"
  mkdir -- "$TMPDIR_RUN" || die "cannot create a temporary directory"
fi
trap 'rm -rf -- "$TMPDIR_RUN"' EXIT HUP INT TERM

# ------------------------------------------------------- source: constraints
#
# Emits the text of every constraint marked carried_at_invocation=yes, in id
# order. Ids must appear in ascending order in the file; they are the reading
# order a human relies on, and a renderer that silently reordered them would
# make the file and the binding tell different stories.

extract_constraints() {
  awk '
    /<!-- BEGIN CONSTRAINT:/ {
      if (inblock) { print "render-bindings: unclosed constraint before line " NR > "/dev/stderr"; exit 2 }
      id = ""; carried = "no"
      for (i = 1; i <= NF; i++) {
        if ($i == "CONSTRAINT:") id = $(i+1)
        if ($i ~ /^carried_at_invocation=/) { split($i, kv, "="); carried = kv[2] }
      }
      if (id == "") { print "render-bindings: constraint marker without an id at line " NR > "/dev/stderr"; exit 2 }
      if (id in seen) { print "render-bindings: duplicate constraint id " id " at line " NR > "/dev/stderr"; exit 2 }
      seen[id] = 1
      n = id; sub(/^C-/, "", n); n = n + 0
      if (n <= last) { print "render-bindings: constraint " id " is out of id order at line " NR > "/dev/stderr"; exit 2 }
      last = n
      inblock = 1; emit = (carried == "yes")
      if (emit) { if (written) print ""; written = 1 }
      next
    }
    /<!-- END CONSTRAINT:/ {
      if (!inblock) { print "render-bindings: END CONSTRAINT without BEGIN at line " NR > "/dev/stderr"; exit 2 }
      inblock = 0; emit = 0
      next
    }
    inblock && emit { print }
    END {
      if (inblock) { print "render-bindings: unclosed constraint at end of file" > "/dev/stderr"; exit 2 }
    }
  ' "$CONSTRAINTS"
}

# ------------------------------------------------------------ source: inputs
#
# Emits the contract input table as a prose list. The table under "## Inputs"
# in invocation-contract.md is the single source; this is a serialisation of
# it, never a second copy.

extract_inputs() {
  awk -F'|' '
    /^## Inputs$/ { intable = 1; next }
    intable && /^## / { intable = 0 }
    intable && /^\|/ {
      name = $2; req = $3; def = $4; mean = $5
      gsub(/^[ \t]+|[ \t]+$/, "", name)
      gsub(/^[ \t]+|[ \t]+$/, "", req)
      gsub(/^[ \t]+|[ \t]+$/, "", def)
      gsub(/^[ \t]+|[ \t]+$/, "", mean)
      if (name == "Name" || name ~ /^-+$/ || name == "") next
      gsub(/`/, "", name); gsub(/`/, "", def)
      if (req == "yes") printf "- %s (required): %s\n", name, mean
      else printf "- %s (optional, default %s): %s\n", name, def, mean
    }
  ' "$CONTRACT"
}

# Names of the contract inputs, one per line. Used to reject a placeholder a
# binding invented for itself.
contract_input_names() {
  awk -F'|' '
    /^## Inputs$/ { intable = 1; next }
    intable && /^## / { intable = 0 }
    intable && /^\|/ {
      name = $2
      gsub(/^[ \t]+|[ \t]+$/, "", name); gsub(/`/, "", name)
      if (name == "Name" || name ~ /^-+$/ || name == "") next
      print name
    }
  ' "$CONTRACT"
}

# ------------------------------------------------------------ region checks
#
# Two lexical checks on the TEMPLATE, which is the one place in a binding where
# a hand-written rule could otherwise survive a green gate forever: the
# renderer would reproduce it faithfully and the comparison would stay quiet.
#
# Both run in --check AND in the default mode. In the default mode a failure is
# exit 2 before anything is written: rendering a template the tool cannot
# account for would commit exactly the content the rule exists to reject.

check_regions() {
  tmpl="$1"
  awk -v F="${1#"$ROOT"/}" '
    function fail(msg) { print msg > "/dev/stderr"; bad = 1 }
    /BEGIN GENERATED:|BEGIN HOST-SPECIFIC:/ {
      if (depth) { fail("UNCLOSED REGION  " F ":" NR "\n                 " kind ": " name " is still open") }
      kind = ($0 ~ /BEGIN GENERATED:/) ? "GENERATED" : "HOST-SPECIFIC"
      name = $0
      sub(/^.*BEGIN (GENERATED|HOST-SPECIFIC): */, "", name)
      sub(/ *(-->|\*\/) *$/, "", name)
      gsub(/^[ \t]+|[ \t]+$/, "", name)
      if (name == "") fail("UNNAMED REGION  " F ":" NR)
      key = kind "/" name
      if (key in seen) fail("DUPLICATE REGION  " F ":" NR "\n                  " key " was already declared at line " seen[key])
      seen[key] = NR
      depth = 1
      next
    }
    /END GENERATED:|END HOST-SPECIFIC:/ {
      if (!depth) fail("STRAY END MARKER  " F ":" NR)
      depth = 0; kind = ""; name = ""
      next
    }
    {
      if (!depth) {
        if ($0 ~ /^[ \t]*$/) next    # a blank line carries no content and cannot be a rule
        fail("UNDECLARED LINE  " F ":" NR "\n                 " $0 "\n                 belongs to no declared region; wrap it in a GENERATED or HOST-SPECIFIC pair")
        next
      }
      if (kind == "HOST-SPECIFIC" && $0 ~ /(^|[^A-Z])(MUST|SHALL|NEVER|ALWAYS|REQUIRED|FORBIDDEN)([^A-Z]|$)/) {
        fail("NORMATIVE VOICE  " F ":" NR "\n                 HOST-SPECIFIC: " name "\n                 " $0 "\n                 a rule belongs in constraints.md, not in a template")
      }
    }
    END {
      if (depth) fail("UNCLOSED REGION  " F ": " kind ": " name " is never closed")
      exit bad ? 1 : 0
    }
  ' "$tmpl"
}

# ----------------------------------------------------------------- rendering
#
# Marker lines delimit regions in the template and do not appear in the output.
# A GENERATED region's content is replaced wholesale by its source; the marker's
# own indentation is applied to every line of that source, so the same block can
# be spliced into a YAML block scalar and a shell heredoc without either
# knowing about the other. Blank lines stay empty rather than becoming lines of
# spaces, because the repository gate rejects trailing whitespace.

render_one() {
  tmpl="$1"
  out="$2"
  extract_constraints >"$TMPDIR_RUN/src.constraints" || return 2
  extract_inputs >"$TMPDIR_RUN/src.inputs" || return 2

  awk -v dir="$TMPDIR_RUN" -v F="$tmpl" '
    /BEGIN GENERATED:/ {
      indent = $0; sub(/[^ \t].*$/, "", indent)
      src = $0
      sub(/^.*BEGIN GENERATED: */, "", src)
      sub(/ *(-->|\*\/) *$/, "", src)
      gsub(/^[ \t]+|[ \t]+$/, "", src)
      path = dir "/src." src
      if ((getline probe < path) < 0) {
        print "UNKNOWN SOURCE  " F ":" NR "\n                " src " is not a source this renderer knows" > "/dev/stderr"
        exit 2
      }
      close(path)
      while ((getline line < path) > 0) {
        if (line ~ /^[ \t]*$/) print ""
        else print indent line
      }
      close(path)
      skip = 1
      next
    }
    /END GENERATED:/ { skip = 0; next }
    /BEGIN HOST-SPECIFIC:|END HOST-SPECIFIC:/ { next }
    !skip { print }
  ' "$tmpl" >"$out"
}

# ---------------------------------------------- placeholder conformance check
#
# Every {{ name }} a rendered binding carries must be a contract input. This
# catches a typo and an input a binding invented for itself, which obligation 2
# of the contract forbids.

check_placeholders() {
  rendered="$1"
  label="$2"
  contract_input_names >"$TMPDIR_RUN/names"
  awk -v F="$label" '
    NR == FNR { known[$0] = 1; next }
    {
      line = $0
      while (match(line, /\{\{[ \t]*[A-Za-z_][A-Za-z0-9_]*[ \t]*\}\}/)) {
        ph = substr(line, RSTART, RLENGTH)
        line = substr(line, RSTART + RLENGTH)
        gsub(/[{} \t]/, "", ph)
        if (!(ph in known)) {
          print "UNKNOWN INPUT  " F ":" FNR "\n               {{ " ph " }} is not declared in invocation-contract.md" > "/dev/stderr"
          bad = 1
        }
      }
    }
    END { exit bad ? 1 : 0 }
  ' "$TMPDIR_RUN/names" "$rendered"
}

# ----------------------------------------------------------------- discovery
#
# Everything the renderer knows about a host comes from where its template
# sits. There is no registry, and nothing to register.

hosts=""
for d in "$BINDINGS"/*/; do
  [ -d "$d" ] || continue
  h=$(basename -- "$d")
  [ -z "$ONLY_HOST" ] || [ "$h" = "$ONLY_HOST" ] || continue
  hosts="$hosts $h"
done

if [ -n "$ONLY_HOST" ] && [ -z "$hosts" ]; then
  die "no binding directory for host: $ONLY_HOST"
fi
[ -n "$hosts" ] || die "no host binding directories under $BINDINGS"

# ---------------------------------------------------------------------- main

status=0

for h in $hosts; do
  dir="$BINDINGS/$h"

  # Exactly one authored template per host. None, or more than one, is what
  # keeps "adding a host costs one authored file" enforced rather than
  # trusted — and two templates would mean the host name no longer picks out
  # a single output.
  count=0
  tmpl=""
  for t in "$dir"/*.tmpl; do
    [ -f "$t" ] || continue
    count=$((count + 1))
    tmpl="$t"
  done
  if [ "$count" -eq 0 ]; then
    die "host directory holds no template: $dir (expected exactly one *.tmpl)"
  fi
  if [ "$count" -gt 1 ]; then
    printf '%s: host directory holds %d templates: %s\n' "$ME" "$count" "$dir" >&2
    for t in "$dir"/*.tmpl; do [ -f "$t" ] && printf '    %s\n' "$t" >&2; done
    printf '    exactly one authored template per host is required\n' >&2
    exit 2
  fi
  [ -r "$tmpl" ] || die "unreadable template: $tmpl"

  rel_tmpl=${tmpl#"$ROOT"/}
  target=${tmpl%.tmpl}
  rel_target=${target#"$ROOT"/}

  if ! check_regions "$tmpl"; then
    if [ "$CHECK" -eq 1 ]; then
      status=1
      continue
    fi
    die "refusing to render $rel_tmpl: it failed a region check" 2
  fi

  rendered="$TMPDIR_RUN/$h.rendered"
  render_one "$tmpl" "$rendered" || exit 2

  if ! check_placeholders "$rendered" "$rel_target"; then
    if [ "$CHECK" -eq 1 ]; then
      status=1
      continue
    fi
    die "refusing to write $rel_target: it carries an input the contract does not declare" 2
  fi

  if [ "$CHECK" -eq 1 ]; then
    if [ ! -f "$target" ]; then
      printf 'MISSING  %s\n' "$rel_target" >&2
      printf '         the template renders to a file that is not committed\n' >&2
      printf '         run tools/render-bindings.sh to create it\n' >&2
      status=1
    elif ! cmp -s -- "$rendered" "$target"; then
      printf 'DRIFT  %s\n' "$rel_target" >&2
      printf '       differs from constraints.md + invocation-contract.md + %s\n' "$rel_tmpl" >&2
      printf '       run tools/render-bindings.sh to regenerate\n' >&2
      printf '       --- committed\n' >&2
      printf '       +++ rendered\n' >&2
      diff -- "$target" "$rendered" 2>/dev/null | sed 's/^/       /' >&2
      status=1
    fi
  else
    cp -- "$rendered" "$target" || die "cannot write $rel_target"
    [ -x "$tmpl" ] && chmod +x -- "$target"
    printf 'rendered  %s\n' "$rel_target"
  fi
done

exit "$status"
