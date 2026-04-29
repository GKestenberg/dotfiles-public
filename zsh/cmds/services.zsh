# ------------------------
# Service Helper Functions
# ------------------------

_print_process_status() {
    local orange="\033[33m"
    local green="\033[32m"
    local reset="\033[0m"

    case "$1" in
        start_on)  echo -e "[START] ${orange}$2${reset} is already running." ;;
        start_off) echo -e "[START] ${green}$2${reset} is starting..." ;;
        stop_off)  echo -e "[STOP] ${orange}$2${reset} is not running." ;;
        stop_on)   echo -e "[STOP] ${green}$2${reset} is stopping..." ;;
    esac
}

start() {
    if [[ -z "$1" ]]; then
        start "yabai" "skhd" "borders"
        return
    fi

    for service in "$@"; do
        case "$service" in
            yabai)
                if [[ -z $(pgrep yabai) ]]; then
                    (nohup yabai & disown) >/dev/null 2>&1
                    _print_process_status start_off yabai
                else
                    _print_process_status start_on yabai
                fi
                ;;
            borders)
                brew services start borders
                ;;
            skhd)
                skhd --start-service
                ;;
            sketch)
                brew services start sketchybar
                ;;
            *)
                echo "[ERROR] Unsupported service: $service"
                echo "Usage: start <yabai|borders|skhd>"
                ;;
        esac
    done
}

stop() {
    for service in "$@"; do
        case "$service" in
            yabai)
                kill $(pgrep "$service")
                ;;
            borders)
                brew services stop borders
                ;;
            skhd)
                skhd --restart-service
                ;;
            sketch)
                brew services stop sketchybar
                ;;
            *)
                echo "[ERROR] Unsupported service: $service"
                echo "Usage: stop <yabai|borders|skhd>"
                ;;
        esac
        _print_process_status stop_on "$service"
    done
}

restart() {
    case "$1" in
        yabai)
            stop "yabai"
            start "yabai"
            ;;
        borders)
            brew services restart borders
            ;;
        skhd)
            skhd --restart-service
            ;;
        sketch)
            brew services restart sketchybar
            ;;
        *)
            echo "Usage: restart <yabai|borders|skhd>"
            return 1
            ;;
    esac
}
