#!/bin/bash

#listingFile="/home/websites/civatislab/www/boundsGrabber/Listing.csv"
listingFile="/Users/lucol/Documents/DEV/AreaManagement/BoundariesManager/Listing.csv"

cat "$listingFile" | sed -e 's/"//g' -e 's/ /_/g' -e 's/,/ /g' | sed '/_Code_INSEE_/d' \
| awk '{
if ($4<10000)
    print 0$4
else
    print $4
}'
