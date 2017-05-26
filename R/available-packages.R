## It's really nasty to try and intercept the calls to download
## PACKAGES index files because R will load one of the three different
## files (PACKAGES.rds, PACKAGES.gz, PACKAGES in order of preference)
## unless it's a file url in which case it will take PACKAGES by
## preference.  If one fails it tries to grab the next one.  The
## resulting data ends up with a `Repository` field added so we need
## to reset that too.
available_packages <- function(contriburl = contrib.url(repos, type),
                               method, fields = NULL,
                               type = getOption("pkgType"),
                               filters = NULL, repos = getOption("repos"),
                               pubkey = getOption("notary.cran.pubkey")) {
  idx <- vapply(contriburl, package_index_download, character(1),
                tempfile(), pubkey)
  tmp <- file_url(dirname(idx))
  ret <- utils::available.packages(tmp, filters = filters)
  ret[, "Repository"] <- contriburl[match(ret[, "Repository"], tmp)]
  ret
}

package_index_download <- function(url, dest_dir, pubkey) {
  protocol <- uri_protocol(url)
  dir.create(dest_dir)
  idx <- file.path(dest_dir, "PACKAGES")
  ## TODO: this could be simplified for the file ones because we don't
  ## usually need to copy them around.
  for (u in index_filename(url, protocol)) {
    path <- tryCatch(download_file_verify(url, tempfile(), pubkey, method),
                     download_error = function(e) e)
    if (!inherits(path, "download_error")) {
      if (u == "PACKAGES.rds") {
        write.rds(readRDS(path), idx)
      } else if (u == "PACKAGES.gz") {
        writeLines(readLines(path), idx)
      } else {
        file.copy(path, idx)
      }
      unlink(path)
      break
    }
    if (file.exists(path)) {
      unlink(path)
    }
  }
  if (inherits(path, "download_error")) {
    stop(path)
  }
  idx
}

index_filename <- function(base, protocol) {
  if (protocol == "file") {
    file <- "PACKAGES"
  } else {
    file <- c(if (getRversion() >= "3.4.0")  "PACKAGES.rds",
              "PACKAGES.gz", "PACKAGES")
  }
  file.path(base, file)
}