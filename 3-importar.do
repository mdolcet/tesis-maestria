*------------------------------------------------
* Importar Bases de precios y volumenes
*------------------------------------------------
cd "`cd'" 

*Importamos 
set excelxlsxlargefile on

*Importo bases 2020-2022
 forvalues x = 2020/2022 {                                                                
	import delimited  "raw-data\combustibles\precios\precios-eess-`x'.csv"  , clear  case(lower)   
	save "bases/base-precios/temporal_`x'" , replace                               
}


*Uno bases 
use "bases\base-precios\temporal_2020.dta" , clear                         


forvalues x = 2021/2022 {
	append using "bases\base-precios\temporal_`x'"
}  

*arreglo algunas cosas: (dropear al operador de prueba) 
rename ïanio year
drop if nro_inscripcion ==101
save "bases\base-precios\precios_eess_2020_2022.dta" , replace  	

*******************************************************************
* COORDENADAS EESS
*******************************************************************
global cd "G:\Mi unidad\Malena\FCE\Maestria\Tesis-v2"
cd "$cd\raw-data\coordenadas 2022\shapefile-de-eess-res-1104-" 
spshape2dta shapefile-de-eess-res-1104--shp.shp,  replace saving(coordenadas_base_2022) 

*abro base coordenadas 2022. 
*Aca hay que hacer 2 cosas: 1)pegarle las coordenadas a la base de coordenadas_base_2022 y 2) matchearlo c la base de eess
*[1]
use coordenadas_base_2022 , clear
merge 1:1 _ID using coordenadas_base_2022_shp  
drop _merge
rename IDEMPRESA  nro_inscripcion 
rename PROVINCIA  provincia
rename DIRECCION  direccion
rename EMPRESABAN bandera
rename RAZONSOCIA operador
rename LOCALIDAD  localidad 
rename CUIT       cuit 
drop _CX _CY 

save "G:\Mi unidad\Malena\FCE\Maestria\Tesis-v2\bases\base-coordenadas\coordenadas-2022.dta" , replace 

*[2]
use "G:\Mi unidad\Malena\FCE\Maestria\Tesis-v2\bases\base-precios\precios_eess_2020_2022.dta" , clear 
merge m:1 nro_inscripcion using "$cd\bases\base-coordenadas\coordenadas-2022"

/*   Result                           # of obs.
    -----------------------------------------
    not matched                        56,677
        from master                    56,667  (_merge==1)
        from using                         10  (_merge==2)

    matched                           567,376  (_merge==3)
    -----------------------------------------
*tengo 56.677 que no matchean. 
 */

rename _merge merge1
*guardo eess matcheadas: 
preserve
keep if merge1 ==3 
save "G:\Mi unidad\Malena\FCE\Maestria\Tesis-v2\bases\base-precios\precios_eess_con_coordenadas_2020_2022" , replace
restore 

*me guardo las q no matchean: 
preserve 
keep if merge1 == 1 
drop _X _Y _ID
save "G:\Mi unidad\Malena\FCE\Maestria\Tesis-v2\bases\base-precios\eess_no_coord_matched_2020_2022", replace 
restore 





*intento matcher por cuit: 
/* NO HACER ESTO. HAY VARIAS EESS CON EL MISMO CUIT Y DISTINTO NRO DE INSCRIPCION.
EJ. LE TERMINO PEGANDO LAS COORDENADAS A UNA AXION QUE SON DE UNA YPF.  
LO QUE IMPORTA ES QUE TIENEN DISTINTO NRO_INSCRIPCION.    */


/* use "G:\Mi unidad\Malena\FCE\Maestria\Tesis-v2\bases\base-precios\eess_no_coord_matched_2020_2022" , clear 

merge m:m cuit using "$cd\bases\base-coordenadas\coordenadas-2022"
 */
/* 
    Result                           # of obs.
    -----------------------------------------
    not matched                        36,566
        from master                    32,824  (_merge==1)
        from using                      3,742  (_merge==2)

    matched                            23,898  (_merge==3)
    ----------------------------------------- 
	*Ahora son 32,824 las que no matchean*/


*rename _merge merge2

*me guardo las matcheadas: 
/* preserve 
keep if merge2==3 
save "G:\Mi unidad\Malena\FCE\Maestria\Tesis-v2\bases\base-precios\precios_eess_con_coordenadas_2020_2022_v2" , replace
restore 
 */

*me quedo con las que no matchearon: 
/* preserve 
keep if merge2 == 1
drop _X _Y _ID
save "G:\Mi unidad\Malena\FCE\Maestria\Tesis-v2\bases\base-precios\eess_no_coord_matched_2020_2022_v2" , replace 
restore  */

*intento matchear con la base de coordenadas viejas de coordenadas de fran - con nro_inscripcion-: 
use "G:\Mi unidad\Malena\FCE\Maestria\Tesis-v2\bases\base-precios\eess_no_coord_matched_2020_2022" , clear 
 merge m:m nro_inscripcion using  "G:\Mi unidad\Malena\FCE\Maestria\Tesis\bases\base-coordenadas\coordenadas-nuevas.dta"


rename _merge merge3 

*resultado:
  /*  Result                           # of obs.
    -----------------------------------------
    not matched                        44,194
        from master                    39,835  (_merge==1)
        from using                      4,359  (_merge==2)

    matched                            16,832  (_merge==3)
 */
 
 
*me guardo las matcheadas: 
preserve 
keep if merge3==3 
save "G:\Mi unidad\Malena\FCE\Maestria\Tesis-v2\bases\base-precios\precios_eess_con_coordenadas_2020_2022_v2" , replace
restore 

*me quedo con las que no matchearon: -SI QUERES VOLVER INTENTAR MATCHEAR CON ALGO ES DESDE ESTA BASE- 
preserve 
keep if merge3 == 1
drop _X _Y _ID
save "G:\Mi unidad\Malena\FCE\Maestria\Tesis-v2\bases\base-precios\eess_no_coord_matched_2020_2022_v2" , replace 
restore


*Appendeo todas las EESS con localizacion matcheada 2020-2022:
use  "G:\Mi unidad\Malena\FCE\Maestria\Tesis-v2\bases\base-precios\precios_eess_con_coordenadas_2020_2022" , clear 

append using "G:\Mi unidad\Malena\FCE\Maestria\Tesis-v2\bases\base-precios\precios_eess_con_coordenadas_2020_2022_v2"


drop rec_header merge1  merge3 _CX _CY 


*Base final con coordenadas - trabajar desde esta base- 
save "G:\Mi unidad\Malena\FCE\Maestria\Tesis-v2\bases\base-precios\p_eess_coordenadas_2020_2022.dta", replace 


