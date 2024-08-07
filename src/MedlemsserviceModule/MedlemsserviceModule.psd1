#
# Module manifest for module 'MedlemsserviceModule'
#
# Generated by: Jesper Balle
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'MedlemsserviceModule.psm1'

# Version number of this module.
ModuleVersion = '1.0.0'

# Supported PSEditions
CompatiblePSEditions = 'Core'

# ID used to uniquely identify this module
GUID = 'b368c22c-4492-4711-97dd-84e63bfceed5'

# Author of this module
Author = 'Jesper Balle'

# Company or vendor of this module
CompanyName = 'Jesper Balle'

# Copyright statement for this module
Copyright = '(c) Jesper Balle. All rights reserved. LGPL'

# Description of the functionality provided by this module
Description = 'Client for interacting with Medlemsservice I/S'

# Minimum version of the PowerShell engine required by this module
PowerShellVersion = '6.0'

# Name of the PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# ClrVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = @(
    "Set-MedlemsserviceUrl",
    "Get-MedlemsserviceUrl",
    "Set-MedlemsserviceProxy",

    "Get-MedlemsserviceContextGroup",
    "Set-MedlemsserviceContextGroup",
    "Invoke-MedlemsserviceLogin",
    "Get-MedlemsserviceSessionContext",

    "Get-MedlemsserviceFieldModel",

    "Get-MedlemsserviceStructure",
    "Get-MedlemsserviceMemberList"
    "Get-MedlemsserviceMember",
    "Get-MedlemsserviceMemberDetail",

    # Functions
    "Get-MedlemsserviceMemberFunction",

    # Events
    "Get-MedlemsserviceEventList",
    "Get-MedlemsserviceEventRegistrationList",

    # Export
    "Invoke-MedlemsserviceExport",
    "Get-MedlemsserviceExportFields",
    "Get-MedlemsserviceExportChildFields",

    # Documents
    "Get-MedlemsserviceSigningDocument",

    # maybe leave out those
    "Invoke-MedlemsserviceCallRequest",
    "Read-MedlemsserviceDataset"
    "Get-MedlemsserviceRelation",
    "Get-MedlemsserviceFunctionForMember",
    "Get-MedlemsserviceMemberIdFromModelId"
)

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = 'Spejder','Medlemsservice','Integration'

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/jballe/medlemsservice-powershell-module'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

        # Prerelease string of this module
        # Prerelease = ''

        # Flag to indicate whether the module requires explicit user acceptance for install/update/save
        # RequireLicenseAcceptance = $false

        # External dependent modules of this module
        # ExternalModuleDependencies = @()

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

