***************************************
/* Dofile para ver si hay resultados en volumenes de venta cerca vs lejos en GASOIL 2 
	
	 VOLUMENES 
	 
 */
****************************************************************************************
use "bases\base-precios\p-pulidas-distancias\gasoil_2_2016_2022_v2.dta", clear 

tssmooth ma lvol_pub2=lvol_pub, window(2 0 1)

drop blue_venta blue_compra oficial_venta oficial_compra 



merge m:1 time using "bases\tc\tc-arg" , gen(merge_tc)
keep if merge_tc==3



/*  PRE TRATAMIENTO: BRECHA BAJA (SIN BARRIL CRIOLLO) 2017m8: 691 hasta 2019m10: 717
	POST TRATAMIENTO: BRECHA ALTA: 2019m12=719 adelante
  */



**********************************************************
*-- variables de distancias a la frontera (lineal)
**********************************************************

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


*Grupos de distancia 50km vs 100-200km 
gen dist_group9 = . 
replace dist_group9=1 if dist_minima<=50 
replace dist_group9=2 if dist_minima>=100 & dist_minima<=200 
label def dist_group9 1 "<50km paso fronterizo" 2 "100-200km" 
label val dist_group9 dist_group9


**********************************************************
*-- variables de distancias a la frontera (ruta y minutos) 
**********************************************************
*Grupos de distancia 50km vs >200km -este va- 
gen dist_group8 = . 
replace dist_group8=1 if dist_minima<=50
replace dist_group8=2 if dist_minima>=200
label def dist_group8 1 "<50km paso fronterizo" 2 ">200km" 
label val dist_group8 dist_group8

*Grupos de distancia 50km vs >200km -este va- RUTA
gen dist_group8_ruta = . 
replace dist_group8_ruta=1 if dist_minima_ruta<=50
replace dist_group8_ruta=2 if dist_minima_ruta>=200 
label def dist_group8_ruta 1 "<50km paso fronterizo" 2 ">200km" 
label val dist_group8_ruta dist_group8_ruta 


local treat "Treat (<50 km)" 
local control "Control (>200km)"

*Grupos de distancia 50km vs >200km -este va- MINUTOS 
gen dist_group8_minutos = . 
replace dist_group8_minutos=1 if dist_minima_minutos<=60
replace dist_group8_minutos=2 if dist_minima_minutos>=150
label def dist_group8_minutos 1 "<60min paso fronterizo" 2 ">150min" 
label val dist_group8_minutos dist_group8_minutos  

local treat_min "Treat (<60min)"
local control_min "Control (>150min)"



/* 


*Grupos de distancia 50km vs >100-200km -este probarlo- RUTA 
gen dist_group9_ruta = . 
replace dist_group9_ruta=1 if dist_minima_ruta<=50
replace dist_group9_ruta=2 if dist_minima_ruta>=100 & dist_minima_ruta<=200
label def dist_group9_ruta 1 "<50km paso fronterizo" 2 ">200km" 
label val dist_group9_ruta dist_group9_ruta



*Grupos de distancia 50km vs >100-200km -este probarlo- MINUTOS 
gen dist_group9_minutos = . 
replace dist_group9_minutos=1 if dist_minima_minutos<=60
replace dist_group9_minutos=2 if dist_minima_minutos>90 & dist_minima_minutos<=240
label def dist_group9_minutos 1 "<60 min paso fronterizo" 2 "90-240min" 
label val dist_group9_minutos dist_group9_minutos
 */

**********************************************************
*-- BANDERAS 
**********************************************************

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
replace ypf = 1 if band==1
replace ypf=2   if (band==2 | band==3 | band==4 | band==5 | band==6) 



*Para contar EESS por frontera y provincia 
gen aux = 1 
bysort id: gen count_eess = sum(aux)
replace count_eess = . if count_eess > 1 

*--DIST-GROUP8 
*[1] distancia lineal 
collect table frontera_pais provincia dist_group8 , stat(total count_eess) name(dist8_lineal)
*[2] distancia por ruta 
collect table frontera_pais provincia dist_group8_ruta , stat(total count_eess) name(dist8_ruta)
*[3] distancia en minutos 
collect table frontera_pais provincia dist_group8_minutos , stat(total count_eess) name(dist8_minutos)

/* *--DIST-GROUP9
*[1] distancia lineal 
collect table frontera_pais provincia dist_group9 , stat(total count_eess) name(dist9_lineal)
*[2] distancia por ruta 
collect table frontera_pais provincia dist_group9_ruta , stat(total count_eess) name(dist9_ruta)
*[3] distancia en minutos 
collect table frontera_pais provincia dist_group9_minutos , stat(total count_eess) name(dist9_minutos)
 */

/* 
collect export "salidas\descriptives\EESS-Gasoil2.xls", name(dist8_lineal) cell(a1) sheet(dist8) modify 
collect export "salidas\descriptives\EESS-Gasoil2.xls", name(dist8_ruta) cell(f1)  sheet(dist8) modify 
collect export "salidas\descriptives\EESS-Gasoil2.xls", name(dist8_minutos) cell(l1) sheet(dist8)  modify 

collect export "salidas\descriptives\EESS-Gasoil2.xls", name(dist9_lineal) cell(a1) sheet(dist9) modify 
collect export "salidas\descriptives\EESS-Gasoil2.xls", name(dist9_ruta) cell(f1)  sheet(dist9) modify 
collect export "salidas\descriptives\EESS-Gasoil2.xls", name(dist9_minutos) cell(l1) sheet(dist9)  modify 
 */





****************************************************************************************
****************************************************************************************
****************************************************************************************
****************************************************************************************


**********************************************************
*-- SERIES DE P por distancia a la frontera y tc  
**********************************************************

/* POST TRATAMIENTO: BRECHA ALTA: 2019m12=719 adelante
   PRE TRATAMIENTO: BRECHA BAJA (SIN BARRIL CRIOLLO) 2017m8: 691 hasta 2019m10: 717*/



***************************************************
*- Precio agregado Gasoil2 - TC Ofcial y TC blue -este va-
**************************************************
preserve 
 drop if time < 691 
	collapse (mean) p_surtidor_pub oficial_venta blue_venta, by(time) 
*28=2019m11 no va mas 
*25 = 2019m8
			gen p_surtidor_pubn = p_surtidor_pub / p_surtidor_pub[25]
			gen blue_ventan = blue_venta / blue_venta[25]
			gen oficial_ventan = oficial_venta / oficial_venta[25]
		
		
	twoway (connected p_surtidor_pubn time, sort cmissing(n) yaxis(1) msymbol(o) msize(small) lcolor(navy) mcolor(navy)) ///
			(line oficial_ventan time, sort cmissing(n) yaxis(1) lcolor(red) lpattern(shortdash) lwidth(medium)) ///
			(line blue_ventan time, sort cmissing(n) yaxis(1) lcolor(green) lpattern(shortdash) lwidth(medium)), ///
			yscale(range(0 4.5)) ///
	scheme(modern)  legend(on col(3) pos(6) region(lcolor(black)) ///
	lab(1 "Avg. Gasoil price") lab(2 "Official exchange rate") lab(3 "Informal exchange rate")) ///
	ytitle("Price index (2019 August = 100)", size(small))  xtitle("")  ///
	xlabel(691 700 707 715 722 730 739 749, valuelabels labsize(small) nogrid) ///
	ylabel(#10, labsize(small) nogrid axis(1))  ///
	xline(715, lpattern(dash) lcolor(black)) 
	
	graph export "salidas\archivos finales\p_tc_regular_gasoil.pdf", replace
	graph export "salidas\precios\precios y brecha tc\prueba2\gasoil\p_exchange_rate_gasoil.png", replace
restore 

--


***************************************************
*- Precio Treat/Control - este va 
**************************************************
*-DIST GROUP 8 - total 
/* 
preserve 
	drop if time < 691
	collapse (mean) p_surtidor_pub, by(dist_group8 time)
			gen byte basetime = 1 if time==718
			by dist_group8 (basetime), sort: gen p_surtidor_pubn = p_surtidor_pub / p_surtidor_pub[1]
			
			
twoway (connected  p_surtidor_pubn time if dist_group8==1, sort  msize(small) msymbol(t) lcolor(cranberry) mcolor(cranberry))  ///
	   (connected p_surtidor_pubn time  if dist_group8==2, sort msize(small) msymbol(t) lcolor(ebblue) mcolor(ebblue)) ,  ///
	  legend(on lab(1 "Avg. Price Treat (<50 km)") lab(2 "Avg. Price Control (>200km)")  col(2) pos(6)  region(lcolor(black))  ) ///
			yscale(range(1 4)) ///
			scheme(modern)   ///
			ytitle("") xtitle("")  ///
			xlabel(691 700 709 719 728 736 744 751, valuelabels  labsize(small) nogrid) ///
			ylabel(#10, labsize(small) nogrid)  ///	
			xline(719, lpattern(dash) lcolor(black)) 
			graph export "salidas\precios\precios y brecha tc\prueba2\gasoil\p_dist8_gasoil.png", replace		
restore 
 */

***************************************************
*- Precio Treat/Control por pais fronterizo  
**************************************************
/* 
*BOLIVIA: 
preserve 
	keep if frontera_pais=="BOL"
	drop if time < 691
	collapse (mean) p_surtidor_pub, by(dist_group8 time)
			gen byte basetime = 1 if time==718
			by dist_group8 (basetime), sort: gen p_surtidor_pubn = p_surtidor_pub / p_surtidor_pub[1]
			
			
twoway (connected  p_surtidor_pubn time if dist_group8==1, sort  msize(small) msymbol(t) lcolor(cranberry) mcolor(cranberry))  ///
	   (connected p_surtidor_pubn time  if dist_group8==2, sort msize(small) msymbol(t) lcolor(ebblue) mcolor(ebblue)) ,  ///
		legend(on lab(1 "Avg. Price Treat (<50 km)") lab(2 "Avg. Price Control (>200km)")  col(2) pos(6)  region(lcolor(black)) ) ///
		yscale(range(1 4)) ///
			scheme(modern)   ///
			ytitle("") xtitle("")  ///
			xlabel(691 700 709 719 728 736 744 751, valuelabels  labsize(small) nogrid) ///
			ylabel(#10, labsize(small) nogrid)  ///	
			xline(718, lpattern(dash) lcolor(black)) 
			graph export "salidas\precios\precios y brecha tc\prueba2\gasoil\p_dist8_BOL_gasoil.png", replace		
restore 


*BRASIL: 
preserve 
	keep if frontera_pais=="BRA"
	drop if time < 691
	collapse (mean) p_surtidor_pub, by(dist_group8 time)
			gen byte basetime = 1 if time==718
			by dist_group8 (basetime), sort: gen p_surtidor_pubn = p_surtidor_pub / p_surtidor_pub[1]
			
			
twoway (connected  p_surtidor_pubn time if dist_group8==1, sort  msize(small) msymbol(t) lcolor(cranberry) mcolor(cranberry))  ///
	   (connected p_surtidor_pubn time  if dist_group8==2, sort msize(small) msymbol(t) lcolor(ebblue) mcolor(ebblue)) ,  ///
	legend(on lab(1 "Avg. Price Treat (<50 km)") lab(2 "Avg. Price Control (>200km)")  col(2) pos(6)  region(lcolor(black)) ) ///
	 yscale(range(1 4)) ///
			scheme(modern)   ///
			ytitle("") xtitle("")  ///
			xlabel(691 700 709 719 728 736 744 751, valuelabels  labsize(small) nogrid) ///
			ylabel(#10, labsize(small) nogrid)  ///	
			xline(718, lpattern(dash) lcolor(black)) 
			graph export "salidas\precios\precios y brecha tc\prueba2\gasoil\p_dist8_BRA_gasoil.png", replace		
restore 


*PARAGUAY: 
preserve 
	keep if frontera_pais=="PRY"
	drop if time < 691
	collapse (mean) p_surtidor_pub, by(dist_group8 time)
			gen byte basetime = 1 if time==718
			by dist_group8 (basetime), sort: gen p_surtidor_pubn = p_surtidor_pub / p_surtidor_pub[1]
			
			
twoway (connected  p_surtidor_pubn time if dist_group8==1, sort  msize(small) msymbol(t) lcolor(cranberry) mcolor(cranberry))  ///
	   (connected p_surtidor_pubn time  if dist_group8==2, sort msize(small) msymbol(t) lcolor(ebblue) mcolor(ebblue)) ,  ///
	   legend(on lab(1 "Avg. Price Treat (<50 km)") lab(2 "Avg. Price Control (>200km)")  col(2) pos(6)  region(lcolor(black)) ) ///
			yscale(range(1 4)) ///
			scheme(modern)   ///
			ytitle("") xtitle("")  ///
			xlabel(691 700 709 719 728 736 744 751, valuelabels  labsize(small) nogrid) ///
			ylabel(#10, labsize(small) nogrid)  ///	
			xline(718, lpattern(dash) lcolor(black)) 
			graph export "salidas\precios\precios y brecha tc\prueba2\gasoil\p_dist8_PRY_gasoil.png", replace		
restore 


*CHILE:
preserve 
	keep if frontera_pais=="CHL"
	drop if time < 691
	collapse (mean) p_surtidor_pub, by(dist_group8 time)
			gen byte basetime = 1 if time==718
			by dist_group8 (basetime), sort: gen p_surtidor_pubn = p_surtidor_pub / p_surtidor_pub[1]
			
			
twoway (connected  p_surtidor_pubn time if dist_group8==1, sort  msize(small) msymbol(t) lcolor(cranberry) mcolor(cranberry))  ///
	   (connected p_surtidor_pubn time  if dist_group8==2, sort msize(small) msymbol(t) lcolor(ebblue) mcolor(ebblue)) ,  ///
	   legend(on lab(1 "Avg. Price Treat (<50 km)") lab(2 "Avg. Price Control (>200km)")  col(2) pos(6)  region(lcolor(black)) ) ///
			yscale(range(1 4)) ///
			scheme(modern)   ///
			ytitle("") xtitle("")  ///
			xlabel(691 700 709 719 728 736 744 751, valuelabels  labsize(small) nogrid) ///
			ylabel(#10, labsize(small) nogrid)  ///	
			xline(718, lpattern(dash) lcolor(black)) 
			graph export "salidas\precios\precios y brecha tc\prueba2\gasoil\p_dist8_CHL_gasoil.png", replace		
restore 



*URUGUAY:
preserve 
	keep if frontera_pais=="URY"
	drop if time < 691
	collapse (mean) p_surtidor_pub, by(dist_group8 time)
			gen byte basetime = 1 if time==718
			by dist_group8 (basetime), sort: gen p_surtidor_pubn = p_surtidor_pub / p_surtidor_pub[1]
			
			
twoway (connected  p_surtidor_pubn time if dist_group8==1, sort  msize(small) msymbol(t) lcolor(cranberry) mcolor(cranberry))  ///
	   (connected p_surtidor_pubn time  if dist_group8==2, sort msize(small) msymbol(t) lcolor(ebblue) mcolor(ebblue)) ,  ///
		legend(on lab(1 "Avg. Price Treat (<50 km)") lab(2 "Avg. Price Control (>200km)")  col(2) pos(6)  region(lcolor(black)) ) ///
			yscale(range(1 4)) ///
			scheme(modern)   ///
			ytitle("") xtitle("")  ///
			xlabel(691 700 709 719 728 736 744 751, valuelabels  labsize(small) nogrid) ///
			ylabel(#10, labsize(small) nogrid)  ///	
			xline(718, lpattern(dash) lcolor(black)) 
			graph export "salidas\precios\precios y brecha tc\prueba2\gasoil\p_dist8_URY_gasoil.png", replace		
restore 


 */


**********************************************************
*-- SERIES DE Q por distancia a la frontera 
**********************************************************

/* POST TRATAMIENTO: BRECHA ALTA: 2019m12=719 adelante
   PRE TRATAMIENTO: BRECHA BAJA (SIN BARRIL CRIOLLO) 2017m8: 691 hasta 2019m10: 717*/

*Q Agregada Treat/Control (DIST LINEAL): 
/* 
preserve 
 drop if time < 691
	collapse (mean) lvol_pub2, by(dist_group8 time)
			gen byte basetime = 1 if time==718
			by dist_group8 (basetime), sort: gen lvol_pubn = lvol_pub2 / lvol_pub2[1]
			format %tm time
			
	twoway (connected  lvol_pubn  time if dist_group8==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
			(connected lvol_pubn time if dist_group8==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (>200km)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\gasoil\q_gasoil_treat_control.png", replace				
		
restore 
 */

/* 
*Q Agregada Treat/Control (DIST LINEAL): (Sin CHL y URY) 
preserve 
 drop if time < 691
 keep if frontera_pais=="BOL" | frontera_pais=="BRA" | frontera_pais=="PRY" 
 
	collapse (mean) lvol_pub2, by(dist_group8 time)
			gen byte basetime = 1 if time==718
			by dist_group8 (basetime), sort: gen lvol_pubn = lvol_pub2 / lvol_pub2[1]
			format %tm time
			
	twoway (connected  lvol_pubn  time if dist_group8==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
			(connected lvol_pubn time if dist_group8==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (>200km)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\gasoil\q_gasoil_treat_control2.png", replace				
		
restore  */

*Q Agregada Treat/Control (DIST RUTA): (Sin CHL y URY) 
/* 
preserve 
 drop if time < 691
 keep if frontera_pais_ruta=="BOL" | frontera_pais_ruta=="BRA" | frontera_pais_ruta=="PRY" 
 
	collapse (mean) lvol_pub2, by(dist_group8_ruta time)
			gen byte basetime = 1 if time==718
			by dist_group8_ruta (basetime), sort: gen lvol_pubn = lvol_pub2 / lvol_pub2[1]
			format %tm time
			
	twoway (connected  lvol_pubn  time if dist_group8_ruta==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
			(connected lvol_pubn time if dist_group8_ruta==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (>200km)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\gasoil\q_gasoil_treat_control2_ruta.png", replace				
		
restore 
 */

*Q Agregada Treat/Control (DIST MINUTOS): (Sin CHL y URY) 
/* 
preserve 
 drop if time < 691
 keep if frontera_pais_minutos=="BOL" | frontera_pais_minutos=="BRA" | frontera_pais_minutos=="PRY" 
 
	collapse (mean) lvol_pub2, by(dist_group8_minutos time)
			gen byte basetime = 1 if time==718
			by dist_group8_minutos (basetime), sort: gen lvol_pubn = lvol_pub2 / lvol_pub2[1]
			format %tm time
			
twoway (connected  lvol_pubn  time if dist_group8_minutos==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
	  (connected lvol_pubn time if dist_group8_minutos==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<60 min)") lab(2 "Control (>150 min)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\gasoil\q_gasoil_treat_control2_minutos.png", replace				
		
restore  */



*---- (4) Volumen por  pais fronterizo 
*LAS EESS VENDEN Q DIFERENTES AL PUBLICO SEGUN LA FRONTERA? 
/* 
*Fronteras x distncia lineal 
preserve 
 drop if time < 691
	collapse (mean) lvol_pub2, by(frontera_pais time)
			gen byte basetime = 1 if time==718
			by frontera_pais (basetime), sort: gen lvol_pubn = lvol_pub2 / lvol_pub2[1]
			
			format %tm time
			
			twoway  (connected  lvol_pubn time if frontera_pais=="BOL", sort  msize(small) msymbol(t))  ///
					(connected lvol_pubn time if frontera_pais=="BRA", sort msize(small) msymbol(t)) ///
					(connected lvol_pubn time if frontera_pais=="CHL", sort msize(small) msymbol(t)) ///
					(connected lvol_pubn time if frontera_pais=="PRY", sort msize(small) msymbol(t)) ///
					(connected lvol_pubn time if frontera_pais=="URY", sort msize(small) msymbol(t)), ///
			legend(on lab(1 "BOL") lab(2 "BRA") lab(3 "CHL") lab(4 "PRY") lab(5 "URY") col(6) pos(6) region(lcolor(black))) ///
					ysc(r(0.89 1.1)) ///
					scheme(modern)  ///
					ytitle("") xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(0.89(0.05)1.10, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) 
			graph export "salidas\volumenes\prueba2\gasoil\q_gasoil_frontera.png", replace		
restore 

*Fronteras x distncia x ruta
preserve 
 drop if time < 691
	collapse (mean) lvol_pub2, by(frontera_pais_ruta time)
			gen byte basetime = 1 if time==718
			by frontera_pais_ruta (basetime), sort: gen lvol_pubn = lvol_pub2 / lvol_pub2[1]
			
			format %tm time
			
			twoway  (connected  lvol_pubn time if  frontera_pais_ruta=="BOL", sort  msize(small) msymbol(t))  ///
					(connected lvol_pubn time  if  frontera_pais_ruta=="BRA", sort msize(small) msymbol(t)) ///
					(connected lvol_pubn time  if  frontera_pais_ruta=="CHL", sort msize(small) msymbol(t)) ///
					(connected lvol_pubn time  if  frontera_pais_ruta=="PRY", sort msize(small) msymbol(t)) ///
					(connected lvol_pubn time  if  frontera_pais_ruta=="URY", sort msize(small) msymbol(t)), ///
			legend(on lab(1 "BOL") lab(2 "BRA") lab(3 "CHL") lab(4 "PRY") lab(5 "URY") col(6) pos(6) region(lcolor(black))) ///
					ysc(r(0.89 1.1)) ///
					scheme(modern)  ///
					ytitle("") xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(0.89(0.05)1.10, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) 
			graph export "salidas\volumenes\prueba2\gasoil\q_gasoil_frontera_ruta.png", replace		
restore 


*Fronteras x distncia x minutos 
preserve 
 drop if time < 691
	collapse (mean) lvol_pub2, by(frontera_pais_minutos time)
			gen byte basetime = 1 if time==718
			by frontera_pais_minutos (basetime), sort: gen lvol_pubn = lvol_pub2 / lvol_pub2[1]
			
			format %tm time
			
			twoway  (connected  lvol_pubn time if frontera_pais_minutos=="BOL", sort  msize(small) msymbol(t))  ///
					(connected lvol_pubn time  if frontera_pais_minutos=="BRA", sort msize(small) msymbol(t)) ///
					(connected lvol_pubn time  if frontera_pais_minutos=="CHL", sort msize(small) msymbol(t)) ///
					(connected lvol_pubn time  if frontera_pais_minutos=="PRY", sort msize(small) msymbol(t)) ///
					(connected lvol_pubn time  if frontera_pais_minutos=="URY", sort msize(small) msymbol(t)), ///
			legend(on lab(1 "BOL") lab(2 "BRA") lab(3 "CHL") lab(4 "PRY") lab(5 "URY") col(6) pos(6) region(lcolor(black))) ///
					ysc(r(0.89 1.1)) ///
					scheme(modern)  ///
					ytitle("") xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(0.89(0.05)1.10, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) 
			graph export "salidas\volumenes\prueba2\gasoil\q_gasoil_frontera_minutos.png", replace		
restore 

 */


**********************************************************************
*- POR PAIS FRONTERIZO 
**********************************************************************
local compradores "pub"

*-----BOLIVIA 
/* 
*DISTANCIA LINEAL: dist_group8 1 "<50km paso fronterizo" 2 ">200km"

 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="BOL"

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
			graph export "salidas\volumenes\prueba2\gasoil\q_gasoil_BOL.png", replace		
restore 
}

*DISTANCIA POR RUTA: dist_group8 1 "<50km paso fronterizo" 2 ">200km"
local compradores "pub"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="BOL"

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
			graph export "salidas\volumenes\prueba2\gasoil\q_gasoil_BOL_ruta.png", replace		
restore 
}

*DISTANCIA EN MINUTOS: dist_group8 1 "<50km paso fronterizo" 2 ">200km"
local compradores "pub"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="BOL"

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
			graph export "salidas\volumenes\prueba2\gasoil\q_gasoil_BOL_minutos.png", replace		
restore 
}
 */


*dist_group9 1 "<50km paso fronterizo" 2 "100-200km"
/* foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="BOL"

	collapse (mean) lvol_`x'2 , by(dist_group9 time)
			gen byte basetime = 1 if time==691
			by dist_group9 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
			twoway (connected  lvol_`x'n  time if dist_group9==1, sort msize(small) lcolor(cranberry) mcolor(cranberry)  )  ///
					(connected lvol_`x'n time if dist_group9==2, sort  msize(small) lcolor(ebblue) mcolor(ebblue)       ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (100-200km)")  col(2) pos(6) region(lcolor(black)) ) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	///
						ttext(1.12 708  "Exchange rate gap = 0"  1.12 730  "Exchange rate gap > 0", color(gs2) size(small))
			graph export "salidas\volumenes\prueba2\por frontera\q_dist9_`x'_BOL_smooth_c.png", replace		
restore 
}
 */



*-----BRASIL 
/* 
*DISTANCIA LINEAL: dist_group8 1 "<50km paso fronterizo" 2 ">200km"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="BRA"

	collapse (mean) lvol_`x'2 , by(dist_group8 time)
			gen byte basetime = 1 if time==718
			by dist_group8 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
		twoway (connected  lvol_`x'n  time if dist_group8==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
			(connected lvol_`x'n time if dist_group8==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "`treat'") lab(2 "`control'")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) name(lineal)
			*graph export "salidas\volumenes\prueba2\gasoil\q_gasoil_BRA.png", replace		
restore 
}

*DISTANCIA POR RUTA: dist_group8 1 "<50km paso fronterizo" 2 ">200km"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="BRA"

	collapse (mean) lvol_`x'2 , by(dist_group8_ruta time)
			gen byte basetime = 1 if time==718
			by dist_group8_ruta (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
twoway (connected  lvol_`x'n  time if dist_group8_ruta==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
			(connected lvol_`x'n time if dist_group8_ruta==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "`treat'") lab(2 "`control'")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) name(ruta)
			*graph export "salidas\volumenes\prueba2\gasoil\q_gasoil_BRA_ruta.png", replace		
restore 
}



*DISTANCIA EN MINUTOS: dist_group8 1 "<50km paso fronterizo" 2 ">200km"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="BRA"

	collapse (mean) lvol_`x'2 , by(dist_group8_minutos time)
			gen byte basetime = 1 if time==718
			by dist_group8 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
twoway (connected  lvol_`x'n  time if dist_group8_minutos==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
		(connected lvol_`x'n time if dist_group8_minutos==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "`treat_min'") lab(2 "`control_min'")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) name(minutos)
			*graph export "salidas\volumenes\prueba2\gasoil\q_gasoil_BRA_minutos.png", replace		
restore 
}
 
  */
 

 
*dist_group9 1 "<50km paso fronterizo" 2 "100-200km"
/*  foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="BRA"

	collapse (mean) lvol_`x'2 , by(dist_group9 time)
			gen byte basetime = 1 if time==691
			by dist_group9 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
			twoway (connected lvol_`x'n  time if dist_group9==1, sort msize(small) lcolor(cranberry) mcolor(cranberry))  ///
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
			graph export "salidas\volumenes\prueba2\por frontera\q_dist9_`x'_BRA_smooth_c.png", replace		
restore 
} */


*-----PARAGUAY 

/* 

*DISTANCIA LINEAL 
  foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="PRY" & provincia!="CHACO"

	collapse (mean) lvol_`x'2 , by(dist_group8 time)
			gen byte basetime = 1 if time==718
			by dist_group8 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
		twoway (connected  lvol_`x'n  time if dist_group8==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
			(connected lvol_`x'n time if dist_group8==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "`treat'") lab(2 "`control'")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\gasoil\q_gasoil_PRY_sin_CHACO.png", replace		
restore 
}


*DISTANCIA POR RUTA 
  foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="PRY" & provincia!="CHACO"

	collapse (mean) lvol_`x'2 , by(dist_group8_ruta time)
			gen byte basetime = 1 if time==718
			by dist_group8_ruta (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
twoway (connected  lvol_`x'n  time if dist_group8_ruta==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
		(connected lvol_`x'n time if dist_group8_ruta==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "`treat'") lab(2 "`control'")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\gasoil\q_gasoil_PRY_ruta_sin_CHACO.png", replace		
restore 
}


*DISTANCIA EN MINUTOS 
  foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="PRY" & provincia!="CHACO"
 
	collapse (mean) lvol_`x'2 , by(dist_group8_minutos time)
			gen byte basetime = 1 if time==718
			by dist_group8_minutos (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
twoway (connected  lvol_`x'n  time if dist_group8_minutos==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
		(connected lvol_`x'n time if dist_group8_minutos==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "`treat_min'") lab(2 "`control_min'")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\gasoil\q_gasoil_PRY_minutos_sin_CHACO.png", replace		
restore 
}

 */
 
 
 
/* 
*dist_group9 1 "<50km paso fronterizo" 2 "100-200km"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="PRY"

	collapse (mean) lvol_`x'2 , by(dist_group9 time)
			gen byte basetime = 1 if time==691
			by dist_group9 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
			twoway (connected lvol_`x'n  time if dist_group9==1, sort msize(small) lcolor(cranberry) mcolor(cranberry))  ///
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
			graph export "salidas\volumenes\prueba2\por frontera\q_dist9_`x'_PRY_smooth_c.png", replace		
	
restore 
} */





*-----URUGUAY 

*DISTANCIA LINEAL:
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="URY" & provincia!="CORRIENTES"

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
			graph export "salidas\volumenes\prueba2\gasoil\q_gasoil_URY_sin_CRRTES.png", replace		
restore 
}

*DISTANCIA POR RUTA:
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="URY" & provincia!="CORRIENTES"

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
			graph export "salidas\volumenes\prueba2\gasoil\q_gasoil_URY_ruta_sin_CRRTES.png", replace		
restore 
}

*DISTANCIA EN MINUTOS:
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="URY" & provincia!="CORRIENTES"

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
			graph export "salidas\volumenes\prueba2\gasoil\q_gasoil_URY_minutos_sin_CRRTES.png", replace		
restore 
}


  */


*dist_group9 1 "<50km paso fronterizo" 2 "100-200km"
/*  foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="URY"

	collapse (mean) lvol_`x'2 , by(dist_group9 time)
			gen byte basetime = 1 if time==691
			by dist_group9 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
			twoway (connected lvol_`x'n  time if dist_group9==1, sort msize(small) lcolor(cranberry) mcolor(cranberry))  ///
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
			graph export "salidas\volumenes\prueba2\por frontera\q_dist9_`x'_URY_smooth_c.png", replace		
	
restore 
}
 */




*-----CHILE 
/* 
*DISTANCIA LINEAL: 
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="CHL" & provincia!="MENDOZA" & provincia!="CATAMARCA" & provincia!="LA RIOJA" & provincia!="SALTA" & provincia!="SAN JUAN" & provincia!="TUCUMAN"

	collapse (mean) lvol_`x'2 , by(dist_group8 time)
			gen byte basetime = 1 if time==718
			by dist_group8 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
		twoway (connected  lvol_`x'n  time if dist_group8==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
			(connected lvol_`x'n time if dist_group8==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "`treat'") lab(2 "`control'")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) note("Sólo con EESS que tengan EESS en T y C (Chubut, NQN y Santa Cruz)", size(small)) 
			graph export "salidas\volumenes\prueba2\gasoil\q_gasoil_CHL_3.png", replace		
restore 
}


*DISTANCIA POR RUTA:  
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="CHL" & provincia!="MENDOZA" & provincia!="CATAMARCA" & provincia!="LA RIOJA" & provincia!="SALTA" & provincia!="SAN JUAN" & provincia!="TUCUMAN"

	collapse (mean) lvol_`x'2 , by(dist_group8_ruta time)
			gen byte basetime = 1 if time==718
			by dist_group8_ruta (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
twoway (connected  lvol_`x'n  time if dist_group8_ruta==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
			(connected lvol_`x'n time if dist_group8_ruta==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "`treat'") lab(2 "`control'")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) note("Sólo con EESS que tengan EESS en T y C (Chubut, NQN y Santa Cruz)", size(small)) 
			graph export "salidas\volumenes\prueba2\gasoil\q_gasoil_CHL_ruta_3.png", replace		
restore 
}


*DISTANCIA MINUTOS:
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="CHL" & provincia!="MENDOZA" & provincia!="CATAMARCA" & provincia!="LA RIOJA" & provincia!="SALTA" & provincia!="SAN JUAN" & provincia!="TUCUMAN"

	collapse (mean) lvol_`x'2 , by(dist_group8_minutos time)
			gen byte basetime = 1 if time==718
			by dist_group8_minutos (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
twoway (connected  lvol_`x'n  time if dist_group8_minutos==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
			(connected lvol_`x'n time if dist_group8_minutos==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "`treat_min'") lab(2 "`control_min'")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
				note("Sólo con EESS que tengan EESS en T y C (Chubut, NQN y Santa Cruz)", size(small)) 
			graph export "salidas\volumenes\prueba2\gasoil\q_gasoil_CHL_minutos_3.png", replace		
restore 
}

 */





*dist_group9 1 "<50km paso fronterizo" 2 "100-200km"
/*  foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="CHL"

	collapse (mean) lvol_`x'2 , by(dist_group9 time)
			gen byte basetime = 1 if time==691
			by dist_group9 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
			twoway (connected lvol_`x'n  time if dist_group9==1, sort msize(small) lcolor(cranberry) mcolor(cranberry))  ///
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
			graph export "salidas\volumenes\prueba2\por frontera\q_dist9_`x'_CHL_smooth_c.png", replace		
	
restore 
}
 */
























