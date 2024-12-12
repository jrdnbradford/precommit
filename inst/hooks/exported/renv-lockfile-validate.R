#!/usr/bin/env Rscript

'style files.
Usage:
  style_files [--style_pkg=<style_guide_pkg>] [--style_fun=<style_guide_fun>] [--cache-root=<cache_root_>] [--no-warn-cache] [--ignore-start=<ignore_start_>] [--ignore-stop=<ignore_stop_>] <files>...

Options:
  --schema= A file path to a JSON schema
  --greedy
  --error
  --verbose
  --strict
' -> doc

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


print(args)
print(non_file_args)

norm_paths <- normalizePath(args)
print(norm_paths)
renv::lockfile_validate(lockfile = norm_paths)
