#Requires -Version 6.0
Set-StrictMode -Version 3.0

New-Variable -Name MedlemsserviceUnits -Value $Null -Scope Script -Force
New-Variable -Name MedlemsserviceUnitIds -Value $Null -Scope Script -Force

$files = @(Get-ChildItem -Path $PSScriptRoot -Include "*.ps1" -File -Recurse)

($files) | ForEach-Object {
    try
    {
        Write-Verbose "Importing $_"
        . $_.FullName
    }
    catch
    {
        Write-Error $_.Exception.Message
    }
}
