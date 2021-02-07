#include <Rcpp.h>
#include <RcppEigen.h>
using namespace Rcpp;
using namespace RcppEigen;
using namespace Eigen;

// [[Rcpp::depends(RcppEigen)]]

// define our own concatenate function for two Eigen::Vector-s
Eigen::VectorXf concatenate( const Eigen::VectorXf & vec1, const Eigen::VectorXf & vec2 )
{
  // preallocate the vector size 
  Eigen::VectorXf vec_concatenated(vec1.size() + vec2.size());
  // assign the elements to the preallocated vector
  vec_concatenated << vec1, vec2;
  
  return vec_concatenated;
}

// [[Rcpp::export]]
Eigen::VectorXf fwht(const Eigen::VectorXf x ) 
{
  // check for termination
  if( x.size() == 1){
    return x;
  }
  // this is technically unnecessary, but there is also no reason to 
  // access the .size() twice
  const int half_size = (x.size()/2);
  // create a left and a right half of the vector
  Eigen::VectorXf left (x.head(half_size));
  Eigen::VectorXf right (x.tail(half_size));
  // the compiler can figure this out for us  
  Eigen::VectorXf a = left + right;
  Eigen::VectorXf b = left - right;
  // tail call - I checked if passing the values directly is not 
  // faster than creating 2 new objects, but found that for all practical 
  // data sizes, the difference was negligible - and led to harder to read code
  return concatenate( fwht(a),fwht(b));
}



