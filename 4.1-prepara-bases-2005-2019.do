*------------------------------------------------
* Preparar bases por combustible 2005-2019
*saco una base por combustible y comprador 
*------------------------------------------------

use "G:\Mi unidad\Malena\FCE\Maestria\Tesis\bases\base-precios\precios_eess_con_coordenadas" , clear 

keep if merge_coord_nuevas==3 

ta tipo_negocio

/*          tipo_negocio |      Freq.     Percent        Cum.
----------------------+-----------------------------------
         Distribuidor |     92,521        2.30        2.30
 Estación de servicio |  3,865,683       95.89       98.19
                Otros |     73,001        1.81      100.00
----------------------+-----------------------------------
                Total |  4,031,205      100.00
 */
 
 
keep if tipo_negocio=="Estación de servicio" 

 

/*                          producto |      Freq.     Percent        Cum.
----------------------------------+-----------------------------------
                        Biodiesel |        661        0.02        0.02
                             GLPA |        407        0.01        0.03
                              GNC |    336,868        8.36        8.38
                  Gas Oil Grado 1 |      7,007        0.17        8.56
                  Gas Oil Grado 2 |  1,067,720       26.49       35.04
                 Gas Oil Grado 2B |     96,371        2.39       37.43
                  Gas Oil Grado 3 |    545,949       13.54       50.98
                         Kerosene |    124,658        3.09       54.07
                              N/D |     33,255        0.82       54.89
       Nafta (común) hasta 92 Ron |    215,987        5.36       60.25
 Nafta (premium) de más de 95 Ron |    733,693       18.20       78.45
  Nafta (súper) entre 92 y 95 Ron |    868,629       21.55      100.00
----------------------------------+-----------------------------------
                            Total |  4,031,205      100.00

*GLPA: Gas Licuado de Petróleo para Automotor. Es un combustible limpio mas nuevo. 

*GNC: mayormente venta al publico. Muy pocas obs de industria. 

*GASOIL grado 2: el agro y transporte de carga compra mas este q el gasoil grado 3. 	
  */
 



 *variable de combustibles:	 
gen combustible = ""
replace combustible ="gasoil_2"    if producto == "Gas Oil Grado 2"
replace combustible ="gasoil_3"    if producto == "Gas Oil Grado 3"
replace combustible ="gnc"         if producto == "GNC"
replace combustible ="nafta_1"     if producto == "Nafta (común) hasta 92 Ron"
replace combustible ="nafta_2"     if producto == "Nafta (súper) entre 92 y 95 Ron"
replace combustible ="nafta_3"     if producto == "Nafta (premium) de más de 95 Ron"
replace combustible ="kerosene"    if producto == "Kerosene"
replace combustible="glpa"  	   if producto== "GLPA"

drop if producto=="N/D" 
drop if combustible=="nafta_1"

 tab canal_de_comercializacion

/*               canal_de_comercializacion |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                   Agro |    189,866        4.71        4.71
                             Al público |  3,422,379       84.90       89.61
                                    N/D |     33,255        0.82       90.43
                         Otros sectores |    108,444        2.69       93.12
 Reventa a otras estaciones de servicio |     63,630        1.58       94.70
                   Transporte de cargas |    175,165        4.35       99.05
        Transporte público de pasajeros |     34,762        0.86       99.91
Vehículos con placa identificatoria e.. |      3,704        0.09      100.00
----------------------------------------+-----------------------------------
                                  Total |  4,031,205      100.00
								  
							  
 */
 
gen comprador = ""
replace comprador = "agro"            if canal_de_comercializacion=="Agro"
replace comprador = "al_publico"      if canal_de_comercializacion=="Al público"
replace comprador = "otras_eess"      if canal_de_comercializacion=="Reventa a otras estaciones de servicio"
replace comprador = "otros_sectores" if canal_de_comercializacion=="Otros sectores"
replace comprador = "transporte"      if (canal_de_comercializacion=="Transporte de cargas" | canal_de_comercializacion=="Transporte público de pasajeros")
replace comprador = "extranjeros"     if canal_de_comercializacion=="Vehículos con placa identificatoria extranjera"
 
*variable de tiempo: 
gen aux = mdy(mes,1,anio) 
gen time = mofd(aux) 
format time %tm
drop aux  

*Armo id para cada EESS con las coordenadas 
gen codigo1 = _Y 
tostring codigo1, replace 
gen codigo2 = _X
tostring codigo2, replace 
gen puntocoma= ";"
egen codigo_unico_de_coordenadas= concat( codigo1 puntocoma codigo2) 

drop codigo1 codigo2 puntocoma

sort codigo_unico_de_coordenadas time 
encode codigo_unico_de_coordenadas, g(id) 

*Renombro variables de precios 
rename precio_sin_impuestos p_no_tax 
rename precio_con_impuestos p_tax
rename precio_surtidor      p_surtidor

*Saco una base x combustible y x tipo de comprador 
local combustibles "gasoil_2 gasoil_3 nafta_2 nafta_3" 
local clientes "agro al_publico otras_eess otros_sectores transporte extranjeros" 


*bases x combustible: 
foreach k of local combustibles {
  	display "k :  `k'" 
     preserve 
	keep if combustible == "`k'"
	save "G:\Mi unidad\Malena\FCE\Maestria\Tesis-v2\bases\bases precios para pulir 2004-2019\temporal_`k'", replace 	
	restore 
}
 

*bases por comprador: 
foreach k of local combustibles{ 
	display " k : `k' " 
	use "G:\Mi unidad\Malena\FCE\Maestria\Tesis-v2\bases\bases precios para pulir 2004-2019\temporal_`k'" , clear 
	
	foreach m of local clientes { 
			display "m: `m'" 
			preserve 
			keep if comprador == "`m'" 
			save "G:\Mi unidad\Malena\FCE\Maestria\Tesis-v2\bases\bases precios para pulir 2004-2019\pulir_`k'_`m'", replace 
			restore 				
		}
	
}	



 
 
 