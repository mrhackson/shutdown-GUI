# Shutdown GUI

A minimal WPF-based PowerShell GUI to schedule shutdown, restart, hibernate, sleep, or log off after a set delay.

![Windows](https://img.shields.io/badge/platform-Windows-blue)

## Features

- Adjustable timer with ±1, ±5, ±15 minute buttons
- Actions: Shutdown, Restart, Hibernate, Sleep, Log Off
- Creates a Windows Scheduled Task to execute the action
- Dark themed (Catppuccin Mocha)

## Usage

```powershell
.\ShutdownGUI.ps1
```

> Requires **Administrator** privileges to create the scheduled task.

## Requirements

- Windows PowerShell 5.1+
- .NET Framework (WPF)
