# Doble KAMA / MA Adaptativa + ADX (Cruce Tendencia)

- url: https://www.tradingview.com/script/VDcGDiJS/
- type: indicator
- pine_id: PUB;fe8a6dda5f74464c92854777d01635ab
- version: 1.0

## Description

este indicador utiliza a las emas como una potente arma para saber donde comprar y vender

## Source Code

````pine
//@version=5
indicator("Doble KAMA / MA Adaptativa + ADX (Cruce Tendencia)", overlay=true)

// ───────── INPUTS ─────────
lenFast  = input.int(10, "Periodo MA Rápida")
lenSlow  = input.int(30, "Periodo MA Lenta")
trendLen = input.int(200, "Periodo MA Tendencia")

typeFast  = input.string("KAMA", "Tipo MA Rápida", options=["KAMA","EMA","SMA","WMA","RMA","VWMA"])
typeSlow  = input.string("KAMA", "Tipo MA Lenta", options=["KAMA","EMA","SMA","WMA","RMA","VWMA"])
typeTrend = input.string("EMA", "Tipo MA Tendencia", options=["EMA","SMA","WMA","RMA","VWMA"])

useTrend = input.bool(true, "Usar filtro de tendencia")
useSlope = input.bool(true, "Usar pendiente MA lenta")
useADX   = input.bool(true, "Usar filtro ADX")
adxLen   = input.int(14, "Periodo ADX")
adxMin   = input.int(20, "Valor mínimo ADX")

// ───────── INPUTS VISUALES ─────────
buyColor   = input.color(color.green, "Color señal BUY")
sellColor  = input.color(color.red, "Color señal SELL")

// ───────── CONFIGURACIÓN TAMAÑO SEÑAL ─────────
// En Pine v5, plotshape requiere un tamaño constante, así que lo definimos aquí
signalPlotSize = size.small  // Cambia a size.tiny, size.normal, size.large, size.huge según prefieras

// ───────── FUNCIONES ─────────
// KAMA
f_kama(src,length)=>
    fastSC=2.0/3.0
    slowSC=2.0/31.0
    change=math.abs(src-src[length])
    vol=ta.sma(math.abs(src-src[1]),length)*length
    er=vol!=0?change/vol:0.0
    sc=math.pow(er*(fastSC-slowSC)+slowSC,2)
    k=0.0
    k:=na(k[1])?src:k[1]+sc*(src-k[1])
    k

// Selector MA
f_ma(type,src,len)=>
    result = 0.0
    if type=="KAMA"
        result := f_kama(src,len)
    else if type=="EMA"
        result := ta.ema(src,len)
    else if type=="SMA"
        result := ta.sma(src,len)
    else if type=="WMA"
        result := ta.wma(src,len)
    else if type=="RMA"
        result := ta.rma(src,len)
    else
        result := ta.vwma(src,len)
    result

// ───────── CÁLCULOS ─────────
maFast  = f_ma(typeFast, close, lenFast)
maSlow  = f_ma(typeSlow, close, lenSlow)
trendMA = f_ma(typeTrend, close, trendLen)

// ───────── ADX ─────────
upMove   = high - high[1]
downMove = low[1] - low
plusDM   = upMove > downMove and upMove>0 ? upMove : 0
minusDM  = downMove > upMove and downMove>0 ? downMove : 0
trur     = ta.rma(ta.tr, adxLen)
plusDI   = 100 * ta.rma(plusDM, adxLen)/trur
minusDI  = 100 * ta.rma(minusDM, adxLen)/trur
adxValue = 100 * ta.rma(math.abs(plusDI - minusDI)/(plusDI + minusDI), adxLen)

// ───────── FILTROS ─────────
trendBuy  = not useTrend or (maFast > trendMA and maSlow > trendMA)
trendSell = not useTrend or (maFast < trendMA and maSlow < trendMA)
slopeBuy  = not useSlope or maSlow > maSlow[1]
slopeSell = not useSlope or maSlow < maSlow[1]
adxOk     = not useADX or adxValue > adxMin

// ───────── SEÑALES ─────────
buySignal  = ta.crossover(maFast, maSlow)  and trendBuy and slopeBuy and adxOk
sellSignal = ta.crossunder(maFast, maSlow) and trendSell and slopeSell and adxOk

// ───────── PLOTS ─────────
plot(maFast,  color=color.lime,   linewidth=2, title="MA Rápida")
plot(maSlow,  color=color.red,    linewidth=2, title="MA Lenta")
plot(useTrend ? trendMA : na, color=color.orange, linewidth=1, title="MA Tendencia")

plotshape(buySignal,  style=shape.triangleup,   location=location.belowbar, color=buyColor,  size=signalPlotSize, text="BUY")
plotshape(sellSignal, style=shape.triangledown, location=location.abovebar, color=sellColor, size=signalPlotSize, text="SELL")
````
