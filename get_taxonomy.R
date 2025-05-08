# Get taxonomy information
# july 17th, 2024
# Leonardo Carlos Jeronimo Corvalan
# some people found it difficult to import the myTAI package, so I just took this function from the package 
# install packages

# install packages

install.packages("taxize")


# Here I copied the function from myTAI package 
taxonomy <- function (organism, db = "ncbi", output = "classification") 
{
  if (!is.element(output, c("classification", "taxid", "children"))) 
    stop("The output '", output, "' is not supported by this function.")
  if (!is.element(db, c("ncbi", "itis"))) 
    stop("Database '", db, "' is not supported by this function.")
  name <- id <- NULL
  if (db == "ncbi") 
    tax_hierarchy <- as.data.frame(taxize::classification(taxize::get_uid(organism), 
                                                          db = "ncbi")[[1]])
  else if (db == "itis") 
    tax_hierarchy <- as.data.frame(taxize::classification(taxize::get_tsn(organism), 
                                                          db = "itis")[[1]])
  if (output == "classification") {
    return(tax_hierarchy)
  }
  if (output == "taxid") {
    return(dplyr::select(dplyr::filter(tax_hierarchy, name == 
                                         organism), id))
  }
  if (output == "children") {
    return(as.data.frame(taxize::children(organism, db = db)[[1]]))
  }
}

#packages
library(taxize)

# If you have many species, I recommend using the ncbi API key
# to generate your API kry acess: https://account.ncbi.nlm.nih.gov/settings/

# TO use the api key
taxize::use_entrez()
ENTREZ_KEY='???????????????????????????'

#copy and paste the key on the .Renvirion
usethis::edit_r_environ()
.rs.restartR() # restart R

# read the datas
library(readxl)

ssp <- read_xlsx('Ncbi_mito_list_mini.xlsx')
ssp

# create a function for get the family  information for each specie. -> cat faily

catfamily <- function(x){
  tax <- taxonomy(x, db = "ncbi", output = "classification")
  family <- tax[tax$rank=="family",]
}

## apply the catfamily function in loop for all listed species 

data <- lapply(ssp$ssp, catfamily)

# transform the species with out data in NA

for (i in 1:length(data)) {
  if(is.data.frame(data[[i]])) {
    } else {
      data[[i]] <- data.frame(name = NA, rank = "family", id = NA)
    }
}

# marge datas
data_total <- do.call(rbind, data)
family_data <- (data_total$name)
family_data

#  add family information to the DF
ssp$family<- family_data

# Get order informations

catorder <- function(x){
  tax <- taxonomy(x, db = "ncbi", output = "classification")
  order <- tax[tax$rank=="order",]
}

#Applying the catorder function and obtaining the names of the orders in which each family under study belongs:

data_order <- lapply(ssp$ssp, catorder)

# transform the species with out data in NA

for (i in 1:length(data_order)) {
  if(is.data.frame(data_order[[i]])) {
  } else {
    data_order[[i]] <- data.frame(name = NA, rank = "order", id = NA)
  }
}

data_total <- do.call(rbind, data_order)
order_data <- (data_total$name)
order_data

ssp$order<- order_data

# save df in csv file
write.csv(ssp, file = "spcies_list_taxonomy_information.csv")
