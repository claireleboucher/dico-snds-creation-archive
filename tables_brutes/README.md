# Tables brutes

Ce dossier contient les tables brutes nécessaires afin de construire l'outil de visualisation. Cette documentation a été rendu possible grâce aux apports de la [Caisse Nationale d'Assurance Maladie (CNAM)](https://assurance-maladie.ameli.fr/)

## Description du contenu des fichiers

+ [nomenclatures](tables_brutes/nomenclatures) : Ce dossier contient toutes les tables de nomenclature (tables de référentiel) extraites depuis ORAVAL sur [le portail de la CNAM](https://www.snds.gouv.fr/SNDS/Plan-du-site).

+ [other_nomenclatures](tables_brutes/other_nomenclatures) : Ce dossier contient d'autres nomenclatures ajoutées à la main par des utilisateurs.

+ [variables_brutes](tables_brutes/variables_brutes) : Ce dossier contient toutes les sources dans lesquels nous sommes allés chercher les dictionnaires de variables pour les différents produits du SNDS et à partir desquels nous construisons `snds_vars.csv`.

+ [complement_var2refs.csv](tables_brutes/complement_var2ref.csv): Cette table contient des associations entre des variables et des nomenclatures ajoutées par les utilisateurs. Afin d'ajouter une correspondance variable<=>nomenclature, il suffit d'ajouter le nom de la nomenclature dans la colonne `ref_name` correspondant à la variable que l'on veut renseigner. La modification est ensuite prise en compte lorsqu'on lance le script [build_dico_variables.R](src/build_dico_variables.R):

|var_name|ref_name|comment|
|-------|-------|-------|
|ma_variable      |  IR_MA_VAR|mon commentaire pertinent|
