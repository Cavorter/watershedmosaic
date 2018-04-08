function Get-LdrawPartName {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$PartId,

        [ValidateScript({Test-Path "$_\LDConfig.ldr"})]
        [string]$LDrawPath = $env:LDRAW_PATH
    )

    $datFile = Get-Content -Path "$LDrawPath\parts\$( $PartId ).dat"
    $name = $datFile[0].Split(' ').Where({ $_ -ne '' })
    $name = $name[1..( $name.count - 1 )] -join ' '
    Write-Output $name
}