#Task scheduler - Run Powershell Script upon Network Connection
#schtasks /create /tn "Net-Connected" /tr "powershell -executionpolicy bypass -file '%SYSTEMDRIVE%\add_vm_host.ps1'" /SC ONEVENT /EC Microsoft-Windows-NetworkProfile/Operational /MO "*[System[Provider[@Name='Microsoft-Windows-NetworkProfile'] and EventID=10000]]" /RU "System" /F


param([switch]$Elevated)

function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false)  {
    if ($elevated) {
        # tried to elevate, did not work, aborting
    } else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }
    exit
}

$regrex_ip4 = "\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b";
$path_hosts="C:\Windows\System32\drivers\etc\hosts"

$array_vm_names=@(get-vm `
                 | Select -ExpandProperty Networkadapters `
                 | Select -ExpandProperty VMName);

$array_vms_data=New-Object System.Collections.ArrayList
$array_vms_data+=("127.0.0.1 app.k8slens.dev" -replace "`n|`r");

for($i=0; $i -le $array_vm_names.Length - 1; $i++) {

    $ip=@(get-vm `
        | Select -Index $i `
        | Select -ExpandProperty Networkadapters `
        | Select -ExpandProperty IPAddresses `
        | Select-String -Pattern $regrex_ip4 `
        | Select -Index 0)
    if ( !$ip ) {
        $ip = "NULL"
    }

    $vm=@(get-vm `
        | Select -ExpandProperty Networkadapters `
        | Select -ExpandProperty VMName `
        | Select -Index $i) 

        $array_vms_data+=("$ip $vm" -replace "`n|`r");
        echo $array_vms_data
}

[string[]]$vms_hosts = Get-Content -Path $path_hosts


foreach ($i in $array_vms_data) {
    
    $a_ip, $a_name = $i.split()

    $b_ip, $b_name = "";

    foreach ($j in $vms_hosts) {
        $b_ip, $b_name = $j.split()
        #change record
        if ("$a_ip" -notmatch "$b_ip" -and "$a_name" -match "$b_name") {
            #delete
            Set-Content -Path $path_hosts -Value (get-content -Path $path_hosts | Select-String -Pattern $a_name -NotMatch)
            #apend new one
            $i | Out-File -FilePath $path_hosts -append -Encoding UTF8
        }

    }

    #add new record
    if (!$b_name) {
        $i | Out-File -FilePath $path_hosts -append -Encoding UTF8
    }
}
