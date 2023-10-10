*-------------------------------------------------------------------------------------------------------------------------------------*
*-------------------------------------------------------------------------------------------------------------------------------------*
*-----------------------------NAFTA SUPER---------------------------------------------------------------------------------------------*
*-------------------------------------------------------------------------------------------------------------------------------------*
*-------------------------------------------------------------------------------------------------------------------------------------*

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

gen     dist_group8_ruta_50 = . 
replace dist_group8_ruta_50 =1 if dist_minima_ruta<=50
replace dist_group8_ruta_50 =2 if dist_minima_ruta>=200

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
gen     treat_50 = 1 if dist_group8_ruta_50 == 1 
replace treat_50 = 0 if dist_group8_ruta_50 == 2 


********************************************************
*- REGRESION AGREGADA NAFTA SUPER- 
*********************************************************
preserve 
drop if frontera_pais_ruta=="CHL" | frontera_pais_ruta=="URY" 
drop if provincia=="CORRIENTES" & frontera_pais_ruta=="PRY"

	
	*Hay que sacar las obs dnd estuvo cerrada la pandemia: 
	*Marzo 2020=722   Octubre 2021=741 (en Nov la frontera ya estuvo abierta)
	drop if time>=722 & time<=741
	
	
	*Trabajo con esta variable pq uso distancia por ruta 
     encode nombre_paso_ruta, gen(paso_fronterizo)
	 ta paso_fronterizo
	 
	 
. ta paso_fronterizo

/*                  nombre_paso_aux |      Freq.     Percent        Cum.
---------------------------------+-----------------------------------
           AGUAS BLANCAS-BERMEJO (BOL) |      5,789       35.52       35.52
              ANDRESITO-CAPANEMA (BRA)|        156        0.96       36.48
CLORINDA - PUERTO JOSE A. FALCON (PRY)|         38        0.23       36.71
            IGUAZU-FOZ DE IGUAZU (BRA) |        916        5.62       42.33
              LA QUIACA-VILLAZÓN (BOL)|        117        0.72       43.05
        PASARELA LA FRATERNIDAD  (PRY)|      4,590       28.16       71.22
   PASO DE LOS LIBRES-URUGUAYANA (BRA)|      1,462        8.97       80.19
           POSADAS - ENCARNACION (PRY)|      2,652       16.27       96.46
          SALVADOR MAZZA-YACUIBA (BOL)|        346        2.12       98.58
            SANTO TOME-SAO BORJA (BRA)|        231        1.42      100.00
---------------------------------+-----------------------------------
                           Total |     16,297      100.00 */


	*[1] Panel balanceado 
	*-RUTA 
	*Sin paso 1: AGUAS BLANCAS-BERMEJO (BOL)
		quietly eststo paso_1: xtreg quantities_index ib0.post ib0.treat_50 ib0.treat_50#ib0.post i.id i.time if balanced==59 & treat_50!=. & paso_fronterizo!=1, vce(cluster id)
	esttab paso_1, keep(1.post 1.treat_50  1.treat_50#1.post) b(%9.4g)
	
	--
	
	
	
	*Sin paso 2: ANDRESITO-CAPANEMA (BRA)
		quietly eststo paso_2: xtreg quantities_index ib0.post ib0.treat_50 ib0.treat_50#ib0.post i.id i.time if balanced==59 & treat_50!=. & paso_fronterizo!=2, vce(cluster id)
	esttab paso_2, keep(1.post 1.treat_50  1.treat_50#1.post) b(%9.4g)
	*Sin paso 3: CLORINDA - PUERTO JOSE A. FALCON (PRY)
		quietly eststo paso_3: xtreg quantities_index ib0.post ib0.treat_50 ib0.treat_50#ib0.post i.id i.time if balanced==59 & treat_50!=. & paso_fronterizo!=3, vce(cluster id)
	esttab paso_3, keep(1.post 1.treat_50  1.treat_50#1.post) b(%9.4g)
	*Sin paso 4: IGUAZU-FOZ DE IGUAZU (BRA)
		quietly eststo paso_4: xtreg quantities_index ib0.post ib0.treat_50 ib0.treat_50#ib0.post i.id i.time if balanced==59 & treat_50!=. & paso_fronterizo!=4, vce(cluster id)
	esttab paso_4, keep(1.post 1.treat_50  1.treat_50#1.post) b(%9.4g)
	*Sin paso 5: LA QUIACA-VILLAZÓN (BOL)
		quietly eststo paso_5: xtreg quantities_index ib0.post ib0.treat_50 ib0.treat_50#ib0.post i.id i.time if balanced==59 & treat_50!=. & paso_fronterizo!=5, vce(cluster id)
	esttab paso_5, keep(1.post 1.treat_50  1.treat_50#1.post) b(%9.4g)
	*Sin paso 6: PASARELA LA FRATERNIDAD  (PRY)
		quietly eststo paso_6: xtreg quantities_index ib0.post ib0.treat_50 ib0.treat_50#ib0.post i.id i.time if balanced==59 & treat_50!=. & paso_fronterizo!=6, vce(cluster id)
	esttab paso_6, keep(1.post 1.treat_50  1.treat_50#1.post) b(%9.4g)
	*Sin paso 7: PASO DE LOS LIBRES-URUGUAYANA (BRA)
		quietly eststo paso_7: xtreg quantities_index ib0.post ib0.treat_50 ib0.treat_50#ib0.post i.id i.time if balanced==59 & treat_50!=. & paso_fronterizo!=7, vce(cluster id)
	esttab paso_7, keep(1.post 1.treat_50  1.treat_50#1.post) b(%9.4g)
	*Sin paso 8: POSADAS - ENCARNACION (PRY)
		quietly eststo paso_8: xtreg quantities_index ib0.post ib0.treat_50 ib0.treat_50#ib0.post i.id i.time if balanced==59 & treat_50!=. & paso_fronterizo!=8, vce(cluster id)
	esttab paso_8, keep(1.post 1.treat_50  1.treat_50#1.post) b(%9.4g)
	*Sin paso 9: SALVADOR MAZZA-YACUIBA (BOL)
		quietly eststo paso_9: xtreg quantities_index ib0.post ib0.treat_50 ib0.treat_50#ib0.post i.id i.time if balanced==59 & treat_50!=. & paso_fronterizo!=9, vce(cluster id)
	esttab paso_9, keep(1.post 1.treat_50  1.treat_50#1.post) b(%9.4g)
	*Sin paso 10: SANTO TOME-SAO BORJA (BRA)
	quietly eststo paso_10: xtreg quantities_index ib0.post ib0.treat_50 ib0.treat_50#ib0.post i.id i.time if balanced==59 & treat_50!=. & paso_fronterizo!=10, vce(cluster id)
	esttab paso_10, keep(1.post 1.treat_50  1.treat_50#1.post) b(%9.4g)

	
		

restore 

colorpalette plottig, nograph 

coefplot  ///
	     (paso_1, keep(1.treat_50#1.post) rename(1.treat_50#1.post = "Aguas Blancas - Bermejo (BOL)") mlabel mlabsize(vsmall) mlabcolor(black)  mlabposition(1) mlabgap(*2) mlabformat(%9.4g) mcolor("`r(p2)'") ciopts(lcolor("`r(p2)%70'") recast(rcap))  ) /// 
		 (paso_5, keep(1.treat_50#1.post) rename(1.treat_50#1.post = "La Quiaca - Villazón (BOL)") mlabel mlabsize(vsmall) mlabcolor(black) mlabposition(1) mlabgap(*2) mlabformat(%9.4g) mcolor("`r(p2)'") ciopts(lcolor("`r(p2)'%70") recast(rcap)) ) ///
		 (paso_9, keep(1.treat_50#1.post) rename(1.treat_50#1.post = "Salvador Mazza - Yacuiba (BOL)") mlabel mlabsize(vsmall) mlabcolor(black) mlabposition(1) mlabgap(*2) mlabformat(%9.4g) mcolor("`r(p2)'") ciopts(lcolor("`r(p2)%70'") recast(rcap)) ) ///   
	     (paso_2, keep(1.treat_50#1.post) rename(1.treat_50#1.post = "Andresito - Capanema (BRA)") mlabel mlabsize(vsmall) mlabcolor(black)  mlabposition(1) mlabgap(*2) mlabformat(%9.4g) mcolor("`r(p8)'")  ciopts(lcolor("`r(p8)'%70") recast(rcap)) ) ///
		  (paso_4, keep(1.treat_50#1.post) rename(1.treat_50#1.post = "Iguazu - Foz de Iguazu (BRA)") mlabel mlabsize(vsmall) mlabcolor(black) mlabposition(1) mlabgap(*2) mlabformat(%9.4g) mcolor("`r(p8)'") ciopts(lcolor("`r(p8)'%70") recast(rcap)) ) ///
		  (paso_7, keep(1.treat_50#1.post) rename(1.treat_50#1.post = "Paso de los Libres - Uruguayana (BRA)") mlabel mlabsize(vsmall) mlabcolor(black)  mlabposition(1) mlabgap(*2) mlabformat(%9.4g) mcolor("`r(p8)'")  ciopts(lcolor("`r(p8)'%70") recast(rcap)) ) ///	   
		 (paso_10, keep(1.treat_50#1.post) rename(1.treat_50#1.post = "Santo Tome - Sao Borja (BRA)") mlabel mlabsize(vsmall) mlabcolor(black) mlabposition(1) mlabgap(*2) mlabformat(%9.4g) mcolor("`r(p8)'") ciopts(lcolor("`r(p8)%70'") recast(rcap)) ) ///		 
	     (paso_3, keep(1.treat_50#1.post) rename(1.treat_50#1.post = "Clorinda - Puerto Jose A. Falcon (PRY)") mlabel mlabsize(vsmall) mlabcolor(black) mlabposition(1) mlabgap(*2) mlabformat(%9.4g) mcolor("`r(p5)'") ciopts(lcolor("`r(p5)'%70") recast(rcap)) ) ///
		 (paso_6, keep(1.treat_50#1.post) rename(1.treat_50#1.post = "Clorinda - Nanawa (PRY)") mlabel mlabsize(vsmall) mlabcolor(black)  mlabposition(1) mlabgap(*2) mlabformat(%9.4g) mcolor("`r(p5)'") ciopts(lcolor("`r(p5)'%70") recast(rcap))  ) /// 
	     (paso_8, keep(1.treat_50#1.post) rename(1.treat_50#1.post = "Posadas - Encarnación (PRY)") mlabel mlabsize(vsmall) mlabcolor(black) mlabposition(1) mlabgap(*2) mlabformat(%9.4g) mcolor("`r(p5)'") ciopts(lcolor("`r(p5)%70'") recast(rcap)) ) ///
	      , scheme(modern)  ///
		  ylabel(, labsize(vsmall) nogrid)  name(prueba) ///
		  legend(off)   xline(0, lpattern(dash)) xlabel(-10(10)80, labsize(small) valuelabels) ///
		  xtitle("") plotregion(margin(medium))
		  
   graph export "salidas\reg\nafta\dynamic did\final tesis\robust-pasos.pdf", replace		  