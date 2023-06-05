#!/bin/bash
arc=$(uname -srvmo)
pcpu=$(lscpu | grep 'Core(s)' | awk '{print $4}')
vcpu=$(lscpu | grep 'Thread(s)' | awk '{print $4}')
tcpu=$(($pcpu * $vcpu))
tram=$(free -m | awk '$1 == "Mem:" {print $2}')
uram=$(free -m | awk '$1 == "Mem:" {print $3}')
pram=$(free -m | awk '$1 == "Mem:" {printf("%.2f", $3 / $2 * 100)}')
tdisk=$(df -BG | grep '^/dev/' | grep -v '/boot$' | awk '{tdisk += $2} END {print tdisk}')
udisk=$(df -BG | grep '^/dev/' | grep -v '/boot$' | awk '{udisk += $3} END {print udisk}')
pdisk=$(df -BG | grep '^/dev/' | grep -v '/boot$' | awk '{tdisk += $2} {udisk += $3} END {printf("%.2f", udisk/tdisk*100)}')
ucpu=$(top -bn1 | grep '^%Cpu' | awk '{acpu = 100 - $8} END {print acpu}')
rboot=$(last | grep 'reboot' | grep 'still running' -m 1 | awk '{print $5" "$6" "$7" @ "$8}')
lvm=$(if [ $(lsblk | grep "lvm" | wc -l) -ne 0 ]; then echo yes; else echo no; fi)
tcp=$(ss -t | grep '^ESTAB' | wc -l)
user=$(users | wc -w)
ip=$(hostname -I)
mac=$(ip address | grep ether | awk '{print $2}')
sudo=$(cat /var/log/sudo/sudo.log | grep 'COMMAND' | wc -l)
wall "	#Architecture: $arc
	#CPU physical: $pcpu
	#vCPU: $tcpu
	#Memory Usage: $uram/${tram}MB ($pram%)
	#Disk Usage: $udisk/${tdisk}Gb ($pdisk%)
	#CPU load: $ucpu%
	#Last boot: $rboot
	#LVM use: $lvm
	#Connections TCP: $tcp ESTABLISHED
	#User log: $user
	#Network: IP $ip ($mac)
	#Sudo: $sudo commands"
