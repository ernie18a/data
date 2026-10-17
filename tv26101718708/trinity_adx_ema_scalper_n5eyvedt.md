# Trinity ADX + EMA Scalper

- url: https://www.tradingview.com/script/N5EyVEDt-Trinity-ADX-EMA-Scalper/
- type: indicator
- pine_id: PUB;e7cc077f85bd4802b27a42dbced5076d
- version: 1.0

## Description

**Trinity ADX + EMA Scalper – User Guide**

This indicator combines an ADX trend background with an EMA-based scalping system. It shows trend strength and direction through chart background color while generating Buy and Sell signals based on price crossing an EMA.

**Adding the Indicator**
Open the Pine Editor in TradingView, paste the full script, click “Add to chart,” and save it under your preferred name. It runs as an overlay on the main price chart.

**ADX Background**
The background changes color based on the ADX value and the relationship between +DI and -DI:
- When ADX is above the Strong level (default 20) and +DI is above -DI, the background turns green (bullish).
- When ADX is above the Strong level and -DI is above +DI, the background turns red (bearish).
- When ADX is above the White level (default 15) but below the Strong level, the background turns white (weaker or developing trend).
- Below the White level the background stays clear.

You can turn the background off entirely with the “Show ADX Background” input.

**EMA and High/Low Lines**
The indicator plots an EMA (default length 20) along with the highest and lowest close over a selectable lookback (default 8 bars). These lines help visualize the short-term range and the moving average used for signals. You can hide all three lines with the “Show EMA / Highest / Lowest” toggle.

**Buy and Sell Signals**
A Buy arrow appears when price crosses above the EMA and the previous close was below the current close.  
A Sell arrow appears when price crosses below the EMA and the previous close was above the current close.

Signals can be filtered in two ways:
- **Filter Signals with ADX Trend** – Buy signals only appear when +DI is above -DI; Sell signals only appear when -DI is above +DI.
- **Only Signal when ADX > Strong Level** – Signals only appear when ADX is above the Strong level (default 20).

You can turn all arrows off with “Show Buy / Sell Arrows.” Arrow size is adjustable (Tiny, Small, or Normal).

**Optional ADX Lines**
You can display the +DI, -DI, and ADX lines directly on the chart. Note that these values are on a different scale from price, so enabling them may compress the price scale. Horizontal lines mark the White and Strong ADX levels when the lines are shown.

**ADX Status Label**
An optional label appears on the last bar showing the current ADX value and whether the direction is Bull, Bear, or Neutral. You can turn this label off if you prefer a cleaner chart.

**Alerts**
Two alerts are available:
- Trinity Buy
- Trinity Sell

Create an alert from the indicator’s alert conditions to receive notifications when a signal appears (after any filters you have enabled).

**Recommended Settings**
- Start with the default ADX length of 14 and EMA length of 20.
- Enable “Filter Signals with ADX Trend” if you want signals to align with the background color.
- Use “Only Signal when ADX > Strong Level” on higher timeframes to reduce noise.
- Keep the ADX lines hidden unless you specifically need to see the DI values.
- Adjust the background transparency in the color inputs if the colors feel too strong or too faint.

**Notes**
The ADX calculation uses Wilder’s smoothing method matching the original logic. All features are optional and can be toggled independently so you can run the indicator as a pure background, a pure signal system, or both together.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © EMA34TRADER
//@version=6
indicator("Trinity ADX + EMA Scalper", shorttitle="Trinity ADX EMA", overlay=true)

// ── ADX Inputs ─────────────────────
adxLen     = input.int(14,  title="ADX & DI Length", minval=1)
level20    = input.int(15,  title="White Background when ADX >", minval=1, maxval=50)
level25    = input.int(20,  title="Strong Color when ADX >", minval=1, maxval=100)

bullColor  = input.color(color.new(color.green, 88), title="Bullish Background (>25)")
bearColor  = input.color(color.new(color.red,   88), title="Bearish Background (>25)")
whiteBg    = input.color(color.new(color.white, 92), title="White Background (>20)")

showLines  = input.bool(false, title="Show +DI / -DI / ADX Lines (may distort scale)")
showBg     = input.bool(true,  title="Show ADX Background")

diPlusCol  = input.color(color.green,  title="+DI Color")
diMinusCol = input.color(color.red,    title="-DI Color")
adxCol     = input.color(color.yellow, title="ADX Color")

// ── EMA Scalper Inputs ─────────────────────
emaLen     = input.int(20, minval=1, title="EMA Length")
src        = input.source(close, title="Source")
hl_len     = input.int(8, minval=1, title="High/Low Length")

emaColor        = input.color(color.blue,  title="EMA Color")
highColor       = input.color(color.red,   title="Highest Color")
lowColor        = input.color(color.green, title="Lowest Color")
buyArrowColor   = input.color(color.green, title="Buy Arrow Color")
sellArrowColor  = input.color(color.red,   title="Sell Arrow Color")
buyTextColor    = input.color(color.green, title="Buy Text Color")
sellTextColor   = input.color(color.red,   title="Sell Text Color")

showEmaPlots    = input.bool(true, title="Show EMA / Highest / Lowest")
showSignals     = input.bool(true, title="Show Buy / Sell Arrows")
useAdxFilter    = input.bool(false, title="Filter Signals with ADX Trend")
onlyStrongAdx   = input.bool(false, title="Only Signal when ADX > Strong Level")
arrowSize       = input.string("tiny", title="Arrow Size", options=["tiny", "small", "normal"])

showAdxLabel    = input.bool(true, title="Show ADX Status Label")

// ── ADX Calculation ─────────────────────
TrueRange                  = math.max(math.max(high - low, math.abs(high - nz(close[1]))), math.abs(low - nz(close[1])))
DirectionalMovementPlus    = high - nz(high[1]) > nz(low[1]) - low ? math.max(high - nz(high[1]), 0) : 0
DirectionalMovementMinus   = nz(low[1]) - low > high - nz(high[1]) ? math.max(nz(low[1]) - low, 0) : 0

var float SmoothedTrueRange                = na
var float SmoothedDirectionalMovementPlus  = na
var float SmoothedDirectionalMovementMinus = na

SmoothedTrueRange                := nz(SmoothedTrueRange[1]) - (nz(SmoothedTrueRange[1]) / adxLen) + TrueRange
SmoothedDirectionalMovementPlus  := nz(SmoothedDirectionalMovementPlus[1]) - (nz(SmoothedDirectionalMovementPlus[1]) / adxLen) + DirectionalMovementPlus
SmoothedDirectionalMovementMinus := nz(SmoothedDirectionalMovementMinus[1]) - (nz(SmoothedDirectionalMovementMinus[1]) / adxLen) + DirectionalMovementMinus

DIPlus  = SmoothedTrueRange > 0 ? SmoothedDirectionalMovementPlus  / SmoothedTrueRange * 100 : na
DIMinus = SmoothedTrueRange > 0 ? SmoothedDirectionalMovementMinus / SmoothedTrueRange * 100 : na
diSum   = DIPlus + DIMinus
DX      = diSum > 0 ? math.abs(DIPlus - DIMinus) / diSum * 100 : na
ADX     = ta.sma(DX, adxLen)

// ── EMA Scalper Calculations ─────────────────────
out    = ta.ema(src, emaLen)
lastH  = ta.highest(close, hl_len)
lastL  = ta.lowest(close, hl_len)

// ── Direction & Background ─────────────────────
isBull = DIPlus > DIMinus
isBear = DIMinus > DIPlus

color bgColor = na
if showBg
    if ADX > level25 and isBull
        bgColor := bullColor
    else if ADX > level25 and isBear
        bgColor := bearColor
    else if ADX > level20
        bgColor := whiteBg

bgcolor(bgColor, title="ADX Trend Background")

// ── ADX Lines (optional) ─────────────────────
plot(showLines ? DIPlus  : na, color=diPlusCol,  title="+DI", linewidth=2)
plot(showLines ? DIMinus : na, color=diMinusCol, title="-DI", linewidth=2)
plot(showLines ? ADX     : na, color=adxCol,     title="ADX", linewidth=2)

hline(showLines ? level20 : na, "Level 20", color=color.gray)
hline(showLines ? level25 : na, "Level 25", color=color.white)

// ── EMA / High / Low Plots ─────────────────────
plot(showEmaPlots ? out   : na, title="EMA",     color=emaColor)
plot(showEmaPlots ? lastH : na, title="Highest", color=highColor, linewidth=2)
plot(showEmaPlots ? lastL : na, title="Lowest",  color=lowColor,  linewidth=2)

// ── Buy / Sell Signals ─────────────────────
rawBearish = ta.cross(close, out) and close[1] > close
rawBullish = ta.cross(close, out) and close[1] < close

adxOkBull = not useAdxFilter or (isBull and (not onlyStrongAdx or ADX > level25))
adxOkBear = not useAdxFilter or (isBear and (not onlyStrongAdx or ADX > level25))

bearish = showSignals and rawBearish and adxOkBear
bullish = showSignals and rawBullish and adxOkBull

// ── Plotshapes with constant sizes (fixes the error) ─────────────────────
// Sell arrows
plotshape(bearish and arrowSize == "tiny",   style=shape.arrowdown, location=location.abovebar, color=sellArrowColor, text="Sell", textcolor=sellTextColor, size=size.tiny)
plotshape(bearish and arrowSize == "small",  style=shape.arrowdown, location=location.abovebar, color=sellArrowColor, text="Sell", textcolor=sellTextColor, size=size.small)
plotshape(bearish and arrowSize == "normal", style=shape.arrowdown, location=location.abovebar, color=sellArrowColor, text="Sell", textcolor=sellTextColor, size=size.normal)

// Buy arrows
plotshape(bullish and arrowSize == "tiny",   style=shape.arrowup, location=location.belowbar, color=buyArrowColor, text="Buy", textcolor=buyTextColor, size=size.tiny)
plotshape(bullish and arrowSize == "small",  style=shape.arrowup, location=location.belowbar, color=buyArrowColor, text="Buy", textcolor=buyTextColor, size=size.small)
plotshape(bullish and arrowSize == "normal", style=shape.arrowup, location=location.belowbar, color=buyArrowColor, text="Buy", textcolor=buyTextColor, size=size.normal)

// ── Alerts ─────────────────────
alertcondition(bullish, title="Trinity Buy",  message="Trinity ADX EMA: Buy Signal")
alertcondition(bearish, title="Trinity Sell", message="Trinity ADX EMA: Sell Signal")

// ── ADX Status Label ─────────────────────
if showAdxLabel and barstate.islast
    string dir = isBull ? "Bull" : isBear ? "Bear" : "Neutral"
    color lblCol = isBull ? color.green : isBear ? color.red : color.gray
    string txt = "ADX: " + str.tostring(ADX, "#.#") + "\n" + dir
    label.new(bar_index, high, txt, 
         style=label.style_label_down, color=color.new(lblCol, 20), 
         textcolor=color.white, size=size.small)
````
