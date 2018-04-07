function Export-Snapshots {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [validateScript( { Test-Path -Path $_ })]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$OutputPath,

        [validateScript( { Test-Path -Path $_ })]
        [string]$LDViewPath = $env:LDVIEW_PATH,

        [switch]$TestRun
    )

    $Path = ( Resolve-Path -Path $Path ).Path
    Write-Verbose "File Path: $Path"

    $stepCount = ( Get-Content -Path $Path | Select-String -Pattern "0 STEP" -AllMatches ).Count
    Write-Verbose "Found $stepCount steps"

    $modelName = ( Split-Path -Path $Path -Leaf ).Split('.')[0]

    $OutputPath = Join-Path -Path $OutputPath -ChildPath $modelName
    Write-Verbose "Output Path: $OutputPath"

    if ( Test-Path -Path $OutputPath ) {
        Write-Verbose "OutputPath exists..."
    }
    else {
        Write-Verbose "Creating OutputPath $outputPath"
        New-Item -Path $OutputPath -Force  -ItemType Directory | Out-Null
    }

    $outFilename = $modelName + ".png"
    Write-Verbose "Out Filename: $outFilename"

    $outFile = Join-Path -Path $OutputPath -ChildPath $outFilename
    Write-Verbose "OutFile: $outFile"

    $ldviewArgs = @(
        $Path
        , "-DefaultMatrix=0.999805,0,0.0197501,0.0191522,0.244187,-0.969539,-0.00482271,0.969728,0.24414"
        , "-DefaultZoom=1"
        , "-SaveSnapshot=$outFile"
        , "-BackgroundColor3=0xFFFFFF"
        , "-ShowHighlightLines=1"
        , "-EdgeThickness=2"
        , "-SaveSteps=1"
        , "-SaveStepsSuffix=-Step"
        , "-SaveZoomToFit=1"
        , "-AutoCrop=1"
    )
    Write-Verbose "LDView Arguments: $( $ldviewArgs -join ' ' )"

    Write-Verbose "Outputting snapshots for $Path to $OutputPath."
    $exp = { Start-Process -FilePath $LDViewPath -ArgumentList $ldviewArgs -Wait }
    if ( $TestRun ) { $exp = { "placeholder" | Out-Null } }
    $metrics = Measure-Command -Expression $exp
    Write-Verbose "Produced snapshots in $( $metrics.TotalMilliseconds ) milliseconds"

    $snapshotCount = ( Get-ChildItem -Path $OutputPath\*.png ).Count
    Write-Verbose "Found $snapshotCount snapshots"

    if ( $stepCount -ne $snapshotCount ) {
        Write-Warning "$Path - Incorrect number of snapshots generated ($snapshotCount)! (StepCount: $stepCount)"
    }
    Write-Output ( New-Object -TypeName psobject -Property @{ Source = $Path; Output = $OutputPath; Time = $metrics } )
}