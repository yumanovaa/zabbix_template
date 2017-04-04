###########################################################
###########################################################
####                                                   ####
####             Скрипт для обновления                 ####
####         элементов данных IIS сервера              ####
####                                                   ####
###########################################################
###########################################################

#Описание принимаемых параметров. Какой параметр опрашиваем? 
#Сайты или пулы?
Param (
    [Parameter (Mandatory=$true, Position=1)]
    [string]$type_resource, #web site or pool
    
    [Parameter (Mandatory=$true, Position=2)]
    [string]$name_item, #name item 

    [Parameter (Mandatory=$true, Position=3)]
    [string]$name_resource #name Website or pool
)

#Импорт модуля управления IIS
Import-Module WebAdministration

function Status_Pool ($name_pool) {
    return Get-WebAppPoolState -Name $name_pool | ForEach-Object { $_.Value }
}
function Queue_Length ($name_pool) {
    [array]$queue = Get-WebRequest -AppPool $name_pool
    return $queue.Length
}
function Time_Query_Wait ($name_pool) {
    [array]$QueueRequest = Get-WebRequest -AppPool $name_pool
    [double]$MaxTime = 0
    switch ($QueueRequest.Length) {
        0 {
            $MaxTime = 0
            break
        }
        1 {
            $MaxTime = [math]::Round(($QueueRequest[0].timeElapsed / 1000), 0) 
            break
        }
        default {
            foreach ($Request in $QueueRequest) {
                if ($Request.timeElapsed -gt $MaxTime) { 
                    $MaxTime = $Request.timeElapsed
                    $MaxTime = [math]::Round(($MaxTime / 1000), 0)
                }
            }
            break
        }
    }
    return $MaxTime
}

if ($type_resource -eq "pool") {
    switch ($name_item) {
        "status" {
            if ((Status_Pool $name_resource) -eq "Started") {
                return 1
            } else {
                return 0
            }
        }
        "queue" {
            return (Queue_Length $name_resource)
        }
        "maxtimereqwait" {
            return (Time_Query_Wait $name_resource)
        }
    }
}
