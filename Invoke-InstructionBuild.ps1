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
    x         = @()
    y         = @()
}

$exportSplat = @{ OutputPath = $outputPath }
if ( $SkipSnapshots ) { $exportSplat.TestRun = [switch]$true }

foreach ( $ldr in $ldrFiles ) {
    $points = $ldr.Name.Split('.')[0].Split('_')
    $axisPoints.baseplate += $points[1]
    $axisPoints.x += [int]$points[2]
    $axisPoints.y += [int]$points[3]

    $exportSplat.Path = $ldr.FullName
    $result = Export-Snapshots @exportSplat
    $renderTime += $result.Time

    if ( -not $SkipSnapshots ) {
        $partList = Get-PartList -Path $ldr.FullName
        Write-Html -Path $result.Output -PartsList $partList
    }
}

$axisPoints.x = $axisPoints.x | Sort-Object -Unique
$axisPoints.y = $axisPoints.y | Sort-Object -Unique

$prefix = '<!DOCTYPE html><html><head><link rel="stylesheet" href="styles.css"></head><body><h1>Mosaic Instructions</h1><div class="Table">'
$suffix = '</div></body></html>'

$html = $prefix

foreach ( $y in @('A', 'B', 'C', 'D') ) {
    $html += "<div class='Row'>"
    foreach ( $x in @(1..5) ) {
        $baseplate = $y + $x
        $fileNameBase = "towers_baseplate_$baseplate"
        $ldrFile = "$PSScriptRoot\mosaic\$( $fileNameBase ).ldr"
        if ( Test-Path -Path $ldrFile ) {
            Write-Host "Found baseplate $baseplate..."
            $html += "<div class='Cell' >"

            #generate baseplate instructions
            $exportSplat.Path = $ldrFile
            $result = Export-Snapshots @exportSplat
            $renderTime += $result.Time
        
            if ( -not $SkipSnapshots ) {
                $partList = Get-PartList -Path $ldrFile
                Write-Html -Path $result.Output -PartsList $partList
            }
        
            $html += "<h2><a href='$fileNameBase/$( $fileNameBase ).html'>$baseplate</a></h2><div class='Table'>"
            $baseName = "mosaic_$baseplate"
            foreach ( $innerY in @(0..5)) {
                $html += "<div class='Row'>"
                foreach ( $innerX in @(0..5)) {
                    $file = @( $baseName , $innerX , $innerY ) -join '_'
                    if ( Test-Path -Path "$outputPath\$file\$file.html" ) {
                        $html += "<div class='Cell' id='innerCell' >"
                        $attr = "href='$file/$file.html'"
                        $html += "<a class='$anchorClass' $attr >$innerX $innerY</a>"
                    } else {
                        $html += "<div class='Cell' id='blankCellInner' >"
                    }
                    $html += "</div>"
                }
                $html += "</div>"
            }
            $html += "</div>"
        } else {
            $html += "<div class='Cell' id='blankCell' >"
        }
        $html += "</div>"
    }
    $html += "</div>"
}
$html + $suffix | Out-File -FilePath "$outputPath\index.html"

$cssFile = "$PSScriptRoot\styles.css"
Copy-Item -Path ( Resolve-Path -Path $cssFile ) -Destination $outputPath

$complete = Get-Date

Write-Host "Total Render Time: $renderTime"
Write-Host "Total Time:" ( $complete - $incept )
