# Daily High Low Reversal Alert v9_SARAN

- url: https://www.tradingview.com/script/4O6y1LFM-Daily-High-Low-Reversal-Alert-v9-SARAN/
- type: indicator
- pine_id: PUB;f5e4edd4540c4d1a9e29beefe769c30a
- version: 1.0

## Description

Script draws a horizontal level for each days high and lows at 30 mins before the market. All the highs will be marked with green color lines and lows will be marked with red color lines. Then, during market hours on 5mins, 2mins time frame whenever there is a reversal closer to the levels a trigger would be produced. Levels would be drawn for the stocks in the user's watchlist and triggers can be seen on the charts for all the ticker symbols. if you need, the notification for each triggers users got to setup the triggers for each symbol manually. ( it is an one time setup).

## Source Code

````pine
//@version=6
indicator("Daily High Low Reversal Alert v9", overlay=true, max_lines_count=500)

// ══════════════════════════════════════════
// INPUTS — GENERAL
// ══════════════════════════════════════════
tolerance   = input.float(0.3, "S/R Tolerance (%)",  minval=0.05, maxval=1.0, step=0.05)
lookback    = input.int(50,    "Lookback Bars",        minval=20,   maxval=200)
showLabels  = input.bool(true, "Show Pattern Labels")
daysBack    = input.int(20,    "How Many Days Back",   minval=1,    maxval=50)

// ══════════════════════════════════════════
// INPUTS — LINE EXTENSION PER TIMEFRAME
// ══════════════════════════════════════════
lineExtend30m   = input.int(50,  "Line Extension — 30min (bars)", minval=5, maxval=500, step=5, group="Line Extension Per Timeframe")
lineExtend5m    = input.int(150, "Line Extension — 5min  (bars)", minval=5, maxval=500, step=5, group="Line Extension Per Timeframe")
lineExtend2m    = input.int(375, "Line Extension — 2min  (bars)", minval=5, maxval=500, step=5, group="Line Extension Per Timeframe")
lineExtendOther = input.int(50,  "Line Extension — Other (bars)", minval=5, maxval=500, step=5, group="Line Extension Per Timeframe")

lineExtend = timeframe.period == "2"  ? lineExtend2m  :
             timeframe.period == "5"  ? lineExtend5m  :
             timeframe.period == "30" ? lineExtend30m :
             lineExtendOther

// ══════════════════════════════════════════
// INPUTS — MANUAL LEVELS
// ══════════════════════════════════════════
showManual = input.bool(false, "Show Manual Levels", group="Manual Levels")
manualL1   = input.float(0.0, "Manual Level 1",      group="Manual Levels", minval=0)
manualL2   = input.float(0.0, "Manual Level 2",      group="Manual Levels", minval=0)
manualL3   = input.float(0.0, "Manual Level 3",      group="Manual Levels", minval=0)
manualL4   = input.float(0.0, "Manual Level 4",      group="Manual Levels", minval=0)
manualL5   = input.float(0.0, "Manual Level 5",      group="Manual Levels", minval=0)

// ══════════════════════════════════════════
// TIMEFRAME LABEL
// ══════════════════════════════════════════
tfLabel = timeframe.period == "2"   ? "2min"  :
          timeframe.period == "5"   ? "5min"  :
          timeframe.period == "30"  ? "30min" :
          timeframe.period == "60"  ? "1H"    :
          timeframe.period == "240" ? "4H"    :
          timeframe.period == "D"   ? "1D"    :
          timeframe.period == "W"   ? "1W"    :
          timeframe.period == "M"   ? "1M"    : timeframe.period

// ══════════════════════════════════════════
// TIME CALCULATIONS — ALL IN ET
// ══════════════════════════════════════════
nyHour   = hour(time,       "America/New_York")
nyMinute = minute(time,     "America/New_York")
nyYear   = year(time,       "America/New_York")
nyMonth  = month(time,      "America/New_York")
nyDay    = dayofmonth(time, "America/New_York")
nyTime   = nyHour * 100 + nyMinute

isMarketHours = nyTime >= 930 and nyTime < 1600

// ══════════════════════════════════════════
// FETCH DAILY DATA
// ══════════════════════════════════════════
dailyBarIdx = request.security(
                syminfo.tickerid, "D",
                bar_index,
                lookahead=barmerge.lookahead_off)

dHigh = request.security(
          syminfo.tickerid, "D",
          high,
          lookahead=barmerge.lookahead_off)

dLow = request.security(
         syminfo.tickerid, "D",
         low,
         lookahead=barmerge.lookahead_off)

// ══════════════════════════════════════════
// DRAW TRIGGER
// Primary:  9:00 AM ET = 6:30 PM IST
// Fallback: 9:30 AM ET = 7:00 PM IST
// Both use ET date to avoid IST mismatch
// lastDrawnDate prevents duplicates
// ══════════════════════════════════════════
isPreMarketReady = nyTime >= 900 and nyTime < 930
isMarketOpen     = nyTime >= 930 and nyTime < 932

currentDateET    = nyYear * 10000 + nyMonth * 100 + nyDay
var int lastDrawnDate = 0

isNewDrawTrigger = (isPreMarketReady or isMarketOpen) and
                   currentDateET != lastDrawnDate

// ══════════════════════════════════════════
// ARRAYS
// ══════════════════════════════════════════
var float[] highLevels = array.new_float(0)
var int[]   highBar    = array.new_int(0)
var float[] lowLevels  = array.new_float(0)
var int[]   lowBar     = array.new_int(0)

// ══════════════════════════════════════════
// DRAW DAILY HIGH LOW
// ══════════════════════════════════════════
if isNewDrawTrigger and not na(dHigh) and not na(dLow)
    lastDrawnDate := currentDateET

    // Daily HIGH — Green
    line.new(bar_index, dHigh,
             bar_index + lineExtend, dHigh,
             color  = color.new(color.green, 0),
             width  = 2,
             style  = line.style_solid,
             extend = extend.none)
    array.unshift(highLevels, dHigh)
    array.unshift(highBar,    bar_index)
    if array.size(highLevels) > daysBack
        array.pop(highLevels)
        array.pop(highBar)

    // Daily LOW — Red
    line.new(bar_index, dLow,
             bar_index + lineExtend, dLow,
             color  = color.new(color.red, 0),
             width  = 2,
             style  = line.style_solid,
             extend = extend.none)
    array.unshift(lowLevels, dLow)
    array.unshift(lowBar,    bar_index)
    if array.size(lowLevels) > daysBack
        array.pop(lowLevels)
        array.pop(lowBar)

// ══════════════════════════════════════════
// MANUAL LEVELS — ORANGE DASHED
// ══════════════════════════════════════════
var line manLine1 = na
var line manLine2 = na
var line manLine3 = na
var line manLine4 = na
var line manLine5 = na

if barstate.islast and showManual
    line.delete(manLine1)
    line.delete(manLine2)
    line.delete(manLine3)
    line.delete(manLine4)
    line.delete(manLine5)
    if manualL1 > 0
        manLine1 := line.new(bar_index - 500, manualL1, bar_index, manualL1,
                             color=color.new(color.orange, 0),
                             width=2, style=line.style_dashed,
                             extend=extend.right)
    if manualL2 > 0
        manLine2 := line.new(bar_index - 500, manualL2, bar_index, manualL2,
                             color=color.new(color.orange, 0),
                             width=2, style=line.style_dashed,
                             extend=extend.right)
    if manualL3 > 0
        manLine3 := line.new(bar_index - 500, manualL3, bar_index, manualL3,
                             color=color.new(color.orange, 0),
                             width=2, style=line.style_dashed,
                             extend=extend.right)
    if manualL4 > 0
        manLine4 := line.new(bar_index - 500, manualL4, bar_index, manualL4,
                             color=color.new(color.orange, 0),
                             width=2, style=line.style_dashed,
                             extend=extend.right)
    if manualL5 > 0
        manLine5 := line.new(bar_index - 500, manualL5, bar_index, manualL5,
                             color=color.new(color.orange, 0),
                             width=2, style=line.style_dashed,
                             extend=extend.right)

// ══════════════════════════════════════════
// LEVEL PROXIMITY CHECK
// ══════════════════════════════════════════
isNearLevel(src, lvl) =>
    lvl > 0 and math.abs(src - lvl) / lvl * 100 <= tolerance

nearAnyLevel() =>
    bool  found = false
    float fLvl  = na

    if array.size(highLevels) > 0
        for i = 0 to array.size(highLevels) - 1
            lvl      = array.get(highLevels, i)
            drawnBar = array.get(highBar,    i)
            if bar_index <= drawnBar + lineExtend
                if isNearLevel(high, lvl)
                    found := true
                    fLvl  := lvl

    if array.size(lowLevels) > 0
        for i = 0 to array.size(lowLevels) - 1
            lvl      = array.get(lowLevels, i)
            drawnBar = array.get(lowBar,    i)
            if bar_index <= drawnBar + lineExtend
                if isNearLevel(low, lvl)
                    found := true
                    fLvl  := lvl

    if showManual
        if isNearLevel(low, manualL1) or isNearLevel(high, manualL1)
            found := true
            fLvl  := manualL1
        if isNearLevel(low, manualL2) or isNearLevel(high, manualL2)
            found := true
            fLvl  := manualL2
        if isNearLevel(low, manualL3) or isNearLevel(high, manualL3)
            found := true
            fLvl  := manualL3
        if isNearLevel(low, manualL4) or isNearLevel(high, manualL4)
            found := true
            fLvl  := manualL4
        if isNearLevel(low, manualL5) or isNearLevel(high, manualL5)
            found := true
            fLvl  := manualL5

    [found, fLvl]

// ══════════════════════════════════════════
// CANDLE MEASUREMENTS
// ══════════════════════════════════════════
bodyHigh   = math.max(open, close)
bodyLow    = math.min(open, close)
bodySize   = bodyHigh - bodyLow
totalRange = high - low
upperWick  = high    - bodyHigh
lowerWick  = bodyLow - low

// ══════════════════════════════════════════
// PATTERN DETECTION — MARKET HOURS ONLY
// ══════════════════════════════════════════

// Standard Hammer
isStandardHammer = isMarketHours and
                   totalRange    > 0 and
                   lowerWick    >= totalRange * 0.45 and
                   bodySize     <= totalRange * 0.40 and
                   upperWick    <= totalRange * 0.20 and
                   bodyLow      >= low + totalRange * 0.45

// Special Hammer — Close = High
isSpecialHammer = isMarketHours and
                  totalRange   > 0 and
                  close        >= high * 0.999 and
                  lowerWick   >= totalRange * 0.40 and
                  upperWick   <= totalRange * 0.20

isHammer = isStandardHammer or isSpecialHammer

// Standard Inverted Hammer
isStandardInvHammer = isMarketHours and
                      totalRange   > 0 and
                      upperWick   >= totalRange * 0.45 and
                      bodySize    <= totalRange * 0.40 and
                      lowerWick   <= totalRange * 0.20 and
                      bodyHigh    <= high - totalRange * 0.45

// Special Inverted Hammer — Open = Low
isSpecialInvHammer = isMarketHours and
                     totalRange  > 0 and
                     open        <= low * 1.001 and
                     upperWick  >= totalRange * 0.40 and
                     lowerWick  <= totalRange * 0.20

isInvertedHammer = isStandardInvHammer or isSpecialInvHammer

// ══════════════════════════════════════════
// ALERTS + LABELS
// ══════════════════════════════════════════
[nearLevel, foundLvl] = nearAnyLevel()

levelStr = not na(foundLvl) ?
           str.tostring(math.round(foundLvl, 2)) :
           str.tostring(math.round(close,    2))

triggerAlert(patternName, direction) =>
    msg = syminfo.ticker + " | " + tfLabel +
          " | Level: "   + levelStr        +
          " | "          + patternName     +
          " | "          + direction
    alert(msg, alert.freq_once_per_bar_close)

if isHammer and nearLevel
    triggerAlert("Hammer", "⬆️ BULLISH")
    if showLabels
        label.new(bar_index, low - totalRange * 0.5,
                  "🔨 Hammer\n" + tfLabel,
                  color=color.teal, textcolor=color.white,
                  style=label.style_label_up, size=size.small)

if isInvertedHammer and nearLevel
    triggerAlert("Inverted Hammer", "⬆️ BULLISH")
    if showLabels
        label.new(bar_index, low - totalRange * 0.5,
                  "🔨 Inv Hammer\n" + tfLabel,
                  color=color.green, textcolor=color.white,
                  style=label.style_label_up, size=size.small)

// ══════════════════════════════════════════
// VISUAL SHAPES
// ══════════════════════════════════════════
plotshape(isHammer and nearLevel,
          title="Hammer",
          style=shape.triangleup,
          location=location.belowbar,
          color=color.teal, size=size.normal)

plotshape(isInvertedHammer and nearLevel,
          title="Inv Hammer",
          style=shape.triangleup,
          location=location.belowbar,
          color=color.green, size=size.normal)
````
