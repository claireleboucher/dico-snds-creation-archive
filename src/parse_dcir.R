library(dplyr)
library(data.table)

find_colnames = function(df, search4){
  for (i in 1:nrow(df)){
    for (j in 1: ncol(df)){
      if( grepl(search4, df[i, j])){
        return(i)
      }
    }
  }
}

# test purpose only
path2dcir = paste0(path2variables_brutes,"DCIR - liste des tables et variables.xls")
  
parseDcir = function(path2dcir){
  dcir_tables = list()
  for (i in 1:16){
    df = readxl::read_xls(path2dcir, sheet = i, skip = 0, col_names = F)
    reg = regexpr("\\w\\w_\\w\\w\\w_\\w", df[1,1])
    if (reg !=-1){
      table_name = gsub("\\n", "", substr(df[1,1], reg, reg + attr(reg, "match.length")))
      print(table_name)
      
      col_line = find_colnames(df, "^VARIABLE$")
      colnames(df) = df[col_line, ]
      df = df[(col_line+1):nrow(df), c("VARIABLE", "LIBELLE", "FORMAT", "VALEURS")]
      # select relevant columns
      colnames(df) = c("var", "description", "format", "nomenclature")
      df$table = rep(table_name, nrow(df))
      dcir_tables[[table_name]] = df %>% select(c("table","var","format",  "description", "nomenclature"))
    }
  }
  
  ## add join variables to the affiliated tables
  joint_keys = c("FLX_DIS_DTD", 
                 "FLX_TRT_DTD", 
                 "FLX_EMT_TYP", 
                 "FLX_EMT_NUM", 
                 "FLX_EMT_ORD", 
                 "ORG_CLE_NUM", 
                 "DCT_ORD_NUM",
                 "PRS_ORD_NUM", 
                 "REM_TYP_AFF")
  
  for (df_name in names(dcir_tables)[2:16]){
    joint_vars =  dcir_tables$ER_PRS_F %>% filter(var %in% joint_keys)
    joint_vars$table = rep(df_name, nrow(joint_vars))
    dcir_tables[[df_name]] = rbind(dcir_tables[[df_name]], joint_vars)
  }
  
  # correct er_cam_f because there are two blank lines in the orginal xlsx
  dcir_tables$ER_CAM_F = dcir_tables$ER_CAM_F %>% filter_all(all_vars(!is.na(.)))
  
  # create final table
  dcirs_vars <- data.frame()
  for (i in dcir_tables){
    dcirs_vars <- rbind(dcirs_vars, i)
  }
  
  # Reformat nomenclature column to change to "-" normalized symbol if no nomenclature is provided
  dcirs_vars = dcirs_vars %>% mutate(nomenclature = replace(nomenclature, !grepl("^IR_", nomenclature), "-"))
  return(dcirs_vars)
}


#DCIR_vars = parseDcir(path2dcir)
#write.csv(DCIR_vars, "data/DCIR_variables.csv", row.names = F)
#DT::datatable(DCIR_vars)
