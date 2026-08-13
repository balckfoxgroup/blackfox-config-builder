#Requires -Version 5.1
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$GoDir = Join-Path $Root "go"
$OutDir = Join-Path $Root "flutter\android\app\libs"
$AarPath = Join-Path $OutDir "mobile.aar"

if (-not (Get-Command go -ErrorAction SilentlyContinue)) {
    throw "Go SDK not found in PATH"
}

$Gomobile = Join-Path (go env GOPATH) "bin\gomobile.exe"
if (-not (Test-Path $Gomobile)) {
    Write-Host "Installing gomobile..."
    go install golang.org/x/mobile/cmd/gomobile@latest
    go install golang.org/x/mobile/cmd/gobind@latest
    $Gomobile = Join-Path (go env GOPATH) "bin\gomobile.exe"
}

$env:ANDROID_HOME = Join-Path $env:LOCALAPPDATA "Android\Sdk"
$env:ANDROID_SDK_ROOT = $env:ANDROID_HOME
$env:GOPROXY = "https://goproxy.cn,https://mirrors.aliyun.com/goproxy/,direct"
$env:GOSUMDB = "sum.golang.google.cn"
$env:CGO_ENABLED = "1"

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

Push-Location $GoDir
try {
    go get golang.org/x/mobile/bind@latest
    & $Gomobile init
    Write-Host "Building mobile.aar (lightweight 3X-UI client only)..."
    & $Gomobile bind -target=android -androidapi=21 -o $AarPath .
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path $AarPath)) {
        throw "gomobile bind failed - check Android SDK/NDK"
    }
    Write-Host "OK: $AarPath"
}
finally {
    Pop-Location
}
