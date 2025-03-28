# kmELM (Kilometer-scale E3SM Land Model)
## Overview
The kilometer-scale E3SM Land Model (ELM) is a high-resolution version of the land surface component of the Energy Exascale Earth System Model (E3SM), designed to capture fine-scale terrestrial processes such as hydrology, vegetation dynamics, and carbon-nutrient cycles with unprecedented spatial detail. By resolving sub-grid heterogeneity at the kilometer scale, ELM improves the representation of complex land-atmosphere interactions, such as topographically driven water redistribution, localized land use changes, and ecosystem responses to climate variability. This high-resolution modeling capability enables more accurate simulations of regional and global land surface processes, supporting applications in climate change assessment, extreme event prediction, and resource management.

## Supported Systems and Recommended Environments
### Frontier at ORNL


### Perlmutter at NERSC


### Baseline at ORNL



## Repo Configuration
```

git clone git@github.com:daliwang/kmELM.git
cd kmELM
export kmELM_home=$PWD
git submodule update --init --recursive
```

## Build and Run
