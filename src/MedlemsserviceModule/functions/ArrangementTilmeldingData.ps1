$defaultFields = @(
    "state",
    "name",
    "display_name",
    "partner_id",
    "email",
    "phone",
    "mobile",
    "payment_state",
    "invoice_diff",
    "payer_organization_id",

    #"confirm_email",
    #"confirm_mobile",
    #"confirm_name",
    #"confirm_public_name",
    #"date_open",
    #"date_closed",

    "emergency_contact",
    "event_question_response_ids",
    "participant_department_organization_id",
    "participant_local_organization_id",
    "participant_regional_organization_id",
    "participant_sub_regional_organization_id",

    "create_date",
    "cancel_date",
    "date_open",
    "visitor_id",
    "can_read_partner",
    "event_id",
    "sale_order_id",
    "event_ticket_id",
    "master",
    "payment_method",
    "refund_state",
    "payer_organization_id",
    "participant_data_changed",
    "company_id",
    "message_needaction",
    "activity_exception_decoration",
    "activity_exception_icon"
)

function Get-MedlemsserviceEventRegistrationList {
    param(
        [Parameter(Mandatory = $True)]
        $EventId,
        $Fields = $defaultFields,
        [Array]$Criteria = @(),
        [Switch]$Forventede,
        [Switch]$FetchQuestionResponse,
        [Switch]$ExpandQuestionResponse
    )

    if ($Null -eq $Criteria) {
        $Criteria = @("&")
    }

    $Criteria += , @("event_id", "=", $EventId)

    If ($Forventede) {
        $Criteria += , @("state", "in", @("manual", "waitinglist", "open", "done"))
    }

    $finalCriteria = $Criteria

    Read-MedlemsserviceDataset -Model "event.registration" -Fields $Fields -Params @{
        domain  = $finalCriteria
        context = @{
            active_ids       = @($EventId)
            active_id        = $EventId
            default_event_id = $EventId
            event_event_id   = $EventId
        }
    } | Select-Object -ExpandProperty records `
    | Invoke-MedlemsserviceEventRegistrationMapping -FetchQuestionResponse:$FetchQuestionResponse -ExpandQuestionResponse:$ExpandQuestionResponse
}

function Get-MedlemsserviceEventRegistrationDetail {
    param(
        [Parameter(Mandatory = $True)]
        $RegistrationId,
        $Fields = @(
            "can_approve",
            "can_edit",
            "is_paid",
            "partner_id",
            "visitor_id",
            "name",
            "participant_data_changed",
            "ask_name",
            "ask_address",
            "ask_phone",
            "ask_mobile",
            "ask_email",
            "street_name",
            "street_number",
            "street_floor",
            "street_placement",
            "street2",
            "address_co",
            "zip",
            "city",
            "email",
            "phone",
            "mobile",
            "ask_emergency_contact",
            "ask_birthdate",
            "ask_gender",
            "ask_schoolclass",
            "emergency_contact",
            "birthdate",
            "gender",
            "ask_other_info",
            "other_info",
            "ask_permission_photo",
            "permission_photo",
            "ask_organization",
            "participant_regional_organization_id",
            "participant_sub_regional_organization_id",
            "participant_local_organization_id",
            "participant_department_organization_id",
            "can_read_partner",
            "event_id",
            "state",
            "cancel_date",
            "invoice_id",
            "organization_invoice_id",
            "price_original",
            "price",
            "refund_amount",
            "refund_state",
            "refund_invoice_id",
            "payment_method",
            "payer_organization_id",
            "payer_other",
            "payment_state",
            "payment_approved_by",
            "payment_approved_date",
            "event_ticket_id",
            "date_open",
            "date_closed",
            "sale_order_id",
            "sale_order_line_id",
            "utm_campaign_id",
            "utm_medium_id",
            "utm_source_id",
            "confirm_name",
            "confirm_email",
            "confirm_mobile",
            "registration_master_id",
            "registration_individual_ids",
            "consent_public_name",
            "event_question_response_ids",
            "installment_invoice_ids",
            "message_follower_ids",
            "activity_ids",
            "message_ids",
            "display_name"
        )
    )

    $method = "read"
    $model = "event.registration"

    $params = @{
        method = $method
        model  = $model
        args   = @(
            @(, $RegistrationId),
            $Fields
        )
        kwargs = @{
            context = @{
                active_id    = $RegistrationId
                active_ids   = @(, $RegistrationId)
                active_model = $model
                bin_size     = $True
            }
        }
    }

    $details = Invoke-MedlemsserviceCallRequest -Path "/web/dataset/call_kw/${model}/${method}" -Params $params -ContextParameterName "kwargs"  | Where-Object { $_.GetType().IsPublic }
    $details.RegistrationId = $details.id
    $details.QuestionResponseIds = $details.event_question_response_ids
}

function Get-MedlemsserviceEventRegistrationQuestionResponse {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName)]
        $EventRegistrationId,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName)]
        [Array]$QuestionResponseIds,
        $Fields = @("event_question_id", "event_question_option_id", "response_format")
    )
    
    begin {
        $method = "read"
        $model = "event.question.response"
    }
    process {
        $params = @{
            method = $method
            model  = $model
            args   = @(
                $QuestionResponseIds,
                $Fields
            )
            kwargs = @{
                context = @{
                    active_id                = $EventRegistrationId
                    active_ids               = @(, $EventRegistrationId)
                    restrict_registration_id = $EventRegistrationId
                    active_model             = $model
                    bin_size                 = $True
                }
            }
        }
    
        $details = Invoke-MedlemsserviceCallRequest -Path "/web/dataset/call_kw/${model}/${method}" -Params $params -ContextParameterName "kwargs"  | Where-Object { $_.GetType().IsPublic }
        $details | ForEach-Object {
            $_ | AddOrSetPropertyValue -PropertyName "question" -Value $_.event_question_id[1]
            if ($_.response_format -ne $False) {
                $_  | AddOrSetPropertyValue -PropertyName "response" -Value $_.response_format
            }
            else {
                $_  | AddOrSetPropertyValue -PropertyName "response" -Value $_.event_question_option_id[1]
            }
            $_
        }
    }
}

function Invoke-MedlemsserviceEventRegistrationMapping {
    param(
        [Parameter(Mandatory = $True, ValueFromPipeline)]
        $EventRegistration,
        [Switch]$FetchQuestionResponse,
        [Switch]$ExpandQuestionResponse
    )

    process {
        $EventRegistration | AddOrSetPropertyValue -PropertyName "EventRegistrationId" -Value $EventRegistration.id
        if ($EventRegistration.PSObject.Properties.Name -contains "event_question_response_ids") {
            $EventRegistration | AddOrSetPropertyValue -PropertyName "QuestionResponseIds" -Value $EventRegistration.event_question_response_ids
        }

        if ($EventRegistration.PSObject.Properties.Name -contains "participant_department_organization_id" -and $EventRegistration.participant_department_organization_id -ne $False) {
            $EventRegistration | AddOrSetPropertyValue -PropertyName OrganizationDepartment -Value $EventRegistration.participant_department_organization_id[1]
        }
        if ($EventRegistration.PSObject.Properties.Name -contains "participant_local_organization_id" -and $EventRegistration.participant_local_organization_id -ne $False) {
            $EventRegistration | AddOrSetPropertyValue -PropertyName OrganizationLocal -Value $EventRegistration.participant_local_organization_id[1]
        }
        if ($EventRegistration.PSObject.Properties.Name -contains "participant_regional_organization_id" -and $EventRegistration.participant_regional_organization_id -ne $False) {
            $EventRegistration | AddOrSetPropertyValue -PropertyName OrganizationRegional -Value $EventRegistration.participant_regional_organization_id[1]
        }
        if ($EventRegistration.PSObject.Properties.Name -contains "participant_sub_regional_organization_id" -and $EventRegistration.participant_sub_regional_organization_id -ne $False) {
            $EventRegistration | AddOrSetPropertyValue -PropertyName OrganizationSubRegional -Value $EventRegistration.participant_sub_regional_organization_id[1]
        }


        if ($ExpandQuestionResponse -or $FetchQuestionResponse) {
            $response = $EventRegistration | Get-MedlemsserviceEventRegistrationQuestionResponse
            $EventRegistration | AddOrSetPropertyValue -PropertyName "QuestionResponse" -Value $response
        }

        if ($ExpandQuestionResponse) {
            $EventRegistration.QuestionResponse | ForEach-Object {
                $EventRegistration | AddOrSetPropertyValue -PropertyName $_.question -Value $_.response
            }
        }
    
        $EventRegistration
    }
}
