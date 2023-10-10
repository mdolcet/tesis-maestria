

*GASOIL

use "bases\base-precios\p-pulidas-distancias\gasoil_2_2016_2022_v2.dta", clear 

tssmooth ma lvol_pub2=lvol_pub, window(2 0 1)

drop blue_venta blue_compra oficial_venta oficial_compra 

merge m:1 time using "bases\tc\tc-arg" , gen(merge_tc)
keep if merge_tc==3

*Grupos de distancia 50km vs >200km -este va- 
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


*Para contar EESS por frontera y provincia 
gen aux = 1 
bysort id: gen count_eess = sum(aux)
replace count_eess = . if count_eess > 1 

**********************************************************
*-- variables de distancias a la frontera (ruta y minutos) 
**********************************************************

*Grupos de distancia 50km vs >200km -este va- RUTA
gen dist_group8_ruta = . 
replace dist_group8_ruta=1 if dist_minima_ruta<=50
replace dist_group8_ruta=2 if dist_minima_ruta>200
label def dist_group8_ruta 1 "<50km paso fronterizo" 2 ">200km" 
label val dist_group8_ruta dist_group8_ruta 


*Grupos de distancia 50km vs >200km -este va- MINUTOS 
gen dist_group8_minutos = . 
replace dist_group8_minutos=1 if dist_minima_minutos<=60
replace dist_group8_minutos=2 if dist_minima_minutos>150
label def dist_group8_minutos 1 "<50km paso fronterizo" 2 ">200km" 
label val dist_group8_minutos dist_group8_minutos  

************************************************************************
local compradores "pub"


*MISIONES + CORRIENTES + ENTRE RIOS 

foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if provincia=="MISIONES" | provincia=="CORRIENTES" | provincia=="ENTRE RIOS"

	collapse (mean) lvol_`x'2 , by(dist_group8 time)
			gen byte basetime = 1 if time==718
			by dist_group8 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
		twoway (connected  lvol_`x'n  time if dist_group8==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
			(connected lvol_`x'n time if dist_group8==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (>200km)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\gasoil\provincias\q_gasoil_MCE.png", replace		
restore 
}

*DISTANCIA POR RUTA: dist_group8 1 "<50km paso fronterizo" 2 ">200km"
local compradores "pub"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if provincia=="MISIONES" | provincia=="CORRIENTES" | provincia=="ENTRE RIOS"

	collapse (mean) lvol_`x'2 , by(dist_group8_ruta time)
			gen byte basetime = 1 if time==718
			by dist_group8_ruta (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
twoway (connected  lvol_`x'n  time if dist_group8_ruta==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
		(connected lvol_`x'n time if dist_group8_ruta==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (>200km)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\gasoil\provincias\q_gasoil_MCE_ruta.png", replace		
restore 
}

*DISTANCIA EN MINUTOS: dist_group8 1 "<50km paso fronterizo" 2 ">200km"
local compradores "pub"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if provincia=="MISIONES" | provincia=="CORRIENTES" | provincia=="ENTRE RIOS"

	collapse (mean) lvol_`x'2 , by(dist_group8_minutos time)
			gen byte basetime = 1 if time==718
			by dist_group8_minutos (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
twoway (connected  lvol_`x'n  time if dist_group8_minutos==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
		(connected lvol_`x'n time if dist_group8_minutos==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<60 min)") lab(2 "Control (>150 min)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\gasoil\provincias\q_gasoil_MCE_minutos.png", replace		
restore 
}




*MISIONES + CORRIENTES 

/*  foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if provincia=="MISIONES" | provincia=="CORRIENTES"

	collapse (mean) lvol_`x'2 , by(dist_group8 time)
			gen byte basetime = 1 if time==718
			by dist_group8 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
		twoway (connected  lvol_`x'n  time if dist_group8==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
			(connected lvol_`x'n time if dist_group8==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (>200km)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\gasoil\provincias\q_gasoil_MC.png", replace		
restore 
}

*DISTANCIA POR RUTA: dist_group8 1 "<50km paso fronterizo" 2 ">200km"
local compradores "pub"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if provincia=="MISIONES" | provincia=="CORRIENTES"

	collapse (mean) lvol_`x'2 , by(dist_group8_ruta time)
			gen byte basetime = 1 if time==718
			by dist_group8_ruta (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
twoway (connected  lvol_`x'n  time if dist_group8_ruta==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
		(connected lvol_`x'n time if dist_group8_ruta==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (>200km)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\gasoil\provincias\q_gasoil_MC_ruta.png", replace		
restore 
}

*DISTANCIA EN MINUTOS: dist_group8 1 "<50km paso fronterizo" 2 ">200km"
local compradores "pub"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if provincia=="MISIONES" | provincia=="CORRIENTES"

	collapse (mean) lvol_`x'2 , by(dist_group8_minutos time)
			gen byte basetime = 1 if time==718
			by dist_group8_minutos (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
twoway (connected  lvol_`x'n  time if dist_group8_minutos==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
		(connected lvol_`x'n time if dist_group8_minutos==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<60 min)") lab(2 "Control (>150 min)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\gasoil\provincias\q_gasoil_MC_minutos.png", replace		
restore 
}
 */


*MISIONES + CORRIENTES + ENTRE RIOS 

/*  foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if provincia=="MISIONES" | provincia=="CORRIENTES" | provincia=="ENTRE RIOS"

	collapse (mean) lvol_`x'2 , by(dist_group8 time)
			gen byte basetime = 1 if time==718
			by dist_group8 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
		twoway (connected  lvol_`x'n  time if dist_group8==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
			(connected lvol_`x'n time if dist_group8==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (>200km)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\gasoil\provincias\q_gasoil_MCE.png", replace		
restore 
}

*DISTANCIA POR RUTA: dist_group8 1 "<50km paso fronterizo" 2 ">200km"
local compradores "pub"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if provincia=="MISIONES" | provincia=="CORRIENTES" | provincia=="ENTRE RIOS"

	collapse (mean) lvol_`x'2 , by(dist_group8_ruta time)
			gen byte basetime = 1 if time==718
			by dist_group8_ruta (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
twoway (connected  lvol_`x'n  time if dist_group8_ruta==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
		(connected lvol_`x'n time if dist_group8_ruta==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (>200km)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\gasoil\provincias\q_gasoil_MCE_ruta.png", replace		
restore 
}

*DISTANCIA EN MINUTOS: dist_group8 1 "<50km paso fronterizo" 2 ">200km"
local compradores "pub"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if provincia=="MISIONES" | provincia=="CORRIENTES" | provincia=="ENTRE RIOS"

	collapse (mean) lvol_`x'2 , by(dist_group8_minutos time)
			gen byte basetime = 1 if time==718
			by dist_group8_minutos (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
twoway (connected  lvol_`x'n  time if dist_group8_minutos==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
		(connected lvol_`x'n time if dist_group8_minutos==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<60 min)") lab(2 "Control (>150 min)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\gasoil\provincias\q_gasoil_MCE_minutos.png", replace		
restore 
}
 */

*FORMOSA 


/*  foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if provincia=="FORMOSA"

	collapse (mean) lvol_`x'2 , by(dist_group8 time)
			gen byte basetime = 1 if time==718
			by dist_group8 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
		twoway (connected  lvol_`x'n  time if dist_group8==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
			(connected lvol_`x'n time if dist_group8==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (>200km)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\gasoil\provincias\q_gasoil_F.png", replace		
restore 
}

*DISTANCIA POR RUTA: dist_group8 1 "<50km paso fronterizo" 2 ">200km"
local compradores "pub"
 foreach x of local compradores { 
preserve 
	drop if time < 691
keep if provincia=="FORMOSA"

	collapse (mean) lvol_`x'2 , by(dist_group8_ruta time)
			gen byte basetime = 1 if time==718
			by dist_group8_ruta (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
twoway (connected  lvol_`x'n  time if dist_group8_ruta==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
		(connected lvol_`x'n time if dist_group8_ruta==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (>200km)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\gasoil\provincias\q_gasoil_F_ruta.png", replace		
restore 
}

*DISTANCIA EN MINUTOS: dist_group8 1 "<50km paso fronterizo" 2 ">200km"
local compradores "pub"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if provincia=="FORMOSA"

	collapse (mean) lvol_`x'2 , by(dist_group8_minutos time)
			gen byte basetime = 1 if time==718
			by dist_group8_minutos (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
twoway (connected  lvol_`x'n  time if dist_group8_minutos==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
		(connected lvol_`x'n time if dist_group8_minutos==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<60 min)") lab(2 "Control (>150 min)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\gasoil\provincias\q_gasoil_F_minutos.png", replace		
restore 
}
 */


*SALTA + JUJUY 
/*  foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if provincia=="SALTA" & frontera_pais=="BOL"
	*| provincia=="JUJUY"

	collapse (mean) lvol_`x'2 , by(dist_group8 time)
			gen byte basetime = 1 if time==718
			by dist_group8 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
		twoway (connected  lvol_`x'n  time if dist_group8==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
			(connected lvol_`x'n time if dist_group8==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (>200km)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\gasoil\provincias\q_gasoil_SALTA.png", replace		
restore 
}

*DISTANCIA POR RUTA: dist_group8 1 "<50km paso fronterizo" 2 ">200km"
local compradores "pub"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if provincia=="SALTA" & frontera_pais=="BOL"
	*| provincia=="JUJUY"
	
	collapse (mean) lvol_`x'2 , by(dist_group8_ruta time)
			gen byte basetime = 1 if time==718
			by dist_group8_ruta (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
twoway (connected  lvol_`x'n  time if dist_group8_ruta==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
		(connected lvol_`x'n time if dist_group8_ruta==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (>200km)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\gasoil\provincias\q_gasoil_SALTA_ruta.png", replace		
restore 
}

*DISTANCIA EN MINUTOS: dist_group8 1 "<50km paso fronterizo" 2 ">200km"
local compradores "pub"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if provincia=="SALTA" & frontera_pais=="BOL"
	*| provincia=="JUJUY"
	
	collapse (mean) lvol_`x'2 , by(dist_group8_minutos time)
			gen byte basetime = 1 if time==718
			by dist_group8_minutos (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
twoway (connected  lvol_`x'n  time if dist_group8_minutos==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
		(connected lvol_`x'n time if dist_group8_minutos==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<60 min)") lab(2 "Control (>150 min)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\gasoil\provincias\q_gasoil_SALTA_minutos.png", replace		
restore 
}
 
 */





*CHUBUT SANTA CRUZ Y NEUQUEN 
/* 
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if provincia=="CHUBUT" | provincia=="NEUQUEN" | provincia=="SANTA CRUZ"
	
	collapse (mean) lvol_`x'2 , by(dist_group8 time)
			gen byte basetime = 1 if time==718
			by dist_group8 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
		twoway (connected  lvol_`x'n  time if dist_group8==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
			(connected lvol_`x'n time if dist_group8==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (>200km)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\gasoil\provincias\q_gasoil_SUR.png", replace		
restore 
}



*DISTANCIA POR RUTA: dist_group8 1 "<50km paso fronterizo" 2 ">200km"
local compradores "pub"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if provincia=="SANTA CRUZ" |provincia=="CHUBUT" |  provincia=="NEUQUEN"  

	collapse (mean) lvol_`x'2 , by(dist_group8_ruta time)
			gen byte basetime = 1 if time==718
			by dist_group8_ruta (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
twoway (connected  lvol_`x'n  time if dist_group8_ruta==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
		(connected lvol_`x'n time if dist_group8_ruta==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (>200km)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\gasoil\provincias\q_gasoil_SUR_ruta.png", replace		
restore 
}




*DISTANCIA EN MINUTOS: dist_group8 1 "<50km paso fronterizo" 2 ">200km"
local compradores "pub"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if provincia=="CHUBUT" | provincia=="NEUQUEN" | provincia=="SANTA CRUZ"

	collapse (mean) lvol_`x'2 , by(dist_group8_minutos time)
			gen byte basetime = 1 if time==718
			by dist_group8_minutos (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
twoway (connected  lvol_`x'n  time if dist_group8_minutos==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
		(connected lvol_`x'n time if dist_group8_minutos==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<60 min)") lab(2 "Control (>150 min)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\gasoil\provincias\q_gasoil_SUR_minutos.png", replace		
restore 
}
 */





*-------------------------------------------------------------------------------------------------*
*-NAFTA 
*-------------------------------------------------------------------------------------------------*

*use "bases\base-precios\p-pulidas-distancias\nafta_2_2016_2022_v2.dta", clear 


*Ventas por comprador: Moving average: 2 periodos antes, el 0 y 1+
/* 
tssmooth ma lvol_pub2=lvol_pub, window(2 0 1)




*Para contar EESS por frontera y provincia 
gen aux = 1 
bysort id: gen count_eess = sum(aux)
replace count_eess = . if count_eess > 1 

**********************************************************
*-- variables de distancias a la frontera (ruta y minutos) 
**********************************************************
*Grupos de distancia 50km vs >200km -este- 
gen dist_group8 = . 
replace dist_group8=1 if dist_minima<=50
replace dist_group8=2 if dist_minima>200 & dist_minima<=250 
label def dist_group8 1 "<50km paso fronterizo" 2 ">200km" 
label val dist_group8 dist_group8


*Grupos de distancia 50km vs >200km -este va- RUTA
gen dist_group8_ruta = . 
replace dist_group8_ruta=1 if dist_minima_ruta<=50
replace dist_group8_ruta=2 if dist_minima_ruta>=200 
label def dist_group8_ruta 1 "<50km paso fronterizo" 2 ">200km" 
label val dist_group8_ruta dist_group8_ruta 


*Grupos de distancia 50km vs >200km -este va- MINUTOS 
gen dist_group8_minutos = . 
replace dist_group8_minutos=1 if dist_minima_minutos<=60
replace dist_group8_minutos=2 if dist_minima_minutos>=150
label def dist_group8_minutos 1 "<60km paso fronterizo" 2 ">150 min" 
label val dist_group8_minutos dist_group8_minutos  

local compradores "pub"
 */
 
 
 


*MISIONES + CORRIENTES 
 
/* 
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if (provincia=="CHACO" | provincia=="FORMOSA" | provincia=="MISIONES") & frontera_pais=="PRY"
	*| provincia=="CORRIENTES"

	collapse (mean) lvol_`x'2 , by(dist_group8 time)
			gen byte basetime = 1 if time==718
			by dist_group8 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
		twoway (connected  lvol_`x'n  time if dist_group8==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
			(connected lvol_`x'n time if dist_group8==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (>200km)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) name(lineal)
			*graph export "salidas\volumenes\prueba2\nafta\provincias\q_nafta_CORRIENTES_PRY.png", replace		
restore 
}

*DISTANCIA POR RUTA: dist_group8 1 "<50km paso fronterizo" 2 ">200km"
local compradores "pub"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if (provincia=="CHACO" | provincia=="FORMOSA" | provincia=="MISIONES") & frontera_pais=="PRY"
	*| provincia=="CORRIENTES"

	collapse (mean) lvol_`x'2 , by(dist_group8_ruta time)
			gen byte basetime = 1 if time==718
			by dist_group8_ruta (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
twoway (connected  lvol_`x'n  time if dist_group8_ruta==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
		(connected lvol_`x'n time if dist_group8_ruta==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (>200km)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) name(ruta)
			*graph export "salidas\volumenes\prueba2\nafta\provincias\q_nafta_CORRIENTES_PRY_ruta.png", replace		
restore 
}

*DISTANCIA EN MINUTOS: dist_group8 1 "<50km paso fronterizo" 2 ">200km"
local compradores "pub"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if (provincia=="CHACO" | provincia=="FORMOSA" | provincia=="MISIONES") & frontera_pais=="PRY"
	*| provincia=="CORRIENTES"

	collapse (mean) lvol_`x'2 , by(dist_group8_minutos time)
			gen byte basetime = 1 if time==718
			by dist_group8_minutos (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
twoway (connected  lvol_`x'n  time if dist_group8_minutos==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
		(connected lvol_`x'n time if dist_group8_minutos==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<60 min)") lab(2 "Control (>150 min)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) name(minutos)
			*graph export "salidas\volumenes\prueba2\nafta\provincias\q_nafta_CORRIENTES_PRY_minutos.png", replace		
restore 
}

 */






*MISIONES + CORRIENTES + ENTRE RIOS 
/* 
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if provincia=="MISIONES" | provincia=="CORRIENTES" | provincia=="ENTRE RIOS"

	collapse (mean) lvol_`x'2 , by(dist_group8 time)
			gen byte basetime = 1 if time==718
			by dist_group8 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
		twoway (connected  lvol_`x'n  time if dist_group8==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
			(connected lvol_`x'n time if dist_group8==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (>200km)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\nafta\provincias\q_nafta_MCE.png", replace		
restore 
}

*DISTANCIA POR RUTA: dist_group8 1 "<50km paso fronterizo" 2 ">200km"
local compradores "pub"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if provincia=="MISIONES" | provincia=="CORRIENTES" | provincia=="ENTRE RIOS"

	collapse (mean) lvol_`x'2 , by(dist_group8_ruta time)
			gen byte basetime = 1 if time==718
			by dist_group8_ruta (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
twoway (connected  lvol_`x'n  time if dist_group8_ruta==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
		(connected lvol_`x'n time if dist_group8_ruta==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (>200km)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\nafta\provincias\q_nafta_MCE_ruta.png", replace		
restore 
}

*DISTANCIA EN MINUTOS: dist_group8 1 "<50km paso fronterizo" 2 ">200km"
local compradores "pub"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if provincia=="MISIONES" | provincia=="CORRIENTES" | provincia=="ENTRE RIOS"

	collapse (mean) lvol_`x'2 , by(dist_group8_minutos time)
			gen byte basetime = 1 if time==718
			by dist_group8_minutos (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
twoway (connected  lvol_`x'n  time if dist_group8_minutos==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
		(connected lvol_`x'n time if dist_group8_minutos==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<60 min)") lab(2 "Control (>150 min)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\nafta\provincias\q_nafta_MCE_minutos.png", replace		
restore 
}
 */



*FORMOSA
/* 
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if provincia=="FORMOSA"

	collapse (mean) lvol_`x'2 , by(dist_group8 time)
			gen byte basetime = 1 if time==718
			by dist_group8 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
		twoway (connected  lvol_`x'n  time if dist_group8==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
			(connected lvol_`x'n time if dist_group8==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (>200km)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\nafta\provincias\q_nafta_F.png", replace		
restore 
}

*DISTANCIA POR RUTA: dist_group8 1 "<50km paso fronterizo" 2 ">200km"
local compradores "pub"
 foreach x of local compradores { 
preserve 
	drop if time < 691
keep if provincia=="FORMOSA"

	collapse (mean) lvol_`x'2 , by(dist_group8_ruta time)
			gen byte basetime = 1 if time==718
			by dist_group8_ruta (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
twoway (connected  lvol_`x'n  time if dist_group8_ruta==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
		(connected lvol_`x'n time if dist_group8_ruta==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (>200km)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\nafta\provincias\q_nafta_F_ruta.png", replace		
restore 
}

*DISTANCIA EN MINUTOS: dist_group8 1 "<50km paso fronterizo" 2 ">200km"
local compradores "pub"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if provincia=="FORMOSA"

	collapse (mean) lvol_`x'2 , by(dist_group8_minutos time)
			gen byte basetime = 1 if time==718
			by dist_group8_minutos (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
twoway (connected  lvol_`x'n  time if dist_group8_minutos==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
		(connected lvol_`x'n time if dist_group8_minutos==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<60 min)") lab(2 "Control (>150 min)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\nafta\provincias\q_nafta_F_minutos.png", replace		
restore 
}
 */
 
 
 
*SALTA + JUJUY 
/* 
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if provincia=="SALTA" | provincia=="JUJUY"
	
	collapse (mean) lvol_`x'2 , by(dist_group8 time)
			gen byte basetime = 1 if time==718
			by dist_group8 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
		twoway (connected  lvol_`x'n  time if dist_group8==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
			(connected lvol_`x'n time if dist_group8==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (>200km)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\nafta\provincias\q_nafta_SJ.png", replace		
restore 
}

*DISTANCIA POR RUTA: dist_group8 1 "<50km paso fronterizo" 2 ">200km"
local compradores "pub"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if provincia=="SALTA" | provincia=="JUJUY"

	collapse (mean) lvol_`x'2 , by(dist_group8_ruta time)
			gen byte basetime = 1 if time==718
			by dist_group8_ruta (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
twoway (connected  lvol_`x'n  time if dist_group8_ruta==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
		(connected lvol_`x'n time if dist_group8_ruta==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (>200km)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\nafta\provincias\q_nafta_SJ_ruta.png", replace		
restore 
}

*DISTANCIA EN MINUTOS: dist_group8 1 "<50km paso fronterizo" 2 ">200km"
local compradores "pub"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if provincia=="SALTA" | provincia=="JUJUY"

	collapse (mean) lvol_`x'2 , by(dist_group8_minutos time)
			gen byte basetime = 1 if time==718
			by dist_group8_minutos (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
twoway (connected  lvol_`x'n  time if dist_group8_minutos==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
		(connected lvol_`x'n time if dist_group8_minutos==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<60 min)") lab(2 "Control (>150 min)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\nafta\provincias\q_nafta_SJ_minutos.png", replace		
restore 
}
  */
  
  
  
  
*CHUBUT NEUQUEN SANTA CRUZ 
/* 
 foreach x of local compradores { 
preserve 
	drop if time < 691
keep if provincia=="CHUBUT" | provincia=="NEUQUEN" | provincia=="SANTA CRUZ"
	
	collapse (mean) lvol_`x'2 , by(dist_group8 time)
			gen byte basetime = 1 if time==718
			by dist_group8 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
		twoway (connected  lvol_`x'n  time if dist_group8==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
			(connected lvol_`x'n time if dist_group8==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (>200km)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\nafta\provincias\q_nafta_SUR.png", replace		
restore 
}

*DISTANCIA POR RUTA: dist_group8 1 "<50km paso fronterizo" 2 ">200km"
local compradores "pub"
 foreach x of local compradores { 
preserve 
	drop if time < 691 
	keep  if provincia=="CHACO"
*keep  if provincia=="SANTA CRUZ"  | provincia=="CHUBUT"  | provincia=="NEUQUEN" 
*

	collapse (mean) lvol_`x'2 , by(dist_group8_ruta time)
			gen byte basetime = 1 if time==718
			by dist_group8_ruta (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
twoway (connected  lvol_`x'n  time if dist_group8_ruta==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
		(connected lvol_`x'n time if dist_group8_ruta==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (>200km)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\nafta\provincias\q_nafta_CHACO_ruta.png", replace		
restore 
}

*DISTANCIA EN MINUTOS: dist_group8 1 "<50km paso fronterizo" 2 ">200km"
local compradores "pub"
 foreach x of local compradores { 
preserve 
	drop if time < 691 
keep  if provincia=="CHACO"
* provincia=="SANTA CRUZ" | provincia=="CHUBUT" | provincia=="NEUQUEN"
*| | provincia=="SANTA CRUZ" provincia=="CHUBUT" 

	collapse (mean) lvol_`x'2 , by(dist_group8_minutos time)
			gen byte basetime = 1 if time==718
			by dist_group8_minutos (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
twoway (connected  lvol_`x'n  time if dist_group8_minutos==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
		(connected lvol_`x'n time if dist_group8_minutos==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<60 min)") lab(2 "Control (>150 min)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\nafta\provincias\q_nafta_CHACO_minutos.png", replace		
restore 
}
 */
