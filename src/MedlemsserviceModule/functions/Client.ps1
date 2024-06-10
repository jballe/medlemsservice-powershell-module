New-Variable -Name MedlemsserviceUrl -Value "https://medlemsservice.spejdernet.dk" -Scope Global -Force
New-Variable -Name MedlemsserviceSession -Value $Null -Scope Global -Force
New-Variable -Name MedlemsserviceContext -Value $Null -Scope Global -Force
New-Variable -Name MedlemsserviceContextGroup -Value $Null -Scope Global -Force
New-Variable -Name MedlemsserviceRequestCount -Value 0 -Scope Global -Force
New-Variable -Name ClientDefaultProperties -Scope Global -Force -Value @{
    Proxy       = $Null
    ContentType = "application/json"
    Headers     = @{
        "X-Requested-With" = "XMLHttpRequest"
    }
    Verbose = $False
    SkipCertificateCheck = $False
}

function Set-MedlemsserviceUrl {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification='No side effects')]
    [CmdletBinding()]
    param($ServerUrl)

    Set-Variable -Scope Global -Name MedlemsserviceUrl -Value $ServerUrl | Out-Null
}

function Get-MedlemsserviceUrl {
    return (Get-Variable -Scope Global -Name MedlemsserviceUrl).Variable
}

function Set-MedlemsserviceContextGroup {
    [CmdletBinding()]
    param([int]$Id)

    Set-Variable -Scope Global -Name MedlemsserviceContextGroup -Value $Id | Out-Null

}

function Set-MedlemsserviceProxy {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification='No side effects')]
    param(
        [Parameter(Mandatory=$True, Position=0)]
        $Uri
    )

    $cfg = $(Get-Variable -Scope Global -Name ClientDefaultProperties).Value
    $cfg.Proxy = $Uri
    Set-Variable -Scope Global -Name ClientDefaultProperties -Value $cfg | Out-Null
}

function Invoke-MedlemsserviceLogin {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('AvoidUsingPlainTextForPassword', 'Password')]
    param(
        $Username,
        $Password
    )

    If("$Username" -eq "" -or "$Password" -eq "") {
        throw "Username and password must be specified"
    }

    $MedlemsserviceSession = $Null
    $response = Invoke-WebRequest -SessionVariable "MedlemsserviceSession" -uri "${MedlemsserviceUrl}/web/login" -Method GET -UseBasicParsing -Proxy $ClientDefaultProperties.Proxy -SkipCertificateCheck:$ClientDefaultProperties.SkipCertificateCheck
    $isMatch = $response.Content -match "csrf_token: `"([^`"]+)`""
    $csrfToken = $Matches[1]
    if(-not $isMatch -or "" -eq "${csrfToken}") {
        throw "Could not get CSRF Token"
    }

    $formData = @{
        login = $Username
        password = $Password
        csrf_token = $csrfToken
        redirect = ""
    }
    $loginResult = Invoke-WebRequest -WebSession $MedlemsserviceSession -uri "${MedlemsserviceUrl}/web/login" -Method POST -ContentType "application/x-www-form-urlencoded" -Body $formData -Proxy $ClientDefaultProperties.Proxy -SkipCertificateCheck:$ClientDefaultProperties.SkipCertificateCheck
    if($loginResult.StatusCode -ne 200) {
        throw ("Unexpected login response status code {0}: {1}" -f $loginResult.StatusCode, $loginResult.Content)
    }

    $isExpectedMatch = $loginResult.Content -match "odoo\.__session_info__"
    if(-not ($isExpectedMatch)) {
        Write-Warning "Unexpected response from login POST call"
        $loginResult.Content | Write-Warning
        throw "Could not login"
    }

    Set-Variable -Scope Global -Name MedlemsserviceSession -Value $MedlemsserviceSession | Out-Null
    #Write-Host ("Login gave status {0}" -f $loginResult.StatusCode)
    #$loginResult.Headers | Format-Table

    $MedlemsserviceContext = Invoke-MedlemsserviceCallRequest -Path "/web/session/get_session_info" -SkipContext | Where-Object { $_.GetType().IsPublic }
    Set-Variable -Scope Global -Name MedlemsserviceContext -Value $MedlemsserviceContext | Out-Null
}

function TryGetMember {
    param(
        [Parameter(Mandatory=$True, Position=0)]
        $InputObject,
        [Parameter(Mandatory=$True, Position=1)]
        $PropertyName
    )

    try {
        $InputObject.$propertyName
    } catch {
        $Null
    }
}

function Invoke-MedlemsserviceCallRequest {
    [CmdletBinding(SupportsShouldProcess=$false)]
    param(
        $Path,
        $Params = @{},
        $ContextParameterName = $Null,
        [Switch]$SkipContext
    )

    $MedlemsserviceRequestCount = (Get-Variable -Scope Global -Name MedlemsserviceRequestCount).Value
    $MedlemsserviceRequestCount += 1 
    Set-Variable -Scope Global -Name MedlemsserviceRequestCount -Value $MedlemsserviceRequestCount | Out-Null

    $req = @{
        jsonrpc = "2.0"
        id = $MedlemsserviceRequestCount
        method  = "call"
        params  = $Params
    }

    $MedlemsserviceContext = (Get-Variable -Scope Global -Name MedlemsserviceContext).Value
    $MedlemsserviceContextGroup = (Get-Variable -Scope Global -Name MedlemsserviceContextGroup).Value
    $MedlemsserviceSession = (Get-Variable -Scope Global -Name MedlemsserviceSession).Value
    $ClientDefaultProperties = (Get-Variable -Scope Global -Name ClientDefaultProperties).Value

    If (-not $SkipContext -and $Null -ne $MedlemsserviceContext) {
        $value = $req.params
        if ($Null -ne $ContextParameterName) { $value = $value.$ContextParameterName }
        If ($Null -eq ( TryGetMember -InputObject $value -PropertyName "context")) { $value.context = @{} }
        $value = $value.context
        $value.tz = $MedlemsserviceContext.user_context.tz
        $value.lang = $MedlemsserviceContext.user_context.lang
        $value.uid = $MedlemsserviceContext.user_context.uid
        $value.allowed_company_ids = @($MedlemsserviceContextGroup)
        if($Null -ne $MedlemsserviceContextGroup) {
            $value.active_id = $MedlemsserviceContextGroup
            $value.active_ids = @(,$MedlemsserviceContextGroup)
            $value.search_default_organization_id = $MedlemsserviceContextGroup
            $value.search_default_state = "active"
        }
    }

    $body = $req | ConvertTo-Json -Depth 10
    #$result = Invoke-RestMethod -WebSession $MedlemsserviceSession `
    $response = Invoke-WebRequest -WebSession $MedlemsserviceSession -UseBasicParsing `
        -Uri "${MedlemsserviceUrl}${Path}" `
        -Method POST -Body $body `
        @ClientDefaultProperties

    #Write-Host ("Response headers from POST request to {0} with result {1} are:" -f $Path, $response.StatusCode)
    #$response.Headers
    #Write-Host "Content:"
    #Write-Host $response.Content

    $result = $response.Content | ConvertFrom-Json

    if ($result.PSObject.Properties.Name -contains "error") {
        Write-Error $result.error.data.message
        throw $result.error
    }
    else {
        return $result.result
    }
}
