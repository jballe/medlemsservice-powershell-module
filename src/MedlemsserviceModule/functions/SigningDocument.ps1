$defaultDocumentFields = @(
    "id"
    "state",
    "document_type_id",
    "organization_id",
    "partner_ids",
    "state_public"
)

function Get-MedlemsserviceSigningDocument {
    param(
        $Fields = $defaultDocumentFields,
        [Array]$Criteria = @(),
        [int]$DocumentTypeId = $Null,
        [Switch]$Completed
    )

    If ($DocumentTypeId -ne $Null) {
        $Criteria += , @("document_type_id", "=", $DocumentTypeId)
    }

    If ($Completed) {
        $Criteria += , @("state", "=", "completed")
    }

    $finalCriteria = @("&") + $Criteria
    $model = "sg.document"

    Read-MedlemsserviceDataset -Model $model -Fields $Fields -Params @{
        domain  = $finalCriteria
    } | Select-Object -ExpandProperty records `
}
