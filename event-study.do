********************************
*--Event study: 
*pre:   2017m8 a 2019m10 
*post: if time>=2019m11  (la brecha pasa de 2019m11=5%; 2019m12=14.85% a 2020m1=23% y no baja de 20% de aqui en adelante.)  
*mes omitido: 2019m10 (717)
*********************************


*--[1] create the lag/lead for treated gas stations: time to event (inicio de la brecha>0) 
*- t=0 ----> 2019m11=718
gen aux_date = 718
format aux_date %tm
gen time_to_treat = time - aux_date 


*--[2]  fill in control obs with 0:
/* This allows for the interaction between `treat` and `time_to_treat` to occur for each gas station. */

*EESS > 200km del paso fronterizo (controles): 
replace time_to_treat = 0 if dist_group8_ruta == 2 

*Controls and treated gas stations:
g       treat = 1 if dist_group8_ruta == 1 
replace treat = 0 if dist_group8_ruta == 2 


*--[3] Stata won't allow factors with negative values, so let's shift
* time-to-treat to start at 0, keeping track of where the true -1 is:
summ time_to_treat
g shifted_ttt = time_to_treat - r(min)

*guardo el verdadero -1: 
summ shifted_ttt if time_to_treat == -1
local true_neg1 = r(mean)
di `true_neg1'

*--[4] Regress 
local paises "BRA PRY URY CHL BOL" 

*PRY URY CHL BOL

*-------------------------------------------
*--DISTANCIA RUTA
*-------------------------------------------

foreach c of local paises { 
*ib.`true_neg1' --> quiero que la omitida sea el periodo -1 (verdadero) 
preserve 
	keep if frontera_pais=="`c'"
	keep if treat!=. 

	xtreg lvol_pub2 ib`true_neg1'.shifted_ttt  lp_surtidor_usd i.prov 

*--[5] Coeficientes + se: 
	g coef = .
	g se = .
	levelsof shifted_ttt, l(times)

	foreach t in `times' {
		replace coef = _b[`t'.shifted_ttt] if shifted_ttt == `t'
	     replace se = _se[`t'.shifted_ttt] if shifted_ttt == `t'
}

	*--[6] CI:  z(0.95)=1.96   z(0.90)=1.645
	g ci_top = coef + 1.96*se
	g ci_bottom = coef - 1.96*se
		
 
	*--[7] Graficar con el time_to_treat original 
	keep time_to_treat coef se ci_top ci_bottom treat
	*me quedo con 1 obs x periodo:
	duplicates drop
	sort time_to_treat
	
	*[8] Create connected scatterplot of coefficients with CIs included with rcap
	twoway (sc coef time_to_treat, connect(line)  msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t)) ///
			(rcap ci_top ci_bottom time_to_treat , lcolor(navy%40)) 	///
			(function y = 0, range(time_to_treat)) , ///
			xline(0, lpattern(solid) lcolor(black)) ///
			xtitle(Months relative to treatment, size(small)) ///
			xlabel(#30, labsize(small) nogrid) ylabel(, labsize(small) nogrid) ///
			legend(order (1 "Point estimate" 2 "95% CI") region(lcolor(black)) pos(6)) ///
			ttext(0.8 -15  "Exchange rate gap = 0"  .8 15  "Exchange rate gap > 0", color(gs2) size(small)) ///
			scheme(modern) ///
			note("Frontera: `c' - T:<50km C:>200km") 
	
			
			graph export "salidas\reg\nafta\dynamic-did\nafta-`c'-g8-ruta.png", replace

restore 

}












*OPCION CON EL COMANDO EVENTDD : 
/* eventdd lvol_pub  i.prov if frontera_pais=="BRA" & dist_group8!=., ///
	timevar(time_to_treat) ///
	graph_op(ytitle("Cross border shopping BRA") ///
	xtitle(Months relative to treatment, size(small)) /// 
	xlabel(-30(5)30, labsize(small) nogrid) ylabel(, labsize(small) nogrid) ///
	legend(on lab(1 "95% CI") lab(2 "Point estimate") region(lcolor(black)) pos(6)) ///
	 scheme(modern) ///
	plotregion(ifcolor(gs15) fcolor(gs15) lstyle(none) lcolor(gs15))  ///
	ttext(0.8 -15  "Exchange rate gap = 0"  .8 15  "Exchange rate gap > 0", color(gs2) size(small))name(braa) )  ///
	ci(rcap, lcolor(blue))  */
	