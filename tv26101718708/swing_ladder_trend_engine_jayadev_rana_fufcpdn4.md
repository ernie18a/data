# Swing Ladder Trend Engine [Jayadev Rana]

- url: https://www.tradingview.com/script/FufCpdn4-Swing-Ladder-Trend-Engine-Jayadev-Rana/
- type: indicator
- pine_id: PUB;210205ba8cd447caa8169191f26b9cd2
- version: 1.0

## Description

OVERVIEW

Swing Ladder Trend Engine is a pure price-action trend-following tool. It builds its entire read of the market from confirmed swing highs and swing lows — no moving averages, no ATR, no oscillators. From that swing structure it derives three things: the current trend state, entry and exit signals, and a structure-anchored trailing stop (the "ladder") that only steps in the direction of the trade.

HOW IT WORKS

1. Swing structure. Confirmed pivot highs and lows (Swing Detection Length bars on each side) are classified as HH, HL, LH or LL and tagged on the chart.

2. Trend engine. When a bar closes beyond the most recent confirmed swing high, the trend state flips bullish; a close below the last confirmed swing low flips it bearish. Each swing level can only be broken once, so continuation breaks are tracked cleanly and bars are tinted by the active trend.

3. Ladder stop. Instead of a volatility trail, the stop is anchored to structure itself: in an uptrend it sits below the last confirmed swing low, offset by a configurable percentage of the current swing range, and it can only ratchet upward as new higher lows confirm. The result is a stepped "ladder" that gives the trade room where structure says it needs room, and tightens where structure tightens.

4. Pullback-quality entries. In the default Pullback mode a structure break only arms a setup. The entry itself requires the market to retrace into the breakout leg (between the Min and Max Retracement %), and then print a resumption candle: a close beyond the previous bar's extreme with a directional body of at least the Trigger Body Dominance fraction of its range. Retracements deeper than the maximum void the setup. A Breakout mode is included for traders who prefer to enter on the structure break itself.

SIGNALS: ENTRY, EXIT AND STOP

LONG / SHORT labels mark entries; the label tooltip stores the entry price and the ladder stop at that moment. A trade is closed either when price closes through the ladder stop or when the structure flips against it — the ✕ exit label's tooltip reports the reason and the approximate result in R (risk multiples, measured from entry to the initial ladder stop). All signals are evaluated on confirmed bars only.

DASHBOARD AND ALERTS

A compact dashboard shows the live trend state, the latest swing structure tags, the active signal, the current ladder stop level and the open trade's running R. Six alerts are available: long entry, short entry, exit long, exit short, and bullish/bearish trend flips.

SETTINGS

Swing Detection Length controls the size of the structure being tracked (larger = bigger swings, later confirmation). Entry Mode switches between Pullback and Breakout logic. Min/Max Retracement % and Trigger Body Dominance define what counts as a quality pullback entry. Stop Buffer sets how far beyond the protected swing the ladder sits, as a % of the current swing range. Dashboard position/size, structure labels, bar coloring and colors are all configurable.

LIMITATIONS

Swing points confirm only after the chosen number of right-side bars, so structure tags appear with a delay by design — this is what keeps the logic non-repainting on confirmed bars. Signals fire on bar close, not intrabar. Like any trend-following method, it gives back ground in choppy, range-bound conditions; the pullback filters reduce but do not remove that. R values shown in tooltips and the dashboard are approximations based on closing prices and do not account for gaps, fees or slippage. This is an analysis tool, not financial advice — always test settings on your own market and timeframe before relying on them.

WHY IT IS ORIGINAL

The combination of a swing-anchored ratcheting stop whose buffer adapts to the current swing range, plus an entry gate built from retracement depth and candle body dominance — all derived exclusively from raw price structure — is what this script contributes. It is not a mashup of built-in indicators; every state in the engine comes from the swing ladder itself.

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © Jayadev Rana

//@version=6
indicator("Swing Ladder Trend Engine [Jayadev Rana]",
     shorttitle       = "Swing Ladder [Jayadev Rana]",
     overlay          = true,
     max_labels_count = 500,
     max_lines_count  = 500)

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
string GRP_CORE  = "Core Engine"
string GRP_PULL  = "Pullback Quality"
string GRP_RISK  = "Risk · Ladder Stop"
string GRP_UI    = "Dashboard"
string GRP_STYLE = "Style"

int    swingLen  = input.int(5, "Swing Detection Length", minval = 2, maxval = 50, group = GRP_CORE,
     tooltip = "Bars required on each side to confirm a swing point. Swings confirm this many bars after they form — larger values track bigger structure but confirm later.")
string entryMode = input.string("Pullback", "Entry Mode", options = ["Pullback", "Breakout"], group = GRP_CORE,
     tooltip = "Breakout: signal fires on the confirmed structure break itself. Pullback: after a break, wait for a retracement into the leg and a momentum-resumption candle.")

float minRetrPct = input.float(30.0, "Min Retracement %", minval = 0.0, maxval = 90.0, step = 5.0, group = GRP_PULL,
     tooltip = "Pullback must retrace at least this % of the breakout leg before an entry can arm (Pullback mode only).")
float maxRetrPct = input.float(85.0, "Max Retracement %", minval = 10.0, maxval = 100.0, step = 5.0, group = GRP_PULL,
     tooltip = "A retracement deeper than this voids the setup — structure is likely failing.")
float bodyMin    = input.float(0.50, "Trigger Body Dominance", minval = 0.10, maxval = 1.00, step = 0.05, group = GRP_PULL,
     tooltip = "The trigger candle's directional body must be at least this fraction of its full high-low range.")

float bufPct    = input.float(15.0, "Stop Buffer (% of swing range)", minval = 0.0, maxval = 100.0, step = 5.0, group = GRP_RISK,
     tooltip = "The ladder stop sits this % of the current swing range beyond the protected swing point.")
bool  showTrail = input.bool(true, "Show Ladder Stop Trail", group = GRP_RISK)

bool   showDash = input.bool(true, "Show Dashboard", group = GRP_UI)
string dashPos  = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = GRP_UI)
string dashSize = input.string("Small", "Size", options = ["Tiny", "Small", "Normal"], group = GRP_UI)

bool  showStruct = input.bool(true, "Show HH / HL / LH / LL Labels", group = GRP_STYLE)
bool  paintBars  = input.bool(true, "Color Bars by Trend", group = GRP_STYLE)
color colUp      = input.color(#26a69a, "Bull", group = GRP_STYLE, inline = "cols")
color colDn      = input.color(#ef5350, "Bear", group = GRP_STYLE, inline = "cols")

//------------------------------------------------------------------------------
// Swing structure (confirmed pivots)
//------------------------------------------------------------------------------
float ph = ta.pivothigh(high, swingLen, swingLen)
float pl = ta.pivotlow(low, swingLen, swingLen)

var float swHigh     = na
var float swLow      = na
var float prevSwHigh = na
var float prevSwLow  = na
var string tagHigh   = "—"
var string tagLow    = "—"

bool newSwHigh = not na(ph)
bool newSwLow  = not na(pl)

if newSwHigh
    prevSwHigh := swHigh
    swHigh     := ph
    tagHigh    := not na(prevSwHigh) and ph > prevSwHigh ? "HH" : "LH"
if newSwLow
    prevSwLow := swLow
    swLow     := pl
    tagLow    := not na(prevSwLow) and pl > prevSwLow ? "HL" : "LL"

if showStruct and newSwHigh
    bool isHH = tagHigh == "HH"
    label.new(bar_index - swingLen, ph, tagHigh, style = label.style_label_down,
         color = color.new(isHH ? colUp : colDn, 80), textcolor = isHH ? colUp : colDn, size = size.tiny)
if showStruct and newSwLow
    bool isHL = tagLow == "HL"
    label.new(bar_index - swingLen, pl, tagLow, style = label.style_label_up,
         color = color.new(isHL ? colUp : colDn, 80), textcolor = isHL ? colUp : colDn, size = size.tiny)

//------------------------------------------------------------------------------
// Trend engine — confirmed structure breaks
//------------------------------------------------------------------------------
var int   trend      = 0
var float brokenHigh = na
var float brokenLow  = na

bool ready     = not na(swHigh) and not na(swLow)
bool confirmed = barstate.isconfirmed

bool breakUp = confirmed and ready and close > swHigh and (na(brokenHigh) or swHigh != brokenHigh)
bool breakDn = confirmed and ready and close < swLow and (na(brokenLow) or swLow != brokenLow)
if breakUp and breakDn
    breakUp := close >= open
    breakDn := not breakUp

bool flipUp = breakUp and trend != 1
bool flipDn = breakDn and trend != -1

if breakUp
    brokenHigh := swHigh
    trend      := 1
if breakDn
    brokenLow := swLow
    trend     := -1

//------------------------------------------------------------------------------
// Ladder stop — ratchets swing-to-swing, buffered by swing range
//------------------------------------------------------------------------------
float swingRange = ready ? math.abs(swHigh - swLow) : na
float buffer     = na(swingRange) ? 0.0 : swingRange * bufPct / 100.0

var float trail = na
if trend == 1
    float cand = na(swLow) ? na : swLow - buffer
    if flipUp or na(trail)
        trail := cand
    else if not na(cand)
        trail := math.max(trail, cand)
else if trend == -1
    float cand = na(swHigh) ? na : swHigh + buffer
    if flipDn or na(trail)
        trail := cand
    else if not na(cand)
        trail := math.min(trail, cand)

//------------------------------------------------------------------------------
// Signal engine — pullback quality state machine
//------------------------------------------------------------------------------
float barRange = math.max(high - low, syminfo.mintick)
float bodyDom  = math.abs(close - open) / barRange
bool  bullBody = close > open and bodyDom >= bodyMin
bool  bearBody = close < open and bodyDom >= bodyMin

var bool  armLong  = false
var bool  armShort = false
var bool  pullOkL  = false
var bool  pullOkS  = false
var float legHighL = na
var float legLowL  = na
var float legHighS = na
var float legLowS  = na

var bool  inLong   = false
var bool  inShort  = false
var float entryPx  = na
var float riskPx   = na

bool longSignal  = false
bool shortSignal = false
bool exitLong    = false
bool exitShort   = false
string exitReasonL = ""
string exitReasonS = ""

// -- exits first
if inLong and confirmed
    bool stopHitL = not na(trail) and trend == 1 and close < trail
    if flipDn or stopHitL
        exitLong    := true
        inLong      := false
        exitReasonL := flipDn ? "structure flip" : "ladder stop"
if inShort and confirmed
    bool stopHitS = not na(trail) and trend == -1 and close > trail
    if flipUp or stopHitS
        exitShort   := true
        inShort     := false
        exitReasonS := flipUp ? "structure flip" : "ladder stop"

// -- arm / fire on structure breaks
if breakUp
    armShort := false
    if entryMode == "Breakout"
        if not inLong
            longSignal := true
        armLong := false
    else
        armLong  := not inLong
        pullOkL  := false
        legLowL  := swLow
        legHighL := high
if breakDn
    armLong := false
    if entryMode == "Breakout"
        if not inShort
            shortSignal := true
        armShort := false
    else
        armShort := not inShort
        pullOkS  := false
        legHighS := swHigh
        legLowS  := low

// -- pullback tracking (long)
if armLong and trend == 1 and not breakUp
    legHighL := math.max(nz(legHighL, high), high)
    float legL = legHighL - legLowL
    if not na(legL) and legL > 0
        float retrL = (legHighL - low) / legL * 100.0
        if retrL >= minRetrPct and retrL <= maxRetrPct
            pullOkL := true
        if retrL > maxRetrPct
            armLong := false
    if armLong and pullOkL and confirmed and bullBody and close > high[1] and not inLong
        longSignal := true
        armLong    := false

// -- pullback tracking (short)
if armShort and trend == -1 and not breakDn
    legLowS := math.min(nz(legLowS, low), low)
    float legS = legHighS - legLowS
    if not na(legS) and legS > 0
        float retrS = (high - legLowS) / legS * 100.0
        if retrS >= minRetrPct and retrS <= maxRetrPct
            pullOkS := true
        if retrS > maxRetrPct
            armShort := false
    if armShort and pullOkS and confirmed and bearBody and close < low[1] and not inShort
        shortSignal := true
        armShort    := false

// -- book entries
if longSignal
    inLong  := true
    inShort := false
    entryPx := close
    riskPx  := not na(trail) and trail < close ? close - trail : na
if shortSignal
    inShort := true
    inLong  := false
    entryPx := close
    riskPx  := not na(trail) and trail > close ? trail - close : na

//------------------------------------------------------------------------------
// Visuals
//------------------------------------------------------------------------------
plot(showTrail and not (flipUp or flipDn) ? trail : na, "Ladder Stop", color = trend == 1 ? colUp : colDn, style = plot.style_linebr, linewidth = 2)
barcolor(paintBars ? (trend == 1 ? colUp : trend == -1 ? colDn : na) : na)

if longSignal
    string tipL = "Entry ≈ " + str.tostring(close, format.mintick) + (na(trail) ? "" : "\nLadder stop " + str.tostring(trail, format.mintick))
    label.new(bar_index, low, "LONG", style = label.style_label_up, color = colUp, textcolor = color.white, size = size.small, tooltip = tipL)
if shortSignal
    string tipS = "Entry ≈ " + str.tostring(close, format.mintick) + (na(trail) ? "" : "\nLadder stop " + str.tostring(trail, format.mintick))
    label.new(bar_index, high, "SHORT", style = label.style_label_down, color = colDn, textcolor = color.white, size = size.small, tooltip = tipS)
if exitLong
    float rMultL = not na(riskPx) and riskPx > 0 and not na(entryPx) ? (close - entryPx) / riskPx : na
    string tipXL = "Exit (" + exitReasonL + ")" + (na(rMultL) ? "" : "\nResult ≈ " + str.tostring(rMultL, "#.##") + " R")
    label.new(bar_index, high, "✕", style = label.style_label_down, color = color.new(colUp, 55), textcolor = color.white, size = size.tiny, tooltip = tipXL)
if exitShort
    float rMultS = not na(riskPx) and riskPx > 0 and not na(entryPx) ? (entryPx - close) / riskPx : na
    string tipXS = "Exit (" + exitReasonS + ")" + (na(rMultS) ? "" : "\nResult ≈ " + str.tostring(rMultS, "#.##") + " R")
    label.new(bar_index, low, "✕", style = label.style_label_up, color = color.new(colDn, 55), textcolor = color.white, size = size.tiny, tooltip = tipXS)

//------------------------------------------------------------------------------
// Dashboard
//------------------------------------------------------------------------------
var table dash = na
if showDash and barstate.islast
    string loc = dashPos == "Top Right" ? position.top_right : dashPos == "Top Left" ? position.top_left : dashPos == "Bottom Right" ? position.bottom_right : position.bottom_left
    string tsz = dashSize == "Tiny" ? size.tiny : dashSize == "Small" ? size.small : size.normal
    if na(dash)
        dash := table.new(loc, 2, 6, bgcolor = color.new(color.black, 35), border_width = 1, border_color = color.new(color.gray, 70))
    color trendCol = trend == 1 ? colUp : trend == -1 ? colDn : color.gray
    string posTxt = inLong ? "LONG" : inShort ? "SHORT" : "FLAT"
    float openR = inLong and not na(riskPx) and riskPx > 0 ? (close - entryPx) / riskPx : inShort and not na(riskPx) and riskPx > 0 ? (entryPx - close) / riskPx : na
    table.cell(dash, 0, 0, "SWING LADDER", text_color = color.white, text_size = tsz, bgcolor = color.new(color.black, 10))
    table.cell(dash, 1, 0, syminfo.ticker, text_color = color.silver, text_size = tsz, bgcolor = color.new(color.black, 10))
    table.cell(dash, 0, 1, "Trend", text_color = color.silver, text_size = tsz)
    table.cell(dash, 1, 1, trend == 1 ? "BULLISH" : trend == -1 ? "BEARISH" : "NEUTRAL", text_color = trendCol, text_size = tsz)
    table.cell(dash, 0, 2, "Structure", text_color = color.silver, text_size = tsz)
    table.cell(dash, 1, 2, tagHigh + " · " + tagLow, text_color = color.white, text_size = tsz)
    table.cell(dash, 0, 3, "Signal", text_color = color.silver, text_size = tsz)
    table.cell(dash, 1, 3, posTxt, text_color = inLong ? colUp : inShort ? colDn : color.gray, text_size = tsz)
    table.cell(dash, 0, 4, "Ladder Stop", text_color = color.silver, text_size = tsz)
    table.cell(dash, 1, 4, na(trail) ? "—" : str.tostring(trail, format.mintick), text_color = color.white, text_size = tsz)
    table.cell(dash, 0, 5, "Open R", text_color = color.silver, text_size = tsz)
    table.cell(dash, 1, 5, na(openR) ? "—" : str.tostring(openR, "#.##") + " R", text_color = not na(openR) and openR > 0 ? colUp : not na(openR) and openR < 0 ? colDn : color.gray, text_size = tsz)

//------------------------------------------------------------------------------
// Alerts
//------------------------------------------------------------------------------
alertcondition(longSignal, "Long Entry", "Swing Ladder: LONG entry on {{ticker}} ({{interval}})")
alertcondition(shortSignal, "Short Entry", "Swing Ladder: SHORT entry on {{ticker}} ({{interval}})")
alertcondition(exitLong, "Exit Long", "Swing Ladder: EXIT LONG on {{ticker}} ({{interval}})")
alertcondition(exitShort, "Exit Short", "Swing Ladder: EXIT SHORT on {{ticker}} ({{interval}})")
alertcondition(flipUp, "Trend Flip Bullish", "Swing Ladder: trend flipped BULLISH on {{ticker}} ({{interval}})")
alertcondition(flipDn, "Trend Flip Bearish", "Swing Ladder: trend flipped BEARISH on {{ticker}} ({{interval}})")
````
