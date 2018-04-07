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
                $part = New-Object -TypeName psobject -Property @{ id = $partId; colorId = $colorId; count = $list.Count }
                Write-Output $part
            }
        }
    }
}