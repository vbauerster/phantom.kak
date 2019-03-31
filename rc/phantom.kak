declare-option -docstring 'Whether Phantom is active' bool phantom_enabled no

declare-option -hidden str-list phantom_selections
declare-option -hidden range-specs phantom_highlighter
declare-option -hidden str phantom_last_key

set-face global Phantom 'black,green'

define-command -hidden phantom-update -params .. %{ evaluate-commands %sh{
  key=$1
  eval "set -- $kak_selections_desc"
  if test $# = 1; then
    echo try %[add-highlighter window/phantom ranges phantom_highlighter]
  else
    echo try %[remove-highlighter window/phantom]
  fi
  if test "$kak_opt_phantom_last_key" = '<space>' -a "$key" = '<space>'; then
    echo phantom-clear-selections
  elif test $# = 1 -a "$key" = '<space>'; then
    echo phantom-add-selections
  elif test $# = 1 -a "$key" = '('; then
    echo phantom-select-selections
  elif test $# = 1 -a "$key" = ')'; then
    echo phantom-select-selections
  elif test $# -gt 1; then
    echo phantom-set-selections
  fi
  if test "$key"; then
    echo set-option window phantom_last_key %arg[1]
  fi
}}

define-command -hidden phantom-select-selections %{
  evaluate-commands -save-regs '^' %{
    set-register ^ %opt(phantom_selections)
    try %{
      execute-keys 'z'
    }
  }
}

define-command -hidden phantom-set-selections %{
  evaluate-commands -draft -save-regs '^' %{
    execute-keys -save-regs '' 'Z'
    set-option window phantom_selections %reg(^)
  }
  set-option window phantom_highlighter %val(timestamp)
  evaluate-commands -no-hooks -draft -itersel %{
    set-option -add window phantom_highlighter "%val(selection_desc)|Phantom"
  }
}

define-command -hidden phantom-add-selections %{
  evaluate-commands -draft -save-regs '^' %{
    set-register ^ %opt(phantom_selections)
    try %{
      execute-keys '<a-z>a'
    }
    phantom-set-selections
  }
}

define-command -hidden phantom-clear-selections %{
  unset-option window phantom_selections
  unset-option window phantom_highlighter
}

define-command phantom-enable -docstring 'Enable phantom selections' %{

  hook window -group phantom NormalKey .* %(phantom-update %val(hook_param))
  hook window -group phantom NormalIdle '' phantom-update
  hook window -group phantom InsertMove .* %(phantom-update %val(hook_param))

  set-option window phantom_enabled yes

}

define-command phantom-disable -docstring 'Disable phantom selections' %{
  remove-highlighter window/phantom
  remove-hooks window phantom
  set-option window phantom_enabled no
}

define-command phantom-toggle -docstring 'Toggle phantom selections' %{ evaluate-commands %sh{
  if test $kak_opt_phantom_enabled = true; then
    echo phantom-disable
  else
    echo phantom-enable
  fi
}}
