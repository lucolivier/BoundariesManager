#!/bin/bash

user='gladal'
pw='Qsbx2n9w0v3Q'
db='gladal'
baseFld='/home/websites/gladal/www/scrappers/boundariesReductor/'
tmp="${baseFld}tmp/"
polyReductor="${baseFld}BM_PolygonsReductor.rb"
mkdir -p tmp


function requestdb {
    #$1 mysql request
    #$2 path to res
    echo $1 > "$2_rq"
    mysql -u $user --password=$pw --database=$db -N -B --silent -vvv 1>"$2_tmp" 2>"$2_err" < "$2_rq"
    cat "$2_tmp" | sed -e '/^|/!d' -e 's/^| //' -e 's/ |$//' | tr '|' '\t' >$2
}

requestdb "SELECT \`insee\` FROM \`boundary\` WHERE 1" ${tmp}listing

date
cpt=0
for line in $(cat ${tmp}listing)
do
    let cpt=$cpt+1
    echo $cpt: $line
    rm -f ${tmp}record
    requestdb "SELECT \`points\` FROM \`boundary\` WHERE \`insee\` = '"$line"'" ${tmp}record #${tmp}record_tmp
#     cat ${tmp}record_tmp | sed     -e 's/^a:[0-9]*://' \
#                                         -e 's/s:4:"type";s:4:/"type":/g' \
#                                         -e 's/;s:2:"id";i:/,"id":/g' \
#                                         -e 's/;s:3:"lat";d:/,"lat":/g' \
#                                         -e 's/;s:3:"lon";d:/,"lon":/g' \
#                                         -e 's/;s:4:"tags";a:1:/,"tags":/g' \
#                                         -e 's/s:6:"source";s:90:/"source":/g' \
#                                         -e 's/{i:[0-9]*;a:5://g' \
#                                         -e 's/}i:[0-9]*;a:5:/,/g' >${tmp}record
    $polyReductor ${tmp}record
    requestdb "UPDATE \`boundary\` SET pointsReduced='"$(cat ${tmp}record.reduced)"' WHERE \`insee\`='"$line"'" ${tmp}update
    
#     if [ $cpt -gt 5 ]; then
#         exit
#     fi
done

date