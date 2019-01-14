*************************************************************************

*  Muestreo probabilístico, bietápico, estratificado y por conglomerados.


*************************************************************************


*0.1 Definir la ruta donde está la base "marco_muestral.dta" 

cd "C:\Users\jmartinez\Desktop\BUAP-master\BUAP-master\Datos"

*0.2 Cargar la base de datos
use  "marco_muestral.dta", replace
describe

*1. PROBABILIDADES DE INSERCIÓN. Para tener una muestra probabilística, se debe de conocer
*   la probabilidad de selección de todas las unidades muestrales UPM

sort est_d upm
contract est_d upm, freq(viviendas)
sort est_d
by est_d: generate double pi1=2/_N
label var pi1 "Probabilidad de inserción de las UPM (Etapa 1)"
label var viviendas "Número de viviendas en cada UPM"
describe


*2. PRIMERA ETAPA DE SELECCIÓN. Se eligen aleatoriamente 2 UPM de cada estrato.

levelsof est_d, local(TRACTlev)
foreach i of local TRACTlev{
quietly sample 2 if est_d==`i', count
}
sort est_d upm
save upm_seleccionadas, replace

*3. SEGUNDA ETAPA DE SELECCIÓN. Se eligen aleatoriamente 2 viviendas en cada UPM.

use  "marco_muestral.dta", replace
sort est_d upm
merge m:1 est_d upm using upm_seleccionadas
keep if _merge==3
drop _merge
sort upm
by upm: generate double pi2=2/_N
label var pi2 "Probabilidad de inserción de las viviendas (Etapa 2)"
levelsof upm, local(TRACTlev)
foreach i of local TRACTlev{
quietly sample 2 if upm==`i', count
}
sort est_d upm vivienda

*4. Cálculo de los factores de expansión

gen double fac=1/(pi1*pi2)
export delimited using "resultaods.csv", replace
