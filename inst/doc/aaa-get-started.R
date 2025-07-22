## ----include = FALSE----------------------------------------------------------
# Make sure the examples are available 
# use try-catch since Github may limit rate
library(bidsr)
has_examples <- tryCatch({
  example_root <- download_bids_examples()
  TRUE
}, error = function(e) {
  FALSE
})

knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = has_examples,
  echo = TRUE
)

## ----setup--------------------------------------------------------------------
library(bidsr)
example_root <- download_bids_examples()

## -----------------------------------------------------------------------------
project_path <- file.path(example_root, "ds000117")
project <- bids_project(path = project_path)

print(project)

## -----------------------------------------------------------------------------
description <- project$get_bids_dataset_description()

## -----------------------------------------------------------------------------
description$BIDSVersion

# or 
description@BIDSVersion

## -----------------------------------------------------------------------------
participants <- project$get_bids_participants()

## -----------------------------------------------------------------------------
participant_path <- file.path(project, "participants.tsv")
as_bids_tabular(participant_path, cls = BIDSTabularParticipants)

## -----------------------------------------------------------------------------
subject <- bids_subject(
  project = project, 
  subject_code = "sub-06"
)

print(subject)

## -----------------------------------------------------------------------------
subject <- bids_subject(
  project = project_path, 
  subject_code = "06"
)

## -----------------------------------------------------------------------------
# resolve subject path (raw data by default)
resolve_bids_path(subject)

resolve_bids_path(subject, storage = "source")

## -----------------------------------------------------------------------------
resolve_bids_path(subject, storage = "derivative", prefix = "freesurfer")

## -----------------------------------------------------------------------------
query_bids(subject, "anat")

## -----------------------------------------------------------------------------
query_bids(subject, list(
  # dataset to filter, choices are raw, source, or derivative
  storage = "raw",
  
  # include JSON sidecars; default is `FALSE`  
  sidecars = FALSE,
  
  # set to `NULL` to include all data types
  data_types = "anat",
  
  # filter all suffixes
  suffixes = NULL
))

## -----------------------------------------------------------------------------
query_bids(subject, list(
  # filter derivatives
  storage = "derivative",
  
  # filter `derivatives/meg_derivatives` folder
  prefix = "meg_derivatives",

  # include JSON sidecars
  sidecars = TRUE,
  
  # set to `NULL` to include all data types
  data_types = NULL,
  
  # only keep files with *_meg/log.* suffixes
  suffixes = c("meg", "log")
))

## -----------------------------------------------------------------------------
filter_result <- query_bids(subject, list(
  storage = "raw",
  sidecars = FALSE,
  
  data_types = "func",
  suffixes = "events",
  
  # use R "formula" to filter entities
  entity_filters = list(

    # entity_key ~ expression returning TRUE/FALSE
    # When filtering the entities, `entity_key` will be
    # replaced with its value
    run ~ as.integer(run) == 2
  )
))
filter_result

## -----------------------------------------------------------------------------
event_file <- filter_result$parsed[[1]]
event_file

## -----------------------------------------------------------------------------
get_bids_entity(event_file, "task")

## -----------------------------------------------------------------------------
event_path <- file.path(project, event_file)

# or 
event_path <- resolve_bids_path(project, format(event_file))

as_bids_tabular(event_path)

## ----cleanup, echo = FALSE, results='hide'------------------------------------
cache_root <- tools::R_user_dir(package = "bidsr", which = "cache")
if(file.exists(cache_root)) {
  unlink(cache_root, recursive = TRUE)
}

