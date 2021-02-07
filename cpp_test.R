
if(!require("reshape2")) install.packages("reshape2")
if(!require("microbenchmark")) install.packages("microbenchmark")
if(!require("ggplot2")) install.packages("ggplot2")

Rcpp::sourceCpp('./fwht_cpp.cpp')


fwht_R <- function( x )
{
  if(length(x) == 1) return(x) 
  upper = x[1:(length(x)/2)]
  lower = x[((length(x)/2)+1):length(x)]
  
  a = upper + lower
  b = -lower + upper
  
  return(c(fwht(a),fwht(b)))
}

max_order_k <- 15
benchmark_list <- list()
for(i in 2^(1:max_order_k))
{
  data <- rnorm(i)
  benchmark_list[[as.character(i)]] <-
    microbenchmark::microbenchmark(fwht_R(data),
                                   fwht(data),
                                   times = 100,
                                   unit = "us")
}

bench_res <- Reduce(rbind, lapply( benchmark_list, function(i) summary(i)$mean))
colnames( bench_res) <- c("fwht_R", "fwht_cpp")

df <- reshape2::melt(bench_res)
df[,1] <- rep( c(1:max_order_k),2) 
colnames(df) <- c("Order", "Algorithm","Timing")


ggplot2::ggplot(df, ggplot2::aes(x = Order, y = Timing, color = Algorithm)) + 
  ggplot2::geom_line() +
  ggplot2::ggtitle("Timing of R vs C++ for the Fast Walsh-Hadamard transform")

