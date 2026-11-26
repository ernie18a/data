# Market Strategies 30M Intraday Pressure Ignition

- url: https://www.tradingview.com/script/CfADkcWr-Market-Strategies-30M-Intraday-Pressure-Ignition/
- type: indicator
- pine_id: PUB;fb793352315e417e8cdaa5bdd7555fa0
- version: 5.0

## Description

# Market Strategies 30M Intraday Pressure Ignition

Market Strategies 30M Intraday Pressure Ignition is a multi-timeframe momentum and pressure tool designed to identify when meaningful intraday participation may be developing.

The indicator is designed primarily for use on a **5-minute chart** while monitoring a developing **30-minute pressure engine**.

Rather than relying on a single momentum measurement, it evaluates several characteristics of the developing 30-minute move to determine whether directional pressure is building, strengthening, or confirming.

## 7-Point Pressure Engine

The indicator evaluates seven conditions:

**Volume Expansion** – Determines whether developing 30-minute volume is elevated relative to its recent average.

**Range Expansion** – Determines whether the developing 30-minute trading range is larger than normal.

**Strong Body** – Evaluates whether the candle demonstrates meaningful directional control rather than excessive wick.

**Meaningful Move** – Measures whether price has moved sufficiently from the 30-minute open to represent meaningful movement.

**Structure Break** – Determines whether price is breaking recent 30-minute market structure.

**Acceleration** – Compares the developing 30-minute candle body with the previous completed 30-minute candle body.

**Follow Through** – Evaluates whether price continues making progress in the direction of the developing move.

These conditions create a **0–7 pressure score**.

By default, at least **4 of the 7 conditions** are required as part of a qualified pressure signal.

The score allows traders to see how many characteristics of directional pressure are currently aligned instead of relying on a single indicator or measurement.

## Volume: Identifying Developing Participation

An important component of the indicator is the combination of **30-minute volume expansion** and shorter-term **5-minute volume change**.

### 30M VOL

The VOL reading compares the developing 30-minute candle's volume with the average volume of the previous 20 completed 30-minute candles.

The default volume-expansion threshold is:

**1.25x average 30-minute volume**

A separate high-volume condition occurs at:

**1.50x average 30-minute volume**

This helps identify situations where participation is increasing relative to the symbol's recent activity.

### 5M VOL

The 5M VOL reading compares the current 5-minute volume with the previous completed 5-minute candle.

This provides a shorter-term view of whether participation is currently increasing or decreasing.

The 5M VOL measurement is informational and does **not** alter the seven-point pressure score.

One way to evaluate the relationship is:

**30M VOL elevated → 5M VOL increasing → price structure confirms → evaluate the setup**

Volume can identify where increased participation is occurring, while price action and structure provide additional confirmation.

In simple terms:

**Volume identifies the activity.  
Price confirms the setup.**

## Dashboard

The compact dashboard provides several pieces of information about the developing move.

**PRESSURE** – Displays the current BULL, BEAR, BUILD BULL, BUILD BEAR, or neutral pressure state.

**SCORE** – Displays the number of active pressure conditions out of seven.

**VOL** – Displays developing 30-minute volume relative to its recent 30-minute average.

**5M VOL** – Displays current 5-minute volume change compared with the previous completed 5-minute candle.

**CONTROL** – Identifies strong bullish or bearish candle control.

**STRUCT** – Identifies bullish or bearish breaks of recent 30-minute structure.

**VWAP** – Displays directional price alignment relative to VWAP.

**ACCEL** – Shows whether the developing 30-minute candle body is larger than the previous completed 30-minute candle body.

Together, these readings provide a compact view of participation, momentum, structure, and directional pressure.

## Alerts

Three alert conditions are included.

### 1.50x 30M High Volume

This alert identifies when developing 30-minute volume reaches the designated high-volume threshold.

It can provide early awareness that participation is increasing before all directional pressure conditions have aligned.

### BULL Pressure Confirmed

This alert identifies when the required bullish pressure conditions have developed and remain valid at confirmation.

### BEAR Pressure Confirmed

This alert identifies when the required bearish pressure conditions have developed and remain valid at confirmation.

A potential sequence to monitor is:

**1.50x 30M VOL → 5M volume expands → directional pressure develops → price structure confirms → evaluate the setup**

Alerts are not intended to represent automatic entries. They identify conditions that may warrant additional evaluation of price action, structure, and risk.

## Using the Indicator With Screening Tools

This indicator can complement market-screening tools rather than replace them.

Screening tools can assist with **discovery** by identifying symbols meeting predefined volume, volatility, momentum, or price-action conditions.

The 30M Intraday Pressure Ignition indicator provides an additional analytical layer by monitoring developing participation and directional pressure directly on the chart.

A potential workflow is:

**SCREENING → Identify candidates**

**30M PRESSURE → Monitor participation and directional pressure**

**5M PRICE ACTION → Evaluate structure and confirmation**

This separates market discovery from trade confirmation.

A symbol meeting screening criteria does not automatically represent a trading opportunity. The indicator can instead be used to determine whether volume, range, structure, acceleration, and price behavior continue to support the developing move.

## Practical Interpretation

The indicator is designed to answer several questions:

**Is participation increasing?**

Review 30M VOL and 5M VOL.

**Is the move showing directional strength?**

Review CONTROL, range expansion, body strength, and the pressure score.

**Is price breaking structure?**

Review STRUCT and the underlying price action.

**Is momentum accelerating?**

Review ACCEL and the developing pressure score.

**Is price directionally aligned with VWAP?**

Review the VWAP reading.

Rather than treating any single condition as sufficient, the indicator allows multiple pieces of market information to be evaluated together.

## Important

This indicator is intended as a **market-analysis and decision-support tool**.

It does not predict future price movement, guarantee continuation, or represent an automatic buy or sell system.

Market conditions can change rapidly, and elevated volume or directional pressure does not guarantee that a move will continue.

The general process is:

**Find the activity.**

**Measure the pressure.**

**Evaluate the structure.**

**Wait for price confirmation.**

**Make an independent trading decision.**

## Source Code

````pine

 //@version=6
indicator("Market Strategies LIVE BS Continuation + Dashboard", overlay=true)

//============================================================
// GENERAL SETTINGS
//============================================================
pressureTF = input.timeframe("30", "Pressure Timeframe")
dailyTF = input.timeframe("D", "Daily Pressure Timeframe")
minimumPrice = input.float(50.0, "Minimum Price", step=1.0)

//============================================================
// 30M PRESSURE SETTINGS
//============================================================
volumeLength = input.int(20, "30M Volume Lookback", minval=1)
volumeExpansionMinimum = input.float(1.25, "30M Volume Expansion Minimum")
rangeLength = input.int(20, "30M Range Lookback", minval=1)
rangeExpansionMinimum = input.float(1.20, "30M Range Expansion Minimum")
minimumBodyPercent = input.float(0.60, "30M Minimum Body Percent")
minimumCloseLocation = input.float(0.70, "30M Minimum Close Location")
minimumBarMovePercent = input.float(0.35, "30M Minimum Move Percent")
lookbackBars = input.int(3, "30M Structure Lookback", minval=1)
minimumBreakPercent = input.float(0.05, "30M Minimum Break Percent")
minimumSignalScore = input.int(4, "30M Minimum Pressure Score", minval=1, maxval=7)

//============================================================
// DAILY PRESSURE SETTINGS
//============================================================
dailyVolumeLength = input.int(20, "Daily Volume Lookback", minval=1)
dailyVolumeExpansionMinimum = input.float(1.25, "Daily Volume Expansion Minimum")
dailyRangeLength = input.int(20, "Daily Range Lookback", minval=1)
dailyRangeExpansionMinimum = input.float(1.20, "Daily Range Expansion Minimum")
dailyMinimumBodyPercent = input.float(0.60, "Daily Minimum Body Percent")
dailyMinimumCloseLocation = input.float(0.70, "Daily Minimum Close Location")
dailyMinimumBarMovePercent = input.float(0.35, "Daily Minimum Move Percent")
dailyLookbackBars = input.int(3, "Daily Structure Lookback", minval=1)
dailyMinimumBreakPercent = input.float(0.05, "Daily Minimum Break Percent")
dailyMinimumSignalScore = input.int(4, "Daily Minimum Pressure Score", minval=1, maxval=7)

//============================================================
// VOLUME SETTINGS
//============================================================
heavyVolumeThreshold = input.float(4.0, "Heavy Volume Threshold")
extremeVolumeThreshold = input.float(7.5, "Extreme Volume Threshold")
exceptionalVolumeThreshold = input.float(15.0, "Exceptional Volume Threshold")
fiveMinVolumeTF = input.timeframe("5", "Short-Term Volume Timeframe")
fiveMinVolumeIncreaseMinimum = input.float(25.0, "5M Volume Increase Minimum %")

//============================================================
// DASHBOARD SETTINGS
//============================================================
showDashboard = input.bool(true, "Show Dashboard")
dashboardPosition = input.string("Top Right", "Dashboard Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"])
dashboardSize = input.string("Small", "Dashboard Size", options=["Tiny", "Small", "Normal"])

dashboardLabelTextColor = input.color(color.white, "Dashboard Label Text")
dashboardLabelBackground = input.color(color.black, "Dashboard Label Background")
dashboardValueTextColor = input.color(color.white, "Dashboard Value Text")
dashboardActiveColor = input.color(color.orange, "Dashboard Active Color")
dashboardInactiveColor = input.color(color.rgb(45,45,45), "Dashboard Inactive Color")
dashboardBullColor = input.color(color.green, "Bull Alignment Color")
dashboardBearColor = input.color(color.red, "Bear Alignment Color")
dashboardHeavyVolumeColor = input.color(color.rgb(6,136,243), "Heavy Volume Color")
dashboardExtremeVolumeColor = input.color(color.rgb(76,175,79), "Extreme Volume Color")
dashboardExceptionalVolumeColor = input.color(color.rgb(4,253,133), "Exceptional Volume Color")

tablePosition = switch dashboardPosition
    "Top Left" => position.top_left
    "Top Center" => position.top_center
    "Top Right" => position.top_right
    "Middle Left" => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right" => position.middle_right
    "Bottom Left" => position.bottom_left
    "Bottom Center" => position.bottom_center
    => position.bottom_right

tableTextSize = dashboardSize == "Tiny" ? size.tiny : dashboardSize == "Small" ? size.small : size.normal

//============================================================
// ORIGINAL 7-POINT PRESSURE ENGINE
//============================================================
pressureEngine(volLen, volMin, rngLen, rngMin, bodyMin, closeMin, moveMin, breakLen, breakMin) =>
    o = open
    h = high
    l = low
    c = close
    v = volume

    priorVol = ta.sma(volume[1], volLen)
    volRatio = priorVol > 0 ? v / priorVol : 0.0
    volExpansion = volRatio >= volMin

    candleRange = h - l
    priorRange = ta.sma(high[1] - low[1], rngLen)
    rangeRatio = priorRange > 0 ? candleRange / priorRange : 0.0
    rangeExpansion = rangeRatio >= rngMin

    body = math.abs(c - o)
    bodyPercent = candleRange > 0 ? body / candleRange : 0.0
    strongBody = bodyPercent >= bodyMin

    bullCandle = c > o
    bearCandle = c < o

    bullLocation = candleRange > 0 ? (c - l) / candleRange : 0.5
    bearLocation = candleRange > 0 ? (h - c) / candleRange : 0.5

    strongBullClose = bullCandle and bullLocation >= closeMin
    strongBearClose = bearCandle and bearLocation >= closeMin

    bullControl = strongBody and strongBullClose
    bearControl = strongBody and strongBearClose

    movePercent = o > 0 ? 100 * math.abs(c / o - 1) : 0.0
    meaningfulMove = movePercent >= moveMin

    recentHigh = ta.highest(high[1], breakLen)
    recentLow = ta.lowest(low[1], breakLen)

    bullBreak = bullCandle and c > recentHigh * (1 + breakMin / 100)
    bearBreak = bearCandle and c < recentLow * (1 - breakMin / 100)

    structureBreak = bullBreak or bearBreak

    previousBody = math.abs(close[1] - open[1])
    accelerating = body > previousBody

    bullFollow = bullCandle and c > close[1] and h > high[1]
    bearFollow = bearCandle and c < close[1] and l < low[1]
    followThrough = bullFollow or bearFollow

    score = (volExpansion ? 1 : 0) + (rangeExpansion ? 1 : 0) + (strongBody ? 1 : 0) + (meaningfulMove ? 1 : 0) + (structureBreak ? 1 : 0) + (accelerating ? 1 : 0) + (followThrough ? 1 : 0)

    [c, volRatio, rangeRatio, bodyPercent, movePercent, bullCandle, bearCandle, strongBullClose, strongBearClose, bullControl, bearControl, bullBreak, bearBreak, accelerating, score]

//============================================================
// 30M PRESSURE DATA
//============================================================
[c30, volumeRatio, rangeRatio, bodyPercent, barMovePercent, bullishCandle, bearishCandle, strongBullClose, strongBearClose, bullControl, bearControl, bullishBreak, bearishBreak, accelerating, signalScore] = request.security(syminfo.tickerid, pressureTF, pressureEngine(volumeLength, volumeExpansionMinimum, rangeLength, rangeExpansionMinimum, minimumBodyPercent, minimumCloseLocation, minimumBarMovePercent, lookbackBars, minimumBreakPercent), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

//============================================================
// DAILY PRESSURE DATA
//============================================================
[dailyC, dailyVolumeRatio, dailyRangeRatio, dailyBodyPercent, dailyBarMovePercent, dailyBullishCandle, dailyBearishCandle, dailyStrongBullClose, dailyStrongBearClose, dailyBullControl, dailyBearControl, dailyBullishBreak, dailyBearishBreak, dailyAccelerating, dailySignalScore] = request.security(syminfo.tickerid, dailyTF, pressureEngine(dailyVolumeLength, dailyVolumeExpansionMinimum, dailyRangeLength, dailyRangeExpansionMinimum, dailyMinimumBodyPercent, dailyMinimumCloseLocation, dailyMinimumBarMovePercent, dailyLookbackBars, dailyMinimumBreakPercent), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

//============================================================
// VWAP ALIGNMENT
//============================================================
vwapValue = ta.vwap(hlc3)
bullishVWAP = bullishCandle and close > vwapValue
bearishVWAP = bearishCandle and close < vwapValue
vwapAligned = bullishVWAP or bearishVWAP

//============================================================
// PRESSURE AND MTF ALIGNMENT
//============================================================
priceOK = c30 >= minimumPrice

bullishPressure = priceOK and strongBullClose and bullishVWAP and signalScore >= minimumSignalScore
bearishPressure = priceOK and strongBearClose and bearishVWAP and signalScore >= minimumSignalScore

dailyBullishPressure = dailyStrongBullClose and dailySignalScore >= dailyMinimumSignalScore
dailyBearishPressure = dailyStrongBearClose and dailySignalScore >= dailyMinimumSignalScore

bullishMTFAlignment = bullishPressure and dailyBullishPressure
bearishMTFAlignment = bearishPressure and dailyBearishPressure

mixedMTFAlignment = (bullishPressure and dailyBearishPressure) or (bearishPressure and dailyBullishPressure)

//============================================================
// LIVE CONTINUATION CONDITIONS
//============================================================
bullContinuationSetup = bullishBreak and bullControl and bullishVWAP and accelerating
bearContinuationSetup = bearishBreak and bearControl and bearishVWAP and accelerating

newBullContinuation = bullContinuationSetup and not bullContinuationSetup[1]
newBearContinuation = bearContinuationSetup and not bearContinuationSetup[1]

// LIVE BS SIGNALS - NO CANDLE CLOSE REQUIRED
bullBS = newBullContinuation
bearBS = newBearContinuation

//============================================================
// ONLY BS LABELS
//============================================================
plotshape(bullBS, title="Bull BC", text="BC", style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white, size=size.tiny)

plotshape(bearBS, title="Bear BC", text="BC", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.tiny)

//============================================================
// LIVE BS ALERTS
//============================================================
alertcondition(bullBS, title=" BULL CONTINUATION", message="BC BULL: {{ticker}}")

alertcondition(bearBS, title=" BEAR CONTINUATION", message="BC BEAR: {{ticker}}")

alertcondition(bullBS or bearBS, title="BC BULL OR BEAR", message="BC CONTINUATION: {{ticker}}")

//============================================================
// VOLUME INTENSITY
//============================================================
volumeExpansion = volumeRatio >= volumeExpansionMinimum
heavyVolume = volumeRatio >= heavyVolumeThreshold
extremeVolume = volumeRatio >= extremeVolumeThreshold
exceptionalVolume = volumeRatio >= exceptionalVolumeThreshold

volumeDashboardColor = exceptionalVolume ? dashboardExceptionalVolumeColor : extremeVolume ? dashboardExtremeVolumeColor : heavyVolume ? dashboardHeavyVolumeColor : volumeExpansion ? dashboardActiveColor : dashboardInactiveColor

//============================================================
// 5M VOLUME
//============================================================
[current5MVolume, previous5MVolume] = request.security(syminfo.tickerid, fiveMinVolumeTF, [volume, volume[1]], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

fiveMinVolumeChange = previous5MVolume > 0 ? 100 * (current5MVolume / previous5MVolume - 1) : 0.0
fiveMinVolumeIncreasing = fiveMinVolumeChange >= fiveMinVolumeIncreaseMinimum

//============================================================
// ORIGINAL 10-ROW DASHBOARD
//============================================================
var table dash = table.new(tablePosition, 2, 10, border_width=1)

if barstate.islast
    if showDashboard
        mtfText = bullishMTFAlignment ? "BULL ALIGNED" : bearishMTFAlignment ? "BEAR ALIGNED" : mixedMTFAlignment ? "MIXED" : "NO ALIGN"
        mtfColor = bullishMTFAlignment ? dashboardBullColor : bearishMTFAlignment ? dashboardBearColor : mixedMTFAlignment ? color.yellow : dashboardInactiveColor

        pressureText = bullishPressure ? "BULL" : bearishPressure ? "BEAR" : bullishCandle ? "BUILD BULL" : bearishCandle ? "BUILD BEAR" : "NEUTRAL"

        controlText = bullControl ? "BULL CTRL" : bearControl ? "BEAR CTRL" : bullishCandle ? "BUILD BULL" : bearishCandle ? "BUILD BEAR" : "NO CTRL"

        structureText = bullishBreak ? "BULL BRK" : bearishBreak ? "BEAR BRK" : "NO BRK"

        vwapText = bullishVWAP ? "ABOVE" : bearishVWAP ? "BELOW" : "NO"

        fiveMinVolumeText = fiveMinVolumeChange > 0 ? "+" + str.tostring(fiveMinVolumeChange, "#") + "% ↑" : fiveMinVolumeChange < 0 ? str.tostring(fiveMinVolumeChange, "#") + "% ↓" : "0%"

        

        table.cell(dash, 0, 2, "30M PRESSURE", text_color=dashboardLabelTextColor, bgcolor=dashboardLabelBackground, text_size=tableTextSize)
        table.cell(dash, 1, 2, pressureText, text_color=dashboardValueTextColor, bgcolor=bullishPressure ? dashboardBullColor : bearishPressure ? dashboardBearColor : dashboardInactiveColor, text_size=tableTextSize)

        table.cell(dash, 0, 3, "30M SCORE", text_color=dashboardLabelTextColor, bgcolor=dashboardLabelBackground, text_size=tableTextSize)
        table.cell(dash, 1, 3, str.tostring(signalScore) + "/7", text_color=dashboardValueTextColor, bgcolor=signalScore >= minimumSignalScore ? dashboardActiveColor : dashboardInactiveColor, text_size=tableTextSize)

        table.cell(dash, 0, 4, "VOL", text_color=dashboardLabelTextColor, bgcolor=dashboardLabelBackground, text_size=tableTextSize)
        table.cell(dash, 1, 4, str.tostring(volumeRatio, "#.##") + "x", text_color=dashboardValueTextColor, bgcolor=volumeDashboardColor, text_size=tableTextSize)

        table.cell(dash, 0, 5, "5M VOL", text_color=dashboardLabelTextColor, bgcolor=dashboardLabelBackground, text_size=tableTextSize)
        table.cell(dash, 1, 5, fiveMinVolumeText, text_color=dashboardValueTextColor, bgcolor=fiveMinVolumeIncreasing ? dashboardActiveColor : dashboardInactiveColor, text_size=tableTextSize)

        table.cell(dash, 0, 6, "CONTROL", text_color=dashboardLabelTextColor, bgcolor=dashboardLabelBackground, text_size=tableTextSize)
        table.cell(dash, 1, 6, controlText, text_color=dashboardValueTextColor, bgcolor=bullControl or bearControl ? dashboardActiveColor : dashboardInactiveColor, text_size=tableTextSize)

        table.cell(dash, 0, 7, "STRUCT", text_color=dashboardLabelTextColor, bgcolor=dashboardLabelBackground, text_size=tableTextSize)
        table.cell(dash, 1, 7, structureText, text_color=dashboardValueTextColor, bgcolor=bullishBreak or bearishBreak ? dashboardActiveColor : dashboardInactiveColor, text_size=tableTextSize)

        table.cell(dash, 0, 8, "VWAP", text_color=dashboardLabelTextColor, bgcolor=dashboardLabelBackground, text_size=tableTextSize)
        table.cell(dash, 1, 8, vwapText, text_color=dashboardValueTextColor, bgcolor=vwapAligned ? dashboardActiveColor : dashboardInactiveColor, text_size=tableTextSize)

        table.cell(dash, 0, 9, "ACCEL", text_color=dashboardLabelTextColor, bgcolor=dashboardLabelBackground, text_size=tableTextSize)
        table.cell(dash, 1, 9, accelerating ? "YES" : "NO", text_color=dashboardValueTextColor, bgcolor=accelerating ? dashboardActiveColor : dashboardInactiveColor, text_size=tableTextSize)
    else
        table.clear(dash, 0, 0, 1, 9)

//============================================================
// DATA WINDOW
//============================================================
plot(dailySignalScore, title="Daily Pressure Score", display=display.data_window)
plot(dailyVolumeRatio, title="Daily Volume Ratio", display=display.data_window)
plot(signalScore, title="30M Pressure Score", display=display.data_window)
plot(volumeRatio, title="30M Volume Ratio", display=display.data_window)
plot(fiveMinVolumeChange, title="5M Volume Change %", display=display.data_window)
plot(rangeRatio, title="30M Range Ratio", display=display.data_window)
plot(bodyPercent * 100, title="30M Body %", display=display.data_window)
plot(barMovePercent, title="30M Move %", display=display.data_window)
````
