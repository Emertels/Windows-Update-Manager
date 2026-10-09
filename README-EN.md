# 🌐 Windows Update Manager

Interactive Windows 10/11 cumulative and important update workflow using Microsoft update sources.

[![Português (Brasil)](https://img.shields.io/badge/DOCUMENTA%C3%87%C3%83O-PORTUGU%C3%8AS%20(BRASIL)-green?style=for-the-badge)](README.md) [![Documentation](https://img.shields.io/badge/DOCUMENTATION-ENGLISH-0070F3?style=for-the-badge)](README-EN.md)

![Version](https://img.shields.io/badge/Version-v1.0.0-blue?style=flat-square) ![License](https://img.shields.io/badge/License-MIT-green?style=flat-square) ![Platform](https://img.shields.io/badge/Platform-Windows-0078D4?style=flat-square) ![Languages](https://img.shields.io/badge/Languages-10%20auto--detected-2ea44f?style=flat-square)

[Portuguese changelog](CHANGELOG-PT-BR.md) · [English changelog](CHANGELOG-EN.md) · [MIT License](LICENSE)

---
## Files

Windows-Update-Manager.ps1 and Session-Header.ps1

## Usage

1. Download or clone the complete repository.
2. Run `Windows-Update-Manager.ps1` in Windows PowerShell and keep `Session-Header.ps1` in the same folder. Review each step before confirming downloads or installations, and approve the UAC prompt when requested.

## Requirements

Windows 10 or Windows 11. Windows PowerShell 5.1 is required; downloads and installations may require administrator privileges. winget is not required.

## Options and workflow

**1 — Cumulative updates:** searches for Windows cumulative updates. **2 — Important updates:** searches for other important packages from the chosen source. **3 — Both. 0 — Exit.** After downloads, review the list and choose to install now or keep files for later. The utility does not restart the PC automatically. Installation may require administrator rights and depends on Windows version, Microsoft sources, and device policies. Save your work first.

### Available languages

Detected from Windows settings; Brazilian Portuguese is the fallback.

| Language | Locale | Typical system |
|---|---|
| Brazilian Portuguese | pt-BR | Brazilian Windows; also the fallback language. |
| English | en | English Windows. |
| Spanish | es | Spanish Windows. |
| French | fr | French Windows. |
| German | de | German Windows. |
| Italian | it | Italian Windows. |
| Japanese | ja | Japanese Windows. |
| Korean | ko | Korean Windows. |
| Simplified Chinese | zh-CN | Simplified Chinese Windows. |
| Russian | ru | Russian Windows. |

## 👨‍💻 About the Author

Developed and maintained by **Emerson Teles** (known in the community as **Emertels**).

Technology, computing, gaming, system maintenance, and software translation/localization enthusiast. Focused on practical utilities, productivity tools, intelligent PowerShell automation, and technical localization solutions that make modern tools more accessible to Brazilian users.

### 🛠️ Projects & Contributions

- [AI-Chat-Vault](https://github.com/Emertels/AI-Chat-Vault) — Portable backup and recovery for local conversations from 20+ AI tools and assistants.
- [Antigravity — Brazilian Portuguese Translation](https://github.com/Emertels/Antigravity-Traducao-PTBR) — Complete localization of Google Antigravity Desktop into Brazilian Portuguese.
- [Codex Router — Brazilian Portuguese Translation](https://github.com/Emertels/CodexRouter-Traducao-PTBR) — Translation and localization package for Codex Router Control Center.
- [Cursor AI — Brazilian Portuguese Translation](https://github.com/Emertels/Cursor-Traducao-PTBR) — Complete, in-depth localization of Cursor AI into Brazilian Portuguese.
- [GPU Tweak III — Brazilian Portuguese Translation](https://github.com/Emertels/GPU-Tweak-III-Traducao-PTBR) — Brazilian Portuguese translation and automated installer for ASUS GPU Tweak III.
- [Microsoft Photos Fix](https://github.com/Emertels/Microsoft-Photos-Fix) — PowerShell and C# fix for startup routing and image viewing in Windows Photos.
- [PSBBN-Translator](https://github.com/Emertels/PSBBN-Translator) — Localization suite for the PSBBN Definitive Project (PlayStation 2) in 40 languages.
- [Silent Hill: Homecoming — Brazilian Portuguese Translation](https://github.com/Emertels/Silent-Hill-Homecoming-Traducao-PTBR) — Complete PC translation and review into Brazilian Portuguese.
- [Suite-Emuladores](https://github.com/Emertels/Suite-Emuladores) — PowerShell suite for downloading and updating 56 emulators and frontends on Windows.
- [ZCode — Brazilian Portuguese Translation](https://github.com/Emertels/ZCode-Traducao-PTBR) — Complete localization of ZCode Desktop into Brazilian Portuguese.

### 🌐 Connect with me & Official Communities

<div align="left">

[![GitHub](https://img.shields.io/badge/GitHub-Emertels-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/emertels)
[![Website](https://img.shields.io/badge/Website-Emerson_Teles-0070F3?style=for-the-badge&logo=googlechrome&logoColor=white)](https://emertels.github.io)
[![Discord](https://img.shields.io/badge/Discord-Emertels%20Server-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://emertels.github.io/discord)
[![X / Twitter](https://img.shields.io/badge/X_Twitter-@emertels-000000?style=for-the-badge&logo=x&logoColor=white)](https://x.com/emertels)
[![YouTube](https://img.shields.io/badge/YouTube-Emerson_Teles-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://www.youtube.com/@emersonteles2379)
[![Telegram](https://img.shields.io/badge/Telegram-Aplicativos%20Mods-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/apksmodsandroid)
[![Ko-fi](https://img.shields.io/badge/Ko--fi-Support_the_Project-FF5E5B?style=for-the-badge&logo=kofi&logoColor=white)](https://ko-fi.com/emertels)

</div>
