param(
    [string]$title   = "Claude Code",
    [string]$message = "Attention",
    [string]$kind    = "info"
)

# Windows 11 native toast via WinRT (non-blocking, appears in Action Center,
# no MessageBox). No third-party modules. Falls back to a beep on failure so
# the hook still makes noise even if toast registration fails.

$appId = "Claude.Code.Hook"

try {
    [void][Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType=WindowsRuntime]
    [void][Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType=WindowsRuntime]

    $template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent(
        [Windows.UI.Notifications.ToastTemplateType]::ToastText02
    )
    $nodes = $template.GetElementsByTagName('text')
    [void]$nodes.Item(0).AppendChild($template.CreateTextNode($title))
    [void]$nodes.Item(1).AppendChild($template.CreateTextNode($message))

    # Audio: IM for "attend", Default chime otherwise.
    $soundName = if ($kind -eq 'attend') { 'ms-winsoundevent:Notification.IM' } else { 'ms-winsoundevent:Notification.Default' }
    $audio = $template.CreateElement('audio')
    [void]$audio.SetAttribute('src', $soundName)
    [void]$template.DocumentElement.AppendChild($audio)

    $toast = [Windows.UI.Notifications.ToastNotification]::new($template)
    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($appId).Show($toast)
}
catch {
    # Fallback: at least make audible feedback if toast pipeline fails.
    try { [console]::beep(660, 180) } catch {}
}
