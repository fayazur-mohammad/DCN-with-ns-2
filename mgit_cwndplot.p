################################################################################
# This Gnuplot script searches the working directory for *-cwnd.dat files and
# plots time vs window size curves for data in each file.
#
# Author: Dr. Fayazur Rahaman M, Dept. ECE, MGIT, Hyderabad
# Version: 01 , 05 Dec 2021
# Suggestions : mfrahaman_ece@mgit.ac.in
# History
# Version 01: Basic Version
################################################################################

set autoscale
unset log
unset label

set xtic auto
set ytic auto

set title "Congestion Window size at the source"
set xlabel "Time (secs)"
set ylabel "Window size"
set grid

list=system('ls -1B *-cwnd.dat')
print("Plotting curves from files ....")
print(list)

plot for [file in list] file with lines lw 2 title file


pause -1
