use "/Users/seba/Downloads/precios-1.dta"

*1a)
keep Fecha SPIPSA AESGENER ITAUCORP CENCOSUD VAPORES
foreach x of varlist AESGENER ITAUCORP CENCOSUD VAPORES {
	rename `x' p`x'
}
merge 1:1 Fecha using "/Users/seba/Downloads/numacciones-2.dta"
foreach x of varlist AESGENER ITAUCORP CENCOSUD VAPORES {
	rename `x' n`x'
}
keep Fecha SPIPSA pAESGENER pITAUCORP pCENCOSUD pVAPORES nAESGENER nITAUCORP nCENCOSUD nVAPORES
describe Fecha
drop if SPIPSA == .
gen months = mofd(Fecha)
bysort months (Fecha): keep if _n==_N
keep if months >=722
drop months
foreach x of varlist SPIPSA pAESGENER pITAUCORP pCENCOSUD pVAPORES {
	gen retorno`x'= (`x'/`x'[_n-1])-1
} 
foreach x of varlist retornoSPIPSA retornopAESGENER retornopITAUCORP retornopCENCOSUD retornopVAPORES {
	su `x'
	di (r(mean)-0.001)/r(sd)
}
 
*1b)
gen Aew = (retornopAESGENER + retornopITAUCORP + retornopCENCOSUD + retornopVAPORES)/4
gen Bew = (retornopCENCOSUD + retornopAESGENER)/2
gen Cew = (retornopCENCOSUD + retornopITAUCORP)/2
gen Dew = (retornopCENCOSUD + retornopVAPORES)/2
foreach x of varlist Aew Bew Cew Dew {
	su `x'
	di (r(mean)-0.001)/r(sd)
}
 corr retornopAESGENER retornopCENCOSUD retornopITAUCORP retornopVAPORES
 
 *1c)
gen Avw = (retornopAESGENER*(pAESGENER*nAESGENER)/(pAESGENER*nAESGENER + pCENCOSUD*nCENCOSUD + pITAUCORP*nITAUCORP + pVAPORES*nVAPORES) + retornopCENCOSUD*(pCENCOSUD*nCENCOSUD)/(pAESGENER*nAESGENER + pCENCOSUD*nCENCOSUD + pITAUCORP*nITAUCORP + pVAPORES*nVAPORES) + retornopITAUCORP*(pITAUCORP*nITAUCORP)/(pAESGENER*nAESGENER + pCENCOSUD*nCENCOSUD + pITAUCORP*nITAUCORP + pVAPORES*nVAPORES) + retornopVAPORES*(pVAPORES*nVAPORES)/(pAESGENER*nAESGENER + pCENCOSUD*nCENCOSUD + pITAUCORP*nITAUCORP + pVAPORES*nVAPORES))
gen Bvw = (retornopCENCOSUD * (pCENCOSUD*nCENCOSUD)/(pCENCOSUD*nCENCOSUD + pAESGENER*nAESGENER) + retornopAESGENER*(pAESGENER*nAESGENER)/(pCENCOSUD*nCENCOSUD + pAESGENER*nAESGENER))
gen Cvw = (retornopCENCOSUD * (pCENCOSUD*nCENCOSUD)/(pCENCOSUD*nCENCOSUD + pITAUCORP*nITAUCORP) + retornopITAUCORP*(pITAUCORP*nITAUCORP)/(pCENCOSUD*nCENCOSUD + pITAUCORP*nITAUCORP))
gen Dvw = (retornopCENCOSUD * (pCENCOSUD*nCENCOSUD)/(pCENCOSUD*nCENCOSUD + pVAPORES*nVAPORES) + retornopVAPORES*(pVAPORES*nVAPORES)/(pCENCOSUD*nCENCOSUD + pVAPORES*nVAPORES))
foreach x of varlist Avw Bvw Cvw Dvw {
	su `x'
	di (r(mean)-0.001)/r(sd)
}

*2
frame create pregunta2
frame change pregunta2
use "/Users/seba/Downloads/precios-1.dta"
keep Fecha SPIPSA
gen mes=mofd(Fecha)
gen retornoSPIPSA = (SPIPSA/SPIPSA[_n-1])-1
keep if mes >=684
egen desviacion_estandar_mensual_IPSA = sd(retornoSPIPSA), by(mes)
format Fecha %tdNN/YY
drop SPIPSA
duplicates drop mes desviacion_estandar_mensual, force
drop mes
twoway line desviacion_estandar_mensual_IPSA Fecha, title("Volatilidad Mensual de los Retornos del IPSA") xtitle("Mes / Año") ytitle("Desviación Estándar")

*Pregunta 3
*3.1
frame create pregunta3
frame change pregunta3
use "/Users/seba/Downloads/precios-1.dta"
drop if SPIPSA==.
keep Fecha SECURITY FALABELLA BSANTANDER CCU SQMB ENTEL VAPORES CENCOSUD
gen months = mofd(Fecha)
bysort months (Fecha): keep if _n==_N
drop months
foreach x of varlist SECURITY FALABELLA BSANTANDER CCU SQMB ENTEL VAPORES CENCOSUD {
	gen retorno`x' = (`x'/`x'[_n-1])-1
}
ssc install mvport
efrontier retornoBSANTANDER retornoCCU retornoFALABELLA retornoSECURITY retornoSQMB
ovport retornoBSANTANDER retornoCCU retornoFALABELLA retornoSECURITY retornoSQMB, rfrate(0.001) nport(100)
cmline retornoBSANTANDER retornoCCU retornoFALABELLA retornoSECURITY retornoSQMB, rfrate(0.001) nport(100)
di (0.05073794-0.001)/0.13951935
foreach x of varlist retornoBSANTANDER retornoCCU retornoFALABELLA retornoSECURITY retornoSQMB {
	sum `x'
	scalar promedio_`x'=r(mean)
	scalar de_`x'=r(sd)
}
twoway function y=0.001 + (promedio_retornoBSANTANDER-0.001)*x/de_retornoBSANTANDER ||function y=0.001 + (promedio_retornoCCU-0.001)*x/de_retornoCCU || function y=0.001 + (promedio_retornoFALABELLA-0.001)*x/de_retornoFALABELLA || function y=0.001 + (promedio_retornoSECURITY-0.001)*x/de_retornoSECURITY || function y=0.001 + (promedio_retornoSQMB-0.001)*x/de_retornoSQMB || function y=0.001 + (0.05073794-0.001)*x/0.13951935 , legend(label(1 "Acción BSANTANDER") label(2 "Acción CCU") label(3 "Acción FALABELLA") label(4 "Acción SECURITY") label(5 "Acción SQMB") label(6 "Portafolio Tangente")) xtitle("Volatilidad") ytitle("Retorno Esperado") title("Riesgo-Retorno de Portafolios (rf=0.1%)")

*3.1
*llegamos a que [E(Ri)-Rf]/[corr(i,p)*sd(i)] > SR para aumentar la cantidad del activo en el portafolio.
*El ratio de Sharpe del portafolio es 0.35649492
gen portafolio_tangente= 2.556457*retornoBSANTANDER - 0.53470406*retornoCCU -1.0457563*retornoFALABELLA -1.3448372*retornoSECURITY + 1.3688405*retornoSQMB
foreach x of varlist retornoCENCOSUD retornoVAPORES retornoENTEL {
	sum `x'
	scalar promedio_`x'=r(mean)
	scalar de_`x' = r(sd)
	corr portafolio_tangente `x'
	return list
	scalar rho_`x'= r(rho)
	di (promedio_`x'-0.001)/(de_`x'*rho_`x')
}
sum portafolio_tangente
scalar promedio_pt = r(mean)
scalar de_pt = r(sd)
foreach x of varlist retornoCENCOSUD retornoVAPORES retornoENTEL retornoBSANTANDER retornoCCU retornoFALABELLA retornoSECURITY retornoSQMB {
	corr portafolio_tangente `x'
	return list
	scalar rho_`x' = r(rho)
	scalar beta_`x'= rho_`x' * de_`x' / de_pt
	di=0.001 + beta_`x'*(promedio_pt-0.001)
	di beta_`x'
}

foreach x of varlist retornoCENCOSUD retornoVAPORES retornoENTEL retornoBSANTANDER retornoCCU retornoFALABELLA retornoSECURITY retornoSQMB {
	sum `x'
}

twoway function y=0.001 + x*(promedio_pt-0.001), range(-0.1 0.5) || scatteri .0016542 -.00501448 || scatteri .0231648 .09606404 || scatteri -.0035291 -.05504601 || scatteri .0093915 .16960434 || scatteri .0040919 .06233177 || scatteri -.0033334 -.08701242 || scatteri .0015386  .0108532 || scatteri .0198185 .38232713, legend(label(1 "E(Ri) = Rf + βi(E(RT ) − Rf )") label(2 "CENCOSUD") label(3 "VAPORES") label(4 "ENTEL") label(5  "BSANTANDER") label(6 "CCU") label(7 "FALABELLA") label(8 "SECURITY") label(9 "SQMB")) title("Security Market Line") xtitle("Beta") ytitle("Retorno Esperado")

*d)
ovport retornoBSANTANDER retornoCCU retornoFALABELLA retornoSECURITY retornoSQMB retornoCENCOSUD, rfrate(0.001) nport(100)
di (.0506458-0.001)/.13911613
ovport retornoBSANTANDER retornoCCU retornoFALABELLA retornoSECURITY retornoSQMB retornoENTEL, rfrate(0.001) nport(100)
di (.05204469-0.001)/.14285845
ovport retornoBSANTANDER retornoCCU retornoFALABELLA retornoSECURITY retornoSQMB retornoVAPORES, rfrate(0.001) nport(100)
di (.05693057-0.001)/.13697553
