# see also:
# https://cran.r-project.org/web/views/Distributions.html

# https://cran.r-project.org/web/packages/fBasics/fBasics.pdf
# param = ssdFit(r)



#' Creating Empirical Distribution Functions
#'
#' @param x numeric vector of data
#' @param support a 2d numeric vector giving the boundaries of the distribution.
#' Default is the range of x.
#' This is used in qfun to decide how to work with extreme cases of q->0|1.
#' @param qfun_method can get a quantile function to use (for example "quantile"),
#' with the first parameter accepts the data (x) and the second accepts probs (numeric vector of probabilities with values in [0,1]).
#' If it is NULL (the default) then the quantiles are estimated using \link{approxfun} from
#' predicting the x values from the pfun(x) values.
#' @param ...
#'
#'
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
edfun <- function(x, support = range(x), # c(-Inf, Inf),
                  qfun_method = NULL,
                  ...) {


  # check support is o.k.

  if(!is.null(support)) {
    if(length(support) != 2L) {
      warning("support must be a 2d numeric vector. Since it is not, it is ignored.")
      support <- NULL
    } else {
      x_range <- range(x)
      if(support[1] > x_range[1] | support[2] < x_range[2]) {
        warning("The range of x must be within the support. Since it is not, support is ignored.")
        support <- NULL
      }
    }
  }



  # create density

  density_x <- density(x)
  dapproxfun <- approxfun(x = density_x$x, y = density_x$y)
  dfun <- function(x) dapproxfun(x)

  # create CDF
  pfun <- ecdf(x)

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
  rfun <- function(n) sample(x, size = n, replace = TRUE)



  list(dfun = dfun,
       pfun = pfun,
       qfun = qfun,
       rfun = rfun)
}




# x <- 1:100000
# microbenchmark::microbenchmark(c(x,1), c(x, NULL))


