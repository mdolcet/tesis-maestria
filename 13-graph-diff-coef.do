set autotabgraph on 


*---------------------------------------------------------------------------*
*---------------grafico coeficientes NAIVE-KM-TIME
*---------------------------------------------------------------------------* 

*-------------------------------------------------------------------------------------------------------------------------------------*
*-------------------------------------------------------------------------------------------------------------------------------------*
*-----------------------------GASOIL--------------------------------------------------------------------------------------------------*
*-------------------------------------------------------------------------------------------------------------------------------------*
*-------------------------------------------------------------------------------------------------------------------------------------*

use "bases\base-precios\p-pulidas-distancias\gasoil_2_2016_2022_v2.dta", clear 

*seteo panel 
tsset id time 
*limpio un poco la bases
keep if volumen_pub!=. 
drop if volumen_pub==46823
*voy a sacar a todos los volumenes menores a 1, pareciera ser un error de carga en la base
drop if volumen_pub <=1 
*Arreglo algunas obs que están destruyendo todo:
replace volumen_pub=41.988 if codigo_unico_de_coordenadas=="-27.48272;-58.93689" & mes==2 & year==2018 


*provincia 
encode provincia, gen(prov)

drop blue_venta blue_compra oficial_venta oficial_compra 
merge m:1 time using "bases\tc\tc-arg" , gen(merge_tc)
keep if merge_tc==3

*log del precio en usd 
gen p_surtidor_usd = p_surtidor_pub / oficial_venta 
gen lp_surtidor_usd  = ln(p_surtidor_usd)


**********************************************************
*-- variables de distancias a la frontera (ruta y minutos) 
**********************************************************
**-----
*-dist group 8 
**-----
*LINEAL
gen dist_group8_lineal = . 
replace dist_group8_lineal=1 if dist_minima<=50
replace dist_group8_lineal=2 if dist_minima>=200 
label def dist_group8_lineal 1 "<50km paso fronterizo" 2 ">200km" 
label val dist_group8_lineal dist_group8_lineal

*RUTA
gen dist_group8_ruta = . 
replace dist_group8_ruta=1 if dist_minima_ruta<=50
replace dist_group8_ruta=2 if dist_minima_ruta>=200 
label def dist_group8_ruta 1 "<50km paso fronterizo" 2 "100-200km" 
label val dist_group8_ruta dist_group8_ruta 

*MINUTOS
gen dist_group8_minutos = . 
replace dist_group8_minutos=1 if dist_minima_minutos<=60
replace dist_group8_minutos=2 if dist_minima_minutos>=150
label def dist_group8_minutos 1 "<60min paso fronterizo" 2 ">150min" 
label val dist_group8_minutos dist_group8_minutos  


*Hasta 2017m8 operó la politica de barril criollo. Saco las obs anteriores 
drop if time < 691


*cantidad de EESS
*Para contar EESS por frontera y provincia 
cap drop aux count_eess
gen aux = 1 
bysort id: gen count_eess = sum(aux)
replace count_eess = . if count_eess > 1 

*Balanced panel -59 meses- 
bysort id: gen balanced = [_N]


*[2] distancia por ruta 
*collect table frontera_pais, stat(total count_eess) 
*collect table frontera_pais provincia dist_group8_ruta , stat(total count_eess) name(dist8_ruta)


*collect export "salidas\descriptives\EESS-dist8.xls", name(dist8_ruta) cell(a1) sheet(gasoil-balanced) modify 


*-------------------------------------------------------------------------------------------*
*---  Diff-in-diff estatico
*-------------------------------------------------------------------------------------------*
*FIRST STAGE: Omitido: 2019m8 = 715 
gen post=. 
replace post=1 if time>=716 & time!=. 
replace post=0 if (time>691 & time<=715)

*Controls and treated gas stations (RUTA):
g       treat_r = 1 if dist_group8_ruta == 1 
replace treat_r = 0 if dist_group8_ruta == 2 

*Controls and treated gas stations (LINEAL):
g       treat_l = 1 if dist_group8_lineal == 1 
replace treat_l = 0 if dist_group8_lineal == 2 

*Controls and treated gas stations (MINUTOS):
g       treat_m = 1 if dist_group8_minutos == 1 
replace treat_m = 0 if dist_group8_minutos == 2 


*Ventas por comprador: Moving average: 2 periodos antes, el 0 y 1+
tssmooth ma volumen_pub2 =volumen_pub, window(2 0 1)

*normalizo todo a t=715 2019m8 
*viejo: t=718 2019m11
gen byte basetime = 1 if time==715
by id (basetime), sort: gen quant_aux = volumen_pub2 / volumen_pub2[1]


gen quantities = quant_aux 
drop quant_aux

gen quantities_index = quantities*100




*-------------------------------*
*- REGRESION AGREGADA (TODOS LOS PAISES)
*-------------------------------*
preserve 
drop if frontera_pais_ruta=="CHL" | frontera_pais_ruta=="URY" 
drop if provincia=="CORRIENTES" & frontera_pais_ruta=="PRY"

	keep if treat_r!=. 
	*Hay que sacar las obs dnd estuvo cerrada la pandemia: 
	*Marzo 2020=722   Octubre 2021=741 (en Nov la frontera ya estuvo abierta)
	drop if time>=722 & time<=741
	
	*[1] LINEAL 
	est clear
	quietly eststo lineal_gasoil: xtreg quantities_index  ib0.post ib0.treat_l ib0.treat_l#ib0.post i.id i.time if balanced==59 & treat_l!=., vce(cluster id)
	esttab lineal_gasoil, keep(1.post 1.treat_l  1.treat_l#1.post) coeflabel(1.treat_l#1.post "Lineal distance") b(%9.4g)
	

	*[2] RUTA 
	quietly eststo ruta_gasoil: xtreg quantities_index  ib0.post ib0.treat_r ib0.treat_r#ib0.post i.id i.time if balanced==59 & treat_r!=., vce(cluster id)
     esttab ruta_gasoil, keep(1.post 1.treat_r  1.treat_r#1.post) coeflabel(1.treat_r#1.post "Route distance") b(%9.4g)
	
	*[3] TIEMPO 	
	quietly eststo minutos_gasoil: xtreg quantities_index ib0.post ib0.treat_m ib0.treat_m#ib0.post i.id i.time if balanced==59 & treat_m!=., vce(cluster id)
	esttab minutos_gasoil, keep(1.post 1.treat_m  1.treat_m#1.post) coeflabel(1.treat_m#1.post "Time distance") b(%9.4g)
	

restore 



*-------------------------------------------------------------------------------------------------------------------------------------*
*-------------------------------------------------------------------------------------------------------------------------------------*
*-----------------------------NAFTA SUPER---------------------------------------------------------------------------------------------*
*-------------------------------------------------------------------------------------------------------------------------------------*
*-------------------------------------------------------------------------------------------------------------------------------------*

use "bases\base-precios\p-pulidas-distancias\nafta_2_2016_2022_v2.dta", clear 

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
*-LINEAL
**-----
gen dist_group8_lineal = . 
replace dist_group8_lineal=1 if dist_minima<=50
replace dist_group8_lineal=2 if dist_minima>=200 
label def dist_group8_lineal 1 "<50km paso fronterizo" 2 ">200km" 
label val dist_group8_lineal dist_group8_lineal

**-----
*-RUTA
**-----
gen dist_group8_ruta = . 
replace dist_group8_ruta=1 if dist_minima_ruta<=50
replace dist_group8_ruta=2 if dist_minima_ruta>=200 
label def dist_group8_ruta 1 "<50km paso fronterizo" 2 ">200km" 
label val dist_group8_ruta dist_group8_ruta 

**-----
*-MINUTOS
**-----
gen dist_group8_minutos = . 
replace dist_group8_minutos=1 if dist_minima_minutos<=60
replace dist_group8_minutos=2 if dist_minima_minutos>=150
label def dist_group8_minutos 1 "<60min paso fronterizo" 2 ">150min" 
label val dist_group8_minutos dist_group8_minutos  


*-------------------------------------------------------------------------------------------*
*---  Diff-in-diff estatico 
*-------------------------------------------------------------------------------------------*

*FIRST STAGE: Omitido: 2019m8 = 715 
gen post=. 
replace post=1 if time>=716 & time!=. 
replace post=0 if (time>691 & time<=715)


*Controls and treated gas stations:
**-----
*-LINEAL
**-----
gen     treat_l = 1 if dist_group8_lineal == 1 
replace treat_l = 0 if dist_group8_lineal == 2 

**-----
*-RUTA
**-----
gen     treat_r = 1 if dist_group8_ruta == 1 
replace treat_r = 0 if dist_group8_ruta == 2 

**-----
*-MINUTOS
**-----
gen     treat_m = 1 if dist_group8_ruta == 1 
replace treat_m = 0 if dist_group8_ruta == 2 


*Ventas por comprador: Moving average: 2 periodos antes, el 0 y 1+
tssmooth ma volumen_pub2 =volumen_pub, window(2 0 1)

*normalizo todo a t=715 2019m8 
*viejo: t=718 2019m11
gen byte basetime = 1 if time==715
by id (basetime), sort: gen quant_aux = volumen_pub2 / volumen_pub2[1]

gen quantities = quant_aux 
drop quant_aux
gen quantities_index = quantities*100


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
	*-LINEAL 
	quietly eststo lineal_super: xtreg quantities_index ib0.post ib0.treat_l ib0.treat_l#ib0.post i.id i.time if balanced==59 & treat_l!=., vce(cluster id)  
	esttab lineal_super, keep(1.post 1.treat_l  1.treat_l#1.post) coeflabel(1.treat_l#1.post "Lineal distance") b(%9.4g)
	/* 
	
		g coef_lineal = _b[1.treat_l#1.post] 
	    g se_lineal = _se[1.treat_l#1.post]
	    g ci_top_lineal = coef_lineal + 1.96*se_lineal
	    g ci_bottom_lineal = coef_lineal - 1.96*se_lineal
		
		g lineal = 2
		
	    keep  coef_lineal se_lineal ci_top_lineal ci_bottom_lineal lineal
		duplicates drop
		
			twoway (sc coef_lineal lineal, connect(line)  msize(small) lcolor(cranberry) mcolor(cranberry) msymbol(s) mlabel(coef_lineal) mlabposition(3) mlabgap(*2) mlabformat(%9.4g))	///
			        (rcap ci_top_lineal ci_bottom_lineal lineal , lcolor(cranberry%40)) , ///
			legend(order (1 "Point estimates") region(lcolor(black)) ring(0) pos(11) size(*0.9)) ///
			scheme(modern) xtitle("") ytitle("M3 (base = August 2019)", size(small)) 
			 */
			
			
		
	
	*-RUTA 
	quietly eststo ruta_super: xtreg quantities_index ib0.post ib0.treat_r ib0.treat_r#ib0.post i.id i.time if balanced==59 & treat_r!=., vce(cluster id)
	esttab ruta_super, keep(1.post 1.treat_r  1.treat_r#1.post) b(%9.4g)
		

	*-TIME 
	quietly eststo minutos_super: xtreg quantities_index ib0.post ib0.treat_m ib0.treat_m#ib0.post i.id i.time if balanced==59 & treat_m!=., vce(cluster id)
	esttab minutos_super, keep(1.post 1.treat_m  1.treat_m#1.post) b(%9.4g)
	

	
	*Figura con los 3 coef: 
	/*   coefplot  ///
	     (lineal_super, keep(1.treat_l#1.post) rename(1.treat_l#1.post = "{bf:Naive (Lineal)}") mlabel mlabcolor(black)  mlabposition(3) mlabgap(*2) mlabformat(%9.4g) mcolor(blue) ciopts(lcolor(blue%40)) ) /// 
	     (ruta_super, keep(1.treat_r#1.post) rename(1.treat_r#1.post = "{bf:Route (Km)}") mlabel mlabcolor(black)  mlabposition(3) mlabgap(*2) mlabformat(%9.4g) mcolor(blue)  ciopts(lcolor(blue%40)) ) ///
	     (minutos_super, keep(1.treat_m#1.post) rename(1.treat_m#1.post = "{bf:Time (Minutes)}") mlabel mlabcolor(black) mlabposition(3) mlabgap(*2) mlabformat(%9.4g) mcolor(blue) ciopts(lcolor(blue%40)) ) ///
	      , scheme(modern) name(prueba) vertical legend(order (2 "Regular Gasoline") region(lcolor(black))  pos(6) size(*0.9)) yscale(range(0 50)) ylabel(#6, labsize(small) valuelabels)
			    */
		

restore 



*-------------------------------------------------------------------------------------------------------------------------------------*
*-------------------------------------------------------------------------------------------------------------------------------------*
*---------------------------------------            NAFTA PREMIUM      ---------------------------------------------------------------*
*-------------------------------------------------------------------------------------------------------------------------------------*
*-------------------------------------------------------------------------------------------------------------------------------------*


********************************************************
*- REGRESION AGREGADA NAFTA PREMIUM- 
*********************************************************
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
*Hasta 2017m8 operó la politica de barril criollo. Saco las obs anteriores 
drop if time < 691
xtdes 
replace anio = year if anio==. 


*cantidad de EESS
*Para contar EESS por frontera y provincia 
cap drop aux count_eess 
gen aux = 1 
bysort id: gen count_eess = sum(aux)
replace count_eess = . if count_eess > 1 

*Balanced panel -59 meses- 
bysort id: gen balanced = [_N]

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


**********************************************************
*-- variables de distancias a la frontera (lineal, por ruta, en minutos) 
**********************************************************

**-----
*-LINEAL -HAY QUE CREARLA NO ESTÁ-
**-----

/* gen dist_group8_lineal = . 
replace dist_group8_lineal=1 if dist_minima_lineal<=50
replace dist_group8_lineal=2 if dist_minima_lineal>=200 
label def dist_group8_lineal 1 "<50km paso fronterizo" 2 ">200km" 
label val dist_group8_lineal dist_group8_lineal */

**-----
*-RUTA
**-----
gen dist_group8_ruta = . 
replace dist_group8_ruta=1 if dist_minima_ruta<=50
replace dist_group8_ruta=2 if dist_minima_ruta>=200 
label def dist_group8_ruta 1 "<50km paso fronterizo" 2 ">200km" 
label val dist_group8_ruta dist_group8_ruta 

**-----
*-MINUTOS
**-----
gen dist_group8_minutos = . 
replace dist_group8_minutos=1 if dist_minima_minutos<=60
replace dist_group8_minutos=2 if dist_minima_minutos>=150
label def dist_group8_minutos 1 "<60min paso fronterizo" 2 ">150min" 
label val dist_group8_minutos dist_group8_minutos  


*-------------------------------------------------------------------------------------------*
*---  Diff-in-diff estatico 
*-------------------------------------------------------------------------------------------*

*FIRST STAGE: Omitido: 2019m8 = 715 
gen post=. 
replace post=1 if time>=716 & time!=. 
replace post=0 if (time>691 & time<=715)


*Controls and treated gas stations:
**-----
*-LINEAL
**-----
/* gen     treat_l = 1 if dist_group8_lineal == 1 
replace treat_l = 0 if dist_group8_lineal == 2  */

**-----
*-RUTA
**-----
gen     treat_r = 1 if dist_group8_ruta == 1 
replace treat_r = 0 if dist_group8_ruta == 2 

**-----
*-MINUTOS
**-----
gen     treat_m = 1 if dist_group8_ruta == 1 
replace treat_m = 0 if dist_group8_ruta == 2 


********************************************************
*- REGRESION AGREGADA NAFTA PREMIUM- 
*********************************************************
preserve 
drop if frontera_pais_ruta=="CHL" | frontera_pais_ruta=="URY" 
drop if provincia=="CORRIENTES" & frontera_pais_ruta=="PRY"

	
	*Hay que sacar las obs dnd estuvo cerrada la pandemia: 
	*Marzo 2020=722   Octubre 2021=741 (en Nov la frontera ya estuvo abierta)
	drop if time>=722 & time<=741
	

	*[1] Panel balanceado 
	*-LINEAL 
/* 	quietly eststo lineal_premium: xtreg quantities_index ib0.post ib0.treat_l ib0.treat_l#ib0.post i.id i.time if balanced==59 & treat_l!=., vce(cluster id)
	esttab lineal_premium, keep(1.post 1.treat_l  1.treat_l#1.post) coeflabel(1.treat_l#1.post "Lineal distance")
	 */
	
	
	*-RUTA 
	quietly eststo ruta_premium: xtreg quantities_index ib0.post ib0.treat_r ib0.treat_r#ib0.post i.id i.time if balanced==59 & treat_r!=., vce(cluster id)
	esttab ruta_premium, keep(1.post 1.treat_r  1.treat_r#1.post) 
		

	*-TIME 
	quietly eststo minutos_premium: xtreg quantities_index ib0.post ib0.treat_m ib0.treat_m#ib0.post i.id i.time if balanced==59 & treat_m!=., vce(cluster id)
	esttab minutos_premium, keep(1.post 1.treat_m  1.treat_m#1.post) 

restore 

*-------------------------------------------------------------------------------------------------------------------------------------*
*-------------------------------------------------------------------------------------------------------------------------------------*
*-------------------------------------------------------------------------------------------------------------------------------------*
*-------------------------------------------------------------------------------------------------------------------------------------*
*-------------------------------------------------------------------------------------------------------------------------------------*
*colorpalette lin fruits, nograph  select(1)

colorpalette cblind, nograph 

*------[1] FIGURA CON TODOS LOS COMBUSTIBLES 
  coefplot  ///
	     (lineal_super, keep(1.treat_l#1.post) rename(1.treat_l#1.post = "{bf:Naive (Lineal)}") mlabel mlabsize(vsmall) mlabcolor(black)  mlabposition(3) mlabgap(*2) mlabformat(%9.4g) mcolor(blue) ciopts(lcolor(blue%40) recast(rcap))  ) /// 
	     (ruta_super, keep(1.treat_r#1.post) rename(1.treat_r#1.post = "{bf:Route (Km)}") mlabel mlabsize(vsmall) mlabcolor(black)  mlabposition(3) mlabgap(*2) mlabformat(%9.4g) mcolor(blue)  ciopts(lcolor(blue%40) recast(rcap)) ) ///
	     (minutos_super, keep(1.treat_m#1.post) rename(1.treat_m#1.post = "{bf:Time (Minutes)}") mlabel mlabsize(vsmall) mlabcolor(black) mlabposition(3) mlabgap(*2) mlabformat(%9.4g) mcolor(blue) ciopts(lcolor(blue%40) recast(rcap)) ) ///
		 (ruta_premium, keep(1.treat_r#1.post) rename(1.treat_r#1.post = "{bf:Route (Km)}") mlabel mlabsize(vsmall) mlabcolor(black) mlabposition(3) mlabgap(*2) mlabformat(%9.4g) mcolor("`r(p8)'") ciopts(lcolor("`r(p8)'%70") recast(rcap)) ) ///
		 (minutos_premium, keep(1.treat_m#1.post) rename(1.treat_m#1.post = "{bf:Time (Minutes)}") mlabel mlabsize(vsmall) mlabcolor(black) mlabposition(3) mlabgap(*2) mlabformat(%9.4g) mcolor("`r(p8)'%70") ciopts(lcolor("`r(p8)'%70") recast(rcap)) ) ///
		 (lineal_gasoil, keep(1.treat_l#1.post) rename(1.treat_l#1.post = "{bf:Naive (Lineal)}") mlabel mlabsize(vsmall) mlabcolor(black)  mlabposition(3) mlabgap(*2) mlabformat(%9.4g) mcolor("`r(p5)'") ciopts(lcolor("`r(p5)'%70") recast(rcap))  ) /// 
	     (ruta_gasoil, keep(1.treat_r#1.post) rename(1.treat_r#1.post = "{bf:Route (Km)}") mlabel mlabsize(vsmall) mlabcolor(black)  mlabposition(3) mlabgap(*2) mlabformat(%9.4g) mcolor("`r(p5)'")  ciopts(lcolor("`r(p5)'%70") recast(rcap)) ) ///
	     (minutos_gasoil, keep(1.treat_m#1.post) rename(1.treat_m#1.post = "{bf:Time (Minutes)}") mlabel mlabsize(vsmall) mlabcolor(black) mlabposition(3) mlabgap(*2) mlabformat(%9.4g) mcolor("`r(p5)'") ciopts(lcolor("`r(p5)%70'") recast(rcap)) ) ///
	      , scheme(modern) vertical yscale(range(0 70)) ///
		  ylabel(#7, labsize(small) valuelabels)  name(prueba) ///
		  legend(order (2 "Regular Gasoline" 8 "Premium Gasoline" 12 "Diesel") region(lcolor(black))  pos(6) col(3) size(*0.9)) ///
		  xtitle("") ytitle("Fuel Quantity gap relative to control group (p.p.)", size(small)) 
		   
		   
		   
			--	
				
		
				
				
	legend(order (3 "`treat8' " 4 "`control8'") region(lcolor(black)) ring(0) pos(11) size(*0.9)) ///
			scheme(modern) 
	
	
	--
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
coefplot (lineal_super ruta_super minutos_super, keep(1.treat_l#1.post 1.treat_r#1.post 1.treat_m#1.post) asequation("Regular Gasoline") \  ///
          ruta_premium minutos_premium, keep(1.treat_r#1.post 1.treat_m#1.post) asequation("Premium Gasoline")) /// 
	           , scheme(modern) name(pruebas)  xscale(range(0 50)) xlabel(#6, labsize(small) valuelabels) 
			   

--
legend(order (2 "Naive (lineal)" 4 "Route (km)" 6 "Time (min)") region(lcolor(black)) col(3) pos(6) size(*0.9))
	 

coefplot (d_mpg d_trunk d_length d_turn, asequation(Domestic) \ ///
          f_mpg f_trunk f_length f_turn, asequation(Foreign)  \ ///
          , pstyle(p4)) ///
    , drop(_cons) xline(0) title("Bivariate effects on price by car type")


	 --
	 legend(order (3 "`treat8' " 4 "`control8'") region(lcolor(black)) ring(0) pos(11) size(*0.9))
	 

lineal_super 
ruta_super 
minutos_super 

ruta_premium
minutos_premium 

lineal_gasoil
ruta_gasoil
minutos_gasoil 



