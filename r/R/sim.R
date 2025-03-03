#' Simulation of Open, High, Low, and Close Prices
#'
#' This function performs simulations consisting of \code{n} periods and where each period consists of a given number of \code{trades}.
#' For each trade, the actual price \eqn{P_t} is simulated as \eqn{P_t = P_{t-1}e^{\sigma x}}, where \eqn{\sigma} is the standard deviation per trade and \eqn{x} is a random draw from a unit normal distribution.
#' The standard deviation per trade equals the \code{volatility} divided by the square root of the number of \code{trades}.
#' Trades are assumed to be observed with a given \code{probability}.
#' The bid (ask) for each trade is defined as \eqn{P_t} multiplied by one minus (plus) half the \code{spread} and we assume a 50\% chance that a bid (ask) is observed.
#' High and low prices equal the highest and lowest prices observed during the period.
#' Open and Close prices equal the first and the last price observed in the period.
#' If no trade is observed for a period, then the previous Close is used as the Open, High, Low, and Close prices for that period.
#'
#' @param n the number of periods to simulate.
#' @param trades the number of trades per period.
#' @param prob the probability to observe a trade.
#' @param spread the bid-ask spread.
#' @param volatility the open-to-close volatility.
#' @param overnight the close-to-open volatility.
#' @param drift the expected return per period.
#' @param units the units of the time period. One of: \code{1}, \code{sec}, \code{min}, \code{hour}, \code{day}, \code{week}, \code{month}, \code{year}.
#' @param sign whether to return positive prices for buys and negative prices for sells.
#'
#' @return A data.frame of open, high, low, and close prices if \code{units=1} (default). 
#' Otherwise, an \code{xts} object is returned (requires the \code{xts} package to be installed).
#'
#' @references
#' Ardia, D., Guidotti, E., Kroencke, T.A. (2024). Efficient Estimation of Bid-Ask Spreads from Open, High, Low, and Close Prices. Journal of Financial Economics, 161, 103916. 
#' \doi{10.1016/j.jfineco.2024.103916}
#'
#' @examples
#' # reduce number of threads to pass CRAN checks (you can ignore this)
#' data.table::setDTthreads(1)
#' 
#' # simulate 10 open, high, low, and close prices with spread 1%
#' sim(n = 10, spread = 0.01)
#' 
#' @export
#'
sim <- function(
    n = 10000, 
    trades = 390, 
    prob = 1, 
    spread = 0.01, 
    volatility = 0.03, 
    overnight = 0, 
    drift = 0, 
    units = 1,
    sign = FALSE){

  # sanitize units
  if(units == "minute") units <- "min"

  # check units
  valid <- c(1, "sec", "min", "hour", "day", "week", "month", "year")
  if(!(units %in% valid))
    stop(sprintf("units must be one of '%s'", paste(valid, collapse = "','")))

  # total number of observations
  m <- n*trades

  # close-to-close returns
  r <- rnorm(m, mean = drift/trades, sd = volatility/sqrt(trades))

  # close-to-open returns
  idx <- 0:(n-1) * trades + 1
  r[idx] <-  r[idx] + rnorm(n, sd = overnight)

  # compute prices
  z <- spread * (rbinom(m, size = 1, prob = 0.5) - 0.5)
  p <- exp(cumsum(r)) * (1 + z)
  
  # signed prices
  if(sign)
    p <- p * base::sign(z)

  # subset observations
  keep <- as.logical(rbinom(m, size = 1, prob = prob))

  # convert to OHLC
  ohlc <- matrix(nrow = n, ncol = 4)
  prev <- p[1]
  for(i in 1:n){
    # indices of the i-th period
    idx <- (i-1)*trades + 1:trades
    # observed prices
    obs <- p[idx][keep[idx]]
    # if empty keep previous close
    if(!length(obs)) obs <- prev
    # index of last observation
    last <- length(obs)
    # unsigned prices
    uobs <- abs(obs)
    # fill matrix
    ohlc[i,] <- obs[c(1, which.max(uobs), which.min(uobs), last)]
    # store previous close
    prev <- obs[last]
  }

  if(units == 1){
    ohlc <- as.data.frame(ohlc)
  }
  else {
    now <- Sys.time()
    if(!(units %in% c("sec", "min", "hour")))
      now <- as.Date(now)
    time <- seq(now, length = n, by = units)
    ohlc <- xts::xts(ohlc, order.by = time)
  }

  colnames(ohlc) <- c("Open", "High", "Low", "Close")
  return(ohlc)

}
