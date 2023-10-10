*------------------------------------------------
* Dofile para correr el grafico del cuadro de la calidad de la data (P news vs P data) 
*------------------------------------------------
set autotabgraph on 
set graphics on

*Esta base de xlsx es una copia del archivo que está en Descriptives 
import excel using "raw-data\Calidad de la data\Data prices vs news.xlsx", firstrow sheet("para-stata") case(lower) clear 

*armo variable de tiempo con variables año-mes 
gen time=ym(year,mes)
format time %tm


egen clock = mlabvpos(price_data price_news)
replace date = "2020m8" in 8


*scatter y x 
/* twoway  (scatter price_data price_news, msize(medlarge) mlcolor(ebblue%90)  mlwidth(thick)        mfcolor(teal%90) msymbol(O) mlabel(date) mlabpos(6)  mlabsize(*.9)) ///
	      (line price_data price_data, lcolor(cranberry%70)) , ///
			 scheme(modern) legend(off) /// 
			 xlabel(#6, labsize(small) valuelabels nogrid format(%8.0g)) ylabel(#6, labsize(small) nogrid format(%8.0g)) ///
			 xtitle("Price (news)", size(medsmall)) ytitle("Price (data)", size(medsmall))
 */
		 
			 
twoway  (scatter price_data price_news if date=="2017m3", msize(medlarge) mlcolor(ebblue%90) mlwidth(thick) mfcolor(teal%90) msymbol(O) mlabel(date) mlabpos(6) mlabsize(*.9) mlabc(navy)) ///
(scatter price_data price_news if date=="2017m12", msize(medlarge) mlcolor(ebblue%90) mlwidth(thick) mfcolor(teal%90) msymbol(O) mlabel(date) mlabpos(3) mlabsize(*.9) mlabc(navy)) ///	
(scatter price_data price_news if date=="2018m1", msize(medlarge) mlcolor(ebblue%90) mlwidth(thick) mfcolor(teal%90) msymbol(O) mlabel(date) mlabpos(12) mlabsize(*.9) mlabc(navy)) ///
(scatter price_data price_news if date=="2018m8", msize(medlarge) mlcolor(ebblue%90) mlwidth(thick) mfcolor(teal%90) msymbol(O) mlabel(date) mlabpos(4) mlabsize(*.9) mlabc(navy)) ///
(scatter price_data price_news if date=="2018m11", msize(medlarge) mlcolor(ebblue%90) mlwidth(thick) mfcolor(teal%90) msymbol(O) mlabel(date) mlabpos(10) mlabsize(*.9) mlabc(navy)) ///
(scatter price_data price_news if date=="2019m2", msize(medlarge) mlcolor(ebblue%90) mlwidth(thick) mfcolor(teal%90) msymbol(O) mlabel(date) mlabpos(5) mlabsize(*.9) mlabc(navy)) ///
(scatter price_data price_news if date=="2019m9", msize(medlarge) mlcolor(ebblue%90) mlwidth(thick) mfcolor(teal%90) msymbol(O) mlabel(date) mlabpos(11) mlabsize(*.9) mlabc(navy)) ///
(scatter price_data price_news if date=="2020m8", msize(medlarge) mlcolor(ebblue%90) mlwidth(thick) mfcolor(teal%90) msymbol(O) mlabel(date) mlabpos(6) mlabsize(*.9) mlabc(navy)) ///
(scatter price_data price_news if date=="2020m11", msize(medlarge) mlcolor(ebblue%90) mlwidth(thick) mfcolor(teal%90) msymbol(O) mlabel(date) mlabpos(11) mlabsize(*.9) mlabc(navy)) ///
(scatter price_data price_news if date=="2020m12", msize(medlarge) mlcolor(ebblue%90) mlwidth(thick) mfcolor(teal%90) msymbol(O) mlabel(date) mlabpos(4) mlabsize(*.9) mlabc(navy)) ///
(scatter price_data price_news if date=="2021m2", msize(medlarge) mlcolor(ebblue%90) mlwidth(thick) mfcolor(teal%90) msymbol(O) mlabel(date) mlabpos(4) mlabsize(*.9) mlabc(navy)) ///
(scatter price_data price_news if date=="2021m5" , msize(medlarge) mlcolor(ebblue%90) mlwidth(thick) mfcolor(teal%90) msymbol(O) mlabel(date) mlabpos(11) mlabsize(*.9) mlabc(navy)) ///
(scatter price_data price_news if date=="2022m5" & province=="Santa Cruz", msize(medlarge) mlcolor(ebblue%90) mlwidth(thick) mfcolor(teal%90) msymbol(O) mlabel(date) mlabpos(4) mlabsize(*.9) mlabc(navy)) ///
(scatter price_data price_news if date=="2022m5" & & province=="La Rioja", msize(medlarge) mlcolor(ebblue%90) mlwidth(thick) mfcolor(teal%90) msymbol(O) mlabel(date) mlabpos(12) mlabsize(*.9) mlabc(navy)) ///
 (line price_data price_data, lcolor(cranberry%70)) , ///
scheme(modern) legend(off) /// 
xlabel(#6, labsize(small) valuelabels nogrid format(%8.0g)) ylabel(#6, labsize(small) nogrid format(%8.0g)) ///
xtitle("Price (news)", size(small)) ytitle("Price (data)", size(small))


*guardo en pdf para tesis
    graph export "salidas/archivos finales/data-quality.pdf", replace	








save "bases\calidad de la data\calidad-nafta-super.dta", replace 




