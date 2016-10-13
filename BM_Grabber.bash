#!/bin/bash
#*****************************************************************************************
#
#
#  BoundsGrabber: Commande Line
#  © Asity 2013
#
#  version: ß1.00.03
#
#*****************************************************************************************

function usage {
    echo "usage: $(basename $0)"
    echo "       -p|--requestprm=path       path to request prm file"
    echo "       [-d|--demonize]"
    echo "       [-r|--repos=path]          folder will be created if not exits"
    echo "                                  based path folder must exist"
    echo "       [-z|--eraserepos]"
    echo
    exit 0
}

function log {
    #$1 str
    ts=$(date '+%y%m%d-%H%M%S')
    echo "$1"
    [ "$logfile" ] && echo "$ts: $1">>"$logfile"
}

function logusage {
    #$1 str
    log "$1"
    usage
}

function logexit {
    #$1 str #$2 errcode
    log "$1 Exiting!"
    exit $2
}


# Check env.
    if [ $(echo $0 | sed '/^.\//!d') ]; then
        baseFolder="$(dirname "$(pwd)/${0/.\//}")"
    else
        baseFolder="$(dirname "$0")"
    fi
    [ "$(echo $baseFolder | sed '/\/$/d')" ] && baseFolder="${baseFolder}/"
    polyBuilder="${baseFolder}BM_PolygonsBuilder.rb"
    if [ ! -f "$polyBuilder" ]; then
        logexit "BM_PolygonsBuilder.rb not found." 1
    fi
    if [ ! -f "${baseFolder}BM_PolygonsBuilder.rb" ]; then
        logexit "BM_PolygonsBuilder.rb not found." 2
    fi
    if [ ! -f "${baseFolder}BM_Basic.rb" ]; then
        logexit "BM_Basic.rb not found." 3
    fi

# Check Params

    #[ ! $* ] && logusage "Minimal params required."

    for prm in $*; do
        if [ $(echo $prm | sed '/=/!d') ]; then
            prms=($(echo $prm | sed 's/=/ /'))
            cmd=${prms[0]}
            value=${prms[1]}
        else
            cmd=$prm
            value=''
        fi

        case "$cmd" in
            "") logusage "Param required." ;;

            -p|--requestprm)
                [ ! $value ] && logusage "void param for --requestprm."
                [ ! -f "$value" ] && logexit "file not found for --requestprm."
                prmRequestPrm="$value"
            ;;

            -d|demonize)
                prms=$(echo "$*" | sed 's/-d//')
                echo "nohup $0 $prms 0<&- &>/dev/null &">"${baseFolder}deamon.bash"
                chmod 700 "${baseFolder}deamon.bash"
                . "${baseFolder}deamon.bash"
                rm -f "${baseFolder}deamon.bash"
                exit
            ;;

            -r|--repos)
                [ ! $value ] && logusage "void param for --repos."
                [ $(echo $value | sed '/\//d') ] && logexit "--repos: bad path ($value)."
                [ $(echo $value | sed '/^.\//!d') ] && logexit "--repos: path must not be relative."
                [ $(echo $value | sed '/^..\//!d') ] && logexit "--repos: path must not be relative."
                [ ! -d "$(dirname $value)" ] && logexit "--repos: based path folder must exist."
                prmRepos=$value
                [ $(echo $prmRepos | sed '/\/$/d') ] && prmRepos="${prmRepos}/"
            ;;

            -z|--eraserepos) prmEraseRepos=1 ;;

            *) logusage "Unknown param switch $cmd" ;;
        esac

    done

    [ ! "$prmRequestPrm" ] && logusage "--resquestprm param required."

    . "$prmRequestPrm"
    [ ! $typeCode ] && logexit "typeCode param is required in request prm file."
    [ ! $requestOpenStreetMap ] && logexit "requestOpenStreetMap param is required in request prm file."
    [ ! $generateDataFiles ] && logexit "generateDataFiles param is required in request prm file."
    [ ! $generateFullPolygons ] && logexit "generateFullPolygons param is required in request prm file."
    [ ! $generateReducedPolygons ] && logexit "generateReducedPolygons param is required in request prm file."
    [ ! $recordReducedPolygonToDB ] && logexit "recordReducedPolygonToDB param is required in request prm file."


# Setup Env
    if [ ! $prmRepos ]; then
        _prmRepos="${baseFolder}repos/"
    else
        _prmRepos="$prmRepos"
    fi
    if [ "$eraseRepos" == 'YES' ]; then
        prmEraseRepos=1
    fi
    [ "$prmEraseRepos" == "1" ] && rm -rf "$_prmRepos"
    mkdir -p "$_prmRepos"

    #tempFolder="${_prmRepos}tmp/" ; mkdir -p "$tempFolder"
    
    logfile="${_prmRepos}log-$(date '+%y%m%d-%H%M%S')" ; touch "$logfile"


    osmjson="${_prmRepos}osmjson/" ; mkdir -p "$osmjson"
    osmdata="${_prmRepos}osmdata/" ; mkdir -p "$osmdata"
    fpjson="${_prmRepos}fpjson/" ; mkdir -p "$fpjson"
    rpjson="${_prmRepos}rpjson/" ; mkdir -p "$rpjson"
    recdb="${_prmRepos}recdb/" ; mkdir -p "$recdb"


# Main

    if [ "$requestOpenStreetMap" == 'YES' ]; then

        [ ! "$openStreetMapRequestURL" ] && logexit "openStreetMapRequestURL not defined for requestOpenStreetMap in request prm file."
        [ ! "$openStreetMapCodeslistingCmd" ] && logexit "openStreetMapCodeslistingCmd not defined for requestOpenStreetMap in request prm file."

        start=0
        if [ "$continueRequest" == 'YES' ]; then
            start=$(ls "$osmjson" | wc -l)
        fi

        cpt=0;
        for code in $("$openStreetMapCodeslistingCmd"); do
            let cpt=$cpt+1
            [ $cpt -lt $start ] && continue

#if [ $cpt -gt 200 ]; then break; fi

            log "$cpt- $code"

            # requesting osm
            grabfile="${osmjson}${code}"
            url=$(echo $openStreetMapRequestURL | sed "s/<CODE>/${code}/")
            curl -g -s -0 $url >"$grabfile"

       done

    fi

    
    if [ "$generateDataFiles" == 'YES' ]; then

        for file in $(ls "$osmjson"); do
            log "DATA: $file"
            grabfile="${osmjson}$file"
            datafile="${osmdata}$file" ; rm -f "$datafile"
            if [ $(cat "$grabfile" | wc -l) -lt 20 ]; then
                log "no request result for code file: $file"
                continue
            fi
            cat "$grabfile"     | sed 's/^[ ]*//g' \
                                | tr -d '\n' | tr '}' '\n' \
                                | sed 's/: /:/g' | sed '/^,{/!d' \
                                | sed -e 's/^,{//' -e s'/ /_/g' \
                                | sed '/"type":"node","id"/!d' \
                                | sed 's/.*"id":\([0-9]*\).*"lat":\([0-9\.-]*\).*"lon":\([0-9\.-]*\).*/node,\1,\2,\3/' >>"$datafile"
            cat "$grabfile"     | sed 's/^[ ]*//g' \
                                | tr -d '\n' | tr '}' '\n' \
                                | sed 's/: /:/g' | sed '/^,{/!d' \
                                | sed -e 's/^,{//' -e s'/ /_/g' \
                                | sed '/"type":"way","id"/!d' \
                                | sed 's/.*"nodes":\[\([0-9,].*\)\].*/way,\1/' >>"$datafile"

            cat "$grabfile"     | egrep '"admin_level":|"name":' | tail -2 \
                                | sed -e 's/^[ ]*//g' -e 's/: /:/' -e 's/ /_/g' -e 's/.*://' -e 's/"//g' \
                                | tr -d '\n' | sed "s/\(.*\),\(.*\),.*/info,$typeCode,$file,\1,\2/" >>"$datafile"

            [ "$removeRequestResultFiles" == 'YES' ] && rm -f "$grabfile"

        done

    fi

    if [ "$generateFullPolygons" == 'YES' ] || [ "$generateReducedPolygons" == 'YES' ]; then

        for file in $(ls "$osmdata"); do

            datafile="${osmdata}$file"

            if [ "$generateFullPolygons" == 'YES' ] && [ "$generateReducedPolygons" == 'YES' ]; then
                log "FP&RP: $file"
                "$polyBuilder" "$datafile" "${fpjson}${file}" "${rpjson}${file}" 1>>"$logfile" 2>>"$logfile"
            elif [ "$generateFullPolygons" == 'YES' ]; then
                log "FP: $file"
                "$polyBuilder" "$datafile" "${fpjson}${file}" NO 1>>"$logfile" 2>>"$logfile"
            elif [ "$generateReducedPolygons" == 'YES' ]; then
                log "RP: $file"
                "$polyBuilder" "$datafile" NO "${rpjson}${file}" 1>>"$logfile"  2>>"$logfile"
            fi

        done

    fi

    if [ "$recordReducedPolygonToDB" == 'YES' ]; then

        [ ! $DBAddress ] && logexit "DBAddress not defined for recordReducedPolygonToDB in request prm file."
        [ ! $DBName ] && logexit "DBName not defined for recordReducedPolygonToDB in request prm file."
        [ ! $DBUser ] && logexit "DBName not defined for recordReducedPolygonToDB in request prm file."
        [ ! $DBPassword ] && logexit "DBName not defined for recordReducedPolygonToDB in request prm file."

        for file in $(ls "$osmdata"); do
            datafile="${osmdata}$file"
            rpfile="${rpjson}${file}"
            recdbfile="${recdb}${file}"

            data=($(cat "$datafile" | sed '/^info/!d' | sed -e 's/ /_/g' -e 's/,/ /g'))
            if [ "${data[*]}" == '' ]; then
                log "RECORD: $file: ***NO INFO FOR RECORD***"
                continue
            fi

            log "RECORD: $file: ${data[*]}"
            polygon=$(cat "$rpfile" | sed -e 's/^reducedpolygon=//' -e 's/;$//')
			echo "REPLACE \`boundaries\` SET type='"${data[1]}"' , level='"${data[3]}"' , code='"${data[2]}"' , name='"$(echo ${data[4]} | sed -e "s/'/\\\'/g" -e 's/_/ /g')"' , polygon='"$polygon"' " >"${recdbfile}_rq"
			
			rm -f "${recdbfile}_std"
			rm -f "${recdbfile}_err"
            mysql -u $DBUser --password=$DBPassword --database=$DBName --default-character-set=utf8 -N -B --silent -vvv 1>"${recdbfile}_std" 2>"${recdbfile}_err" < "${recdbfile}_rq"

        done

    fi





