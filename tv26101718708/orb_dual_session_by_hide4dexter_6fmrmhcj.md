# ORB Dual Session by hide4dexter

- url: https://www.tradingview.com/script/6FmRmHcj-ORB-Dual-Session-by-hide4dexter/
- type: indicator
- pine_id: PUB;cfe6026842214a0c8c153ecd66a40a3f
- version: 1.0

## Description

A dual-session Opening Range Breakout indicator for Forex, built around London and New York opens with directional bias filtering.

## Source Code

````pine
//@version=6
indicator("ORB Dual Session by hide4dexter", shorttitle = "ORB Dual Session by hide4dexter", overlay = true, max_labels_count = 500, max_lines_count = 500)

//---------------------------------------------------------------------------------------------------------------------
// Inputs
//---------------------------------------------------------------------------------------------------------------------
timezoneInput = input.string("UTC-5", "Timezone", options = ["UTC-12","UTC-11","UTC-10","UTC-9","UTC-8","UTC-7","UTC-6","UTC-5","UTC-4","UTC-3","UTC-2","UTC-1","UTC+0","UTC+1","UTC+2","UTC+3","UTC+4","UTC+5","UTC+6","UTC+7","UTC+8","UTC+9","UTC+10","UTC+11","UTC+12"])
sessionDays   = input.string("23456", "Days of Week", tooltip = "1=Sunday, 7=Saturday. 23456 = Mon–Fri")

londonSession = input.session("0300-0315", "London Session (HHMM-HHMM)", group = "London ORB")
londonEndTime = input.string("0500",       "Stop Plotting At (HHMM)",     group = "London ORB")
nySession     = input.session("0800-0815", "NY Session (HHMM-HHMM)",     group = "New York ORB")
nyEndTime     = input.string("1200",       "Stop Plotting At (HHMM)",     group = "New York ORB")

retestMode = input.bool(false, "Retest Mode", group = "Signal", tooltip = "Signal fires only after: break outside OR → pullback to OR level → close back outside.")

bullColor    = input.color(#089981, "Bullish Color",         group = "Style")
bearColor    = input.color(#f23645, "Bearish Color",         group = "Style")
londonColor  = input.color(#f5a623, "London Range Color",    group = "Style")
nyColor      = input.color(#5b9cf6, "NY Range Color",        group = "Style")
bgTransp     = input.int(90,        "Range BG Transparency", minval = 0, maxval = 100, group = "Style")
sigLabelSize = input.string("Small","Signal Label Size",      options = ["Tiny","Small","Normal","Large"], group = "Style")

//---------------------------------------------------------------------------------------------------------------------
// Pip Size
//---------------------------------------------------------------------------------------------------------------------
pipSize = syminfo.mintick < 0.01 ? syminfo.mintick * 10 : syminfo.mintick

//---------------------------------------------------------------------------------------------------------------------
// Variables
//---------------------------------------------------------------------------------------------------------------------
var float londonHigh     = na
var float londonLow      = na
var bool  londonEnded    = false
var bool  londonSigUp    = true
var bool  londonSigDn    = true
var int   londonDir      = 0
var int   londonRState   = 0
var bool  londonRTouched = false
var bool  londonRecorded = false

var float nyHigh         = na
var float nyLow          = na
var bool  nyEnded        = false
var bool  nySigUp        = true
var bool  nySigDn        = true
var int   nyRState       = 0
var bool  nyRTouched     = false
var bool  nyRecorded     = false

isNewDay = ta.change(time("D", "", timezoneInput)) != 0
szSignal = sigLabelSize == "Tiny" ? size.tiny : sigLabelSize == "Small" ? size.small : sigLabelSize == "Normal" ? size.normal : size.large
inLondon = not na(time(timeframe.period, londonSession + ":" + sessionDays, timezoneInput))
inNY     = not na(time(timeframe.period, nySession     + ":" + sessionDays, timezoneInput))

//---------------------------------------------------------------------------------------------------------------------
// Pre-calculate crossovers at top level
//---------------------------------------------------------------------------------------------------------------------
crossOverLondonHigh = ta.crossover(close,  londonHigh)
crossUnderLondonLow = ta.crossunder(close, londonLow)
crossOverNYHigh     = ta.crossover(close,  nyHigh)
crossUnderNYLow     = ta.crossunder(close, nyLow)

//---------------------------------------------------------------------------------------------------------------------
// Reset on New Day
//---------------------------------------------------------------------------------------------------------------------
if isNewDay
    londonHigh     := na
    londonLow      := na
    londonEnded    := false
    londonSigUp    := true
    londonSigDn    := true
    londonDir      := 0
    londonRState   := 0
    londonRTouched := false
    londonRecorded := false
    nyHigh         := na
    nyLow          := na
    nyEnded        := false
    nySigUp        := true
    nySigDn        := true
    nyRState       := 0
    nyRTouched     := false
    nyRecorded     := false

//---------------------------------------------------------------------------------------------------------------------
// London ORB Logic
//---------------------------------------------------------------------------------------------------------------------
if inLondon and not inLondon[1]
    londonHigh     := na
    londonLow      := na
    londonEnded    := false
    londonSigUp    := true
    londonSigDn    := true
    londonRState   := 0
    londonRTouched := false

if inLondon
    londonHigh := na(londonHigh) ? high : math.max(londonHigh, high)
    londonLow  := na(londonLow)  ? low  : math.min(londonLow,  low)

if not inLondon and inLondon[1]
    londonEnded := true

londonPlotSession = str.substring(londonSession, 0, 4) + "-" + londonEndTime
bool londonDisplay = not na(time(timeframe.period, londonPlotSession + ":" + sessionDays, timezoneInput))

plotLondonHigh = londonDisplay ? londonHigh : na
plotLondonLow  = londonDisplay ? londonLow  : na

bool londonBreakUp = false
bool londonBreakDn = false

if not inLondon and londonEnded
    if not retestMode
        londonBreakUp := crossOverLondonHigh
        londonBreakDn := crossUnderLondonLow
    else
        if londonRState == 0
            if close > londonHigh
                londonRState := 1
            else if close < londonLow
                londonRState := -1
        else if londonRState == 1
            if low <= londonHigh
                londonRTouched := true
            if londonRTouched and close > londonHigh
                londonBreakUp := true
                londonRState  := 2
        else if londonRState == -1
            if high >= londonLow
                londonRTouched := true
            if londonRTouched and close < londonLow
                londonBreakDn := true
                londonRState  := 2

if londonBreakUp and londonSigUp and londonDisplay
    label.new(bar_index, high, "BUY NOW", color = bullColor, style = label.style_label_down, textcolor = color.white, size = szSignal)
    londonSigUp := false
    if londonDir == 0
        londonDir := 1

if londonBreakDn and londonSigDn and londonDisplay
    label.new(bar_index, low, "SELL NOW", color = bearColor, style = label.style_label_up, textcolor = color.white, size = szSignal)
    londonSigDn := false
    if londonDir == 0
        londonDir := -1

//---------------------------------------------------------------------------------------------------------------------
// NY ORB Logic
//---------------------------------------------------------------------------------------------------------------------
if inNY and not inNY[1]
    nyHigh     := na
    nyLow      := na
    nyEnded    := false
    nySigUp    := true
    nySigDn    := true
    nyRState   := 0
    nyRTouched := false

if inNY
    nyHigh := na(nyHigh) ? high : math.max(nyHigh, high)
    nyLow  := na(nyLow)  ? low  : math.min(nyLow,  low)

if not inNY and inNY[1]
    nyEnded := true

nyPlotSession = str.substring(nySession, 0, 4) + "-" + nyEndTime
bool nyDisplay = not na(time(timeframe.period, nyPlotSession + ":" + sessionDays, timezoneInput))

plotNYHigh = nyDisplay ? nyHigh : na
plotNYLow  = nyDisplay ? nyLow  : na

bool nyBreakUp = false
bool nyBreakDn = false

if not inNY and nyEnded
    if not retestMode
        nyBreakUp := crossOverNYHigh
        nyBreakDn := crossUnderNYLow
    else
        if nyRState == 0
            if close > nyHigh
                nyRState := 1
            else if close < nyLow
                nyRState := -1
        else if nyRState == 1
            if low <= nyHigh
                nyRTouched := true
            if nyRTouched and close > nyHigh
                nyBreakUp := true
                nyRState  := 2
        else if nyRState == -1
            if high >= nyLow
                nyRTouched := true
            if nyRTouched and close < nyLow
                nyBreakDn := true
                nyRState  := 2

if nyBreakUp and nySigUp and nyDisplay and londonDir == 1
    label.new(bar_index, high, "BUY NOW", color = bullColor, style = label.style_label_down, textcolor = color.white, size = szSignal)
    nySigUp := false

if nyBreakDn and nySigDn and nyDisplay and londonDir == -1
    label.new(bar_index, low, "SELL NOW", color = bearColor, style = label.style_label_up, textcolor = color.white, size = szSignal)
    nySigDn := false

//---------------------------------------------------------------------------------------------------------------------
// Visuals — Ranges
//---------------------------------------------------------------------------------------------------------------------
bgcolor(inLondon ? color.new(londonColor, 90) : na, title = "London Session BG")
bgcolor(inNY     ? color.new(nyColor,     90) : na, title = "NY Session BG")

pLondonHigh = plot(plotLondonHigh, "London High", color.new(londonColor, 20), 2, plot.style_linebr)
pLondonLow  = plot(plotLondonLow,  "London Low",  color.new(londonColor, 20), 2, plot.style_linebr)
fill(pLondonHigh, pLondonLow, plotLondonHigh, plotLondonLow, color.new(londonColor, bgTransp), color.new(londonColor, bgTransp), "London Fill")

pNYHigh = plot(plotNYHigh, "NY High", color.new(nyColor, 20), 2, plot.style_linebr)
pNYLow  = plot(plotNYLow,  "NY Low",  color.new(nyColor, 20), 2, plot.style_linebr)
fill(pNYHigh, pNYLow, plotNYHigh, plotNYLow, color.new(nyColor, bgTransp), color.new(nyColor, bgTransp), "NY Fill")

//---------------------------------------------------------------------------------------------------------------------
// Alerts
//---------------------------------------------------------------------------------------------------------------------
alertcondition(londonBreakUp,                 "London BUY",  "London ORB: BUY NOW")
alertcondition(londonBreakDn,                 "London SELL", "London ORB: SELL NOW")
alertcondition(nyBreakUp and londonDir == 1,  "NY BUY",      "NY ORB: BUY NOW — aligns with London bias")
alertcondition(nyBreakDn and londonDir == -1, "NY SELL",     "NY ORB: SELL NOW — aligns with London bias")
````
