## Setup

### 1. Build Docker image

```powershell
docker build -t opencode-dhammerl .
```

### 2. Shell alias einrichten

**Windows (PowerShell):**
```powershell
function oc {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        $args
    )
    if ((Resolve-Path).Path -eq $HOME -or (Resolve-Path).Path -eq "$HOME\Documents" -or (Resolve-Path).Path -eq "$HOME\Desktop") {
        Write-Error "Abbruch: oc darf nicht in ~, ~/Documents oder ~/Desktop ausgeführt werden."
        return
    }
    $project = (Get-Location).Path
    docker run --rm -it `
        -v "${project}:/home/opencode_user/project" `
        -v "$HOME\.config\opencode:/home/opencode_user/.config/opencode" `
        -w /home/opencode_user/project `
        -e GITHUB_TOKEN $env:GITHUB_TOKEN `
        opencode-dhammerl @args
}
```

Füge vor dem Start von `oc` die Variable in deiner Shell hinzu, z. B.:

**Windows PowerShell:**
```powershell
$env:GITHUB_TOKEN="dein_token_hier"
```
oder in der Datei `$PROFILE`. Reload profile: `. $PROFILE`

macOS:

**macOS (zsh):**
echo 'oc() {
  case "$PWD" in
    "$HOME") echo "Abbruch: oc darf nicht in ~, ~/Documents oder ~/Desktop ausgeführt werden." >&2; return 1 ;;
    "$HOME/Documents") echo "Abbruch: oc darf nicht in ~, ~/Documents oder ~/Desktop ausgeführt werden." >&2; return 1 ;;
    "$HOME/Desktop") echo "Abbruch: oc darf nicht in ~, ~/Documents oder ~/Desktop ausgeführt werden." >&2; return 1 ;;
  esac
  docker run --rm -it \
  -v "$PWD:/home/opencode_user/project" \
  --network container:opencode-firewall \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  -v \"$HOME/.config/opencode:/home/opencode_user/.config/opencode\" \
  -v \"$HOME/.local/share/opencode:/home/opencode_user/.local/share/opencode\" \
  -v \"$HOME/.local/state/opencode:/home/opencode_user/.local/state/opencode\" \
  -v \"$HOME/.config/opencode:/home/opencode_user/.config/opencode\" \
  -v \"$HOME/.cache/opencode:/home/opencode_user/.cache/opencode\" \
  -w /home/opencode_user/project \
  -e GITHUB_TOKEN=${GITHUB_TOKEN} \
  -e TERM=$TERM \
  opencode-dhammerl
}' >> ~/.zshrc
```

Reload profile: `source ~/.zshrc`

Füge vor dem Start von `oc` die Variable in deiner Shell hinzu, z. B.:

**macOS zsh:**
```zsh
export GITHUB_TOKEN="dein_token_hier"
```

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