# Medlemsservice

> This is a Powershell module to interact with system for members of [KFUM-Spejderne i Danmark](https://www.kfumspejderne.dk), De Grønne Pigespejdere, Baptistspejderne i Danmark og FDF Frivilligt Drenge og Pigeforbund. The member system is custom built based on Odoo. You will need access to the system. The following description will be in danish.

## Baggrund

Odoo har en funktion for server til server kald, XML-RPC, men dette er ikke aktiveret i Medlemsservice.
Derfor er dette Powershell modul bygget så det laver kald på samme måde som når man logger ind i browseren.

I det store hele er det "bare" en wrapper omkring de kald, så resultatet bliver bare returneret med de property navne og objekter som der kommer fra serveren og der er ikke nogen mapping eller type beskrivelse her.

Vi bruger dette til at bygge maillister baseret på funktioner, så enhederne kan skrive til en bestemt mailadresse fremfor at sende mails med Medlemsservice

## Installation

Powershell modulet ligger på [det offentlige Powershell Galleri](https://www.powershellgallery.com/packages/MedlemsserviceModule/0.1.0). Du skal derfor kunne installere moduler derfra:

```powershell
# Tillad at køre powershell scripts
Set-ExecutionPolicy Unrestricted
# Installer PSResourceGet som PSGallery er baseret på
Install-Module Microsoft.PowerShell.PSResourceGet -Repository PSGallery -Force
# Registrer PSGallery, kør Unregister først hvis det allerede er registreret uden Trusted
UnRegister-PSResourceRepository -Name PSGallery -ErrorAction SilentlyContinue | Out-Null
Register-PSResourceRepository -psgallery -Trusted
```

Derefter er det bare at installere og importere modulet:

```powershell
Install-Module -Name MedlemsserviceModule -Repository PSGallery -AllowPrerelease -AcceptLicense -Force -SkipPublisherCheck
Import-Module MedlemsserviceModule
```

## Login

Du skal angive adressen til det system der er relevant for dig/dit korps/forbund/organisation. Her er det [kursus systemet](https://medlemsservice.nu/faq/er-der-et-sted-jeg-kan-oeve-mig-uden-at-oedelaegge-noget/) for KFUM-Spejderne.

For alm. login med brugernavn og password:

```powershell
Set-MedlemsserviceUrl "https://mskursus.spejdernet.dk"
Invoke-MedlemsserviceLogin -Username $MedlemUsername -Password $MedlemPassword
```

## Typer af kald

### Helt low level

* __Invoke-MedlemsserviceCallRequest__ Denne håndterer det basale, eks. det fortløbne request nummer og context
* __Read-MedlemsserviceDataset__ Mange kald for at få lister er til ``/web/dataset/search_read``. Denne metode gør det lidt enklere
* __Invoke-MedlemsserviceExport__ Eksport i Medlemsservice er meget effektiv, med denne kan en eksport laves fra powershell til eks. Csv

## Arrangementer

```powershell
# Liste over fremtidige sommerlejre
$events = Get-MedlemsserviceEventList -Fields @("name") -Criteria @(,@("name", "ilike", "sommerlejr"))  -MinDateStart (Get-Date)
# Alle deltagere inkl. svar på brugerdefinerede spørgsmål
$participants = $events | Get-MedlemsserviceEventRegistrationList -FetchQuestionResponse -Forventede -Fields @("name")
```

## Medlemmer



## Hvis du har adgang til flere grupper/organisatoriske enheder

```
$contextForKorps = 1
Set-MedlemsserviceContextGroup $contextForKorps
```

Listen over grupper som man kan vælge mellem på web kan ses med:

```powershell
(Get-MedlemsserviceSessionContext).user_companies.allowed_companies.psobject.properties.Value | Format-Table id, name
```

## Noget virker ikke

Det kan ske... jeg prøver at følge med, ikke mindst til det jeg/vi selv bruger, men det kan ske at der er fejl...

Hvis jeg skal undersøge noget så bruger jeg en proxy, eks. [Burp](https://portswigger.net/burp) og konfigurerer modulet til at sende alle requests der igennem for at følge med.

```powershell
Set-MedlemsserviceProxy http://127.0.0.1:8080 -SkipCertificateCheck
```