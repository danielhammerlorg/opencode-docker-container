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

4. **Run opencode:**
   ```powershell
   oc
   ```