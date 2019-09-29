function Invoke-P5Sketch {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, Position=0)]
        [String] $SketchPath,
        [Parameter(Mandatory=$True, Position=1)]
        [String] $OutFile,
        [Parameter(Mandatory=$False)]
        [UInt32] $Port = 8080,
        [Parameter(Mandatory=$False)]
        [UInt32] $Delay = 10000
    )
    PROCESS {
        $temp = CreateTemporaryHtmlFile
        try {
            $SketchPath = "file:///$(Resolve-Path $SketchPath)".Replace("\", "\\")
            ReplaceTemplate $temp $SketchPath $Port $Delay

            # Open the HTML file.
            Start-Process "file:///$temp"

            $listener = New-Object System.Net.HttpListener
            try {
                # Begin listening on the given port.
                $listener.Prefixes.Add("http://localhost:$Port/")
                $listener.Start()
                $context = $listener.GetContext()
                Write-Host "Received connection from p5 tab on port $Port."

                # Read the data URL from the POST message.
                $bytes = @()
                $reader = New-Object System.IO.BinaryReader $context.Request.InputStream
                do {
                    $tempBytes = $reader.ReadBytes(4mb)
                    $bytes += $tempBytes
                } while ($tempBytes.Length -gt 0)
                Write-Host "Read image into byte array."

                # Write the image bytes out to the file.
                Set-Content -Value $bytes -Path $OutFile -Encoding Byte
                Write-Host "Wrote image out to file $OutFile."
            } finally {
                $listener.Stop()
            }
        } finally {
            Remove-Item $temp
        }
    }
}

function CreateTemporaryHtmlFile() {
    $temp = New-TemporaryFile
    $tempHtml = "$($temp.FullName).html"
    Move-Item $temp $tempHtml
    return $tempHtml
}

function ReplaceTemplate([String] $TemplateFile, [String] $SketchPath, [UInt32] $Port, [UInt32] $Delay) {
    $templateContent = Get-Content "$PSScriptRoot\run.html" -Encoding UTF8

    $templateContent = $templateContent.Replace("{ sketchPath }", "'$SketchPath'")
    $templateContent = $templateContent.Replace("{ port }", $Port)
    $templateContent = $templateContent.Replace("{ delay }", $Delay)

    $templateContent | Out-File $TemplateFile -Encoding UTF8
}
