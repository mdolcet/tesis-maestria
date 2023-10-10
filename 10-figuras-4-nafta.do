
*FIGURAS POR PASO FRONTERIZO

*SACAR 1 GRAFICO CON LA SERIE DE VOLUMEN X PASO FRONTERIZO.
*OBJETIVO: CAPAZ SE PUEDE DESCARGAR ALGUN PASO QUE NO SEA RELEVANTE o asociar la EESS AL PASO QUE TIENE RELEVANCIA 

use "bases\base-precios\p-pulidas-distancias\nafta_2_2016_2022.dta", clear 


tssmooth ma lvol_pub2=lvol_pub, window(2 0 1)



/*  PRE TRATAMIENTO: BRECHA BAJA (SIN BARRIL CRIOLLO) 2017m8: 691 hasta 2019m10: 717
	POST TRATAMIENTO: BRECHA ALTA: 2019m12=719 adelante
  */


levelsof info_paso, local(pasos)
di `pasos' 

foreach x of local pasos { 
	preserve 
	drop if time < 691
	keep if info_paso==`x'
	keep if dist_minima<=50

	collapse (mean) lvol_pub2, by(time nombre_paso info_paso frontera_pais)
	gen lvol_`x' = lvol_pub2 / lvol_pub2[1]
	format %tm time



	local nombre = nombre_paso[1]
	local numero_paso = info_paso[1]
	local q_observaciones = [_N]
	local frontera = frontera_pais[1]
	
			twoway (line lvol_`x'  time, sort) , ///
					legend(on lab(1 "`nombre'")   col(1) pos(6) region(lcolor(black)) ) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	///
						note("Observaciones: _`q_observaciones'" ///
								"Frotera: `frontera'" ///
								"Info_paso: `numero_paso'" ///
								"Distancia a la frontera: <50km") 
						
			graph export "salidas\volumenes\prueba1\por frontera y menos pasos 1\q_paso_`x'_50km.png", replace		
			
  
restore 
}




 */

*Algunos pasos q se trabaron: 
/* 
forvalues x = 22(1)28 { 
preserve 
	drop if time < 691
	keep if info_paso==`x'
	keep if dist_minima<=50

	collapse (mean) lvol_pub2, by(time nombre_paso info_paso frontera_pais)
	gen lvol_`x' = lvol_pub2 / lvol_pub2[1]
	format %tm time



	local nombre = nombre_paso[1]
	local numero_paso = info_paso[1]
	local q_observaciones = [_N]
	local frontera = frontera_pais[1]
	
			twoway (line lvol_`x'  time, sort) , ///
					legend(on lab(1 "`nombre'")   col(1) pos(6) region(lcolor(black)) ) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	///
						note("Observaciones: _`q_observaciones'" ///
								"Frotera: `frontera'" ///
								"Info_paso: `numero_paso'" ///
								"Distancia a la frontera: <50km") 
						
			graph export "salidas\volumenes\prueba1\por paso fronterizo\q_paso_`x'_50km.png", replace		
			
  
restore 
}

 */