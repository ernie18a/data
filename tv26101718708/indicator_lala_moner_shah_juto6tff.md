# indicator lala moner shah 

- url: https://www.tradingview.com/script/jUto6TFf-indicator-lala-moner-shah/
- type: indicator
- pine_id: PUB;6f6cd9e1875441e2be81f80ab6c9fe68
- version: 1.0

## Description

just do it it will make you profit but the risk is for you i am already doing it

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo

//@version=6
indicator("Five Essential Price Action Patterns", overlay = true, max_boxes_count = 500, max_lines_count = 500)

// --- Groups ---
string G_FVG = "Fair Value Gaps"
string G_ENG = "Engulfing Candles"
string G_SFP = "Swing Failure Patterns"
string G_BR  = "Break and Retest"
string G_REJ = "Rejections"

// --- Inputs ---
showFvg   = input.bool(true, "Show Fair Value Gaps", group = G_FVG)
fvgColorB = input.color(color.new(#089981, 80), "Bullish FVG", group = G_FVG)
fvgColorS = input.color(color.new(#f23645, 80), "Bearish FVG", group = G_FVG)

showEng   = input.bool(true, "Show Engulfing Candles", group = G_ENG)
engColorB = input.color(#089981, "Bullish Engulfing", group = G_ENG)
engColorS = input.color(#f23645, "Bearish Engulfing", group = G_ENG)
engFilter = input.bool(true, "Filter Engulfing by Trend", group = G_ENG)
engEmaLen = input.int(200, "Trend EMA Length", minval = 1, group = G_ENG)

showSfp   = input.bool(true, "Show Swing Failure Patterns", group = G_SFP)
sfpLook   = input.int(20, "SFP Lookback (Bars)", minval = 5, group = G_SFP)
sfpColor  = input.color(#5b9cf6, "SFP Color", group = G_SFP)

showBr    = input.bool(true, "Show Break and Retest", group = G_BR)
brColor   = input.color(#808080, "Break/Retest Color", group = G_BR)

showRej   = input.bool(true, "Show Rejections", group = G_REJ)
rejMult   = input.float(2.0, "Wick to Body Multiplier", minval = 1.0, group = G_REJ)
rejColor  = input.color(color.new(#5b9cf6, 50), "Rejection Color", group = G_REJ)

// --- 1. Fair Value Gaps (FVG) ---
bool isBullFvg = showFvg and low > high[2] and close[1] > high[2]
bool isBearFvg = showFvg and high < low[2] and close[1] < low[2]

if isBullFvg
    box.new(bar_index - 2, low, bar_index, high[2], border_color = color.new(fvgColorB, 50), bgcolor = fvgColorB)
if isBearFvg
    box.new(bar_index - 2, high, bar_index, low[2], border_color = color.new(fvgColorS, 50), bgcolor = fvgColorS)

// --- 2. Engulfing Candles ---
emaFilter = ta.ema(close, engEmaLen)
bool bullEng = showEng and close > open and close[1] < open[1] and close >= open[1] and open <= close[1] and (not engFilter or close > emaFilter)
bool bearEng = showEng and close < open and close[1] > open[1] and close <= open[1] and open >= close[1] and (not engFilter or close < emaFilter)

plotshape(bullEng, "Bullish Engulfing", shape.triangleup, location.belowbar, engColorB, size = size.small)
plotshape(bearEng, "Bearish Engulfing", shape.triangledown, location.abovebar, engColorS, size = size.small)

// --- 3. Swing Failure Patterns (SFP) ---
float hh = ta.highest(high, sfpLook)[1]
float ll = ta.lowest(low, sfpLook)[1]

bool bullSfp = showSfp and low < ll and close > ll
bool bearSfp = showSfp and high > hh and close < hh

plotshape(bullSfp, "Bullish SFP", shape.labelup, location.belowbar, sfpColor, text = "SFP", textcolor = color.white, size = size.small)
plotshape(bearSfp, "Bearish SFP", shape.labeldown, location.abovebar, sfpColor, text = "SFP", textcolor = color.white, size = size.small)

// --- 4. Break and Retest ---
float ph = ta.pivothigh(high, 5, 5)
float pl = ta.pivotlow(low, 5, 5)

float levelPrice = ta.valuewhen(not na(ph) or not na(pl), not na(ph) ? ph : pl, 0)
bool  isLevelH   = ta.valuewhen(not na(ph) or not na(pl), not na(ph), 0)

var int breakBar = 0
if not na(levelPrice)
    if (isLevelH and ta.crossover(close, levelPrice)) or (not isLevelH and ta.crossunder(close, levelPrice))
        breakBar := bar_index

bool isRetest = showBr and not na(levelPrice) and bar_index > breakBar and (bar_index - breakBar) < 50 and (isLevelH ? (low <= levelPrice and close > levelPrice) : (high >= levelPrice and close < levelPrice))

plotshape(isRetest, "Retest", shape.circle, location.belowbar, brColor, size = size.tiny, text = "Retest", textcolor = brColor)

// --- 5. Rejections ---
float bS = math.abs(close - open)
float uW = high - math.max(open, close)
float lW = math.min(open, close) - low

bool tR = showRej and uW > bS * rejMult
bool bR = showRej and lW > bS * rejMult

plotshape(tR, "Top Rejection", shape.arrowdown, location.abovebar, rejColor, size = size.tiny)
plotshape(bR, "Bottom Rejection", shape.arrowup, location.belowbar, rejColor, size = size.tiny)

// --- Alerts ---
alertcondition(isBullFvg or isBearFvg, "FVG Formed", "A Fair Value Gap has been detected.")
alertcondition(bullEng or bearEng, "Engulfing Candle", "An Engulfing candle pattern has formed.")
alertcondition(bullSfp or bearSfp, "SFP Pattern", "A Swing Failure Pattern has formed.")
alertcondition(isRetest, "Level Retest", "A price level retest has occurred.")
````
