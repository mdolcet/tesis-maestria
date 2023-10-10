***mini base para jorge puig 
local cd "G:\Mi unidad\Malena\FCE\Maestria\Tesis-v2"
cd "`cd'"

use "bases\base-precios\p-pulidas-distancias\nafta_2_2016_2022_v2.dta", clear 

drop fecha_de_baja no_novimientos _CX _CY rec_header merge_coord_nuevas oficial_venta oficial_compra _merge para_dropear extranjeros volumen_ext p_surtidor_ext m_ext0519 transporte volumen_transp p_surtidor_transp p_aux m_transp0519 m_agro0519 otras_eess volumen_oeess p_surtidor_oeess m_eess0519 otros_sectores p_surtidor_osectores m_ext m_transp m_agro m_eess volumen_osectores m_sect m_years lvol_pub lvol_ext lvol_transp lvol_agro lvol_oeess lvol_osectores psurt_usd_pub psurt_usd_ext psurt_usd_transp psurt_usd_agro psurt_usd_oeess psurt_usd_osectores m_pasos blue_venta blue_compra brecha brechap upper m_tc dist_group m_nafta m_sect0519


drop year mes
label var time "Time"

drop if time<745
keep if provincia=="MISIONES" | provincia=="FORMOSA"
drop comprador nro_inscripcion publico 
drop _ID ene_id_time_aux
drop combustible
drop agro volumen_agro p_surtidor_agro
drop tipo_negocio

label var operador "Operador"
label var bandera "Bandera"
label var cuit "Cuit"
label var direccion "Direccion"
label var localidad "Localidad"
label var provincia "Provincia"
label var producto "Combustible"
label var p_no_tax "P antes de impuestos"
label var p_tax "P despues de impuestos"
label var volumen_pub "Q (m3 vendidos)"
label var p_surtidor_pub "P en boca de expendio"
label var exentos "Exentos"

drop p_tax_usd
drop codigo_unico_de_coordenadas
rename canal_de_comercializacion comprador
label var comprador "Comprador"
drop q_aux
label var dist_minima "dist minima lineal"
drop info_paso info_paso_ruta info_paso_minutos


label var dist_minima "Dist minima lineal"
label var nombre_paso "Nombre paso (d lineal)"
drop provincia
label var prov_arg_frontera "Provincia"
label var dist_minima_minutos "Dist minima minutos"
label var dist_minima "Dist minima lineal"
label var dist_minima_ruta "Dist minima ruta"
label var nombre_paso_minutos "Nombre paso (d minutos)"
label var nombre_paso_ruta "Nombre paso (d ruta)"

label var frontera_pais "Pais fronterizo (d lineal)"
label var frontera_pais_minutos "Pais fronterizo (d minutos)"
label var frontera_pais_ruta "Pais fronterizo (d ruta)"

drop dist_minima_minutos nombre_paso frontera_pais dist_minima
drop frontera_pais_minutos nombre_paso_minutos frontera_arg_prov_minutos
drop frontera_arg_prov_ruta

rename prov_arg_frontera provincia 
label var provincia "Provincia"


keep if (id==4511 | id==595 | id==127 | id==138)

replace comprador="Al Publico" if comprador=="Al pÃºblico"
rename producto combustible 

replace combustible="Nafta (super) entre 92 y 95 Ron" if combustible=="Nafta (sÃºper) entre 92 y 95 Ron"



export excel using "bases\nafta-super-arg.xls", firstrow(var)


