################################################################################
# This Gnuplot script searches the working directory for *-th.dat files and
# plots time vs average throughput curves for data in each file.
#
# Author: Dr. Fayazur Rahaman M, Dept. ECE, MGIT, Hyderabad
# Version: 01 , 01 Dec 2021
# Suggestions : mfrahaman_ece@mgit.ac.in
# History
# Version 01: Basic Version
################################################################################

set autoscale
unset log
unset label

set xtic auto
set ytic auto

set title "Throughput plots at the destination "
set xlabel "Time (secs)"
set ylabel "Throughput (kbps)"
set grid

list=system('ls -1B *-th.dat')
print("Plotting curves from files ....")
print(list)

plot for [file in list] file with lines lw 2 title file

pause -1
