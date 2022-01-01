# This script is created by NSG2 beta1
# <http://wushoupong.googlepages.com/nsg>

#===================================
#     Simulation parameters setup
#===================================
set val(stop)   130.0                         ;# time of simulation end

#===================================
#        Initialization        
#===================================
#Create a ns simulator
set ns [new Simulator]

$ns color 1 Red

#Open the NS trace file
set tracefile [open Exp07-TCP.tr w]
$ns trace-all $tracefile

#Open the NAM trace file
set namfile [open Exp07-TCP.nam w]
$ns namtrace-all $namfile

set cwndfile [open Exp07-TCP-cwnd.dat w]
#===================================
#        Nodes Definition        
#===================================
#Create 6 nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

#===================================
#        Links Definition        
#===================================
#Createlinks between nodes
$ns duplex-link $n0 $n2 1.0Mb 10ms DropTail
$ns queue-limit $n0 $n2 50
$ns duplex-link $n1 $n2 1.0Mb 10ms DropTail
$ns queue-limit $n1 $n2 50
$ns duplex-link $n3 $n4 0.5Mb 50ms DropTail
$ns queue-limit $n3 $n4 10
$ns duplex-link $n3 $n5 0.5Mb 50ms DropTail
$ns queue-limit $n3 $n5 10
$ns duplex-link $n2 $n3 0.1Mb 100ms DropTail
$ns queue-limit $n2 $n3 10

#Give node position (for NAM)
$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n3 $n4 orient right-up
$ns duplex-link-op $n3 $n5 orient right-down
$ns duplex-link-op $n2 $n3 orient right

$ns duplex-link-op $n2 $n3 queuePos 0.5
#===================================
#        Agents Definition        
#===================================
#Setup a TCP connection
set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0
set sink1 [new Agent/TCPSink]
$ns attach-agent $n4 $sink1
$ns connect $tcp0 $sink1
$tcp0 set packetSize_ 2048
$tcp0 set fid_ 1

proc recWin { tcp file } {
global ns
set time 0.1
set ctime [$ns now]
set wnd [$tcp set cwnd_]
puts $file "$ctime $wnd"
$ns at [expr $ctime + $time] "recWin $tcp $file"
}
$ns at 0.1 "recWin $tcp0 $cwndfile"

#===================================
#        Applications Definition        
#===================================
#Setup a FTP Application over TCP connection
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ns at 1.0 "$ftp0 start"
$ns at 125.0 "$ftp0 stop"


#===================================
#        Termination        
#===================================
#Define a 'finish' procedure
proc finish {} {
    global ns tracefile namfile cwndfile
    $ns flush-trace
    close $tracefile
    close $namfile
    close $cwndfile
    exec nam Exp07-TCP.nam &
    exit 0
}
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"done\" ; $ns halt"
$ns run
