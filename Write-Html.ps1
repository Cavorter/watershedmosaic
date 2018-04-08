function Write-Html {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [validateScript( { Test-Path -Path $_ })]
        [string]$Path,

        [string]$PartsList
    )

    $Path = ( Resolve-Path -Path $Path ).Path
    Write-Verbose "File Path: $Path"

    $modelName = Split-Path -Path $Path -Leaf

    $outFilename = $modelName + ".html"
    Write-Verbose "Out Filename: $outFilename"

    $outFile = Join-Path -Path $Path -ChildPath $outFilename
    Write-Verbose "OutFile: $outFile"

    $name = $modelName.Split('_') -join ' '
    $prefix = "<html><head><link rel='stylesheet' href='../styles.css'></head><body><h1>$name</h1>"
    $suffix = '</div></body></html>'

    $imageList = Get-ChildItem -Path $Path\*.png | Sort-Object -Property Name

    $html = $prefix

    if ( $PartsList ) {
        Write-Verbose "Adding parts list..."
        $html += "<h2>Parts List</h2>$PartsList"
    }

    $html += "<div class='Table'>"

    foreach ( $file in $imageList ) {
        $file.Name -match ".*\-Step(\d*)\.png" | Out-Null
        $stepIndex = [int]($Matches[1])
        $line = "<div class='Row'><div class='Cell'><h2>Step $stepIndex</h2><br/><img src='$($file.Name)' /></div></div>"
        $html += $line
    }

    if ( $txtLine -or $imgLine ) {
        $html += $txtLine + "</tr>" + $imgLine + "</tr>"
    }

    $html + $suffix | Out-File -FilePath $outFile
}