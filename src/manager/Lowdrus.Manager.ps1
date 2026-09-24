param([string]$Root=(Split-Path -Parent $PSScriptRoot))
$ErrorActionPreference='Stop'

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

$engine = Join-Path $Root 'engine\windows\Lowdrus.Engine.ps1'

function Run-Engine([string]$action) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $engine -Action $action |
        Out-String |
        ConvertFrom-Json
}

function StateBrush([string]$state) {
    switch ($state) {
        'ok'    { [Windows.Media.Brushes]::LightGreen }
        'error' { [Windows.Media.Brushes]::Tomato }
        'warn'  { [Windows.Media.Brushes]::Khaki }
        default { [Windows.Media.Brushes]::LightGray }
    }
}

# Build WPF directly in PowerShell. No XAML parser dependency.
$w = New-Object Windows.Window
$w.Title = 'LOWDRUS INSTALLER'
$w.Width = 900
$w.Height = 650
$w.MinWidth = 760
$w.MinHeight = 560
$w.WindowStartupLocation = 'CenterScreen'
$w.Background = [Windows.Media.Brushes]::Black

$rootGrid = New-Object Windows.Controls.Grid
$rootGrid.Margin = '34'
$r1 = New-Object Windows.Controls.RowDefinition
$r1.Height = [Windows.GridLength]::Auto
$r2 = New-Object Windows.Controls.RowDefinition
$r2.Height = New-Object Windows.GridLength(1,[Windows.GridUnitType]::Star)
$r3 = New-Object Windows.Controls.RowDefinition
$r3.Height = [Windows.GridLength]::Auto
[void]$rootGrid.RowDefinitions.Add($r1)
[void]$rootGrid.RowDefinitions.Add($r2)
[void]$rootGrid.RowDefinitions.Add($r3)

$header = New-Object Windows.Controls.StackPanel
$title = New-Object Windows.Controls.TextBlock
$title.Text = 'LOWDRUS INSTALLER'
$title.FontSize = 30
$title.FontWeight = 'Bold'
$title.Foreground = [Windows.Media.Brushes]::White
$subtitle = New-Object Windows.Controls.TextBlock
$subtitle.Text = 'Desktop Manager - Razer Blade Pro - macOS Tahoe'
$subtitle.Foreground = [Windows.Media.Brushes]::LightGray
$subtitle.Margin = '0,5,0,22'
[void]$header.Children.Add($title)
[void]$header.Children.Add($subtitle)
[void]$rootGrid.Children.Add($header)

$panelBorder = New-Object Windows.Controls.Border
[Windows.Controls.Grid]::SetRow($panelBorder,1)
$panelBorder.Background = New-Object Windows.Media.SolidColorBrush([Windows.Media.Color]::FromRgb(21,24,33))
$panelBorder.CornerRadius = '20'
$panelBorder.Padding = '24'

$panel = New-Object Windows.Controls.StackPanel
$section = New-Object Windows.Controls.TextBlock
$section.Text = 'Estado do sistema'
$section.FontSize = 18
$section.FontWeight = 'SemiBold'
$section.Foreground = [Windows.Media.Brushes]::White
$section.Margin = '0,0,0,12'
[void]$panel.Children.Add($section)

$checks = New-Object Windows.Controls.ListBox
$checks.Background = [Windows.Media.Brushes]::Transparent
$checks.BorderThickness = '0'
$checks.Foreground = [Windows.Media.Brushes]::White
[void]$panel.Children.Add($checks)

$status = New-Object Windows.Controls.TextBlock
$status.Text = 'Inicializando LOWDRUS Engine...'
$status.TextWrapping = 'Wrap'
$status.Foreground = [Windows.Media.Brushes]::LightGray
$status.Margin = '0,18,0,14'
[void]$panel.Children.Add($status)

$buttons = New-Object Windows.Controls.Grid
$c1 = New-Object Windows.Controls.ColumnDefinition
$c2 = New-Object Windows.Controls.ColumnDefinition
[void]$buttons.ColumnDefinitions.Add($c1)
[void]$buttons.ColumnDefinitions.Add($c2)

$diag = New-Object Windows.Controls.Button
$diag.Content = 'DIAGNOSTICO COMPLETO'
$diag.Height = 46
$diag.Margin = '0,0,6,0'
[void]$buttons.Children.Add($diag)

$refresh = New-Object Windows.Controls.Button
$refresh.Content = 'ATUALIZAR ESTADO'
$refresh.Height = 46
$refresh.Margin = '6,0,0,0'
[Windows.Controls.Grid]::SetColumn($refresh,1)
[void]$buttons.Children.Add($refresh)
[void]$panel.Children.Add($buttons)

$install = New-Object Windows.Controls.Button
$install.Content = 'INSTALAR macOS TAHOE'
$install.Height = 52
$install.Margin = '0,12,0,0'
$install.FontWeight = 'Bold'
$install.IsEnabled = $false
[void]$panel.Children.Add($install)

$panelBorder.Child = $panel
[void]$rootGrid.Children.Add($panelBorder)

$footer = New-Object Windows.Controls.TextBlock
$footer.Text = 'LOWDRUS Engine - modo seguro / somente leitura'
$footer.Foreground = [Windows.Media.Brushes]::Gray
$footer.HorizontalAlignment = 'Center'
$footer.Margin = '0,18,0,0'
[Windows.Controls.Grid]::SetRow($footer,2)
[void]$rootGrid.Children.Add($footer)

$w.Content = $rootGrid

$labels = [ordered]@{
    hardware = 'Hardware Razer'
    lexar    = 'Lexar LOWDRUS'
    efi      = 'OpenCore / EFI'
    builder  = 'Tahoe Builder'
    payload  = 'InstallAssistant'
    samsung  = 'Samsung SSD'
}

function Render($result) {
    $checks.Items.Clear()
    foreach ($k in $labels.Keys) {
        $v = $result.checks.$k
        if (-not $v) { continue }
        $tb = New-Object Windows.Controls.TextBlock
        $tb.FontSize = 15
        $tb.Margin = '0,7,0,7'
        $tb.Text = '[{0}] {1} - {2}' -f $v.state.ToUpperInvariant(), $labels[$k], $v.text
        $tb.Foreground = StateBrush $v.state
        [void]$checks.Items.Add($tb)
    }
    $status.Text = $result.message
    $install.IsEnabled = [bool]$result.installReady
}

function SafeRun([string]$action) {
    try {
        $status.Text = 'LOWDRUS Engine trabalhando...'
        $w.Dispatcher.Invoke([action]{}, 'Background')
        Render (Run-Engine $action)
    }
    catch {
        $install.IsEnabled = $false
        $status.Text = 'Falha segura: ' + $_.Exception.Message
    }
}

$refresh.Add_Click({ SafeRun 'status' })
$diag.Add_Click({ SafeRun 'diagnose' })
$install.Add_Click({
    [Windows.MessageBox]::Show(
        'A instalacao permanece bloqueada ate o ambiente Razer ser validado.',
        'LOWDRUS INSTALLER'
    ) | Out-Null
})
$w.Add_ContentRendered({ SafeRun 'status' })
[void]$w.ShowDialog()
