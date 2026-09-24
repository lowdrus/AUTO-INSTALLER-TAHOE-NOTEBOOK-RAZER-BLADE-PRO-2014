param([string]$Root=(Split-Path -Parent $PSScriptRoot))
$ErrorActionPreference='Stop'
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms

$engine = Join-Path $Root 'engine\windows\Lowdrus.Engine.ps1'
$asset = Join-Path $Root 'gui\assets\lowdrus_razer_plush.mp4'

function Run-Engine([string]$action) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $engine -Action $action |
        Out-String | ConvertFrom-Json
}
function Brush([byte]$r,[byte]$g,[byte]$b,[byte]$a=255) {
    New-Object Windows.Media.SolidColorBrush([Windows.Media.Color]::FromArgb($a,$r,$g,$b))
}
function StateBrush([string]$state) {
    switch($state){'ok'{Brush 80 216 144}'error'{Brush 238 106 106}'warn'{Brush 228 187 85}default{Brush 160 166 176}}
}

$w=New-Object Windows.Window
$w.Title='LOWDRUS INSTALLER'
$w.Width=1100;$w.Height=720;$w.MinWidth=900;$w.MinHeight=620
$w.WindowStartupLocation='CenterScreen'
$w.Background=Brush 0 0 0

$stage=New-Object Windows.Controls.Grid
$w.Content=$stage

# Official LOWDRUS animated background. Always silent.
$media=New-Object Windows.Controls.MediaElement
$media.Stretch='UniformToFill'
$media.LoadedBehavior='Manual'
$media.UnloadedBehavior='Manual'
$media.Volume=0
$media.IsMuted=$true
$media.Opacity=.72
if(Test-Path $asset){$media.Source=New-Object Uri($asset);$media.Add_MediaEnded({$media.Position=[TimeSpan]::Zero;$media.Play()})}
[void]$stage.Children.Add($media)

$shade=New-Object Windows.Controls.Border
$shade.Background=Brush 0 0 0 105
[void]$stage.Children.Add($shade)

$outer=New-Object Windows.Controls.Grid
$outer.Margin='34'
$or1=New-Object Windows.Controls.RowDefinition;$or1.Height=[Windows.GridLength]::Auto
$or2=New-Object Windows.Controls.RowDefinition;$or2.Height=New-Object Windows.GridLength(1,[Windows.GridUnitType]::Star)
$or3=New-Object Windows.Controls.RowDefinition;$or3.Height=[Windows.GridLength]::Auto
[void]$outer.RowDefinitions.Add($or1);[void]$outer.RowDefinitions.Add($or2);[void]$outer.RowDefinitions.Add($or3)
[void]$stage.Children.Add($outer)

$head=New-Object Windows.Controls.StackPanel
$title=New-Object Windows.Controls.TextBlock;$title.Text='LOWDRUS';$title.FontSize=38;$title.FontWeight='Bold';$title.Foreground=Brush 103 232 164
$sub=New-Object Windows.Controls.TextBlock;$sub.Text='INSTALLER & RECOVERY';$sub.FontSize=16;$sub.FontWeight='SemiBold';$sub.Foreground=[Windows.Media.Brushes]::White
$edition=New-Object Windows.Controls.TextBlock;$edition.Text='TAHOE EDITION  |  DESKTOP MANAGER';$edition.Margin='0,5,0,18';$edition.Foreground=Brush 180 186 196
[void]$head.Children.Add($title);[void]$head.Children.Add($sub);[void]$head.Children.Add($edition)
[void]$outer.Children.Add($head)

$card=New-Object Windows.Controls.Border
[Windows.Controls.Grid]::SetRow($card,1)
$card.Background=Brush 16 18 22 235
$card.BorderBrush=Brush 35 206 126
$card.BorderThickness='1'
$card.CornerRadius='18'
$card.Padding='22'
[void]$outer.Children.Add($card)
$body=New-Object Windows.Controls.Grid
$bc1=New-Object Windows.Controls.ColumnDefinition;$bc1.Width=New-Object Windows.GridLength(1.15,[Windows.GridUnitType]::Star)
$bc2=New-Object Windows.Controls.ColumnDefinition;$bc2.Width=New-Object Windows.GridLength(.85,[Windows.GridUnitType]::Star)
[void]$body.ColumnDefinitions.Add($bc1);[void]$body.ColumnDefinitions.Add($bc2)
$card.Child=$body

$left=New-Object Windows.Controls.StackPanel;$left.Margin='0,0,18,0'
$stateTitle=New-Object Windows.Controls.TextBlock;$stateTitle.Text='Estado do sistema';$stateTitle.FontSize=20;$stateTitle.FontWeight='Bold';$stateTitle.Foreground=[Windows.Media.Brushes]::White;$stateTitle.Margin='0,0,0,10'
[void]$left.Children.Add($stateTitle)
$checks=New-Object Windows.Controls.ListBox;$checks.Background=[Windows.Media.Brushes]::Transparent;$checks.BorderThickness='0'
[void]$left.Children.Add($checks)
$status=New-Object Windows.Controls.TextBlock;$status.TextWrapping='Wrap';$status.Foreground=Brush 190 196 205;$status.Margin='0,14,0,0'
[void]$left.Children.Add($status)
[void]$body.Children.Add($left)

$right=New-Object Windows.Controls.StackPanel
[Windows.Controls.Grid]::SetColumn($right,1)
$ready=New-Object Windows.Controls.TextBlock;$ready.Text='LOWDRUS ENGINE';$ready.FontSize=18;$ready.FontWeight='Bold';$ready.Foreground=Brush 103 232 164;$ready.Margin='0,0,0,12'
[void]$right.Children.Add($ready)

function New-Action([string]$text){
 $b=New-Object Windows.Controls.Button;$b.Content=$text;$b.Height=52;$b.Margin='0,0,0,10';$b.FontWeight='SemiBold';return $b
}
$install=New-Action 'INSTALAR TAHOE';$install.IsEnabled=$false
$diag=New-Action 'DIAGNOSTICO E LOGS'
$refresh=New-Action 'ATUALIZAR ESTADO'
$recover=New-Action 'RECUPERACAO';$recover.IsEnabled=$false
$remote=New-Action 'ACESSO REMOTO';$remote.IsEnabled=$false
[void]$right.Children.Add($install);[void]$right.Children.Add($diag);[void]$right.Children.Add($refresh);[void]$right.Children.Add($recover);[void]$right.Children.Add($remote)
[void]$body.Children.Add($right)

$footer=New-Object Windows.Controls.TextBlock
[Windows.Controls.Grid]::SetRow($footer,2)
$footer.Text='LOWDRUS Engine  |  modo seguro / somente leitura  |  console avancado opcional'
$footer.HorizontalAlignment='Center';$footer.Foreground=Brush 145 151 161;$footer.Margin='0,14,0,0'
[void]$outer.Children.Add($footer)

$labels=[ordered]@{hardware='Notebook alvo';lexar='Midia LOWDRUS';efi='OpenCore / EFI';builder='Tahoe Builder';payload='InstallAssistant';storage='Armazenamento interno'}
function Render($result){
 $checks.Items.Clear()
 foreach($k in $labels.Keys){
  $v=$result.checks.$k;if(!$v){continue}
  $tb=New-Object Windows.Controls.TextBlock;$tb.FontSize=15;$tb.Margin='0,8,0,8';$tb.TextWrapping='Wrap'
  $tb.Text='[{0}]  {1}  -  {2}' -f $v.state.ToUpperInvariant(),$labels[$k],$v.text
  $tb.Foreground=StateBrush $v.state
  [void]$checks.Items.Add($tb)
 }
 $status.Text=$result.message
 $install.IsEnabled=[bool]$result.installReady
}
function SafeRun([string]$action){
 try{$status.Text='LOWDRUS Engine trabalhando...';$w.Dispatcher.Invoke([action]{},'Background');Render(Run-Engine $action)}
 catch{$install.IsEnabled=$false;$status.Text='Falha segura: '+$_.Exception.Message}
}
$refresh.Add_Click({SafeRun 'status'})
$diag.Add_Click({SafeRun 'diagnose'})
$install.Add_Click({[Windows.MessageBox]::Show('A instalacao permanece bloqueada ate o ambiente Razer ser validado.','LOWDRUS INSTALLER')|Out-Null})
$w.Add_ContentRendered({
 if(Test-Path $asset){try{$media.Play()}catch{}}
 else{$status.Text='GUI carregada. Asset de animacao nao encontrado em src\gui\assets\lowdrus_razer_plush.mp4.'}
 SafeRun 'status'
})
$w.Add_Closed({try{$media.Stop()}catch{}})
[void]$w.ShowDialog()
