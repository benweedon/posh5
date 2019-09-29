# Module manifest for module "posh5.psm1"
@{

# Script module or binary module file associated with this manifest
RootModule = "posh5.psm1"

# Version number of this module.
ModuleVersion = "0.1"

# ID used to uniquely identify this module
GUID = "bb395b2f-b569-4b5e-9bd0-5864554ff4f0"

# Author of this module
Author = "Ben Weedon"

# Description of the functionality provided by this module
Description = "Command line utilities for p5"

# TODO: Are these minimum versions correct?
# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = "5.0"

# Minimum version of the common language runtime (CLR) required by this module
CLRVersion = "4.0"

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = @(
    "Invoke-P5Sketch.ps1")

# Cmdlets to export from this module
CmdletsToExport = @(
    "Invoke-P5Sketch")

AliasesToExport = @()
}