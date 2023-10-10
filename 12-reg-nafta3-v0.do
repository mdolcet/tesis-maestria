set autotabgraph on 


*---------------------------------------------------------------------------*
*---------------regresiones NAFTA PREMIUM
*---------------------------------------------------------------------------* 
use "bases\base-precios\p-pulidas-distancias\nafta_3_2016_2022_v3.dta", clear 


*seteo panel 
tsset id time 

*limpio un poco la bases
keep if volumen_pub!=. 

*voy a sacar a todos los volumenes menores a 1, pareciera ser un error de carga en la base
drop if volumen_pub <=1 
drop if p_surtidor==0

drop blue_venta blue_compra oficial_venta oficial_compra merge_tc
merge m:1 time using "bases\tc\tc-arg" , gen(merge_tc)
keep if merge_tc==3

*log del precio en usd 
gen p_surtidor_usd = p_surtidor / oficial_venta 
gen lp_surtidor_usd  = ln(p_surtidor_usd)

*Grupos de distancia 50km vs >200km -este va- RUTA
gen dist_group8_ruta = . 
replace dist_group8_ruta=1 if dist_minima_ruta<=50
replace dist_group8_ruta=2 if dist_minima_ruta>=200 
label def dist_group8_ruta 1 "<50km paso fronterizo" 2 ">200km" 
label val dist_group8_ruta dist_group8_ruta 
* & dist_minima_ruta<=200 & dist_minima_ruta<=300 

*Grupos de distancia 50km vs >200km -este va- 
gen dist_group8_lineal = . 
replace dist_group8_lineal=1 if dist_minima_lineal<=50
replace dist_group8_lineal=2 if dist_minima_lineal>=200 
label def dist_group8_lineal 1 "<50km paso fronterizo" 2 ">200km" 
label val dist_group8_lineal dist_group8_lineal


*Grupos de distancia 50km vs >200km -este va- MINUTOS 
gen dist_group8_minutos = . 
replace dist_group8_minutos=1 if dist_minima_minutos<=60
replace dist_group8_minutos=2 if dist_minima_minutos>=150 
label def dist_group8_minutos 1 "<60min paso fronterizo" 2 ">150min" 
label val dist_group8_minutos dist_group8_minutos  




*Hasta 2017m8 operó la politica de barril criollo. Saco las obs anteriores 
drop if time < 691

xtdes 

replace anio = year if anio==. 


*YPF vs resto
gen ypf = . 
replace ypf=1 if bandera=="YPF" 
replace ypf=2 if bandera!="YPF" & bandera!="." 

*Figura Market shares
/* graph bar (sum) volumen_pub, over(ypf) over(year) asyvars percent stack ///
       bar(1, color(dkgreen%50)) bar(2, color(edkblue%50)) ///
	 scheme(modern) ytitle("Market share (%)") ///
	 legend(order (1 "YPF" 2 "Other companies") region(lcolor(black)) pos(6) col(2) row(1) size(small)) ///
	  blabel(bar,  pos(center) format( %9.1f)) 
graph export "salidas\descriptives\market shares\ypf-resto-nafta-premium.png", replace	  
	 */


*TABLA PARA MARKET SHARES -out no lo usé al final 16-abril-2023-
/* collect table  ypf anio , stat(sum volumen_pub) name(ypf)
collect export "salidas\descriptives\YPF-market-share.xls", name(ypf) cell(a1) sheet(ypf-nafta3) modify 
*Figura 
import excel using "salidas\descriptives\YPF-market-share.xls", sheet(ypf-nafta3-stata) firstrow clear
 */


*cantidad de EESS
*Para contar EESS por frontera y provincia 
cap drop aux count_eess 
gen aux = 1 
bysort id: gen count_eess = sum(aux)
replace count_eess = . if count_eess > 1 


*Balanced panel -59 meses- 
bysort id: gen balanced = [_N]
*keep if balanced ==59
*keep if balanced>=40


*------EESS POR MEDIDAS DE DISTANCIA 
*LINEAL 
/* collect clear 
collect table frontera_pais_lineal if balanced==59, stat(total count_eess) name(frontera)
collect table frontera_pais_lineal provincia dist_group8_lineal, stat(total count_eess) name(provincia)
collect export "salidas\descriptives\EESS-premium-gasoline-2.xls", name(frontera) cell(a1) sheet(f-balanced-lineal) modify 
collect export "salidas\descriptives\EESS-premium-gasoline-2.xls", name(provincia) cell(a1) sheet(p-balanced-lineal) modify 
collect clear 
*RUTA
collect table frontera_pais_ruta if balanced==59, stat(total count_eess) name(frontera)
collect table frontera_pais_ruta provincia dist_group8_ruta, stat(total count_eess) name(provincia)
collect export "salidas\descriptives\EESS-premium-gasoline-2.xls", name(frontera) cell(a1) sheet(f-balanced-ruta) modify 
collect export "salidas\descriptives\EESS-premium-gasoline-2.xls", name(provincia) cell(a1) sheet(p-balanced-ruta) modify 
collect clear 
 */

*MINUTOS 
/* collect table frontera_pais_minutos if balanced==59, stat(total count_eess) name(frontera)
collect table frontera_pais_minutos provincia dist_group8_minutos, stat(total count_eess) name(provincia)
collect export "salidas\descriptives\EESS-premium-gasoline-2.xls", name(frontera) cell(a1) sheet(f-balanced-minutos) modify 
collect export "salidas\descriptives\EESS-premium-gasoline-2.xls", name(provincia) cell(a1) sheet(p-balanced-minutos) modify 
 */




***************************************************
*- Precio agregado Premium Gasoline - TC Ofcial y TC blue -este va-
**************************************************
/* preserve 
 drop if time < 691 
	collapse (mean) p_surtidor oficial_venta blue_venta, by(time) 
*28=2019m11
			gen p_surtidor_pubn = p_surtidor / p_surtidor[28]
			gen blue_ventan = blue_venta / blue_venta[28]
			gen oficial_ventan = oficial_venta / oficial_venta[28]
		
		
	twoway (connected p_surtidor_pubn time, sort cmissing(n) yaxis(1) msymbol(o) msize(small) lcolor(navy) mcolor(navy)) ///
			(line oficial_ventan time, sort cmissing(n) yaxis(1) lcolor(red) lpattern(shortdash) lwidth(medium)) ///
			(line blue_ventan time, sort cmissing(n) yaxis(1) lcolor(green) lpattern(shortdash) lwidth(medium)), ///
			yscale(range(0 4.5)) ///
	scheme(modern)  legend(on col(3) pos(6) region(lcolor(black)) ///
	lab(1 "Avg. Premium Gasoline price") lab(2 "Official exchange rate") lab(3 "Parallel exchange rate")) ///
	ytitle("")  xtitle("")  ///
	xlabel(691 700 709 719 728 736 744 751, valuelabels labsize(small) nogrid) ///
	ylabel(#10, labsize(small) nogrid axis(1))  ///
	xline(718, lpattern(dash) lcolor(black)) 
	
	
	graph export "salidas\precios\precios y brecha tc\prueba2\nafta premium\p_exchange_rate_nafta_premium.png", replace
restore 
 */


 
 
 
*-------------------------------------------------------------------------------------------*
*---  Diff-in-diff estatico
*-------------------------------------------------------------------------------------------*
*FIRST STAGE: Omitido: 2019m8 = 715 
gen post=. 
replace post=1 if time>=716 & time!=. 
replace post=0 if (time>691 & time<=715)

*Controls and treated gas stations:
 g      treat_r = 1 if dist_group8_ruta == 1 
replace treat_r = 0 if dist_group8_ruta == 2 

 g      treat_l = 1 if dist_group8_lineal == 1 
replace treat_l = 0 if dist_group8_lineal == 2 

 g      treat_m = 1 if dist_group8_minutos == 1 
replace treat_m = 0 if dist_group8_minutos == 2 

*CANTIDAD DE FIRMAS POR GRUPO T/C:
table frontera_pais_lineal treat_l, stat(total count_eess)
table frontera_pais_ruta treat_r, stat(total count_eess)
table frontera_pais_minutos treat_m, stat(total count_eess)




*Ventas por comprador: Moving average: 2 periodos antes, el 0 y 1+
tssmooth ma volumen_pub2 =volumen_pub, window(2 0 1)

*normalizo todo a t=715 2019m8 
*viejo: t=718 2019m11
gen byte basetime = 1 if time==715
by id (basetime), sort: gen quant_aux = volumen_pub2 / volumen_pub2[1]


gen quantities = quant_aux 
drop quant_aux

gen quantities_index = quantities*100

*BORRO UNA OBS DE CHILE QUE ESTAN MAL: 
drop if anio==2018 & mes==11 & frontera_pais_ruta=="CHL" & id==4471 
drop if anio==2019 & mes==1 & frontera_pais_ruta=="CHL" & id==4471 
drop if anio==2019 & mes==2 & frontera_pais_ruta=="CHL" & id==4471 


local treat8 "Treat (<50km)"
local control8 "Control (>200km)"


local treat8_min "Treat: <60min"
local control8_min "Control: >150min"





*-------------------------------*
*- REGRESION AGREGADA (TODOS LOS PAISES)
*-------------------------------*
  ********************************************************
	* DISTANCIA POR RUTA 
	********************************************************
/* 
preserve 
drop if frontera_pais_ruta=="CHL" | frontera_pais_ruta=="URY" 
*drop if provincia=="CORRIENTES" & frontera_pais_ruta=="PRY"
	keep if treat_r!=. 
	*Hay que sacar las obs dnd estuvo cerrada la pandemia: 
	*Marzo 2020=722   Octubre 2021=741 (en Nov la frontera ya estuvo abierta)
	drop if time>=722 & time<=741
	
 
	*[1] Panel balanceado 
	est clear
	quietly eststo a: xtreg quantities_index  ib0.post ib0.treat_r ib0.treat_r#ib0.post i.id i.time if balanced==59, vce(cluster id)
	*Para agregar controles abajo: 
	estadd local panel "Balanced"
	estadd local firmas "`e(N_g)'"
	estadd local obs  "`e(N)'" 
	
	
	*[2] Panel parcialmente balanceado:
	quietly eststo b: xtreg quantities_index  ib0.post ib0.treat_r ib0.treat_r#ib0.post i.id i.time if balanced>=40, vce(cluster id)
	estadd local panel "At least 40 obs"
	estadd local firmas "`e(N_g)'"
	estadd local obs  "`e(N)'"  
	
	*[3] Panel desbalanceado: 
	quietly eststo c: xtreg quantities_index  ib0.post ib0.treat_r ib0.treat_r#ib0.post i.id i.time, vce(cluster id)
	estadd local panel "Unbalanced"
	estadd local firmas "`e(N_g)'"
	estadd local obs  "`e(N)'" 
	
	*esttab solo para que me muestre la tabla en el output de stata:
	esttab a b c, keep(1.post 1.treat_r  1.treat_r#1.post)  ///
	coeflabel(1.treat_r#1.post "Treat x Post (route distance)" _cons "Constant") ///
	stats(obs firmas  panel, label("Observations" "Number of firms"  "Panel") fmt(%9.0fc))  ///
	b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
	mtitles(Quantities Quantities Quantities) ///
	title(Route distance)   
	
    *exporto a format .tex
	esttab using "salidas/reg/nafta premium/standard-did/final tesis/nafta-premium-ruta.tex" , ///
	keep(1.treat_r#1.post) ///
	coeflabel(1.treat_r#1.post "Treat x Post (route distance)" _cons "Constant") ///
	stats(obs firmas  panel, label("Observations" "Number of firms"  "Panel") fmt(%9.0fc))  ///
	b(3) se(3) star(* 0.10 ** 0.05 *** 0.01)   ///
	mtitles(Quantities Quantities Quantities) ///
	title(Route distance)  booktabs   replace  
restore 
 */



	********************************************************
	* DISTANCIA LINEAL
	********************************************************
/* 
preserve 
	drop if frontera_pais_ruta=="CHL" | frontera_pais_ruta=="URY" 
  *drop if provincia=="CORRIENTES" & frontera_pais_ruta=="PRY"
	keep if treat_l!=. 
	*Hay que sacar las obs dnd estuvo cerrada la pandemia: 
	*Marzo 2020=722   Octubre 2021=741 (en Nov la frontera ya estuvo abierta)
	drop if time>=722 & time<=741


	*[1] Panel balanceado 
	est clear
	quietly eststo a: xtreg quantities_index  ib0.post ib0.treat_l ib0.treat_l#ib0.post i.id i.time if balanced==59, vce(cluster id)
	*Para agregar controles abajo: 
	estadd local panel "Balanced"
	estadd local firmas "`e(N_g)'"
	estadd local obs  "`e(N)'" 
	
	*[2] Panel parcialmente balanceado:
	quietly eststo b: xtreg quantities_index  ib0.post ib0.treat_l ib0.treat_l#ib0.post i.id i.time if balanced>=40, vce(cluster id)
	estadd local panel "At least 40 obs"
	estadd local firmas "`e(N_g)'"
	estadd local obs  "`e(N)'"  
	
	*[3] Panel desbalanceado: 
	quietly eststo c: xtreg quantities_index  ib0.post ib0.treat_l ib0.treat_l#ib0.post i.id i.time, vce(cluster id)
	estadd local panel "Unbalanced"
	estadd local firmas "`e(N_g)'"
	estadd local obs  "`e(N)'" 
	
	*esttab solo para que me muestre la tabla en el output de stata:
	esttab a b c, keep(1.post 1.treat_l  1.treat_l#1.post)  ///
	coeflabel(1.treat_l#1.post "Treat x Post (lineal distance)" _cons "Constant") ///
	stats(obs firmas  panel, label("Observations" "Number of firms"  "Panel") fmt(%9.0fc))  ///
	b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
	mtitles(Quantities Quantities Quantities) ///
	title(`c' - Lineal distance)   
	
    *exporto a format .tex
	esttab using "salidas/reg/nafta premium/standard-did/final tesis/nafta-premium-lineal.tex" , ///
	keep(1.treat_l#1.post) ///
	coeflabel(1.treat_l#1.post "Treat x Post (lineal distance)" _cons "Constant") ///
	stats(obs firmas  panel, label("Observations" "Number of firms"  "Panel") fmt(%9.0fc))  ///
	b(3) se(3) star(* 0.10 ** 0.05 *** 0.01)   ///
	mtitles(Quantities Quantities Quantities) ///
	title(Lineal distance)  booktabs   replace  
restore 	
	 */
    ********************************************************
	* DISTANCIA EN MINUTOS 
	********************************************************
/* 	
preserve 
drop if frontera_pais_ruta=="CHL" | frontera_pais_ruta=="URY" 
*drop if provincia=="CORRIENTES" & frontera_pais_ruta=="PRY"
	keep if treat_m!=. 
	*Hay que sacar las obs dnd estuvo cerrada la pandemia: 
	*Marzo 2020=722   Octubre 2021=741 (en Nov la frontera ya estuvo abierta)
	drop if time>=722 & time<=741
	

	*[1] Panel balanceado 
	est clear
	quietly eststo a: xtreg quantities_index  ib0.post ib0.treat_m ib0.treat_m#ib0.post i.id i.time if balanced==59, vce(cluster id)
	*Para agregar controles abajo: 
	estadd local panel "Balanced"
	estadd local firmas "`e(N_g)'"
	estadd local obs  "`e(N)'" 
	
	*[2] Panel parcialmente balanceado:
	quietly eststo b: xtreg quantities_index  ib0.post ib0.treat_m ib0.treat_m#ib0.post i.id i.time if balanced>=40, vce(cluster id)
	estadd local panel "At least 40 obs"
	estadd local firmas "`e(N_g)'"
	estadd local obs  "`e(N)'"  
	
	*[3] Panel desbalanceado: 
	quietly eststo c: xtreg quantities_index  ib0.post ib0.treat_m ib0.treat_m#ib0.post i.id i.time, vce(cluster id)
	estadd local panel "Unbalanced"
	estadd local firmas "`e(N_g)'"
	estadd local obs  "`e(N)'" 
	
	*esttab solo para que me muestre la tabla en el output de stata:
	esttab a b c, keep(1.post 1.treat_m  1.treat_m#1.post)  ///
	coeflabel(1.treat_m#1.post "Treat x Post (time distance)" _cons "Constant") ///
	stats(obs firmas  panel, label("Observations" "Number of firms"  "Panel") fmt(%9.0fc))  ///
	b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
	mtitles(Quantities Quantities Quantities) ///
	title(`c' - Time distance)   
	
    *exporto a format .tex
	esttab using "salidas/reg/nafta premium/standard-did/final tesis/nafta-premium-time.tex" , ///
	keep(1.treat_m#1.post) ///
	coeflabel(1.treat_m#1.post "Treat x Post (time distance)" _cons "Constant") ///
	stats(obs firmas  panel, label("Observations" "Number of firms"  "Panel") fmt(%9.0fc))  ///
	b(3) se(3) star(* 0.10 ** 0.05 *** 0.01)   ///
	mtitles(Quantities Quantities Quantities) ///
	title(Time distance)  booktabs   replace  
restore 	
 */

rename frontera_pais_lineal frontera_pais_l 
rename frontera_pais_ruta frontera_pais_r 
rename frontera_pais_minutos frontera_pais_m 



*-------------------------------*
*- REGRESIONES POR PAISES 
*-------------------------------*
local paises "BRA BOL PRY"
local treatment "r l m"  
/* 
foreach c of local paises {
			

	*drop if provincia=="CORRIENTES" & frontera_pais_ruta=="PRY"
	foreach x of local treatment { 
	preserve 
	keep if frontera_pais_`x'=="`c'"
	keep if treat_`x'!=. 
 
	*Hay que sacar las obs dnd estuvo cerrada la pandemia: 
	*Marzo 2020=722   Octubre 2021=741 (en Nov la frontera ya estuvo abierta)
	drop if time>=722 & time<=741
	
	*[1] Panel balanceado 
	est clear
	quietly eststo a: xtreg quantities_index  ib0.post ib0.treat_`x' ib0.treat_`x'#ib0.post i.id i.time if balanced==59, vce(cluster id)
	*Para agregar controles abajo: 
	estadd local panel "Balanced"
	estadd local firmas "`e(N_g)'"
	estadd local obs  "`e(N)'" 
	
	*[2] Panel parcialmente balanceado:
	quietly eststo b: xtreg quantities_index  ib0.post ib0.treat_`x' ib0.treat_`x'#ib0.post i.id i.time if balanced>=40, vce(cluster id)
	estadd local panel "At least 40 obs"
	estadd local firmas "`e(N_g)'"
	estadd local obs  "`e(N)'"  
	
	*[3] Panel desbalanceado: 
	quietly eststo c: xtreg quantities_index  ib0.post ib0.treat_`x' ib0.treat_`x'#ib0.post i.id i.time, vce(cluster id)
	estadd local panel "Unbalanced"
	estadd local firmas "`e(N_g)'"
	estadd local obs  "`e(N)'" 
	
	*esttab solo para que me muestre la tabla en el output de stata:
	esttab a b c, keep(1.post 1.treat_`x'  1.treat_`x'#1.post)  ///
	coeflabel(1.treat_`x'#1.post "Treat x Post (`x' distance)" _cons "Constant") ///
	stats(obs firmas  panel, label("Observations" "Number of firms"  "Panel") fmt(%9.0fc))  ///
	b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
	mtitles(Quantities Quantities Quantities) ///
	title(`c' border - `x' distance)   
	
    *exporto a format .tex
	esttab using "salidas/reg/nafta premium/standard-did/final tesis/naftapremium-ruta-`c'-`x'.tex" , ///
	keep(1.treat_`x'#1.post) ///
	coeflabel(1.treat_`x'#1.post "Treat x Post (`x' distance)" _cons "Constant") ///
	stats(obs firmas  panel, label("Observations" "Number of firms"  "Panel") fmt(%9.0fc))  ///
	b(3) se(3) star(* 0.10 ** 0.05 *** 0.01)   ///
	mtitles(Quantities Quantities Quantities) ///
	title(`x' distance - `c' border)  booktabs   replace  
	restore 
} // close loop of l r t 

} // close loop of border countries  
 
  */


 
 


*-------------------------------------------------------------------------------------------*
*---  Diff-in-diff dinamico
*-------------------------------------------------------------------------------------------*

local treat8 "Treat (<50km)"
local control8 "Control (>200km)"

local treat8_min "Treat (<60min)"
local control8_min "Control (150min)"

 
*REGRESION EN NIVELES -HAY QUE ARMAR LOS GRAF X SEPARADO PQ HAY QUE MOVER LA POSICION DEL TEXTO 

*----------------------------------------------------------------------------------------------*
* --- TODOS LOS PAISES ---- *
*----------------------------------------------------------------------------------------------*
*SOLO CON DISTANCIA POR RUTA !!

preserve 
keep if treat_r!=. 
drop if frontera_pais_r=="CHL" | frontera_pais_r=="URY"
*drop if frontera_pais_ruta=="PRY" & provincia=="CORRIENTES" 


	*[1] Estimaciones: Mes omitido: 2019m8 = 715 
	*TREAT: 
	xtreg quantities_index ib715.time i.id  if treat_r==1 & balanced==59, vce(cluster id)
	
	 
	g coef_treat = .
	g se_treat = .
	levelsof time, l(times)
	
	foreach t in `times' {
		replace coef = _b[`t'.time] if time == `t'
	    replace se = _se[`t'.time] if time == `t'
}
	
	g ci_top_treat = coef_treat + 1.96*se_treat
	g ci_bottom_treat = coef_treat - 1.96*se_treat
		
	*CONTROL 
	xtreg quantities_index ib715.time i.id  if treat_r==0 & balanced==59, vce(cluster id)

	g coef_control = .
	g se_control = .
	levelsof time, l(times)
	
	foreach t in `times' {
		replace coef_control = _b[`t'.time] if time == `t'
	    replace se_control = _se[`t'.time] if time == `t'
}
	
	g ci_top_control = coef_control + 1.96*se_control
	g ci_bottom_control = coef_control - 1.96*se_control

*--[3] Graficar 
	keep time coef_treat se_treat ci_top_treat ci_bottom_treat coef_control se_treat ci_top_control ci_bottom_control
	*me quedo con 1 obs x periodo:
	duplicates drop
	sort time
	
	*Crear el sombreado gris para la pandemia
	gen down = -50
	gen up  = 100
	local shaded_up up time if inrange(time, 723, 741), bcolor(gs15) barwidth(1.1)     lcolor(gs15) lwidth(0) 
	local shaded_down down time if  inrange(time, 723, 741), bcolor(gs15)  barwidth(1.1)  lcolor(gs15) lwidth(0) 
	
	*[4] Create connected scatterplot of coefficients with CIs included with rcap
	twoway  (bar `shaded_up') ///
	        (bar `shaded_down') ///
	       (sc coef_treat time, connect(line)  msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))	///
	       (sc coef_control time, connect(line)  msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)) ///
			(rcap ci_top_treat ci_bottom_treat time , lcolor(cranberry%40)) 	///
			(rcap ci_top_control ci_bottom_control time , lcolor(ebblue%50)) 	///
			(function y = 0, range(time) lcolor(black)) , ///
			xline(715, lpattern(solid) lcolor(black)) ///
			xline(722, lpattern(shortdash) lcolor(gs8)) ///
			xline(742, lpattern(shortdash) lcolor(gs8)) ///
			xlabel(#11, labsize(small) valuelabels nogrid) ylabel(#6, labsize(small) valuelabels nogrid) ///
			legend(order (3 "`treat8' " 4 "`control8'") region(lcolor(black)) ring(0) pos(11) size(*0.9)) ///
			scheme(modern) xtitle("") ytitle("M3 (base = August 2019)", size(small))  ///
			text(130 732  "{it:Closed borders}", color(navy) size(small)  lcolor(gs2) fcolor(gs15) margin(vsmall)) /*  ///
			note("Frontera: All countries   `treat8'   `control8'    " /// 
			"FE: EESS, time		  Control: - " ///
 			"Panel: balanced      Distance def: ruta  Errors: cluster EESS"  ///
			"Obs: `e(N)'  EE.SS: `e(N_g)'" ///
			"Omitted month: 2019m8")   */
			 
			*Para exportar con notes:  
			*graph export "salidas\reg\nafta\dynamic did\did-v7-nafta-super-level-TEXT.png", replace
			*Para exportar sin notes: 
			graph export "salidas\reg\nafta premium\dynamic did\final tesis\naftapremium-level-r.pdf", replace

restore

 


*----------------------------------------------------------------------------------------------*
* --- FRONTERA CON BOLIVIA ---- *
*----------------------------------------------------------------------------------------------*
preserve 
keep if frontera_pais_r=="BOL"
keep if treat_r!=. 

	*[1] Estimaciones: 
	*TREAT: 
	xtreg quantities_index ib715.time i.id  if (treat_r==1 & balanced==59), vce(cluster id)
	
	 
	g coef_treat = .
	g se_treat = .
	levelsof time, l(times)
	
	foreach t in `times' {
		replace coef = _b[`t'.time] if time == `t'
	    replace se = _se[`t'.time] if time == `t'
}
	
	g ci_top_treat = coef_treat + 1.96*se_treat
	g ci_bottom_treat = coef_treat - 1.96*se_treat
		
	*CONTROL 
	xtreg quantities_index ib715.time i.id  if (treat_r==0 & balanced==59), vce(cluster id)

	g coef_control = .
	g se_control = .
	levelsof time, l(times)
	
	foreach t in `times' {
		replace coef_control = _b[`t'.time] if time == `t'
	    replace se_control = _se[`t'.time] if time == `t'
}
	
	g ci_top_control = coef_control + 1.96*se_control
	g ci_bottom_control = coef_control - 1.96*se_control

*--[3] Graficar 
	keep time coef_treat se_treat ci_top_treat ci_bottom_treat coef_control se_treat ci_top_control ci_bottom_control
	*me quedo con 1 obs x periodo:
	duplicates drop
	sort time
	
	*Crear el sombreado gris para la pandemia
	gen down = -50
	gen up_BOL = 150
	local shaded_up_BOL up_BOL time if inrange(time, 723, 741), bcolor(gs15) barwidth(1.1)     lcolor(gs15) lwidth(0) 
	local shaded_down down time if  inrange(time, 723, 741), bcolor(gs15)  barwidth(1.1)  lcolor(gs15) lwidth(0) 
	
	*[4] Create connected scatterplot of coefficients with CIs included with rcap
	twoway  (bar `shaded_up_BOL') ///
	        (bar `shaded_down') ///
	       (sc coef_treat time, connect(line)  msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))	///
	       (sc coef_control time, connect(line)  msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)) ///
			(rcap ci_top_treat ci_bottom_treat time , lcolor(cranberry%40)) 	///
			(rcap ci_top_control ci_bottom_control time , lcolor(ebblue%50)) 	///
			(function y = 0, range(time) lcolor(black)) , ///
			xline(715, lpattern(solid) lcolor(black)) ///
			xline(722, lpattern(shortdash) lcolor(gs8)) ///
			xline(742, lpattern(shortdash) lcolor(gs8)) ///
			xlabel(#11, labsize(small) valuelabels nogrid) ylabel(, labsize(small) nogrid) ///
			legend(order (3 "`treat8' " 4 "`control8'") region(lcolor(black)) ring(0) pos(11) size(*0.9)) ///
			scheme(modern) xtitle("") ytitle("M3 (base = August 2019)", size(small))  ///
			text(96 732  "{it:Closed borders}", color(navy) size(small)  lcolor(gs2) fcolor(gs15) margin(vsmall)) /*  ///
			note("Frontera: BOL    `treat8'   `control8'    " /// 
			"FE: EESS, time		  Control: - " ///
 			"Panel: balanced      Distance def: ruta  Errors: cluster EESS"  ///
			"Obs: `e(N)'  EE.SS: `e(N_g)'" ///
			"Omitted month: 2019m8")   */
			 
			*Para exportar con notes:  
			*graph export "salidas\reg\nafta\dynamic did\did-BOL-v7-nafta-super-level-TEXT-2019m8.png", replace
			*Para exportar sin notes: 
			graph export "salidas\reg\nafta premium\dynamic did\final tesis\BOL-naftapremium-level-r.pdf", replace

restore





*----------------------------------------------------------------------------------------------*
* --- FRONTERA CON BRASIL ---- *
*----------------------------------------------------------------------------------------------*
preserve 
keep if frontera_pais_r=="BRA"
keep if treat_r!=. 

	*[1] Estimaciones: 
	*TREAT: 
	xtreg quantities_index ib715.time i.id  if (treat_r==1 & balanced==59), vce(cluster id)
	
	 
	g coef_treat = .
	g se_treat = .
	levelsof time, l(times)
	
	foreach t in `times' {
		replace coef = _b[`t'.time] if time == `t'
	    replace se = _se[`t'.time] if time == `t'
}
	
	g ci_top_treat = coef_treat + 1.96*se_treat
	g ci_bottom_treat = coef_treat - 1.96*se_treat
		
	*CONTROL 
	xtreg quantities_index ib715.time i.id  if (treat_r==0 & balanced==59), vce(cluster id)

	g coef_control = .
	g se_control = .
	levelsof time, l(times)
	
	foreach t in `times' {
		replace coef_control = _b[`t'.time] if time == `t'
	    replace se_control = _se[`t'.time] if time == `t'
}
	
	g ci_top_control = coef_control + 1.96*se_control
	g ci_bottom_control = coef_control - 1.96*se_control

*--[3] Graficar 
	keep time coef_treat se_treat ci_top_treat ci_bottom_treat coef_control se_treat ci_top_control ci_bottom_control
	*me quedo con 1 obs x periodo:
	duplicates drop
	sort time
	
	*Crear el sombreado gris para la pandemia
	gen down = -100
	gen up_BRA = 400
	local shaded_up_BRA up_BRA time if inrange(time, 723, 741), bcolor(gs15) barwidth(1.1)     lcolor(gs15) lwidth(0) 
	local shaded_down down time if  inrange(time, 723, 741), bcolor(gs15)  barwidth(1.1)  lcolor(gs15) lwidth(0) 
	
	*[4] Create connected scatterplot of coefficients with CIs included with rcap
	twoway  (bar `shaded_up_BRA') ///
	        (bar `shaded_down') ///
	       (sc coef_treat time, connect(line)  msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))	///
	       (sc coef_control time, connect(line)  msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)) ///
			(rcap ci_top_treat ci_bottom_treat time , lcolor(cranberry%40)) 	///
			(rcap ci_top_control ci_bottom_control time , lcolor(ebblue%50)) 	///
			(function y = 0, range(time) lcolor(black)) , ///
			xline(715, lpattern(solid) lcolor(black)) ///
			xline(722, lpattern(shortdash) lcolor(gs8)) ///
			xline(742, lpattern(shortdash) lcolor(gs8)) ///
			xlabel(#11, labsize(small) valuelabels nogrid) ylabel(, labsize(small) nogrid) /// 
			ytitle("M3 (base = August 2019)", size(small))  ///
			legend(order (3 "`treat8' " 4 "`control8'") region(lcolor(black)) ring(0) pos(11) size(*0.9)) ///
			scheme(modern) xtitle("") ///
			text(190 732  "{it:Closed borders}", color(navy) size(small)  lcolor(gs2) fcolor(gs15) margin(vsmall)) /*  ///
			note("Frontera: BRA    `treat8'   `control8'    " /// 
			"FE: EESS, time		  Control: - " ///
 			"Panel: balanced      Distance def: ruta  Errors: cluster EESS"  ///
			"Obs: `e(N)'  EE.SS: `e(N_g)'" ///
			"Omitted month: 2019m8")   */
			 
			*Para exportar con notes:  
			*graph export "salidas\reg\nafta\dynamic did\did-BRA-v7-nafta-super-level-TEXT-2019m8.png", replace
			*Para exportar sin notes: 
			graph export "salidas\reg\nafta premium\dynamic did\final tesis\BRA-naftapremium-level-r.pdf", replace

restore

  
  *sacar eess del control pq son 71 vs 24 treated: (esto estaba puesto en el dofile del avance tesis!)
*keep if provincia=="CHACO" | provincia=="FORMOSA" | provincia=="MISIONES"
 
*----------------------------------------------------------------------------------------------*
* --- FRONTERA CON PARAGUAY ---- *
*----------------------------------------------------------------------------------------------*
preserve 
keep if frontera_pais_r=="PRY"
keep if treat_r!=. 

	*Estimaciones:
	*TREAT: 
	xtreg quantities_index ib715.time i.id  if (treat_r==1 & balanced==59), vce(cluster id)
	
	g coef_treat = .
	g se_treat = .
	levelsof time, l(times)
	
	foreach t in `times' {
		replace coef = _b[`t'.time] if time == `t'
	    replace se = _se[`t'.time] if time == `t'
}
	
	g ci_top_treat = coef_treat + 1.96*se_treat
	g ci_bottom_treat = coef_treat - 1.96*se_treat
		
	*CONTROL 
	xtreg quantities_index ib715.time i.id  if (treat_r==0 & balanced==59), vce(cluster id)

	g coef_control = .
	g se_control = .
	levelsof time, l(times)
	
	foreach t in `times' {
		replace coef_control = _b[`t'.time] if time == `t'
	    replace se_control = _se[`t'.time] if time == `t'
}
	
	g ci_top_control = coef_control + 1.96*se_control
	g ci_bottom_control = coef_control - 1.96*se_control

*--[3] Graficar 
	keep time coef_treat se_treat ci_top_treat ci_bottom_treat coef_control se_treat ci_top_control ci_bottom_control
	*me quedo con 1 obs x periodo:
	duplicates drop
	sort time
	
	*Crear el sombreado gris para la pandemia
	gen down = -50
	gen up_PRY = 150
	local shaded_up_PRY up_PRY time if inrange(time, 723, 741), bcolor(gs15) barwidth(1.1)     lcolor(gs15) lwidth(0) 
    local shaded_down down time if  inrange(time, 723, 741), bcolor(gs15)  barwidth(1.1)  lcolor(gs15) lwidth(0) 
	
			
	*[4] Create connected scatterplot of coefficients with CIs included with rcap
	twoway (bar `shaded_up_PRY') ///
	        (bar `shaded_down')  ///
           (sc coef_treat time, connect(line)  msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(t))	///
	       (sc coef_control time, connect(line)  msize(small) lcolor(ebblue) mcolor(ebblue) msymbol(t)) ///
			(rcap ci_top_treat ci_bottom_treat time , lcolor(cranberry%40)) 	///
			(rcap ci_top_control ci_bottom_control time , lcolor(ebblue%50)) 	///
			(function y = 0, range(time) lcolor(black)) , ///
			xline(715, lpattern(solid) lcolor(black)) ///
			xline(722, lpattern(shortdash) lcolor(gs8)) ///
			xline(742, lpattern(shortdash) lcolor(gs8)) ///
			xlabel(#11, labsize(small) valuelabels nogrid) ylabel(, labsize(small) nogrid) ///
			legend(order (3 "`treat8'" 4 "`control8'") region(lcolor(black)) ring(0) pos(11) size(*0.9) ) ///
			scheme(modern) ///
			xtitle("") ytitle("M3 (base = August 2019)", size(small))  /// 
			text(93 732  "{it:Closed borders}", color(navy) size(small)  lcolor(gs2) fcolor(gs15) margin(vsmall))  /* ///
			note("Frontera: PRY    `treat8'   `control8'    " /// 
			"FE: EESS, time		  Control: - " ///
 			"Panel: balanced      Distance def: ruta  Errors: cluster EESS"  ///
			"Obs: `e(N)'  EE.SS: `e(N_g)'" ///
			"Omitted month: 2019m8")    */
			
			*Para exportar con notes:
			*graph export "salidas\reg\nafta\dynamic did\did-PRY-v7-nafta-super-level-TEXT-2019m8.png", replace
			*Para exportar sin notes: 
			graph export "salidas\reg\nafta premium\dynamic did\final tesis\PRY-naftapremium-level-r.pdf", replace


restore 




*REGRESION EN DIFERENCIAS  


*----------------------------------------------------------------------------------------------*
* --- TODOS LOS PAISES---- *
*----------------------------------------------------------------------------------------------*
*DISTANCIA POR RUTA 
preserve 
	keep if treat_r!=. 
	drop if frontera_pais_r=="CHL" | frontera_pais_r=="URY"
	*drop if frontera_pais_ruta=="PRY" & provincia=="CORRIENTES" 

	*el treat no va en realidad pero lo tengo q poner pq no me lee la categoria base sino del ib715.time#ib0.treat_r
	xtreg quantities_index ib715.time i.id ib0.treat_r  ib715.time#ib0.treat_r if balanced==59, vce(cluster id)

*--[1] Coeficientes + se: 
	g coef = .
	g se = .
	levelsof time, l(times)

	foreach t in `times' {
		replace coef = _b[`t'.time#1.treat_r] if time == `t'
	     replace se = _se[`t'.time#1.treat_r] if time == `t'
}

	*--[2] CI:  z(0.95)=1.96   z(0.90)=1.645
	g ci_top = coef + 1.96*se
	g ci_bottom = coef - 1.96*se
		
 

	*--[3] Graficar 
	keep time coef se ci_top ci_bottom treat_r
	*me quedo con 1 obs x periodo:
	duplicates drop
	sort time
	
	 *Crear el sombreado gris para la pandemia
	gen down = -50
	gen up = 150
	local shaded_up up time if inrange(time, 723, 741), bcolor(gs15) barwidth(1.1)     lcolor(gs15) lwidth(0) 
    local shaded_down down time if  inrange(time, 723, 741), bcolor(gs15)  barwidth(1.1)  lcolor(gs15) lwidth(0) 
 
	
	
	*[4] Create connected scatterplot of coefficients with CIs included with rcap
	twoway (bar `shaded_up') ///
	        (bar `shaded_down') ///
	        (sc coef time, connect(line)  msize(small) lcolor(blue%80) mcolor(blue%30) msymbol(O)) ///
			(rcap ci_top ci_bottom time , lcolor(blue%15)) 	///
			(function y = 0, range(time) lcolor(black)) , ///
			xline(715, lpattern(solid) lcolor(black)) ///
			xline(722, lpattern(shortdash) lcolor(gs8)) ///
			xline(742, lpattern(shortdash) lcolor(gs8)) ///
			xlabel(#11, labsize(small) valuelabels nogrid) ylabel(, labsize(small) nogrid) ///
			legend(order (3 "Point estimate" 4 "95% CI") region(lcolor(black)) ring(0) pos(11) size(*0.9)) ///
			scheme(modern) ytitle("M3 (base = August 2019)", size(small)) ///
			text(130 732  "{it:Closed borders}", color(navy) size(small)  lcolor(gs2) fcolor(gs15) margin(vsmall)) ///
			 text(105 696 "DiD = 37.168 (11.251)", color(black) size(small)) /* /// 
			note("Frontera: all countries   `treat8'   `control8'    " /// 
			"FE: EESS, time		  Control: - " ///
 			"Panel: balanced      Distance def: ruta  Errors: cluster EESS"  ///
			"Obs: `e(N)'  EE.SS: `e(N_g)'" ///
			"Omitted month: 2019m8")   */
			
			*Exportar con notes:
			graph export "salidas\reg\nafta premium\dynamic did\final tesis\naftapremium-dif-r.pdf", replace
			*Exportar sin notes: 
			*graph export "salidas\reg\nafta premium\dynamic did\gasoil-dif-r.png", replace

restore
 





*----------------------------------------------------------------------------------------------*
* --- FRONTERA CON BOLIVIA ---- *
*----------------------------------------------------------------------------------------------*



preserve 
	keep if frontera_pais_r=="BOL"
	keep if treat_r!=. 

	*el treat no va en realidad pero lo tengo q poner pq no me lee la categoria base sino del ib715.time#ib0.treat_r
	xtreg quantities_index ib715.time i.id ib0.treat_r  ib715.time#ib0.treat_r if balanced==59, vce(cluster id)

*--[1] Coeficientes + se: 
	g coef = .
	g se = .
	levelsof time, l(times)

	foreach t in `times' {
		replace coef = _b[`t'.time#1.treat_r] if time == `t'
	     replace se = _se[`t'.time#1.treat_r] if time == `t'
}

	*--[2] CI:  z(0.95)=1.96   z(0.90)=1.645
	g ci_top = coef + 1.96*se
	g ci_bottom = coef - 1.96*se
		
 

	*--[3] Graficar 
	keep time coef se ci_top ci_bottom treat_r
	*me quedo con 1 obs x periodo:
	duplicates drop
	sort time
	
	 *Crear el sombreado gris para la pandemia
	gen down = -50
	gen up = 100
	local shaded_up up time if inrange(time, 723, 741), bcolor(gs15) barwidth(1.1)     lcolor(gs15) lwidth(0) 
    local shaded_down down time if  inrange(time, 723, 741), bcolor(gs15)  barwidth(1.1)  lcolor(gs15) lwidth(0) 
 
	
	
	*[4] Create connected scatterplot of coefficients with CIs included with rcap
	twoway (bar `shaded_up') ///
	        (bar `shaded_down') ///
	        (sc coef time, connect(line)  msize(small) lcolor(blue%80) mcolor(blue%30) msymbol(O)) ///
			(rcap ci_top ci_bottom time , lcolor(blue%15)) 	///
			(function y = 0, range(time) lcolor(black)) , ///
			xline(715, lpattern(solid) lcolor(black)) ///
			xline(722, lpattern(shortdash) lcolor(gs8)) ///
			xline(742, lpattern(shortdash) lcolor(gs8)) ///
			xlabel(#11, labsize(small) valuelabels nogrid) ylabel(, labsize(small) nogrid) ///
			legend(order (3 "Point estimate" 4 "95% CI") region(lcolor(black)) ring(0) pos(11) size(*0.9)) ///
			scheme(modern)  ytitle("M3 (base = August 2019)", size(small)) ///
			text(93 732  "{it:Closed borders}", color(navy) size(small)  lcolor(gs2) fcolor(gs15) margin(vsmall)) /* ///  

			note("Frontera: BOL    `treat8'   `control8'    " /// 
			"FE: EESS, time		  Control: - " ///
 			"Panel: balanced      Distance def: ruta  Errors: cluster EESS"  ///
			"Obs: `e(N)'  EE.SS: `e(N_g)'" ///
			"Omitted month: 2019m8")   */
			
			*Exportar con notes:
			*graph export "salidas\reg\nafta\dynamic did\did-BOL-v7-nafta-super-dif-TEXT.png", replace
			*Exportar sin notes: 
			graph export "salidas\reg\nafta premium\dynamic did\final tesis\BOL-naftapremium-dif-r.pdf", replace

restore


*----------------------------------------------------------------------------------------------*
* --- FRONTERA CON BRASIL ---- *
*----------------------------------------------------------------------------------------------*

preserve 
	keep if frontera_pais_r=="BRA"
	keep if treat_r!=. 

	*el treat no va en realidad pero lo tengo q poner pq no me lee la categoria base sino del ib715.time#ib0.treat_r
	xtreg quantities_index ib715.time i.id ib0.treat_r  ib715.time#ib0.treat_r if balanced==59, vce(cluster id)
*quantities
*--[1] Coeficientes + se: 
	g coef = .
	g se = .
	levelsof time, l(times)

	foreach t in `times' {
		replace coef = _b[`t'.time#1.treat_r] if time == `t'
	     replace se = _se[`t'.time#1.treat_r] if time == `t'
}

	*--[2] CI:  z(0.95)=1.96   z(0.90)=1.645
	g ci_top = coef + 1.96*se
	g ci_bottom = coef - 1.96*se
		
 

	*--[3] Graficar 
	keep time coef se ci_top ci_bottom treat_r
	*me quedo con 1 obs x periodo:
	duplicates drop
	sort time
	
	 *Crear el sombreado gris para la pandemia
	gen down = -100
	gen up = 400
	local shaded_up up time if inrange(time, 723, 741), bcolor(gs15) barwidth(1.1)     lcolor(gs15) lwidth(0) 
    local shaded_down down time if  inrange(time, 723, 741), bcolor(gs15)  barwidth(1.1)  lcolor(gs15) lwidth(0) 
 
	
	
	*[4] Create connected scatterplot of coefficients with CIs included with rcap
	twoway (bar `shaded_up') ///
	        (bar `shaded_down') ///
	        (sc coef time, connect(line)  msize(small) lcolor(blue%80) mcolor(blue%30) msymbol(O)) ///
			(rcap ci_top ci_bottom time , lcolor(blue%15)) 	///
			(function y = 0, range(time) lcolor(black)) , ///
			xline(715, lpattern(solid) lcolor(black)) ///
			xline(722, lpattern(shortdash) lcolor(gs8)) ///
			xline(742, lpattern(shortdash) lcolor(gs8)) ///
			xlabel(#11, labsize(small) valuelabels nogrid) ylabel(, labsize(small) nogrid) ///
			 ytitle("M3 (base = August 2019)", size(small)) ///
			legend(order (3 "Point estimate" 4 "95% CI") region(lcolor(black)) ring(0) pos(11) size(*0.9)) ///
			scheme(modern) ///
			text(190 732  "{it:Closed borders}", color(navy) size(small)  lcolor(gs2) fcolor(gs15) margin(vsmall)) ///
			 text(140 697 "DiD = 80.545 (28.188)", color(black) size(small))
			/* /// 
			note("Frontera: BRA    `treat8'   `control8'    " /// 
			"FE: EESS, time		  Control: - " ///
 			"Panel: balanced      Distance def: ruta  Errors: cluster EESS"  ///
			"Obs: `e(N)'  EE.SS: `e(N_g)'  prueba sin sacarle el nivel a 2019m8" ///
			"Omitted month: 2019m8")   */
			
			*Exportar con notes:
			*graph export "salidas\reg\nafta\dynamic did\did-BRA-v7-nafta-super-dif-TEXT-2019m8-prueba.png", replace
			*Exportar sin notes: 
			graph export "salidas\reg\nafta premium\dynamic did\final tesis\BRA-naftapremium-dif-r.pdf", replace

restore





*----------------------------------------------------------------------------------------------*
* --- FRONTERA CON PARAGUAY ---- *
*----------------------------------------------------------------------------------------------*
preserve 
	keep if frontera_pais_r=="PRY"
	keep if treat_r!=. 

	xtreg quantities_index ib715.time ib0.treat_r i.id  ib715.time#ib0.treat_r if balanced==59, vce(cluster id)

*--[1] Coeficientes + se: 
	g coef = .
	g se = .
	levelsof time, l(times)

	foreach t in `times' {
		replace coef = _b[`t'.time#1.treat_r] if time == `t'
	     replace se = _se[`t'.time#1.treat_r] if time == `t'
}

	*--[2] CI:  z(0.95)=1.96   z(0.90)=1.645
	g ci_top = coef + 1.96*se
	g ci_bottom = coef - 1.96*se
		
 
	*--[3] Graficar 
	keep time coef se ci_top ci_bottom treat_r
	*me quedo con 1 obs x periodo:
	duplicates drop
	sort time
	
	 *Crear el sombreado gris para la pandemia
	gen down = -50
	gen up = 150
	local shaded_up up time if inrange(time, 723, 741), bcolor(gs15) barwidth(1.1)     lcolor(gs15) lwidth(0) 
    local shaded_down down time if  inrange(time, 723, 741), bcolor(gs15)  barwidth(1.1)  lcolor(gs15) lwidth(0) 
 
	
	*[4] Create connected scatterplot of coefficients with CIs included with rcap
	twoway   (bar `shaded_up') ///
	        (bar `shaded_down') ///
			(sc coef time, connect(line)  msize(small) lcolor(blue%80) mcolor(blue%30) msymbol(O)) ///
			(rcap ci_top ci_bottom time , lcolor(blue%15)) 	///
			(function y = 0, range(time) lcolor(black)) , ///
			xline(715, lpattern(solid) lcolor(black)) ///
			xline(722, lpattern(shortdash) lcolor(gs8)) ///
			xline(742, lpattern(shortdash) lcolor(gs8)) ///
			xlabel(#11, labsize(small) valuelabels nogrid) ylabel(, labsize(small) nogrid) ///
			legend(order (3 "Point estimate" 4 "95% CI") region(lcolor(black)) ring(0) pos(11) size(*0.9)) ///
			scheme(modern)  ytitle("M3 (base = August 2019)", size(small)) ///
			text(93 732  "{it:Closed borders}", color(navy) size(small)  lcolor(gs2) fcolor(gs15) margin(vsmall)) ///
			 text(80 697 "DiD = 25.040 (13.260)", color(black) size(small))	/* ///
			note("Frontera: PRY    `treat8'   `control8'    " /// 
			"FE: EESS, time		  Control: - " ///
 			"Panel: balanced      Distance def: ruta  Errors: cluster EESS"  ///
			"Obs: `e(N)'  EE.SS: `e(N_g)'" ///
			"Omitted month: 2019m8")  */
			
			*Exportar con notes:
			*graph export "salidas\reg\nafta\dynamic did\did-PRY-v7-nafta-super-dif-TEXT-2019m8.png", replace
			*Exportar sin notes: 
			graph export "salidas\reg\nafta premium\dynamic did\final tesis\PRY-naftapremium-dif-r.pdf", replace


restore 


