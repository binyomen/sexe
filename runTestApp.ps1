$local:ErrorActionPreference = 'Stop'

Push-Location $PSScriptRoot
try {
    if (Test-Path .\target\testapp) {
        Remove-Item -Recurse .\target\testapp
    }
    if (Test-Path .\target\extracted) {
        Remove-Item -Recurse .\target\extracted
    }

    cargo build
    if (-not $?) { Write-Error 'Command failed' }
    cargo clippy --all-targets --all-features -- -D warnings
    if (-not $?) { Write-Error 'Command failed' }
    mkdir .\target\testapp > $null

    Copy-Item -Recurse .\testapp\assets\* .\target\testapp
    Copy-Item .\target\debug\testapp.exe .\target\testapp

    .\target\debug\onex.exe pack .\target\debug\onex_loader.exe .\target\testapp .\target\testapp_packaged.exe
    if (-not $?) { Write-Error 'Command failed' }
    .\target\testapp_packaged.exe arg1 arg2 arg3
    if (-not $?) { Write-Error 'Command failed' }

    .\target\debug\onex.exe swap .\target\testapp_packaged.exe .\target\debug\onex_loader.exe .\target\testapp_packaged.exe
    if (-not $?) { Write-Error 'Command failed' }
    .\target\testapp_packaged.exe arg1 arg2 arg3
    if (-not $?) { Write-Error 'Command failed' }
    .\target\debug\onex.exe swap .\target\testapp_packaged.exe .\target\debug\onex_loader.exe
    if (-not $?) { Write-Error 'Command failed' }
    .\target\testapp_packaged.exe arg1 arg2 arg3
    if (-not $?) { Write-Error 'Command failed' }

    .\target\debug\onex.exe list .\target\testapp_packaged.exe
    if (-not $?) { Write-Error 'Command failed' }

    .\target\debug\onex.exe extract .\target\testapp_packaged.exe .\target\extracted
    if (-not $?) { Write-Error 'Command failed' }
    Get-ChildItem -Recurse .\target\extracted

    .\target\debug\onex.exe check .\target\testapp_packaged.exe
    if (-not $?) { Write-Error 'Command failed' }
    .\target\debug\onex.exe check .\target\debug\onex.exe
    if ($?) { Write-Error 'Command should have failed' }
} finally {
    Pop-Location
}

exit 0
