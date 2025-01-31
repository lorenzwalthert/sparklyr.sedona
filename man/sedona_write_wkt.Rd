% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data_interface.R
\name{sedona_write_wkt}
\alias{sedona_write_wkt}
\title{Write SpatialRDD into a WKT file.}
\usage{
sedona_write_wkt(x, output_location)
}
\arguments{
\item{x}{The SpatialRDD object.}

\item{output_location}{Location of the output file.}
}
\description{
Export serialized data from a Sedona SpatialRDD into a WKT file.
}
\seealso{
Other Sedona data inferface functions: 
\code{\link{sedona_read_dsv_to_typed_rdd}()},
\code{\link{sedona_read_geojson_to_typed_rdd}()},
\code{\link{sedona_read_geojson}()},
\code{\link{sedona_read_shapefile_to_typed_rdd}()},
\code{\link{sedona_read_shapefile}()},
\code{\link{sedona_read_wkb}()},
\code{\link{sedona_read_wkt}()},
\code{\link{sedona_save_spatial_rdd}()},
\code{\link{sedona_write_geojson}()},
\code{\link{sedona_write_wkb}()}
}
\concept{Sedona data inferface functions}
