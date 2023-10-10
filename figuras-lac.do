

**********************************************************
*-- SERIES DE P ARG Y PAISES FRONTERIZOS - REHACER ESTE GRAF CON LAS SERIES NUEVAS DE BOL Y BRA- 
**********************************************************

local paises "ury bol bra chl pry" 

*guardo las bases en dta NAFTA
/* foreach m of local paises { 
	di "Pais: `m'" 
	import excel using "G:/Mi unidad/Malena/FCE/Maestria/Tesis/raw-data/series lac/para matchear/`m'.xlsx", firstrow sheet("stata-nafta") case(lower) clear 
	destring mes year, replace 
	save "G:/Mi unidad/Malena/FCE/Maestria/Tesis/raw-data/series lac/para matchear/`m'_nafta.dta", replace  
}	
  */
 
 
/* *guardo bases en dta GASOIL 
 foreach m of local paises { 
	di "Pais: `m'" 
	import excel using "G:/Mi unidad/Malena/FCE/Maestria/Tesis/raw-data/series lac/para matchear/`m'.xlsx", firstrow sheet("stata-gasoil") case(lower) clear 
	destring mes year, replace 
	save "G:/Mi unidad/Malena/FCE/Maestria/Tesis/raw-data/series lac/para matchear/`m'_gasoil.dta", replace  
}	

 */
 
 
 
 
******************************
*-GRAFICOS NAFTA 
******************************

use  "bases\base-precios\p-pulidas-distancias\nafta_2_2016_2022_v2.dta", clear 

*matcheo bases 
foreach m of local paises { 
	di "Pais: `m'"
	merge m:m year mes using "X:\Mi unidad\Maestria en economia\Tesis-version vieja\raw-data\series lac\para matchear/`m'_nafta" , gen(m_`m') 
}	

*Armo variables de Precios 
egen p_nafta_bra = rowmean(p_nafta_rg_do_sul p_nafta_santa_catarina p_nafta_parana)
egen p_nafta_chl= rowmean(p_nafta_antofagasta p_nafta_atacama p_nafta_coquimbo p_nafta_valparaiso p_nafta_maule p_nafta_biobio p_nafta_araucania p_nafta_loslagos p_nafta_aysen p_nafta_magallanes)

gen p_nafta_arg_oficial = p_surtidor_pub / oficial_venta 
gen p_nafta_arg_blue    = p_surtidor_pub / blue_venta 	

*Price index (2019August=100)


*-Precio con tipo de cambio oficial 
 preserve 
	drop if time < 691 & time>749
	collapse (mean) p_nafta_bolivia p_nafta_ury p_nafta_bra p_nafta_chl p_nafta_pry p_nafta_arg_oficial , by(time) 
	
	 *44 = 2019m8 
	 	di tm(2019,8)
	   gen p_naftan_bolivia       = p_nafta_bolivia / p_nafta_bolivia[44] 
	   gen p_naftan_arg_oficial   = p_nafta_arg_oficial / p_nafta_arg_oficial[44]
	   gen p_naftan_ury           = p_nafta_ury     / p_nafta_ury[44]
	   gen p_naftan_bra           = p_nafta_bra     / p_nafta_bra[44]
	   gen p_naftan_chl           = p_nafta_chl     / p_nafta_chl[44]
	   gen p_naftan_pry           = p_nafta_pry     / p_nafta_pry[44]
	   
	format %tm time
	sort time 
	drop if time==.

	twoway (connected p_naftan_arg_oficial time, sort msymbol(o) msize(small) color(blue)) ///
		   (connected p_naftan_bra     time ,    sort msymbol(t) msize(vsmall) color(cranberry)) ///
		   (connected p_naftan_bolivia time ,    sort msymbol(t) msize(vsmall) color(teal)) ///
		   (connected p_naftan_chl     time ,    sort msymbol(t) msize(vsmall) color(purple)) ///
		   (connected p_naftan_ury     time ,    sort msymbol(t) msize(vsmall) color(dkorange)) ///
		   (connected p_naftan_pry     time ,    sort msymbol(t) msize(vsmall) color(brown)), ///
		   scheme(modern)  legend(on col(6) pos(6) lab(1 "ARG") lab(2 "BRA") lab(3 "BOL") lab(4 "CHL") lab(5 "URY") lab(6 "PRY") ///
		     region(lcolor(black))) ysc(r(0.4 1.7)) ///
			ytitle("Price index (2019 August = 100)", size(small))  xtitle("")  ///
			xlabel(672 682 693 704 715 725 737 749, valuelabels  labsize(small) nogrid) ///
			ylabel(#10, labsize(small) nogrid)  ///
			xline(715, lpattern(dash) lcolor(black)) name(oficial)  ///
		
		graph export "salidas\archivos finales\p_regular_gasoline_oficial_lac.pdf", replace

		graph export "salidas\precios\precios y brecha tc\prueba1\p_nafta_LAC_oficial_AGO-2019.png", replace
restore 




*-Precio con tipo de cambio blue
 preserve 
	drop if time < 691 & time>749
	collapse (mean) p_nafta_bolivia p_nafta_ury p_nafta_bra p_nafta_chl p_nafta_pry p_nafta_arg_blue , by(time) 
	 *44 = 2019m8
	   gen p_naftan_bolivia     = p_nafta_bolivia       / p_nafta_bolivia[44]
	   gen p_naftan_arg_blue    = p_nafta_arg_blue     / p_nafta_arg_blue[44]
	   gen p_naftan_ury         = p_nafta_ury               / p_nafta_ury[44]
	   gen p_naftan_bra         = p_nafta_bra               / p_nafta_bra[44]
	   gen p_naftan_chl         = p_nafta_chl               / p_nafta_chl[44]
	   gen p_naftan_pry         = p_nafta_pry               / p_nafta_pry[44]
	   
	format %tm time
    drop if time==. 
	
	twoway (connected p_naftan_arg_blue time, sort msymbol(o) msize(small) color(blue)) ///
		   (connected p_naftan_bra     time ,    sort msymbol(t) msize(vsmall) color(cranberry)) ///
		   (connected p_naftan_bolivia time ,    sort msymbol(t) msize(vsmall) color(teal)) ///
		   (connected p_naftan_chl     time ,    sort msymbol(t) msize(vsmall) color(purple)) ///
		   (connected p_naftan_ury     time ,    sort msymbol(t) msize(vsmall) color(dkorange)) ///
		   (connected p_naftan_pry     time ,    sort msymbol(t) msize(vsmall) color(brown)), ///
		   scheme(modern)  legend(on col(6) pos(6) lab(1 "ARG") lab(2 "BRA") lab(3 "BOL") lab(4 "CHL") lab(5 "URY") lab(6 "PRY") ///
		     region(lcolor(black))) ysc(r(0.4 1.7)) ///
			ytitle("Price index (2019 August = 100)", size(small))  xtitle("")  ///
			xlabel(672 682 693 704 715 725 737 749, valuelabels  labsize(small) nogrid) ///
			ylabel(#10, labsize(small) nogrid)  ///
			xline(715, lpattern(dash) lcolor(black)) ///
			
		graph export "salidas\archivos finales\p_regular_gasoline_blue_lac.pdf", replace
		graph export "salidas\precios\precios y brecha tc\prueba1\p_nafta_LAC_blue.png", replace
restore 



******************************
*-GRAFICOS GASOIL
******************************
use "bases\base-precios\p-pulidas-distancias\gasoil_2_2016_2022_v2.dta", clear 

*hay que traer de nuevo los TC porque hay missings en algunos meses. 

drop blue_venta blue_compra oficial_venta oficial_compra 
merge m:1 time using "bases\tc\tc-arg" , gen(merge_tc)
keep if merge_tc==3




*matcheo bases 
foreach m of local paises { 
	di "Pais: `m'"
	merge m:m year mes using "X:\Mi unidad\Maestria en economia\Tesis-version vieja\raw-data\series lac\para matchear/`m'_gasoil" , gen(m_`m') 
}	




*Armo variables de Precios 
egen p_gasoil_bra = rowmean(p_gasoil_rg_do_sul p_gasoil_santa_catarina p_gasoil_parana)
egen p_gasoil_chl= rowmean(p_gasoil_antofagasta p_gasoil_atacama p_gasoil_coquimbo p_gasoil_valparaiso p_gasoil_maule p_gasoil_biobio p_gasoil_araucania p_gasoil_loslagos p_gasoil_aysen p_gasoil_magallanes)

gen p_gasoil_arg_oficial = p_surtidor_pub / oficial_venta 
gen p_gasoil_arg_blue    = p_surtidor_pub / blue_venta 	

*-Precio con tipo de cambio oficial 
preserve 
	drop if time < 691 & time>749
	collapse (mean) p_gasoil_bolivia p_gasoil_ury p_gasoil_bra p_gasoil_chl p_gasoil_pry p_gasoil_arg_oficial , by(time) 
	  *44 = 2019m8
	   gen p_gasoiln_bolivia          = p_gasoil_bolivia /        p_gasoil_bolivia[44]
	   gen p_gasoiln_arg_oficial      = p_gasoil_arg_oficial/ p_gasoil_arg_oficial[44]
	   gen p_gasoiln_ury              = p_gasoil_ury                / p_gasoil_ury[44]
	   gen p_gasoiln_bra              = p_gasoil_bra                / p_gasoil_bra[44]
	   gen p_gasoiln_chl              = p_gasoil_chl                / p_gasoil_chl[44]
	   gen p_gasoiln_pry              = p_gasoil_pry                / p_gasoil_pry[44]
	   
	format %tm time
	drop if time==.

	twoway (connected p_gasoiln_arg_oficial time, sort msymbol(o) msize(small) color(blue)) ///
		   (connected p_gasoiln_bra     time ,    sort msymbol(t) msize(vsmall) color(cranberry)) ///
		   (connected p_gasoiln_bolivia time ,    sort msymbol(t) msize(vsmall) color(teal)) ///
		   (connected p_gasoiln_chl     time ,    sort msymbol(t) msize(vsmall) color(purple)) ///
		   (connected p_gasoiln_ury     time ,    sort msymbol(t) msize(vsmall) color(dkorange)) ///
		   (connected p_gasoiln_pry     time ,    sort msymbol(t) msize(vsmall) color(brown)), ///
		   scheme(modern)  legend(on col(6) pos(6) lab(1 "ARG") lab(2 "BRA") lab(3 "BOL") lab(4 "CHL") lab(5 "URY") lab(6 "PRY") ///
		     region(lcolor(black))) ysc(r(0.4 1.7)) ///
			ytitle("Price index (2019 August = 100)", size(small))  xtitle("")  ///
			xlabel(672 682 693 704 715 725 737 749, valuelabels  labsize(small) nogrid) ///
			ylabel(#10, labsize(small) nogrid)  ///
			xline(715, lpattern(dash) lcolor(black)) ///
			
				graph export "salidas\archivos finales\p_regular_gasoline_oficial_lac.pdf", replace
	
		graph export "salidas\precios\precios y brecha tc\prueba1\p_gasoil_LAC_oficial.png", replace
restore 

*-Precio con tipo de cambio blue
preserve 
	drop if time < 691 & time>749
	collapse (mean) p_gasoil_bolivia p_gasoil_ury p_gasoil_bra p_gasoil_chl p_gasoil_pry p_gasoil_arg_blue , by(time) 
	  *44 = 2019m8
	   gen p_gasoiln_bolivia  = p_gasoil_bolivia        / p_gasoil_bolivia[44]
	   gen p_gasoiln_arg_blue      = p_gasoil_arg_blue / p_gasoil_arg_blue[44]
	   gen p_gasoiln_ury      = p_gasoil_ury                / p_gasoil_ury[44]
	   gen p_gasoiln_bra      = p_gasoil_bra                / p_gasoil_bra[44]
	   gen p_gasoiln_chl      = p_gasoil_chl                / p_gasoil_chl[44]
	   gen p_gasoiln_pry      = p_gasoil_pry                / p_gasoil_pry[44]
	   
	format %tm time
	drop if time==. 

	twoway (connected p_gasoiln_arg_blue time, sort msymbol(o) msize(small) color(blue)) ///
		   (connected p_gasoiln_bra     time ,    sort msymbol(t) msize(vsmall) color(cranberry)) ///
		   (connected p_gasoiln_bolivia time ,    sort msymbol(t) msize(vsmall) color(teal)) ///
		   (connected p_gasoiln_chl     time ,    sort msymbol(t) msize(vsmall) color(purple)) ///
		   (connected p_gasoiln_ury     time ,    sort msymbol(t) msize(vsmall) color(dkorange)) ///
		   (connected p_gasoiln_pry     time ,    sort msymbol(t) msize(vsmall) color(brown)), ///
		   scheme(modern)  legend(on col(6) pos(6) lab(1 "ARG") lab(2 "BRA") lab(3 "BOL") lab(4 "CHL") lab(5 "URY") lab(6 "PRY") ///
		     region(lcolor(black))) ysc(r(0.4 1.7)) ///
			ytitle("Price index (2019 August = 100)", size(small))  xtitle("")  ///
			xlabel(672 682 693 704 715 725 737 749, valuelabels  labsize(small) nogrid) ///
			ylabel(#10, labsize(small) nogrid)  ///
			xline(715, lpattern(dash) lcolor(black)) ///
			
					graph export "salidas\archivos finales\p_regular_gasoil_blue_lac.pdf", replace

		graph export "salidas\precios\precios y brecha tc\prueba1\p_gasoil_LAC_blue.png", replace
restore 








 