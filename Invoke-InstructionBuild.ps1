[cmdletBinding()]
Param(
    [switch]$SkipSnapshots
)

$incept = Get-Date

. $PSScriptRoot\Write-Html.ps1
. $PSScriptRoot\Export-Snapshots.ps1

$outputPath = "$PSScriptRoot\Output"

$ldrFiles = Get-ChildItem -Path $PSScriptRoot\mosaic\mosaic*.ldr -Exclude mosaic_baseplate*.ldr

$axisPoints = @{
    baseplate = @()
    x = @()
    y = @()
}

foreach ( $ldr in $ldrFiles ) {
    $points = $ldr.Name.Split('.')[0].Split('_')
    $axisPoints.baseplate += $points[1]
    $axisPoints.x += [int]$points[2]
    $axisPoints.y += [int]$points[3]

    $exportSplat = @{
        Path = $ldr.FullName
        OutputPath = $outputPath
    }

    if ( $SkipSnapshots ) { $exportSplat.TestRun = [switch]$true }
    $result = Export-Snapshots @exportSplat
    $renderTime += $result.Time

    if ( -not $SkipSnapshots ) {
        $partList = Get-PartList -Path $ldr.FullName
        Write-Html -Path $result.Output -PartsList $partList
    }
}

Write-Host "Total Render Time: $renderTime"

$axisPoints.x = $axisPoints.x | Sort-Object -Unique
$axisPoints.y = $axisPoints.y | Sort-Object -Unique

$prefix = '<!DOCTYPE html><html><head><link rel="stylesheet" href="styles.css"></head><body><h1>Watershed Mosaic</h1><div class="Table">'
$suffix = '</div></body></html>'

$html = $prefix

foreach ( $y in @('A','B','C','D') ) {
    $html += "<div class='Row'>"
    foreach ( $x in @(1..5) ) {
        $baseplate = $y + $x
        Write-Verbose "Processing baseplate $baseplate..."
        $html += "<div class='Cell'><h2>$baseplate</h1>"

        $baseName = "mosaic_$baseplate"
        foreach ( $innerY in @(0..5)) {
            $html += "<div class='Row'>"
            foreach ( $innerX in @(0..5)) {
                $file = @( $baseName , $innerX , $innerY ) -join '_'
                $anchorClass = "blank"
                if ( Test-Path -Path "$outputPath\$file\$file.html" ) {
                    $attr = "href='$file/$file.html'"
                    $anchorClass = "filled"
                }
        
                $html += "<div class='Cell' ><a class='$anchorClass' $attr >$innerX $innerY</a></div>"
            }
            $html += "</div>"
        }
        $html += "</div>"
    }
    $html += "</div>"
}
$html + $suffix | Out-File -FilePath "$outputPath\index.html"

$cssFile = "$PSScriptRoot\styles.css"
Copy-Item -Path ( Resolve-Path -Path $cssFile ) -Destination $outputPath

$complete = Get-Date

Write-Host "Total Time:" ( $complete - $incept )
