# Hammer + Engulfing Close Alert + Fractal Filter

- url: https://www.tradingview.com/script/WNNeztaA-Hammer-Engulfing-Close-Alert-Fractal-Filter/
- type: indicator
- pine_id: PUB;4b8d4b910df741f9b350e6e9c0eaeaba
- version: 3.0

## Description

Hammer + Engulfing Close Alert + Fractal Filter

This indicator looks for **hammer and engulfing patterns**, but filters them using **fractals** so you’re not getting signals everywhere.

Instead of reacting to every candle, it focuses on patterns that show up around **recent structure (pivot highs and lows)**.

How it works

* Signals only show after a **confirmed fractal**
* You can limit it to **just the first signal** after each fractal to cut down noise
* Everything is based on **closed candles** (no repainting)

Alerts

* **Setup alerts** → lets you know when a pattern forms after structure
* **Signal alerts** → only fires when the filtered signal actually prints

Features

* Clean, minimal **fractal dots**
* Simple labels:

  * HM (Long/Short)
  * ENG (Long/Short)
* Adjustable label size and offset
* Fully customizable settings

Best way to use it

Works best when you pair it with:

* Structure (BOS / CHoCH)
* Trend (EMA, VWAP, etc.)
* Key levels

Notes

* Fractals show with a slight delay (that’s normal)
* Signals print on candle close

Summary

Simple idea:
Use structure first, then let the patterns help with timing.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © davon.jennings1023

//@version=6
//@version=6
indicator("Hammer + Engulfing Close Alert + Fractal Filter", overlay=true, max_labels_count=500)

// ─── Direction Filter ────────────────────────────────────────────────────────
directionInput = input.string("Both", "Signal Direction", options=["Both", "Longs Only", "Shorts Only"], group="Direction Filter")

allowLongDir  = directionInput == "Both" or directionInput == "Longs Only"
allowShortDir = directionInput == "Both" or directionInput == "Shorts Only"

// ─── Session Filter ──────────────────────────────────────────────────────────
useSessionFilter = input.bool(false, "Enable Session Filter", group="Session Filter")
useUTC           = input.bool(false, "Use UTC Times (DST-safe)", group="Session Filter")

// Asia
asiaEnabled     = input.bool(true,       "Asia Session",           group="Session Filter")
asiaSessionET   = input.session("1800-0000", "  Asia Time (ET)",   group="Session Filter")
asiaSessionUTC  = input.session("2300-0500", "  Asia Time (UTC)",  group="Session Filter")

// London
londonEnabled    = input.bool(true,       "London Session",         group="Session Filter")
londonSessionET  = input.session("0200-0800", "  London Time (ET)", group="Session Filter")
londonSessionUTC = input.session("0700-1300", "  London Time (UTC)",group="Session Filter")

// NY
nyEnabled        = input.bool(true,       "NY Session",             group="Session Filter")
nySessionET      = input.session("0800-1700", "  NY Time (ET)",     group="Session Filter")
nySessionUTC     = input.session("1300-2200", "  NY Time (UTC)",    group="Session Filter")

// Resolve timezone and session strings based on mode
tz = useUTC ? "UTC" : "America/New_York"

asiaStr   = useUTC ? asiaSessionUTC   : asiaSessionET
londonStr = useUTC ? londonSessionUTC : londonSessionET
nyStr     = useUTC ? nySessionUTC     : nySessionET

inAsia   = not na(time(timeframe.period, asiaStr,   tz))
inLondon = not na(time(timeframe.period, londonStr, tz))
inNY     = not na(time(timeframe.period, nyStr,     tz))

inActiveSession = not useSessionFilter or
     (asiaEnabled   and inAsia)   or
     (londonEnabled and inLondon) or
     (nyEnabled     and inNY)

// ─── Inputs ──────────────────────────────────────────────────────────────────
showHammer         = input.bool(true, "Show Hammer Signals")
showInvertedHammer = input.bool(true, "Show Inverted Hammer Signals")
showEngulfing      = input.bool(true, "Show Engulfing Signals")

showLabels          = input.bool(true,  "Show All Labels")
showHammerLabels    = input.bool(true,  "Show Hammer Labels")
showEngulfingLabels = input.bool(true,  "Show Engulfing Labels")

labelSizeInput     = input.string("small",  "Label Size",     options=["tiny", "small", "normal", "large", "huge"])
labelPositionInput = input.string("offset", "Label Position", options=["bar", "above/below", "offset"])
labelOffsetTicks   = input.int(4, "Label Offset Ticks", minval=0)

bullColor      = input.color(color.rgb(0, 100, 0),   "Bullish Label Color")
bearColor      = input.color(color.rgb(139, 0, 0),   "Bearish Label Color")
labelTextColor = input.color(color.white,             "Label Text Color")

dojiBodyPercent      = input.float(10.0, "Ignore Doji if Body <= % of Range",   minval=0.1, maxval=50.0)
hammerBodyMaxPct     = input.float(35.0, "Hammer Max Body % of Range",          minval=1.0, maxval=80.0)
longWickMinMultiple  = input.float(2.0,  "Long Wick Minimum Multiple of Body",  minval=0.5, maxval=10.0)
smallWickMaxMultiple = input.float(1.0,  "Small Wick Maximum Multiple of Body", minval=0.0, maxval=5.0)

// ─── Fractals ────────────────────────────────────────────────────────────────
useFractalFilter = input.bool(true,    "Use Fractal Filter")
fractalLeftBars  = input.int(2,        "Fractal Left Bars",          minval=1)
fractalRightBars = input.int(2,        "Fractal Right Bars",         minval=1)
signalWindowBars = input.int(6,        "Bars Allowed After Fractal", minval=1)
firstSignalOnly  = input.bool(true,    "Only First Signal After Fractal")

showFractals     = input.bool(true,    "Show Fractals")
fractalSizeInput = input.string("tiny","Fractal Size", options=["tiny", "small", "normal"])
bullFractalColor = input.color(color.rgb(46,  125, 50), "Bull Fractal Dot Color")
bearFractalColor = input.color(color.rgb(106,  27, 27), "Bear Fractal Dot Color")

// ─── Alerts ──────────────────────────────────────────────────────────────────
enableSetupAlerts  = input.bool(true, "Enable Setup Alerts")
enableSignalAlerts = input.bool(true, "Enable Signal Alerts")

// ─── Label Size ──────────────────────────────────────────────────────────────
labelSize = switch labelSizeInput
    "tiny"   => size.tiny
    "small"  => size.small
    "normal" => size.normal
    "large"  => size.large
    => size.huge

tickOffset = labelOffsetTicks * syminfo.mintick

getBullY()    => labelPositionInput == "offset"      ? low  - tickOffset : low
getBearY()    => labelPositionInput == "offset"      ? high + tickOffset : high
getBullYloc() => labelPositionInput == "above/below" ? yloc.belowbar     : yloc.price
getBearYloc() => labelPositionInput == "above/below" ? yloc.abovebar     : yloc.price

// ─── Candle Measurements ─────────────────────────────────────────────────────
rng  = high - low
body = math.abs(close - open)
upper = high - math.max(open, close)
lower = math.min(open, close) - low

prevRng  = high[1] - low[1]
prevBody = math.abs(close[1] - open[1])

bullish     = close > open
bearish     = close < open
prevBullish = close[1] > open[1]
prevBearish = close[1] < open[1]

isDoji     = rng > 0 ? (body / rng) * 100 <= dojiBodyPercent : true
prevIsDoji = prevRng > 0 ? (prevBody / prevRng) * 100 <= dojiBodyPercent : true

// ─── Pattern Logic ───────────────────────────────────────────────────────────
smallHammerBody = rng > 0 ? (body / rng) * 100 <= hammerBodyMaxPct : false

hammer           = rng > 0 and not isDoji and smallHammerBody and lower >= body * longWickMinMultiple and upper <= body * smallWickMaxMultiple
invertedHammer   = rng > 0 and not isDoji and smallHammerBody and upper >= body * longWickMinMultiple and lower <= body * smallWickMaxMultiple

bullishEngulfing = not isDoji and not prevIsDoji and prevBearish and bullish and open <= close[1] and close >= open[1] and body > prevBody
bearishEngulfing = not isDoji and not prevIsDoji and prevBullish and bearish and open >= close[1] and close <= open[1] and body > prevBody

// ─── Fractal Logic ───────────────────────────────────────────────────────────
pivotHigh = ta.pivothigh(high, fractalLeftBars, fractalRightBars)
pivotLow  = ta.pivotlow(low,  fractalLeftBars, fractalRightBars)

var int  lastBullFractalBar = na
var int  lastBearFractalBar = na
var bool longTaken  = false
var bool shortTaken = false

if not na(pivotLow)
    lastBullFractalBar := bar_index - fractalRightBars
    longTaken := false

if not na(pivotHigh)
    lastBearFractalBar := bar_index - fractalRightBars
    shortTaken := false

bullFractalRecent = not na(lastBullFractalBar) and bar_index - lastBullFractalBar <= signalWindowBars
bearFractalRecent = not na(lastBearFractalBar) and bar_index - lastBearFractalBar <= signalWindowBars

allowLongBase  = not useFractalFilter or bullFractalRecent
allowShortBase = not useFractalFilter or bearFractalRecent

allowLong  = allowLongDir  and allowLongBase  and (not firstSignalOnly or not longTaken)
allowShort = allowShortDir and allowShortBase and (not firstSignalOnly or not shortTaken)

// ─── Setup Alerts (direction + session gated) ─────────────────────────────────
setupHammerLong  = inActiveSession and allowLongDir  and showHammer         and hammer           and allowLongBase  and barstate.isconfirmed
setupHammerShort = inActiveSession and allowShortDir and showInvertedHammer and invertedHammer   and allowShortBase and barstate.isconfirmed
setupEngulfLong  = inActiveSession and allowLongDir  and showEngulfing       and bullishEngulfing and allowLongBase  and barstate.isconfirmed
setupEngulfShort = inActiveSession and allowShortDir and showEngulfing       and bearishEngulfing and allowShortBase and barstate.isconfirmed

anyLongSetup  = setupHammerLong  or setupEngulfLong
anyShortSetup = setupHammerShort or setupEngulfShort

// ─── Final Signals (direction + session gated) ────────────────────────────────
hammerSignal    = inActiveSession and showHammer         and hammer           and allowLong  and barstate.isconfirmed
invHammerSignal = inActiveSession and showInvertedHammer and invertedHammer   and allowShort and barstate.isconfirmed
bullEngSignal   = inActiveSession and showEngulfing       and bullishEngulfing and allowLong  and barstate.isconfirmed
bearEngSignal   = inActiveSession and showEngulfing       and bearishEngulfing and allowShort and barstate.isconfirmed

longTriggered  = hammerSignal  or bullEngSignal
shortTriggered = invHammerSignal or bearEngSignal

if longTriggered
    longTaken := true

if shortTriggered
    shortTaken := true

// ─── Fractal Dots ────────────────────────────────────────────────────────────
bullFractal = showFractals and not na(pivotLow)
bearFractal = showFractals and not na(pivotHigh)

fractalTiny   = fractalSizeInput == "tiny"
fractalSmall  = fractalSizeInput == "small"
fractalNormal = fractalSizeInput == "normal"

plotchar(bullFractal and fractalTiny,   title="Bull Fractal Tiny",   char="·", location=location.belowbar, color=bullFractalColor, size=size.tiny,   offset=-fractalRightBars)
plotchar(bullFractal and fractalSmall,  title="Bull Fractal Small",  char="·", location=location.belowbar, color=bullFractalColor, size=size.small,  offset=-fractalRightBars)
plotchar(bullFractal and fractalNormal, title="Bull Fractal Normal", char="·", location=location.belowbar, color=bullFractalColor, size=size.normal, offset=-fractalRightBars)

plotchar(bearFractal and fractalTiny,   title="Bear Fractal Tiny",   char="·", location=location.abovebar, color=bearFractalColor, size=size.tiny,   offset=-fractalRightBars)
plotchar(bearFractal and fractalSmall,  title="Bear Fractal Small",  char="·", location=location.abovebar, color=bearFractalColor, size=size.small,  offset=-fractalRightBars)
plotchar(bearFractal and fractalNormal, title="Bear Fractal Normal", char="·", location=location.abovebar, color=bearFractalColor, size=size.normal, offset=-fractalRightBars)

// ─── Labels ──────────────────────────────────────────────────────────────────
if showLabels and showHammerLabels and hammerSignal
    label.new(bar_index, getBullY(), "HM (Long) " + str.tostring(close, format.mintick), yloc=getBullYloc(), style=label.style_label_up,   color=bullColor, textcolor=labelTextColor, size=labelSize)

if showLabels and showHammerLabels and invHammerSignal
    label.new(bar_index, getBearY(), "HM (Short) " + str.tostring(close, format.mintick), yloc=getBearYloc(), style=label.style_label_down, color=bearColor, textcolor=labelTextColor, size=labelSize)

if showLabels and showEngulfingLabels and bullEngSignal
    label.new(bar_index, getBullY(), "ENG (Long) " + str.tostring(close, format.mintick), yloc=getBullYloc(), style=label.style_label_up,   color=bullColor, textcolor=labelTextColor, size=labelSize)

if showLabels and showEngulfingLabels and bearEngSignal
    label.new(bar_index, getBearY(), "ENG (Short) " + str.tostring(close, format.mintick), yloc=getBearYloc(), style=label.style_label_down, color=bearColor, textcolor=labelTextColor, size=labelSize)

// ─── Alert Conditions ────────────────────────────────────────────────────────
alertcondition(enableSetupAlerts and setupHammerLong,  title="Setup: HM Long",  message="Setup HM Long on {{ticker}} {{interval}} at {{close}}")
alertcondition(enableSetupAlerts and setupHammerShort, title="Setup: HM Short", message="Setup HM Short on {{ticker}} {{interval}} at {{close}}")
alertcondition(enableSetupAlerts and setupEngulfLong,  title="Setup: ENG Long", message="Setup ENG Long on {{ticker}} {{interval}} at {{close}}")
alertcondition(enableSetupAlerts and setupEngulfShort, title="Setup: ENG Short", message="Setup ENG Short on {{ticker}} {{interval}} at {{close}}")

alertcondition(enableSetupAlerts and anyLongSetup,  title="Setup: Any Long Pattern",  message="Long setup pattern on {{ticker}} {{interval}} at {{close}}")
alertcondition(enableSetupAlerts and anyShortSetup, title="Setup: Any Short Pattern", message="Short setup pattern on {{ticker}} {{interval}} at {{close}}")

alertcondition(enableSignalAlerts and hammerSignal,    title="Signal: Hammer Long",     message="HM Long signal on {{ticker}} {{interval}} at {{close}}")
alertcondition(enableSignalAlerts and invHammerSignal, title="Signal: Hammer Short",    message="HM Short signal on {{ticker}} {{interval}} at {{close}}")
alertcondition(enableSignalAlerts and bullEngSignal,   title="Signal: Engulfing Long",  message="ENG Long signal on {{ticker}} {{interval}} at {{close}}")
alertcondition(enableSignalAlerts and bearEngSignal,   title="Signal: Engulfing Short", message="ENG Short signal on {{ticker}} {{interval}} at {{close}}")

alertcondition(enableSignalAlerts and longTriggered,  title="Signal: Any Long",  message="Any long signal on {{ticker}} {{interval}} at {{close}}")
alertcondition(enableSignalAlerts and shortTriggered, title="Signal: Any Short", message="Any short signal on {{ticker}} {{interval}} at {{close}}")
````
