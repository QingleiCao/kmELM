#!/bin/bash

set -e

E3SM_DIN=$1
DATA_ROOT=$2
EXPID=$3
E3SM_SRCROOT=$(git rev-parse --show-toplevel)
echo "E3SM_SRCROOT: $E3SM_SRCROOT"
echo "E3SM_DIN: $E3SM_DIN"

CASEDIR="$E3SM_SRCROOT/e3sm_cases/uELM_${EXPID}_I1850uELMCNPRDCTCBC"
CASE_DATA="${DATA_ROOT}/${EXPID}"
DOMAIN_FILE="${EXPID}_domain.lnd.Daymet_NA.1km.1d.c240524.nc"
SURFDATA_FILE="${EXPID}_surfdata.Daymet_NA.1km.1d.c240524.nc"

\rm -rf "${CASEDIR}"

${E3SM_SRCROOT}/cime/scripts/create_newcase --case "${CASEDIR}" --mach $4 --compiler $5 --compset I1850uELMCNPRDCTCBC --res ELM_USRDAT  --handle-preexisting-dirs r --srcroot "${E3SM_SRCROOT}"

cd "${CASEDIR}"

./xmlchange PIO_TYPENAME="pnetcdf"

./xmlchange PIO_NETCDF_FORMAT="64bit_data"

./xmlchange DIN_LOC_ROOT="${E3SM_DIN}"

./xmlchange DIN_LOC_ROOT_CLMFORC="${CASE_DATA}"

./xmlchange CIME_OUTPUT_ROOT="${E3SM_SRCROOT}/e3sm_runs/"

./xmlchange ELM_FORCE_COLDSTART="on"
#./xmlchange PROJECT="m4814"
#./xmlchange CHARGE_ACCOUNT="m4814"

./xmlchange DATM_MODE="uELM_NA"

./xmlchange DATM_CLMNCEP_YR_START=2014

./xmlchange DATM_CLMNCEP_YR_END=2014

./xmlchange ATM_NCPL=24

./xmlchange STOP_N=5

./xmlchange STOP_OPTION=ndays

#./xmlchange MAX_TASKS_PER_NODE=$6

#./xmlchange MAX_MPITASKS_PER_NODE=$6

./xmlchange NTASKS=$6

./xmlchange NTASKS_LND=$7

./xmlchange NTASKS_PER_INST=1

./xmlchange ATM_DOMAIN_PATH="${CASE_DATA}/domain_surfdata/"

./xmlchange ATM_DOMAIN_FILE="${DOMAIN_FILE}"

./xmlchange LND_DOMAIN_PATH="${CASE_DATA}/domain_surfdata/"

./xmlchange LND_DOMAIN_FILE="${DOMAIN_FILE}"

./xmlchange JOB_WALLCLOCK_TIME="0:30:00"

./xmlchange USER_REQUESTED_WALLTIME="0:30:00"

echo "fsurdat = '${CASE_DATA}/domain_surfdata/${SURFDATA_FILE}'
      hist_nhtfrq=-120
      hist_mfilt=1
     " >> user_nl_elm

./case.setup --reset

./case.setup

./case.build --clean-all

./case.build

./case.submit

