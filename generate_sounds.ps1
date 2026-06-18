Add-Type -AssemblyName System.IO.Compression

$sampleRate = 44100
$bitsPerSample = 16
$numChannels = 1
$blockAlign = $numChannels * $bitsPerSample / 8
$byteRate = $sampleRate * $numChannels * $bitsPerSample / 8

$outputDir = "C:\Users\facu_\OneDrive\Desktop\alarma ios\Alarma\Resources\Sounds"
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null

function WriteWav($path, $data) {
    $numSamples = $data.Length
    $dataSize = $numSamples * $blockAlign
    $fileSize = 36 + $dataSize

    $ms = New-Object System.IO.MemoryStream
    $w = New-Object System.IO.BinaryWriter($ms)

    $w.Write([byte]0x52); $w.Write([byte]0x49); $w.Write([byte]0x46); $w.Write([byte]0x46)
    $w.Write([byte]($fileSize -band 0xFF)); $w.Write([byte](($fileSize -shr 8) -band 0xFF)); $w.Write([byte](($fileSize -shr 16) -band 0xFF)); $w.Write([byte](($fileSize -shr 24) -band 0xFF))
    $w.Write([byte]0x57); $w.Write([byte]0x41); $w.Write([byte]0x56); $w.Write([byte]0x45)
    $w.Write([byte]0x66); $w.Write([byte]0x6D); $w.Write([byte]0x74); $w.Write([byte]0x20)
    $w.Write([byte]16); $w.Write([byte]0); $w.Write([byte]0); $w.Write([byte]0)
    $w.Write([byte]1); $w.Write([byte]0)
    $w.Write([byte]$numChannels); $w.Write([byte]0)
    $w.Write([byte]($sampleRate -band 0xFF)); $w.Write([byte](($sampleRate -shr 8) -band 0xFF)); $w.Write([byte](($sampleRate -shr 16) -band 0xFF)); $w.Write([byte](($sampleRate -shr 24) -band 0xFF))
    $w.Write([byte]($byteRate -band 0xFF)); $w.Write([byte](($byteRate -shr 8) -band 0xFF)); $w.Write([byte](($byteRate -shr 16) -band 0xFF)); $w.Write([byte](($byteRate -shr 24) -band 0xFF))
    $w.Write([byte]$blockAlign); $w.Write([byte]0)
    $w.Write([byte]$bitsPerSample); $w.Write([byte]0)
    $w.Write([byte]0x64); $w.Write([byte]0x61); $w.Write([byte]0x74); $w.Write([byte]0x61)
    $w.Write([byte]($dataSize -band 0xFF)); $w.Write([byte](($dataSize -shr 8) -band 0xFF)); $w.Write([byte](($dataSize -shr 16) -band 0xFF)); $w.Write([byte](($dataSize -shr 24) -band 0xFF))

    foreach ($sample in $data) {
        $clamped = [int]([Math]::Max(-1.0, [Math]::Min(1.0, $sample)) * 32767)
        $w.Write([byte]($clamped -band 0xFF))
        $w.Write([byte](($clamped -shr 8) -band 0xFF))
    }
    $w.Dispose()
    [System.IO.File]::WriteAllBytes($path, $ms.ToArray())
    $ms.Dispose()
}

function Gen($freq, $dur, $style) {
    $n = [int]($sampleRate * $dur)
    $result = @(0) * $n
    for ($i = 0; $i -lt $n; $i++) {
        $t = $i / $sampleRate
        $v = 0.0

        # Fade in/out (10ms)
        $env = 1.0
        $fadeLen = [int]($sampleRate * 0.01)
        if ($i -lt $fadeLen) { $env = $i / $fadeLen }
        elseif ($i -gt ($n - $fadeLen)) { $env = ($n - $i) / $fadeLen }

        if ($style -eq "const") {
            $v = [Math]::Sin(2 * [Math]::PI * $freq * $t)
        }
        elseif ($style -eq "pulse") {
            $on = 0.15; $off = 0.35; $cycle = $on + $off
            $pos = $t % $cycle
            $amp = if ($pos -le $on) { 1.0 } else { 0.0 }
            $v = $amp * [Math]::Sin(2 * [Math]::PI * $freq * $t)
        }
        elseif ($style -eq "slowpulse") {
            $on = 0.5; $off = 0.5; $cycle = $on + $off
            $pos = $t % $cycle
            $amp = if ($pos -le $on) { 1.0 } else { 0.0 }
            $v = $amp * [Math]::Sin(2 * [Math]::PI * $freq * $t)
        }
        elseif ($style -eq "double") {
            $on = 0.1; $gap = 0.15; $on2 = 0.1; $off = 0.65; $cycle = $on + $gap + $on2 + $off
            $pos = $t % $cycle
            $amp = if ($pos -le $on -or ($pos -gt ($on + $gap) -and $pos -le ($on + $gap + $on2))) { 1.0 } else { 0.0 }
            $v = $amp * [Math]::Sin(2 * [Math]::PI * $freq * $t)
        }
        elseif ($style -eq "sweep") {
            $sf = $freq + $freq * 2 * $t / $dur
            $v = [Math]::Sin(2 * [Math]::PI * $sf * $t)
        }
        elseif ($style -eq "sweepdown") {
            $sf = $freq * 3 - $freq * 2 * $t / $dur
            $v = [Math]::Sin(2 * [Math]::PI * $sf * $t)
        }
        elseif ($style -eq "alternating") {
            $aperiod = 0.2
            $alt = [int][Math]::Floor($t / $aperiod) % 2
            $af = $freq * (1.0 + $alt * 0.5)
            $v = [Math]::Sin(2 * [Math]::PI * $af * $t)
        }
        elseif ($style -eq "fastalt") {
            $aperiod = 0.08
            $alt = [int][Math]::Floor($t / $aperiod) % 2
            $af = $freq * (1.0 + $alt * 0.6)
            $v = [Math]::Sin(2 * [Math]::PI * $af * $t)
        }
        elseif ($style -eq "tremolo") {
            $mod = 0.5 + 0.5 * [Math]::Sin(2 * [Math]::PI * 4 * $t)
            $v = $mod * [Math]::Sin(2 * [Math]::PI * $freq * $t)
        }
        elseif ($style -eq "rich") {
            $v = 0.5 * [Math]::Sin(2 * [Math]::PI * $freq * $t)
            $v += 0.25 * [Math]::Sin(2 * [Math]::PI * $freq * 2 * $t)
            $v += 0.125 * [Math]::Sin(2 * [Math]::PI * $freq * 3 * $t)
            $v += 0.0625 * [Math]::Sin(2 * [Math]::PI * $freq * 4 * $t)
        }
        elseif ($style -eq "noise") {
            $seed = ($i * 1103515245 + 12345) -band 0x7FFFFFFF
            $nv = ($seed / 0x7FFFFFFF) * 2 - 1
            $v = 0.5 * $nv + 0.3 * [Math]::Sin(2 * [Math]::PI * $freq * $t)
        }
        elseif ($style -eq "water") {
            $seed1 = ($i * 1103515245 + 12345) -band 0x7FFFFFFF
            $seed2 = (($i + 1000) * 1103515245 + 12345) -band 0x7FFFFFFF
            $n1 = ($seed1 / 0x7FFFFFFF) * 2 - 1
            $n2 = ($seed2 / 0x7FFFFFFF) * 2 - 1
            $v = 0.3 * [Math]::Sin(2 * [Math]::PI * $freq * $t + $n1 * 0.5)
            $v += 0.2 * [Math]::Sin(2 * [Math]::PI * ($freq * 1.5) * $t + $n2 * 0.3)
            $v += 0.2 * $n1 * [Math]::Sin(2 * [Math]::PI * 200 * $t)
        }
        elseif ($style -eq "chirp") {
            $ci = 2.0
            $pos = $t % $ci
            if ($pos -lt 0.15) {
                $ct = $pos / 0.15
                $cf = $freq + 200 * $ct
                $ce = [Math]::Sin([Math]::PI * $ct)
                $v = $ce * [Math]::Sin(2 * [Math]::PI * $cf * $pos)
            }
        }
        elseif ($style -eq "smooth") {
            $mod = 0.7 + 0.3 * [Math]::Sin(2 * [Math]::PI * 2 * $t)
            $v = $mod * [Math]::Sin(2 * [Math]::PI * $freq * $t)
        }
        elseif ($style -eq "morse") {
            $tot = $dur * $sampleRate
            $bitLen = 0.08
            $bitsCount = [int]($dur / $bitLen)
            $pat = "10101010101010101010"
            $bi = [int][Math]::Floor($t / $bitLen) % $pat.Length
            $ch = $pat[$bi]
            if ($ch -eq '1') {
                $v = [Math]::Sin(2 * [Math]::PI * $freq * $t)
            }
        }
        elseif ($style -eq "rising") {
            $rf = $freq * (1 + 2 * $t / $dur)
            $v = [Math]::Sin(2 * [Math]::PI * $rf * $t)
        }
        elseif ($style -eq "saw") {
            $phase = ($freq * $t) % 1.0
            $v = 0.5 * (2 * $phase - 1)
        }
        elseif ($style -eq "harmonics") {
            $v = [Math]::Sin(2 * [Math]::PI * $freq * $t) * 0.4
            $v += [Math]::Sin(2 * [Math]::PI * $freq * 2.76 * $t) * 0.15
            $v += [Math]::Sin(2 * [Math]::PI * $freq * 4.14 * $t) * 0.08
            $v += [Math]::Sin(2 * [Math]::PI * $freq * 5.43 * $t) * 0.04
            $decay = [Math]::Exp(-$t * 0.8)
            $v = $v * $decay
        }
        elseif ($style -eq "melody") {
            $notes = @(262, 294, 330, 392, 440, 523)
            $nd = $dur / $notes.Length
            $ni = [int][Math]::Min($notes.Length - 1, [Math]::Floor($t / $nd))
            $lt = $t - $ni * $nd
            $ne = [Math]::Min(1.0, $lt * 10) * [Math]::Min(1.0, ($nd - $lt) * 10)
            $v = $ne * [Math]::Sin(2 * [Math]::PI * $notes[$ni] * $t)
        }
        elseif ($style -eq "bell") {
            $strike = [Math]::Exp(-$t * 2)
            $v = $strike * [Math]::Sin(2 * [Math]::PI * $freq * $t)
            $v += 0.4 * $strike * [Math]::Sin(2 * [Math]::PI * $freq * 2.76 * $t)
            $v += 0.2 * $strike * [Math]::Sin(2 * [Math]::PI * $freq * 4.14 * $t)
        }

        $result[$i] = $v * $env
    }
    return $result
}

$sounds = @(
    @{id="alarma_clasica";  freq=800; dur=3.0; style="pulse"},
    @{id="timbre_antiguo";  freq=600; dur=3.0; style="slowpulse"},
    @{id="campana";         freq=400; dur=3.0; style="bell"},
    @{id="carillon";        freq=523; dur=3.0; style="harmonics"},
    @{id="despertador";     freq=1000; dur=3.0; style="double"},
    @{id="pulso";           freq=200; dur=3.0; style="saw"},
    @{id="bosque";          freq=500; dur=3.0; style="chirp"},
    @{id="lluvia";          freq=300; dur=3.0; style="noise"},
    @{id="olas";            freq=400; dur=3.0; style="water"},
    @{id="brisa";           freq=800; dur=3.0; style="smooth"},
    @{id="murmullo";        freq=300; dur=3.0; style="const"},
    @{id="emergencia";      freq=800; dur=3.0; style="alternating"},
    @{id="sirena";          freq=400; dur=3.0; style="sweep"},
    @{id="alarma_fuerte";   freq=1200; dur=3.0; style="pulse"},
    @{id="bocina";          freq=500; dur=3.0; style="rich"},
    @{id="martillo";        freq=200; dur=3.0; style="tremolo"},
    @{id="alarma_max";      freq=800; dur=3.0; style="fastalt"},
    @{id="melodia";         freq=392; dur=3.0; style="melody"},
    @{id="tono_suave";      freq=440; dur=3.0; style="smooth"},
    @{id="piano";           freq=523; dur=3.0; style="bell"},
    @{id="arpa";            freq=440; dur=3.0; style="rising"},
    @{id="alegre";          freq=523; dur=3.0; style="double"},
    @{id="amanecer";        freq=400; dur=3.0; style="rising"},
    @{id="sol_naciente";    freq=500; dur=3.0; style="smooth"},
    @{id="naturaleza";      freq=600; dur=3.0; style="chirp"},
    @{id="rio";             freq=300; dur=3.0; style="water"},
    @{id="viento";          freq=700; dur=3.0; style="noise"},
    @{id="digital_1";       freq=440; dur=3.0; style="double"},
    @{id="radar";           freq=300; dur=3.0; style="pulse"},
    @{id="laser";           freq=1500; dur=3.0; style="sweepdown"},
    @{id="sensor";          freq=880; dur=3.0; style="morse"},
    @{id="codigo";          freq=1200; dur=3.0; style="morse"}
)

foreach ($s in $sounds) {
    $data = Gen $s.freq $s.dur $s.style
    $path = Join-Path $outputDir "$($s.id).wav"
    WriteWav $path $data
    Write-Host "$($s.id).wav"
}

$total = $sounds.Count
$size = (Get-ChildItem $outputDir -Filter *.wav | Measure-Object -Property Length -Sum).Sum
Write-Host "`n$total sounds generated ($([int]($size/1024)) KB total) in $outputDir"
