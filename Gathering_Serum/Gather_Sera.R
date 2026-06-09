#' Gather and Consolidate VirusPlus Lab ELISA Platemaps
#' 
#' @description
#' This function loops through the directory you point it at (i.e. a folder containing ELISA output files) and then consolidates the files into a single working tibble for later use. It is worth noting that this function does not clean the duplicate ELISA samples (i.e. _1 & _2) therefore care must be used when determining the correct values to use. Once you have your tibble you can filter to any sample you desire by using functions in the dplyr package.
#' 
#' This Rscript details the use and function of the gather serum function
#' for the VirusPlus Lab
#' 
#' @param path Character. The full directory path where the Excel files are located.
#' @param add_individual_plate_info Logical. If TRUE, adds columns for Plate_ID (extracted from filename) and ELISA_type. Default is FALSE.
#' @param ELISA_type Character. Label to apply to the ELISA_type column (e.g., "NP" or "H5"). Default is NA.
#' 
#' @return A data frame (tibble) containing the combined data from all matched plates.
#' @export
#'
#' @author Jonathan Dain.\email{jonathan.dain001@@umb.edu}
#' @note Created on 2026-06-09 for VirusPlusLab Data Screening
#' #' @seealso 
#' * [dplyr::bind_rows()] which is used internally to combine the plates, 
#' * [dplyr::filter()] for how the "Unknowns" are subset.


gather_sera <- function(path,add_individual_plate_info=F,ELISA_type=NA){
  # Find all the files!
  file.list <- list.files(path = path,pattern = "Plate",full.names = T)
  # make a empty vector
  results_list <- list()
  # reads along the file list to deal with each file
  for (i in seq_along(file.list)){
    current.file <- file.list[i]
    temp.file <- readxl::read_xlsx(path = current.file,sheet = "final results",skip=0,col_types = "text")
    # browser()
    temp.file$`Sample type` <- trimws(temp.file$`Sample type`)
    temp.file <- temp.file |> dplyr::filter(tolower(`Sample type`) == "unknowns")
    temp.file <- temp.file |> dplyr::filter(!is.na(`Sample ID`))
    if (add_individual_plate_info==T){ # if you want the individual file info.
      temp.name <- basename(current.file)
      temp.name <- gsub(pattern = ".xlsx",replacement = "",x=temp.name)
      temp.file$Plate_ID <- temp.name
      temp.file$ELISA_type <- ELISA_type
    } 
    results_list[[i]] <- temp.file # adds the ready file to the list
  }
  # Combines everything to a single data frame
  final_df <- dplyr::bind_rows(results_list)
  # returns the result. 
  return(final_df)
}
