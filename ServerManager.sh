#!/bin/bash

# 颜色代码
colorRed='\033[0;31m'
colorGreen='\033[0;32m'
colorYellow='\033[1;33m'
colorBlue='\033[0;34m'
colorMagenta='\033[0;35m'
colorCyan='\033[0;36m'
colorNone='\033[0m'

# 全局变量
authorInfo="BetterServerManager v1.0 | Author: Marecyra | ©2025"
welcomeMsg="欢迎使用 Better Server Manager"
currentTime=$(date "+%Y-%m-%d %H:%M:%S")
systemInfo=""
licenseInfo="本程序遵循 GNU General Public License v3.0 开源协议。"

logoArt='

Version 0.1 \n
██████╗ ███████╗████████╗████████╗███████╗██████╗       ███████╗███╗   ███╗ \n
██╔══██╗██╔════╝╚══██╔══╝╚══██╔══╝██╔════╝██╔══██╗      ██╔════╝████╗ ████║ \n
██████╔╝█████╗     ██║      ██║   █████╗  ██████╔╝█████╗███████╗██╔████╔██║ \n
██╔══██╗██╔══╝     ██║      ██║   ██╔══╝  ██╔══██╗╚════╝╚════██║██║╚██╔╝██║ \n
██████╔╝███████╗   ██║      ██║   ███████╗██║  ██║      ███████║██║ ╚═╝ ██║ \n
╚═════╝ ╚══════╝   ╚═╝      ╚═╝   ╚══════╝╚═╝  ╚═╝      ╚══════╝╚═╝     ╚═╝ \n
                                                                           

'

# 显示版权信息
showCopyright() {
    dialog --title "Better Server Manager" \
           --yes-label "接受" \
           --no-label "拒绝" \
           --yesno "\n$logoArt\n\n$welcomeMsg\n\n版权声明:\n$licenseInfo\n\n$authorInfo" 40 100
    
    if [ $? -ne 0 ]; then
        clear
        exit 0
    fi
}

# 显示帮助
showHelp() {
    dialog --title "命令帮助" \
           --msgbox "$(man $1 | col -bx | head -n 30)" 20 70
}

# 系统监控菜单
systemMonitorMenu() {
    while true; do
        choice=$(dialog --stdout \
            --title "系统监控工具" \
            --menu "选择工具: (按H显示帮助)\n按下 Q 或 Ctrl+C 退出当前打开的工具" 18 60 10 \
            "1" "top | 实时系统资源监控器" \
            "2" "htop | 增强版系统监控器" \
            "3" "df -h | 磁盘空间使用情况" \
            "4" "free -h | 内存使用统计" \
            "5" "iostat | IO设备使用统计" \
            "6" "vmstat | 虚拟内存统计" \
            "9" "返回主菜单")
        
        [ $? -ne 0 ] && return

        # 检查是否按下H键获取帮助
        case "$REPLY" in
            104|72) # ASCII码 'h'或'H'
                showHelp "${choice#* }" # 提取命令名称
                continue
                ;;
        esac

        case "$choice" in
            1) runCommand "top" ;;
            2) runCommand "htop" ;;
            3) runCommand "df -h" ;;
            4) runCommand "free -h" ;;
            5) runCommand "iostat" ;;
            6) runCommand "vmstat" ;;
            9) return ;;
        esac
    done
}

# 网络工具菜单
networkToolsMenu() {
    while true; do
        choice=$(dialog --stdout \
            --title "网络调试工具" \
            --menu "选择工具: (按H显示帮助)\n按下 Q 或 Ctrl+C 退出当前打开的工具" 18 60 10 \
            "1" "netstat -an | 显示所有网络连接" \
            "2" "netstat -tlpn | 显示监听端口" \
            "3" "ss -tuln | 显示网络统计信息" \
            "4" "ifconfig | 网络接口配置" \
            "5" "route -n | 路由表信息" \
            "6" "iptables -L | 防火墙规则" \
            "7" "ping -c 4 | 网络连通性测试" \
            "8" "traceroute | 路由追踪" \
            "9" "返回主菜单")
        
        [ $? -ne 0 ] && return

        case "$REPLY" in
            104|72)
                showHelp "${choice#* }"
                continue
                ;;
        esac

        case "$choice" in
            1) runCommand "netstat -an" ;;
            2) runCommand "netstat -tlpn" ;;
            3) runCommand "ss -tuln" ;;
            4) runCommand "ifconfig" ;;
            5) runCommand "route -n" ;;
            6) runCommand "sudo iptables -L" ;;
            7) runCommand "ping -c 4 8.8.8.8" ;;
            8) runCommand "traceroute 8.8.8.8" ;;
            9) return ;;
        esac
    done
}

# 系统维护菜单
systemMaintenanceMenu() {
    while true; do
        choice=$(dialog --stdout \
            --title "系统维护工具" \
            --menu "选择工具: (按H显示帮助)\n按下 Q 或 Ctrl+C 退出当前打开的工具" 18 60 10 \
            "1" "journalctl | 系统日志查看" \
            "2" "systemctl | 服务管理" \
            "3" "find / -type f -size | 大文件查找" \
            "4" "du -sh /* | 目录空间占用" \
            "5" "lsof | 打开文件列表" \
            "6" "fdisk -l | 磁盘分区信息" \
            "7" "chkconfig | 服务启动项" \
            "8" "last | 登录历史记录" \
            "9" "返回主菜单")
        
        [ $? -ne 0 ] && return

        case "$REPLY" in
            104|72)
                showHelp "${choice#* }"
                continue
                ;;
        esac

        case "$choice" in
            1) runCommand "journalctl -n 50" ;;
            2) runCommand "systemctl list-units" ;;
            3) runCommand "find / -type f -size +100M 2>/dev/null" ;;
            4) runCommand "du -sh /*" ;;
            5) runCommand "lsof" ;;
            6) runCommand "sudo fdisk -l" ;;
            7) runCommand "chkconfig --list" ;;
            8) runCommand "last" ;;
            9) return ;;
        esac
    done
}

# 主菜单
mainMenu() {
    initSystemInfo
    
    while true; do
        choice=$(dialog --stdout \
            --colors \
            --title "服务器控制台" \
            --backtitle "$welcomeMsg 当前时间: $currentTime $systemInfo" \
            --menu "主菜单\n选择功能类别:" 20 70 10 \
            "1" "系统监控" \
            "2" "网络工具" \
            "3" "系统管理" \
            "4" "系统维护" \
            "5" "电源管理" \
            "9" "退出程序")
        
        [ $? -ne 0 ] && { clear; exit 0; }

        case "$choice" in
            1) systemMonitorMenu ;;
            2) networkToolsMenu ;;
            3) systemActionsMenu ;;
            4) systemMaintenanceMenu ;;
            5) powerManagementMenu ;;
            9) clear; exit 0 ;;
        esac
    done
}

# 初始化系统信息
initSystemInfo() {
    local kernelVersion=$(uname -r)
    local cpuArch=$(uname -m)
    systemInfo="内核: $kernelVersion | 架构: $cpuArch"
}

# 检查依赖
checkDependencies() {
    local deps=("dialog")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        echo -e "${colorRed}错误: 缺少必需的依赖: ${missing[*]}${colorNone}"
        echo -e "请使用包管理器安装所需依赖后重试"
        exit 1
    fi
}

# 执行命令
runCommand() {
    clear
    echo -e "${colorBlue}▶ 执行命令: $1${colorNone}\n"
    eval "$1"
    echo -e "\n${colorYellow}▼ 命令执行完成 ▼${colorNone}"
    read -p "按回车返回菜单..." </dev/tty
}

# 确认操作
confirmAction() {
    dialog --yesno "$2" 6 40
    if [ $? -eq 0 ]; then
        clear
        echo -e "${colorRed}执行: $1${colorNone}"
        eval "$1"
    fi
}

# 显示帮助
showHelp() {
    clear
    echo -e "\n${colorCyan}★ 命令帮助: $1 ★${colorNone}\n"
    man "$1" | col -bx | head -n 30
    read -p "按回车返回菜单..." </dev/tty
}

# 系统管理菜单
systemActionsMenu() {
    while true; do
        choice=$(dialog --stdout \
            --title "系统管理操作" \
            --menu "选择操作:" 18 60 10 \
            "1" "系统信息" \
            "2" "进程列表" \
            "3" "服务状态" \
            "4" "用户管理" \
            "9" "返回主菜单")
        
        [ $? -ne 0 ] && return

        case "$choice" in
            1) runCommand "uname -a" ;;
            2) runCommand "ps aux" ;;
            3) runCommand "systemctl status" ;;
            4) runCommand "who" ;;
            9) return ;;
        esac
    done
}

# 电源管理菜单
powerManagementMenu() {
    while true; do
        choice=$(dialog --stdout \
            --title "电源管理" \
            --menu "选择操作: (请谨慎操作)" 18 60 10 \
            "1" "立即关机" \
            "2" "立即重启" \
            "3" "注销当前用户" \
            "4" "延时关机" \
            "5" "延时重启" \
            "6" "取消延时任务" \
            "9" "返回主菜单")
        
        [ $? -ne 0 ] && return

        case "$choice" in
            1) confirmAction "sudo shutdown -h now" "确定要立即关机吗？" ;;
            2) confirmAction "sudo shutdown -r now" "确定要立即重启吗？" ;;
            3) confirmAction "pkill -KILL -u $(whoami)" "确定要注销当前用户吗？" ;;
            4) 
                minutes=$(dialog --stdout --inputbox "请输入延时时间(分钟):" 8 40)
                [ $? -eq 0 ] && confirmAction "sudo shutdown -h +$minutes" "系统将在 $minutes 分钟后关机，确认吗？" 
                ;;
            5)
                minutes=$(dialog --stdout --inputbox "请输入延时时间(分钟):" 8 40)
                [ $? -eq 0 ] && confirmAction "sudo shutdown -r +$minutes" "系统将在 $minutes 分钟后重启，确认吗？" 
                ;;
            6) runCommand "sudo shutdown -c" ;;
            9) return ;;
        esac
    done
}

# 修改主菜单，添加电源管理选项
mainMenu() {
    initSystemInfo
    
    while true; do
        choice=$(dialog --stdout \
            --colors \
            --title "服务器控制台" \
            --backtitle "$welcomeMsg 当前时间: $currentTime $systemInfo" \
            --menu "主菜单\n选择功能类别:" 20 70 10 \
            "1" "系统监控" \
            "2" "网络工具" \
            "3" "系统管理" \
            "4" "系统维护" \
            "5" "电源管理" \
            "9" "退出程序")
        
        [ $? -ne 0 ] && { clear; exit 0; }

        case "$choice" in
            1) systemMonitorMenu ;;
            2) networkToolsMenu ;;
            3) systemActionsMenu ;;
            4) systemMaintenanceMenu ;;
            5) powerManagementMenu ;;
            9) clear; exit 0 ;;
        esac
    done
}

# 主菜单
# 删除这个重复的 mainMenu 函数
# mainMenu() {
#     initSystemInfo
#     
#     while true; do
#         choice=$(dialog --stdout \
#             --colors \
#             --title " ■ 服务器控制台 ■" \
#             --backtitle "$welcomeMsg\n当前时间: $currentTime\n$systemInfo" \
#             --menu "主菜单\n选择功能类别:" 20 70 10 \
#             "1" "系统监控" \
#             "2" "网络工具" \
#             "3" "系统管理" \
#             "9" "退出程序")
#         
#         [ $? -ne 0 ] && { clear; exit 0; }
#
#         case "$choice" in
#             1) systemMonitorMenu ;;
#             2) networkToolsMenu ;;
#             3) systemActionsMenu ;;
#             9) clear; exit 0 ; echo Bye ;;
#         esac
#     done
# }
# 主菜单
mainMenu() {
    initSystemInfo
    
    while true; do
        choice=$(dialog --stdout \
            --colors \
            --title "服务器控制台" \
            --backtitle "$welcomeMsg 当前时间: $currentTime $systemInfo" \
            --menu "主菜单\n选择功能类别:" 20 70 10 \
            "1" "系统监控" \
            "2" "网络工具" \
            "3" "系统管理" \
            "4" "系统维护" \
            "5" "电源管理" \
            "9" "退出程序")
        
        [ $? -ne 0 ] && { clear; exit 0; }

        case "$choice" in
            1) systemMonitorMenu ;;
            2) networkToolsMenu ;;
            3) systemActionsMenu ;;
            4) systemMaintenanceMenu ;;
            5) powerManagementMenu ;;
            9) clear; exit 0 ;;
        esac
    done
}

# 主程序入口
main() {
    checkDependencies
    showCopyright
    mainMenu
    clear
}

main