Add-Type -AssemblyName System.Drawing

$basePath = "C:\Users\facu_\OneDrive\Desktop\alarma ios\Alarma\Resources"
$baseImage = [System.Drawing.Image]::FromFile((Join-Path $basePath "icon_base.png"))

$iconSet = Join-Path (Join-Path $basePath "Assets.xcassets") "AppIcon.appiconset"
New-Item -ItemType Directory -Path $iconSet -Force | Out-Null

function New-Icon($size, $scale, $idiom, $role, $subtype) {
    $pixelSize = [int][Math]::Round($size * $scale)
    $parts = @($pixelSize)
    if ($idiom) { $parts += $idiom }
    if ($role) { $parts += $role }
    if ($subtype) { $parts += ($subtype -replace "[^a-zA-Z0-9]", "") }
    $filename = ($parts -join "_") + ".png"

    $bmp = New-Object System.Drawing.Bitmap($pixelSize, $pixelSize)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.DrawImage($baseImage, 0, 0, $pixelSize, $pixelSize)
    $g.Dispose()

    $path = Join-Path $iconSet $filename
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()

    $sz = "$size`x$size"
    $entry = @{ size = $sz; filename = $filename; idiom = $idiom; scale = "${scale}x" }
    if ($role) { $entry.role = $role }
    if ($subtype) { $entry["subtype"] = $subtype }
    return $entry
}

$images = @()
$images += New-Icon 20 2 "iphone"
$images += New-Icon 20 3 "iphone"
$images += New-Icon 29 2 "iphone"
$images += New-Icon 29 3 "iphone"
$images += New-Icon 40 2 "iphone"
$images += New-Icon 40 3 "iphone"
$images += New-Icon 60 2 "iphone"
$images += New-Icon 60 3 "iphone"
$images += New-Icon 20 1 "ipad"
$images += New-Icon 20 2 "ipad"
$images += New-Icon 29 1 "ipad"
$images += New-Icon 29 2 "ipad"
$images += New-Icon 40 1 "ipad"
$images += New-Icon 40 2 "ipad"
$images += New-Icon 76 1 "ipad"
$images += New-Icon 76 2 "ipad"
$images += New-Icon 83.5 2 "ipad" "" "83.5@2x"
$images += New-Icon 1024 1 "ios-marketing"

$contents = @{
    info = @{ author = "xcode"; version = 1 }
    images = $images
}

$contents | ConvertTo-Json -Depth 4 | Set-Content (Join-Path $iconSet "Contents.json") -Encoding UTF8

$baseImage.Dispose()
Write-Host "Icon set created at $iconSet with $($images.Count) icons"
