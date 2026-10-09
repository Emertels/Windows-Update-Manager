# Instruções para agentes

## Objetivo e identidade

- Preserve o propósito, o fluxo e as escolhas visuais que Emerson refinou manualmente. Antes de redesenhar uma interface, compare-a com a versão existente e altere somente o que for necessário para corrigir um problema solicitado.
- Mantenha a versão do projeto em `1.0.0` até uma mudança explícita de versão. Atualize ambos os changelogs quando comportamento, interface, requisitos ou documentação mudarem.
- Preserve os nomes e formatos de arquivo definidos para o projeto. Projetos escolhidos como Batch devem continuar em um único `.bat`, sem cópia paralela em `.ps1`.

## Idiomas, terminal e aparência

- Toda interface deve oferecer exatamente estes dez idiomas e detectar automaticamente a cultura do Windows: PT-BR, inglês (`en`), espanhol (`es`), francês (`fr`), alemão (`de`), italiano (`it`), japonês (`ja`), coreano (`ko`), chinês simplificado (`zh-CN`) e russo (`ru`). Use PT-BR como fallback.
- Traduza mensagens visíveis, prompts, estados, erros e instruções de uso; mantenha comandos, parâmetros, identificadores de registro, caminhos técnicos e saídas literais do sistema sem tradução.
- Escreva PT-BR com acentos e cedilha corretos e use a ortografia própria dos demais idiomas. Não use `chcp 65001 >nul` em arquivos `.bat` nem sequências ANSI de negrito. Preserve as cores e o padrão visual aprovado para cada projeto.
- Cabeçalhos de sessão devem mostrar versão, data, hora de início e idioma detectado. Evite redesenhar telas já aprovadas pelo autor.

## Segurança e compatibilidade

- Não execute ações destrutivas durante revisão ou validação. Explique efeitos de alterações de rede, registro, limpeza ou atualização e preserve confirmações apropriadas.
- Valide entradas e confira códigos de saída. Não informe sucesso se uma operação falhar ou não puder ser confirmada.
- Mantenha compatibilidade com as versões e requisitos documentados. Não acrescente dependências nem invente suporte a hardware, Windows ou ferramentas.
- Não inclua dados pessoais, credenciais, logs, temporários ou arquivos gerados sem relação com o projeto.

## Documentação e releases

- Mantenha `README.md` como documentação principal em PT-BR e `README-EN.md` como versão independente em inglês. Ambos devem explicar finalidade, requisitos, uso, limitações e os dez idiomas sem repetir texto desnecessariamente.
- Atualize também `AGENTS-PT-BR.md`, `AGENTS-EN.md`, ambos os changelogs e a descrição do projeto quando necessário.
- Mantenha a licença MIT no repositório.
- O ZIP de release deve conter somente arquivos necessários para usar o projeto; exclua README, changelog, AGENTS, licença e assets.
