#!/bin/bash

# Color codes
colorRed='\033[0;31m'
colorGreen='\033[0;32m'
colorYellow='\033[1;33m'
colorBlue='\033[0;34m'
colorMagenta='\033[0;35m'
colorCyan='\033[0;36m'
colorNone='\033[0m'

# Global variables
authorInfo="BetterServerManager v1.0 | Author: Marecyra | ©2025"
welcomeMsg="Welcome to Better Server Manager"
currentTime=$(date "+%Y-%m-%d %H:%M:%S")
systemInfo=""
licenseInfo="This program is licensed under GNU General Public License v3.0."

logoArt='

Version 0.1 - TTY \n
██████╗ ███████╗████████╗████████╗███████╗██████╗       ███████╗███╗   ███╗ \n
██╔══██╗██╔════╝╚══██╔══╝╚══██╔══╝██╔════╝██╔══██╗      ██╔════╝████╗ ████║ \n
██████╔╝█████╗     ██║      ██║   █████╗  ██████╔╝█████╗███████╗██╔████╔██║ \n
██╔══██╗██╔══╝     ██║      ██║   ██╔══╝  ██╔══██╗╚════╝╚════██║██║╚██╔╝██║ \n
██████╔╝███████╗   ██║      ██║   ███████╗██║  ██║      ███████║██║ ╚═╝ ██║ \n
╚═════╝ ╚══════╝   ╚═╝      ╚═╝   ╚══════╝╚═╝  ╚═╝      ╚══════╝╚═╝     ╚═╝ \n
 

'

# Show copyright
showCopyright() {
    dialog --title "Better Server Manager" \
           --yes-label "Accept" \
           --no-label "Decline" \
           --yesno "\n$logoArt\n\n$welcomeMsg\n\nLicense:\n$licenseInfo\n\n$authorInfo" 40 100
    
    if [ $? -ne 0 ]; then
        clear
        exit 0
    fi
}

# Show help
showHelp() {
    dialog --title "Command Help" \
           --msgbox "$(man $1 | col -bx | head -n 30)" 20 70
}

# System monitor menu
systemMonitorMenu() {
    while true; do
        choice=$(dialog --stdout \
            --title "System Monitoring Tools" \
            --menu "Select tool: (Press H for help)\nPress Q or Ctrl+C to exit current tool" 18 60 10 \
            "1" "top | Real-time system monitor" \
            "2" "htop | Enhanced system monitor" \
            "3" "df -h | Disk space usage" \
            "4" "free -h | Memory usage" \
            "5" "iostat | IO device statistics" \
            "6" "vmstat | Virtual memory stats" \
            "9" "Return to main menu")
        
        [ $? -ne 0 ] && return

        case "$REPLY" in
            104|72)
                showHelp "${choice#* }"
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

# Network tools menu
networkToolsMenu() {
    while true; do
        choice=$(dialog --stdout \
            --title "Network Tools" \
            --menu "Select tool: (Press H for help)\nPress Q or Ctrl+C to exit current tool" 18 60 10 \
            "1" "netstat -an | Show all network connections" \
            "2" "netstat -tlpn | Show listening ports" \
            "3" "ss -tuln | Show network statistics" \
            "4" "ifconfig | Network interface config" \
            "5" "route -n | Routing table info" \
            "6" "iptables -L | Firewall rules" \
            "7" "ping -c 4 | Network connectivity test" \
            "8" "traceroute | Route tracing" \
            "9" "Return to main menu")
        
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

# System maintenance menu
systemMaintenanceMenu() {
    while true; do
        choice=$(dialog --stdout \
            --title "System Maintenance Tools" \
            --menu "Select tool: (Press H for help)\nPress Q or Ctrl+C to exit current tool" 18 60 10 \
            "1" "journalctl | View system logs" \
            "2" "systemctl | Service management" \
            "3" "find / -type f -size | Find large files" \
            "4" "du -sh /* | Directory space usage" \
            "5" "lsof | List open files" \
            "6" "fdisk -l | Disk partition info" \
            "7" "chkconfig | Service startup config" \
            "8" "last | Login history" \
            "9" "Return to main menu")
        
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

# System management menu
systemActionsMenu() {
    while true; do
        choice=$(dialog --stdout \
            --title "System Management" \
            --menu "Select operation:" 18 60 10 \
            "1" "System Information" \
            "2" "Process List" \
            "3" "Service Status" \
            "4" "User Management" \
            "9" "Return to main menu")
        
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

# Power management menu
powerManagementMenu() {
    while true; do
        choice=$(dialog --stdout \
            --title "Power Management" \
            --menu "Select operation: (Use with caution)" 18 60 10 \
            "1" "Shutdown Now" \
            "2" "Restart Now" \
            "3" "Logout Current User" \
            "4" "Delayed Shutdown" \
            "5" "Delayed Restart" \
            "6" "Cancel Scheduled Tasks" \
            "9" "Return to main menu")
        
        [ $? -ne 0 ] && return

        case "$choice" in
            1) confirmAction "sudo shutdown -h now" "Are you sure you want to shutdown now?" ;;
            2) confirmAction "sudo shutdown -r now" "Are you sure you want to restart now?" ;;
            3) confirmAction "pkill -KILL -u $(whoami)" "Are you sure you want to logout?" ;;
            4) 
                minutes=$(dialog --stdout --inputbox "Enter delay time (minutes):" 8 40)
                [ $? -eq 0 ] && confirmAction "sudo shutdown -h +$minutes" "System will shutdown in $minutes minutes. Confirm?" 
                ;;
            5)
                minutes=$(dialog --stdout --inputbox "Enter delay time (minutes):" 8 40)
                [ $? -eq 0 ] && confirmAction "sudo shutdown -r +$minutes" "System will restart in $minutes minutes. Confirm?" 
                ;;
            6) runCommand "sudo shutdown -c" ;;
            9) return ;;
        esac
    done
}

# Main menu
mainMenu() {
    initSystemInfo
    
    while true; do
        choice=$(dialog --stdout \
            --colors \
            --title "Server Console" \
            --backtitle "$welcomeMsg Time: $currentTime $systemInfo" \
            --menu "Main Menu\nSelect category:" 20 70 10 \
            "1" "System Monitor" \
            "2" "Network Tools" \
            "3" "System Management" \
            "4" "System Maintenance" \
            "5" "Power Management" \
            "9" "Exit")
        
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

# Initialize system info
initSystemInfo() {
    local kernelVersion=$(uname -r)
    local cpuArch=$(uname -m)
    systemInfo="Kernel: $kernelVersion | Arch: $cpuArch"
}

# Check dependencies
checkDependencies() {
    local deps=("dialog")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        echo -e "${colorRed}Error: Missing required dependencies: ${missing[*]}${colorNone}"
        echo -e "Please install the required dependencies using your package manager"
        exit 1
    fi
}

# Run command
runCommand() {
    clear
    echo -e "${colorBlue}▶ Executing: $1${colorNone}\n"
    eval "$1"
    echo -e "\n${colorYellow}▼ Command completed ▼${colorNone}"
    read -p "Press Enter to return to menu..." </dev/tty
}

# Confirm action
confirmAction() {
    dialog --yesno "$2" 6 40
    if [ $? -eq 0 ]; then
        clear
        echo -e "${colorRed}Executing: $1${colorNone}"
        eval "$1"
    fi
}

# Program entry
main() {
    checkDependencies
    showCopyright
    mainMenu
    clear
}

main