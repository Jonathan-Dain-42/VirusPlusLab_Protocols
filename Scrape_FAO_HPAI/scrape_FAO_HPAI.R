#' Scrape FAO Webpage for HPAI infected species
#'
#' @description
#' This function scrapes the current list of species that are on the Food and Animal Organization of the United Nations' HPAI Outbreak report page and returns a tidy tibble for downstream usage. This is for internal use only as this function is likely fairly 'fragile' if the FAO decides to update things.
#'
#'
#' @param url Character. Defaults to: https://www.fao.org/animal-health/situation-updates/global-aiv-with-zoonotic-potential/bird-species-affected-by-h5nx-hpai/en
#'
#' @returns tibble object containing the following columns: catagory (farmed birds, wild birds, or mammals), taxanomic group, scientific name, common name, and a binary (T/F) for if this is a new species to be infected since 2021. Note this function does not remove any ambiguous species such as those with a scientific name of "Anserinae sp.". Care must be taken when handling those.
#' @export
#'
#' @examples
#' \dontrun{
#' obj <- scrape_FAO_HPAI()
#' print(obj,n=10)
#' }
#'
#' @author Jonathan Dain \email{jonathan.dain001@@umb.edu}
#' @note Created on 2026-07-21 for dissertation analysis.
#' @seealso
#' * [rvest::read_html()]
#' * [rvest::html_elements()]
#' * [rvest::read_html()]
#' * [rvest::html_attr()]
#' * [rvest::html_text()]
#' * [purrr::map_dfr()]
#' * [stringr::str_replace()]
#' * [stringr::str_detect()]
#' * [dplyr::mutate()]
#' * [dplyr::select()]
#' * [dplyr::distinct()]
#'
scrape_FAO_HPAI <- function(
    url = "https://www.fao.org/animal-health/situation-updates/global-aiv-with-zoonotic-potential/bird-species-affected-by-h5nx-hpai/en"
) {
  # Read in the webpage:
  webpage <- rvest::read_html(url)
  
  # 1. Grab all main tables on the page
  all_tables <- webpage  |>  rvest::html_elements("table")
  
  if (length(all_tables) < 3) {
    stop("DOM structure error: Expected at least 3 HTML tables on the page.")
  }
  
  # Table 1 = Farmed Birds, Table 2 = Wild Birds, Table 3 = Mammals
  sections <- list(
    list(category = "Farmed bird species affected", table_node = all_tables[[1]]),
    list(category = "Wild bird species affected",   table_node = all_tables[[2]]),
    list(category = "Mammalian species affected",   table_node = all_tables[[3]])
  )
  
  # 2. Extract entries from all three tables
  all_species_raw <- purrr::map_dfr(sections, function(sec) {
    cells <- sec$table_node  |>  rvest::html_elements("td")
    
    purrr::map_dfr(cells, function(cell) {
      # Target block elements only so nested <strong> tags inside list items don't overwrite group
      nodes <- cell  |>  rvest::html_children()
      
      current_group <- "Unclassified"
      rows <- list()
      
      for (node in nodes) {
        tag <- rvest::html_name(node)
        text <- rvest::html_text(node, trim = TRUE)
        
        # Update active Order/Family when hitting headers/paragraphs
        if (tag %in% c("p", "h4", "strong") && nchar(text) > 0 && !stringr::str_detect(text, "^\\*")) {
          current_group <- stringr::str_remove_all(text, "[\\*\\(\\)]")  |>  stringr::str_trim()
        }
        
        # Extract species list items
        if (tag == "ul") {
          species_items <- node  |>  rvest::html_elements("li")
          
          if (length(species_items) > 0) {
            raw_text <- species_items  |>  rvest::html_text(trim = TRUE)
            
            # Check for orange text highlight (new entries since 2021)
            is_orange <- species_items  |> 
              rvest::html_attr("class")  |> 
              tidyr::replace_na("")  |> 
              stringr::str_detect("text-color-orange")
            
            rows[[length(rows) + 1]] <- tibble::tibble(
              category = sec$category,
              taxonomic_group = current_group,
              raw_entry = raw_text,
              new_since_2021 = is_orange
            )
          }
        }
      }
      
      dplyr::bind_rows(rows)
    })
  })
  
  # 3. Clean scientific and common names
  hpai_master_df <- all_species_raw  |> 
    dplyr::mutate(
      # Extract Scientific Name (everything before opening parenthesis)
      scientific_name = stringr::str_extract(raw_entry, "^[^\n\\(]+")  |> 
        stringr::str_remove_all("\\*")  |> 
        stringr::str_trim(),
      
      # Extract Common Name (everything inside parentheses)
      common_name = stringr::str_extract(raw_entry, "(?<=\\().+?(?=\\))") |> 
        stringr::str_trim()
    )  |> 
    dplyr::select(category, taxonomic_group, scientific_name, common_name, new_since_2021)  |> 
    dplyr::distinct()
  
  return(hpai_master_df)
}

