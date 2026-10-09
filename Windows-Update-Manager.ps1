# AtualizarWindows.ps1 - Windows 10 e 11 / Windows PowerShell 5.1
# Version 1.0.0
# Executa uma busca por chamada; não cria agendamentos.
# Padrão: Catálogo, cumulativa mais recente publicada, incluindo prévias e OOB.
# Alternativa: -Fonte WindowsUpdate. Não faz upgrade entre versões do Windows.
# Parser de páginas públicas: se a estrutura mudar, interrompe sem adivinhar pacotes.
# Windows 11: baixa também os checkpoints MSU listados no mesmo diálogo.
# A verificação de assinatura/aplicabilidade e feita pelo instalador oficial WUSA.
# Baixa e instala cumulativas do SO e pilha de manutenção oferecidas pelo WUA.
# Módulos Windows e Importantes (Defender, .NET, segurança, críticas e rollups).
# Menu inicia downloads de todos os pacotes aplicaveis dos grupos, incluindo prévias.
# Registros internos em ProgramData; nenhum arquivo na Área de Trabalho.
# Não instala drivers nem mudanças de versão (feature upgrades).
# Novos títulos de cumulativas do Windows 11 podem aparecer como Security Update.
# Use -SomenteVerificar para listar sem baixar/instalar.
# Fonte: https://learn.microsoft.com/en-us/windows/win32/wua_sdk/searching--downloading--and-installing-updates
# Não altera WSUS, licenças, ESU, políticas ou configurações de segurança.
# Para manter até erros de sintaxe visíveis, iniciar com powershell.exe -NoExit -File.
[CmdletBinding()]
param(
    [switch]$SomenteVerificar,
    [ValidateSet('Catalogo', 'WindowsUpdate')]
    [string]$Fonte = 'Catalogo',
    [ValidateSet('Menu', 'Windows', 'Importantes', 'DotNet', 'Ambos')]
    [string]$Modulo = 'Menu'
)

. "$PSScriptRoot\Session-Header.ps1"

# Catálogos localizados do menu, dos fluxos de atualização e das mensagens de status.
$script:UpdateMenuText = @{
    'pt-BR' = @('ATUALIZAR WINDOWS','Atualizações cumulativas e de segurança para Windows 10 e 11','O QUE DESEJA BAIXAR?','Cumulativa do Windows','Baixa a cumulativa mais recente da sua versão, incluindo prévias.','Atualizações importantes','Baixa Defender, .NET e outras correções, incluindo prévias opcionais.','Windows + atualizações importantes','Executa as duas buscas: cumulativa do sistema e correções adicionais.','Sair','Encerra o script e fecha esta janela.','Confirme um número com Enter. A busca e o download começam automaticamente.','Ao concluir todos os downloads, você escolhe se quer instalar.','Digite um número do menu e pressione Enter para confirmar.','SUA ESCOLHA','Escolha um número (0, 1, 2 ou 3)')
    en = @('WINDOWS UPDATE','Cumulative and security updates for Windows 10 and 11','WHAT WOULD YOU LIKE TO DOWNLOAD?','Windows cumulative update','Downloads the latest cumulative update for your version, including previews.','Important updates','Downloads Defender, .NET, and other fixes, including optional previews.','Windows + important updates','Runs both searches: system cumulative update and additional fixes.','Exit','Closes the script and this window.','Enter a number and press Enter. The search and download start automatically.','After all downloads finish, you can choose whether to install them.','Enter a menu number and press Enter to confirm.','YOUR SELECTION','Choose a number (0, 1, 2, or 3)')
    es = @('ACTUALIZAR WINDOWS','Actualizaciones acumulativas y de seguridad para Windows 10 y 11','¿QUÉ DESEA DESCARGAR?','Actualización acumulativa de Windows','Descarga la actualización acumulativa más reciente de su versión, incluidas las versiones preliminares.','Actualizaciones importantes','Descarga Defender, .NET y otras correcciones, incluidas versiones preliminares opcionales.','Windows + actualizaciones importantes','Realiza ambas búsquedas: actualización acumulativa del sistema y correcciones adicionales.','Salir','Cierra el script y esta ventana.','Confirme un número con Enter. La búsqueda y la descarga comienzan automáticamente.','Al terminar todas las descargas, podrá elegir si desea instalarlas.','Introduzca un número del menú y pulse Enter para confirmar.','SU ELECCIÓN','Elija un número (0, 1, 2 o 3)')
    fr = @('MISE À JOUR DE WINDOWS','Mises à jour cumulatives et de sécurité pour Windows 10 et 11','QUE SOUHAITEZ-VOUS TÉLÉCHARGER ?','Mise à jour cumulative de Windows','Télécharge la dernière mise à jour cumulative de votre version, y compris les versions préliminaires.','Mises à jour importantes','Télécharge Defender, .NET et d''autres correctifs, y compris les versions préliminaires facultatives.','Windows + mises à jour importantes','Effectue les deux recherches : mise à jour cumulative du système et correctifs supplémentaires.','Quitter','Ferme le script et cette fenêtre.','Confirmez un numéro avec Entrée. La recherche et le téléchargement démarrent automatiquement.','Une fois tous les téléchargements terminés, vous pourrez choisir de les installer.','Saisissez un numéro du menu et appuyez sur Entrée pour confirmer.','VOTRE CHOIX','Choisissez un numéro (0, 1, 2 ou 3)')
    de = @('WINDOWS AKTUALISIEREN','Kumulative und Sicherheitsupdates für Windows 10 und 11','WAS MÖCHTEN SIE HERUNTERLADEN?','Kumulatives Windows-Update','Lädt das neueste kumulative Update für Ihre Version herunter, einschließlich Vorschauversionen.','Wichtige Updates','Lädt Defender, .NET und weitere Korrekturen herunter, auch optionale Vorschauversionen.','Windows + wichtige Updates','Führt beide Suchen aus: kumulatives Systemupdate und zusätzliche Korrekturen.','Beenden','Schließt das Skript und dieses Fenster.','Bestätigen Sie eine Zahl mit Enter. Suche und Download starten automatisch.','Nach Abschluss aller Downloads können Sie die Installation auswählen.','Geben Sie eine Menünummer ein und drücken Sie Enter zur Bestätigung.','IHRE AUSWAHL','Wählen Sie eine Zahl (0, 1, 2 oder 3)')
    it = @('AGGIORNA WINDOWS','Aggiornamenti cumulativi e di sicurezza per Windows 10 e 11','COSA VUOI SCARICARE?','Aggiornamento cumulativo di Windows','Scarica l''ultimo aggiornamento cumulativo per la tua versione, incluse le anteprime.','Aggiornamenti importanti','Scarica Defender, .NET e altre correzioni, incluse le anteprime facoltative.','Windows + aggiornamenti importanti','Esegue entrambe le ricerche: aggiornamento cumulativo del sistema e correzioni aggiuntive.','Esci','Chiude lo script e questa finestra.','Conferma un numero con Invio. La ricerca e il download iniziano automaticamente.','Al termine di tutti i download, potrai scegliere se installarli.','Inserisci un numero del menu e premi Invio per confermare.','LA TUA SCELTA','Scegli un numero (0, 1, 2 o 3)')
    ja = @('Windows を更新','Windows 10 と 11 の累積更新プログラムとセキュリティ更新','何をダウンロードしますか？','Windows 累積更新プログラム','プレビューを含む、お使いのバージョンの最新累積更新プログラムをダウンロードします。','重要な更新プログラム','Defender、.NET、その他の修正をダウンロードします。オプションのプレビューを含みます。','Windows + 重要な更新プログラム','システムの累積更新と追加の修正の両方を検索します。','終了','スクリプトを終了してウィンドウを閉じます。','番号を入力して Enter を押します。検索とダウンロードは自動的に始まります。','すべてのダウンロード完了後、インストールするか選択できます。','メニュー番号を入力し、Enter を押して確定してください。','選択内容','番号を選択してください (0、1、2、3)')
    ko = @('Windows 업데이트','Windows 10 및 11 누적 및 보안 업데이트','무엇을 다운로드하시겠습니까?','Windows 누적 업데이트','미리 보기를 포함하여 해당 버전의 최신 누적 업데이트를 다운로드합니다.','중요 업데이트','Defender, .NET 및 기타 수정 사항을 다운로드합니다. 선택적 미리 보기를 포함합니다.','Windows + 중요 업데이트','시스템 누적 업데이트와 추가 수정 사항을 모두 검색합니다.','종료','스크립트와 이 창을 닫습니다.','번호를 입력하고 Enter 키를 누르세요. 검색 및 다운로드가 자동으로 시작됩니다.','모든 다운로드가 완료되면 설치 여부를 선택할 수 있습니다.','메뉴 번호를 입력하고 Enter 키를 눌러 확인하세요.','선택 항목','번호를 선택하세요 (0, 1, 2 또는 3)')
    'zh-CN' = @('更新 Windows','适用于 Windows 10 和 11 的累积更新与安全更新','要下载什么？','Windows 累积更新','下载适用于当前版本的最新累积更新，包括预览版。','重要更新','下载 Defender、.NET 和其他修复，包括可选预览版。','Windows + 重要更新','执行两项搜索：系统累积更新和其他修复。','退出','关闭脚本和此窗口。','输入数字并按 Enter。搜索和下载将自动开始。','所有下载完成后，您可以选择是否安装。','输入菜单编号并按 Enter 确认。','您的选择','请选择编号（0、1、2 或 3）')
    ru = @('ОБНОВИТЬ WINDOWS','Накопительные обновления и обновления безопасности для Windows 10 и 11','ЧТО СКАЧАТЬ?','Накопительное обновление Windows','Скачивает последнее накопительное обновление для вашей версии, включая предварительные выпуски.','Важные обновления','Скачивает Defender, .NET и другие исправления, включая необязательные предварительные версии.','Windows + важные обновления','Выполняет оба поиска: накопительное обновление системы и дополнительные исправления.','Выход','Закрывает сценарий и это окно.','Введите номер и нажмите Enter. Поиск и загрузка начнутся автоматически.','После завершения всех загрузок можно выбрать, устанавливать ли их.','Введите номер меню и нажмите Enter для подтверждения.','ВАШ ВЫБОР','Выберите номер (0, 1, 2 или 3)')
}
$script:UpdateMenu = $script:UpdateMenuText[$script:AppLanguage]


# Traduções dos principais rótulos e avisos dos fluxos de busca e instalação.
$script:UpdateUiSources = @(
    'ETAPA ', ' DE 5   |   ', 'RESUMO DOS DOWNLOADS',
    'DOWNLOADS CONCLUÍDOS — INSTALAR AGORA?',
    '[1] Instalar os pacotes baixados (sem reiniciar)',
    '[2] Guardar os downloads e instalar depois',
    'Digite 1 ou 2 e pressione Enter',
    'Escolha 1 para instalar ou 2 para deixar para depois.',
    'Sessão iniciada', 'Execução', 'Administrador', 'Ação',
    'Somente consultar; nenhum download', 'Buscar e baixar automaticamente',
    'Fonte do Windows', 'Fonte adicional',
    'O percentual pode permanecer estável enquanto um pacote é processado.',
    'Consultando atualizações aplicáveis, incluindo prévias opcionais.',
    'Nenhuma atualização pendente deste grupo foi oferecida.',
    'Consulta concluída. Nenhum download solicitado.',
    'Downloads guardados. Nenhuma instalação foi iniciada.',
    'Os downloads terminaram. Reinicie o computador antes de instalar. Os pacotes continuam guardados.',
    'A atualização anterior precisa de reinício. Os outros downloads foram preservados para instalar depois.',
    'INSTALAÇÃO EM ANDAMENTO',
    'Aguarde a conclusão. O computador não será reiniciado automaticamente.',
    'Instalação concluída com reinício pendente. Os demais downloads continuam guardados.',
    'Consultando a cumulativa publicada mais recente para sua versão, incluindo prévias.',
    'A build instalada já alcança ou supera a cumulativa mais recente publicada.',
    'WUSA verificará assinatura, aplicabilidade e pré-requisitos, incluindo ESU. Não desligue o computador.',
    'Instalador concluiu com sucesso.',
    'Instalação concluída. Reinicie manualmente para finalizar.',
    'O instalador informou que a atualização já está instalada.',
    'Confira o Winver após reiniciar. Nenhuma reinicialização automática foi solicitada.',
    'Abrindo Windows PowerShell como administrador. Confirme o UAC do Windows.',
    'Seu computador', 'Preparação dos serviços',
    'Windows 10 Home/Pro encerrou suporte regular em 14/10/2025. Atualizações posteriores exigem elegibilidade ESU.',
    'A busca verifica o que está disponível para ESTE computador; não comprova a maior build publicada.',
    'WSUS configurado: respeitando a fonte gerenciada. Ela pode limitar as atualizações oferecidas.',
    'Há um reinício pendente. Você pode baixar; a instalação aguardará a reinicialização.',
    'Download cancelado. Voltando ao menu principal.',
    'Detalhes técnicos salvos no log.',
    'NÃO FOI POSSÍVEL CONCLUIR', 'FIM DA EXECUÇÃO',
    'ENTER  Voltar ao menu principal',
    'ESC    Encerrar o script e fechar esta janela',
    'Enter: menu principal | digite SAIR: encerrar',
    'Atualização', 'Destino', 'Concluídos', 'Tipo', 'Tamanho',
    'SomenteVerificar: nenhum arquivo baixado ou instalado.',
    'ETAPA 3 DE 5   |   CONSULTAR PUBLICAÇÕES OFICIAIS E CATÁLOGO',
    'ETAPA 4 DE 5   |   BAIXAR CUMULATIVA E CHECKPOINTS',
    'ETAPA 5 DE 5   |   INSTALAR CUMULATIVA OFICIAL',
    'Seu computador', 'Preparação dos serviços',
    'Esta etapa pode levar vários minutos. O serviço não informa percentual nesta chamada.'
)
$script:UpdateUiText = @{
'pt-BR' = @($script:UpdateUiSources)
'en' = @(
 'STAGE ',' OF 5   |   ','DOWNLOAD SUMMARY',
 'DOWNLOADS COMPLETE — INSTALL NOW?',
 '[1] Install downloaded packages (do not restart)',
 '[2] Keep downloads and install later',
 'Enter 1 or 2 and press Enter',
 'Choose 1 to install or 2 to save for later.',
 'Session started','Run mode','Administrator','Action',
 'Check only; do not download','Search and download automatically',
 'Windows source','Additional source',
 'Progress may remain unchanged while a package is being processed.',
 'Checking applicable updates, including optional previews.',
 'No pending updates were offered for this group.',
 'Check complete. No download was requested.',
 'Downloads saved. No installation was started.',
 'Downloads finished. Restart the computer before installing. Packages remain saved.',
 'The previous update requires a restart. Other downloads were kept for later installation.',
 'INSTALLATION IN PROGRESS',
 'Wait for completion. The computer will not restart automatically.',
 'Installation completed; a restart is pending. Other downloads remain saved.',
 'Checking the latest cumulative update published for your version, including previews.',
 'The installed build already matches or exceeds the latest published cumulative update.',
 'WUSA will verify the signature, applicability, and prerequisites, including ESU. Do not turn off the computer.',
 'Installer completed successfully.',
 'Installation completed. Restart manually to finish.',
 'The installer reported that this update is already installed.',
 'Check Winver after restarting. No automatic restart was requested.',
 'Opening Windows PowerShell as administrator. Confirm the Windows UAC prompt.',
 'Your computer','Preparing services',
 'Windows 10 Home/Pro regular support ended on 2025-10-14. Later updates require ESU eligibility.',
 'The search checks what is available for THIS computer; it does not prove the newest published build.',
 'WSUS is configured; using the managed source. It may limit offered updates.',
 'A restart is pending. You can download updates; installation will wait until after the restart.',
 'Download cancelled. Returning to the main menu.',
 'Technical details were saved to the log.',
 'UNABLE TO COMPLETE','END OF RUN',
 'ENTER  Return to the main menu',
 'ESC    Exit and close this window',
 'Enter: main menu | type EXIT to close',
 'Update','Destination','Completed','Type','Size',
 'Check-only mode: no files were downloaded or installed.',
 'STAGE 3 OF 5   |   CHECK OFFICIAL RELEASES AND CATALOG',
 'STAGE 4 OF 5   |   DOWNLOAD CUMULATIVE UPDATE AND CHECKPOINTS',
 'STAGE 5 OF 5   |   INSTALL OFFICIAL CUMULATIVE UPDATE',
 'Your computer','Preparing services',
  'This step may take several minutes. The service does not report progress during this request.'
)
'es' = @(
 'ETAPA ',' DE 5   |   ','RESUMEN DE DESCARGAS',
 'DESCARGAS COMPLETADAS — ¿INSTALAR AHORA?',
 '[1] Instalar los paquetes descargados (sin reiniciar)',
 '[2] Guardar las descargas e instalar más tarde',
 'Escriba 1 o 2 y pulse Enter',
 'Elija 1 para instalar o 2 para dejarlo para después.',
 'Sesión iniciada','Modo de ejecución','Administrador','Acción',
 'Solo consultar; no descargar','Buscar y descargar automáticamente',
 'Origen de Windows','Origen adicional',
 'El porcentaje puede permanecer estable mientras se procesa un paquete.',
 'Buscando actualizaciones aplicables, incluidas las versiones preliminares opcionales.',
 'No se ofrecieron actualizaciones pendientes para este grupo.',
 'Consulta completada. No se solicitó ninguna descarga.',
 'Descargas guardadas. No se inició ninguna instalación.',
 'Las descargas terminaron. Reinicie el equipo antes de instalar. Los paquetes siguen guardados.',
 'La actualización anterior requiere reiniciar. Las demás descargas se conservaron para instalarlas después.',
 'INSTALACIÓN EN CURSO',
 'Espere a que termine. El equipo no se reiniciará automáticamente.',
 'Instalación completada; hay que reiniciar. Las demás descargas siguen guardadas.',
 'Buscando la última actualización acumulativa publicada para su versión, incluidas las versiones preliminares.',
 'La compilación instalada ya alcanza o supera la última actualización acumulativa publicada.',
 'WUSA comprobará la firma, la aplicabilidad y los requisitos previos, incluido ESU. No apague el equipo.',
 'El instalador terminó correctamente.',
 'Instalación completada. Reinicie manualmente para finalizar.',
 'El instalador indicó que esta actualización ya está instalada.',
 'Compruebe Winver después de reiniciar. No se solicitó un reinicio automático.',
 'Abriendo Windows PowerShell como administrador. Confirme el aviso de UAC de Windows.',
 'Su equipo','Preparación de servicios',
 'El soporte normal de Windows 10 Home/Pro terminó el 14/10/2025. Las actualizaciones posteriores requieren elegibilidad para ESU.',
 'La búsqueda comprueba lo disponible para ESTE equipo; no confirma cuál es la compilación publicada más reciente.',
 'WSUS está configurado; se usa el origen administrado. Puede limitar las actualizaciones ofrecidas.',
 'Hay un reinicio pendiente. Puede descargar; la instalación esperará hasta después del reinicio.',
 'Descarga cancelada. Volviendo al menú principal.',
 'Los detalles técnicos se guardaron en el registro.',
 'NO SE PUDO COMPLETAR','FIN DE LA EJECUCIÓN',
 'ENTER  Volver al menú principal',
 'ESC    Salir y cerrar esta ventana',
 'Enter: menú principal | escriba SALIR para cerrar',
 'Actualización','Destino','Completadas','Tipo','Tamaño',
 'Modo de consulta: no se descargaron ni instalaron archivos.',
 'ETAPA 3 DE 5   |   CONSULTAR PUBLICACIONES OFICIALES Y CATÁLOGO',
 'ETAPA 4 DE 5   |   DESCARGAR ACTUALIZACIÓN ACUMULATIVA Y PUNTOS DE CONTROL',
 'ETAPA 5 DE 5   |   INSTALAR ACTUALIZACIÓN ACUMULATIVA OFICIAL',
 'Su equipo','Preparación de servicios',
  'Esta etapa puede tardar varios minutos. El servicio no informa el progreso durante esta solicitud.'
)
'fr' = @(
 'ÉTAPE ',' SUR 5   |   ','RÉSUMÉ DES TÉLÉCHARGEMENTS',
 'TÉLÉCHARGEMENTS TERMINÉS — INSTALLER MAINTENANT ?',
 '[1] Installer les paquets téléchargés (sans redémarrer)',
 '[2] Conserver les téléchargements et installer plus tard',
 'Saisissez 1 ou 2, puis appuyez sur Entrée',
 'Choisissez 1 pour installer ou 2 pour remettre à plus tard.',
 'Session démarrée','Mode d''exécution','Administrateur','Action',
 'Vérifier uniquement ; ne pas télécharger','Rechercher et télécharger automatiquement',
 'Source Windows','Source supplémentaire',
 'Le pourcentage peut rester stable pendant le traitement d’’un paquet.',
 'Recherche des mises à jour applicables, y compris les aperçus facultatifs.',
 'Aucune mise à jour en attente n’’a été proposée pour ce groupe.',
 'Vérification terminée. Aucun téléchargement demandé.',
 'Téléchargements conservés. Aucune installation n’’a été lancée.',
 'Les téléchargements sont terminés. Redémarrez l’’ordinateur avant l’’installation. Les paquets sont conservés.',
 'La mise à jour précédente nécessite un redémarrage. Les autres téléchargements sont conservés pour plus tard.',
 'INSTALLATION EN COURS',
 'Attendez la fin. L’’ordinateur ne redémarrera pas automatiquement.',
 'Installation terminée ; un redémarrage est nécessaire. Les autres téléchargements sont conservés.',
 'Recherche de la dernière mise à jour cumulative publiée pour votre version, aperçus compris.',
 'La version installée atteint ou dépasse déjà la dernière mise à jour cumulative publiée.',
 'WUSA vérifiera la signature, l’’applicabilité et les prérequis, y compris ESU. N’’éteignez pas l’’ordinateur.',
 'Installation terminée avec succès.',
 'Installation terminée. Redémarrez manuellement pour finaliser.',
 'Le programme d’’installation indique que cette mise à jour est déjà installée.',
 'Vérifiez Winver après le redémarrage. Aucun redémarrage automatique n’’a été demandé.',
 'Ouverture de Windows PowerShell en tant qu’’administrateur. Confirmez la demande UAC de Windows.',
 'Votre ordinateur','Préparation des services',
 'Le support standard de Windows 10 Home/Pro a pris fin le 14/10/2025. Les mises à jour ultérieures nécessitent l’’éligibilité ESU.',
 'La recherche vérifie ce qui est proposé pour CET ordinateur ; elle ne prouve pas quelle est la dernière build publiée.',
 'WSUS est configuré ; la source gérée est utilisée. Elle peut limiter les mises à jour proposées.',
 'Un redémarrage est en attente. Le téléchargement est possible ; l’’installation attendra le redémarrage.',
 'Téléchargement annulé. Retour au menu principal.',
 'Les détails techniques ont été enregistrés dans le journal.',
 'IMPOSSIBLE DE TERMINER','FIN DE L’’EXÉCUTION',
 'ENTRÉE  Retour au menu principal',
 'ÉCHAP    Quitter et fermer cette fenêtre',
 'Entrée : menu principal | saisissez QUITTER pour fermer',
 'Mise à jour','Destination','Terminés','Type','Taille',
 'Mode de vérification : aucun fichier téléchargé ni installé.',
 'ÉTAPE 3 SUR 5   |   CONSULTER LES PUBLICATIONS OFFICIELLES ET LE CATALOGUE',
 'ÉTAPE 4 SUR 5   |   TÉLÉCHARGER LA MISE À JOUR CUMULATIVE ET LES CHECKPOINTS',
 'ÉTAPE 5 SUR 5   |   INSTALLER LA MISE À JOUR CUMULATIVE OFFICIELLE',
 'Votre ordinateur','Préparation des services',
  'Cette étape peut prendre plusieurs minutes. Le service ne signale pas la progression pendant cette requête.'
)
'de' = @(
 'SCHRITT ',' VON 5   |   ','DOWNLOADÜBERSICHT',
 'DOWNLOADS ABGESCHLOSSEN — JETZT INSTALLIEREN?',
 '[1] Heruntergeladene Pakete installieren (ohne Neustart)',
 '[2] Downloads behalten und später installieren',
 'Geben Sie 1 oder 2 ein und drücken Sie Enter',
 'Wählen Sie 1 zum Installieren oder 2 für später.',
 'Sitzung gestartet','Ausführungsmodus','Administrator','Aktion',
 'Nur suchen; nichts herunterladen','Automatisch suchen und herunterladen',
 'Windows-Quelle','Zusätzliche Quelle',
 'Der Prozentwert kann während der Verarbeitung eines Pakets unverändert bleiben.',
 'Suche nach anwendbaren Updates, einschließlich optionaler Vorschauen.',
 'Für diese Gruppe wurden keine ausstehenden Updates angeboten.',
 'Suche abgeschlossen. Kein Download angefordert.',
 'Downloads gespeichert. Es wurde keine Installation gestartet.',
 'Downloads abgeschlossen. Starten Sie den Computer vor der Installation neu. Pakete bleiben gespeichert.',
 'Für das vorherige Update ist ein Neustart erforderlich. Andere Downloads bleiben für später erhalten.',
 'INSTALLATION LÄUFT',
 'Warten Sie den Abschluss ab. Der Computer wird nicht automatisch neu gestartet.',
 'Installation abgeschlossen; ein Neustart steht aus. Andere Downloads bleiben gespeichert.',
 'Suche nach dem neuesten veröffentlichten kumulativen Update für Ihre Version, einschließlich Vorschauen.',
 'Der installierte Build erreicht oder übertrifft bereits das neueste veröffentlichte kumulative Update.',
 'WUSA prüft Signatur, Anwendbarkeit und Voraussetzungen, einschließlich ESU. Schalten Sie den Computer nicht aus.',
 'Installation erfolgreich abgeschlossen.',
 'Installation abgeschlossen. Starten Sie manuell neu, um sie abzuschließen.',
 'Der Installer meldet, dass dieses Update bereits installiert ist.',
 'Prüfen Sie Winver nach dem Neustart. Es wurde kein automatischer Neustart angefordert.',
 'Windows PowerShell wird als Administrator geöffnet. Bestätigen Sie die Windows-UAC-Abfrage.',
 'Ihr Computer','Dienste vorbereiten',
 'Der reguläre Support für Windows 10 Home/Pro endete am 14.10.2025. Spätere Updates erfordern ESU-Berechtigung.',
 'Die Suche prüft die Verfügbarkeit für DIESEN Computer; sie bestätigt nicht den neuesten veröffentlichten Build.',
 'WSUS ist konfiguriert; die verwaltete Quelle wird verwendet. Sie kann angebotene Updates einschränken.',
 'Ein Neustart steht aus. Downloads sind möglich; die Installation wartet bis nach dem Neustart.',
 'Download abgebrochen. Zurück zum Hauptmenü.',
 'Technische Details wurden im Protokoll gespeichert.',
 'VORGANG NICHT MÖGLICH','AUSFÜHRUNG BEENDET',
 'ENTER  Zurück zum Hauptmenü',
 'ESC    Beenden und dieses Fenster schließen',
 'Enter: Hauptmenü | BEENDEN eingeben zum Schließen',
 'Update','Ziel','Abgeschlossen','Typ','Größe',
 'Nur-Prüfen-Modus: Es wurden keine Dateien heruntergeladen oder installiert.',
 'SCHRITT 3 VON 5   |   OFFIZIELLE VERÖFFENTLICHUNGEN UND KATALOG PRÜFEN',
 'SCHRITT 4 VON 5   |   KUMULATIVES UPDATE UND CHECKPOINTS HERUNTERLADEN',
 'SCHRITT 5 VON 5   |   OFFIZIELLES KUMULATIVES UPDATE INSTALLIEREN',
 'Ihr Computer','Dienste vorbereiten',
  'Dieser Schritt kann mehrere Minuten dauern. Der Dienst meldet während dieser Abfrage keinen Fortschritt.'
)
'it' = @(
 'FASE ',' DI 5   |   ','RIEPILOGO DEI DOWNLOAD',
 'DOWNLOAD COMPLETATI — INSTALLARE ORA?',
 '[1] Installa i pacchetti scaricati (senza riavviare)',
 '[2] Conserva i download e installa in seguito',
 'Digita 1 o 2 e premi Invio',
 'Scegli 1 per installare o 2 per rimandare.',
 'Sessione avviata','Modalità di esecuzione','Amministratore','Azione',
 'Solo verifica; non scaricare','Cerca e scarica automaticamente',
 'Origine Windows','Origine aggiuntiva',
 'La percentuale può restare stabile durante l’’elaborazione di un pacchetto.',
 'Ricerca degli aggiornamenti applicabili, incluse le anteprime facoltative.',
 'Non sono stati offerti aggiornamenti in sospeso per questo gruppo.',
 'Verifica completata. Nessun download richiesto.',
 'Download conservati. Non è stata avviata alcuna installazione.',
 'Download completati. Riavvia il computer prima di installare. I pacchetti restano salvati.',
 'L’’aggiornamento precedente richiede un riavvio. Gli altri download sono conservati per dopo.',
 'INSTALLAZIONE IN CORSO',
 'Attendi il completamento. Il computer non verrà riavviato automaticamente.',
 'Installazione completata; è necessario riavviare. Gli altri download restano salvati.',
 'Ricerca dell’’ultimo aggiornamento cumulativo pubblicato per la tua versione, incluse le anteprime.',
 'La build installata raggiunge o supera già l’’ultimo aggiornamento cumulativo pubblicato.',
 'WUSA verificherà firma, applicabilità e prerequisiti, incluso ESU. Non spegnere il computer.',
 'Installazione completata correttamente.',
 'Installazione completata. Riavvia manualmente per terminare.',
 'Il programma di installazione segnala che questo aggiornamento è già installato.',
 'Controlla Winver dopo il riavvio. Non è stato richiesto un riavvio automatico.',
 'Apertura di Windows PowerShell come amministratore. Conferma la richiesta UAC di Windows.',
 'Il computer','Preparazione dei servizi',
 'Il supporto standard di Windows 10 Home/Pro è terminato il 14/10/2025. Gli aggiornamenti successivi richiedono l’’idoneità ESU.',
 'La ricerca controlla la disponibilità per QUESTO computer; non prova quale sia la build pubblicata più recente.',
 'WSUS è configurato; viene usata la fonte gestita. Potrebbe limitare gli aggiornamenti offerti.',
 'È necessario riavviare. Puoi scaricare; l’’installazione attenderà il riavvio.',
 'Download annullato. Ritorno al menu principale.',
 'Dettagli tecnici salvati nel registro.',
 'IMPOSSIBILE COMPLETARE','FINE ESECUZIONE',
 'INVIO  Torna al menu principale',
 'ESC    Esci e chiudi questa finestra',
 'Invio: menu principale | digita ESCI per chiudere',
 'Aggiornamento','Destinazione','Completati','Tipo','Dimensione',
 'Modalità di verifica: nessun file scaricato o installato.',
 'FASE 3 DI 5   |   CONSULTA LE PUBBLICAZIONI UFFICIALI E IL CATALOGO',
 'FASE 4 DI 5   |   SCARICA L’’AGGIORNAMENTO CUMULATIVO E I CHECKPOINT',
 'FASE 5 DI 5   |   INSTALLA L’’AGGIORNAMENTO CUMULATIVO UFFICIALE',
 'Il computer','Preparazione dei servizi',
  'Questa fase può richiedere diversi minuti. Il servizio non segnala l’’avanzamento durante questa richiesta.'
)
'ja' = @(
 'ステップ ',' / 5   |   ','ダウンロードの概要',
 'ダウンロード完了 — 今すぐインストールしますか？',
 '[1] ダウンロードしたパッケージをインストール（再起動なし）',
 '[2] ダウンロードを保存して後でインストール',
 '1 または 2 を入力して Enter キーを押してください',
 '今すぐインストールする場合は 1、後で行う場合は 2 を選択します。',
 'セッション開始','実行モード','管理者','操作',
 '確認のみ（ダウンロードしない）','自動的に検索してダウンロード',
 'Windows のソース','追加ソース',
 'パッケージの処理中は進行率が変わらない場合があります。',
 '適用可能な更新プログラムを検索しています（オプションのプレビューを含む）。',
 'このグループに保留中の更新プログラムはありません。',
 '確認が完了しました。ダウンロードは要求されていません。',
 'ダウンロードを保存しました。インストールは開始していません。',
 'ダウンロードが完了しました。インストール前に PC を再起動してください。パッケージは保存されています。',
 '前の更新には再起動が必要です。他のダウンロードは後で使えるよう保存しました。',
 'インストール中',
 '完了までお待ちください。PC は自動的に再起動しません。',
 'インストールが完了しました。再起動が必要です。他のダウンロードは保存されています。',
 'お使いのバージョン向けに公開された最新の累積更新プログラムを検索しています。',
 'インストール済みのビルドは最新の公開累積更新プログラム以上です。',
 'WUSA が署名、適用可能性、前提条件（ESU を含む）を確認します。PC の電源を切らないでください。',
 'インストールが正常に完了しました。',
 'インストールが完了しました。完了するには手動で再起動してください。',
 'この更新プログラムはすでにインストール済みです。',
 '再起動後に Winver を確認してください。自動再起動は要求されていません。',
 '管理者として Windows PowerShell を開きます。Windows の UAC を確認してください。',
 'このコンピューター','サービスの準備',
 'Windows 10 Home/Pro の通常サポートは 2025/10/14 に終了しました。それ以降の更新には ESU の対象資格が必要です。',
 'この検索はこの PC で利用可能な更新を確認します。公開された最新ビルドを保証するものではありません。',
 'WSUS が設定されています。管理対象のソースを使用します。提供される更新が制限される場合があります。',
 '再起動が保留中です。ダウンロードできますが、インストールは再起動後に行います。',
 'ダウンロードをキャンセルしました。メイン メニューに戻ります。',
 '技術的な詳細をログに保存しました。',
 '完了できません','実行終了',
 'Enter  メイン メニューに戻る',
 'Esc    終了してウィンドウを閉じる',
 'Enter: メニュー | 閉じるには EXIT と入力',
 '更新プログラム','保存先','完了','種類','サイズ',
 '確認のみのモード: ファイルのダウンロードやインストールは行われていません。',
 'ステップ 3 / 5   |   公式リリースとカタログを確認',
 'ステップ 4 / 5   |   累積更新プログラムとチェックポイントをダウンロード',
 'ステップ 5 / 5   |   公式累積更新プログラムをインストール',
 'このコンピューター','サービスの準備',
  'この処理には数分かかる場合があります。この要求中、サービスは進行状況を報告しません。'
)
'ko' = @(
 '단계 ',' / 5   |   ','다운로드 요약',
 '다운로드 완료 — 지금 설치할까요?',
 '[1] 다운로드한 패키지 설치 (다시 시작 안 함)',
 '[2] 다운로드를 저장하고 나중에 설치',
 '1 또는 2를 입력하고 Enter 키를 누르세요',
 '지금 설치하려면 1, 나중에 하려면 2를 선택하세요.',
 '세션 시작','실행 모드','관리자','작업',
 '확인만 수행; 다운로드 안 함','자동으로 검색 및 다운로드',
 'Windows 원본','추가 원본',
 '패키지를 처리하는 동안 진행률이 그대로일 수 있습니다.',
 '선택적 미리 보기를 포함하여 적용 가능한 업데이트를 확인하는 중입니다.',
 '이 그룹에 보류 중인 업데이트가 없습니다.',
 '확인이 완료되었습니다. 다운로드를 요청하지 않았습니다.',
 '다운로드를 저장했습니다. 설치를 시작하지 않았습니다.',
 '다운로드가 완료되었습니다. 설치 전에 컴퓨터를 다시 시작하세요. 패키지는 저장되어 있습니다.',
 '이전 업데이트는 다시 시작해야 합니다. 다른 다운로드는 나중에 설치할 수 있도록 보존했습니다.',
 '설치 진행 중',
 '완료될 때까지 기다리세요. 컴퓨터가 자동으로 다시 시작되지 않습니다.',
 '설치가 완료되었으며 다시 시작해야 합니다. 다른 다운로드는 저장되어 있습니다.',
 '현재 버전에 공개된 최신 누적 업데이트를 확인하는 중입니다.',
 '설치된 빌드가 최신 공개 누적 업데이트와 같거나 더 최신입니다.',
 'WUSA가 서명, 적용 가능성 및 필수 구성 요소(ESU 포함)를 확인합니다. 컴퓨터를 끄지 마세요.',
 '설치가 성공적으로 완료되었습니다.',
 '설치가 완료되었습니다. 마무리하려면 직접 다시 시작하세요.',
 '이 업데이트는 이미 설치되어 있다고 설치 프로그램이 보고했습니다.',
 '다시 시작한 후 Winver를 확인하세요. 자동 다시 시작은 요청되지 않았습니다.',
 '관리자 권한으로 Windows PowerShell을 엽니다. Windows UAC를 확인하세요.',
 '내 컴퓨터','서비스 준비',
 'Windows 10 Home/Pro 일반 지원은 2025-10-14에 종료되었습니다. 이후 업데이트에는 ESU 자격이 필요합니다.',
 '이 검색은 이 컴퓨터에서 사용할 수 있는 항목을 확인하며 최신 공개 빌드를 보장하지 않습니다.',
 'WSUS가 구성되어 관리되는 원본을 사용합니다. 제공되는 업데이트가 제한될 수 있습니다.',
 '다시 시작이 보류 중입니다. 다운로드는 가능하지만 설치는 다시 시작한 후 진행됩니다.',
 '다운로드가 취소되었습니다. 주 메뉴로 돌아갑니다.',
 '기술 세부 정보가 로그에 저장되었습니다.',
 '완료할 수 없음','실행 종료',
 'Enter  주 메뉴로 돌아가기',
 'Esc    종료하고 창 닫기',
 'Enter: 메뉴 | 종료하려면 EXIT 입력',
 '업데이트','저장 위치','완료','유형','크기',
 '확인 전용 모드: 파일을 다운로드하거나 설치하지 않았습니다.',
 '3단계 / 5   |   공식 릴리스 및 카탈로그 확인',
 '4단계 / 5   |   누적 업데이트 및 체크포인트 다운로드',
 '5단계 / 5   |   공식 누적 업데이트 설치',
 '내 컴퓨터','서비스 준비',
  '이 단계는 몇 분 정도 걸릴 수 있습니다. 이 요청 중에는 서비스가 진행률을 보고하지 않습니다.'
)
'zh-CN' = @(
 '阶段 ',' / 5   |   ','下载摘要',
 '下载完成 — 现在安装吗？',
 '[1] 安装已下载的软件包（不重启）',
 '[2] 保留下载内容，以后安装',
 '输入 1 或 2，然后按 Enter',
 '现在安装请输入 1，稍后安装请输入 2。',
 '会话开始时间','运行模式','管理员','操作',
 '仅检查，不下载','自动搜索并下载',
 'Windows 更新源','其他更新源',
 '处理软件包期间，进度百分比可能保持不变。',
 '正在检查适用的更新，包括可选预览版。',
 '此组没有提供待处理的更新。',
 '检查完成。未请求下载。',
 '已保留下载内容。未开始安装。',
 '下载已完成。请先重启电脑再安装。软件包已保留。',
 '上一个更新需要重启。其他下载内容已保留，可稍后安装。',
 '正在安装',
 '请等待完成。电脑不会自动重启。',
 '安装已完成，需要重启。其他下载内容仍已保留。',
 '正在查找适用于当前版本的最新已发布累积更新，包括预览版。',
 '当前已安装版本已达到或超过最新已发布累积更新。',
 'WUSA 将验证签名、适用性和先决条件（包括 ESU）。请勿关闭电脑。',
 '安装程序已成功完成。',
 '安装已完成。请手动重启以完成操作。',
 '安装程序报告此更新已安装。',
 '重启后请检查 Winver。未请求自动重启。',
 '正在以管理员身份打开 Windows PowerShell。请确认 Windows UAC 提示。',
 '你的电脑','准备服务',
 'Windows 10 Home/Pro 常规支持已于 2025-10-14 结束。后续更新需要符合 ESU 资格。',
 '搜索仅检查此电脑可用的更新；无法证明其为最新发布版本。',
 '已配置 WSUS，正在使用受管理的更新源。它可能限制可提供的更新。',
 '有待处理的重启。可以下载更新；安装将在重启后进行。',
 '下载已取消。返回主菜单。',
 '技术详情已保存到日志。',
 '无法完成','执行结束',
 'Enter  返回主菜单',
 'Esc    退出并关闭窗口',
 'Enter：主菜单 | 输入 EXIT 关闭',
 '更新','位置','已完成','类型','大小',
 '仅检查模式：未下载或安装任何文件。',
 '阶段 3 / 5   |   检查官方发布和目录',
 '阶段 4 / 5   |   下载累积更新和检查点',
 '阶段 5 / 5   |   安装官方累积更新',
 '你的电脑','准备服务',
  '此步骤可能需要几分钟。服务在此请求期间不会报告进度。'
)
'ru' = @(
 'ЭТАП ',' ИЗ 5   |   ','СВОДКА ЗАГРУЗОК',
 'ЗАГРУЗКИ ЗАВЕРШЕНЫ — УСТАНОВИТЬ СЕЙЧАС?',
 '[1] Установить загруженные пакеты (без перезагрузки)',
 '[2] Сохранить загрузки и установить позже',
 'Введите 1 или 2 и нажмите Enter',
 'Выберите 1 для установки или 2, чтобы отложить.',
 'Сеанс начат','Режим выполнения','Администратор','Действие',
 'Только проверка; без загрузки','Автоматический поиск и загрузка',
 'Источник Windows','Дополнительный источник',
 'Процент может не меняться во время обработки пакета.',
 'Поиск применимых обновлений, включая необязательные предварительные версии.',
 'Для этой группы не предложено ожидающих обновлений.',
 'Проверка завершена. Загрузка не запрашивалась.',
 'Загрузки сохранены. Установка не запускалась.',
 'Загрузка завершена. Перезагрузите компьютер перед установкой. Пакеты сохранены.',
 'Для предыдущего обновления нужна перезагрузка. Остальные загрузки сохранены на потом.',
 'ВЫПОЛНЯЕТСЯ УСТАНОВКА',
 'Дождитесь завершения. Компьютер не будет перезагружен автоматически.',
 'Установка завершена; требуется перезагрузка. Остальные загрузки сохранены.',
 'Поиск последнего опубликованного накопительного обновления для вашей версии, включая предварительные.',
 'Установленная сборка уже соответствует последнему опубликованному накопительному обновлению или новее.',
 'WUSA проверит подпись, применимость и требования, включая ESU. Не выключайте компьютер.',
 'Установка успешно завершена.',
 'Установка завершена. Перезагрузите компьютер вручную.',
 'Установщик сообщает, что это обновление уже установлено.',
 'Проверьте Winver после перезагрузки. Автоматическая перезагрузка не запрашивалась.',
 'Открытие Windows PowerShell от имени администратора. Подтвердите запрос UAC Windows.',
 'Ваш компьютер','Подготовка служб',
 'Обычная поддержка Windows 10 Home/Pro завершилась 14.10.2025. Для последующих обновлений требуется участие в ESU.',
 'Поиск проверяет доступность обновлений для ЭТОГО компьютера, но не подтверждает самую новую опубликованную сборку.',
 'Настроен WSUS; используется управляемый источник. Он может ограничивать предлагаемые обновления.',
 'Ожидается перезагрузка. Загрузка доступна; установка начнется после перезагрузки.',
 'Загрузка отменена. Возврат в главное меню.',
 'Технические сведения сохранены в журнал.',
 'НЕ УДАЛОСЬ ЗАВЕРШИТЬ','ВЫПОЛНЕНИЕ ЗАВЕРШЕНО',
 'ENTER  Вернуться в главное меню',
 'ESC    Выйти и закрыть окно',
 'Enter: меню | введите ВЫХОД, чтобы закрыть',
 'Обновление','Путь','Завершено','Тип','Размер',
 'Режим проверки: файлы не загружались и не устанавливались.',
 'ЭТАП 3 ИЗ 5   |   ПРОВЕРКА ОФИЦИАЛЬНЫХ ПУБЛИКАЦИЙ И КАТАЛОГА',
 'ЭТАП 4 ИЗ 5   |   ЗАГРУЗКА НАКОПИТЕЛЬНОГО ОБНОВЛЕНИЯ И КОНТРОЛЬНЫХ ТОЧЕК',
 'ЭТАП 5 ИЗ 5   |   УСТАНОВКА ОФИЦИАЛЬНОГО НАКОПИТЕЛЬНОГО ОБНОВЛЕНИЯ',
 'Ваш компьютер','Подготовка служб',
  'Этот этап может занять несколько минут. Во время этого запроса служба не сообщает о ходе выполнения。'
)
}
$script:UpdateUiExtraSources = @(
    'Até ', 'Baixado; exige interação no Windows Update:', 'Catálogo Microsoft Update',
    'Código', 'Consulta/download de atualizações importantes:', 'Diagnóstico',
    'Download concluído em ', 'Download não concluído:', 'Duração',
    'Iniciando download automático de ', 'Não foi possível concluir esta instalação:',
    'Não foi possível gravar os detalhes técnicos no log.', 'Serviço ',
    'Windows Update - pacotes compatíveis com este PC'
)
$script:UpdateUiExtraText = @{
    'pt-BR' = @($script:UpdateUiExtraSources)
    'en' = @('Up to ', 'Downloaded; requires Windows Update interaction:', 'Microsoft Update Catalog', 'Code', 'Important updates search/download:', 'Diagnostics', 'Download completed in ', 'Download incomplete:', 'Duration', 'Starting automatic download of ', 'Could not complete this installation:', 'Could not write technical details to the log.', 'Service ', 'Windows Update packages compatible with this PC')
    'es' = @('Hasta ', 'Descargado; requiere interacción en Windows Update:', 'Catálogo de Microsoft Update', 'Código', 'Consulta/descarga de actualizaciones importantes:', 'Diagnóstico', 'Descarga completada en ', 'Descarga incompleta:', 'Duración', 'Iniciando la descarga automática de ', 'No se pudo completar esta instalación:', 'No se pudieron guardar los detalles técnicos en el registro.', 'Servicio ', 'Windows Update: paquetes compatibles con este equipo')
    'fr' = @('Jusqu’’à ', 'Téléchargé ; nécessite une interaction dans Windows Update :', 'Catalogue Microsoft Update', 'Code', 'Recherche/téléchargement des mises à jour importantes :', 'Diagnostic', 'Téléchargement terminé en ', 'Téléchargement incomplet :', 'Durée', 'Démarrage du téléchargement automatique de ', 'Impossible de terminer cette installation :', 'Impossible d’’enregistrer les détails techniques dans le journal.', 'Service ', 'Windows Update — paquets compatibles avec ce PC')
    'de' = @('Bis zu ', 'Heruntergeladen; Interaktion mit Windows Update erforderlich:', 'Microsoft Update-Katalog', 'Code', 'Suche/Download wichtiger Updates:', 'Diagnose', 'Download abgeschlossen in ', 'Download unvollständig:', 'Dauer', 'Automatischer Download von ', 'Diese Installation konnte nicht abgeschlossen werden:', 'Technische Details konnten nicht im Protokoll gespeichert werden.', 'Dienst ', 'Windows Update – mit diesem PC kompatible Pakete')
    'it' = @('Fino a ', 'Scaricato; richiede interazione con Windows Update:', 'Catalogo Microsoft Update', 'Codice', 'Ricerca/download degli aggiornamenti importanti:', 'Diagnostica', 'Download completato in ', 'Download incompleto:', 'Durata', 'Avvio del download automatico di ', 'Impossibile completare questa installazione:', 'Impossibile salvare i dettagli tecnici nel registro.', 'Servizio ', 'Windows Update - pacchetti compatibili con questo PC')
    'ja' = @('最大 ', 'ダウンロード済み。Windows Update での操作が必要:', 'Microsoft Update カタログ', 'コード', '重要な更新プログラムの検索/ダウンロード:', '診断', 'ダウンロード完了まで ', 'ダウンロード未完了:', '所要時間', '自動ダウンロードを開始: ', 'インストールを完了できませんでした:', '技術的な詳細をログに保存できませんでした。', 'サービス ', 'Windows Update - この PC と互換性のあるパッケージ')
    'ko' = @('최대 ', '다운로드됨; Windows 업데이트에서 추가 작업이 필요합니다:', 'Microsoft 업데이트 카탈로그', '코드', '중요 업데이트 검색/다운로드:', '진단', '다운로드 완료 시간 ', '다운로드 미완료:', '소요 시간', '자동 다운로드 시작: ', '설치를 완료할 수 없습니다:', '기술 세부 정보를 로그에 저장할 수 없습니다.', '서비스 ', 'Windows 업데이트 - 이 PC와 호환되는 패키지')
    'zh-CN' = @('最多 ', '已下载；需要在 Windows 更新中进行交互：', 'Microsoft 更新目录', '代码', '重要更新搜索/下载：', '诊断', '下载完成用时 ', '下载未完成：', '持续时间', '开始自动下载 ', '无法完成此次安装：', '无法将技术详细信息写入日志。', '服务 ', 'Windows 更新 - 与此电脑兼容的程序包')
    'ru' = @('До ', 'Загружено; требуется взаимодействие с Центром обновления Windows:', 'Каталог Microsoft Update', 'Код', 'Поиск/загрузка важных обновлений:', 'Диагностика', 'Загрузка завершена за ', 'Загрузка не завершена:', 'Длительность', 'Начало автоматической загрузки: ', 'Не удалось завершить установку:', 'Не удалось записать технические сведения в журнал.', 'Служба ', 'Центр обновления Windows — пакеты, совместимые с этим ПК')
}
$script:UpdateUiStatusSources = @(
    'BAIXADO', 'NÃO CONCLUÍDO', 'Não iniciado', 'Em andamento', 'Sucesso',
    'Concluído com erros', 'Falhou', 'Cancelado', 'Aguardando informação de progresso',
    'Aguardando confirmação do cancelamento', 'ESC  Cancelar este download e voltar ao menu',
    'ESC cancela o download e volta ao menu.'
)
$script:UpdateUiStatusText = @{
    'pt-BR' = @($script:UpdateUiStatusSources)
    'en' = @('DOWNLOADED','NOT COMPLETED','Not started','In progress','Success','Completed with errors','Failed','Cancelled','Waiting for progress information','Waiting for cancellation confirmation','ESC  Cancel this download and return to the menu','ESC cancels the download and returns to the menu.')
    'es' = @('DESCARGADO','NO COMPLETADO','No iniciado','En curso','Correcto','Completado con errores','Error','Cancelado','Esperando información del progreso','Esperando confirmación de cancelación','ESC  Cancelar esta descarga y volver al menú','ESC cancela la descarga y vuelve al menú.')
    'fr' = @('TÉLÉCHARGÉ','NON TERMINÉ','Non démarré','En cours','Réussi','Terminé avec des erreurs','Échec','Annulé','En attente des informations de progression','En attente de confirmation de l’’annulation','ÉCHAP  Annuler le téléchargement et revenir au menu','ÉCHAP annule le téléchargement et revient au menu.')
    'de' = @('HERUNTERGELADEN','NICHT ABGESCHLOSSEN','Nicht gestartet','In Bearbeitung','Erfolgreich','Mit Fehlern abgeschlossen','Fehlgeschlagen','Abgebrochen','Warten auf Fortschrittsinformationen','Warten auf die Abbruchbestätigung','ESC  Download abbrechen und zum Menü zurückkehren','ESC bricht den Download ab und kehrt zum Menü zurück.')
    'it' = @('SCARICATO','NON COMPLETATO','Non avviato','In corso','Riuscito','Completato con errori','Non riuscito','Annullato','In attesa delle informazioni sull’’avanzamento','In attesa della conferma di annullamento','ESC  Annulla il download e torna al menu','ESC annulla il download e torna al menu.')
    'ja' = @('ダウンロード済み','未完了','未開始','進行中','成功','エラーありで完了','失敗','キャンセル','進行状況を待っています','キャンセルの確認を待っています','ESC  ダウンロードをキャンセルしてメニューに戻る','ESC でダウンロードをキャンセルし、メニューに戻ります。')
    'ko' = @('다운로드됨','미완료','시작되지 않음','진행 중','성공','오류와 함께 완료','실패','취소됨','진행 정보 대기 중','취소 확인 대기 중','ESC  다운로드를 취소하고 메뉴로 돌아가기','ESC를 누르면 다운로드를 취소하고 메뉴로 돌아갑니다.')
    'zh-CN' = @('已下载','未完成','未开始','进行中','成功','完成但有错误','失败','已取消','正在等待进度信息','正在等待取消确认','ESC  取消下载并返回菜单','按 ESC 取消下载并返回菜单。')
    'ru' = @('ЗАГРУЖЕНО','НЕ ЗАВЕРШЕНО','Не начато','Выполняется','Успешно','Завершено с ошибками','Ошибка','Отменено','Ожидание сведений о ходе выполнения','Ожидание подтверждения отмены','ESC  Отменить загрузку и вернуться в меню','ESC отменяет загрузку и возвращает в меню.')
}
$script:UpdateUiErrorSources = @(
    'A busca demorou mais de 15 minutos e foi cancelada. Tente novamente após concluir outras atualizações.',
    'A consulta do Windows Update não terminou integralmente.',
    'Fonte WSUS configurada. Use -Fonte WindowsUpdate para seguir a fonte da organização.',
    'O catálogo não retornou links MSU reconhecidos. Nenhum instalador será executado.',
    'Nome de pacote não reconhecido.',
    'O Windows já está instalando outra atualização. Aguarde sua conclusão.',
    'Não foi possível identificar a cumulativa no histórico oficial. A página pode ter mudado. Use -Fonte WindowsUpdate.',
    'Já existe outra instância deste script em execução.',
    'Download cancelado pelo usuário.',
    'Consulta/download do Windows:'
)
$script:UpdateUiErrorText = @{
    'pt-BR' = @($script:UpdateUiErrorSources)
    'en' = @('The search timed out after 15 minutes and was cancelled. Try again after other updates finish.','The Windows Update search did not complete fully.','WSUS is configured. Use -Fonte WindowsUpdate to follow your organization source.','The catalog returned no recognized MSU links. No installer will be run.','Unrecognized package name.','Windows is installing another update. Wait for it to finish.','Could not identify the cumulative update in official history. The page may have changed. Use -Fonte WindowsUpdate.','Another instance of this script is already running.','Download cancelled by the user.','Windows update search/download:')
    'es' = @('La búsqueda superó los 15 minutos y se canceló. Vuelva a intentarlo cuando terminen otras actualizaciones.','La búsqueda de Windows Update no finalizó por completo.','WSUS está configurado. Use -Fuente WindowsUpdate para seguir el origen de su organización.','El catálogo no devolvió enlaces MSU reconocidos. No se ejecutará ningún instalador.','Nombre de paquete no reconocido.','Windows está instalando otra actualización. Espere a que termine.','No se pudo identificar la actualización acumulativa en el historial oficial. La página pudo cambiar. Use -Fuente WindowsUpdate.','Ya hay otra instancia de este script en ejecución.','El usuario canceló la descarga.','Búsqueda/descarga de Windows Update:')
    'fr' = @('La recherche a dépassé 15 minutes et a été annulée. Réessayez après la fin des autres mises à jour.','La recherche Windows Update ne s’’est pas terminée complètement.','WSUS est configuré. Utilisez -Fonte WindowsUpdate pour suivre la source de votre organisation.','Le catalogue n’’a renvoyé aucun lien MSU reconnu. Aucun programme ne sera exécuté.','Nom de paquet non reconnu.','Windows installe une autre mise à jour. Attendez la fin de son installation.','Impossible d’’identifier la mise à jour cumulative dans l’’historique officiel. La page a peut-être changé. Utilisez -Fonte WindowsUpdate.','Une autre instance de ce script est déjà en cours.','Téléchargement annulé par l’’utilisateur.','Recherche/téléchargement Windows Update :')
    'de' = @('Die Suche wurde nach 15 Minuten abgebrochen. Versuchen Sie es erneut, wenn andere Updates abgeschlossen sind.','Die Windows Update-Suche wurde nicht vollständig abgeschlossen.','WSUS ist konfiguriert. Verwenden Sie -Fonte WindowsUpdate für die Quelle Ihrer Organisation.','Der Katalog lieferte keine erkannten MSU-Links. Es wird kein Installationsprogramm ausgeführt.','Paketname nicht erkannt.','Windows installiert gerade ein anderes Update. Warten Sie, bis es abgeschlossen ist.','Das kumulative Update wurde im offiziellen Verlauf nicht gefunden. Die Seite könnte geändert worden sein. Verwenden Sie -Fonte WindowsUpdate.','Eine weitere Instanz dieses Skripts läuft bereits.','Download vom Benutzer abgebrochen.','Windows Update-Suche/Download:')
    'it' = @('La ricerca è stata annullata dopo 15 minuti. Riprova al termine degli altri aggiornamenti.','La ricerca di Windows Update non è terminata completamente.','WSUS è configurato. Usa -Fonte WindowsUpdate per seguire la fonte dell’’organizzazione.','Il catalogo non ha restituito collegamenti MSU riconosciuti. Non verrà eseguito alcun programma di installazione.','Nome del pacchetto non riconosciuto.','Windows sta installando un altro aggiornamento. Attendi il completamento.','Impossibile identificare l’’aggiornamento cumulativo nella cronologia ufficiale. La pagina potrebbe essere cambiata. Usa -Fonte WindowsUpdate.','Un’’altra istanza dello script è già in esecuzione.','Download annullato dall’’utente.','Ricerca/download di Windows Update:')
    'ja' = @('検索は15分を超えたためキャンセルされました。他の更新が完了してから再試行してください。','Windows Update の検索が完了しませんでした。','WSUS が設定されています。組織の更新元を使うには -Fonte WindowsUpdate を指定してください。','カタログに認識可能な MSU リンクがありません。インストーラーは実行されません。','認識できないパッケージ名です。','Windows は別の更新プログラムをインストール中です。完了までお待ちください。','公式履歴から累積更新を特定できません。ページが変更された可能性があります。-Fonte WindowsUpdate を使用してください。','このスクリプトはすでに別のインスタンスで実行されています。','ユーザーがダウンロードをキャンセルしました。','Windows Update の検索/ダウンロード:')
    'ko' = @('검색이 15분을 초과하여 취소되었습니다. 다른 업데이트가 끝난 뒤 다시 시도하세요.','Windows 업데이트 검색이 완료되지 않았습니다.','WSUS가 구성되어 있습니다. 조직의 업데이트 원본을 사용하려면 -Fonte WindowsUpdate를 지정하세요.','카탈로그에서 인식 가능한 MSU 링크를 찾지 못했습니다. 설치 프로그램을 실행하지 않습니다.','인식할 수 없는 패키지 이름입니다.','Windows가 다른 업데이트를 설치 중입니다. 완료될 때까지 기다리세요.','공식 기록에서 누적 업데이트를 확인할 수 없습니다. 페이지가 변경되었을 수 있습니다. -Fonte WindowsUpdate를 사용하세요.','이 스크립트의 다른 인스턴스가 이미 실행 중입니다.','사용자가 다운로드를 취소했습니다.','Windows 업데이트 검색/다운로드:')
    'zh-CN' = @('搜索超过 15 分钟后已取消。请在其他更新完成后重试。','Windows 更新搜索未能完整完成。','已配置 WSUS。请使用 -Fonte WindowsUpdate 以遵循组织的更新源。','目录未返回可识别的 MSU 链接。不会运行安装程序。','无法识别的程序包名称。','Windows 正在安装其他更新。请等待完成。','无法在官方历史记录中识别累积更新。页面可能已更改。请使用 -Fonte WindowsUpdate。','此脚本的另一个实例已在运行。','用户已取消下载。','Windows 更新搜索/下载：')
    'ru' = @('Поиск отменен через 15 минут. Повторите попытку после завершения других обновлений.','Поиск Центра обновления Windows завершился не полностью.','Настроен WSUS. Используйте -Fonte WindowsUpdate для источника организации.','Каталог не вернул распознанных ссылок MSU. Установщик не будет запущен.','Неизвестное имя пакета.','Windows устанавливает другое обновление. Дождитесь завершения.','Не удалось найти накопительное обновление в официальной истории. Страница могла измениться. Используйте -Fonte WindowsUpdate.','Другой экземпляр этого сценария уже запущен.','Загрузка отменена пользователем.','Поиск/загрузка Центра обновления Windows:')
}
$script:UpdateUiInfoSources = @(
    'Baixando: ', 'Pacotes salvos: ', 'Winver antes: ', 'Sistema detectado: ',
    '; arquitetura: ', 'Publicada: ', ' | Build ', ' | Instalada: ',
    'Winver agora: ', ' segundos', 'Fim'
)
$script:UpdateUiInfoText = @{
    'pt-BR' = @($script:UpdateUiInfoSources)
    'en' = @('Downloading: ', 'Packages saved: ', 'Winver before: ', 'Detected system: ', '; architecture: ', 'Published: ', ' | Build ', ' | Installed: ', 'Winver now: ', ' seconds', 'End')
    'es' = @('Descargando: ', 'Paquetes guardados: ', 'Winver antes: ', 'Sistema detectado: ', '; arquitectura: ', 'Publicada: ', ' | Compilación ', ' | Instalada: ', 'Winver ahora: ', ' segundos', 'Fin')
    'fr' = @('Téléchargement : ', 'Paquets enregistrés : ', 'Winver avant : ', 'Système détecté : ', ' ; architecture : ', 'Publiée : ', ' | Build ', ' | Installée : ', 'Winver actuel : ', ' secondes', 'Fin')
    'de' = @('Wird heruntergeladen: ', 'Gespeicherte Pakete: ', 'Winver vorher: ', 'Erkanntes System: ', '; Architektur: ', 'Veröffentlicht: ', ' | Build ', ' | Installiert: ', 'Winver aktuell: ', ' Sekunden', 'Ende')
    'it' = @('Download in corso: ', 'Pacchetti salvati: ', 'Winver prima: ', 'Sistema rilevato: ', '; architettura: ', 'Pubblicata: ', ' | Build ', ' | Installata: ', 'Winver ora: ', ' secondi', 'Fine')
    'ja' = @('ダウンロード中: ', '保存したパッケージ: ', '実行前の Winver: ', '検出されたシステム: ', '、アーキテクチャ: ', '公開済み: ', ' | ビルド ', ' | インストール済み: ', '現在の Winver: ', ' 秒', '終了')
    'ko' = @('다운로드 중: ', '저장된 패키지: ', '이전 Winver: ', '감지된 시스템: ', '; 아키텍처: ', '게시됨: ', ' | 빌드 ', ' | 설치됨: ', '현재 Winver: ', '초', '종료')
    'zh-CN' = @('正在下载：', '已保存的程序包：', '更新前 Winver：', '检测到的系统：', '；体系结构：', '发布日期：', ' | 版本 ', ' | 已安装：', '当前 Winver：', ' 秒', '结束')
    'ru' = @('Загрузка: ', 'Сохраненные пакеты: ', 'Winver до обновления: ', 'Обнаруженная система: ', '; архитектура: ', 'Опубликовано: ', ' | Сборка ', ' | Установлено: ', 'Текущий Winver: ', ' сек.', 'Конец')
}
$script:UpdateUiCriticalSources = @(
    'Download interrompido: ', 'Reinicie antes de instalar os pacotes baixados.',
    'Arquitetura não reconhecida: ', 'Catálogo retornou ',
    ' pacotes inequívocos. Nenhum será escolhido por tentativa. Consulte: ',
    'Link de download fora dos servidores esperados da Microsoft.',
    'Pacote alvo ambíguo. Arquivos preservados em ', 'WUSA retornou ',
    'Confira ESU, aplicabilidade e checkpoints. Pacotes: ',
    'Salve o conteúdo como AtualizarWindows.ps1 antes de executar.',
    'Use este script no Windows 10 ou Windows 11 cliente.',
    ' desativado. Revise a configuração com o administrador; o script não modifica políticas.'
)
$script:UpdateUiCriticalText = @{
    'pt-BR' = @($script:UpdateUiCriticalSources)
    'en' = @('Download interrupted: ', 'Restart before installing the downloaded packages.', 'Unrecognized architecture: ', 'Catalog returned ', ' unambiguous packages. None will be selected by guessing. See: ', 'Download link is outside Microsoft expected servers.', 'Target package is ambiguous. Files were preserved in ', 'WUSA returned ', 'Check ESU, applicability, and checkpoints. Packages: ', 'Save this content as AtualizarWindows.ps1 before running.', 'Use this script on Windows 10 or Windows 11 client editions.', ' is disabled. Review the setting with your administrator; this script does not change policies.')
    'es' = @('Descarga interrumpida: ', 'Reinicie antes de instalar los paquetes descargados.', 'Arquitectura no reconocida: ', 'El catálogo devolvió ', ' paquetes inequívocos. No se elegirá ninguno por tanteo. Consulte: ', 'El enlace de descarga no pertenece a los servidores esperados de Microsoft.', 'El paquete de destino es ambiguo. Los archivos se conservaron en ', 'WUSA devolvió ', 'Compruebe ESU, aplicabilidad y puntos de control. Paquetes: ', 'Guarde este contenido como AtualizarWindows.ps1 antes de ejecutarlo.', 'Use este script en las ediciones cliente de Windows 10 o Windows 11.', ' está deshabilitado. Revise la configuración con su administrador; el script no modifica las directivas.')
    'fr' = @('Téléchargement interrompu : ', 'Redémarrez avant d’’installer les paquets téléchargés.', 'Architecture non reconnue : ', 'Le catalogue a renvoyé ', ' paquets sans ambiguïté. Aucun ne sera choisi au hasard. Consultez : ', 'Le lien de téléchargement ne correspond pas aux serveurs Microsoft attendus.', 'Le paquet cible est ambigu. Les fichiers ont été conservés dans ', 'WUSA a renvoyé ', 'Vérifiez ESU, l’’applicabilité et les points de contrôle. Paquets : ', 'Enregistrez ce contenu sous AtualizarWindows.ps1 avant de l’’exécuter.', 'Utilisez ce script sur les éditions clientes de Windows 10 ou Windows 11.', ' est désactivé. Vérifiez la configuration avec votre administrateur ; le script ne modifie pas les stratégies.')
    'de' = @('Download unterbrochen: ', 'Starten Sie den Computer neu, bevor Sie die heruntergeladenen Pakete installieren.', 'Nicht erkannte Architektur: ', 'Der Katalog lieferte ', ' eindeutige Pakete. Es wird nichts durch Raten ausgewählt. Siehe: ', 'Der Downloadlink gehört nicht zu den erwarteten Microsoft-Servern.', 'Das Zielpaket ist nicht eindeutig. Dateien wurden gespeichert unter ', 'WUSA meldete ', 'Prüfen Sie ESU, Anwendbarkeit und Checkpoints. Pakete: ', 'Speichern Sie diesen Inhalt vor der Ausführung als AtualizarWindows.ps1.', 'Verwenden Sie dieses Skript mit den Client-Editionen von Windows 10 oder Windows 11.', ' ist deaktiviert. Prüfen Sie die Einstellung mit Ihrem Administrator; das Skript ändert keine Richtlinien.')
    'it' = @('Download interrotto: ', 'Riavvia prima di installare i pacchetti scaricati.', 'Architettura non riconosciuta: ', 'Il catalogo ha restituito ', ' pacchetti non ambigui. Non verrà scelto nulla per tentativi. Consulta: ', 'Il collegamento non appartiene ai server Microsoft previsti.', 'Il pacchetto di destinazione è ambiguo. I file sono stati conservati in ', 'WUSA ha restituito ', 'Controlla ESU, applicabilità e checkpoint. Pacchetti: ', 'Salva questo contenuto come AtualizarWindows.ps1 prima di eseguirlo.', 'Usa questo script nelle edizioni client di Windows 10 o Windows 11.', ' è disabilitato. Controlla l’’impostazione con l’’amministratore; lo script non modifica i criteri.')
    'ja' = @('ダウンロードが中断されました: ', 'ダウンロードしたパッケージをインストールする前に再起動してください。', '認識できないアーキテクチャ: ', 'カタログから ', ' 件の一意なパッケージが返されました。推測で選択しません。参照先: ', 'ダウンロードリンクが想定される Microsoft サーバーのものではありません。', '対象パッケージを特定できません。ファイルは次に保存されています: ', 'WUSA の戻り値: ', 'ESU、適用条件、チェックポイントを確認してください。パッケージ: ', '実行前にこの内容を AtualizarWindows.ps1 として保存してください。', 'Windows 10 または Windows 11 のクライアント版で使用してください。', ' は無効です。管理者に設定を確認してください。このスクリプトはポリシーを変更しません。')
    'ko' = @('다운로드 중단: ', '다운로드한 패키지를 설치하기 전에 다시 시작하세요.', '인식할 수 없는 아키텍처: ', '카탈로그에서 ', '개의 고유 패키지를 반환했습니다. 추측하여 선택하지 않습니다. 참조: ', '다운로드 링크가 Microsoft의 예상 서버에 속하지 않습니다.', '대상 패키지가 모호합니다. 파일을 다음 위치에 보존했습니다: ', 'WUSA 반환 코드: ', 'ESU, 적용 가능성 및 체크포인트를 확인하세요. 패키지: ', '실행 전에 이 내용을 AtualizarWindows.ps1로 저장하세요.', 'Windows 10 또는 Windows 11 클라이언트 버전에서 사용하세요.', ' 사용 안 함 상태입니다. 관리자에게 설정을 확인하세요. 이 스크립트는 정책을 변경하지 않습니다.')
    'zh-CN' = @('下载已中断：', '安装已下载的程序包前，请先重新启动。', '无法识别的体系结构：', '目录返回了 ', ' 个明确的程序包。不会猜测选择。请参阅：', '下载链接不属于预期的 Microsoft 服务器。', '目标程序包不明确。文件已保存在：', 'WUSA 返回：', '请检查 ESU、适用性和检查点。程序包：', '运行前请将此内容保存为 AtualizarWindows.ps1。', '请在 Windows 10 或 Windows 11 客户端版本上使用此脚本。', ' 已禁用。请与管理员确认设置；此脚本不会更改策略。')
    'ru' = @('Загрузка прервана: ', 'Перезагрузите компьютер перед установкой загруженных пакетов.', 'Неизвестная архитектура: ', 'Каталог вернул ', ' однозначных пакетов. Выбор наугад запрещен. См.: ', 'Ссылка для загрузки не относится к ожидаемым серверам Microsoft.', 'Целевой пакет неоднозначен. Файлы сохранены в ', 'WUSA вернул код ', 'Проверьте ESU, применимость и контрольные точки. Пакеты: ', 'Перед запуском сохраните этот файл как AtualizarWindows.ps1.', 'Используйте сценарий в клиентских редакциях Windows 10 или Windows 11.', ' отключена. Обсудите настройку с администратором; сценарий не меняет политики.')
}
$script:UpdateUiProgressSources = @('BUSCANDO','BAIXANDO','INSTALANDO','Buscando','Baixando','Instalando','Aguardando Windows Update','Aguarde o instalador')
$script:UpdateUiProgressText = @{
    'pt-BR'=@($script:UpdateUiProgressSources)
    'en'=@('SEARCHING','DOWNLOADING','INSTALLING','Searching','Downloading','Installing','Waiting for Windows Update','Wait for the installer')
    'es'=@('BUSCANDO','DESCARGANDO','INSTALANDO','Buscando','Descargando','Instalando','Esperando a Windows Update','Espere al instalador')
    'fr'=@('RECHERCHE','TÉLÉCHARGEMENT','INSTALLATION','Recherche','Téléchargement','Installation','En attente de Windows Update','Attendez le programme d’’installation')
    'de'=@('SUCHEN','HERUNTERLADEN','INSTALLIEREN','Suche','Wird heruntergeladen','Wird installiert','Warten auf Windows Update','Auf das Installationsprogramm warten')
    'it'=@('RICERCA','DOWNLOAD','INSTALLAZIONE','Ricerca','Download in corso','Installazione in corso','In attesa di Windows Update','Attendi il programma di installazione')
    'ja'=@('検索中','ダウンロード中','インストール中','検索中','ダウンロード中','インストール中','Windows Update を待っています','インストーラーをお待ちください')
    'ko'=@('검색 중','다운로드 중','설치 중','검색 중','다운로드 중','설치 중','Windows 업데이트 대기 중','설치 프로그램을 기다리세요')
    'zh-CN'=@('正在搜索','正在下载','正在安装','正在搜索','正在下载','正在安装','正在等待 Windows 更新','请等待安装程序')
    'ru'=@('ПОИСК','ЗАГРУЗКА','УСТАНОВКА','Поиск','Загрузка','Установка','Ожидание Центра обновления Windows','Дождитесь запуска установщика')
}
function Convert-UpdateUiText([string]$Text) {
    $translations = $script:UpdateUiText[$script:AppLanguage]
    if ($null -eq $translations) { return $Text }
    for ($i = 0; $i -lt [Math]::Min($script:UpdateUiSources.Count, $translations.Count); $i++) {
        if ($Text.Contains($script:UpdateUiSources[$i])) {
            $Text = $Text.Replace($script:UpdateUiSources[$i], [string]$translations[$i])
        }
    }
    $extraTranslations = $script:UpdateUiExtraText[$script:AppLanguage]
    for ($i = 0; $i -lt [Math]::Min($script:UpdateUiExtraSources.Count, $extraTranslations.Count); $i++) {
        if ($Text.Contains($script:UpdateUiExtraSources[$i])) {
            $Text = $Text.Replace($script:UpdateUiExtraSources[$i], [string]$extraTranslations[$i])
        }
    }
    $statusTranslations = $script:UpdateUiStatusText[$script:AppLanguage]
    for ($i = 0; $i -lt [Math]::Min($script:UpdateUiStatusSources.Count, $statusTranslations.Count); $i++) {
        if ($Text.Contains($script:UpdateUiStatusSources[$i])) {
            $Text = $Text.Replace($script:UpdateUiStatusSources[$i], [string]$statusTranslations[$i])
        }
    }
    $errorTranslations = $script:UpdateUiErrorText[$script:AppLanguage]
    for ($i = 0; $i -lt [Math]::Min($script:UpdateUiErrorSources.Count, $errorTranslations.Count); $i++) {
        if ($Text.Contains($script:UpdateUiErrorSources[$i])) {
            $Text = $Text.Replace($script:UpdateUiErrorSources[$i], [string]$errorTranslations[$i])
        }
    }
    $infoTranslations = $script:UpdateUiInfoText[$script:AppLanguage]
    for ($i = 0; $i -lt [Math]::Min($script:UpdateUiInfoSources.Count, $infoTranslations.Count); $i++) {
        if ($Text.Contains($script:UpdateUiInfoSources[$i])) {
            $Text = $Text.Replace($script:UpdateUiInfoSources[$i], [string]$infoTranslations[$i])
        }
    }
    $criticalTranslations = $script:UpdateUiCriticalText[$script:AppLanguage]
    for ($i = 0; $i -lt [Math]::Min($script:UpdateUiCriticalSources.Count, $criticalTranslations.Count); $i++) {
        if ($Text.Contains($script:UpdateUiCriticalSources[$i])) {
            $Text = $Text.Replace($script:UpdateUiCriticalSources[$i], [string]$criticalTranslations[$i])
        }
    }
    $progressTranslations = $script:UpdateUiProgressText[$script:AppLanguage]
    for ($i = 0; $i -lt [Math]::Min($script:UpdateUiProgressSources.Count, $progressTranslations.Count); $i++) {
        if ($Text.Contains($script:UpdateUiProgressSources[$i])) {
            $Text = $Text.Replace($script:UpdateUiProgressSources[$i], [string]$progressTranslations[$i])
        }
    }
    return $Text
}
function Write-Host {
    [CmdletBinding()]
    param(
        [Parameter(Position=0, ValueFromPipeline=$true)]
        [object[]]$Object,
        [string]$Separator = ' ',
        [switch]$NoNewline,
        [ConsoleColor]$ForegroundColor,
        [ConsoleColor]$BackgroundColor
    )
    process {
        $rendered = @()
        foreach ($item in $Object) {
            if ($item -is [string]) { $rendered += (Convert-UpdateUiText $item) }
            else { $rendered += $item }
        }
        $call = @{ Object=$rendered; Separator=$Separator }
        if ($PSBoundParameters.ContainsKey('NoNewline')) { $call.NoNewline=$true }
        if ($PSBoundParameters.ContainsKey('ForegroundColor')) { $call.ForegroundColor=$ForegroundColor }
        if ($PSBoundParameters.ContainsKey('BackgroundColor')) { $call.BackgroundColor=$BackgroundColor }
        Microsoft.PowerShell.Utility\Write-Host @call
    }
}
function Read-Host {
    [CmdletBinding()]
    param([Parameter(Position=0)][string]$Prompt = 'Input', [switch]$AsSecureString)
    $localizedPrompt = Convert-UpdateUiText $Prompt
    if ($AsSecureString) { Microsoft.PowerShell.Utility\Read-Host -Prompt $localizedPrompt -AsSecureString }
    else { Microsoft.PowerShell.Utility\Read-Host -Prompt $localizedPrompt }
}

# Seleciona as traduções correspondentes ao idioma detectado no cabeçalho.
$script:UpdateMenu = $script:UpdateMenuText[$script:AppLanguage]

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$transcriptStarted = $false
$delegated = $false
$mutex = $null
$ownsMutex = $false
$log = $null
$sessionStart = Get-Date

# Apresentação: compatível com o console clássico e Windows Terminal.
function Get-LayoutWidth {
    $width = 92
    try { $width = [Math]::Max(36, [Math]::Min(92, $Host.UI.RawUI.WindowSize.Width - 4)) } catch {}
    return $width
}
function Show-Rule {
    Write-Host ('-' * (Get-LayoutWidth)) -ForegroundColor DarkGray
}
function Show-Field([string]$Label, [string]$Value, [string]$Color = 'Gray') {
    $prefix = '{0,-16} : ' -f $Label
    $room = [Math]::Max(12, (Get-LayoutWidth) - $prefix.Length)
    $remaining = ([string]$Value -replace '\s+', ' ').Trim()
    $first = $true
    do {
        $take = [Math]::Min($room, $remaining.Length)
        if ($remaining.Length -gt $room) {
            $space = $remaining.LastIndexOf(' ', $take - 1, $take)
            if ($space -gt 0) { $take = $space }
        }
        if ($first) { Write-Host $prefix -NoNewline -ForegroundColor DarkGray; $first = $false }
        else { Write-Host (' ' * $prefix.Length) -NoNewline }
        Write-Host $remaining.Substring(0, $take) -ForegroundColor $Color
        $remaining = $remaining.Substring($take).TrimStart()
    } while ($remaining.Length -gt 0)
}

function Show-MenuOption([string]$Number, [string]$Title, [string]$Description) {
    Write-Host ('[{0}] ' -f $Number) -NoNewline -ForegroundColor Green
    Write-Host $Title -ForegroundColor White
    # Descrição alinhada a esquerda, separada do número selecionável.
    $text = $Description
    $width = Get-LayoutWidth
    while ($text.Length -gt $width) {
        $cut = $text.LastIndexOf(' ', $width - 1, $width)
        if ($cut -le 0) { $cut = $width }
        Write-Host $text.Substring(0, $cut) -ForegroundColor Gray
        $text = $text.Substring($cut).TrimStart()
    }
    Write-Host $text -ForegroundColor Gray
    Write-Host ''
}

function Say([string]$Text, [string]$Kind = 'INFO') {
    if ($Kind -eq 'INFO') {
        if ($Text -match '^(IGNORADA|Histórico oficial|O filtro)') { $Kind = 'DETALHE' }
        elseif ($Text -match 'Falhou|Concluído com erros|Cancelado|^ERRO') { $Kind = 'ERRO' }
        elseif ($Text -match 'ESU|NÃO significa|não comprova|WSUS|REINICIALIZAÇÃO|não garante') { $Kind = 'AVISO' }
        elseif ($Text -match 'Sucesso|^SELECIONADA') { $Kind = 'OK' }
    }
    $color = switch ($Kind) {
        'OK' { 'Green' }; 'AVISO' { 'Yellow' }; 'ERRO' { 'Red' }
        'DETALHE' { 'DarkGray' }; 'AGUARDE' { 'Cyan' }; default { 'Gray' }
    }
    $width = Get-LayoutWidth
    $prefix = '{0}  {1,-7} ' -f (Get-Date -Format 'HH:mm:ss'), $Kind
    $limit = [Math]::Max(16, $width - $prefix.Length)
    $lines = New-Object 'System.Collections.Generic.List[string]'
    $line = ''
    foreach ($word in ($Text -split '\s+')) {
        if ($line.Length -gt 0 -and ($line.Length + $word.Length + 1) -gt $limit) {
            $lines.Add($line); $line = ''
        }
        if ($line.Length -gt 0) { $line += ' ' }
        $line += $word
    }
    if ($line.Length -gt 0) { $lines.Add($line) }
    $first = $true
    foreach ($part in $lines) {
        if ($first) {
            Write-Host $prefix -NoNewline -ForegroundColor $color
            $first = $false
        } else { Write-Host (' ' * $prefix.Length) -NoNewline }
        Write-Host $part -ForegroundColor $color
    }
}
function Show-Stage([int]$Number, [string]$Title) {
    Write-Host ''
    Write-Host ('ETAPA {0} DE 5   |   {1}' -f $Number, $Title.ToUpper()) -ForegroundColor Cyan
    Show-Rule
}
function Show-Wait([string]$Activity) {
    Say "$Activity. Aguardando resposta do Windows Update..." 'AGUARDE'
    Say 'Esta etapa pode levar vários minutos. O serviço não informa percentual nesta chamada.' 'DETALHE'

}
function End-Wait {
    # Sem painel de progresso sobreposto.
}
function Get-Winver {
    $r = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
    '{0} | {1} | Build {2}.{3}' -f (Get-CimInstance Win32_OperatingSystem).Caption, $r.DisplayVersion, $r.CurrentBuildNumber, $r.UBR
}
function HexCode($Value) {
    '0x{0:X8}' -f ([long]$Value -band 4294967295L)
}
function ResultName($Code) {
    switch ([int]$Code) {
        0 { 'Não iniciado' }; 1 { 'Em andamento' }; 2 { 'Sucesso' }
        3 { 'Concluído com erros' }; 4 { 'Falhou' }; 5 { 'Cancelado' }
        default { "Código $Code" }
    }
}

# Catalogo: HTML público, sem executar JavaScript recebido.
function Get-PageText([string]$Html) {
    [Net.WebUtility]::HtmlDecode(($Html -replace '<[^>]+>', ' ')) -replace '\s+', ' '
}
function Receive-Package([string]$Url, [string]$Destination, [string]$Label) {
    $job = $null
    $finished = $false
    $clock = [Diagnostics.Stopwatch]::StartNew()
    $lastBytes = 0.0
    $lastTime = 0.0
    $lastOutput = -10.0
    $inline = $Host.Name -eq 'ConsoleHost'
    try { if ([Console]::IsOutputRedirected) { $inline = $false } } catch { $inline = $false }
    $canReadKeys = $Host.Name -eq 'ConsoleHost'
    try { if ([Console]::IsInputRedirected) { $canReadKeys = $false } } catch { $canReadKeys = $false }
    if ($canReadKeys) { Write-Host 'ESC  Cancelar este download e voltar ao menu' -ForegroundColor Yellow }
    try {
        $job = Start-BitsTransfer -Source $Url -Destination $Destination -DisplayName $Label -Description 'Cumulativa oficial do Windows' -Asynchronous
        while ($true) {
            if ($canReadKeys) {
                while ([Console]::KeyAvailable) {
                    $pressed = [Console]::ReadKey($true)
                    if ($pressed.Key -eq [ConsoleKey]::Escape) {
                        $script:downloadCancelled = $true
                        throw [OperationCanceledException]::new('Download cancelado pelo usuário.')
                    }
                }
            }
            $job = Get-BitsTransfer -JobId $job.JobId
            $state = [string]$job.JobState
            $bytes = [double]$job.BytesTransferred
            $total = [double]$job.BytesTotal
            $now = $clock.Elapsed.TotalSeconds
            $speed = [Math]::Max(0, ($bytes - $lastBytes) / [Math]::Max(0.001, $now - $lastTime) / 1MB)
            $known = $total -gt 0 -and $total -lt [double][uint64]::MaxValue
            $percent = '--.-%'
            if ($known) { $percent = '{0,5:N1}%' -f ([Math]::Min(100, 100 * $bytes / $total)) }
            $status = switch ($state) {
                'Connecting' { 'Conectando' }; 'Queued' { 'Na fila' }
                'TransientError' { 'Reconectando' }; 'Transferred' { 'Recebido' }
                'Transferring' { 'Baixando' }; default { $state }
            }
            $size = '{0:N1} MB' -f ($bytes / 1MB)
            if ($known) { $size = '{0:N1} / {1:N1} MB' -f ($bytes / 1MB), ($total / 1MB) }
            $line = '{0}  |  {1}  |  {2:N1} MB/s  |  {3}' -f $percent, $size, $speed, $status
            if ($inline) {
                $width = 78
                try { $width = [Math]::Max(20, [Math]::Min(100, $Host.UI.RawUI.WindowSize.Width - 1)) } catch {}
                if ($line.Length -gt $width) { $line = $line.Substring(0, $width) }
                Write-Host ("`r" + $line.PadRight($width)) -NoNewline -ForegroundColor Cyan
            } elseif (($now - $lastOutput) -ge 5 -or $state -eq 'Transferred') {
                Write-Host $line -ForegroundColor Cyan
                $lastOutput = $now
            }
            $lastBytes = $bytes
            $lastTime = $now
            if ($state -eq 'Transferred') {
                Complete-BitsTransfer -BitsJob $job
                $finished = $true
                break
            }
            if ($state -in @('Error', 'Cancelled', 'Suspended', 'Acknowledged')) {
                throw ('Download interrompido: {0}. {1}' -f $state, $job.ErrorDescription)
            }
            Start-Sleep -Milliseconds 500
        }
    } finally {
        $clock.Stop()
        if ($inline) { Write-Host '' }
        if ($null -ne $job -and -not $finished) {
            Remove-BitsTransfer -BitsJob $job -Confirm:$false -ErrorAction SilentlyContinue
        }
    }
    Say ('Download concluído em {0:N0}s.' -f $clock.Elapsed.TotalSeconds) 'OK'
}

function Add-DownloadRecord([string]$Title, [string]$KB, [string]$Location, [bool]$Success) {
    [void]$script:downloadRecords.Add([pscustomobject]@{
        Title = $Title; KB = $KB; Location = $Location; Success = $Success
    })
}
function Show-DownloadSummary {
    if ($script:downloadRecords.Count -eq 0 -or $script:lastSummaryCount -eq $script:downloadRecords.Count) { return }
    $script:lastSummaryCount = $script:downloadRecords.Count
    Write-Host ''
    Write-Host 'RESUMO DOS DOWNLOADS' -ForegroundColor Cyan
    Show-Rule
    $number = 0
    foreach ($entry in $script:downloadRecords) {
        $number++
        $color = 'Green'
        $status = 'BAIXADO'
        if (-not $entry.Success) { $color = 'Yellow'; $status = 'NÃO CONCLUÍDO' }
        Write-Host ('{0} | {1}' -f $status, $entry.KB) -ForegroundColor $color
        Show-Field 'Atualização' $entry.Title
        Show-Field 'Destino' $entry.Location 'DarkGray'
    }
    $successCount = @($script:downloadRecords | Where-Object { $_.Success }).Count
    Show-Rule
    Show-Field 'Concluídos' ('{0} de {1}' -f $successCount, $script:downloadRecords.Count) 'Green'
}

function Confirm-Installation {
    Write-Host ''
    Show-DownloadSummary
    Write-Host 'DOWNLOADS CONCLUÍDOS — INSTALAR AGORA?' -ForegroundColor Cyan
    Write-Host '[1] Instalar os pacotes baixados (sem reiniciar)' -ForegroundColor Cyan
    Write-Host '[2] Guardar os downloads e instalar depois' -ForegroundColor Gray
    do {
        $choice = (Read-Host 'Digite 1 ou 2 e pressione Enter').Trim()
        if ($choice -notin @('1', '2')) { Write-Host 'Escolha 1 para instalar ou 2 para deixar para depois.' -ForegroundColor Yellow }
    } while ($choice -notin @('1', '2'))
    return ($choice -eq '1')
}
function Get-DownloadsFolder {
    $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
    $folders = Get-ItemProperty -LiteralPath $key -ErrorAction SilentlyContinue
    $path = $folders.'{374DE290-123F-4565-9164-39C4925E467B}'
    if ($path) { $path = [Environment]::ExpandEnvironmentVariables([string]$path) }
    else { $path = Join-Path $env:USERPROFILE 'Downloads' }
    New-Item -ItemType Directory -Path $path -Force | Out-Null
    return $path
}

function Initialize-WuaCallbacks {
    if ('WindowsUpdateUI2.Callback' -as [type]) { return }
    # GUIDs e assinaturas de callback do wuapi.h oficial do Windows SDK.
    Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
namespace WindowsUpdateUI2 {
    [ComVisible(true), Guid("88aee058-d4b0-4725-a2f1-814a67ae964c"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface ISearchCompletedCallback {
        void Invoke([MarshalAs(UnmanagedType.Interface)] object job, [MarshalAs(UnmanagedType.Interface)] object args);
    }
    [ComVisible(true), Guid("77254866-9f5b-4c8e-b9e2-c77a8530d64b"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IDownloadCompletedCallback {
        void Invoke([MarshalAs(UnmanagedType.Interface)] object job, [MarshalAs(UnmanagedType.Interface)] object args);
    }
    [ComVisible(true), Guid("8c3f1cdd-6173-4591-aebd-a56a53ca77c1"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IDownloadProgressChangedCallback {
        void Invoke([MarshalAs(UnmanagedType.Interface)] object job, [MarshalAs(UnmanagedType.Interface)] object args);
    }
    [ComVisible(true), Guid("45f4f6f3-d602-4f98-9a8a-3efa152ad2d3"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IInstallationCompletedCallback {
        void Invoke([MarshalAs(UnmanagedType.Interface)] object job, [MarshalAs(UnmanagedType.Interface)] object args);
    }
    [ComVisible(true), Guid("e01402d5-f8da-43ba-a012-38894bd048f1"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IInstallationProgressChangedCallback {
        void Invoke([MarshalAs(UnmanagedType.Interface)] object job, [MarshalAs(UnmanagedType.Interface)] object args);
    }
    [ComVisible(true), ClassInterface(ClassInterfaceType.None)]
    public sealed class Callback : ISearchCompletedCallback, IDownloadCompletedCallback,
        IDownloadProgressChangedCallback, IInstallationCompletedCallback, IInstallationProgressChangedCallback {
        public void Invoke(object job, object args) { }
    }
}
'@
}
function Invoke-WuaOperation {
    param($Worker, [ValidateSet('Search','Download','Install')][string]$Mode,
          [string]$Criteria = "IsInstalled=0 and IsHidden=0 and Type='Software'")
    Initialize-WuaCallbacks
    $callback = New-Object WindowsUpdateUI2.Callback
    $job = $null
    $ended = $false
    $cancelled = $false
    $timedOut = $false
    $clock = [Diagnostics.Stopwatch]::StartNew()
    $inline = $Host.Name -eq 'ConsoleHost'
    $canReadKeys = $inline -and $Mode -eq 'Download'
    try {
        if ([Console]::IsOutputRedirected) { $inline = $false }
        if ([Console]::IsInputRedirected) { $canReadKeys = $false }
    } catch { $inline = $false; $canReadKeys = $false }
    $lastPrint = -10.0
    $lastBytes = 0.0
    $lastTime = 0.0
    $phase = switch ($Mode) { 'Search' { 'BUSCANDO' }; 'Download' { 'BAIXANDO' }; 'Install' { 'INSTALANDO' } }
    if ($canReadKeys) { Write-Host 'ESC cancela o download e volta ao menu.' -ForegroundColor Yellow }
    if ($Mode -eq 'Install') { Say 'O percentual pode permanecer estável enquanto um pacote é processado.' 'DETALHE' }
    try {
        $job = switch ($Mode) {
            'Search' { $Worker.BeginSearch($Criteria, $callback, $null) }
            'Download' { $Worker.BeginDownload($callback, $callback, $null) }
            'Install' { $Worker.BeginInstall($callback, $callback, $null) }
        }
        while (-not $job.IsCompleted) {
            if ($canReadKeys -and -not $cancelled) {
                while ([Console]::KeyAvailable) {
                    if ([Console]::ReadKey($true).Key -eq [ConsoleKey]::Escape) {
                        $job.RequestAbort(); $cancelled = $true
                        $script:downloadCancelled = $true
                    }
                }
            }
            if ($Mode -eq 'Search' -and $clock.Elapsed.TotalMinutes -ge 15 -and -not $timedOut) {
                $job.RequestAbort(); $timedOut = $true
            }
            $progressText = 'Aguardando Windows Update'
            if ($Mode -ne 'Search') {
                try {
                    $progress = $job.GetProgress()
                    $progressText = '{0,3:N0}%' -f $progress.PercentComplete
                    if ($Mode -eq 'Download') {
                        $now = $clock.Elapsed.TotalSeconds
                        $bytes = [double]$progress.TotalBytesDownloaded
                        $total = [double]$progress.TotalBytesToDownload
                        $speed = [Math]::Max(0, ($bytes - $lastBytes) / [Math]::Max(0.001, $now - $lastTime) / 1MB)
                        $progressText += ' | {0:N1}/{1:N1} MB | {2:N1} MB/s' -f ($bytes/1MB), ($total/1MB), $speed
                        $lastBytes = $bytes; $lastTime = $now
                    }
                } catch { $progressText = 'Aguardando informação de progresso' }
            }
            if ($cancelled -or $timedOut) { $progressText = 'Aguardando confirmação do cancelamento' }
            $line = '{0} | {1} | {2:00}:{3:00}' -f $phase, $progressText, [int][Math]::Floor($clock.Elapsed.TotalMinutes), $clock.Elapsed.Seconds
            if ($inline) {
                $width = Get-LayoutWidth
                if ($line.Length -gt $width) { $line = $line.Substring(0, $width) }
                Write-Host ("`r" + $line.PadRight($width)) -NoNewline -ForegroundColor Cyan
            } elseif ($clock.Elapsed.TotalSeconds - $lastPrint -ge 5) {
                Write-Host $line -ForegroundColor Cyan
                $lastPrint = $clock.Elapsed.TotalSeconds
            }
            Start-Sleep -Milliseconds 500
        }
        $result = switch ($Mode) {
            'Search' { $Worker.EndSearch($job) }
            'Download' { $Worker.EndDownload($job) }
            'Install' { $Worker.EndInstall($job) }
        }
        $ended = $true
        if ($cancelled) { throw [OperationCanceledException]::new('Download cancelado pelo usuário.') }
        if ($timedOut) { throw 'A busca demorou mais de 15 minutos e foi cancelada. Tente novamente após concluir outras atualizações.' }
        return $result
    } finally {
        $clock.Stop()
        if ($inline) { Write-Host '' }
        if ($null -ne $job -and -not $ended) { try { $job.RequestAbort() } catch {} }
        [GC]::KeepAlive($callback)
    }
}
function Get-UpdateGroup($Update) {
    $title = [string]$Update.Title
    $ids = @($Update.Categories | ForEach-Object { [string]$_.CategoryID })
    if ([int]$Update.Type -eq 2 -or $ids -contains 'ebfc1fc5-71a4-4f7b-9aca-3b9a503104a0') { return $null }
    if ($ids -contains '3689bdc8-b205-4af4-8d4a-a63924c5e9d5' -or $title -match '(?i)Insider|Feature update|Atualiza[cç][aã]o de recursos') { return $null }
    $preview = $title -match '(?i)preview|visualiza[cç][aã]o|pr[eé]via'
    $isNet = $title -match '(?i)\.NET'
    $isDefender = $title -match '(?i)(Microsoft|Windows) Defender'
    $osUpdate = -not $isNet -and -not $isDefender -and $title -match '(?i)Windows (10|11)' -and $title -match '(?i)cumulative|cumulativ|servicing stack|pilha de (manuten|servi)|security update|atualiza[cç][aã]o de seguran[cç]a'
    if ($osUpdate) { return [pscustomobject]@{ Group='Windows'; Tag='WINDOWS'; Preview=$preview } }
    $importantIds = @('0fa1201d-4330-4fa8-8ae9-b877473b6441', 'e6cf1350-c01b-414d-a61f-263d14d133b4',
        'e0789628-ce08-4437-be74-2495b842f43b', '28bc880e-0592-4cbf-8f95-c79b17911d5f', 'cd5ffd1e-e932-4e3a-bf74-18bf0b1bbd83')
    if (-not $isNet -and -not $isDefender -and @($ids | Where-Object { $_ -in $importantIds }).Count -eq 0) { return $null }
    $tag = 'CORREÇÃO DE SOFTWARE'
    if ($ids -contains '0fa1201d-4330-4fa8-8ae9-b877473b6441') { $tag = 'SEGURANÇA' }
    if ($ids -contains 'e6cf1350-c01b-414d-a61f-263d14d133b4') { $tag = 'CORREÇÃO CRÍTICA' }
    if ($isNet) { $tag = '.NET' }
    if ($isDefender) { $tag = 'DEFENDER' }
    return [pscustomobject]@{ Group='Importantes'; Tag=$tag; Preview=$preview }
}
function Invoke-WuaDownloads([ValidateSet('Windows','Importantes')][string]$Group) {
    $groupTitle = if ($Group -eq 'Windows') { 'CUMULATIVAS DO WINDOWS' } else { 'ATUALIZAÇÕES IMPORTANTES' }
    Write-Host "`n$groupTitle" -ForegroundColor Cyan
    Show-Rule
    Say 'Consultando atualizações aplicáveis, incluindo prévias opcionais.' 'AGUARDE'
    $session = New-Object -ComObject Microsoft.Update.Session
    $session.ClientApplicationID = 'AtualizarWindows.Downloads'
    $searcher = $session.CreateUpdateSearcher()
    $searcher.Online = $true
    $searcher.ServerSelection = 0
    if ($policy.UseWUServer -ne 1) { $searcher.ServerSelection = 2 }
    $searcher.IncludePotentiallySupersededUpdates = $false
    $found = Invoke-WuaOperation -Worker $searcher -Mode Search
    if ([int]$found.ResultCode -ne 2) { throw 'A consulta do Windows Update não terminou integralmente.' }
    $chosen = New-Object -ComObject Microsoft.Update.UpdateColl
    foreach ($update in $found.Updates) {
        $info = Get-UpdateGroup $update
        if ($null -eq $info -or $info.Group -ne $Group) { continue }
        $state = 'SERÁ BAIXADA'
        $color = 'Green'
        if ($info.Preview) { $state += ' | PRÉVIA OPCIONAL INCLUÍDA'; $color = 'Yellow' }
        if ($SomenteVerificar) { $state = 'SOMENTE CONSULTA'; $color = 'Cyan' }
        Write-Host $state -ForegroundColor $color
        Show-Field 'Tipo' $info.Tag
        Show-Field 'Atualização' ([string]$update.Title)
        Show-Field 'Tamanho' ('Até {0:N1} MB' -f ($update.MaxDownloadSize / 1MB))
        Show-Rule
        [void]$chosen.Add($update)
    }
    if ($chosen.Count -eq 0) { Say 'Nenhuma atualização pendente deste grupo foi oferecida.'; return }
    if ($SomenteVerificar) { Say 'Consulta concluída. Nenhum download solicitado.'; return }
    foreach ($update in $chosen) { if (-not $update.EulaAccepted) { $update.AcceptEula() } }
    $downloader = $session.CreateUpdateDownloader()
    $downloader.Updates = $chosen
    Say ('Iniciando download automático de {0} pacote(s).' -f $chosen.Count) 'OK'
    $download = Invoke-WuaOperation -Worker $downloader -Mode Download
    $ready = New-Object -ComObject Microsoft.Update.UpdateColl
    for ($i=0; $i -lt $chosen.Count; $i++) {
        $update = $chosen.Item($i)
        $r = $download.GetUpdateResult($i)
        $downloaded = [bool]$update.IsDownloaded
        Add-DownloadRecord -Title $update.Title -KB (($update.KBArticleIDs | ForEach-Object { 'KB' + $_ }) -join ', ') -Location 'Cache do Windows Update' -Success $downloaded
        if ($downloaded) { [void]$ready.Add($update) }
        else { Say ('Download não concluído: {0} | {1}' -f $update.Title, (HexCode $r.HResult)) 'AVISO' }
    }
    if ($ready.Count -gt 0) {
        [void]$script:pendingInstalls.Add([pscustomobject]@{ Kind='WUA'; Session=$session; Updates=$ready; Title=$groupTitle })
    }
}
function Invoke-PendingInstallations {
    Show-DownloadSummary
    if ($script:pendingInstalls.Count -eq 0) { return }
    if (-not (Confirm-Installation)) { Say 'Downloads guardados. Nenhuma instalação foi iniciada.'; return }
    if ((New-Object -ComObject Microsoft.Update.SystemInfo).RebootRequired) {
        Say 'Os downloads terminaram. Reinicie o computador antes de instalar. Os pacotes continuam guardados.' 'AVISO'
        return
    }
    foreach ($pending in $script:pendingInstalls) {
        if ((New-Object -ComObject Microsoft.Update.SystemInfo).RebootRequired) {
            Say 'A atualização anterior precisa de reinício. Os outros downloads foram preservados para instalar depois.' 'AVISO'
            break
        }
        try {
            if ($pending.Kind -eq 'Catalogo') {
                Install-CatalogPackage -TargetPath $pending.Path -DownloadFolder $pending.Folder
                continue
            }
            $installer = $pending.Session.CreateUpdateInstaller()
            if ($installer.IsBusy) { throw 'O Windows já está instalando outra atualização. Aguarde sua conclusão.' }
            if ($installer.RebootRequiredBeforeInstallation) { throw 'Reinicie antes de instalar os pacotes baixados.' }
            # Pacotes que exigem interface ficam baixados para instalação pelo Windows Update.
            $silent = New-Object -ComObject Microsoft.Update.UpdateColl
            foreach ($update in $pending.Updates) {
                if ($update.InstallationBehavior.CanRequestUserInput) {
                    Say ('Baixado; exige interação no Windows Update: {0}' -f $update.Title) 'AVISO'
                } else { [void]$silent.Add($update) }
            }
            if ($silent.Count -eq 0) { continue }
            $installer.Updates = $silent
            $installer.AllowSourcePrompts = $false
            Write-Host "`nINSTALAÇÃO EM ANDAMENTO" -ForegroundColor Cyan
            Show-Rule
            Say 'Aguarde a conclusão. O computador não será reiniciado automaticamente.'
            $result = Invoke-WuaOperation -Worker $installer -Mode Install
            for ($i=0; $i -lt $silent.Count; $i++) {
                $r = $result.GetUpdateResult($i)
                $color = 'AVISO'
                if ([int]$r.ResultCode -eq 2) { $color = 'OK' }
                Say ('{0} | {1} | {2}' -f $silent.Item($i).Title, (ResultName $r.ResultCode), (HexCode $r.HResult)) $color
            }
            if ($result.RebootRequired) {
                Say 'Instalação concluída com reinício pendente. Os demais downloads continuam guardados.' 'AVISO'
                break
            }
        } catch {
            Say ('Não foi possível concluir esta instalação: {0}' -f $_.Exception.Message) 'ERRO'
        }
    }
}

function Invoke-CatalogUpdate {
    Show-Stage 3 'Consultar publicações oficiais e catálogo'
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    $headers = @{ 'Accept-Language' = 'en-US'; 'User-Agent' = 'Mozilla/5.0' }
    $releaseUrl = 'https://learn.microsoft.com/en-us/windows/release-health/release-information'
    if ($family -eq 'Windows 11') { $releaseUrl = 'https://learn.microsoft.com/en-us/windows/release-health/windows11-release-information' }
    Say 'Consultando a cumulativa publicada mais recente para sua versão, incluindo prévias.'
    $html = (Invoke-WebRequest $releaseUrl -UseBasicParsing -Headers $headers -TimeoutSec 90).Content
    $candidates = @()
    foreach ($row in [regex]::Matches($html, '(?is)<tr\b[^>]*>.*?</tr>')) {
        $plain = Get-PageText $row.Value
        $buildMatch = [regex]::Match($plain, ('\b' + [regex]::Escape([string]$os.CurrentBuildNumber) + '\.(\d+)\b'))
        $kbMatch = [regex]::Match($plain, '(?i)\bKB\d{6,8}\b')
        if ($buildMatch.Success -and $kbMatch.Success -and $plain -match '\b\d{4}-\d{2}\s+(B|C|D|OOB)\b') {
            $candidates += [pscustomobject]@{ Build = [version]$buildMatch.Value; KB = $kbMatch.Value.ToUpper() }
        }
    }
    $latest = $candidates | Sort-Object Build -Descending | Select-Object -First 1
    if (-not $latest) { throw 'Não foi possível identificar a cumulativa no histórico oficial. A página pode ter mudado. Use -Fonte WindowsUpdate.' }
    $current = [version]('{0}.{1}' -f $os.CurrentBuildNumber, $os.UBR)
    Say ('Publicada: {0} | Build {1} | Instalada: {2}' -f $latest.KB, $latest.Build, $current) 'OK'
    if ($current -ge $latest.Build) { Say 'A build instalada já alcança ou supera a cumulativa mais recente publicada.' 'OK'; return }
    $arch = $env:PROCESSOR_ARCHITECTURE
    if ($env:PROCESSOR_ARCHITEW6432) { $arch = $env:PROCESSOR_ARCHITEW6432 }
    $arch = switch ($arch) { 'AMD64' { 'x64' }; 'ARM64' { 'arm64' }; 'x86' { 'x86' }; default { throw "Arquitetura não reconhecida: $arch" } }
    $query = '{0} {1} {2} {3}' -f $latest.KB, $family, $os.DisplayVersion, $arch
    $catalogUrl = 'https://www.catalog.update.microsoft.com/Search.aspx?q=' + [uri]::EscapeDataString($query)
    Say "Pesquisa: $query"
    $page = (Invoke-WebRequest $catalogUrl -UseBasicParsing -Headers $headers -TimeoutSec 90).Content
    $matchesFound = @()
    foreach ($row in [regex]::Matches($page, '(?is)<tr\b[^>]*>.*?</tr>')) {
        $link = [regex]::Match($row.Value, '(?is)<a\b[^>]*id=["'']([0-9a-f-]{36})_link["''][^>]*>(.*?)</a>')
        if (-not $link.Success) { continue }
        $title = (Get-PageText $link.Groups[2].Value).Trim()
        if ($title -notmatch [regex]::Escape($family) -or $title -notmatch [regex]::Escape([string]$os.DisplayVersion)) { continue }
        if ($title -notmatch ('\b' + $arch + '\b') -or $title -notmatch [regex]::Escape($latest.KB)) { continue }
        if ($title -match '(?i)\.NET|Dynamic|Server|Insider|Hotpatch') { continue }
        if ($title -notmatch '(?i)Cumulative Update|Security Update') { continue }
        $matchesFound += [pscustomobject]@{ Id = $link.Groups[1].Value; Title = $title }
    }
    if ($matchesFound.Count -ne 1) { throw "Catálogo retornou $($matchesFound.Count) pacotes inequívocos. Nenhum será escolhido por tentativa. Consulte: $catalogUrl" }
    $item = $matchesFound[0]
    Say $item.Title 'OK'
    if ($SomenteVerificar) { Say 'SomenteVerificar: nenhum arquivo baixado ou instalado.'; return }
    $ids = ConvertTo-Json -Compress -InputObject @(@{ size = 0; languages = ''; uidInfo = $item.Id; updateID = $item.Id })
    $dialog = (Invoke-WebRequest 'https://www.catalog.update.microsoft.com/DownloadDialog.aspx' -Method Post -Body @{ updateIDs = $ids } -UseBasicParsing -Headers $headers -TimeoutSec 90).Content
    $urls = @([regex]::Matches($dialog, '(?i)https?://[^\s''"<>]+\.msu') | ForEach-Object { [Net.WebUtility]::HtmlDecode($_.Value) } | Select-Object -Unique)
    if ($urls.Count -eq 0) { throw 'O catálogo não retornou links MSU reconhecidos. Nenhum instalador será executado.' }
    # Pasta exclusiva: WUSA pode resolver checkpoints presentes ao lado do alvo.
    $downloadFolder = Join-Path (Get-DownloadsFolder) ('AtualizarWindows\{0}_{1}' -f $latest.KB, [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $downloadFolder -Force | Out-Null
    $files = @()
    Show-Stage 4 'Baixar cumulativa e checkpoints'
    foreach ($url in $urls) {
        $uri = [uri]($url -replace '^http:', 'https:')
        if ($uri.Scheme -ne 'https' -or $uri.DnsSafeHost -notmatch '(^|\.)windowsupdate\.com$') { throw 'Link de download fora dos servidores esperados da Microsoft.' }
        $name = [IO.Path]::GetFileName($uri.AbsolutePath)
        if ($name -notmatch '^[a-zA-Z0-9_.-]+\.msu$') { throw 'Nome de pacote não reconhecido.' }
        $dest = Join-Path $downloadFolder $name
        Say "Baixando: $name" 'AGUARDE'
        Receive-Package -Url $uri.AbsoluteUri -Destination ($dest + '.partial') -Label $latest.KB
        Move-Item -LiteralPath ($dest + '.partial') -Destination $dest
        # WUSA verifica assinatura e aplicabilidade pelo mecanismo de servicing.
        Say ('SHA256: {0}' -f (Get-FileHash -LiteralPath $dest -Algorithm SHA256).Hash) 'DETALHE'
        $fileKB = [regex]::Match($name, '(?i)kb[0-9]+').Value.ToUpper()
        $fileTitle = $item.Title
        if ($fileKB -ne $latest.KB) { $fileTitle = 'Checkpoint necessário: ' + $fileKB }
        Add-DownloadRecord -Title $fileTitle -KB $fileKB -Location $dest -Success $true
        $files += $dest
    }
    $target = @($files | Where-Object { [IO.Path]::GetFileName($_) -match ('(?i)' + $latest.KB + '-') })
    if ($target.Count -ne 1) { throw "Pacote alvo ambíguo. Arquivos preservados em $downloadFolder" }
    Say "Pacotes salvos: $downloadFolder" 'OK'
    [void]$script:pendingInstalls.Add([pscustomobject]@{ Kind='Catalogo'; Path=$target[0]; Folder=$downloadFolder; Title=$item.Title })
}

function Install-CatalogPackage([string]$TargetPath, [string]$DownloadFolder) {
    $target = @($TargetPath)
    if ((New-Object -ComObject Microsoft.Update.SystemInfo).RebootRequired) { throw 'Download concluído. Reinicie antes de instalar; pacotes preservados.' }
    if ((New-Object -ComObject Microsoft.Update.Session).CreateUpdateInstaller().IsBusy) { throw 'Download concluído, mas há outra instalação em andamento. Pacotes preservados.' }
    Show-Stage 5 'Instalar cumulativa oficial'
    Say 'WUSA verificará assinatura, aplicabilidade e pré-requisitos, incluindo ESU. Não desligue o computador.' 'AVISO'
    $process = Start-Process -FilePath "$env:SystemRoot\System32\wusa.exe" -ArgumentList ('"{0}" /quiet /norestart' -f $target[0]) -PassThru
    $installClock = [Diagnostics.Stopwatch]::StartNew()
    $frames = @('|', '/', '-', '\')
    $frame = 0
    $lastPrint = -10.0
    $inlineInstall = $Host.Name -eq 'ConsoleHost'
    try { if ([Console]::IsOutputRedirected) { $inlineInstall = $false } } catch { $inlineInstall = $false }
    try {
        while (-not $process.HasExited) {
            $elapsed = $installClock.Elapsed
            $message = '{0}  INSTALANDO  |  {1:00}:{2:00}:{3:00}  |  Aguarde o instalador' -f $frames[$frame % 4], [int][Math]::Floor($elapsed.TotalHours), $elapsed.Minutes, $elapsed.Seconds
            if ($inlineInstall) {
                $width = 78
                try { $width = [Math]::Max(20, [Math]::Min(100, $Host.UI.RawUI.WindowSize.Width - 1)) } catch {}
                if ($message.Length -gt $width) { $message = $message.Substring(0, $width) }
                Write-Host ("`r" + $message.PadRight($width)) -NoNewline -ForegroundColor Yellow
            } elseif (($elapsed.TotalSeconds - $lastPrint) -ge 10) {
                Write-Host $message -ForegroundColor Yellow
                $lastPrint = $elapsed.TotalSeconds
            }
            $frame++
            Start-Sleep -Milliseconds 500
            $process.Refresh()
        }
        $process.WaitForExit()
    } finally {
        $installClock.Stop()
        if ($inlineInstall) { Write-Host '' }
    }
    $code = [long]$process.ExitCode -band 4294967295L
    switch ($code) {
        0 { Say 'Instalador concluiu com sucesso.' 'OK' }
        3010 { Say 'Instalação concluída. Reinicie manualmente para finalizar.' 'AVISO' }
        2359302 { Say 'O instalador informou que a atualização já está instalada.' 'OK' }
        default { throw ('WUSA retornou {0}. Confira ESU, aplicabilidade e checkpoints. Pacotes: {1}' -f (HexCode $code), $downloadFolder) }
    }
    Say ("Winver agora: {0}" -f (Get-Winver))
    Say 'Confira o Winver após reiniciar. Nenhuma reinicialização automática foi solicitada.'
}

function Invoke-UpdateCycle {
    $transcriptStarted = $false
    $delegated = $false
    $mutex = $null
    $ownsMutex = $false
    $log = $null
    $sessionStart = Get-Date
    $technicalError = $null
    $script:downloadRecords = New-Object 'System.Collections.Generic.List[object]'
    $script:lastSummaryCount = 0
    $script:pendingInstalls = New-Object 'System.Collections.Generic.List[object]'

try {
    $admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $admin -or ([Environment]::Is64BitOperatingSystem -and -not [Environment]::Is64BitProcess)) {
        if (-not $PSCommandPath) { throw 'Salve o conteúdo como AtualizarWindows.ps1 antes de executar.' }
        $exe = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
        if ([Environment]::Is64BitOperatingSystem -and -not [Environment]::Is64BitProcess) {
            $exe = "$env:SystemRoot\Sysnative\WindowsPowerShell\v1.0\powershell.exe"

        }
        $arguments = '-NoLogo -NoProfile -ExecutionPolicy Bypass -File "' + $PSCommandPath + '"'
        if ($SomenteVerificar) { $arguments += ' -SomenteVerificar' }
        $arguments += ' -Fonte ' + $Fonte + ' -Modulo ' + $Modulo
        Say 'Abrindo Windows PowerShell como administrador. Confirme o UAC do Windows.'
        Start-Process -FilePath $exe -Verb RunAs -ArgumentList $arguments | Out-Null
        $delegated = $true
        $script:windowDelegated = $true
        return
    }

    $mutex = New-Object System.Threading.Mutex($false, 'Global\AtualizarWindows_Principal')
    try { $ownsMutex = $mutex.WaitOne(0) } catch [System.Threading.AbandonedMutexException] { $ownsMutex = $true }
    if (-not $ownsMutex) { throw 'Já existe outra instância deste script em execução.' }

    $folder = Join-Path $env:ProgramData 'AtualizarWindows\Logs'
    New-Item -ItemType Directory -Path $folder -Force | Out-Null
    $log = Join-Path $folder ('WinUpdate_{0}_{1}.log' -f (Get-Date -Format 'yyyyMMdd_HHmmss'), $PID)
    Start-Transcript -Path $log -Force | Out-Null
    $transcriptStarted = $true
    try { $Host.UI.RawUI.WindowTitle = 'Atualizar Windows | Cumulativas oficiais' } catch {}
    Write-Host $script:UpdateMenu[0] -ForegroundColor Cyan
    Write-Host $script:UpdateMenu[1] -ForegroundColor Gray
    Show-Rule
    Show-Field 'Sessão iniciada' ($sessionStart.ToString('dd/MM/yyyy HH:mm:ss zzz')) 'Green'
    Show-Field 'Execução' 'Administrador' 'Green'
    Write-Host ''
    if ($Modulo -eq 'Menu') {
        Write-Host $script:UpdateMenu[2] -ForegroundColor Cyan
        Write-Host ''
        Show-MenuOption '1' $script:UpdateMenu[3] $script:UpdateMenu[4]
        Show-MenuOption '2' $script:UpdateMenu[5] $script:UpdateMenu[6]
        Show-MenuOption '3' $script:UpdateMenu[7] $script:UpdateMenu[8]
        Show-MenuOption '0' $script:UpdateMenu[9] $script:UpdateMenu[10]
        Show-Rule
        Write-Host $script:UpdateMenu[11] -ForegroundColor Gray
        Write-Host $script:UpdateMenu[12] -ForegroundColor Gray
        Write-Host ''
        do {
            $option = (Read-Host $script:UpdateMenu[15]).Trim()
            if ($option -notin @('0', '1', '2', '3')) {
                Write-Host $script:UpdateMenu[13] -ForegroundColor Yellow
            }
        } while ($option -notin @('0', '1', '2', '3'))
        if ($option -eq '0') { $script:exitRequested = $true; return }
        $Modulo = switch ($option) { '1' { 'Windows' }; '2' { 'Importantes' }; '3' { 'Ambos' } }
    }
    Write-Host ''
    Write-Host $script:UpdateMenu[14] -ForegroundColor Cyan
    Show-Rule
    if ($Modulo -eq 'DotNet') { $Modulo = 'Importantes' }
    $moduleLabel = switch ($Modulo) { 'Importantes' { 'Atualizações importantes' }; 'Ambos' { 'Windows + atualizações importantes' }; default { 'Cumulativa do Windows' } }
    Show-Field 'Baixar' $moduleLabel 'Green'
    if ($SomenteVerificar) { Show-Field 'Ação' 'Somente consultar; nenhum download' }
    else { Show-Field 'Ação' 'Buscar e baixar automaticamente' }
    if ($Modulo -ne 'Importantes') { Show-Field 'Fonte do Windows' ($(if ($Fonte -eq 'Catalogo') { 'Catálogo Microsoft Update' } else { 'Windows Update' })) }
    if ($Modulo -ne 'Windows') { Show-Field 'Fonte adicional' 'Windows Update - pacotes compatíveis com este PC' }
    Show-Rule
    Show-Stage 1 'Seu computador' 
    $before = Get-Winver
    Say "Winver antes: $before" 'OK'
    $os = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
    $system = Get-CimInstance Win32_OperatingSystem
    if ($system.ProductType -ne 1 -or [int]$os.CurrentBuildNumber -lt 10240) { throw 'Use este script no Windows 10 ou Windows 11 cliente.' }
    $family = 'Windows 10'
    if ([int]$os.CurrentBuildNumber -ge 22000) { $family = 'Windows 11' }
    Say ("Sistema detectado: {0} {1}; arquitetura: {2}" -f $family, $os.DisplayVersion, $system.OSArchitecture) 'OK'
    if ($family -eq 'Windows 10') { Say 'Windows 10 Home/Pro encerrou suporte regular em 14/10/2025. Atualizações posteriores exigem elegibilidade ESU.' }
    Say 'A busca verifica o que está disponível para ESTE computador; não comprova a maior build publicada.'
    Show-Stage 2 'Preparação dos serviços'
    $policy = Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -ErrorAction SilentlyContinue
    if ($policy.UseWUServer -eq 1) { Say 'WSUS configurado: respeitando a fonte gerenciada. Ela pode limitar as atualizações oferecidas.' }
    foreach ($name in @('wuauserv', 'BITS')) {
        $svc = Get-Service $name
        if ($svc.StartType -eq 'Disabled') { throw "Serviço $name desativado. Revise a configuração com o administrador; o script não modifica políticas." }
        if ($svc.Status -ne 'Running') { Start-Service $name }
        Say ("Serviço {0} pronto para uso." -f $name) 'OK'
    }
    $sysInfo = New-Object -ComObject Microsoft.Update.SystemInfo
    if ($sysInfo.RebootRequired) { Say 'Há um reinício pendente. Você pode baixar; a instalação aguardará a reinicialização.' 'AVISO' }

    if ($Modulo -ne 'Importantes') {
        try {
            if ($Fonte -eq 'Catalogo') {
                if ($policy.UseWUServer -eq 1) { throw 'Fonte WSUS configurada. Use -Fonte WindowsUpdate para seguir a fonte da organização.' }
                Invoke-CatalogUpdate
            } else { Invoke-WuaDownloads -Group Windows }
        } catch [OperationCanceledException] { throw }
        catch { Say ('Consulta/download do Windows: {0}' -f $_.Exception.Message) 'ERRO' }
    }
    if ($Modulo -ne 'Windows') {
        try { Invoke-WuaDownloads -Group Importantes }
        catch [OperationCanceledException] { throw }
        catch { Say ('Consulta/download de atualizações importantes: {0}' -f $_.Exception.Message) 'ERRO' }
    }
    if (-not $SomenteVerificar) { Invoke-PendingInstallations }
} catch [OperationCanceledException] {
    End-Wait
    Say 'Download cancelado. Voltando ao menu principal.' 'AVISO'
} catch {
    End-Wait
    Write-Host "`nNÃO FOI POSSÍVEL CONCLUIR" -ForegroundColor Red
    Say $_.Exception.Message 'ERRO' 
    Show-Field 'Código' (HexCode $_.Exception.HResult) 'Red'
    $technicalError = ($_ | Format-List * -Force | Out-String)
    Say 'Detalhes técnicos salvos no log.' 'DETALHE'
} finally {
    if ($ownsMutex) { $mutex.ReleaseMutex() }
    if ($null -ne $mutex) { $mutex.Dispose() }
    if (-not $delegated) {
        End-Wait
        Show-DownloadSummary
        Write-Host "`nFIM DA EXECUÇÃO" -ForegroundColor Cyan
        Show-Rule
        Show-Field 'Fim' (Get-Date -Format 'dd/MM/yyyy HH:mm:ss')
        Show-Field 'Duração' ('{0:N0} segundos' -f ((Get-Date) - $sessionStart).TotalSeconds)
        Show-Rule
        if ($technicalError -and $log) { Show-Field 'Diagnóstico' $log 'DarkGray' }
        if ($transcriptStarted) { try { Stop-Transcript | Out-Null } catch {} }
        if ($log -and $technicalError) {
            try { Add-Content -LiteralPath $log -Value $technicalError -Encoding UTF8 } catch { Write-Host 'Não foi possível gravar os detalhes técnicos no log.' -ForegroundColor Yellow }
        }

    }
}

}

# Cada ciclo termina e libera log/mutex antes de voltar ao menu.
# Não reinicia o script recursivamente e não acumula processos.
$script:windowDelegated = $false
$script:exitRequested = $false
$script:downloadCancelled = $false
Show-AppSessionMetadata -Version '1.0.0' -Started $sessionStart
while ($true) {
    Invoke-UpdateCycle
    if ($script:windowDelegated) { break }
    if ($script:exitRequested) { exit }
    if ($script:downloadCancelled) {
        $script:downloadCancelled = $false
        $Modulo = 'Menu'
        continue
    }
    Write-Host ''
    Write-Host 'ENTER  Voltar ao menu principal' -ForegroundColor Green
    Write-Host 'ESC    Encerrar o script e fechar esta janela' -ForegroundColor Yellow
    $goBack = $false
    try {
        while ($true) {
            $key = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
            if ($key.VirtualKeyCode -eq 27) { exit }
            if ($key.VirtualKeyCode -eq 13) { $goBack = $true; break }
        }
    } catch {
        # Hosts sem leitura de tecla (por exemplo, ISE).
        $response = Read-Host 'Enter: menu principal | digite SAIR: encerrar'
        if ($response -eq 'SAIR') { exit }
        $goBack = $true
    }
    if ($goBack) {
        $Modulo = 'Menu'
        try { Clear-Host } catch {}
    }
}



