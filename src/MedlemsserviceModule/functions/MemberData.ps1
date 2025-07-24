$memberDefaultFields = @(
    "name",
    "member_number",
    "active_function_ids",
    "partner_id",
    "relation_all_ids",
    "email",
    "firstname",
    "lastname",
    "phone",
    "mobile",
    "permission_photo",
    "complete_address",
    "school",
    "school_class_number",
    "school_class_letter"
)

function Get-MedlemsserviceStructure {
    $result = Read-MedlemsserviceDataset -Model "member.organization" -Fields @("display_name", "organization_type_id")
    $result.records
}

function Get-MedlemsserviceMemberList {
    param(
        [Parameter(Mandatory = $true)]
        $GroupId,
        [Parameter(Mandatory = $false)]
        $StructureId = $Null,
        [Parameter(Mandatory = $false)]
        $Fields = $memberDefaultFields,
        [Parameter(Mandatory = $false)]
        [String]$MemberNo = $null,
        [Switch]$AlsoNonActive
    )

    $criteria = @(,
        @("organization_id", "=", $GroupId)
    )
    if ("" -ne "$StructureId") {
        $criteria += @(,
            @("partner_id.function_ids.organization_id", "child_of", $StructureId)
        )
    }
    If (-not $AlsoNonActive) {
        $criteria += @(,
            @("state", "=", "active")
        )
    }


    if ("" -ne "$MemberNo") {
        $criteria += @(,
            @("member_number", "=", $MemberNo)
        )
    }

    Read-MedlemsserviceDataset -Model "member.profile" -Fields $Fields -Params @{
        domain = $criteria
    } | Select-Object -ExpandProperty records
}

function Get-MedlemsserviceMember {
    param(
        [Parameter(Mandatory = $true)]
        $MemberId,
        [Parameter(Mandatory = $false)]
        $Fields = $memberDefaultFields
    )

    $params = @{
        args   = @(
            @(, $MemberId),
            $Fields
        )
        kwargs = @{
            context = @{
                bin_size     = $true
                active_model = "member.organization"
            }
        }
        method = "read"
        model  = "member.profile"
    }

    Invoke-MedlemsserviceCallRequest -Path "/web/dataset/call_kw/member.profile/read" -Params $params -ContextParameterName "kwargs"
}

function Get-MedlemsserviceMemberIdForRelation {
    param(
        $GroupId,
        $PartnerId,
        $RecordId,
        $Description
    )

    $MedlemsserviceContext = (Get-Variable -Scope Global -Name MedlemsserviceContext).Value

    $params = @{
        args   = @(, $RecordId)
        kwargs = @{
            context = @{
                default_this_partner_id          = $PartnerId

                tz                               = $MedlemsserviceContext.user_context.tz
                lang                             = $MedlemsserviceContext.user_context.lang
                uid                              = $MedlemsserviceContext.user_context.uid

                active_id                        = $GroupId
                active_ids                       = @(, $GroupId)
                relation_profile_organization_id = $GroupId
                search_default_organization_id   = $GroupId
                search_default_state             = "active"
            }
        }
        method = "action_open_profile"
        model  = "res.partner.relation.all"
    }

    try {
        $result = Invoke-MedlemsserviceCallRequest -Path "/web/dataset/call_button" -Params $params -SkipContext
        $result.res_id
    }
    catch {
        Write-Warning "Cannot open $Description"
        $Null
    }
}

function Get-MedlemsserviceMemberIdFromModelId {
    param(
        $Id,
        $Model
    )

    $params = @{
        args   = @(, $Id)
        kwargs = @{
            context = @{
            }
        }
        method = "action_open_profile"
        model  = $Model
    }

    $result = Invoke-MedlemsserviceCallRequest -Path "/web/dataset/call_button" -Params $params -ContextParameterName "kwargs"
    $result.res_id
}


function Get-MedlemsserviceRelation {
    param(
        $GroupId,
        $MemberId,
        $PartnerId,
        $RelationId,
        $Fields = @(
            "this_partner_id",
            "type_selection_id",
            "other_partner_id",
            "other_partner_mobile",
            "this_primary_contact"
        ),
        [Switch]$Expand,
        [Switch]$SkipExpandFunctionDetails
    )

    $params = @{
        method = "read"
        model  = "res.partner.relation.all"
        args   = @(
            @(, $RelationId),
            $Fields
        )
        kwargs = @{
            context = @{
                relation_profile_org    = $GroupId
                bin_size                = $True
                default_this_partner_id = $PartnerId
            }
        }
    }

    [array]$relations = Invoke-MedlemsserviceCallRequest -Path "/web/dataset/call_kw/res.partner.relation.all/read" -Params $params -ContextParameterName "kwargs"  | Where-Object { $_.GetType().IsPublic }
    $results = @()
    foreach ($relationItm in $relations) {
        $type = $relationItm.type_selection_id[1]
        $memberId = $relationItm.other_partner_id[0]
        $memberName = $relationItm.other_partner_id[1]
        $primaryContact = [Boolean]$relationItm.this_primary_contact

        $memberNo = $null
        if ($relationItm.other_partner_id[1] -match "^(?<memberno>[0-9]{6,10}) \w+") {
            $memberNo = $Matches[1]
            $memberName = $relationItm.other_partner_id[1].Substring("${memberNo}".Length + 2)
        }

        $relationMemberId = Get-MedlemsserviceMemberIdForRelation -GroupId $GroupId -MemberId $MemberId -PartnerId $PartnerId -RecordId $relationItm.id

        if ($Expand) {
            try {
                $details = Get-MedlemsserviceMemberDetail -MemberId $relationMemberId -GroupId $GroupId -SkipFunctionDetails:$SkipExpandFunctionDetails -ExpandRelations:$false -Throw
            }
            catch {
                Write-Warning ("Error while expanding $memberName ($memberNo) $_")
                $details = $Null
            }

            $results += [PSCustomObject]@{
                Type           = $type
                MemberNo       = $details.Number
                MemberName     = $memberName
                MemberId       = $details.Id
                MemberDetails  = $details
                PrimaryContact = $primaryContact
            }
        }
        else {
            $results += [PSCustomObject]@{
                Type           = $type
                MemberId       = $memberId
                MemberNo       = $memberNo
                MemberName     = $memberName
                PrimaryContact = $primaryContact
            }
        }
    }
    $results
}

function Get-MedlemsserviceMemberDetailForMemberNumber {
    param(
        [Parameter(Mandatory = $true)]
        [string]$MemberNo,
        [Parameter(Mandatory = $true)]
        $GroupId,
        $Fields = $memberDefaultFields,
        [Switch]$ExpandRelations,
        [Switch]$SkipFunctionDetails,
        [Switch]$Throw
    )

    $member = Get-MedlemsserviceMemberList -MemberNo $MemberNo -GroupId $GroupId -Fields $Fields -AlsoNonActive
    Get-MedlemsserviceMemberDetail -MemberId $member.id -GroupId $GroupId -Fields $Fields -AlsoNonActive -ExpandRelations:$ExpandRelations -SkipFunctionDetails:$SkipFunctionDetails -Throw:$Throw
}

function Get-MedlemsserviceMemberDetail {
    param(
        [Alias("MemberId")]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName)]
        [int]$Id,
        [Parameter(Mandatory = $true)]
        $GroupId,
        $Fields = $memberDefaultFields,
        [Switch]$ExpandRelations,
        [Switch]$SkipFunctionDetails,
        [Switch]$Throw
    )

    begin {
        if ($null -eq $MedlemsserviceUnits) {
            $MedlemsserviceUnits = Get-MedlemsserviceStructure
            $MedlemsserviceUnitIds = $medlemsserviceUnits | Select-object -ExpandProperty id
        }
    }

    process {
        $memberId = $Id
        $member = Get-MedlemsserviceMember -MemberId $memberId -Fields $Fields
        if ($Null -eq $member) {
            $msg = "Could not get member id: $memberId"
            if ($Throw) {
                throw $msg
            }
            else {
                Write-Warning $msg
            }
            Return
        }
        $relations = @()
        foreach ($relationId in $member.relation_all_ids) {
            $relations += Get-MedlemsserviceRelation -GroupId $GroupId `
                -MemberId $member.id -PartnerId $member.partner_id[0] `
                -RelationId $relationId `
                -Expand:$ExpandRelations `
                -SkipExpandFunctionDetails:$SkipFunctionDetails
        }
        $functionIds = @()
        $functionIds += TryGetMember -InputObject $member -Property active_function_ids
        $functions = $functionIds | ForEach-Object {
            Get-MedlemsserviceFunctionForMember -MemberId $member.id -FunctionId $_ -SkipDetails:$SkipFunctionDetails
        }

        [PSCustomObject]@{
            Id        = $member.id
            Number    = $member.member_number
            Details   = $member
            Relations = $relations
            Functions = $functions | Where-Object {
                $orgId = TryGetMember -InputObject $_ -Property OrgId
                return $Null -eq $orgId -or $MedlemsserviceUnitIds.Contains($orgId[0]) }
        }
    }
}
