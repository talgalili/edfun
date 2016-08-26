# Copyright (C) Tal Galili
#
# This file is part of edfun.
#
# edfun is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# edfun is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
#  A copy of the GNU General Public License is available at
#  http://www.r-project.org/Licenses/
#




# see also:
# https://cran.r-project.org/web/views/Distributions.html

# https://cran.r-project.org/web/packages/fBasics/fBasics.pdf
# param = ssdFit(r)



#' @title Creating Empirical Distribution Functions
#' @export
#' @param x numeric vector of data or (in case density is not NULL) a sequance of values
#' for which to evaluate the density function for creating the inv-CDF.
#' Also, the rfun will be based on the inverse CDF on uniform distribution (inv-CDF(U[0,1]) -
#' which is "better" than using \link{sample}, if we have the density).
#' @param support a 2d numeric vector giving the boundaries of the distribution.
#' Default is the range of x.
#' This is used in qfun to decide how to work with extreme cases of q->0|1.
#' @param dfun a density function. If supplied, this
#' creates a different pfun (which now relies on \link{integrate}) and rfun (which will now rely on inv-CDF(U[0,1])).
#' @param qfun_method can get a quantile function to use (for example "quantile"),
#' with the first parameter accepts the data (x) and the second accepts probs (numeric vector of probabilities with values in [0,1]).
#' If it is NULL (the default) then the quantiles are estimated using \link{approxfun} from
#' predicting the x values from the pfun(x) values.
#' @param ... ignored
#'
#'
#'
#' @return
#' A list with 4+ components: dfun, pfun, qfun and rfun.
#' The 5th componont is pfun_integrate_dfun which is NUNLL if dfun is not supplied.
#' If it is supplied, it returns a function that relies on \link{integrate} of dfun for
#' returning pfun. Since this method is VERY slow, it is not returned within pfun.
#' Instead, pfun will pre-compute pfun_integrate_dfun on all values of x.
#'
#' Each component is a function to perform the usual tasks of distributions.
#'
#' @examples
#'
#' set.seed(2016-08-18)
#' x <- rnorm(100)
#' x_funs <- edfun(x)
#' x_funs$qfun(0) # -2.6
#'
#' # for extreme cases, we can add the support vector
#' x_funs <- edfun(x, support = c(-Inf, Inf))
#' x_funs$qfun(0) # -Inf
#'
#' f <- x_funs$dfun
#' curve(f, -2,2)
#'
#' f <- x_funs$pfun
#' curve(f, -2,2)
#'
#' f <- x_funs$qfun
#' curve(f, 0,1)
#'
#' f <- x_funs$rfun
#' hist(f(1000))
#'
#'
#'
edfun <- function(x, support = range(x), # c(-Inf, Inf),
                  dfun = NULL,
                  qfun_method = NULL,
                  ...) {


  # check support is o.k.

  if((length(support) != 2L) | !is.numeric(support)) {
    warning("support must be a 2d numeric vector. Since it is not, it is ignored.")
    support <- range(x)
  } else {
    x_range <- range(x)
    if(support[1] > x_range[1] | support[2] < x_range[2]) {
      warning("The range of x must be within the support. Since it is not, support is ignored.")
      support <- x_range
    }
  }

  # check density is o.k.
  if(!is.null(dfun) & !is.function(dfun)) stop("density must either be NULL or a function.")

  dfun_by_user <- is.function(dfun) # did the user input dfun?

  # create density - dfun
  if(dfun_by_user) {
    # dfun <- dfun # redundent
  } else {
    density_x <- density(x)
    dapproxfun <- approxfun(x = density_x$x, y = density_x$y)
    dfun <- function(x) dapproxfun(x)
  }

  # create CDF - pfun
  if(dfun_by_user) {
    # min_x <- min(x)
    pfun_integrate_dfun_1 <- function(v) integrate(dfun, support[1], v)$value
    pfun_integrate_dfun <- function(x) Vectorize(pfun_integrate_dfun_1)(x)
    pfun <- approxfun(x = x, y = pfun_integrate_dfun(x), yleft = 0L, yright = 1L)
  } else {
    pfun_integrate_dfun <- NULL
    pfun <- ecdf(x)
  }


  # or this: (but it would be MUCH slower)
  # qfun <- quantile(x, q)


  # create inverse-CDF
  if(is.null(qfun_method)) {
    qfun <- approxfun(x = pfun(x), y = x, yleft = support[1], yright = support[2]) # if support is NULL than no problem
  } else {
    if(!is.function(qfun_method)) stop("qfun_method must be a (quantile) function.")
    qfun <- function(v) qfun_method(x, probs = v)
    # quantile
  }
  # # curve(qfun,0,1)
  ### not needed:
  # if(!is.null(support)) {
  #   qfun_data <- qfun
  #   qfun <- function(v) {
  #     out <- qfun_data(v)
  #     out <- ifelse(v == 0L, support[1], out)
  #     out <- ifelse(v == 1L, support[2], out)
  #     out
  #   }
  # }


  # create RNG
  if(dfun_by_user) {
    rfun <- function(n) qfun(runif(n)) #inv-CDF on U(0,1)
  } else {
    rfun <- function(n) sample(x, size = n, replace = TRUE)
  }





  list(dfun = dfun,
       pfun = pfun,
       qfun = qfun,
       rfun = rfun,
       pfun_integrate_dfun = pfun_integrate_dfun)
}












#
# #### timing - when knowing the dfun vs when not.
# if(FALSE) {
#
#   # checking speeds of when dfun is known or not.
#
#   set.seed(2016-08-18)
#   x_simu <- rnorm(1e3)
#   x_funs_simu <- edfun(x_simu, support = c(-Inf, Inf))
#
#
#   x <- seq(-4,4, length.out = 1e3)
#   x_funs <- edfun(x, dfun = dnorm, support = c(-Inf, Inf))
#   x_funs$qfun(0) # -Inf
#
#   # precision - qfun
#   q_to_test <- seq(0.001,.999, length.out = 100)
#   edfun_out <- x_funs$qfun(q_to_test) # -4
#   edfun_simu_out <- x_funs_simu$qfun(q_to_test) # -4
#   real_out <- qnorm(q_to_test)
#
#   mean(abs(edfun_out-real_out))
#   mean(abs(edfun_simu_out-real_out)) # quite terrible compared to when knowing dfun
#
#   library(microbenchmark)
#   microbenchmark(dfun_known = x_funs$qfun(q_to_test),
#                  dfun_NOT_known = x_funs_simu$qfun(q_to_test))
#   # same time for the q function!
#
#
#   # precision - pfun
#   q_to_test <- seq(-3,3, length.out = 100)
#   edfun_out <- x_funs$pfun(q_to_test) # -4
#   edfun_simu_out <- x_funs_simu$pfun(q_to_test) # -4
#   real_out <- pnorm(q_to_test)
#
#   mean(abs(edfun_out-real_out))
#   mean(abs(edfun_simu_out-real_out)) # quite terrible compared to when knowing dfun
#
#   library(microbenchmark)
#   microbenchmark(dfun_known = x_funs$pfun(q_to_test),
#                  dfun_NOT_known = x_funs_simu$pfun(q_to_test))
#   # same time for the p function!
#
#
#   # timing for the rfun
#   library(microbenchmark)
#   microbenchmark(dfun_known = x_funs$rfun(100),
#                  dfun_NOT_known = x_funs_simu$rfun(100))
#   # this rfun is slower...
# }
