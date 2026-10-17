# EMA-RSLAIK Strategy (Diario) Kelvin

- url: https://www.tradingview.com/script/Igq6XlXA/
- type: strategy
- pine_id: PUB;d9e4166c249c42b5a92f60ce02ae505f
- version: 1.0

## Description

[b]Estrategia EMA-RSLAIK para ETHUSDT Diario[/b]

[i]-¿Qué hace esta estrategia? [/i]
Es una estrategia de seguimiento de tendencia. Solo entra al mercado cuando tres condiciones se alinean simultáneamente: la tendencia es alcista, el momentum es fuerte pero no agotado, y el mercado tiene suficiente volatilidad para que el movimiento cubra los costes y genere beneficio. Si cualquiera de las tres falla, no hay entrada. -Los tres indicadores y su función exacta La EMA 21 y la EMA 89 trabajan juntas para definir la tendencia. La EMA 21 es la media rápida, refleja el precio reciente. La EMA 89 es la media lenta, refleja la tendencia de fondo. Para que haya señal, la EMA 21 tiene que estar por encima de la EMA 89 - eso confirma tendencia alcista — y además el precio de cierre tiene que estar por encima de la EMA 21, lo que confirma que el precio está respetando y siguiendo esa tendencia, no alejándose de ella. EL RSI de 14 períodos pide el momentum. El rango válido es 55-75. El mínimo de 55 garantiza que hay momentum real detrás del movimiento, descartando señales débiles o laterales. El máximo de 75 evita entrar cuando el precio ya está sobrecomprado y el movimiento puede estar agotado. Es decir, queremos entrar cuando el tren ya ha salido pero aún no ha llegado a destino. El ATR de 14 períodos mide la volatilidad actual comparada con su media de los últimos 20 períodos. Si el ATR está por debajo de su media, el mercado está en consolidación y la estrategia no opera. Esto es crítico porque en mercados planos el precio oscila sin dirección y los stops saltan constantemente sin que el precio llegue al objetivo. 
[i]-Cuándo entra exactamente[/i] 
Al cierre de cada vela de diario, el sistema comprueba si se cumplen las tres condiciones a la vez. Si se cumplen, lanza una orden de compra en la apertura de la siguiente vela. Nunca entra a mitad de vela, siempre espera al cierre para confirmar la señal y ejecuta en la apertura siguiente para evitar el lookahead bias - un error común en backtesting donde el sistema usa información que en la realidad no estaría disponible todavía. 
[i]-Cómo gestiona el riesgo[/i]
Nada más entrar quedan fijados dos niveles basados en el ATR del momento de la entrada, y no cambian durante la vida del trade: El stop loss se coloca a 2.5 veces el ATR por debajo del precio de entrada. Esto da al precio margen para respirar y hacer movimientos normales sin saltar el stop. En ETH D, con un ATR típico de alrededor del 3.5% del precio, el stop queda aproximadamente un 8-9% por debajo de la entrada. El take profit se coloca a 4 veces el ATR por encima del precio de entrada. Eso representa unos 13-14% por encima de la entrada en condiciones normales. El ratio riesgo/beneficio es 1:1.6 — por cada unidad que se arriesga se buscan 1.6 unidades de ganancia. El tamaño de posición es el 40% del equity en cada trade. Con un stop del 8-9% sobre el 40% de la posición, el riesgo real por operación es aproximadamente el 2% del capital total. Si el stop salta, pierdes el 2% de tu cuenta. Si el objetivo se alcanza, ganas el 3.2%. -Los costes que ya están descontados El backtest incluye 0.075% de comisión por cada lado de la operación - ida y vuelta suman 0.15% por trade, que corresponde a la tarifa maker de Binance o Bybit con volumen normal. Además se añaden 2 ticks de slippage por orden para simular que en la realidad nunca se ejecuta exactamente al precio deseado. Todos los resultados mostrados ya tienen estos costes restados.

## Source Code

````pine
//@version=5
strategy("EMA-RSLAIK Strategy Diario",
     overlay=true,
     initial_capital=10000,
     default_qty_type=strategy.percent_of_equity,
     default_qty_value=40,
     commission_type=strategy.commission.percent,
     commission_value=0.075,
     slippage=2)

// === INDICADORES ===

// EMAs
ema21 = ta.ema(close, 21)
ema89 = ta.ema(close, 89)

// RSI
rsi = ta.rsi(close, 14)

// ATR
atr = ta.atr(14)
atr_ma = ta.sma(atr, 20)

// === CONDICIONES ===

// Tendencia
trend_ok = ema21 > ema89 and close > ema21

// Momentum
momentum_ok = rsi >= 55 and rsi <= 75

// Volatilidad
volatility_ok = atr > atr_ma

// Entrada
long_condition = trend_ok and momentum_ok and volatility_ok

// === EJECUCIÓN ===

// Entrada en apertura siguiente (usando cierre confirmado)
if (long_condition and barstate.isconfirmed)
    strategy.entry("Long", strategy.long)

// === GESTIÓN DE RIESGO ===

// Variables persistentes
var float stop_price = na
var float take_profit = na

if (strategy.opentrades > 0)
    entry_price = strategy.opentrades.entry_price(0)
    atr_entry = atr

    stop_price := entry_price - atr_entry * 2.5
    take_profit := entry_price + atr_entry * 4

    strategy.exit("Exit", "Long", stop=stop_price, limit=take_profit)

// === PLOTS ===

plot(ema21, color=color.orange, title="EMA 21")
plot(ema89, color=color.blue, title="EMA 89")
````
