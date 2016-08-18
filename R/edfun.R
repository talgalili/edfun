# see also:
# https://cran.r-project.org/web/views/Distributions.html

# https://cran.r-project.org/web/packages/fBasics/fBasics.pdf
# param = ssdFit(r)



#' Title
#'
#' @param x numeric vector of data
#' @param ...
#'
#' @return
#' A list with 4 components: dfun, pfun, qfun and rfun.
#' Each one is a function to perform the usual tasks of distributions.
#' @export
#'
#' @examples
#'
#' set.seed(2016-08-18)
#' x <- rnorm(100)
#' x_funs <- edfun(x)
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
edfun <- function(x, ...) {



  density_x <- density(x)
  dapproxfun <- approxfun(x = density_x$x, y = density_x$y)
  dfun <- function(x) dapproxfun(x)

  pfun = ecdf(x)

  # or this: (but it would be MUCH slower)
  # qfun <- quantile(x, q)
  qfun <- approxfun(x = pfun(x), y = x)

  rfun <- function(n) sample(x, size = n, replace = TRUE)



  list(dfun = dfun,
       pfun = pfun,
       qfun = qfun,
       rfun = rfun)
}
