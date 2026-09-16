<!-- tradingview-pine-id: PUB;7564c920c8a54bcb8198130270a60983 -->
<!-- tradingview-pine-version: 3.0 -->
<!-- tradingviewscripts-format: 1 -->
# Rv-Div - Regular Divergence (Daily)

Source: https://www.tradingview.com/script/WMnrpv3h/

## Description

Rv-Div — Regular Divergence (Daily)

Rv-Div marks confirmed regular divergences on the daily chart and draws the line that connects them, so you can see the structure the signal is based on instead of trusting an arrow.

**What it does**

A bullish divergence is price making a lower low while the oscillator makes a higher low: price is still falling, but with less force behind it. A bearish divergence is the mirror image — a higher high in price against a lower high in the oscillator.

Rv-Div marks the exact candle that confirms the divergence, draws the line between the two pivots it used, and can fire an alert.

**The problem it solves**

Most divergence tools compare each new pivot against the immediately previous one. That works until a small wrinkle appears between the two lows that actually matter — and then the line gets drawn between the wrinkle and the new low instead of between the two real lows. The divergence you see on screen is not the one your eye would have drawn.

Rv-Div compares each new pivot against the last N pivots, not just the previous one, and keeps the one that forms a valid divergence. That is what the eye does: connect the two lows that matter, skipping the noise in between.

It also spends each anchor. Without that, one old pivot gets reused against every new pivot that appears, and you end up with several lines fanning out from the same point — the same divergence counted three or four times, which inflates any count you make of them. Here, once an anchor is used it is discarded along with everything older.

**Quality filters**

Not every pair of pivots deserves to be called a divergence. Four filters, all adjustable:

- Minimum price difference between the two extremes, measured in ATR, so it travels across symbols and volatility regimes instead of using a fixed percentage.
- Minimum difference between the two oscillator pivots.
- Both oscillator pivots on the correct side of zero.
- Minimum and maximum bar separation between the two pivots.

**Settings**

Three oscillators to choose from — Awesome Oscillator, MACD histogram, and a linear-regression momentum. All three are public-domain formulas.

The pivot definition (bars to the left and right), the quality filters, the two EMAs, the colours, the label size and the line width are all adjustable. The default values are the ones I use on the daily chart.

**How to use it**

Daily chart only. The indicator says so on screen if you load it on any other timeframe.

Set alerts to **Once per bar close**. A forming candle keeps changing until it closes, and a divergence is not confirmed until then.

**Dropping to a lower timeframe to confirm**

The signal is a daily signal, but you do not have to take it blind on the daily close. Once the daily marks the entry, drop to 4h and wait for a break of the local high followed by a pullback — or go from 4h down to 1h and look for the same thing. You give up a little of the move in exchange for not entering into a candle that is still falling.

This is deliberately not built into the indicator. It is a judgement call, and judgement calls belong to the trader, not to a script that has to work the same way on every symbol and every market.

**What it does not do**

It does not manage exits. It marks an entry candle and nothing else — no targets, no stops, no position sizing. Those decisions are yours.

It is not a standalone system. A divergence tells you that momentum is fading, not that the trend has turned. What you do with that information is where your own judgement goes.

**About the confirmation delay**

A pivot does not exist until the required bars have closed to its right, so the signal arrives with that delay. This is deliberate. Removing it would mean signalling on unconfirmed pivots, which look excellent in hindsight and vanish in real time.

Historical signals do not repaint: once a pivot is confirmed, it stays confirmed. The forming candle is the only thing that can change, which is why alerts should be set to bar close.

---

**Español**

Rv-Div marca divergencias regulares confirmadas en gráfico diario y dibuja la línea que las une, para que veas la estructura en la que se apoya la señal en lugar de fiarte de una flecha.

Una divergencia alcista es el precio haciendo un mínimo más bajo mientras el oscilador hace un mínimo más alto: sigue cayendo, pero con menos fuerza detrás. La bajista es la imagen espejo.

La diferencia con la mayoría de detectores de divergencia está en el trazado. Casi todos comparan cada pivote nuevo con el inmediatamente anterior, y en cuanto aparece una arruga entre los dos suelos que de verdad importan, la línea sale mal dibujada. Rv-Div compara contra los últimos N pivotes y se queda con el que forma la divergencia válida — que es lo que hace el ojo. Además consume cada ancla, así que un mismo pivote antiguo no se reutiliza una y otra vez generando varias líneas en abanico desde el mismo punto.

Cuatro filtros de calidad ajustables (diferencia mínima de precio en ATR, diferencia mínima del oscilador, ambos pivotes del lado correcto del cero, y separación mínima y máxima), tres osciladores a elegir, y todo el aspecto configurable.

Solo diario. Alertas configuradas como "Una vez por barra al cerrar".

**Bajar a una temporalidad menor para confirmar.** La señal es del diario, pero no hace falta tomarla a ciegas en el cierre diario. Cuando el diario marca la entrada, se puede bajar a 4h y esperar una ruptura del máximo local con su retroceso — o de 4h bajar a 1h y buscar lo mismo. Se cede un poco del movimiento a cambio de no entrar en una vela que todavía viene cayendo. Esto no está metido en el indicador a propósito: es criterio del operador, y el criterio no se le delega a un script que tiene que funcionar igual en todos los símbolos.

No gestiona salidas ni es un sistema completo: marca la vela de entrada y nada más. Una divergencia dice que el impulso se está agotando, no que la tendencia ya giró.

El retraso de confirmación es deliberado: un pivote no existe hasta que cierran las velas que lleva a su derecha. Quitarlo significaría señalar sobre pivotes sin confirmar, que se ven perfectos en el pasado y desaparecen en vivo. Las señales históricas no repintan.

---

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════════
//  Rv-Div - Regular divergence on the daily chart
//
//  BUY   the price prints a LOWER low than the previous one, but the
//        oscillator prints a HIGHER low. It is falling with less force.
//  SELL  the price prints a HIGHER high, but the oscillator prints a
//        LOWER high. It is rising with less force.
//
//  The entry is EXACTLY the candle that confirms the divergence.
//  A pivot does not exist until "Bars to the right of the pivot" bars
//  have passed, so the signal arrives with that delay. That is the price
//  of a confirmed divergence instead of a guess. There is no way to
//  remove the delay without cheating.
//
//  Daily chart only.
// ══════════════════════════════════════════════════════════════════════
indicator("Rv-Div - Regular Divergence (Daily)", "Rv-Div", overlay = true, max_labels_count = 500, max_lines_count = 500)

isDaily = timeframe.in_seconds() >= 86400

// ─────────────────────────── MOVING AVERAGES ───────────────────────────
g0       = "Moving averages"
fastLen  = input.int(55,  "Fast EMA", minval = 1, group = g0)
slowLen  = input.int(200, "Slow EMA", minval = 1, group = g0)
showSlow = input.bool(true, "Draw the slow EMA", group = g0)

emaFast = ta.ema(close, fastLen)
emaSlow = ta.ema(close, slowLen)
atr     = ta.atr(14)

// ─────────────────────────── OSCILLATOR ───────────────────────────
gH      = "Oscillator"
oscType = input.string("Awesome Oscillator", "Oscillator", options = ["Awesome Oscillator", "MACD histogram", "Linear momentum"], group = gH, tooltip = "The divergence is measured against this. All three are public-domain formulas.")
aoFast  = input.int(5,  "AO - fast length",  minval = 1, group = gH)
aoSlow  = input.int(34, "AO - slow length",  minval = 2, group = gH)
macdF   = input.int(12, "MACD - fast",       minval = 1, group = gH)
macdS   = input.int(26, "MACD - slow",       minval = 2, group = gH)
macdSig = input.int(9,  "MACD - signal",     minval = 1, group = gH)
momLen  = input.int(20, "Linear momentum - length", minval = 2, group = gH)

_ao = ta.sma(hl2, aoFast) - ta.sma(hl2, aoSlow)
[_m1, _m2, _mHist] = ta.macd(close, macdF, macdS, macdSig)
_hh  = ta.highest(high, momLen)
_ll  = ta.lowest(low, momLen)
_lin = ta.linreg(close - math.avg(math.avg(_hh, _ll), ta.sma(close, momLen)), momLen, 0)
osc  = oscType == "Awesome Oscillator" ? _ao : oscType == "MACD histogram" ? _mHist : _lin

// ─────────────────────────── DIVERGENCE ───────────────────────────
gR      = "Divergence"
pivLeft = input.int(7, "Bars to the left of the pivot",  minval = 1, group = gR)
pivRght = input.int(2, "Bars to the right of the pivot", minval = 1, group = gR, tooltip = "This is the confirmation delay. A pivot is not a pivot until this many bars have closed after it.")
sepMin  = input.int(4,  "Minimum bars between the two pivots", minval = 1, group = gR)
sepMax  = input.int(90, "Maximum bars between the two pivots", minval = 2, group = gR)
drawLn  = input.bool(false, "Draw the divergence line", group = gR)

// ─────────────────────── DIVERGENCE QUALITY ───────────────────────
// Without these, every small wrinkle counts as a divergence.
gQ         = "Divergence quality"
pivLookbk  = input.int(12, "Compare against the last N pivots", minval = 1, maxval = 12, group = gQ, tooltip = "KEY SETTING. With 1 it only compares against the previous pivot, so a small wrinkle in between draws the divergence wrong. With 6 it looks for the WIDE structure, which is how the eye draws it.")
preferWide = input.bool(true, "Keep the widest structure", group = gQ, tooltip = "Among all valid pivots, take the furthest one. That is what the eye does: connect the two important lows, not the two most recent ones.")
anchorOnce = input.bool(true, "Use each anchor only ONCE", group = gQ, tooltip = "Without this, one old pivot is reused against every new pivot and you get several lines fanning out from the same point: the same divergence counted three or four times.")
waitBars   = input.int(3, "Wait N bars between two signals on the SAME side", minval = 0, group = gQ, tooltip = "0 = no wait. Raise it if you still see signals bunched together.")
sameSide   = input.bool(true, "Oscillator pivots must be on the correct side of zero", group = gQ, tooltip = "For a buy, both oscillator lows below zero. For a sell, both highs above zero.")
minPx      = input.float(0.8,  "Minimum price difference between the two extremes (x ATR)", step = 0.1, minval = 0.0, group = gQ)
minOsc     = input.float(0.0, "Minimum difference between the two oscillator pivots", step = 0.05, minval = 0.0, group = gQ)

// ─────────────────────────── APPEARANCE ───────────────────────────
gC       = "Appearance"
cFast    = input.color(#2962ff, "Fast EMA", group = gC)
cSlow    = input.color(#ff5252, "Slow EMA", group = gC)
cBuy     = input.color(#00897b, "Buy label", group = gC)
cSell    = input.color(#c62828, "Sell label", group = gC)
cBull    = input.color(#7e57c2, "Bullish divergence line", group = gC)
cBear    = input.color(#ec407a, "Bearish divergence line", group = gC)
sizeTxt  = input.string("Small", "Label size", options = ["Tiny", "Small", "Normal", "Large"], group = gC)
lblSize  = sizeTxt == "Tiny" ? size.tiny : sizeTxt == "Normal" ? size.normal : sizeTxt == "Large" ? size.large : size.small
emaWidth = input.int(1, "EMA line width", minval = 1, maxval = 4, group = gC)

// ─────────────────────────── ENGINE ───────────────────────────
oscLow  = ta.pivotlow(osc,  pivLeft, pivRght)
oscHigh = ta.pivothigh(osc, pivLeft, pivRght)
oscScale = ta.sma(math.abs(osc), 100)

// Pivot history: oldest first.
var array<float> oL = array.new<float>(0)
var array<float> pL = array.new<float>(0)
var array<int>   bL = array.new<int>(0)
var array<float> oH = array.new<float>(0)
var array<float> pH = array.new<float>(0)
var array<int>   bH = array.new<int>(0)

var int lastSigC = na
var int lastSigV = na

bullDiv = false
bearDiv = false
var float lnA  = na
var int   lnBa = na
var float lnB  = na
var int   lnBb = na

// ─────────── BULLISH DIVERGENCE (lows) ───────────
if not na(oscLow)
    px = low[pivRght]
    bb = bar_index - pivRght
    chosen = -1
    if array.size(oL) > 0
        i = 0
        while i < array.size(oL)
            o0  = array.get(oL, i)
            p0  = array.get(pL, i)
            b0  = array.get(bL, i)
            sep = bb - b0
            ok = sep >= sepMin and sep <= sepMax and px < p0 and oscLow > o0
            ok := ok and (not sameSide or (oscLow < 0 and o0 < 0))
            ok := ok and math.abs(px - p0) >= minPx * atr
            ok := ok and oscScale > 0 and math.abs(oscLow - o0) >= minOsc * oscScale
            if ok and (chosen == -1 or not preferWide)
                chosen := i
            i += 1
    if chosen >= 0 and (waitBars == 0 or na(lastSigC) or bar_index - lastSigC >= waitBars)
        bullDiv := true
        lnA  := array.get(pL, chosen)
        lnBa := array.get(bL, chosen)
        lnB  := px
        lnBb := bb
        // the anchor is spent: drop it and everything older
        if anchorOnce
            k = 0
            while k <= chosen and array.size(oL) > 0
                array.shift(oL)
                array.shift(pL)
                array.shift(bL)
                k += 1
    array.push(oL, oscLow)
    array.push(pL, px)
    array.push(bL, bb)
    while array.size(oL) > pivLookbk
        array.shift(oL)
        array.shift(pL)
        array.shift(bL)

// ─────────── BEARISH DIVERGENCE (highs) ───────────
if not na(oscHigh)
    px = high[pivRght]
    bb = bar_index - pivRght
    chosen = -1
    if array.size(oH) > 0
        i = 0
        while i < array.size(oH)
            o0  = array.get(oH, i)
            p0  = array.get(pH, i)
            b0  = array.get(bH, i)
            sep = bb - b0
            ok = sep >= sepMin and sep <= sepMax and px > p0 and oscHigh < o0
            ok := ok and (not sameSide or (oscHigh > 0 and o0 > 0))
            ok := ok and math.abs(px - p0) >= minPx * atr
            ok := ok and oscScale > 0 and math.abs(oscHigh - o0) >= minOsc * oscScale
            if ok and (chosen == -1 or not preferWide)
                chosen := i
            i += 1
    if chosen >= 0 and (waitBars == 0 or na(lastSigV) or bar_index - lastSigV >= waitBars)
        bearDiv := true
        lnA  := array.get(pH, chosen)
        lnBa := array.get(bH, chosen)
        lnB  := px
        lnBb := bb
        if anchorOnce
            k = 0
            while k <= chosen and array.size(oH) > 0
                array.shift(oH)
                array.shift(pH)
                array.shift(bH)
                k += 1
    array.push(oH, oscHigh)
    array.push(pH, px)
    array.push(bH, bb)
    while array.size(oH) > pivLookbk
        array.shift(oH)
        array.shift(pH)
        array.shift(bH)

buySignal  = isDaily and bullDiv
sellSignal = isDaily and bearDiv

if buySignal
    lastSigC := bar_index
if sellSignal
    lastSigV := bar_index

// ─────────────────────────── DRAWING ───────────────────────────
if drawLn and (buySignal or sellSignal)
    line.new(lnBa, lnA, lnBb, lnB, color = color.new(buySignal ? cBull : cBear, 0), width = 2)

plot(emaFast, "Fast EMA", cFast, emaWidth)
plot(showSlow ? emaSlow : na, "Slow EMA", cSlow, emaWidth)

if buySignal
    label.new(bar_index, low, "div-buy", style = label.style_label_up, color = color.new(cBuy, 0), textcolor = color.white, size = lblSize)
if sellSignal
    label.new(bar_index, high, "div-sell", style = label.style_label_down, color = color.new(cSell, 0), textcolor = color.white, size = lblSize)

// ──────────── SAY SO WHEN THE CHART IS NOT DAILY ────────────
// Without this the indicator goes silent on 4h or 1h and looks broken.
if barstate.islast and not isDaily
    var label lTf = na
    label.delete(lTf)
    lTf := label.new(bar_index, close, "Rv-Div works on the DAILY chart only\nSwitch the timeframe to 1D", style = label.style_label_left, color = color.new(color.orange, 10), textcolor = color.white, size = size.normal)

// ─────────────────────────── ALERTS ───────────────────────────
// Set the alert to "Once per bar close". The forming candle keeps
// changing until it closes, and a divergence is not confirmed until then.
alertcondition(buySignal,  "BUY",  "Rv-Div: bullish divergence confirmed on {{ticker}}")
alertcondition(sellSignal, "SELL", "Rv-Div: bearish divergence confirmed on {{ticker}}")
   // v2
````
