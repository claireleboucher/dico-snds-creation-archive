/* Code d'extraction des référentiels de valeurs sur le portail SNDS*/

/* Extraction et stockage dans des macro-variables des noms de tables des référentiels présents dans la libraire ORAVAL */
PROC SQL;  CREATE TABLE nom_ref AS
	SELECT libname, memname
	FROM dictionary.tables
	WHERE upcase(libname)='ORAVAL' AND upcase(memtype)='DATA' ;
QUIT;

DATA _null_;
   SET nom_ref;
   cnt+1;
   CALL SYMPUT (cats('REF',put(cnt,best.)),memname);
RUN;
DATA _null_ ;
   CALL SYMPUTX('max_var',_N_-1);
   SET nom_ref;
RUN;

DATA referentiel_valeurs;
LENGTH  nom_table $30.;
RUN;

/* Création d'une macro pour rapatrier la table de valeurs sur la work */
%MACRO chargement_ref(nom_table);

PROC SQL; CREATE TABLE &nom_table. AS 
	SELECT "&nom_table." AS nom_table,*
	FROM ORAVAL.&nom_table.;
QUIT;

DATA referentiel_valeurs;
SET referentiel_valeurs &nom_table.;
RUN;
%MEND;

/* Macro réalisant une boucle sur l'ensemble des noms de référentiels et les ajoutant à une table diagonale référentiel_valeurs */
%MACRO boucle();
  %do i=1 %to &max_var.;
    %chargement_ref(&&REF&i.);
   %end;
%MEND;

OPTIONS MPRINT;
%boucle();

/* Découpe de la table diagonale des référentiels en deux sous-tables pour les référentiels IR (les plus utilisés) et les autres */
DATA referentiels_IR;
SET referentiel_valeurs;
WHERE nom_table LIKE "IR%";
RUN;

DATA referentiels_autres;
SET referentiel_valeurs;
WHERE nom_table NOT LIKE "IR%";
RUN;