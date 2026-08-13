#Requires -Version 5.1
$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
$AndroidDir = Join-Path $Root "flutter\android"
$KeystorePath = Join-Path $AndroidDir "app\config-builder-release.jks"
$KeyProps = Join-Path $AndroidDir "key.properties"

if (Test-Path $KeystorePath) {
    Write-Host "Keystore already exists: $KeystorePath"
    exit 0
}

$pass = Read-Host "Enter keystore password (min 6 chars)"
if ([string]::IsNullOrWhiteSpace($pass) -or $pass.Length -lt 6) {
    throw "Password must be at least 6 characters."
}

$keytool = Join-Path $env:JAVA_HOME "bin\keytool.exe"
if (-not (Test-Path $keytool)) {
    $keytool = "keytool"
}

& $keytool -genkeypair -v `
    -storetype PKCS12 `
    -keyalg RSA `
    -keysize 2048 `
    -validity 10000 `
    -alias configbuilder `
    -keystore $KeystorePath `
    -storepass $pass `
    -keypass $pass `
    -dname "CN=Black Fox Config Builder, OU=Mobile, O=Black Fox Group, L=Tehran, ST=Tehran, C=IR"

@"
storePassword=$pass
keyPassword=$pass
keyAlias=configbuilder
storeFile=config-builder-release.jks
"@ | Set-Content -Path $KeyProps -Encoding UTF8

Write-Host "Created:"
Write-Host "  $KeystorePath"
Write-Host "  $KeyProps"
