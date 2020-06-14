* name: RRD.do
* by:Juan Urueña
* section: regression discontinuity

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


ssc install cmogram

qui cmogram male bac1, cut(0.08) scatter line(0.08) qfitci lfit title(PanelA)
graph save panela.gph, replace 
qui cmogram white bac1, cut(0.08) scatter line(0.08) qfitci lfit title(PanelB)
graph save panelb.gph, replace
qui cmogram aged bac1, cut(0.08) scatter line(0.08) qfitci lfit title(PanelC)
graph save panelc.gph, replace 
qui cmogram acc bac1, cut(0.08) scatter line(0.08) qfitci lfit title(PanelD)
graph save paneld.gph, replace 
graph combine panela.gph panelb.gph panelc.gph paneld.gph


