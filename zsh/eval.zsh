
# Setup cache directory
COMPLETION_CACHE_DIR="$HOME/.zsh/completions"
mkdir -p "$COMPLETION_CACHE_DIR"

# Load completion from cache or generate it
_cached_lazy_completion() {
    local cmd=$1
    local cache_file="$COMPLETION_CACHE_DIR/_$cmd"
    local loaded_var="_${cmd}_completion_loaded"
    
    # Skip if already loaded this session
    [[ ${(P)loaded_var} == "1" ]] && return
    
    # Regenerate cache if missing or older than 7 days
    if [[ ! -f "$cache_file" ]] || [[ $(find "$cache_file" -mtime +7 2>/dev/null) ]]; then
        case "$cmd" in
            "docker")  command docker completion zsh > "$cache_file" 2>/dev/null ;;
            "kubectl") command kubectl completion zsh > "$cache_file" 2>/dev/null ;;
        esac
    fi
    
    # Load cached completion and mark as loaded
    if [[ -f "$cache_file" ]]; then
        source "$cache_file"
        eval "${loaded_var}=1"
    fi
}

_create_lazy_completion() {
    local cmd=$1
    
    # Check if command exists on system
    # $cmd() {
    if command -v "$cmd" >/dev/null 2>&1; then
        eval "
        _${cmd}_lazy_complete() {
            _cached_lazy_completion $cmd
            unfunction $cmd
            $cmd \"\$@\"
        }"
    fi
}

_create_lazy_alias_completion() {
    local alias_name=$1
    local cmd=$2
    
    if command -v "$cmd" >/dev/null 2>&1; then
        # Load completion right away
        _cached_lazy_completion $cmd
        # Create alias
        alias "$alias_name"="$cmd"
        # Set up completion for alias
        compdef _kubectl $alias_name 2>/dev/null
    fi
}

# --- Actual Completions ---

_create_lazy_completion docker  
_create_lazy_completion kubectl
_create_lazy_alias_completion k kubectl
