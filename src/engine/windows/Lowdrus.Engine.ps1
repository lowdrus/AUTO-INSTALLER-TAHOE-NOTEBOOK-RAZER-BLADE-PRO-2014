param([ValidateSet('status','diagnose')][string]$Action='status',[string]$OutFile)
$ErrorActionPreference='Stop'
$EXPECTED_TAR_SIZE=18437734400
$EXPECTED_TAR_SHA='7EA862E4FB009E5E7AEBCA7F9A43B0AA8471149084841CBEF95F19BEA8EE53B4'
$EXPECTED_PKG_SIZE=18381960622
$EXPECTED_PKG_SHA='23261873087FCCA0432E6CCC293C858ED9CE5D22C528FFF801BB1653786FA9AE'
function C($state,$text){[ordered]@{state=$state;text=$text}}
function Find-LowdrusVolume {
  Get-CimInstance Win32_LogicalDisk -Filter "DriveType=2" | ForEach-Object {
    $root="$($_.DeviceID)\"
    if((Test-Path "$root\LOWDRUS-TRANSPORT") -or (Test-Path "$root\InstallAssistant.pkg")){[pscustomobject]@{Root=$root;Label=$_.VolumeName;Size=$_.Size}}
  } | Select-Object -First 1
}
function Find-FileDeep([string]$root,[string]$name){
  $direct=Join-Path $root $name;if(Test-Path $direct){return Get-Item $direct}
  Get-ChildItem $root -Filter $name -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
}
try{
  $checks=[ordered]@{}
  $vol=Find-LowdrusVolume
  if(!$vol){$checks.lexar=C error 'Lexar LOWDRUS não encontrada';$checks.efi=C pending 'Aguardando Lexar';$checks.builder=C pending 'Aguardando Lexar';$checks.payload=C pending 'Aguardando Lexar'}
  else{
    $checks.lexar=C ok ("Detectada em "+$vol.Root.TrimEnd('\'))
    $tar=Find-FileDeep $vol.Root 'Tahoe-Builder.tar'
    if($tar -and $tar.Length -eq $EXPECTED_TAR_SIZE){$checks.builder=C ok 'Tahoe Builder encontrado (tamanho validado)'}elseif($tar){$checks.builder=C error 'Tahoe Builder com tamanho inesperado'}else{$checks.builder=C error 'Tahoe Builder não encontrado'}
    $pkg=Find-FileDeep $vol.Root 'InstallAssistant.pkg'
    if($pkg -and $pkg.Length -eq $EXPECTED_PKG_SIZE){$checks.payload=C ok 'InstallAssistant encontrado (tamanho validado)'}elseif($pkg){$checks.payload=C error 'InstallAssistant com tamanho inesperado'}else{$checks.payload=C warn 'InstallAssistant não localizado nesta partição'}
    $checks.efi=C warn 'EFI física requer inspeção privilegiada segura'
  }
  $checks.hardware=C warn 'Perfil Razer será validado no notebook'
  $samsung=Get-CimInstance Win32_DiskDrive | Where-Object {$_.Model -match 'Samsung'} | Select-Object -First 1
  $checks.samsung=if($samsung){C warn 'Samsung visível no Desktop — não é alvo aqui'}else{C warn 'Samsung interno será identificado no Razer'}
  if($Action -eq 'diagnose' -and $vol){
    if($tar -and $tar.Length -eq $EXPECTED_TAR_SIZE){$h=(Get-FileHash $tar.FullName -Algorithm SHA256).Hash;$checks.builder=if($h -eq $EXPECTED_TAR_SHA){C ok 'Tahoe Builder SHA-256 aprovado'}else{C error 'Tahoe Builder SHA-256 inválido'}}
    if($pkg -and $pkg.Length -eq $EXPECTED_PKG_SIZE){$h=(Get-FileHash $pkg.FullName -Algorithm SHA256).Hash;$checks.payload=if($h -eq $EXPECTED_PKG_SHA){C ok 'InstallAssistant SHA-256 aprovado'}else{C error 'InstallAssistant SHA-256 inválido'}}
  }
  $result=[ordered]@{installReady=$false;message='Desktop Manager: diagnóstico seguro concluído. Instalação permanece bloqueada até validação no Razer.';checks=$checks;meta=[ordered]@{mode='windows-manager';destructive=$false;timestamp=(Get-Date).ToString('o')}}
  $json=$result|ConvertTo-Json -Depth 6
  if($OutFile){$json|Set-Content -LiteralPath $OutFile -Encoding UTF8}
  $json
}catch{
  $result=[ordered]@{installReady=$false;message=('Falha segura: '+$_.Exception.Message);checks=[ordered]@{};meta=[ordered]@{mode='windows-manager';destructive=$false;timestamp=(Get-Date).ToString('o')}}
  $result|ConvertTo-Json -Depth 6
  exit 1
}