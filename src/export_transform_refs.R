library(data.table)

# Fonction isolant chaque référentiel
sep_table <- function(ref_name, ref_table){
  ir_table<-as.data.frame(ref_table[nom_table==ref_name,])
  ir_table<-ir_table[!sapply(ir_table, function(x) all(is.na(x)|x==""))]
  ir_table
}

dir.create("../tables_produits/tables")
dir.create("../app/app_data/tables")

# Chargement des référentiels IR
path2refs = "../tables_brutes/REFERENTIELS_IR.csv"
ref_ir<-fread(path2refs)

for (nom in unique(ref_ir$nom_table)){
  eval(parse(text=paste0(nom,"<-sep_table(nom, ref_ir)")))
  # write dans produits et dans app_data
  eval(parse(text=paste0("fwrite(",nom,",'../tables_produits/tables/",nom,".csv')")))
  eval(parse(text=paste0("fwrite(",nom,",'../app/app_data/tables/",nom,".csv')")))
}


# Chargement des autres référentiels
ref_aut<-fread("C:/Users/claire-lise.dubost/Documents/Sniiram/Référentiels/referentiels_ir2b.txt")
for (nom in unique(ref_aut$nom_table)){
  eval(parse(text=paste0(nom,"<-sep_table(nom, ref_aut)")))
  # write dans produits et dans app_data
  eval(parse(text=paste0("fwrite(",nom,",'../tables_produits/tables/",nom,".csv')")))
  eval(parse(text=paste0("fwrite(",nom,",'../app/app_data/tables/",nom,".csv')")))
}
