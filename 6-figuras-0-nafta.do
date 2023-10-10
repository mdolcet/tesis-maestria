***************************************
/* Dofile para armar los siguientes graficos:
	- Precio combustible y TC oficial 
	- Precio combustible TC oficial y blue 
	- Precio combustible y brecha cambiaria 
	- Volumenes de venta cerca/lejos con xline en los periodos de devaluacion
	- Volumenes de venta cerca/lejos con xline en los periodos de brecha cambiaria alta 
 */
**************************************** 
 
use "bases\base-precios\p-pulidas-distancias\nafta_2_2005_2022.dta", clear


tsset time id 
*arreglo un outliar de oeess en el P 
replace p_surtidor_oeess=12.40 if codigo_unico_de_coordenadas=="-25.59796;-54.57068" & time==656




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


label def dist_group 1 "<50km paso fronterizo" 2 "50-100km paso fronterizo" 3 "100-150km paso fronterizo"  4 ">150km paso fronterizo"
label val dist_group dist_group

rename dist_group dist_group1

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

*Banderas 
gen band = . 
replace band = 1 if bandera=="YPF"
replace band = 2 if bandera=="SHELL C.A.P.S.A."
replace band = 3 if bandera=="AXION" | bandera=="ESSO PETROLERA ARGENTINA S.R.L"
replace band = 4 if bandera=="BLANCA"
replace band = 5 if bandera=="PUMA" 
replace band = 6 if bandera=="PETROBRAS" 
replace band = 7 if bandera=="OIL COMBUSTIBLES S.A." 
replace band = 8 if bandera=="REFINOR" 
replace band = 9   if bandera=="ASPRO" | bandera=="CIS" | bandera=="DAPSA S.A." | bandera=="GULF" | bandera=="Pampa Energia" | bandera=="RHASA" | bandera=="VOY" | bandera=="SOL PETROLEO"

label def band 1 "YPF" 2 "SHELL" 3 "AXION" 4 "BLANCA" 5 "PUMA" 6 "PETROBRAS" 7 "OIL COMBUSTIBLES" 8 "REFINOR" 9 "OTRAS"
label val band band 



**************************************************
*PRECIOS AGREGADOS 
**************************************************
local compradores "pub ext transp agro oeess osectores" 

/* *P ARGENTINA 
  foreach x of local compradores { 
	preserve 
		 
		drop if p_surtidor_`x' == . 
		gen p_surtidor_`x'n = p_surtidor_`x' / p_surtidor_`x'[1]
		
	twoway (line p_surtidor_`x'n time, sort cmissing(n)), ///
	scheme(modern)  legend(on col(1) pos(6) lab(1 "Precio promedio Nafta Super")) ///
	ytitle("") xtitle("") ysc(r(1 85)) ///
	xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
	ylabel(1(9)85, labsize(small) nogrid)  ///
	note("Comprador: `x'") 		///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
		plotregion(fcolor(gs15)) 
		graph export "salidas\precios\precios agregados\p_arg_`x'.png", replace
	restore 
}
   */
  
 

*P por PROVINCIAS al publico 
/* preserve 
	collapse (mean) p_surtidor_pub , by(provincia mes year)
			*le saco el nivel a las variables
			gen byte basetime = 1 if mes==1 & year==2005
			by provincia (basetime), sort: gen p_surtidor_pubn = p_surtidor_pub / p_surtidor_pub[1]
			
			gen time = ym(year, mes) 
			format %tm time 
	
			twoway (line  p_surtidor_pubn time if provincia=="CATAMARCA", sort)      ///
					(line p_surtidor_pubn time if provincia=="CHACO", sort)         ///
					(line p_surtidor_pubn time if provincia=="CHUBUT", sort)        ///
					(line p_surtidor_pubn time if provincia=="CORRIENTES", sort)    ///
					(line p_surtidor_pubn time if provincia=="ENTRE RIOS", sort) ///
					(line p_surtidor_pubn time if provincia=="FORMOSA", sort) ///
					(line p_surtidor_pubn time if provincia=="JUJUY", sort)         ///
					(line p_surtidor_pubn time if provincia=="LA RIOJA", sort)      ///
					(line p_surtidor_pubn time if provincia=="MENDOZA", sort)      ///
					(line p_surtidor_pubn time if provincia=="MISIONES", sort)     ///
					(line p_surtidor_pubn time if provincia=="NEUQUEN", sort)     ///
					(line p_surtidor_pubn time if provincia=="SALTA", sort)        ///
					(line p_surtidor_pubn time if provincia=="SAN JUAN", sort)      ///
					(line p_surtidor_pubn time if provincia=="SANTA CRUZ", sort)    ///
					(line p_surtidor_pubn time if provincia=="TUCUMAN", sort) , ///
					legend(on lab (1 "Catamarca") lab(2 "Chaco") lab(3 "Chubut") lab(4 "Corrientes") lab(5 "Entre Rios") lab(6 "Formosa") lab(7 "Jujuy") lab(8 "La Rioja") lab(9 "Mendoza") lab(10 "Misiones") lab(11 "Neuquén") lab(12 "Salta") lab(13 "San Juan") lab(14 "Santa Cruz") lab(15 "Tucuman") col(1) pos(4)) ///
					scheme(modern)   ///
					ytitle("") xtitle("") ysc(r(1 85)) ///
					xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(1(9)85, labsize(small) nogrid)  ///
					note("Comprador: público") 	///	
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 
			graph export "salidas\precios\precios agregados\p_prov_publico.png", replace					
restore 
   */
 
 
*P por PROVINCIAS al publico NORTE 
 /* preserve 
	collapse (mean) p_surtidor_pub , by(provincia mes year)
			*le saco el nivel a las variables
			gen byte basetime = 1 if mes==1 & year==2005
			by provincia (basetime), sort: gen p_surtidor_pubn = p_surtidor_pub / p_surtidor_pub[1]
			
			gen time = ym(year, mes) 
			format %tm time 
	
			twoway (line  p_surtidor_pubn time if provincia=="CATAMARCA", sort)      ///
					(line p_surtidor_pubn time if provincia=="CHACO", sort)         ///
					(line p_surtidor_pubn time if provincia=="CORRIENTES", sort)    ///
					(line p_surtidor_pubn time if provincia=="ENTRE RIOS", sort) ///
					(line p_surtidor_pubn time if provincia=="FORMOSA", sort) ///
					(line p_surtidor_pubn time if provincia=="JUJUY", sort)         ///
					(line p_surtidor_pubn time if provincia=="LA RIOJA", sort)      ///
					(line p_surtidor_pubn time if provincia=="MISIONES", sort)     ///
					(line p_surtidor_pubn time if provincia=="SALTA", sort)        ///
					(line p_surtidor_pubn time if provincia=="SAN JUAN", sort)      ///
					(line p_surtidor_pubn time if provincia=="TUCUMAN", sort) , ///				
					legend(on lab (1 "Catamarca") lab(2 "Chaco")  lab(3 "Corrientes") lab(4 "Entre Rios") lab(5 "Formosa") lab(6 "Jujuy") lab(7 "La Rioja")  lab(8 "Misiones") lab(9 "Salta") lab(10 "San Juan") lab(11 "Tucuman") col(1) pos(4)) ///
					scheme(modern)   ///
					ytitle("") xtitle("") ysc(r(1 85)) ///
					xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(1(9)85, labsize(small) nogrid)  ///
					note("Comprador: público") 		///	
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 
			graph export "salidas\precios\precios agregados\p_norte_publico.png", replace					
restore 
  */

*P por PROVINCIAS al publico SUR
/*  preserve 
	collapse (mean) p_surtidor_pub , by(provincia mes year)
			*le saco el nivel a las variables
			gen byte basetime = 1 if mes==1 & year==2005
			by provincia (basetime), sort: gen p_surtidor_pubn = p_surtidor_pub / p_surtidor_pub[1]
			
			gen time = ym(year, mes) 
			format %tm time 
	
			twoway (line p_surtidor_pubn time if provincia=="CHUBUT", sort)        ///
					(line p_surtidor_pubn time if provincia=="MENDOZA", sort)      ///
					(line p_surtidor_pubn time if provincia=="NEUQUEN", sort)     ///
					(line p_surtidor_pubn time if provincia=="SANTA CRUZ", sort),    ///
					legend(on lab(1 "Chubut") lab(2 "Mendoza") lab(3 "Neuquén") lab(4 "Santa Cruz")  col(1) pos(4)) ///
					scheme(modern)   ///
					ytitle("") xtitle("") ysc(r(1 85)) ///
					xlabel(#15, valuelabels angle(stdarrow) nogrid labsize(small)) ///
					ylabel(1(9)85, labsize(small) nogrid)  ///
					note("Comprador: público") 		///	
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 
			graph export "salidas\precios\precios agregados\p_sur_publico.png", replace					
restore 
  */

*P EESS CERCA VS LEJOS - toda la serie 
local compradores "pub ext transp agro oeess osectores" 
/* 
foreach x of local compradores { 

preserve 
	collapse (mean) p_surtidor_`x' , by(dist_group mes year)
			gen byte basetime = 1 if mes==1 & year==2005
			by dist_group (basetime), sort: gen p_surtidor_`x'n = p_surtidor_`x' / p_surtidor_`x'[1]
			gen time = ym(year, mes) 
			format %tm time
			
			twoway (line p_surtidor_`x'n time if dist_group==1, sort)  ///
					(line p_surtidor_`x'n time if dist_group==2, sort) ///
					(line p_surtidor_`x'n time if dist_group==3, sort) ///
					(line p_surtidor_`x'n time if dist_group==4, sort), ///
					legend(on lab(1 "<50 km") lab(2 "50-100km") lab(3 "100-150km") lab(4 ">150km")  col(4) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("") ysc(r(1 90)) ///
					xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(1(9)90, labsize(small) nogrid)  ///
					note("Comprador: `x'") 	///	
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\precios\precios agregados\p_dist_`x'.png", replace		
restore 
}
 */

*P EESS CERCA VS LEJOS - desde 2012
/* foreach x of local compradores { 

preserve 
	drop if time<624
	collapse (mean) p_surtidor_`x' , by(dist_group mes year)
			gen byte basetime = 1 if mes==1 & year==2012
			by dist_group (basetime), sort: gen p_surtidor_`x'n = p_surtidor_`x' / p_surtidor_`x'[1]
			gen time = ym(year, mes) 
			format %tm time
			
			twoway (line p_surtidor_`x'n time if dist_group==1, sort)  ///
					(line p_surtidor_`x'n time if dist_group==2, sort) ///
					(line p_surtidor_`x'n time if dist_group==3, sort) ///
					(line p_surtidor_`x'n time if dist_group==4, sort), ///
					legend(on lab(1 "<50 km") lab(2 "50-100km") lab(3 "100-150km") lab(4 ">150km")  col(4) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#15, valuelabels angle(stdarrow) nogrid labsize(small)) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x'") 		///	
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 
			graph export "salidas\precios\precios agregados\p_dist_`x'_2012.png", replace		
restore 
}
 */

*P EESS CERCA VS LEJOS - desde 2012 - con devaluaciones 
/* foreach x of local compradores { 

preserve 
	drop if time<624
	collapse (mean) p_surtidor_`x' , by(dist_group mes year)
			gen byte basetime = 1 if mes==1 & year==2012
			by dist_group (basetime), sort: gen p_surtidor_`x'n = p_surtidor_`x' / p_surtidor_`x'[1]
			gen time = ym(year, mes) 
			format %tm time
			
			twoway (line p_surtidor_`x'n time if dist_group==1, sort)  ///
					(line p_surtidor_`x'n time if dist_group==2, sort) ///
					(line p_surtidor_`x'n time if dist_group==3, sort) ///
					(line p_surtidor_`x'n time if dist_group==4, sort), ///
					legend(on lab(1 "<50 km") lab(2 "50-100km") lab(3 "100-150km") lab(4 ">150km")  col(4) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#15, valuelabels angle(stdarrow) nogrid labsize(small)) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x'") 	 ///
					xline(649, lpattern(dash) lcolor(black)) ///
					xline(672, lpattern(dash) lcolor(black)) ///
					xline(704, lpattern(dash) lcolor(black)) ///	
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 
			graph export "salidas\precios\precios agregados\p_dist_`x'_2012_deva.png", replace		
restore 
}
 */
 
 
*P EESS CERCA VS LEJOS - desde 2012 - con devaluaciones - solo 0-100km 
/* foreach x of local compradores { 

preserve 
	drop if time<624
	collapse (mean) p_surtidor_`x' , by(dist_group mes year)
			gen byte basetime = 1 if mes==1 & year==2012
			by dist_group (basetime), sort: gen p_surtidor_`x'n = p_surtidor_`x' / p_surtidor_`x'[1]
			gen time = ym(year, mes) 
			format %tm time
			
			twoway (line p_surtidor_`x'n time if dist_group==1, sort)  ///
					(line p_surtidor_`x'n time if dist_group==2, sort), ///
					legend(on lab(1 "<50 km") lab(2 "50-100km")  col(2) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(, labsize(small) nogrid)  ///
					note("Comprador: `x'") 		 ///
					xline(649, lpattern(dash) lcolor(black)) ///
					xline(672, lpattern(dash) lcolor(black)) ///
					xline(704, lpattern(dash) lcolor(black)) ///	
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 
			graph export "salidas\precios\precios agregados\p_dist_`x'_2012_deva2.png", replace		
restore 
}


 */
 
**************************************************
*PRECIOS VS TIPO DE CAMBIO  OFICIAL Y BLUE ?
**************************************************
*EVOLUCION P ARG AGREGADO VS EVOLUCION TC OFICIAL Y BLUE *ysc(r(1 130))
local compradores "pub ext transp agro oeess osectores" 

*P ARGENTINA tc OFICIAL Y BLUE 
/*   foreach x of local compradores { 
	preserve 
		collapse (mean) p_surtidor_`x' oficial_venta blue_venta, by(time)
		drop if p_surtidor_`x' == . 
		gen p_surtidor_`x'n = p_surtidor_`x' / p_surtidor_`x'[1]
		gen oficial_ventan = oficial_venta / oficial_venta[1]
		gen blue_ventan = blue_venta / blue_venta[1]
		
		format oficial_ventan %8.0g
		format blue_ventan %8.0g
		
	twoway (line p_surtidor_`x'n time, sort cmissing(n) yaxis(1)) ///
		   (line oficial_ventan time, sort cmissing(n) yaxis(2)) ///
		   (line blue_ventan time, sort cmissing(n) yaxis(2)), ///
			scheme(modern)  legend(on col(1) pos(6) lab(1 "Precio promedio Nafta Super") lab(2 "tc oficial") lab(3 "tc blue")) ///
			ytitle("", axis(1)) ytitle("", axis(2)) xtitle("")  ///
			xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
			ylabel(#15, labsize(small) nogrid axis(1)) ylabel(#15, labsize(small) nogrid axis(2))  ///
			note("Comprador: `x'") 		///
			xline(649, lpattern(dash) lcolor(black)) ///
			xline(672, lpattern(dash) lcolor(black)) ///
			xline(704, lpattern(dash) lcolor(black)) ///
			plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
			plotregion(fcolor(gs15)) 
		graph export "salidas\precios\precios y brecha tc\p_ob_`x'.png", replace
	restore 
}
   */
   
   
*P ARGENTINA y tc OFICIAL 
/*   foreach x of local compradores { 
	preserve 
		collapse (mean) p_surtidor_`x' oficial_venta , by(time)
		drop if p_surtidor_`x' == . 
		gen p_surtidor_`x'n = p_surtidor_`x' / p_surtidor_`x'[1]
		gen oficial_ventan = oficial_venta / oficial_venta[1]
		
		format oficial_ventan %8.0g
		
	twoway (line p_surtidor_`x'n time, sort cmissing(n) yaxis(1)) ///
		   (line oficial_ventan time, sort cmissing(n) yaxis(2)), ///
			scheme(modern)  legend(on col(1) pos(6) lab(1 "Precio promedio Nafta Super") lab(2 "tc oficial")) ///
			ytitle("", axis(1)) ytitle("", axis(2)) xtitle("")  ///
			xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
			ylabel(#15, labsize(small) nogrid axis(1)) ylabel(#15, labsize(small) nogrid axis(2))  ///
			note("Comprador: `x'") 		///
			xline(649, lpattern(dash) lcolor(black)) ///
			xline(672, lpattern(dash) lcolor(black)) ///
			xline(704, lpattern(dash) lcolor(black)) ///
			plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
			plotregion(fcolor(gs15)) 
		graph export "salidas\precios\precios y brecha tc\p_o_`x'.png", replace
	restore 
}
     */
	
	
	
	
*P ARGENTINA TODOS LOS COMPRADORES JUNTOS Y TC OFICIAL 
*saco los P de los extranjeros, hay muy pocas observaciones. 
/* preserve 
	collapse (mean) p_surtidor_pub p_surtidor_transp p_surtidor_ext p_surtidor_agro p_surtidor_oeess p_surtidor_osectores oficial_venta, by(time) 
		drop if time==749 | time==750
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
			xline(649, lpattern(dash) lcolor(black)) ///
			xline(672, lpattern(dash) lcolor(black)) ///
			xline(704, lpattern(dash) lcolor(black)) ///
			plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
			plotregion(fcolor(gs15)) 
		graph export "salidas\precios\precios y brecha tc\p_sectores.png", replace
restore 

 */

*P ARGENTINA TODOS LOS COMPRADORES JUNTOS Y TC OFICIAL zoom 2012 
*saco los P de los extranjeros, hay muy pocas observaciones. 	
/* preserve 
drop if time<624
	collapse (mean) p_surtidor_pub p_surtidor_transp p_surtidor_ext p_surtidor_agro p_surtidor_oeess p_surtidor_osectores oficial_venta, by(time) 
		drop if time==749 | time==750
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
			xline(649, lpattern(dash) lcolor(black)) ///
			xline(672, lpattern(dash) lcolor(black)) ///
			xline(704, lpattern(dash) lcolor(black)) ///
			plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
			plotregion(fcolor(gs15)) 
		graph export "salidas\precios\precios y brecha tc\p_sectores_12.png", replace
restore	
	
	
 */	
	

	
*P ARGENTINA y tc BLUE 
/*   foreach x of local compradores { 
	preserve 
		collapse (mean) p_surtidor_`x'  blue_venta, by(time)
		drop if p_surtidor_`x' == . 
		gen p_surtidor_`x'n = p_surtidor_`x' / p_surtidor_`x'[1]
		gen blue_ventan = blue_venta / blue_venta[1]
		
		
		format blue_ventan %8.0g
		
		
	twoway (line p_surtidor_`x'n time, sort cmissing(n) yaxis(1)) ///
		   (line blue_ventan time, sort cmissing(n) yaxis(2)), ///
			scheme(modern)  legend(on col(1) pos(6) lab(1 "Precio promedio Nafta Super") lab(2 "tc blue")) ///
			ytitle("", axis(1)) ytitle("", axis(2)) xtitle("")  ///
			xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
			ylabel(#15, labsize(small) nogrid axis(1)) ylabel(#15, labsize(small) nogrid axis(2))  ///
			note("Comprador: `x'") 		///
			xline(649, lpattern(dash) lcolor(black)) ///
			xline(672, lpattern(dash) lcolor(black)) ///
			xline(704, lpattern(dash) lcolor(black)) ///
			plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
			plotregion(fcolor(gs15)) 
		graph export "salidas\precios\precios y brecha tc\p_b_`x'.png", replace
	restore 
}
 */

*P ARGENTINA tc OFICIAL Y BLUE DESDE 2012 
/*   foreach x of local compradores { 
  
	preserve 
	drop if time<624
		collapse (mean) p_surtidor_`x' oficial_venta blue_venta, by(time)
		gen p_surtidor_`x'n = p_surtidor_`x' / p_surtidor_`x'[1]
		gen oficial_ventan = oficial_venta / oficial_venta[1]
		gen blue_ventan = blue_venta / blue_venta[1]
		
		format oficial_ventan %8.0g
		format blue_ventan %8.0g
		
	twoway (line p_surtidor_`x'n time, sort cmissing(n) yaxis(1)) ///
		   (line oficial_ventan time, sort cmissing(n) yaxis(2)) ///
		   (line blue_ventan time, sort cmissing(n) yaxis(2)), ///
			scheme(modern)  legend(on col(1) pos(6) lab(1 "Precio promedio Nafta Super") lab(2 "tc oficial") lab(3 "tc blue")) ///
			ytitle("", axis(1)) ytitle("", axis(2)) xtitle("")  ///
			xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
			ylabel(#15, labsize(small) nogrid axis(1)) ylabel(#15, labsize(small) nogrid axis(2))  ///
			note("Comprador: `x' - 2012-2022") 		///
			xline(649, lpattern(dash) lcolor(black)) ///
			xline(672, lpattern(dash) lcolor(black)) ///
			xline(704, lpattern(dash) lcolor(black)) ///
			plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
			plotregion(fcolor(gs15)) 
		graph export "salidas\precios\precios y brecha tc\p_ob_`x'_12.png", replace
	restore 
}
 
 */

*P ARGENTINA y tc OFICIAL 
/*   foreach x of local compradores { 
 
	preserve 
	 drop if time<624
		collapse (mean) p_surtidor_`x' oficial_venta , by(time)
		drop if p_surtidor_`x' == . 
		gen p_surtidor_`x'n = p_surtidor_`x' / p_surtidor_`x'[1]
		gen oficial_ventan = oficial_venta / oficial_venta[1]
		
		
		format oficial_ventan %8.0g
		
		
	twoway (line p_surtidor_`x'n time, sort cmissing(n) yaxis(1)) ///
		   (line oficial_ventan time, sort cmissing(n) yaxis(2)), ///
			scheme(modern)  legend(on col(1) pos(6) lab(1 "Precio promedio Nafta Super") lab(2 "tc oficial")) ///
			ytitle("", axis(1)) ytitle("", axis(2)) xtitle("")  ///
			xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
			ylabel(#15, labsize(small) nogrid axis(1)) ylabel(#15, labsize(small) nogrid axis(2))  ///
			note("Comprador: `x'") 		///
			xline(649, lpattern(dash) lcolor(black)) ///
			xline(672, lpattern(dash) lcolor(black)) ///
			xline(704, lpattern(dash) lcolor(black)) ///
			plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
			plotregion(fcolor(gs15)) 
		graph export "salidas\precios\precios y brecha tc\p_o_`x'_12.png", replace
	restore 
}
     */
*P ARGENTINA y tc BLUE 

/*   foreach x of local compradores { 
  
	preserve 
	drop if time<624
		collapse (mean) p_surtidor_`x'  blue_venta, by(time)
		drop if p_surtidor_`x' == . 
		gen p_surtidor_`x'n = p_surtidor_`x' / p_surtidor_`x'[1]
		gen blue_ventan = blue_venta / blue_venta[1]
		
		
		format blue_ventan %8.0g
		
		
	twoway (line p_surtidor_`x'n time, sort cmissing(n) yaxis(1)) ///
		   (line blue_ventan time, sort cmissing(n) yaxis(2)), ///
			scheme(modern)  legend(on col(1) pos(6) lab(1 "Precio promedio Nafta Super") lab(2 "tc blue")) ///
			ytitle("", axis(1)) ytitle("", axis(2)) xtitle("")  ///
			xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
			ylabel(#15, labsize(small) nogrid axis(1)) ylabel(#15, labsize(small) nogrid axis(2))  ///
			note("Comprador: `x'") 		///
			xline(649, lpattern(dash) lcolor(black)) ///
			xline(672, lpattern(dash) lcolor(black)) ///
			xline(704, lpattern(dash) lcolor(black)) ///
			plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
			plotregion(fcolor(gs15)) 
		graph export "salidas\precios\precios y brecha tc\p_b_`x'_12.png", replace
	restore 
}
    */   

*EVOLUCION P POR PROVINCIA VS EVOLUCION TC OFICIAL 

*EVOLUCION P CERCA-LEJOS VS EVOLUCION TC OFICIAL toda la serie 
/* foreach x of local compradores { 

preserve 
	collapse (mean) p_surtidor_`x' oficial_venta, by(dist_group mes year)
			gen byte basetime = 1 if mes==1 & year==2005
			by dist_group (basetime), sort: gen p_surtidor_`x'n = p_surtidor_`x' / p_surtidor_`x'[1]
			gen oficial_ventan = oficial_venta / oficial_venta[1]
			
			gen time = ym(year, mes) 
			
			format %tm time
			format oficial_ventan %8.0g
			
			twoway (line p_surtidor_`x'n time if dist_group==1, sort)  ///
					(line p_surtidor_`x'n time if dist_group==2, sort) ///
					(line p_surtidor_`x'n time if dist_group==3, sort) ///
					(line p_surtidor_`x'n time if dist_group==4, sort) ///
					(line oficial_ventan time, sort yaxis(2) lcolor(red) lpattern(shortdash) lwidth(medium)), ///
					legend(on lab(1 "<50 km") lab(2 "50-100km") lab(3 "100-150km") lab(4 ">150km") lab(5 "tc oficial") col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("", axis(1)) ytitle("", axis(2)) xtitle("")  ///
					xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x'") 	///	
					xline(649, lpattern(dash) lcolor(black)) ///
					xline(672, lpattern(dash) lcolor(black)) ///
					xline(704, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\precios\precios y brecha tc\p_dist_tc_`x'.png", replace		
restore 
}

 */


*EVOLUCION P CERCA-LEJOS VS EVOLUCION TC OFICIAL desde 2010
/* foreach x of local compradores { 

preserve 
drop if time<600 
	collapse (mean) p_surtidor_`x' oficial_venta, by(dist_group mes year)
			gen byte basetime = 1 if mes==1 & year==2010
			by dist_group (basetime), sort: gen p_surtidor_`x'n = p_surtidor_`x' / p_surtidor_`x'[1]
			gen oficial_ventan = oficial_venta / oficial_venta[1]
			
			gen time = ym(year, mes) 
			
			format %tm time
			format oficial_ventan %8.0g
			
			twoway (line p_surtidor_`x'n time if dist_group==1, sort)  ///
					(line p_surtidor_`x'n time if dist_group==2, sort) ///
					(line p_surtidor_`x'n time if dist_group==3, sort) ///
					(line p_surtidor_`x'n time if dist_group==4, sort) ///
					(line oficial_ventan time, sort yaxis(2) lcolor(red) lpattern(shortdash) lwidth(medium)), ///
					legend(on lab(1 "<50 km") lab(2 "50-100km") lab(3 "100-150km") lab(4 ">150km") lab(5 "tc oficial") col(5) pos(6)) ///
					scheme(modern)   ///
					ytitle("", axis(1)) ytitle("", axis(2)) xtitle("")  ///
					xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#15, labsize(small) nogrid)  ///
					note("Comprador: `x'") 	///	
					xline(649, lpattern(dash) lcolor(black)) ///
					xline(672, lpattern(dash) lcolor(black)) ///
					xline(704, lpattern(dash) lcolor(black)) ///
					plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
						plotregion(fcolor(gs15)) 	
			graph export "salidas\precios\precios y brecha tc\p_dist_tc_`x'_10.png", replace		
restore 
}

 */


**************
*PRECIOS SCATTER 
**************

* - AGRO 
/* 
*- Deva 2014m2 
forvalues x = 1/8 { 
preserve 
*desde 2008 - 2020M2 
drop if time<576 | time>721

		collapse (mean) p_surtidor_agro, by(dist_group`x' time)
		drop if dist_group`x'==.
		reshape wide p_surtidor_agro, i(time) j(dist_group`x')
		
		gen diff = p_surtidor_agro1 - p_surtidor_agro2
		
		
		twoway (scatter diff time) (qfit diff time if time<649) (qfit diff time if time>649), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(649, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\precios\precios scatter\agro\deva2014-dist`x'.png", replace
		
restore 
} 


*- Deva 2016m1
forvalues x = 1/8 { 
preserve 
*desde 2008 - 2020M2 
drop if time<576 | time>721

		collapse (mean) p_surtidor_agro, by(dist_group`x' time)
		drop if dist_group`x'==.
		reshape wide p_surtidor_agro, i(time) j(dist_group`x')
		
		gen diff = p_surtidor_agro1 - p_surtidor_agro2
		
		
		twoway (scatter diff time) (qfit diff time if time<672) (qfit diff time if time>672), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(672, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\precios\precios scatter\agro\deva2015-dist`x'.png", replace
		
restore 
} 

*- Deva 2018m9  
forvalues x = 1/8 { 
preserve 
*desde 2008 - 2020M2 
drop if time<576 | time>721

		collapse (mean) p_surtidor_agro, by(dist_group`x' time)
		drop if dist_group`x'==.
		reshape wide p_surtidor_agro, i(time) j(dist_group`x')
		
		gen diff = p_surtidor_agro1 - p_surtidor_agro2
		
		
		twoway (scatter diff time) (qfit diff time if time<704) (qfit diff time if time>704), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(704, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\precios\precios scatter\agro\deva2018-dist`x'.png", replace
		
restore 
} 
 */

* - TRANSPORTE 
/* 

*- Deva 2014m2 
forvalues x = 1/8 { 
preserve 
*desde 2008 - 2020M2 
drop if time<576 | time>721

		collapse (mean) p_surtidor_transp, by(dist_group`x' time)
		drop if dist_group`x'==.
		reshape wide p_surtidor_transp, i(time) j(dist_group`x')
		
		gen diff = p_surtidor_transp1 - p_surtidor_transp2
		
		
		twoway (scatter diff time) (qfit diff time if time<649) (qfit diff time if time>649), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(649, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\precios\precios scatter\transporte\deva2014-dist`x'.png", replace
		
restore 
} 


*- Deva 2016m1
forvalues x = 1/8 { 
preserve 
*desde 2008 - 2020M2 
drop if time<576 | time>721

		collapse (mean) p_surtidor_transp, by(dist_group`x' time)
		drop if dist_group`x'==.
		reshape wide p_surtidor_transp, i(time) j(dist_group`x')
		
		gen diff = p_surtidor_transp1 - p_surtidor_transp2
		
		
		twoway (scatter diff time) (qfit diff time if time<672) (qfit diff time if time>672), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(672, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\precios\precios scatter\transporte\deva2015-dist`x'.png", replace
		
restore 
} 

*- Deva 2018m9  
forvalues x = 1/8 { 
preserve 
*desde 2008 - 2020M2 
drop if time<576 | time>721

		collapse (mean) p_surtidor_transp, by(dist_group`x' time)
		drop if dist_group`x'==.
		reshape wide p_surtidor_transp, i(time) j(dist_group`x')
		
		gen diff = p_surtidor_transp1 - p_surtidor_transp2
		
		
		twoway (scatter diff time) (qfit diff time if time<704) (qfit diff time if time>704), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(704, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\precios\precios scatter\transporte\deva2018-dist`x'.png", replace
		
restore 
} 

 */

* - AL PUBLICO 


 *- Deva 2014m2 
/* forvalues x = 1/8 { 
preserve 
*desde 2008 - 2020M2 
drop if time<576 | time>721

		collapse (mean) p_surtidor_pub, by(dist_group`x' time)
		drop if dist_group`x'==.
		reshape wide p_surtidor_pub, i(time) j(dist_group`x')
		
		gen diff = p_surtidor_pub1 - p_surtidor_pub2
		
		
		twoway (scatter diff time) (qfit diff time if time<649) (qfit diff time if time>649), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(649, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\precios\precios scatter\publico\deva2014-dist`x'.png", replace
		
restore 
} 


*- Deva 2016m1
forvalues x = 1/8 { 
preserve 
*desde 2008 - 2020M2 
drop if time<576 | time>721

		collapse (mean) p_surtidor_pub, by(dist_group`x' time)
		drop if dist_group`x'==.
		reshape wide p_surtidor_pub, i(time) j(dist_group`x')
		
		gen diff = p_surtidor_pub1 - p_surtidor_pub2
		
		
		twoway (scatter diff time) (qfit diff time if time<672) (qfit diff time if time>672), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(672, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\precios\precios scatter\publico\deva2015-dist`x'.png", replace
		
restore 
} 

*- Deva 2018m9  
forvalues x = 1/8 { 
preserve 
*desde 2008 - 2020M2 
drop if time<576 | time>721

		collapse (mean) p_surtidor_pub, by(dist_group`x' time)
		drop if dist_group`x'==.
		reshape wide p_surtidor_pub, i(time) j(dist_group`x')
		
		gen diff = p_surtidor_pub1 - p_surtidor_pub2
		
		
		twoway (scatter diff time) (qfit diff time if time<704) (qfit diff time if time>704), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(704, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\precios\precios scatter\publico\deva2018-dist`x'.png", replace
		
restore 
} 

 */

*- EXTRANJEROS 

*P todas las EESS con ventas a extranjeros - tenes 600 obs en la base- no sirve para nada. 
preserve 
	collapse (mean) p_surtidor_ext , by(time) 
	drop if p_surtidor_ext==. 
	
	twoway (scatter p_surtidor_ext time) , ///
	scheme(modern) ytitle("") xtitle("") ///	
	xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
	xline(649, lpattern(dash) lcolor(black)) legend(off) ///
	xline(672, lpattern(dash) lcolor(black)) legend(off) ///
	xline(704, lpattern(dash) lcolor(black)) legend(off) ///
	plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
	graph export "salidas\precios\precios scatter\extranjeros\p-extranjeros.png", replace
restore 



	
*- Deva 2014m2 
forvalues x = 1/8 { 
preserve 
*Hay obs desde 2006m8 

		collapse (mean) p_surtidor_ext, by(dist_group`x' time)
		drop if dist_group`x'==.
		reshape wide p_surtidor_ext, i(time) j(dist_group`x')
		
		gen diff = p_surtidor_ext1 - p_surtidor_ext2
		
		
		twoway (scatter diff time) (qfit diff time if time<649) (qfit diff time if time>649), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(649, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\precios\precios scatter\extranjeros\deva2014-dist`x'.png", replace
		
restore 
} 
 


*- Deva 2016m1 
forvalues x = 1/8 { 
preserve 
*Hay obs desde 2006m8 

		collapse (mean) p_surtidor_ext, by(dist_group`x' time)
		drop if dist_group`x'==.
		reshape wide p_surtidor_ext, i(time) j(dist_group`x')
		
		gen diff = p_surtidor_ext1 - p_surtidor_ext2
		
		
		twoway (scatter diff time) (qfit diff time if time<672) (qfit diff time if time>672), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(672, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\precios\precios scatter\extranjeros\deva2015-dist`x'.png", replace
		
restore 
} 
 



*- Deva 2018m9 
forvalues x = 1/8 { 
preserve 
*Hay obs desde 2006m8 

		collapse (mean) p_surtidor_ext, by(dist_group`x' time)
		drop if dist_group`x'==.
		reshape wide p_surtidor_ext, i(time) j(dist_group`x')
		
		gen diff = p_surtidor_ext1 - p_surtidor_ext2
		
		
		twoway (scatter diff time) (qfit diff time if time<704) (qfit diff time if time>704), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(704, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\precios\precios scatter\extranjeros\deva2018-dist`x'.png", replace
		
restore 
} 
 
 **************************************************
*PRECIOS X BANDERA Y DEVALUACIONES 
**************************************************
 
preserve 
	collapse (mean) p_surtidor_pub , by(time band) 
	drop if p_surtidor_ext==. 
	
	
	twoway (scatter p_surtidor_ext time) , ///
	scheme(modern) ytitle("") xtitle("") ///	
	xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
	xline(649, lpattern(dash) lcolor(black)) legend(off) ///
	xline(672, lpattern(dash) lcolor(black)) legend(off) ///
	xline(704, lpattern(dash) lcolor(black)) legend(off) ///
	plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
	graph export "salidas\precios\precios scatter\extranjeros\p-extranjeros.png", replace
restore 

 

**************************************************
*VOLUMENES 
**************************************************

*Q POR COMPRADOR 
local compradores "pub transp ext agro oeess osectores" 
/* 
foreach x of local compradores { 
	preserve 
		collapse (mean) lvol_`x', by(time)
			drop if lvol_`x' == . 
			 gen lvol_`x'n = lvol_`x' / lvol_`x'[1]
		
			twoway (line  lvol_`x'n time, sort), ///
					legend(on lab(1 "Volumen promedio `x'")  col(4) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#20, labsize(small) nogrid)  ///
					note("Comprador: `x' - mensual") 	///
					xline(649, lpattern(dash) lcolor(black)) ///
					xline(672, lpattern(dash) lcolor(black)) ///
					xline(704, lpattern(dash) lcolor(black)) ///			
				plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
				plotregion(fcolor(gs15)) 					
			graph export "salidas\volumenes\por comprador\q_`x'_mensual.png", replace		
restore
}
 */

*Q POR COMPRADOR Y DISTANCIA A LA FRONTERA (cada 50 km) 
/* local compradores "pub transp agro oeess osectores" 
foreach x of local compradores { 
	preserve 
		collapse (mean) lvol_`x', by(dist_group mes year)
		
			gen byte basetime = 1 if mes==1 & year==2005
			by dist_group (basetime), sort: gen lvol_`x'n = lvol_`x' / lvol_`x'[1]
			gen time = ym(year, mes) 
			format %tm time
			
			twoway (line  lvol_`x'n time if dist_group==1, sort) ///
					(line lvol_`x'n time if dist_group==2, sort) ///
					(line lvol_`x'n time if dist_group==3, sort) ///
					(line lvol_`x'n time if dist_group==4, sort), ///
					legend(on lab(1 "<50 km") lab(2 "50-100km") lab(3 "100-150km") lab(4 ">150km")  col(4) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#20, labsize(small) nogrid)  ///
					note("Comprador: `x' - mensual") 	///
					xline(649, lpattern(dash) lcolor(black)) ///
					xline(672, lpattern(dash) lcolor(black)) ///
					xline(704, lpattern(dash) lcolor(black)) ///			
				plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
				plotregion(fcolor(gs15)) 						
			graph export "salidas\volumenes\comprador distancia\q_dist_`x'_mensual.png", replace		
restore
}
 */

*Q POR COMPRADOR Y DISTANCIA A LA FRONTERA (cada 75 km) 
/* foreach x of local compradores { 
	preserve 
		collapse (mean) lvol_`x', by(dist_group2 mes year)
		
			gen byte basetime = 1 if mes==1 & year==2005
			by dist_group2 (basetime), sort: gen lvol_`x'n = lvol_`x' / lvol_`x'[1]
			gen time = ym(year, mes) 
			format %tm time
			
			twoway (line  lvol_`x'n time if dist_group2==1, sort) ///
					(line lvol_`x'n time if dist_group2==2, sort) ///
					(line lvol_`x'n time if dist_group2==3, sort), ///
					legend(on lab(1 "<75 km") lab(2 "75-150km") lab(3 ">150km")  col(3) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#20, labsize(small) nogrid)  ///
					note("Comprador: `x' - mensual") 	///
					xline(649, lpattern(dash) lcolor(black)) ///
					xline(672, lpattern(dash) lcolor(black)) ///
					xline(704, lpattern(dash) lcolor(black)) ///			
				plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
				plotregion(fcolor(gs15)) 						
			graph export "salidas\volumenes\comprador distancia\q_dist2_`x'_mensual.png", replace		
restore
}
 */

*Q POR COMPRADOR Y DISTANCIA A LA FRONTERA (cada 100 km) 
/* foreach x of local compradores { 
	preserve 
		collapse (mean) lvol_`x', by(dist_group3 mes year)
		
			gen byte basetime = 1 if mes==1 & year==2005
			by dist_group3 (basetime), sort: gen lvol_`x'n = lvol_`x' / lvol_`x'[1]
			gen time = ym(year, mes) 
			format %tm time
			
			twoway (line  lvol_`x'n time if dist_group3==1, sort) ///
					(line lvol_`x'n time if dist_group3==2, sort) ///
					(line lvol_`x'n time if dist_group3==3, sort), ///
					legend(on lab(1 "<100 km") lab(2 "100-200km") lab(3 ">200km")  col(3) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#20, labsize(small) nogrid)  ///
					note("Comprador: `x' - mensual") 	///
					xline(649, lpattern(dash) lcolor(black)) ///
					xline(672, lpattern(dash) lcolor(black)) ///
					xline(704, lpattern(dash) lcolor(black)) ///			
				plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
				plotregion(fcolor(gs15)) 						
			graph export "salidas\volumenes\comprador distancia\q_dist3_`x'_mensual.png", replace		
restore
}
 */

*EESS cerca ¿hay compradores que reaccionan a la brecha/tc y otros que no? 
local compradores "pub transp agro oeess osectores" 
/* 
*AL PUBLICO VS AGRO 
forvalues x = 1/3 { 
	preserve 
		collapse (mean) lvol_pub lvol_agro, by(dist_group`x' mes year)
		
			gen byte basetime = 1 if mes==1 & year==2005
			by dist_group`x' (basetime), sort: gen lvol_pubn = lvol_pub / lvol_pub[1]
			by dist_group`x' (basetime), sort: gen lvol_agron = lvol_agro / lvol_agro[1]
			gen time = ym(year, mes) 
			format %tm time
			
			*guardo etiqueta para el grafico:
			local lab_group: label(dist_group`x') 1 
			
			
			twoway (line  lvol_pubn time if dist_group`x'==1, sort) ///
				 (line lvol_agron time if dist_group`x'==1, sort yaxis(2)), ///
					legend(on lab(1 "Al público") lab(2 "Agro")  col(2) pos(6)) ///
					scheme(modern)   ///
					ytitle("", axis(1)) ytitle("", axis(2)) xtitle("")  ///
					xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#20, labsize(small) nogrid)  ///
					note("EESS a `lab_group'") 	///
					xline(649, lpattern(dash) lcolor(black)) ///
					xline(672, lpattern(dash) lcolor(black)) ///
					xline(704, lpattern(dash) lcolor(black)) ///			
				plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
				plotregion(fcolor(gs15)) 						
			graph export "salidas\volumenes\eess cerca\q`x'_pub_agro.png", replace		
restore
}

*AL PUBLICO VS OTRAS EESS
forvalues x = 1/3 { 
	preserve 
		collapse (mean) lvol_pub lvol_oeess, by(dist_group`x' mes year)
		
			gen byte basetime = 1 if mes==1 & year==2005
			by dist_group`x' (basetime), sort: gen lvol_pubn = lvol_pub / lvol_pub[1]
			by dist_group`x' (basetime), sort: gen lvol_oeessn = lvol_oeess / lvol_oeess[1]
			gen time = ym(year, mes) 
			format %tm time
			
			*guardo etiqueta para el grafico:
			local lab_group: label(dist_group`x') 1 
			
			
			twoway (line  lvol_pubn time if dist_group`x'==1, sort) ///
				 (line lvol_oeessn time if dist_group`x'==1, sort yaxis(2)), ///
					legend(on lab(1 "Al público") lab(2 "Otras EESS")  col(2) pos(6)) ///
					scheme(modern)   ///
					ytitle("", axis(1)) ytitle("", axis(2)) xtitle("")  ///
					xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#20, labsize(small) nogrid)  ///
					note("EESS a `lab_group'") 	///
					xline(649, lpattern(dash) lcolor(black)) ///
					xline(672, lpattern(dash) lcolor(black)) ///
					xline(704, lpattern(dash) lcolor(black)) ///			
				plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
				plotregion(fcolor(gs15)) 						
			graph export "salidas\volumenes\eess cerca\q`x'_pub_oeess.png", replace		
restore
}
*AL PUBLICO VS OTROS SECTORES PRODUCTIVOS 
forvalues x = 1/3 { 
	preserve 
		collapse (mean) lvol_pub lvol_osectores, by(dist_group`x' mes year)
		
			gen byte basetime = 1 if mes==1 & year==2005
			by dist_group`x' (basetime), sort: gen lvol_pubn = lvol_pub / lvol_pub[1]
			by dist_group`x' (basetime), sort: gen lvol_osectoresn = lvol_osectores / lvol_osectores[1]
			gen time = ym(year, mes) 
			format %tm time
			
			*guardo etiqueta para el grafico:
			local lab_group: label(dist_group`x') 1 
			
			
			twoway (line  lvol_pubn time if dist_group`x'==1, sort) ///
				 (line lvol_osectoresn time if dist_group`x'==1, sort yaxis(2)), ///
					legend(on lab(1 "Al público") lab(2 "Otros sectores")  col(2) pos(6)) ///
					scheme(modern)   ///
					ytitle("", axis(1)) ytitle("", axis(2)) xtitle("")  ///
					xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#20, labsize(small) nogrid)  ///
					note("EESS a `lab_group'") 	///
					xline(649, lpattern(dash) lcolor(black)) ///
					xline(672, lpattern(dash) lcolor(black)) ///
					xline(704, lpattern(dash) lcolor(black)) ///			
				plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
				plotregion(fcolor(gs15)) 						
			graph export "salidas\volumenes\eess cerca\q`x'_pub_osectores.png", replace		
restore
}

*AL PUBLICO VS TRANSPORTE
forvalues x = 1/3 { 
	preserve 
		collapse (mean) lvol_pub lvol_transp, by(dist_group`x' mes year)
		
			gen byte basetime = 1 if mes==1 & year==2005
			by dist_group`x' (basetime), sort: gen lvol_pubn = lvol_pub / lvol_pub[1]
			by dist_group`x' (basetime), sort: gen lvol_transpn = lvol_transp / lvol_transp[1]
			gen time = ym(year, mes) 
			format %tm time
			
			*guardo etiqueta para el grafico:
			local lab_group: label(dist_group`x') 1 
			
			
			twoway (line  lvol_pubn time if dist_group`x'==1, sort) ///
				 (line lvol_transpn time if dist_group`x'==1, sort yaxis(2)), ///
					legend(on lab(1 "Al público") lab(2 "Transporte")  col(2) pos(6)) ///
					scheme(modern)   ///
					ytitle("", axis(1)) ytitle("", axis(2)) xtitle("")  ///
					xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
					ylabel(#20, labsize(small) nogrid)  ///
					note("EESS a `lab_group'") 	///
					xline(649, lpattern(dash) lcolor(black)) ///
					xline(672, lpattern(dash) lcolor(black)) ///
					xline(704, lpattern(dash) lcolor(black)) ///			
				plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
				plotregion(fcolor(gs15)) 						
			graph export "salidas\volumenes\eess cerca\q`x'_pub_transp.png", replace		
restore
}
 */
*DEVALUACIONES:  xline(649, lpattern(dash) lcolor(black))   2014m2
*DEVALUACIONES:  xline(672, lpattern(dash) lcolor(black))  2016m1
*DEVALUACIONES: xline(704, lpattern(dash) lcolor(black))  2018m9
*diferencia logaritmica en las ventas de las que estan CERCA



/* MALE SEGUIR DESDE ACA PROBAR CON LAS DIFERENCIAS CONTRA EL TIEMPO*/
/* 
forvalues x = 1/3 { 
preserve 
		collapse (mean) lvol_pub, by(dist_group`x' time)
		reshape wide lvol_pub, i(time) j(dist_group`x')
		
		gen diff = lvol_pub1 - lvol_pub2
		
		*deva de 2018m9
twoway (scatter diff time) (lfit diff time), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(704, lpattern(dash) lcolor(black)) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) ///
			name(prueba`x')
restore 
} 

		
		
		 */
		


*con las devaluaciones: 2014m2, 2016m1, 2018m9
/* 
foreach x of local compradores { 
	preserve 
		drop if time<600 | time>719
		collapse (mean) lvol_`x', by(dist_group mes year)
			gen byte basetime = 1 if mes==1 & year==2010
			by dist_group (basetime), sort: gen lvol_`x'n = lvol_`x' / lvol_`x'[1]
			gen time = yq(year, mes) 
			format %tm time
			
			twoway (line  lvol_`x'n time if dist_group==1, sort) ///
					(line lvol_`x'n time if dist_group==2, sort), ///
					legend(on lab(1 "<50 km") lab(2 "50-100km")   col(4) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#15, valuelabels angle(stdarrow) labsize(small)) ///
					ylabel(#20, labsize(small))  ///
					note("Comprador: `x' - trimestral ") ///
					xline(649, lpattern(dash) lcolor(black)) ///
					xline(672, lpattern(dash) lcolor(black)) ///
					xline(704, lpattern(dash) lcolor(black))
					
			graph export "salidas\volumenes\vol_dist2_`x'_q.png", replace		
restore
}
 */




/* 
	preserve 
		drop if time<600 | time>719
		collapse (mean) lvol_osectores, by(dist_group quarter year)
			gen byte basetime = 1 if quarter=1 & year==2010
			by dist_group (basetime), sort: gen lvol_osectoresn = lvol_osectores / lvol_osectores[1]
			gen time = yq(year, quarter) 
			format %tq time
			
			twoway (line  lvol_osectoresn time if dist_group==1 | dist_group==2, sort), ///
					legend(on lab(1 "0-100km")   col(4) pos(6)) ///
					scheme(modern)   ///
					ytitle("") xtitle("")  ///
					xlabel(#15, valuelabels angle(stdarrow) labsize(small)) ///
					ylabel(#20, labsize(small))  ///
					note("Comprador: Otros sectores - trimestral") ///
					xline(649, lpattern(dash) lcolor(black)) ///
					xline(672, lpattern(dash) lcolor(black)) ///
					xline(704, lpattern(dash) lcolor(black)) name(hola)
					
			*graph export "salidas\volumenes\vol_dist2_`x'.png", replace		
restore

 */

**************
*VOLUMENES SCATTER 
**************

* - AGRO 

*- Deva 2014m2 
forvalues x = 1/8 { 
preserve 
*desde 2008 - 2020M2 
drop if time<576 | time>721

		collapse (mean) lvol_agro, by(dist_group`x' time)
		drop if dist_group`x'==.
		reshape wide lvol_agro, i(time) j(dist_group`x')
		
		gen diff = lvol_agro1 - lvol_agro1
		
		
		twoway (scatter diff time) (qfit diff time if time<649) (qfit diff time if time>649), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(649, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\volumenes\volumenes scatter\agro\deva2014-dist`x'.png", replace
		
		*volumenes de venta eess cerca 
			twoway (scatter lvol_agro1 time) (qfit lvol_agro1 time if time<649) (qfit lvol_agro1 time if time>649), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(649, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\volumenes\volumenes scatter\agro\deva2014-dist`x'-EESS-CERCA.png", replace
		
restore 
} 


*- Deva 2016m1
forvalues x = 1/8 { 
preserve 
*desde 2008 - 2020M2 
drop if time<576 | time>721

		collapse (mean) lvol_agro, by(dist_group`x' time)
		drop if dist_group`x'==.
		reshape wide lvol_agro, i(time) j(dist_group`x')
		
		gen diff = lvol_agro1 - lvol_agro2
		
		
		twoway (scatter diff time) (qfit diff time if time<672) (qfit diff time if time>672), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(672, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\volumenes\volumenes scatter\agro\deva2015-dist`x'.png", replace
		
		*Volumenes de venta EESS cerca 
		twoway (scatter lvol_agro1 time) (qfit lvol_agro1 time if time<672) (qfit lvol_agro1 time if time>672), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(672, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\volumenes\volumenes scatter\agro\deva2015-dist`x'-EESS-CERCA.png", replace
		
restore 
} 

*- Deva 2018m9  
forvalues x = 1/8 { 
preserve 
*desde 2008 - 2020M2 
drop if time<576 | time>721

		collapse (mean) lvol_agro, by(dist_group`x' time)
		drop if dist_group`x'==.
		reshape wide lvol_agro, i(time) j(dist_group`x')
		
		gen diff = lvol_agro1 - lvol_agro2
		
		
		twoway (scatter diff time) (qfit diff time if time<704) (qfit diff time if time>704), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(704, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\volumenes\volumenes scatter\agro\deva2018-dist`x'.png", replace
		
		*volumenes de venta eess cerca 
		twoway (scatter lvol_agro1 time) (qfit lvol_agro1 time if time<704) (qfit lvol_agro1 time if time>704), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(704, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\volumenes\volumenes scatter\agro\deva2018-dist`x'-EESS-CERCA.png", replace
		
restore 
} 


* - TRANSPORTE 
*- Deva 2014m2 
forvalues x = 1/8 { 
preserve 
*desde 2008 - 2020M2 
drop if time<576 | time>721

		collapse (mean) lvol_transp, by(dist_group`x' time)
		drop if dist_group`x'==.
		reshape wide lvol_transp, i(time) j(dist_group`x')
		
		gen diff = lvol_transp1 - lvol_transp2
		
		
		twoway (scatter diff time) (qfit diff time if time<649) (qfit diff time if time>649), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(649, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\volumenes\volumenes scatter\transporte\deva2014-dist`x'.png", replace
		
		*Volumenes de venta EESS cerca 
		twoway (scatter lvol_transp1 time) (qfit lvol_transp1 time if time<649) (qfit lvol_transp1 time if time>649), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(649, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\volumenes\volumenes scatter\transporte\deva2014-dist`x'-EESS-CERCA.png", replace
		
		
restore 
} 


*- Deva 2016m1
forvalues x = 1/8 { 
preserve 
*desde 2008 - 2020M2 
drop if time<576 | time>721

		collapse (mean) lvol_transp, by(dist_group`x' time)
		drop if dist_group`x'==.
		reshape wide lvol_transp, i(time) j(dist_group`x')
		
		gen diff = lvol_transp1 - lvol_transp2
		
		*diff volumenes cerca - lejos 
		twoway (scatter diff time) (qfit diff time if time<672) (qfit diff time if time>672), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(672, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\volumenes\volumenes scatter\transporte\deva2015-dist`x'.png", replace
		
		*volumenes de venta EESS cerca 
			twoway (scatter lvol_transp1 time) (qfit lvol_transp1 time if time<672) (qfit lvol_transp1 time if time>672), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(672, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\volumenes\volumenes scatter\transporte\deva2015-dist`x'-EESS-CERCA.png", replace
		
restore 
} 

*- Deva 2018m9  
forvalues x = 1/8 { 
preserve 
*desde 2008 - 2020M2 
drop if time<576 | time>721

		collapse (mean) lvol_transp, by(dist_group`x' time)
		drop if dist_group`x'==.
		reshape wide lvol_transp, i(time) j(dist_group`x')
		
		gen diff = lvol_transp1 - lvol_transp2
		
		
		twoway (scatter diff time) (qfit diff time if time<704) (qfit diff time if time>704), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(704, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\volumenes\volumenes scatter\transporte\deva2018-dist`x'.png", replace
		
		*volumenes de venta EESS cerca 
		twoway (scatter lvol_transp1 time) (qfit lvol_transp1 time if time<704) (qfit lvol_transp1 time if time>704), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(704, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\volumenes\volumenes scatter\transporte\deva2018-dist`x'-EESS-CERCA.png", replace
		
restore 
} 



* - AL PUBLICO 
*- Deva 2014m2 
forvalues x = 1/8 { 
preserve 
*desde 2008 - 2020M2 
drop if time<576 | time>721

		collapse (mean) lvol_pub, by(dist_group`x' time)
		drop if dist_group`x'==.
		reshape wide lvol_pub, i(time) j(dist_group`x')
		
		gen diff = lvol_pub1 - lvol_pub2
		
		
		twoway (scatter diff time) (qfit diff time if time<649) (qfit diff time if time>649), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(649, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\volumenes\volumenes scatter\publico\deva2014-dist`x'.png", replace
		
		*volumenes de venta EESS cerca 
		twoway (scatter lvol_pub1 time) (qfit lvol_pub1 time if time<649) (qfit lvol_pub1 time if time>649), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(649, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\volumenes\volumenes scatter\publico\deva2014-dist`x'-EESS-CERCA.png", replace
		
restore 
} 


*- Deva 2016m1
forvalues x = 1/8 { 
preserve 
*desde 2008 - 2020M2 
drop if time<576 | time>721

		collapse (mean) lvol_pub, by(dist_group`x' time)
		drop if dist_group`x'==.
		reshape wide lvol_pub, i(time) j(dist_group`x')
		
		gen diff = lvol_pub1 - lvol_pub2
		
		
		twoway (scatter diff time) (qfit diff time if time<672) (qfit diff time if time>672), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(672, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\volumenes\volumenes scatter\publico\deva2015-dist`x'.png", replace
		
		*volumenes promedio de venta EESS cerca 
		twoway (scatter lvol_pub1 time) (qfit lvol_pub1 time if time<672) (qfit lvol_pub1 time if time>672), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(672, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\volumenes\volumenes scatter\publico\deva2015-dist`x'-EESS-CERCA.png", replace
		
		
restore 
} 

*- Deva 2018m9  
forvalues x = 1/8 { 
preserve 
*desde 2008 - 2020M2 
drop if time<576 | time>721

		collapse (mean) lvol_pub, by(dist_group`x' time)
		drop if dist_group`x'==.
		reshape wide lvol_pub, i(time) j(dist_group`x')
		
		gen diff = lvol_pub1 - lvol_pub2
		
		*diferencia cerca - lejos 
		twoway (scatter diff time) (qfit diff time if time<704) (qfit diff time if time>704), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(704, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\volumenes\volumenes scatter\publico\deva2018-dist`x'.png", replace
		
		*volumenes promedio de venta EESS cerca 
		twoway (scatter lvol_pub1 time) (qfit lvol_pub1 time if time<704) (qfit lvol_pub1 time if time>704), /// 
		scheme(modern) ytitle("") xtitle("")  ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ylabel(#20, labsize(small) nogrid) ///
		xline(704, lpattern(dash) lcolor(black)) legend(off) ///
		plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) plotregion(fcolor(gs15)) 
		graph export "salidas\volumenes\volumenes scatter\publico\deva2018-dist`x'-EESS-cerca.png", replace
		
restore 
} 





**************************************************
*VOLUMENES CON DEVALUACIONES 
**************************************************

*Q ARGENTINA 

*Q POR PROVINCIA 

*Q CERCA VS LEJOS 


**************************************************
*VOLUMENES CON BRECHA CAMBIARIA 
**************************************************

*Q ARGENTINA 

*Q POR PROVINCIA 

*Q CERCA VS LEJOS 









*Tc oficial y blue all
 /* tsline blue_venta oficial_venta, ///
		scheme(modern) name(tc) ///
		legend(on col(2) pos(6)  lab(1 "TC blue") lab(2 "TC oficial")) ///
		ytitle("") xtitle("") ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small)) ///
		ylabel(#10, labsize(small))
	graph export "salidas/graficos/tipos de cambio/tc.png", replace */
