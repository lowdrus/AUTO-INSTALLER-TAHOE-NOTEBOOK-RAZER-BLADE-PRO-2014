param(
  [ValidateSet('status','diagnose','repair-check','recovery-check','logs','export-report')][string]$Action='status',
  [string]$OutFile
)
$ErrorActionPreference='Stop'

$EXPECTED_TAR_SIZE=18437734400
$EXPECTED_TAR_SHA='7EA862E4FB009E5E7AEBCA7F9A43B0AA8471149084841CBEF95F19BEA8EE53B4'
$EXPECTED_PKG_SIZE=18381960622
$EXPECTED_PKG_SHA='23261873087FCCA0432E6CCC293C858ED9CE5D22C528FFF801BB1653786FA9AE'

function C([string]$state,[string]$text){[ordered]@{state=$state;text=$text}}
function Repo-Root { Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) }
function Report-Dir {
  $d=Join-Path (Repo-Root) 'reports\windows'
  New-Item -ItemType Directory -Force -Path $d | Out-Null
  $d
}
function Find-LowdrusVolume {
  foreach($d in Get-CimInstance Win32_LogicalDisk | Where-Object {$_.DriveType -in 2,3 -and $_.DeviceID -match '^[A-Z]:$'}){
    $root=$d.DeviceID+'\'
    try{
      if(-not(Test-Path -LiteralPath $root -ErrorAction Stop)){continue}
      if($d.VolumeName -eq 'LOWDRUS' -or
         (Test-Path -LiteralPath ($root+'LOWDRUS-TRANSPORT') -ErrorAction SilentlyContinue) -or
         (Test-Path -LiteralPath ($root+'InstallAssistant.pkg') -ErrorAction SilentlyContinue)){
        return [pscustomobject]@{Root=$root;Label=$d.VolumeName;Size=$d.Size;DriveType=$d.DriveType}
      }
    }catch{}
  }
  $null
}
function Find-FileDeep([string]$root,[string]$name){
  $direct=Join-Path $root $name
  if(Test-Path -LiteralPath $direct){return Get-Item -LiteralPath $direct}
  Get-ChildItem -LiteralPath $root -Filter $name -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
}
function Get-HardwareInventory {
  $os=Get-CimInstance Win32_OperatingSystem
  $cs=Get-CimInstance Win32_ComputerSystem
  [ordered]@{
    computer=[ordered]@{manufacturer=$cs.Manufacturer;model=$cs.Model;totalMemoryBytes=[int64]$cs.TotalPhysicalMemory}
    operatingSystem=[ordered]@{caption=$os.Caption;version=$os.Version;build=$os.BuildNumber;architecture=$os.OSArchitecture}
    cpu=@(Get-CimInstance Win32_Processor | Select-Object Name,Manufacturer,NumberOfCores,NumberOfLogicalProcessors,MaxClockSpeed)
    gpu=@(Get-CimInstance Win32_VideoController | Select-Object Name,AdapterRAM,DriverVersion,VideoProcessor)
    memoryModules=@(Get-CimInstance Win32_PhysicalMemory | Select-Object Manufacturer,PartNumber,Capacity,Speed,ConfiguredClockSpeed)
    disks=@(Get-CimInstance Win32_DiskDrive | Select-Object Model,SerialNumber,Size,InterfaceType,MediaType,PNPDeviceID)
    networkAdapters=@(Get-CimInstance Win32_NetworkAdapter | Where-Object {$_.PhysicalAdapter} | Select-Object Name,MACAddress,AdapterType,NetEnabled,PNPDeviceID)
    audio=@(Get-CimInstance Win32_SoundDevice | Select-Object Name,Manufacturer,Status,PNPDeviceID)
    bios=Get-CimInstance Win32_BIOS | Select-Object Manufacturer,SMBIOSBIOSVersion,ReleaseDate,SerialNumber
    baseBoard=Get-CimInstance Win32_BaseBoard | Select-Object Manufacturer,Product,Version,SerialNumber
    battery=@(Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue | Select-Object Name,Status,EstimatedChargeRemaining)
  }
}
function New-BaseResult {
  $checks=[ordered]@{}
  $vol=Find-LowdrusVolume
  $tar=$null;$pkg=$null
  if(!$vol){
    $checks.lexar=C error 'Midia LOWDRUS nao encontrada'
    $checks.efi=C pending 'Aguardando midia LOWDRUS'
    $checks.builder=C pending 'Aguardando midia LOWDRUS'
    $checks.payload=C pending 'Aguardando midia LOWDRUS'
  }else{
    $checks.lexar=C ok ('Detectada em '+$vol.Root.TrimEnd('\'))
    $tar=Find-FileDeep $vol.Root 'Tahoe-Builder.tar'
    $pkg=Find-FileDeep $vol.Root 'InstallAssistant.pkg'
    $checks.builder=if($tar -and $tar.Length -eq $EXPECTED_TAR_SIZE){C ok 'Tahoe Builder encontrado (tamanho validado)'}elseif($tar){C error 'Tahoe Builder com tamanho inesperado'}else{C error 'Tahoe Builder nao encontrado'}
    $checks.payload=if($pkg -and $pkg.Length -eq $EXPECTED_PKG_SIZE){C ok 'InstallAssistant encontrado (tamanho validado)'}elseif($pkg){C error 'InstallAssistant com tamanho inesperado'}else{C warn 'InstallAssistant nao localizado'}
    $checks.efi=C warn 'EFI preservada: validacao destrutiva permanece bloqueada'
  }
  $cs=Get-CimInstance Win32_ComputerSystem
  $isTarget=(($cs.Manufacturer+' '+$cs.Model) -match 'Razer') -and (($cs.Model -match 'Blade Pro') -or ($cs.Model -match 'RZ09-0117'))
  $checks.hardware=if($isTarget){C ok ('Razer alvo detectado: '+$cs.Manufacturer+' '+$cs.Model)}else{C warn ('Executando em '+$cs.Manufacturer+' '+$cs.Model+'; instalacao liberada somente no Razer validado')}
  $internal=@(Get-CimInstance Win32_DiskDrive | Where-Object {$_.InterfaceType -ne 'USB'})
  $checks.storage=if($isTarget -and $internal.Count){C warn ('Armazenamento interno: '+(($internal.Model|Where-Object{$_}) -join '; ')+'; alvo ainda nao selecionado')}else{C warn 'Nenhum disco de destino sera alterado pelo Manager'}
  [pscustomobject]@{checks=$checks;volume=$vol;tar=$tar;pkg=$pkg;isTarget=$isTarget}
}
try{
  $base=New-BaseResult
  $checks=$base.checks
  $inventory=$null;$reportPath=$null;$extra=[ordered]@{}
  if($Action -in @('diagnose','export-report')){
    if($base.tar -and $base.tar.Length -eq $EXPECTED_TAR_SIZE){
      $h=(Get-FileHash -LiteralPath $base.tar.FullName -Algorithm SHA256).Hash
      $checks.builder=if($h -eq $EXPECTED_TAR_SHA){C ok 'Tahoe Builder SHA-256 aprovado'}else{C error 'Tahoe Builder SHA-256 invalido'}
    }
    if($base.pkg -and $base.pkg.Length -eq $EXPECTED_PKG_SIZE){
      $h=(Get-FileHash -LiteralPath $base.pkg.FullName -Algorithm SHA256).Hash
      $checks.payload=if($h -eq $EXPECTED_PKG_SHA){C ok 'InstallAssistant SHA-256 aprovado'}else{C error 'InstallAssistant SHA-256 invalido'}
    }
    $inventory=Get-HardwareInventory
    $reportPath=Join-Path (Report-Dir) ('LOWDRUS-HARDWARE-'+(Get-Date -Format 'yyyyMMdd-HHmmss')+'.json')
  }
  if($Action -eq 'repair-check'){
    $extra.repair=[ordered]@{safe=$true;destructive=$false;summary='Pre-flight de reparo concluido. Nenhuma EFI foi substituida.'}
  }
  if($Action -eq 'recovery-check'){
    $extra.recovery=[ordered]@{safe=$true;destructive=$false;summary='Pre-flight de recuperacao concluido. Operacoes destrutivas continuam bloqueadas.'}
  }
  if($Action -eq 'logs'){
    $dir=Report-Dir
    $extra.logs=@(Get-ChildItem $dir -File -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 20 Name,FullName,Length,LastWriteTime)
  }
  $message=switch($Action){
    'diagnose' {'Diagnostico completo concluido e inventario salvo.'}
    'export-report' {'Relatorio completo exportado.'}
    'repair-check' {$extra.repair.summary}
    'recovery-check' {$extra.recovery.summary}
    'logs' {'Historico de relatorios carregado.'}
    default {'LOWDRUS Engine pronto. Estado atualizado com seguranca.'}
  }
  $result=[ordered]@{
    installReady=$false
    message=$message
    checks=$checks
    hardwareInventory=$inventory
    extra=$extra
    meta=[ordered]@{mode='windows-manager';action=$Action;destructive=$false;timestamp=(Get-Date).ToString('o');hardwareReport=$reportPath}
  }
  if($reportPath){$result|ConvertTo-Json -Depth 9 | Set-Content -LiteralPath $reportPath -Encoding UTF8}
  if($OutFile){$result|ConvertTo-Json -Depth 9 | Set-Content -LiteralPath $OutFile -Encoding UTF8}
  $result|ConvertTo-Json -Depth 9 -Compress
}catch{
  [ordered]@{installReady=$false;message=('Falha segura: '+$_.Exception.Message);checks=[ordered]@{};meta=[ordered]@{mode='windows-manager';destructive=$false;timestamp=(Get-Date).ToString('o')}}|ConvertTo-Json -Depth 6 -Compress
  exit 1
}
