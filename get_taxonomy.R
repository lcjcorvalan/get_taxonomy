# Get taxonomy information
# july 17th, 2024
# Leonardo Carlos Jeronimo Corvalan

# install packages
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install()
BiocManager::valid()
BiocManager::install(c('AnnotationDbi', 'caTools', 'edgeR', 'GenomicRanges', 'GenomicAlignments', 'gtools', 'Rsamtools', 'VennDiagram' ), ask = FALSE)

#pacote
install.packages("myTAI")
require(myTAI)

# If you hava a lot specie, use the API key from ncbi
#se API key, só use se for rodar para muitas espécies mais de 5k
taxize::use_entrez()
ENTREZ_KEY='552717a8bf15a10e0810fe042905dd5f3808'
#copy and paste the key on the .Renvirion
usethis::edit_r_environ()
.rs.restartR()

# read the datas

library(readxl)

ssp <- read_xlsx('Ncbi_mito_list.xlsx')
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

data_total <- do.call(rbind, data)
family_data <- (data_total$name)
family_data

ssp$family<- family_data

#procurar ordens 
catorder <- function(x){
  tax <- taxonomy(x, db = "ncbi", output = "classification")
  order <- tax[tax$rank=="order",]
}


## Aplicando a função catorder e obtendo os nomes das ordem a que percentecem cada familia em estudo:

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

write.csv(ssp, file = "spcies_list_taxonomy_information.csv")
