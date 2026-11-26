# SMC PRO 6 Smart Money Structure

- url: https://www.tradingview.com/script/ppbAhNgm/
- type: indicator
- pine_id: PUB;2340ac094d114ef298d18ab600476555
- version: 2.0

## Description

Indicador basado en Smart Money Concepts (SMC) diseñado para detectar:

BOS (Break of Structure)
CHoCH (Change of Character)
Zonas Supply & Demand
Entradas BUY / SELL
Confirmaciones por ATR, RSI y Volumen
Gestión automática de SL y TP
Tendencia mediante EMA 50 y EMA 200
Pullbacks institucionales
Filtro anti-ruido para evitar falsas rupturas

🔹 Diseñado para scalping y swing trading.
🔹 Optimizado para detectar continuaciones y cambios de estructura reales.
🔹 Incluye panel inteligente de contexto de mercado.
🔹 Compatible con índices, forex y criptomonedas.

⚠️ No es asesor financiero. Utilizar junto a gestión de riesgo

## Source Code

````pine
//@version=5
indicator("SMC PRO 6 - Confirmaciones Limpias", overlay=true, max_boxes_count=30, max_lines_count=50, max_labels_count=50)

//━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━
swingLen      = input.int(8, "Fuerza estructura", minval=3)
atrLen        = input.int(14, "ATR")
atrMult       = input.float(0.8, "Altura zona", step=0.1)
impulseATR    = input.float(1.5, "Impulso mínimo", step=0.1)
breakStrength = input.float(0.25, "Fuerza ruptura ATR", step=0.05)
extendBars    = input.int(80, "Extensión zona")

tp1RR = input.float(1.0, "TP1 RR", step=0.25)
tp2RR = input.float(1.5, "TP2 RR", step=0.25)
tp3RR = input.float(2.0, "TP3 RR", step=0.25)

confirmMode = input.string("ATR + RSI", "Confirmación BOS/CHoCH",
     options=["Solo cierre", "ATR", "ATR + RSI", "ATR + RSI + Volumen"])

showPanel = input.bool(true, "Panel")
showBos   = input.bool(true, "Mostrar BOS/CHoCH")

//━━━━━━━━━━━━━━━━━━━
// INDICADORES
//━━━━━━━━━━━━━━━━━━━
ema50  = ta.ema(close, 50)
ema200 = ta.ema(close, 200)
atr    = ta.atr(atrLen)
rsi    = ta.rsi(close, 14)
volOk  = volume > ta.sma(volume, 20)

// Contexto
bullContext = close > ema200 and ema50 > ema200 and ema50 > ema50[1]
bearContext = close < ema200 and ema50 < ema200 and ema50 < ema50[1]

//━━━━━━━━━━━━━━━━━━━
// ESTRUCTURA
//━━━━━━━━━━━━━━━━━━━
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

var float lastHigh = na
var float lastLow  = na
var int bias = 0

if not na(ph)
    lastHigh := ph

if not na(pl)
    lastLow := pl

bullClose = not na(lastHigh) and close > lastHigh
bearClose = not na(lastLow) and close < lastLow

bullATR = not na(lastHigh) and close > lastHigh + atr * breakStrength
bearATR = not na(lastLow) and close < lastLow - atr * breakStrength

bullRSI = rsi > 50
bearRSI = rsi < 50

bullConfirm =
     confirmMode == "Solo cierre" ? bullClose :
     confirmMode == "ATR" ? bullATR :
     confirmMode == "ATR + RSI" ? bullATR and bullRSI :
     bullATR and bullRSI and volOk

bearConfirm =
     confirmMode == "Solo cierre" ? bearClose :
     confirmMode == "ATR" ? bearATR :
     confirmMode == "ATR + RSI" ? bearATR and bearRSI :
     bearATR and bearRSI and volOk

var int lastBosDir = 0

bosBull = bullConfirm and lastBosDir != 1
bosBear = bearConfirm and lastBosDir != -1

chochBull = bosBull and bias == -1
chochBear = bosBear and bias == 1

if bosBull
    bias := 1
    lastBosDir := 1

if bosBear
    bias := -1
    lastBosDir := -1

if not na(ph) and bias == -1
    lastBosDir := 0

if not na(pl) and bias == 1
    lastBosDir := 0

plotshape(showBos and bosBull and not chochBull, title="BOS Bull", text="BOS", style=shape.labelup,
     location=location.belowbar, color=color.green, textcolor=color.white, size=size.tiny)

plotshape(showBos and bosBear and not chochBear, title="BOS Bear", text="BOS", style=shape.labeldown,
     location=location.abovebar, color=color.red, textcolor=color.white, size=size.tiny)

plotshape(showBos and chochBull, title="CHoCH Bull", text="CHoCH", style=shape.labelup,
     location=location.belowbar, color=color.lime, textcolor=color.black, size=size.tiny)

plotshape(showBos and chochBear, title="CHoCH Bear", text="CHoCH", style=shape.labeldown,
     location=location.abovebar, color=color.orange, textcolor=color.black, size=size.tiny)

//━━━━━━━━━━━━━━━━━━━
// ZONA ÚNICA INTELIGENTE
//━━━━━━━━━━━━━━━━━━━
var box activeZone = na
var int zoneType = 0
var bool zoneUsed = false

bullImpulse = not na(pl) and (high - pl) > atr * impulseATR
bearImpulse = not na(ph) and (ph - low) > atr * impulseATR

if bullImpulse and (bullContext or chochBull)
    if not na(activeZone)
        box.delete(activeZone)

    bottom = pl
    top = pl + atr * atrMult

    activeZone := box.new(
         left=bar_index - swingLen,
         top=top,
         right=bar_index + extendBars,
         bottom=bottom,
         bgcolor=color.new(color.green, 84),
         border_color=color.green)

    zoneType := 1
    zoneUsed := false

if bearImpulse and (bearContext or chochBear)
    if not na(activeZone)
        box.delete(activeZone)

    top = ph
    bottom = ph - atr * atrMult

    activeZone := box.new(
         left=bar_index - swingLen,
         top=top,
         right=bar_index + extendBars,
         bottom=bottom,
         bgcolor=color.new(color.red, 84),
         border_color=color.red)

    zoneType := -1
    zoneUsed := false

if not na(activeZone)
    box.set_right(activeZone, bar_index + extendBars)

if not na(activeZone) and zoneType == 1 and close < box.get_bottom(activeZone)
    box.delete(activeZone)
    activeZone := na
    zoneType := 0
    zoneUsed := false

if not na(activeZone) and zoneType == -1 and close > box.get_top(activeZone)
    box.delete(activeZone)
    activeZone := na
    zoneType := 0
    zoneUsed := false

//━━━━━━━━━━━━━━━━━━━
// ENTRADAS
//━━━━━━━━━━━━━━━━━━━
touchZone = not na(activeZone) and low <= box.get_top(activeZone) and high >= box.get_bottom(activeZone)

bullReject = close > open and close > low + (high - low) * 0.6
bearReject = close < open and close < high - (high - low) * 0.6

dist = math.abs(close - ema50) / ema50
validDist = dist < 0.025

buySignal =
     zoneType == 1 and
     bullContext and
     bias == 1 and
     touchZone and
     bullReject and
     validDist and
     not zoneUsed

sellSignal =
     zoneType == -1 and
     bearContext and
     bias == -1 and
     touchZone and
     bearReject and
     validDist and
     not zoneUsed

if buySignal or sellSignal
    zoneUsed := true

plotshape(buySignal, title="BUY", text="BUY", style=shape.labelup,
     location=location.belowbar, color=color.green, textcolor=color.white)

plotshape(sellSignal, title="SELL", text="SELL", style=shape.labeldown,
     location=location.abovebar, color=color.red, textcolor=color.white)

//━━━━━━━━━━━━━━━━━━━
// ENTRADA + SL / TP1 / TP2 / TP3
//━━━━━━━━━━━━━━━━━━━
var box entryBox = na
var line slLine = na
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na
var label slLabel = na
var label tp1Label = na
var label tp2Label = na
var label tp3Label = na

if buySignal
    sl = box.get_bottom(activeZone)
    entry = close
    risk = entry - sl

    tp1 = entry + risk * tp1RR
    tp2 = entry + risk * tp2RR
    tp3 = entry + risk * tp3RR

    if not na(entryBox)
        box.delete(entryBox)
    if not na(slLine)
        line.delete(slLine)
    if not na(tp1Line)
        line.delete(tp1Line)
    if not na(tp2Line)
        line.delete(tp2Line)
    if not na(tp3Line)
        line.delete(tp3Line)
    if not na(slLabel)
        label.delete(slLabel)
    if not na(tp1Label)
        label.delete(tp1Label)
    if not na(tp2Label)
        label.delete(tp2Label)
    if not na(tp3Label)
        label.delete(tp3Label)

    entryBox := box.new(bar_index, entry, bar_index + 40, sl,
         bgcolor=color.new(color.green, 82), border_color=color.green)

    slLine := line.new(bar_index, sl, bar_index + 40, sl, color=color.red, width=2)
    tp1Line := line.new(bar_index, tp1, bar_index + 40, tp1, color=color.green, width=1)
    tp2Line := line.new(bar_index, tp2, bar_index + 40, tp2, color=color.green, width=2)
    tp3Line := line.new(bar_index, tp3, bar_index + 40, tp3, color=color.green, width=3)

    slLabel := label.new(bar_index + 40, sl, "SL", style=label.style_label_left, color=color.red, textcolor=color.white)
    tp1Label := label.new(bar_index + 40, tp1, "TP1", style=label.style_label_left, color=color.green, textcolor=color.white)
    tp2Label := label.new(bar_index + 40, tp2, "TP2", style=label.style_label_left, color=color.green, textcolor=color.white)
    tp3Label := label.new(bar_index + 40, tp3, "TP3", style=label.style_label_left, color=color.green, textcolor=color.white)

if sellSignal
    sl = box.get_top(activeZone)
    entry = close
    risk = sl - entry

    tp1 = entry - risk * tp1RR
    tp2 = entry - risk * tp2RR
    tp3 = entry - risk * tp3RR

    if not na(entryBox)
        box.delete(entryBox)
    if not na(slLine)
        line.delete(slLine)
    if not na(tp1Line)
        line.delete(tp1Line)
    if not na(tp2Line)
        line.delete(tp2Line)
    if not na(tp3Line)
        line.delete(tp3Line)
    if not na(slLabel)
        label.delete(slLabel)
    if not na(tp1Label)
        label.delete(tp1Label)
    if not na(tp2Label)
        label.delete(tp2Label)
    if not na(tp3Label)
        label.delete(tp3Label)

    entryBox := box.new(bar_index, sl, bar_index + 40, entry,
         bgcolor=color.new(color.red, 82), border_color=color.red)

    slLine := line.new(bar_index, sl, bar_index + 40, sl, color=color.red, width=2)
    tp1Line := line.new(bar_index, tp1, bar_index + 40, tp1, color=color.green, width=1)
    tp2Line := line.new(bar_index, tp2, bar_index + 40, tp2, color=color.green, width=2)
    tp3Line := line.new(bar_index, tp3, bar_index + 40, tp3, color=color.green, width=3)

    slLabel := label.new(bar_index + 40, sl, "SL", style=label.style_label_left, color=color.red, textcolor=color.white)
    tp1Label := label.new(bar_index + 40, tp1, "TP1", style=label.style_label_left, color=color.green, textcolor=color.white)
    tp2Label := label.new(bar_index + 40, tp2, "TP2", style=label.style_label_left, color=color.green, textcolor=color.white)
    tp3Label := label.new(bar_index + 40, tp3, "TP3", style=label.style_label_left, color=color.green, textcolor=color.white)

//━━━━━━━━━━━━━━━━━━━
// PANEL
//━━━━━━━━━━━━━━━━━━━
var table panel = table.new(position.top_right, 2, 5, border_width=1)

if showPanel and barstate.islast
    modo = bullContext ? "SOLO COMPRAS" : bearContext ? "SOLO VENTAS" : "ESPERAR"
    estructura = bias == 1 ? "Alcista" : bias == -1 ? "Bajista" : "Neutral"
    zona = zoneType == 1 ? "Demand BUY" : zoneType == -1 ? "Supply SELL" : "Sin zona"
    accion = buySignal ? "BUY" : sellSignal ? "SELL" : touchZone ? "Esperar rechazo" : "Esperar zona"

    table.cell(panel, 0, 0, "Modo")
    table.cell(panel, 1, 0, modo)

    table.cell(panel, 0, 1, "Estructura")
    table.cell(panel, 1, 1, estructura)

    table.cell(panel, 0, 2, "Confirmación")
    table.cell(panel, 1, 2, confirmMode)

    table.cell(panel, 0, 3, "Zona activa")
    table.cell(panel, 1, 3, zona)

    table.cell(panel, 0, 4, "Acción")
    table.cell(panel, 1, 4, accion)

// EMAs
plot(ema50, color=color.blue, title="EMA 50")
plot(ema200, color=color.orange, title="EMA 200")

// Alertas
alertcondition(buySignal, title="BUY SMC PRO 6", message="BUY SMC PRO 6")
alertcondition(sellSignal, title="SELL SMC PRO 6", message="SELL SMC PRO 6")
alertcondition(chochBull, title="CHoCH Alcista", message="CHoCH alcista confirmado")
alertcondition(chochBear, title="CHoCH Bajista", message="CHoCH bajista confirmado")
````
