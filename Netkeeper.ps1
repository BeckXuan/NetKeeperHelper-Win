## Encoding Username
function Shift-Right ([int]$numob, [int]$bits) {
    $numres = [Math]::Floor(($numob / [Math]::Pow(2, $bits)))
    Write-Output $numres
}
function Shift-Left ([int]$numob, [int]$bits) {
    $numres = ($numob * [Math]::Pow(2, $bits))
    Write-Output $numres
}
function Get-PIN ($PIN0) {
    $RAD = "singlenet01" #zjxinlisx01
    $time = (New-Timespan 1/1/1970 $(Get-Date).ToUniversalTime()).TotalSeconds
    $timediv5 = [Math]::Floor($time / 5)
    $timehash = @(0, 0, 0, 0)
    for ($i = 0; $i -le 3; $i++) {
        for ($j = 0; $j -le 7; $j++) {
            $timehash[$i] += (Shift-Left (((Shift-Right $timediv5 ($i + 4 * $j)) -band 1)) (7 - $j))
        }
    }
    $tmp = @(0, 0, 0, 0)
    $tmp[0] = ($timediv5 -band 0xff000000) / 0x1000000
    $tmp[1] = ($timediv5 -band 0xff0000) / 0x10000
    $tmp[2] = ($timediv5 -band 0xff00) / 0x100
    $tmp[3] = ($timediv5 -band 0xff)
    for ($i = 0; $i -le 3; $i++) {
        $PIN1 += [convert]::ToChar($tmp[$i])
    }
    $bm = "$PIN1" + $username.split('@')[0] + $RAD
    $cryptoServiceProvider = [System.Security.Cryptography.MD5CryptoServiceProvider]
    $hashAlgorithm = new-object $cryptoServiceProvider
    $hashByteArray = $hashAlgorithm.ComputeHash([Char[]]$bm)
    foreach ($byte in $hashByteArray) { $bm0 += "{0:X2}" -f $byte }
    $pk = $bm0.ToLower().substring(0, 2)
    $PIN27 = @(0, 0, 0, 0, 0, 0)
    $PIN2 = ''
    $PIN27[0] = ((Shift-Right $timeHash[0] 2) -band 0x3F)
    $PIN27[1] = ((Shift-Left ($timeHash[0] -band 0x03) 4) -band 0xff) -bor ((Shift-Right $timeHash[1] 4) -band 0x0F)
    $PIN27[2] = ((Shift-Left ($timeHash[1] -band 0x0F) 2) -band 0xff) -bor ((Shift-Right $timeHash[2] 6) -band 0x03)
    $PIN27[3] = $timeHash[2] -band 0x3F
    $PIN27[4] = (Shift-Right $timeHash[3] 2) -band 0x3F
    $PIN27[5] = (Shift-Left ($timeHash[3] -band 0x03) 4) -band 0xff
    for ($i = 0; $i -le 5; $i++) {
        if ((($PIN27[$i] + 0x20) -band 0xff) -lt 0x40) { $PIN27[$i] = (($PIN27[$i] + 0x20) -band 0xff) } else { $PIN27[$i] = (($PIN27[$i] + 0x21) -band 0xff) }
    }
    for ($i = 0; $i -le 5; $i++) {
        $PIN2 += [convert]::ToChar($PIN27[$i])
    }
    $PIN = "`r`n" + $PIN2 + $pk + $username
    Write-Output $PIN
}
## Read JSON
function Read-JSON() {
    if (Test-Path $jsonPath) {
        $script:json = $(Get-Content $jsonPath) | ConvertFrom-Json
        if (($null -ne $json.password) -and ($null -ne $json.expiration) -and ($null -ne $json.valid)) {
            if ($json.valid) {
                if ((Get-Date) -lt (Get-Date $json.expiration)) {
                    $script:password = $json.password
                    return $true
                }
            }
        }
    }
    else {
        $script:json = @{}
    }
    return $false
}
## Save JSON
function Save-JSON() {
    $json | convertTo-Json | Set-Content $jsonPath
}
## Dial
function Dial-Netkeeper() {
    $realusername = Get-PIN($username)
    Write-Host "Connecting..."
    rasdial $pppname $realusername $password | Tee-Object -Variable result
    if ($?) {
        if (-not $flag) {
            $json.password = $password
            $json.expiration = ((Get-Date) + (New-TimeSpan -Days 1 -Hours 4)).ToString("yyyy-MM-dd HH:mm:ss")
            $json.valid = $true
            Save-JSON
        }
    }
    elseif ($result -match 691) {
        if ($flag) {
            $json.valid = $false
            Save-JSON
        }
    }
    #netsh wlan start hostednetwork
}
## Modify Window Config
$Host.UI.RawUI.BackgroundColor = "Black"
$hostsize = new-object System.Management.Automation.Host.Size(40, 15)
$Host.UI.RawUI.WindowSize = $hostsize
$Host.UI.RawUI.BufferSize = $hostsize

## PPPOE Entry
$pppname = "Netkeeper"

## Netkeeper Accounts
$username = "12345678900@XXXX.XY"

## JSON Path
$jsonPath = "$PSScriptRoot\Netkeeper.json"
$flag = Read-JSON
if (-not $flag) {
    $password = $(Read-Host "Password")
}

Dial-Netkeeper
Write-Host
pause
