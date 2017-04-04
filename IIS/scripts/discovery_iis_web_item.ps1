###########################################################
###########################################################
####                                                   ####
####             Скрипт для автоматического            ####
####           обнаружения сайтов и пулов IIS          ####
####                                                   ####
###########################################################
###########################################################

#Описание принимаемых параметров. В сущность что обнаруживаем? 
#Сайты или пулы? Websites or Pools
Param (
    [Parameter (Mandatory=$true, Position=1)]
    [string]$WebItem
)

#Импорт модуля управления IIS
Import-Module WebAdministration

$first=0
$JSON_Response = "{`r`n` `t`"data`":[`r`n"

switch ($WebItem) 
    {
        "Websites" {
                Get-Website | ForEach-Object {
                        if ($first -ne 0 ) { $JSON_Response = $JSON_Response + ", `r`n" }
                        $JSON_Response = $JSON_Response + "`t`t{ `"{`#SITENAME}`":`"" + $_.name + "`" }"
                        $first++
                    }
            }
        "Pools"    {
                Get-WebApplication | ForEach-Object {
                        if ($first -ne 0 ) { $JSON_Response = $JSON_Response + ", `r`n" }
                        $JSON_Response = $JSON_Response + "`t`t{ `"{`#POOLNAME}`":`"" + $_.applicationPool + "`" }"
                        $first++
                    }
            }
    }
$JSON_Response = $JSON_Response + "`r`n`t]`r`n}"
return $JSON_Response
