#compdef mcpvm
#
# Zsh completion for mcpvm
#
# To enable, add to ~/.zshrc:
#   source /path/to/tools/mcpvm-zsh-completion.zsh
#
# Or place in a directory in your $fpath and name it _mcpvm

_mcpvm_vms() {
    local vms
    vms=(${(f)"$(mcpvm list --name-only 2>/dev/null)"})
    _describe 'vm' vms
}

_mcpvm_setup() {
    _arguments \
        '--version=[RHEL version (e.g., 9.5)]:version:' \
        '--playbook=[Ansible playbook to run after setup]:playbook:_files' \
        '*: :'
}

_mcpvm_list() {
    _arguments \
        '--name-only[Output only VM names]' \
        '*: :'
}

_mcpvm_start() {
    _arguments \
        '*:vm:_mcpvm_vms'
}

_mcpvm_stop() {
    _arguments \
        '*:vm:_mcpvm_vms'
}

_mcpvm_delete() {
    _arguments \
        '*:vm:_mcpvm_vms'
}

_mcpvm() {
    local -a commands
    commands=(
        'setup:Create and start a new RHEL VM'
        'list:List all mcpvm-managed VMs'
        'start:Start an existing VM'
        'stop:Stop a running VM'
        'delete:Delete a VM and its resources'
    )

    if (( CURRENT == 2 )); then
        _describe 'command' commands
    else
        local cmd="${words[2]}"
        case "$cmd" in
            setup)  _mcpvm_setup ;;
            list)   _mcpvm_list ;;
            start)  _mcpvm_start ;;
            stop)   _mcpvm_stop ;;
            delete) _mcpvm_delete ;;
        esac
    fi
}

_mcpvm "$@"

# Register the completion function when sourced directly
# (The #compdef directive only works when loaded via $fpath)
if [[ -n "$ZSH_VERSION" ]]; then
    compdef _mcpvm mcpvm
fi
