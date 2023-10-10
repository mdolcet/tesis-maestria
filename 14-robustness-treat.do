*-------------------------------------------------------------------------------------------------------------------------------------*
*-------------------------------------------------------------------------------------------------------------------------------------*
*-----------------------------NAFTA SUPER---------------------------------------------------------------------------------------------*
*-------------------------------------------------------------------------------------------------------------------------------------*
*-------------------------------------------------------------------------------------------------------------------------------------*
**NAFTA SUPER 
*use "bases\base-precios\p-pulidas-distancias\nafta_2_2016_2022_v2.dta", clear 
use "bases\base-precios\p-pulidas-distancias\nafta_2_2016_2022_v3.dta", clear 

*seteo panel 
tsset id time 
*limpio un poco la bases
keep if volumen_pub!=. 
drop if volumen_pub==46823
*voy a sacar a todos los volumenes menores a 1, pareciera ser un error de carga en la base
drop if volumen_pub <=1 

*ACOMODAR PANEL: 
*[1]. Hasta 2017m8 operó la politica de barril criollo. Saco las obs anteriores 
drop if time < 691
*[2]. Saco las obs de la pandemia antes de armar lo del panel balanceado 
bysort id: gen balanced = [_N]
*OJO PQ ACA TENES QUE SACAR LOS MESES DEL COVID Y NO TE QUEDAN 59 OBS ENTONCES:
*-BORRAR LOS MESES DEL COVID 
*-HACER LO DE CONUNT EESS
*keep if balanced ==59

*Para contar EESS por frontera y provincia 
gen aux = 1 
bysort id: gen count_eess = sum(aux)
replace count_eess = . if count_eess > 1 
xtdes 

*provincia 
encode provincia, gen(prov)

drop blue_venta blue_compra oficial_venta oficial_compra 
merge m:1 time using "bases\tc\tc-arg" , gen(merge_tc)
keep if merge_tc==3
*log del precio en usd 
gen p_surtidor_usd = p_surtidor_pub / oficial_venta 
gen lp_surtidor_usd  = ln(p_surtidor_usd)

**********************************************************
*-- variables de distancias a la frontera (lineal, por ruta, en minutos) 
**********************************************************

**-----
*-RUTA
**-----
gen     dist_group8_ruta_10 = . 
replace dist_group8_ruta_10 =1 if dist_minima_ruta<=10
replace dist_group8_ruta_10 =2 if dist_minima_ruta>=200

gen     dist_group8_ruta_15 = . 
replace dist_group8_ruta_15 =1 if dist_minima_ruta<=15
replace dist_group8_ruta_15 =2 if dist_minima_ruta>=200

gen     dist_group8_ruta_20 = . 
replace dist_group8_ruta_20 =1 if dist_minima_ruta<=20
replace dist_group8_ruta_20 =2 if dist_minima_ruta>=200

gen     dist_group8_ruta_25 = . 
replace dist_group8_ruta_25 =1 if dist_minima_ruta<=25
replace dist_group8_ruta_25 =2 if dist_minima_ruta>=200

gen     dist_group8_ruta_30 = . 
replace dist_group8_ruta_30 =1 if dist_minima_ruta<=30
replace dist_group8_ruta_30 =2 if dist_minima_ruta>=200

gen     dist_group8_ruta_35 = . 
replace dist_group8_ruta_35 =1 if dist_minima_ruta<=35
replace dist_group8_ruta_35 =2 if dist_minima_ruta>=200

gen     dist_group8_ruta_40 = . 
replace dist_group8_ruta_40 =1 if dist_minima_ruta<=40
replace dist_group8_ruta_40 =2 if dist_minima_ruta>=200

gen     dist_group8_ruta_45 = . 
replace dist_group8_ruta_45 =1 if dist_minima_ruta<=45
replace dist_group8_ruta_45 =2 if dist_minima_ruta>=200

gen     dist_group8_ruta_50 = . 
replace dist_group8_ruta_50 =1 if dist_minima_ruta<=50
replace dist_group8_ruta_50 =2 if dist_minima_ruta>=200 

gen     dist_group8_ruta_55 = . 
replace dist_group8_ruta_55 =1 if dist_minima_ruta<=55
replace dist_group8_ruta_55 =2 if dist_minima_ruta>=200

gen     dist_group8_ruta_60 = . 
replace dist_group8_ruta_60 =1 if dist_minima_ruta<=60
replace dist_group8_ruta_60 =2 if dist_minima_ruta>=200

gen     dist_group8_ruta_65 = . 
replace dist_group8_ruta_65 =1 if dist_minima_ruta<=65
replace dist_group8_ruta_65 =2 if dist_minima_ruta>=200

gen     dist_group8_ruta_70 = . 
replace dist_group8_ruta_70 =1 if dist_minima_ruta<=70
replace dist_group8_ruta_70 =2 if dist_minima_ruta>=200

gen     dist_group8_ruta_75 = . 
replace dist_group8_ruta_75 =1 if dist_minima_ruta<=75
replace dist_group8_ruta_75 =2 if dist_minima_ruta>=200

gen     dist_group8_ruta_80 = . 
replace dist_group8_ruta_80 =1 if dist_minima_ruta<=80
replace dist_group8_ruta_80 =2 if dist_minima_ruta>=200

gen     dist_group8_ruta_85 = . 
replace dist_group8_ruta_85 =1 if dist_minima_ruta<=85
replace dist_group8_ruta_85 =2 if dist_minima_ruta>=200


*-------------------------------------------------------------------------------------------*
*---  Diff-in-diff estatico 
*-------------------------------------------------------------------------------------------*

*FIRST STAGE: Omitido: 2019m8 = 715 
gen post=. 
replace post=1 if time>=716 & time!=. 
replace post=0 if (time>691 & time<=715)


*Ventas por comprador: Moving average: 2 periodos antes, el 0 y 1+
tssmooth ma volumen_pub2 =volumen_pub, window(2 0 1)

*normalizo todo a t=715 2019m8 
*viejo: t=718 2019m11
gen byte basetime = 1 if time==715
by id (basetime), sort: gen quant_aux = volumen_pub2 / volumen_pub2[1]

gen quantities = quant_aux 
drop quant_aux
gen quantities_index = quantities*100

*Controls and treated gas stations:
**-----
*-RUTA
**-----
gen     treat_10 = 1 if dist_group8_ruta_10 == 1 
replace treat_10 = 0 if dist_group8_ruta_10 == 2

gen     treat_15 = 1 if dist_group8_ruta_15 == 1 
replace treat_15 = 0 if dist_group8_ruta_15 == 2 

gen     treat_20 = 1 if dist_group8_ruta_20 == 1 
replace treat_20 = 0 if dist_group8_ruta_20 == 2 

gen     treat_25 = 1 if dist_group8_ruta_25 == 1 
replace treat_25 = 0 if dist_group8_ruta_25 == 2 

gen     treat_30 = 1 if dist_group8_ruta_30 == 1 
replace treat_30 = 0 if dist_group8_ruta_30 == 2 

gen     treat_35 = 1 if dist_group8_ruta_35 == 1 
replace treat_35 = 0 if dist_group8_ruta_35 == 2 

gen     treat_40 = 1 if dist_group8_ruta_40 == 1 
replace treat_40 = 0 if dist_group8_ruta_40 == 2 

gen     treat_45 = 1 if dist_group8_ruta_45 == 1 
replace treat_45 = 0 if dist_group8_ruta_45 == 2 

gen     treat_50 = 1 if dist_group8_ruta_50 == 1 
replace treat_50 = 0 if dist_group8_ruta_50 == 2

gen     treat_55 = 1 if dist_group8_ruta_55 == 1 
replace treat_55 = 0 if dist_group8_ruta_55 == 2 
 
gen     treat_60 = 1 if dist_group8_ruta_60 == 1 
replace treat_60 = 0 if dist_group8_ruta_60 == 2  

gen     treat_65 = 1 if dist_group8_ruta_65 == 1 
replace treat_65 = 0 if dist_group8_ruta_65 == 2  
 
gen     treat_70 = 1 if dist_group8_ruta_70 == 1 
replace treat_70 = 0 if dist_group8_ruta_70 == 2  

gen     treat_75 = 1 if dist_group8_ruta_75 == 1 
replace treat_75 = 0 if dist_group8_ruta_75 == 2  

gen     treat_80 = 1 if dist_group8_ruta_80 == 1 
replace treat_80 = 0 if dist_group8_ruta_80 == 2  

 
********************************************************
*- REGRESION AGREGADA NAFTA SUPER- 
*********************************************************
preserve 
drop if frontera_pais_ruta=="CHL" | frontera_pais_ruta=="URY" 
drop if provincia=="CORRIENTES" & frontera_pais_ruta=="PRY"

	
	*Hay que sacar las obs dnd estuvo cerrada la pandemia: 
	*Marzo 2020=722   Octubre 2021=741 (en Nov la frontera ya estuvo abierta)
	drop if time>=722 & time<=741
	

	*[1] Panel balanceado 
     
	
	*-RUTA 
	forvalues x = 10(5)75 { 
	quietly eststo ruta_super_`x': xtreg quantities_index ib0.post ib0.treat_`x' ib0.treat_`x'#ib0.post i.id i.time if balanced==59 & treat_`x'!=., vce(cluster id)
	esttab ruta_super_`x', keep(1.post 1.treat_`x'  1.treat_`x'#1.post) b(%9.4g)
	}
	
restore 


	
 coefplot  ///
         (ruta_super_10, keep(1.treat_10#1.post) rename(1.treat_10#1.post = "10") mlabel mlabsize(vsmall) mlabcolor(black)  mlabposition(3) mlabgap(*2) mlabformat(%9.4g) mcolor(purple)  ciopts(lcolor(purple%40) recast(rcap)) ) ///
	     (ruta_super_15, keep(1.treat_15#1.post) rename(1.treat_15#1.post = "15") mlabel mlabsize(vsmall) mlabcolor(black)  mlabposition(3) mlabgap(*2) mlabformat(%9.4g) mcolor(purple)  ciopts(lcolor(purple%40) recast(rcap)) ) ///
	     (ruta_super_20, keep(1.treat_20#1.post) rename(1.treat_20#1.post = "20") mlabel mlabsize(vsmall) mlabcolor(black) mlabposition(3) mlabgap(*2) mlabformat(%9.4g) mcolor(purple) ciopts(lcolor(purple%40) recast(rcap)) ) ///
	     (ruta_super_25, keep(1.treat_25#1.post) rename(1.treat_25#1.post = "25") mlabel mlabsize(vsmall) mlabcolor(black)  mlabposition(3) mlabgap(*2) mlabformat(%9.4g) mcolor(purple)  ciopts(lcolor(purple%40) recast(rcap)) ) ///
	     (ruta_super_30, keep(1.treat_30#1.post) rename(1.treat_30#1.post = "30") mlabel mlabsize(vsmall) mlabcolor(black) mlabposition(3) mlabgap(*2) mlabformat(%9.4g) mcolor(purple) ciopts(lcolor(purple%40) recast(rcap)) ) ///
	    (ruta_super_35, keep(1.treat_35#1.post) rename(1.treat_35#1.post = "35") mlabel mlabsize(vsmall) mlabcolor(black)  mlabposition(3) mlabgap(*2) mlabformat(%9.4g) mcolor(purple)  ciopts(lcolor(purple%40) recast(rcap)) ) ///
	     (ruta_super_40, keep(1.treat_40#1.post) rename(1.treat_40#1.post = "40") mlabel mlabsize(vsmall) mlabcolor(black) mlabposition(3) mlabgap(*2) mlabformat(%9.4g) mcolor(purple) ciopts(lcolor(purple%40) recast(rcap)) ) /// 
		 (ruta_super_45, keep(1.treat_45#1.post) rename(1.treat_45#1.post = "45") mlabel mlabsize(vsmall) mlabcolor(black)  mlabposition(3) mlabgap(*2) mlabformat(%9.4g) mcolor(purple)  ciopts(lcolor(purple%40) recast(rcap)) ) ///
	     (ruta_super_50, keep(1.treat_50#1.post) rename(1.treat_50#1.post = "50") mlabel mlabsize(vsmall) mlabcolor(black) mlabposition(3) mlabgap(*2) mlabformat(%9.4g) mcolor(blue) ciopts(lcolor(blue%40) recast(rcap)) ) /// 
		 (ruta_super_55, keep(1.treat_55#1.post) rename(1.treat_55#1.post = "55") mlabel mlabsize(vsmall) mlabcolor(black)  mlabposition(3) mlabgap(*2) mlabformat(%9.4g) mcolor(purple)  ciopts(lcolor(purple%40) recast(rcap)) ) ///
	     (ruta_super_60, keep(1.treat_60#1.post) rename(1.treat_60#1.post = "60") mlabel mlabsize(vsmall) mlabcolor(black) mlabposition(3) mlabgap(*2) mlabformat(%9.4g) mcolor(purple) ciopts(lcolor(purple%40) recast(rcap)) ) /// 
		 (ruta_super_65, keep(1.treat_65#1.post) rename(1.treat_65#1.post = "65") mlabel mlabsize(vsmall) mlabcolor(black)  mlabposition(3) mlabgap(*2) mlabformat(%9.4g) mcolor(purple)  ciopts(lcolor(purple%40) recast(rcap)) ) ///
	     (ruta_super_70, keep(1.treat_70#1.post) rename(1.treat_70#1.post = "70") mlabel mlabsize(vsmall) mlabcolor(black) mlabposition(3) mlabgap(*2) mlabformat(%9.4g) mcolor(purple) ciopts(lcolor(purple%40) recast(rcap)) ) /// 
		 (ruta_super_75, keep(1.treat_75#1.post) rename(1.treat_75#1.post = "75") mlabel mlabsize(vsmall) mlabcolor(black)  mlabposition(3) mlabgap(*2) mlabformat(%9.4g) mcolor(purple)  ciopts(lcolor(purple%40) recast(rcap)) ) ///
		  , scheme(modern) vertical yscale(range(-10 80)) plotregion(margin(medium)) ///
		  ylabel(#10, labsize(small) valuelabels nogrid) yline(0, lpattern(dash)) ///
		  xlabel(, nogrid) ///
		  legend(order (2 "Regular Gasoline") region(lcolor(black))  pos(6) col(1) size(*0.9)) ///
		  xtitle("") ytitle("Fuel Quantity gap relative to control group (p.p.)", size(small))  
		   
		   graph export "salidas\reg\nafta\dynamic did\final tesis\robust-control-group.pdf", replace
		   
		   
		   
--
		   
		   
		   
		   
		   
		   
		   
		   
		   
		   
		   
		   
		   
		   
		   
		   
		   
		   
		   
		   
		   
		   
		   
		   
		   
///
		 (ruta_premium, keep(1.treat_r#1.post) rename(1.treat_r#1.post = "{bf:Route (Km)}") mlabel mlabsize(vsmall) mlabcolor(black) mlabposition(3) mlabgap(*2) mlabformat(%9.4g) mcolor("`r(p8)'") ciopts(lcolor("`r(p8)'%70") recast(rcap)) ) ///
		 (minutos_premium, keep(1.treat_m#1.post) rename(1.treat_m#1.post = "{bf:Time (Minutes)}") mlabel mlabsize(vsmall) mlabcolor(black) mlabposition(3) mlabgap(*2) mlabformat(%9.4g) mcolor("`r(p8)'%70") ciopts(lcolor("`r(p8)'%70") recast(rcap)) ) ///
		 (lineal_gasoil, keep(1.treat_l#1.post) rename(1.treat_l#1.post = "{bf:Naive (Lineal)}") mlabel mlabsize(vsmall) mlabcolor(black)  mlabposition(3) mlabgap(*2) mlabformat(%9.4g) mcolor("`r(p5)'") ciopts(lcolor("`r(p5)'%70") recast(rcap))  ) /// 
	     (ruta_gasoil, keep(1.treat_r#1.post) rename(1.treat_r#1.post = "{bf:Route (Km)}") mlabel mlabsize(vsmall) mlabcolor(black)  mlabposition(3) mlabgap(*2) mlabformat(%9.4g) mcolor("`r(p5)'")  ciopts(lcolor("`r(p5)'%70") recast(rcap)) ) ///
	     (minutos_gasoil, keep(1.treat_m#1.post) rename(1.treat_m#1.post = "{bf:Time (Minutes)}") mlabel mlabsize(vsmall) mlabcolor(black) mlabposition(3) mlabgap(*2) mlabformat(%9.4g) mcolor("`r(p5)'") ciopts(lcolor("`r(p5)%70'") recast(rcap)) ) ///		   
		   
		   