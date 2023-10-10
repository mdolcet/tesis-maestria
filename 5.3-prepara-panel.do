*----------------------------------------------------------------------------------------------------
* Este dofile calcula la distancia LINEAL entre los pasos fronterizos y las EESS para la nafta premium
*NOTA: toma la base que ya tiene calculada las distancias por RUTA y MINUTOS porque fue la ult que arme 

*Toma la base que ya tenia distancias lineales viejas (52 pasos) + dist ruta y minutos de Nafta Super y
*Gasoil, y vuelve a calcular las distancias lineales con los 31 pasos fronterizos. 
*-----------------------------------------------------------------------------------------------------

set autotabgraph on 


*-----------------------------------------------------------------------------------------*
*-----------------------------------------------------------------------------------------*
*-NAFTA PREMIUM - CALCULO DE DISTANCIAS LINEALES CON 31 PASOS FRONTERIZOS (NO 52)
*-----------------------------------------------------------------------------------------*
/* 
use "bases\base-precios\p-pulidas-distancias\nafta_3_2016_2022_v2.dta", clear 

****************************
*USAR SOLO PASOS FRONTERIZOS LIMITADOS: 31
*X:\Mi unidad\Maestria en economia\Tesis-version vieja\raw-data\pasos fronterizos\pasos-fronterizos-finales

*etiquetas coordenadas eess 
label var _X "Longitud EE.SS"
label var _Y "Latitud EE.SS" 




*Creo variables con las coordenadas de los pasos 
forvalues a = 1/31 { 
	gen x_`a' = . 
	gen y_`a' = . 
	label var x_`a' "Latitud paso `a'"
	label var y_`a' "Longitud paso `a'" 
		}

		replace x_1 = -33.1114478	
		replace y_1 = -58.2460198
		replace x_2 = -32.26377376
		replace y_2 = -58.09786121
		replace x_3 = -31.2609222
		replace y_3 = -57.961622
		replace x_4 = -22.01436223
		replace y_4 = -63.68222836
		replace x_5 = -22.72620497
		replace y_5 = -64.36962899
		replace x_6 = -22.09672714
		replace y_6 = -65.59619637
		replace x_7 = -25.60106748	
		replace y_7 = -53.97057139
		replace x_8 = -25.6006454  	
		replace y_8 = -54.56112463
		replace x_9 = -29.73110932	
		replace y_9 = -57.11126655
		replace x_10 = -28.59117286
		replace y_10 = -56.03289063
		replace x_11 = -25.26475634	
		replace y_11 = -57.72759045
		replace x_12 = -25.28605686	
		replace y_12 = -57.70915988
		replace x_13 =	-27.37430302	
		replace y_13 = -55.88208906
		replace x_14 = -32.82543516	
		replace y_14 = -70.09213018
		replace x_15 = -30.19135328
		replace y_15 = -69.82563194
		replace x_16 = -40.6984364	    
		replace y_16 = -71.93376231
		replace x_17 = -39.78724569	
		replace y_17 = -71.6817892
		replace x_18 = -51.57445833	
		replace y_18 = -72.35013889
		replace x_19 = -52.13863902	
		replace y_19 = -69.51603956
		replace x_20 = -45.14033066
		replace y_20 = -71.33646004
		replace x_21 = -35.98585044	
		replace y_21 = -70.39111652
		replace x_22 = -37.44763756	
		replace y_22 = -71.11618237
		replace x_23 = -38.66065544	
		replace y_23 = -70.89879853
		replace x_24 = -27.9882992	
		replace y_24 = -69.32401697
		replace x_25 = -51.25899931	
		replace y_25 = -72.34407249
		replace x_26 = -44.5538149	
		replace y_26 = -71.09421421
		replace x_27 = -43.17369427	
		replace y_27 = -71.74984262
		replace x_28 =	-46.5864258	
		replace y_28 = -71.66754638
		replace x_29 = -26.48287502	
		replace y_29 = -68.18383364
		replace x_30 = -23.82663028	
		replace y_30 = -67.25150602
		replace x_31 = -35.18089593	
		replace y_31 = -70.51976084
		


*calculo distancias a los pasos
local todas_dist 

		forvalues z = 1/31 { 
		*distancia a cada uno de los pasos: (en m) 
		geodist _Y _X  x_`z' y_`z' , gen(dist_`z') 
		format dist_`z' %9.4f
		*guardo los valores de cada distancia 
		*levelsof dist_`z' 
		*local dist_`z' = r(levels) 
		*acumulo distancias 
		local todas_dist `todas_dist' dist_`z' 
}



*armo distancia minima 
egen dist_minima_lineal = rowmin(dist_1 dist_2 dist_3 dist_4 dist_5 dist_6 dist_7 dist_8 dist_9 dist_10 dist_11 dist_12 ///
                                 dist_13 dist_14 dist_15 dist_16 dist_17 dist_18 dist_19 dist_20 dist_21 dist_22 ///
								 dist_23 dist_24 dist_25 dist_26 dist_27 dist_28 dist_29 dist_30 dist_31) 
								 
*identifico que numero de paso es: tengo que redondear porque los decimales de las dist_* son mayores que dist_minima 
gen info_paso_aux = 0
gen dist_minima_aux=round(dist_minima_lineal, .4)
label var dist_minima_lineal "Distancia min lineal"


forvalues z = 1/31 { 
	gen dist_`z'_aux = round(dist_`z', .4)
	replace info_paso_aux=`z' if dist_minima_aux==dist_`z'_aux 
}

ta info_paso_aux , m 




 *traigo la info de los pasos fronterizos de la otra carpeta de la tesis: 
merge m:1 info_paso_aux using "X:\Mi unidad\Maestria en economia\Tesis-version vieja\raw-data\pasos fronterizos\pasos-fronterizos-finales", gen(m_pasos)
ta m_pasos
 


*indentificador de provincia del paso arg 
 encode frontera_arg_provincia_aux , generate(frontera_arg_prov_lineal) label("Prov ARG en la frontera (lineal)")
drop frontera_arg_provincia_aux 

*borro coordenadas de los pasos y las distancias de cada EESS 

forvalues z = 1/31 { 
	drop x_`z' 
	drop y_`z'
	drop dist_`z' 
} 
 
*borro las distancias a los pasos 
drop dist_*_aux 

rename info_paso_aux info_paso_lineal 
rename nombre_paso_aux nombre_paso_lineal 
rename frontera_pais_aux frontera_pais_lineal 

*guardo base final (esta vas a usar para las regresiones)
save "bases\base-precios\p-pulidas-distancias\nafta_3_2016_2022_v3.dta", replace


 */




*-----------------------------------------------------------------------------------------*
*-----------------------------------------------------------------------------------------*
*-NAFTA COMUN - CALCULO DE DISTANCIAS LINEALES CON 31 PASOS FRONTERIZOS (NO 52)
*-----------------------------------------------------------------------------------------*

use "bases\base-precios\p-pulidas-distancias\nafta_2_2016_2022_v2.dta", clear 

*borro las variables de distancia lineales viejas (calculadas con los 52 pasos)
drop nombre_paso  //nombres
drop info_paso  // numero 
drop dist_minima  // distancia minima lineal vieja 
drop frontera_pais // paias fronterizo dist lineal vieja 
drop prov_arg_frontera // provincia argentina dist lineal vieja 

*Creo variables con las coordenadas de los pasos 
forvalues a = 1/31 { 
	gen x_`a' = . 
	gen y_`a' = . 
	label var x_`a' "Latitud paso `a'"
	label var y_`a' "Longitud paso `a'" 
		}

		replace x_1 = -33.1114478	
		replace y_1 = -58.2460198
		replace x_2 = -32.26377376
		replace y_2 = -58.09786121
		replace x_3 = -31.2609222
		replace y_3 = -57.961622
		replace x_4 = -22.01436223
		replace y_4 = -63.68222836
		replace x_5 = -22.72620497
		replace y_5 = -64.36962899
		replace x_6 = -22.09672714
		replace y_6 = -65.59619637
		replace x_7 = -25.60106748	
		replace y_7 = -53.97057139
		replace x_8 = -25.6006454  	
		replace y_8 = -54.56112463
		replace x_9 = -29.73110932	
		replace y_9 = -57.11126655
		replace x_10 = -28.59117286
		replace y_10 = -56.03289063
		replace x_11 = -25.26475634	
		replace y_11 = -57.72759045
		replace x_12 = -25.28605686	
		replace y_12 = -57.70915988
		replace x_13 =	-27.37430302	
		replace y_13 = -55.88208906
		replace x_14 = -32.82543516	
		replace y_14 = -70.09213018
		replace x_15 = -30.19135328
		replace y_15 = -69.82563194
		replace x_16 = -40.6984364	    
		replace y_16 = -71.93376231
		replace x_17 = -39.78724569	
		replace y_17 = -71.6817892
		replace x_18 = -51.57445833	
		replace y_18 = -72.35013889
		replace x_19 = -52.13863902	
		replace y_19 = -69.51603956
		replace x_20 = -45.14033066
		replace y_20 = -71.33646004
		replace x_21 = -35.98585044	
		replace y_21 = -70.39111652
		replace x_22 = -37.44763756	
		replace y_22 = -71.11618237
		replace x_23 = -38.66065544	
		replace y_23 = -70.89879853
		replace x_24 = -27.9882992	
		replace y_24 = -69.32401697
		replace x_25 = -51.25899931	
		replace y_25 = -72.34407249
		replace x_26 = -44.5538149	
		replace y_26 = -71.09421421
		replace x_27 = -43.17369427	
		replace y_27 = -71.74984262
		replace x_28 =	-46.5864258	
		replace y_28 = -71.66754638
		replace x_29 = -26.48287502	
		replace y_29 = -68.18383364
		replace x_30 = -23.82663028	
		replace y_30 = -67.25150602
		replace x_31 = -35.18089593	
		replace y_31 = -70.51976084
		


*calculo distancias a los pasos
local todas_dist 

		forvalues z = 1/31 { 
		*distancia a cada uno de los pasos: (en m) 
		geodist _Y _X  x_`z' y_`z' , gen(dist_`z') 
		format dist_`z' %9.4f
		*guardo los valores de cada distancia 
		*levelsof dist_`z' 
		*local dist_`z' = r(levels) 
		*acumulo distancias 
		local todas_dist `todas_dist' dist_`z' 
}



*armo distancia minima 
egen dist_minima_lineal = rowmin(dist_1 dist_2 dist_3 dist_4 dist_5 dist_6 dist_7 dist_8 dist_9 dist_10 dist_11 dist_12 ///
                                 dist_13 dist_14 dist_15 dist_16 dist_17 dist_18 dist_19 dist_20 dist_21 dist_22 ///
								 dist_23 dist_24 dist_25 dist_26 dist_27 dist_28 dist_29 dist_30 dist_31) 
								 
*identifico que numero de paso es: tengo que redondear porque los decimales de las dist_* son mayores que dist_minima 
gen info_paso_aux = 0
gen dist_minima_aux=round(dist_minima_lineal, .4)
label var dist_minima_lineal "Distancia min lineal"


forvalues z = 1/31 { 
	gen dist_`z'_aux = round(dist_`z', .4)
	replace info_paso_aux=`z' if dist_minima_aux==dist_`z'_aux 
}

ta info_paso_aux , m 


drop m_pasos 


 *traigo la info de los pasos fronterizos de la otra carpeta de la tesis: 
merge m:1 info_paso_aux using "X:\Mi unidad\Maestria en economia\Tesis-version vieja\raw-data\pasos fronterizos\pasos-fronterizos-finales", gen(m_pasos)
ta m_pasos
 




*indentificador de provincia del paso arg 
 encode frontera_arg_provincia_aux , generate(frontera_arg_prov_lineal) label("Prov ARG en la frontera (lineal)")
drop frontera_arg_provincia_aux 

*borro coordenadas de los pasos y las distancias de cada EESS 

forvalues z = 1/31 { 
	drop x_`z' 
	drop y_`z'
	drop dist_`z' 
} 
 
*borro las distancias a los pasos 
drop dist_*_aux 

rename info_paso_aux info_paso_lineal 
rename nombre_paso_aux nombre_paso_lineal 
rename frontera_pais_aux frontera_pais_lineal 


save "bases\base-precios\p-pulidas-distancias\nafta_2_2016_2022_v3.dta", replace 


*-----------------------------------------------------------------------------------------*
*-----------------------------------------------------------------------------------------*
*-GASOIL COMUN  - CALCULO DE DISTANCIAS LINEALES CON 31 PASOS FRONTERIZOS (NO 52)
*-----------------------------------------------------------------------------------------*
use "bases\base-precios\p-pulidas-distancias\gasoil_2_2016_2022_v2.dta", clear 

*borro las variables de distancia lineales viejas (calculadas con los 52 pasos)

drop nombre_paso  //nombres
drop info_paso  // numero 
drop dist_minima  // distancia minima lineal vieja 
drop frontera_pais // paias fronterizo dist lineal vieja 
drop prov_arg_frontera // provincia argentina dist lineal vieja 

*Creo variables con las coordenadas de los pasos 
forvalues a = 1/31 { 
	gen x_`a' = . 
	gen y_`a' = . 
	label var x_`a' "Latitud paso `a'"
	label var y_`a' "Longitud paso `a'" 
		}

		replace x_1 = -33.1114478	
		replace y_1 = -58.2460198
		replace x_2 = -32.26377376
		replace y_2 = -58.09786121
		replace x_3 = -31.2609222
		replace y_3 = -57.961622
		replace x_4 = -22.01436223
		replace y_4 = -63.68222836
		replace x_5 = -22.72620497
		replace y_5 = -64.36962899
		replace x_6 = -22.09672714
		replace y_6 = -65.59619637
		replace x_7 = -25.60106748	
		replace y_7 = -53.97057139
		replace x_8 = -25.6006454  	
		replace y_8 = -54.56112463
		replace x_9 = -29.73110932	
		replace y_9 = -57.11126655
		replace x_10 = -28.59117286
		replace y_10 = -56.03289063
		replace x_11 = -25.26475634	
		replace y_11 = -57.72759045
		replace x_12 = -25.28605686	
		replace y_12 = -57.70915988
		replace x_13 =	-27.37430302	
		replace y_13 = -55.88208906
		replace x_14 = -32.82543516	
		replace y_14 = -70.09213018
		replace x_15 = -30.19135328
		replace y_15 = -69.82563194
		replace x_16 = -40.6984364	    
		replace y_16 = -71.93376231
		replace x_17 = -39.78724569	
		replace y_17 = -71.6817892
		replace x_18 = -51.57445833	
		replace y_18 = -72.35013889
		replace x_19 = -52.13863902	
		replace y_19 = -69.51603956
		replace x_20 = -45.14033066
		replace y_20 = -71.33646004
		replace x_21 = -35.98585044	
		replace y_21 = -70.39111652
		replace x_22 = -37.44763756	
		replace y_22 = -71.11618237
		replace x_23 = -38.66065544	
		replace y_23 = -70.89879853
		replace x_24 = -27.9882992	
		replace y_24 = -69.32401697
		replace x_25 = -51.25899931	
		replace y_25 = -72.34407249
		replace x_26 = -44.5538149	
		replace y_26 = -71.09421421
		replace x_27 = -43.17369427	
		replace y_27 = -71.74984262
		replace x_28 =	-46.5864258	
		replace y_28 = -71.66754638
		replace x_29 = -26.48287502	
		replace y_29 = -68.18383364
		replace x_30 = -23.82663028	
		replace y_30 = -67.25150602
		replace x_31 = -35.18089593	
		replace y_31 = -70.51976084
		


*calculo distancias a los pasos
local todas_dist 

		forvalues z = 1/31 { 
		*distancia a cada uno de los pasos: (en m) 
		geodist _Y _X  x_`z' y_`z' , gen(dist_`z') 
		format dist_`z' %9.4f
		*guardo los valores de cada distancia 
		*levelsof dist_`z' 
		*local dist_`z' = r(levels) 
		*acumulo distancias 
		local todas_dist `todas_dist' dist_`z' 
}



*armo distancia minima 
egen dist_minima_lineal = rowmin(dist_1 dist_2 dist_3 dist_4 dist_5 dist_6 dist_7 dist_8 dist_9 dist_10 dist_11 dist_12 ///
                                 dist_13 dist_14 dist_15 dist_16 dist_17 dist_18 dist_19 dist_20 dist_21 dist_22 ///
								 dist_23 dist_24 dist_25 dist_26 dist_27 dist_28 dist_29 dist_30 dist_31) 
								 
*identifico que numero de paso es: tengo que redondear porque los decimales de las dist_* son mayores que dist_minima 
gen info_paso_aux = 0
gen dist_minima_aux=round(dist_minima_lineal, .4)
label var dist_minima_lineal "Distancia min lineal"


forvalues z = 1/31 { 
	gen dist_`z'_aux = round(dist_`z', .4)
	replace info_paso_aux=`z' if dist_minima_aux==dist_`z'_aux 
}

ta info_paso_aux , m 


drop m_pasos 


 *traigo la info de los pasos fronterizos de la otra carpeta de la tesis: 
merge m:1 info_paso_aux using "X:\Mi unidad\Maestria en economia\Tesis-version vieja\raw-data\pasos fronterizos\pasos-fronterizos-finales", gen(m_pasos)
ta m_pasos
 




*indentificador de provincia del paso arg 
 encode frontera_arg_provincia_aux , generate(frontera_arg_prov_lineal) label("Prov ARG en la frontera (lineal)")
drop frontera_arg_provincia_aux 

*borro coordenadas de los pasos y las distancias de cada EESS 

forvalues z = 1/31 { 
	drop x_`z' 
	drop y_`z'
	drop dist_`z' 
} 
 
*borro las distancias a los pasos 
drop dist_*_aux 

rename info_paso_aux info_paso_lineal 
rename nombre_paso_aux nombre_paso_lineal 
rename frontera_pais_aux frontera_pais_lineal 


save "bases\base-precios\p-pulidas-distancias\gasoil_2_2016_2022_v3.dta", replace 