Add-Type -AssemblyName System.Drawing

$size = 1024
$bmp = New-Object System.Drawing.Bitmap($size, $size)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

$bg = [System.Drawing.Color]::FromArgb(18, 18, 30)
$g.Clear($bg)

$cx = $size / 2
$cy = $size / 2
$radius = $size * 0.38

$glowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 0, 122, 255))
$g.FillEllipse($glowBrush, $cx - $radius - 20, $cy - $radius - 20, ($radius + 20) * 2, ($radius + 20) * 2)

$faceBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(28, 28, 48))
$g.FillEllipse($faceBrush, $cx - $radius, $cy - $radius, $radius * 2, $radius * 2)

$pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(0, 122, 255), 12)
$pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$g.DrawEllipse($pen, $cx - $radius, $cy - $radius, $radius * 2, $radius * 2)

$markerPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(200, 200, 200), 6)
for ($i = 0; $i -lt 12; $i++) {
    $angle = $i * [Math]::PI * 2 / 12 - [Math]::PI / 2
    $innerR = $radius * 0.82
    $outerR = $radius * 0.9
    $x1 = $cx + $innerR * [Math]::Cos($angle)
    $y1 = $cy + $innerR * [Math]::Sin($angle)
    $x2 = $cx + $outerR * [Math]::Cos($angle)
    $y2 = $cy + $outerR * [Math]::Sin($angle)
    $g.DrawLine($markerPen, $x1, $y1, $x2, $y2)
}

$hourAngle = 7 * [Math]::PI * 2 / 12 - [Math]::PI / 2
$hourLen = $radius * 0.45
$hourPen = New-Object System.Drawing.Pen([System.Drawing.Color]::White, 18)
$hourPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$g.DrawLine($hourPen, $cx, $cy, $cx + $hourLen * [Math]::Cos($hourAngle), $cy + $hourLen * [Math]::Sin($hourAngle))

$minAngle = 0 * [Math]::PI * 2 / 60 - [Math]::PI / 2
$minLen = $radius * 0.65
$minPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(0, 122, 255), 12)
$minPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$g.DrawLine($minPen, $cx, $cy, $cx + $minLen * [Math]::Cos($minAngle), $cy + $minLen * [Math]::Sin($minAngle))

$centerBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(0, 122, 255))
$g.FillEllipse($centerBrush, $cx - 20, $cy - 20, 40, 40)

$bellSize = $radius * 0.22
$bellX = $cx
$bellY = $cy - $radius * 0.75
$bellPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 200, 50), 8)
$bellPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round

$g.DrawArc($bellPen, $bellX - $bellSize, $bellY - $bellSize * 0.8, $bellSize * 2, $bellSize * 1.6, 0, 180)
$g.DrawLine($bellPen, $bellX - $bellSize, $bellY + $bellSize * 0.1, $bellX - $bellSize, $bellY + $bellSize * 0.3)
$g.DrawLine($bellPen, $bellX + $bellSize, $bellY + $bellSize * 0.1, $bellX + $bellSize, $bellY + $bellSize * 0.3)
$g.DrawArc($bellPen, $bellX - $bellSize * 0.6, $bellY + $bellSize * 0.2, $bellSize * 1.2, $bellSize * 0.3, 0, 180)

$knobBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 200, 50))
$g.FillEllipse($knobBrush, $bellX - 10, $bellY - $bellSize * 0.8 - 9, 20, 18)

$g.Dispose()

$outputDir = "C:\Users\facu_\OneDrive\Desktop\alarma ios\Alarma\Resources"
$path = Join-Path $outputDir "icon_base.png"
$bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Host "Icon saved to $path"
