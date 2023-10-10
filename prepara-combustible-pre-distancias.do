
******************************************************************************
/*  Prepara base con distancias lineales para calcular distancias x ruta 
Solo saca:
- 1 obs por EESS con id y coordenadas */ 
******************************************************************************

local combustibles nafta

*gasoil nafta

foreach c of local combustibles { 
  
  *nafta 3 -premium-: (usar esta sin las distancias lineales) 
  use "bases\base-precios\p-pulidas\\`c'3\\`c'_3_al_publico", clear
  
  
  
 *gasoil2 nafta2:  
 *use "bases\base-precios\p-pulidas-distancias\\`c'_2_2016_2022.dta", clear 
  
	preserve
		collapse _Y _X  , by(codigo_unico_de_coordenadas)
	
	*para matchear la info hay que usar el excel de localizacion-pasos-fronterizos, sheet(pasos-finales-para-merge)
        forvalues a = 1/31 { 
	gen x_`a' = . 
	gen y_`a' = . 
	label var x_`a' "Latitud paso `a'"
	label var y_`a' "Longitud paso `a'" 
		}	
	
	
		replace x_1	= -33.1114478	
		replace y_1	= -58.2460198
		replace x_2	= -32.26377376	
		replace y_2	= -58.09786121
		replace x_3	= -31.2609222	
		replace y_3	= -57.961622
		replace x_4	= -22.01436223	
		replace y_4	= -63.68222836
		replace x_5	= -22.72620497	
		replace y_5	= -64.36962899
		replace x_6	= -22.09672714	
		replace y_6	= -65.59619637
		replace x_7	= -25.60106748	
		replace y_7	= -53.97057139
		replace x_8	= -25.6006454	
		replace y_8	= -54.56112463
		replace x_9	= -29.73110932	
		replace y_9	= -57.11126655
		replace x_10= -28.59117286	
		replace y_10= -56.03289063
		replace x_11= -25.26475634	
		replace y_11= -57.72759045
		replace x_12= -25.28605686	
		replace y_12= -57.70915988
		replace x_13= -27.37430302	
		replace y_13= -55.88208906
		replace x_14= -32.82543516	
		replace y_14= -70.09213018
		replace x_15= -30.19135328	
		replace y_15= -69.82563194
		replace x_16= -40.6984364	
		replace y_16= -71.93376231
		replace x_17= -39.78724569	
		replace y_17= -71.6817892
		replace x_18= -51.57445833	
		replace y_18= -72.35013889
		replace x_19= -52.13863902	
		replace y_19= -69.51603956
		replace x_20= -45.14033066	
		replace y_20= -71.33646004
		replace x_21= -35.98585044	
		replace y_21= -70.39111652
		replace x_22= -37.44763756	
		replace y_22= -71.11618237
		replace x_23= -38.66065544	
		replace y_23= -70.89879853
		replace x_24= -27.9882992	
		replace y_24= -69.32401697
		replace x_25= -51.25899931	
		replace y_25= -72.34407249
		replace x_26= -44.5538149	
		replace y_26= -71.09421421
		replace x_27= -43.17369427	
		replace y_27= -71.74984262
		replace x_28= -46.5864258	
		replace y_28= -71.66754638
		replace x_29= -26.48287502	
		replace y_29= -68.18383364
		replace x_30= -23.82663028	
		replace y_30= -67.25150602
		replace x_31= -35.18089593	
		replace y_31= -70.51976084

drop if _X==. & _Y==. 
	save "bases\base-precios\p-pulidas-distancias\aux-`c'3-pre-distancias.dta", replace 
	restore 

}


