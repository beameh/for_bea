-----------------------------------
-- Author:			Stefan Opitz
-- Create date: 	2012-10-09
-- Description:		UE2 Teil 1
-----------------------------------

use Fahrrad;


-- 1. In welcher Abteilung (können auch mehrere sein) sind die meisten Berufe 
--	  der Unternehmung vertreten?

SELECT abt.NAME AS Abt_Name, COUNT(distinct ang.BERUF) Anz_Berufe
	FROM ABTEILUNGEN abt 
	INNER JOIN ANGESTELLTE ang
	ON abt.ABT_NR=ang.ABT_NR
		GROUP BY abt.NAME
		ORDER BY Anz_Berufe desc;


---- 2.	Welcher Lieferant liefert alle Materialien?

SELECT lft.NAME, COUNT(tei.TNR) Materialien
	FROM LIEFERANTEN lft
	INNER JOIN LIEFERPROGRAMME lfp
	ON lft.LIEF_NR=lfp.LIEF_NR
	INNER JOIN TEILE tei
	ON lfp.TNR = tei.TNR
		WHERE tei.TYP = 'Material'
		GROUP BY lft.NAME
		HAVING COUNT(tei.TNR) = 
			(SELECT COUNT(tei.TNR) 
				FROM Teile tei
				WHERE tei.TYP = 'Material');


--3. Welche Angestellten verdienen mehr als der Durchschnitt aller Gehälter von 
--   Angestellten der gleichen Abteilung?

SELECT Nachname, ang1.ABT_NR, ang1.GEHALT, ang2.Durchschnittsgehalt
	FROM ANGESTELLTE ang1
	INNER JOIN (
		SELECT AVG(Gehalt) Durchschnittsgehalt, ABT_NR 
			FROM ANGESTELLTE 
			GROUP BY ABT_NR) ang2
	ON ang1.ABT_NR = ang2.ABT_NR
		WHERE ang1.Gehalt > ang2.Durchschnittsgehalt;


-- 4. Wer verdient mehr als irgendein Angestellter von Hrn. Schmidt? 

-- von welcher Abteilung ist Schmidt Abteilungsleiter?
SELECT abt.ABT_NR
	FROM ANGESTELLTE ang
	INNER JOIN ABTEILUNGEN abt
	ON ang.ABT_NR=abt.ABT_NR
		WHERE abt.LEITER = ang.ANG_NR AND ang.NACHNAME='Schmidt';

-- welche Angestellten hat Schmidt und wieviel verdienen diese?
SELECT Gehalt, NACHNAME
	FROM ANGESTELLTE
		WHERE ABT_NR = 
			(SELECT abt.ABT_NR
				FROM ANGESTELLTE ang
				INNER JOIN ABTEILUNGEN abt
				ON ang.ABT_NR=abt.ABT_NR
				WHERE abt.LEITER = ang.ANG_NR AND ang.NACHNAME='Schmidt') 
			AND Nachname!='Schmidt';

-- wer verdient mehr als der Angestellte Wahn
SELECT Nachname, Gehalt
	FROM ANGESTELLTE
	WHERE Gehalt > 
		(SELECT Gehalt
			FROM ANGESTELLTE
			WHERE ABT_NR = 
				(SELECT abt.ABT_NR
					FROM ANGESTELLTE ang
					INNER JOIN ABTEILUNGEN abt
					ON ang.ABT_NR=abt.ABT_NR
					WHERE abt.LEITER = ang.ANG_NR AND ang.NACHNAME='Schmidt') 
				AND NACHNAME = 'Wahn');


---- 5.	Welche Artikel sind in allen Lagern vorhanden? 

SELECT art.Bezeichnung
	FROM ARTIKEL art
	INNER JOIN LAGERBESTAND lgb
	ON art.TNR = lgb.TNR 
		WHERE lgb.BESTAND > 0
		GROUP BY art.BEZEICHNUNG
		HAVING COUNT(lgb.LANR) = 3;