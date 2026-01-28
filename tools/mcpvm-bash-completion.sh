# Bash completion for mcpvm
#
# To enable, add to ~/.bashrc:
#   source /path/to/tools/mcpvm-bash-completion.sh
#
# Or copy to /etc/bash_completion.d/mcpvm (system-wide)

_mcpvm_completions() {
    local cur prev words cword

    # Use bash-completion helpers if available, otherwise parse manually
    if declare -F _init_completion >/dev/null 2>&1; then
        _init_completion || return
    else
        COMPREPLY=()
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
        words=("${COMP_WORDS[@]}")
        cword=$COMP_CWORD
    fi

    local commands="setup list start stop delete"

    # Determine which subcommand we're in (if any)
    local cmd=""
    local i
    for ((i=1; i < cword; i++)); do
        case "${words[i]}" in
            setup|list|start|stop|delete)
                cmd="${words[i]}"
                break
                ;;
        esac
    done

    # No subcommand yet - complete subcommands
    if [[ -z "$cmd" ]]; then
        COMPREPLY=($(compgen -W "$commands" -- "$cur"))
        return
    fi

    # Handle completions based on subcommand
    case "$cmd" in
        setup)
            # Handle --playbook=<path> completion
            # Bash splits on = so we see: --playbook = path
            # Case 1: --playbook=<TAB> -> cur="=", prev="--playbook"
            if [[ "$cur" == "=" && "$prev" == "--playbook" ]]; then
                COMPREPLY=($(compgen -f -- ""))
                compopt -o filenames 2>/dev/null
                return
            fi
            # Case 2: --playbook=pa<TAB> -> cur="pa", prev="="
            if [[ "$prev" == "=" && $cword -ge 2 ]]; then
                local opt="${words[cword-2]}"
                if [[ "$opt" == "--playbook" ]]; then
                    COMPREPLY=($(compgen -f -- "$cur"))
                    compopt -o filenames 2>/dev/null
                    return
                fi
            fi
            # Case 3: --playbook <TAB> (space-separated form)
            if [[ "$prev" == "--playbook" ]]; then
                COMPREPLY=($(compgen -f -- "$cur"))
                compopt -o filenames 2>/dev/null
                return
            fi

            # Complete options or VM name
            if [[ "$cur" == --* ]]; then
                COMPREPLY=($(compgen -W "--version= --playbook=" -- "$cur"))
                compopt -o nospace 2>/dev/null
            elif [[ "$cur" == -* ]]; then
                COMPREPLY=($(compgen -W "--version= --playbook=" -- "$cur"))
                compopt -o nospace 2>/dev/null
            else
                # Could be typing a VM name - offer mcpvm- prefix
                if [[ -z "$cur" ]]; then
                    COMPREPLY=("mcpvm-")
                    compopt -o nospace 2>/dev/null
                fi
            fi
            ;;

        list)
            # Complete --name-only option
            if [[ "$cur" == -* ]]; then
                COMPREPLY=($(compgen -W "--name-only" -- "$cur"))
            fi
            ;;

        start|stop|delete)
            # Complete with existing VM names
            if [[ "$cur" != -* ]]; then
                local vms
                vms=$(mcpvm list --name-only 2>/dev/null)
                if [[ -n "$vms" ]]; then
                    COMPREPLY=($(compgen -W "$vms" -- "$cur"))
                fi
            fi
            ;;
    esac
}

complete -F _mcpvm_completions mcpvm
