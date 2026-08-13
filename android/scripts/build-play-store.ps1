#Requires -Version 5.1
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$FlutterDir = Join-Path $Root "flutter"
$PlayDir = Join-Path $Root "Black Fox Config Builder 4 Play Store"

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

$AarPath = Join-Path $FlutterDir "android\app\libs\mobile.aar"
if (-not (Test-Path $AarPath)) {
    & (Join-Path $PSScriptRoot "setup-gradle-mirror.ps1")
    & (Join-Path $PSScriptRoot "build-gomobile.ps1")
    if ($LASTEXITCODE -ne 0) { throw "gomobile build failed" }
}

$KeyProps = Join-Path $FlutterDir "android\key.properties"
if (-not (Test-Path $KeyProps)) {
    throw "Missing android/key.properties"
}

Push-Location $FlutterDir
try {
    flutter pub get
    if ($LASTEXITCODE -ne 0) { throw "flutter pub get failed" }

    Write-Host "Building split APKs (arm64, armeabi-v7a, x86_64)..."
    flutter build apk --release --split-per-abi
    if ($LASTEXITCODE -ne 0) { throw "flutter build apk --split-per-abi failed" }

    Write-Host "Building App Bundle (AAB)..."
    flutter build appbundle --release
    if ($LASTEXITCODE -ne 0) { throw "flutter build appbundle failed" }

    $ApkDir = Join-Path $FlutterDir "build\app\outputs\flutter-apk"
    $BundleDir = Join-Path $FlutterDir "build\app\outputs\bundle\release"
    New-Item -ItemType Directory -Force -Path $PlayDir | Out-Null

    $copies = @(
        @{ Src = Join-Path $ApkDir "app-arm64-v8a-release.apk"; Dst = "Black Fox Config Builder-arm64-v8a.apk" },
        @{ Src = Join-Path $ApkDir "app-armeabi-v7a-release.apk"; Dst = "Black Fox Config Builder-armeabi-v7a.apk" },
        @{ Src = Join-Path $ApkDir "app-x86_64-release.apk"; Dst = "Black Fox Config Builder-x86_64.apk" },
        @{ Src = Join-Path $BundleDir "app-release.aab"; Dst = "Black Fox Config Builder.aab" }
    )

    foreach ($item in $copies) {
        if (-not (Test-Path $item.Src)) {
            throw "Missing build output: $($item.Src)"
        }
        $dest = Join-Path $PlayDir $item.Dst
        Copy-Item $item.Src $dest -Force
        $sizeMb = [math]::Round((Get-Item $dest).Length / 1MB, 1)
        Write-Host "SUCCESS: $dest ($sizeMb MB)"
    }
}
finally {
    Pop-Location
}
