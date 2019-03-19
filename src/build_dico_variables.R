# author: "Matthieu Doutreligne"
# date: "21 décembre 2018"

library(data.table)
library(dplyr)
library(readxl)
# for regex
library(stringr)


# Build all different tables
## Build common variables df

# create folder if it does not exist
path2variables_brutes = "../tables_brutes/variables_brutes/"

# Add top patho (ct_ide_g5)
ct_ide_g5_vars = readxl::read_xlsx(paste0(path2variables_brutes, "CT_G5.xlsx"), sheet = "CT_IDE")
ct_ide_g5_vars$Type = apply(ct_ide_g5_vars, 1, function(x) paste0(x[2], " (", gsub(' ', '', x[3]),")"))
ct_ide_g5_vars = ct_ide_g5_vars[, -c(3,5)]
ct_ide_g5_vars$table = rep("CT_IDE_AAAA_GN", nrow(ct_ide_g5_vars))
## reorder
ct_ide_g5_vars = ct_ide_g5_vars[, c(4,1,2,3)]
colnames(ct_ide_g5_vars) = c("table", "var", "format", "description")
## add valeur column (empty for this table)
ct_ide_g5_vars$nomenclature = rep("-", nrow((ct_ide_g5_vars)))

# Add top patho (ct_ind_g5)
ct_ind_g5_vars = readxl::read_xlsx(paste0(path2variables_brutes, "CT_G5.xlsx"), sheet = "CT_IND")
ct_ind_g5_vars$Type = apply(ct_ind_g5_vars, 1, function(x) paste0(x[2], " (", gsub(' ', '', x[3]),")"))
ct_ind_g5_vars = ct_ind_g5_vars[, -c(3,5)]
ct_ind_g5_vars$table = rep("CT_IND_AAAA_GN", nrow(ct_ind_g5_vars))
## reorder
ct_ind_g5_vars = ct_ind_g5_vars[, c(4,1,2,3)]
colnames(ct_ind_g5_vars) = c("table", "var", "format", "description")
## add valeur column (empty for this table)
ct_ind_g5_vars$nomenclature = rep("-", nrow((ct_ind_g5_vars)))

# Add top patho (ct_dep_g5)
ct_dep_g5_vars = readxl::read_xlsx(paste0(path2variables_brutes, "CT_G5.xlsx"), sheet = "CT_DEP")
ct_dep_g5_vars$Type = apply(ct_dep_g5_vars, 1, function(x) paste0(x[2], " (", gsub(' ', '', x[3]),")"))
ct_dep_g5_vars = ct_dep_g5_vars[, -c(3,5)]
ct_dep_g5_vars$table = rep("CT_DEP_AAAA_GN", nrow(ct_dep_g5_vars))
## reorder
ct_dep_g5_vars = ct_dep_g5_vars[, c(4,1,2,3)]
colnames(ct_dep_g5_vars) = c("table", "var", "format", "description")
## add valeur column (empty for this table)
ct_dep_g5_vars$nomenclature = rep("-", nrow((ct_dep_g5_vars)))

# Add practiciens tables (DA_PRA_R)
da_pra_r_vars = read.csv(paste0(path2variables_brutes,"DA_PRA_R.csv"), encoding = 'latin1')
da_pra_r_vars$nomenclature = rep("-", nrow((da_pra_r_vars)))

# Add affection longue durées (IR_IMB_R)
ir_imb_r_vars = read.csv2(paste0(path2variables_brutes,"IR_IMB_R.csv"), encoding = "latin1")

# Add other referentiels tables (IR_ACS_R, IR_ORC_R, IR_MTT_R, IR_MAT_R)
ir_others_vars=readxl::read_xlsx(paste0(path2variables_brutes,"Referentiels_ben_autres.xlsx"))
colnames(ir_others_vars) = c("table", "var", "format", "description", "nomenclature")

## Build specific dcir variables
# Parse the original Excel
source("parse_dcir.R")
dcir_main_vars = parseDcir(paste0(path2variables_brutes, "DCIR - liste des tables et variables.xls"))

# main variables (dcir)
## Add IR_BEN_R variables 
ir_ben_r_vars = readxl::read_xlsx(paste0(path2variables_brutes, "IR_BEN_R.xlsx"))
colnames(ir_ben_r_vars) = c("table", "var", "format", "description", "nomenclature")
ir_ben_r_vars$nomenclature = rep("-", nrow((ir_ben_r_vars)))

## Merge dcir variables
dcir_vars = rbind(dcir_main_vars, 
                  ir_ben_r_vars)

## Build specific dcirs variables 

# Main variables (dcirs)
dcirs_main_vars = readxl::read_xlsx(paste0(path2variables_brutes, "DCIRS - Liste des tables et variables - 2017 04 06.xlsx"), sheet = "Variables et rdg")

# Nomenclatures spéficiques aux variables du DCIRS
dcirs_nom_spe = dcirs_main_vars %>% 
  select(one_of("variables", "Commentaires")) %>% 
  filter(grepl("IR_", Commentaires)) %>% 
  mutate(nomenclature = replace(Commentaires, 
                                grepl("IR_", Commentaires), 
                                stringr::str_extract(Commentaires, "IR_\\w\\w\\w_\\w")))  %>% 
  select(-Commentaires)

dcirs_main_vars = dcirs_main_vars[, 1:4]

colnames(dcirs_main_vars) = c("table", "var", "format", "description")
# left join to get back nomenclature from dcir
dcirs_main_vars = dcirs_main_vars %>% 
  left_join(dcir_main_vars %>% 
              select(var, nomenclature), by = "var") %>% 
  mutate(nomenclature = replace(nomenclature, !grepl("^IR_", nomenclature), "-"))

for (ivar in dcirs_nom_spe$variables){
  dcir_main_vars = dcir_main_vars %>% 
    mutate(nomenclature = replace(nomenclature, 
                                  var == ivar, 
                                  dcirs_nom_spe$nomenclature[dcirs_nom_spe$variables == ivar]))
}

# Add IR_IBA_R variables
ir_iba_r_vars = readxl::read_xlsx(paste0(path2variables_brutes, "IR_IBA_R.xlsx"), sheet="Variables de la table IR_IBA_R", skip = 1)

ir_iba_r_vars = ir_iba_r_vars[,c(1:4,8)]
colnames(ir_iba_r_vars) = c("table", "var", "format", "description", "nomenclature")
ir_iba_r_vars$nomenclature = rep("-", nrow((ir_iba_r_vars)))

# Merge different sets of variables
dcirs_vars = rbind(dcirs_main_vars, 
                   ir_iba_r_vars)

## PMSI
pmsi_vars = read.csv2(paste0(path2variables_brutes,"PMSI_vars.csv"), encoding = 'latin1')

## CEPIDC
cepidc_vars = read.csv2(paste0(path2variables_brutes, "cepidc_vars.csv"), encoding = 'latin1')

# Merge all tables of the snds
snds_vars = rbind(dcir_vars, 
                  dcirs_vars, 
                  ir_imb_r_vars,
                  ir_others_vars,
                  ct_ide_g5_vars,
                  ct_ind_g5_vars,
                  ct_dep_g5_vars,
                  da_pra_r_vars,
                  pmsi_vars,
                  cepidc_vars)

snds_vars = snds_vars %>% 
  filter_all(all_vars(!is.na(.))) %>% 
  distinct()

## Ajout des correspondances manuelles de référentiel

# Création de complement_var2ref.csv, simplement pour information
# Les 3 lignes suivantes doivent restées commentée en opérations normales
#all_vars = unique(snds_vars$var)
#comp_df = data.table(var_name = all_vars, ref_name = "-", comment = "")
#write.csv2(comp_df, "../tables_brutes/complement_var2ref.csv", fileEncoding = "UTF-8", row.names = FALSE)

comp_df = read.csv2("../tables_brutes/complement_var2ref.csv", stringsAsFactors = F)
snds_vars = left_join(snds_vars, comp_df %>% select(var_name, ref_name), 
                      by = c("var" = "var_name")) %>% 
  mutate(nomenclature = ifelse(ref_name != "-", ref_name, nomenclature)) %>% 
  select(-ref_name)

## Copie de referentiels ajoutés à la main dans les dossiers nomenclatures
path2mynoms = '../tables_brutes/other_nomenclatures/'
path2appnoms = '../app/app_data/nomenclatures/'
path2noms = '../tables_brutes/nomenclatures/'

mynoms = paste0(path2mynoms, list.files(path2mynoms))
file.copy(mynoms, path2appnoms, overwrite = T)
file.copy(mynoms, path2noms, overwrite = T)

## Save snds_table
path2produits = "../tables_produits/"
path2app_data = "../app/app_data/"

# snds
write.csv2(snds_vars, file = paste0(path2produits, "snds_vars.csv"), row.names = F,  fileEncoding = "UTF-8")
write.csv2(snds_vars, file = paste0(path2app_data, "snds_vars.csv"), row.names = F, fileEncoding = "UTF-8")

