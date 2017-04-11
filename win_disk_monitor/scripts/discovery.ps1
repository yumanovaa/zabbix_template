###########################################################
###########################################################
####                                                   ####
####             Скрипт для автоматического            ####
####           обнаружения физических дисков           ####
####                                                   ####
###########################################################
###########################################################

#Configurations scritp#
$ConfigFile = "C:\zabbix\scripts\win_disk_monitor\config\physical_disk_monitor_param.json"

function CreateConfig ($ConfigFile) {
    $PhysicalDiskParam = @()
    $MetaParam  = (Get-Counter -ListSet PhysicalDisk).PathsWithInstances
    foreach ($param in $MetaParam) {
        $disk = [regex]::split($param, '\(|\)')
        if (($disk[1] -notmatch "total") -and ($disk[2] -match "Current Disk Queue Length")){
            $a = [regex]::split($disk[1], '\s')
            $object = New-Object -TypeName PSObject
            $object | Add-Member -Name 'NameDisk' -MemberType Noteproperty -Value $a[1][0]
            $object | Add-Member -Name 'Enable' -MemberType Noteproperty -Value $FALSE
            $object | Add-Member -Name 'Params' -MemberType Noteproperty -Value (New-Object Collections.ArrayList)
            $PhysicalDiskParam += $object
        }
    }
    foreach ($param in $MetaParam) {
        $disk = [regex]::split($param, '\(|\)')
        if ($disk[1] -notmatch "total"){
            $a = [regex]::split($disk[1], '\s')
            $object = New-Object -TypeName PSObject
            $object | Add-Member -Name 'DeviseID' -MemberType Noteproperty -Value $a[0]
            $object | Add-Member -Name 'DeviseLabel' -MemberType Noteproperty -Value $a[1][0]
            $object | Add-Member -Name 'ShortCmdled' -MemberType Noteproperty -Value ($disk[2] -replace "\s|\.|%|\\|/","")
            $object | Add-Member -Name 'PerfomanceCommand' -MemberType Noteproperty -Value $param
            $object | Add-Member -Name 'Enable' -MemberType Noteproperty -Value $TRUE
            $l = 0
            foreach ($id in $PhysicalDiskParam) {
                if ($id.NameDisk -eq $a[1][0]) {break} else {$l++}
            }
            $temp = $PhysicalDiskParam[$l].Params.Add($object)
        }
    }
    $JSON_Response = "[`r`n` `t{`r`n"
    $first=0
    foreach ($param in $PhysicalDiskParam) {
        if ($first -ne 0 ) { $JSON_Response = $JSON_Response + "`n`t},`n`t{`n" }
        $JSON_Response = $JSON_Response + "`t`t`"NameDisk`": `"" + $param.NameDisk + "`",`n"
        $JSON_Response = $JSON_Response + "`t`t`"Enable`": `"" + $param.Enable + "`",`n"
        $JSON_Response = $JSON_Response + "`t`t`"Params`": `n" + (ConvertTo-Json $param.Params)
        $first++
    }
    $JSON_Response = $JSON_Response + "`r`n`t}`r`n]"
    $JSON_Response >> $ConfigFile
}

function CreateJSONDiscovery ($ConfigFile) {
    $PhysicalDiskParam = Get-Content -RAW $ConfigFile | ConvertFrom-Json
    $JSON_Response = "{`r`n` `t`"data`":[`r`n"
    $first=0
    ForEach ($param in $PhysicalDiskParam) {
        if ($param.Enable -eq $TRUE) {
            if ($first -ne 0 ) { $JSON_Response = $JSON_Response + ", `r`n" }
            $JSON_Response = $JSON_Response + "`t`t{ `"{`#DEVICEID}`":`"" + $param.Params[0].DeviseID + "`", `"{#DISKID}`":`"" + $param.Params[0].DeviseLabel +"`" }"
            $first++
        }
    }
    $JSON_Response = $JSON_Response + "`r`n`t]`r`n}"
    return $JSON_Response
}

if (!(Test-Path $ConfigFile)) {
    CreateConfig $ConfigFile
} else {
    CreateJSONDiscovery $ConfigFile
}
