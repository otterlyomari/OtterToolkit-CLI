# OtterToolkit-CLI

A modular PowerShell 7 terminal interface for Windows maintenance, diagnostics, application management, and system customization.

---

## Overview

OtterToolkit-CLI is a PowerShell-based terminal user interface designed to provide a centralized, safe, and extensible toolkit for Windows administration tasks.

Instead of maintaining dozens of disconnected scripts, OtterToolkit organizes common maintenance workflows into modules with a consistent CLI experience.

The project focuses on:

- Transparency over automation
- Safe system modification
- Modular architecture
- Native Windows tooling
- User-controlled actions

OtterToolkit is inspired by the philosophy of tools like Ghost Toolbox: a lightweight, menu-driven utility that gives users powerful system controls without hiding what is happening behind the scenes.

---

## Features

Current functionality includes:

### Diagnostics

System information and troubleshooting tools.

Includes:

- Operating system information
- CPU and memory information
- Hardware health checks
- Disk information
- BIOS and motherboard information
- Event log analysis
- Network connectivity testing
- VPN detection
- Windows health checks
  - DISM
  - System File Checker
- Diagnostic report generation

---

### Application Management

Provider-based application management.

Supported providers currently include:

- Winget
- Chocolatey
- Scoop
- Microsoft Store (AppX/MSIX support in development)

Features:

- Search applications across providers
- View available package managers
- Install applications
- View installed applications
- Provider abstraction system

The goal is to allow additional package managers to be added without modifying the core application system.

---

### Windows Tweaks

JSON-driven Windows customization system.

Features:

- External tweak definitions
- Registry-based modifications
- Safe action execution
- PowerShell confirmation support

Example tweak workflow:

```
Load tweak definition
        ↓
Display available tweak
        ↓
User selects action
        ↓
Apply requested change
```

Future versions will expand this into a larger tweak database.

---

## Architecture

OtterToolkit uses a modular PowerShell architecture.

```
OtterToolkit-CLI
│
├── Modules
│   │
│   ├── Core
│   │   ├── Application.Core.psm1
│   │   ├── Diagnostics.Core.psm1
│   │   ├── Tweaks.Core.psm1
│   │   ├── Logging.Core.psm1
│   │   └── Components.Core.psm1
│   │
│   ├── UI
│   │   ├── Applications.UI.psm1
│   │   ├── Diagnostics.UI.psm1
│   │   ├── Tweaks.UI.psm1
│   │   └── OtterToolkit.UI.psm1
│   │
│   └── Providers
│       ├── Winget.Provider.psm1
│       ├── Scoop.Provider.psm1
│       ├── Chocolatey.Provider.psm1
│       └── MicrosoftStore.Provider.psm1
│
├── Data
│   ├── Applications.json
│
├── Logs
│
└── OtterToolkit.ps1
```

---

## Requirements

- Windows 10 or Windows 11
- PowerShell 7 or later
- Administrator privileges recommended

Optional dependencies:

- Winget
- Chocolatey
- Scoop

---

## Installation

Clone the repository:

```powershell
git clone https://github.com/<username>/OtterToolkit-CLI.git
```

Enter the directory:

```powershell
cd OtterToolkit-CLI
```

Launch:

```powershell
.\OtterToolkit.ps1
```

---

## Usage

After launching OtterToolkit:

```
=================================
          OtterToolkit
=================================

Main Menu

> Windows Tweaks
  Applications
  Windows Components
  Diagnostics
  Settings

---------------------------------
↑ ↓ Navigate   ENTER Select
Q Quit / ESC Back
```

Each module provides its own interactive menu while sharing the same UI framework.

---

## Safety Philosophy

OtterToolkit is designed around the principle:

> A system tool should explain what it does before it does it.

The project avoids:

- Hidden modifications
- Forced changes
- Aggressive cleanup behavior
- Unclear automation

Where possible, actions support:

- Previewing changes
- Confirmation prompts
- Native Windows tools
- Logging

---

## Settings

The Settings module is planned as the central location for user preferences.

Planned options:

- CLI accent color customization
- UI preferences
- Logging preferences
- Default behaviors
- Diagnostic preferences

Accent colors will only affect interface elements and will not replace warning, error, or status color coding.

---

## Current Status

**Version:** 0.1.0-beta

OtterToolkit is currently in active development.

The core architecture is being stabilized before expanding functionality.

---

## Planned Improvements

Future development includes:

### UI Improvements

- More polished terminal interface
- Better navigation
- Accent color customization
- Improved tables and formatting
- Progress indicators

---

### Diagnostics

- SMART drive health checks
- More hardware sensors
- Expanded event analysis
- Network troubleshooting tools
- Exportable JSON reports

---

### Applications

- Additional package providers
- Application categories
- Batch installation profiles
- Import/export application lists

---

### Tweaks

- Larger tweak database
- Backup and rollback support
- Before/after snapshots
- More action types:
  - Services
  - Scheduled tasks
  - Power settings
  - Group Policy changes

---

## Versioning

OtterToolkit follows Semantic Versioning:

```
MAJOR.MINOR.PATCH
```

Current development stage:

```
0.1.0-beta
```

Meaning:

- `0` - Initial development phase
- `1` - First feature milestone
- `0` - Initial beta release

Breaking architectural changes may occur before version 1.0.

---

## Contributing

Contributions, suggestions, and testing feedback are welcome.

Before submitting changes:

- Keep modules focused
- Avoid unnecessary dependencies
- Preserve the safety-first philosophy
- Test changes on a clean Windows installation when possible

---

## License

License information will be added before the first stable release.

---

## Credits

Created by **Omari A. Tidemere**

Built with:

- PowerShell 7
- Native Windows management APIs
- Community package managers

---

## Disclaimer

OtterToolkit modifies Windows settings and system behavior.

Always review what a tweak or maintenance action does before applying it.

The developer is not responsible for unintended system changes, data loss, or misconfiguration caused by improper use.
