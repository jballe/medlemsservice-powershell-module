$defaultMemberFunctionFields = @(
    "id",
    "active",
    "top_info",
    "partner_id",
    "organization_id",
    "function_type_id",
    "func_org_name",
    "display_name",
    "leader_function"
)

function Get-MedlemsserviceMemberFunction {
    param(
        [Array]$Criteria = @(),
        [Array]$Fields = $defaultMemberFunctionFields
    )

    if ($Null -eq $Criteria) {
        $Criteria = @()
    }

    $model = "member.function"

    $params = @{
        domain = $Criteria
    }

    $result = Read-MedlemsserviceDataset -Model $model -Fields $Fields -Params $params
    $result | Select-Object -ExpandProperty records
}

function Get-MedlemsserviceFunctionForMember {
    param(
        $MemberId,
        $FunctionId,
        $Fields = $defaultMemberFunctionFields,
        [Switch]$SkipDetails
    )

    $params = @{
        method = "read"
        model  = "member.function"
        args   = @(
            @(, $FunctionId),
            $Fields
        )
        kwargs = @{
            context = @{
                bin_size      = $True
                limit_profile = $MemberId
            }
        }
    }

    $result = Invoke-MedlemsserviceCallRequest -Path "/web/dataset/call_kw/member.function/read" -Params $params -ContextParameterName "kwargs" | Where-Object { $_.GetType().IsPublic }
    $result | ForEach-Object {
        $details = $_
        if ($SkipDetails) {
            $details = $Null
        }
        [PSCustomObject]@{
            Unit     = $_.organization_id[1]
            Function = $_.function_type_id[1]
            IsLeader = $_.leader_function
            OrgId    = $_.organization_id[0]
            Details  = $details
        }
    }
}
