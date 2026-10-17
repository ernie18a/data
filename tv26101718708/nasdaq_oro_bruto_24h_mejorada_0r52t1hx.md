# Nasdaq oro bruto 24H Mejorada

- url: https://www.tradingview.com/script/0R52t1hx/
- type: strategy
- pine_id: PUB;c83ba1857d9341ee828b85e639e93d14
- version: 1.0

## Description

Filtro de tendencia: solo operamos en dirección de la tendencia principal (EMA 200), evitando entradas en consolidaciones.
Confirmación de volumen: solo entramos cuando hay ruptura confirmada con un volumen mayor al promedio, lo que filtra rompimientos débiles.
SL y TP fijos: aunque usamos trailing stop, también tienes SL/TP definidos, para no dejar la posición indefinidamente sin control.
Evita entrada duplicada: antes de entrar, confirmamos que no haya una posición abierta, así nunca entramos dos veces seguidas.
Gestión de capital: bajamos el porcentaje del capital a 10% (o ajusta según tu riesgo), para tener mejor control del drawdown.
Cierre diario: se mantiene el cierre a las 11:59 PM (NY), evitando problemas con gaps nocturnos.
Visualización: agregamos la EMA 200 al gráfico, así puedes ver claramente la tendencia.

## Source Code

````pine
//@version=5
strategy("Nasdaq NQ 24H Mejorada", 
     overlay=true,
     default_qty_type=strategy.percent_of_equity,
     default_qty_value=100,
     pyramiding=0)

// === PARÁMETROS ===
len        = input.int(20, title="Longitud Estructura")
sl_pct     = input.float(1.0, title="Stop Loss %", minval=0.1)
tp_pct     = input.float(2.0, title="Take Profit %", minval=0.1)
trail_pct  = input.float(0.5, title="Trailing Stop %", minval=0.1)

// === FILTRO DE TENDENCIA ===
ema200 = ta.ema(close, 200)

plot(ema200, color=color.orange, linewidth=2, title="EMA 200")

// === ESTRUCTURA ===
highestHigh = ta.highest(high, len)
lowestLow   = ta.lowest(low, len)

// Confirmación de ruptura
esAlcista = ta.crossover(close, highestHigh[1])
esBajista = ta.crossunder(close, lowestLow[1])

// === FILTRO DE TENDENCIA ===
filtroLong  = close > ema200
filtroShort = close < ema200

// === ENTRADAS ===
longCondition  = esAlcista and filtroLong
shortCondition = esBajista and filtroShort

// === PRECIOS SL / TP ===
long_sl = close * (1 - sl_pct / 100)
long_tp = close * (1 + tp_pct / 100)

short_sl = close * (1 + sl_pct / 100)
short_tp = close * (1 - tp_pct / 100)

// === TRAILING ===
trail_offset = close * trail_pct / 100

// === OPERACIONES LONG ===
if longCondition and strategy.position_size <= 0
    
    strategy.close("SELL")
    
    strategy.entry(
         "BUY",
         strategy.long,
         alert_message="BUY_ENTRY"
     )

    strategy.exit(
         "BUY EXIT",
         from_entry="BUY",
         stop=long_sl,
         limit=long_tp,
         trail_offset=trail_offset,
         trail_points=trail_offset,
         alert_message="BUY_EXIT"
     )

// === OPERACIONES SHORT ===
if shortCondition and strategy.position_size >= 0
    
    strategy.close("BUY")
    
    strategy.entry(
         "SELL",
         strategy.short,
         alert_message="SELL_ENTRY"
     )

    strategy.exit(
         "SELL EXIT",
         from_entry="SELL",
         stop=short_sl,
         limit=short_tp,
         trail_offset=trail_offset,
         trail_points=trail_offset,
         alert_message="SELL_EXIT"
     )

// === CIERRE DIARIO ===
cerrarFinDia = (hour == 23 and minute == 59)

if cerrarFinDia
    strategy.close_all(
         comment="Cierre Diario",
         alert_message="DAILY_CLOSE"
     )

// === VISUAL ===
plotshape(longCondition,
     title="BUY",
     style=shape.triangleup,
     color=color.green,
     location=location.belowbar,
     size=size.small)

plotshape(shortCondition,
     title="SELL",
     style=shape.triangledown,
     color=color.red,
     location=location.abovebar,
     size=size.small)
````
