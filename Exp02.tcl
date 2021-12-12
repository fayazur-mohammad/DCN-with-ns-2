set ns [new Simulator]

set tracefile [open Exp02.tr w]
$ns trace-all $tracefile

set namfile [open Exp02.nam w]
$ns namtrace-all $namfile

set n0 [$ns node]
set n1 [$ns node]

$ns duplex-link $n0 $n1 3Mb 10ms DropTail

set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0

set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp0

set null0 [new Agent/Null]
$ns attach-agent $n1 $null0
$ns connect $udp0 $null0

proc finish {} {
	global ns tracefile namfile
	$ns flush-trace
	close $tracefile
	close $namfile
	exit 0
}

$ns at 1.0 "$cbr0 start"
$ns at 8.0 "$cbr0 stop"

$ns at 10.0 "finish"
$ns run
