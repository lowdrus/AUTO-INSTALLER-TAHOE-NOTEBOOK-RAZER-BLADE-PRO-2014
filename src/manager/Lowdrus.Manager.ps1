param([string]$Root=(Split-Path -Parent $PSScriptRoot))
$ErrorActionPreference='Stop'
Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase,System.Windows.Forms

$engine=Join-Path $Root 'engine\windows\Lowdrus.Engine.ps1'
$repoRoot=Split-Path -Parent $Root
$asset=Join-Path $repoRoot 'lowdrus_gui\assets\lowdrus_razer_plush.mp4'
$poster=Join-Path $repoRoot 'lowdrus_gui\assets\preview.jpg'

function Run-Engine([string]$action){& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $engine -Action $action | Out-String | ConvertFrom-Json}
function Brush([byte]$r,[byte]$g,[byte]$b,[byte]$a=255){New-Object Windows.Media.SolidColorBrush([Windows.Media.Color]::FromArgb($a,$r,$g,$b))}
function StateBrush([string]$s){switch($s){'ok'{Brush 80 216 144}'error'{Brush 238 106 106}'warn'{Brush 228 187 85}default{Brush 160 166 176}}}
function Btn([string]$text){
 $b=New-Object Windows.Controls.Button;$b.Content=$text;$b.Height=48;$b.Margin='0,0,0,9';$b.FontWeight='SemiBold'
 $b.Background=Brush 27 30 36 235;$b.Foreground=[Windows.Media.Brushes]::White;$b.BorderBrush=Brush 74 84 96;$b.BorderThickness='1';$b
}

$w=New-Object Windows.Window
$w.Title='LOWDRUS INSTALLER';$w.Width=1160;$w.Height=760;$w.MinWidth=960;$w.MinHeight=650
$w.WindowStartupLocation='CenterScreen';$w.Background=Brush 0 0 0

$stage=New-Object Windows.Controls.Grid;$w.Content=$stage
$media=New-Object Windows.Controls.MediaElement
$media.Stretch='UniformToFill';$media.LoadedBehavior='Manual';$media.UnloadedBehavior='Manual';$media.Volume=0;$media.IsMuted=$true;$media.Opacity=.68
if(Test-Path $asset){$media.Source=New-Object Uri($asset);$media.Add_MediaEnded({$media.Position=[TimeSpan]::Zero;$media.Play()})}
[void]$stage.Children.Add($media)
$shade=New-Object Windows.Controls.Border;$shade.Background=Brush 0 0 0 120;[void]$stage.Children.Add($shade)

$outer=New-Object Windows.Controls.Grid;$outer.Margin='34'
$r1=New-Object Windows.Controls.RowDefinition;$r1.Height=[Windows.GridLength]::Auto
$r2=New-Object Windows.Controls.RowDefinition;$r2.Height=New-Object Windows.GridLength(1,[Windows.GridUnitType]::Star)
$r3=New-Object Windows.Controls.RowDefinition;$r3.Height=[Windows.GridLength]::Auto
[void]$outer.RowDefinitions.Add($r1);[void]$outer.RowDefinitions.Add($r2);[void]$outer.RowDefinitions.Add($r3);[void]$stage.Children.Add($outer)

$head=New-Object Windows.Controls.StackPanel
$title=New-Object Windows.Controls.TextBlock;$title.Text='LOWDRUS';$title.FontSize=40;$title.FontWeight='Bold';$title.Foreground=Brush 103 232 164
$sub=New-Object Windows.Controls.TextBlock;$sub.Text='INSTALLER & RECOVERY';$sub.FontSize=16;$sub.FontWeight='SemiBold';$sub.Foreground=[Windows.Media.Brushes]::White
$edition=New-Object Windows.Controls.TextBlock;$edition.Text='TAHOE EDITION  |  RAZER BLADE PRO 2014';$edition.Margin='0,5,0,18';$edition.Foreground=Brush 180 186 196
[void]$head.Children.Add($title);[void]$head.Children.Add($sub);[void]$head.Children.Add($edition);[void]$outer.Children.Add($head)

$card=New-Object Windows.Controls.Border;[Windows.Controls.Grid]::SetRow($card,1)
$card.Background=Brush 12 14 18 238;$card.BorderBrush=Brush 35 206 126;$card.BorderThickness='1';$card.CornerRadius='18';$card.Padding='22';[void]$outer.Children.Add($card)
$body=New-Object Windows.Controls.Grid
$c1=New-Object Windows.Controls.ColumnDefinition;$c1.Width=New-Object Windows.GridLength(1.2,[Windows.GridUnitType]::Star)
$c2=New-Object Windows.Controls.ColumnDefinition;$c2.Width=New-Object Windows.GridLength(.8,[Windows.GridUnitType]::Star)
[void]$body.ColumnDefinitions.Add($c1);[void]$body.ColumnDefinitions.Add($c2);$card.Child=$body

$left=New-Object Windows.Controls.StackPanel;$left.Margin='0,0,22,0'
$stateTitle=New-Object Windows.Controls.TextBlock;$stateTitle.Text='Estado do sistema';$stateTitle.FontSize=20;$stateTitle.FontWeight='Bold';$stateTitle.Foreground=[Windows.Media.Brushes]::White;$stateTitle.Margin='0,0,0,8';[void]$left.Children.Add($stateTitle)
$checks=New-Object Windows.Controls.ListBox;$checks.Background=[Windows.Media.Brushes]::Transparent;$checks.BorderThickness='0';[void]$left.Children.Add($checks)
$status=New-Object Windows.Controls.TextBlock;$status.TextWrapping='Wrap';$status.Foreground=Brush 195 201 210;$status.Margin='0,14,0,0';[void]$left.Children.Add($status);[void]$body.Children.Add($left)

$right=New-Object Windows.Controls.StackPanel;[Windows.Controls.Grid]::SetColumn($right,1)
$ready=New-Object Windows.Controls.TextBlock;$ready.Text='LOWDRUS ENGINE';$ready.FontSize=18;$ready.FontWeight='Bold';$ready.Foreground=Brush 103 232 164;$ready.Margin='0,0,0,12';[void]$right.Children.Add($ready)
$install=Btn 'INSTALAR macOS TAHOE';$install.IsEnabled=$false
$diag=Btn 'DIAGNOSTICO COMPLETO'
$repair=Btn 'REPARAR / PRE-FLIGHT'
$recover=Btn 'RECUPERACAO / PRE-FLIGHT'
$logs=Btn 'LOGS E RELATORIOS'
$refresh=Btn 'ATUALIZAR ESTADO'
$export=Btn 'EXPORTAR RELATORIO'
foreach($b in @($install,$diag,$repair,$recover,$logs,$refresh,$export)){[void]$right.Children.Add($b)}
[void]$body.Children.Add($right)

$footer=New-Object Windows.Controls.TextBlock;[Windows.Controls.Grid]::SetRow($footer,2)
$footer.Text='LOWDRUS Engine  •  GUI oficial  •  operacoes destrutivas bloqueadas ate validacao final'
$footer.HorizontalAlignment='Center';$footer.Foreground=Brush 145 151 161;$footer.Margin='0,14,0,0';[void]$outer.Children.Add($footer)

$labels=[ordered]@{hardware='Notebook alvo';lexar='Midia LOWDRUS';efi='OpenCore / EFI';builder='Tahoe Builder';payload='InstallAssistant';storage='Armazenamento interno'}
function Render($result){
 $checks.Items.Clear()
 foreach($k in $labels.Keys){
  $v=$result.checks.$k;if(!$v){continue}
  $tb=New-Object Windows.Controls.TextBlock;$tb.FontSize=14;$tb.Margin='0,7,0,7';$tb.TextWrapping='Wrap'
  $tb.Text='[{0}]  {1}  —  {2}' -f $v.state.ToUpperInvariant(),$labels[$k],$v.text;$tb.Foreground=StateBrush $v.state;[void]$checks.Items.Add($tb)
 }
 $status.Text=$result.message
 $install.IsEnabled=[bool]$result.installReady
}
function SafeRun([string]$action){
 try{$status.Text='LOWDRUS Engine trabalhando...';$w.Dispatcher.Invoke([action]{},'Background');$r=Run-Engine $action;Render $r;return $r}
 catch{$install.IsEnabled=$false;$status.Text='Falha segura: '+$_.Exception.Message;return $null}
}
$refresh.Add_Click({[void](SafeRun 'status')})
$diag.Add_Click({[void](SafeRun 'diagnose')})
$repair.Add_Click({[void](SafeRun 'repair-check')})
$recover.Add_Click({[void](SafeRun 'recovery-check')})
$export.Add_Click({$r=SafeRun 'export-report';if($r -and $r.meta.hardwareReport){[Windows.MessageBox]::Show('Relatorio salvo em:'+([Environment]::NewLine)+$r.meta.hardwareReport,'LOWDRUS INSTALLER')|Out-Null}})
$logs.Add_Click({
 $r=SafeRun 'logs'
 if($r){
   $dir=Join-Path $repoRoot 'reports\windows'
   if(Test-Path $dir){Start-Process explorer.exe $dir}else{[Windows.MessageBox]::Show('Ainda nao existem relatorios.','LOWDRUS INSTALLER')|Out-Null}
 }
})
$install.Add_Click({[Windows.MessageBox]::Show('Instalacao destrutiva permanece bloqueada ate o perfil final do Razer ser validado. O LOWDRUS nao substituira a EFI conhecida como funcional automaticamente.','LOWDRUS INSTALLER — PROTECAO')|Out-Null})
$w.Add_ContentRendered({
 if(Test-Path $asset){try{$media.Play()}catch{$status.Text='Video oficial indisponivel; GUI continua operacional.'}}
 elseif(Test-Path $poster){$status.Text='Poster oficial encontrado; video nao localizado. GUI continua operacional.'}
 else{$status.Text='Assets visuais nao encontrados; LOWDRUS Engine continua operacional.'}
 [void](SafeRun 'status')
})
$w.Add_Closed({try{$media.Stop()}catch{}})
[void]$w.ShowDialog()
