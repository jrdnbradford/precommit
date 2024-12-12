#!/usr/bin/env Rscript

"Validate renv lockfiles.
Usage:
  lockfile_validate [--schema=<schema_>] [--greedy=<greedy_>] [--error=<error_>] [--verbose=<verbose_>] [--strict=<strict_>] <files>...

Options:
  --schema A file path to a JSON schema
  --greedy Boolean
  --error Boolean
  --verbose Boolean
  --strict Boolean
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

arguments <- precommit::precommit_docopt(doc)
arguments$files <- normalizePath(arguments$files) # because working directory changes to root
print(arguments)

args <- commandArgs(trailingOnly = TRUE)
non_file_args <- args[!grepl("^[^-][^-]", args)]
file_args <- setdiff(args, non_file_args)
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

print(doc)
print(keys)

print(args)
print(non_file_args)

norm_paths <- normalizePath(file_args)
print(norm_paths)
renv::lockfile_validate(lockfile = norm_paths)
