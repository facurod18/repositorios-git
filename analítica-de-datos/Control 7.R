# ---------------------- PRÁCTICO 7 ------------------------------------------# 
#---------------- FACUNDO RODRÍGUEZ BORCHE -----------------------------------#

#----------------------- EJERCICIO 1 -----------------------------------------#

#---------------> A) DIAGRAMA DE DISPERSIÓN 
plot(ecommerce$RRSS, ecommerce$Ventas, xlab = "Inversión en publicidad", 
     ylab = "Ventas (en miles de USD)", col="blue")

# Se observa una correlación lineal positiva entre la inversión en publicidad en 
# Redes Sociales y las ventas en miles de USD. 

#---------------> B) COEFICIENTE DE CORRELACIÓN LINEAL 
cor(ecommerce[-1]) 

# COEFICIENTE DE CORRELACIÓN LINEAL: 0.892 | Se observa una correlación lineal 
#                                            MUY FUERTE entre la inversión en 
#                                            publicidad en RRSS y las ventas en 
#                                            miles de USD. 

#--------------> C) MODELO DE REGRESIÓN LINEAL 
set.seed(2025)

# ENTRENAMOS AL MODELO CON EL 80 % DE LOS DATOS 
train=sample(nrow(ecommerce),nrow(ecommerce)*0.80) 

# EL RESTANTE 20% DE LOS DATOS LO USAMOS PARA TESTING 
test  =(-train)

# REALIZAMOS EL MODELO 
reg = lm(Ventas~RRSS, data= ecommerce, subset=train) 

reg 

# Ventas = 0.418 + 0.0023*(Inversión en USD en RSS)
# ß0 = 0.418 | ß1 = 0.0023 

#--------------> D)PRUEBA DE HIPÓTESIS PARA LA REGRESIÓN 

# PASO 1 | PLANTEAR HIPÓTESIS NULA E HIPÓTESIS ALTERNATIVA

# H0 = NO HAY ASOCIACIÓN LINEAL ENTRE LA INVERSIÓN EN RSS Y LAS VENTAS
# HA = HAY ASOCIACIÓN LINEAL ENTRE LA INVERSIÓN EN RSS Y LAS VENTAS

# H0 : ß1 = 0 
# H1 : ß1 ≠ 0  

# PASO 2 | DEFINIR ESTADÍSTICO DE PRUEBA 
summary(reg)

# EL ESTADÍSTICO DE PRUEBA ES t = 10.174 | EL COEFICIENTE ESTIMADO EN LA BASE DE 
# ENTRENAMIENTO ESTÁ A MÁS DE 10 DESVÍOS POR ENCIMA DEL VALOR HIPOTÉTICO 
# ß(INVERSIÓN) = 0  

# PASO 3 | P-VALUE 

# P-VALUE (ß1) =1.48e-10 < 0.01| SE RECHAZA H0 Y SE ACEPTA H1  
#
# CONCLUSIÓN = BASÁNDONOS EN LA MUESTRA DE ENTRENAMIENTO DE n = 28 MESES, 
#              PODEMOS CONCLUIR CON UN NIVEL DE SIGNIFICANCIA DEL 1% QUE HAY 
#              ASOCIACIÓN LINEAL  ENTRE LAS VARIABLES INVERSIÓN Y VENTAS 


#--------------> E) INTERPRETACIÓN DE PENDIENTE 

# ß1 = 0.00232 | EN PROMEDIO, POR CADA DÓLAR ADICIONAL QUE SE INVIERTE EN REDES 
#                SOCIALES, LAS VENTAS AUMENTAN 0.00232 USD. 


#--------------> F) CÁLCULO DE RCME Y R2 

# GENERAMOS UNA COLUMNA CON LAS PREDICCIONES DE VENTAS
ecommerce$ventas_estimadas = predict(reg, newdata=ecommerce) 

# PROCEDEMOS A CALCUALR EL RCME 
RCME.train = sqrt(mean((ecommerce$Ventas[train]-ecommerce$ventas_estimadas[train])^2))

# RCME en train = 1.41 USD | EL ERROR PROMEDIO DE PREDICCIÓN QUE COMETE EL 
#                            MODELO EN TRAIN ES DE 1.41 USD

# R2 = 0.799 | EL 79.9 % DE LA VARIABILIDAD EN LAS VENTAS ES EXPLICADA POR LAS 
#              INVERSIONES EN RRSS. 


RCME.test = sqrt( mean((ecommerce$Ventas[test]-ecommerce$ventas_estimadas[test])^2) )
RCME.test

# RCME en test = 1.15 USD | EL ERROR PROMEDIO DE PREDICCIÓN QUE COMETE EL 
#                           MODELO EN TEST ES DE 1.15 USD 


#--------------> H) PREDICCIÓN DE VENTAS CON 15000 USD DE INVERSIÓN 

datos_nuevos=data.frame(RRSS=(15000))   # Creo un data frame 
predict(reg, datos_nuevos) 

# LAS VENTAS PREDICHAS PARA UNA INVERSIÓN DE 15000 USD SON DE 35251 USD 

# ADVERTENCIA: EL RANGO DE DATOS DE ENTRENAMIENTO NO INCLUYE EL VALOR 35251, POR 
#              LO QUE LAS PREDICCIONES SON RIESGOSAS. 

# ¿DENTRO DE QUÉ RANGO DE VALORES SON VÁLIDAS LAS PREDICCIONES? 

range(ecommerce$RRSS)

# ENTRE LOS 2000 Y 6000 USD LAS PREDICCIONES SON VÁLIDAS 



#----------------------- EJERCICIO 2 -----------------------------------------#

#--------------> 2.1 ECUACIÓN DEL MODELO DE RLS 

# Renovación = -0.818*(Tiempo de respuesta en minutos) + 94.578

#--------------> 2.2 INTERPRETACIÓN DEL ß1 

# POR CADA MINUTO ADICIONAL DE DEMORA EN EL TIEMPO DE RESPUESTA, LA TASA DE 
# RENOVACIÓN DISMINUYE 0.818 % 


#--------------> 2.3 PRUEBA DE HIPÓTESIS DE ß1 


# ----- PASO 1 --------------------------------------------------------------- #
# H0 = NO HAY ASOCIACIÓN LINEAL ENTRE EL TIEMPO DE RESPUESTA Y LA TASA DE 
#      RENOVACIÓN
# HA = HAY ASOCIACIÓN LINEAL ENTRE EL TIEMPO DE RESPUESTA Y LA TASA DE 
#      RENOVACIÓN 

# H0 : ß1 = 0 
# H1 : ß1 ≠ 0 

# ----- PASO 2 --------------------------------------------------------------- #

# EL ESTADÍSTICO DE PRUEBA ES t = -25.85 | EL COEFICIENTE ESTIMADO EN LA BASE DE 
# ENTRENAMIENTO ESTÁ A MÁS DE 25 DESVÍOS POR DEBAJO DEL VALOR 
# HIPOTÉTICO ß(TIEMPO DE RESPUESTA) = 0 

# ----- PASO 3 --------------------------------------------------------------- #

# P-VALUE = 1.07e-08 < 0.01 | SE RECHAZA H0 Y SE ACEPTA H1 

# CONCLUSIÓN = BASÁNDONOS EN LA MUESTRA DE ENTRENAMIENTO DE n = 130, PODEMOS 
#              CONCLUIR CON UN NIVEL DE SIGNIFICANCIA DEL 1% QUE HAY ASOCIACIÓN 
#              LINEAL ENTRE LAS VARIABLES TIEMPO DE RESPUESTA Y RENOVACIÓN


#--------------> 2.4 INTERPRETACIÓN DE R2 

# R2 = 0.9885 | EL 98.85 % DE LA VARIABILIDAD DE LAS RENOVACIONES SON EXPLICADAS  
#               POR EL TIEMPO DE RESPUESTA EN MINUTOS 

#--------------> 2.5 TASA DE RENOVACIÓN ESPERADA CON X = 11 

-0.81843*(11) + 94.57816

# TASA DE RENOVACIÓN ESPERADA: 85.57543 % 


#--------------> 2.6 TIEMPO DE RESPUESTA PROMEDIO PARA Y = 85 % 

(85 - 94.57816) / (-0.81843)

# TIEMPO DE RESPUESTA PROMEDIO : 11.70 MINUTOS







