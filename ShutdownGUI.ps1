Add-Type -AssemblyName PresentationFramework

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Shutdown Timer" Height="200" Width="480"
        WindowStartupLocation="CenterScreen" ResizeMode="NoResize"
        Background="#1E1E2E" Foreground="White">
    <Window.Resources>
        <Style TargetType="Button">
            <Setter Property="Background" Value="#313244"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="BorderBrush" Value="#45475A"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="8,4"/>
            <Setter Property="Margin" Value="3,0"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}"
                                CornerRadius="4" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Background" Value="#45475A"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter Property="Background" Value="#585B70"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        <Style x:Key="StartButton" TargetType="Button">
            <Setter Property="Background" Value="#A6E3A1"/>
            <Setter Property="Foreground" Value="#1E1E2E"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Padding" Value="16,6"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}"
                                CornerRadius="4" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Background" Value="#94E2D5"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter Property="Background" Value="#74C7EC"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>
    <Grid Margin="10">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
        </Grid.RowDefinitions>

        <!-- Row 0: Timer buttons and display -->
        <StackPanel Grid.Row="0" Orientation="Horizontal" HorizontalAlignment="Center"
                    VerticalAlignment="Center" Margin="0,10,0,6">
            <Button x:Name="BtnSub15" Content="-15" Width="44"/>
            <Button x:Name="BtnSub5"  Content="-5"  Width="44"/>
            <Button x:Name="BtnSub1"  Content="-1"  Width="44"/>
            <TextBlock x:Name="TimerDisplay" Text="01:00"
                       FontSize="36" FontWeight="Bold" Foreground="#CDD6F4"
                       VerticalAlignment="Center" Margin="14,0"
                       FontFamily="Consolas" MinWidth="110" TextAlignment="Center"/>
            <Button x:Name="BtnAdd1"  Content="+1"  Width="44"/>
            <Button x:Name="BtnAdd5"  Content="+5"  Width="44"/>
            <Button x:Name="BtnAdd15" Content="+15" Width="44"/>
        </StackPanel>

        <!-- Row 1: Effective run time -->
        <TextBlock Grid.Row="1" x:Name="RunsAtLabel"
                   FontSize="13" Foreground="#A6ADC8"
                   HorizontalAlignment="Center" Margin="0,0,0,10"/>

        <!-- Row 2: Dropdown + Start -->
        <StackPanel Grid.Row="2" Orientation="Horizontal" HorizontalAlignment="Center"
                    VerticalAlignment="Center">
            <ComboBox x:Name="ActionCombo" Width="140" FontSize="13"
                      Background="#313244" Foreground="Black"
                      BorderBrush="#45475A" Margin="0,0,10,0"/>
            <Button x:Name="BtnStart" Content="Start" Style="{StaticResource StartButton}"/>
        </StackPanel>
    </Grid>
</Window>
"@

# --- Load XAML ---
$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

# --- Grab controls ---
$timerDisplay = $window.FindName("TimerDisplay")
$runsAtLabel  = $window.FindName("RunsAtLabel")
$actionCombo  = $window.FindName("ActionCombo")
$btnStart     = $window.FindName("BtnStart")

$btnSub15 = $window.FindName("BtnSub15")
$btnSub5  = $window.FindName("BtnSub5")
$btnSub1  = $window.FindName("BtnSub1")
$btnAdd1  = $window.FindName("BtnAdd1")
$btnAdd5  = $window.FindName("BtnAdd5")
$btnAdd15 = $window.FindName("BtnAdd15")

# --- State ---
$script:timerMinutes = 60

# --- Populate combo ---
$actions = @("Shutdown", "Restart", "Hibernate", "Sleep", "Log Off")
foreach ($a in $actions) { $actionCombo.Items.Add($a) | Out-Null }
$actionCombo.SelectedIndex = 0

# --- Helper: update display ---
function Update-Display {
    $ts = [TimeSpan]::FromMinutes($script:timerMinutes)
    if ($ts.TotalHours -ge 1) {
        $timerDisplay.Text = $ts.ToString("hh\:mm\:ss")
    } else {
        $timerDisplay.Text = $ts.ToString("mm\:ss")
    }
    $runTime = (Get-Date).Add($ts)
    $runsAtLabel.Text = "Runs at: $($runTime.ToString('h:mm tt'))"
}

# --- Helper: adjust minutes ---
function Add-Minutes([int]$delta) {
    $newVal = $script:timerMinutes + $delta
    if ($newVal -lt 1) { $newVal = 1 }
    $script:timerMinutes = $newVal
    Update-Display
}

# --- Wire buttons ---
$btnSub15.Add_Click({ Add-Minutes -15 })
$btnSub5.Add_Click({ Add-Minutes -5 })
$btnSub1.Add_Click({ Add-Minutes -1 })
$btnAdd1.Add_Click({ Add-Minutes 1 })
$btnAdd5.Add_Click({ Add-Minutes 5 })
$btnAdd15.Add_Click({ Add-Minutes 15 })

# --- Start button ---
$btnStart.Add_Click({
    $taskName = "ShutdownGUI_ScheduledAction"
    $selectedAction = $actionCombo.SelectedItem.ToString()

    # Map action to command
    switch ($selectedAction) {
        "Shutdown"  { $exe = "shutdown.exe"; $args = "/s /t 0" }
        "Restart"   { $exe = "shutdown.exe"; $args = "/r /t 0" }
        "Hibernate" { $exe = "shutdown.exe"; $args = "/h" }
        "Sleep"     { $exe = "rundll32.exe"; $args = "powrprof.dll,SetSuspendState 0,1,0" }
        "Log Off"   { $exe = "shutdown.exe"; $args = "/l" }
    }

    $triggerTime = (Get-Date).AddMinutes($script:timerMinutes)

    # Remove existing task if present
    try { Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue } catch {}

    # Create the scheduled task
    $action  = New-ScheduledTaskAction -Execute $exe -Argument $args
    $trigger = New-ScheduledTaskTrigger -Once -At $triggerTime
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
                -StartWhenAvailable -DeleteExpiredTaskAfter (New-TimeSpan -Minutes 5)

    try {
        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger `
            -Settings $settings -Description "Scheduled by ShutdownGUI" `
            -RunLevel Highest -Force | Out-Null

        [System.Windows.MessageBox]::Show(
            "$selectedAction scheduled at $($triggerTime.ToString('h:mm:ss tt'))",
            "Scheduled", "OK", "Information") | Out-Null

        $window.Close()
    }
    catch {
        [System.Windows.MessageBox]::Show(
            "Failed to create scheduled task.`n`nError: $_`n`nTry running as Administrator.",
            "Error", "OK", "Error") | Out-Null
    }
})

# --- Initial display ---
Update-Display

# --- Show window ---
$window.ShowDialog() | Out-Null
