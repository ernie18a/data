<!-- tradingview-pine-id: PUB;27265d9b837645f297f90bcb06a3b0c5 -->
<!-- tradingviewscripts-format: 1 -->
# VWAP Pullback Signal - FUTURE)

Source: https://www.tradingview.com/script/AsoFo1pU-VWAP-Pullback-Signal-FUTURE/

## Description

Momentum Pullback Pro
Session Bias Signal
VWAP+EMA Confluence

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © sarduydaniel

//@version=6
plot(close)
//@version=5
indicator("VWAP Pullback Signal - FUTURE)", overlay=true)

// ---------- Inputs ----------
emaFastLen   = input.int(9, "EMA rapida", minval=1)
emaSlowLen   = input.int(20, "EMA lenta", minval=1)
volLen       = input.int(20, "Periodo promedio de volumen", minval=1)
volMultiplo  = input.float(1.0, "Volumen minimo x promedio", minval=0.1, step=0.1)
mostrarVWAP  = input.bool(true, "Mostrar VWAP")

// ---------- Indicadores base ----------
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
vwapVal = ta.vwap(hlc3)
volProm = ta.sma(volume, volLen)

plot(emaFast, "EMA rapida", color=color.new(color.blue, 0), linewidth=1)
plot(emaSlow, "EMA lenta", color=color.new(color.orange, 0), linewidth=1)
plot(mostrarVWAP ? vwapVal : na, "VWAP", color=color.new(color.purple, 0), linewidth=2)

// ---------- Sesgo del dia ----------
sesgoLargo = close > vwapVal and close > emaSlow
sesgoCorto = close < vwapVal and close < emaSlow

bgcolor(sesgoLargo ? color.new(color.green, 92) : sesgoCorto ? color.new(color.red, 92) : na, title="Sesgo del dia")

// ---------- Condiciones de entrada ----------
tocoPullbackLargo = low <= emaFast or low <= vwapVal
tocoPullbackCorto = high >= emaFast or high >= vwapVal

velaAlcista = close > open
velaBajista = close < open

volumenConfirma = volume > volProm * volMultiplo

// Nota: para reducir señales repetidas dentro del mismo pullback,
// exige que la barra anterior NO haya cumplido ya la señal.
condLong  = sesgoLargo  and tocoPullbackLargo  and velaAlcista and volumenConfirma
condShort = sesgoCorto  and tocoPullbackCorto  and velaBajista and volumenConfirma

senalCompra = condLong  and not condLong[1]
senalVenta  = condShort and not condShort[1]

// ---------- Plot de señales ----------
plotshape(senalCompra, title="Señal de compra", style=shape.triangleup, location=location.belowbar, color=color.new(color.green, 0), size=size.small, text="COMPRA")
plotshape(senalVenta,  title="Señal de venta",  style=shape.triangledown, location=location.abovebar, color=color.new(color.red, 0), size=size.small, text="VENTA")

// ---------- Alertas ----------
alertcondition(senalCompra, title="Señal de compra", message="Setup de COMPRA: sesgo largo + pullback + vela de reversion + volumen")
alertcondition(senalVenta,  title="Señal de venta",  message="Setup de VENTA: sesgo corto + pullback + vela de reversion + volumen")

// ---------- Tabla de estado en pantalla ----------
var table panel = table.new(position.top_right, 1, 3, bgcolor=color.new(color.black, 80), border_width=1)
if barstate.islast
    estadoTexto = sesgoLargo ? "SESGO: LARGO" : sesgoCorto ? "SESGO: CORTO" : "SESGO: NEUTRO / SIN OPERAR"
    estadoColor = sesgoLargo ? color.green : sesgoCorto ? color.red : color.gray
    table.cell(panel, 0, 0, estadoTexto, text_color=color.white, bgcolor=estadoColor)
    table.cell(panel, 0, 1, "Vol vs promedio: " + str.tostring(math.round((volume/volProm)*100)) + "%", text_color=color.white)
    table.cell(panel, 0, 2, senalCompra ? "COMPRA ACTIVA" : senalVenta ? "VENTA ACTIVA" : "Esperando setup", text_color=color.white)
````
