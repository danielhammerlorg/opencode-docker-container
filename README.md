## Setup

1. **Build Docker image:**
   ```powershell
   docker build -t opencode-dhammerl .
   ```

2. **Edit PowerShell profile:**
   ```powershell
   notepad $PROFILE
   ```
   (oder `code $PROFILE` / `vim $PROFILE`). Erstelle die Datei falls sie nicht existiert.

3. **Alias einfügen:**
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

4. **Optional: Config aus eigenem Repo symlinken (empfohlen):**

   Wenn du deine opencode-config in einem eigenen Git-Repo versionierst
   (z.B. `C:\Users\Daniel\WebstormProjects\dhammerl-opencode-config`),
   kannst du es als Symlink anlegen. Änderungen landen dann direkt im
   Repo und bleiben persistent – auch über Container-Neustarts hinweg.

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

   **Hinweise:**
   - **Admin/Developer Mode:** Symlinks brauchen entweder Admin-Rechte
     oder aktivierten Developer Mode (Windows 10/11 Einstellungen →
     Für Entwickler → Entwicklermodus). Ohne das: `New-Item` schlägt
     fehl – dann entweder Developer Mode aktivieren oder PowerShell
     **als Administrator** ausführen.
   - **Docker Volume Mount:** Docker folgt dem Symlink automatisch.
     Der Container sieht `/home/opencode_user/.config/opencode` mit
     dem Inhalt deines Repos.
   - **Persistenz:** Der Symlink ist eine NTFS-Eigenschaft, überlebt
     Neustarts. Einmal angelegt bleibt er – solange du das Repo nicht
     verschiebst oder löschst.

5. **Run opencode:**
   ```powershell
   oc
   ```