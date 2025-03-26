# First, clone github.com/micahpf/reprex-vwb-cr-renv-cache into ~/repos
# and open the R Studio Project

## Set up controlled resource bucket and mount it
# Create controlled resource
system("wb resource resolve --name renv-cache || wb resource create gcs-bucket --name=renv-cache --cloning=COPY_NOTHING --description='Bucket for caching R package binaries using renv'")
# Mount new resources
system("wb resource mount")

## Set cache path to controlled resource bucket
install.packages("here")
cat('RENV_PATHS_CACHE="~/workspace/renv-cache/"', file=here::here(".Renviron"), sep="\n")

## Uninstalled limma package will be detected by renv and automatically installed
try(limma::voom())

## Install and initialize renv
# Install renv
install.packages("renv")
# Init renv with access to bioconductor repos (this will restart RStudio)
renv::init(bioconductor = TRUE)
# Check path of renv cache is pointing to ~/workspace/renv-cache/
renv::paths$cache()
# Check for inconsistencies between lockfile and dependencies
renv::status()

## Deactivate renv and re-initialize using the new cache (this will restart RStudio)
renv::deactivate(clean=TRUE)
renv::init(bioconductor = TRUE)
renv::paths$cache()
renv::status()

## Questions
# 1) Can I create a renv cache in the controlled resource bucket? (i.e. does the above code work?)
# 2) In a new R app within the same workspace, can I use `renv::restore()` to reinstall required packages from the CR bucket cache?
# 3) In a new workspace, can I use this same CR bucket as a reference resource and `renv::restore()` the project libraries in a new R app?
# 4) After Step 3, can I update the cache with new contents via the reference resource?
