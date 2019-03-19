**ATTENTION: Le code contenu dans ce repo est froid, c'est une archive pour garder trace de la manière dont nous avons créé le [dico snds](https://github.com/indsante/dico-snds) initialement. Ce code est conservé uniquement pour information et ne sert plus à l'application.**

# Dictionnaire des variables

Ce repo contient un dictionnaire des variables du Système national de Données de Santé, dérivé des tables et de la documentation fournies par la Caisse Nationale d'Assurance Maladie sur le [portail SNDS](https://www.snds.gouv.fr/SNDS/).

Il est mis en forme, tenu à jour et commenté par des agents de l'INDS, de la DREES et des autres agences ministérielles en lien avec le SNDS.

# Usage

L'outil de travail pour visualiser les variables et leurs modalités est [disponible à cette adresse](https://drees.shinyapps.io/dico-snds/).

# Organisation du dossier

- [tables_brutes](tables_brutes) contient les tables de variables brutes ainsi que les informations ajoutées par les utilisateurs
- [tables_produits](tables_produits) contient les tables organisées tels qu'utilisées par l'outil de visualisation
- [src](src) contient les codes nécessaires afin de reproduire les tables produits notamment comment passer des tables brutes aux tables tables produits

# Participation à l'outil

Il est possible de participer à l'outil de différentes manières. Afin de rendre ces modifications effectives, il est nécessaire de faire tourner le fichier [`build_dico_variables.R`](src/build_dico_variables.R) qui prend en compte les modifications dans les différents fichiers et les applique pour la visualisation.

## Ajouter une nomenclature (table de référentiel)

S'il manque une nomenclature (table de réferentiel) ou qu'une nomenclature est incorrecte, on peut l'ajouter dans le dossier [other_nomenclatures](tables_brutes/other_nomenclatures/). Le nom du fichier doit respecter le format `IR_****.csv` et les champs doivent être séparés par un point virgule `;` (comma separated).

La table de nomenclature ajoutée doit au minimum avoir deux champs:

+ `VAR_CAT`, les modalités de la variable

+ `VAR_LIB`, les libellés de la variable

**Exemple:**

|VAR_CAT|VAR_LIB|
|-------|-------|
|0      | Jour  |
|1      | Nuit  |

Puis il est nécessaire de lier la varibale au réferentiel (cf. point suivant).

## Lier une variable à un référentiel
Si l'on veut renseigner qu'une variable possède une nomenclature déjà existante (ou que l'on vient d'ajouter dans [other_nomenclatures](tables_brutes/other_nomenclatures/)), il faut modifier le fichier [complement_var2refs.csv](tables_brutes/complement_var2ref.csv). Cette table contient des associations entre des variables et des nomenclatures ajoutées par les utilisateurs. Afin d'ajouter une correspondance variable<=>nomenclature, il suffit d'ajouter le nom de la nomenclature dans la colonne `ref_name` correspondant à la variable que l'on veut renseigner.

|var_name|ref_name|comment|
|-------|-------|-------|
|ma_variable      |  IR_MA_VAR|mon commentaire pertinent|

## Modifier des liens dans le graph (A venir).

## Contribuer à la documentation métier (A venir).
