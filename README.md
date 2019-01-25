**Suprise Loss of Multivarite Time Series (SL-MTS)**

SL-MTS is a script implemented in R for studying the transitions in multivariate time series data (MTS). The script uses 
State Space Model (SSM) to model the dynamics of MTS and determine points in the time series where the error in the
forecast of SSM model (i.e. out-sample error) is worse than the its in-sample performance, where the performance is measured
for a fixed loss function in a rolling window manner. The error is called Surprise Loss (SL). Relatievley High SLs can be an indicator of transition in the system. 
The script is implemented on Intensive Vare Unit (ICU) tiem series data for studying the transition to Septic shock in ICU setting.


**How do I use SL-MTS?**

The Multivariate Time series data must be in form of datframe, where rows or equally spaced time points and columns are variables. 
The script can calculate SL for multiple timesereis dataset in parallel. For the purpose, the data must be feeded to the model in a list format, where each component of the list is a dataframe. In each dataframe rows are equally spaced time points and columns are variables.

| Arguments        |           |
| ------------- |:-------------:| 
| `mts_data`    | Multivariate Time Series Data [List format]| 
| `num_trends`    | Number of hidden trends in SSM   |  
| `rolling_window_size`        | Length of rolling window [hours]|
|`bin_size`        |  Length of intervals between time points [minutes]|
|`num_cores`        |  Number of cores for parallel camputing|


**Examples**
```source("SLMTS.R")
result = computeSL(
              mts_data = ICU_data, 
              num_trends = 3,
              rolling_window_size = 18,
              bin_size = 30,
              num_cores = 10
              )
```

**OS Compatibility**

SL-MTS has been tested in the MacOS.

**Dependencies**

The following softwares need to be pre-installed before before running this program:

1. 
  * [R 3.5 ](https://cran.r-project.org/bin/windows/base/)
2. R packages:
  * [MARSS](https://cran.r-project.org/web/packages/MARSS/)
  * [parallel](https://www.rdocumentation.org/packages/parallel/versions/3.5.1)
  * [pracma](https://cran.r-project.org/web/packages/pracma/)

**License**

SL-MTS is an open source software and is licensed under LGPL.

**Getting help**

For queries regarding the software write to: samal@combine.rwth-aachen.de , farhadi@combine.rwth-aachen

**Citing TROSS**
