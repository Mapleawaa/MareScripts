@echo off
:: Hyper-V �� WSL2 ������
:: ʹ�� PowerShell ����ʵ�ֹ���
:: ��Ҫ����ԱȨ������

:: ������ԱȨ��
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ���Թ���Ա������д˽ű���
    pause
    exit /b
)

:menu
cls
echo ======================================
echo      Hyper-V �� WSL2 ������
echo ======================================
echo 1. ���� Hyper-V �� WSL2
echo 2. ���� Hyper-V �� WSL2
echo 3. ������ Hyper-V
echo 4. ������ Hyper-V
echo 5. ������ WSL2
echo 6. ������ WSL2
echo 7. ���� WSL2 �ں˸���
echo Q. �˳�
echo ======================================

set /p choice=��ѡ�� [1-7 �� Q]:
if "%choice%"=="1" goto enable_all
if "%choice%"=="2" goto disable_all
if "%choice%"=="3" goto enable_hyperv
if "%choice%"=="4" goto disable_hyperv
if "%choice%"=="5" goto enable_wsl
if "%choice%"=="6" goto disable_wsl
if "%choice%"=="7" goto download_wsl
if /i "%choice%"=="q" goto quit
echo ��Чѡ�������ԡ�
pause
goto menu

:enable_all
powershell -command "Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart; Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart; Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart"
echo Hyper-V �� WSL2 �����á�������Ҫ�����������
pause
goto menu

:disable_all
powershell -command "Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All; Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux; Disable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform"
echo Hyper-V �� WSL2 �ѽ��á���Ҫ�����������
pause
goto menu

:enable_hyperv
powershell -command "Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart"
echo Hyper-V �����á�������Ҫ�����������
pause
goto menu

:disable_hyperv
powershell -command "Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All"
echo Hyper-V �ѽ��á���Ҫ�����������
pause
goto menu

:enable_wsl
powershell -command "Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart; Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart"
echo WSL2 �����á�������������������� 'wsl --set-default-version 2' ����Ĭ�ϰ汾��
pause
goto menu

:disable_wsl
powershell -command "Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux; Disable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform"
echo WSL2 �ѽ��á���Ҫ�����������
pause
goto menu

:download_wsl
cls
echo ======================================
echo      WSL2 �ں�����ѡ��
echo ======================================
echo 1. ���������ȶ��� WSL2 �ں�
echo 2. ���ؾɰ� WSL2 �ں� (������ĳЩ����������)
echo 3. �������˵�
echo ======================================

set /p wsl_choice=��ѡ�� [1-3]:
if "%wsl_choice%"=="1" (
    powershell -command "$url = 'https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi'; $output = \"$env:USERPROFILE\Downloads\wsl_update_x64_latest.msi\"; Invoke-WebRequest -Uri $url -OutFile $output; Write-Host \"������ɡ��ļ�������: $output\"; Write-Host \"�����и�MSI�ļ��Ը���WSL2�ںˡ�\""
    pause
    goto menu
)
if "%wsl_choice%"=="2" (
    powershell -command "$url = 'https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64_legacy.msi'; $output = \"$env:USERPROFILE\Downloads\wsl_update_x64_legacy.msi\"; Invoke-WebRequest -Uri $url -OutFile $output; Write-Host \"������ɡ��ļ�������: $output\"; Write-Host \"�����и�MSI�ļ��Ը���WSL2�ںˡ�\""
    pause
    goto menu
)
if "%wsl_choice%"=="3" goto menu
echo ��Чѡ�������ԡ�
pause
goto download_wsl

:quit
echo �˳��ű���
pause