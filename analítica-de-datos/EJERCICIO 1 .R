#---------------------- EJERCICIO 1 ----------------------------------------- # 
#---------------------------------------------------------------------------- # 

# 1. ANÁLISIS EXPLORATORIO 
summary(Consumer) 

# 2. TRAIN & TEST 
set.seed(50404258)

train = sample(nrow(Consumer),nrow(Consumer)*0.8) 

test = (-train)

# 3. REGRESIÓN LINEAL SIMPLE 

# INCOME
reg = lm(Amount_Charged~Income, data=Consumer, subset = train) 
summary(reg)

# HOUSEHOLD SIZE 
reg2 = lm(Amount_Charged~Household_Size, data=Consumer, subset = train) 
summary(reg2)

# EL MEJOR PREDICTOR PARA EL AMOUNT CHARGED ES HOUSEHOLD SIZE, YA QUE EL P VALUE 
# DE "HOUSEHOLD SIZE" > P VALUE DE "INCOME". 


# 4. REGRESIÓN LINEAL MÚLTIPLE | INCOME & HOUSEHOLD SIZE 

reg3 = lm(Amount_Charged~Household_Size+Income, data=Consumer, subset = train) 
summary(reg3)

# BONDAD DE AJUSTE 

# R CUADRADO 
# 0.8108 | HOUSE HOLD SIZE & EL INGRESO ANUAL DE LAS FAMILIAS EXPLICAN EL 
# 81.8 % DE LA VARIABLIDAD DE EL CARGO EN TARJETAS DE CRÉDITO. 

#--------- PREDICCIÓN ------------------------------------------------------- #

Consumer$Amount_pred  =  predict(reg3, newdata=Consumer)

Consumer$Error= Consumer$Amount_Charged - Consumer$Amount_pred 

#---------------------> EVALUACION EN TRAIN
# RCME: Raiz cuadrada del cuadrado medio del error.  
RCME.train = sqrt( mean((Consumer$Amount_Charged[train]-Consumer$Amount_pred[train])^2) )
RCME.train 

#---------------------> EVALUACION EN TEST
RCME.test = sqrt( mean((Consumer$Amount_Charged[test]-Consumer$Amount_pred[test])^2) )
RCME.test


# 5.MONTO DEL CARGO ANUAL EN TARJETAS PARA HOGAR DE 4 & INGRESOS DE 50000 

datos_nuevos=data.frame(Household_Size=(4),Income=(50000))   
predict(reg3, datos_nuevos) 
 
# 1761690 USD 

RCME.test/RCME.train > 1.25

RCME.test/RCME.train



















































