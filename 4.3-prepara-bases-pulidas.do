 *------------------------------------------------
* UNO BASES PULIDAS 
*------------------------------------------------
cd `cd' 


************************************************************
*- uno bases x combustible ya pulidas de duplicados y seteadas en panel 
*en estos merge abrir siempre al publico y pegarle el resto. 
*las q matchea son EESS que venden a mas de un cliente ok 
***********************************************************

/* 

*-------------------
*NAFTA 2 - 2020-2022  
*-------------------

use "bases\base-precios\p-pulidas\nafta2\nafta_2_al_publico", clear 



merge m:m codigo_unico_de_coordenadas mes year using "bases\base-precios\p-pulidas\nafta2\nafta_2_extranjeros", gen(m_ext)
merge m:m codigo_unico_de_coordenadas mes year using "bases\base-precios\p-pulidas\nafta2\nafta_2_transporte", gen(m_transp)
merge m:m codigo_unico_de_coordenadas mes year using "bases\base-precios\p-pulidas\nafta2\nafta_2_agro", gen(m_agro)
merge m:m codigo_unico_de_coordenadas mes year using "bases\base-precios\p-pulidas\nafta2\nafta_2_otras_eess", gen(m_eess)
merge m:m codigo_unico_de_coordenadas mes year using "bases\base-precios\p-pulidas\nafta2\nafta_2_otros_sectores", gen(m_sect)

tsset id time 

save "bases\base-precios\p-pulidas\nafta2\nafta_2_2020_2022", replace



*-----------------------
*NAFTA 2 - 2005-2019
*-----------------------
use "bases\base-precios\p-pulidas\nafta2\nafta_2_al_publico_05_19", clear

merge m:m codigo_unico_de_coordenadas mes anio using "bases\base-precios\p-pulidas\nafta2\nafta_2_extranjeros_05_19", gen(m_ext0519)
merge m:m codigo_unico_de_coordenadas mes anio using "bases\base-precios\p-pulidas\nafta2\nafta_2_transporte_05_19", gen(m_transp0519)
merge m:m codigo_unico_de_coordenadas mes anio using "bases\base-precios\p-pulidas\nafta2\nafta_2_agro_05_19", gen(m_agro0519)
merge m:m codigo_unico_de_coordenadas mes anio using "bases\base-precios\p-pulidas\nafta2\nafta_2_otras_eess_05_19", gen(m_eess0519)
merge m:m codigo_unico_de_coordenadas mes anio using "bases\base-precios\p-pulidas\nafta2\nafta_2_otros_sectores_05_19", gen(m_sect0519)


rename anio year 

*controlo duplicados
 bysort id time: gen duplicado = _n
 ta duplicado 
 
/*   duplicado |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |    162,394      100.00      100.00
          2 |          1        0.00      100.00
------------+-----------------------------------
      Total |    162,395      100.00 */



drop if duplicado==2 
drop duplicado 
 
tsset id time
save "bases\base-precios\p-pulidas\nafta2\nafta_2_2005_2019", replace



*------------------------------
*BASE FINAL NAFTA 2 - 2005-2022
*------------------------------

use "bases\base-precios\p-pulidas\nafta2\nafta_2_2005_2019", clear 

merge m:m codigo_unico_de_coordenadas mes year using "bases\base-precios\p-pulidas\nafta2\nafta_2_2020_2022", gen(m_years) 

*panelvar; timevar:
tsset id time 
*guardo base para pulir el panel NAFTA 2 
save "bases\base-precios\p-pulidas\nafta2\nafta_2_2005_2022_aux", replace 




 */
 
 
*------------------------------
*BASE FINAL GASOIL 2 - 2005-2022
*------------------------------
use "bases\base-precios\p-pulidas\gasoil2\combustible-gasoil2_v2_05_19", clear 
rename anio year 

merge m:m codigo_unico_de_coordenadas mes year using "bases\base-precios\p-pulidas\gasoil2\gasoil2_20_22", gen(m_panel)

*guardo el panel completo
save "bases\base-precios\p-pulidas\gasoil2\gasoil2_2005_2022_aux", replace 


*guardo el panel desde 2016 
preserve
drop if year<2016 
save "bases\base-precios\p-pulidas\gasoil2\gasoil2_2016_2022_aux", replace 
restore 





