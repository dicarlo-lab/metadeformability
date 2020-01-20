# MetaDeformability

This repository contains datasets and all analysis scripts necessary to generate the results presented in the paper published in _XXXXX_ by Urbanska, Muñoz _et al._:

[A comparison of microfluidic methods for high-throughput cell deformability measurements](https://doi.org/)


### Abstract 
The mechanical phenotype of a cell is an inherent biophysical marker of its state and function, with potential value in clinical diagnostics.
Several microfluidic-based methods developed in recent years have enabled single-cell mechanophenotyping at throughputs comparable to flow cytometery.
Here we present a highly standardized cross-laboratory study comparing three leading microfluidic-based approaches to measure cell mechanical phenotype: constriction-based deformability cytometry (cDC), shear flow deformability cytometry (sDC), and extensional flow deformability cytometry (xDC).
We show that all three methods detect cell deformability changes induced by exposure to altered osmolarity.
However, a dose-dependent deformability increase upon latrunculin B-induced actin disassembly was detected only with cDC and sDC, which suggests that when exposing cells to the higher strain rate imposed by xDC, other cell components dominate the response.
The direct comparison presented here serves to unify deformability cytometry methods and provides context for the interpretation of deformability measurements performed using different platforms. 

### Key words 
cell mechanics,
deformability cytometry,
real-time deformability cytometry,
suspended microchannel resonator,
microfluidics,
osmotic pressure,
actin cytoskeleton

## Directory Structure

```
├───Code                Code needed for complete analysis
│   ├───LatB                    Matlab scripts/R notebooks for LatB data analysis
│   ├───Osm                     Matlab scripits/R notebooks for osmolarity data analysis
│   ├───Strain                  Matlab scripts to estimate strain per method
│   └───Utils                   3rd party Matlab functions
│
├───renv                Files associated with recreating R virtual environment
│
├───Data_Raw            Original measurements to be analyzed
│   ├───LatB                    LatB-treated cell measurement data
│   ├───Osm                     Osmolarity-treated cell measurement data
│   ├───Strain                  Control cell measurement data for strain calculation
│   ├───LatB_FlowRate           LatB-treated cell measurement data with different flow rates
│   ├───LatB_HighDose           High LatB-treated cell measurement data
│   └───Osm_Time_Response       Time response to osmolairty treatement of cells
│
├───Data_Processed      Processed data for figures or statistical analysis
│   ├───LatB                    LatB-treated cell measurement with Relative Deformability
│   ├───Osm                     Osmolarity-treated cell measurement with Relative Deformability
│   └───Strain                  Calculated strain values
│
├───Figures             Automatically generated figures for publication
│
└───Results             Statistical results
    ├───LatB_ANOVA              LatB-treated ANOVA comparison results
    ├───LatB_Regression         LatB-treated curve fitting results
    ├───Osm_ANOVA               Osmolarity-treated ANOVA comparison results
    └───Osm_Regression          Osmolarity-treated curve fitting results
```

## Analysis

Both `Matlab` scripts and `R` notebooks are used to generate results.

The original data is contained within `Data_Raw` folder.
All analysis scripts are contained within `Code` folder.

Downloading complete repository provides user with all final and intermediate results of the analysis, which allows for running scripts in arbitrary order.

Without the intermediate results, the scripts are in big part independent of one another. 
However, please note the following dependencies:
> to run any of the `R` scripts, summary of the raw data has to be generated first using:

```
Osm_Generate_Summary_CSV.m          for osmolarity analysis
LatB_Generate_Summary_CSV.m         for LatB analysis
```

> to plot response functions in `Matlab`, fitting using `R` has to be performed first:
```
Osm_Response_Curves.m   requires results from   Osm_Dose_Curves.Rmd
Osm_SI_GOF_Plots.m      requires results from   Osm_Dose_Curves.Rmd
LatB_Response_Curve.m   requires results from   LatB_Dose_Curves.Rmd
```

### Matlab Scripts

`Matlab` scripts (`.m`) should be executed in the directory where they exist, as the scripts are built on relative paths. Each script starts with a line that changes the current working directory to the directory 
of the script evaluated to ensure correct definition of data and destination directories.

`Matlab` code was evaluated with `R2016B` and `R2019B`.

### R Scripts

`R`  notebooks (`.Rmd`) should be executed in the directory where they exist, as the scripts are built on relative paths.

`R` code was evaluated with `3.6.1`

#### Setting up `R` analysis

Opening this folder in `RStudio` will load the project details saved in `MetaDeformability.Rproj`.

This project uses `renv` to document and create the environment in which the analysis is performed. Opening the project will install the package `renv` if not already installed. Recorded package versions are stored in [renv.lock](./renv.lock).

To install the recorded packages and versions run in `R`:

```
renv::restore()
```
This will not affect the other packages you have installed on your computer.

&nbsp;  
&nbsp;  
Last updated: January 20, 2020
