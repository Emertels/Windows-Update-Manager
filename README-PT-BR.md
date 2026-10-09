# Gerenciador do Windows Update

**Versão:** 1.0.0  
**Idiomas da interface:** PT-BR, inglês, espanhol, francês, alemão, italiano, japonês, coreano, chinês simplificado e russo. O idioma segue a configuração do Windows; PT-BR é usado como alternativa quando o idioma não é compatível.

## O que faz

Fluxo interativo de atualizações cumulativas e importantes do Windows 10/11 usando fontes oficiais.

## Arquivos

Windows-Update-Manager.ps1 e Session-Header.ps1

## Como usar

1. Baixe ou clone o repositório completo.
2. Execute `Windows-Update-Manager.ps1` no Windows PowerShell. Mantenha `Session-Header.ps1` na mesma pasta. Leia cada etapa antes de confirmar downloads ou instalações e aceite o UAC quando solicitado.

## Requisitos

Windows 10 ou Windows 11. Requer Windows PowerShell 5.1; downloads e instalações podem exigir privilégios de administrador. O winget não é necessário.

## Segurança e limitações

O projeto não deve apagar dados pessoais, credenciais ou conteúdo fora dos caminhos definidos pela ferramenta. A disponibilidade de comandos e recursos depende da edição e versão do Windows. Revise CHANGELOG.md antes de atualizar.

## Desenvolvimento

Consulte AGENTS-PT-BR.md e AGENTS-EN.md. O idioma padrão da interface é detectado pela cultura do Windows; quando ela não for compatível, use PT-BR como fallback.

## Idiomas, finalidade e dicas

Menus, etapas, avisos, resumos e mensagens de download/instalação são apresentados nos dez idiomas. Dica: deixe os pacotes baixarem até o resumo final; então escolha instalar agora ou guardar para depois. A ferramenta não reinicia o computador automaticamente.

Salve seu trabalho e considere criar ponto de restauração antes de redefinir componentes. Políticas corporativas e versão do Windows podem limitar ações.

### Idiomas disponíveis / Available languages

| Idioma | Código | Indicação |
|---|---|---|
| Português (Brasil) | pt-BR | Brasil |
| Inglês | en | Sistemas em inglês |
| Espanhol | es | Sistemas em espanhol |
| Francês | fr | Sistemas em francês |
| Alemão | de | Sistemas em alemão |
| Italiano | it | Sistemas em italiano |
| Japonês | ja | Sistemas em japonês |
| Coreano | ko | Sistemas em coreano |
| Chinês simplificado | zh-CN | Sistemas em chinês simplificado |
| Russo | ru | Sistemas em russo |







## Sobre Emerson Teles

Emerson Teles (Emertels) desenvolve ferramentas para Windows, automação, emulação e localização de software. Veja os projetos e acompanhe os canais oficiais:

- [Site oficial](https://emertels.github.io) · [GitHub](https://github.com/Emertels) · [Discord](https://emertels.github.io/discord)
- [YouTube](https://www.youtube.com/@emersonteles2379) · [X](https://x.com/emertels) · [Telegram](https://t.me/apksmodsandroid) · [Ko-fi](https://ko-fi.com/emertels)

### Outros projetos

- [AI-Chat-Vault](https://github.com/Emertels/AI-Chat-Vault) — backup portátil e recuperação de conversas locais de ferramentas de IA.
- [Suite-Emuladores](https://github.com/Emertels/Suite-Emuladores) — gerenciamento de download e atualização de emuladores e frontends no Windows.
- [Microsoft-Photos-Fix](https://github.com/Emertels/Microsoft-Photos-Fix) — correção de inicialização e papel de parede do app Fotos do Windows.
- [PSBBN-Translator](https://github.com/Emertels/PSBBN-Translator) — localização do PSBBN Definitive Project em 40 idiomas.
- [GPU-Tweak-III-Traducao-PTBR](https://github.com/Emertels/GPU-Tweak-III-Traducao-PTBR), [Cursor-Traducao-PTBR](https://github.com/Emertels/Cursor-Traducao-PTBR), [CodexRouter-Traducao-PTBR](https://github.com/Emertels/CodexRouter-Traducao-PTBR), [Antigravity-Traducao-PTBR](https://github.com/Emertels/Antigravity-Traducao-PTBR) e [ZCode-Traducao-PTBR](https://github.com/Emertels/ZCode-Traducao-PTBR) — projetos de localização para PT-BR.
- [Silent-Hill-Homecoming-Traducao-PTBR](https://github.com/Emertels/Silent-Hill-Homecoming-Traducao-PTBR) — tradução e revisão para PC.



