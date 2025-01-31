context("visualization")

sc <- testthat_spark_connection()

test_that("sedona_render_heatmap() works as expected", {
  pt_rdd <- sedona_read_dsv_to_typed_rdd(
    sc,
    location = test_data("arealm-small.csv"),
    type = "point",
    first_spatial_col_index = 1
  )

  sedona_render_heatmap(
    pt_rdd,
    800,
    600,
    output_location = tempfile("arealm-small-"),
    boundary = c(-91, -84, 30, 35),
    blur_radius = 10
  )

  succeed()
})

test_that("sedona_render_scatter_plot() works as expected", {
  pt_rdd <- sedona_read_dsv_to_typed_rdd(
    sc,
    location = test_data("arealm.csv"),
    type = "point"
  )

  sedona_render_scatter_plot(
    pt_rdd,
    1000,
    600,
    output_location = tempfile("scatter-plot-"),
    boundary = c(-126.790180, -64.630926, 24.863836, 50.000),
    base_color = c(255, 255, 255)
  )

  succeed()
})

test_that("sedona_render_choropleth_map() works as expected", {
  pt_rdd <- sedona_read_dsv_to_typed_rdd(
    sc,
    location = test_data("arealm.csv"),
    type = "point"
  )
  polygon_rdd <- sedona_read_dsv_to_typed_rdd(
    sc,
    location = test_data("primaryroads-polygon.csv"),
    type = "polygon"
  )
  invoke(
    pt_rdd$.jobj,
    "spatialPartitioning",
    invoke_static(
      sc,
      "org.apache.sedona.core.enums.GridType",
      "KDBTREE"
    )
  )
  invoke(
    polygon_rdd$.jobj,
    "spatialPartitioning",
    invoke(pt_rdd$.jobj, "getPartitioner")
  )
  invoke(
    pt_rdd$.jobj,
    "buildIndex",
    invoke_static(
      sc,
      "org.apache.sedona.core.enums.IndexType",
      "RTREE"
    ),
    TRUE
  )
  pair_rdd <- invoke_static(
    sc,
    "org.apache.sedona.core.spatialOperator.JoinQuery",
    "SpatialJoinQueryCountByKey",
    pt_rdd$.jobj,
    polygon_rdd$.jobj,
    TRUE,
    TRUE
  ) %>%
    sparklyr.sedona:::make_spatial_rdd("pair_rdd")

  sedona_render_choropleth_map(
    pair_rdd,
    1000,
    600,
    output_location = tempfile("scatter-plot-"),
    boundary = c(-126.790180, -64.630926, 24.863836, 50.000),
    base_color = c(255, 255, 255)
  )

  succeed()
})
