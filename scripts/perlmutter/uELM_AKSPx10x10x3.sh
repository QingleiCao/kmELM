#!/bin/bash

set -e

# Create a test case uELM_MOF21_I1850uELMCNPRDCTCBC

E3SM_DIN="/global/cfs/cdirs/e3sm/inputdata"
DATA_ROOT="/global/cfs/cdirs/m4814/wangd/kiloCraft/NA_cases_data"
KMELM_SRCROOT=$(git rev-parse --show-toplevel)
E3SM_SRCROOT=$KMELM_SRCROOT/E3SM
echo "E3SM_SRCROOT: $E3SM_SRCROOT"
echo "E3SM_DIN: $E3SM_DIN"

EXPID="AKSPx10x10x3"
WRITE_OP="FALSE" #  "TRUE/FALSE"

CASEDIR="$KMELM_SRCROOT/e3sm_cases/uELM_${EXPID}_I1850uELMCNPRDCTCBC"
CASE_DATA="${DATA_ROOT}/${EXPID}"
DOMAIN_FILE="${EXPID}_domain.lnd.Daymet_NA.1km.1d.c240524.nc"
SURFDATA_FILE="${EXPID}_surfdata.Daymet_NA.1km.1d.c240524.nc"

\rm -rf "${CASEDIR}"

${E3SM_SRCROOT}/cime/scripts/create_newcase --case "${CASEDIR}" --mach pm-cpu --compiler gnu --compset I1850uELMCNPRDCTCBC --res ELM_USRDAT  --handle-preexisting-dirs r --srcroot "${E3SM_SRCROOT}"

cd "${CASEDIR}"

./xmlchange PIO_TYPENAME="pnetcdf"

./xmlchange PIO_NETCDF_FORMAT="64bit_data"

./xmlchange DIN_LOC_ROOT="${E3SM_DIN}"

./xmlchange DIN_LOC_ROOT_CLMFORC="${CASE_DATA}"

./xmlchange CIME_OUTPUT_ROOT="${KMELM_SRCROOT}/e3sm_runs/"

./xmlchange ELM_FORCE_COLDSTART="on"
./xmlchange PROJECT="m4814"

./xmlchange DATM_MODE="uELM_NA"

./xmlchange DATM_CLMNCEP_YR_START=2014

./xmlchange DATM_CLMNCEP_YR_END=2014

./xmlchange ATM_NCPL=24

./xmlchange MAX_TASKS_PER_NODE=128
./xmlchange MAX_MPITASKS_PER_NODE=128

./xmlchange NTASKS=1
./xmlchange NTASKS_LND=38400
./xmlchange NTASKS_CPL=38400
./xmlchange NTASKS_ATM=3000

./xmlchange NTASKS_PER_INST=1

./xmlchange ATM_DOMAIN_PATH="${CASE_DATA}/domain_surfdata/"

./xmlchange ATM_DOMAIN_FILE="${DOMAIN_FILE}"

./xmlchange LND_DOMAIN_PATH="${CASE_DATA}/domain_surfdata/"

./xmlchange LND_DOMAIN_FILE="${DOMAIN_FILE}"

./xmlchange JOB_WALLCLOCK_TIME="1:00:00"
./xmlchange USER_REQUESTED_WALLTIME="1:00:00"

./xmlchange SAVE_TIMING="TRUE"
./xmlchange SAVE_TIMING_DIR="/global/cfs/cdirs/m4814/wangd"
./xmlchange SAVE_TIMING_DIR_PROJECTS="m4814"

if [ "$WRITE_OP" = "TRUE" ]; then
	echo "fsurdat = '${CASE_DATA}/domain_surfdata/${SURFDATA_FILE}'
      	hist_nhtfrq=-120
     	 hist_mfilt=1
     	" >> user_nl_elm
	./xmlchange STOP_N=5
        ./xmlchange STOP_OPTION=ndays
else
	echo "fsurdat = '${CASE_DATA}/domain_surfdata/${SURFDATA_FILE}'
    	hist_empty_htapes =.true.
    	" >> user_nl_elm
	./xmlchange STOP_N=5
	./xmlchange STOP_OPTION=ndays
	./xmlchange REST_N=10
fi

./case.setup --reset

./case.setup

./case.build --clean-all

./case.build

./case.submit

