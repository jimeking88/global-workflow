#! /usr/bin/env bash

source "${HOMEgfs}/ush/preamble.sh"

###############################################################
# Source FV3GFS workflow modules
source "${HOMEgfs}/ush/load_fv3gfs_modules.sh"
status=$?
(( status != 0 )) && exit "${status}"

export job="vrfy"
export jobid="${job}.$$"

# TODO (#235) - This job is calling multiple j-jobs and doing too much in general
#   Also, this forces us to call the config files here instead of the j-job
source "${HOMEgfs}/ush/jjob_header.sh" -e "vrfy" -c "base vrfy"

###############################################################
export COMPONENT="atmos"
export CDATEm1=$(${NDATE} -24 ${CDATE})
export PDYm1=$(echo ${CDATEm1} | cut -c1-8)

CDATEm1c=$(${NDATE} -06 ${CDATE})
PDYm1c=$(echo ${CDATEm1c} | cut -c1-8)
pcyc=$(echo ${CDATEm1c} | cut -c9-10)

export COMIN="${ROTDIR}/${CDUMP}.${PDY}/${cyc}/${COMPONENT}"


###############################################################
echo
echo "=============== START TO GENERATE QUARTER DEGREE GRIB1 FILES ==============="
if [ ${MKPGB4PRCP} = "YES" -a ${CDUMP} = "gfs" ]; then
    if [ ! -d ${ARCDIR} ]; then mkdir ${ARCDIR} ; fi
    nthreads_env=${OMP_NUM_THREADS:-1} # get threads set in env
    export OMP_NUM_THREADS=1
    cd ${COMIN}
    fhmax=${vhr_rain:-${FHMAX_GFS}}
    fhr=0
    while [ ${fhr} -le ${fhmax} ]; do
       fhr2=$(printf %02i ${fhr})
       fhr3=$(printf %03i ${fhr})
       fname=${CDUMP}.t${cyc}z.sfluxgrbf${fhr3}.grib2
       fileout=${ARCDIR}/pgbq${fhr2}.${CDUMP}.${CDATE}.grib2
       ${WGRIB2} ${fname} -match "(:PRATE:surface:)|(:TMP:2 m above ground:)" -grib ${fileout}
       (( fhr = ${fhr} + 6 ))
    done
    export OMP_NUM_THREADS=${nthreads_env} # revert to threads set in env
fi


###############################################################
echo
echo "=============== START TO RUN MOS ==============="
if [ ${RUNMOS} = "YES" -a ${CDUMP} = "gfs" ]; then
    ${RUNGFSMOSSH} ${PDY}${cyc}
fi


###############################################################
echo
echo "=============== START TO RUN FIT2OBS VERIFICATION ==============="
if [ ${VRFYFITS} = "YES" -a ${CDUMP} = ${CDFNL} -a ${CDATE} != ${SDATE} ]; then

    export CDUMPFCST=${VDUMP}
    export TMPDIR="${RUNDIR}/${CDATE}/${CDUMP}"
    [[ ! -d ${TMPDIR} ]] && mkdir -p ${TMPDIR}

    xdate=$(${NDATE} -${VBACKUP_FITS} ${CDATE})

    export RUN_ENVIR_SAVE=${RUN_ENVIR}
    export RUN_ENVIR="netcdf"

    ${PREPQFITSH} ${PSLOT} ${xdate} ${ROTDIR} ${ARCDIR} ${TMPDIR}

    export RUN_ENVIR=${RUN_ENVIR_SAVE}

fi


###############################################################
echo
echo "=============== START TO RUN RADMON DATA EXTRACTION ==============="
if [ ${VRFYRAD} = "YES" -a "${CDUMP}" = "${CDFNL}" -a "${CDATE}" != "${SDATE}" ]; then

    export EXP=${PSLOT}
    export COMOUT="${ROTDIR}/${CDUMP}.${PDY}/${cyc}/${COMPONENT}"
    export TANKverf_rad="${TANKverf}/stats/${PSLOT}/${CDUMP}.${PDY}/${cyc}"
    export TANKverf_radM1="${TANKverf}/stats/${PSLOT}/${CDUMP}.${PDYm1c}/${pcyc}"
    export MY_MACHINE=${machine}

    ${VRFYRADSH}

fi


###############################################################
echo
echo "=============== START TO RUN OZMON DATA EXTRACTION ==============="
if [ "${VRFYOZN}" = "YES" -a "${CDUMP}" = "${CDFNL}" -a "${CDATE}" != "${SDATE}" ]; then

    export EXP=${PSLOT}
    export COMOUT="${ROTDIR}/${CDUMP}.${PDY}/${cyc}/${COMPONENT}"
    export TANKverf_ozn="${TANKverf_ozn}/stats/${PSLOT}/${CDUMP}.${PDY}/${cyc}"
    export TANKverf_oznM1="${TANKverf_ozn}/stats/${PSLOT}/${CDUMP}.${PDYm1c}/${pcyc}"
    export MY_MACHINE=${machine}

    ${VRFYOZNSH}

fi


###############################################################
echo
echo "=============== START TO RUN MINMON ==============="
if [ "${VRFYMINMON}" = "YES" -a "${CDATE}" != "${SDATE}" ]; then

    export COMOUT="${ROTDIR}/${CDUMP}.${PDY}/${cyc}/${COMPONENT}"
    export M_TANKverfM0="${M_TANKverf}/stats/${PSLOT}/${CDUMP}.${PDY}/${cyc}"
    export M_TANKverfM1="${M_TANKverf}/stats/${PSLOT}/${CDUMP}.${PDYm1c}/${pcyc}"
    export MY_MACHINE=${machine}

    ${VRFYMINSH}

fi


################################################################################
echo
echo "=============== START TO RUN CYCLONE TRACK VERIFICATION ==============="
if [ ${VRFYTRAK} = "YES" ]; then

    export COMINsyn=${COMINsyn:-$(compath.py ${envir}/com/gfs/${gfs_ver})/syndat}

    ${TRACKERSH}
fi


################################################################################
echo
echo "=============== START TO RUN CYCLONE GENESIS VERIFICATION ==============="
if [ ${VRFYGENESIS} = "YES" -a "${CDUMP}" = "gfs" ]; then
    ${GENESISSH}
fi


################################################################################
echo
echo "=============== START TO RUN CYCLONE GENESIS VERIFICATION (FSU) ==============="
if [ ${VRFYFSU} = "YES" -a "${CDUMP}" = "gfs" ]; then
    ${GENESISFSU}
fi


###############################################################
# Force Exit out cleanly
cd ${DATAROOT}
if [ ${KEEPDATA:-"NO"} = "NO" ] ; then rm -rf ${DATA} ; fi


exit 0
