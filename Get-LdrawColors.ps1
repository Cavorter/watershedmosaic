[CmdletBinding()]
Param(
    [ValidateScript({Test-Path "$_\LDConfig.ldr"})]
    [string]$LDrawPath = $env:LDRAW_PATH
)

$ldConfig = Get-Content -Path $Path
$ldrRegex = '0 !COLOUR (.*)\s*CODE\s*(\d{1,}).*'
$lgoRegex = '0\s*\/\/ LEGOID\s*(\d{1,}) - (.*)'

foreach ( $line in $ldConfig ) {
    if ( $line -match $ldrRegex ) {
        $color = @{ code = $Matches[2]; ldrawName = $Matches[1].Trim() }
        $prevIndex = $ldConfig.IndexOf( $Matches[0] ) - 1
        if ( $ldConfig[$prevIndex] -match $lgoRegex ) {
            $color.legoId = $Matches[1]
            $color.legoName = $Matches[2]
        }
        $return = New-Object -TypeName psobject -Property $color
        Write-Output $return
    }
}
