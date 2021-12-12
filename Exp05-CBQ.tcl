# This script is created by NSG2 beta1
# <http://wushoupong.googlepages.com/nsg>

#===================================
#     Simulation parameters setup
#===================================
set val(stop)   10.0                         ;# time of simulation end

#===================================
#        Initialization        
#===================================
#Create a ns simulator
set ns [new Simulator]
$ns color 1 Blue
$ns color 2 Red
$ns color 3 Green

#Open the NS trace file
set tracefile [open Exp05-CBQ.tr w]
$ns trace-all $tracefile

#Open the NAM trace file
set namfile [open Exp05-CBQ.nam w]
$ns namtrace-all $namfile

#===================================
#        Nodes Definition        
#===================================
#Create 5 nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]

#===================================
#        Links Definition        
#===================================
#Createlinks between nodes
$ns duplex-link $n0 $n3 2.0Mb 10ms DropTail
$ns queue-limit $n0 $n3 50
$ns duplex-link $n1 $n3 2.0Mb 10ms DropTail
$ns queue-limit $n1 $n3 50
$ns duplex-link $n2 $n3 2.0Mb 10ms DropTail
$ns queue-limit $n2 $n3 50

$ns simplex-link $n3 $n4 1Mb 100ms CBQ/WRR
$ns simplex-link $n4 $n3 1Mb 10ms DropTail
			
set cbqlink [$ns link $n3 $n4]
set topclass [new CBQClass]
$topclass setparams none 0 1 auto 8 2 0
			
set class1 [new CBQClass]
set queue1 [new Queue/DropTail]
$class1 install-queue $queue1
$class1 setparams $topclass true 0.5 auto 1 1 0
			
set class2 [new CBQClass]
set queue2 [new Queue/DropTail]
$class2 install-queue $queue2
$class2 setparams $topclass true 0.3 auto 1 1 0
			
set class3 [new CBQClass]
set queue3 [new Queue/DropTail]
$class3 install-queue $queue3
$class3 setparams $topclass true 0.2 auto 1 1 0
			
$cbqlink insert $topclass
$cbqlink insert $class1
$cbqlink insert $class2
$cbqlink insert $class3
			
$cbqlink bind $class1 1 
$cbqlink bind $class2 2
$cbqlink bind $class3 3


#Give node position (for NAM)
$ns duplex-link-op $n0 $n3 orient right-down
$ns duplex-link-op $n1 $n3 orient right
$ns duplex-link-op $n2 $n3 orient right-up
$ns duplex-link-op $n2 $n3 queuePos 0.5

#===================================
#        Agents Definition        
#===================================
#Setup a UDP connection
set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0
set null3 [new Agent/Null]
$ns attach-agent $n4 $null3
$ns connect $udp0 $null3
$udp0 set packetSize_ 500
$udp0 set fid_ 1

#Setup a UDP connection
set udp1 [new Agent/UDP]
$ns attach-agent $n1 $udp1
set null4 [new Agent/Null]
$ns attach-agent $n4 $null4
$ns connect $udp1 $null4
$udp1 set packetSize_ 500
$udp1 set fid_ 2


#Setup a UDP connection
set udp2 [new Agent/UDP]
$ns attach-agent $n2 $udp2
set null5 [new Agent/Null]
$ns attach-agent $n4 $null5
$ns connect $udp2 $null5
$udp2 set packetSize_ 500
$udp2 set fid_ 3

#===================================
#        Applications Definition        
#===================================
#Setup a CBR Application over UDP connection
set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp0
$cbr0 set packetSize_ 500
$cbr0 set rate_ 1.0Mb
$cbr0 set random_ null
$ns at 1.0 "$cbr0 start"
$ns at 8.0 "$cbr0 stop"

#Setup a CBR Application over UDP connection
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1
$cbr1 set packetSize_ 500
$cbr1 set rate_ 1.0Mb
$cbr1 set random_ null
$ns at 1.0 "$cbr1 start"
$ns at 8.0 "$cbr1 stop"

#Setup a CBR Application over UDP connection
set cbr2 [new Application/Traffic/CBR]
$cbr2 attach-agent $udp2
$cbr2 set packetSize_ 500
$cbr2 set rate_ 1.0Mb
$cbr2 set random_ null
$ns at 1.0 "$cbr2 start"
$ns at 8.0 "$cbr2 stop"


#===================================
#        Termination        
#===================================
#Define a 'finish' procedure
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam Exp05-CBQ.nam &
    exit 0
}
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"done\" ; $ns halt"
$ns run
