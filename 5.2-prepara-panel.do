*------------------------------------------------
* Preparar panel 2016-2022 -  GASOIL 2 
*------------------------------------------------


use "bases\base-precios\p-pulidas\gasoil2\gasoil2_2016_2022_aux", clear  

*borro variables que no sirven 
drop _merge merge_coord_nuevas m_panel 
drop p_tax_real p_tax_usd p_no_tax_real p_no_tax_usd p_surtidor_real p_surtidor_usd

*vuelvo a crear id, log vol y p en usd 
drop id log_vol vol_aux volumen_duplicado 


*creo id por EESS 
encode codigo_unico_de_coordenadas, g(id) 
label var id "Identificador de EE.SS ARG" 

*seteo panel 
tsset id time 


*unifico variable de volumen 2005-2019 y 2020-2022 
replace volumen_pub= volumen if volumen_pub==.
drop volumen

*volumen en logs
gen lvol_pub = log(volumen_pub)
label var lvol_pub "Ln(vol) pub"

*etiquetas coordenadas eess 
label var _X "Longitud EE.SS"
label var _Y "Latitud EE.SS"

*PRECIOS EN SURTIDOR: TRAER LOS TC
merge m:m time using "bases\tc\tc-arg.dta", keepusing(blue_venta blue_compra oficial_venta oficial_compra) 
keep if _merge==3

*unifico variable de precio 2005-2019 y 2020-2022 
replace p_surtidor_pub=p_surtidor if p_surtidor_pub==.
drop p_surtidor 


gen psurt_usd_pub  = . 
replace psurt_usd_pub = p_surtidor_pub / oficial_venta 
label var psurt_usd_pub "Psurtidor usd oficial pub" 


*Creo variables con las coordenadas de los pasos 
drop x_* y_* 
forvalues a = 1/52 { 
	gen x_`a' = . 
	gen y_`a' = . 
	label var x_`a' "Latitud paso `a'"
	label var y_`a' "Longitud paso `a'" 
		}

		replace x_1 = -33.1114478	
		replace y_1 = -58.2460198
		replace x_2 = -32.26377376
		replace y_2 = -58.09786121
		replace x_3 = -31.2609222
		replace y_3 = -57.961622
		replace x_4 = -22.01436223
		replace y_4 = -63.68222836
		replace x_5 = -22.72620497
		replace y_5 = -64.36962899
		replace x_6 = -22.18928562
		replace y_6 = -64.65312351
		replace x_7 = -22.09672714
		replace y_7 = -65.59619637
		replace x_8 = -25.60106748
		replace y_8 =  -53.97057139
		replace x_9 = -26.25474167
		replace y_9 = -53.64406944
		replace x_10 = -25.6006454
		replace y_10 = -54.56112463
		replace x_11 = -29.73110932
		replace y_11 = -57.11126655
		replace x_12 = -26.61203056
		replace y_12 = -53.736925
		replace x_13 = -26.05632034
		replace y_13 = -53.73132575
		replace x_14 = -28.59117286
		replace y_14 = -56.03289063
		replace x_15 = -25.26475634
		replace y_15 = -57.72759045
		replace x_16 = -24.74845278
		replace y_16 = -58.83346944
		replace x_17 = -24.21251111
		replace y_17 = -60.1974444
		replace x_18 = -22.37783456
		replace y_18 = -62.51802235
		replace x_19 = -25.28605686
		replace y_19 = -57.70915988
		replace x_20 = -23.94633052
		replace y_20 = -60.48942635
		replace x_21 = -23.8725
		replace y_21 = -60.760278
		replace x_22 = -27.37430302
		replace y_22 = -55.88208906
		replace x_23 = -32.82543516
		replace y_23 = -70.09213018
		replace x_24 = -30.19135328
		replace y_24 = -69.82563194
		replace x_25 = -40.6984364
		replace y_25 = -71.93376231
		replace x_26 = -39.78724569
		replace y_26 = -71.6817892
		replace x_27 = -45.52875278
		replace y_27 = -71.56580556
		replace x_28 = -51.57445833
		replace y_28 = -72.35013889
		replace x_29 = -45.91538193
		replace y_29 = -71.64399313
		replace x_30 = -38.84366851
		replace y_30 = -71.24445296
		replace x_31 = -46.26396825
		replace y_31 = -71.67969171
		replace x_32 = -52.13863902
		replace y_32 = -69.51603956
		replace x_33 = -21.7976362
		replace y_33 = -66.89836809
		replace x_34 = -44.227222
		replace y_34 = -71.775
		replace x_35 = -51.68954253
		replace y_35 = -72.29094155
		replace x_36 = -38.76680841
		replace y_36 = -71.54586303
		replace x_37 = -45.14033066
		replace y_37 = -71.33646004
		replace x_38 = -35.98585044
		replace y_38 = -70.39111652
		replace x_39 = -37.44763756
		replace y_39 = -71.11618237
		replace x_40 = -38.66065544
		replace y_40 = -70.89879853
		replace x_41 = -27.9882992
		replace y_41 = -69.32401697
		replace x_42 = -51.25899931
		replace y_42 = -72.34407249
		replace x_43 = -43.58760771
		replace y_43 = -71.70653983
		replace x_44 = -44.5538149
		replace y_44 = -71.09421421
		replace x_45 = -43.17369427
		replace y_45 = -71.74984262
		replace x_46 = -46.5864258
		replace y_46 = -71.66754638
		replace x_47 = -47.1576585
		replace y_47 = -71.85146975
		replace x_48 = -26.48287502
		replace y_48 = -68.18383364
		replace x_49 = -23.82663028
		replace y_49 = -67.25150602
		replace x_50 = -24.44735634
		replace y_50 = -68.27906644
		replace x_51 = -45.58057757
		replace y_51 = -71.72254009
		replace x_52 = -35.18089593
		replace y_52 = -70.51976084


************************************
*BORRO ALGUNOS PASOS FRONTERIZOS.
*Mirar el num del xlsx:
*G:\Mi unidad\Malena\FCE\Maestria\Tesis\raw-data\pasos fronterizos ARG\localizacion-pasos-fronterizos HOJA1 
************************************

*SACO PASOS DE BRA
drop x_9 y_9 x_12 y_12 

*SACO PASOS DE PRY 
drop x_16 y_16 x_17 y_17 x_21 y_21



*calculo distancias a los pasos
local todas_dist 
drop dist_*

		forvalues z = 1/52 { 
		*distancia a cada uno de los pasos: (en m) 
		geodist _Y _X  x_`z' y_`z' , gen(dist_`z') 
		format dist_`z' %9.4f
		*guardo los valores de cada distancia 
		*levelsof dist_`z' 
		*local dist_`z' = r(levels) 
		*acumulo distancias 
		local todas_dist `todas_dist' dist_`z' 
}


*armo distancia minima 
egen dist_minima = rowmin(dist_*) 
*identifico que numero de paso es: tengo que redondear porque los decimales de las dist_* son mayores que dist_minima 
drop info_paso 
gen info_paso = 0

gen dist_minima_aux=round(dist_minima, .4)
label var dist_minima "Distancia min al paso mas cercano en km"


forvalues z = 1/52 { 
	cap drop dist_`z'_aux 
	gen dist_`z'_aux = round(dist_`z', .4)
	replace info_paso=`z' if dist_minima_aux==dist_`z'_aux 
}
drop dist_*_aux 


drop frontera_arg_provincia frontera_pais nombre_paso 

 *traigo la info de los pasos fronterizos de la otra carpeta de la tesis: 
merge m:1 info_paso using "G:\Mi unidad\Malena\FCE\Maestria\Tesis\bases\base-pasos-fronterizos\pasos-fronterizos-coord", gen(m_pasos)
ta m_pasos



*saco los pasos que no tienen eess cerca
drop if m_pasos==2

*traigo los tc blue y oficial 
*merge m:1 time using  "bases\tc\tc-arg.dta", gen(m_tc)

*indentificador de provincia del paso arg 
encode frontera_arg_provincia , generate(prov_arg_frontera) label("Prov ARG en la frontera")
drop frontera_arg_provincia

*borro coordenadas de los pasos y las distancias de cada EESS 
forvalues z = 1/52 { 
	drop x_`z' 
	drop y_`z'
	drop dist_`z' 
}

*borro variables que no sirven 
drop tipo_de_cambio codigo1 codigo2 puntocoma codigo_combustible ene_id_time_aux para_dropear rec_header publico _merge 






*guardo base final para armar graficos 
save "bases\base-precios\p-pulidas-distancias\gasoil_2_2016_2022.dta", replace 




/* 



*EESS por año y provincia 
	preserve
		table provincia anio, c(count id) replace
		reshape wide table1, i(provincia) j(anio)
			forvalues x = 2005/2019 { 
				rename table1`x' y`x' 
			} 
		export excel using "salidas\control muestra\obs-finales-nafta_2.xlsx", sheet("provincias") sheetmodify   firstrow(var)
	restore 

*EESS por año y paso fronterizo 
	preserve 
		table info_paso anio, c(count id) replace 
		reshape wide table1, i(info_paso) j(anio)
			forvalues x = 2005/2019 { 
				rename table1`x' y`x' 
			}
		export excel using "salidas\control muestra\obs-finales-nafta_2.xlsx", sheet("info_pasos") sheetmodify   firstrow(var)	
	restore 	
	
	
*GUARDO BASE 
save "bases\base-por-combustible\combustible-nafta_2_v2", replace 



 */



