# On the Use of the Scrape_FAO_HPAI.R Function


## Welcome VirusPlusLab Member

Hello there! This is the ReadMe file for the custom function that
Jonathan Dain built for extracting (‘scraping’) the current list of all
avian species infected with HPAI in the current clade 2.3.4.4n outbreak
from the Food and Agriculture Organization of the United Nations (FAO).
Specifically from this
[website](https://www.fao.org/animal-health/situation-updates/global-aiv-with-zoonotic-potential/bird-species-affected-by-h5nx-hpai/en)

## Getting the function into R

This is very simple. Download the `Scrape_FAO_HPAI.R` script into a
local directory of your choosing and then run the below command which
will load the function into your R environment.

``` r
source(file = "scrape_FAO_HPAI.R")
```

## Using the function:

This function is really simple to use. All it takes is a url input.
Thought since this is a internal function for personal use I have set
the default to the FAO webpage url so you can just run the function as
below to get the result.

``` r
obj <- scrape_FAO_HPAI()

print(obj,n = 15)
```

    # A tibble: 723 × 5
       category           taxonomic_group scientific_name common_name new_since_2021
       <chr>              <chr>           <chr>           <chr>       <lgl>         
     1 Farmed bird speci… Unclassified    Gallus gallus … Chicken     FALSE         
     2 Farmed bird speci… Unclassified    Anas platyrhyn… Duck        FALSE         
     3 Farmed bird speci… Unclassified    Anserinae sp.   Goose       FALSE         
     4 Farmed bird speci… Unclassified    Cairina moscha… Muscovy Du… FALSE         
     5 Farmed bird speci… Unclassified    Colinus virgin… Northern B… FALSE         
     6 Farmed bird speci… Unclassified    Columba livia … Domestic P… FALSE         
     7 Farmed bird speci… Unclassified    Coturnix cotur… Common qua… FALSE         
     8 Farmed bird speci… Unclassified    Coturnix japon… Japanese q… FALSE         
     9 Farmed bird speci… Unclassified    Dromaius novae… Emu         FALSE         
    10 Farmed bird speci… Unclassified    Pavo cristatus  Peacock     FALSE         
    11 Farmed bird speci… Unclassified    Phasianus colc… Common Phe… FALSE         
    12 Farmed bird speci… Unclassified    Numida meleagr… Common Gui… FALSE         
    13 Farmed bird speci… Unclassified    Struthio camel… Ostrich     FALSE         
    14 Wild bird species… Anseriformes    Aix galericula… Mandarin D… FALSE         
    15 Wild bird species… Anseriformes    Aix sponsa      Wood Duck   FALSE         
    # ℹ 708 more rows

As you can see we have a tibble object with four columns. Specifically
we have the broad catagory (farmed, wild bird, or mammals), then the
taxonomic order, then the scientific name, then the common name, and
finally a binary indicating of this is a novel infection event since
2021.

> ⚠️⚠️⚠️Warning: This function is likely very brittle because it is
> using the R packages `rvest` among others rather than a API to access
> the webpage. If this breaks I will need to fix it if possible however
> provided FAO continues to update their site in a consistent manner
> then this will work. I make no claims as to the longevity of this
> function.

## In the future:

I will eventually wrap these into a formal R package called VPLToolsR
but that is down the line. For now enjoy and keep your eyes to the sky!

<img src="Mallard_R_Coder.png" width="800" align="center">
