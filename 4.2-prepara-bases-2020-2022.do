*------------------------------------------------
* Preparar bases por combustible 
*saco una base por combustible y comprador 
*------------------------------------------------
cd `cd' 

*use "bases\base-precios\p_eess_coordenadas_2020_2022.dta", clear 

*me quedo solo con las EESS:


/*          tipo_negocio |      Freq.     Percent        Cum.
------------------------+-----------------------------------
           Distribuidor |      9,672        1.60        1.60
  EstaciÃ³n de servicio |    587,771       97.23       98.83
                  Otros |      7,066        1.17      100.00
------------------------+-----------------------------------
                  Total |    604,509      100.00

 */
 
/* replace tipo_negocio = "Estacion de servicio" if tipo_negocio=="EstaciÃ³n de servicio"
keep if tipo_negocio=="Estacion de servicio" 
 */

*tipos de producto:
/*                          producto|      Freq.     Percent        Cum.
------------------------------------+-----------------------------------
                               GLPA |        101        0.02        0.02
                                GNC |     55,410        9.17        9.18
                    Gas Oil Grado 2 |    154,370       25.54       34.72
                    Gas Oil Grado 3 |    134,074       22.18       56.90
                           Kerosene |      6,016        1.00       57.89
                                N/D |      4,753        0.79       58.68
        Nafta (comÃºn) hasta 92 Ron |        244        0.04       58.72
  Nafta (premium) de mÃ¡s de 95 Ron |    119,280       19.73       78.45
   Nafta (sÃºper) entre 92 y 95 Ron |    130,261       21.55      100.00
------------------------------------+-----------------------------------
                              Total |    604,509      100.00

*GLPA: Gas Licuado de Petróleo para Automotor. Es un combustible limpio mas nuevo. 

*GNC: mayormente venta al publico. Muy pocas obs de industria. 

*GASOIL grado 2: el agro y transporte de carga compra mas este q el gasoil grado 3. 
 */
 



/* *variable de combustibles:	 
 gen combustible = ""
replace combustible ="gasoil_2"    if producto == "Gas Oil Grado 2"
replace combustible ="gasoil_3"    if producto == "Gas Oil Grado 3"
replace combustible ="gnc"         if producto == "GNC"
replace combustible ="nafta_1"     if producto == "Nafta (comÃºn) hasta 92 Ron"
replace combustible ="nafta_2"     if producto == "Nafta (sÃºper) entre 92 y 95 Ron"
replace combustible ="nafta_3"     if producto == "Nafta (premium) de mÃ¡s de 95 Ron"
replace combustible ="kerosene"    if producto == "Kerosene"
replace combustible="glpa"  	   if producto== "GLPA"

drop if producto=="N/D" 
drop if combustible=="nafta_1"
 */
 
*canal de comercializacion:

 /*            canal_de_comercializacion |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                   Agro |     25,617        4.24        4.24
                            Al pÃºblico |    521,631       86.29       90.53
                                    N/D |      4,753        0.79       91.31
                         Otros sectores |     15,935        2.64       93.95
 Reventa a otras estaciones de servicio |      6,759        1.12       95.07
                   Transporte de cargas |     23,738        3.93       98.99
       Transporte pÃºblico de pasajeros |      5,920        0.98       99.97
VehÃ­culos con placa identificatoria .. |        156        0.03      100.00
----------------------------------------+-----------------------------------
                                  Total |    604,509      100.00 */
 
/* drop if canal_de_comercializacion=="N/D"
 
gen comprador = ""
replace comprador = "agro"            if canal_de_comercializacion=="Agro"
replace comprador = "al_publico"      if canal_de_comercializacion=="Al pÃºblico"
replace comprador = "otras_eess"      if canal_de_comercializacion=="Reventa a otras estaciones de servicio"
replace comprador = "otros_sectores" if canal_de_comercializacion=="Otros sectores"
replace comprador = "transporte"      if (canal_de_comercializacion=="Transporte de cargas" | canal_de_comercializacion=="Transporte pÃºblico de pasajeros")
replace comprador = "extranjeros"     if canal_de_comercializacion=="VehÃ­culos con placa identificatoria extranjera"
  */
*variable de tiempo: 
/* gen aux = mdy(mes,1,year) 
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
local clientes "agro al_publico otras_eess otros_sectores transporte extranjeros"  */

/* 
*bases x combustible: 
foreach k of local combustibles {
  	display "k :  `k'" 
     preserve 
	keep if combustible == "`k'"
	save "bases\bases precios para pulir\temporal_`k'", replace 	
	restore 
}


*bases por comprador: 
 foreach k of local combustibles{ 
	display " k : `k' " 
	use "bases\bases precios para pulir\temporal_`k'" , clear 
	
	foreach m of local clientes { 
			display "m: `m'" 
			preserve 
			keep if comprador == "`m'" 
			save "bases\bases precios para pulir\pulir_`k'_`m'", replace 
			restore 				
		}
	erase "bases\bases precios para pulir\temporal_`k'.dta"
}	
 */



*****************************************************************************
*- pulicion de las bases -no lo use al final 29-11-2022-
*****************************************************************************
/* foreach k of local combustibles { 
		foreach m of local clientes{
			use "bases\bases precios para pulir\pulir_`k'_`m'", clear
			
			*male trabajar sobre estos dofiles ahora:	
		
			do dofiles\pulicion\pulicion_`k'_`m'.do
			save "bases\bases precios para pulir\bases pulidas\p_`k'_`m'", replace 
			}
}


 */
 
 





