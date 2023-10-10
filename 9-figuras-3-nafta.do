***************************************
/* Dofile para buscar algun tratamiento que sirva: 
	
	GOAL: ENCONTRAR UN PERIODO PRE Y POST TREATMENT: BRECHA ALTA 
	 
	 
	 VOLUMENES 
	 
 */
**************************************** 
use "bases\base-precios\p-pulidas-distancias\nafta_2_2016_2022.dta", clear 






**********************************************************
*-- variables de distancias a la frontera 
**********************************************************
label def dist_group 1 "<50km paso fronterizo" 2 "50-100km paso fronterizo" 3 "100-150km paso fronterizo"  4 ">150km paso fronterizo"
label val dist_group dist_group

rename dist_group dist_group1


*Grupos de distancia 75km 
gen dist_group2=. 
replace dist_group2=1 if dist_minima<=75 
replace dist_group2=2 if dist_minima>75 & dist_minima<=150 
replace dist_group2=3 if dist_minima>150 
label def dist_group2 1 "<75km paso fronterizo" 2 "75-150km paso fronterizo" 3 ">150 km"
label val dist_group2 dist_group2

*Grupos de distancia 100km  
gen dist_group3=. 
replace dist_group3=1 if dist_minima<=100
replace dist_group3=2 if dist_minima>100 & dist_minima<=200
replace dist_group3=3 if dist_minima>200 
label def dist_group3 1 "<100km paso fronterizo" 2 "100-200km paso fronterizo" 3 ">200km" 
label val dist_group3 dist_group3

*Grupos de distancia 25km 
gen dist_group4 = . 
replace dist_group4=1 if dist_minima<=25
replace dist_group4=2 if dist_minima>25 & dist_minima<=50
replace dist_group4=3 if dist_minima>50
label def dist_group4 1 "<25km paso fronterizo" 2 "25-50km paso fronterizo" 3 ">50km" 
label val dist_group4 dist_group4

*Grupos de distancia 50km vs el resto 
gen dist_group5 = . 
replace dist_group5=1 if dist_minima<=50
replace dist_group5=2 if dist_minima>50
label def dist_group5 1 "<50km paso fronterizo" 2 ">50km" 
label val dist_group5 dist_group5

*Grupos de distancia 25km vs el resto 
gen dist_group6 = . 
replace dist_group6=1 if dist_minima<=25
replace dist_group6=2 if dist_minima>25
label def dist_group6 1 "<25km paso fronterizo" 2 ">25km" 
label val dist_group6 dist_group6

*Grupos de distancia 25 km vs >200 km 
gen dist_group7 = . 
replace dist_group7=1 if dist_minima<=25
replace dist_group7=2 if dist_minima>200
label def dist_group7 1 "<25km paso fronterizo" 2 ">200km" 
label val dist_group7 dist_group7


*Grupos de distancia 50km vs >200km 
gen dist_group8 = . 
replace dist_group8=1 if dist_minima<=50
replace dist_group8=2 if dist_minima>200
label def dist_group8 1 "<50km paso fronterizo" 2 ">200km" 
label val dist_group8 dist_group8

*Grupos de distancia 50km vs 100-200km 
gen dist_group9 = . 
replace dist_group9=1 if dist_minima<=50 
replace dist_group9=2 if dist_minima>=100 & dist_minima<=200 
label def dist_group9 1 "<50km paso fronterizo" 2 "100-200km" 
label val dist_group9 dist_group9

*Banderas 
gen band = . 
replace band = 1 if bandera=="YPF"
replace band = 2 if bandera=="SHELL C.A.P.S.A."
replace band = 3 if bandera=="AXION" | bandera=="ESSO PETROLERA ARGENTINA S.R.L"
replace band = 4 if bandera=="BLANCA"
replace band = 5 if bandera=="PUMA" 
replace band = 6 if bandera=="PETROBRAS" | bandera=="OIL COMBUSTIBLES S.A." |  bandera=="REFINOR" | bandera=="ASPRO" | bandera=="CIS" | bandera=="DAPSA S.A." | bandera=="GULF" | bandera=="Pampa Energia" | bandera=="RHASA" | bandera=="VOY" | bandera=="SOL PETROLEO"

label def band 1 "YPF" 2 "SHELL" 3 "AXION" 4 "BLANCA" 5 "PUMA" 6 "OTRAS" 
label val band band 

*YPF vs resto 
gen ypf = . 
replace ypf =1 if band==1
replace ypf=2   if (band==2 | band==3 | band==4 | band==5 | band==6) 

*Ventas por comprador: Moving average: 2 periodos antes, el 0 y 1+
tssmooth ma lvol_pub2=lvol_pub, window(2 0 1)
tssmooth ma lvol_transp2=lvol_transp, window(3 0 1)
tssmooth ma lvol_agro2=lvol_agro, window(3 0 1)
tssmooth ma lvol_osectores2=lvol_osectores, window(3 0 1)
tssmooth ma lvol_oeess2=lvol_oeess, window(3 0 1)

*para contar EESS
egen id_count2 = group(id frontera_pais) 
local distancias "dist_group1 dist_group2 dist_group3 dist_group4 dist_group5 dist_group6 dist_group7 dist_group8"


foreach var of local distancias { 
preserve 
	*borro todo lo anterior a 2017m8 
  drop if time<691
  keep if frontera_pais=="BOL" | frontera_pais=="BRA" | frontera_pais=="PRY"  
	 bysort `var' frontera_pais: distinct id
	 *rename table1 eess
	 *reshape wide eess, i(`var') j(frontera_pais, s)
	*export excel using "G:\Mi unidad\Malena\FCE\Maestria\Tesis-v2\salidas\volumenes\prueba1\EESS-panel-nafta2.xlsx" , firstrow(var) sheet("`var'") 
restore 
} 



**********************************************************
*-- SERIES DE Q por COMPRADOR 
**********************************************************

/* POST TRATAMIENTO: BRECHA ALTA: 2019m12=719 adelante
   PRE TRATAMIENTO: BRECHA BAJA (SIN BARRIL CRIOLLO) 2017m8: 691 hasta 2019m10: 717*/



*---- (1) Volumenes por comprador -nada, todas lineas raras.
/* 

preserve 
 drop if time < 691 
	collapse (mean) lvol_pub2 lvol_transp2 lvol_agro2 lvol_oeess2 lvol_osectores2, by(time) 
		gen lvoln_pub =       lvol_pub2 /    	lvol_pub2[1]
		gen lvoln_transp =    lvol_transp2 / 	lvol_transp2[1]
		gen lvoln_agro =      lvol_agro2 /   	lvol_agro2[1]
		gen lvoln_oeess =     lvol_oeess2 /  	lvol_oeess2[1]
		gen lvoln_osectores = lvol_osectores2 /  lvol_osectores2[1]
	
		
			twoway (line  lvoln_pub  time, sort cmissing(n)) ///
					(line lvoln_transp time, sort cmissing(n)) ///
					(line lvoln_agro time, sort cmissing(n)) ///
					(line lvoln_oeess time, sort cmissing(n)) ///
					(line lvoln_osectores time, sort cmissing(n)), ///
			scheme(modern)  legend(on col(6) pos(6) lab(1 "Al público") lab(2 "Transporte") lab(3 "Agro") lab(4 "Otras EESS") lab(5 "Otros sectores")) ///
			ytitle("") xtitle("")  ///
			xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
			ylabel(#15, labsize(small) nogrid)  ///
			xline(719, lpattern(dash) lcolor(black)) ///
			plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
			plotregion(fcolor(gs15)) 
		graph export "salidas\volumenes\prueba1\q_sectores_smooth.png", replace
restore 
  */


*---- (2) Volumenes al publico por bandera - PUMA por que aumentan tanto las ventas?
/* 

 preserve 
 drop if time < 691
	collapse (mean) lvol_pub2 , by(band time)
			gen byte basetime = 1 if time==691
			by band (basetime), sort: gen lvol_pubn = lvol_pub2 / lvol_pub2[1]
			
			format %tm time
			
			twoway (line  lvol_pubn time if band==1, sort)  ///
					(line lvol_pubn time if band==2, sort) ///
					(line lvol_pubn time if band==3, sort) ///
					(line lvol_pubn time if band==4, sort) ///
					(line lvol_pubn time if band==5, sort) ///
					(line lvol_pubn time if band==6, sort), ///
					legend(on lab(1 "YPF") lab(2 "Shell") lab(3 "Axion") lab(4 "Blanca") lab(5 "Puma") lab(6 "Otras") col(6) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: al público") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\volumenes\prueba1\q_badera_publico_smooth.png", replace		
restore 
  */
 
 
*---- (3) Volumenes por comprador y distancia a la frontera  - NO SIRVE MIRARLO X COMPRADOR-
*¿HAY UN DIFERENCIAL DE VENTAS CUANDO LA BRECHA ES ALTA????????????
/* 
local compradores "pub transp agro oeess osectores" 

*--DIST GROUP 6 
* 1 "<25km paso fronterizo" 2 ">25km"
foreach x of local compradores { 
preserve 
	drop if time < 691

	collapse (mean) lvol_`x'2, by(dist_group6 time)
			gen byte basetime = 1 if time==691
			by dist_group6 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			
			format %tm time
		
			
			twoway (line  lvol_`x'n  time if dist_group6==1, sort)  ///
					(line lvol_`x'n time if dist_group6==2, sort), ///
					legend(on lab(1 "<25 km") lab(2 ">25km")    col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x'") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\volumenes\prueba1\q_dist6_`x'_smooth.png", replace		
restore 
}
 */

*--DIST GROUP 8 
* 1 "<50km paso fronterizo" 2 ">200km"
/* 
 foreach x of local compradores { 
preserve 
	drop if time < 691

	collapse (mean) lvol_`x'2, by(dist_group8 time)
			gen byte basetime = 1 if time==691
			by dist_group8 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
			twoway (line  lvol_`x'n  time if dist_group8==1, sort)  ///
					(line lvol_`x'n time if dist_group8==2, sort), ///
					legend(on lab(1 "<50 km") lab(2 ">200km") col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x'") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\volumenes\prueba1\q_dist8_`x'_smooth.png", replace		
restore 
} 
 */
 
*---------------------------------------------------------------------------------------------------------------*
*---------------------------------------------------------------------------------------------------------------*
 
*----------------ANÁLISIS POR FRONTERA--------------------------------------------------------------------------*

*---------------------------------------------------------------------------------------------------------------*
*---------------------------------------------------------------------------------------------------------------*

 
*---- (4) Volumen por  pais fronterizo 
*LAS EESS VENDEN Q DIFERENTES AL PUBLICO SEGUN LA FRONTERA? 


preserve 
 drop if time < 691
	collapse (mean) lvol_pub2, by(frontera_pais time)
			gen byte basetime = 1 if time==691
			by frontera_pais (basetime), sort: gen lvol_pubn = lvol_pub2 / lvol_pub2[1]
			
			format %tm time
			
			twoway  (connected  lvol_pubn time if frontera_pais=="BOL", sort)  ///
					(connected lvol_pubn time if frontera_pais=="BRA", sort) ///
					(connected lvol_pubn time if frontera_pais=="CHL", sort) ///
					(connected lvol_pubn time if frontera_pais=="PRY", sort) ///
					(connected lvol_pubn time if frontera_pais=="URY", sort), ///
					legend(on lab(1 "BOL") lab(2 "BRA") lab(3 "CHL") lab(4 "PRY") lab(5 "URY") col(6) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: al público") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\volumenes\prueba1\q_frontera_publico_c.png", replace		
restore 

 


*---- (5) Volumenes por  pais fronterizo y distancia a la frontera 
*LAS EESS veden Q DIFERENTES SEGUN DISTANCIA Y FRONTERA?  SMOOTH 

local compradores "pub"

*----------BOLIVIA 


*dist_group1 "<50km paso fronterizo" 2 "50-100km paso fronterizo" 3 "100-150km paso fronterizo"  4 ">150km paso fronterizo"
/* 
foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="BOL"

	collapse (mean) lvol_`x'2, by(dist_group1 time)
			gen byte basetime = 1 if time==691
			by dist_group1 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			
			format %tm time
		
			
			twoway (line lvol_`x'n  time if dist_group1==1, sort)  ///
					(line lvol_`x'n time if dist_group1==2, sort) ///
					(line lvol_`x'n time if dist_group1==3, sort), ///
					legend(on lab(1 "<50 km") lab(2 "50-100km") lab(3 "100-150km") lab(4 ">150km")    col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Frontera: BOL") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\volumenes\prueba1\por frontera\BOL\q_dist1_`x'_BOL_smooth.png", replace		
restore 
}

 */
 
*dist_group2 1 "<75km paso fronterizo" 2 "75-150km paso fronterizo" 3 ">150 km"
/* 
foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="BOL"

	collapse (mean) lvol_`x'2, by(dist_group2 time)
			gen byte basetime = 1 if time==691
			by dist_group2 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			
			format %tm time
		
			
			twoway (line lvol_`x'n  time if dist_group2==1, sort)  ///
					(line lvol_`x'n time if dist_group2==2, sort) ///
					(line lvol_`x'n time if dist_group2==3, sort), ///
					legend(on lab(1 "<75 km") lab(2 "75-150km") lab(3 ">150km")    col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Frontera: BOL") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\volumenes\prueba1\por frontera\BOL\q_dist2_`x'_BOL_smooth.png", replace		
restore 
}
 */

*dist_group3 1 "<100km paso fronterizo" 2 "100-200km paso fronterizo" 3 ">200km" 
/* 
foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="BOL"

	collapse (mean) lvol_`x'2, by(dist_group3 time)
			gen byte basetime = 1 if time==691
			by dist_group3 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			
			format %tm time
		
			
			twoway (line lvol_`x'n  time if dist_group3==1, sort)  ///
					(line lvol_`x'n time if dist_group3==2, sort) ///
					(line lvol_`x'n time if dist_group3==3, sort), ///
					legend(on lab(1 "<100 km") lab(2 "100-200km") lab(3 ">200km")    col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Frontera: BOL") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\volumenes\prueba1\por frontera\BOL\q_dist3_`x'_BOL_smooth.png", replace		
restore 
} */



*dist_group4 dist_group4 1 "<25km paso fronterizo" 2 "25-50km paso fronterizo" 3 ">50km" 

/* 
foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="BOL"

	collapse (mean) lvol_`x'2, by(dist_group4 time)
			gen byte basetime = 1 if time==691
			by dist_group4 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			
			format %tm time
		
			
			twoway (line lvol_`x'n  time if dist_group4==1, sort)  ///
					(line lvol_`x'n time if dist_group4==2, sort) ///
					(line lvol_`x'n time if dist_group4==3, sort), ///
					legend(on lab(1 "<25 km") lab(2 "25-50km") lab(3 ">50km")    col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Frontera: BOL") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\volumenes\prueba1\por frontera\BOL\q_dist4_`x'_BOL_smooth.png", replace		
restore 
}
 */

*dist_group5 dist_group5 1 "<50km paso fronterizo" 2 ">50km" 

/* 
foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="BOL"

	collapse (mean) lvol_`x'2, by(dist_group5 time)
			gen byte basetime = 1 if time==691
			by dist_group5 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
			twoway (line lvol_`x'n  time if dist_group5==1, sort)  ///
					(line lvol_`x'n time if dist_group5==2, sort), ///
					legend(on lab(1 "<50 km") lab(2 ">50km")    col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Frontera: BOL") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\volumenes\prueba1\por frontera\BOL\q_dist5_`x'_BOL_smooth.png", replace		
restore 
}
 */
 
 
*dist_group6 1 "<25km paso fronterizo" 2 ">25km" 
/* 
foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="BOL"

	collapse (mean) lvol_`x'2, by(dist_group6 time)
			gen byte basetime = 1 if time==691
			by dist_group6 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			
			format %tm time
		
			
			twoway (line lvol_`x'n  time if dist_group6==1, sort)  ///
					(line lvol_`x'n time if dist_group6==2, sort), ///
					legend(on lab(1 "<25 km") lab(2 ">25km")    col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Frontera: BOL") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\volumenes\prueba1\por frontera\BOL\q_dist6_`x'_BOL_smooth.png", replace		
restore 
}
 */
 
 
*dist_group7 1 "<25km paso fronterizo" 2 ">200km"
/* 
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="BOL"

	collapse (mean) lvol_`x'2 , by(dist_group7 time)
			gen byte basetime = 1 if time==691
			by dist_group7 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
			twoway (line  lvol_`x'n  time if dist_group7==1, sort)  ///
					(line lvol_`x'n time if dist_group7==2, sort), ///
					legend(on lab(1 "<25 km") lab(2 ">200km")  col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Frontera: BOL") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\volumenes\prueba1\por frontera\BOL\q_dist7_`x'_BOL_smooth.png", replace		
restore 
}

 */


*dist_group8 1 "<50km paso fronterizo" 2 ">200km"
local compradores "pub"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="BOL"

	collapse (mean) lvol_`x'2 , by(dist_group8 time)
			gen byte basetime = 1 if time==691
			by dist_group8 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
			twoway  (connected  lvol_`x'n  time if dist_group8==1, sort msize(small) lcolor(cranberry) mcolor(cranberry))  ///
					(connected lvol_`x'n time if dist_group8==2,   sort msize(small) lcolor(ebblue) mcolor(ebblue)      ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (>200km)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	///
						ttext(1.12 708  "Exchange rate gap = 0"  1.12 730  "Exchange rate gap > 0", color(gs2) size(small))
			graph export "salidas\volumenes\prueba1\por frontera y menos pasos 1\q_dist8_`x'_BOL_smooth_c.png", replace		
restore 
}


*dist_group9 1 "<50km paso fronterizo" 2 "100-200km"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="BOL"

	collapse (mean) lvol_`x'2 , by(dist_group9 time)
			gen byte basetime = 1 if time==691
			by dist_group9 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
			twoway  (connected  lvol_`x'n  time if dist_group9==1, sort msize(small) lcolor(cranberry) mcolor(cranberry))  ///
					(connected lvol_`x'n time if dist_group9==2,   sort msize(small) lcolor(ebblue) mcolor(ebblue)      ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (100-200km)")  col(2) pos(6) region(lcolor(black)) ) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
					plotregion(fcolor(gs15)) 	///
					ttext(1.12 708  "Exchange rate gap = 0"  1.12 730  "Exchange rate gap > 0", color(gs2) size(small))
			graph export "salidas\volumenes\prueba1\por frontera y menos pasos 1\q_dist9_`x'_BOL_smooth_c.png", replace		
restore 
}






*----------BRASIL
/* 
*dist_group1 "<50km paso fronterizo" 2 "50-100km paso fronterizo" 3 "100-150km paso fronterizo"  4 ">150km paso fronterizo"
foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="BRA"

	collapse (mean) lvol_`x'2, by(dist_group1 time)
			gen byte basetime = 1 if time==691
			by dist_group1 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			
			format %tm time
		
			
			twoway (line lvol_`x'n  time if dist_group1==1, sort)  ///
					(line lvol_`x'n time if dist_group1==2, sort) ///
					(line lvol_`x'n time if dist_group1==3, sort), ///
					legend(on lab(1 "<50 km") lab(2 "50-100km") lab(3 "100-150km") lab(4 ">150km")    col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Frontera: BRA") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\volumenes\prueba1\por frontera\BRA\q_dist1_`x'_BRA_smooth.png", replace		
restore 
}


*dist_group2 1 "<75km paso fronterizo" 2 "75-150km paso fronterizo" 3 ">150 km"
foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="BRA"

	collapse (mean) lvol_`x'2, by(dist_group2 time)
			gen byte basetime = 1 if time==691
			by dist_group2 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			
			format %tm time
		
			
			twoway (line lvol_`x'n  time if dist_group2==1, sort)  ///
					(line lvol_`x'n time if dist_group2==2, sort) ///
					(line lvol_`x'n time if dist_group2==3, sort), ///
					legend(on lab(1 "<75 km") lab(2 "75-150km") lab(3 ">150km")    col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Frontera: BRA") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\volumenes\prueba1\por frontera\BRA\q_dist2_`x'_BRA_smooth.png", replace		
restore 
}


*dist_group3 1 "<100km paso fronterizo" 2 "100-200km paso fronterizo" 3 ">200km" 
foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="BRA"

	collapse (mean) lvol_`x'2, by(dist_group3 time)
			gen byte basetime = 1 if time==691
			by dist_group3 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			
			format %tm time
		
			
			twoway (line lvol_`x'n  time if dist_group3==1, sort)  ///
					(line lvol_`x'n time if dist_group3==2, sort) ///
					(line lvol_`x'n time if dist_group3==3, sort), ///
					legend(on lab(1 "<100 km") lab(2 "100-200km") lab(3 ">200km")    col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Frontera: BRA") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\volumenes\prueba1\por frontera\BRA\q_dist3_`x'_BRA_smooth.png", replace		
restore 
}

*dist_group4 dist_group4 1 "<25km paso fronterizo" 2 "25-50km paso fronterizo" 3 ">50km" 
foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="BRA"

	collapse (mean) lvol_`x'2, by(dist_group4 time)
			gen byte basetime = 1 if time==691
			by dist_group4 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			
			format %tm time
		
			
			twoway (line lvol_`x'n  time if dist_group4==1, sort)  ///
					(line lvol_`x'n time if dist_group4==2, sort) ///
					(line lvol_`x'n time if dist_group4==3, sort), ///
					legend(on lab(1 "<25 km") lab(2 "25-50km") lab(3 ">50km")    col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Frontera: BRA") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\volumenes\prueba1\por frontera\BRA\q_dist4_`x'_BRA_smooth.png", replace		
restore 
}


*dist_group5 dist_group5 1 "<50km paso fronterizo" 2 ">50km" 
foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="BRA"

	collapse (mean) lvol_`x'2, by(dist_group5 time)
			gen byte basetime = 1 if time==691
			by dist_group5 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			
			format %tm time
		
			
			twoway (line lvol_`x'n  time if dist_group5==1, sort)  ///
					(line lvol_`x'n time if dist_group5==2, sort), ///
					legend(on lab(1 "<50 km") lab(2 ">50km")    col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Frontera: BRA") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\volumenes\prueba1\por frontera\BRA\q_dist5_`x'_BRA_smooth.png", replace		
restore 
}

*dist_group6 1 "<25km paso fronterizo" 2 ">25km" 
foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="BRA"

	collapse (mean) lvol_`x'2, by(dist_group6 time)
			gen byte basetime = 1 if time==691
			by dist_group6 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]			
			format %tm time
			
			twoway (line lvol_`x'n  time if dist_group6==1, sort)  ///
					(line lvol_`x'n time if dist_group6==2, sort), ///
					legend(on lab(1 "<25 km") lab(2 ">25km")    col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Frontera: BRA") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\volumenes\prueba1\por frontera\BRA\q_dist6_`x'_BRA_smooth.png", replace		

restore 
}

*dist_group7 1 "<25km paso fronterizo" 2 ">200km"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="BRA"

	collapse (mean) lvol_`x'2 , by(dist_group7 time)
			gen byte basetime = 1 if time==691
			by dist_group7 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
			twoway (line lvol_`x'n  time if dist_group7==1, sort)  ///
					(line lvol_`x'n time if dist_group7==2, sort), ///
					legend(on lab(1 "<25 km") lab(2 ">200km")  col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Frontera: BRA") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\volumenes\prueba1\por frontera\BRA\q_dist7_`x'_BRA_smooth.png", replace		
restore 
}

 */



*dist_group8 1 "<50km paso fronterizo" 2 ">200km"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="BRA"

	collapse (mean) lvol_`x'2 , by(dist_group8 time)
			gen byte basetime = 1 if time==691
			by dist_group8 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
			twoway  (connected lvol_`x'n  time if dist_group8==1, sort msize(small) lcolor(cranberry) mcolor(cranberry))  ///
					(connected lvol_`x'n time if dist_group8==2, sort msize(small) lcolor(ebblue) mcolor(ebblue)      ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (>200km)")  col(2) pos(6) region(lcolor(black)) ) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) ///
						ttext(1.12 708  "Exchange rate gap = 0"  1.12 730  "Exchange rate gap > 0", color(gs2) size(small))
			graph export "salidas\volumenes\prueba1\por frontera y menos pasos 1\q_dist8_`x'_BRA_smooth_c.png", replace		
restore 
}





*dist_group9 1 "<50km paso fronterizo" 2 "100-200km"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="BRA"

	collapse (mean) lvol_`x'2 , by(dist_group9 time)
			gen byte basetime = 1 if time==691
			by dist_group9 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
			twoway  (connected lvol_`x'n  time if dist_group9==1, sort msize(small) lcolor(cranberry) mcolor(cranberry))  ///
					(connected lvol_`x'n time if dist_group9==2, sort msize(small) lcolor(ebblue) mcolor(ebblue)      ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (100-200km)")  col(2) pos(6) region(lcolor(black)) ) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) ///
						ttext(1.12 708  "Exchange rate gap = 0"  1.12 730  "Exchange rate gap > 0", color(gs2) size(small))
			graph export "salidas\volumenes\prueba1\por frontera y menos pasos 1\q_dist9_`x'_BRA_smooth_c.png", replace		
restore 
}







*----------PARAGUAY
/* 
*dist_group1 "<50km paso fronterizo" 2 "50-100km paso fronterizo" 3 "100-150km paso fronterizo"  4 ">150km paso fronterizo"
foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="PRY"

	collapse (mean) lvol_`x'2, by(dist_group1 time)
			gen byte basetime = 1 if time==691
			by dist_group1 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			
			format %tm time
		
			
			twoway (line lvol_`x'n  time if dist_group1==1, sort)  ///
					(line lvol_`x'n time if dist_group1==2, sort) ///
					(line lvol_`x'n time if dist_group1==3, sort), ///
					legend(on lab(1 "<50 km") lab(2 "50-100km") lab(3 "100-150km") lab(4 ">150km")    col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Frontera: PRY") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\volumenes\prueba1\por frontera\PRY\q_dist1_`x'_PRY_smooth.png", replace		
restore 
}


*dist_group2 1 "<75km paso fronterizo" 2 "75-150km paso fronterizo" 3 ">150 km"
foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="PRY"

	collapse (mean) lvol_`x'2, by(dist_group2 time)
			gen byte basetime = 1 if time==691
			by dist_group2 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			
			format %tm time
		
			
			twoway (line lvol_`x'n  time if dist_group2==1, sort)  ///
					(line lvol_`x'n time if dist_group2==2, sort) ///
					(line lvol_`x'n time if dist_group2==3, sort), ///
					legend(on lab(1 "<75 km") lab(2 "75-150km") lab(3 ">150km")    col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Frontera: PRY") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\volumenes\prueba1\por frontera\PRY\q_dist2_`x'_PRY_smooth.png", replace		
restore 
}


*dist_group3 1 "<100km paso fronterizo" 2 "100-200km paso fronterizo" 3 ">200km" 
foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="PRY"

	collapse (mean) lvol_`x'2, by(dist_group3 time)
			gen byte basetime = 1 if time==691
			by dist_group3 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			
			format %tm time
		
			
			twoway (line lvol_`x'n  time if dist_group3==1, sort)  ///
					(line lvol_`x'n time if dist_group3==2, sort) ///
					(line lvol_`x'n time if dist_group3==3, sort), ///
					legend(on lab(1 "<100 km") lab(2 "100-200km") lab(3 ">200km")    col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Frontera: PRY") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\volumenes\prueba1\por frontera\PRY\q_dist3_`x'_PRY_smooth.png", replace		
restore 
}

*dist_group4 dist_group4 1 "<25km paso fronterizo" 2 "25-50km paso fronterizo" 3 ">50km" 
foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="PRY"

	collapse (mean) lvol_`x'2, by(dist_group4 time)
			gen byte basetime = 1 if time==691
			by dist_group4 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			
			format %tm time
		
			
			twoway (line lvol_`x'n  time if dist_group4==1, sort)  ///
					(line lvol_`x'n time if dist_group4==2, sort) ///
					(line lvol_`x'n time if dist_group4==3, sort), ///
					legend(on lab(1 "<25 km") lab(2 "25-50km") lab(3 ">50km")    col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Frontera: PRY") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\volumenes\prueba1\por frontera\PRY\q_dist4_`x'_PRY_smooth.png", replace		
restore 
}


*dist_group5 dist_group5 1 "<50km paso fronterizo" 2 ">50km" 
foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="PRY"

	collapse (mean) lvol_`x'2, by(dist_group5 time)
			gen byte basetime = 1 if time==691
			by dist_group5 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			
			format %tm time
		
			
			twoway (line lvol_`x'n  time if dist_group5==1, sort)  ///
					(line lvol_`x'n time if dist_group5==2, sort), ///
					legend(on lab(1 "<50 km") lab(2 ">50km")    col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Frontera: BRA") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\volumenes\prueba1\por frontera\PRY\q_dist5_`x'_PRY_smooth.png", replace		
restore 
}


*dist_group6 1 "<25km paso fronterizo" 2 ">25km" 
foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="PRY"

	collapse (mean) lvol_`x'2, by(dist_group6 time)
			gen byte basetime = 1 if time==691
			by dist_group6 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			
			format %tm time
		
			
			twoway (line lvol_`x'n  time if dist_group6==1, sort)  ///
					(line lvol_`x'n time if dist_group6==2, sort), ///
					legend(on lab(1 "<25 km") lab(2 ">25km")    col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Frontera: PRY") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\volumenes\prueba1\por frontera\PRY\q_dist6_`x'_PRY_smooth.png", replace		
restore 
}


*dist_group7 1 "<25km paso fronterizo" 2 ">200km"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="PRY"

	collapse (mean) lvol_`x'2 , by(dist_group7 time)
			gen byte basetime = 1 if time==691
			by dist_group7 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
			twoway (line lvol_`x'n  time if dist_group7==1, sort)  ///
					(line lvol_`x'n time if dist_group7==2, sort), ///
					legend(on lab(1 "<25 km") lab(2 ">200km")  col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Frontera: PRY") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\volumenes\prueba1\por frontera\PRY\q_dist7_`x'_PRY_smooth.png", replace		
	
restore 
}


 */



*dist_group8 1 "<50km paso fronterizo" 2 ">200km"

*Grupos de distancia 50km vs >200km 
gen dist_group10 = . 
replace dist_group10=1 if dist_minima<=50 & info_paso==22
replace dist_group10=2 if dist_minima>200 & dist_minima<300
label def dist_group10 1 "<50km paso fronterizo" 2 ">200km" 
label val dist_group10 dist_group10


 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="PRY"

	collapse (mean) lvol_`x'2 , by(dist_group8 time)
			gen byte basetime = 1 if time==691
			by dist_group8 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
			twoway  (connected lvol_`x'n  time if dist_group8==1, sort msize(small) lcolor(cranberry) mcolor(cranberry))  ///
					(connected lvol_`x'n time if dist_group8==2, sort msize(small) lcolor(ebblue) mcolor(ebblue)      ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (>200km)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	///
						ttext(1.12 708  "Exchange rate gap = 0"  1.12 730  "Exchange rate gap > 0", color(gs2) size(small))
			graph export "salidas\volumenes\prueba1\por frontera y menos pasos 1\q_dist8_`x'_PRY_smooth_c.png", replace		
	
restore 
}



*dist_group9 1 "<50km paso fronterizo" 2 "100-200km"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="PRY"

	collapse (mean) lvol_`x'2 , by(dist_group9 time)
			gen byte basetime = 1 if time==691
			by dist_group9 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
			twoway  (connected lvol_`x'n  time if dist_group9==1, sort msize(small) lcolor(cranberry) mcolor(cranberry))  ///
					(connected lvol_`x'n time if dist_group9==2, sort msize(small) lcolor(ebblue) mcolor(ebblue)      ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (100-200km)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	///
						ttext(1.12 708  "Exchange rate gap = 0"  1.12 730  "Exchange rate gap > 0", color(gs2) size(small))
			graph export "salidas\volumenes\prueba1\por frontera y menos pasos 1\q_dist9_`x'_PRY_smooth_c.png", replace		
	
restore 
}




*----------URUGUAY



*dist_group7 1 "<25km paso fronterizo" 2 ">200km"
/*  foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="URY"

	collapse (mean) lvol_`x'2 , by(dist_group7 time)
			gen byte basetime = 1 if time==691
			by dist_group7 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
			twoway (line lvol_`x'n  time if dist_group7==1, sort)  ///
					(line lvol_`x'n time if dist_group7==2, sort), ///
					legend(on lab(1 "<25 km") lab(2 ">200km")  col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Frontera: URY") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\volumenes\prueba1\por frontera\q_dist7_`x'_URY_smooth.png", replace		
	
restore 
}


*dist_group6 1 "<25km paso fronterizo" 2 ">25km" 
foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="URY"

	collapse (mean) lvol_`x'2, by(dist_group6 time)
			gen byte basetime = 1 if time==691
			by dist_group6 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time

			twoway (line lvol_`x'n  time if dist_group6==1, sort)  ///
					(line lvol_`x'n time if dist_group6==2, sort), ///
					legend(on lab(1 "<25 km") lab(2 ">25km")    col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Frontera: URY") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\volumenes\prueba1\por frontera\q_dist6_`x'_URY_smooth.png", replace		
restore 
}

 */



*dist_group8 1 "<50km paso fronterizo" 2 ">200km"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="URY"

	collapse (mean) lvol_`x'2 , by(dist_group8 time)
			gen byte basetime = 1 if time==691
			by dist_group8 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
			twoway  (connected lvol_`x'n  time if dist_group8==1, sort msize(small) lcolor(cranberry) mcolor(cranberry))  ///
					(connected lvol_`x'n time if dist_group8==2, sort msize(small) lcolor(ebblue) mcolor(ebblue)      ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (>200km)")  col(2) pos(6) region(lcolor(black)) ) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	///
						ttext(1.12 708  "Exchange rate gap = 0"  1.12 730  "Exchange rate gap > 0", color(gs2) size(small))
			graph export "salidas\volumenes\prueba1\por frontera y menos pasos 1\q_dist8_`x'_URY_smooth_c.png", replace		
restore 
}


*dist_group9 1 "<50km paso fronterizo" 2 "100-200km"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="URY"

	collapse (mean) lvol_`x'2 , by(dist_group9 time)
			gen byte basetime = 1 if time==691
			by dist_group9 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
			twoway  (connected lvol_`x'n  time if dist_group9==1, sort msize(small) lcolor(cranberry) mcolor(cranberry))  ///
					(connected lvol_`x'n time if dist_group9==2, sort msize(small) lcolor(ebblue) mcolor(ebblue)      ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (100-200km)")  col(2) pos(6) region(lcolor(black)) ) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	///
						ttext(1.12 708  "Exchange rate gap = 0"  1.12 730  "Exchange rate gap > 0", color(gs2) size(small))
			graph export "salidas\volumenes\prueba1\por frontera y menos pasos 1\q_dist9_`x'_URY_smooth_c.png", replace		
restore 
}





*----------CHILE


/* 
*dist_group7 1 "<25km paso fronterizo" 2 ">200km"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="CHL"

	collapse (mean) lvol_`x'2 , by(dist_group7 time)
			gen byte basetime = 1 if time==691
			by dist_group7 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
			twoway (line lvol_`x'n  time if dist_group7==1, sort)  ///
					(line lvol_`x'n time if dist_group7==2, sort), ///
					legend(on lab(1 "<25 km") lab(2 ">200km")  col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Frontera: CHL") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\volumenes\prueba1\por frontera\q_dist7_`x'_CHL_smooth.png", replace		
restore 
}


*dist_group6 1 "<25km paso fronterizo" 2 ">25km" 
foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="CHL"

	collapse (mean) lvol_`x'2, by(dist_group6 time)
			gen byte basetime = 1 if time==691
			by dist_group6 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]

			format %tm time
		
			twoway (line lvol_`x'n  time if dist_group6==1, sort)  ///
					(line lvol_`x'n time if dist_group6==2, sort), ///
					legend(on lab(1 "<25 km") lab(2 ">25km")    col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Frontera: CHL") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
				graph export "salidas\volumenes\prueba1\por frontera\q_dist6_`x'_CHL_smooth.png", replace		
	
restore 
}
 */


*dist_group8 1 "<50km paso fronterizo" 2 ">200km"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="CHL"

	collapse (mean) lvol_`x'2 , by(dist_group8 time)
			gen byte basetime = 1 if time==691
			by dist_group8 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
			twoway  (connected lvol_`x'n  time if dist_group8==1, sort msize(small) lcolor(cranberry) mcolor(cranberry))  ///
					(connected lvol_`x'n time if dist_group8==2, sort msize(small) lcolor(ebblue) mcolor(ebblue)      ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (>200km)")  col(2) pos(6) region(lcolor(black)) ) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	///
						ttext(1.12 708  "Exchange rate gap = 0"  1.12 730  "Exchange rate gap > 0", color(gs2) size(small))
			graph export "salidas\volumenes\prueba1\por frontera y menos pasos 1\q_dist8_`x'_CHL_smooth_c.png", replace		
restore 
}


*dist_group9 1 "<50km paso fronterizo" 2 "100-200km"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="CHL"

	collapse (mean) lvol_`x'2 , by(dist_group9 time)
			gen byte basetime = 1 if time==691
			by dist_group9 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
			twoway  (connected lvol_`x'n  time if dist_group9==1, sort msize(small) lcolor(cranberry) mcolor(cranberry))  ///
					(connected lvol_`x'n time if dist_group9==2, sort msize(small) lcolor(ebblue) mcolor(ebblue)      ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (100-200km)")  col(2) pos(6) region(lcolor(black)) ) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	///
						ttext(1.12 708  "Exchange rate gap = 0"  1.12 730  "Exchange rate gap > 0", color(gs2) size(small))
			graph export "salidas\volumenes\prueba1\por frontera y menos pasos 1\q_dist9_`x'_CHL_smooth_c.png", replace		
restore 
}




--






*---- (5.1) Volumenes por participacion de mercado: YPF vs RESTO 
preserve 
 drop if time < 691
	collapse (mean) lvol_pub2 , by(ypf time)
			gen byte basetime = 1 if time==691
			by ypf (basetime), sort: gen lvol_pubn = lvol_pub2 / lvol_pub2[1]
			
			format %tm time
			
			twoway (line  lvol_pubn time if ypf==1, sort)  ///
					(line lvol_pubn time if ypf==2, sort), ///
					legend(on lab(1 "YPF") lab(2 "Otras")  col(2) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: al público") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	///
						ttext(1.12 708  "Exchange rate gap = 0"  1.12 730  "Exchange rate gap > 0", color(gs2) size(small))
			graph export "salidas\volumenes\prueba1\q_ypf_publico_smooth.png", replace		
restore 


*---- (6) Volumenes por  bandera y distancia a la frontera 
*Ventas por bandera: cerca vs lejos 

local bandera "YPF SHELL AXION BLANCA PUMA OTRAS" 
local comp "pub transp"
gen band2 = "."
replace band2="YPF" if band==1 
replace band2="SHELL" if band==2 
replace band2="AXION" if band==3 
replace band2="BLANCA" if band==4
replace band2="PUMA" if band==5 
replace band2="OTRAS" if band==6 


gen band3="."
replace band3="YPF" if ypf==1 
replace band3="Otras" if ypf==2 
local bande "YPF Otras" 

*todas las banderas 
foreach m of local bandera { 
	foreach x of local comp { 
	preserve 
	keep if band2=="`m'" 
	drop if time < 691
	
	collapse (mean) lvol_`x'2, by(dist_group6 time)
			gen byte basetime = 1 if time==691
			by dist_group6 (basetime), sort: gen lvol_`x'2n = lvol_`x'2 / lvol_`x'2[1]
			
			
			format %tm time
		
			
			twoway (line lvol_`x'2n  time if dist_group6==1, sort)  ///
					(line lvol_`x'2n time if dist_group6==2, sort), ///
					legend(on lab(1 "<25 km") lab(2 ">25km")    col(2) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Bandera: `m'") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	///
			graph export "salidas\volumenes\prueba1\por bandera\q_dist6_`x'_`m'_smooth.png", replace		
restore 

}


		
}

*---- (8) Volumenes por  bandera, distancia a la frontera y pais fronterizo 

*BOL - todas las banderas 
/* foreach m of local bandera { 
	foreach x of local comp { 
	preserve 
	keep if band2=="`m'" & frontera_pais=="BOL"
	drop if time < 691
	
	collapse (mean) lvol_`x'2, by(dist_group6 time)
			gen byte basetime = 1 if time==691
			by dist_group6 (basetime), sort: gen lvol_`x'2n = lvol_`x'2 / lvol_`x'2[1]
			
			
			format %tm time
		
			
			twoway (line lvol_`x'2n  time if dist_group6==1, sort)  ///
					(line lvol_`x'2n time if dist_group6==2, sort), ///
					legend(on lab(1 "<25 km") lab(2 ">25km")    col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Bandera: `m'") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\volumenes\prueba1\por bandera\q_dist6_`x'_`m'_BOL_smooth.png", replace		
restore 

}		
} */

*BOL - YPF vs resto 
foreach m of local bande { 
	foreach x of local comp { 
	preserve 
	keep if band3=="`m'" & frontera_pais=="BOL"
	drop if time < 691
	
	collapse (mean) lvol_`x'2, by(dist_group8 time)
			gen byte basetime = 1 if time==691
			by dist_group8 (basetime), sort: gen lvol_`x'2n = lvol_`x'2 / lvol_`x'2[1]
			
			
			format %tm time
		
			
			twoway (line lvol_`x'2n  time if dist_group8==1, sort)  ///
					(line lvol_`x'2n time if dist_group8==2, sort), ///
					legend(on lab(1 "<50 km") lab(2 ">200km")    col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Bandera: `m'") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\volumenes\prueba1\por bandera\YPF vs resto\q_dist8_`x'_`m'_BOL_smooth.png", replace		
restore 

}		
}


*BRA - todas las banderas 
foreach m of local bandera { 
	foreach x of local comp { 
	preserve 
	keep if band2=="`m'" & frontera_pais=="BRA"
	drop if time < 691
	
	collapse (mean) lvol_`x'2, by(dist_group6 time)
			gen byte basetime = 1 if time==691
			by dist_group6 (basetime), sort: gen lvol_`x'2n = lvol_`x'2 / lvol_`x'2[1]
			
			
			format %tm time
		
			
			twoway (line lvol_`x'2n  time if dist_group6==1, sort)  ///
					(line lvol_`x'2n time if dist_group6==2, sort), ///
					legend(on lab(1 "<25 km") lab(2 ">25km")    col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Bandera: `m'") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\volumenes\prueba1\por bandera\q_dist6_`x'_`m'_BRA_smooth.png", replace		
restore 

}		
}

*BRA - YPF vs resto 
foreach m of local bande { 
	foreach x of local comp { 
	preserve 
	keep if band3=="`m'" & frontera_pais=="BRA"
	drop if time < 691
	
	collapse (mean) lvol_`x'2, by(dist_group8 time)
			gen byte basetime = 1 if time==691
			by dist_group8 (basetime), sort: gen lvol_`x'2n = lvol_`x'2 / lvol_`x'2[1]
			
			
			format %tm time
		
			
			twoway (line lvol_`x'2n  time if dist_group8==1, sort)  ///
					(line lvol_`x'2n time if dist_group8==2, sort), ///
					legend(on lab(1 "<50 km") lab(2 ">200km")    col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Bandera: `m'") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\volumenes\prueba1\por bandera\YPF vs resto\q_dist8_`x'_`m'_BRA_smooth.png", replace		
restore 

}		
}


*PRY-todas las banderas
foreach m of local bandera { 
	foreach x of local comp { 
	preserve 
	keep if band2=="`m'" & frontera_pais=="PRY"
	drop if time < 691
	
	collapse (mean) lvol_`x'2, by(dist_group6 time)
			gen byte basetime = 1 if time==691
			by dist_group6 (basetime), sort: gen lvol_`x'2n = lvol_`x'2 / lvol_`x'2[1]
			
			
			format %tm time
		
			
			twoway (line lvol_`x'2n  time if dist_group6==1, sort)  ///
					(line lvol_`x'2n time if dist_group6==2, sort), ///
					legend(on lab(1 "<25 km") lab(2 ">25km")    col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Bandera: `m'") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\volumenes\prueba1\por bandera\q_dist6_`x'_`m'_PRY_smooth.png", replace		
restore 

}		
}


*PRY - YPF vs resto 
foreach m of local bande { 
	foreach x of local comp { 
	preserve 
	keep if band3=="`m'" & frontera_pais=="PRY"
	drop if time < 691
	
	collapse (mean) lvol_`x'2, by(dist_group8 time)
			gen byte basetime = 1 if time==691
			by dist_group8 (basetime), sort: gen lvol_`x'2n = lvol_`x'2 / lvol_`x'2[1]
			
			
			format %tm time
		
			
			twoway (line lvol_`x'2n  time if dist_group8==1, sort)  ///
					(line lvol_`x'2n time if dist_group8==2, sort), ///
					legend(on lab(1 "<50 km") lab(2 ">200km")    col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Bandera: `m'") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\volumenes\prueba1\por bandera\YPF vs resto\q_dist8_`x'_`m'_PRY_smooth.png", replace		
restore 

}		
}


/* 

*CHL  
foreach m of local bandera { 
	foreach x of local comp { 
	preserve 
	keep if band2=="`m'" & frontera_pais=="CHL"
	drop if time < 691
	
	collapse (mean) lvol_`x'2, by(dist_group6 time)
			gen byte basetime = 1 if time==691
			by dist_group6 (basetime), sort: gen lvol_`x'2n = lvol_`x'2 / lvol_`x'2[1]
			
			
			format %tm time
		
			
			twoway (line lvol_`x'2n  time if dist_group6==1, sort)  ///
					(line lvol_`x'2n time if dist_group6==2, sort), ///
					legend(on lab(1 "<25 km") lab(2 ">25km")    col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Bandera: `m'") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\volumenes\prueba1\por bandera\q_dist6_`x'_`m'_CHL_smooth.png", replace		
restore 

}		
}

*URY
foreach m of local bandera { 
	foreach x of local comp { 
	preserve 
	keep if band2=="`m'" & frontera_pais=="CHL"
	drop if time < 691
	
	collapse (mean) lvol_`x'2, by(dist_group6 time)
			gen byte basetime = 1 if time==691
			by dist_group6 (basetime), sort: gen lvol_`x'2n = lvol_`x'2 / lvol_`x'2[1]
			
			
			format %tm time
		
			
			twoway (line lvol_`x'2n  time if dist_group6==1, sort)  ///
					(line lvol_`x'2n time if dist_group6==2, sort), ///
					legend(on lab(1 "<25 km") lab(2 ">25km")    col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Bandera: `m'") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\volumenes\prueba1\por bandera\q_dist6_`x'_`m'_URY_smooth.png", replace		
restore 

}		
}





 */


