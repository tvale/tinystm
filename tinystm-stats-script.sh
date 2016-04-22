counter=1
echo -n "Run until how many threads? "
read limit
echo -n "Run how many tests? "
read ntests
> tinystm-stats.txt
while [ $counter -le $limit ]; do
  echo == THREADS: $counter ==
  countertests=0
  txpersecondsum=0
  aborstpersecondsum=0
  while [ $countertests -lt $ntests ]; do
    ./test/intset/intset-ll -n $counter > tempstats.txt
    txsfull=$(grep "#tx" tempstats.txt)
    txsarray=($txsfull)
    txsnumber=(${txsarray[3]})
    IFS='(' read -ra STRING <<< $txsnumber
    number=${STRING[1]}
    IFS='.' read -ra STRINGFINAL <<< $number
    txpersecond=${STRINGFINAL[0]}
    echo txpersecond: $txpersecond

    abortsfull=$(grep "#aborts" tempstats.txt)
    IFS='#' read -ra STRINGABORTS <<< $abortsfull
    arraylength=${#STRINGABORTS[@]}
    position=$((arraylength-3))
    abortsfullchunk=${STRINGABORTS[$position]}
    IFS='(' read -ra FIRSTSTRINGABORTS <<< $abortsfullchunk
    number=${FIRSTSTRINGABORTS[1]}
    IFS='.' read -ra SECONDSTRINGABORTS <<< $number
    abortspersecond=${SECONDSTRINGABORTS[0]}
    echo abortspersecond: $abortspersecond
    
    txpersecondsum=$(($txpersecondsum+$txpersecond))
    abortspersecondsum=$(($abortspersecondsum+$abortspersecond))
    
    countertests=$((countertests+1))
  done
    
  txpersecondaverage=$(($txpersecondsum / $ntests))
  abortspersecondaverage=$(($abortspersecondsum / $ntests))
  
  echo $counter $txpersecondaverage $abortspersecondaverage >> tinystm-stats.txt
  counter=$((counter+1))
done
echo "Script done"
