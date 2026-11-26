# Elaris Absorption Zones Pro

- url: https://www.tradingview.com/script/xxRrERar-Elaris-Absorption-Zones-Pro/
- type: indicator
- pine_id: PUB;935641837dde423da599c19bee651b3d
- version: 1.0

## Description

[b]Elaris Absorption Zones Pro[/b]

Elaris Absorption Zones Pro is an advanced price-action and volume analysis indicator designed to identify potential absorption events where aggressive market orders are absorbed by opposing passive liquidity.

The indicator focuses on situations where price attempts to break an important level but fails to continue, suggesting that significant limit orders may be absorbing the incoming buying or selling pressure.

Unlike traditional breakout indicators that look for continuation, this tool is designed to highlight failed auctions, rejection events, and potential liquidity absorption zones that may lead to reversals, pullbacks, or reduced directional momentum.

---

[b]What Is Absorption?[/b]

Absorption occurs when aggressive participants repeatedly attempt to push price through a level using market orders, but opposing limit orders absorb that pressure and prevent further movement.

Examples include:

• Buyers aggressively pushing above resistance but failing to achieve continuation.

• Sellers aggressively pushing below support but failing to achieve continuation.

• Large rejection wicks appearing after a breakout attempt.

• High volume with limited price progress (Effort vs Result imbalance).

These conditions can indicate the presence of significant liquidity providers defending a price area.

---

[b]How The Indicator Works[/b]

The indicator combines multiple confirmation layers:

[b]Market Structure Analysis[/b]

The script monitors:

• Confirmed swing highs and swing lows

• Recent trading ranges

• Failed breakout attempts

Price must first attempt to break an important structural level before absorption conditions can be evaluated.

[b]Rejection Analysis[/b]

The indicator evaluates:

• Upper wick size

• Lower wick size

• Body-to-range relationship

Large rejection wicks combined with small candle bodies may indicate strong opposing liquidity.

[b]Volume Confirmation[/b]

Volume is evaluated using:

• Relative volume

• Volume moving averages

• Optional volume Z-score analysis

This helps identify situations where participation is elevated compared to normal market activity.

[b]Effort vs Result Model[/b]

One of the core components of the indicator is Effort vs Result analysis.

High volume combined with poor directional progress can indicate that incoming orders are being absorbed rather than successfully moving the market.

[b]Absorption Scoring[/b]

Every detected signal receives a strength score based on:

• Rejection quality

• Relative volume

• Candle efficiency

Higher scores generally indicate stronger absorption characteristics.

---

[b]Features[/b]

✔ Bullish absorption detection

✔ Bearish absorption detection

✔ Failed breakout recognition

✔ Confirmed swing structure analysis

✔ Range breakout absorption detection

✔ Relative volume filters

✔ Volume Z-score filtering

✔ Effort vs Result analysis

✔ Absorption strength scoring

✔ Optional absorption zones

✔ Zone retest detection

✔ Dashboard with live metrics

✔ Alert conditions

✔ Non-repainting confirmation mode

---

[b]Bullish Absorption[/b]

Bullish absorption may occur when:

1. Price breaks below support.
2. Sellers attempt continuation.
3. Price quickly returns above the level.
4. A strong lower rejection wick forms.
5. Volume confirms elevated participation.

This may suggest that passive buyers absorbed the selling pressure.

---

[b]Bearish Absorption[/b]

Bearish absorption may occur when:

1. Price breaks above resistance.
2. Buyers attempt continuation.
3. Price closes back below the level.
4. A strong upper rejection wick forms.
5. Volume confirms elevated participation.

This may suggest that passive sellers absorbed the buying pressure.

---

[b]How To Use[/b]

Many traders use absorption signals as:

• Early reversal warnings

• Liquidity sweep confirmations

• Support and resistance confirmation

• Market structure confirmation

• Trade management tools

For best results, consider combining absorption signals with:

• Trend analysis

• Market structure

• Higher timeframe context

• Risk management rules

• Additional confirmation tools

---

[b]Non-Repainting[/b]

When "Confirm Only After Candle Close" is enabled, signals are generated only after a candle has fully closed.

Confirmed swing levels are based on completed pivot structures.

This helps reduce signal instability and prevents intrabar repainting behavior.

---

[b]Important Notes
[/b]
This indicator does not use Level II, order book, footprint, or exchange matching engine data.

Because TradingView Pine Script does not have direct access to actual market order flow, absorption is estimated using a combination of price action, rejection behavior, volume analysis, and structural breakout failure characteristics.

As with all trading tools, signals should be used as part of a complete trading plan and not as standalone buy or sell recommendations.

## Source Code

````pine
// This Pine Script® code is subject to the Mozilla Public License 2.0
// © ElarisGroup

//@version=6
indicator("Elaris Absorption Zones Pro", shorttitle="Elaris Absorption Pro", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

//====================================================
// INPUT GROUPS
//====================================================
groupCore   = "01. Core Detection"
groupVolume = "02. Volume / Effort Filters"
groupCandle = "03. Candle Absorption Filters"
groupZones  = "04. Absorption Zones"
groupVisual = "05. Visuals"
groupDash   = "06. Dashboard"
groupAlerts = "07. Alerts"

//====================================================
// CORE SETTINGS
//====================================================
swingLen = input.int(8, "Confirmed Swing Length", minval=2, maxval=50, group=groupCore)
rangeLookback = input.int(30, "Range Breakout Lookback", minval=5, maxval=300, group=groupCore)
useSwingBreak = input.bool(true, "Detect Swing Break Absorption", group=groupCore)
useRangeBreak = input.bool(true, "Detect Range Break Absorption", group=groupCore)

confirmOnClose = input.bool(true, "Confirm Only After Candle Close", group=groupCore, tooltip="Keeps signals non-repainting by confirming only on closed candles.")

//====================================================
// VOLUME / EFFORT FILTERS
//====================================================
volLen = input.int(50, "Volume Average Length", minval=5, maxval=300, group=groupVolume)
minRelVol = input.float(1.4, "Minimum Relative Volume", minval=0.1, step=0.1, group=groupVolume)
useVolZScore = input.bool(true, "Use Volume Z-Score Filter", group=groupVolume)
minVolZ = input.float(0.8, "Minimum Volume Z-Score", step=0.1, group=groupVolume)

useEffortVsResult = input.bool(true, "Use Effort vs Result Filter", group=groupVolume)
maxBodyToRange = input.float(0.45, "Max Body / Candle Range", minval=0.05, maxval=1.0, step=0.05, group=groupVolume)

//====================================================
// CANDLE FILTERS
//====================================================
minWickRatio = input.float(0.45, "Minimum Rejection Wick %", minval=0.1, maxval=0.95, step=0.05, group=groupCandle)
minFailedBreakAtr = input.float(0.05, "Minimum Break Beyond Level ATR", minval=0.0, step=0.01, group=groupCandle)
atrLen = input.int(14, "ATR Length", minval=1, maxval=100, group=groupCandle)

useCloseBackInside = input.bool(true, "Require Close Back Inside Level", group=groupCandle)
useOppositeClose = input.bool(false, "Require Opposite Candle Close", group=groupCandle, tooltip="Bear absorption requires bearish candle. Bull absorption requires bullish candle.")

//====================================================
// ZONES
//====================================================
showZones = input.bool(false, "Show Absorption Zones", group=groupZones)
zoneAtrMult = input.float(0.25, "Zone Thickness ATR Multiplier", minval=0.02, maxval=3.0, step=0.05, group=groupZones)
extendBars = input.int(150, "Extend Zones Bars", minval=10, maxval=1000, group=groupZones)
maxZones = input.int(40, "Maximum Active Zones", minval=5, maxval=200, group=groupZones)

removeBrokenZones = input.bool(true, "Remove Broken Zones", group=groupZones)
markZoneTouches = input.bool(true, "Mark Zone Retests", group=groupZones)

//====================================================
// VISUALS
//====================================================
showSignals = input.bool(true, "Show Absorption Signals", group=groupVisual)
showBreakLevels = input.bool(true, "Show Breakout Levels", group=groupVisual)
showBg = input.bool(false, "Highlight Signal Background", group=groupVisual)
showScoreLabels = input.bool(true, "Show Absorption Score Labels", group=groupVisual)

bearZoneColor = input.color(color.new(color.red, 82), "Bearish Absorption Zone", group=groupVisual)
bullZoneColor = input.color(color.new(color.lime, 82), "Bullish Absorption Zone", group=groupVisual)
bearSignalColor = input.color(color.red, "Bearish Signal Color", group=groupVisual)
bullSignalColor = input.color(color.lime, "Bullish Signal Color", group=groupVisual)

//====================================================
// DASHBOARD
//====================================================
showDashboard = input.bool(true, "Show Dashboard", group=groupDash)
dashPosition = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=groupDash)
darkMode = input.bool(true, "Dashboard Dark Mode", group=groupDash)

//====================================================
// CALCULATIONS
//====================================================
confirmed = confirmOnClose ? barstate.isconfirmed : true

atr = ta.atr(atrLen)
barRange = high - low
body = math.abs(close - open)

upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

upperWickPct = barRange > 0 ? upperWick / barRange : 0.0
lowerWickPct = barRange > 0 ? lowerWick / barRange : 0.0
bodyPct = barRange > 0 ? body / barRange : 1.0

volAvg = ta.sma(volume, volLen)
volStd = ta.stdev(volume, volLen)
relVol = volAvg > 0 ? volume / volAvg : 0.0
volZ = volStd > 0 ? (volume - volAvg) / volStd : 0.0

volumePass = relVol >= minRelVol and (not useVolZScore or volZ >= minVolZ)
effortResultPass = not useEffortVsResult or bodyPct <= maxBodyToRange

//====================================================
// STRUCTURE LEVELS
//====================================================
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

lastSwingHigh = ta.valuewhen(not na(ph), ph, 0)
lastSwingLow = ta.valuewhen(not na(pl), pl, 0)

rangeHigh = ta.highest(high[1], rangeLookback)
rangeLow = ta.lowest(low[1], rangeLookback)

bearLevelSwing = lastSwingHigh
bullLevelSwing = lastSwingLow

bearLevelRange = rangeHigh
bullLevelRange = rangeLow

bearLevel = useSwingBreak and not na(bearLevelSwing) ? bearLevelSwing : bearLevelRange
bullLevel = useSwingBreak and not na(bullLevelSwing) ? bullLevelSwing : bullLevelRange

bearBreakSwing = useSwingBreak and not na(lastSwingHigh) and high > lastSwingHigh
bullBreakSwing = useSwingBreak and not na(lastSwingLow) and low < lastSwingLow

bearBreakRange = useRangeBreak and not na(rangeHigh) and high > rangeHigh
bullBreakRange = useRangeBreak and not na(rangeLow) and low < rangeLow

bearBreak = bearBreakSwing or bearBreakRange
bullBreak = bullBreakSwing or bullBreakRange

bearRefLevel = bearBreakSwing ? lastSwingHigh : rangeHigh
bullRefLevel = bullBreakSwing ? lastSwingLow : rangeLow

bearCloseBack = not useCloseBackInside or close < bearRefLevel
bullCloseBack = not useCloseBackInside or close > bullRefLevel

bearBreakDistance = high - bearRefLevel
bullBreakDistance = bullRefLevel - low

bearDistancePass = bearBreakDistance >= atr * minFailedBreakAtr
bullDistancePass = bullBreakDistance >= atr * minFailedBreakAtr

bearOppositePass = not useOppositeClose or close < open
bullOppositePass = not useOppositeClose or close > open

//====================================================
// ABSORPTION SIGNALS
//====================================================
bearAbsorption =
     confirmed and
     bearBreak and
     bearCloseBack and
     bearDistancePass and
     upperWickPct >= minWickRatio and
     volumePass and
     effortResultPass and
     bearOppositePass

bullAbsorption =
     confirmed and
     bullBreak and
     bullCloseBack and
     bullDistancePass and
     lowerWickPct >= minWickRatio and
     volumePass and
     effortResultPass and
     bullOppositePass

//====================================================
// ABSORPTION SCORE
//====================================================
wickScoreBear = math.min(upperWickPct / minWickRatio, 2.0)
wickScoreBull = math.min(lowerWickPct / minWickRatio, 2.0)
volScore = math.min(relVol / minRelVol, 2.0)
resultScore = math.max(0.0, 1.0 - bodyPct)

bearScoreRaw = (wickScoreBear * 35.0) + (volScore * 30.0) + (resultScore * 35.0)
bullScoreRaw = (wickScoreBull * 35.0) + (volScore * 30.0) + (resultScore * 35.0)

bearScore = math.min(math.round(bearScoreRaw), 100)
bullScore = math.min(math.round(bullScoreRaw), 100)

//====================================================
// ZONE STORAGE
//====================================================
var box[] zones = array.new_box()
var int[] zoneDirs = array.new_int()
var float[] zoneTops = array.new_float()
var float[] zoneBottoms = array.new_float()

createZone(_dir, _top, _bottom, _color) =>
    if showZones
        b = box.new(
             left=bar_index,
             top=_top,
             right=bar_index + extendBars,
             bottom=_bottom,
             bgcolor=_color,
             border_color=color.new(_dir == 1 ? bullSignalColor : bearSignalColor, 35)
        )
        array.push(zones, b)
        array.push(zoneDirs, _dir)
        array.push(zoneTops, _top)
        array.push(zoneBottoms, _bottom)

        if array.size(zones) > maxZones
            oldBox = array.shift(zones)
            box.delete(oldBox)
            array.shift(zoneDirs)
            array.shift(zoneTops)
            array.shift(zoneBottoms)

// Bear zone = supply absorption near failed highs
if bearAbsorption
    zTop = high
    zBot = math.max(bearRefLevel, high - atr * zoneAtrMult)
    createZone(-1, zTop, zBot, bearZoneColor)

// Bull zone = demand absorption near failed lows
if bullAbsorption
    zBot = low
    zTop = math.min(bullRefLevel, low + atr * zoneAtrMult)
    createZone(1, zTop, zBot, bullZoneColor)

//====================================================
// ZONE MANAGEMENT
//====================================================
bullZoneTouch = false
bearZoneTouch = false

if array.size(zones) > 0
    for i = array.size(zones) - 1 to 0
        b = array.get(zones, i)
        dir = array.get(zoneDirs, i)
        top = array.get(zoneTops, i)
        bot = array.get(zoneBottoms, i)

        box.set_right(b, bar_index + extendBars)

        isBroken = dir == 1 ? close < bot : close > top
        isTouched = dir == 1 ? low <= top and close > bot : high >= bot and close < top

        bullZoneTouch := bullZoneTouch or (dir == 1 and isTouched)
        bearZoneTouch := bearZoneTouch or (dir == -1 and isTouched)

        if removeBrokenZones and isBroken
            box.delete(b)
            array.remove(zones, i)
            array.remove(zoneDirs, i)
            array.remove(zoneTops, i)
            array.remove(zoneBottoms, i)

//====================================================
// VISUAL OUTPUT
//====================================================
plot(showBreakLevels ? lastSwingHigh : na, "Confirmed Swing High", color=color.new(color.red, 65), style=plot.style_linebr)
plot(showBreakLevels ? lastSwingLow : na, "Confirmed Swing Low", color=color.new(color.lime, 65), style=plot.style_linebr)

plotshape(showSignals and bearAbsorption, title="Bearish Absorption", style=shape.triangledown, location=location.abovebar, color=bearSignalColor, size=size.small, text="ABS")
plotshape(showSignals and bullAbsorption, title="Bullish Absorption", style=shape.triangleup, location=location.belowbar, color=bullSignalColor, size=size.small, text="ABS")

plotshape(markZoneTouches and bearZoneTouch, title="Bearish Absorption Zone Retest", style=shape.circle, location=location.abovebar, color=color.new(color.red, 0), size=size.tiny, text="RT")
plotshape(markZoneTouches and bullZoneTouch, title="Bullish Absorption Zone Retest", style=shape.circle, location=location.belowbar, color=color.new(color.lime, 0), size=size.tiny, text="RT")

bgcolor(showBg and bearAbsorption ? color.new(color.red, 88) : na)
bgcolor(showBg and bullAbsorption ? color.new(color.lime, 88) : na)

if showScoreLabels and bearAbsorption
    label.new(bar_index, high, "Bear Absorption\nScore: " + str.tostring(bearScore), style=label.style_label_down, textcolor=color.white, color=color.new(color.red, 10), size=size.small)

if showScoreLabels and bullAbsorption
    label.new(bar_index, low, "Bull Absorption\nScore: " + str.tostring(bullScore), style=label.style_label_up, textcolor=color.white, color=color.new(color.green, 10), size=size.small)

//====================================================
// DASHBOARD
//====================================================
pos = dashPosition == "Top Right" ? position.top_right :
      dashPosition == "Top Left" ? position.top_left :
      dashPosition == "Bottom Right" ? position.bottom_right :
      position.bottom_left

var table dash = table.new(pos, 2, 7, border_width=1)

dashBg = darkMode ? color.new(color.black, 0) : color.new(color.white, 0)
dashText = darkMode ? color.white : color.black
dashHeader = darkMode ? color.new(color.gray, 70) : color.new(color.gray, 85)

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "Elaris Absorption Pro", bgcolor=dashHeader, text_color=dashText)
    table.cell(dash, 1, 0, "Live", bgcolor=dashHeader, text_color=dashText)

    table.cell(dash, 0, 1, "Relative Volume", bgcolor=dashBg, text_color=dashText)
    table.cell(dash, 1, 1, str.tostring(relVol, "#.##") + "x", bgcolor=dashBg, text_color=dashText)

    table.cell(dash, 0, 2, "Volume Z-Score", bgcolor=dashBg, text_color=dashText)
    table.cell(dash, 1, 2, str.tostring(volZ, "#.##"), bgcolor=dashBg, text_color=dashText)

    table.cell(dash, 0, 3, "Body / Range", bgcolor=dashBg, text_color=dashText)
    table.cell(dash, 1, 3, str.tostring(bodyPct * 100, "#") + "%", bgcolor=dashBg, text_color=dashText)

    table.cell(dash, 0, 4, "Upper Wick", bgcolor=dashBg, text_color=dashText)
    table.cell(dash, 1, 4, str.tostring(upperWickPct * 100, "#") + "%", bgcolor=dashBg, text_color=dashText)

    table.cell(dash, 0, 5, "Lower Wick", bgcolor=dashBg, text_color=dashText)
    table.cell(dash, 1, 5, str.tostring(lowerWickPct * 100, "#") + "%", bgcolor=dashBg, text_color=dashText)

    table.cell(dash, 0, 6, "Active Zones", bgcolor=dashBg, text_color=dashText)
    table.cell(dash, 1, 6, str.tostring(array.size(zones)), bgcolor=dashBg, text_color=dashText)

//====================================================
// ALERTS
//====================================================
alertcondition(bearAbsorption, "Bearish Absorption Detected", "Bearish absorption detected: price tried to break higher but was absorbed.")
alertcondition(bullAbsorption, "Bullish Absorption Detected", "Bullish absorption detected: price tried to break lower but was absorbed.")
alertcondition(bearZoneTouch, "Bearish Absorption Zone Retest", "Price retested a bearish absorption zone.")
alertcondition(bullZoneTouch, "Bullish Absorption Zone Retest", "Price retested a bullish absorption zone.")
````
