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

                # Read the data URL from the POST message.
                $dataUrl = (New-Object System.IO.StreamReader $context.Request.InputStream).ReadToEnd()

                # Convert the data URL to bytes and write it out to the file.
                $bytes = DataUrlToBytes $dataUrl
                $bytes | Set-Content $OutFile -Encoding Byte
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

function DataUrlToBytes([String] $DataUrl) {
    $dataUrlHeader = "data:image/png;"
    if ($DataUrl.StartsWith($dataUrlHeader)) {
        $DataUrl = $DataUrl.Remove(0, $dataUrlHeader.Length)
    }

    $base64Header = "base64,"
    if ($DataUrl.StartsWith($base64Header)) {
        $DataUrl = $DataUrl.Remove(0, $base64Header.Length)
    }

    return [Convert]::FromBase64String($DataUrl)
}
