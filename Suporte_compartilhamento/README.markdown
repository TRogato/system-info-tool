# System Information Tool - Problemas_rede.ps1

## Overview
This repository contains a PowerShell script located at `Suporte_compartilhamento/Problemas_rede.ps1`, designed to assist in diagnosing and troubleshooting network-related issues on Windows systems. Part of the broader `system-info-tool` project by TRogato, this script provides advanced functionality to collect and display detailed information about network configurations, connectivity, and potential problems.

## Features
- Collects detailed network configuration data.
- Identifies common network issues.
- Provides actionable insights for troubleshooting.

## Usage
1. Clone the repository:
   ```
   git clone https://github.com/TRogato/system-info-tool.git
   ```
2. Navigate to the script directory:
   ```
   cd system-info-tool/Suporte_compartilhamento
   ```
3. Run the script with PowerShell:
   ```
   .\Problemas_rede.ps1
   ```
   - Ensure you have appropriate permissions to execute PowerShell scripts (you may need to set `ExecutionPolicy` to `RemoteSigned` or `Unrestricted` if restricted).

4. Método Alternativo (download + execução):
''''
$url = "https://raw.githubusercontent.com/TRogato/system-info-tool/main/Suporte_compartilhamento/Problemas_rede.ps1"
$path = "$env:TEMP\Problemas_rede.ps1"
irm $url -OutFile $path
& $path
''''

## Requirements
- Windows operating system.
- PowerShell installed (included by default in modern Windows versions).
- Administrative privileges may be required for certain diagnostic commands.

## Contributing
Feel free to contribute to this project by forking the repository and submitting pull requests. For major changes, please open an issue first to discuss what you would like to change.

## License
This project is © 2025 GitHub, Inc. Please refer to the repository for more details on licensing and usage terms.

## Contact
For support or questions, you can reach out via the GitHub repository issues page: [https://github.com/TRogato/system-info-tool/issues](https://github.com/TRogato/system-info-tool/issues).