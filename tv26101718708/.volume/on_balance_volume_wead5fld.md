# on Balance Volume 

- url: https://www.tradingview.com/script/WEAD5fld-on-Balance-Volume/
- type: indicator
- pine_id: PUB;2d1a7adc23724abf93164b929badadbe
- version: 1.0

## Description

OBV Pro — Delta + Divergence + Trend
On Balance Volume with delta volume candles showing buying and selling pressure inside each bar. Automatically detects higher highs, lower lows, and real divergences between price and OBV. Includes a trend ribbon, MA cross signals, and volume exhaustion alerts — everything you need to read momentum at a glance.

## Source Code

````pine
//@version=6
indicator(title="OBV Pro — Delta + Divergence + Trend", shorttitle="OBV Pro", format=format.volume, precision=0)

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════════
grpOBV      = "── OBV & MA ──"
maLength    = input.int(20,       "MA Length",            minval=1,  group=grpOBV)
maType      = input.string("EMA", "MA Type",              options=["SMA","EMA","WMA","VWMA"], group=grpOBV)
showMA      = input.bool(true,    "Show MA",              group=grpOBV)
showMACross = input.bool(true,    "Show MA Cross Signals",group=grpOBV)

grpDiv      = "── Divergence ──"
pivotLen    = input.int(5,  "Pivot Bars Each Side",  minval=2, maxval=20,  group=grpDiv)
divWindow   = input.int(40, "Divergence Window",     minval=5, maxval=150, group=grpDiv)
showDiv     = input.bool(true, "Show Divergence Lines",  group=grpDiv)
showLabels  = input.bool(true, "Show Structure Labels",  group=grpDiv)

grpVol      = "── Volume ──"
bullCol     = input.color(color.new(#26a69a, 15), "Buy Color",  group=grpVol)
bearCol     = input.color(color.new(#ef5350, 15), "Sell Color", group=grpVol)

grpTrend    = "── Trend Ribbon ──"
showTrend   = input.bool(true, "Show Trend Ribbon", group=grpTrend)
fastLen     = input.int(10,    "Fast MA",           minval=1, group=grpTrend)
slowLen     = input.int(30,    "Slow MA",           minval=1, group=grpTrend)

// ═══════════════════════════════════════════════════════════════════════════════
// DELTA VOLUME
// ═══════════════════════════════════════════════════════════════════════════════
candleRange = high - low
bullRatio   = candleRange == 0 ? 0.5 : (close - low) / candleRange
buyVol      = volume * bullRatio
sellVol     = volume * (1.0 - bullRatio)

// ═══════════════════════════════════════════════════════════════════════════════
// OBV + SCALING
// ═══════════════════════════════════════════════════════════════════════════════
obv       = ta.obv
obvMin    = ta.lowest(obv,  200)
obvMax    = ta.highest(obv, 200)
volMax    = ta.highest(volume, 200)
denom     = obvMax - obvMin
obvScaled = denom == 0 ? 0.0 : ((obv - obvMin) / denom) * volMax

// ═══════════════════════════════════════════════════════════════════════════════
// MA + TREND RIBBON
// ═══════════════════════════════════════════════════════════════════════════════
ma = switch maType
    "SMA"  => ta.sma(obvScaled, maLength)
    "EMA"  => ta.ema(obvScaled, maLength)
    "WMA"  => ta.wma(obvScaled, maLength)
    "VWMA" => ta.vwma(obvScaled, maLength)

fastRibbon = ta.ema(obvScaled, fastLen)
slowRibbon = ta.ema(obvScaled, slowLen)
ribbonBull = fastRibbon > slowRibbon
ribbonCol  = ribbonBull ? color.new(#26a69a, 78) : color.new(#ef5350, 78)

maCrossUp   = showMACross and ta.crossover(obvScaled, ma)
maCrossDown = showMACross and ta.crossunder(obvScaled, ma)

// ═══════════════════════════════════════════════════════════════════════════════
// PIVOT DETECTION
// ═══════════════════════════════════════════════════════════════════════════════
obvPH   = ta.pivothigh(obvScaled, pivotLen, pivotLen)
obvPL   = ta.pivotlow(obvScaled,  pivotLen, pivotLen)
pricePH = ta.pivothigh(high, pivotLen, pivotLen)
pricePL = ta.pivotlow(low,   pivotLen, pivotLen)

isNewPH      = not na(obvPH)
isNewPL      = not na(obvPL)
confirmedBar = bar_index - pivotLen

// ═══════════════════════════════════════════════════════════════════════════════
// STRUCTURE + DIVERGENCE ENGINE
// ═══════════════════════════════════════════════════════════════════════════════
var float prevPH      = na
var int   prevPH_bar  = na
var float prevPricePH = na
var float prevPL      = na
var int   prevPL_bar  = na
var float prevPricePL = na

bearDivActive = false
bullDivActive = false

if isNewPH
    curPH      = obvPH
    curPricePH = not na(pricePH) ? pricePH : high[pivotLen]

    if not na(prevPH) and not na(prevPricePH)
        // Bearish divergence: price HH, OBV LH
        if curPH < prevPH and curPricePH > prevPricePH and (confirmedBar - prevPH_bar) <= divWindow
            bearDivActive := true
            if showDiv
                line.new(prevPH_bar, prevPH, confirmedBar, curPH,
                     color=color.new(#ef5350, 0), width=1, style=line.style_dashed)
            if showLabels
                label.new(confirmedBar, curPH, "BD",
                     style=label.style_label_down,
                     color=color.new(#ef5350, 0),
                     textcolor=color.white, size=size.tiny)
        else if curPH > prevPH and showLabels
            label.new(confirmedBar, curPH, "HH",
                 style=label.style_label_down,
                 color=color.new(#26a69a, 20),
                 textcolor=color.white, size=size.tiny)
        else if curPH < prevPH and showLabels
            label.new(confirmedBar, curPH, "LH",
                 style=label.style_label_down,
                 color=color.new(#ef5350, 40),
                 textcolor=color.white, size=size.tiny)

    prevPH      := curPH
    prevPH_bar  := confirmedBar
    prevPricePH := curPricePH

if isNewPL
    curPL      = obvPL
    curPricePL = not na(pricePL) ? pricePL : low[pivotLen]

    if not na(prevPL) and not na(prevPricePL)
        // Bullish divergence: price LL, OBV HL
        if curPL > prevPL and curPricePL < prevPricePL and (confirmedBar - prevPL_bar) <= divWindow
            bullDivActive := true
            if showDiv
                line.new(prevPL_bar, prevPL, confirmedBar, curPL,
                     color=color.new(#26a69a, 0), width=1, style=line.style_dashed)
            if showLabels
                label.new(confirmedBar, curPL, "BD",
                     style=label.style_label_up,
                     color=color.new(#26a69a, 0),
                     textcolor=color.white, size=size.tiny)
        else if curPL < prevPL and showLabels
            label.new(confirmedBar, curPL, "LL",
                 style=label.style_label_up,
                 color=color.new(#ef5350, 20),
                 textcolor=color.white, size=size.tiny)
        else if curPL > prevPL and showLabels
            label.new(confirmedBar, curPL, "HL",
                 style=label.style_label_up,
                 color=color.new(#26a69a, 40),
                 textcolor=color.white, size=size.tiny)

    prevPL      := curPL
    prevPL_bar  := confirmedBar
    prevPricePL := curPricePL

// ═══════════════════════════════════════════════════════════════════════════════
// VOLUME EXHAUSTION
// High volume spike + weak OBV response = absorption / potential reversal
// ═══════════════════════════════════════════════════════════════════════════════
volSMA     = ta.sma(volume, 20)
volSpike   = volume > volSMA * 1.8
obvMove    = math.abs(obv - obv[1])
obvMoveSMA = ta.sma(obvMove, 20)
exhaustion = volSpike and obvMove < obvMoveSMA * 0.5

// ═══════════════════════════════════════════════════════════════════════════════
// PLOTS — layered bottom to top for clean visual stacking
// ═══════════════════════════════════════════════════════════════════════════════

// 1. Ghost total volume (faintest layer)
plot(volume, "Total Volume", style=plot.style_columns,
     color=color.new(color.gray, 88))

// 2. Delta columns — sell (red) then buy (teal) stacked on top
plot(sellVol, "Sell Volume", style=plot.style_columns, color=bearCol)
plot(buyVol,  "Buy Volume",  style=plot.style_columns, color=bullCol)

// 3. Exhaustion diamond at top of the spike bar
plotshape(exhaustion ? volume : na, "Exhaustion",
     shape.diamond, location.absolute,
     color=color.new(#f5a623, 0), size=size.tiny)

// 4. Trend ribbon (filled area between fast/slow EMA of OBV)
p1 = plot(showTrend ? fastRibbon : na, "Fast Ribbon", color=na, editable=false)
p2 = plot(showTrend ? slowRibbon : na, "Slow Ribbon", color=na, editable=false)
fill(p1, p2, color=showTrend ? ribbonCol : na, title="Trend Ribbon")

// 5. MA line
plot(showMA ? ma : na, "OBV MA",
     color=color.new(#b2b5be, 35), linewidth=1, style=plot.style_line)

// 6. OBV line on top — color flips with trend ribbon
obvLineCol = ribbonBull ? color.new(#26c6da, 0) : color.new(#ef5350, 0)
plot(obvScaled, "OBV", color=obvLineCol, linewidth=2)

// 7. Confirmed swing dots directly on the OBV line
plotshape(isNewPH ? obvScaled[0] : na, "Swing High",
     shape.circle, location.absolute,
     color=color.new(#ffffff, 30), size=size.tiny)
plotshape(isNewPL ? obvScaled[0] : na, "Swing Low",
     shape.circle, location.absolute,
     color=color.new(#ffffff, 30), size=size.tiny)

// 8. MA cross arrows — tiny, just below/above the OBV line
plotshape(maCrossUp   ? obvScaled : na, "Cross Up",
     shape.triangleup,   location.absolute,
     color=color.new(#26a69a, 0), size=size.tiny)
plotshape(maCrossDown ? obvScaled : na, "Cross Down",
     shape.triangledown, location.absolute,
     color=color.new(#ef5350, 0), size=size.tiny)

// 9. Zero baseline
hline(0, "Zero", color=color.new(color.gray, 65), linestyle=hline.style_dashed)

// ═══════════════════════════════════════════════════════════════════════════════
// BACKGROUND FLASHES
// ═══════════════════════════════════════════════════════════════════════════════
bgcolor(bearDivActive ? color.new(#ef5350, 90) : na, title="Bear Div BG")
bgcolor(bullDivActive ? color.new(#26a69a, 90) : na, title="Bull Div BG")
bgcolor(exhaustion    ? color.new(#f5a623, 93) : na, title="Exhaustion BG")

// ═══════════════════════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════════════════════
alertcondition(bullDivActive, "Bullish Divergence", "OBV Bull Div — price LL, OBV HL")
alertcondition(bearDivActive, "Bearish Divergence", "OBV Bear Div — price HH, OBV LH")
alertcondition(maCrossUp,     "OBV Cross Up",       "OBV crossed above MA — bullish")
alertcondition(maCrossDown,   "OBV Cross Down",     "OBV crossed below MA — bearish")
alertcondition(exhaustion,    "Volume Exhaustion",  "Volume spike, weak OBV — possible reversal")
````
