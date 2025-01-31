testthat_spark_connection <- function(conn_attempts, conn_retry_interval_s = 2) {
  conn_key <- ".testthat_spark_connection"
  if (!exists(conn_key, envir = .GlobalEnv)) {
    version <- Sys.getenv("SPARK_VERSION")
    spark_installed <- spark_installed_versions()
    if (nrow(spark_installed[spark_installed$spark == version, ]) == 0) {
      spark_install(version)
    }

    conn_attempts <- 3
    for (attempt in seq(conn_attempts)) {
      success <- tryCatch(
        {
          sc <- spark_connect(
            master = "local",
            method = "shell",
            app_name = paste0("testthat-", uuid::UUIDgenerate()),
            version = version
          )
          assign(conn_key, sc, envir = .GlobalEnv)
          TRUE
        },
        error = function(e) {
          if (attempt < conn_attempts) {
            Sys.sleep(conn_retry_interval_s)
            FALSE
          } else {
            e
          }
        }
      )
      if (success) break
    }
  }

  get(conn_key, envir = .GlobalEnv)
}

test_data <- function(file_name) {
  file.path(normalizePath(getwd()), "data", file_name)
}

expect_boundary_envelope <- function(rdd, expected) {
  actual <- lapply(
    paste0("get", c("MinX", "MaxX", "MinY", "MaxY")),
    function(getter) {
      rdd$.jobj %>% invoke("%>%", list("boundaryEnvelope"), list(getter))
    }
  ) %>%
    unlist()

  expect_equal(actual, expected)
}

expect_geom_equal <- function(sc, lhs, rhs) {
  expect_equal(length(lhs), length(rhs))
  for (i in seq_along(lhs)) {
    expect_true(
      invoke_static(
        sc,
        "org.apache.sedona.core.utils.GeomUtils",
        "equalsExactGeom",
        lhs[[i]],
        rhs[[i]]
      )
    )
  }
}
