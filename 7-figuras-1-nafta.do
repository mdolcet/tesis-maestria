***************************************
/* Dofile para armar los siguientes graficos:
	-BASE TRIMESTRAL PARA LOS GRAFICOS DE VOLUMEN- 
	- Volumenes de venta cerca/lejos con xline en los periodos de devaluacion
	- Volumenes de venta cerca/lejos con xline en los periodos de brecha cambiaria alta 
 */
**************************************** 
use "bases\base-precios\p-pulidas-distancias\nafta_2_2005_2022.dta", clear

*seteo panel mensual (di tm(2014,1) mensual di qm(2014,1) trimestral) 
tsset id time 


*paso a data trimestral 
tscollap  dist_group p_surtidor_pub p_surtidor_ext p_surtidor_transp p_surtidor_agro p_surtidor_oeess p_surtidor_osectores volumen_pub volumen_ext volumen_transp volumen_agro volumen_oeess volumen_osectores lvol_pub lvol_ext lvol_transp lvol_agro lvol_oeess lvol_osectores , gen(time2) to(q)


local compradores "pub ext transp agro oeess osectores"

******************************************************
*-GRAFICOS VOLUMENES 
******************************************************
*Q POR PROVINCIA 
*Q ARGENTINA POR COMPRADOR TODA LA SERIE
foreach x of local compradores { 
	preserve 
		collapse (mean) lvol_`x', by(time2)
		drop if lvol_`x' == . 
		gen lvol_`x'n = lvol_`x' / lvol_`x'[1]
		
	twoway (line lvol_`x'n time2, sort cmissing(n)), ///
	scheme(modern)  legend(on col(1) pos(6) lab(1 "Log(volumen) Nafta Super")) ///
	ytitle("") xtitle("") ///
	xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
	ylabel(#20, labsize(small) nogrid)  ///
	note("Comprador: `x' - trimestral") ///
	xline(216, lpattern(dash) lcolor(black)) ///
	xline(224, lpattern(dash) lcolor(black)) ///
	xline(234, lpattern(dash) lcolor(black)) ///
	plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
	plotregion(fcolor(gs15)) 	
		graph export "salidas\volumenes\vol_arg_`x'_q.png", replace
	restore 
}


*Q ARGENTINA POR COMPRADOR DESDE 2012 
*Lineas deva:2014q1 (podria ser q2), 2016q1 (podria ser q2), 2018q3 (es en sept el quilombo) 
foreach x of local compradores { 
	preserve 
	drop if time2<206
		collapse (mean) lvol_`x', by(time2)
		drop if lvol_`x' == . 
		gen lvol_`x'n = lvol_`x' / lvol_`x'[1]
		
	twoway (line lvol_`x'n time2, sort cmissing(n)), ///
	scheme(modern)  legend(on col(1) pos(6) lab(1 "Log(volumen) Nafta Super")) ///
	ytitle("") xtitle("") ///
	xlabel(#15, valuelabels angle(stdarrow) labsize(small) nogrid) ///
	ylabel(#20, labsize(small) nogrid)  ///
	note("Comprador: `x' - trimestral") ///
	xline(216, lpattern(dash) lcolor(black)) ///
	xline(224, lpattern(dash) lcolor(black)) ///
	xline(234, lpattern(dash) lcolor(black)) ///
	plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
	plotregion(fcolor(gs15)) 	
		graph export "salidas\volumenes\vol_arg_`x'_2012.png", replace
	restore 
}


*Q POR DISTANCIA A LA FRONTERA TODA LA SERIE -BASE 2005Q1- 
foreach x of local compradores { 
	preserve 
		collapse (mean) lvol_`x', by(time2 dist_group)
		gen byte basetime = 1 if time2==180 
		drop if lvol_`x' == . 
		by dist_group (basetime), sort: gen lvol_`x'n = lvol_`x' / lvol_`x'[1]
		
	twoway 	(line lvol_`x'n time if dist_group==1, sort)  ///
			(line lvol_`x'n time if dist_group==2, sort) ///
			(line lvol_`x'n time if dist_group==3, sort) ///
			(line lvol_`x'n time if dist_group==4, sort), ///
			legend(on lab(1 "<50 km") lab(2 "50-100km") lab(3 "100-150km") lab(4 ">150km")  col(4) pos(6)) ///
			scheme(modern)   ///
			ytitle("") xtitle("")  ///
			xlabel(#15, valuelabels angle(stdarrow) nogrid labsize(small)) ///
			ylabel(#15, labsize(small) nogrid)  ///
			note("Comprador: `x'") 		///	
			plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
			plotregion(fcolor(gs15)) ///
			xline(216, lpattern(dash) lcolor(black)) ///
			xline(224, lpattern(dash) lcolor(black)) ///
			xline(234, lpattern(dash) lcolor(black)) ///
			plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
			plotregion(fcolor(gs15)) 	
		graph export "salidas\volumenes\vol_dist_`x'.png", replace
	restore 
}

*Q POR DISTANCIA A LA FRONTERA TODA LA SERIE
foreach x of local compradores { 
	preserve 
		collapse (mean) lvol_`x', by(time2 dist_group)
		
	twoway 	(line lvol_`x' time if dist_group==1, sort)  ///
			(line lvol_`x' time if dist_group==2, sort) ///
			(line lvol_`x' time if dist_group==3, sort) ///
			(line lvol_`x' time if dist_group==4, sort), ///
			legend(on lab(1 "<50 km") lab(2 "50-100km") lab(3 "100-150km") lab(4 ">150km")  col(4) pos(6)) ///
			scheme(modern)   ///
			ytitle("") xtitle("")  ///
			xlabel(#15, valuelabels angle(stdarrow) nogrid labsize(small)) ///
			ylabel(#15, labsize(small) nogrid)  ///
			note("Comprador: `x'") 		///	
			plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
			plotregion(fcolor(gs15)) ///
			xline(216, lpattern(dash) lcolor(black)) ///
			xline(224, lpattern(dash) lcolor(black)) ///
			xline(234, lpattern(dash) lcolor(black)) ///
			plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
			plotregion(fcolor(gs15)) 	
		graph export "salidas\volumenes\vol_dist_`x'_level.png", replace
	restore 
}


*Q POR DISTANCIA A LA FRONTERA DESDE 2012 -BASE 2012Q1-
foreach x of local compradores { 
	preserve 
	drop if time2<206
		collapse (mean) lvol_`x', by(time2 dist_group)
		gen byte basetime = 1 if time2==206
		drop if lvol_`x' == . 
		by dist_group (basetime), sort: gen lvol_`x'n = lvol_`x' / lvol_`x'[1]
		
	twoway 	(line lvol_`x'n time if dist_group==1, sort)  ///
			(line lvol_`x'n time if dist_group==2, sort) ///
			(line lvol_`x'n time if dist_group==3, sort) ///
			(line lvol_`x'n time if dist_group==4, sort), ///
			legend(on lab(1 "<50 km") lab(2 "50-100km") lab(3 "100-150km") lab(4 ">150km")  col(4) pos(6)) ///
			scheme(modern)   ///
			ytitle("") xtitle("")  ///
			xlabel(#15, valuelabels angle(stdarrow) nogrid labsize(small)) ///
			ylabel(#15, labsize(small) nogrid)  ///
			note("Comprador: `x'") 		///	
			plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
			plotregion(fcolor(gs15)) ///
			xline(216, lpattern(dash) lcolor(black)) ///
			xline(224, lpattern(dash) lcolor(black)) ///
			xline(234, lpattern(dash) lcolor(black)) ///
			plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
			plotregion(fcolor(gs15)) 	
		graph export "salidas\volumenes\vol_dist_`x'_2012.png", replace
	restore 
}

*Q POR DISTANCIA A LA FRONTERA DESDE 2012 
foreach x of local compradores { 
	preserve 
		collapse (mean) lvol_`x', by(time2 dist_group)

	twoway 	(line lvol_`x' time if dist_group==1, sort)  ///
			(line lvol_`x' time if dist_group==2, sort) ///
			(line lvol_`x' time if dist_group==3, sort) ///
			(line lvol_`x' time if dist_group==4, sort), ///
			legend(on lab(1 "<50 km") lab(2 "50-100km") lab(3 "100-150km") lab(4 ">150km")  col(4) pos(6)) ///
			scheme(modern)   ///
			ytitle("") xtitle("")  ///
			xlabel(#15, valuelabels angle(stdarrow) nogrid labsize(small)) ///
			ylabel(#15, labsize(small) nogrid)  ///
			note("Comprador: `x'") 		///	
			plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
			plotregion(fcolor(gs15)) ///
			xline(216, lpattern(dash) lcolor(black)) ///
			xline(224, lpattern(dash) lcolor(black)) ///
			xline(234, lpattern(dash) lcolor(black)) ///
			plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
			plotregion(fcolor(gs15)) 	
		graph export "salidas\volumenes\vol_dist_`x'_2012_level.png", replace
	restore 
}

*Q POR DISTANCIA A LA FRONTERA DESDE 2012 SOLO 50 Y 75 KM. 
foreach x of local compradores { 
	preserve 
		collapse (mean) lvol_`x', by(time2 dist_group)

	twoway 	(line lvol_`x' time if dist_group==1, sort)  ///
			(line lvol_`x' time if dist_group==2, sort), ///
			legend(on lab(1 "<50 km") lab(2 "50-100km") col(4) pos(6)) ///
			scheme(modern)   ///
			ytitle("") xtitle("")  ///
			xlabel(#15, valuelabels angle(stdarrow) nogrid labsize(small)) ///
			ylabel(#15, labsize(small) nogrid)  ///
			note("Comprador: `x'") 		///	
			plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
			plotregion(fcolor(gs15)) ///
			xline(216, lpattern(dash) lcolor(black)) ///
			xline(224, lpattern(dash) lcolor(black)) ///
			xline(234, lpattern(dash) lcolor(black)) ///
			plotregion(ifcolor(gs15) lstyle(none) lcolor(gs15)) ///
			plotregion(fcolor(gs15)) 	
		graph export "salidas\volumenes\vol_dist_`x'_2012_level_12.png", replace
	restore 
}

