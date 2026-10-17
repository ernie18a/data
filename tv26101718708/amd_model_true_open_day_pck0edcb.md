# AMD Model True Open Day 

- url: https://www.tradingview.com/script/PCK0EdcB-AMD-Model-True-Open-Day/
- type: indicator
- pine_id: PUB;e20181375ea44d47af904cead1658421
- version: 1.0

## Description

The True Open Day (AMD Model) indicator automates daily opening range tracking combined with real-time Accumulation-Manipulation-Distribution (AMD) cycle detection and Fair Value Gap (FVG) confirmation. Designed for intraday price action traders utilizing Smart Money Concepts (SMC) and ICT methodology.

Key Features
Customizable Opening Range & Extensions: Tracks the Open, High, and Low of the key session start window (06:30–07:00 NY by default). Levels extend dynamically across the trading day and automatically freeze at the defined cutoff time to keep charts clean.

Automated AMD Cycle Engine (30m Timeframe):

Accumulation: Maps the benchmark range established during the initial opening window.

Manipulation (Sweeps): Identifies liquidity sweeps of the opening high or low (Sweep Low / Sweep High x markers).

Distribution (True Move): Confirms institutional directional expansion when price closes beyond opening extremes (True Long / True Short triangles).

Contextual FVG Detection: Automatically draws bullish and bearish Fair Value Gap boxes formed specifically during the manipulation or expansion phases.

Non-Disruptive Timeframe Protection: Engineered for lower timeframes (1m to 30m). On higher timeframes, it displays a subtle on-screen status label instead of triggering runtime errors or disrupting price scale.

How to Use
Establish the Benchmark: Allow the indicator to map the initial session range (06:30–07:00 NY).

Watch for Manipulation: Monitor for x markers indicating price has swept session Highs or Lows into higher-timeframe liquidity pools or POIs.

Confirm Expansion: Look for AMD triangle signals (True Long / True Short) combined with freshly printed FVG boxes for high-RR re-test entries.

Inputs & Settings
Start Candle Time: Define the key opening window (Default: 0630-0700 NY).

Cutoff Time: Set the time to stop extending lines before the next day's session (Default: 1230-1330 NY).

Timezone: Customizable timezone anchor (Default: America/New_York).

Show Candle Range: Toggle visualization of Open, High, and Low levels.

Show AMD Signals: Toggle 30m AMD markers and automated FVG boxes.

Timeframe Compatibility
This indicator is optimized for timeframes of 30 minutes or lower (30m, 15m, 5m, 3m, 1m) to ensure precise intraday range and structure calculations.

## Source Code

````pine
//@version=6
indicator("True Open Day (AMD Model)", overlay=true, max_lines_count=500, max_boxes_count=500)

// --- Inputs ---
sessionTime = input.session("0630-0700", "Start Candle Time")
cutoffTime  = input.session("1230-1330", "Cutoff Time (Stop Lines)") // Отсечка за 1 час до новой сессии
tz          = input.string("America/New_York", "Timezone")
showLines   = input.bool(true, "Show Candle Range")
showAMD     = input.bool(true, "Show AMD Signals (30m Only)")

// --- Timeframe Protection & Info Table ---
is30mOrLower = timeframe.isminutes and timeframe.multiplier <= 30
is30m        = timeframe.isminutes and timeframe.multiplier == 30

var table tfWarning = table.new(position.top_right, 1, 1)
if barstate.islast
    if not is30mOrLower
        table.cell(tfWarning, 0, 0, "⚠️ True Open Day: Use 30m TF or lower", bgcolor=color.new(color.red, 15), text_color=color.white, text_size=size.small)
    else
        table.clear(tfWarning, 0, 0)

// --- Session & Candle Logic ---
inSession   = not na(time(timeframe.period, sessionTime, tz)) and is30mOrLower
inCutoff    = not na(time(timeframe.period, cutoffTime, tz)) and is30mOrLower
isFirstBar  = inSession and not inSession[1]

var float openCandle = na
var float highCandle = na
var float lowCandle  = na

var line l_open = na
var line l_high = na
var line l_low  = na
var bool stopExtending = false

if isFirstBar
    openCandle    := open
    highCandle    := high
    lowCandle     := low
    stopExtending := false

    if showLines
        l_open := line.new(bar_index, openCandle, bar_index + 1, openCandle, color=color.rgb(150, 150, 150), style=line.style_solid, width=2)
        l_high := line.new(bar_index, highCandle, bar_index + 1, highCandle, color=color.rgb(239, 83, 80), style=line.style_dashed, width=1)
        l_low  := line.new(bar_index, lowCandle, bar_index + 1, lowCandle,  color=color.rgb(38, 166, 154), style=line.style_dashed, width=1)

else if inSession
    // Динамическая фиксация диапазона для младших ТФ
    highCandle := math.max(highCandle, high)
    lowCandle  := math.min(lowCandle, low)

    if showLines and not na(l_open)
        line.set_y1(l_high, highCandle)
        line.set_y2(l_high, highCandle)
        line.set_x2(l_high, bar_index)

        line.set_y1(l_low, lowCandle)
        line.set_y2(l_low, lowCandle)
        line.set_x2(l_low, bar_index)

        line.set_x2(l_open, bar_index)

// Продление линий до отсечки
if not inSession and not stopExtending and not na(l_open) and showLines and is30mOrLower
    line.set_x2(l_open, bar_index)
    line.set_x2(l_high, bar_index)
    line.set_x2(l_low,  bar_index)
    
    if inCutoff
        stopExtending := true

// --- AMD Logic (Расчет только для 30m) ---
var int amdState = 0

bool triggerSweepLow  = false
bool triggerSweepHigh = false
bool triggerTrueLong  = false
bool triggerTrueShort = false

if is30m
    if isFirstBar
        amdState := 0

    if not isFirstBar and not na(openCandle)
        // Detect Manipulation
        if amdState == 0
            if low < lowCandle
                amdState := 1
                triggerSweepLow := true
            else if high > highCandle
                amdState := -1
                triggerSweepHigh := true

        // Detect True Move
        if amdState == 1 and close > highCandle
            amdState := 2
            triggerTrueLong := true

        if amdState == -1 and close < lowCandle
            amdState := -2
            triggerTrueShort := true

// --- Метки AMD (Отображаются ТОЛЬКО на 30m) ---
plotshape(is30m and showAMD and triggerSweepLow, "Sweep Low", shape.xcross, location.belowbar, color=color.red, size=size.tiny)
plotshape(is30m and showAMD and triggerSweepHigh, "Sweep High", shape.xcross, location.abovebar, color=color.green, size=size.tiny)

plotshape(is30m and showAMD and triggerTrueLong, "True Long", shape.triangleup, location.belowbar, color=color.blue, size=size.tiny, text="AMD", textcolor=color.blue)
plotshape(is30m and showAMD and triggerTrueShort, "True Short", shape.triangledown, location.abovebar, color=color.purple, size=size.tiny, text="AMD", textcolor=color.purple)

// --- FVG Logic (Отображение ТОЛЬКО на 30m) ---
if is30m and showAMD
    isBullishFVG = low > high[2] and close > open
    isBearishFVG = high < low[2] and close < open

    var bool fvgFound = false
    if isFirstBar
        fvgFound := false

    if isBullishFVG and (amdState == 1 or amdState == 2) and not fvgFound
        box.new(bar_index[2], high[2], bar_index, low, border_color=color.new(color.blue, 50), bgcolor=color.new(color.blue, 85))
        fvgFound := true

    if isBearishFVG and (amdState == -1 or amdState == -2) and not fvgFound
        box.new(bar_index[2], low[2], bar_index, high, border_color=color.new(color.red, 50), bgcolor=color.new(color.red, 85))
        fvgFound := true
````
