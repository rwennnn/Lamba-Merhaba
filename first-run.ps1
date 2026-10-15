$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
Set-Location -LiteralPath $PSScriptRoot

function Invoke-PythonChecked {
    param([string]$Interpreter, [string[]]$Arguments)
    & $Interpreter @Arguments
    if ($LASTEXITCODE -ne 0) { throw "Python islemi tamamlanamadi (kod $LASTEXITCODE)." }
}

try {
    $picker = New-Object System.Windows.Forms.OpenFileDialog
    $picker.Title = 'Kurulum icin Python 3.12 python.exe dosyasini secin'
    $picker.Filter = 'Python (python.exe)|python.exe|Uygulamalar (*.exe)|*.exe'
    $picker.CheckFileExists = $true
    if ($picker.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) { exit 2 }
    $selectedPython = $picker.FileName
    $version = (& $selectedPython -c 'import sys; print(sys.version_info.major,sys.version_info.minor,sep=chr(46))' | Out-String).Trim()
    if ($LASTEXITCODE -ne 0 -or $version -ne '3.12') {
        throw 'Python 3.12 python.exe secilmeli. Python kurulu degilse python.org adresinden once Python 3.12 kurun.'
    }
    $message = "Bu klasorde ayri bir Python ortami kurulacak.`nCUDA destekli PyTorch, gerekli paketler ve model indirilecek.`nIndirme birkac GB olabilir. Internet ve NVIDIA GPU gerekir.`n`nSecilen Python: $selectedPython`n`nKurulum baslasin mi?"
    $answer = [System.Windows.Forms.MessageBox]::Show($message, 'Lamba-Merhaba - ilk kurulum', 'YesNo', 'Question')
    if ($answer -ne [System.Windows.Forms.DialogResult]::Yes) { exit 2 }
    $venvPython = Join-Path $PSScriptRoot '.venv\Scripts\python.exe'
    if (-not (Test-Path -LiteralPath $venvPython)) {
        Invoke-PythonChecked -Interpreter $selectedPython -Arguments @('-m','venv',(Join-Path $PSScriptRoot '.venv'))
    }
    Invoke-PythonChecked -Interpreter $venvPython -Arguments @('-m','pip','install','torch==2.11.0','--index-url','https://download.pytorch.org/whl/cu128')
    Invoke-PythonChecked -Interpreter $venvPython -Arguments @('-m','pip','install','-r',(Join-Path $PSScriptRoot 'requirements.txt'))
    Invoke-PythonChecked -Interpreter $venvPython -Arguments @('-c','import torch,tkinter; assert torch.cuda.is_available(); assert torch.cuda.is_bf16_supported()')
    Invoke-PythonChecked -Interpreter $venvPython -Arguments @((Join-Path $PSScriptRoot 'setup_model.py'))
    @{python_path='.venv\Scripts\pythonw.exe'} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'settings.json') -Encoding utf8
    [System.Windows.Forms.MessageBox]::Show('Kurulum tamamlandi. Sohbet simdi acilacak.', 'Lamba-Merhaba', 'OK', 'Information') | Out-Null
    exit 0
} catch {
    [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Lamba-Merhaba kurulumu tamamlanamadi', 'OK', 'Error') | Out-Null
    Write-Error $_
    exit 1
}
