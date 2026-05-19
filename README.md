## Setup

### 1. Build Docker image

```powershell
docker build -t opencode-dhammerl .
```

### 2. Shell alias einrichten

**Windows (PowerShell):**
```powershell
notepad $PROFILE
```
(oder `code $PROFILE` / `vim $PROFILE`). Erstelle die Datei falls sie nicht existiert.

```powershell
function oc {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        $args
    )
    $project = (Get-Location).Path
    docker run --rm -it `
        -v "${project}:/home/opencode_user/project" `
        -v "$HOME\.config\opencode:/home/opencode_user/.config/opencode" `
        -w /home/opencode_user/project `
        -e GITHUB_TOKEN=<token> `
        opencode-dhammerl @args
}
```

Replace `<token>` with a GitHub token. Reload profile: `. $PROFILE`

**macOS (zsh):**
```zsh
echo 'alias oc="docker run --rm -it \
  -v \"$PWD:/home/opencode_user/project\" \
  -v \"$HOME/.config/opencode:/home/opencode_user/.config/opencode\" \
  -w /home/opencode_user/project \
  -e GITHUB_TOKEN=<token> \
  opencode-dhammerl"' >> ~/.zshrc
```

Replace `<token>` with a GitHub token. Reload profile: `source ~/.zshrc`

### 3. Config aus eigenem Repo symlinken (empfohlen)

Wenn du deine opencode-config in einem eigenen Git-Repo versionierst, kannst du es als Symlink anlegen. Änderungen landen dann direkt im Repo und bleiben persistent – auch über Container-Neustarts hinweg.

**Windows (PowerShell):**
```powershell
# Sicherstellen dass ~\.config\opencode existiert
# (Docker volume mount braucht das Ziel)
if (Test-Path "$HOME\.config\opencode") {
    Remove-Item "$HOME\.config\opencode" -Recurse -Force
}

# Symlink anlegen (Ziel = dein Repo)
New-Item -ItemType SymbolicLink -Path "$HOME\.config\opencode" `
    -Target "C:\Users\Daniel\WebstormProjects\dhammerl-opencode-config"
```

**macOS:**
```zsh
# ~/.config/opencode löschen falls vorhanden
rm -rf ~/.config/opencode

# Symlink anlegen (Ziel = dein Repo)
ln -s /Users/danielhammerl/WebstormProjects/dhammerl-opencode-config ~/.config/opencode
```

**Hinweise:**
- **Windows:** Symlinks brauchen entweder Admin-Rechte oder aktivierten Developer Mode (Windows 10/11 Einstellungen → Für Entwickler → Entwicklermodus). Ohne das: `New-Item` schlägt fehl – dann entweder Developer Mode aktivieren oder PowerShell **als Administrator** ausführen.
- **macOS:** Symlinks funktionieren ohne besondere Berechtigungen.
- **Docker Volume Mount:** Docker folgt dem Symlink automatisch. Der Container sieht `/home/opencode_user/.config/opencode` mit dem Inhalt deines Repos.
- **Persistenz:** Einmal angelegt bleibt der Symlink – solange du das Repo nicht verschiebst oder löschst.

### 4. Run opencode

```powershell
oc
```
