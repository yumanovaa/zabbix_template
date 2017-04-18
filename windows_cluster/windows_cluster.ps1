Param (   
    [Parameter (Mandatory=$false, Position=1)]
    [string]$name_node,

    [Parameter (Mandatory=$false, Position=2)]
    [string]$name_param,

    [Parameter (Mandatory=$false, Position=3)]
    [string]$discovery
)


if ($discovery -eq 1) {
    $first=0
    $JSON_Response = "{`r`n` `t`"data`":[`r`n"
    gwmi -class MSCluster_Node -namespace "root\mscluster" | ForEach-Object {
        if ($first -ne 0 ) { $JSON_Response = $JSON_Response + ", `r`n" }
        $JSON_Response = $JSON_Response + "`t`t{ `"{`#NODENAME}`":`"" + $_.Name + "`" }"
        $first++
    }
    $JSON_Response = $JSON_Response + "`r`n`t]`r`n}"
    return $JSON_Response
} else {
    switch ($name_param) {
        "cluster_state" {
            #if (((Get-WmiObject win32_computersystem).DNSHostName+"."+(Get-WmiObject win32_computersystem).Domain) -match $name_node) { 
                $response = gwmi -class "MSCluster_Resource" -namespace "root\mscluster" | Where-Object {$_.name -eq "Cluster Name"}
                return $response.state
                exit
            #}
        }
        "network_node_state" {
            gwmi -class "MSCluster_NetworkInterface" -namespace "root\mscluster" | ForEach-Object {
                if ($name_node -match $_.SystemName) {
                    return $_.state
                    exit
                }
            }
        }
        "primary_SQL_AG_node" {
            $response = gwmi -class "MSCluster_Resource" -namespace "root\mscluster" | Where-Object {$_.type -match "SQL Server Availability Group"}
            return $response.OwnerNode
            exit
        }
    }
}