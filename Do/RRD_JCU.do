* name: RRD.do
* by:Juan Urueña
* section: Assignment 4. Regression discontinuity

* Load the raw data into memory
use https://github.com/scunning1975/causal-inference-class/raw/master/hansen_dwi, clear


*Create a dummy equaling 1 if bac1>= 0.08 and 0 otherwise
generate bac = 0
replace bac = 1 if bac1>= 0.08

*Recreate Figure 1

histogram bac1 if bac1>= 0.06 & bac1<= 0.10,  frequency discrete  title("BAC Histogram") scheme(s2mono) lwidth(vvvthin) fcolor(gray) lcolor(gray) xline(.08) 
(start=0, width=.00099999) frequency normal 

*Re-center the running variable (bac1)
gen bac1_c = bac1 - 0.08

* McCrary density test
net install rddensity, from(https://sites.google.com/site/rdpackages/rddensity/stata) replace
net install lpdensity, from(https://sites.google.com/site/nppackages/lpdensity/stata) replace
rddensity bac1, c(0.08) plot all

* Table 2
eststo: quietly reg bac1 male if bac1<.08
eststo: quietly reg bac1 white if bac1<.08
eststo: quietly reg bac1 aged if bac1<.08
eststo: quietly reg bac1 acc if bac1<.08
esttab using exampled.rtf, replace label nogap onecell

eststo: quietly reg bac1 male if bac1>.08
eststo: quietly reg bac1 white if bac1>.08
eststo: quietly reg bac1 aged if bac1>.08
eststo: quietly reg bac1 acc if bac1>.08
esttab using examplef.rtf, replace label nogap onecell

* Recreate Figure 2
ssc install cmogram

qui cmogram male bac1 if bac1<.20, cut(0.08) scatter line(0.08) qfitci lfit title(PanelA)
graph save panela.gph, replace 
qui cmogram white bac1 if bac1<.20, cut(0.08) scatter line(0.08) qfitci lfit title(PanelB)
graph save panelb.gph, replace
qui cmogram aged bac1 if bac1<.20, cut(0.08) scatter line(0.08) qfitci lfit title(PanelC)
graph save panelc.gph, replace 
qui cmogram acc bac1 if bac1<.20, cut(0.08) scatter line(0.08) qfitci lfit title(PanelD)
graph save paneld.gph, replace 
graph combine panela.gph panelb.gph panelc.gph paneld.gph


* Table 3

ssc install rdrobust
eststo: rdrobust recidivism bac1 male, c(0.08)
eststo: rdrobust recidivism bac1 white, c(0.08)
eststo: rdrobust recidivism bac1 aged, c(0.08)
eststo: rdrobust recidivism bac1 acc, c(0.08)
esttab using exampleg.rtf

* Figure 3 linear fit
gen fitted=.

reg recidivism bac1 if bac1>=.03 & bac1<.08
predict xb_1 if bac1>=.03 & bac1<.08, xb 
replace fitted=xb_1 if bac1>=.03 & bac1<.08

reg recidivism bac1 if bac1<.15
predict xb_2 if bac1>=.08 & bac1<.15, xb 
replace fitted=xb_2 if bac1<.15
drop xb_*

collapse (mean)  recidivism fitted male white aged acc, by(bac1)

twoway (scatter fitted bac1 if bac1<=.15, lcolor(black) msize(0) xscale(range(.03 .20)) xlabel(.05(.05).20)  lcolor(black) connect(1)) (scatter fitted bac1 if bac1>.15 & bac1<=.20, lcolor(black) msize(0) xscale(range(.03 .20)) xlabel(.05(.05).20)  lcolor(black) connect(1)) (scatter recidivism bac1 if bac1<.15, xline(.151) mfcolor(none) scheme(s2mono)  msymbol(Oh) legend(label(1 "Fitted" ) label(4 "Recidivism") order(1 3)) xscale(range(.03 .20)) xlabel(.05(.05).20))


* Figure 3 quadratic fit

gen bac1q=bac1*bac1
gen fitted=.

reg recidivism bac1 bac1q if bac1>=.03 & bac1<.08
predict xb_1 if bac1>=.03 & bac1<.08, xb 
replace fitted=xb_1 if bac1>=.03 & bac1<.08

reg recidivism bac1 bac1q if bac1<.15
predict xb_2 if bac1>=.08 & bac1<.15, xb 
replace fitted=xb_2 if bac1<.15
drop xb_*

collapse (mean)  recidivism fitted male white aged acc, by(bac1)

twoway (scatter fitted bac1 if bac1>=.08 & bac1<=.15, lcolor(black) msize(0) xscale(range(.03 .20)) xlabel(.05(.05).20)  lcolor(black) connect(1)) (scatter fitted bac1 if bac1>.15 & bac1<=.20, lcolor(black) msize(0) xscale(range(.03 .20)) xlabel(.05(.05).20)  lcolor(black) connect(1)) (scatter recidivism bac1 if bac1<.15, xline(.151) mfcolor(none) scheme(s2mono)  msymbol(Oh) legend(label(1 "Fitted" ) label(4 "Recidivism") order(1 3)) xscale(range(.03 .20)) xlabel(.05(.05).20))




lpoly recidivism bac1 male, nograph kernel(triangle) bwidth(0.05)}
