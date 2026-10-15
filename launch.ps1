param([switch]$Check)
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot
$settingsPath = Join-Path $PSScriptRoot 'settings.json'
function Read-PythonPath {
    if (-not (Test-Path -LiteralPath $settingsPath)) { return '' }
    return [string](Get-Content -LiteralPath $settingsPath -Raw | ConvertFrom-Json).python_path
}
try {
    $pythonPath = Read-PythonPath
    if ([string]::IsNullOrWhiteSpace($pythonPath)) {
        if ($Check) { exit 2 }
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'first-run.ps1')
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
        $pythonPath = Read-PythonPath
    }
    if ([string]::IsNullOrWhiteSpace($pythonPath)) { exit 2 }
    if (-not [System.IO.Path]::IsPathRooted($pythonPath)) {
        $pythonPath = Join-Path $PSScriptRoot $pythonPath
    }
    if (-not (Test-Path -LiteralPath $pythonPath -PathType Leaf)) {
        if (-not $Check) {
            Add-Type -AssemblyName System.Windows.Forms
            [System.Windows.Forms.MessageBox]::Show('Python dosyasi bulunamadi. Yeniden yol secmek icin settings.json icindeki python_path alanini bosaltin.', 'Lamba-Merhaba', 'OK', 'Error') | Out-Null
        }
        exit 3
    }
    if ($Check) { exit 0 }
    $appPath = Join-Path $PSScriptRoot 'chat_app.py'
    Start-Process -FilePath $pythonPath -ArgumentList ('"{0}"' -f $appPath) -WorkingDirectory $PSScriptRoot -WindowStyle Normal
    exit 0
} catch {
    if (-not $Check) {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Lamba-Merhaba acilamadi', 'OK', 'Error') | Out-Null
    }
    exit 1
}
