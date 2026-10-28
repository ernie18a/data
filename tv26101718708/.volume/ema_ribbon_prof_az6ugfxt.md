# EMA Ribbon [prof]

- url: https://www.tradingview.com/script/az6UgFXt-EMA-Ribbon-prof/
- type: indicator
- pine_id: PUB;211f61bf271b4debb15eb930e37d01ef
- version: 12.0

## Description

# EMA Ribbon [prof] —  

## Overview

EMA Ribbon [prof] plots eight Exponential Moving Averages (EMAs) with staggered periods (default 24 down to 10) stacked on top of each other, forming a visual "ribbon" that reflects the current trend's direction and strength. When the eight lines are spread apart and neatly ordered, it signals a strong, clear trend; when the lines tangle and cross each other, it signals a choppy, range-bound market with no clear direction.

The indicator is designed to run directly on the price chart (overlay) and works on any market (stocks, forex, crypto, indices) and any timeframe.

## Key Features

- Eight EMAs with fully adjustable periods from the settings.
- Selectable price source (Close, High, Low, etc.) — defaults to High.
- "Drop first N candles" option to ignore a chosen number of the earliest candles before calculations start.
- "Offset" option to shift the ribbon left or right on the chart without affecting its underlying calculations.
- Automatic buy/sell signals (circles below/above the bar) triggered when price breaks through the entire ribbon to the upside or downside.
- Bar coloring (green/red) based on whether price is above or below the ribbon's midline, for quick at-a-glance trend reading.
- Full control over each line's color and thickness from the Style tab.

## How to Use It

- **Trend direction:** When price is above the ribbon and the lines are stacked with the shortest EMA on top, it supports a continuing uptrend; the mirror image supports a downtrend.
- **Trend strength:** The wider the gap between the lines, the stronger the momentum behind the move.
- **Dynamic support/resistance:** The ribbon itself can act as a dynamic support zone in an uptrend, or a dynamic resistance zone in a downtrend.
- **Signals:** The buy signal fires when price breaks above the highest point of the entire ribbon; the sell signal fires when price breaks below the lowest point. Treat these as additional confirmation, not standalone trade calls.
- It's best used alongside other tools (volume, support/resistance levels, momentum indicators) rather than relied on in isolation.

## Settings

| Setting | Description | Default |
|---|---|---|
| MA-1 to MA-8 period | Periods of the eight EMAs | 24, 22, 20, 18, 16, 14, 12, 10 |
| Source | Price source used for calculations | High |
| Drop first N candles | Number of leading candles excluded from calculations | 0 |
| Offset (Shift Ribbon) | Shifts the ribbon left/right on the chart | 8 |
| Show Buy/Sell Signals | Toggles the buy/sell signal markers | Enabled |
| Color Candles Above/Below Ribbon | Colors bars based on their position relative to the ribbon | Enabled |

## Disclaimer

This indicator is a technical analysis tool, not investment advice or a recommendation to buy or sell. Past performance does not guarantee future results. Users are solely responsible for their own trading decisions and should always apply independent risk and capital management before acting on any signal.

## Source Code

````pine
//@version=6
// ==========================================================================
// EMA Ribbon [prof] + RSI on Chart (plan z) + Liquidity Levels + Golden Zone
// --------------------------------------------------------------------------
// إصدار مبسّط: جميع الإعدادات مخفية — فقط تفعيل/إغلاق المؤشر
// ==========================================================================
indicator(title="EMA Ribbon + RSI + Liquidity + Golden Zone [BETA - Lab Test]", shorttitle="prof Lab ", overlay=true, max_lines_count=500)

// مفتاح التفعيل الوحيد للمؤشر كامل
enableIndicator = input.bool(true, title="🔴 Enable Indicator (تفعيل/إغلاق المؤشر)", group="Main Control")

// دالة مساعدة تُستخدم مع "Drop first N candles"
dropn(src, n) =>
    na(src[n]) ? na : src

// ==========================================================================
// ============================  1) EMA Ribbon  ============================
// ==========================================================================

// قيم EMA الثابتة (مخفية)
length1 = 24
length2 = 22
length3 = 20
length4 = 18
length5 = 16
length6 = 14
length7 = 12
length8 = 8
src = high
dropCandles = 0
offsetInput = 8
showSignals = true
colorCandles = false
showLines = false
showCloud = true
cloudUpIn  = color.new(#4caf50, 15)
cloudUpOut = color.new(#1e3d22, 15)
cloudDnIn  = color.new(#9e9e9e, 30)
cloudDnOut = color.new(#e0e0e0, 20)

price = dropn(src, dropCandles)

ma1 = enableIndicator ? ta.ema(price, length1) : na
ma2 = enableIndicator ? ta.ema(price, length2) : na
ma3 = enableIndicator ? ta.ema(price, length3) : na
ma4 = enableIndicator ? ta.ema(price, length4) : na
ma5 = enableIndicator ? ta.ema(price, length5) : na
ma6 = enableIndicator ? ta.ema(price, length6) : na
ma7 = enableIndicator ? ta.ema(price, length7) : na
ma8 = enableIndicator ? ta.ema(price, length8) : na

p1 = plot(ma1, color=showLines ? #1f3a93 : na, linewidth=2, offset=offsetInput)
plot(ma2, color=showLines ? #2e5fb5 : na, linewidth=2, offset=offsetInput)
plot(ma3, color=showLines ? #3d82e0 : na, linewidth=2, offset=offsetInput)
p4 = plot(ma4, color=showLines ? #6babf0 : na, linewidth=2, offset=offsetInput)
plot(ma5, color=showLines ? #a8d4f5 : na, linewidth=2, offset=offsetInput)
plot(ma6, color=showLines ? #4dd0c4 : na, linewidth=2, offset=offsetInput)
plot(ma7, color=showLines ? #26a69a : na, linewidth=2, offset=offsetInput)
p8 = plot(ma8, color=showLines ? #1a8a7a : na, linewidth=2, offset=offsetInput)

cloudBull = enableIndicator and ma8 >= ma1
fill(p8, p4, color=enableIndicator and showCloud ? (cloudBull ? cloudUpIn  : cloudDnIn)  : na)
fill(p4, p1, color=enableIndicator and showCloud ? (cloudBull ? cloudUpOut : cloudDnOut) : na)

topBand = enableIndicator ? math.max(math.max(math.max(ma1, ma2), math.max(ma3, ma4)), math.max(math.max(ma5, ma6), math.max(ma7, ma8))) : na
bottomBand = enableIndicator ? math.min(math.min(math.min(ma1, ma2), math.min(ma3, ma4)), math.min(math.min(ma5, ma6), math.min(ma7, ma8))) : na

offBars       = math.max(offsetInput, 0)
topBandVis    = enableIndicator ? topBand[offBars] : na
bottomBandVis = enableIndicator ? bottomBand[offBars] : na

buySignal = enableIndicator and showSignals and ta.crossover(price, topBandVis)
sellSignal = enableIndicator and showSignals and ta.crossunder(price, bottomBandVis)

plotshape(buySignal, style=shape.circle, location=location.belowbar, color=color.lime, size=size.tiny)
plotshape(sellSignal, style=shape.circle, location=location.abovebar, color=color.red, size=size.tiny)

alertcondition(buySignal, title="EMA Ribbon Breakout Up (Buy)",
     message="{{ticker}} ({{interval}}): السعر اخترق كل مستويات شريط EMA صعوداً")
alertcondition(sellSignal, title="EMA Ribbon Breakout Down (Sell)",
     message="{{ticker}} ({{interval}}): السعر كسر كل مستويات شريط EMA هبوطاً")

midBand = enableIndicator ? (ma1 + ma2 + ma3 + ma4 + ma5 + ma6 + ma7 + ma8) / 8 : na
candleColor = enableIndicator and price > midBand ? color.lime : enableIndicator and price < midBand ? color.red : na


// ==========================================================================
// ========================  2) RSI on Chart (plan z)  =====================
// ==========================================================================

rsiperiod = 250
labels    = false
ema_col   = color.rgb(0, 255, 170)

exponential_period    = 2 * rsiperiod - 1
smoothing_coefficient = 2 / (exponential_period + 1)

emaresult(level) =>
    averageUp   = 0.0
    averageDown = 0.0
    averageUp   := close > close[1] ? smoothing_coefficient * (close - close[1]) + (1 - smoothing_coefficient) * nz(averageUp[1], 1) : (1 - smoothing_coefficient) * nz(averageUp[1], 1)
    averageDown := close > close[1] ? (1 - smoothing_coefficient) * nz(averageDown[1], 1) : smoothing_coefficient * (close[1] - close) + (1 - smoothing_coefficient) * nz(averageDown[1], 1)
    netValue    = (rsiperiod - 1) * (averageDown * level / (100 - level) - averageUp)
    result      = netValue >= 0 ? close + netValue : close + netValue * (100 - level) / level
    result

ema_result = enableIndicator ? emaresult(50) : na

ema_color = enableIndicator and close > ema_result ? color.rgb(130, 229, 133) : color.red

plot(ema_result, color=enableIndicator ? ema_color : na, linewidth=2)

rsiCrossUp   = enableIndicator and ta.crossover(close, ema_result)
rsiCrossDown = enableIndicator and ta.crossunder(close, ema_result)

plotshape(rsiCrossUp, style=shape.triangleup, location=location.belowbar, color=color.aqua, size=size.tiny)
plotshape(rsiCrossDown, style=shape.triangledown, location=location.abovebar, color=color.orange, size=size.tiny)

alertcondition(rsiCrossUp, title="RSI 50 Cross Up",
     message="{{ticker}} ({{interval}}): السعر اخترق خط RSI 50 صعوداً")
alertcondition(rsiCrossDown, title="RSI 50 Cross Down",
     message="{{ticker}} ({{interval}}): السعر كسر خط RSI 50 هبوطاً")

labelfunc(bool_, n, line_, text_, label_col, text_col, size_) =>
    label l = bool_ ? label.new(bar_index + n, line_, text=text_, color=label_col,
      style=label.style_label_left, textcolor=text_col, size=size_,
      textalign=text.align_left) : na
    label.delete(l[1])

labelfunc(enableIndicator and labels, 5, ema_result, "RSI 50", color.blue, color.white, size.small)

// ==========================================================================
// ==========================  3) Liquidity Levels  =========================
// ==========================================================================

lookback   = 15
extendBars = 5
lineWidth  = 2
useRange     = true
barsToCheck  = 200

inRange = not useRange or (bar_index >= last_bar_index - barsToCheck)

liquidity            = volume
high_liquidity_candle = enableIndicator and liquidity == ta.highest(liquidity, lookback) and inRange

midpoint = (high + low) / 2

var float stored_midpoint = na
if high_liquidity_candle
    stored_midpoint := midpoint

barcolor(high_liquidity_candle ? color.yellow : na)

if enableIndicator and not na(stored_midpoint)
    line_color = close > stored_midpoint ? color.green : color.red
    line.new(x1=bar_index, y1=stored_midpoint, x2=bar_index + extendBars, y2=stored_midpoint, width=lineWidth, color=line_color)

liqOpenAbove = enableIndicator and not na(stored_midpoint) and ta.crossover(open, stored_midpoint)
liqOpenBelow = enableIndicator and not na(stored_midpoint) and ta.crossunder(open, stored_midpoint)

plotshape(liqOpenAbove, style=shape.triangleup, location=location.belowbar, color=color.green, size=size.tiny)
plotshape(liqOpenBelow, style=shape.triangledown, location=location.abovebar, color=color.red, size=size.tiny)

alertcondition(liqOpenAbove, title="Liquidity Mid - Candle Open Above", message="{{ticker}} ({{interval}}): شمعة فتحت فوق خط منتصف السيولة")
alertcondition(liqOpenBelow, title="Liquidity Mid - Candle Open Below", message="{{ticker}} ({{interval}}): شمعة فتحت تحت خط منتصف السيولة")

// ==========================================================================
// ===== تنبيه مركّب: اختراق EMA + موقع فتح الشمعة من خط السيولة =====
// ==========================================================================
buyCombo  = enableIndicator and ta.crossover(price, topBandVis) and not na(stored_midpoint) and open > stored_midpoint
sellCombo = enableIndicator and ta.crossunder(price, bottomBandVis) and not na(stored_midpoint) and open < stored_midpoint

plotshape(buyCombo, style=shape.labelup, location=location.belowbar, color=color.new(color.lime, 0), textcolor=color.black, text="BUY", size=size.small)
plotshape(sellCombo, style=shape.labeldown, location=location.abovebar, color=color.new(color.red, 0), textcolor=color.white, text="SELL", size=size.small)

alertcondition(buyCombo, title="Combo BUY (EMA Breakout Up + Open Above Liq)",
     message="{{ticker}} ({{interval}}): شراء — اختراق EMA صعوداً مع فتح الشمعة فوق خط السيولة")
alertcondition(sellCombo, title="Combo SELL (EMA Breakout Down + Open Below Liq)",
     message="{{ticker}} ({{interval}}): بيع — كسر EMA هبوطاً مع فتح الشمعة تحت خط السيولة")

// ==========================================================================
// ============================  4) Golden Zone  ============================
// ==========================================================================

showGoldenZone = true
gzLookback     = 10
gzColor        = color.new(color.yellow, 80)
showGZLines    = true
gzLineColor    = color.new(color.yellow, 20)

var float gzSwingHigh = na
var float gzSwingLow  = na
var int   gzHighIdx   = na
var int   gzLowIdx    = na

gzPvtHi = enableIndicator ? ta.pivothigh(high, gzLookback, gzLookback) : na
gzPvtLo = enableIndicator ? ta.pivotlow(low, gzLookback, gzLookback) : na

if not na(gzPvtHi)
    gzSwingHigh := gzPvtHi
    gzHighIdx   := bar_index - gzLookback
if not na(gzPvtLo)
    gzSwingLow := gzPvtLo
    gzLowIdx   := bar_index - gzLookback

gzFib(v) =>
    float result = na
    if not na(gzSwingHigh) and not na(gzSwingLow)
        result := gzLowIdx < gzHighIdx ? gzSwingHigh - (gzSwingHigh - gzSwingLow) * v : gzSwingLow + (gzSwingHigh - gzSwingLow) * v
    result

gzLevel50  = enableIndicator ? gzFib(0.5) : na
gzLevel618 = enableIndicator ? gzFib(0.618) : na

var line     gzLine50  = na
var line     gzLine618 = na
var linefill gzFill    = na

if enableIndicator and showGoldenZone and not na(gzLevel50) and not na(gzLevel618)
    gzStartIdx = math.min(gzHighIdx, gzLowIdx)
    if na(gzLine50)
        gzLine50  := line.new(gzStartIdx, gzLevel50, bar_index, gzLevel50, color=gzLineColor, width=1)
        gzLine618 := line.new(gzStartIdx, gzLevel618, bar_index, gzLevel618, color=gzLineColor, width=1)
        gzFill    := linefill.new(gzLine50, gzLine618, gzColor)
    line.set_xy1(gzLine50, gzStartIdx, gzLevel50)
    line.set_xy2(gzLine50, bar_index, gzLevel50)
    line.set_xy1(gzLine618, gzStartIdx, gzLevel618)
    line.set_xy2(gzLine618, bar_index, gzLevel618)
    line.set_color(gzLine50, showGZLines ? gzLineColor : color.new(color.white, 100))
    line.set_color(gzLine618, showGZLines ? gzLineColor : color.new(color.white, 100))

// ==========================================================================
// ==========================  5) Price MA on Chart  ========================
// ==========================================================================

pma_src    = high
pma_len    = 88
pma_type   = "SMA"
pma_offset = 20
pma_up     = color.rgb(38, 166, 154)
pma_down   = color.rgb(239, 83, 80)

pma_line = switch pma_type
    "SMA" => enableIndicator ? ta.sma(pma_src, pma_len) : na
    "EMA" => enableIndicator ? ta.ema(pma_src, pma_len) : na
    "WMA" => enableIndicator ? ta.wma(pma_src, pma_len) : na
    => enableIndicator ? ta.rma(pma_src, pma_len) : na

pma_color = enableIndicator and close >= pma_line ? pma_up : pma_down

plot(pma_line, color=enableIndicator ? pma_color : na, linewidth=2, offset=pma_offset)

// ==========================================================================
// =====================  6) Last Liquidity Candle Box  =====================
// ==========================================================================

showLiqBox = true
lbUpColor  = color.new(color.green, 65)
lbDnColor  = color.new(color.red, 65)
lbExtend   = 3

var box lbUp = na
var box lbDn = na

if enableIndicator and showLiqBox and high_liquidity_candle
    box.delete(lbUp)
    box.delete(lbDn)
    lbUp := box.new(bar_index, high, bar_index + lbExtend, midpoint,
         border_color=color.new(lbUpColor, 0), bgcolor=lbUpColor)
    lbDn := box.new(bar_index, midpoint, bar_index + lbExtend, low,
         border_color=color.new(lbDnColor, 0), bgcolor=lbDnColor)

if enableIndicator and showLiqBox and not na(lbUp)
    box.set_right(lbUp, bar_index + lbExtend)
    box.set_right(lbDn, bar_index + lbExtend)
````
