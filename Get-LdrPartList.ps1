$colorList = Get-Content -Path $PSScriptRoot\colors.json | ConvertFrom-Json
. $PSScriptRoot\Get-LdrawPartName

function Get-LdrPartList {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({ Test-Path $_ })]
        [string]$Path
    )

    $content = Get-Content -Path $Path
    $parts = @()
    foreach ( $line in $content ) {
        if ( $line -match " 1 (\d*) .* (\d*)\.dat" ) {
            $parts += New-Object -TypeName psobject -Property @{ id = $Matches[2] ; colorId = $Matches[1] }
        }
    }

    $colors = $parts.colorId | Select-Object -Unique
    $partIds = $parts.id | Select-Object -Unique

    foreach ( $partId in $partIds ) {
        foreach ( $colorId in $colors ) {
            $list = $parts.Where({ $_.id -eq $partId -and $_.colorId -eq $colorId })
            if ( $list ) {
                $color = $colorList.Where( { $_.code -eq $colorId })
                $propHash = @{
                    partId = $partId
                    partName = ( Get-LdrawPartName -PartId $partId )
                    colorId = $colorId
                    colorName = "$( $color.ldrawName ) ($( $color.legoName ))"
                    partCount = $list.Count
                }
                $part = New-Object -TypeName psobject -Property $propHash
                Write-Output $part
            }
        }
    }
}