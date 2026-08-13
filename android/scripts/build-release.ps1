#Requires -Version 5.1
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$FlutterDir = Join-Path $Root "flutter"
$Dist = Join-Path $Root "dist"

$env:FLUTTER_STORAGE_BASE_URL = "https://storage.flutter-io.cn"
$env:PUB_HOSTED_URL = "https://pub.flutter-io.cn"
$env:GOPROXY = "https://goproxy.cn,https://mirrors.aliyun.com/goproxy/,direct"
$env:GOSUMDB = "sum.golang.google.cn"
$env:ANDROID_HOME = Join-Path $env:LOCALAPPDATA "Android\Sdk"
$env:ANDROID_NDK_HOME = Join-Path $env:ANDROID_HOME "ndk\27.0.12077973"

$JdkPath = "C:\Program Files\Microsoft\jdk-17.0.19.10-hotspot"
if (Test-Path $JdkPath) {
    $env:JAVA_HOME = $JdkPath
    $env:PATH = "$JdkPath\bin;" + $env:PATH
}

$FlutterBin = "C:\Users\Amir\flutter\bin"
if (Test-Path $FlutterBin) {
    $env:PATH = "$FlutterBin;" + $env:PATH
}

& (Join-Path $PSScriptRoot "setup-gradle-mirror.ps1")
& (Join-Path $PSScriptRoot "build-gomobile.ps1")
if ($LASTEXITCODE -ne 0) { throw "gomobile build failed" }

$KeyProps = Join-Path $FlutterDir "android\key.properties"
if (-not (Test-Path $KeyProps)) {
    throw "Missing android/key.properties. Copy key.properties.example or run scripts/create-release-keystore.ps1"
}

Push-Location $FlutterDir
try {
    flutter pub get
    flutter build apk --release --target-platform android-arm64
    if ($LASTEXITCODE -ne 0) { throw "flutter build failed" }

    New-Item -ItemType Directory -Force -Path $Dist | Out-Null
    $Apk = Join-Path $FlutterDir "build\app\outputs\flutter-apk\app-release.apk"
    $Pubspec = Join-Path $FlutterDir "pubspec.yaml"
    $versionLine = (Get-Content $Pubspec | Where-Object { $_ -match '^version:\s*' } | Select-Object -First 1)
    $version = if ($versionLine -match 'version:\s*([0-9.]+)') { $Matches[1] } else { '1.1.3' }
    $Out = Join-Path $Dist "BlackFox-ConfigBuilder-Android-$version.apk"
    Copy-Item $Apk $Out -Force

    $PlayDir = Join-Path $Root "Black Fox Config Builder 4 Play Store"
    New-Item -ItemType Directory -Force -Path $PlayDir | Out-Null
    Copy-Item $Apk (Join-Path $PlayDir "Black Fox Config Builder-arm64-v8a.apk") -Force
    Copy-Item $Apk (Join-Path $Root "Black Fox Config Builder.apk") -Force

    $sizeMb = [math]::Round((Get-Item $Out).Length / 1MB, 1)
    Write-Host ""
    Write-Host "SUCCESS: $Out ($sizeMb MB)"
    Write-Host "SUCCESS: $(Join-Path $PlayDir 'Black Fox Config Builder-arm64-v8a.apk')"
    Write-Host "SUCCESS: $(Join-Path $Root 'Black Fox Config Builder.apk')"
}
finally {
    Pop-Location
}
