# ------------------------- PROYECTO FINAL ---------------------------------- #
# --------------------------------------------------------------------------- #
# ----------- SOFIA BOJREIBE , NAHUEL COSTA , FACUNDO RODRÍGUEZ ------------- #
# --------------------------------------------------------------------------- # 

# ------------------------------ EJERCICIO 1 ---------------------------------# 

#-----------------> 1.1 ANÁLISIS EXPLORATORIO 

# SCATTER PLOTS
par(mfrow = c(2, 2)) 
plot(PROYECTO$IngresosCliente, PROYECTO$MontoPrestamo, col = 'red', main = 'MontoPrestamo vs Ingresos de los clientes')
plot(PROYECTO$CreditoDisponible, PROYECTO$MontoPrestamo, col = 'red', main = 'MontoPrestamo vs Crédito disponible')
plot(PROYECTO$Edad, PROYECTO$MontoPrestamo, col = 'red', main = 'MontoPrestamo vs Edad')
plot(PROYECTO$NumeroDependientes, PROYECTO$MontoPrestamo, col = 'red', main = 'MontoPrestamo vs Nro de dependeintes')

# Monto Prestamo vs Ingresos: SE OBSERVA UNA CORELACIÓN LINEAL POSITIVA ENTRE EL 
#                             MONTO DEL PRÉSTAMO Y EL INGRESO DE LOS CLIENTES 
#
# Monto Prestamo vs Crédito: SE OBSERVA UNA CORELACIÓN LINEAL NEGATIVA ENTRE EL 
#                            MONTO DEL PRÉSTAMO Y EL CRÉDITO DISPONIBLE 
#
# Monto Prestamo vs Edad : NO SE OBSERVA NINGUNA CORRELACIÓN LINEAL ENTRE EL 
#                          MONTO DEL PRÉSTAMO Y LA EDAD
#
# Monto Prestamo vs Número de Dependientes : NO SE OBSERVA NINGUNA CORRELACIÓN 
#                                            LINEAL ENTRE EL MONTO DEL PRÉSTAMO 
#                                            Y EL NUMERO DE DEPENDIENTES

# BOX PLOTS 
par(mfrow = c(2, 3)) 
boxplot(PROYECTO$MontoPrestamo ~ PROYECTO$Educacion, col = 'red', main = 'Monto Préstamo vs Educación')
boxplot(PROYECTO$MontoPrestamo ~ PROYECTO$EstadoCivil, col = 'red', main = 'Monto Préstamo vs Estado Civil')
boxplot(PROYECTO$MontoPrestamo ~ PROYECTO$Default, col = 'red', main = 'Monto Préstamo vs Default')
boxplot(PROYECTO$MontoPrestamo ~ PROYECTO$Genero, col = 'red', main = "Monto Prestámo vs Género") 
boxplot(PROYECTO$MontoPrestamo ~ PROYECTO$RegionResidencia, col = 'red', main = "Monto Prestámo vs Región de Residencia") 
boxplot(PROYECTO$MontoPrestamo ~ PROYECTO$SectorEmpleo, col = 'red', main = "Monto Prestámo vs Sector de Empleo") 

# Monto Préstamo vs Educación : SE OBSERVA UNA RELACIÓN LINEAL POSITIVA ENTRE 
#                               SECTORES DE EDUCACIÓN SUPERIORES Y EL MONTO DEL 
#                               PRÉSTAMO
#
# Monto Préstamo vs Estado Civil : SE OBSERVA UNA LIGERA RELACIÓN POSITIVA ENTRE 
#                                  ESTAR CASADO Y EL MONTO DEL PRÉSTAMO 
# 
# Monto Préstamo vs Default : SE OBSERVA UNA RELACIÓN LINEAL NEGATIVA ENTRE HABER 
#                             ENTRADO EN DEFAULT CON EL MONTO DEL PRÉSTAMO
#
# Monto Préstamo vs Género : NO SE OBSERVA UNA RELACIÓN LINEAL ENTRE EL GÉNERO
#                            Y EL MONTO DEL PRÉSTAMO
#
# Monto Préstamo vs Región de Residencia : NO SE OBSERVA UNA RELACIÓN LINEAL 
#                                          ENTRE LA REGIÓN DE RESIDENCIA Y EL 
#                                          MONTO DEL PRÉSTAMO
#
# Monto Préstamo vs Sector de Empleo : NO SE OBSERVA UNA RELACIÓN LINEAL ENTRE
#                                      EL SECTOR DEL EMPLEO Y EL MONTO DEL
#                                      PRÉSTAMO

# CORRELACIONES 
round(cor(PROYECTO[, c(2,3,7,11,4)]), 2) 

# TABLA DE FRECUENCIA ABSOLUTA 
frec_abs=table(PROYECTO$Default)
frec_abs

# TABLA DE FRECUENCIA RELATIVA 
prop.table(frec_abs)

# CLIENTES QUE NO ENTRARON EN DEFAULT: 27937
# CLIENTES QUE SI ENTRARON EN DEFAULT: 6273 

# PORCENTAJE DE CLIENTES QUE NO ENTRARON EN DEFAULT: 81.66 %
# PORCENTAJE DE CLIENTES QUE SI ENTRARON EN DEFAULT: 18.33 %   


# PRUEBA DE HIPÓTESIS 

# PASO 1 | PLANTEAR HIPÓTESIS NULA E HIPÓTESIS ALTERNATIVA 

# H0 = EL MONTO PROMEDIO DE UN PRÉSTAMO NO DIFIERE SIGNIFICATIVAMENTE DE 55000 USD
# HA = EL MONTO PROMEDIO DE UN PRÉSTAMO DIFIERE SIGNIFICATIVAMENTE DE 55000 USD 

# H0 :  µ(PRESTAMO) = 55000
# H1 :  µ(PRESTAMO) ≠ 55000

# PASO 2 | DEFINIR ESTADÍSTICO DE PRUEBA 
t.test(PROYECTO$MontoPrestamo,mu=55000,conf.level=0.99) 

# t = 80.108 | La media muestral del monto de un préstamo se encuentra a 80.108
#              sigmas por encima de la media hipotética. Es decir, la media 
#              muestral es bastante mayor que µ = 55000 


# PASO 3 | P-VALUE

# P-VALUE < 2.2e-16 | Hay muy baja probabilidad de que la hipótesis nula de un 
#                     préstamo promedio de 55000 USD sea válida. Ya que 
#                     p-value < alfa (1%), hay evidencia suficiente para rechazar 
#                     H0. 


# PASO 4 | DECISIÓN 

# DECISIÓN : BÁSANDONOS EN UNA MUESTRA n = 34210 PODEMOS CONCLUIR CON UN NIVEL 
#            DE SIGNIFICANCIA DE DEL 1% (O DE MANERA EQUIVALENTE, CON UNA CONFIANZA 
#            DEL 99 %), QUE EL MONTO PROMEDIO DE UN PRESTAMO DIFIERE SIGNIFICATIVAAMENTE 
#            DE 55000 USD. 


# SEGUNDA PRUEBA DE HIPÓTESIS 

# PASO 1 | PLANTEAR HIPÓTESIS NULA E HIPÓTESIS ALTERNATIVA 

# H0 = LA PROPORCIÓN DE CLIENTES QUE INGRESAN EN DEFAULT NO DIFIERE DEL 15 %
# HA = LA PROPORCIÓN DE CLIENTES QUE INGRESAN EN DEFAULT DIFIERE DEL 15 %

# H0 :  µ(DEFAULT) = 15 %
# H1 :  µ(DEFAULT) ≠ 15 % 

# PARA SABER EL NÚMERO DE CLIENTES EQUIVALENTE AL 15 % , REALIZAMOS ESTA OPERACIÓN 

34210*0.15
# 5132 

# CREAMOS UNA VARIABLE PARA QUE EN DEFAULT TODOS LOS SI = 1 Y LOS NO = 0
PROYECTO$Default_num <-ifelse(PROYECTO$Default == "Si",1,0) 


# PASO 2 | DEFINIR ESTADÍSTICO DE PRUEBA 
t.test(PROYECTO$Default_num,mu=0.15,conf.level=0.99) 

# t = -2452827 | La media muestral del clientes en default se encuentra a 15.948
#                sigmas por encima de la media hipotética. Es decir, la media 
#                muestral es bastante mayor que µ = 15 % 


# PASO 3 | P-VALUE

# P-VALUE < 2.2e-16 | Hay muy baja probabilidad de que la hipótesis nula de que 
#                     el porcentaje de clientes que entren en default =  15%
#                     sea válida. Ya que p-value < alfa (1%), hay evidencia 
#                     suficiente para rechazar H0. 


# PASO 4 | DECISIÓN 

# DECISIÓN : BÁSANDONOS EN UNA MUESTRA n = 34210 PODEMOS CONCLUIR CON UN NIVEL 
#            DE SIGNIFICANCIA DE DEL 1% (O DE MANERA EQUIVALENTE, CON UNA CONFIANZA 
#            DEL 99 %), QUE EL PORCENTAJE DE CLIENTES QUE ENTRAN EN DEFAULT 
#            DIFIERE SIGNIFICATIVAAMENTE DEL 15 %.  






# ------------------------------ EJERCICIO 4 ---------------------------------# 

install.packages("tree",dependencies = TRUE)
install.packages("rpart",dependencies = TRUE)
install.packages("rio",dependencies = TRUE )
install.packages("rattle",dependencies = TRUE )
library(tree)
library(rio) 
library(rpart)
library(rattle)


# ANÁLISIS EXPLORATORIO 

addmargins(prop.table(table(PROYECTO$Educacion, PROYECTO$Default), 1), 2)*100
addmargins(prop.table(table(PROYECTO$EstadoCivil, PROYECTO$Default), 1), 2)*100 
addmargins(prop.table(table(PROYECTO$Genero, PROYECTO$Default), 1), 2)*100
addmargins(prop.table(table(PROYECTO$SectorEmpleo, PROYECTO$Default), 1), 2)*100
addmargins(prop.table(table(PROYECTO$RegionResidencia, PROYECTO$Default), 1), 2)*100



par(mfrow = c(2, 2)) 
boxplot(PROYECTO$IngresosCliente ~ PROYECTO$Default, col = 'red', main = 'Ingresos vs Default')
boxplot(PROYECTO$Edad ~ PROYECTO$Default, col = 'red', main = 'Edad vs Default')
boxplot(PROYECTO$CreditoDisponible ~ PROYECTO$Default, col = 'red', main = 'Crédito Disponible vs Default')
boxplot(PROYECTO$NumeroDependientes ~ PROYECTO$Default, col = 'red', main = 'Numero de Dependientes vs Default')

# INGRESOS, CREDITO, NUMERO DE DEPENDIENTES, MONTO DE PRESTAMO, 
# EDUCACION, ESTADO CIVIL & GENERO MEJORES PREDICTORES 

# 2.1 MODELO DE RANDOM FOREST 
set.seed(50404258) 
train <- sample(nrow(PROYECTO), nrow(PROYECTO)*0.6) 
test <- (-train)

# ARBOL CON LA BASE TRAINING
par(mfrow = c(1, 1))
Arbol1 = rpart(Default ~ IngresosCliente + MontoPrestamo + CreditoDisponible + NumeroDependientes + Educacion + Genero + EstadoCivil,
               PROYECTO[train,], method = 'class')
Arbol1
fancyRpartPlot(Arbol1)


# 2.2 PODAMOS EL ARBOL 
plotcp(Arbol1) 

# 2.3 INTERPRETACIÓN
# VEMOS QUE NO ES NECESARIO PODAR EL ARBOL, YA QUE EL NUMERO DE NODOS DE AQUEL MODELO 
# QUE DESCIENDE PRIMERO POR DEBAJO DEL MODELO IDEAL ES 5. ES DECIR, EL MODELO CON EL MENOR 
# ERROR TIENE LA MISMA CANTIDAD DE NODOS QUE NUESTRO MODELO INICIAL.


# 2.4 
asRules(Arbol1)

# RULE NUMBER 3 :
# SI EL MONTO DEL PRESTAMO ES MENOR A 3.565e+04, EL MODELO PREDICE "SI" ENTRAR 
# EN DEFAULT,CON UNA PROBABILIDAD DE 1. 2169 PERSONAS EN MI BASE DE TRAIN ENTRAN 
# EN ESTA CATEGORÍA.

# RULE NUMBER 5 :
# SI EL MONTO DEL PRESTAMO ES MAYOR O IGUAL A 3.565e+04 Y LOS INGRESOS DEL CLEINTE SON 
# MENORES A 1.794e+04, EL MODELO PREDICE "SI" ENTRAR EN DEFAULT CON UNA PROBABILIDAD DE 
# 1. 259 PERSONAS EN MI BASE DE TRAIN ENTRAN DENTRO DE ESTA CATEGORÍA 

# RULE NUMBER 19 :
# SI EL MONTO DEL PRESTAMO ES MAYOR O IGUAL A 3.565e+04, LOS INGRESOS DEL CLIENTE SON 
# MAYORES O IGUALES A 1.794e+04, SI EL CREDITO DISPONIBLE ES MAYOR O IGUAL A 
# 8.905e+04, Y LUEGO SI EL INGRESO ES MENOR A 2.591e+04, EL MODELO PREDICE "SI" 
# ENTRAR EN DEFAULT, CON UNA PROBABILIDAD DE 0.70. 238 PERSONAS EN MI BASE DE 
# TRAIN ENTRAN DENTRO DE ESTA CATEGORÍA. 

# RULE NUMBER 18 : 
# SI EL MONTO DEL PRESTAMO ES MAYOR O IGUAL A 3.565e+04, LOS INGRESOS DEL CLIENTE SON 
# MAYORES O IGUALES A 1.794e+04, SI EL CREDITO DISPONIBLE ES MAYOR O IGUAL A 
# 8.905e+04, Y LUEGO SI EL INGRESO ES MAYOR O IGUAL  A 2.591e+04, EL MODELO PREDICE "NO" 
# ENTRAR EN DEFAULT, CON UNA PROBABILIDAD DE FALLAR DE 0.15. 3949 PERSONAS EN MI BASE 
# DE TRAIN ENTRAN DENTRO DE ESTA CATEGORÍA.


# RULE NUMBER 8 :
# SI EL MONTO DEL PRESTAMO ES MAYOR O IGUAL A 3.565e+04, LOS INGRESOS DEL CLIENTE SON 
# MAYORES O IGUALES A 1.794e+04 Y SI EL CREDITO DISPONIBLE ES MENOR A 8.905e+04, 
# EL MODELO PREDICE "NO" ENTRAR EN DEFAULT, CON UNA PROBABILIDAD DE FALLAR DE 0.04. 
# 13911 PERSONAS DE MI BASE DE TRAIN ENTRAN DENTRO DE ESTA CATEGORÍA.   


# PREDICCIONES
PROYECTO$prediccion_default = predict(Arbol1, PROYECTO)

# MATRIZ DE CONFUSIÓN EN TRAIN
addmargins(table(PROYECTO$Default[train],PROYECTO$prediccion_default[train] > 0.5))


# MATRIZ DE CONFUSIÓN EN TEST 
addmargins(table(PROYECTO$Default[test], PROYECTO$prediccion_default[test, "Si"] > 0.5))

# ---------> MÉTRICAS DE BONDAD DE LAS PREDICCIONES:  


# BASE TEST 

# PRECISIÓN 
(1768+11108)/13684

# 0.94

# TASA DE ERROR 
(53+755)/13684

# 0.059

# SENSIBILIDAD 
1768/2523

# 0.70

# ESPECIFICIDAD 
11108/11161

# 0.995 


# BASE TRAIN 

# PRECISIÓN 
(1156+72)/20526

# 0.059 


# TASA DE ERROR 
(16704+2594)/20526

# 0.94 

# SENSIBILIDAD 
1156/3750

# 0.308 


# ESPECIFICIDAD 
72/16776

# 0.0042































































































