% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data_documentation.R
\docType{data}
\name{b_pam}
\alias{b_pam}
\title{Example of object obtained from using the function base_PAM}
\format{
A list of 2 elements:
\describe{
\item{PAM}{SpatialPolygonsDataFrame wiht 306 features}
\item{PAM_indices}{a list of 11 elements}
}
}
\usage{
b_pam
}
\description{
An S3 object of class base_PAM. See functions \code{\link{prepare_base_PAM}}.
}
\examples{
data("b_pam", package = "biosurvey")

print(b_pam)
}
\keyword{datasets}
