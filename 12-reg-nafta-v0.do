
set autotabgraph on 

*---------------------------------------------------------------------------*
*---------------regresiones NAFTA 2
*---------------------------------------------------------------------------* 
use "bases\base-precios\p-pulidas-distancias\nafta_2_2016_2022_v2.dta", clear 

*seteo panel 
tsset id time 

*Ventas por comprador: Moving average: 2 periodos antes, el 0 y 1+
tssmooth ma lvol_pub2=lvol_pub, window(2 0 1)

*limpio un poco la bases
keep if volumen_pub!=. | lvol_pub!=.

*Para contar EESS por frontera y provincia 
gen aux = 1 
bysort id: gen count_eess = sum(aux)
replace count_eess = . if count_eess > 1 


*log del precio en usd 
gen p_surtidor_usd = p_surtidor_pub / oficial_venta 
gen lp_surtidor_usd  = ln(p_surtidor_usd)

*provincia 
encode provincia, gen(prov)




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

*Grupos de distancia 50km vs >200km -este va- MINUTOS 
gen dist_group8_minutos = . 
replace dist_group8_minutos=1 if dist_minima_minutos<=60
replace dist_group8_minutos=2 if dist_minima_minutos>=150
label def dist_group8_minutos 1 "<60min paso fronterizo" 2 ">150min" 
label val dist_group8_minutos dist_group8_minutos  



********************************
*--DIFF ESTATICO: (ESTÁ CORRIDO ASÍ)
*post: if time>=2019m11=718  
*pre:   2017m8 a 2019m10 
*********************************


*-------------------------------------------------------------------------------------------*
*---  Diff-in-diff estático
*-------------------------------------------------------------------------------------------*
*saco todas las obs anteriores a 2017m8 
drop if time<691 

*FIRST STAGE:
gen post=. 
replace post=1 if time>=718 & time!=. 
replace post=0 if (time>=691 & time<718)


*TREAT- CONTROL: variables de distancia 
rename dist_group8 treat_l
rename dist_group8_ruta treat_r
rename dist_group8_minutos treat_m

local treat "treat_lineal treat_ruta treat_minutos" 
local countries "BOL BRA PRY URY CHL" 

 *MENDOZA NO TIENE EESS EN NINGUN GRUPO TRATAMIENTO. SACAR 
drop if provincia=="MENDOZA" 

*DISTANCIA LINEAL 
foreach c of local countries{
	*raw		
	est clear
	eststo: xtreg lvol_pub2  ib0.post##ib2.treat_l if frontera_pais=="`c'" & treat_l!=. 
	estadd local provinces  "No"
	estadd local price "No"
	
	*FE por provincia 
	eststo: xtreg lvol_pub2  ib0.post##ib2.treat_l i.prov if frontera_pais=="`c'" & treat_l!=. 
	estadd local provinces "Yes"
	estadd local price  "No"
	
	*FE por provincia y control por el P en usd 
	eststo: xtreg lvol_pub2  ib0.post##ib2.treat_l i.prov lp_surtidor_usd if frontera_pais=="`c'" & treat_l!=. 
	estadd local provinces  "Yes"
	estadd local price "Yes"


	esttab using "salidas/reg/nafta/standard-did/nafta-`c'-lineal-g8.tex" , ///
	keep(1.post 1.treat_l  ///
	1.post#1.treat_l  _cons) ///
	coeflabel(1.post "Post"  1.treat_l "Treat" ///
	1.post#1.treat_l "Post X Treat (lineal)" _cons "Constant") ///
	stats(N provinces price, label("Observations" "Provinces FE" "Price") fmt(%9.0fc))  ///
	b(3) se(3) star(* 0.10 ** 0.05 *** 0.01)  compress booktabs   nomtitles  ///
	title(`c' - Lineal distance) replace 
}



*DISTANCIA POR RUTA 
foreach c of local countries{
	*raw		
	est clear
	eststo: xtreg lvol_pub2  ib0.post##ib2.treat_r if frontera_pais=="`c'" & treat_r!=. 
	estadd local provinces  "No"
	estadd local price "No"
	
	*FE por provincia 
	eststo: xtreg lvol_pub2  ib0.post##ib2.treat_r i.prov if frontera_pais=="`c'" & treat_r!=. 
	estadd local provinces "Yes"
	estadd local price  "No"
	
	*FE por provincia y control por el P en usd 
	eststo: xtreg lvol_pub2  ib0.post##ib2.treat_r i.prov lp_surtidor_usd if frontera_pais=="`c'" & treat_r!=. 
	estadd local provinces  "Yes"
	estadd local price "Yes"


	esttab using "salidas/reg/nafta/standard-did/nafta-`c'-ruta-g8.tex" , ///
	keep(1.post 1.treat_r  ///
	1.post#1.treat_r  _cons) ///
	coeflabel(1.post "Post"  1.treat_r "Treat" ///
	1.post#1.treat_r "Post X Treat (route)" _cons "Constant") ///
	stats(N provinces price, label("Observations" "Provinces FE" "Price") fmt(%9.0fc))  ///
	b(3) se(3) star(* 0.10 ** 0.05 *** 0.01)  compress booktabs   nomtitles  ///
	title(`c' - Route distance) replace 
}


*DISTANCIA EN MINUTOS 
foreach c of local countries{
	*raw		
	est clear
	eststo: xtreg lvol_pub2  ib0.post##ib2.treat_m if frontera_pais=="`c'" & treat_m!=. 
	estadd local provinces  "No"
	estadd local price "No"
	
	*FE por provincia 
	eststo: xtreg lvol_pub2  ib0.post##ib2.treat_m i.prov if frontera_pais=="`c'" & treat_m!=. 
	estadd local provinces "Yes"
	estadd local price  "No"
	
	*FE por provincia y control por el P en usd 
	eststo: xtreg lvol_pub2  ib0.post##ib2.treat_m i.prov lp_surtidor_usd if frontera_pais=="`c'" & treat_m!=. 
	estadd local provinces  "Yes"
	estadd local price "Yes"


	esttab using "salidas/reg/nafta/standard-did/nafta-`c'-time-g8.tex" , ///
	keep(1.post 1.treat_m  ///
	1.post#1.treat_m  _cons) ///
	coeflabel(1.post "Post"  1.treat_m "Treat" ///
	1.post#1.treat_m "Post X Treat (minutes)" _cons "Constant") ///
	stats(N provinces price, label("Observations" "Provinces FE" "Price") fmt(%9.0fc))  ///
	b(3) se(3) star(* 0.10 ** 0.05 *** 0.01)  compress booktabs   nomtitles  ///
	title(`c' - Time distance) replace 

}




*-------------------------------------------------------------------------------------------*
*---  Diff-in-diff dinámico / Event Study 
*-------------------------------------------------------------------------------------------*

********************************
*--Event study: 
*pre:   2017m8 a 2019m11 
*post: if time>=2019m12   (la brecha pasa de 2019m11=5%; 2019m12=14.85% a 2020m1=23% y no baja de 20% de aqui en adelante.)  
*mes omitido: 2019m11 (718)
*********************************


*--[1] create the lag/lead for treated gas stations: time to inicio de la brecha 

*- omitted 2019m11=718
gen omitted = 718
format omitted %tm
gen time_to_treat = time - omitted 


*--[2]  fill in control obs with 0:
/* This allows for the interaction between `treat` and `time_to_treat` to occur for each gas station.
 Otherwise, there may be some NAs and the estimations will be off. */

*EESS > 200km del paso fronterizo (controles): 
replace time_to_treat = 0 if dist_group8 == 2 

* this will determine the difference btw controls and treated gas stations:
g       treat = 1 if dist_group8 == 1 
replace treat = 0 if dist_group8 == 2 


*--[3] Stata won't allow factors with negative values, so let's shift
* time-to-treat to start at 0, keeping track of where the true -1 is:

summ time_to_treat
g shifted_ttt = time_to_treat - r(min)

*guardo el verdadero -1: 
summ shifted_ttt if time_to_treat == -1
local true_neg1 = r(mean)

*--[4] Regress on our interaction terms with FEs for group and year, clustering at the group (state) level
*use ib# to specify our reference group
*, a(year)  
local paises "BOL BRA PRY URY CHL" 

foreach c of local paises { 
reghdfe lvol_pub2 ib`true_neg1'.shifted_ttt if frontera_pais==`c' & treat!=.,  absorb(prov) vce(cluster prov)


*--[5] Pull out the coefficients and SEs
g coef = .
g se = .
levelsof shifted_ttt, l(times)

foreach t in `times' {
	replace coef = _b[`t'.shifted_ttt] if shifted_ttt == `t'
	replace se = _se[`t'.shifted_ttt] if shifted_ttt == `t'
}


*--[6] Make confidence intervals  z(0.95)=1.96   z(0.90)=1.645
g ci_top = coef + 1.96*se
g ci_bottom = coef - 1.96*se
 
 
*--[7] Limit ourselves to one observation per quarter
* now switch back to time_to_treat to get original timing
preserve 
keep time_to_treat coef se ci_top ci_bottom treat
*me quedo con 1 obs x periodo:
duplicates drop
sort time_to_treat

*[8] Create connected scatterplot of coefficients with CIs included with rcap
* and a line at 0 both horizontally and vertically

twoway (sc coef time_to_treat, connect(line)  msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t)) ///
	    (rcap ci_top ci_bottom time_to_treat , lcolor(navy%40)) 	///
		(function y = 0, range(time_to_treat)) , ///
		xline(0, lpattern(solid) lcolor(black)) ///
	    xtitle(Months relative to treatment, size(small)) ///
		xlabel(-27(5)30, labsize(small) nogrid) ylabel(, labsize(small) nogrid) ///
		legend(order (1 "Point estimate" 2 "95% CI") region(lcolor(black)) pos(6)) ///
		ttext(0.8 -15  "Exchange rate gap = 0"  .8 15  "Exchange rate gap > 0", color(gs2) size(small)) ///
		scheme(modern) ///
		note("Frontera: Brasil") ///
		name(bra) 
		
		graph export "salidas\reg\gasoil\graph-did\prueba0\bra.png", replace
restore 






*OPCION CON EL COMANDO EVENTDD : 

eventdd lvol_pub  i.prov if frontera_pais=="BRA" & dist_group8!=., ///
	timevar(time_to_treat) ///
	graph_op(ytitle("Cross border shopping BRA") ///
	xtitle(Months relative to treatment, size(small)) /// 
	xlabel(-30(5)30, labsize(small) nogrid) ylabel(, labsize(small) nogrid) ///
	legend(on lab(1 "95% CI") lab(2 "Point estimate") region(lcolor(black)) pos(6)) ///
	 scheme(modern) ///
	plotregion(ifcolor(gs15) fcolor(gs15) lstyle(none) lcolor(gs15))  ///
	ttext(0.8 -15  "Exchange rate gap = 0"  .8 15  "Exchange rate gap > 0", color(gs2) size(small))name(braa) )  ///
	ci(rcap, lcolor(blue)) 
	
	

*--[4]
*--[5]
*--[6]


		