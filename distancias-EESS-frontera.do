

******************************************************************************
/* Dofile para calcular distancias por ruta en la base aux y limpiarla:

G:\Mi unidad\Malena\FCE\Maestria\Tesis-v2\bases\base-precios\p-pulidas-distancias\aux-nafta-pre-distancias.dta
*/
******************************************************************************

local combustibles nafta
*gasoil
/*  
foreach c of local combustibles { 

*traigo base corte transversal nafta premium (nafta3):
use "bases\base-precios\p-pulidas-distancias\\aux-`c'3-pre-distancias.dta", clear 
  

		forvalues z = 1/31 { 
		*distancia de cada EESS a cada uno de los pasos:
		osrmtime _Y _X  x_`z' y_`z' ,  mapfile("C:\mymaps\argentina.osrm") osrmdir("C:\osrm\") nocleanup 
	    drop jumpdist1 jumpdist2 
		rename distance dist_`z'
		rename duration dur_`z'
		rename return_code return_code_`z' 		
}

save "bases\base-precios\p-pulidas-distancias\\aux-`c'3-post-distancias.dta", replace 

}

 */


******************************************************************************
/* Correr esta parte para limpiar las bases con las distancias*/
******************************************************************************

/* 
foreach c of local combustibles { 


use "bases\base-precios\p-pulidas-distancias\\aux-`c'3-post-distancias.dta", clear 

*no hay errores en los calculos de distancia (tiene =0 cuando todo ok), borro las variables:
sum return_code_*
drop return_code_* 

*Calculo distancia minima: 
egen minima_ruta = rowmin(dist_*) 
*Calculo duracion minima:
egen minima_segundos = rowmin(dur_*) 

*Ajusto decimales distancia/duracion minima: 
gen minima_ruta_aux = round(minima_ruta, .1)
gen minima_segundos_aux = round(minima_segundos, .1)

drop minima_ruta minima_segundos

*Ajusto decimales: 
forvalues z = 1/31 { 
	gen distancia_`z'_aux = round(dist_`z', .1)
	gen duracion_`z'_aux = round(dur_`z', .1)
} 

drop dist_* 
drop dur_* 

*Identifico el numero de paso: 
 
gen info_paso_ruta = .
gen info_paso_segundos = .  

forvalues x = 1/31 { 
	replace info_paso_ruta =`x'    if distancia_`x'_aux == minima_ruta_aux 
	replace info_paso_segundos =`x' if duracion_`x'_aux == minima_segundos_aux
}

*Borro variables con las coordenadas de los pasos fronterios:
drop x_* y_* 

*Borro coordenadas de las EESS:
drop _Y _X

*Borro las variables de distancias a todos los pasos: 
drop distancia_*
drop duracion_* 

*La variable de duracion minima está en SEGUNDOS, paso a minutos: 
gen dist_minima_minutos = minima_segundos_aux / 60 

*La variable de distancia minima esta en metros, paso a km: 
gen dist_minima_ruta = minima_ruta_aux / 1000 

drop minima_ruta_aux minima_segundos_aux

*Traigo el nombre de los pasos fronterizos: (Está en la carpeta vieja de la tesis)

*MERGE 1: distancia por tiempo
rename info_paso_segundos info_paso_aux 
merge m:1 info_paso_aux using "G:\Mi unidad\Malena\FCE\Maestria\Tesis\raw-data\pasos fronterizos ARG\pasos-fronterizos-finales", gen(m_minutos) keepusing(frontera_pais_aux nombre_paso_aux frontera_arg_provincia_aux)

rename frontera_pais_aux frontera_pais_minutos
rename nombre_paso_aux nombre_paso_minutos 
rename frontera_arg_provincia_aux frontera_arg_prov_minutos

rename info_paso_aux info_paso_minutos 


*MERGE 2: distancia en km 
rename info_paso_ruta info_paso_aux
merge m:1 info_paso_aux using "G:\Mi unidad\Malena\FCE\Maestria\Tesis\raw-data\pasos fronterizos ARG\pasos-fronterizos-finales", gen(m_ruta)

rename frontera_pais_aux frontera_pais_ruta 
rename nombre_paso_aux nombre_paso_ruta
rename frontera_arg_provincia_aux frontera_arg_prov_ruta 


rename info_paso_aux info_paso_ruta

*-Limpio un poco la base:
*borro pasos fronterizos que no matchearon ninguna EESS:  
drop if m_minutos==2
drop if m_minutos==. & m_ruta==2

drop m_minutos
drop m_ruta 

drop x_paso_aux 
drop y_paso_aux 


save "bases\base-distancias-EESS-frontera\distancias-EESS-frontera-`c'3.dta", replace 

} 

  */


******************************************************************************
/* Correr esta parte para matchear las base con las distancias de las EESS a los pasos fronterizos
con las bases de combustibles */
******************************************************************************

*GASOIL
/* use "bases\base-precios\p-pulidas-distancias\gasoil_2_2016_2022.dta", clear 

merge m:1 codigo_unico_de_coordenadas using "bases\base-distancias-EESS-frontera\distancias-EESS-frontera-gasoil.dta" , gen(m_gasoil)

save "bases\base-precios\p-pulidas-distancias\gasoil_2_2016_2022_v2.dta", replace  */

*NAFTA PREMIUM 
use "bases\base-precios\p-pulidas\nafta3\nafta_3_al_publico", clear
merge m:1 codigo_unico_de_coordenadas using "bases\base-distancias-EESS-frontera\distancias-EESS-frontera-nafta3.dta", gen(m_nafta_premium) 

*matched: 
/* 
  Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                            57,060  (m_nafta_premium==3)
    -----------------------------------------


 */
 
save "bases\base-precios\p-pulidas-distancias\nafta_3_2016_2022_v2.dta", replace  


--




*NAFTA COMUN/SUPER
use "bases\base-precios\p-pulidas-distancias\nafta_2_2016_2022.dta", clear 

merge m:1 codigo_unico_de_coordenadas using "bases\base-distancias-EESS-frontera\distancias-EESS-frontera-gasoil.dta", gen(m_nafta)

drop if m_nafta==2 

*hay 500 obs de la base original que no matchean. no se pq ! No imp, son EESS de CHL o URY 

drop x_* y_*
drop dist_1
drop dist_2
drop dist_3
drop dist_4
drop dist_5
drop dist_6
drop dist_7
drop dist_8
drop dist_10
drop dist_11

drop dist_13
drop dist_14
drop dist_15



drop dist_19
drop dist_22
drop dist_23
drop dist_24
drop dist_25
drop dist_26
drop dist_27
drop dist_28
drop dist_29
drop dist_30
drop dist_31
drop dist_32
drop dist_33
drop dist_34
drop dist_35
drop dist_36
drop dist_37
drop dist_38
drop dist_39
drop dist_40
drop dist_41
drop dist_42
drop dist_43
drop dist_44
drop dist_45
drop dist_46
drop dist_47
drop dist_48
drop dist_49
drop dist_50
drop dist_51
drop dist_52

save "bases\base-precios\p-pulidas-distancias\nafta_2_2016_2022_v2.dta", replace 

 























