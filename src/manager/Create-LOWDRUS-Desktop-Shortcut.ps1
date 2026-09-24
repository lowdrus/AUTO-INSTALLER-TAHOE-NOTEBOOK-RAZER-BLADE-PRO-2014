$ErrorActionPreference='Stop'
$managerDir=Split-Path -Parent $MyInvocation.MyCommand.Path
$launcher=Join-Path $managerDir 'Start-LOWDRUS-INSTALLER.cmd'
$icon=Join-Path $managerDir 'assets\LOWDRUS-INSTALLER.ico'
if(!(Test-Path -LiteralPath $launcher)){throw 'Launcher LOWDRUS nao encontrado.'}
if(!(Test-Path -LiteralPath $icon)){throw 'Icone LOWDRUS nao encontrado em src\manager\assets\LOWDRUS-INSTALLER.ico'}
$desktop=[Environment]::GetFolderPath('Desktop')
$link=Join-Path $desktop 'LOWDRUS INSTALLER.lnk'
$ws=New-Object -ComObject WScript.Shell
$s=$ws.CreateShortcut($link)
$s.TargetPath=$launcher
$s.WorkingDirectory=$managerDir
$s.IconLocation=$icon+',0'
$s.Description='LOWDRUS INSTALLER - Tahoe Edition'
$s.Save()
Write-Host 'Atalho LOWDRUS INSTALLER criado na Area de Trabalho.'
