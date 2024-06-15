[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', 'MedlemPassword', Justification = 'Obsolete')]
param(
    [String]$MedlemUsername = $env:MEDLEM_USERNAME,
    [String]$MedlemPassword = $env:MEDLEM_PASSWORD,
    [String]$MedlemUrl = "https://medlemsservice.spejdernet.dk",
    $Destination = "./out"
)

$ErrorActionPreference = "STOP"
Import-Module (Join-Path $PSScriptRoot "../src/MedlemsserviceModule" -Resolve) -RequiredVersion 1.0.0 -Force
Set-MedlemsserviceUrl -ServerUrl $MedlemUrl
Invoke-MedlemsserviceLogin -Username $MedlemUsername -Password $MedlemPassword

If(-not (Test-Path $Destination -PathType Container)) {
    New-Item $Destination -ItemType Directory
}

$models = @(
    "member.organization",
    "member.organizationtype",
    "member.profile",
    "member.function",
    "res.partner"
    "res.partner.relation.all",
    "event.event",
    "event.registration"
)

foreach($model in $models) {
    Get-MedlemsserviceModelFields -Model $model | ConvertTo-Json | Set-Content -Path "model.${model}.json"
}
