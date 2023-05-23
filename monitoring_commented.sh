# Execute as bash.
#!/bin/bash

# System Architecture info (-a all info)
arc=$(uname -a)

# Prints lines matching pattern "physical id" inside file /proc/cpuinfo, uniq
# to ignore duplicated lines and wc -l to count the number of lines and display
# that number.
pcpu=$(grep "physical id" /proc/cpuinfo | uniq | wc -l)

# Print lines matching "processor" (^ means only lines that start with word
# processor and not every occurrence of the word)
vcpu=$(grep "^processor" /proc/cpuinfo | wc -l)

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

# 'who' show info about the last boot. awk filters only date and time.
lboot=$(who -b | awk '{print $3 " " $4}')

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

sudo=$(cat /var/log/sudo/sudo.log | wc -l)

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
