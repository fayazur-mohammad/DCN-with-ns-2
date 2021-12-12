set ns [new Simulator]

set tracefile [open Exp01.tr w]
$ns trace-all $tracefile

set namfile [open Exp01.nam w]
$ns namtrace-all $namfile

set n0 [$ns node]
set n1 [$ns node]

$ns duplex-link $n0 $n1 3Mb 5ms DropTail

proc finish {} {
	global ns tracefile namfile
	$ns flush-trace
	close $tracefile
	close $namfile
	exit 0
}

$ns at 5.0 "finish"
$ns run
