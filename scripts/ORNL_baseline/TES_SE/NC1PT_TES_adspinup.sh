#!/bin/bash

set -e

# Create a test kmELMcase with dataset created by kiloCraft for DATM with I1850CNPRDCTCBC compset

KILOCRAFT_ROOT="/gpfs/wolf2/cades/cli185/proj-shared/wangd/kiloCraft/"
KMELM_ROOT="/gpfs/wolf2/cades/cli185/proj-shared/wangd/kmELM/"
KILOCRAFT_DATA_ROOT="${KILOCRAFT_ROOT}/TES_cases_data/Daymet_ERA5_TESSFA2/"
KMELM_CASE_ROOT="${KMELM_ROOT}/e3sm_cases/"
KMELM_RUN_ROOT="${KMELM_ROOT}/e3sm_runs/"

# Define the root directories for the E3SM data and source code
E3SM_SRC_ROOT="${KMELM_ROOT}/E3SM/"
E3SM_DIN="//gpfs/wolf2/cades/cli185/world-shared/e3sm"
echo "E3SM_SRCROOT: $E3SM_SRCROOT"
echo "E3SM_DIN: $E3SM_DIN"


# Define the root directory for the kmELM case data
DATA_ROOT="$KILO_DATA_ROOT/TES_cases_data/Daymet_ERA5_TESSFA2/"

# Define the root directory for the kmELM case experiments
#EXP_CASE_ROOT="/gpfs/wolf2/cades/cli185/proj-shared/wangd/kmELM/e3sm_cases/"
# Define the root directory for the kmELM case experiments
#EXP_RUN_ROOT="/gpfs/wolf2/cades/cli185/proj-shared/wangd/kmELM/e3sm_runs/"

# Define the experiment ID
EXPID="NC1PT"
# Define the experiment data group (Domain and forcing data specific group)
EXP_DATA_GROUP="TES_SE"
# Define the case directory
CASEDIR="$KMELM_CASE_ROOT/${EXP_DATA_GROUP}/uELM_${EXPID}_IBC1850CNPRDCTCBC"
# Define the case data directory
CASE_DATA="${KILOCRAFT_DATA_ROOT}/${EXP_DATA_GROUP}/${EXPID}"
# Define the domain file
DOMAIN_FILE="${EXPID}_domain.lnd.${EXP_DATA_GROUP}.4km.1d.c251003.nc"
# Define the surface data file
SURFDATA_FILE="${EXPID}_surfdata.${EXP_DATA_GROUP}.4km.1d.NLCD.c251003.nc"

\rm -rf "${CASEDIR}"

#${E3SM_SRCROOT}/cime/scripts/create_newcase --case "${CASEDIR}" --mach summitPlus --compiler pgi --mpilib spectrum-mpi --compset I1850uELMCNPRDCTCBC --res ELM_USRDAT --pecount "${PECOUNT}" --handle-preexisting-dirs r --srcroot "${E3SM_SRCROOT}"

${E3SM_SRCROOT}/cime/scripts/create_newcase --case "${CASEDIR}" --mach cades-baseline --compiler gnu --mpilib openmpi --compset IBC1850CNPRDCTCBC --res ELM_USRDAT  --handle-preexisting-dirs r --srcroot "${E3SM_SRCROOT}"

cd "${CASEDIR}"

# Define the case configuration

./xmlchange PIO_TYPENAME="pnetcdf"
./xmlchange PIO_NETCDF_FORMAT="64bit_data"

./xmlchange DIN_LOC_ROOT="${E3SM_DIN}"
./xmlchange DIN_LOC_ROOT_CLMFORC="${CASE_DATA}"

./xmlchange CIME_OUTPUT_ROOT="$KMELM_RUN_ROOT"

# Define the data mode, particial cleaunp unless there are calibration-related fields
# The forcing data is stored in $CASE_DATA/atm_forcing.datm7.km.1d/
# The domain and surface data file are stored in $CASE_DATA/domain_surfdata/

./xmlchange DATM_MODE="uELM_TES"

./xmlchange ATM_DOMAIN_PATH="${CASE_DATA}/domain_surfdata/"
./xmlchange ATM_DOMAIN_FILE="${DOMAIN_FILE}"

./xmlchange LND_DOMAIN_PATH="${CASE_DATA}/domain_surfdata/"
./xmlchange LND_DOMAIN_FILE="${DOMAIN_FILE}"


# Define the Scientific Experiment Configuration
./xmlchange STOP_N="400"
./xmlchange REST_N="20"
./xmlchange STOP_OPTION="nyears"

./xmlchange ATM_NCPL="24"
./xmlchange DATM_CLMNCEP_YR_START="1980"
./xmlchange DATM_CLMNCEP_YR_END="1999"
./xmlchange DATM_CLMNCEP_YR_ALIGN="1990"

./xmlchange ELM_FORCE_COLDSTART="on"

./xmlchange CONTINUE_RUN="FALSE"
./xmlchange ELM_ACCELERATED_SPINUP="on"
./xmlchange  --append ELM_BLDNML_OPTS="-bgc_spinup on"

echo "fsurdat = '${CASE_DATA}/domain_surfdata/${SURFDATA_FILE}'
      spinup_state = 1
      suplphos = 'ALL'
      hist_nhtfrq=-175200
      hist_mfilt=1
      nyears_ad_carbon_only = 25
      spinup_mortality_factor = 10
     " >> user_nl_elm

# Computational resources settings
./xmlchange NTASKS="1"
./xmlchange NTASKS_PER_INST="1"
./xmlchange MAX_MPITASKS_PER_NODE="1"
./xmlchange JOB_WALLCLOCK_TIME="2:00:00"

./case.setup --reset

./case.setup

./case.build --clean-all

./case.build

#./case.submit

