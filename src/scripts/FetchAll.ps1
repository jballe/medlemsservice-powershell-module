#Requires -Version 6.0
param(
    [ValidateNotNullOrEmpty()]
    [String]$GroupName = $env:GROUPNAME,
    [ValidateNotNullOrEmpty()] 
    [String]$MedlemUsername = $env:MEDLEM_LOGIN_USERNAME,
    [ValidateNotNullOrEmpty()]
    [String]$MedlemPassword = $env:MEDLEM_LOGIN_PASSWORD,
    [ValidateNotNullOrEmpty()]
    $OutFile = (Join-Path $PWD "out/data.json"),
    [string]$Proxy = $env:HTTP_PROXY,
    [Array]$MemberNo,
    [Switch]$SkipFunctionDetails
)

$ErrorActionPreference = "STOP"
#$ErrorActionPreference = "Continue"

Import-Module (Join-Path $PSScriptRoot "src/Medlemsservice" -Resolve) -RequiredVersion 1.0.1 -Force

If ("" -ne "${Proxy}") {
    Write-Host "Setting proxy $Proxy"
    Set-MedlemsserviceProxy $Proxy
}

Invoke-MedlemsserviceLogin -Username $MedlemUsername -Password $MedlemPassword

$units = Get-MedlemsserviceStructure
$group = $units | Where-object { $_.organization_type_id -eq 2 -and ($_.display_name -eq $GroupName -or $GroupName -eq $Null) } | Select-Object -first 1
if ($null -eq $group) {
    Write-Host "Found groups:"
    $units | Where-Object { $_.organization_type_id -eq 2 } | Format-Table
    throw "Could not find unit for group named $GroupName"
}

Set-MedlemsserviceContextGroup $group.id

Write-Host "Fetching list of members"
$lst = Get-MedlemsserviceMemberList -GroupId $group.id -Fields member_number, name
if ($MemberNo.Length -gt 0) {
    $lst = $lst | Where-Object { $MemberNo.Contains($_.member_number) }
}
$all = @()
$count = 0
foreach($member in $lst) {
    Write-Host ("Fetching member {0} of {1}: {2} ({3})" -f ++$count, $lst.Length, $member.name, $member.member_number)
    $itm = Get-MedlemsserviceMemberDetails -GroupId $group.id -MemberId $member.id -ExpandRelations -SkipFunctionDetails:$SkipFunctionDetails
    $all += $itm
}
$data = [PSCustomObject]@{
    units   = $units | Select-Object @{name = 'name'; expression = { $_.display_name } }, id, @{name = 'type'; expression = { $_.organization_type_id[1] } }
    members = $all
}

$folder = Split-Path $OutFile -Parent
If (-not (Test-Path $folder)) { new-item -itemtype Directory $folder | Out-Null }
$data | ConvertTo-Json -Depth 10 | Set-Content -Path $OutFile -Encoding UTF8

Write-Host "Done" -ForegroundColor Green
