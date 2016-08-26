
[![Build Status](https://travis-ci.org/talgalili/edfun.png?branch=master)](https://travis-ci.org/talgalili/edfun)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/edfun)](https://cran.r-project.org/package=edfun)
![](http://cranlogs.r-pkg.org/badges/edfun?color=yellow)
![](http://cranlogs.r-pkg.org/badges/grand-total/edfun?color=yellowgreen)

# edfun

**Table of contents:**

* [Introduction](#introduction)
* [Installation](#installation)
* [Usage](#usage)
* [Credit](#credit)
* [Contact](#contact)


## Please submit features requests

This package is still under active development. If you have features you would like to have added, please submit your suggestions (and bug-reports) at: <https://github.com/talgalili/edfun/issues>


## Introduction

As mentioned in [CRAN Task View: Probability Distributions](https://cran.r-project.org/web/views/Distributions.html)

> Empirical distribution : Base R provides functions for univariate analysis: (1) the empirical density (see density()), (2) the empirical cumulative distribution function (see ecdf()), (3) the empirical quantile (see quantile()) and (4) random sampling (see sample()).

This package aims to easily wrap these into a single function `edfun` (short for Empirical Distribution FUNctions). Also, since quantile is generally a slow function to perform, the default for creating a quantile function (inverse-CDF) is by approximating the function of predicting the data values (x) from their quantiles (CDF). This is done using the `approxfun` function. It takes a bit longer to create qfun, but it is MUCH faster to run than quantile (and is thus much better for simulations). Special care is taken for dealing with the support of the distribution (if it is known upfront).

The added speed allows to use these functions to run simulation studies for unusual distributions.

## Installation

To install the stable version on CRAN:

```r
# install.packages('edfun') # not on CRAN yet
```

To install the latest ("cutting-edge") GitHub version run:

```R
# You'll need devtools
if (!require(devtools)) install.packages("devtools");

devtools::install_github('talgalili/edfun')
```

And then you may load the package using:

```R
library("edfun")
```

## Usage

Quick example:

```r
library(edfun)

set.seed(123)
x <- rnorm(1000)
x_dist <- edfun(x)

f <- x_dist$dfun
curve(f, -2,2)

f <- x_dist$pfun
curve(f, -2,2)

f <- x_dist$qfun
curve(f, 0,1)

new_x <- x_dist$rfun(1000)
hist(new_x)
```

This is especially useful for cases where we can simulate numbers or have their density, but don't have their CDF or inv-CDF. For example, for the double exponential distribution, or a bi-modal normal distribution.



## Credit

This package is thanks to the amazing work done by MANY people in the (open source) R community.


## Contact

You are welcome to:

* submit suggestions and bug-reports at: <https://github.com/talgalili/edfun/issues>
* send a pull request on: <https://github.com/talgalili/edfun/>
* compose a friendly e-mail to: <tal.galili@gmail.com>


## Latest news

You can see the most recent changes to the package in the [NEWS.md file](https://github.com/talgalili/edfun/blob/master/NEWS.md)





## Code of conduct

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

