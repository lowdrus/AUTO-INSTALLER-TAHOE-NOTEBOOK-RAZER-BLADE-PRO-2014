param(
  [ValidateSet('status','diagnose')][string]$Action='status',
  [string]$OutFile
)
$ErrorActionPreference='Stop'

$EXPECTED_TAR_SIZE=18437734400
$EXPECTED_TAR_SHA='7EA862E4FB009E5E7AEBCA7F9A43B0AA8471149084841CBEF95F19BEA8EE53B4'
$EXPECTED_PKG_SIZE=18381960622
$EXPECTED_PKG_SHA='23261873087FCCA0432E6CCC293C858ED9CE5D22C528FFF801BB1653786FA9AE'

function C([string]$state,[string]$text) {
  [ordered]@{state=$state;text=$text}
}

function Find-LowdrusVolume {
  $candidates=Get-CimInstance Win32_LogicalDisk | Where-Object {
    $_.DriveType -in 2,3 -and $_.DeviceID -match '^[A-Z]:$'
  }
  foreach($d in $candidates) {
    $root=$d.DeviceID+'\'
    try {
      if(-not (Test-Path -LiteralPath $root -ErrorAction Stop)){continue}
      $isLabel=$d.VolumeName -eq 'LOWDRUS'
      $hasTransport=Test-Path -LiteralPath ($root+'LOWDRUS-TRANSPORT') -ErrorAction SilentlyContinue
      $hasPkg=Test-Path -LiteralPath ($root+'InstallAssistant.pkg') -ErrorAction SilentlyContinue
      if($isLabel -or $hasTransport -or $hasPkg) {
        return [pscustomobject]@{Root=$root;Label=$d.VolumeName;Size=$d.Size;DriveType=$d.DriveType}
      }
    } catch { continue }
  }
  return $null
}

function Find-FileDeep([string]$root,[string]$name) {
  $direct=Join-Path $root $name
  if(Test-Path -LiteralPath $direct){return Get-Item -LiteralPath $direct}
  Get-ChildItem -LiteralPath $root -Filter $name -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
}

try {
  $checks=[ordered]@{}
  $vol=Find-LowdrusVolume
  $tar=$null
  $pkg=$null

  if(!$vol) {
    $checks.lexar=C error 'Lexar LOWDRUS nao encontrada'
    $checks.efi=C pending 'Aguardando Lexar'
    $checks.builder=C pending 'Aguardando Lexar'
    $checks.payload=C pending 'Aguardando Lexar'
  } else {
    $checks.lexar=C ok ('Detectada em '+$vol.Root.TrimEnd('\'))
    $tar=Find-FileDeep $vol.Root 'Tahoe-Builder.tar'
    if($tar -and $tar.Length -eq $EXPECTED_TAR_SIZE){$checks.builder=C ok 'Tahoe Builder encontrado (tamanho validado)'}
    elseif($tar){$checks.builder=C error 'Tahoe Builder com tamanho inesperado'}
    else{$checks.builder=C error 'Tahoe Builder nao encontrado'}

    $pkg=Find-FileDeep $vol.Root 'InstallAssistant.pkg'
    if($pkg -and $pkg.Length -eq $EXPECTED_PKG_SIZE){$checks.payload=C ok 'InstallAssistant encontrado (tamanho validado)'}
    elseif($pkg){$checks.payload=C error 'InstallAssistant com tamanho inesperado'}
    else{$checks.payload=C warn 'InstallAssistant nao localizado nesta particao'}

    $checks.efi=C warn 'EFI fisica requer inspecao privilegiada segura'
  }

  $checks.hardware=C warn 'Perfil Razer sera validado no notebook'
  $samsung=Get-CimInstance Win32_DiskDrive | Where-Object {$_.Model -match 'Samsung'} | Select-Object -First 1
  $checks.samsung=if($samsung){C warn 'Samsung visivel no Desktop - nao e alvo aqui'}else{C warn 'Samsung interno sera identificado no Razer'}

  if($Action -eq 'diagnose' -and $vol) {
    if($tar -and $tar.Length -eq $EXPECTED_TAR_SIZE) {
      $h=(Get-FileHash -LiteralPath $tar.FullName -Algorithm SHA256).Hash
      $checks.builder=if($h -eq $EXPECTED_TAR_SHA){C ok 'Tahoe Builder SHA-256 aprovado'}else{C error 'Tahoe Builder SHA-256 invalido'}
    }
    if($pkg -and $pkg.Length -eq $EXPECTED_PKG_SIZE) {
      $h=(Get-FileHash -LiteralPath $pkg.FullName -Algorithm SHA256).Hash
      $checks.payload=if($h -eq $EXPECTED_PKG_SHA){C ok 'InstallAssistant SHA-256 aprovado'}else{C error 'InstallAssistant SHA-256 invalido'}
    }
  }

  $result=[ordered]@{
    installReady=$false
    message='Desktop Manager: diagnostico seguro concluido. Instalacao permanece bloqueada ate validacao no Razer.'
    checks=$checks
    meta=[ordered]@{mode='windows-manager';destructive=$false;timestamp=(Get-Date).ToString('o')}
  }
  $json=$result|ConvertTo-Json -Depth 6 -Compress
  if($OutFile){$json|Set-Content -LiteralPath $OutFile -Encoding UTF8}
  Write-Output $json
} catch {
  $result=[ordered]@{
    installReady=$false
    message=('Falha segura: '+$_.Exception.Message)
    checks=[ordered]@{}
    meta=[ordered]@{mode='windows-manager';destructive=$false;timestamp=(Get-Date).ToString('o')}
  }
  Write-Output ($result|ConvertTo-Json -Depth 6 -Compress)
  exit 1
}
