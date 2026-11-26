# Highs & Lows_Neo - Daily & 4H Levels

- url: https://www.tradingview.com/script/xH2UAZKb-Highs-Lows-Neo-Daily-4H-Levels/
- type: indicator
- pine_id: PUB;6406d57ec02c4d18a9ab962d232098ea
- version: 1.0

## Description

# Highs & Lows_Neo — Daily & 4H Levels

**Highs & Lows_Neo** is a market-structure and liquidity-level indicator designed to help traders monitor important **previous Daily and 4H highs and lows**, identify when those levels are broken, and observe the market's reaction around them.

The indicator focuses on keeping higher-timeframe levels visible while providing additional information about active levels, break zones, and potential entry signals.

## 🔹 Key Features

### 📊 Previous Daily Highs & Lows

Display previous Daily highs and lows as horizontal levels.

You can customize:

* Number of Daily periods displayed
* High and Low colors
* Line style
* Timeframe used to calculate the levels

The default setting displays the previous **5 Daily periods**.

### 📈 Previous 4H Highs & Lows

The indicator also tracks previous 4H highs and lows.

You can customize:

* Number of 4H periods displayed
* High and Low colors
* Line style
* Timeframe used for calculation

The default setting displays the previous **5 4H periods**.

### 🎯 Active Level Tracking

Each Daily and 4H level remains active until it is mitigated.

Two mitigation methods are available:

**High/Low**

* A level is considered reached when price's High or Low touches/breaks the level.

**Close**

* A level is considered reached only when the candle closes through the level.

This gives traders control over how strictly a level should be considered broken.

### ⚡ Break Zones

When an active level is broken, the indicator can display a temporary vertical background zone.

The zone duration is configurable in minutes.

These zones are designed to highlight the period immediately following a level break, where traders can watch for potential reactions and setups.

### 📉 Optional 1-Minute RSI Signals

An optional RSI-based signal model is included.

When enabled:

* A Daily/4H resistance break zone can look for a **SELL** condition when 1-minute RSI crosses back below the overbought level.
* A Daily/4H support break zone can look for a **BUY** condition when 1-minute RSI crosses back above the oversold level.

RSI length, overbought, and oversold levels are configurable.

### 🔄 Candle-Based Signals

When the RSI signal mode is disabled, the indicator uses its built-in candle-based reaction logic around the broken level.

After a resistance break, the indicator looks for bearish candle confirmation and a break of the relevant candle low.

After a support break, it looks for bullish candle confirmation and a break of the relevant candle high.

The indicator also tracks the reaction after a signal and limits the number of trades within the same zone.

### 🧮 Level Score Table

The table in the top-right corner provides a quick overview of currently active higher-timeframe levels.

It displays:

| Level   |        Active |          Score |
| ------- | ------------: | -------------: |
| 1D High | Active levels | Positive score |
| 4H High | Active levels | Positive score |
| 1D Low  | Active levels | Negative score |
| 4H Low  | Active levels | Negative score |

Daily levels carry a larger score weight than 4H levels.

This makes the table useful as a quick visual reference for the amount of higher-timeframe liquidity that remains active.

### 🟢🔴 Level Break Markers

The indicator can display vertical markers when the active level count reaches zero.

These markers help identify moments when the currently tracked Daily or 4H levels have been fully mitigated.

### 🔗 Overlapping Level Management

When a 4H level overlaps with an active Daily level at essentially the same price, the overlapping 4H level is removed from the active 4H set.

This helps reduce duplicate levels and keeps the chart cleaner.

## ⚙️ Main Settings

**Mitigation Source**

* High/Low
* Close

**Right Offset**
Controls how far active levels extend into the future.

**Daily Levels**

* Enable/Disable
* Number of periods
* Timeframe
* High/Low colors
* Line style

**4H Levels**

* Enable/Disable
* Number of periods
* Timeframe
* High/Low colors
* Line style

**Signals**

* Enable/Disable 1-minute RSI signals
* RSI length
* RSI overbought
* RSI oversold

**Vertical Zones**

* Enable/Disable
* Zone duration
* Bullish/Bearish break colors

## 📌 How I Use the Indicator

The main purpose of this indicator is not to tell you to blindly buy or sell every time price reaches a level.

Instead, use the Daily and 4H levels as **areas of interest**.

When price approaches or breaks an important level, watch the reaction:

**Resistance / High**
→ Price breaks a previous high
→ Monitor the break zone
→ Look for bearish rejection/reaction
→ Optional RSI confirmation can be used
→ SELL signal may appear according to the selected signal model

**Support / Low**
→ Price breaks a previous low
→ Monitor the break zone
→ Look for bullish rejection/reaction
→ Optional RSI confirmation can be used
→ BUY signal may appear according to the selected signal model

The indicator is therefore intended to provide **context and structure**, rather than replace trade management or independent analysis.

## ⚠️ Important

This indicator is a technical-analysis tool and does not guarantee profitable trades.

Signals should be evaluated together with:

* Market structure
* Volatility
* Session conditions
* Risk management
* Higher-timeframe context
* News and market conditions

Always test the indicator on your preferred market and timeframe before using it in live trading.

**For educational and analytical purposes only.**

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Highs & Lows_Neo - Daily & 4H Levels", overlay = true, max_lines_count = 500, max_boxes_count = 500)

// --- Constants ---
int MAX_TRADES_PER_ZONE = 2
float STOP_LOSS_PERCENT = 0.15

// --- Inputs ---
i_mitigation = input.string("High/Low", "Mitigation Source", options = ["High/Low", "Close"], tooltip = "Choose whether the line stops when the High/Low touches it or only when the candle close touches it.")
i_rightOffset = input.int(15, "Right Offset", minval = 0, tooltip = "How many bars into the future to extend active, unmitigated lines.")

i_showZones = input.bool(true, "Show Vertical Zones", group = "Vertical Zones", tooltip = "Display a vertical background zone when a level is broken.")
i_zoneDuration = input.int(30, "Zone Duration (Minutes)", minval = 1, group = "Vertical Zones", tooltip = "How many minutes the background remains highlighted after a level break.")
i_zoneBullColor = input.color(color.new(#089981, 85), "Bullish Break Color", group = "Vertical Zones", tooltip = "Color for the vertical zone when a resistance level is broken.")
i_zoneBearColor = input.color(color.new(#f23645, 85), "Bearish Break Color", group = "Vertical Zones", tooltip = "Color for the vertical zone when a support level is broken.")

i_showDaily = input.bool(true, "Show Daily Highs & Lows", group = "Daily Levels", tooltip = "Display highs and lows from previous days.")
i_dailyTimeframe = input.timeframe("D", "Timeframe", group = "Daily Levels", tooltip = "Timeframe used to calculate the prior-period high and low levels.")
i_dailyCount = input.int(5, "Number of Periods", minval = 1, maxval = 20, group = "Daily Levels", tooltip = "How many previous selected-timeframe periods to display levels for.")
i_dailyHighColor = input.color(color.new(color.gray, 30), "Daily High Color", group = "Daily Levels")
i_dailyLowColor = input.color(color.new(color.gray, 30), "Daily Low Color", group = "Daily Levels")
i_dailyStyle = input.string("Dashed", "Daily Line Style", options = ["Solid", "Dashed", "Dotted"], group = "Daily Levels")

i_show4h = input.bool(true, "Show 4H Highs & Lows", group = "4H Levels", tooltip = "Display highs and lows from previous 4H periods.")
i_4hTimeframe = input.timeframe("240", "Timeframe", group = "4H Levels", tooltip = "Timeframe used to calculate the prior-period high and low levels.")
i_4hCount = input.int(5, "Number of Periods", minval = 1, maxval = 20, group = "4H Levels", tooltip = "How many previous selected-timeframe periods to display levels for.")
i_4hHighColor = input.color(color.new(color.blue, 30), "4H High Color", group = "4H Levels")
i_4hLowColor = input.color(color.new(color.blue, 30), "4H Low Color", group = "4H Levels")
i_4hStyle = input.string("Dotted", "4H Line Style", options = ["Solid", "Dashed", "Dotted"], group = "4H Levels")

i_useRsiSignals = input.bool(false, "Use 1-Minute RSI Signals", group = "Signals", tooltip = "When enabled, entries use 1-minute RSI crosses; when disabled, the normal candle-based signal logic is used.")
i_rsiLength = input.int(14, "1-Minute RSI Length", minval = 1, group = "Signals", tooltip = "Length used to calculate the 1-minute RSI.")
i_rsiOversold = input.float(30.0, "RSI Oversold Level", minval = 0.0, maxval = 100.0, group = "Signals", tooltip = "Buy trigger: 1-minute RSI crosses back above this level in a support-break zone.")
i_rsiOverbought = input.float(70.0, "RSI Overbought Level", minval = 0.0, maxval = 100.0, group = "Signals", tooltip = "Sell trigger: 1-minute RSI crosses back below this level in a resistance-break zone.")
i_showVerticalLines = input.bool(true, "Show Vertical Lines", group = "Style", tooltip = "Toggle the solid and dashed vertical zero-count markers on or off.")

// --- Line Styles ---
dailyStyle = switch i_dailyStyle
    "Solid" => line.style_solid
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted
    => line.style_dashed

style4h = switch i_4hStyle
    "Solid" => line.style_solid
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted
    => line.style_dotted

// --- Types & Variables ---
type Level
    line id
    float price
    int startBar
    bool active
    float volume = 0.0

var activeDailyHighs = array.new<Level>()
var activeDailyLows = array.new<Level>()
var active4hHighs = array.new<Level>()
var active4hLows = array.new<Level>()

var int lastBreakTime = 0
var int lastBreakBar = na
var int lastBreakType = 0
var bool wasInZone = false

// --- Higher-Timeframe Data ---
[pdH, pdL, pdVol] = request.security(syminfo.tickerid, i_dailyTimeframe, [high[1], low[1], volume[1]], lookahead = barmerge.lookahead_on)
[p4hH, p4hL, p4hVol] = request.security(syminfo.tickerid, i_4hTimeframe, [high[1], low[1], volume[1]], lookahead = barmerge.lookahead_on)

isNewDay = ta.change(time(i_dailyTimeframe)) != 0
isNew4H = ta.change(time(i_4hTimeframe)) != 0

// --- New Daily Levels ---
if i_showDaily and isNewDay
    line dailyHighLine = line.new(bar_index, pdH, bar_index + i_rightOffset, pdH, color = i_dailyHighColor, style = dailyStyle)
    line dailyLowLine = line.new(bar_index, pdL, bar_index + i_rightOffset, pdL, color = i_dailyLowColor, style = dailyStyle)
    array.push(activeDailyHighs, Level.new(dailyHighLine, pdH, bar_index, true, nz(pdVol, 0.0)))
    array.push(activeDailyLows, Level.new(dailyLowLine, pdL, bar_index, true, nz(pdVol, 0.0)))
    if array.size(activeDailyHighs) > i_dailyCount
        Level oldHigh = array.shift(activeDailyHighs)
        line.delete(oldHigh.id)
    if array.size(activeDailyLows) > i_dailyCount
        Level oldLow = array.shift(activeDailyLows)
        line.delete(oldLow.id)

if not i_showDaily and (array.size(activeDailyHighs) > 0 or array.size(activeDailyLows) > 0)
    for lvl in activeDailyHighs
        line.delete(lvl.id)
    array.clear(activeDailyHighs)
    for lvl in activeDailyLows
        line.delete(lvl.id)
    array.clear(activeDailyLows)

// --- New 4H Levels ---
if i_show4h and isNew4H
    line high4hLine = line.new(bar_index, p4hH, bar_index + i_rightOffset, p4hH, color = i_4hHighColor, style = style4h)
    line low4hLine = line.new(bar_index, p4hL, bar_index + i_rightOffset, p4hL, color = i_4hLowColor, style = style4h)
    array.push(active4hHighs, Level.new(high4hLine, p4hH, bar_index, true, nz(p4hVol, 0.0)))
    array.push(active4hLows, Level.new(low4hLine, p4hL, bar_index, true, nz(p4hVol, 0.0)))
    if array.size(active4hHighs) > i_4hCount
        Level oldHigh4h = array.shift(active4hHighs)
        line.delete(oldHigh4h.id)
    if array.size(active4hLows) > i_4hCount
        Level oldLow4h = array.shift(active4hLows)
        line.delete(oldLow4h.id)

if not i_show4h and (array.size(active4hHighs) > 0 or array.size(active4hLows) > 0)
    for lvl in active4hHighs
        line.delete(lvl.id)
    array.clear(active4hHighs)
    for lvl in active4hLows
        line.delete(lvl.id)
    array.clear(active4hLows)

// --- Invalidate Overlapping 4H Levels ---
if array.size(active4hHighs) > 0
    for i = array.size(active4hHighs) - 1 to 0
        Level fourHourLvl = array.get(active4hHighs, i)
        if fourHourLvl.active
            bool overlapsDaily = false
            for dailyLvl in activeDailyHighs
                if dailyLvl.active and math.abs(fourHourLvl.price - dailyLvl.price) < syminfo.mintick * 0.5
                    overlapsDaily := true
            for dailyLvl in activeDailyLows
                if dailyLvl.active and math.abs(fourHourLvl.price - dailyLvl.price) < syminfo.mintick * 0.5
                    overlapsDaily := true
            if overlapsDaily
                line.delete(fourHourLvl.id)
                fourHourLvl.active := false
                array.set(active4hHighs, i, fourHourLvl)

if array.size(active4hLows) > 0
    for i = array.size(active4hLows) - 1 to 0
        Level fourHourLvl = array.get(active4hLows, i)
        if fourHourLvl.active
            bool overlapsDaily = false
            for dailyLvl in activeDailyHighs
                if dailyLvl.active and math.abs(fourHourLvl.price - dailyLvl.price) < syminfo.mintick * 0.5
                    overlapsDaily := true
            for dailyLvl in activeDailyLows
                if dailyLvl.active and math.abs(fourHourLvl.price - dailyLvl.price) < syminfo.mintick * 0.5
                    overlapsDaily := true
            if overlapsDaily
                line.delete(fourHourLvl.id)
                fourHourLvl.active := false
                array.set(active4hLows, i, fourHourLvl)

// --- Dynamic Extension & Mitigation ---
float mitHigh = i_mitigation == "High/Low" ? high : close
float mitLow = i_mitigation == "High/Low" ? low : close

if i_showDaily and array.size(activeDailyHighs) > 0
    for i = array.size(activeDailyHighs) - 1 to 0
        Level lvl = array.get(activeDailyHighs, i)
        if lvl.active and bar_index > lvl.startBar and mitHigh >= lvl.price
            line.set_x2(lvl.id, bar_index)
            lvl.active := false
            array.set(activeDailyHighs, i, lvl)
            lastBreakTime := time
            lastBreakBar := bar_index
            lastBreakType := 1
        else if lvl.active
            line.set_x2(lvl.id, bar_index + i_rightOffset)

if i_showDaily and array.size(activeDailyLows) > 0
    for i = array.size(activeDailyLows) - 1 to 0
        Level lvl = array.get(activeDailyLows, i)
        if lvl.active and bar_index > lvl.startBar and mitLow <= lvl.price
            line.set_x2(lvl.id, bar_index)
            lvl.active := false
            array.set(activeDailyLows, i, lvl)
            lastBreakTime := time
            lastBreakBar := bar_index
            lastBreakType := -1
        else if lvl.active
            line.set_x2(lvl.id, bar_index + i_rightOffset)

if i_show4h and array.size(active4hHighs) > 0
    for i = array.size(active4hHighs) - 1 to 0
        Level lvl = array.get(active4hHighs, i)
        if lvl.active and bar_index > lvl.startBar and mitHigh >= lvl.price
            line.set_x2(lvl.id, bar_index)
            lvl.active := false
            array.set(active4hHighs, i, lvl)
            lastBreakTime := time
            lastBreakBar := bar_index
            lastBreakType := 1
        else if lvl.active
            line.set_x2(lvl.id, bar_index + i_rightOffset)

if i_show4h and array.size(active4hLows) > 0
    for i = array.size(active4hLows) - 1 to 0
        Level lvl = array.get(active4hLows, i)
        if lvl.active and bar_index > lvl.startBar and mitLow <= lvl.price
            line.set_x2(lvl.id, bar_index)
            lvl.active := false
            array.set(active4hLows, i, lvl)
            lastBreakTime := time
            lastBreakBar := bar_index
            lastBreakType := -1
        else if lvl.active
            line.set_x2(lvl.id, bar_index + i_rightOffset)

// --- Entry Logic ---
bool inZone = i_showZones and lastBreakTime != 0 and time <= lastBreakTime + (i_zoneDuration * 60000)
bgcolor(inZone ? (lastBreakType == 1 ? i_zoneBearColor : i_zoneBullColor) : na, title = "Break Zone Background")

var int tradesInZone = 0
var bool tradeActive = false
var int activeTradeDirection = 0
var float activeStopPrice = na
var int activeEntryBar = na
var line activeEntryLine = na
var line activeStopLine = na
var int trackedZoneBreakBar = na
var bool waitingForSweep = false
var float sweepLevel = na
var int redCandlesCount = 0
var float firstRedLow = na
var float firstRedHigh = na
var int greenCandlesCount = 0
var float firstGreenLow = na
var float firstGreenHigh = na

bool isRed = close < open
bool isGreen = close > open
bool newZone = inZone and (na(trackedZoneBreakBar) or lastBreakBar != trackedZoneBreakBar)

if not inZone or newZone
    if tradeActive
        if not na(activeEntryLine)
            line.set_x2(activeEntryLine, bar_index)
        if not na(activeStopLine)
            line.set_x2(activeStopLine, bar_index)
    tradeActive := false
    activeTradeDirection := 0
    activeStopPrice := na
    activeEntryBar := na
    activeEntryLine := na
    activeStopLine := na
    tradesInZone := 0
    waitingForSweep := false
    sweepLevel := na
    redCandlesCount := 0
    firstRedLow := na
    firstRedHigh := na
    greenCandlesCount := 0
    firstGreenLow := na
    firstGreenHigh := na
    trackedZoneBreakBar := inZone ? lastBreakBar : na

bool stopHitThisBar = false
if inZone and tradeActive
    if bar_index > activeEntryBar
        if not na(activeEntryLine)
            line.set_x2(activeEntryLine, bar_index)
        if not na(activeStopLine)
            line.set_x2(activeStopLine, bar_index)
        bool stopWasHit = activeTradeDirection == 1 ? low <= activeStopPrice : high >= activeStopPrice
        if stopWasHit
            tradeActive := false
            activeTradeDirection := 0
            activeEntryBar := na
            activeEntryLine := na
            activeStopLine := na
            activeStopPrice := na
            stopHitThisBar := true

bool rsiBuyTrigger = false
bool rsiSellTrigger = false
var float previousRsi1m = na

if timeframe.in_seconds() > timeframe.in_seconds("1")
    array<float> rsiSamples1m = request.security_lower_tf(syminfo.tickerid, "1", ta.rsi(close, i_rsiLength))
    if array.size(rsiSamples1m) > 0
        for sampleIndex = 0 to array.size(rsiSamples1m) - 1
            float currentRsi1m = array.get(rsiSamples1m, sampleIndex)
            if not na(previousRsi1m) and not na(currentRsi1m)
                rsiBuyTrigger := rsiBuyTrigger or (previousRsi1m <= i_rsiOversold and currentRsi1m > i_rsiOversold)
                rsiSellTrigger := rsiSellTrigger or (previousRsi1m >= i_rsiOverbought and currentRsi1m < i_rsiOverbought)
            previousRsi1m := currentRsi1m
else
    float rsi1m = request.security(syminfo.tickerid, "1", ta.rsi(close, i_rsiLength), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
    rsiBuyTrigger := ta.crossover(rsi1m, i_rsiOversold)
    rsiSellTrigger := ta.crossunder(rsi1m, i_rsiOverbought)

bool sellSignal = false
bool buySignal = false

if inZone and not tradeActive and not stopHitThisBar and tradesInZone < MAX_TRADES_PER_ZONE
    if i_useRsiSignals
        if lastBreakType == 1 and rsiSellTrigger
            sellSignal := true
            tradesInZone += 1
            waitingForSweep := false
            sweepLevel := na
        else if lastBreakType == -1 and rsiBuyTrigger
            buySignal := true
            tradesInZone += 1
            waitingForSweep := false
            sweepLevel := na
    else
        if lastBreakType == 1
            if waitingForSweep
                if high > sweepLevel
                    waitingForSweep := false
                    redCandlesCount := 0
                    firstRedLow := na
                    firstRedHigh := na
            else
                if isRed
                    if redCandlesCount == 0
                        firstRedLow := low
                        firstRedHigh := high
                    redCandlesCount += 1
                else
                    redCandlesCount := 0
                    firstRedLow := na
                    firstRedHigh := na
                if redCandlesCount >= 1 and close < firstRedLow
                    sellSignal := true
                    tradesInZone += 1
                    waitingForSweep := true
                    sweepLevel := firstRedHigh
                    redCandlesCount := 0
                    firstRedLow := na
                    firstRedHigh := na

        if lastBreakType == -1
            if waitingForSweep
                if low < sweepLevel
                    waitingForSweep := false
                    greenCandlesCount := 0
                    firstGreenLow := na
                    firstGreenHigh := na
            else
                if isGreen
                    if greenCandlesCount == 0
                        firstGreenLow := low
                        firstGreenHigh := high
                    greenCandlesCount += 1
                else
                    greenCandlesCount := 0
                    firstGreenLow := na
                    firstGreenHigh := na
                if greenCandlesCount >= 1 and close > firstGreenHigh
                    buySignal := true
                    tradesInZone += 1
                    waitingForSweep := true
                    sweepLevel := firstGreenLow
                    greenCandlesCount := 0
                    firstGreenLow := na
                    firstGreenHigh := na

if buySignal or sellSignal
    tradeActive := true
    activeTradeDirection := buySignal ? 1 : -1
    activeEntryBar := bar_index
    activeStopPrice := buySignal ? close * (1.0 - STOP_LOSS_PERCENT / 100.0) : close * (1.0 + STOP_LOSS_PERCENT / 100.0)
    activeEntryLine := line.new(bar_index, close, bar_index + 1, close, color = color.new(#5b9cf6, 0), style = line.style_dotted, width = 1)
    activeStopLine := line.new(bar_index, activeStopPrice, bar_index + 1, activeStopPrice, color = color.new(#f23645, 0), style = line.style_solid, width = 2)

plotshape(sellSignal, "Sell Signal", shape.triangledown, location.abovebar, color.new(#f23645, 0), size = size.small)
plotshape(buySignal, "Buy Signal", shape.triangleup, location.belowbar, color.new(#089981, 0), size = size.small)

// --- Active Level Counts, Alerts & Score Table ---
var table scoreTable = table.new(position.top_right, 3, 5, border_width = 1, frame_color = #2E2E2E, border_color = #2E2E2E)

int dailyHighActive = 0
int fourHourHighActive = 0
int dailyLowActive = 0
int fourHourLowActive = 0

for lvl in activeDailyHighs
    if lvl.active
        dailyHighActive += 1
for lvl in active4hHighs
    if lvl.active
        fourHourHighActive += 1
for lvl in activeDailyLows
    if lvl.active
        dailyLowActive += 1
for lvl in active4hLows
    if lvl.active
        fourHourLowActive += 1

int dailyHighScore = dailyHighActive * 2
int fourHourHighScore = fourHourHighActive
int dailyLowScore = dailyLowActive * -2
int fourHourLowScore = fourHourLowActive * -1

bool dailyHighZeroEvent = barstate.isconfirmed and dailyHighActive == 0 and nz(dailyHighActive[1], 0) > 0
bool fourHourHighZeroEvent = barstate.isconfirmed and fourHourHighActive == 0 and nz(fourHourHighActive[1], 0) > 0
bool dailyLowZeroEvent = barstate.isconfirmed and dailyLowActive == 0 and nz(dailyLowActive[1], 0) > 0
bool fourHourLowZeroEvent = barstate.isconfirmed and fourHourLowActive == 0 and nz(fourHourLowActive[1], 0) > 0
bool anyLevelZeroEvent = dailyHighZeroEvent or fourHourHighZeroEvent or dailyLowZeroEvent or fourHourLowZeroEvent

bool highPairZero = dailyHighActive == 0 and fourHourHighActive == 0
bool lowPairZero = dailyLowActive == 0 and fourHourLowActive == 0
bool highPairZeroEvent = barstate.isconfirmed and highPairZero and not (nz(dailyHighActive[1], 0) == 0 and nz(fourHourHighActive[1], 0) == 0)
bool lowPairZeroEvent = barstate.isconfirmed and lowPairZero and not (nz(dailyLowActive[1], 0) == 0 and nz(fourHourLowActive[1], 0) == 0)
bool pairedZeroLineEvent = highPairZeroEvent or lowPairZeroEvent
bool fourHourZeroLineEvent = (fourHourHighZeroEvent or fourHourLowZeroEvent) and not pairedZeroLineEvent

if i_showVerticalLines and pairedZeroLineEvent
    line.new(x1 = bar_index, y1 = low, x2 = bar_index, y2 = high, extend = extend.both, color = color.white, style = line.style_solid, width = 1)
else if i_showVerticalLines and fourHourZeroLineEvent
    line.new(x1 = bar_index, y1 = low, x2 = bar_index, y2 = high, extend = extend.both, color = color.white, style = line.style_dashed, width = 1)

alertcondition(anyLevelZeroEvent, title = "Any active level count reaches zero", message = "At least one active daily or 4H level count has changed to zero.")

if barstate.islast
    table.clear(scoreTable, 0, 0, 2, 4)
    table.cell(scoreTable, 0, 0, "Level", text_color = #808080, bgcolor = #161616, text_size = size.small)
    table.cell(scoreTable, 1, 0, "Active", text_color = #808080, bgcolor = #161616, text_size = size.small)
    table.cell(scoreTable, 2, 0, "Score", text_color = #808080, bgcolor = #161616, text_size = size.small)

    table.cell(scoreTable, 0, 1, "1D High", text_color = #089981, bgcolor = #161616, text_size = size.small)
    table.cell(scoreTable, 1, 1, str.tostring(dailyHighActive), text_color = #DBDBDB, bgcolor = #161616, text_size = size.small)
    table.cell(scoreTable, 2, 1, "+" + str.tostring(dailyHighScore), text_color = #089981, bgcolor = #161616, text_size = size.small)

    table.cell(scoreTable, 0, 2, "4H High", text_color = #089981, bgcolor = #161616, text_size = size.small)
    table.cell(scoreTable, 1, 2, str.tostring(fourHourHighActive), text_color = #DBDBDB, bgcolor = #161616, text_size = size.small)
    table.cell(scoreTable, 2, 2, "+" + str.tostring(fourHourHighScore), text_color = #089981, bgcolor = #161616, text_size = size.small)

    table.cell(scoreTable, 0, 3, "1D Low", text_color = #f23645, bgcolor = #161616, text_size = size.small)
    table.cell(scoreTable, 1, 3, str.tostring(dailyLowActive), text_color = #DBDBDB, bgcolor = #161616, text_size = size.small)
    table.cell(scoreTable, 2, 3, str.tostring(dailyLowScore), text_color = #f23645, bgcolor = #161616, text_size = size.small)

    table.cell(scoreTable, 0, 4, "4H Low", text_color = #f23645, bgcolor = #161616, text_size = size.small)
    table.cell(scoreTable, 1, 4, str.tostring(fourHourLowActive), text_color = #DBDBDB, bgcolor = #161616, text_size = size.small)
    table.cell(scoreTable, 2, 4, str.tostring(fourHourLowScore), text_color = #f23645, bgcolor = #161616, text_size = size.small)
````
