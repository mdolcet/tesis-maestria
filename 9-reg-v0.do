*******************************************************
*- DRAFT 0 REGRESIONES 
*******************************************************
use "bases\base-precios\p-pulidas-distancias\nafta_2_2016_2022.dta", clear 




*seteo panel 
tsset id time 



*limpio un poco la bases
keep if volumen_pub!=. | lvol_pub!=.

*para contar EESS
egen id_count2 = group(id frontera_pais) 

*variables de distancia a la frontera 

*Grupos de distancia 50km vs el resto 
gen dist_group5 = . 
replace dist_group5=1 if dist_minima<=50
replace dist_group5=0 if dist_minima>50
label def dist_group5 1 "<50km paso fronterizo" 0 ">50km" 
label val dist_group5 dist_group5


*Grupos de distancia 25 km vs >200 km 
gen dist_group7 = . 
replace dist_group7=1 if dist_minima<=25
replace dist_group7=2 if dist_minima>200
label def dist_group7 1 "<25km paso fronterizo" 2 ">200km" 
label val dist_group7 dist_group7

*Grupos de distancia 50km vs >200km 
gen dist_group8 = . 
replace dist_group8=1 if dist_minima<=50
replace dist_group8=0 if dist_minima>200
label def dist_group8 1 "<50km paso fronterizo" 0 ">200km" 
label val dist_group8 dist_group8

*Grupos de distancia 65km vs >75km 
gen dist_group9 = . 
replace dist_group9=1 if dist_minima<=75
replace dist_group9=0 if dist_minima>200
label def dist_group9 1 "<75km paso fronterizo" 0 ">200km" 
label val dist_group9 dist_group9

*log del precio en usd 
gen p_surtidor_usd = p_surtidor_pub / oficial_venta 
gen lp_surtidor_usd  = ln(p_surtidor_usd)

*provincia 
encode provincia, gen(prov)


*****************************************************************
*post: if time>=2019m11=718  
*pre:   2017m8 a 2019m10 
*****************************************************************

*FIRST STAGE:
gen post=. 
replace post=1 if time>=718 & time!=. 
replace post=0 if (time>=691 & time<718)
*--------------------------*
*-TRADITIONAL DIFF-IN-DIFF 
*--------------------------*
/* 

*saco todas las obs anteriores a 2017m8 
drop if time<691 



*TREATED - CONTROL: variables de distancia 
*estimates table, keep(ib0.post##ib0.dist_group8 lp_surtidor_usd) b p

rename dist_group8 treated

*BOLIVIA 
*Sin FE por prov y time , sin el P 
quietly xtreg lvol_pub  ib0.post##ib0.treated  if frontera_pais=="BOL" & treated!=. 
estimates store m1 
outreg2 [m1] using "salidas/reg/nafta/nafta-BOL.xls", label ///
			addtext(Prov, NO, Time, NO, P, NO)  ///
			append ctitle(1) dec(3) 
			
			

*Con FE por prov y time, sin el P 
quietly xtreg lvol_pub  ib0.post##ib0.treated i.time i.prov if frontera_pais=="BOL" & treated!=. 
estimates store m2 
outreg2 [m2] using "salidas/reg/nafta/nafta-BOL.xls", label ///
			addtext(Prov, YES, Time, YES, P, NO)  ///
			append ctitle(1) dec(3) 
		

*Con FE por prov y time, con el P 
quietly xtreg lvol_pub  ib0.post##ib0.treated i.time i.prov c.lp_surtidor_usd if frontera_pais=="BOL" & treated!=. 
estimates store m2 
outreg2 [m2] using "salidas/reg/nafta/nafta-BOL.xls", label ///
			addtext(Prov, YES, Time, YES, P, YES)  ///
			append ctitle(1) dec(3) 
		

 */
*estimates table m1 m2 m3, keep(ib0.post##ib0.treated lp_surtidor_usd) b p title(BOLIVIA)


*--------------------------*
*-DYNAMIC DIFF-IN-DIFF / EVENT-STUDY  
*--------------------------*

*[1] Create the lag/lead for treated states
































preserve 
keep if frontera_pais=="BOL" 
keep if dist_group8!=. 

egen id_bol = group(id) if frontera_pais=="BOL" & dist_group8!=.
tsset id_bol  time 


xtreg lvol_pub ///
	  ib0.post##ib0.dist_group8 
	 
*if (frontera_pais=="BOL" & dist_group8!=.)


estimates store beta_bol
local obs=e(N)
local T=e(g_avg)
local N=e(N_g)
sum year if e(sample)
local year_start = r(min)
local year_end = r(max)

*e(sample) es para ver con cuantas obs hace la reg 
sum mes if year==`year_start' & e(sample)
local mes_start = r(min)
sum mes if year==`year_end' & e(sample)
local mes_end = r(max)



* plot coefficients:
*ciopts: forma de los ic 
*recast(rcap) forma de los marcadores 

coefplot (beta_bol, ciopts(recast(rcap)) recast(connected) level(95)), ///
  	vertical ///
 	yline(0, lcolor(black) lwidth(thin)) ylabel(,labsize(medlarge)) ///
 	graphregion(color(white)) ///
  	xtitle (" " "Months", size(medlarge)) ytitle ("Effect on log sales gas stations" " ", size(medlarge)) ///
	legend(off) scheme(modern) ///
	note(" " "Observations: `obs', Stations: `N', Periods: `T' (`mes_start'/`year_start' - `mes_end'/`year_end').", size(small)) ///
	name(prueba)

restore







graph export "beta_bol.pdf", replace


















*BRASIL 
*Sin FE por prov y time , sin el P 
quietly xi: reg lvol_pub  ib0.post##ib0.dist_group8  if frontera_pais=="BRA" & dist_group8!=. 
estimates store m1 
*Con FE por prov y time, sin el P 
quietly xi: reg lvol_pub  ib0.post##ib0.dist_group8 i.time i.prov if frontera_pais=="BRA" & dist_group8!=. 
estimates store m2
*Con FE por prov y time, con el P 
quietly xi: reg lvol_pub  ib0.post##ib0.dist_group8 i.time i.prov c.lp_surtidor_usd if frontera_pais=="BRA" & dist_group8!=. 
estimates store m3 

estimates table m1 m2 m3, keep(ib0.post##ib0.dist_group8 lp_surtidor_usd) b p title(BRASIL)



--

diff lvol_pub  if frontera_pais=="BOL" & dist_group8!=., p(post) t(dist_aux)