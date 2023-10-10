*------------------------------------------------------*
*TABLAS PARA JMP Y THOMAS: 24-JULIO-2023
*-CANTIDAD PROMEDIO Y TOTAL DE VENTAS POR PROVINCIA
*------------------------------------------------------*


*TABLA CANTIDAD PROMEDIO Y TOTAL POR PROVINCIA 


************************
*nafta comun 
************************
use "bases\base-precios\p-pulidas-distancias\nafta_2_2016_2022_v2.dta", clear 


*seteo panel 
tsset id time 

*limpio un poco la bases
keep if volumen_pub!=. 
drop if volumen_pub==46823

*voy a sacar a todos los volumenes menores a 1, pareciera ser un error de carga en la base
drop if volumen_pub <=1 

collect table  provincia year, stat(total volumen_pub) stat(mean volumen_pub) name(naftasuper)
collect export "salidas\descriptives\combustibles-arg.xls", name(naftasuper) cell(a1) sheet(nafta-comun) modify 



************************
*nafta premium 
************************
use "bases\base-precios\p-pulidas-distancias\nafta_3_2016_2022_v2.dta", clear 


*seteo panel 
tsset id time 

*limpio un poco la bases
keep if volumen_pub!=. 

*voy a sacar a todos los volumenes menores a 1, pareciera ser un error de carga en la base
drop if volumen_pub <=1 
drop if p_surtidor==0


collect table  provincia year, stat(total volumen_pub) stat(mean volumen_pub) name(naftapremium)
collect export "salidas\descriptives\combustibles-arg.xls", name(naftapremium) cell(a1) sheet(nafta-premium) modify 




************************
*gasoil comun (grado 2) 
************************

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

collect table  provincia year, stat(total volumen_pub) stat(mean volumen_pub) name(gasoilcomun)
collect export "salidas\descriptives\combustibles-arg.xls", name(gasoilcomun) cell(a1) sheet(gasoil-comun(grado2)) modify 



