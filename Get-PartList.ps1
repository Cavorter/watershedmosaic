. $PSScriptRoot\Get-LdrPartList.ps1

Function Get-PartList {
    [CmdletBinding()]
    Param(
        [ValidateScript( { Test-Path -Path $_ })]
        [string]$Path
    )

    $prefix = "<div class='Table'><div class='Heading'><div class='Cell'>Quantity</div><div class='Cell'>Part</div><div class='Cell'>Color</div></div>"
    $suffix = "</div>"
    $content = ""

    $parts = Get-LdrPartList -Path $Path | Sort-Object -Property colorId,id
    foreach ( $part in $parts ) {
        $content += "<div class='Row'><div class='Cell.qty'>$( $part.partCount )</div><div class='Cell'>$( $part.partName )</div><div class='Cell'>$( $part.colorName )</div></div>"
    }

    Write-Output ( $prefix + $content + $suffix )
}