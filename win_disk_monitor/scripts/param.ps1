###########################################################
###########################################################
####                                                   ####
####             Скрипт для обновления                 ####
####         элементов данных производительности       ####
####              дисковой подсистемы                  ####
####                                                   ####
###########################################################
###########################################################

$watch = [System.Diagnostics.Stopwatch]::StartNew()

$ConfigFile = "C:\zabbix\scripts\win_disk_monitor\config\physical_disk_monitor_param.json"
$CacheFolder = "C:\zabbix\scripts\win_disk_monitor\cache"

$rezult = New-Object Collections.ArrayList

$PhysicalDiskParam = Get-Content -RAW $ConfigFile | ConvertFrom-Json
ForEach ($param in $PhysicalDiskParam) {
    if ($param.Enable -eq $TRUE) {
        ForEach ($value in $param.Params) {
            if ($value.Enable -eq $TRUE) {
                $temp = (Get-Counter -Counter ($value.PerfomanceCommand)).CounterSamples.CookedValue
                $pathcache = $CacheFolder + "\" + $value.DeviseID + "_" + $value.DeviseLabel + "_" + $value.ShortCmdled
                [math]::Round($temp, 2) -replace ",","." > $pathcache
            }
        }
    }
}
$watch.Stop()
$watch.Elapsed.Seconds > ($CacheFolder + "\execution_time")