*------------------------------------------------
* Dofile para armar brecha cambiaria 
* DATA diaria: Ambito financiero 1-01-2055 a 2-08-2022
*------------------------------------------------

*blue 

import excel using "raw-data\ambito financiero\serie tc.xlsx", firstrow sheet("blue ") case(lower) clear 
*indicador de mes-año
 gen my = mofd(time)
format my %tm
collapse (mean) blue_venta blue_compra, by(my)
save "bases\tc\serie-blue.dta", replace 

 
 
*oficial 

import excel using "raw-data\ambito financiero\serie tc.xlsx", firstrow sheet("oficial") case(lower) clear 
gen my = mofd(time) 
format my %tm 
collapse (mean) oficial_venta oficial_compra, by(my) 
save "bases\tc\serie-oficial.dta", replace 
 

use "bases\tc\serie-blue.dta", clear 
merge 1:1 my using "bases\tc\serie-oficial" 

drop if (my==. & blue_compra==. &  blue_venta==.)

*brecha 
gen brecha = . 
replace brecha = (blue_venta - oficial_venta) / oficial_venta

gen brechap = 100*brecha 

tsset my 


*formateo sin decimales 
format blue_venta %8.0g
format oficial_venta %8.0g

 




/* 
*Tc oficial y blue all  angle(stdarrow)
 tsline blue_venta oficial_venta, ///
		scheme(modern) ///
		legend(on col(2) pos(6)  lab(1 "TC blue") lab(2 "TC oficial")) ///
		ytitle("") xtitle("") ///
		xlabel(#10, valuelabels  labsize(small)) ///
		ylabel(#10, labsize(small))
	*graph export "salidas/graficos/tipos de cambio/tc.png", replace


*tc oficial y blue 2010-2022 angle(stdarrow) 
tsline blue_venta oficial_venta if tin(2010m1, 2022m8), ///
		scheme(modern)  ///
		legend(on col(2) pos(6)  lab(1 "TC blue") lab(2 "TC oficial")) ///
		ytitle("") xtitle("") ///
		xlabel(#10, valuelabels labsize(small)) ///
		ylabel(#10, labsize(small))
	*graph export "salidas/graficos/tipos de cambio/tc2010-2022.png", replace
	
*tc oficial y blue 2005-2009 angle(stdarrow)
tsline blue_venta oficial_venta if tin(2005m1, 2009m12), ///
		scheme(modern) ///
		legend(on col(2) pos(6)  lab(1 "TC blue") lab(2 "TC oficial")) ///
		ytitle("") xtitle("") ///
		xlabel(#10, valuelabels  labsize(small)) ///
		ylabel(#10, labsize(small))
	*graph export "salidas/graficos/tipos de cambio/tc2005-2009.png", replace

*tc oficial y blue 2011-2016  - angle(stdarrow)
tsline blue_venta oficial_venta if tin(2011m1, 2016m1), ///
		scheme(modern)  ///
		legend(on col(2) pos(6)  lab(1 "TC blue") lab(2 "TC oficial")) ///
		ytitle("") xtitle("") ///
		xlabel(#10, valuelabels  labsize(small)) ///
		ylabel(#10, labsize(small))
	*graph export "salidas/graficos/tipos de cambio/tc2011-2016.png", replace
	
*tc oficial y blue 2015m12-2019m12   angle(stdarrow)
tsline blue_venta oficial_venta if tin(2015m12, 2019m12), ///
		scheme(modern)  ///
		legend(on col(2) pos(6)  lab(1 "TC blue") lab(2 "TC oficial")) ///
		ytitle("") xtitle("") ///
		xlabel(#10, valuelabels  labsize(small)) ///
		ylabel(#10, labsize(small))
	*graph export "salidas/graficos/tipos de cambio/tc2015-2019.png", replace

*tc oficial y blue 2015m12-2019m12   angle(stdarrow)
tsline blue_venta oficial_venta if tin(2020m1, 2022m8), ///
		scheme(modern)  ///
		legend(on col(2) pos(6)  lab(1 "TC blue") lab(2 "TC oficial")) ///
		ytitle("") xtitle("") ///
		xlabel(#10, valuelabels  labsize(small)) ///
		ylabel(#10, labsize(small))
	*graph export "salidas/graficos/tipos de cambio/tc2020-2022.png", replace
	
*tc oficial y blue 2016 en adelante    angle(stdarrow) 
tsline blue_venta oficial_venta if tin(2016m1, 2022m8), ///
		scheme(modern)  ///
		legend(on col(2) pos(6)  lab(1 "TC blue") lab(2 "TC oficial")) ///
		ytitle("") xtitle("") ///
		xlabel(#10, valuelabels labsize(small)) ///
		ylabel(#10, labsize(small))
	*graph export "salidas/graficos/tipos de cambio/tc2016-2022.png", replace



*graficos tc vendedor oficial y blue; brecha cambiaria 
twoway (tsline blue_venta oficial_venta, ///
		yaxis(1) ytitle("",axis(1)) xtitle("")  ///
		ylabel(#10, labsize(small)) xlabel(#15, valuelabels angle(stdarrow) labsize(small))) ///    
		(tsline brecha,  ///
		yaxis(2) ytitle("",axis(2)) xtitle("") ///
		ylabel(#10, labsize(small))  xlabel(#15, valuelabels angle(stdarrow) labsize(small))), ///
		scheme(modern)  ///
		legend(on col(3) pos(6) lab(1 "TC blue") lab(2 "TC oficial") lab(3 "Brecha tc")) 
		*graph export "salidas/graficos/tipos de cambio/tc-brecha-2005-2022.png", replace
		
*graficos tc vendedor oficial y blue; brecha cambiaria 2010 en adelante 
twoway (tsline blue_venta oficial_venta if tin(2010m1, 2022m8), ///
		yaxis(1) ytitle("",axis(1)) xtitle("")  ///
		ylabel(#10, labsize(small)) xlabel(#15, valuelabels angle(stdarrow) labsize(small))) ///    
		(tsline brecha if tin(2010m1, 2022m8),  ///
		yaxis(2) ytitle("",axis(2)) xtitle("") ///
		ylabel(#10, labsize(small))  xlabel(#15, valuelabels angle(stdarrow) labsize(small))), ///
		scheme(modern)  ///
		legend(on col(3) pos(6) lab(1 "TC blue") lab(2 "TC oficial") lab(3 "Brecha tc")) 
		*graph export "salidas/graficos/tipos de cambio/tc-brecha-2010-2022.png", replace
		
*graficos tc vendedor oficial y blue; brecha cambiaria 2005-2009 en adelante 
twoway (tsline blue_venta oficial_venta if tin(2005m1, 2009m12), ///
		yaxis(1) ytitle("",axis(1)) xtitle("")  ///
		ylabel(#10, labsize(small)) xlabel(#15, valuelabels angle(stdarrow) labsize(small))) ///    
		(tsline brecha if  tin(2005m1, 2009m12),  ///
		yaxis(2) ytitle("",axis(2)) xtitle("") ///
		ylabel(#10, labsize(small))  xlabel(#15, valuelabels angle(stdarrow) labsize(small))), ///
		scheme(modern)  ///
		legend(on col(3) pos(6) lab(1 "TC blue") lab(2 "TC oficial") lab(3 "Brecha tc")) 
		*graph export "salidas/graficos/tipos de cambio/tc-brecha-2005-2009.png", replace
		

*brecha pelada 
		tsline brechap, ///
		scheme(modern)  ///
		legend(on col(1) pos(6)  lab(1 "Exchange rate gap")) ///
		ytitle("") xtitle("") ///
		xlabel(#15, valuelabels angle(stdarrow) labsize(small)) ///
		ylabel(#10, labsize(small))
	graph export "salidas/graficos/tipos de cambio/brecha2005-2022.png", replace
	
*brecha pelada de 2005 - 2009 
	tsline brechap  if tin(2005m1, 2009m12), ///
	scheme(modern)  ///
	legend(on col(1) pos(6)  lab(1 "Exchange rate gap")) ///
	ytitle("") xtitle("") ///
	xlabel(#10, valuelabels angle(stdarrow) labsize(small)) ///
	ylabel(#10, labsize(small))
	graph export "salidas/graficos/tipos de cambio/brecha2005-2009.png", replace


*brecha pelada de 2010 en adelante (en vez del tlabel se puede poner valuelabels) angle(stdarrow) 
	tsline brechap  if tin(2010m1, 2022m8), ///
	scheme(modern) ///
	legend(on col(1) pos(6)  lab(1 "Exchange rate gap")) ///
	ytitle("") xtitle("") ///
	xlabel(#8, valuelabels  labsize(small)) ///
	ylabel(#10, labsize(small))
	graph export "salidas/graficos/tipos de cambio/brecha2010-2022.png", replace
	
*brecha pelada GOBIERNO DE MM 
	twoway connected brechap my if tin(2015m12, 2019m12), ///
	scheme(modern)  leg(on) msymbol(d) msize(small) lcolor(dkgreen) mcolor(dkgreen) ///
	legend(on col(1) pos(6)  lab(1 "Exchange rate gap")) ///
	ytitle("") xtitle("") ///
	xlabel(#15, valuelabels angle(stdarrow) labsize(small)) ///
	ylabel(#10, labsize(small))
	graph export "salidas/graficos/tipos de cambio/brecha2015-2019.png", replace
	
*/	 
	
	
*---------------------------------------------------------------------------------*
*--FIGURAS FINALES BRECHA CAMBIARIA - TESIS 
*---------------------------------------------------------------------------------*

	
*Brecha cambiaria + Barril Criollo Ene2015 - Ago2017  - ESTA VA -MODIFICAR ACA SI VAS A MOVER EL OTRO-
gen upper = 120 
local shaded upper my if inrange(my, 661, 690), bcolor(gs14) lcolor(gs14) lwidth(0) barwidth(1.1) leg(off) 

 twoway (bar `shaded' ) ///
	   (connected brechap my if tin(2010m1, 2022m8) , leg(on) msymbol(O) msize(medsmall) lcolor(dkgreen%60) mcolor(dkgreen%60)), ///
	    xline(660, lpattern(shortdash) lcolor(gs8)) ///
		xline(691, lpattern(shortdash) lcolor(gs8)) ///
	    legend(off) ///
		scheme(modern) ///
		ytitle("Exchange rate gap (%)", size(small)) xtitle("") ///
		xlabel(600 624 660 691 720 751, valuelabels  labsize(small) nogrid) ///
		ylabel(#10, labsize(small) nogrid) ///
		text(110 676 "{it:Barril Criollo}", color(navy) size (small)) ///
		text(105 676 "{it:Policy}", color(navy) size (small))
	graph export "salidas/graficos/tipos de cambio/brecha-barril.png", replace
    graph export "salidas/archivos finales/brecha-barril.pdf", replace		




	
*brecha sola de 2017en adelante -Sin texto-  ESTA VA.
/* twoway connected brechap my if tin(2017m8, 2022m8), ///
	leg(on) msymbol(d) msize(small) lcolor(dkgreen) mcolor(dkgreen) ///
	xline(718, lpattern(dash) lcolor(black)) /// 
	scheme(modern)  ///
	legend(on col(1) pos(6)  lab(1 "Exchange rate gap") region(lcolor(black)) ) ///
	ytitle("") xtitle("") ///
	xlabel(691 700 708 718 724 731 737 744 751, valuelabels  labsize(small) nogrid) ///
	ylabel(#10, labsize(small) nogrid)
	graph export "salidas/graficos/tipos de cambio/brecha2017m8-2022m8-v1.png", replace
 */


*brecha sola de 2017en adelante -Con texto exchange rate gap=0 / exchange rate gap>0- ESTA VA.
*715 = Agosto2019
gen up = 120
local shaded_up up my if inrange(my, 723, 741), bcolor(gs14) barwidth(1.1)  lcolor(gs14) lwidth(0) leg(off)

twoway  (bar `shaded_up') ///
          (connected brechap my if tin(2017m8, 2022m8), ///
	      leg(on) msymbol(O) msize(medsmall) lcolor(dkgreen%60) mcolor(dkgreen%60) ///
	      xline(715, lpattern(dash) lcolor(black)) /// 
	      xline(722, lpattern(shortdash) lcolor(gs8)) ///
	      xline(742, lpattern(shortdash) lcolor(gs8)) ///
	      scheme(modern)  ///
	      legend(off) ///
	      ytitle("Exchange rate gap (%)", size(small))  xtitle("") ///
	      xlabel(691 700 708 715 722 729 735 742 751, valuelabels  labsize(small) nogrid) ///
	      ylabel(#10, labsize(small) nogrid) ///
	      text(117 704  "Exchange rate gap = 0", color(cranberry) size(small) box lcolor(cranberry) fcolor(white) margin(vsmall)) ///
	      text(117 732  "Exchange rate gap > 0", color(navy)      size(small) box lcolor(navy) fcolor(white) margin(vsmall))  ///
		  text(10 732 "{it:Closed borders}", color(navy) size (small)) ) 
		  
		  
	      graph export "salidas/graficos/tipos de cambio/brecha.png", replace
          graph export "salidas/archivos finales/brecha.pdf", replace
--




*brecha sola de 2017en adelante -Con texto before / after -  
twoway connected brechap my if tin(2017m8, 2022m8), ///
	leg(on) msymbol(d) msize(small) lcolor(dkgreen) mcolor(dkgreen) ///
	xline(718, lpattern(dash) lcolor(black)) /// 
	scheme(modern)  ///
	legend(on col(1) pos(6)  lab(1 "Exchange rate gap") region(lcolor(black)) ) ///
	ytitle("") xtitle("") ///
	xlabel(691 700 708 718 724 731 737 744 751, valuelabels  labsize(small) nogrid) ///
	ylabel(#10, labsize(small) nogrid) ///
		ttext(117 708  "Before", color(cranberry) size(small) box lcolor(cranberry) fcolor(white) margin(vsmall)) ///
	ttext(117 730  "After", color(navy)      size(small) box lcolor(navy) fcolor(white) margin(vsmall)) 
	graph export "salidas/graficos/tipos de cambio/brecha2017m8-2022m8-v3.png", replace





--

*renombro para mergear con base combustibles:
rename my time 
	
save "bases\tc\tc-arg.dta", replace 

*renombro tc en la base del tc oficial 
use "bases\tc\serie-oficial.dta", clear 
rename my time 
save "bases\tc\serie-oficial.dta", replace




