# Torque% Quantity (By Efficiency)

- url: https://www.tradingview.com/script/l3bkQ9Ci/
- type: indicator
- pine_id: PUB;d4b34565b0404c5dbbe82b0bedb565e4
- version: 1.0

## Description

//@version=5
indicator("Torque% Quality (By Efficiency)", overlay=false)


// Número de sesiones a considerar
periodo = 60


// Variable para contar sesiones positivas
contadorPositivas = 0


// Bucle para contar las sesiones positivas de las últimas 60 barras
for i = 1 to periodo
   if (close[i] > close[i + 1])
       contadorPositivas := contadorPositivas + 1


// Cálculo del porcentaje de sesiones positivas
porcentajePositivas = (contadorPositivas / periodo) * 100


// Mostrar el valor en el gráfico
plot(porcentajePositivas, title="Torque% Quality (By Efficiency)", color=color.green)

## Source Code

````pine

//@version=5
indicator(title="Torque% Quantity (By Efficiency)", shorttitle="Torque% Quantity (By Efficiency)", timeframe="", timeframe_gaps=true)


// Definir la longitud
len = 60  // Valor fijo


src = close
mom_perc = ((src - src[len]) / src[len]) * 100


plot(mom_perc, color=#29dfff, title="Torque%")
````
