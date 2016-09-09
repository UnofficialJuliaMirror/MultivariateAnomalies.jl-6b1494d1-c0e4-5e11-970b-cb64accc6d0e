# cd(joinpath(Pkg.dir("MultivariateAnomalies"), "docs"))

using Documenter, MultivariateAnomalies

makedocs(modules = [MultivariateAnomalies],
         #format   = Documenter.Formats.HTML,
             pages    = Any[
           "Home" =>  "index.md",
           "Manual" => Any[
               "man/FeatureExtraction.md"
             , "man/DetectionAlgorithms.md"
             , "man/DetectionAlgorithms.md"
             , "man/DistDensity.md"
             , "man/Scores.md"
             ]
           ]
         )


deploydocs(
  deps   = Deps.pip("mkdocs", "python-markdown-math"),
  repo = "github.com/milanflach/MultivariateAnomalies.jl.git",
  julia = "release",
  osname = "osx"
)
