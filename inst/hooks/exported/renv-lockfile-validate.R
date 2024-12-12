#!/usr/bin/env Rscript

"Validate renv 

See `?renv::lockfile_validate()`.

Usage:
  lockfile_validate [--greedy] [--error] [--verbose] [--strict] <files>...

Options:
  --greedy Boolean. Continue after first error?
  --error Boolean. Throw an error on parse failure?
  --verbose Boolean. If `TRUE`, then an attribute `errors` will list validation failures as a `data.frame`.
  --strict Boolean. Set whether the schema should be parsed strictly or not.
" -> doc
arguments <- precommit::precommit_docopt(doc)
arguments$files <- normalizePath(arguments$files)
if (!require(renv, quietly = TRUE)) {
  stop("{renv} could not be loaded, please install it.")
}
if (packageVersion("renv") < package_version("1.0.8")) {
  rlang::abort("You need at least version 1.0.8 of {renv} to run this hook.")
}

if (!require(jsonvalidate, quietly = TRUE)) {
  stop("{jsonvalidate} could not be loaded, please install it.")
}


print(arguments)
print(arguments$greedy)
print(arguments$error)

renv::lockfile_validate(
  lockfile = arguments$files,
  greedy = arguments$greedy,
  error = arguments$error,
  verbose = arguments$verbose,
  strict = arguments$strict
)
