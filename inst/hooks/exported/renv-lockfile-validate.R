#!/usr/bin/env Rscript

"Validate renv 

See `?renv::lockfile_validate()`.

Usage:
  lockfile_validate [--schema=<schema_>] [--greedy] [--error] [--verbose] [--strict] <files>...

Options:
  --schema A file path to a JSON schema. If not provided or `NULL` it defaults to the default renv schema.
  --greedy Boolean. Continue after first error?
  --error Boolean. Throw an error on parse failure?
  --verbose Boolean. If `TRUE`, then an attribute `errors` will list validation failures as a `data.frame`.
  --strict Boolean. Set whether the schema should be parsed strictly or not.
" -> doc

if (!require(renv, quietly = TRUE)) {
  stop("{renv} could not be loaded, please install it.")
}
if (packageVersion("renv") < package_version("1.0.8")) {
  rlang::abort("You need at least version 1.0.8 of {renv} to run this hook.")
}

if (!require(jsonvalidate, quietly = TRUE)) {
  stop("{jsonvalidate} could not be loaded, please install it.")
}

args <- commandArgs(trailingOnly = TRUE)
non_file_args <- args[!grepl("^[^-][^-]", args)]
keys <- setdiff(
  gsub("(^--[0-9A-Za-z_-]+).*", "\\1", non_file_args),
  c("--schema", "--greedy", "--error", "--verbose", "--strict")
)
if (length(keys) > 0) {
  bare_keys <- gsub("^--", "", keys)
  key_value_pairs <- paste0("  ", keys, "=<default_", bare_keys, ">  non_file_args ", bare_keys, ".")
  insert <- paste(paste0("[", keys, "=<default_", bare_keys, ">]", collapse = " "), "<files>...")

  doc <- gsub("<files>...", insert, paste0(doc, paste(key_value_pairs, collapse = "\n")))
}
arguments <- arguments <- precommit::precommit_docopt(doc, args)
arguments$files <- normalizePath(arguments$files) # because working directory changes to root

# Convert character strings to actual NULLs and booleans
convert_values <- function(x) {
  if (x == "NULL") {
    return(NULL)
  } else if (x == "TRUE") {
    return(TRUE)
  } else if (x == "FALSE") {
    return(FALSE)
  } else {
    return(x)
  }
}
print(arguments)
arguments <- lapply(arguments, convert_values)
print(arguments)

renv::lockfile_validate(
  lockfile = arguments$files,
  greedy = arguments$greedy,
  error = arguments$error,
  verbose = arguments$verbose,
  strict = arguments$strict
)
