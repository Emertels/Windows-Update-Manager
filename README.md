# 🌐 Gerenciador do Windows Update 🇧🇷

Fluxo interativo de atualizações cumulativas e importantes do Windows 10/11 usando fontes oficiais.

[![Documentação](https://img.shields.io/badge/DOCUMENTA%C3%87%C3%83O-PORTUGU%C3%8AS%20(BRASIL)-green?style=for-the-badge)](README.md) [![Documentation](https://img.shields.io/badge/DOCUMENTATION-ENGLISH-0070F3?style=for-the-badge)](README-EN.md)

![Versão](https://img.shields.io/badge/Vers%C3%A3o-v1.0.0-blue?style=flat-square) ![Licença](https://img.shields.io/badge/Licen%C3%A7a-MIT-green?style=flat-square) ![Plataforma](https://img.shields.io/badge/Plataforma-Windows-0078D4?style=flat-square) ![Idiomas](https://img.shields.io/badge/Idiomas-10%20auto--detectados-2ea44f?style=flat-square)

[Changelog PT-BR](CHANGELOG-PT-BR.md) · [English changelog](CHANGELOG-EN.md) · [Licença MIT](LICENSE)

---
## Arquivos

Windows-Update-Manager.ps1 e Session-Header.ps1

## Como usar

1. Baixe ou clone o repositório completo.
2. Execute `Windows-Update-Manager.ps1` no Windows PowerShell. Mantenha `Session-Header.ps1` na mesma pasta. Leia cada etapa antes de confirmar downloads ou instalações e aceite o UAC quando solicitado.

## Requisitos

Windows 10 ou Windows 11. Requer Windows PowerShell 5.1; downloads e instalações podem exigir privilégios de administrador. O winget não é necessário.

## Opções e fluxo

**1 — Atualizações cumulativas:** busca esse tipo de atualização do Windows. **2 — Atualizações importantes:** busca os demais pacotes importantes da fonte escolhida. **3 — Ambas. 0 — Sair.** Depois dos downloads, revise a lista e escolha instalar agora ou guardar os arquivos para depois. O utilitário não reinicia o PC automaticamente. Instalações podem exigir administrador e dependem da versão do Windows, das fontes Microsoft e das políticas do dispositivo. Salve seu trabalho antes de instalar.

### Idiomas disponíveis

Detectados pela configuração do Windows; PT-BR é o fallback.

| Idioma | Código | Uso |
|---|---|
| Português (Brasil) | pt-BR | Interface PT-BR; também é o idioma alternativo. |
| Inglês | en | Interface em inglês. |
| Espanhol | es | Interface em espanhol. |
| Francês | fr | Interface em francês. |
| Alemão | de | Interface em alemão. |
| Italiano | it | Interface em italiano. |
| Japonês | ja | Interface em japonês. |
| Coreano | ko | Interface em coreano. |
| Chinês simplificado | zh-CN | Interface em chinês simplificado. |
| Russo | ru | Interface em russo. |

## 👨‍💻 Sobre o Autor

Desenvolvido e mantido por **Emerson Teles** (conhecido na comunidade como **Emertels**).

Entusiasta de tecnologia, informática, jogos, manutenção de sistemas e tradução/localização de softwares para Português do Brasil (PT-BR). Desenvolvedor focado em utilitários práticos, ferramentas de produtividade, automação inteligente em PowerShell e soluções completas de localização técnica que aproximam ferramentas modernas do público brasileiro.

### 🛠️ Projetos & Contribuições

- [AI-Chat-Vault](https://github.com/Emertels/AI-Chat-Vault) — Backup portátil e recuperação de conversas locais de 20+ ferramentas e assistentes de IA.
- [Antigravity — Tradução PT-BR](https://github.com/Emertels/Antigravity-Traducao-PTBR) — Localização completa do Google Antigravity Desktop para Português do Brasil.
- [Codex Router — Tradução PT-BR](https://github.com/Emertels/CodexRouter-Traducao-PTBR) — Pacote de tradução e localização do Codex Router Control Center em PT-BR.
- [Cursor AI — Tradução PT-BR](https://github.com/Emertels/Cursor-Traducao-PTBR) — Localização completa e profunda do Cursor AI para Português do Brasil.
- [GPU Tweak III — Tradução PT-BR](https://github.com/Emertels/GPU-Tweak-III-Traducao-PTBR) — Tradução em português brasileiro e instalador automatizado para ASUS GPU Tweak III.
- [Microsoft Photos Fix](https://github.com/Emertels/Microsoft-Photos-Fix) — Solução definitiva em PowerShell e C# para rota de inicialização rápida e visualização no app Fotos do Windows.
- [PSBBN-Translator](https://github.com/Emertels/PSBBN-Translator) — Suíte corporativa de tradução e localização para o PSBBN Definitive Project (PlayStation 2) em 40 idiomas.
- [Silent Hill: Homecoming — Tradução PT-BR](https://github.com/Emertels/Silent-Hill-Homecoming-Traducao-PTBR) — Tradução e revisão completa do jogo para PC em português brasileiro.
- [Suite-Emuladores](https://github.com/Emertels/Suite-Emuladores) — Suíte inteligente em PowerShell para download e atualização autônoma de 56 emuladores e frontends no Windows.
- [ZCode — Tradução PT-BR](https://github.com/Emertels/ZCode-Traducao-PTBR) — Tradução e localização completa do ZCode Desktop para Português do Brasil.

### 🌐 Conecte-se comigo & Comunidades Oficiais

<div align="left">

[![GitHub](https://img.shields.io/badge/GitHub-Emertels-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/emertels)
[![Website](https://img.shields.io/badge/Website-Emerson_Teles-0070F3?style=for-the-badge&logo=googlechrome&logoColor=white)](https://emertels.github.io)
[![Discord](https://img.shields.io/badge/Discord-Emertels%20Server-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://emertels.github.io/discord)
[![X / Twitter](https://img.shields.io/badge/X_Twitter-@emertels-000000?style=for-the-badge&logo=x&logoColor=white)](https://x.com/emertels)
[![YouTube](https://img.shields.io/badge/YouTube-Emerson_Teles-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://www.youtube.com/@emersonteles2379)
[![Telegram](https://img.shields.io/badge/Telegram-Aplicativos%20Mods-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/apksmodsandroid)
[![Ko-fi](https://img.shields.io/badge/Ko--fi-Apoiar%20Projeto-FF5E5B?style=for-the-badge&logo=kofi&logoColor=white)](https://ko-fi.com/emertels)

</div>
