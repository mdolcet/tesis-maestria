
set autotabgraph on 


*---------------------------------------------------------------------------*
*---------------regresiones GASOIL 2
*---------------------------------------------------------------------------* 
use "bases\base-precios\p-pulidas-distancias\gasoil_2_2016_2022_v2.dta", clear 

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


**-----
*-dist group 9
**-----
gen dist_group9 = . 
replace dist_group9=1 if dist_minima<=50
replace dist_group9=2 if dist_minima>=150 & dist_minima<=250 
label def dist_group9 1 "<50km paso fronterizo" 2 "150-250km" 
label val dist_group9 dist_group9

drop if provincia=="MENDOZA" 



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


	esttab using "salidas/reg/gasoil/standard-did/gasoil-`c'-lineal-g8.tex" , ///
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


	esttab using "salidas/reg/gasoil/standard-did/gasoil-`c'-ruta-g8.tex" , ///
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


	esttab using "salidas/reg/gasoil/standard-did/gasoil-`c'-time-g8.tex" , ///
	keep(1.post 1.treat_m  ///
	1.post#1.treat_m  _cons) ///
	coeflabel(1.post "Post"  1.treat_m "Treat" ///
	1.post#1.treat_m "Post X Treat (minutes)" _cons "Constant") ///
	stats(N provinces price, label("Observations" "Provinces FE" "Price") fmt(%9.0fc))  ///
	b(3) se(3) star(* 0.10 ** 0.05 *** 0.01)  compress booktabs   nomtitles  ///
	title(`c' - Time distance) replace 

}





 