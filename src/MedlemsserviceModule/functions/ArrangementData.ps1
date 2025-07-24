$defaultEventFields = @(
    "user_id",
    "name",
    "stage_id",
    "address_id",
    "date_begin",
    "date_end",
    "auto_confirm",
    "seats_unconfirmed",
    "seats_reserved",
    "seats_used",
    "seats_expected",
    "legend_blocked",
    "legend_normal",
    "legend_done",
    "activity_ids",
    "activity_state",
    "event_code",
    "website_published"
)

function Get-MedlemsserviceEventList {
    param(
        $MinDateStart = $Null,
        [Array]$Criteria = @(),
        [Array]$Fields = $defaultEventFields,
        [Switch]$Future
    )

    if ($Null -eq $Criteria) {
        $Criteria = @()
    }

    if ($Null -ne $MinDateStart) {
        $Criteria += , @("date_end", ">=", $MinDateStart.ToString("yyyy-MM-ddThh:mm:ss.000Z") )
    }

    if ($Future) {
        $Criteria += , @("date_end", ">=", (Get-Date).ToString("yyyy-MM-ddThh:mm:ss.000Z") )
    }

    Read-MedlemsserviceDataset -Model "event.event" -Fields $Fields -Params @{
        domain = $criteria
    } | Select-Object -ExpandProperty records
}
