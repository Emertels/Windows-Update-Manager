# Shared release-session banner for the Windows utilities.
$script:AppCulture = if ($env:EMERTELS_LANGUAGE) { $env:EMERTELS_LANGUAGE } else { [Globalization.CultureInfo]::CurrentUICulture.Name }
$script:AppLanguage = switch -Regex ($script:AppCulture) {
    '^pt' { 'pt-BR'; break }
    '^en' { 'en'; break }
    '^es' { 'es'; break }
    '^fr' { 'fr'; break }
    '^de' { 'de'; break }
    '^it' { 'it'; break }
    '^ja' { 'ja'; break }
    '^ko' { 'ko'; break }
    '^zh-(TW|HK|MO)' { 'pt-BR'; break } '^(zh|cmn)' { 'zh-CN'; break }
    '^ru' { 'ru'; break }
    default { 'pt-BR' }
}
$script:AppSessionText = @{
    'pt-BR' = @('Versão','Sessão iniciada em','Idioma detectado')
    'en' = @('Version','Session started','Detected language')
    'es' = @('Versión','Sesión iniciada','Idioma detectado')
    'fr' = @('Version','Session démarrée','Langue détectée')
    'de' = @('Version','Sitzung gestartet','Erkannte Sprache')
    'it' = @('Versione','Sessione avviata','Língua rilevata')
    'ja' = @('バージョン','セッション開始','検出された言語')
    'ko' = @('버전','세션 시작','감지된 언어')
    'zh-CN' = @('版本','会话开始时间','检测到的语言')
    'ru' = @('Версия','Сеанс начат','Обнаруженный язык')
}
$script:AppSessionStartedAt = Get-Date
function Show-AppSessionMetadata {
    param([string]$Version='1.0.0',[datetime]$Started=$script:AppSessionStartedAt)
    $labels=$script:AppSessionText[$script:AppLanguage]
    Write-Host ("{0}: {1}" -f $labels[0],$Version) -ForegroundColor DarkGray
    Write-Host ("{0}: {1}" -f $labels[1],$Started.ToString('yyyy-MM-dd HH:mm:ss')) -ForegroundColor DarkGray
    Write-Host ("{0}: {1}" -f $labels[2],$script:AppLanguage) -ForegroundColor DarkGray
}
function Show-AppSessionInfo {
    param([string]$Title,[string]$Version='1.0.0',[datetime]$Started=$script:AppSessionStartedAt)
    Write-Host $Title -ForegroundColor Cyan
    Show-AppSessionMetadata -Version $Version -Started $Started
}



