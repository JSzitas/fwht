
if(!require("reshape2")) install.packages("reshape2")
if(!require("microbenchmark")) install.packages("microbenchmark")
if(!require("memoise")) install.packages("memoise")
if(!require("ggplot2")) install.packages("ggplot2")

# set the maximal size of the vector to transform (will be a power of 2)
# the following creates vectors of size 2^(1:16) for benchmarking
max_order_k <- 10

fwht <- function( x )
{
  if(length(x) == 1) return(x) 
  upper = x[1:(length(x)/2)]
  lower = x[((length(x)/2)+1):length(x)]

  a = upper + lower
  b = -lower + upper

  return(c(fwht(a),fwht(b)))
}

make_hadamard <- function(d) {
  A <- matrix(1)
  
  for (i in 2:d) {
    A <- rbind(cbind(A, A), cbind(A, -A))
  }
  
  return(A)
}

wht_naive <- function( x )
{
  h <- make_hadamard( log(length(x),2)+1)
  return( x %*% h )
}

wht_naive_memoise <- function( x )
{
  h <- mem_hadamard( log(length(x),2)+1)
  return( x %*% h )
}

# note that with this we memorise for the naive version - so we 
# benchmark just the multiplication, not the generation of hadamard matrices
mem_hadamard <- memoise::memoise( make_hadamard )
for(i in 2^(1:max_order_k)){ mem_hadamard( log(i,2)+1) }

benchmark_list <- list()

for(i in 2^(1:max_order_k))
{
  data <- rnorm(i)
  benchmark_list[[as.character(i)]] <- microbenchmark::microbenchmark( 
    fwht(data),
    wht_naive(data), 
    wht_naive_memoise(data),
    unit = "us",
    times = 100 )
}

bench_res <- Reduce(rbind, lapply( benchmark_list, function(i) summary(i)$mean))
colnames( bench_res) <- c("fwht", "wht_naive", "wht_naive_memoise")

df <- reshape2::melt(bench_res)
df[,1] <- rep( c(1:max_order_k),3) 
colnames(df) <- c("Order", "Algorithm","Timing")


ggplot2::ggplot(df, ggplot2::aes(x = Order, y = Timing, color = Algorithm)) + 
  ggplot2::geom_line() +
  ggplot2::ggtitle("Timing of different algorithms for the Walsh-Hadamard transform")

memoise::forget(mem_hadamard)




