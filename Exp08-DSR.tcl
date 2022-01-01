# This script is created by NSG2 beta1
# <http://wushoupong.googlepages.com/nsg>

#===================================
#     Simulation parameters setup
#===================================
set val(chan)   Channel/WirelessChannel    ;# channel type
set val(prop)   Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)  Phy/WirelessPhy            ;# network interface type
set val(mac)    Mac/802_11                 ;# MAC type
set val(ifq)    CMUPriQueue    ;# interface queue type
set val(ll)     LL                         ;# link layer type
set val(ant)    Antenna/OmniAntenna        ;# antenna model
set val(ifqlen) 50                         ;# max packet in ifq
set val(nn)     3                          ;# number of mobilenodes
set val(rp)     DSR                       ;# routing protocol
set val(x)      500                      ;# X dimension of topography
set val(y)      400                      ;# Y dimension of topography
set val(stop)   160.0                         ;# time of simulation end

#===================================
#        Initialization        
#===================================
#Create a ns simulator
set ns [new Simulator]

#Setup topography object
set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)
create-god $val(nn)

#Open the NS trace file
set tracefile [open Exp08-DSR.tr w]
$ns trace-all $tracefile

#Open the NAM trace file
set namfile [open Exp08-DSR.nam w]
$ns namtrace-all $namfile
$ns namtrace-all-wireless $namfile $val(x) $val(y)
set chan [new $val(chan)];#Create wireless channel

set cwndfile [open Exp08-DSR-cwnd.dat w]

#===================================
#     Mobile node parameter setup
#===================================
$ns node-config -adhocRouting  $val(rp) \
                -llType        $val(ll) \
                -macType       $val(mac) \
                -ifqType       $val(ifq) \
                -ifqLen        $val(ifqlen) \
                -antType       $val(ant) \
                -propType      $val(prop) \
                -phyType       $val(netif) \
                -channel       $chan \
                -topoInstance  $topo \
                -agentTrace    ON \
                -routerTrace   ON \
                -macTrace      ON \
                -movementTrace ON

#===================================
#        Nodes Definition        
#===================================
#Create 3 nodes
set n0 [$ns node]
$n0 set X_ 5
$n0 set Y_ 5
$n0 set Z_ 0.0
$ns initial_node_pos $n0 20
set n1 [$ns node]
$n1 set X_ 490
$n1 set Y_ 285
$n1 set Z_ 0.0
$ns initial_node_pos $n1 20
set n2 [$ns node]
$n2 set X_ 150
$n2 set Y_ 240
$n2 set Z_ 0.0
$ns initial_node_pos $n2 20

#===================================
#        Generate movement          
#===================================
$ns at 10 " $n0 setdest 250 250 3 " 
$ns at 110 " $n0 setdest 480 300 5 " 
$ns at 15 " $n1 setdest 45 285 5 " 

#===================================
#        Agents Definition        
#===================================
#Setup a TCP/Newreno connection
set tcp0 [new Agent/TCP/Newreno]
$ns attach-agent $n0 $tcp0
set sink1 [new Agent/TCPSink]
$ns attach-agent $n1 $sink1
$ns connect $tcp0 $sink1
$tcp0 set packetSize_ 1500

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
#Setup a FTP Application over TCP/Newreno connection
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ns at 12.0 "$ftp0 start"
$ns at 150.0 "$ftp0 stop"


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
    exec nam Exp08-DSR.nam &
    exit 0
}
for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "\$n$i reset"
}
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"done\" ; $ns halt"
$ns run
