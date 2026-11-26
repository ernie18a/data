# APEX Institutional Pro v2

- url: https://www.tradingview.com/script/1XRnUuaH/
- type: indicator
- pine_id: PUB;6b5d4130d54e4ca6ad5cd4dc0869f747
- version: 2.0

## Description

APEX Institutional Pro v2APEX Institutional Pro v2APEX Institutional Pro v2APEX Institutional Pro v2APEX Institutional Pro v2APEX Institutional Pro v2

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © figueroajb08

//@version=6
indicator("Day Trading Precisión Total", overlay=true, max_labels_count=500)

// 1. AJUSTES
uTF = input.bool(true, "Horario")
sess = input.session("0945-1545", "Sess EST")
wL = input.int(14, "WPR")
eL = input.int(200, "EMA Mayor")

// 2. CÁLCULOS
t = time(timeframe.period, sess + ":1234567", "America/New_York")
ok = not uTF or not na(t)
vW = ta.vwap(hlc3)
wr = ta.wpr(wL)
ema200 = ta.ema(close, eL)

// Volumen y Presión
vR = math.max(high-low, syminfo.mintick)
bV = ((close-low)/vR)*volume
sV = ((high-close)/vR)*volume
cli = volume > ta.sma(volume, 20)*2.0

// SEÑALES DE ALTA PRECISIÓN
// Long: En sesión + Sobre VWAP + Sobre EMA 200 + Cruce WPR
longS = ok and close > vW and close > ema200 and ta.crossover(wr, -80)
// Short: En sesión + Bajo VWAP + Bajo EMA 200 + Cruce WPR
shortS = ok and close < vW and close < ema200 and ta.crossunder(wr, -20)

// 3. DIBUJO (Todo pegado a la izquierda)
bgcolor(ok ? na : color.new(color.gray, 90))
plot(ema200, "EMA 200", color.new(color.white, 30), 2)
plot(vW, "VWAP", color.orange, 2)

// LÓGICA DE VELAS (Blanco=Compra, Naranja=Venta)
bCol = longS ? color.white : shortS ? color.orange : cli ? #FFD700 : (bV > sV ? color.new(color.green, 50) : color.new(color.red, 50))
barcolor(bCol)

// 4. ETIQUETAS
if longS and not longS[1]
    label.new(bar_index, low, "ALTA PROB COMPRA", color=color.white, textcolor=color.black, style=label.style_label_up)
    if shortS and not shortS[1]
        label.new(bar_index, high, "ALTA PROB VENTA", color=color.orange, textcolor=color.black, style=label.style_label_down)
````
