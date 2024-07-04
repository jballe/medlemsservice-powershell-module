function Read-MedlemsserviceDataset {
    param(
        [Parameter(Mandatory=$true)]
        $Model, 
    
        [Parameter(Mandatory=$true)]
        [Array]$Fields, 
    
        $Params=@{}, 
        $Limit = 1000, 
        $Offset = 0, 
        $Sort = ""
    )

    $Params.model = $Model
    $Params.offset = $Offset
    $Params.limit = $Limit
    $Params.sort = $Sort
    $Params.fields = $Fields

    $result = Invoke-MedlemsserviceCallRequest -Path "/web/dataset/search_read" -Params $Params
    return $result | Where-Object { $_.GetType().IsPublic }
}

function Get-MedlemsserviceFieldModel {
    param(
        [Parameter(Mandatory=$true)]
        $Model
    )

    Invoke-MedlemsserviceCallRequest -Path "/web/dataset/call_kw/${Model}/fields_get" -Params @{
        model = $Model
        method = "fields_get"
        args = @()
        kwargs = @{
            context = @{
                active_model = $Model
                show_org_path = $True
            }
        }
    } -ContextParameterName "kwargs" | Where-Object { $_.GetType().IsPublic }
}
