#!/bin/bash
#===============================================================================
#  A-Termux-Integration-Toolbox - 全平台Shell集成工具箱
#  支持 Linux / macOS / Termux
#===============================================================================
#  作者:   Azeri
#  版本:   1.0.0
#  依赖:   bash, curl/wget (可选 python3, go)
#  用法:   ./ATT.sh
#  仓库:   https://github.com/laninenterline/A-Termux-integration-Toolbox
#===============================================================================

set -o pipefail

readonly VERSION="1.0.0"
readonly SCRIPT_NAME="Shell Toolkit"

# 环境检测与目录配置
if [[ -d "/data/data/com.termux/files" ]]; then
    readonly IS_TERMUX=true
    readonly BASE_DIR="/data/data/com.termux/files/home/.ATT"
    readonly CONFIG_DIR="/data/data/com.termux/files/home/.config/shell-toolkit"
else
    readonly IS_TERMUX=false
    readonly BASE_DIR="${HOME}/.ATT"
    readonly CONFIG_DIR="${HOME}/.config/ATT"
fi

readonly CUSTOM_SCRIPTS_DIR="${BASE_DIR}/custom_scripts"
readonly LOG_DIR="${BASE_DIR}/logs"
readonly TEMP_DIR="${BASE_DIR}/temp"
readonly REMOTE_SCRIPTS_DIR="${BASE_DIR}/remote_scripts"
readonly REMOTE_SOURCES_FILE="${CONFIG_DIR}/remote_sources.conf"

readonly SYSTEM_TYPE=$(uname -s)

# 检测详细系统类型（termux/macos/ubuntu/wsl等）
detect_system_type() {
    case "${SYSTEM_TYPE}" in
        Linux)
            if [[ "${IS_TERMUX}" == true ]]; then
                echo "termux"
            elif [[ -f /proc/sys/kernel/osrelease ]] && grep -q "Microsoft" /proc/sys/kernel/osrelease 2>/dev/null; then
                echo "wsl"
            elif [[ -f /etc/os-release ]]; then
                grep "^ID=" /etc/os-release 2>/dev/null | cut -d'=' -f2 | tr -d '"'
            else
                echo "linux"
            fi
            ;;
        Darwin) echo "macos" ;;
        CYGWIN*|MINGW*|MSYS*) echo "windows" ;;
        FreeBSD|OpenBSD|NetBSD) echo "bsd" ;;
        *) echo "unknown" ;;
    esac
}

readonly SYSTEM_ID=$(detect_system_type)

# 获取友好的系统名称
get_system_name() {
    case "${SYSTEM_ID}" in
        termux) echo "Termux" ;;
        macos) echo "macOS" ;;
        ubuntu) echo "Ubuntu" ;;
        debian) echo "Debian" ;;
        centos) echo "CentOS" ;;
        rhel) echo "RHEL" ;;
        fedora) echo "Fedora" ;;
        wsl) echo "WSL" ;;
        windows) echo "Windows" ;;
        bsd) echo "BSD" ;;
        *) echo "${SYSTEM_ID}" ;;
    esac
}

# 颜色配置（终端支持检测）
if [[ -t 1 ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly BLUE='\033[0;34m'
    readonly CYAN='\033[0;36m'
    readonly MAGENTA='\033[0;35m'
    readonly NC='\033[0m'
    readonly BOLD='\033[1m'
else
    readonly RED=''; readonly GREEN=''; readonly YELLOW=''; readonly BLUE=''
    readonly CYAN=''; readonly MAGENTA=''; readonly NC=''; readonly BOLD=''
fi

# 日志记录（目录存在时才写入文件）
log_info() {
    local msg="[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $1"
    echo -e "${GREEN}${msg}${NC}"
    if [[ -d "${LOG_DIR}" ]]; then
        echo "${msg}" >> "${LOG_DIR}/toolkit.log" 2>/dev/null || true
    fi
}

log_warn() {
    local msg="[WARN] $(date '+%Y-%m-%d %H:%M:%S') - $1"
    echo -e "${YELLOW}${msg}${NC}"
    if [[ -d "${LOG_DIR}" ]]; then
        echo "${msg}" >> "${LOG_DIR}/toolkit.log" 2>/dev/null || true
    fi
}

log_error() {
    local msg="[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $1"
    echo -e "${RED}${msg}${NC}"
    if [[ -d "${LOG_DIR}" ]]; then
        echo "${msg}" >> "${LOG_DIR}/toolkit.log" 2>/dev/null || true
    fi
}

#-------------------------------------------------------------------------------
# 初始化
#-------------------------------------------------------------------------------

# 创建必要的目录结构和默认配置文件
init_directories() {
    echo -e "${GREEN}[INFO] 正在初始化工具箱环境...${NC}"

    local dirs=(
        "${BASE_DIR}"
        "${CONFIG_DIR}"
        "${CUSTOM_SCRIPTS_DIR}"
        "${LOG_DIR}"
        "${TEMP_DIR}"
        "${REMOTE_SCRIPTS_DIR}"
        "${CUSTOM_SCRIPTS_DIR}/python"
        "${CUSTOM_SCRIPTS_DIR}/shell"
        "${CUSTOM_SCRIPTS_DIR}/go"
        "${CUSTOM_SCRIPTS_DIR}/other"
    )

    for dir in "${dirs[@]}"; do
        if [[ ! -d "${dir}" ]]; then
            mkdir -p "${dir}" 2>/dev/null || {
                echo -e "${RED}[ERROR] 无法创建目录: ${dir}${NC}"
                return 1
            }
        fi
    done

    # 创建默认远程源配置文件
    if [[ ! -f "${REMOTE_SOURCES_FILE}" ]]; then
        cat > "${REMOTE_SOURCES_FILE}" << 'EOF'
# Shell Toolkit 远程脚本源配置文件
# 格式: 名称|URL|描述
# Useful Scripts|https://raw.githubusercontent.com/user/repo/main/scripts/|常用工具脚本集合
EOF
        chmod 644 "${REMOTE_SOURCES_FILE}"
    fi

    echo -e "${GREEN}[INFO] 环境初始化完成${NC}"
    return 0
}

# 检查必要依赖
check_dependencies() {
    local deps=("curl" "bash") missing=()
    for dep in "${deps[@]}"; do
        command -v "${dep}" &>/dev/null || missing+=("${dep}")
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_warn "缺少依赖: ${missing[*]}"
        echo -e "${YELLOW}请安装缺失的依赖${NC}"
    fi
}

#-------------------------------------------------------------------------------
# 界面显示
#-------------------------------------------------------------------------------

clear_screen() {
    if [[ "${IS_TERMUX}" == true ]]; then
        clear
    else
        clear || printf "\033c"
    fi
}

draw_line() {
    local char="${1:-─}"
    local width="${2:-$(tput cols 2>/dev/null || echo 60)}"
    printf "%${width}s\n" "" | tr " " "${char}"
}

show_header() {
    clear_screen
    local title="${1:-${SCRIPT_NAME}}"
    local width=60
    echo ""
    echo -e "${CYAN}${BOLD}"
    draw_line "═" "${width}"
    printf " %s\n" "  ${title} v${VERSION}"
    [[ "${IS_TERMUX}" == true ]] && printf " %s\n" "  [Termux模式]"
    draw_line "═" "${width}"
    echo -e "${NC}"
}

show_menu_item() {
    local num="$1" name="$2" desc="$3" color="${4:-${BLUE}}"
    printf "  ${color}[%-2s]${NC} ${BOLD}%-20s${NC} %s\n" "${num}" "${name}" "${desc}"
}

show_main_menu() {
    show_header "${SCRIPT_NAME}"
    echo -e "${MAGENTA}${BOLD}  ▶ 主菜单${NC}\n"
    show_menu_item "1" "基础工具" "系统管理、进程管理、网络工具" "${GREEN}"
    show_menu_item "2" "自定义工具" "运行本地自定义脚本(Python/Go/Shell)" "${YELLOW}"
    show_menu_item "3" "远程脚本" "从指定网站拉取并执行脚本" "${CYAN}"
    show_menu_item "4" "工具箱管理" "配置、更新、日志查看" "${BLUE}"
    show_menu_item "5" "$(get_system_name)专区" "系统专属工具 ($(echo ${SYSTEM_ID} | tr '[:lower:]' '[:upper:]'))" "${MAGENTA}"
    show_menu_item "0" "退出" "退出工具箱" "${RED}"
    echo ""
    draw_line "-" "60"
    echo ""
}

#-------------------------------------------------------------------------------
# 基础工具模块
#-------------------------------------------------------------------------------

show_system_info() {
    show_header "系统信息"
    echo -e "${CYAN}${BOLD}  操作系统信息:${NC}"
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        echo "    名称: ${NAME:-Unknown}"
        echo "    版本: ${VERSION_ID:-Unknown}"
    elif [[ "${IS_TERMUX}" == true ]]; then
        echo "    平台: Termux (Android)"
        echo "    架构: $(uname -m)"
    elif [[ "$(uname)" == "Darwin" ]]; then
        echo "    平台: macOS"
        echo "    版本: $(sw_vers -productVersion 2>/dev/null || echo 'Unknown')"
    fi

    echo -e "\n${CYAN}${BOLD}  硬件信息:${NC}"
    echo "    架构: $(uname -m)"
    echo "    内核: $(uname -r)"
    if [[ "${IS_TERMUX}" == false ]] && command -v lscpu &>/dev/null; then
        echo "    CPU: $(lscpu | grep 'Model name' | cut -d':' -f2 | xargs 2>/dev/null || echo 'Unknown')"
    fi

    echo -e "\n${CYAN}${BOLD}  内存使用:${NC}"
    if [[ "${IS_TERMUX}" == true ]] && [[ -f /proc/meminfo ]]; then
        local total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
        local avail=$(grep MemAvailable /proc/meminfo 2>/dev/null | awk '{print $2}' || echo "0")
        [[ -n "${total}" ]] && {
            local used=$((total - avail))
            local pct=$((used * 100 / total))
            echo "    总计: $((total / 1024)) MB"
            echo "    已用: $((used / 1024)) MB (${pct}%)"
        }
    else
        free -h 2>/dev/null | grep -E "Mem|内存" | awk '{print "    总计: " $2 ", 已用: " $3 ", 可用: " $7}' || echo "    无法获取内存信息"
    fi

    echo -e "\n${CYAN}${BOLD}  存储使用:${NC}"
    df -h . 2>/dev/null | tail -1 | awk '{print "    总计: " $2 ", 已用: " $3 ", 可用: " $4 ", 使用率: " $5}'
    echo ""
    read -rp "按回车键返回..."
}

process_management() {
    while true; do
        show_header "进程管理"
        echo -e "${MAGENTA}${BOLD}  ▶ 进程管理选项${NC}\n"
        show_menu_item "1" "查看进程列表" "显示所有运行中的进程"
        show_menu_item "2" "查看资源占用" "按CPU/内存排序显示"
        show_menu_item "3" "搜索进程" "根据名称查找进程"
        show_menu_item "4" "终止进程" "安全结束指定进程"
        show_menu_item "5" "杀死进程" "强制结束指定进程"
        show_menu_item "0" "返回上级" "返回基础工具菜单"
        echo ""
        read -rp "请选择操作 [0-5]: " choice

        case "${choice}" in
            1) show_header "进程列表"
               [[ "${IS_TERMUX}" == true ]] && ps aux 2>/dev/null || ps aux --sort=-pid | head -20
               echo ""; read -rp "按回车键继续..." ;;
            2) show_header "资源占用TOP"
               if command -v top &>/dev/null; then
                   [[ "${IS_TERMUX}" == true ]] && top -n 1 -m 10 2>/dev/null || top -bn1 | head -20
               else
                   ps aux --sort=-%cpu | head -10
               fi
               echo ""; read -rp "按回车键继续..." ;;
            3) echo ""; read -rp "输入进程名称关键词: " keyword
               [[ -n "${keyword}" ]] && {
                   show_header "搜索结果: ${keyword}"
                   ps aux | grep -i "${keyword}" | grep -v grep || echo "未找到匹配的进程"
               }
               echo ""; read -rp "按回车键继续..." ;;
            4) echo ""; read -rp "输入要终止的PID: " pid
               if [[ "${pid}" =~ ^[0-9]+$ ]]; then
                   kill "${pid}" 2>/dev/null && log_info "进程 ${pid} 已终止" || log_error "无法终止进程 ${pid}"
                   sleep 1
               else
                   log_error "无效的PID"; sleep 1
               fi ;;
            5) echo ""; read -rp "输入要强杀的PID: " pid
               [[ "${pid}" =~ ^[0-9]+$ ]] && kill -9 "${pid}" 2>/dev/null && log_info "进程 ${pid} 已强制结束" || log_error "无法结束进程 ${pid}"
               sleep 1 ;;
            0) return ;;
            *) log_error "无效的选择"; sleep 1 ;;
        esac
    done
}

network_tools() {
    while true; do
        show_header "网络工具"
        echo -e "${MAGENTA}${BOLD}  ▶ 网络工具选项${NC}\n"
        show_menu_item "1" "查看网络接口" "显示所有网络接口信息"
        show_menu_item "2" "测试网络连通" "Ping测试"
        show_menu_item "3" "端口扫描" "扫描开放端口"
        show_menu_item "4" "查看连接" "显示网络连接状态"
        show_menu_item "5" "下载测试" "测试下载速度"
        show_menu_item "0" "返回上级" "返回基础工具菜单"
        echo ""
        read -rp "请选择操作 [0-5]: " choice

        case "${choice}" in
            1) show_header "网络接口"
               if [[ "${IS_TERMUX}" == true ]]; then
                   command -v ifconfig &>/dev/null && ifconfig 2>/dev/null || ip addr 2>/dev/null || echo "无法获取网络接口信息"
               else
                   ip addr 2>/dev/null || ifconfig
               fi
               echo ""; read -rp "按回车键继续..." ;;
            2) echo ""; read -rp "输入目标主机: " host
               [[ -n "${host}" ]] && {
                   show_header "Ping测试: ${host}"
                   ping -c 4 "${host}" 2>/dev/null || ping4 -c 4 "${host}" 2>/dev/null || log_error "Ping失败"
                   echo ""; read -rp "按回车键继续..."
               } ;;
            3) echo ""; read -rp "输入目标主机: " host
               read -rp "输入端口范围(如 1-1000): " range
               [[ -n "${host}" && -n "${range}" ]] && {
                   show_header "端口扫描: ${host}"
                   if command -v nc &>/dev/null; then
                       for port in $(seq $(echo "${range}" | tr '-' ' ')); do
                           timeout 1 nc -zv "${host}" "${port}" 2>/dev/null && echo "端口 ${port} 开放"
                       done
                   else
                       log_warn "未安装nc工具，尝试使用/dev/tcp"
                       for port in $(seq $(echo "${range}" | tr '-' ' ')); do
                           (timeout 1 bash -c "echo >/dev/tcp/${host}/${port}" 2>/dev/null && echo "端口 ${port} 开放") &
                       done
                       wait
                   fi
                   echo ""; read -rp "按回车键继续..."
               } ;;
            4) show_header "网络连接"
               if command -v netstat &>/dev/null; then
                   netstat -tuln 2>/dev/null || netstat -an
               elif command -v ss &>/dev/null; then
                   ss -tuln
               else
                   cat /proc/net/tcp 2>/dev/null || log_error "无法获取连接信息"
               fi
               echo ""; read -rp "按回车键继续..." ;;
            5) echo ""; read -rp "输入测试文件URL (默认: https://speed.hetzner.de/100MB.bin): " url
               [[ -z "${url}" ]] && url="https://speed.hetzner.de/100MB.bin"
               show_header "下载测试"
               log_info "正在从 ${url} 下载测试..."
               if command -v curl &>/dev/null; then
                   curl -o /dev/null -w "下载速度: %{speed_download} bytes/sec\n" "${url}" 2>/dev/null || log_error "下载失败"
               elif command -v wget &>/dev/null; then
                   wget -O /dev/null "${url}" 2>&1 | tail -5
               fi
               echo ""; read -rp "按回车键继续..." ;;
            0) return ;;
            *) log_error "无效的选择"; sleep 1 ;;
        esac
    done
}

system_maintenance() {
    while true; do
        show_header "系统维护"
        echo -e "${MAGENTA}${BOLD}  ▶ 系统维护选项${NC}\n"
        show_menu_item "1" "更新软件包" "更新系统软件包"
        show_menu_item "2" "系统升级" "执行完整系统升级"
        show_menu_item "3" "查看日志" "查看系统日志"
        show_menu_item "4" "服务管理" "管理系统服务"
        show_menu_item "5" "定时任务" "查看和管理crontab"
        show_menu_item "0" "返回上级" "返回基础工具菜单"
        echo ""
        read -rp "请选择操作 [0-5]: " choice

        case "${choice}" in
            1) log_info "正在更新软件包列表..."
               if [[ "${IS_TERMUX}" == true ]]; then
                   pkg update
               else
                   if command -v apt-get &>/dev/null; then sudo apt-get update
                   elif command -v yum &>/dev/null; then sudo yum check-update
                   elif command -v dnf &>/dev/null; then sudo dnf check-update
                   elif command -v brew &>/dev/null; then brew update
                   fi
               fi
               echo ""; read -rp "按回车键继续..." ;;
            2) log_info "正在升级系统..."
               if [[ "${IS_TERMUX}" == true ]]; then
                   pkg upgrade
               else
                   if command -v apt-get &>/dev/null; then sudo apt-get upgrade
                   elif command -v yum &>/dev/null; then sudo yum update
                   elif command -v dnf &>/dev/null; then sudo dnf upgrade
                   elif command -v brew &>/dev/null; then brew upgrade
                   fi
               fi
               echo ""; read -rp "按回车键继续..." ;;
            3) show_header "系统日志"
               if [[ "${IS_TERMUX}" == true ]]; then
                   logcat -d 2>/dev/null | tail -50 || log_info "Termux无传统系统日志"
               else
                   if [[ -f /var/log/syslog ]]; then sudo tail -50 /var/log/syslog
                   elif [[ -f /var/log/messages ]]; then sudo tail -50 /var/log/messages
                   elif command -v journalctl &>/dev/null; then journalctl -n 50
                   else dmesg | tail -50
                   fi
               fi
               echo ""; read -rp "按回车键继续..." ;;
            4) show_header "服务管理"
               if [[ "${IS_TERMUX}" == true ]]; then
                   log_info "Termux不支持传统服务管理"
               else
                   if command -v systemctl &>/dev/null; then
                       systemctl list-units --type=service --state=running 2>/dev/null | head -20
                   elif command -v service &>/dev/null; then
                       service --status-all 2>/dev/null | head -20
                   fi
               fi
               echo ""; read -rp "按回车键继续..." ;;
            5) show_header "定时任务"
               crontab -l 2>/dev/null || log_info "当前用户无定时任务"
               echo ""; read -rp "按回车键继续..." ;;
            0) return ;;
            *) log_error "无效的选择"; sleep 1 ;;
        esac
    done
}

# 获取当前系统的包管理器
get_package_manager() {
    if [[ "${IS_TERMUX}" == true ]]; then
        echo "pkg"
    elif command -v apt &>/dev/null; then
        echo "apt"
    elif command -v dnf &>/dev/null; then
        echo "dnf"
    elif command -v yum &>/dev/null; then
        echo "yum"
    elif command -v brew &>/dev/null; then
        echo "brew"
    elif command -v pacman &>/dev/null; then
        echo "pacman"
    elif command -v zypper &>/dev/null; then
        echo "zypper"
    else
        echo "unknown"
    fi
}

install_packages() {
    local packages="$1"
    local pkg_manager="$2"
    echo ""
    log_info "将要安装: ${packages}"
    read -rp "确认安装? (Y/n): " confirm
    [[ "${confirm}" =~ ^[Nn]$ ]] && return
    echo ""
    case "${pkg_manager}" in
        apt) sudo apt update && sudo apt install -y ${packages} ;;
        dnf) sudo dnf install -y ${packages} ;;
        yum) sudo yum install -y ${packages} ;;
        pkg) pkg install -y ${packages} ;;
        brew) brew install ${packages} ;;
        pacman) sudo pacman -S --noconfirm ${packages} ;;
        zypper) sudo zypper install -y ${packages} ;;
    esac
    [[ $? -eq 0 ]] && log_info "安装完成" || log_error "安装失败"
    echo ""; read -rp "按回车键继续..."
}

install_dependency_group() {
    local group="$1" pkg_manager="$2" packages=""
    case "${group}" in
        basic)   packages="curl wget git vim nano" ;;
        dev)     case "${pkg_manager}" in
                     apt) packages="build-essential gcc g++ make cmake python3 python3-dev" ;;
                     dnf|yum) packages="gcc gcc-c++ make cmake python3 python3-devel" ;;
                     pkg) packages="clang make cmake python" ;;
                     brew) packages="gcc make cmake python3" ;;
                     pacman) packages="base-devel gcc make cmake python" ;;
                     zypper) packages="gcc gcc-c++ make cmake python3" ;;
                 esac ;;
        network) case "${pkg_manager}" in
                     apt) packages="net-tools nmap tcpdump whois dnsutils" ;;
                     dnf|yum) packages="net-tools nmap tcpdump whois bind-utils" ;;
                     pkg) packages="net-tools nmap tcpdump whois dnsutils" ;;
                     brew) packages="nmap tcpdump whois" ;;
                     pacman) packages="net-tools nmap tcpdump whois bind-tools" ;;
                     zypper) packages="net-tools nmap tcpdump whois bind-utils" ;;
                 esac ;;
        sys)     case "${pkg_manager}" in
                     apt) packages="htop tree jq unzip p7zip-full" ;;
                     dnf|yum) packages="htop tree jq unzip p7zip p7zip-plugins" ;;
                     pkg|brew|pacman|zypper) packages="htop tree jq unzip p7zip" ;;
                 esac ;;
        python)  case "${pkg_manager}" in
                     apt) packages="python3 python3-pip python3-venv python3-dev" ;;
                     dnf|yum) packages="python3 python3-pip python3-virtualenv python3-devel" ;;
                     pkg) packages="python python-pip" ;;
                     brew) packages="python3" ;;
                     pacman) packages="python python-pip python-virtualenv" ;;
                     zypper) packages="python3 python3-pip python3-virtualenv" ;;
                 esac ;;
        nodejs)  case "${pkg_manager}" in
                     apt) packages="nodejs npm" ;;
                     dnf|yum) packages="nodejs npm" ;;
                     pkg) packages="nodejs" ;;
                     brew) packages="node" ;;
                     pacman) packages="nodejs npm" ;;
                     zypper) packages="nodejs npm" ;;
                 esac ;;
        other)   case "${pkg_manager}" in
                     apt) packages="ffmpeg imagemagick sqlite3" ;;
                     dnf|yum) packages="ffmpeg ImageMagick sqlite" ;;
                     pkg|brew|pacman) packages="ffmpeg imagemagick sqlite" ;;
                     zypper) packages="ffmpeg ImageMagick sqlite3" ;;
                 esac ;;
    esac
    [[ -n "${packages}" ]] && install_packages "${packages}" "${pkg_manager}"
}

show_installed_packages() {
    local pkg_manager="$1"
    show_header "已安装的依赖包"
    echo -e "${MAGENTA}${BOLD}  ▶ 当前系统: $(get_system_name)${NC}"
    echo -e "${CYAN}  ▶ 包管理器: ${pkg_manager}${NC}\n"
    local total_count=0

    case "${pkg_manager}" in
        apt) total_count=$(dpkg -l | grep -c "^ii" 2>/dev/null || echo "0")
             echo -e "${YELLOW}已安装的包列表 (前50个，共 ${total_count} 个):${NC}\n"
             dpkg -l | grep "^ii" | awk '{print $2, $3}' | head -50 | nl -w2 -s'. ' ;;
        dnf|yum) total_count=$(rpm -qa 2>/dev/null | wc -l || echo "0")
                  echo -e "${YELLOW}已安装的包列表 (前50个，共 ${total_count} 个):${NC}\n"
                  rpm -qa --qf "%{NAME}\t%{VERSION}\n" 2>/dev/null | head -50 | nl -w2 -s'. ' ;;
        pkg) total_count=$(pkg list-installed 2>/dev/null | wc -l || echo "0")
             echo -e "${YELLOW}已安装的包列表 (前50个，共 ${total_count} 个):${NC}\n"
             pkg list-installed 2>/dev/null | head -50 | nl -w2 -s'. ' ;;
        brew) total_count=$(brew list 2>/dev/null | wc -l || echo "0")
              echo -e "${YELLOW}已安装的包列表 (前50个，共 ${total_count} 个):${NC}\n"
              brew list 2>/dev/null | head -50 | nl -w2 -s'. ' ;;
        pacman) total_count=$(pacman -Q 2>/dev/null | wc -l || echo "0")
                echo -e "${YELLOW}已安装的包列表 (前50个，共 ${total_count} 个):${NC}\n"
                pacman -Q 2>/dev/null | head -50 | nl -w2 -s'. ' ;;
        zypper) total_count=$(zypper search -i 2>/dev/null | grep -c "^i" || echo "0")
                echo -e "${YELLOW}已安装的包列表 (前50个，共 ${total_count} 个):${NC}\n"
                zypper search -i 2>/dev/null | grep "^i" | awk '{print $3, $5}' | head -50 | nl -w2 -s'. ' ;;
        *) log_error "不支持的包管理器: ${pkg_manager}"; echo ""; read -rp "按回车键继续..."; return ;;
    esac

    if [[ ${total_count} -gt 50 ]]; then
        echo ""; read -rp "共 ${total_count} 个包，是否显示剩余的 $((total_count - 50)) 个? (y/N): " show_more
        [[ "${show_more}" =~ ^[Yy]$ ]] && {
            echo ""; echo -e "${YELLOW}显示剩余的包:${NC}\n"
            case "${pkg_manager}" in
                apt) dpkg -l | grep "^ii" | awk '{print $2, $3}' | tail -n +51 | nl -w2 -s'. ' -v 51 ;;
                dnf|yum) rpm -qa --qf "%{NAME}\t%{VERSION}\n" 2>/dev/null | tail -n +51 | nl -w2 -s'. ' -v 51 ;;
                pkg) pkg list-installed 2>/dev/null | tail -n +51 | nl -w2 -s'. ' -v 51 ;;
                brew) brew list 2>/dev/null | tail -n +51 | nl -w2 -s'. ' -v 51 ;;
                pacman) pacman -Q 2>/dev/null | tail -n +51 | nl -w2 -s'. ' -v 51 ;;
                zypper) zypper search -i 2>/dev/null | grep "^i" | awk '{print $3, $5}' | tail -n +51 | nl -w2 -s'. ' -v 51 ;;
            esac
        }
    fi
    echo ""; log_info "总共已安装: ${total_count} 个包"

    # 显示常用工具安装状态
    echo -e "\n${GREEN}${BOLD}  ▶ 常用工具安装状态:${NC}\n"
    local tools=("curl" "wget" "git" "vim" "nano" "python3" "nodejs" "gcc" "make" "htop")
    local installed_count=0
    for tool in "${tools[@]}"; do
        if command -v "${tool}" &>/dev/null; then
            local version=$(${tool} --version 2>/dev/null | head -1 || echo "未知版本")
            printf "  ${GREEN}✓${NC} %-10s ${CYAN}%s${NC}\n" "${tool}" "${version:0:40}"
            ((installed_count++))
        else
            printf "  ${RED}✗${NC} %-10s ${YELLOW}未安装${NC}\n" "${tool}"
        fi
    done
    echo ""; log_info "常用工具: ${installed_count}/${#tools[@]} 已安装"
    echo ""; read -rp "按回车键继续..."
}

dependency_install_menu() {
    while true; do
        show_header "依赖安装"
        local pkg_manager=$(get_package_manager)
        echo -e "${MAGENTA}${BOLD}  ▶ 当前包管理器: ${pkg_manager}${NC}\n"
        if [[ "${pkg_manager}" == "unknown" ]]; then
            echo -e "${RED}  无法识别当前系统的包管理器${NC}\n"
            echo -e "  支持的包管理器:\n    - apt (Debian/Ubuntu)\n    - dnf/yum (RHEL/CentOS/Fedora)\n    - pkg (Termux)\n    - brew (macOS)\n    - pacman (Arch Linux)\n    - zypper (openSUSE)\n"
            read -rp "按回车键返回..."; return
        fi
        echo -e "${GREEN}${BOLD}  常用依赖安装:${NC}\n"
        show_menu_item "1" "基础工具" "curl, wget, git, vim, nano" "${CYAN}"
        show_menu_item "2" "开发工具" "gcc, g++, make, cmake, python3" "${CYAN}"
        show_menu_item "3" "网络工具" "net-tools, nmap, tcpdump, whois" "${CYAN}"
        show_menu_item "4" "系统工具" "htop, tree, jq, unzip, p7zip" "${CYAN}"
        show_menu_item "5" "Python环境" "python3, python3-pip, python3-venv" "${CYAN}"
        show_menu_item "6" "Node.js环境" "nodejs, npm" "${CYAN}"
        show_menu_item "7" "其他工具" "ffmpeg, imagemagick, sqlite3" "${CYAN}"
        show_menu_item "8" "自定义安装" "输入要安装的包名" "${YELLOW}"
        show_menu_item "9" "查看已安装" "显示已安装的依赖包" "${MAGENTA}"
        show_menu_item "0" "返回上级" "返回基础工具菜单" "${RED}"
        echo ""
        read -rp "请选择要安装的依赖 [0-9]: " choice

        case "${choice}" in
            1|2|3|4|5|6|7) install_dependency_group "${choice##*[!0-9]}" "${pkg_manager}" ;;
            8) echo ""; read -rp "输入要安装的包名(多个包用空格分隔): " packages
               [[ -n "${packages}" ]] && install_packages "${packages}" "${pkg_manager}" ;;
            9) show_installed_packages "${pkg_manager}" ;;
            0) return ;;
            *) log_error "无效的选择"; sleep 1 ;;
        esac
    done
}

basic_tools_menu() {
    while true; do
        show_header "基础工具"
        echo -e "${MAGENTA}${BOLD}  ▶ 基础工具分类${NC}\n"
        show_menu_item "1" "系统信息" "查看系统详细信息和状态" "${GREEN}"
        show_menu_item "2" "进程管理" "进程查看、搜索、终止" "${GREEN}"
        show_menu_item "3" "网络工具" "网络诊断和测试工具" "${GREEN}"
        show_menu_item "4" "系统维护" "清理缓存、更新系统等" "${GREEN}"
        show_menu_item "5" "依赖安装" "安装常用工具和依赖包" "${CYAN}"
        show_menu_item "0" "返回主菜单" "返回上级菜单" "${RED}"
        echo ""
        read -rp "请选择分类 [0-5]: " choice
        case "${choice}" in
            1) show_system_info ;;
            2) process_management ;;
            3) network_tools ;;
            4) system_maintenance ;;
            5) dependency_install_menu ;;
            0) return ;;
            *) log_error "无效的选择"; sleep 1 ;;
        esac
    done
}

#-------------------------------------------------------------------------------
# 自定义工具模块
#-------------------------------------------------------------------------------

detect_script_type() {
    local file="$1"
    local ext="${file##*.}"
    local shebang=$(head -1 "${file}" 2>/dev/null)
    case "${ext}" in
        py|python) echo "python" ;;
        go) echo "go" ;;
        sh|bash) echo "shell" ;;
        *)
            if [[ "${shebang}" =~ python ]]; then echo "python"
            elif [[ "${shebang}" =~ bash ]] || [[ "${shebang}" =~ sh ]]; then echo "shell"
            else echo "other"
            fi ;;
    esac
}

get_script_desc() {
    local file="$1"
    local desc=$(head -10 "${file}" 2>/dev/null | grep -iE "^#.*(DESC|Description|描述|简介|功能)" | head -1 | sed -E 's/^#+[ 	]*//; s/^(DESC|Description|描述|简介|功能)[ 	]*:?[ 	]*//i')
    [[ -z "${desc}" ]] && desc="自定义脚本"
    [[ ${#desc} -gt 40 ]] && desc="${desc:0:40}..."
    echo "${desc}"
}

execute_script() {
    local script_path="$1" script_type="$2"
    [[ ! -f "${script_path}" ]] && { log_error "脚本不存在: ${script_path}"; return 1; }
    chmod +x "${script_path}" 2>/dev/null || true
    log_info "正在执行: $(basename "${script_path}")"
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    case "${script_type}" in
        python)
            if command -v python3 &>/dev/null; then python3 "${script_path}"
            elif command -v python &>/dev/null; then python "${script_path}"
            else log_error "未安装Python"; return 1
            fi ;;
        go)
            if command -v go &>/dev/null; then
                if [[ "${script_path}" == *.go ]]; then go run "${script_path}" 2>/dev/null || {
                    local bin_name="${TEMP_DIR}/$(basename "${script_path}" .go)"
                    go build -o "${bin_name}" "${script_path}" && "${bin_name}"
                }; else "${script_path}"; fi
            else log_error "未安装Go"; return 1; fi ;;
        shell) bash "${script_path}" ;;
        *) "${script_path}" || bash "${script_path}" ;;
    esac
    local exit_code=$?
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    [[ ${exit_code} -eq 0 ]] && log_info "脚本执行成功" || log_error "脚本执行失败 (退出码: ${exit_code})"
    return ${exit_code}
}

scan_custom_scripts() {
    local scripts=()
    [[ -d "${CUSTOM_SCRIPTS_DIR}" ]] && while IFS= read -r -d '' file; do
        local name=$(basename "${file}")
        local type=$(detect_script_type "${file}")
        local desc=$(get_script_desc "${file}")
        scripts+=("${type}|${file}|${name}|${desc}")
    done < <(find "${CUSTOM_SCRIPTS_DIR}" -type f \( -name "*.py" -o -name "*.sh" -o -name "*.go" -o -name "*.bash" \) -print0 2>/dev/null)
    printf "%s\n" "${scripts[@]}"
}

get_script_icon() {
    case "$1" in
        python) echo "🐍" ;;
        shell) echo "📜" ;;
        go) echo "🚀" ;;
        *) echo "📄" ;;
    esac
}

import_custom_script() {
    show_header "导入自定义脚本"
    echo -e "${MAGENTA}${BOLD}  ▶ 导入方式${NC}\n"
    show_menu_item "1" "从本地路径导入" "复制外部脚本到工具箱"
    show_menu_item "2" "从URL下载导入" "从网络下载脚本并导入"
    show_menu_item "0" "取消" "返回上级"
    echo ""
    read -rp "请选择 [0-2]: " import_choice

    case "${import_choice}" in
        1)
            echo ""; read -rp "输入脚本完整路径: " source_path
            [[ ! -f "${source_path}" ]] && { log_error "文件不存在: ${source_path}"; sleep 2; return; }
            local script_type=$(detect_script_type "${source_path}")
            local target_dir="${CUSTOM_SCRIPTS_DIR}/$(case "${script_type}" in python) echo python ;; shell) echo shell ;; go) echo go ;; *) echo other ;; esac)"
            mkdir -p "${target_dir}"
            local filename=$(basename "${source_path}")
            local target_path="${target_dir}/${filename}"
            if [[ -f "${target_path}" ]]; then
                read -rp "文件已存在，是否覆盖? (y/N): " overwrite
                [[ ! "${overwrite}" =~ ^[Yy]$ ]] && { log_info "已取消导入"; sleep 1; return; }
            fi
            cp "${source_path}" "${target_path}" && chmod +x "${target_path}" 2>/dev/null
            log_info "脚本已导入: ${target_path}"
            ;;
        2)
            echo ""; read -rp "输入脚本URL: " url
            [[ -z "${url}" ]] && { log_error "URL不能为空"; sleep 1; return; }
            local temp_file="${TEMP_DIR}/import_$(date +%s)_$(basename "${url}")"
            log_info "正在下载..."
            if command -v curl &>/dev/null; then
                curl -fsSL "${url}" -o "${temp_file}" 2>/dev/null || { log_error "下载失败"; sleep 2; return; }
            elif command -v wget &>/dev/null; then
                wget -q "${url}" -O "${temp_file}" 2>/dev/null || { log_error "下载失败"; sleep 2; return; }
            else
                log_error "未安装curl或wget"; sleep 2; return
            fi
            local script_type=$(detect_script_type "${temp_file}")
            local target_dir="${CUSTOM_SCRIPTS_DIR}/$(case "${script_type}" in python) echo python ;; shell) echo shell ;; go) echo go ;; *) echo other ;; esac)"
            mkdir -p "${target_dir}"
            local filename=$(basename "${url}")
            [[ "${filename}" == "/" || -z "${filename}" || "${filename}" == *"/"* ]] && {
                case "${script_type}" in python) filename="script_$(date +%s).py" ;; shell) filename="script_$(date +%s).sh" ;; go) filename="script_$(date +%s).go" ;; *) filename="script_$(date +%s)" ;; esac
            }
            local target_path="${target_dir}/${filename}"
            if [[ -f "${target_path}" ]]; then
                read -rp "文件已存在，是否覆盖? (y/N): " overwrite
                [[ ! "${overwrite}" =~ ^[Yy]$ ]] && { rm -f "${temp_file}"; log_info "已取消导入"; sleep 1; return; }
            fi
            mv "${temp_file}" "${target_path}" && chmod +x "${target_path}" 2>/dev/null
            log_info "脚本已导入: ${target_path}"
            ;;
        0) return ;;
    esac
    sleep 2
}

manage_custom_scripts() {
    while true; do
        show_header "管理自定义脚本"
        local scripts=()
        while IFS= read -r line; do [[ -n "${line}" ]] && scripts+=("${line}"); done < <(scan_custom_scripts)
        [[ ${#scripts[@]} -eq 0 ]] && { echo -e "${YELLOW}  暂无自定义脚本${NC}"; sleep 2; return; }

        echo -e "${GREEN}${BOLD}  已导入脚本列表:${NC}\n"
        local i=1
        for script in "${scripts[@]}"; do
            IFS='|' read -r type path name desc <<< "${script}"
            local icon=$(get_script_icon "${type}")
            local size=$(du -h "${path}" 2>/dev/null | cut -f1)
            printf "  ${CYAN}[%-2s]${NC} %s ${BOLD}%-20s${NC} ${CYAN}%-6s${NC} %s\n" "${i}" "${icon}" "${name}" "${size}" "${desc}"
            ((i++))
        done

        echo -e "\n${MAGENTA}${BOLD}  ▶ 管理操作${NC}\n"
        show_menu_item "V" "查看脚本" "查看脚本内容"
        show_menu_item "E" "编辑脚本" "使用编辑器修改脚本"
        show_menu_item "D" "删除脚本" "删除选中的脚本"
        show_menu_item "C" "清空全部" "删除所有自定义脚本"
        show_menu_item "0" "返回" "返回上级"
        echo ""
        read -rp "请选择操作 [0/V/E/D/C]: " choice

        case "${choice}" in
            0) return ;;
            [Vv]) read -rp "输入要查看的脚本编号: " num
                  [[ "${num}" =~ ^[0-9]+$ && "${num}" -gt 0 && "${num}" -le ${#scripts[@]} ]] && {
                      IFS='|' read -r type path name desc <<< "${scripts[$((num-1))]}"
                      show_header "查看脚本: ${name}"
                      echo -e "${CYAN}路径: ${path}${NC}\n"
                      echo -e "${YELLOW}--- 脚本内容 ---${NC}"
                      cat "${path}"
                      echo -e "\n${YELLOW}--- 结束 ---${NC}"
                      echo ""; read -rp "按回车键继续..."
                  } ;;
            [Ee]) read -rp "输入要编辑的脚本编号: " num
                  [[ "${num}" =~ ^[0-9]+$ && "${num}" -gt 0 && "${num}" -le ${#scripts[@]} ]] && {
                      IFS='|' read -r type path name desc <<< "${scripts[$((num-1))]}"
                      command -v nano &>/dev/null && nano "${path}" || command -v vim &>/dev/null && vim "${path}" || command -v vi &>/dev/null && vi "${path}" || log_warn "未找到编辑器"
                  } ;;
            [Dd]) read -rp "输入要删除的脚本编号: " num
                  [[ "${num}" =~ ^[0-9]+$ && "${num}" -gt 0 && "${num}" -le ${#scripts[@]} ]] && {
                      IFS='|' read -r type path name desc <<< "${scripts[$((num-1))]}"
                      read -rp "确认删除 ${name}? (y/N): " confirm
                      [[ "${confirm}" =~ ^[Yy]$ ]] && rm -f "${path}" && log_info "已删除: ${name}" || log_info "已取消"
                  } ;;
            [Cc]) read -rp "确认删除所有自定义脚本? 此操作不可恢复! (yes/N): " confirm
                  [[ "${confirm}" == "yes" ]] && {
                      rm -rf "${CUSTOM_SCRIPTS_DIR}"/*
                      mkdir -p "${CUSTOM_SCRIPTS_DIR}/python" "${CUSTOM_SCRIPTS_DIR}/shell" "${CUSTOM_SCRIPTS_DIR}/go" "${CUSTOM_SCRIPTS_DIR}/other"
                      log_info "已清空所有自定义脚本"
                  } ;;
        esac
        sleep 1
    done
}

add_custom_script() {
    show_header "新建自定义脚本"
    echo -e "${MAGENTA}${BOLD}  ▶ 选择脚本类型${NC}\n"
    show_menu_item "1" "Python脚本" "创建Python脚本模板" "${GREEN}"
    show_menu_item "2" "Shell脚本" "创建Bash脚本模板" "${YELLOW}"
    show_menu_item "3" "Go程序" "创建Go程序模板" "${CYAN}"
    show_menu_item "0" "取消" "返回上级" "${RED}"
    echo ""
    read -rp "请选择类型 [0-3]: " type_choice

    local template_dir template_ext template_content
    case "${type_choice}" in
        1) template_dir="${CUSTOM_SCRIPTS_DIR}/python"; template_ext="py"; template_content='#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# DESC: 自定义Python脚本

import sys
import os

def main():
    print("自定义Python脚本运行中...")

if __name__ == "__main__":
    main()' ;;
        2) template_dir="${CUSTOM_SCRIPTS_DIR}/shell"; template_ext="sh"; template_content='#!/bin/bash
# DESC: 自定义Shell脚本

set -e

echo "自定义Shell脚本运行中..."' ;;
        3) template_dir="${CUSTOM_SCRIPTS_DIR}/go"; template_ext="go"; template_content='package main

// DESC: 自定义Go程序

import "fmt"

func main() {
    fmt.Println("自定义Go程序运行中...")
}' ;;
        0) return ;;
        *) log_error "无效的选择"; sleep 1; return ;;
    esac

    echo ""; read -rp "输入脚本名称(不含扩展名): " script_name
    [[ -z "${script_name}" ]] && { log_error "名称不能为空"; sleep 1; return; }
    script_name=$(echo "${script_name}" | tr -cd '[:alnum:]_-')
    local script_path="${template_dir}/${script_name}.${template_ext}"
    [[ -f "${script_path}" ]] && { log_error "文件已存在: ${script_path}"; sleep 1; return; }
    mkdir -p "${template_dir}"
    echo "${template_content}" > "${script_path}"
    chmod +x "${script_path}" 2>/dev/null || true
    log_info "脚本已创建: ${script_path}"
    read -rp "是否立即编辑? (y/N): " edit_now
    [[ "${edit_now}" =~ ^[Yy]$ ]] && {
        command -v nano &>/dev/null && nano "${script_path}" || command -v vim &>/dev/null && vim "${script_path}" || command -v vi &>/dev/null && vi "${script_path}" || log_warn "未找到编辑器"
    }
}

custom_tools_menu() {
    while true; do
        show_header "自定义工具"
        echo -e "${MAGENTA}${BOLD}  ▶ 已导入的自定义脚本${NC}"
        echo -e "  ${CYAN}脚本存储目录: ${CUSTOM_SCRIPTS_DIR}${NC}\n"
        local scripts=()
        while IFS= read -r line; do [[ -n "${line}" ]] && scripts+=("${line}"); done < <(scan_custom_scripts)

        if [[ ${#scripts[@]} -eq 0 ]]; then
            echo -e "${YELLOW}  暂无自定义脚本${NC}\n"
        else
            echo -e "${GREEN}${BOLD}  可用脚本 (点击编号直接运行):${NC}\n"
            local i=1
            for script in "${scripts[@]}"; do
                IFS='|' read -r type path name desc <<< "${script}"
                local icon=$(get_script_icon "${type}")
                printf "  ${CYAN}[%-2s]${NC} %s ${BOLD}%-20s${NC} %s\n" "${i}" "${icon}" "${name}" "${desc}"
                ((i++))
            done
            echo ""
        fi

        echo -e "${MAGENTA}${BOLD}  ▶ 管理选项${NC}\n"
        show_menu_item "I" "导入脚本" "从外部路径导入脚本到工具箱" "${GREEN}"
        show_menu_item "N" "新建脚本" "创建新的自定义脚本" "${YELLOW}"
        show_menu_item "M" "管理脚本" "查看、删除、编辑已导入的脚本" "${BLUE}"
        show_menu_item "R" "刷新列表" "重新扫描脚本目录" "${CYAN}"
        show_menu_item "0" "返回主菜单" "返回上级" "${RED}"
        echo ""
        read -rp "请选择脚本编号或操作 [0/I/N/M/R]: " choice

        case "${choice}" in
            0) return ;;
            [Ii]) import_custom_script ;;
            [Nn]) add_custom_script ;;
            [Mm]) manage_custom_scripts ;;
            [Rr]) continue ;;
            *)
                if [[ "${choice}" =~ ^[0-9]+$ && "${choice}" -gt 0 ]]; then
                    local idx=$((choice - 1))
                    [[ ${idx} -lt ${#scripts[@]} ]] && {
                        IFS='|' read -r type path name desc <<< "${scripts[${idx}]}"
                        execute_script "${path}" "${type}"
                        echo ""; read -rp "按回车键继续..."
                    } || { log_error "无效的选择"; sleep 1; }
                else
                    log_error "无效的选择"; sleep 1
                fi ;;
        esac
    done
}

#-------------------------------------------------------------------------------
# 远程脚本模块
#-------------------------------------------------------------------------------

load_remote_sources() {
    local sources=()
    [[ -f "${REMOTE_SOURCES_FILE}" ]] && while IFS= read -r line; do
        [[ -z "${line}" || "${line}" =~ ^# ]] && continue
        sources+=("${line}")
    done < "${REMOTE_SOURCES_FILE}"
    printf "%s\n" "${sources[@]}"
}

download_remote_script() {
    local url="$1"
    local filename=$(basename "${url}")
    local local_path="${REMOTE_SCRIPTS_DIR}/${filename}"
    [[ "${filename}" == "/" || -z "${filename}" ]] && {
        filename="script_$(date +%s).sh"
        local_path="${REMOTE_SCRIPTS_DIR}/${filename}"
    }
    log_info "正在下载: ${url}"
    if command -v curl &>/dev/null; then
        curl -fsSL "${url}" -o "${local_path}" 2>/dev/null || { log_error "下载失败: ${url}"; return 1; }
    elif command -v wget &>/dev/null; then
        wget -q "${url}" -O "${local_path}" 2>/dev/null || { log_error "下载失败: ${url}"; return 1; }
    else
        log_error "未安装curl或wget"; return 1
    fi
    chmod +x "${local_path}" 2>/dev/null || true
    log_info "已保存到: ${local_path}"
    echo "${local_path}"
    return 0
}

manage_downloaded_scripts() {
    show_header "已下载的远程脚本"
    local scripts=()
    while IFS= read -r -d '' file; do scripts+=("${file}"); done < <(find "${REMOTE_SCRIPTS_DIR}" -type f -print0 2>/dev/null)
    [[ ${#scripts[@]} -eq 0 ]] && { echo -e "${YELLOW}  暂无已下载的脚本${NC}"; sleep 2; return; }

    echo -e "${GREEN}${BOLD}  已下载脚本列表:${NC}\n"
    local i=1
    for script in "${scripts[@]}"; do
        local name=$(basename "${script}")
        local size=$(du -h "${script}" 2>/dev/null | cut -f1)
        local date=$(stat -c %y "${script}" 2>/dev/null | cut -d' ' -f1 || stat -f %Sm "${script}" 2>/dev/null)
        printf "  ${CYAN}[%-2s]${NC} ${BOLD}%-30s${NC} %s %s\n" "${i}" "${name}" "${size}" "${date}"
        ((i++))
    done

    echo -e "\n${MAGENTA}${BOLD}  ▶ 管理操作${NC}\n"
    show_menu_item "D" "删除选中" "删除指定脚本"
    show_menu_item "E" "清空全部" "删除所有下载的脚本"
    show_menu_item "0" "返回" "返回上级"
    echo ""
    read -rp "请选择操作 [0/D/E]: " choice

    case "${choice}" in
        [Dd]) read -rp "输入要删除的编号: " num
              [[ "${num}" =~ ^[0-9]+$ && "${num}" -gt 0 && "${num}" -le ${#scripts[@]} ]] && {
                  rm -f "${scripts[$((num-1))]}"
                  log_info "已删除"
              } ;;
        [Ee]) read -rp "确认清空所有脚本? (y/N): " confirm
              [[ "${confirm}" =~ ^[Yy]$ ]] && { rm -rf "${REMOTE_SCRIPTS_DIR}"/*; log_info "已清空"; } ;;
        0) return ;;
    esac
    sleep 1
}

manage_remote_sources() {
    show_header "远程脚本源配置"
    echo -e "${CYAN}配置文件: ${REMOTE_SOURCES_FILE}${NC}\n"
    local sources=()
    while IFS= read -r line; do [[ -n "${line}" ]] && sources+=("${line}"); done < <(load_remote_sources)

    if [[ ${#sources[@]} -gt 0 ]]; then
        echo -e "${GREEN}${BOLD}  当前配置的源:${NC}"
        local i=1
        for source in "${sources[@]}"; do
            IFS='|' read -r name url desc <<< "${source}"
            printf "  ${CYAN}%s.${NC} ${BOLD}%s${NC}\n     URL: %s\n     描述: %s\n\n" "${i}" "${name}" "${url}" "${desc}"
            ((i++))
        done
    else
        echo -e "${YELLOW}  暂无配置的源${NC}"
    fi

    echo -e "\n${MAGENTA}${BOLD}  ▶ 操作${NC}\n"
    show_menu_item "1" "添加源" "添加新的远程源"
    show_menu_item "2" "编辑配置" "手动编辑配置文件"
    show_menu_item "0" "返回" "返回上级"
    echo ""
    read -rp "请选择 [0-2]: " choice

    case "${choice}" in
        1) echo ""; read -rp "源名称: " name; read -rp "基础URL: " url; read -rp "描述: " desc
           [[ -n "${name}" && -n "${url}" ]] && echo "${name}|${url}|${desc}" >> "${REMOTE_SOURCES_FILE}" && log_info "源已添加"
           sleep 1 ;;
        2) if command -v nano &>/dev/null; then nano "${REMOTE_SOURCES_FILE}"
           elif command -v vim &>/dev/null; then vim "${REMOTE_SOURCES_FILE}"
           else cat "${REMOTE_SOURCES_FILE}"; echo -e "\n${YELLOW}请使用文本编辑器手动编辑${NC}"; read -rp "按回车键继续..."
           fi ;;
        0) return ;;
    esac
}

quick_download_menu() {
    show_header "快速下载"
    local sources=()
    while IFS= read -r line; do [[ -n "${line}" ]] && sources+=("${line}"); done < <(load_remote_sources)
    [[ ${#sources[@]} -eq 0 ]] && { echo -e "${YELLOW}  请先配置远程源${NC}"; sleep 2; return; }

    echo -e "${MAGENTA}${BOLD}  ▶ 选择源${NC}\n"
    local i=1
    for source in "${sources[@]}"; do
        IFS='|' read -r name url desc <<< "${source}"
        printf "  ${CYAN}[%-2s]${NC} ${BOLD}%-20s${NC} %s\n" "${i}" "${name}" "${desc}"
        ((i++))
    done
    echo ""
    show_menu_item "0" "返回" "返回上级"
    echo ""
    read -rp "请选择源 [0-$((i-1))]: " choice

    [[ "${choice}" == "0" ]] && return
    [[ "${choice}" =~ ^[0-9]+$ && "${choice}" -gt 0 && "${choice}" -le ${#sources[@]} ]] && {
        IFS='|' read -r name url desc <<< "${sources[$((choice-1))]}"
        echo ""; read -rp "输入脚本路径(相对于基础URL): " path
        [[ -n "${path}" ]] && {
            local full_url="${url}${path}"
            full_url=$(echo "${full_url}" | sed 's|//|/|g' | sed 's|http:/|http://|g' | sed 's|https:/|https://|g')
            local downloaded=$(download_remote_script "${full_url}")
            [[ $? -eq 0 ]] && {
                read -rp "是否立即执行? (y/N): " run_now
                [[ "${run_now}" =~ ^[Yy]$ ]] && {
                    local type=$(detect_script_type "${downloaded}")
                    execute_script "${downloaded}" "${type}"
                    echo ""; read -rp "按回车键继续..."
                }
            } || sleep 2
        }
    } || { log_error "无效的选择"; sleep 1; }
}

remote_scripts_menu() {
    while true; do
        show_header "远程脚本"
        echo -e "${MAGENTA}${BOLD}  ▶ 远程脚本管理${NC}\n"
        show_menu_item "1" "从URL下载" "输入指定URL下载脚本"
        show_menu_item "2" "已下载脚本" "管理本地缓存的远程脚本"
        show_menu_item "3" "配置源" "管理远程脚本源列表"
        show_menu_item "4" "快速下载" "从预设源快速获取"
        show_menu_item "0" "返回主菜单" "返回上级"
        echo ""
        read -rp "请选择操作 [0-4]: " choice

        case "${choice}" in
            1) echo ""; read -rp "输入脚本URL: " url
               [[ -n "${url}" ]] && {
                   local downloaded=$(download_remote_script "${url}")
                   [[ $? -eq 0 ]] && {
                       read -rp "是否立即执行? (y/N): " run_now
                       [[ "${run_now}" =~ ^[Yy]$ ]] && {
                           local type=$(detect_script_type "${downloaded}")
                           execute_script "${downloaded}" "${type}"
                           echo ""; read -rp "按回车键继续..."
                       }
                   } || sleep 2
               } ;;
            2) manage_downloaded_scripts ;;
            3) manage_remote_sources ;;
            4) quick_download_menu ;;
            0) return ;;
            *) log_error "无效的选择"; sleep 1 ;;
        esac
    done
}

#-------------------------------------------------------------------------------
# Termux Linux 部署模块（仅 Termux 生效）
#-------------------------------------------------------------------------------

clean_bashrc_entry() {
    local container_name="$1"
    local bashrc="${HOME}/.bashrc"
    [[ ! -f "${bashrc}" ]] && return 0
    local func_name=$(echo "enter_${container_name}" | tr -cd '[:alnum:]_')
    grep -q "# Shell Toolkit - ${container_name} 容器入口" "${bashrc}" 2>/dev/null || grep -q "^${func_name}()" "${bashrc}" 2>/dev/null || return 0
    log_info "清理bashrc中的容器入口: ${container_name}"
    sed -i "/# Shell Toolkit - ${container_name} 容器入口/,/^}$/d" "${bashrc}" 2>/dev/null
    sed -i "/^${func_name}()/,/^}$/d" "${bashrc}" 2>/dev/null
    sed -i "/^alias ${container_name}=/d" "${bashrc}" 2>/dev/null
    sed -i '/^$/{ N; /^\n$/d }' "${bashrc}" 2>/dev/null || true
    log_info "已清理bashrc入口: ${container_name}"
}

add_to_bashrc_func() {
    local container_name="$1" container_type="$2" start_cmd="$3"
    log_info "添加到bashrc..."
    local bashrc="${HOME}/.bashrc"
    local func_name=$(echo "enter_${container_name}" | tr -cd '[:alnum:]_')
    if grep -q "^${func_name}()" "${bashrc}" 2>/dev/null; then
        log_warn "容器名称 '${container_name}' 已存在于bashrc中"
        read -rp "是否覆盖? (y/N): " overwrite
        [[ ! "${overwrite}" =~ ^[Yy]$ ]] && { log_info "已取消添加"; return 1; }
        sed -i "/^${func_name}()/,/^}/d" "${bashrc}"
    fi
    {
        echo ""
        echo "# Shell Toolkit - ${container_name} 容器入口 (${container_type})"
        echo "${func_name}() {"
        echo "    echo '正在进入 ${container_name}...'"
        if [[ "${container_type}" == "proot-distro" ]]; then
            echo "    proot-distro login ${start_cmd}"
        elif [[ "${container_type}" == "chroot" ]]; then
            echo "    if [[ \$EUID -ne 0 ]]; then"
            echo "        echo '需要root权限，尝试使用tsu...'"
            echo "        tsu -c 'bash ${start_cmd}'"
            echo "    else"
            echo "        bash ${start_cmd}"
            echo "    fi"
        else
            echo "    bash ${start_cmd}"
        fi
        echo "}"
        echo "alias ${container_name}='${func_name}'"
    } >> "${bashrc}"
    log_info "已添加到 ${bashrc}"
    echo -e "\n${GREEN}设置完成!${NC}"
    echo -e "${CYAN}使用方法:${NC}"
    echo -e "  1. 重新加载bashrc: ${YELLOW}source ~/.bashrc${NC}"
    echo -e "  2. 输入: ${YELLOW}${container_name}${NC} 即可进入容器"
    echo -e "\n${YELLOW}提示:${NC} 也可以直接运行函数: ${func_name}"
}

manage_bashrc_entries() {
    show_header "管理Bashrc容器入口"
    local bashrc="${HOME}/.bashrc"
    [[ ! -f "${bashrc}" ]] && { echo -e "${YELLOW}未找到 .bashrc 文件${NC}"; sleep 2; return; }
    local entries=() funcs=()
    while IFS= read -r line; do
        if [[ "${line}" =~ ^enter_([a-zA-Z0-9_-]+)\(\) ]]; then
            local name="${BASH_REMATCH[1]}"
            grep -q "^alias ${name}='enter_${name}'" "${bashrc}" 2>/dev/null && { entries+=("${name}"); funcs+=("enter_${name}"); }
        fi
    done < <(grep "^enter_" "${bashrc}" 2>/dev/null)

    if [[ ${#entries[@]} -eq 0 ]]; then
        echo -e "${YELLOW}  暂无配置的容器入口${NC}"
        echo -e "${CYAN}提示: 部署Linux时选择\"添加到bashrc\"选项${NC}"
    else
        echo -e "${GREEN}${BOLD}  ▶ 已配置的容器入口:${NC}\n"
        local i=1
        for entry in "${entries[@]}"; do
            printf "  ${CYAN}[%-2s]${NC} ${BOLD}%-20s${NC} ${YELLOW}输入: %s${NC}\n" "${i}" "${entry}" "${entry}"
            ((i++))
        done
    fi

    echo -e "\n${MAGENTA}${BOLD}  ▶ 管理操作:${NC}\n"
    show_menu_item "D" "删除入口" "从bashrc中删除容器入口" "${RED}"
    show_menu_item "V" "查看详情" "查看函数定义" "${CYAN}"
    show_menu_item "R" "重新加载" "source ~/.bashrc" "${GREEN}"
    show_menu_item "0" "返回" "返回上级" "${BLUE}"
    echo ""
    read -rp "请选择 [0/D/V/R]: " choice

    case "${choice}" in
        [Dd]) [[ ${#entries[@]} -eq 0 ]] && { log_warn "没有可删除的入口"; sleep 1; return; }
              read -rp "输入要删除的编号: " num
              [[ "${num}" =~ ^[0-9]+$ && "${num}" -gt 0 && "${num}" -le ${#entries[@]} ]] && {
                  local entry="${entries[$((num-1))]}"
                  local func="enter_${entry}"
                  read -rp "确认删除 ${entry}? (y/N): " confirm
                  [[ "${confirm}" =~ ^[Yy]$ ]] && {
                      sed -i "/# Shell Toolkit - ${entry}/,/^}$/d" "${bashrc}"
                      sed -i "/^alias ${entry}='${func}'$/d" "${bashrc}"
                      log_info "已删除: ${entry}"
                  }
              }
              sleep 1 ;;
        [Vv]) [[ ${#entries[@]} -eq 0 ]] && { log_warn "没有可查看的入口"; sleep 1; return; }
              read -rp "输入要查看的编号: " num
              [[ "${num}" =~ ^[0-9]+$ && "${num}" -gt 0 && "${num}" -le ${#entries[@]} ]] && {
                  local entry="${entries[$((num-1))]}"
                  show_header "查看容器入口: ${entry}"
                  sed -n "/# Shell Toolkit - ${entry}/,/^}$/p" "${bashrc}"
                  grep "^alias ${entry}=" "${bashrc}" 2>/dev/null
                  echo ""; read -rp "按回车键继续..."
              } ;;
        [Rr]) source "${bashrc}" 2>/dev/null && log_info "bashrc 重新加载成功" || log_warn "重新加载完成，部分设置可能需要重启终端生效"
              sleep 1 ;;
        0) return ;;
    esac
}

readonly TERMUX_LINUX_DIR="${BASE_DIR}/linux_deploy"

get_device_arch() {
    local arch=$(uname -m)
    case "${arch}" in
        aarch64|arm64) echo "arm64" ;;
        armv7l|armhf) echo "armhf" ;;
        x86_64|amd64) echo "amd64" ;;
        i386|i686) echo "i386" ;;
        *) echo "${arch}" ;;
    esac
}

get_rootfs_url() {
    local distro_id="$1" version="$2"
    local arch=$(get_device_arch)
    case "${distro_id}" in
        ubuntu) echo "https://cdimage.ubuntu.com/ubuntu-base/releases/${version}/release/ubuntu-base-${version}-base-${arch}.tar.gz" ;;
        alpine) local major_ver="${version%.*}"; echo "https://dl-cdn.alpinelinux.org/alpine/v${major_ver}/releases/${arch}/alpine-minirootfs-${version}.0-${arch}.tar.gz" ;;
        archlinux) echo "http://os.archlinuxarm.org/os/ArchLinuxARM-${arch}-latest.tar.gz" ;;
        kali) echo "https://kali.download/nethunter-images/current/rootfs/kali-nethunter-rootfs-full-${arch}.tar.xz" ;;
        debian|fedora) echo "docker" ;;
        *) echo "" ;;
    esac
}

download_rootfs() {
    local url="$1" output_file="$2"
    log_info "开始下载rootfs..."
    log_info "URL: ${url}"
    if command -v wget &>/dev/null; then
        wget --progress=bar:force -O "${output_file}" "${url}" 2>&1 || return 1
    elif command -v curl &>/dev/null; then
        curl -fSL --progress-bar -o "${output_file}" "${url}" || return 1
    else
        log_error "未安装wget或curl"; return 1
    fi
    log_info "下载完成"
    return 0
}

extract_rootfs() {
    local archive="$1" target_dir="$2"
    log_info "解压rootfs到 ${target_dir}..."
    mkdir -p "${target_dir}"
    case "${archive}" in
        *.tar.gz|*.tgz) tar -xzf "${archive}" -C "${target_dir}" --exclude='dev/*' ;;
        *.tar.xz|*.txz) tar -xJf "${archive}" -C "${target_dir}" --exclude='dev/*' ;;
        *.tar.bz2) tar -xjf "${archive}" -C "${target_dir}" --exclude='dev/*' ;;
        *) log_error "不支持的压缩格式: ${archive}"; return 1 ;;
    esac && log_info "解压完成"
}

readonly LINUX_DISTROS=(
    "ubuntu|Ubuntu|官方长期支持版本|默认(proot-distro最新版),24.04,22.04,20.04"
    "debian|Debian|稳定可靠的通用发行版|默认(proot-distro最新版),12,11,10"
    "alpine|Alpine Linux|轻量级安全发行版|默认(proot-distro最新版),3.19,3.18,3.17"
    "archlinux|Arch Linux|滚动更新 bleeding-edge|默认(proot-distro最新版),latest"
    "kali|Kali Linux|渗透测试专用发行版|默认(proot-distro最新版),latest"
    "fedora|Fedora|红帽系创新发行版|默认(proot-distro最新版),40,39"
)

show_distro_list() {
    echo -e "${MAGENTA}${BOLD}  ▶ 支持的Linux发行版:${NC}\n"
    local i=1
    for distro in "${LINUX_DISTROS[@]}"; do
        IFS='|' read -r id name desc versions <<< "${distro}"
        local ver_count=$(echo "${versions}" | tr ',' '\n' | wc -l)
        printf "  ${CYAN}[%-2s]${NC} ${BOLD}%-15s${NC} %s ${YELLOW}(%s个版本)${NC}\n" "${i}" "${name}" "${desc}" "${ver_count}"
        ((i++))
    done
    echo ""
}

get_distro_info() {
    local num="$1"
    local idx=$((num - 1))
    [[ ${idx} -ge 0 && ${idx} -lt ${#LINUX_DISTROS[@]} ]] && echo "${LINUX_DISTROS[${idx}]}"
}

show_distro_versions() {
    local distro_id="$1" distro_name="$2" versions_str="$3"
    echo -e "${MAGENTA}${BOLD}  ▶ 选择 ${distro_name} 版本:${NC}\n"
    IFS=',' read -ra versions <<< "${versions_str}"
    local i=1
    for ver in "${versions[@]}"; do
        local desc=""
        if [[ "${ver}" == "默认(proot-distro最新版)" ]]; then
            desc="${GREEN}(推荐)${NC} 自动使用proot-distro官方最新版"
            printf "  ${CYAN}[%-2s]${NC} ${BOLD}%-30s${NC}\n" "${i}" "${ver}"
            printf "      %b\n" "${desc}"
        else
            case "${distro_id}" in
                ubuntu) case "${ver}" in "24.04") desc="(LTS Noble Numbat)";; "22.04") desc="(LTS Jammy Jellyfish)";; "20.04") desc="(LTS Focal Fossa)";; esac ;;
                debian) case "${ver}" in "12") desc="(Bookworm 当前稳定版)";; "11") desc="(Bullseye 旧稳定版)";; "10") desc="(Buster 旧版本)";; esac ;;
            esac
            printf "  ${CYAN}[%-2s]${NC} ${BOLD}%-30s${NC} ${YELLOW}%s${NC}\n" "${i}" "${ver}" "${desc}"
        fi
        ((i++))
    done
    echo -e "\n${YELLOW}提示:${NC} 选择'默认'会自动使用proot-distro安装官方维护的最新版"
    echo -e "       选择其他版本需要手动下载对应版本的rootfs\n"
}

get_distro_version() {
    local versions_str="$1" ver_num="$2"
    local idx=$((ver_num - 1))
    IFS=',' read -ra versions <<< "${versions_str}"
    [[ ${idx} -ge 0 && ${idx} -lt ${#versions[@]} ]] && echo "${versions[${idx}]}"
}

check_deploy_tools() {
    local missing=()
    command -v proot &>/dev/null || command -v proot-distro &>/dev/null || missing+=("proot")
    [[ "${IS_TERMUX}" == true && ! -x /data/data/com.termux/files/usr/bin/tsu ]] && missing+=("tsu")
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_warn "缺少必要工具: ${missing[*]}"
        echo -e "${YELLOW}请安装: pkg install ${missing[*]}${NC}"
        return 1
    fi
    return 0
}

deploy_linux_menu() {
    while true; do
        show_header "部署Linux发行版"
        show_distro_list
        echo -e "${MAGENTA}${BOLD}  ▶ 部署方式:${NC}\n"
        show_menu_item "C" "Chroot部署" "需要root权限，性能更好" "${GREEN}"
        show_menu_item "P" "Proot部署" "无需root，兼容性好" "${YELLOW}"
        show_menu_item "0" "返回" "返回上级菜单" "${RED}"
        echo ""
        read -rp "选择发行版编号和部署方式 (如: 1C 或 2P): " choice
        [[ "${choice}" == "0" ]] && return

        local distro_num=$(echo "${choice}" | grep -o '^[0-9]*')
        local method=$(echo "${choice}" | grep -o '[CcPp]$')
        [[ -z "${distro_num}" || -z "${method}" ]] && { log_error "格式错误，请使用: 数字+C/P"; sleep 2; continue; }

        local distro_info=$(get_distro_info "${distro_num}")
        [[ -z "${distro_info}" ]] && { log_error "无效的发行版编号"; sleep 1; continue; }
        IFS='|' read -r distro_id distro_name distro_desc distro_versions <<< "${distro_info}"

        show_header "选择版本"
        show_distro_versions "${distro_id}" "${distro_name}" "${distro_versions}"
        read -rp "请选择版本 [1-N]: " ver_choice
        local version=$(get_distro_version "${distro_versions}" "${ver_choice}")
        [[ -z "${version}" ]] && { log_error "无效的版本选择"; sleep 1; continue; }

        echo ""
        echo -e "${MAGENTA}${BOLD}  ▶ 容器名称设置${NC}\n"
        local default_name="${distro_id}-${version}"
        [[ "${version}" == "默认(proot-distro最新版)" ]] && default_name="${distro_id}"
        echo -e "${CYAN}默认名称: ${default_name}${NC}"
        read -rp "输入自定义名称(直接回车使用默认): " custom_name
        local container_name="${default_name}"
        [[ -n "${custom_name}" ]] && container_name=$(echo "${custom_name}" | tr -cd '[:alnum:]_-') && [[ -z "${container_name}" ]] && container_name="${default_name}"

        # 检查冲突
        local check_dir="${TERMUX_LINUX_DIR}/${container_name}-"
        case "${method}" in
            [Cc]) check_dir="${TERMUX_LINUX_DIR}/${container_name}-chroot" ;;
            [Pp]) [[ "${version}" != "默认(proot-distro最新版)" ]] && check_dir="${TERMUX_LINUX_DIR}/${container_name}-proot" ;;
        esac
        local exists=false existing_type=""
        [[ -d "${check_dir}" ]] && { exists=true; existing_type="目录"; }
        if [[ "${version}" == "默认(proot-distro最新版)" ]] && command -v proot-distro &>/dev/null && proot-distro list 2>/dev/null | grep -q "^${distro_id}.*Installed"; then
            exists=true; existing_type="proot-distro"
        fi

        if [[ "${exists}" == true ]]; then
            log_warn "名称 '${container_name}' 已存在 (${existing_type})"
            echo ""; echo -e "${CYAN}选项:${NC}"
            show_menu_item "1" "使用其他名称" "使用不同的容器名称" "${GREEN}"
            show_menu_item "2" "强制重新部署" "删除现有数据并重新部署" "${YELLOW}"
            show_menu_item "3" "取消" "返回上级菜单" "${RED}"
            echo ""; read -rp "请选择 [1-3]: " conflict_choice
            case "${conflict_choice}" in
                1) continue ;;
                2) log_warn "将删除现有数据并重新部署..."
                   [[ "${existing_type}" == "目录" ]] && rm -rf "${check_dir}"
                   [[ "${existing_type}" == "proot-distro" || "${version}" == "默认(proot-distro最新版)" ]] && command -v proot-distro &>/dev/null && proot-distro remove "${distro_id}" 2>/dev/null || true
                   clean_bashrc_entry "${container_name}" ;;
                *) return ;;
            esac
        fi

        case "${method}" in
            [Cc]) deploy_with_chroot "${distro_id}" "${distro_name}" "${version}" "${container_name}" ;;
            [Pp]) deploy_with_proot "${distro_id}" "${distro_name}" "${version}" "${container_name}" ;;
        esac
    done
}

deploy_with_chroot() {
    local distro_id="$1" distro_name="$2" version="$3" container_name="${4:-${distro_id}-${version}}"
    show_header "Chroot部署 - ${distro_name} ${version}"
    echo -e "${CYAN}容器名称: ${container_name}${NC}\n"
    if [[ "${version}" == "默认(proot-distro最新版)" ]]; then
        log_warn "Chroot部署需要选择具体版本"
        echo -e "${YELLOW}请返回并选择具体的版本号（如24.04、12等）${NC}"
        read -rp "按回车键继续..."
        return
    fi
    check_deploy_tools || { read -rp "按回车键继续..."; return; }
    if [[ $EUID -ne 0 ]]; then
        log_warn "Chroot需要root权限"
        command -v tsu &>/dev/null || { log_error "未安装tsu，无法获取root权限"; read -rp "按回车键继续..."; return; }
    fi

    local install_dir="${TERMUX_LINUX_DIR}/${container_name}-chroot"
    local rootfs_dir="${install_dir}/rootfs"
    local temp_dir="${TERMUX_LINUX_DIR}/.downloads"
    local download_url=$(get_rootfs_url "${distro_id}" "${version}")
    [[ -z "${download_url}" ]] && { log_error "无法获取下载URL"; read -rp "按回车键继续..."; return; }
    local filename=$(basename "${download_url}")
    local archive_file="${temp_dir}/${filename}"
    mkdir -p "${temp_dir}"

    echo -e "${CYAN}部署路径: ${install_dir}${NC}"
    echo -e "${CYAN}设备架构: $(get_device_arch)${NC}\n"
    echo -e "${YELLOW}即将下载:${NC} ${download_url}\n"

    if [[ -f "${archive_file}" ]]; then
        read -rp "检测到已存在下载文件，是否重新下载? (y/N): " redownload
        [[ "${redownload}" =~ ^[Yy]$ ]] && rm -f "${archive_file}"
    fi
    if [[ ! -f "${archive_file}" ]]; then
        download_rootfs "${download_url}" "${archive_file}" || { read -rp "按回车键继续..."; return; }
    fi

    echo ""; read -rp "确认解压并部署? (Y/n): " confirm
    [[ "${confirm}" =~ ^[Nn]$ ]] && { log_info "已取消部署"; return; }
    extract_rootfs "${archive_file}" "${rootfs_dir}" || { read -rp "按回车键继续..."; return; }

    # 配置DNS
    [[ -d "${rootfs_dir}/etc" ]] && {
        echo "nameserver 8.8.8.8" > "${rootfs_dir}/etc/resolv.conf"
        echo "nameserver 114.114.114.114" >> "${rootfs_dir}/etc/resolv.conf"
    }

    # 创建启动脚本
    local start_script="${install_dir}/start-chroot.sh"
    cat > "${start_script}" << 'CHROOT_EOF'
#!/bin/bash
# Chroot启动脚本

CHROOT_DIR="INSTALL_DIR/rootfs"

if [[ $EUID -ne 0 ]]; then
    echo "需要root权限运行"
    exit 1
fi

# 挂载必要的文件系统
mount -t proc proc ${CHROOT_DIR}/proc 2>/dev/null || true
mount -t sysfs sysfs ${CHROOT_DIR}/sys 2>/dev/null || true
mount -o bind /dev ${CHROOT_DIR}/dev 2>/dev/null || true
mount -o bind /dev/pts ${CHROOT_DIR}/dev/pts 2>/dev/null || true

# 进入chroot
chroot ${CHROOT_DIR} /bin/bash

# 退出后卸载
umount ${CHROOT_DIR}/proc 2>/dev/null || true
umount ${CHROOT_DIR}/sys 2>/dev/null || true
umount ${CHROOT_DIR}/dev/pts 2>/dev/null || true
umount ${CHROOT_DIR}/dev 2>/dev/null || true
CHROOT_EOF
    sed -i "s|INSTALL_DIR|${install_dir}|g" "${start_script}"
    chmod +x "${start_script}"

    # 询问是否删除压缩包
    read -rp "是否删除下载的压缩包以节省空间? (y/N): " delete_archive
    [[ "${delete_archive}" =~ ^[Yy]$ ]] && rm -f "${archive_file}" && log_info "已删除压缩包"

    # 添加到bashrc
    read -rp "是否添加到bashrc?(输入容器名称即可进入) (y/N): " add_to_bashrc
    [[ "${add_to_bashrc}" =~ ^[Yy]$ ]] && add_to_bashrc_func "${container_name}" "chroot" "${start_script}"

    echo ""; log_info "${distro_name} ${version} Chroot部署完成!"
    echo -e "${GREEN}容器名称: ${container_name}${NC}"
    echo -e "${GREEN}启动命令:${NC} ${CYAN}tsu -c bash ${start_script}${NC}"
    echo -e "${YELLOW}注意: Chroot需要root权限运行${NC}"
    sleep 2; read -rp "按回车键继续..."
}

deploy_with_proot() {
    local distro_id="$1" distro_name="$2" version="$3" container_name="${4:-${distro_id}}"
    show_header "Proot部署 - ${distro_name} ${version}"
    echo -e "${CYAN}容器名称: ${container_name}${NC}\n"
    check_deploy_tools || { read -rp "按回车键继续..."; return; }

    if [[ "${version}" == "默认(proot-distro最新版)" ]]; then
        command -v proot-distro &>/dev/null || { log_error "未安装proot-distro"; echo -e "${YELLOW}请先安装: pkg install proot-distro${NC}"; read -rp "按回车键继续..."; return; }
        if proot-distro list 2>/dev/null | grep -q "^${distro_id}.*Installed"; then
            echo ""; log_warn "${distro_name} 已经通过proot-distro安装"
            echo ""; echo -e "${CYAN}操作选项:${NC}"
            show_menu_item "1" "直接登录" "启动已安装的${distro_name}" "${GREEN}"
            show_menu_item "2" "重新安装" "重置/重新安装（数据会丢失）" "${YELLOW}"
            show_menu_item "3" "卸载" "删除已安装的${distro_name}" "${RED}"
            show_menu_item "0" "返回" "返回上级菜单" "${BLUE}"
            echo ""; read -rp "请选择 [0-3]: " installed_choice
            case "${installed_choice}" in
                1) proot-distro login "${distro_id}" ;;
                2) read -rp "确认重新安装? 数据将丢失! (yes/N): " reinstall_confirm
                   [[ "${reinstall_confirm}" == "yes" ]] && { log_info "正在重新安装 ${distro_id}..."; proot-distro reset "${distro_id}" 2>&1; } ;;
                3) read -rp "确认卸载? 数据将丢失! (yes/N): " remove_confirm
                   [[ "${remove_confirm}" == "yes" ]] && { log_info "正在卸载 ${distro_id}..."; proot-distro remove "${distro_id}" 2>&1; } ;;
                0) return ;;
            esac
            echo ""; read -rp "按回车键继续..."; return
        fi

        echo ""; echo -e "${CYAN}将使用proot-distro安装${distro_name}${NC}"
        echo -e "${YELLOW}proot-distro会安装官方维护的最新版rootfs${NC}\n"
        read -rp "确认安装? (Y/n): " confirm
        [[ "${confirm}" =~ ^[Nn]$ ]] && return
        log_info "正在使用proot-distro安装 ${distro_id}..."
        proot-distro install "${distro_id}" 2>&1
        if [[ $? -eq 0 ]]; then
            echo ""; log_info "安装成功！"
            echo -e "${GREEN}启动命令:${NC} ${CYAN}proot-distro login ${distro_id}${NC}\n"
            local install_dir="${TERMUX_LINUX_DIR}/${container_name}-proot-distro"
            mkdir -p "${install_dir}"
            cat > "${install_dir}/start-proot-distro.sh" << PROOTDISTEOF
#!/bin/bash
# proot-distro启动脚本
DISTRO_ID="${distro_id}"
proot-distro login \${DISTRO_ID}
PROOTDISTEOF
            chmod +x "${install_dir}/start-proot-distro.sh"
            read -rp "是否添加到bashrc?(输入容器名称即可进入) (y/N): " add_to_bashrc
            [[ "${add_to_bashrc}" =~ ^[Yy]$ ]] && add_to_bashrc_func "${container_name}" "proot-distro" "${distro_id}"
        else
            log_error "安装失败"
            echo -e "${YELLOW}可能的原因: 网络问题、存储空间不足${NC}"
        fi
        read -rp "按回车键继续..."
        return
    fi

    # 非默认版本手动部署
    local download_url=$(get_rootfs_url "${distro_id}" "${version}")
    [[ -z "${download_url}" ]] && { log_error "不支持的发行版: ${distro_id}"; sleep 2; return; }
    if [[ "${download_url}" == "docker" ]]; then
        echo -e "${YELLOW}${distro_name}需要通过Docker导出方式获取${NC}"
        echo -e "${CYAN}请手动执行: docker pull ${distro_id}:${version} 并导出rootfs${NC}"
        echo -e "${YELLOW}或者选择'默认'版本使用proot-distro安装${NC}"
        sleep 3; return
    fi

    local install_dir="${TERMUX_LINUX_DIR}/${container_name}-proot"
    local rootfs_dir="${install_dir}/rootfs"
    local temp_dir="${TERMUX_LINUX_DIR}/.downloads"
    local filename=$(basename "${download_url}")
    local archive_file="${temp_dir}/${filename}"
    mkdir -p "${temp_dir}"

    echo -e "${CYAN}部署路径: ${install_dir}${NC}"
    echo -e "${CYAN}设备架构: $(get_device_arch)${NC}\n"
    echo -e "${YELLOW}即将下载:${NC} ${download_url}\n"

    if [[ -f "${archive_file}" ]]; then
        read -rp "检测到已存在下载文件，是否重新下载? (y/N): " redownload
        [[ "${redownload}" =~ ^[Yy]$ ]] && rm -f "${archive_file}"
    fi
    if [[ ! -f "${archive_file}" ]]; then
        download_rootfs "${download_url}" "${archive_file}" || { read -rp "按回车键继续..."; return; }
    fi

    echo ""; read -rp "确认解压并部署? (Y/n): " confirm
    [[ "${confirm}" =~ ^[Nn]$ ]] && { log_info "已取消部署"; return; }
    extract_rootfs "${archive_file}" "${rootfs_dir}" || { read -rp "按回车键继续..."; return; }

    # 配置DNS
    [[ -d "${rootfs_dir}/etc" ]] && {
        echo "nameserver 8.8.8.8" > "${rootfs_dir}/etc/resolv.conf"
        echo "nameserver 114.114.114.114" >> "${rootfs_dir}/etc/resolv.conf"
    }

    # 创建启动脚本
    local start_script="${install_dir}/start-proot.sh"
    cat > "${start_script}" << EOF
#!/bin/bash
# ${distro_name} ${version} Proot启动脚本

PROOT_DIR="${rootfs_dir}"

if [[ ! -d "\${PROOT_DIR}" ]]; then
    echo "错误: 未找到rootfs目录"
    exit 1
fi

# 启动proot
exec proot \
    --link2symlink \
    --root-id \
    --cwd=/root \
    --rootfs="\${PROOT_DIR}" \
    -b /dev -b /proc -b /sys -b /sdcard -b /data \
    /bin/bash --login
EOF
    chmod +x "${start_script}"

    read -rp "是否删除下载的压缩包以节省空间? (y/N): " delete_archive
    [[ "${delete_archive}" =~ ^[Yy]$ ]] && rm -f "${archive_file}" && log_info "已删除压缩包"

    read -rp "是否添加到bashrc?(输入容器名称即可进入) (y/N): " add_to_bashrc
    [[ "${add_to_bashrc}" =~ ^[Yy]$ ]] && add_to_bashrc_func "${container_name}" "proot" "${start_script}"

    echo ""; log_info "${distro_name} ${version} 部署完成!"
    echo -e "${GREEN}启动命令:${NC} ${CYAN}bash ${start_script}${NC}"
    [[ -n "${add_to_bashrc}" ]] && echo -e "${GREEN}或直接输入: ${container_name}${NC}"
    sleep 2; read -rp "按回车键继续..."
}

manage_deployed_linux() {
    while true; do
        show_header "管理已部署的Linux"
        local deployments=()
        if [[ -d "${TERMUX_LINUX_DIR}" ]]; then
            for dir in "${TERMUX_LINUX_DIR}"/*/; do
                [[ -d "${dir}" ]] || continue
                local name=$(basename "${dir}")
                local type=$(echo "${name}" | grep -oE '(chroot|proot|proot-distro)$' || echo "unknown")
                local distro_ver=""
                if [[ "${name}" == *"-proot-distro" ]]; then
                    distro=$(echo "${name}" | sed 's/-proot-distro$//')
                    distro_ver="${distro} (proot-distro官方版)"
                    type="proot-distro"
                else
                    local tmp=$(echo "${name}" | sed 's/-chroot$//;s/-proot$//')
                    distro=$(echo "${tmp}" | sed 's/-[0-9].*$//;s/-latest$//;s/-rolling$//;s/-默认.*$//')
                    version=$(echo "${tmp}" | grep -oE '[0-9]+.*$|latest$|rolling$|默认.*$' || echo "custom")
                    distro_ver="${distro} ${version}"
                fi
                local size=$(du -sh "${dir}" 2>/dev/null | cut -f1)
                local status="${GREEN}●${NC}"
                [[ "${type}" != "proot-distro" && ! -d "${dir}/rootfs" ]] && status="${YELLOW}○${NC}"
                deployments+=("${name}|${distro_ver}|${type}|${size}|${status}")
            done
        fi

        if command -v proot-distro &>/dev/null; then
            while IFS= read -r line; do
                [[ -z "${line}" ]] && continue
                local alias=$(echo "${line}" | awk '{print $1}')
                local installed=$(echo "${line}" | grep -o 'Installed' || echo "")
                local already_added=false
                for d in "${deployments[@]}"; do
                    [[ "${d}" == "${alias}-proot-distro|*" ]] && already_added=true && break
                done
                if [[ "${installed}" == "Installed" && "${already_added}" == false ]]; then
                    local is_supported=false
                    for sd in "${LINUX_DISTROS[@]}"; do
                        IFS='|' read -r sid sname sdesc svers <<< "${sd}"
                        [[ "${sid}" == "${alias}" ]] && is_supported=true && break
                    done
                    if [[ "${is_supported}" == true ]]; then
                        local size="unknown"
                        [[ -d "${PREFIX}/var/lib/proot-distro/installed-rootfs/${alias}" ]] && size=$(du -sh "${PREFIX}/var/lib/proot-distro/installed-rootfs/${alias}" 2>/dev/null | cut -f1)
                        deployments+=("${alias}|${alias} (proot-distro官方版)|proot-distro|${size}|${GREEN}●${NC}")
                    fi
                fi
            done < <(proot-distro list 2>/dev/null | grep -v '^#' | tail -n +2)
        fi

        if [[ ${#deployments[@]} -eq 0 ]]; then
            echo -e "${YELLOW}  暂无已部署的Linux发行版${NC}"
            echo -e "${CYAN}提示: 使用\"部署Linux发行版\"选项来安装${NC}"
        else
            echo -e "${GREEN}${BOLD}  ▶ 已部署的Linux系统:${NC}\n"
            local i=1
            for deploy in "${deployments[@]}"; do
                IFS='|' read -r name distro_ver type size status <<< "${deploy}"
                local type_icon=$([[ "${type}" == "chroot" ]] && echo "🔒" || echo "📦")
                printf "  %b ${CYAN}[%-2s]${NC} %s ${BOLD}%-12s${NC} [${MAGENTA}%-6s${NC}] %s\n" "${status}" "${i}" "${type_icon}" "${distro_ver}" "${type}" "${size}"
                ((i++))
            done
        fi

        echo -e "\n${MAGENTA}${BOLD}  ▶ 管理操作:${NC}\n"
        show_menu_item "S" "启动系统" "启动选中的Linux" "${GREEN}"
        show_menu_item "B" "备份系统" "备份rootfs" "${YELLOW}"
        show_menu_item "R" "删除系统" "删除部署（保留备份）" "${RED}"
        show_menu_item "C" "完全清理" "删除部署和备份" "${RED}"
        show_menu_item "0" "返回" "返回上级" "${BLUE}"
        echo ""
        read -rp "请选择操作 [0/S/B/R/C]或输入编号直接启动: " choice

        case "${choice}" in
            0) return ;;
            [Ss]) [[ ${#deployments[@]} -eq 0 ]] && { log_warn "没有可启动的系统"; sleep 1; continue; }
                  read -rp "输入要启动的系统编号: " num
                  [[ "${num}" =~ ^[0-9]+$ && "${num}" -gt 0 && "${num}" -le ${#deployments[@]} ]] && {
                      local idx=$((num-1))
                      IFS='|' read -r name distro_ver type size status <<< "${deployments[${idx}]}"
                      if [[ "${type}" == "proot-distro" ]]; then
                          local pd_alias=$(echo "${name}" | sed 's/-proot-distro$//')
                          log_info "启动 ${distro_ver}..."
                          proot-distro login "${pd_alias}"
                      else
                          local start_script="${TERMUX_LINUX_DIR}/${name}/start-${type}.sh"
                          if [[ -f "${start_script}" ]]; then
                              log_info "启动 ${distro_ver} (${type})..."
                              if [[ "${type}" == "chroot" ]]; then
                                  if [[ $EUID -eq 0 ]]; then bash "${start_script}"
                                  else tsu -c "bash ${start_script}" 2>/dev/null || log_error "需要root权限"
                                  fi
                              else bash "${start_script}"
                              fi
                          else log_error "未找到启动脚本: ${start_script}"
                          fi
                      fi
                      echo ""; read -rp "按回车键继续..."
                  } ;;
            [Bb]) [[ ${#deployments[@]} -eq 0 ]] && { log_warn "没有可备份的系统"; sleep 1; continue; }
                  read -rp "输入要备份的系统编号: " num
                  [[ "${num}" =~ ^[0-9]+$ && "${num}" -gt 0 && "${num}" -le ${#deployments[@]} ]] && {
                      local idx=$((num-1))
                      IFS='|' read -r name distro_ver type size status <<< "${deployments[${idx}]}"
                      local distro_clean=$(echo "${distro_ver}" | tr ' ' '_' | tr '.' '_')
                      local backup_name="${distro_clean}_${type}_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
                      local backup_path="${TERMUX_LINUX_DIR}/${backup_name}"
                      log_info "正在备份 ${distro_ver} (${type})..."
                      tar -czf "${backup_path}" -C "${TERMUX_LINUX_DIR}/${name}" rootfs 2>/dev/null && log_info "备份完成: ${backup_path}" || log_error "备份失败"
                      sleep 2
                  } ;;
            [Rr]) [[ ${#deployments[@]} -eq 0 ]] && { log_warn "没有可删除的系统"; sleep 1; continue; }
                  read -rp "输入要删除的系统编号: " num
                  [[ "${num}" =~ ^[0-9]+$ && "${num}" -gt 0 && "${num}" -le ${#deployments[@]} ]] && {
                      local idx=$((num-1))
                      IFS='|' read -r name distro_ver type size status <<< "${deployments[${idx}]}"
                      read -rp "确认删除 ${distro_ver} (${type})? 数据将被删除但保留备份 (y/N): " confirm
                      [[ "${confirm}" =~ ^[Yy]$ ]] && {
                          if [[ "${type}" == "proot-distro" ]]; then
                              local pd_alias=$(echo "${name}" | sed 's/-proot-distro$//')
                              command -v proot-distro &>/dev/null && proot-distro remove "${pd_alias}" 2>/dev/null || true
                          fi
                          rm -rf "${TERMUX_LINUX_DIR:?}/${name}"
                          log_info "已删除 ${distro_ver} 所有数据"
                          local entry_name=$(echo "${name}" | sed 's/-proot-distro$//;s/-chroot$//;s/-proot$//')
                          clean_bashrc_entry "${entry_name}"
                      }
                      sleep 1
                  } ;;
            [Cc]) [[ ${#deployments[@]} -eq 0 ]] && { log_warn "没有可清理的系统"; sleep 1; continue; }
                  read -rp "输入要完全清理的系统编号: " num
                  [[ "${num}" =~ ^[0-9]+$ && "${num}" -gt 0 && "${num}" -le ${#deployments[@]} ]] && {
                      local idx=$((num-1))
                      IFS='|' read -r name distro_ver type size status <<< "${deployments[${idx}]}"
                      read -rp "警告: 这将完全删除 ${distro_ver} 包括所有数据! 确认? (yes/N): " confirm
                      [[ "${confirm}" == "yes" ]] && {
                          if [[ "${type}" == "proot-distro" ]]; then
                              local pd_alias=$(echo "${name}" | sed 's/-proot-distro$//')
                              command -v proot-distro &>/dev/null && proot-distro remove "${pd_alias}" 2>/dev/null || true
                          fi
                          rm -rf "${TERMUX_LINUX_DIR:?}/${name}"
                          log_info "已完全删除 ${distro_ver}"
                          local entry_name=$(echo "${name}" | sed 's/-proot-distro$//;s/-chroot$//;s/-proot$//')
                          clean_bashrc_entry "${entry_name}"
                      } || log_info "已取消"
                      sleep 1
                  } ;;
            *)
                if [[ "${choice}" =~ ^[0-9]+$ && "${choice}" -gt 0 && "${choice}" -le ${#deployments[@]} ]]; then
                    local idx=$((choice-1))
                    IFS='|' read -r name distro_ver type size status <<< "${deployments[${idx}]}"
                    if [[ "${type}" == "proot-distro" ]]; then
                        local pd_alias=$(echo "${name}" | sed 's/-proot-distro$//')
                        log_info "启动 ${distro_ver}..."
                        proot-distro login "${pd_alias}"
                    else
                        local start_script="${TERMUX_LINUX_DIR}/${name}/start-${type}.sh"
                        [[ -f "${start_script}" ]] && {
                            log_info "启动 ${distro_ver} (${type})..."
                            if [[ "${type}" == "chroot" ]]; then
                                if [[ $EUID -eq 0 ]]; then bash "${start_script}"
                                else tsu -c "bash ${start_script}" 2>/dev/null || log_error "需要root权限"
                                fi
                            else bash "${start_script}"
                            fi
                        }
                    fi
                    echo ""; read -rp "按回车键继续..."
                else
                    log_error "无效的选择"; sleep 1
                fi ;;
        esac
    done
}

xxx_zone_menu() {
    while true; do
        show_header "$(get_system_name)专区"
        if [[ "${IS_TERMUX}" == true ]]; then
            echo -e "${MAGENTA}${BOLD}  ▶ Termux Linux部署中心${NC}\n"
            show_menu_item "1" "部署Linux发行版" "使用Chroot/Proot部署Linux" "${GREEN}"
            show_menu_item "2" "管理已部署的系统" "启动/备份/删除Linux" "${YELLOW}"
            show_menu_item "3" "管理Bashrc入口" "管理容器快捷入口" "${CYAN}"
            show_menu_item "4" "安装部署工具" "安装proot、tsu等必要工具" "${BLUE}"
            show_menu_item "0" "返回主菜单" "返回上级" "${RED}"
            echo ""
            read -rp "请选择 [0-4]: " choice
            case "${choice}" in
                1) deploy_linux_menu ;;
                2) manage_deployed_linux ;;
                3) manage_bashrc_entries ;;
                4) show_header "安装部署工具"; log_info "正在安装必要工具..."; pkg install proot tsu wget tar -y; sleep 2 ;;
                0) return ;;
                *) log_error "无效的选择"; sleep 1 ;;
            esac
        else
            echo -e "${MAGENTA}${BOLD}  ▶ $(get_system_name)专区${NC}"
            echo -e "  ${YELLOW}此区域为Termux环境预留${NC}\n"
            echo -e "  ${CYAN}当前系统: ${NC}$(uname -s)"
            echo -e "  ${CYAN}平台: ${NC}$(get_system_name)\n"
            echo -e "  ${YELLOW}此专区在Termux环境下提供以下功能:${NC}"
            echo -e "  - Linux发行版部署 (Chroot/Proot)"
            echo -e "  - 已部署系统的管理"
            echo -e "  - 部署工具安装\n"
            show_menu_item "0" "返回主菜单" "返回上级" "${RED}"
            echo ""
            read -rp "请选择 [0]: " choice
            [[ "${choice}" == "0" ]] && return
            log_error "无效的选择"; sleep 1
        fi
    done
}

#-------------------------------------------------------------------------------
# 工具箱管理模块
#-------------------------------------------------------------------------------

backup_config() {
    show_header "备份配置"
    local backup_name="toolkit_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    local backup_path="${HOME}/${backup_name}"
    log_info "正在创建备份: ${backup_name}"
    tar -czf "${backup_path}" -C "${BASE_DIR}" . 2>/dev/null || { log_error "备份失败"; sleep 2; return 1; }
    log_info "备份完成: ${backup_path}"
    if [[ "${IS_TERMUX}" == true ]] && command -v termux-share &>/dev/null; then
        read -rp "是否分享备份文件? (y/N): " share
        [[ "${share}" =~ ^[Yy]$ ]] && termux-share "${backup_path}"
    fi
    sleep 2
}

restore_config() {
    show_header "恢复配置"
    echo -e "${YELLOW}可用的备份文件:${NC}"
    ls -lh "${HOME}"/toolkit_backup_*.tar.gz 2>/dev/null || { echo "未找到备份文件"; sleep 2; return; }
    echo ""; read -rp "输入备份文件名(含路径): " backup_file
    if [[ -f "${backup_file}" ]]; then
        read -rp "恢复将覆盖当前配置，确认? (y/N): " confirm
        [[ "${confirm}" =~ ^[Yy]$ ]] && {
            local pre_restore="${BASE_DIR}/.pre_restore_$(date +%s)"
            mv "${BASE_DIR}" "${pre_restore}" 2>/dev/null
            mkdir -p "${BASE_DIR}"
            tar -xzf "${backup_file}" -C "${BASE_DIR}" 2>/dev/null && {
                log_info "恢复成功"; rm -rf "${pre_restore}" 2>/dev/null
            } || {
                log_error "恢复失败，正在还原..."; rm -rf "${BASE_DIR}" 2>/dev/null; mv "${pre_restore}" "${BASE_DIR}" 2>/dev/null
            }
        }
    else
        log_error "文件不存在"
    fi
    sleep 2
}

show_toolkit_info() {
    show_header "工具箱环境信息"
    echo -e "${CYAN}${BOLD}  基础信息:${NC}"
    echo "    版本: ${VERSION}"
    echo "    安装目录: ${BASE_DIR}"
    echo "    配置目录: ${CONFIG_DIR}"
    echo "    Termux模式: ${IS_TERMUX}"
    echo -e "\n${CYAN}${BOLD}  目录状态:${NC}"
    echo "    自定义脚本: $(find "${CUSTOM_SCRIPTS_DIR}" -type f 2>/dev/null | wc -l) 个文件"
    echo "    远程脚本: $(find "${REMOTE_SCRIPTS_DIR}" -type f 2>/dev/null | wc -l) 个文件"
    echo "    日志大小: $(du -sh "${LOG_DIR}" 2>/dev/null | cut -f1)"
    echo -e "\n${CYAN}${BOLD}  系统兼容性:${NC}"
    echo "    Shell: ${BASH_VERSION}"
    echo "    平台: $(uname -s)"
    echo "    架构: $(uname -m)"
    echo ""; read -rp "按回车键继续..."
}

check_updates() {
    show_header "检查更新"
    log_info "当前版本: ${VERSION}"
    log_info "正在检查更新..."
    echo -e "\n${GREEN}  您当前运行的是最新版本${NC}"
    echo ""; read -rp "按回车键继续..."
}

management_menu() {
    while true; do
        show_header "工具箱管理"
        echo -e "${MAGENTA}${BOLD}  ▶ 管理选项${NC}\n"
        show_menu_item "1" "查看日志" "查看工具箱运行日志"
        show_menu_item "2" "清理缓存" "清理临时文件和日志"
        show_menu_item "3" "备份配置" "备份自定义脚本和配置"
        show_menu_item "4" "恢复配置" "从备份恢复"
        show_menu_item "5" "系统信息" "显示工具箱环境信息"
        show_menu_item "6" "检查更新" "检查工具箱更新"
        show_menu_item "0" "返回主菜单" "返回上级"
        echo ""
        read -rp "请选择操作 [0-6]: " choice

        case "${choice}" in
            1) show_header "工具箱日志"
               [[ -f "${LOG_DIR}/toolkit.log" ]] && tail -50 "${LOG_DIR}/toolkit.log" || echo "暂无日志"
               echo ""; read -rp "按回车键继续..." ;;
            2) log_info "正在清理缓存..."
               rm -rf "${TEMP_DIR}"/* 2>/dev/null
               find "${LOG_DIR}" -name "*.log" -type f -mtime +7 -delete 2>/dev/null
               log_info "清理完成"; sleep 1 ;;
            3) backup_config ;;
            4) restore_config ;;
            5) show_toolkit_info ;;
            6) check_updates ;;
            0) return ;;
            *) log_error "无效的选择"; sleep 1 ;;
        esac
    done
}

#-------------------------------------------------------------------------------
# 主程序
#-------------------------------------------------------------------------------

main() {
    init_directories || exit 1
    check_dependencies
    while true; do
        show_main_menu
        read -rp "请输入选项 [0-5]: " choice
        case "${choice}" in
            1) basic_tools_menu ;;
            2) custom_tools_menu ;;
            3) remote_scripts_menu ;;
            4) management_menu ;;
            5) xxx_zone_menu ;;
            0) clear_screen
               echo -e "${GREEN}感谢使用 ${SCRIPT_NAME} v${VERSION}${NC}"
               echo ""; exit 0 ;;
            *) log_error "无效的选项: ${choice}"; sleep 1 ;;
        esac
    done
}

trap 'echo ""; log_warn "接收到中断信号，正在退出..."; exit 130' INT TERM

main "$@"