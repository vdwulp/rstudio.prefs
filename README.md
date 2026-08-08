# rstudio.prefs

<!-- badges: start -->
[![Codecov test coverage](https://codecov.io/gh/vdwulp/rstudio.prefs/branch/main/graph/badge.svg)](https://app.codecov.io/gh/vdwulp/rstudio.prefs/tree/main)
[![R-CMD-check](https://github.com/vdwulp/rstudio.prefs/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/vdwulp/rstudio.prefs/actions/workflows/R-CMD-check.yaml)
[![CRAN status](https://www.r-pkg.org/badges/version/rstudio.prefs)](https://CRAN.R-project.org/package=rstudio.prefs)
<!-- badges: end -->

*Manage RStudio Preferences and Addin Shortcuts*

The {rstudio.prefs} package provides a programmatic interface for working with
'RStudio' preference files to modify settings and addin keyboard shortcuts
without using point-and-click option menus. This is useful for teams and
individuals working across multiple devices who want a **unified experience**
and for enforcing **best practices**. The package also exposes settings not available
in the *Global Options* dialog.

## Installation

Install {rstudio.prefs} from CRAN with:

``` r
install.packages("rstudio.prefs")
```

Install the development version of {rstudio.prefs} from [GitHub](https://github.com/vdwulp/rstudio.prefs) with:

``` r
# install.packages('devtools')
devtools::install_github("vdwulp/rstudio.prefs")
```

## Examples

### Set RStudio Preferences

Update the RStudio default preferences.
Full list of modifiable settings here: https://docs.posit.co/ide/server-pro/admin/reference/session_user_settings.html

``` r
library(rstudio.prefs)

use_rstudio_prefs(
  always_save_history = FALSE,
  save_workspace = "never",
  load_workspace = FALSE,
  rainbow_parentheses = TRUE
)
#> √ Downloading list of available RStudio settings
#>
#> == Updates ==================================================
#> - always_save_history   [TRUE   --> FALSE]
#> - save_workspace        [ask    --> never]
#> - load_workspace        [TRUE   --> FALSE]
#> - rainbow_parentheses   [FALSE  --> TRUE ]
#> 
#> Would you like to continue? [y/n] y
#> √ File 'C:/Users/sjobergd/AppData/Roaming/RStudio/rstudio-prefs 2021-06-20.json' saved as backup.
#> √ File 'C:/Users/sjobergd/AppData/Roaming/RStudio/rstudio-prefs.json' updated.
#> * Restart RStudio for updates to take effect.
```
### Add Secondary Repository

Add secondary repositories to the **ROpenSci** and **ddsjoberg** R-Universes.
This is also helpful for adding secondary RStudio Package Manager repositories.

``` r
use_rstudio_secondary_repo(
  ropensci = "https://ropensci.r-universe.dev",
  ddsjoberg = "https://ddsjoberg.r-universe.dev"
)
#> == Updates ==================================================
#> - ropensci    [*  --> https://ropensci.r-universe.dev ]
#> - ddsjoberg   [*  --> https://ddsjoberg.r-universe.dev]
#> 
#> Would you like to continue? [y/n] y
#> √ File 'C:/Users/sjobergd/AppData/Roaming/RStudio/rstudio-prefs 2021-06-20.json' saved as backup.
#> √ File 'C:/Users/sjobergd/AppData/Roaming/RStudio/rstudio-prefs.json' updated.
#> * Restart RStudio for updates to take effect.
```

### Add Keyboard Shortcut

Use `use_rstudio_keyboard_shortcut()` to programmatically add keyboard shortcuts for add-ins.

```r
use_rstudio_keyboard_shortcut(
  "Ctrl+Shift+/" = "rstudio.prefs::make_path_norm"
)
#> == Updates ==================================================
#> - Ctrl+Shift+/   [*  --> rstudio.prefs::make_path_norm]
#> 
#> Would you like to continue? [y/n] y
#> √ File 'C:/Users/sjobergd/AppData/Roaming/RStudio/keybindings/addins 2021-06-20.json' saved as backup.
#> √ File 'C:/Users/sjobergd/AppData/Roaming/RStudio/keybindings/addins.json' updated.
#> * Restart RStudio for updates to take effect.
```

## Package history
{rstudio.prefs} was originally created and developed by
[Daniel D. Sjoberg](https://github.com/ddsjoberg). Maintenance was transferred
to [S.A. van der Wulp](https://github.com/vdwulp) starting with v0.2.0.
