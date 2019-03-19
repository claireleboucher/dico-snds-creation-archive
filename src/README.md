# Codes sources

Ce dossier contient les codes nécessaires afin de convertir les tables de valeurs de la CNAM en un format exploitable par une application tierce.

## Consultation du dictionnaire

Le dictionnaire et la visualisation sont disponibles à [cette adresse](https://drees.shinyapps.io/dico-snds).

## Fichiers

+ [programme_extraction.sas](src/programme_extraction.sas) : Permet d'exporter les référentiels de valeurs disponibles dans le répertoire ORAVAL sur le portail SNDS de la CNAM

+ [build_dico_variables.R](src/build_dico_variables.R): Construit les fichiers nécessaires au dictionnaire interactif (correspondances tables-variables). Ce script construit pour les différents produits du SNDS (DCIR, DCIRS, CEPIDC, PMSI) la table suivante [`snds_vars.csv`](tables_produits/snds_vars):

|table|var|format|description|nomenclature|
|-------|-------|-------|-------|-------|
|ER_PRS_F|BEN_AMA_COD|Numérique (4)|Age du beneficiaire en mois (< 2 ans) ou annees (>= 2 ans)|IR_AMA_V|
|ER_PRS_F|BEN_CDI_NIR|Caractère (2)|Code identification du NIR|IR_NIR_V|
|...|...|...|...|...|


+ [network_build.R](src/network_build.R): Construit les fichiers nécessaires à la visualisation du schéma du SNDS. Ce code R produit une table `snds_nodes.csv` et une table `snds_links.csv` permettant d'afficher un graph de la structure du SNDS (avec l'outil [networkd3](https://christophergandrud.github.io/networkD3/)). Ces deux tables sont sauvées dans le dossier [app](app) et le dossier [tables_produits](tables_produits).

+ [parse_dcir.R](src/parse_dcir.R): Extrait la liste des variables du DCIR depuis le fichier brut de présentation des tables (Nécessaire pour build_dico_variables.R).

## Utilisation

Afin de reproduire la construction des fichiers d'entrées de notre application shiny, reproduire les étapes suivantes:

1 - Cloner ce repository sur votre poste.

2 - Exécuter dans cet ordrer les scripts R présents dans *build_dico_variables_build.R* et *network_build.R*. Ceux-ci vont chercher les informations dans les tables brutes et délivre des résultats dans [tables_produits](tables_produits) et [app_data](app/app_data)

3 - Lancer l'application en executant dans Rstudio [ui.R](app/ui.R) ou [server.R](app/server.R)
