# Execute as bash.
#!/bin/bash

# System Architecture info (-s kernel name; -r kernel-release; -v kernel-version; -m machine hardware; -o OS)
arc=$(uname -srvmo)

# 'lscpu' gives cpu info. Check ammount of cores.
pcpu=$(lscpu | grep 'Core(s)' | awk '{print $4}')

# Check ammount of threads per core.
vcpu=$(lscpu | grep 'Thread(s)' | awk '{print $4}')

# Multiplies Cores times Threads for total vram.
tcpu=$(($pcpu * $vcpu))

# Free gives info about available RAM, -m shows info in megabytes, awk
# filters info so that only the line starting by "Mem:" is showed, and the
# print $2 tells it to print only the second field on that line.
tram=$(free -m | awk '$1 == "Mem:" {print $2}')

# Same but now filter used ram.
uram=$(free -m | awk '$1 == "Mem:" {print $3}')

# Calculate the percentage by dividing used ram/total ram * 100
pram=$(free -m | awk '$1 == "Mem:" {printf("%.2f", $3/$2*100)}')

# 'df' shows info about disk space usage. -BG scales size by blocks and displays
# them in GB. It then filters the results to show lines starting by 'dev' and
# grep -v excludes the ones that end with '/boot'. ^ indicates start of line and
# $ indicates end of line. Otherwise it would include all lines with dev and
# exclude all lines with /boot.
# The END parameter between the calculation and print ensure it doesn't print
# the result after every time it adds a value.
tdisk=$(df -BG | grep '^dev' | grep -v '/boot$' | awk '{tdisk += $2} END {print tdisk}')

# Same but for used disk space.
udisk=$(df -BG | grep '^dev' | grep -v '/boot$' | awk '{udisk += $3} END {print udisk}')

# Percentage of disk usage
pdisk=$(df -BG | grep '^/dev/' | grep -v '/boot$' | awk '{tdisk += $2} {udisk += $3} END {printf("%.2f", udisk/tdisk*100)}')

# 'top' displays an interactive interface showing the current state of the system.
# -b runs it in batch mode, meaning it's not interactive and sends output directly
# to the command pipeline.
# We then filter the results to show only the line about CPU info, get the idle,
# or available cpu info, and substract 100 to it to get the current utilization rate.
ucpu=$(top -bn1 | grep '^%Cpu' | awk '{acpu = 100 - $8} {print acpu}')

# last shows list of logged in users. find the last reboot that is still running. (-m 1 means stop reading file after NUM times
# in this case 1 time). Then print fields corresponding to date.)
rboot=$(last | grep 'reboot' | grep 'still running' -m 1 | awk '{print $5" "$6" "$7" @ "$8}')

# The command substitution following $ is used to capture the output inside the ().
# '-ne' if not equal, '-eq' would be if equal. [] test command to perform various
# tests on values. ; separates multiple commands on a single line. fi ends the if statement.
lvm=$(if [ $(lsblk | grep "lvm" | wc -l) -ne 0 ]; then echo yes; else echo no; fi)

# Info about sockets using ss, -t to show only TCP connections.
tcp=$(ss -t | grep '^ESTAB' | wc -l)

# -w counts number of words.
user=$(users | wc -w)

# -I shows host ip instead of name.
ip=$(hostname -I)

# MAC address is listed next to 'ether'
mac=$(ip adress | grep ether | awk '{print $2}')

sudo=$(cat /var/log/sudo/sudo.log | grep -a COMMAND | wc -l)

wall "	#Architecture: $arc
	#CPU physical: $pcpu
	#vCPU: $vcpu
	#Memory Usage: $uram/{$tram}Gb ($pram)
	#Disk Usage: $udisk/{$tdisk}Gb ($pdisk)
	#CPU load: $ucpu%
	#Last boot: $lboot
	#LVM use: $lvm
	#Connections TCP: $tcp ESTABLISHED
	#User log: $user
	#Network: IP $ip ($mac)
	#Sudo: $sudo commands"
