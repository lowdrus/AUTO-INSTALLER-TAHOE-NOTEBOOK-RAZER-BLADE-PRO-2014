param([string]$Root=(Split-Path -Parent $PSScriptRoot))
$ErrorActionPreference='Stop'

# Windows PowerShell 5.1 needs the WPF assemblies loaded explicitly before XamlReader.
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Xaml
Add-Type -AssemblyName System.Windows.Forms

$engine = Join-Path $Root 'engine\windows\Lowdrus.Engine.ps1'

function Run-Engine([string]$action) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $engine -Action $action |
        Out-String |
        ConvertFrom-Json
}

function StateBrush([string]$state) {
    switch ($state) {
        'ok'    { '#35D07F' }
        'error' { '#FF6262' }
        'warn'  { '#E7B84B' }
        default { '#8B93A1' }
    }
}

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="LOWDRUS INSTALLER"
        Width="900"
        Height="650"
        MinWidth="760"
        MinHeight="560"
        WindowStartupLocation="CenterScreen"
        Background="#090B10"
        Foreground="White">
  <Grid Margin="34">
    <Grid.RowDefinitions>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="*"/>
      <RowDefinition Height="Auto"/>
    </Grid.RowDefinitions>

    <StackPanel>
      <TextBlock Text="LOWDRUS INSTALLER" FontSize="30" FontWeight="Bold"/>
      <TextBlock Text="Desktop Manager - Razer Blade Pro - macOS Tahoe"
                 Opacity=".65"
                 Margin="0,5,0,22"/>
    </StackPanel>

    <Border Grid.Row="1"
            Background="#151821"
            CornerRadius="20"
            Padding="24">
      <StackPanel>
        <TextBlock Text="Estado do sistema"
                   FontSize="18"
                   FontWeight="SemiBold"
                   Margin="0,0,0,12"/>

        <ListBox Name="Checks"
                 Background="Transparent"
                 BorderThickness="0"
                 Foreground="White"/>

        <TextBlock Name="Status"
                   TextWrapping="Wrap"
                   Opacity=".72"
                   Margin="0,18,0,14"/>

        <Grid>
          <Grid.ColumnDefinitions>
            <ColumnDefinition/>
            <ColumnDefinition/>
          </Grid.ColumnDefinitions>

          <Button Name="Diagnose"
                  Content="DIAGNOSTICO COMPLETO"
                  Height="46"
                  Margin="0,0,6,0"/>

          <Button Name="Refresh"
                  Grid.Column="1"
                  Content="ATUALIZAR ESTADO"
                  Height="46"
                  Margin="6,0,0,0"/>
        </Grid>

        <Button Name="Install"
                Content="INSTALAR macOS TAHOE"
                Height="52"
                Margin="0,12,0,0"
                IsEnabled="False"
                FontWeight="Bold"/>
      </StackPanel>
    </Border>

    <TextBlock Grid.Row="2"
               Text="LOWDRUS Engine - modo seguro / somente leitura"
               HorizontalAlignment="Center"
               Opacity=".45"
               Margin="0,18,0,0"/>
  </Grid>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$w = [Windows.Markup.XamlReader]::Load($reader)

$checks  = $w.FindName('Checks')
$status  = $w.FindName('Status')
$diag    = $w.FindName('Diagnose')
$refresh = $w.FindName('Refresh')
$install = $w.FindName('Install')

$labels = [ordered]@{
    hardware = 'Hardware Razer'
    lexar    = 'Lexar LOWDRUS'
    efi      = 'OpenCore / EFI'
    builder  = 'Tahoe Builder'
    payload  = 'InstallAssistant'
    samsung  = 'Samsung SSD'
}

function Render($r) {
    $checks.Items.Clear()

    foreach ($k in $labels.Keys) {
        $v = $r.checks.$k
        if (-not $v) { continue }

        $tb = New-Object Windows.Controls.TextBlock
        $tb.FontSize = 15
        $tb.Margin = '0,7,0,7'
        $tb.Text = "[{0}] {1} - {2}" -f $v.state.ToUpperInvariant(), $labels[$k], $v.text
        $tb.Foreground = StateBrush $v.state

        [void]$checks.Items.Add($tb)
    }

    $status.Text = $r.message
    $install.IsEnabled = [bool]$r.installReady
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
    [System.Windows.MessageBox]::Show(
        'A instalacao permanece bloqueada ate o ambiente Razer ser validado.',
        'LOWDRUS INSTALLER'
    ) | Out-Null
})

$w.Add_ContentRendered({ SafeRun 'status' })
$w.ShowDialog() | Out-Null
