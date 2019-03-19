# title: "Network build"
# author: "Matthieu Doutreligne"
# creation date: "2018-12-20"

# Construction des tables 

library(dplyr)
library(data.table)

# Verify that app_data exists and create it if it does not
path2app = "../app/"
dir.create(path2app)

# Read the list of tables in the SNDS
path2variables_brutes = "../tables_brutes/variables_brutes/"
snds_nodes = read.csv2(file=paste0(path2variables_brutes,"SNDS_tables_lib.csv"), fileEncoding = "UTF-8")
groups = data.frame(Produit=unique(snds_nodes$Produit))
groups$group = groups$Produit

snds_nodes = snds_nodes %>% 
  left_join(groups, by="Produit")

snds_nodes = snds_nodes %>% 
  select(one_of("Table", "Libelle", "group"))

snds_nodes$index = 1:nrow(snds_nodes) -1

# update column names
colnames(snds_nodes) = c("name", "description", "group", "index")

# Load snds_vars
path2produits = "../tables_produits/"
snds_vars = read.csv(paste0(path2produits, "snds_vars.csv"), fileEncoding = "UTF-8")

# Nodes sizes
## update tables_nodes to take into account node size (prop to number of variables)
nb_vars = data.frame(table(snds_vars$table))
snds_nodes = left_join(snds_nodes, nb_vars, by = c("name" = "Var1"))
snds_nodes = rename(snds_nodes, nb_vars = Freq)
## shrink the size of top patho for which there is only 16 variables + 150 tops 
snds_nodes[snds_nodes$name=="CT_IND_AAAA_GN", "nb_vars"] = snds_nodes[snds_nodes$name=="CT_IND_AAAA_GN", "nb_vars"] / 10
snds_nodes[snds_nodes$name=="CT_DEP_AAAA_GN", "nb_vars"] = snds_nodes[snds_nodes$name=="CT_DEP_AAAA_GN", "nb_vars"] / 5
## Control node size
snds_nodes = snds_nodes %>% mutate(nb_vars = nb_vars/3)

# Sort to have the same order as in the links (important)
snds_nodes = snds_nodes[with(snds_nodes, order(index)),]

# Function to create links
build_links = function(table_name, # nom de la table à lier
                       joint_var, # nom de la variable liante
                       joint_var2write, # affichage de la variable liante (souvent il faut concatener 2 variables)
                       targets = NULL, # cibles explicites
                       excluded_tables = c(), # tables à ne pas lier
                       vars_table = snds_vars, # table des variables (par défaut snds_vars)
                       nodes_table = snds_nodes, # tables des noeuds (par défaut snds_nodes)
                       group = 1){
  if (is.null(targets)){
    targets =  vars_table[vars_table$var %in% joint_var,]$table
    targets = targets[!targets %in% table_name]
    targets = unique(targets)
  }
  # exclusion 
  targets = targets[!targets %in% excluded_tables]
  targets_ix = c()
  # check in node tables the link to build 
  for (l in targets){
    targets_ix = append(targets_ix, nodes_table[nodes_table$name == l,"index"])
  }
  ref_links =  data.frame("source" = rep(nodes_table[nodes_table$name == table_name,"index"], length(targets)),
                          "target" = targets_ix)
  ref_links$group = rep(group, nrow(ref_links))
  ref_links$joint_var = rep(joint_var2write, nrow(ref_links))
  return (ref_links)
}

# Create tables_links for snds
## DCIRS LINKS
dcirs_main_links = build_links("NS_PRS_F", "CLE_DCI_JNT", "CLE_DCI_JNT")
## DCIR LINKS
joint_vars = c("FLX_DIS_DTD", "FLX_TRT_DTD", "FLX_EMT_TYP", "FLX_EMT_NUM", "FLX_EMT_ORD", "ORG_CLE_NUM", "DCT_ORD_NUM", "PRS_ORD_NUM", "REM_TYP_AFF")
dcir_main_links = build_links("ER_PRS_F", joint_vars, "9 clés de jointure", 
                              excluded_tables = c("NS_BIO_F", "NS_CAM_F", "NS_DTR_F", "NS_TRS_F", "NS_INV_F", "NS_RAT_F", "NS_PHA_F", "NS_UCD_F", "NS_TIP_F"))

# DCIR/DCIRS Links
dcir_irbenr_links = build_links("IR_BEN_R", "BEN_NIR_PSA", "BEN_NIR_PSA||BEN_RNG_GEM")
dcirs_iribar_links = build_links("IR_IBA_R", "BEN_IDT_ANO", "BEN_IDT_ANO")
dcir_daprar_links = build_links("DA_PRA_R", c("PFS_EXE_NUM", "PFS_PRE_NUM"), "PFS_EXE_NUM / PFS_PRE_NUM / PRS_MTT_NUM = PFS_PFS_NUM")
dcir_irimbr_links = build_links("IR_IMB_R",  "BEN_NIR_PSA", "BEN_NIR_PSA||BEN_RNG_GEM")
dcir_iracsr_links = build_links("IR_ACS_R",  "BEN_NIR_PSA", "BEN_NIR_PSA||BEN_RNG_GEM")
dcir_irorcr_links = build_links("IR_ORC_R",  "BEN_NIR_PSA", "BEN_NIR_PSA||BEN_RNG_GEM")
dcir_iretmr_links = build_links("IR_ETM_R",  "BEN_NIR_PSA", "BEN_NIR_PSA||BEN_RNG_GEM")
dcir_irmatr_links = build_links("IR_MAT_R",  "BEN_NIR_PSA", "BEN_NIR_PSA||BEN_RNG_GEM")
dcir_irmttr_links = build_links("IR_MTT_R",  "BEN_NIR_PSA", "BEN_NIR_PSA||BEN_RNG_GEM")

## Carto pathologies
dcirs_kicci_links = build_links("KI_CCI_R", "BEN_IDT_ANO", "BEN_IDT_ANO")
dcirs_kiecd_links = build_links("KI_ECD_R", "BEN_IDT_ANO", "BEN_IDT_ANO")

## Identifiants cartographie 
dcir_patho_links = rbind(build_links("CT_IDE_AAAA_GN", "BEN_NIR_PSA", "BEN_NIR_PSA||BEN_RNG_GEM"),
                     build_links("CT_IND_AAAA_GN", "id_carto", "id_carto"),
                     build_links("CT_DEP_AAAA_GN", "id_carto", "id_carto"))

## Concatenate to obtain a link table for dcir
sniiram_links = rbind(dcir_main_links, 
                   dcirs_main_links,
                   # DCIR/DCIRS
                   dcir_irbenr_links, 
                   dcirs_iribar_links,
                   dcir_daprar_links, 
                   dcir_irimbr_links,
                   dcir_iracsr_links,
                   dcir_irorcr_links,
                   dcir_iretmr_links,
                   dcir_irmatr_links,
                   dcir_irmttr_links,
                   # CEPIDC
                   dcirs_kicci_links,
                   dcirs_kiecd_links,
                   # Carto pathologies
                   dcir_patho_links
                   )


# PMSI MCO LINKS
## Patterns to search in the links and simplify code for each product (useless)
#pattern = c("aa_nnA", "aa_nnB", "aa_nnD", "aa_nnE", "aa_nnUM", "aa_nnVALO")

mco_main_links = build_links("T_MCOaa_nnC", "BEN_NIR_PSA", "NIR_ANO_17 = BEN_NIR_PSA", 
                             exclude = c("IR_ETM_R", "IR_MTT_R", "IR_ORC_R", "IR_MAT_R", "IR_ACS_R", "IR_IMB_R"))
mco_sec_links = build_links("T_MCOaa_nnC", "ETA_NUM", "ETA_NUM||RSA_NUM", 
                                 targets = snds_nodes$name[grepl("T_MCO", snds_nodes$name)])

ssr_main_links = build_links("T_SSRaa_nnC", "BEN_NIR_PSA", "NIR_ANO_17 = BEN_NIR_PSA", 
                             exclude = c("IR_ETM_R", "IR_MTT_R", "IR_ORC_R", "IR_MAT_R", "IR_ACS_R", "IR_IMB_R"))
ssr_sec_links = build_links("T_SSRaa_nnC", "ETA_NUM", "ETA_NUM||RSA_NUM", 
                                 targets =snds_nodes$name[grepl("T_SSR", snds_nodes$name)])

pattern_had = c("aa_nnA", "aa_nnB", "aa_nnD", "aa_nnE")
had_main_links = build_links("T_HADaa_nnC", "BEN_NIR_PSA", "NIR_ANO_17 = BEN_NIR_PSA", 
                             exclude = c("IR_ETM_R", "IR_MTT_R", "IR_ORC_R", "IR_MAT_R", "IR_ACS_R", "IR_IMB_R"))
had_sec_links = build_links("T_HADaa_nnC", "ETA_NUM_EPMSI", "ETA_NUM_EPMSI||RHAD_NUM", 
                                 targets = snds_nodes$name[grepl("T_HAD", snds_nodes$name)])


rip_main_links = build_links("T_RIPaa_nnC", "BEN_NIR_PSA", "NIR_ANO_17 = BEN_NIR_PSA", 
                             exclude = c("IR_ETM_R", "IR_MTT_R", "IR_ORC_R", "IR_MAT_R", "IR_ACS_R", "IR_IMB_R"))
rip_sec_links = build_links("T_RIPaa_nnC", "ETA_NUM_EPMSI", "ETA_NUM_EPMSI||RIP_NUM", 
                                 targets =snds_nodes$name[grepl("T_RIP", snds_nodes$name)])

pmsi_links = rbind(mco_main_links, mco_sec_links,
                   ssr_main_links, ssr_sec_links,
                   had_main_links, had_sec_links,
                   rip_main_links, rip_sec_links
             )

## Merge all links
snds_links = rbind(sniiram_links, pmsi_links)


# Save tables 
path2produits = "../tables_produits/"
path2app_data = "../app/app_data/"

write.csv(snds_nodes, paste0(path2app_data, "snds_nodes.csv"), row.names = F, fileEncoding = "UTF-8")
write.csv(snds_links, file = paste0(path2app_data, "snds_links.csv"), row.names = F, fileEncoding = "UTF-8")

write.csv(snds_nodes, paste0(path2produits, "snds_nodes.csv"), row.names = F, fileEncoding = "UTF-8")
write.csv(snds_links, file = paste0(path2produits, "snds_links.csv"), row.names = F, fileEncoding = "UTF-8")

# Test network outside shiny app 
library(networkD3)
#data("MisLinks")
#data("MisNodes")
groups
ColourScale <- 'd3.scaleOrdinal()
            .domain(["BENEFICIAIRE", "DCIR/DCIRS", "DCIRS", "DCIR", "Causes de décès", "CARTOGRAPHIE_PATHOLOGIES", "PMSI MCO", "PMSI HAD", "PMSI SSR", "PMSI RIM-P"])
           .range(["#CC2920", "#F36C64", "#E88310", "#E85B10", "#3C3C42", "#BB5DD1", "#3E5D96", "#8CD6E8", "#2A9BA5", "#26A589"]);'

MyClickScript = 'd.description +" "+d.name'
f = forceNetwork(Links = snds_links, Nodes = snds_nodes,
                 Source = "source", Target = "target",
                 #Value = "value",
                 Group = "group", Nodesize = "nb_vars", colourScale = JS(ColourScale), 
                 NodeID = "name", opacity = 1, fontSize = 20, zoom = TRUE,  clickAction = MyClickScript, charge = -50)

f
