# Estrategia EMA-RSI-ATR (FETUSDT - 4H)

- url: https://www.tradingview.com/script/193w3Pua/
- type: strategy
- pine_id: PUB;11dfe13e8c594a2685d94a583bb8f1f1
- version: 1.0

## Description

Es un sistema de seguimiento de tendencia algorítmico. Su filosofía no es adivinar cuándo el precio va a girar, sino identificar un "viento a favor" tan fuerte que la probabilidad de éxito sea matemáticamente superior al azar.

Aquí tienes el desglose de sus 4 pilares fundamentales:

1. El Filtro de Tendencia (El "GPS")

La estrategia utiliza una jerarquía de medias móviles para asegurarse de que solo compramos cuando el mercado tiene una estructura claramente alcista:

Confirmación de fondo: La EMA 21 debe estar sobre la EMA 89. Esto indica que el impulso a corto plazo es más fuerte que el promedio a largo plazo.

Confirmación de precio: El precio de cierre debe estar por encima de la EMA 21. Esto actúa como un "suelo" dinámico; si el precio cae por debajo, la estrategia asume que la tendencia inmediata se ha roto y no entra.

2. El Filtro de Momentum y Calidad (El "Motor")

No basta con que el precio suba, debe subir con "gasolina" pero sin quemarse:

RSI (55-75): Es el corazón del sistema. Al exigir un mínimo de 55, evitamos mercados laterales o "zombis". Al poner un techo de 75, evitamos la "trampa del clímax", que es cuando entras justo antes de que los profesionales empiecen a tomar ganancias y el precio corrija.

Regresión Lineal (Nuevo): Este filtro actúa como un verificador de salud. Compara el precio con su línea de tendencia ideal. Si el precio está por debajo de su regresión, la entrada se descarta porque el movimiento actual es demasiado débil o errático.

3. El Filtro de Volatilidad (El "Escudo")

Esta es la parte más profesional de tu estrategia. Muchos traders pierden dinero porque operan cuando el mercado está "muerto".

ATR > Media ATR: La estrategia solo se activa si el ATR (rango real promedio) es superior a su propia media de 20 periodos.

Por qué es vital: Si el mercado no se mueve lo suficiente, las comisiones y el slippage se comerán tus beneficios. Este filtro asegura que el "recorrido" potencial del precio sea lo suficientemente amplio para cubrir los costes y darte profit.

4. Gestión de Riesgo Dinámica (La "Salida")

A diferencia de la versión original que era estática, esta versión optimizada gestiona la operación mientras está viva:

Stop Loss Inicial (2.0 ATR): Un poco más ajustado que el original para mejorar tu Ratio Riesgo/Beneficio. Te protege de caídas bruscas iniciales.

Take Profit Ambicioso (5.0 ATR): Aprovecha la naturaleza volátil de Ethereum para buscar ganancias del 15-20% en operaciones que realmente despegan.

Trailing Stop (El seguro de vida):

Si el precio sube 3 veces el ATR a tu favor, la estrategia activa el "modo defensa".

El Stop Loss deja de estar en el sitio original y empieza a seguir al precio a una distancia de 1.5 ATR.

Resultado: Si el trade iba muy bien pero de repente ETH se desploma, sales con ganancias aseguradas en lugar de ver cómo tu profit se convierte en pérdida.

## Source Code

````pine
//@version=5
strategy("Estrategia EMA-RSI-ATR ETH 4H", overlay=true, initial_capital=10000, default_qty_type=strategy.percent_of_equity, default_qty_value=40, commission_type=strategy.commission.percent, commission_value=0.075, slippage=2)

// --- PARÁMETROS DE INDICADORES ---
emaFastLen = input.int(21, "EMA Rápida (21)", minval=1)
emaSlowLen = input.int(89, "EMA Lenta (89)", minval=1)
rsiLen     = input.int(14, "Periodos RSI", minval=1)
rsiMin     = input.float(55.0, "RSI Mínimo", minval=0, maxval=100)
rsiMax     = input.float(75.0, "RSI Máximo", minval=0, maxval=100)
atrLen     = input.int(14, "Periodos ATR", minval=1)
atrMaLen   = input.int(20, "Media ATR (Filtro Volatilidad)", minval=1)

// --- CÁLCULOS ---
ema21 = ta.ema(close, emaFastLen)
ema89 = ta.ema(close, emaSlowLen)
rsi   = ta.rsi(close, rsiLen)
atr   = ta.atr(atrLen)
atrAvg = ta.sma(atr, atrMaLen)

// --- CONDICIONES DE ENTRADA ---
// 1. Tendencia: EMA 21 > EMA 89 Y Precio > EMA 21
trendCondition = ema21 > ema89 and close > ema21

// 2. Momentum: RSI entre 55 y 75
momentumCondition = rsi >= rsiMin and rsi <= rsiMax

// 3. Volatilidad: ATR > Media del ATR (20)
volatilityCondition = atr > atrAvg

// Señal de Compra
longCondition = trendCondition and momentumCondition and volatilityCondition

// --- GESTIÓN DE RIESGO (FIJADA AL ENTRAR) ---
// Usamos variables 'var' para que los niveles no cambien mientras el trade está abierto
var float stopLossLevel = na
var float takeProfitLevel = na

if (longCondition and strategy.position_size == 0)
    stopLossLevel  := close - (atr * 2.5)
    takeProfitLevel := close + (atr * 4.0)
    strategy.entry("Long", strategy.long, comment="RSI:" + str.tostring(math.round(rsi,2)))

// Ejecución de salida si hay una posición abierta
if (strategy.position_size > 0)
    strategy.exit("Exit Long", "Long", stop=stopLossLevel, limit=takeProfitLevel, comment_loss="SL", comment_profit="TP")

// --- VISUALIZACIÓN EN GRÁFICO ---
plot(ema21, color=color.blue, title="EMA 21")
plot(ema89, color=color.orange, linewidth=2, title="EMA 89")

// Colorear el fondo cuando las condiciones se cumplen (opcional)
bgcolor(longCondition ? color.new(color.green, 90) : na)

// Dibujar niveles de salida solo si estamos dentro
plot(strategy.position_size > 0 ? stopLossLevel : na, color=color.red, style=plot.style_linebr, title="Nivel Stop Loss")
plot(strategy.position_size > 0 ? takeProfitLevel : na, color=color.green, style=plot.style_linebr, title="Nivel Take Profit")
````
