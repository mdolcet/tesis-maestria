***************************************
/* Dofile para armar los siguientes graficos:
	- Precio combustible y TC oficial 
	- Precio combustible TC oficial y blue 
	- Precio combustible y brecha cambiaria 
	- Volumenes de venta cerca/lejos con xline en los periodos de devaluacion
	- Volumenes de venta cerca/lejos con xline en los periodos de brecha cambiaria alta 
	-Scatter de P y volumenes 
 */
**************************************** 

*Traigo base gasoil hasta 2019, solo venta al PUBLICO 
use "G:\Mi unidad\Malena\FCE\Maestria\Tesis\bases\base-por-combustible\combustible-gasoil_2_v2", clear 


tsset time id 

*variables de distancia 50 km 
gen dist_group1=. 
replace dist_group1=1 if dist_minima<=50 
replace dist_group1=2 if dist_minima>50 & dist_minima<=100
replace dist_group1=3 if dist_minima>100 & dist_minima<=150 
replace dist_group1=4 if dist_minima>150
label def dist_group1 1 "<50km paso fronterizo" 2 "50-100km paso fronterizo" 3 "100-150km paso fronterizo"  4 ">150km paso fronterizo"
label val dist_group1

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
label def dist_group8 1 "<25km paso fronterizo" 2 ">200km" 
label val dist_group8 dist_group8

*---------------------------------------------------------------------------------------*
*---------------------------------------------------------------------------------------*
*---------------------------------------------------------------------------------------*


*-------------------------------*
*- PRECIOS 
*-------------------------------*


*- PRECIO DE GASOIL Y TIPO DE CAMBIO 
	preserve 
		collapse (mean) p_surtidor tipo_de_cambio, by(time)
		drop if p_surtidor == . 
		gen p_surtidor_n = p_surtidor / p_surtidor[1]
		gen tipo_de_cambion = tipo_de_cambio / tipo_de_cambio[1]
		
		format tipo_de_cambion %8.0g

		
	twoway (line p_surtidor_n time, sort cmissing(n) yaxis(1)) ///
		   (line  tipo_de_cambion time, sort cmissing(n) yaxis(2)), ///
			scheme(modern)  legend(on col(1) pos(6) lab(1 "Precio promedio Gasoil grado 2") lab(2 "tc oficial"))  ///
			ytitle("", axis(1)) ytitle("", axis(2)) xtitle("")  ///
			xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
			ylabel(#15, labsize(small) nogrid axis(1)) ylabel(#15, labsize(small) nogrid axis(2)) ///
			xline(649, lpattern(dash) lcolor(black)) ///
			xline(672, lpattern(dash) lcolor(black)) ///
			xline(704, lpattern(dash) lcolor(black)) ///
			plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
			plotregion(fcolor(gs15)) 
		graph export "salidas\graficos\gasoil\p y tipo de cambio\p_gasoil2.png", replace
	restore 


*- SCATTER P CERCA/LEJOS DE LA FRONTERA CON DEVALUACIONES 

 *- Deva 2014m2 
 
forvalues x = 1/8 { 
preserve 
*desde 2011
drop if time<612

		collapse (mean) p_surtidor, by(dist_group`x' time)
		drop if dist_group`x'==. 
		reshape wide p_surtidor, i(time) j(dist_group`x')
		
		gen diff = p_surtidor1 - p_surtidor2
		
		
		twoway (scatter diff time) (qfit diff time if time<649) (qfit diff time if time>649), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(649, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\graficos\gasoil\precios\scatter\deva2014-dist`x'.png", replace
		
restore 
} 


*- Deva 2016m1
forvalues x = 1/8 { 
preserve 
*desde 2011
drop if time<612

		collapse (mean) p_surtidor, by(dist_group`x' time)
		drop if dist_group`x'==. 
		reshape wide p_surtidor, i(time) j(dist_group`x')
		
		gen diff = p_surtidor1 - p_surtidor2
		
		
		twoway (scatter diff time) (qfit diff time if time<672) (qfit diff time if time>672), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(672, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\graficos\gasoil\precios\scatter\deva2015-dist`x'.png", replace
		
restore 
} 

*- Deva 2018m9  
forvalues x = 1/8 { 
preserve 
*desde 2011 
drop if time<612

		collapse (mean) p_surtidor, by(dist_group`x' time)
		drop if dist_group`x'==. 
		reshape wide p_surtidor, i(time) j(dist_group`x')
		
		gen diff = p_surtidor1 - p_surtidor2
		
		
		twoway (scatter diff time) (qfit diff time if time<704) (qfit diff time if time>704), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(704, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\graficos\gasoil\precios\scatter\deva2018-dist`x'.png", replace
		
restore 
} 


*-------------------------------*
*- VOLUMENES 
*-------------------------------*

*- Deva 2014m2 
forvalues x = 1/8 { 
preserve 
*desde 2011 - 2020M2 
drop if time<612

		collapse (mean) log_vol, by(dist_group`x' time)
		drop if dist_group`x'==. 
		reshape wide log_vol, i(time) j(dist_group`x')
		
		gen diff = log_vol1  - log_vol2
		
		
		twoway (scatter diff time) (qfit diff time if time<649) (qfit diff time if time>649), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(649, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\graficos\gasoil\volumenes\scatter\deva2014-dist`x'.png", replace
		
		*volumenes de venta EESS cerca 
		twoway (scatter log_vol1  time) (qfit log_vol1  time if time<649) (qfit log_vol1  time if time>649), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(649, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\graficos\gasoil\volumenes\scatter\deva2014-dist`x'-EESS-CERCA.png", replace
		
restore 
} 


*- Deva 2016m1
forvalues x = 1/8 { 
preserve 
*desde 2011 - 2020M2 
drop if time<612

		collapse (mean) log_vol, by(dist_group`x' time)
		drop if dist_group`x'==. 
		reshape wide log_vol, i(time) j(dist_group`x')
		
		gen diff = log_vol1 - log_vol2
		
		
		twoway (scatter diff time) (qfit diff time if time<672) (qfit diff time if time>672), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(672, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\graficos\gasoil\volumenes\scatter\deva2015-dist`x'.png", replace
		
		*volumenes promedio de venta EESS cerca 
		twoway (scatter log_vol1  time) (qfit log_vol1  time if time<672) (qfit log_vol1  time if time>672), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(672, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\graficos\gasoil\volumenes\scatter\deva2015-dist`x'-EESS-CERCA.png", replace
		
		
restore 
} 

*- Deva 2018m9  
forvalues x = 1/8 { 
preserve 
*desde 2011 - 2020M2 
drop if time<612

		collapse (mean) log_vol, by(dist_group`x' time)
		drop if dist_group`x'==. 
		reshape wide log_vol, i(time) j(dist_group`x')
		
		gen diff = log_vol1 - log_vol2
		
		*diferencia cerca - lejos 
		twoway (scatter diff time) (qfit diff time if time<704) (qfit diff time if time>704), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(704, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\graficos\gasoil\volumenes\scatter\deva2018-dist`x'.png", replace
		
		*volumenes promedio de venta EESS cerca 
		twoway (scatter log_vol1  time) (qfit log_vol1  time if time<704) (qfit log_vol1  time if time>704), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(704, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\graficos\gasoil\volumenes\scatter\deva2018-dist`x'-EESS-CERCA.png", replace
		
restore 
} 
