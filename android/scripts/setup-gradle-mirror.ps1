#Requires -Version 5.1
$ErrorActionPreference = "Stop"

$InitSrc = Join-Path $PSScriptRoot "gradle-mirror-init.gradle"
$InitDstDir = Join-Path $env:USERPROFILE ".gradle"
$InitDst = Join-Path $InitDstDir "init.gradle"
New-Item -ItemType Directory -Force -Path $InitDstDir | Out-Null
Copy-Item -Force $InitSrc $InitDst
Write-Host "Gradle mirror init: $InitDst"

$FlutterGradleSettings = "C:\Users\Amir\flutter\packages\flutter_tools\gradle\settings.gradle.kts"
if (-not (Test-Path $FlutterGradleSettings)) {
    Write-Host "Flutter gradle settings not found; skipping patch."
    exit 0
}

$content = Get-Content $FlutterGradleSettings -Raw
if ($content -match "maven.aliyun.com/repository/google") {
    Write-Host "Flutter gradle settings already patched."
    exit 0
}

$patch = @"
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        google()
        mavenCentral()
    }
}
"@

Set-Content -Path $FlutterGradleSettings -Value $patch -Encoding UTF8
Write-Host "Patched Flutter gradle settings: $FlutterGradleSettings"
