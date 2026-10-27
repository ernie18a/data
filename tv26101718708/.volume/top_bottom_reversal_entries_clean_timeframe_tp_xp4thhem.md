# Top Bottom Reversal Entries + Clean Timeframe TP

- url: https://www.tradingview.com/script/xp4THHEm/
- type: indicator
- pine_id: PUB;c73751de6ffe40eb817849ca6dc6f1be
- version: 1.0

## Description

Top Bottom Reversal Entries + Clean Timeframe TP is a reversal-focused overlay designed to identify potential market tops and bottoms using a multi-factor scoring engine.

The script combines RSI behavior, wick rejection, swing liquidity sweeps, Bollinger Band extremes, candle structure, ATR-based range validation, optional volume filtering, and EMA context into one clean reversal framework.

It is built for traders who want a visual entry map for possible reversal zones, including clean ATR-based take-profit and stop-loss levels that automatically adapt to the active chart timeframe.

Key Features

Top & Bottom Reversal Detection
The indicator searches for possible reversal conditions after price reaches local extremes. It evaluates both long and short setups using a structured score system.

Multi-Factor Score Engine
Long and short signals are based on a combination of:

RSI overbought / oversold behavior
Wick rejection
Swing high or swing low sweeps
Bollinger Band extremes
Engulfing candle structure
Previous candle confirmation
ATR-based candle range validation

A signal is only triggered once the required score threshold is reached.

Liquidity Sweep Logic
The script detects when price takes out a previous swing high or swing low and then closes back inside the range, highlighting potential trap or reversal areas.

Wick Rejection Filter
Strong upper or lower wicks are used to identify rejection candles near potential tops or bottoms.

Bollinger Band Context
Optional Bollinger Bands help show when price is trading near statistical extremes.

EMA 200 Context Filter
The EMA can be displayed for trend context.
It can also be used as a soft or hard filter depending on the settings.

Optional Volume Filter
A volume filter can be enabled to require above-average volume during reversal setups.

Cooldown & Alternating Signals
To reduce chart noise, the indicator includes cooldown logic and an optional long/short alternation mode.

Clean TP / SL System

The script includes a clean visual take-profit and stop-loss system based on ATR.

When a long or short setup appears, the indicator can draw:

Entry line
TP1
TP2
TP3
Stop Loss

The TP and SL distances can be calculated in two ways:

Auto Timeframe Mode
Automatically adjusts ATR multipliers depending on the active chart timeframe.
Lower timeframes use tighter targets, while higher timeframes use wider targets.

Manual Mode
Allows full control over TP1, TP2, TP3, and SL ATR multipliers.

Old TP/SL levels can be cleared automatically when a new entry appears or once TP3 / SL is reached.

Signal Labels

The chart displays simple and clean labels:

L for possible bottom long setups
S for possible top short setups

Each label includes a tooltip with ticker, entry price, and setup score.

Alerts

The indicator includes alert conditions for:

Possible Bottom Long
Possible Top Short

It also triggers built-in alert messages once a confirmed setup appears on bar close.

How to Use

This indicator is designed as a reversal entry assistant, not as a fully automated trading system.

It can help traders identify areas where price may be forming a potential top or bottom, especially when multiple reversal factors align.

Typical use cases include:

Spotting possible bottom reversals after liquidity sweeps
Identifying possible top reversals after overextended moves
Mapping ATR-based profit targets and stop zones
Combining reversal labels with higher-timeframe context
Filtering trades using EMA 200, Bollinger Bands, or volume

For best results, use this tool together with your own market structure, session timing, liquidity, and risk management rules.

Notes

Signals are generated only after bar confirmation.
The TP/SL system is visual and based on ATR from the signal candle.
The indicator does not execute trades and does not guarantee that any target or stop will be reached.

The reversal score is designed to highlight confluence, not certainty.

Disclaimer

This indicator is for educational and analytical purposes only.
It does not provide financial advice, trading recommendations, or guaranteed results. Always manage risk carefully and perform your own analysis before entering any trade.

## Source Code

````pine
//@version=5
indicator("Top Bottom Reversal Entries + Clean Timeframe TP", "TB Reversal Clean TP", overlay=true, max_labels_count=500, max_lines_count=500)

// ═══════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════

grpEntry = "Entry Engine"

rsiLen       = input.int(14, "RSI Length", group=grpEntry)
rsiOB        = input.int(68, "RSI Overbought", minval=55, maxval=90, group=grpEntry)
rsiOS        = input.int(32, "RSI Oversold", minval=10, maxval=45, group=grpEntry)
atrLen       = input.int(14, "ATR Length", group=grpEntry)
minAtrRange  = input.float(0.30, "Min Candle Range × ATR", step=0.05, group=grpEntry)
cooldownBars = input.int(5, "Cooldown Bars", minval=1, maxval=50, group=grpEntry)
alternate    = input.bool(true, "Long/Short abwechselnd", group=grpEntry)

grpReversal = "Top / Bottom Detection"

swingLen      = input.int(8, "Swing Lookback", minval=3, maxval=50, group=grpReversal)
wickMin       = input.float(0.42, "Min Wick Anteil", minval=0.10, maxval=0.90, step=0.01, group=grpReversal)
bbLen         = input.int(20, "Bollinger Length", group=grpReversal)
bbMult        = input.float(2.0, "Bollinger Mult", step=0.1, group=grpReversal)
useVolFilter  = input.bool(false, "Volume Filter", group=grpReversal)
volMult       = input.float(1.05, "Volume × MA", step=0.05, group=grpReversal)

grpTrend = "Context Filter"

showEMA       = input.bool(true, "EMA 200 anzeigen", group=grpTrend)
emaLen        = input.int(200, "EMA Length", group=grpTrend)
useSoftEMA    = input.bool(true, "EMA nur als Kontext, nicht hart blockieren", group=grpTrend)

grpTP = "Take Profit / Stop"

showTP          = input.bool(true, "TP/SL anzeigen", group=grpTP)
tpMode          = input.string("Auto Timeframe", "TP Mode", options=["Auto Timeframe", "Manual"], group=grpTP)
manualTP1       = input.float(0.45, "Manual TP1 × ATR", step=0.05, group=grpTP)
manualTP2       = input.float(0.80, "Manual TP2 × ATR", step=0.05, group=grpTP)
manualTP3       = input.float(1.20, "Manual TP3 × ATR", step=0.05, group=grpTP)
manualSL        = input.float(0.70, "Manual SL × ATR", step=0.05, group=grpTP)
tpLineBars      = input.int(45, "TP/SL Linienlänge", minval=10, maxval=300, group=grpTP)
clearOnNewEntry = input.bool(true, "Vergangene TPs bei neuem Entry löschen", group=grpTP)
clearOnExit     = input.bool(true, "TP/SL nach TP3 oder SL löschen", group=grpTP)

grpVis = "Visuals"

showOnlyLastEntry = input.bool(false, "Nur letzten Entry anzeigen", group=grpVis)
showBB            = input.bool(false, "Bollinger Bands anzeigen", group=grpVis)
longColor         = input.color(color.new(color.lime, 0), "Long Farbe", group=grpVis)
shortColor        = input.color(color.new(color.red, 0), "Short Farbe", group=grpVis)
tpColor           = input.color(color.new(color.teal, 0), "TP Farbe", group=grpVis)
slColor           = input.color(color.new(color.orange, 0), "SL Farbe", group=grpVis)
emaColor          = input.color(color.new(color.gray, 70), "EMA Farbe", group=grpVis)

// ═══════════════════════════════════════════════════════════════════════════
// CORE
// ═══════════════════════════════════════════════════════════════════════════

ema200 = ta.ema(close, emaLen)
rsiVal = ta.rsi(close, rsiLen)
atrVal = ta.atr(atrLen)

rangeVal = high - low
bodyVal  = math.abs(close - open)

upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

upperWickRatio = rangeVal > 0 ? upperWick / rangeVal : 0.0
lowerWickRatio = rangeVal > 0 ? lowerWick / rangeVal : 0.0

rangeOk = rangeVal > atrVal * minAtrRange

volMA = ta.sma(volume, 20)
volOk = not useVolFilter or volume > volMA * volMult

basis = ta.sma(close, bbLen)
dev   = ta.stdev(close, bbLen) * bbMult
bbTop = basis + dev
bbBot = basis - dev

nearLowerBB = low <= bbBot or close <= bbBot + atrVal * 0.25
nearUpperBB = high >= bbTop or close >= bbTop - atrVal * 0.25

prevSwingLow  = ta.lowest(low[1], swingLen)
prevSwingHigh = ta.highest(high[1], swingLen)

sweepLow  = low < prevSwingLow and close > prevSwingLow
sweepHigh = high > prevSwingHigh and close < prevSwingHigh

bullishCandle = close > open
bearishCandle = close < open

bullishEngulfing = bullishCandle and close[1] < open[1] and close > open[1] and open <= close[1]
bearishEngulfing = bearishCandle and close[1] > open[1] and close < open[1] and open >= close[1]

rsiBottom = rsiVal <= rsiOS or ta.crossover(rsiVal, rsiOS) or rsiVal < 42 and rsiVal > rsiVal[1]
rsiTop    = rsiVal >= rsiOB or ta.crossunder(rsiVal, rsiOB) or rsiVal > 58 and rsiVal < rsiVal[1]

bottomRejection = lowerWickRatio >= wickMin and close > low + rangeVal * 0.50
topRejection    = upperWickRatio >= wickMin and close < high - rangeVal * 0.50

softLongContext  = useSoftEMA ? true : close > ema200
softShortContext = useSoftEMA ? true : close < ema200

// ═══════════════════════════════════════════════════════════════════════════
// SCORE ENGINE
// ═══════════════════════════════════════════════════════════════════════════

longScore = 0
longScore += rsiBottom ? 2 : 0
longScore += bottomRejection ? 2 : 0
longScore += sweepLow ? 2 : 0
longScore += nearLowerBB ? 1 : 0
longScore += bullishEngulfing ? 1 : 0
longScore += close > close[1] ? 1 : 0
longScore += rangeOk ? 1 : 0

shortScore = 0
shortScore += rsiTop ? 2 : 0
shortScore += topRejection ? 2 : 0
shortScore += sweepHigh ? 2 : 0
shortScore += nearUpperBB ? 1 : 0
shortScore += bearishEngulfing ? 1 : 0
shortScore += close < close[1] ? 1 : 0
shortScore += rangeOk ? 1 : 0

bottomSetup = longScore >= 5 and volOk and softLongContext
topSetup    = shortScore >= 5 and volOk and softShortContext

// ═══════════════════════════════════════════════════════════════════════════
// TIMEFRAME TP/SL — ENGER ABGESTIMMT
// ═══════════════════════════════════════════════════════════════════════════

f_auto_mults() =>
    float tp1 = 0.45
    float tp2 = 0.80
    float tp3 = 1.20
    float sl  = 0.70

    if timeframe.isintraday
        tf = timeframe.multiplier

        if tf <= 1
            tp1 := 0.25
            tp2 := 0.45
            tp3 := 0.70
            sl  := 0.45
        else if tf <= 3
            tp1 := 0.30
            tp2 := 0.55
            tp3 := 0.85
            sl  := 0.50
        else if tf <= 5
            tp1 := 0.35
            tp2 := 0.65
            tp3 := 1.00
            sl  := 0.55
        else if tf <= 15
            tp1 := 0.45
            tp2 := 0.80
            tp3 := 1.20
            sl  := 0.70
        else if tf <= 30
            tp1 := 0.55
            tp2 := 1.00
            tp3 := 1.50
            sl  := 0.85
        else if tf <= 60
            tp1 := 0.70
            tp2 := 1.25
            tp3 := 1.90
            sl  := 1.00
        else if tf <= 240
            tp1 := 0.90
            tp2 := 1.60
            tp3 := 2.40
            sl  := 1.20
        else
            tp1 := 1.10
            tp2 := 2.00
            tp3 := 3.00
            sl  := 1.40
    else if timeframe.isdaily
        tp1 := 1.20
        tp2 := 2.20
        tp3 := 3.40
        sl  := 1.50
    else if timeframe.isweekly
        tp1 := 1.80
        tp2 := 3.20
        tp3 := 5.00
        sl  := 2.00

    [tp1, tp2, tp3, sl]

[autoTP1, autoTP2, autoTP3, autoSL] = f_auto_mults()

tp1Mult = tpMode == "Auto Timeframe" ? autoTP1 : manualTP1
tp2Mult = tpMode == "Auto Timeframe" ? autoTP2 : manualTP2
tp3Mult = tpMode == "Auto Timeframe" ? autoTP3 : manualTP3
slMult  = tpMode == "Auto Timeframe" ? autoSL  : manualSL

// ═══════════════════════════════════════════════════════════════════════════
// SIGNAL FILTERS
// ═══════════════════════════════════════════════════════════════════════════

var int lastSignal = 0
var int lastLongBar = na
var int lastShortBar = na

longCooldownOk  = na(lastLongBar) or bar_index - lastLongBar >= cooldownBars
shortCooldownOk = na(lastShortBar) or bar_index - lastShortBar >= cooldownBars

alternateLongOk  = not alternate or lastSignal != 1
alternateShortOk = not alternate or lastSignal != -1

longSignal  = barstate.isconfirmed and bottomSetup and longCooldownOk and alternateLongOk
shortSignal = barstate.isconfirmed and topSetup and shortCooldownOk and alternateShortOk

// ═══════════════════════════════════════════════════════════════════════════
// DRAWING STORAGE
// ═══════════════════════════════════════════════════════════════════════════

var label lastEntryLabel = na
var array<line> levelLines = array.new_line()
var array<label> levelLabels = array.new_label()

var bool tradeActive = false
var int activeDir = 0
var float activeSL = na
var float activeTP3 = na

f_clear_levels() =>
    while array.size(levelLines) > 0
        line.delete(array.shift(levelLines))

    while array.size(levelLabels) > 0
        label.delete(array.shift(levelLabels))

f_clear_entry() =>
    if not na(lastEntryLabel)
        label.delete(lastEntryLabel)

f_draw_levels(bool isLong, float entry, float atrNow) =>
    float tp1 = isLong ? entry + atrNow * tp1Mult : entry - atrNow * tp1Mult
    float tp2 = isLong ? entry + atrNow * tp2Mult : entry - atrNow * tp2Mult
    float tp3 = isLong ? entry + atrNow * tp3Mult : entry - atrNow * tp3Mult
    float sl  = isLong ? entry - atrNow * slMult  : entry + atrNow * slMult

    line lEntry = line.new(bar_index, entry, bar_index + tpLineBars, entry, xloc=xloc.bar_index, color=color.new(color.white, 70), style=line.style_dashed, width=1)
    line ltp1   = line.new(bar_index, tp1,   bar_index + tpLineBars, tp1,   xloc=xloc.bar_index, color=color.new(tpColor, 0), style=line.style_dotted, width=1)
    line ltp2   = line.new(bar_index, tp2,   bar_index + tpLineBars, tp2,   xloc=xloc.bar_index, color=color.new(tpColor, 15), style=line.style_dotted, width=1)
    line ltp3   = line.new(bar_index, tp3,   bar_index + tpLineBars, tp3,   xloc=xloc.bar_index, color=color.new(tpColor, 30), style=line.style_dotted, width=1)
    line lsl    = line.new(bar_index, sl,    bar_index + tpLineBars, sl,    xloc=xloc.bar_index, color=color.new(slColor, 0), style=line.style_dashed, width=1)

    label lbE = label.new(bar_index + tpLineBars, entry, "EN " + str.tostring(entry, format.mintick), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(color.white, 88), textcolor=color.white, size=size.tiny)
    label lb1 = label.new(bar_index + tpLineBars, tp1, "TP1 " + str.tostring(tp1, format.mintick), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(tpColor, 82), textcolor=tpColor, size=size.tiny)
    label lb2 = label.new(bar_index + tpLineBars, tp2, "TP2 " + str.tostring(tp2, format.mintick), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(tpColor, 84), textcolor=tpColor, size=size.tiny)
    label lb3 = label.new(bar_index + tpLineBars, tp3, "TP3 " + str.tostring(tp3, format.mintick), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(tpColor, 86), textcolor=tpColor, size=size.tiny)
    label lbs = label.new(bar_index + tpLineBars, sl,  "SL "  + str.tostring(sl,  format.mintick), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(slColor, 82), textcolor=slColor, size=size.tiny)

    array.push(levelLines, lEntry)
    array.push(levelLines, ltp1)
    array.push(levelLines, ltp2)
    array.push(levelLines, ltp3)
    array.push(levelLines, lsl)

    array.push(levelLabels, lbE)
    array.push(levelLabels, lb1)
    array.push(levelLabels, lb2)
    array.push(levelLabels, lb3)
    array.push(levelLabels, lbs)

    [sl, tp3]

// ═══════════════════════════════════════════════════════════════════════════
// AUTO CLEAR AFTER EXIT
// ═══════════════════════════════════════════════════════════════════════════

if clearOnExit and tradeActive
    exitHit = false

    if activeDir == 1
        exitHit := low <= activeSL or high >= activeTP3

    if activeDir == -1
        exitHit := high >= activeSL or low <= activeTP3

    if exitHit
        f_clear_levels()
        tradeActive := false
        activeDir := 0
        activeSL := na
        activeTP3 := na

// ═══════════════════════════════════════════════════════════════════════════
// EXECUTION
// ═══════════════════════════════════════════════════════════════════════════

if longSignal
    if showOnlyLastEntry
        f_clear_entry()

    if clearOnNewEntry
        f_clear_levels()

    lastEntryLabel := label.new(
         bar_index,
         low,
         "L",
         xloc=xloc.bar_index,
         yloc=yloc.belowbar,
         style=label.style_label_up,
         color=longColor,
         textcolor=color.white,
         size=size.small,
         tooltip="Possible Bottom Long\nTicker: " + syminfo.ticker + "\nEntry: " + str.tostring(close, format.mintick) + "\nScore: " + str.tostring(longScore)
     )

    if showTP
        [slL, tp3L] = f_draw_levels(true, close, atrVal)
        activeSL := slL
        activeTP3 := tp3L
        activeDir := 1
        tradeActive := true

    alert("POSSIBLE BOTTOM LONG | " + syminfo.ticker + " | Entry: " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)

    lastLongBar := bar_index
    lastSignal := 1

if shortSignal
    if showOnlyLastEntry
        f_clear_entry()

    if clearOnNewEntry
        f_clear_levels()

    lastEntryLabel := label.new(
         bar_index,
         high,
         "S",
         xloc=xloc.bar_index,
         yloc=yloc.abovebar,
         style=label.style_label_down,
         color=shortColor,
         textcolor=color.white,
         size=size.small,
         tooltip="Possible Top Short\nTicker: " + syminfo.ticker + "\nEntry: " + str.tostring(close, format.mintick) + "\nScore: " + str.tostring(shortScore)
     )

    if showTP
        [slS, tp3S] = f_draw_levels(false, close, atrVal)
        activeSL := slS
        activeTP3 := tp3S
        activeDir := -1
        tradeActive := true

    alert("POSSIBLE TOP SHORT | " + syminfo.ticker + " | Entry: " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)

    lastShortBar := bar_index
    lastSignal := -1

// ═══════════════════════════════════════════════════════════════════════════
// PLOTS
// ═══════════════════════════════════════════════════════════════════════════

plot(showEMA ? ema200 : na, "EMA 200", color=emaColor, linewidth=2)

plot(showBB ? bbTop : na, "BB Upper", color=color.new(color.gray, 80))
plot(showBB ? basis : na, "BB Basis", color=color.new(color.gray, 88))
plot(showBB ? bbBot : na, "BB Lower", color=color.new(color.gray, 80))

alertcondition(longSignal, title="Possible Bottom Long", message="Possible Bottom Long")
alertcondition(shortSignal, title="Possible Top Short", message="Possible Top Short")
````
