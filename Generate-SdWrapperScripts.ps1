param(
    $ContainingFoldersFile,
    $FoldersFile,
    $StayDeletedExecutable,
    [string]$ScriptsFolder = $null
)

if (-not (Test-Path -Path $ContainingFoldersFile))
{
    Write-Error "Can't find the file listing the containing folders '$($ContainingFoldersFile)'!"
}

if (-not (Test-Path -Path $FoldersFile))
{
    Write-Error "Can't find the file listing the folders '$($FoldersFile)'!"
}

if (-not (Test-Path -Path $StayDeletedExecutable))
{
    Write-Error "Can't find the file listing the Stay Deleted Executable '$($StayDeletedExecutable)'!"
}

if ([string]::IsNullOrWhiteSpace($ScriptsFolder))
{
    $ScriptsFolder = Split-Path -Path $ContainingFoldersFile -Parent
}

if (-not (Test-Path -Path $ScriptsFolder))
{
    Write-Error "Can't find the file listing the scripts folders '$($ScriptsFolder)'!"
}

# Functions
function Get-SdCallingLine($StayDeletedExecutable, $Folder)
{
    return "Start-Process -FilePath '$($StayDeletedExecutable)' -ArgumentList '--delete ""$($Folder)""'"
}

# Read the input files
$ContainingFolders = @()
foreach ($ContainingFolder in Get-Content $ContainingFoldersFile)
{
    if (-not [string]::IsNullOrWhiteSpace($ContainingFolder))
    {
        if (Test-Path $ContainingFolder)
        {
            $ContainingFolders += , $ContainingFolder
        }
    }
}

$Folders = @()
foreach ($FoldersRaw in Get-Content $FoldersFile)
{
    if (-not [string]::IsNullOrWhiteSpace($FoldersRaw))
    {
        $FolderNameVariations = $FoldersRaw -split ','
        $Folders += , $FolderNameVariations
    }   
}

# Process the file inputs
$FullListOfFoldersToSweep = @()
$GroupedFolders = @{}

foreach ($Folder in $Folders)
{
    $GroupName = $Folder[0]
    $GroupFolders = @()

    foreach ($FolderNameVariation in $Folder)
    {
        foreach ($ContainingFolder in $ContainingFolders)
        {
            $FolderToSweep = Join-Path -Path $ContainingFolder -ChildPath $FolderNameVariation

            if (Test-Path $FolderToSweep)
            {
                $FullListOfFoldersToSweep += , $FolderToSweep
                $GroupFolders += , $FolderToSweep
            }
        }
    }

    $GroupedFolders[$GroupName] = $GroupFolders
}

# Generate the group scripts
foreach ($GroupName in $GroupedFolders.Keys)
{
    $GroupScript = Join-Path -Path $ScriptsFolder -ChildPath "$($GroupName).ps1"

    if (Test-Path $GroupScript)
    {
        Remove-Item $GroupScript
    }

    Write-Output "# AUTOGEN'D DO NOT EDIT!" | Out-File -Append $GroupScript

    foreach ($Folder in $GroupedFolders.Get_Item($GroupName)) 
    {
        $Line = Get-SdCallingLine `
            -StayDeletedExecutable $StayDeletedExecutable `
            -Folder $Folder

        Write-Output $Line | Out-File -Append $GroupScript
    }
}

# Generate the nightly scheduled task
$NightlyScript = Join-Path -Path $ScriptsFolder -ChildPath "_Nightly.ps1"
if (Test-Path $NightlyScript)
{
    Remove-Item $NightlyScript
}

Write-Output "# AUTOGEN'D DO NOT EDIT!" | Out-File -Append $NightlyScript

foreach ($FolderToSweep in $FullListOfFoldersToSweep)
{
    $Line = Get-SdCallingLine `
        -StayDeletedExecutable $StayDeletedExecutable `
        -Folder $FolderToSweep

    Write-Output $Line | Out-File -Append $NightlyScript
}


