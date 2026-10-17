# Market Map

- url: https://www.tradingview.com/script/yAlbWTOW-market-map/
- type: indicator
- pine_id: PUB;902cce2c6f754193a0c364e19346417b
- version: 1.0

## Description

MarketStructureLab - Market Map

  Market Map is a visual market context indicator designed to help traders read the chart structure more clearly.

The tool does not generate buy or sell signals. Instead, it focuses on mapping the current market environment by highlighting important support and resistance zones, premium / balance / discount areas, projected dynamic trend lines, and a compact dashboard with simple market context readings.

The main idea behind this indicator is to answer a few practical questions:

Where is price trading now?
Is it close to support or resistance?
Is price located in the upper, middle, or lower part of the recent range?
Who currently has more control according to the trend context: buyers, sellers, or neither side?
How much room is there to the nearest support or resistance area?

━━━━━━━━━━━━━━━━━━━━━━
📌 WHAT THE INDICATOR SHOWS
━━━━━━━━━━━━━━━━━━━━━━

1. Support and Resistance Zones

The indicator builds support and resistance areas from clustered pivot highs and pivot lows.

A resistance zone appears where price has previously reacted from above.
A support zone appears where price has previously held from below.

These zones are not exact prediction levels. They are visual areas where price has shown previous market interest and where traders may want to pay closer attention.

2. Premium / Balance / Discount Areas

The script divides the recent price range into three visual areas:

Premium area — the upper part of the range.
Balance area — the middle part of the range.
Discount area — the lower part of the range.

This helps traders understand whether price is currently high, low, or balanced within the recent market structure.

3. Dynamic Trend Lines

The indicator can project dynamic trend lines from recent pivot highs and pivot lows.

The red projected line represents the slope of recent highs.
The green projected line represents the slope of recent lows.

These lines are designed for visual structure reading only. They are not automatic entry or exit signals.

4. Dashboard

The dashboard gives a compact summary of the current market context:

Market — bullish, bearish, or neutral trend context based on EMA structure.
Zone — current location of price: support, resistance, premium, discount, balance, or middle.
Control — whether buyers, sellers, or neither side have the current edge.
Room — approximate distance from the current price to nearby resistance and support.
Focus — a simple note on what area deserves attention.

━━━━━━━━━━━━━━━━━━━━━━
🧭 HOW TO USE IT
━━━━━━━━━━━━━━━━━━━━━━

This indicator is best used as a market map.

It can help traders prepare before making decisions by showing the current chart environment in a cleaner and more structured way.

A simple workflow may look like this:

1. Check whether price is near a support or resistance zone.
2. Look at whether price is in premium, balance, or discount.
3. Read the dashboard to understand the current market context.
4. Use the dynamic trend lines to review the slope of recent structure.
5. Combine the map with your own strategy, confirmation tools, and risk management.

━━━━━━━━━━━━━━━━━━━━━━
⚠️ IMPORTANT LIMITATIONS
━━━━━━━━━━━━━━━━━━━━━━

This script does not provide financial advice.
It does not predict future price movement.
It does not guarantee profitable trades.
It does not execute trades.
It does not provide automatic buy or sell signals.
It should not be used as a standalone trading system.

Support and resistance zones are based on historical price structure and may fail at any time. Market conditions can change quickly, especially during high volatility, earnings events, news releases, or low-liquidity periods.

Every trader is responsible for their own analysis, validation, risk management, position sizing, and trading decisions.

━━━━━━━━━━━━━━━━━━━━━━
✅ BEST USED FOR
━━━━━━━━━━━━━━━━━━━━━━

Market structure reading
Support and resistance analysis
Range location analysis
Trend context review
Visual chart preparation
Beginner-friendly market mapping
Multi-timeframe context building

Suggested timeframes: H1 and above.

━━━━━━━━━━━━━━━━━━━━━━
🛡️ DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━

MarketStructureLab - Market Map is provided for educational and informational purposes only.

It is a visual chart analysis tool, not financial, investment, or trading advice. No indicator can guarantee future results. Always do your own research and use proper risk management before making any trading decision.
[url=https://www.tradingview.com/x/GN0MfyPd/]https://www.tradingview.com/x/GN0MfyPd/[/url][image]https://www.tradingview.com/x/GN0MfyPd/[/image]

## Source Code

````pine
// This source code is subject to the terms of the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) license.
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarketStructureLab
// MSL Market Map, developed by MarketStructureLab.
// May your trades be green and your stops never hit. Good luck out there.
//@version=6
indicator("MarketStructureLab - Market Map", "MSL Map", overlay=true, max_lines_count=200, max_labels_count=100, max_boxes_count=100, max_bars_back=1000)
//==== INPUTS ============================================================
groupCalc   = "Core Settings"
groupZones  = "Zones & Range"
groupTrend  = "Trend Lines"
groupVisual = "Visuals"
groupTable  = "Dashboard"
// Core
useAutoPivots    = input.bool(true, "Auto Pivots by Timeframe", group=groupCalc, display=display.none, tooltip="On: pivot left/right bars are picked automatically (3 below H1, 5 on H1 and above). Off: use the manual values below.")
manualPivotLeft  = input.int(5, "Manual Pivot Left Bars",  minval=1, maxval=50, group=groupCalc, display=display.none, active=not useAutoPivots, tooltip="Bars to the left a high/low must dominate to count as a pivot. Higher = fewer, stronger pivots. Used only when Auto Pivots is off.")
manualPivotRight = input.int(5, "Manual Pivot Right Bars", minval=1, maxval=50, group=groupCalc, display=display.none, active=not useAutoPivots, tooltip="Bars to the right needed to confirm a pivot. Higher = later but more reliable confirmation. Used only when Auto Pivots is off.")
atrLen           = input.int(14, "ATR Length", minval=1, maxval=100, group=groupCalc, display=display.none, tooltip="ATR period that sets zone thickness. Higher = smoother, thicker zones. Lower = tighter, more reactive zones.")
trendFastLen     = input.int(20, "Fast Trend EMA", minval=1, group=groupCalc, display=display.none, tooltip="Fast EMA for the dashboard Market / Control reading. Lower = more reactive trend context.")
trendSlowLen     = input.int(50, "Slow Trend EMA", minval=1, group=groupCalc, display=display.none, tooltip="Slow EMA for the dashboard Market / Control reading. Higher = steadier trend context.")
// Zones & range
showSRZones      = input.bool(true, "Show Support / Resistance Zones", group=groupZones, display=display.none, tooltip="Toggle the support and resistance zone boxes built from clustered pivots.")
srLookbackBars   = input.int(220, "S/R Zone Lookback Bars", minval=50, maxval=1000, group=groupZones, display=display.none, active=showSRZones, tooltip="How many bars back pivots are kept for zone building. Higher = zones from older structure. Lower = only recent structure.")
clusterMult      = input.float(0.50, "Zone Width (ATR x)", minval=0.10, maxval=3.0, step=0.05, group=groupZones, display=display.none, active=showSRZones, tooltip="Zone thickness as a multiple of ATR. Higher = thicker zones that catch more pivots. Lower = tighter zones.")
minClusterPivots = input.int(2, "Min Pivots per Zone", minval=1, maxval=10, group=groupZones, display=display.none, active=showSRZones, tooltip="How many nearby pivots must agree before a level becomes a zone. Higher = stronger, rarer zones.")
showRangeClouds  = input.bool(true, "Show Premium / Balance / Discount", group=groupZones, display=display.none, tooltip="Toggle the premium (top), balance (middle) and discount (bottom) range clouds.")
rangeLookback    = input.int(160, "Range Lookback Bars", minval=50, maxval=500, group=groupZones, display=display.none, active=showRangeClouds, tooltip="Window used to measure the high/low range for the premium and discount clouds. Higher = wider, slower range.")
// Trend lines
showTrendlines      = input.bool(true, "Show Dynamic Trend Lines", group=groupTrend, display=display.none, tooltip="Toggle the projected dynamic support and resistance trend lines drawn from the last pivots.")
trendPivotMemory    = input.int(5, "Pivot Memory", minval=2, maxval=20, group=groupTrend, display=display.none, active=showTrendlines, tooltip="How many recent pivots are remembered for the slope. Higher = smoother, slower trend lines.")
trendProjectionBars = input.int(40, "Projection Bars", minval=10, maxval=300, group=groupTrend, display=display.none, active=showTrendlines, tooltip="How far to the right the trend line is projected. Higher = longer forward projection.")
// Visuals
showZoneLabels  = input.bool(true, "Show Friendly Zone Labels", group=groupVisual, display=display.none, tooltip="Toggle the plain-language labels (Resistance zone, Balance area, Support zone) to the right of price.")
labelOffsetBars = input.int(10, "Label Offset (bars right)", minval=1, maxval=100, group=groupVisual, display=display.none, active=showZoneLabels, tooltip="How far to the right of the last bar the labels sit. Higher = labels further from price.")
bullColor = input.color(color.lime, "Support / Discount",   inline="zoneClr", group=groupVisual, display=display.none, tooltip="Colour for support zones and the discount (lower) range area.")
bearColor = input.color(color.red,  "Resistance / Premium", inline="zoneClr", group=groupVisual, display=display.none, tooltip="Colour for resistance zones and the premium (upper) range area.")
zoneFillT = input.int(86, "Zone Fill Transparency", minval=0, maxval=100, group=groupVisual, display=display.none, tooltip="Higher = more transparent zone and cloud fills. Lower = more solid fills.")
// Dashboard
showDashboard = input.bool(true, "Show Dashboard", group=groupTable, display=display.none, tooltip="Toggle the compact market context dashboard.")
tablePos      = input.string("Top Right", "Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group=groupTable, display=display.none, active=showDashboard, tooltip="Dashboard position on the chart.")
//==== COLORS ============================================================
textColor      = color.white
neutralColor   = color.gray
bullSoft       = color.new(bullColor, zoneFillT)
bearSoft       = color.new(bearColor, zoneFillT)
balanceSoft    = color.new(neutralColor, zoneFillT)
headerBg       = #1e222d
leftColBg      = #252833
rightNeutralBg = #2a2e39
borderColor    = #373a46
//==== HELPERS ===========================================================
safeDiv(float num, float den, float fallback) =>
    (na(num) or na(den) or den == 0.0) ? fallback : (num / den)
getPos(string p) =>
    p == "Top Left" ? position.top_left : p == "Top Right" ? position.top_right : p == "Bottom Left" ? position.bottom_left : p == "Bottom Right" ? position.bottom_right : position.middle_right
findCluster(array<float> pivots, float threshold, int minPivots) =>
    float zone = na
    int sz = array.size(pivots)
    if sz > 0
        for i = 0 to sz - 1
            float current = array.get(pivots, i)
            int hits = 0
            for j = 0 to sz - 1
                if math.abs(current - array.get(pivots, j)) <= threshold
                    hits += 1
            if hits >= minPivots
                zone := current
                break
    zone
timeBack(int barsBack) =>
    int off = bar_index > barsBack ? barsBack : bar_index
    time[off]
makeLabel(label oldLabel, int xOffset, float y, string txt, color bgColor) =>
    label.delete(oldLabel)
    label.new(x=bar_index + xOffset, y=y, text=txt, xloc=xloc.bar_index, style=label.style_label_left, textcolor=textColor, color=bgColor, size=size.small)
//==== CALCULATIONS ======================================================
// Auto pivot sizing by timeframe
tfSec      = timeframe.in_seconds(timeframe.period)
isBelow1H  = tfSec < 3600
autoPivot  = isBelow1H ? 3 : 5
pivotLeft  = useAutoPivots ? autoPivot : manualPivotLeft
pivotRight = useAutoPivots ? autoPivot : manualPivotRight
// Volatility and raw pivots
volatility      = ta.atr(atrLen)
clusterDistance = volatility * clusterMult
pivotH = ta.pivothigh(high, pivotLeft, pivotRight)
pivotL = ta.pivotlow(low, pivotLeft, pivotRight)
// Rolling pivot memory for S/R clustering
var float[] srHighVals = array.new<float>()
var int[]   srHighBars = array.new<int>()
var float[] srLowVals  = array.new<float>()
var int[]   srLowBars   = array.new<int>()
if not na(pivotH)
    array.unshift(srHighVals, pivotH)
    array.unshift(srHighBars, bar_index - pivotRight)
if not na(pivotL)
    array.unshift(srLowVals, pivotL)
    array.unshift(srLowBars, bar_index - pivotRight)
while array.size(srHighBars) > 0 and bar_index - array.get(srHighBars, array.size(srHighBars) - 1) > srLookbackBars
    array.pop(srHighVals)
    array.pop(srHighBars)
while array.size(srLowBars) > 0 and bar_index - array.get(srLowBars, array.size(srLowBars) - 1) > srLookbackBars
    array.pop(srLowVals)
    array.pop(srLowBars)
resistance = findCluster(srHighVals, clusterDistance, minClusterPivots)
support    = findCluster(srLowVals, clusterDistance, minClusterPivots)
// Premium / balance / discount range
rangeHigh = ta.highest(high, rangeLookback)
rangeLow  = ta.lowest(low, rangeLookback)
rangeSize = math.max(rangeHigh - rangeLow, syminfo.mintick)
premiumTop  = rangeHigh
premiumBot  = rangeHigh - rangeSize * 0.25
discountTop = rangeLow + rangeSize * 0.25
discountBot = rangeLow
balanceTop  = rangeLow + rangeSize * 0.55
balanceBot  = rangeLow + rangeSize * 0.45
// Trend context (dashboard only)
emaFast     = ta.ema(close, trendFastLen)
emaSlow     = ta.ema(close, trendSlowLen)
isUptrend   = close > emaFast and emaFast > emaSlow
isDowntrend = close < emaFast and emaFast < emaSlow
//==== SIGNAL ENGINE =====================================================
// Market context states only. No buy / sell signals by design.
inPremium      = close >= premiumBot
inDiscount     = close <= discountTop
inBalance      = close <= balanceTop and close >= balanceBot
nearResistance = not na(resistance) and math.abs(close - resistance) <= clusterDistance
nearSupport    = not na(support)    and math.abs(close - support)    <= clusterDistance
zoneText    = nearResistance ? "Resistance" : nearSupport ? "Support" : inPremium ? "Premium" : inDiscount ? "Discount" : inBalance ? "Balance" : "Middle"
controlText = isUptrend ? "Buyers" : isDowntrend ? "Sellers" : "Mixed"
marketText  = isUptrend ? "Bullish" : isDowntrend ? "Bearish" : "Neutral"
upPct        = safeDiv(resistance - close, close, na) * 100
downPct      = safeDiv(close - support, close, na) * 100
roomUpText   = not na(upPct)   ? str.tostring(upPct, "#.##") + "%"   : "n/a"
roomDownText = not na(downPct) ? str.tostring(downPct, "#.##") + "%" : "n/a"
focusText = nearResistance ? "Watch resistance" : nearSupport ? "Watch support" : isUptrend and inBalance ? "Buyers slight edge" : isDowntrend and inBalance ? "Sellers slight edge" : inPremium ? "High in range" : inDiscount ? "Low in range" : "No edge"
// Alert events (edge-triggered, fire once on entry)
enteredResistance = nearResistance and not nearResistance[1]
enteredSupport    = nearSupport    and not nearSupport[1]
enteredPremium    = inPremium      and not inPremium[1]
enteredDiscount   = inDiscount     and not inDiscount[1]
//==== VISUAL STATE ======================================================
// S/R zone box bounds
resTop = not na(resistance) ? resistance + clusterDistance / 2.0 : na
resBot = not na(resistance) ? resistance - clusterDistance / 2.0 : na
supTop = not na(support)    ? support    + clusterDistance / 2.0 : na
supBot = not na(support)    ? support    - clusterDistance / 2.0 : na
// Dashboard colours
marketColor  = isUptrend ? color.new(bullColor, 0) : isDowntrend ? color.new(bearColor, 0) : color.new(neutralColor, 0)
controlColor = marketColor
zoneColor    = nearResistance or inPremium ? color.new(bearColor, 0) : nearSupport or inDiscount ? color.new(bullColor, 0) : color.new(neutralColor, 0)
focusColor   = nearResistance ? color.orange : nearSupport ? color.aqua : isUptrend ? color.new(bullColor, 0) : isDowntrend ? color.new(bearColor, 0) : color.new(neutralColor, 0)
//==== PLOTS =============================================================
// Support / resistance zone boxes
var box resBox = na
var box supBox = na
boxLeft  = timeBack(srLookbackBars)
boxRight = time
if showSRZones and not na(resistance)
    if na(resBox)
        resBox := box.new(left=boxLeft, top=resTop, right=boxRight, bottom=resBot, xloc=xloc.bar_time, border_color=bearColor, bgcolor=bearSoft)
    else
        box.set_left(resBox, boxLeft)
        box.set_right(resBox, boxRight)
        box.set_top(resBox, resTop)
        box.set_bottom(resBox, resBot)
        box.set_border_color(resBox, bearColor)
        box.set_bgcolor(resBox, bearSoft)
else
    if not na(resBox)
        box.delete(resBox)
        resBox := na
if showSRZones and not na(support)
    if na(supBox)
        supBox := box.new(left=boxLeft, top=supTop, right=boxRight, bottom=supBot, xloc=xloc.bar_time, border_color=bullColor, bgcolor=bullSoft)
    else
        box.set_left(supBox, boxLeft)
        box.set_right(supBox, boxRight)
        box.set_top(supBox, supTop)
        box.set_bottom(supBox, supBot)
        box.set_border_color(supBox, bullColor)
        box.set_bgcolor(supBox, bullSoft)
else
    if not na(supBox)
        box.delete(supBox)
        supBox := na
// Premium / balance / discount clouds
pPremiumTop  = plot(showRangeClouds ? premiumTop  : na, "Premium Top",     display=display.none)
pPremiumBot  = plot(showRangeClouds ? premiumBot  : na, "Premium Bottom",  display=display.none)
pDiscountTop = plot(showRangeClouds ? discountTop : na, "Discount Top",    display=display.none)
pDiscountBot = plot(showRangeClouds ? discountBot : na, "Discount Bottom", display=display.none)
pBalanceTop  = plot(showRangeClouds ? balanceTop  : na, "Balance Top",     display=display.none)
pBalanceBot  = plot(showRangeClouds ? balanceBot  : na, "Balance Bottom",  display=display.none)
fill(pPremiumTop,  pPremiumBot,  color=showRangeClouds ? bearSoft    : color(na), title="Premium Area")
fill(pDiscountTop, pDiscountBot, color=showRangeClouds ? bullSoft    : color(na), title="Discount Area")
fill(pBalanceTop,  pBalanceBot,  color=showRangeClouds ? balanceSoft : color(na), title="Balance Area")
// Dynamic trend lines with limited projection
var float[] trendHighVals = array.new<float>()
var int[]   trendHighBars = array.new<int>()
var float[] trendLowVals  = array.new<float>()
var int[]   trendLowBars   = array.new<int>()
if not na(pivotH)
    array.unshift(trendHighVals, pivotH)
    array.unshift(trendHighBars, bar_index - pivotRight)
    if array.size(trendHighVals) > trendPivotMemory
        array.pop(trendHighVals)
        array.pop(trendHighBars)
if not na(pivotL)
    array.unshift(trendLowVals, pivotL)
    array.unshift(trendLowBars, bar_index - pivotRight)
    if array.size(trendLowVals) > trendPivotMemory
        array.pop(trendLowVals)
        array.pop(trendLowBars)
var line dynResLine = na
var line dynSupLine = na
if showTrendlines and array.size(trendHighVals) >= 2
    line.delete(dynResLine)
    int   x2h    = array.get(trendHighBars, 0)
    int   x1h    = array.get(trendHighBars, 1)
    float y2h    = array.get(trendHighVals, 0)
    float y1h    = array.get(trendHighVals, 1)
    float slopeH = safeDiv(y2h - y1h, float(x2h - x1h), 0.0)
    int   xProjH = bar_index + trendProjectionBars
    float yProjH = y2h + slopeH * float(xProjH - x2h)
    dynResLine := line.new(x1=x2h, y1=y2h, x2=xProjH, y2=yProjH, xloc=xloc.bar_index, extend=extend.none, color=bearColor, width=2)
else
    if not showTrendlines and not na(dynResLine)
        line.delete(dynResLine)
        dynResLine := na
if showTrendlines and array.size(trendLowVals) >= 2
    line.delete(dynSupLine)
    int   x2l    = array.get(trendLowBars, 0)
    int   x1l    = array.get(trendLowBars, 1)
    float y2l    = array.get(trendLowVals, 0)
    float y1l    = array.get(trendLowVals, 1)
    float slopeL = safeDiv(y2l - y1l, float(x2l - x1l), 0.0)
    int   xProjL = bar_index + trendProjectionBars
    float yProjL = y2l + slopeL * float(xProjL - x2l)
    dynSupLine := line.new(x1=x2l, y1=y2l, x2=xProjL, y2=yProjL, xloc=xloc.bar_index, extend=extend.none, color=bullColor, width=2)
else
    if not showTrendlines and not na(dynSupLine)
        line.delete(dynSupLine)
        dynSupLine := na
// Friendly zone labels
var label lblResistance = na
var label lblSupport    = na
var label lblBalance    = na
if barstate.islast
    if showZoneLabels
        if showSRZones and not na(resistance)
            lblResistance := makeLabel(lblResistance, labelOffsetBars + 10, resistance, "Resistance zone", color.new(bearColor, 25))
        else
            label.delete(lblResistance)
            lblResistance := na
        if showRangeClouds
            lblBalance := makeLabel(lblBalance, labelOffsetBars + 22, (balanceTop + balanceBot) / 2.0, "Balance area", color.new(neutralColor, 35))
        else
            label.delete(lblBalance)
            lblBalance := na
        if showSRZones and not na(support)
            lblSupport := makeLabel(lblSupport, labelOffsetBars + 34, support, "Support zone", color.new(bullColor, 25))
        else
            label.delete(lblSupport)
            lblSupport := na
    else
        label.delete(lblResistance)
        label.delete(lblSupport)
        label.delete(lblBalance)
        lblResistance := na
        lblSupport := na
        lblBalance := na
//==== ALERTS ============================================================
alertcondition(enteredResistance, "MSL Map - Near Resistance", "MarketStructureLab Market Map: price reached the resistance zone on {{ticker}}.")
alertcondition(enteredSupport,    "MSL Map - Near Support",    "MarketStructureLab Market Map: price reached the support zone on {{ticker}}.")
alertcondition(enteredPremium,    "MSL Map - Premium Area",    "MarketStructureLab Market Map: price entered the premium area on {{ticker}}.")
alertcondition(enteredDiscount,   "MSL Map - Discount Area",   "MarketStructureLab Market Map: price entered the discount area on {{ticker}}.")
//==== TABLE =============================================================
var table proTable = table.new(getPos(tablePos), 2, 6, bgcolor=headerBg, border_color=borderColor, border_width=1, frame_color=borderColor, frame_width=1)
if showDashboard and barstate.islast
    table.cell(proTable, 0, 0, "MSL",       text_color=textColor,    text_size=size.normal, bgcolor=headerBg)
    table.cell(proTable, 1, 0, "Map",       text_color=textColor,    text_size=size.normal, bgcolor=headerBg)
    table.cell(proTable, 0, 1, "Market",    text_color=textColor,    text_size=size.small,  bgcolor=leftColBg)
    table.cell(proTable, 1, 1, marketText,  text_color=marketColor,  text_size=size.small,  bgcolor=rightNeutralBg)
    table.cell(proTable, 0, 2, "Zone",      text_color=textColor,    text_size=size.small,  bgcolor=leftColBg)
    table.cell(proTable, 1, 2, zoneText,    text_color=zoneColor,    text_size=size.small,  bgcolor=rightNeutralBg)
    table.cell(proTable, 0, 3, "Control",   text_color=textColor,    text_size=size.small,  bgcolor=leftColBg)
    table.cell(proTable, 1, 3, controlText, text_color=controlColor, text_size=size.small,  bgcolor=rightNeutralBg)
    table.cell(proTable, 0, 4, "Room",      text_color=textColor,    text_size=size.small,  bgcolor=leftColBg)
    table.cell(proTable, 1, 4, "↑ " + roomUpText + " / ↓ " + roomDownText, text_color=color.silver, text_size=size.small, bgcolor=rightNeutralBg)
    table.cell(proTable, 0, 5, "Focus",     text_color=textColor,    text_size=size.small,  bgcolor=leftColBg)
    table.cell(proTable, 1, 5, focusText,   text_color=focusColor,   text_size=size.small,  bgcolor=rightNeutralBg)
if not showDashboard and barstate.islast
    table.clear(proTable, 0, 0, 1, 5)
//==== USAGE GUIDE =======================================================
// WHAT THIS INDICATOR DOES
// MSL Market Map is a beginner-friendly context map. It paints the most
// important areas on the chart: support and resistance zones built from
// clustered pivots, plus premium (top), balance (middle) and discount
// (bottom) areas of the recent range. Optional dynamic trend lines show
// the current slope of the recent highs and lows.
//
// IMPORTANT
// This indicator gives NO buy or sell signals. There are no BOS, CHoCH,
// liquidity, trap or trade labels. It only describes where price is and
// what the current context looks like. Always combine it with your own
// trend reading, market structure and risk management.
//
// HOW TO READ THE MAP
//   Resistance zone : red box where price was rejected from above before.
//   Support zone    : green box where price was held from below before.
//   Premium area    : upper quarter of the range, price is expensive.
//   Discount area   : lower quarter of the range, price is cheap.
//   Balance area    : middle of the range, no strong location edge.
//   Trend lines     : projected slope of recent highs (red) and lows (green).
//
// DASHBOARD
//   Market  : trend context from two EMAs. Bullish / Bearish / Neutral.
//   Zone    : where price sits now. Resistance / Support / Premium /
//             Discount / Balance / Middle.
//   Control : who has the edge from the EMA stack. Buyers / Sellers / Mixed.
//   Room    : distance from price up to resistance and down to support.
//   Focus   : plain-language note on what to watch. Not a trade command.
//
// SUGGESTED USE
// 1. Is price inside a support or resistance zone right now?
// 2. Is price in premium, discount or balance of the range?
// 3. Does the dashboard trend agree with where price sits?
// 4. Use the trend lines for a rough idea of slope, not exact entries.
//
// Suggested timeframes: H1 and above. Use this map for context building,
// not for blind entries.
//==========================================================================
````
