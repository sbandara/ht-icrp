#!/bin/bash

# experiment folder
exp=20140528_HeLa_IC_Bcl_TRAIL_Bortez
# subdirectory in which the image files are located
crpth=Images

# the place on orchestra to where you export your experiment folder
base=~/hms/scratch1/svb6/$exp

for site in `seq 1 4`
do
  for row in `seq 3 6` 
  do
    for col in `seq 4 9`
    do
      bsub -n 4 -W 5:57 -q short -o log/$exp-$row-$col-$site.out -e log/$exp-$row-$col-$site.err matlab -nosplash -nodesktop -r "addpath('~/icrp/'); icrprun('$base','$crpth','$row','$col','$site')"
    done
  done
done

exit 0
