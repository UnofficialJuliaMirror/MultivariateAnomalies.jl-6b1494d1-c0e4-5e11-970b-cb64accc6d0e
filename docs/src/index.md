# MultivariateAnomalies.jl 

*A julia package for detecting multivariate anomalies.*

*Keywords: Novelty detection, Anomaly Detection, Outlier Detection, Statistical Process Control*

    Please cite this package as ...

## Requirements

- Julia `0.4`
- `Distances`, `MultivariateStats`
-  latest `LIBSVM` branch via:
`Pkg.clone("https://github.com/milanflach/LIBSVM.jl.git");`
`Pkg.checkout("LIBSVM", "mutating_versions");`
`Pkg.build("LIBSVM")`

## Package Features

- Preprocess your data by extracting its relevant features
[Feature Extraction](man/Preprocessing.md)
```@contents 
Pages = ["man/Preprocessing.md"]
Depth = 1
```
- Compute Distance, Kernel matrices and k-nearest neighbors objects
```@contents 
Pages = ["man/DistancesDensity.md"]
Depth = 1
```
- Detect the anomalies
```@contents 
Pages = ["man/DetectionAlgorithms.md"]
Depth = 1
```
- Postprocess your anomaly scores, by computing their quantiles or ensembles, i.e. combinations of several algorithms
 ```@contents 
Pages = ["man/Postprocessing.md"]
Depth = 1
```

- Compute the area under the curve as external evaluation metric of your scores
```@contents 
Pages = ["man/AUC.md"]
Depth = 1
```

## Using the Package

We provide high-level convenience functions for detecting the anomalies. Namely the pair of 

`P = getParameters(algorithms, training_data)` 
and
`detectAnomalies(testing_data, P)`

sets standard choices of the Parameters `P` and hands the parameters as well as the algorithms choice over to detect the anomalies. 

Currently supported algorithms include Kernel Density Estimation (`algorithms = ["KDE"]`), Recurrences (`"REC"`), k-Nearest Neighbors algorithms (`"KNN-Gamma"`, `"KNN-Delta"`), Hotelling's T2 (`"T2"`), Support Vector Data Description (`"SVDD"`) and Kernel Null Foley Summon Transform (`"KNFST"`). With `getParameters()` it is also possible to compute output scores of multiple algorithms at once (`algorihtms = ["KDE", "T2"]`), quantiles of the output anomaly scores (`quantiles = true`) and ensembles of the selected algorithms (e.g. `ensemble_method = "mean"`). For more details about the detection algorithms and their usage please consider 

```@contents 
Pages = ["man/DetectionAlgorithms.md"]
Depth = 2
```

## Input Data

Within MultivariateAnomalies we assume that observations/samples/time steps are stored along the first dimension of the data array (rows of a matrix) with the number of observations `T = size(data, 1)`. Variables/attributes are stored along the last dimension `N` of the data array (along the columns of a matrix) with the number of variables `VAR = size(data, N)`. We are interested in the question which observation(s) of the data are anomalous.

## Index

```@index
Pages = ["man/Preprocessing.md", "man/DetectionAlgorithms.md", "man/Postprocessing.md", "man/AUC.md", "man/DistancesDensity.md"]
```