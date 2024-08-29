enum ExportType {
    Csv
    Xls
}

function Invoke-MedlemsserviceExport {
    param(
        [Parameter(Mandatory = $True)]
        [string]$ModelType,

        [Parameter(Mandatory = $True)]
        [Array]$Fields,

        [Array]$Ids = $Null,

        [ExportType]$ResultType = "Csv",

        [Array]$Criteria
    )

    $MedlemsserviceContext = (Get-Variable -Scope Global -Name MedlemsserviceContext).Value
    if($Null -eq $Ids) {
        $idParam = $false
    } else {
        $idParam = @() + $Ids
    }

    $dataObj = @{
        model = $ModelType
        fields = $Fields
        domain = $Criteria
        ids = $idParam
        groupby = @()
        context = @{
            tz = $MedlemsserviceContext.user_context.tz
            lang = $MedlemsserviceContext.user_context.lang
            uid = $MedlemsserviceContext.user_context.uid
            allowed_company_ids = @($MedlemsserviceContextGroup)
        }
        import_compat = $false
    }

    $urlpath = "/web/export/{0}" -f $ResultType.ToString().ToLower()
    Invoke-MedlemsserviceFormDataRequest -UrlPath $urlpath  -DataObject $dataObj
}

function Get-MedlemsserviceExportFieldModel {
    param(
        [Parameter(Mandatory=$true)]
        $Model,

        [switch]$ImportCompatible
    )

    $params = @{
        model = $Model
        import_compat = $ImportCompatible.IsPresent
    }

    Invoke-MedlemsserviceCallRequest -Path "/web/export/get_fields" -SkipContext -Params $params
}

#  Get-MedlemsserviceExportChildFields -Model "event.question.response" -ParentFieldName "event_question_response_ids"
function Get-MedlemsserviceExportChildFieldModel {
    param(
        [Parameter(Mandatory=$true)]
        $Model,

        $ParentFieldType = "one2many",

        $ParentFieldName,

        [switch]$ImportCompatible
    )

    $params = @{
        model = $Model
        import_compat = $ImportCompatible.IsPresent
        parent_field_type = $ParentFieldType
        prefix = $ParentFieldName
    }

    Invoke-MedlemsserviceCallRequest -Path "/web/export/get_fields" -SkipContext -Params $params
}
