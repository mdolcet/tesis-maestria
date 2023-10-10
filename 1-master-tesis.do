clear all
set more off

*cd viejo
*local cd "G:\Mi unidad\Malena\FCE\Maestria\Tesis-v2"

*cd nuevo 
local cd "X:\Mi unidad\Maestria en economia\Tesis-v2"
cd "`cd'"



*-----------------------------------------------------------
* [2] Brecha cambiaria + Calidad data + Precios en la region
*-----------------------------------------------------------
*do dofiles\2-tc.do                  // Importar bases del tc (oficial + blue), figuras de la brecha 
*do dofiles\2.1-calidad-data.do      // Figura calidad de la data 
*do dofiles\figuras-lac.do            // Figuras de Precios LAC

*------------------------------------------------
* [3] Importar bases de combustibles 2020-2022 
*------------------------------------------------
*do dofiles\3-importar.do       // matchear coordenadas 

*------------------------------------------------
* [4.1] Preparar bases x tipo de combustible para pulirlas y comprador 
*------------------------------------------------
*do dofiles\4.1-prepara-bases-2005-2019.do     // 2005-2019
*do dofiles\4.2-prepara-bases-2020-2022.do     // 2020-2022

*------------------------------------------------
* [aux] Pulicion x tipo de combustible y comprador 2020-2022 
*NOTA: despues de pulir correr el dofile [4] para armar los paneles 
*------------------------------------------------
*ir corriendo de aca antes de correr el prepara base:

*NAFTA 2 2020-2022 - DONE 
*do dofiles\pulicion\pulicion_nafta_2_agro.do            
*do dofiles\pulicion\pulicion_nafta_2_al_publico.do 
*do dofiles\pulicion\pulicion_nafta_2_extranjeros.do 
*do dofiles\pulicion\pulicion_nafta_2_transporte.do 
*do dofiles\pulicion\pulicion_nafta_2_otras_eess.do 
*do dofiles\pulicion\pulicion_nafta_2_otros_sectores.do 


*NAFTA 2 - 2005-2019 -DONE 
*do dofiles\pulicion\0519\pulicion_nafta_2_agro_05_19.do             
*do dofiles\pulicion\0519\pulicion_nafta_2_otros_sectores_05_19.do
*do dofiles\pulicion\0519\pulicion_nafta_2_al_publico_05_19.do
*do dofiles\pulicion\0519\pulicion_nafta_2_extranjeros_05_19.do
*do dofiles\pulicion\0519\pulicion_nafta_2_otras_eess_05_19.do
*do dofiles\pulicion\0519\pulicion_nafta_2_transporte_05_19.do


*do dofiles\pulicion\pulicion_nafta_3_al_publico.do   // Nafta 3
*do dofiles\pulicion\pulicion_gasoil_2_al_publico.do  // Gasoil2  2020-2022



*------------------------------------------------
* [4.3] Armado de bases finales por combustible (ya pulidas)  
*------------------------------------------------

*do dofiles\4.3-prepara-bases-pulidas.do // une las bases pulidas de distintos compradores (publico,agro, ind, transp)

*------------------------------------------------
* [5.1] Pulicion panel 
*------------------------------------------------
*do dofiles\5.1-prepara-panel.do     // Panel Nafta 2 (calcula dist lineales)
*do dofiles\5.2-prepara-panel.do    // Panel Gasoil 2 (calcula dist lineales)
*do dofiles\5.3-prepara-panel.do     // Panel Nafta 3 (calcula dist lineal -tomando la base q ya tiene la dist x ruta y en mins)
*-----------------------------------------------
* [10] Distancias x ruta y en minutos 
*-----------------------------------------------
*do dofiles\prepara-mapa-osm.do                    // Prepara el mapa de ARG
*do dofiles\prepara-combustible-pre-distancias.do  // Prepara bases de corte transversal para calcular distancias
*do dofiles\distancias-EESS-frontera.do            // Calcular distancias por RUTA y en SEGUNDOS


*------------------------------------------------
* [6] Graficos nafta2  
*------------------------------------------------
*do dofiles\6-figuras-0-nafta.do 
*do dofiles\7-figuras-1-nafta.do 
*do dofiles\9-figuras-2-nafta.do       // este dofile arma el graph de P, tc oficial y tc blue 
*do dofiles\9-figuras-3-nafta.do     // volumenes 
*do dofiles\10-figuras-4-nafta.do     // volumenes por paso fronterizo (out)


*------------------------------------------------
* [8] Graficos  gasoil2  
*------------------------------------------------
*do dofiles\8-figuras-0-gasoil.do 
*do dofiles\11-figuras-1-gasoil.do // este dofile arma el graph de P, tc oficial y tc blue 
*do dofiles\graficos-provincias.do  // prueba de figuras por provincias -18ene2023-

*-----------------------------------------------
* [9] Estimaciones 
*-----------------------------------------------

*------------*
*NAFTA SUPER:
*------------*
*do dofiles\9-reg-v0.do          //viejo -no usar ene23- 
*do dofiles\12-reg-nafta-v0.do   // did estatico
*do dofiles\12-reg-nafta-v1.do   // aca esta el graph de los mkt share - usar este 8marzo-2023


*------------*
*GASOIL:
*------------*
*did estatico:
*do dofiles\12-reg-gasoil-v0.do
*do dofiles\12-reg-gasoil-v1.do // aca esta el graph de los mkt share  -usar este 8-marzo-2023-



*-------------*
*NAFTA PREMIUM:
*-------------* 
*do dofiles\12-reg-nafta3-v0.do // usar este 8-marzo-2023



****************************
*-FIGURAS 
*****************************
*do dofiles\13-graph-diff-coef.do     // GRAPH TODOS LOS COEF DE LA TESIS: 3 COMBUSTIBLES, 3 MEDIDAS DE DISTANCIA
*do dofiles\14-robustness-treat.do    // GRAPH COEF MOVIENDO AL GRUPO TRATAMIENTO  
do dofiles\15-robustness-pasos.do   //GRAPH COEF ESTIMADO SACANDO DE A 1 PASO FRONTERIZO 

*GRAPH EXPLORANDO CIUDADES TUR Y NO TUR 






*Did con precios como outcome: 
*do dofiles\12-reg-nafta-v2-prices.do
*do dofiles\tablas-jmp.do 












