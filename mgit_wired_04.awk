################################################################################
# This script analyses the tracefile generated by ns-2 simulator and computes
# various end-to-end data transfer performance parameters for each source
# to destination application pair.
# It handles scenarios where application pair are connected using single or 
# multiple links
# To do: Build capability to detect packets dropped due to link errors
#
# Author: Dr. Fayazur Rahaman M, Dept. ECE, MGIT, Hyderabad
# Version: 04 , 01 Dec 2021
# Suggestions : mfrahaman_ece@mgit.ac.in
# History
# Version 04: Added capability to store througput into separate dat files
# Version 03: Added capability to distinguish the drops due to errors
# Version 02: Added capability to distinguish the broadcast packets
# Version 01: Basic Version
################################################################################
{
  event = $1;  event_time = $2; from_node = $3; to_node = $4; pkt_type = $5;
  pkt_size = $6;  flag = $7;  flow_id = $8; src_addr = $9;  dest_addr = $10;
  seq_no = $11;  pkt_id = $12;
  
  key = src_addr ":" dest_addr
  
  if (startTime[key] == 0){
    startTime[key] = event_time
    srcAddr[key] = src_addr
    destAddr[key] = dest_addr
    pktType[key] = pkt_type
  }
  
  split(src_addr, parts, ".")
  src = parts[1]
  
  split(dest_addr, parts, ".")
  dst = parts[1]
  
  seqKey = key ":" seq_no
  
  if (from_node == src) {
    if (event == "+"){
      if(pktSentTime[seqKey] == 0){
        pktSentTime[seqKey] = event_time
        sentPkts[key]++
      } else {
        retrans[key]++
      }
    }
  }
  
  if (event == "h"){
    brdCst_type[seqKey] = 1
    brdCst_node[seqKey] = to_node
  }
  
  if (event == "d"){
    if (brdCst_type[seqKey] == 1 &&  to_node == brdCst_node[seqKey] ){
      discard_broadcast[key]++
    } else {
      if(prev_event[seqKey] == "-"){
        dropPkts_err[key]++
      } else {
        dropPkts[key]++
      }
    }
  }
  
  split(FILENAME, parts, ".")
  file = parts[1]
  
  if (to_node == dst) {
    if (event == "r"){
      if (duplicate[seqKey] == 0){
        rxPkts[key]++
        pktTxDuration[key] += (event_time - pktSentTime[seqKey])
        if (pkt_type == "tcp"){
          data_size = pkt_size - 40
          if (data_size > 0) {
            pktSz[key] += data_size
            rxDataPkts[key]++
            file = file "-tcp-" key "-th.dat"
            printf("%g\t%g\n",event_time,pktSz[key]*8/( (event_time-startTime[key]) *1000) ) > file
          }
        } else {
          pktSz[key] += pkt_size
          rxDataPkts[key]++
          if (pkt_type == "cbr"){
            file = file "-udp-" key "-th.dat"
            printf("%g\t%g\n",event_time,pktSz[key]*8/( (event_time-startTime[key]) *1000) ) > file
          }
        }
        duplicate[seqKey] = 1
      } else {
        dupPkts[key]++
      }
    }
  }
  
  endTime[key] = event_time
  
  prev_event[seqKey] = event
}

END {
  for (key in startTime){
    rThroughput = pktSz[key]*8 / (endTime[key] - startTime[key]);
    rPacketDeliveryRatio = rxPkts[key] / sentPkts[key] * 100 ;
    rPacketDropRatio = (sentPkts[key] - rxPkts[key]) / sentPkts[key] * 100;
  
    if ( rxPkts[key] != 0 ) {
      rAverageDelay = pktTxDuration[key] / rxPkts[key] ;
    }
    
    print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    
    printf("Src_addr->Dst_addr \t= %15s \n",  srcAddr[key] " -> " destAddr[key])
    printf("Pkt Type \t \t= %15s\n",pktType[key]);
    printf("Pkt Size \t \t= %15d\n",pktSz[key]/rxDataPkts[key]);
    printf("Transfer Start Time \t= %15.2f sec \n", startTime[key])
    printf("Transfer End Time \t= %15.2f sec \n", endTime[key])
    printf("# Sent Packets \t \t= %15.0f\n",sentPkts[key]);
    printf("# Dropped Pkts : \n");
    printf("->Due to Congestion \t= %15.0f\n", dropPkts[key]);
    printf("->Due to Link Errors \t= %15.0f\n", dropPkts_err[key]);
    printf("->Due to Broadcasts \t= %15.0f\n", discard_broadcast[key]);
    printf("# Retransmitted Packets = %15.0f\n", retrans[key]);
    printf("# Duplicate Packets \t= %15.0f\n", dupPkts[key]);
    printf("# Delivered Packets \t= %15.0f\n",rxPkts[key]);
    printf("Packet Delivery Ratio \t= %15.2f percent \n",rPacketDeliveryRatio);
    printf("Packet Drop Ratio \t= %15.2f percent \n",rPacketDropRatio);
    
    printf("Average Delay \t \t= %15.4f secs\n",rAverageDelay);
    printf("Throughput \t \t= %15.2f bps\n",rThroughput);

    #printf("Data transfer duration \t= %15.2f secs \n",duration);
  }
}
