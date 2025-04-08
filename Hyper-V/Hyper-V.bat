@echo off
:: Hyper-V 和 WSL2 管理工具
:: 使用 PowerShell 命令实现功能
:: 需要管理员权限运行

:: 检查管理员权限
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo 请以管理员身份运行此脚本！
    pause
    exit /b
)

:menu
cls
echo ======================================
echo      Hyper-V 和 WSL2 管理工具
echo ======================================
echo 1. 启用 Hyper-V 和 WSL2
echo 2. 禁用 Hyper-V 和 WSL2
echo 3. 仅启用 Hyper-V
echo 4. 仅禁用 Hyper-V
echo 5. 仅启用 WSL2
echo 6. 仅禁用 WSL2
echo 7. 下载 WSL2 内核更新
echo Q. 退出
echo ======================================

set /p choice=请选择 [1-7 或 Q]:
if "%choice%"=="1" goto enable_all
if "%choice%"=="2" goto disable_all
if "%choice%"=="3" goto enable_hyperv
if "%choice%"=="4" goto disable_hyperv
if "%choice%"=="5" goto enable_wsl
if "%choice%"=="6" goto disable_wsl
if "%choice%"=="7" goto download_wsl
if /i "%choice%"=="q" goto quit
echo 无效选择，请重试。
pause
goto menu

:enable_all
powershell -command "Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart; Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart; Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart"
echo Hyper-V 和 WSL2 已启用。可能需要重启计算机。
pause
goto menu

:disable_all
powershell -command "Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All; Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux; Disable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform"
echo Hyper-V 和 WSL2 已禁用。需要重启计算机。
pause
goto menu

:enable_hyperv
powershell -command "Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart"
echo Hyper-V 已启用。可能需要重启计算机。
pause
goto menu

:disable_hyperv
powershell -command "Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All"
echo Hyper-V 已禁用。需要重启计算机。
pause
goto menu

:enable_wsl
powershell -command "Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart; Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart"
echo WSL2 已启用。建议重启计算机后运行 'wsl --set-default-version 2' 设置默认版本。
pause
goto menu

:disable_wsl
powershell -command "Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux; Disable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform"
echo WSL2 已禁用。需要重启计算机。
pause
goto menu

:download_wsl
cls
echo ======================================
echo      WSL2 内核下载选项
echo ======================================
echo 1. 下载最新稳定版 WSL2 内核
echo 2. 下载旧版 WSL2 内核 (适用于某些兼容性问题)
echo 3. 返回主菜单
echo ======================================

set /p wsl_choice=请选择 [1-3]:
if "%wsl_choice%"=="1" (
    powershell -command "$url = 'https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi'; $output = \"$env:USERPROFILE\Downloads\wsl_update_x64_latest.msi\"; Invoke-WebRequest -Uri $url -OutFile $output; Write-Host \"下载完成。文件保存在: $output\"; Write-Host \"请运行该MSI文件以更新WSL2内核。\""
    pause
    goto menu
)
if "%wsl_choice%"=="2" (
    powershell -command "$url = 'https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64_legacy.msi'; $output = \"$env:USERPROFILE\Downloads\wsl_update_x64_legacy.msi\"; Invoke-WebRequest -Uri $url -OutFile $output; Write-Host \"下载完成。文件保存在: $output\"; Write-Host \"请运行该MSI文件以更新WSL2内核。\""
    pause
    goto menu
)
if "%wsl_choice%"=="3" goto menu
echo 无效选择，请重试。
pause
goto download_wsl

:quit
echo 退出脚本。
pause