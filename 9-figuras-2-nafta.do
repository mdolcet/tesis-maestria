***************************************
/* Dofile para buscar algun tratamiento que sirva: 
	
	GOAL: ENCONTRAR UN PERIODO PRE Y POST TREATMENT: BRECHA ALTA 
	 
	 
	 PRECIOS 
	 
 */
**************************************** 

*use "bases\base-precios\p-pulidas-distancias\nafta_2_2005_2022.dta", clear

*seteo panel mensual (di tm(2014,1) mensual di qm(2014,1) trimestral) 
*tsset id time

*guardo una base aux para correr mas rapido (672= 2016m1) :
/* preserve
drop if time<672 
save "bases\base-precios\p-pulidas-distancias\nafta_2_2016_2022.dta", replace 
restore 

 */
**************************************************

set autotabgraph on 

use "bases\base-precios\p-pulidas-distancias\nafta_2_2016_2022_v2.dta", clear 


**********************************************************
*-- variables de distancias a la frontera (linea)
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


*Grupos de distancia 50km vs >200km -este- 
gen dist_group8 = . 
replace dist_group8=1 if dist_minima<=50
replace dist_group8=2 if dist_minima>=200
label def dist_group8 1 "<50km paso fronterizo" 2 ">200km" 
label val dist_group8 dist_group8

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
label def dist_group8_minutos 1 "<60min paso fronterizo" 2 ">150min" 
label val dist_group8_minutos dist_group8_minutos  




**********************************************************
*-- variables de distancias a la frontera (ruta y minutos) 
**********************************************************
*Grupos de distancia 50km vs >100-200km -este probarlo- 
gen dist_group9 = . 
replace dist_group9=1 if dist_minima<=50
replace dist_group9=2 if dist_minima>=200 
label def dist_group9 1 "<50km paso fronterizo" 2 "200-250km" 
label val dist_group9 dist_group9

local treat "Treat (<50 km)" 
local control "Control (>200km)"


*Grupos de distancia 50km vs >100-200km -este probarlo- RUTA 
gen dist_group9_ruta = . 
replace dist_group9_ruta=1 if dist_minima_ruta<=50
replace dist_group9_ruta=2 if dist_minima_ruta>=200
label def dist_group9_ruta 1 "<50km paso fronterizo" 2 "200-250km" 
label val dist_group9_ruta dist_group9_ruta

*Grupos de distancia 50km vs >100-200km -este probarlo- MINUTOS 
gen dist_group9_minutos = . 
replace dist_group9_minutos=1 if dist_minima_minutos<=50
replace dist_group9_minutos=2 if dist_minima_minutos>=120 & dist_minima_minutos<=180
label def dist_group9_minutos 1 "<40 min paso fronterizo" 2 "135-175min" 
label val dist_group9_minutos dist_group9_minutos

local treat_min "Treat (<50min)"
local control_min "Control (120-180min)"


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


*Ventas por comprador: Moving average: 2 periodos antes, el 0 y 1+
tssmooth ma lvol_pub2=lvol_pub, window(2 0 1)
tssmooth ma lvol_transp2=lvol_transp, window(3 0 1)
tssmooth ma lvol_agro2=lvol_agro, window(3 0 1)
tssmooth ma lvol_osectores2=lvol_osectores, window(3 0 1)
tssmooth ma lvol_oeess2=lvol_oeess, window(3 0 1)

**********************************************************
*-- RECUENTO DE EESS POR FRONTERA Y POR PROVINCIA 
**********************************************************

*para contar EESS
egen id_count2 = group(id frontera_pais) 
local distancias "dist_group1 dist_group2 dist_group3 dist_group4 dist_group5 dist_group6 dist_group7 dist_group8"

*Para contar EESS por frontera y provincia 
gen aux = 1 
bysort id: gen count_eess = sum(aux)
replace count_eess = . if count_eess > 1 



/*
*--DIST-GROUP8 
*[1] distancia lineal 
collect table frontera_pais provincia dist_group8 , stat(total count_eess) name(dist8_lineal)
*[2] distancia por ruta 
collect table frontera_pais provincia dist_group8_ruta , stat(total count_eess) name(dist8_ruta)
*[3] distancia en minutos 
collect table frontera_pais provincia dist_group8_minutos , stat(total count_eess) name(dist8_minutos)

*--DIST-GROUP9
*[1] distancia lineal 
collect table frontera_pais provincia dist_group9 , stat(total count_eess) name(dist9_lineal)
*[2] distancia por ruta 
collect table frontera_pais provincia dist_group9_ruta , stat(total count_eess) name(dist9_ruta)
*[3] distancia en minutos 
collect table frontera_pais provincia dist_group9_minutos , stat(total count_eess) name(dist9_minutos)


 
collect export "salidas\descriptives\EESS-Nafta2.xls", name(dist8_lineal) cell(a1) sheet(dist8) modify 
collect export "salidas\descriptives\EESS-Nafta2.xls", name(dist8_ruta) cell(f1)  sheet(dist8) modify 
collect export "salidas\descriptives\EESS-Nafta2.xls", name(dist8_minutos) cell(l1) sheet(dist8)  modify 

collect export "salidas\descriptives\EESS-Nafta2.xls", name(dist9_lineal) cell(a1) sheet(dist9) modify 
collect export "salidas\descriptives\EESS-Nafta2.xls", name(dist9_ruta) cell(f1)  sheet(dist9) modify 
collect export "salidas\descriptives\EESS-Nafta2.xls", name(dist9_minutos) cell(l1) sheet(dist9)  modify 

 */





***************************************************
*- Precio agregado nafta2 y TC oficial 
**************************************************
/*  preserve 
 drop if time < 691 
	collapse (mean) p_surtidor_pub oficial_venta, by(time) 
		gen p_surtidorn_pub = p_surtidor_pub / p_surtidor_pub[1]
		
		
		gen oficial_ventan = oficial_venta / oficial_venta[1]
		
			twoway (line p_surtidorn_pub time, sort cmissing(n) yaxis(1)) ///
					(line oficial_ventan time, sort cmissing(n) lcolor(red) lpattern(shortdash) lwidth(medium)), ///
			scheme(modern)  legend(on col(6) pos(6) lab(1 "Precio promedio venta al público") lab(2 "Tipo de cambio oficial")) ///
			ytitle("") xtitle("")  ///
			xlabel(691 700 709 719 728 736 744 751, valuelabels labsize(small) nogrid) ///
			ylabel(#10, labsize(small) nogrid)  ///
			xline(719, lpattern(dash) lcolor(black)) ///
			plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
			plotregion(fcolor(gs15)) 
		graph export "salidas\precios\precios y brecha tc\prueba1\p_alpublico.png", replace
restore 
 */

***************************************************
*- Precio agregado nafta2 - TC Ofcial y TC blue 
**************************************************
/*  preserve 
 drop if time < 691 
	collapse (mean) p_surtidor_pub oficial_venta blue_venta, by(time) 
		gen p_surtidorn_pub = p_surtidor_pub / p_surtidor_pub[1]
		
		gen blue_ventan = blue_venta / blue_venta[1]
		gen oficial_ventan = oficial_venta / oficial_venta[1]
		
			twoway (line p_surtidorn_pub time, sort cmissing(n) yaxis(1)) ///
					(line oficial_ventan time, sort cmissing(n) yaxis(1) lcolor(red) lpattern(shortdash) lwidth(medium)) ///
					(line blue_ventan time, sort cmissing(n) yaxis(1) lcolor(green) lpattern(shortdash) lwidth(medium)), ///
			scheme(modern)  legend(on col(6) pos(6) lab(1 "Precio promedio venta al público") lab(2 "Tipo de cambio oficial") lab(3 "Tipo de cambio paralelo")) ///
			ytitle("")  xtitle("")  ///
			xlabel(691 700 709 719 728 736 744 751, valuelabels labsize(small) nogrid) ///
			ylabel(#10, labsize(small) nogrid axis(1))  ///
			xline(719, lpattern(dash) lcolor(black)) ///
			plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
			plotregion(fcolor(gs15)) 
		graph export "salidas\precios\precios y brecha tc\prueba1\p_alpublico_paralelo.png", replace
restore 
 */





*V2: - este va a la tesis (2023)
preserve 
 drop if time < 691 
	collapse (mean) p_surtidor_pub oficial_venta blue_venta, by(time) 
   *28 = 2019m11 no va mas 
   *25 = 2019m8
		gen p_surtidorn_pub = p_surtidor_pub / p_surtidor_pub[25]
		gen blue_ventan = blue_venta / blue_venta[25]
		gen oficial_ventan = oficial_venta / oficial_venta[25]
		
	twoway (connected p_surtidorn_pub time, sort cmissing(n) yaxis(1) msymbol(o) msize(small) lcolor(navy) mcolor(navy)) ///
			(line oficial_ventan time, sort cmissing(n) yaxis(1) lcolor(red) lpattern(shortdash) lwidth(medium)) ///
			(line blue_ventan time, sort cmissing(n) yaxis(1) lcolor(green) lpattern(shortdash) lwidth(medium)), ///
				yscale(range(0 4)) ///
	scheme(modern)  legend(on col(3) pos(6) region(lcolor(black)) ///
	lab(1 "Avg. Regular Gasoline price") lab(2 "Official exchange rate") lab(3 "Informal exchange rate")) ///
	ytitle("Price index (2019 August = 100)", size(small))  xtitle("")  ///
	xlabel(691 700 707 715 722 730 739 749, valuelabels labsize(small) nogrid) ///
	ylabel(#10, labsize(small) nogrid axis(1))  ///
	xline(715, lpattern(dash) lcolor(black)) 
	
	graph export "salidas/archivos finales/p_tc_regular_gasoline.pdf", replace
	graph export "salidas\precios\precios y brecha tc\prueba2\nafta\p_exchange_rate_nafta_super.png", replace
restore 

 */



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
			scheme(modern)   ///
			yscale(range(1 3)) ///
			ytitle("") xtitle("")  ///
			xlabel(691 700 709 719 728 736 744 751, valuelabels  labsize(small) nogrid) ///
			ylabel(#10, labsize(small) nogrid)  ///	
			xline(718, lpattern(dash) lcolor(black)) 
			graph export "salidas\precios\precios y brecha tc\prueba2\nafta\p_dist8_nafta.png", replace		
restore 
 */



***************************************************
*- Precio Treat/Control por pais fronterizo  -estos van-
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
			scheme(modern)   ///
			yscale(range(1 3)) ///
			ytitle("") xtitle("")  ///
			xlabel(691 700 709 719 728 736 744 751, valuelabels  labsize(small) nogrid) ///
			ylabel(#10, labsize(small) nogrid)  ///	
			xline(718, lpattern(dash) lcolor(black)) 
			graph export "salidas\precios\precios y brecha tc\prueba2\nafta\p_dist8_BOL_nafta.png", replace		
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
			scheme(modern)   ///
			yscale(range(1 3)) ///
			ytitle("") xtitle("")  ///
			xlabel(691 700 709 719 728 736 744 751, valuelabels  labsize(small) nogrid) ///
			ylabel(#10, labsize(small) nogrid)  ///	
			xline(718, lpattern(dash) lcolor(black)) 
			graph export "salidas\precios\precios y brecha tc\prueba2\nafta\p_dist8_BRA_nafta.png", replace		
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
			scheme(modern)   ///
			yscale(range(1 3)) ///
			ytitle("") xtitle("")  ///
			xlabel(691 700 709 719 728 736 744 751, valuelabels  labsize(small) nogrid) ///
			ylabel(#10, labsize(small) nogrid)  ///	
			xline(718, lpattern(dash) lcolor(black)) 
			graph export "salidas\precios\precios y brecha tc\prueba2\nafta\p_dist8_PRY_nafta.png", replace		
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
			yscale(range(1 3)) ///
			scheme(modern)   ///
			ytitle("") xtitle("")  ///
			xlabel(691 700 709 719 728 736 744 751, valuelabels  labsize(small) nogrid) ///
			ylabel(#10, labsize(small) nogrid)  ///	
			xline(718, lpattern(dash) lcolor(black)) 
			graph export "salidas\precios\precios y brecha tc\prueba2\nafta\p_dist8_CHL_nafta.png", replace		
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
			yscale(range(1 3)) ///
			scheme(modern)   ///
			ytitle("") xtitle("")  ///
			xlabel(691 700 709 719 728 736 744 751, valuelabels  labsize(small) nogrid) ///
			ylabel(#10, labsize(small) nogrid)  ///	
			xline(718, lpattern(dash) lcolor(black)) 
			graph export "salidas\precios\precios y brecha tc\prueba2\nafta\p_dist8_URY_nafta.png", replace		
restore 



 */

**********************************************************
*-- SERIES DE VOLUMENES DE VENTA TREAT / CONTROL 
**********************************************************

/* POST TRATAMIENTO: BRECHA ALTA: 2019m11=718 adelante
   PRE TRATAMIENTO: BRECHA BAJA (SIN BARRIL CRIOLLO) 2017m8: 691 hasta 2019m10: 717*/

/* 
*Q Agregada Treat/Control (DISTANCIA LINEAL): 

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
			graph export "salidas\volumenes\prueba2\nafta\q_nafta_treat_control.png", replace				
		
restore 

*Q Agregada Treat/Control (DISTANCIA LINEAL): (Sin CHL y URY) 
preserve 
 drop if time < 691
 keep if frontera_pais=="BOL" | frontera_pais=="BRA" | frontera_pais=="PRY" 
 
	collapse (mean) lvol_pub2, by(dist_group8 time)
			gen byte basetime = 1 if time==718
			by dist_group8 (basetime), sort: gen lvol_pubn = lvol_pub2 / lvol_pub2[1]
			format %tm time
			
	twoway (connected  lvol_pubn  time if dist_group8==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
			(connected lvol_pubn time if dist_group8==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (>200km)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\nafta\q_nafta_treat_control2.png", replace				
		
restore 

*Q Agregada Treat/Control (DISTANCIA POR RUTA): (Sin CHL y URY) 
preserve 
 drop if time < 691
 keep if frontera_pais_ruta=="BOL" | frontera_pais_ruta=="BRA" | frontera_pais_ruta=="PRY" 
 
	collapse (mean) lvol_pub2, by(dist_group8_ruta time)
			gen byte basetime = 1 if time==718
			by dist_group8_ruta (basetime), sort: gen lvol_pubn = lvol_pub2 / lvol_pub2[1]
			format %tm time
			
	twoway (connected  lvol_pubn  time if dist_group8_ruta==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
			(connected lvol_pubn time if dist_group8_ruta==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (>200km)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\nafta\q_nafta_treat_control2_ruta.png", replace				
		
restore 


*Q Agregada Treat/Control (DISTANCIA MINUTOS): (Sin CHL y URY) 
preserve 
 drop if time < 691
 keep if frontera_pais_minutos=="BOL" | frontera_pais_minutos=="BRA" | frontera_pais_minutos=="PRY" 
 
	collapse (mean) lvol_pub2, by(dist_group8_minutos time)
			gen byte basetime = 1 if time==718
			by dist_group8_minutos (basetime), sort: gen lvol_pubn = lvol_pub2 / lvol_pub2[1]
			format %tm time
			
	twoway (connected  lvol_pubn  time if dist_group8_minutos==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
			(connected lvol_pubn time if dist_group8_minutos==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)), ///
					legend(on lab(1 "Treat (<60 min)") lab(2 "Control (>150 min)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) 
			graph export "salidas\volumenes\prueba2\nafta\q_nafta_treat_control2_minutos.png", replace				
		
restore 
 */

*---- (4) Volumen por  pais fronterizo 
*LAS EESS VENDEN Q DIFERENTES AL PUBLICO SEGUN LA FRONTERA? 

/* 
*Fronteras x distancia lineal 
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
			graph export "salidas\volumenes\prueba2\nafta\q_nafta_frontera.png", replace		
restore 

*Fronteras x distancia x ruta 
preserve 
 drop if time < 691
	collapse (mean) lvol_pub2, by(frontera_pais_ruta time)
			gen byte basetime = 1 if time==718
			by frontera_pais_ruta (basetime), sort: gen lvol_pubn = lvol_pub2 / lvol_pub2[1]
			
			format %tm time
			
			twoway  (connected  lvol_pubn time if frontera_pais_ruta=="BOL", sort  msize(small) msymbol(t))  ///
					(connected lvol_pubn time  if frontera_pais_ruta=="BRA", sort msize(small) msymbol(t)) ///
					(connected lvol_pubn time  if frontera_pais_ruta=="CHL", sort msize(small) msymbol(t)) ///
					(connected lvol_pubn time  if frontera_pais_ruta=="PRY", sort msize(small) msymbol(t)) ///
					(connected lvol_pubn time  if frontera_pais_ruta=="URY", sort msize(small) msymbol(t)), ///
			legend(on lab(1 "BOL") lab(2 "BRA") lab(3 "CHL") lab(4 "PRY") lab(5 "URY") col(6) pos(6) region(lcolor(black))) ///
					ysc(r(0.89 1.1)) ///
					scheme(modern)  ///
					ytitle("") xtitle("")  ///
					xlabel(#20, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(0.89(0.05)1.10, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) 
			graph export "salidas\volumenes\prueba2\nafta\q_nafta_frontera_ruta.png", replace		
restore 


*Fronteras x distancia en minutos 
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
			graph export "salidas\volumenes\prueba2\nafta\q_nafta_frontera_minutos.png", replace		
restore 

 */




**********************************************************************
*- VOLUMENES DE VENTA POR TREAT/CONTROL Y POR PAIS FRONTERIZO 
**********************************************************************
local compradores "pub"

*-----BOLIVIA 
/* 

*DISTANCIA LINEAL:  dist_group8 1 "<50km paso fronterizo" 2 ">200km"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="BOL" 
	keep if provincia=="SALTA" 	| provincia=="JUJUY"
    
	collapse (mean) lvol_`x'2 , by(dist_group9 time)
			gen byte basetime = 1 if time==718
			by dist_group9 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
		twoway (connected  lvol_`x'n  time if dist_group9==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
			(connected lvol_`x'n time if dist_group9==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (200-250km)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) name(dist9lineal)
			*graph export "salidas\volumenes\prueba2\nafta\q_nafta_BOL.png", replace		
restore 
}


*DISTANCIA POR RUTA:  dist_group8 1 "<50km paso fronterizo" 2 ">200km"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais_ruta=="BOL"
	keep if provincia=="SALTA" 	| provincia=="JUJUY"

	collapse (mean) lvol_`x'2 , by(dist_group9_ruta time)
			gen byte basetime = 1 if time==718
			by dist_group9_ruta (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
twoway (connected  lvol_`x'n  time if dist_group9_ruta==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
	(connected lvol_`x'n time if dist_group9_ruta==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (200-250km)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) name(dist9ruta)
			*graph export "salidas\volumenes\prueba2\nafta\q_nafta_BOL_ruta.png", replace		
restore 
}

*DISTANCIA EN MINUTOS:  dist_group8 1 "<50km paso fronterizo" 2 ">200km"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais_minutos=="BOL"
	keep if provincia=="SALTA" 	| provincia=="JUJUY"
	
	
	collapse (mean) lvol_`x'2 , by(dist_group9_minutos time)
			gen byte basetime = 1 if time==718
			by dist_group9_minutos (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
twoway (connected  lvol_`x'n  time if dist_group9_minutos==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
			(connected lvol_`x'n time if dist_group9_minutos==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<40 min)") lab(2 "Control (135-175 min)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) name(dist9mins)
			*graph export "salidas\volumenes\prueba2\nafta\q_nafta_BOL_minutos.png", replace		
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
	*keep if provincia=="CORRIENTES"

	collapse (mean) lvol_`x'2 , by(dist_group9 time)
			gen byte basetime = 1 if time==718
			by dist_group9 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
		twoway (connected  lvol_`x'n  time if dist_group9==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
			(connected lvol_`x'n time if dist_group9==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (200-250km)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) name(lineal) 
			
			*graph export "salidas\volumenes\prueba2\nafta\q_nafta_BRA.png", replace		
restore 
}

*DISTANCIA X RUTA: dist_group8 1 "<50km paso fronterizo" 2 ">200km"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais_ruta=="BRA"

	collapse (mean) lvol_`x'2 , by(dist_group9_ruta time)
			gen byte basetime = 1 if time==718
			by dist_group9_ruta (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
twoway (connected  lvol_`x'n  time if dist_group9_ruta==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
			(connected lvol_`x'n time if dist_group9_ruta==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<50 km)") lab(2 "Control (200-250km)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) name(ruta)
			
			*graph export "salidas\volumenes\prueba2\nafta\q_nafta_BRA_ruta.png", replace		
restore 
}

*DISTANCIA EN MINUTOS: dist_group8 1 "<50km paso fronterizo" 2 ">200km"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais_minutos=="BRA"

	collapse (mean) lvol_`x'2 , by(dist_group9_minutos time)
			gen byte basetime = 1 if time==718
			by dist_group9_minutos (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
twoway (connected  lvol_`x'n  time if dist_group9_minutos==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
	(connected lvol_`x'n time if dist_group9_minutos==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "Treat (<40 min)") lab(2 "Control (>135-175 min)")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) name(minutos)
			
			*graph export "salidas\volumenes\prueba2\nafta\q_nafta_BRA_minutos.png", replace		
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

*DISTANCIA LINEAL:
  foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if  provincia=="MISIONES" | provincia=="CHACO"
	keep if frontera_pais=="PRY" 

	collapse (mean) lvol_`x'2 , by(dist_group9 time)
			gen byte basetime = 1 if time==718
			by dist_group9 (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
		twoway (connected  lvol_`x'n  time if dist_group9==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
			(connected lvol_`x'n time      if dist_group9==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "`treat'") lab(2 "`control'")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) name(lineal)
			
			*graph export "salidas\volumenes\prueba2\nafta\q_nafta_PRY.png", replace		
restore 
}

*DISTANCIA POR RUTA: 
  foreach x of local compradores { 
preserve 
	drop if time < 691
		keep if provincia=="CHACO" | provincia=="MISIONES" 
	keep if frontera_pais_ruta=="PRY"

	collapse (mean) lvol_`x'2 , by(dist_group9_ruta time)
			gen byte basetime = 1 if time==718
			by dist_group9_ruta (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
twoway (connected  lvol_`x'n  time if dist_group9_ruta==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
	(connected lvol_`x'n time if dist_group9_ruta==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)     ), ///
					legend(on lab(1 "`treat'") lab(2 "`control'")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) name(ruta)
			
			*graph export "salidas\volumenes\prueba2\nafta\q_nafta_PRY_ruta.png", replace		
restore 
}

*DISTANCIA EN MINUTOS:
  foreach x of local compradores { 
preserve 
	drop if time < 691
		keep if provincia=="CHACO" | provincia=="MISIONES" 
	keep if frontera_pais_minutos=="PRY"

	collapse (mean) lvol_`x'2 , by(dist_group9_minutos time)
			gen byte basetime = 1 if time==718
			by dist_group9_minutos (basetime), sort: gen lvol_`x'n = lvol_`x'2 / lvol_`x'2[1]
			
			format %tm time
			
twoway (connected  lvol_`x'n  time if dist_group9_minutos==1, sort msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))  ///
	   (connected lvol_`x'n time if dist_group9_minutos==2,  sort msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)), ///
					legend(on lab(1 "`treat_min'") lab(2 "`control_min'")  col(2) pos(6) region(lcolor(black))) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#11, valuelabels  labsize(small) nogrid) ///
					ylabel(0.8(0.05)1.15, labsize(small) nogrid)  ///
					xline(718, lpattern(dash) lcolor(black)) ///
				ttext(1.12 708  "Exchange rate gap = 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) ///
	            ttext(1.12 730  "Exchange rate gap > 0", color(black) size(small) box lcolor(black) fcolor(white) margin(vsmall)) name(minutos)
				
			*graph export "salidas\volumenes\prueba2\nafta\q_nafta_PRY_minutos.png", replace		
restore 
}


--


*dist_group9 1 "<50km paso fronterizo" 2 "100-200km"
/*  foreach x of local compradores { 
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
}
 */




*-----URUGUAY 
/* 
*DISTANCIA LINEAL: 
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="URY"

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
			graph export "salidas\volumenes\prueba2\nafta\q_nafta_URY.png", replace		
restore 
}

*DISTANCIA POR RUTA: 
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais_ruta=="URY"

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
			graph export "salidas\volumenes\prueba2\nafta\q_nafta_URY_ruta.png", replace		
restore 
}

*DISTANCIA EN MINUTOS: 
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais_minutos=="URY"

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
			graph export "salidas\volumenes\prueba2\nafta\q_nafta_URY_minutos.png", replace		
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
*DISTANCIA LINEAL 
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="CHL"

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
			graph export "salidas\volumenes\prueba2\nafta\q_nafta_CHL.png", replace		
restore 
}


*DISTANCIA POR RUTA 
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais_ruta=="CHL"

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
			graph export "salidas\volumenes\prueba2\nafta\q_nafta_CHL_ruta.png", replace		
restore 
}


*DISTANCIA EN MINUTOS 
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais_minutos=="CHL"

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
			graph export "salidas\volumenes\prueba2\nafta\q_nafta_CHL_minutos.png", replace		
restore 
}


 */



 
 
 
**********************************************************
*-- SERIES DE P por COMPRADOR 
**********************************************************

/* POST TRATAMIENTO: BRECHA ALTA: 2019m12=719 adelante
   PRE TRATAMIENTO: BRECHA BAJA (SIN BARRIL CRIOLLO) 2017m8: 691 hasta 2019m10: 717*/


*---- (1) Precios por comprador y tipo de cambio 
 preserve 
 drop if time < 691 
	collapse (mean) p_surtidor_pub p_surtidor_transp p_surtidor_agro p_surtidor_oeess p_surtidor_osectores oficial_venta, by(time) 
		gen p_surtidorn_pub = p_surtidor_pub / p_surtidor_pub[1]
		gen p_surtidorn_transp = p_surtidor_transp / p_surtidor_transp[1]
		gen p_surtidorn_agro = p_surtidor_agro / p_surtidor_agro[1]
		gen p_surtidorn_oeess = p_surtidor_oeess / p_surtidor_oeess[1]
		gen p_surtidorn_osectores = p_surtidor_osectores / p_surtidor_osectores[1]
		
		gen oficial_ventan = oficial_venta / oficial_venta[1]
		
			twoway (line p_surtidorn_pub time, sort cmissing(n) yaxis(1)) ///
					(line p_surtidorn_transp time, sort cmissing(n) yaxis(1)) ///
					(line p_surtidorn_agro time, sort cmissing(n) yaxis(1)) ///
					(line p_surtidorn_oeess time, sort cmissing(n) yaxis(1)) ///
					(line p_surtidorn_osectores time, sort cmissing(n) yaxis(1)) ///
					(line oficial_ventan time, sort cmissing(n) yaxis(2) lcolor(red) lpattern(shortdash) lwidth(medium)), ///
			scheme(modern)  legend(on col(6) pos(6) lab(1 "Al público") lab(2 "Transporte") lab(3 "Agro") lab(4 "Otras EESS") lab(5 "Otros sectores") lab(6 "tc oficial")) ///
			ytitle("", axis(1)) ytitle("", axis(2)) xtitle("")  ///
			xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
			ylabel(#15, labsize(small) nogrid axis(1)) ylabel(#15, labsize(small) nogrid axis(2))  ///
			xline(719, lpattern(dash) lcolor(black)) ///
			plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
			plotregion(fcolor(gs15)) 
		graph export "salidas\precios\precios y brecha tc\prueba1\p_sectores.png", replace
restore 

*---- (2) Precios al publico, tipo de cambio por bandera 
preserve 
 drop if time < 691
	collapse (mean) p_surtidor_pub oficial_venta, by(band time)
			gen byte basetime = 1 if time==691
			by band (basetime), sort: gen p_surtidor_pubn = p_surtidor_pub / p_surtidor_pub[1]
			gen oficial_ventan = oficial_venta / oficial_venta[1]
			
			format %tm time
			format oficial_ventan %8.0g
			
			twoway (line p_surtidor_pubn time if band==1, sort)  ///
					(line p_surtidor_pubn time if band==2, sort) ///
					(line p_surtidor_pubn time if band==3, sort) ///
					(line p_surtidor_pubn time if band==4, sort) ///
					(line p_surtidor_pubn time if band==5, sort) ///
					(line p_surtidor_pubn time if band==6, sort) ///
					(line oficial_ventan time, sort yaxis(2) lcolor(red) lpattern(shortdash) lwidth(medium)), ///
					legend(on lab(1 "YPF") lab(2 "Shell") lab(3 "Axion") lab(4 "Blanca") lab(5 "Puma") lab(6 "Otras") col(6) pos(6)) ///
					scheme(modern)   ///
					ytitle("", axis(1)) ytitle("", axis(2)) xtitle("")  ///
					xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: al público") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\precios\precios y brecha tc\prueba1\p_bandera_publico.png", replace		
restore 

*---- (3) Precios por comprador y distancia a la frontera 
*RETOMAR DESDE ACA ¿HAY UN DIFERENCIAL DE P CUANDO LA BRECHA ES ALTA?????????????????????????
local compradores "pub transp agro oeess osectores" 


*-DIST GROUP 1 
/*  foreach x of local compradores { 
preserve 
	drop if time < 691

	collapse (mean) p_surtidor_`x' oficial_venta, by(dist_group1 time)
			gen byte basetime = 1 if time==691
			by dist_group1 (basetime), sort: gen p_surtidor_`x'n = p_surtidor_`x' / p_surtidor_`x'[1]
			gen oficial_ventan = oficial_venta / oficial_venta[1]
			
			format %tm time
			format oficial_ventan %8.0g
			
			twoway (line p_surtidor_`x'n  time if dist_group1==1, sort)  ///
					(line p_surtidor_`x'n time if dist_group1==2, sort) ///
					(line p_surtidor_`x'n time if dist_group1==3, sort) ///
					(line p_surtidor_`x'n time if dist_group1==4, sort) ///
					(line oficial_ventan time, sort yaxis(2) lcolor(red) lpattern(shortdash) lwidth(medium)), ///
					legend(on lab(1 "<50 km") lab(2 "50-100km") lab(3 "100-150km") lab(4 ">150km") lab(5 "tc oficial") col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("", axis(1)) ytitle("", axis(2)) xtitle("")  ///
					xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x'") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\precios\precios y brecha tc\prueba1\p_dist1_`x'.png", replace		
restore 
}
 */




*-DIST GROUP 2
/*  foreach x of local compradores { 
preserve 
	drop if time < 691

	collapse (mean) p_surtidor_`x' oficial_venta, by(dist_group2 time)
			gen byte basetime = 1 if time==691
			by dist_group2 (basetime), sort: gen p_surtidor_`x'n = p_surtidor_`x' / p_surtidor_`x'[1]
			gen oficial_ventan = oficial_venta / oficial_venta[1]
			
			format %tm time
			format oficial_ventan %8.0g
			
			twoway (line p_surtidor_`x'n  time if dist_group2==1, sort)  ///
					(line p_surtidor_`x'n time if dist_group2==2, sort) ///
					(line p_surtidor_`x'n time if dist_group2==3, sort) ///
					(line oficial_ventan time, sort yaxis(2) lcolor(red) lpattern(shortdash) lwidth(medium)), ///
					legend(on lab(1 "<75 km") lab(2 "75-150km") lab(3 ">150km")  lab(4 "tc oficial") col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("", axis(1)) ytitle("", axis(2)) xtitle("")  ///
					xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x'") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\precios\precios y brecha tc\prueba1\p_dist2_`x'.png", replace		
restore 
}

 */


*-DIST GROUP 5
*1 "<50km paso fronterizo" 2 ">50km" 
/* 
 foreach x of local compradores { 
preserve 
	drop if time < 691

	collapse (mean) p_surtidor_`x' oficial_venta, by(dist_group5 time)
			gen byte basetime = 1 if time==691
			by dist_group5 (basetime), sort: gen p_surtidor_`x'n = p_surtidor_`x' / p_surtidor_`x'[1]
			gen oficial_ventan = oficial_venta / oficial_venta[1]
			
			format %tm time
			format oficial_ventan %8.0g
			
			twoway (line p_surtidor_`x'n  time if dist_group5==1, sort)  ///
					(line p_surtidor_`x'n time if dist_group5==2, sort) ///
					(line oficial_ventan time, sort yaxis(2) lcolor(red) lpattern(shortdash) lwidth(medium)), ///
					legend(on lab(1 "<50 km") lab(2 ">50km")   lab(3 "tc oficial") col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("", axis(1)) ytitle("", axis(2)) xtitle("")  ///
					xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x'") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\precios\precios y brecha tc\prueba1\p_dist5_`x'.png", replace		
restore 
}
 */

*--DIST GROUP 6
*1 "<25km paso fronterizo" 2 ">25km" 
*con tc: 
/*  foreach x of local compradores { 
preserve 
	drop if time < 691

	collapse (mean) p_surtidor_`x' oficial_venta, by(dist_group6 time)
			gen byte basetime = 1 if time==691
			by dist_group6 (basetime), sort: gen p_surtidor_`x'n = p_surtidor_`x' / p_surtidor_`x'[1]
			gen oficial_ventan = oficial_venta / oficial_venta[1]
			
			format %tm time
			format oficial_ventan %8.0g
			
			twoway (line p_surtidor_`x'n  time if dist_group6==1, sort)  ///
					(line p_surtidor_`x'n time if dist_group6==2, sort) ///
					(line oficial_ventan time, sort yaxis(2) lcolor(red) lpattern(shortdash) lwidth(medium)), ///
					legend(on lab(1 "<25 km") lab(2 ">25km")   lab(3 "tc oficial") col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("", axis(1)) ytitle("", axis(2)) xtitle("")  ///
					xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x'") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\precios\precios y brecha tc\prueba1\p_dist6_`x'.png", replace		
restore 
}

 */

*sin tc:
/*  foreach x of local compradores { 
preserve 
	drop if time < 691

	collapse (mean) p_surtidor_`x', by(dist_group6 time)
			gen byte basetime = 1 if time==691
			by dist_group6 (basetime), sort: gen p_surtidor_`x'n = p_surtidor_`x' / p_surtidor_`x'[1]
			
			
			format %tm time
		
			
			twoway (line p_surtidor_`x'n  time if dist_group6==1, sort)  ///
					(line p_surtidor_`x'n time if dist_group6==2, sort), ///
					legend(on lab(1 "<25 km") lab(2 ">25km")    col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x'") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\precios\precios y brecha tc\prueba1\p_dist6_`x'_2.png", replace		
restore 
}
 */


*--DIST GROUP 7 
*dist_group7 1 "<25km paso fronterizo" 2 ">200km"

*con TC:
/*  foreach x of local compradores { 
preserve 
	drop if time < 691

	collapse (mean) p_surtidor_`x' oficial_venta, by(dist_group7 time)
			gen byte basetime = 1 if time==691
			by dist_group7 (basetime), sort: gen p_surtidor_`x'n = p_surtidor_`x' / p_surtidor_`x'[1]
			gen oficial_ventan = oficial_venta / oficial_venta[1]	
			
			format %tm time
			format oficial_ventan %8.0g
			
			twoway (line p_surtidor_`x'n  time if dist_group7==1, sort)  ///
					(line p_surtidor_`x'n time if dist_group7==2, sort) ///
					(line oficial_ventan time, sort yaxis(2) lcolor(red) lpattern(shortdash) lwidth(medium)), ///
					legend(on lab(1 "<25 km") lab(2 ">200km")   lab(3 "tc oficial") col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("", axis(1)) ytitle("", axis(2)) xtitle("")  ///
					xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x'") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\precios\precios y brecha tc\prueba1\p_dist7_`x'.png", replace		
restore 
}

 */

*sin tc 
/*  foreach x of local compradores { 
preserve 
	drop if time < 691

	collapse (mean) p_surtidor_`x', by(dist_group7 time)
			gen byte basetime = 1 if time==691
			by dist_group7 (basetime), sort: gen p_surtidor_`x'n = p_surtidor_`x' / p_surtidor_`x'[1]
			
			
			format %tm time
			
			
			twoway (line p_surtidor_`x'n  time if dist_group7==1, sort)  ///
					(line p_surtidor_`x'n time if dist_group7==2, sort), ///
					legend(on lab(1 "<25 km") lab(2 ">200km")  col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x'") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\precios\precios y brecha tc\prueba1\p_dist7_`x'_2.png", replace		
restore 
}
 */

*--DIST GROUP 8 
* 1 "<50km paso fronterizo" 2 ">200km"
/* 
 foreach x of local compradores { 
preserve 
	drop if time < 691

	collapse (mean) p_surtidor_`x' oficial_venta, by(dist_group8 time)
			gen byte basetime = 1 if time==691
			by dist_group8 (basetime), sort: gen p_surtidor_`x'n = p_surtidor_`x' / p_surtidor_`x'[1]
			gen oficial_ventan = oficial_venta / oficial_venta[1]
			
			format %tm time
			format oficial_ventan %8.0g
			
			twoway (line p_surtidor_`x'n  time if dist_group8==1, sort)  ///
					(line p_surtidor_`x'n time if dist_group8==2, sort) ///
					(line oficial_ventan time, sort yaxis(2) lcolor(red) lpattern(shortdash) lwidth(medium)), ///
					legend(on lab(1 "<50 km") lab(2 ">200km")   lab(3 "tc oficial") col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("", axis(1)) ytitle("", axis(2)) xtitle("")  ///
					xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x'") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\precios\precios y brecha tc\prueba1\p_dist8_`x'.png", replace		
restore 
}
 */

*---- (4) Precios por  pais fronterizo 
*LAS EESS COBRAN P DIFERENTES AL PUBLICO SEGUN LA FRONTERA? 
/* 
preserve 
 drop if time < 691
	collapse (mean) p_surtidor_pub, by(frontera_pais time)
			gen byte basetime = 1 if time==691
			by frontera_pais (basetime), sort: gen p_surtidor_pubn = p_surtidor_pub / p_surtidor_pub[1]
			
			format %tm time
			
			twoway (line p_surtidor_pubn time if frontera_pais=="BOL", sort)  ///
					(line p_surtidor_pubn time if frontera_pais=="BRA", sort) ///
					(line p_surtidor_pubn time if frontera_pais=="CHL", sort) ///
					(line p_surtidor_pubn time if frontera_pais=="PRY", sort) ///
					(line p_surtidor_pubn time if frontera_pais=="URY", sort), ///
					legend(on lab(1 "BOL") lab(2 "BRA") lab(3 "CHL") lab(4 "PRY") lab(5 "URY") col(6) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: al público") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\precios\precios y brecha tc\prueba1\p_frontera_publico.png", replace		
restore 

 */
*---- (4) Precios por  pais fronterizo y distancia a la frontera 
*LAS EESS COBRAN P DIFERENTES SEGUN DISTANCIA Y FRONTERA?


*----------BOLIVIA 
*dist_group7 1 "<25km paso fronterizo" 2 ">200km"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="BOL"

	collapse (mean) p_surtidor_`x' , by(dist_group7 time)
			gen byte basetime = 1 if time==691
			by dist_group7 (basetime), sort: gen p_surtidor_`x'n = p_surtidor_`x' / p_surtidor_`x'[1]

			
			format %tm time
			
			twoway (line p_surtidor_`x'n  time if dist_group7==1, sort)  ///
					(line p_surtidor_`x'n time if dist_group7==2, sort), ///
					legend(on lab(1 "<25 km") lab(2 ">200km")  col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Frontera: BOL") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\precios\precios y brecha tc\prueba1\p_dist7_`x'_BOL.png", replace		
restore 
}


*dist_group8 1 "<50km paso fronterizo" 2 ">200km" 
foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="BOL"

	collapse (mean) p_surtidor_`x', by(dist_group8 time)
			gen byte basetime = 1 if time==691
			by dist_group8 (basetime), sort: gen p_surtidor_`x'n = p_surtidor_`x' / p_surtidor_`x'[1]
			
			format %tm time

			twoway (line p_surtidor_`x'n  time if dist_group8==1, sort)  ///
					(line p_surtidor_`x'n time if dist_group8==2, sort), ///
					legend(on lab(1 "<50 km") lab(2 ">200km")    col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Frontera: BOL") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\precios\precios y brecha tc\prueba1\p_dist8_`x'_BOL.png", replace		
restore 
}


*----------BRASIL
*dist_group7 1 "<25km paso fronterizo" 2 ">200km"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="BRA"

	collapse (mean) p_surtidor_`x' , by(dist_group7 time)
			gen byte basetime = 1 if time==691
			by dist_group7 (basetime), sort: gen p_surtidor_`x'n = p_surtidor_`x' / p_surtidor_`x'[1]
			
			format %tm time
			
			twoway (line p_surtidor_`x'n  time if dist_group7==1, sort)  ///
					(line p_surtidor_`x'n time if dist_group7==2, sort), ///
					legend(on lab(1 "<25 km") lab(2 ">200km")  col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Frontera: BRA") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\precios\precios y brecha tc\prueba1\p_dist7_`x'_BRA.png", replace		
restore 
}


*dist_group8 "<50km paso fronterizo" 2 ">200km" 
foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="BRA"

	collapse (mean) p_surtidor_`x', by(dist_group8 time)
			gen byte basetime = 1 if time==691
			by dist_group8 (basetime), sort: gen p_surtidor_`x'n = p_surtidor_`x' / p_surtidor_`x'[1]
			
			format %tm time
		
			twoway (line p_surtidor_`x'n  time if dist_group8==1, sort)  ///
					(line p_surtidor_`x'n time if dist_group8==2, sort), ///
					legend(on lab(1 "<50 km") lab(2 ">200km")    col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Frontera: BRA") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\precios\precios y brecha tc\prueba1\p_dist8_`x'_BRA.png", replace		
restore 
}


*----------URUGUAY
*dist_group7 1 "<25km paso fronterizo" 2 ">200km"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="URY"

	collapse (mean) p_surtidor_`x' , by(dist_group7 time)
			gen byte basetime = 1 if time==691
			by dist_group7 (basetime), sort: gen p_surtidor_`x'n = p_surtidor_`x' / p_surtidor_`x'[1]
			
			format %tm time
			
			twoway (line p_surtidor_`x'n  time if dist_group7==1, sort)  ///
					(line p_surtidor_`x'n time if dist_group7==2, sort), ///
					legend(on lab(1 "<25 km") lab(2 ">200km")  col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Frontera: URY") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\precios\precios y brecha tc\prueba1\p_dist8_`x'_URY.png", replace		
restore 
}


*dist_group6 1 "<25km paso fronterizo" 2 ">25km" 
foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="URY"

	collapse (mean) p_surtidor_`x', by(dist_group6 time)
			gen byte basetime = 1 if time==691
			by dist_group6 (basetime), sort: gen p_surtidor_`x'n = p_surtidor_`x' / p_surtidor_`x'[1]
			
			format %tm time
			
			twoway (line p_surtidor_`x'n  time if dist_group6==1, sort)  ///
					(line p_surtidor_`x'n time if dist_group6==2, sort), ///
					legend(on lab(1 "<25 km") lab(2 ">25km")    col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Frontera: URY") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\precios\precios y brecha tc\prueba1\p_dist6_`x'_URY.png", replace		
restore 
}






*----------CHILE

*dist_group7 1 "<25km paso fronterizo" 2 ">200km"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="CHL"

	collapse (mean) p_surtidor_`x' , by(dist_group7 time)
			gen byte basetime = 1 if time==691
			by dist_group7 (basetime), sort: gen p_surtidor_`x'n = p_surtidor_`x' / p_surtidor_`x'[1]
			
			format %tm time
			
			twoway (line p_surtidor_`x'n  time if dist_group7==1, sort)  ///
					(line p_surtidor_`x'n time if dist_group7==2, sort), ///
					legend(on lab(1 "<25 km") lab(2 ">200km")  col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Frontera: CHL") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\precios\precios y brecha tc\prueba1\p_dist8_`x'_CHL.png", replace		
restore 
}


*dist_group6 1 "<25km paso fronterizo" 2 ">25km" 
foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="CHL"

	collapse (mean) p_surtidor_`x', by(dist_group6 time)
			gen byte basetime = 1 if time==691
			by dist_group6 (basetime), sort: gen p_surtidor_`x'n = p_surtidor_`x' / p_surtidor_`x'[1]
			
			format %tm time

			twoway (line p_surtidor_`x'n  time if dist_group6==1, sort)  ///
					(line p_surtidor_`x'n time if dist_group6==2, sort), ///
					legend(on lab(1 "<25 km") lab(2 ">25km")    col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Frontera: CHL") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\precios\precios y brecha tc\prueba1\p_dist6_`x'_CHL.png", replace		
restore 
}


*----------PARAGUAY
*dist_group7 1 "<25km paso fronterizo" 2 ">200km"
 foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="PRY"

	collapse (mean) p_surtidor_`x' , by(dist_group7 time)
			gen byte basetime = 1 if time==691
			by dist_group7 (basetime), sort: gen p_surtidor_`x'n = p_surtidor_`x' / p_surtidor_`x'[1]
			
			format %tm time
			
			twoway (line p_surtidor_`x'n  time if dist_group7==1, sort)  ///
					(line p_surtidor_`x'n time if dist_group7==2, sort), ///
					legend(on lab(1 "<25 km") lab(2 ">200km")  col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("")  xtitle("")  ///
					xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Frontera: PRY") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\precios\precios y brecha tc\prueba1\p_dist8_`x'_PRY.png", replace		
restore 
}


*dist_group6 1 "<25km paso fronterizo" 2 ">25km" 
foreach x of local compradores { 
preserve 
	drop if time < 691
	keep if frontera_pais=="PRY"

	collapse (mean) p_surtidor_`x', by(dist_group6 time)
			gen byte basetime = 1 if time==691
			by dist_group6 (basetime), sort: gen p_surtidor_`x'n = p_surtidor_`x' / p_surtidor_`x'[1]

			format %tm time
	
			twoway (line p_surtidor_`x'n  time if dist_group6==1, sort)  ///
					(line p_surtidor_`x'n time if dist_group6==2, sort), ///
					legend(on lab(1 "<25 km") lab(2 ">25km")    col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x' - Frontera: PRY") 	///	
					xline(719, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\precios\precios y brecha tc\prueba1\p_dist6_`x'_PRY.png", replace		
restore 
}







