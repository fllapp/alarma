Add-Type -AssemblyName System.IO.Compression

$sr = 22050
$bs = 16
$ch = 1
$ba = $ch * $bs / 8

$out = "C:\Users\facu_\OneDrive\Desktop\alarma ios\Alarma\Resources\Sounds"
New-Item -ItemType Directory -Path $out -Force | Out-Null

function Wav($path, $d) {
    $n = $d.Length; $ds = $n * $ba; $fs = 36 + $ds
    $ms = New-Object System.IO.MemoryStream; $w = New-Object System.IO.BinaryWriter($ms)
    $w.Write([byte]0x52); $w.Write([byte]0x49); $w.Write([byte]0x46); $w.Write([byte]0x46)
    $w.Write([byte]($fs -band 0xFF)); $w.Write([byte](($fs -shr 8) -band 0xFF)); $w.Write([byte](($fs -shr 16) -band 0xFF)); $w.Write([byte](($fs -shr 24) -band 0xFF))
    $w.Write([byte]0x57); $w.Write([byte]0x41); $w.Write([byte]0x56); $w.Write([byte]0x45)
    $w.Write([byte]0x66); $w.Write([byte]0x6D); $w.Write([byte]0x74); $w.Write([byte]0x20)
    $w.Write([byte]16); $w.Write([byte]0); $w.Write([byte]0); $w.Write([byte]0)
    $w.Write([byte]1); $w.Write([byte]0); $w.Write([byte]$ch); $w.Write([byte]0)
    $w.Write([byte]($sr -band 0xFF)); $w.Write([byte](($sr -shr 8) -band 0xFF)); $w.Write([byte](($sr -shr 16) -band 0xFF)); $w.Write([byte](($sr -shr 24) -band 0xFF))
    $w.Write([byte](($sr * $ba) -band 0xFF)); $w.Write([byte](($sr * $ba -shr 8) -band 0xFF)); $w.Write([byte](($sr * $ba -shr 16) -band 0xFF)); $w.Write([byte](($sr * $ba -shr 24) -band 0xFF))
    $w.Write([byte]$ba); $w.Write([byte]0); $w.Write([byte]$bs); $w.Write([byte]0)
    $w.Write([byte]0x64); $w.Write([byte]0x61); $w.Write([byte]0x74); $w.Write([byte]0x61)
    $w.Write([byte]($ds -band 0xFF)); $w.Write([byte](($ds -shr 8) -band 0xFF)); $w.Write([byte](($ds -shr 16) -band 0xFF)); $w.Write([byte](($ds -shr 24) -band 0xFF))
    foreach ($v in $d) {
        $c = [int]([Math]::Max(-1.0, [Math]::Min(1.0, $v)) * 30000)
        $w.Write([byte]($c -band 0xFF)); $w.Write([byte](($c -shr 8) -band 0xFF))
    }
    $w.Dispose(); [System.IO.File]::WriteAllBytes($path, $ms.ToArray()); $ms.Dispose()
}

# Pre-compute a sine table
$sinTbl = New-Object double[] 1024
for ($i = 0; $i -lt 1024; $i++) { $sinTbl[$i] = [Math]::Sin(2 * [Math]::PI * $i / 1024) }

function SinF($f, $t) { $sinTbl[[int]($f * $t * 1024) -band 0x3FF] }

# Generate a complete tone buffer
function Tone($freq, $dur, $pattern) {
    $n = [int]($sr * $dur); $b = New-Object double[] $n; $step = 0
    for ($i = 0; $i -lt $n; $i++) {
        $t = $i / $sr
        $env = 1.0; $fl = [int]($sr * 0.01)
        if ($i -lt $fl) { $env = $i / $fl } elseif ($i -gt ($n - $fl)) { $env = ($n - $i) / $fl }
        $v = 0.0
        if ($pattern -eq "const") { $v = SinF $freq $t }
        elseif ($pattern -eq "pulse") { $on = 0.15; $off = 0.35; $pos = $t % ($on + $off); if ($pos -le $on) { $v = (& SinF $freq $t) } }
        elseif ($pattern -eq "slowpulse") { $on = 0.5; $off = 0.5; $pos = $t % ($on + $off); if ($pos -le $on) { $v = (& SinF $freq $t) } }
        elseif ($pattern -eq "double") { $on = 0.1; $g = 0.15; $on2 = 0.1; $off = 0.65; $pos = $t % ($on+$g+$on2+$off); if ($pos -le $on -or ($pos -gt ($on+$g) -and $pos -le ($on+$g+$on2))) { $v = (& SinF $freq $t) } }
        elseif ($pattern -eq "alt") { $ap = 0.2; $alt = [int][Math]::Floor($t/$ap)%2; $af=$freq*(1+$alt*0.5); $v=(& SinF $af $t) }
        elseif ($pattern -eq "sweep") { $sf=$freq+$freq*2*$t/$dur; $v=(& SinF $sf $t) }
        $b[$i] = $v * $env
    }
    return $b
}

function Song($notes, $dur) {
    $n = [int]($sr * $dur); $b = New-Object double[] $n
    foreach ($note in $notes) {
        $f=$note.f; $s=$note.s; $d=$note.d; $a=$note.a; $pf=$note.pf
        $si=[int]($s*$sr); $ni=[int]($d*$sr); $end=[Math]::Min($si+$ni,$n)
        for ($i = $si; $i -lt $end; $i++) {
            $t=($i-$si)/$sr; $rt=$t/$d
            $env=[Math]::Min(1.0,$rt*80)*[Math]::Min(1.0,(1.0-$rt)*40)
            $v=(& SinF $f $t); $v+=0.3*(& SinF ($f*2) $t); $v+=0.15*(& SinF ($f*3) $t)
            $v*=$a*$env
            if ($pf) { $v*=0.5+0.5*[Math]::Sin(2*[Math]::PI*$pf*$t) }
            $b[$i]+=$v
        }
    }
    $mx=[Math]::Max(0.01,($b|Measure-Object -Maximum).Maximum); $sc=[Math]::Min(1.0,0.9/$mx)
    for($i=0;$i-lt$n;$i++){$b[$i]*=$sc}
    return $b
}

$C4=262; $D4=294; $E4=330; $F4=349; $G4=392; $A4=440; $B4=494; $C5=523; $D5=587; $E5=659; $C3=131; $G3=196; $A3=220; $F3=175

# 1. Amanecer - gentle C major arpeggio
$am = @()
foreach ($t in @(0,0.8,1.6,2.4,3.2,4.0,4.8,5.6)) {
    $notes = @($C4,$E4,$G4,$C5,$G4,$E4); $ni=$t/0.8%6
    $am += @{f=$notes[$ni]; s=$t; d=0.7; a=0.5; pf=$null}
}

# 2. Melodia - upbeat pentatonic
$mel = @()
$pent = @($C4,$D4,$E4,$G4,$A4,$C5,$A4,$G4,$E4,$D4)
for ($i=0;$i-lt$pent.Count*2;$i++) {
    $ni=$i%$pent.Count; $s=$i*0.35
    $mel += @{f=$pent[$ni]; s=$s; d=0.3; a=0.5; pf=$null}
    if($i%4-eq0){$mel+=@{f=$C3; s=$s; d=0.3; a=0.3; pf=$null}}
}

# 3. Bosque - nature pentatonic
$bos = @()
$pn = @($D4,$E4,$G4,$A4,$D5)
for ($j=0;$j-lt5;$j++) {
    $t=$j*1.2; $ni=0
    foreach ($f in $pn) { $bos+=@{f=$f; s=$t+$ni*0.25; d=0.5; a=0.35; pf=$null}; $ni++ }
}
for($j=0;$j-lt8;$j++){$bos+=@{f=130; s=$j; d=1.0; a=0.15; pf=$null}}

# 4. Suave - chord progression
$sua = @()
$chords = @(@($C4,$E4,$G4), @($G3,$B4,$D5), @($A3,$C5,$E5), @($F3,$A4,$C5))
for ($i=0;$i-lt8;$i++) {
    $ci=$i%4; $st=1.0*$i
    foreach ($f in $chords[$ci]) {$sua+=@{f=$f; s=$st; d=0.9; a=0.3; pf=$null}}
}

# 5. Energia - bright fast
$ene = @()
$me = @($C5,$D5,$E5,$G5,$A5,$G5,$E5,$D5,$C5,$D5,$E5,$G5,$A5,$G5,$E5,$C5)
for ($i=0;$i-lt$me.Count;$i++) {
    $s=$i*0.22
    $ene += @{f=$me[$i]; s=$s; d=0.18; a=0.5; pf=$null}
    if($i%4-eq0){$ene+=@{f=$C3; s=$s; d=0.18; a=0.3; pf=$null}}
}

# 6. Clasico - marimba style
$cla = @()
$mc = @($C5,$G4,$E4,$C4,$E4,$G4,$C5,$G4,$E4,$C4,$E4,$G4,$C5,$E5,$G5,$C6)
for ($i=0;$i-lt$mc.Count;$i++) {
    $s=$i*0.4
    $cla += @{f=$mc[$i]; s=$s; d=0.35; a=0.5; pf=8}
}

$songs = @(
    @{id="amanecer"; data=$am; dur=7.0},
    @{id="melodia"; data=$mel; dur=7.0},
    @{id="bosque"; data=$bos; dur=7.0},
    @{id="suave"; data=$sua; dur=8.0},
    @{id="energia"; data=$ene; dur=7.0},
    @{id="clasico"; data=$cla; dur=7.0}
)

foreach ($s in $songs) {
    $buf = Song $s.data $s.dur
    Wav (Join-Path $out "$($s.id).wav") $buf
    Write-Host "$($s.id).wav"
}

$siz = (Get-ChildItem $out -Filter *.wav | Measure-Object -Property Length -Sum).Sum
Write-Host "Done - $([int]($siz/1024)) KB total"
