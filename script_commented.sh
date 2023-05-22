#!/bin/bash # Execute as bash.

# System Architecture info (-a all info)
arc=$(uname -a)

# Prints lines matching pattern "physical id" inside file /proc/cpuinfo, uniq
# to ignore duplicated lines and wc -l to count the number of lines and display
# that number.
pcpu=$(grep "physical id" /proc/cpuinfo | uniq | wc -l)

# Print lines matching "processor" (^ means only lines that start with word
# processor and not every occurrence of the word)
vcpu=$(grep "^processor" /proc/cpuinfo | wc -l)

# free gives info about available memory, RAM, -m shows info in megabytes, awk
# filters info so that only the line starting by "Mem:" is showed, and the
# print $2 tells it to print only the second field on that line.
fram=$(free -m | awk '$1 == "Mem:" {print $2})
