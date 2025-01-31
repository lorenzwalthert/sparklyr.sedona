#' Export a Spark SQL query with a spatial column into a Sedona spatial RDD.
#'
#' Given a Spark dataframe object or a dplyr expression encapsulating a Spark
#' SQL query, build a Sedona spatial RDD that will encapsulate the same query or
#' data source. The input should contain exactly one spatial column and all
#' other non-spatial columns will be treated as custom user-defined attributes
#' in the resulting spatial RDD.
#'
#' @param x A Spark dataframe object in sparklyr or a dplyr expression
#'   representing a Spark SQL query.
#' @param spatial_col The name of the spatial column.
#'
#' @export
to_spatial_rdd <- function(x, spatial_col) {
  sdf <- x %>% spark_dataframe()

  invoke_static(
    spark_connection(sdf),
    "org.apache.sedona.sql.utils.Adapter",
    "toSpatialRdd",
    sdf,
    spatial_col
  ) %>%
    make_spatial_rdd(NULL)
}

#' Spatial RDD aggregation routine
#'
#' Function extracting aggregate statistics from a Sedona spatial RDD.
#'
#' @param x A Sedona spatial RDD.
#'
#' @name sedona_spatial_rdd_aggregation_routine
NULL

#' Find the minimal bounding box of a geometry.
#'
#' Given a Sedona spatial RDD, find the axis-aligned minimal bounding box of the
#' geometry represented by the RDD.
#'
#' @inheritParams sedona_spatial_rdd_aggregation_routine
#'
#' @family Spatial RDD aggregation routine
#' @export
minimum_bounding_box <- function(x) {
  x$.jobj %>%
    invoke("boundary") %>%
    make_bounding_box()
}

#' Find the approximate total number of records within a Spatial RDD.
#'
#' Given a Sedona spatial RDD, find the (possibly approximated) number of total
#' records within it.
#'
#' @inheritParams sedona_spatial_rdd_aggregation_routine
#'
#' @family Spatial RDD aggregation routine
#' @export
approx_count <- function(x) {
  x$.jobj %>%
    invoke("approximateTotalCount")
}

make_spatial_rdd <- function(jobj, type, ...) {
  structure(
    list(.jobj = jobj, .state = new.env(parent = emptyenv())),
    class = paste0(c(type, "spatial"), "_rdd")
  )
}
