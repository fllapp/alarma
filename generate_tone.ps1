Add-Type -AssemblyName System.IO.Compression

$sampleRate = 44100
$duration = 3.0
$numSamples = [int]($sampleRate * $duration)
$numChannels = 1
$bitsPerSample = 16
$byteRate = $sampleRate * $numChannels * $bitsPerSample / 8
$blockAlign = $numChannels * $bitsPerSample / 8
$dataSize = $numSamples * $blockAlign
$fileSize = 36 + $dataSize

$ms = New-Object System.IO.MemoryStream
$w = New-Object System.IO.BinaryWriter($ms)

function Write-Le32($val) { $w.Write([byte]($val -band 0xFF)); $w.Write([byte](($val -shr 8) -band 0xFF)); $w.Write([byte](($val -shr 16) -band 0xFF)); $w.Write([byte](($val -shr 24) -band 0xFF)) }
function Write-Le16($val) { $w.Write([byte]($val -band 0xFF)); $w.Write([byte](($val -shr 8) -band 0xFF)) }
function Write-Str($s) { $w.Write([System.Text.Encoding]::ASCII.GetBytes($s)) }

Write-Str "RIFF"
Write-Le32 $fileSize
Write-Str "WAVE"
Write-Str "fmt "
Write-Le32 16
Write-Le16 1
Write-Le16 $numChannels
Write-Le32 $sampleRate
Write-Le32 $byteRate
Write-Le16 $blockAlign
Write-Le16 $bitsPerSample
Write-Str "data"
Write-Le32 $dataSize

$halfDataSize = $numSamples / 2

for ($i = 0; $i -lt $numSamples; $i++) {
    $t = $i / $sampleRate
    $freq = 520 + [Math]::Sin(2.0 * [Math]::PI * 0.5 * $t) * 200
    $value = [Math]::Sin(2.0 * [Math]::PI * $freq * $t) * 0.4
    $value += [Math]::Sin(2.0 * [Math]::PI * $freq * 1.5 * $t) * 0.2
    $value += [Math]::Sin(2.0 * [Math]::PI * $freq * 2.0 * $t) * 0.1
    $sample = [int]($value * 32767)
    $w.Write([byte]($sample -band 0xFF))
    $w.Write([byte](($sample -shr 8) -band 0xFF))
}

$w.Dispose()

$outputPath = "C:\Users\facu_\OneDrive\Desktop\alarma ios\Alarma\Resources\alarm_tone.wav"
[System.IO.File]::WriteAllBytes($outputPath, $ms.ToArray())
$ms.Dispose()
Write-Host "Generated $outputPath ($($ms.Length) bytes)"
