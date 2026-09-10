# ⚙️ rstudio.prefs
<img src="man/figures/logo.png" align="right" width="150" style="float:right; width:150px;" class="pkgdown-hide">

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/rstudio.prefs)](https://CRAN.R-project.org/package=rstudio.prefs)
[![R-CMD-check](https://github.com/vdwulp/rstudio.prefs/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/vdwulp/rstudio.prefs/actions/workflows/R-CMD-check.yaml)
[![Codecov test coverage](https://codecov.io/gh/vdwulp/rstudio.prefs/branch/main/graph/badge.svg)](https://app.codecov.io/gh/vdwulp/rstudio.prefs/tree/main)
<!-- badges: end -->

*Manage RStudio preferences and addin shortcuts*

The {rstudio.prefs} package provides a programmatic interface for working with
RStudio preference files to modify settings and addin keyboard shortcuts
without using point-and-click option menus. This is useful for teams and
individuals working across multiple devices who want a **unified experience**
and for enforcing **best practices**. The package also exposes settings not available
in the *Global Options* dialog.

## Installation

Install {rstudio.prefs} from [CRAN](https://cran.r-project.org/package=rstudio.prefs) with:

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

Update the RStudio preferences. A full listing of preferences is available in
the [RStudio documentation](https://docs.posit.co/ide/server-pro/admin/reference/session_user_settings.html).

``` r
library(rstudio.prefs)

use_rstudio_prefs(
  always_save_history = FALSE,
  save_workspace = "never",
  load_workspace = FALSE,
  rainbow_parentheses = TRUE,
  busy_exclusion_list = list("tmux", "screen")
)
#> √ Downloading list of available RStudio settings
#>
#> == Updates ==================================================
#> - always_save_history   [TRUE   --> FALSE       ]
#> - save_workspace        [ask    --> never       ]
#> - load_workspace        [TRUE   --> FALSE       ]
#> - rainbow_parentheses   [FALSE  --> TRUE        ]
#> - busy_exclusion_list   [tmux   --> tmux, screen]
#> 
#> Would you like to continue? [y/n] y
```

### Add Secondary Repository

Add secondary repositories to the **ROpenSci** and **username** R-Universes.
This is also helpful for adding secondary RStudio Package Manager repositories.

``` r
use_rstudio_secondary_repo(
  ropensci = "https://ropensci.r-universe.dev",
  username = "https://username.r-universe.dev"
)
#> == Updates ==================================================
#> - ropensci   [*  --> https://ropensci.r-universe.dev]
#> - username   [*  --> https://username.r-universe.dev]
#> 
#> Would you like to continue? [y/n] y
```

### Add Keyboard Shortcut

Use `use_rstudio_keyboard_shortcut()` to programmatically add or remove keyboard
shortcuts for add-ins. To remove a shortcut, pass `NULL` instead of a function.

```r
use_rstudio_keyboard_shortcut(
  "Ctrl+Shift+/" = "rstudio.prefs::make_path_norm"
)
#> == Updates ==================================================
#> - Ctrl+Shift+/   [*  --> rstudio.prefs::make_path_norm]
#> 
#> Would you like to continue? [y/n] y
#> √ File 'C:/Users/username/AppData/Roaming/RStudio/keybindings/addins 2026-08-30.json' saved as backup.
#> √ File 'C:/Users/username/AppData/Roaming/RStudio/keybindings/addins.json' updated.
#> * Restart RStudio for updates to take effect.
```

As shown in the output **RStudio needs to be restarted** for keyboard shortcut
changes to take effect.

## Package history
{rstudio.prefs} was originally created and developed by
[Daniel D. Sjoberg](https://github.com/ddsjoberg). Maintenance was transferred
to [S.A. van der Wulp](https://github.com/vdwulp) starting with v0.2.0.
