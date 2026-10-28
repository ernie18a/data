# All Session Levels (Futures) - Asia, London, Overnight, NY Prior

- url: https://www.tradingview.com/script/gY1l6XlY-All-Session-Levels-Futures-Asia-London-Overnight-NY-Prior/
- type: indicator
- pine_id: PUB;ff6fa07a4c0c4b2999b345f8d3468e3d
- version: 1.0

## Description

A session-levels built for trading during the New York session on the Micro Dow (MYM), though it works on any index future or intraday symbol. The core idea: the Asia and London sessions are thin and choppy on the Dow because the underlying US cash market is closed; rather than trading those sessions directly, this indicator plots the key levels they leave behind and helps you trade them when real volume arrives at the 9:30 ET open.

[b]What it plots[/b]
[list=1]
[*]Asia session high/low (default 8:00 PM–2:00 AM ET) — overnight liquidity pools.
[*]London session high/low (default 3:00 AM–8:00 AM ET) — the more recent, more relevant overnight range.
[*]Overnight high/low (ONH/ONL) — the full overnight range.
[*]Prior day NY high/low/close — the most-watched daily references, drawn per-day so they don't stretch across chart history.
[*]9:30 NY open marker and a shaded 9:30–10:30 killzone highlighting the highest-probability window.
[*]Auto-detected supply and demand zones — the script identifies base-then-impulse departures (a tight consolidation candle followed by a strong directional move) and draws the base as a zone. Zones remain on the chart only until mitigated: once price closes fully back through a zone, it's automatically removed, so you only ever see live, untested zones.
[*]Info dashboard (top-right) listing every current level and its price.
[/list]

[b]Alerts[/b]
Eight built-in alert conditions: level breaks (London, Asia, and overnight highs/lows) and zone taps (when price enters the most recent unmitigated demand or supply zone). Create them via the alarm-clock icon after adding the indicator; "Once Per Bar Close" is recommended for the break alerts.

[b]How to use it[/b]
Set your chart timezone to America/New York (or adjust the timezone input to match your data feed).
Run it on an intraday timeframe, 3m to 15m is the sweet spot; 5m is a good all-round default.
Before the open, review the plotted overnight and prior-day levels.

In the 9:30–10:30 window, watch for price interacting with those levels: a clean break-and-hold for continuation, or a failed break that snaps back inside the range for a reversal.
Use the confluence of a zone tap, price extended past VWAP, and volume for entry confirmation.

[b]Notes and settings[/b]
All session windows are fully adjustable in the settings, as are colors, and the supply/demand sensitivity (impulse strength, base size, lookback, and max zones per side).
The overnight window contains the Asia and London windows by design, so ONH/ONL will often overlap those extremes — toggle it off if you prefer less overlap.
The zone-tap alerts track only the most recent unmitigated zone on each side to avoid alert spam.

Disclaimer
This is an analysis and charting tool, not a trading system or financial advice. It does not generate buy/sell signals or guarantee any outcome. Levels and zones are calculated from historical price and session times; past behavior does not predict future results. Always do your own analysis and manage your own risk.

## Source Code

````pine
//@version=6
indicator("MYM NY-Open Levels", shorttitle="★All Session Levels★", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// =====================================================================
// MYM NY-OPEN SESSION PLAN  -  Auto-plots prep levels for the 9:30-10:30 ET window
// Asia H/L, London H/L, Overnight H/L, Prior Day H/L/C  (each line labelled)
// All session inputs are in EXCHANGE TIME. Default config assumes chart
// timezone America/New_York. Adjust session windows if your data feed differs.
// =====================================================================

// ---------- INPUTS: TOGGLES ----------
grpT = "Display Toggles"
showAsia    = input.bool(true,  "Show Asia Range",        group=grpT)
showLondon  = input.bool(true,  "Show London Range",      group=grpT)
showON      = input.bool(true,  "Show Overnight H/L",     group=grpT)
showPD      = input.bool(true,  "Show Prior Day H/L/C",   group=grpT)
showNYOpen  = input.bool(true,  "Show 9:30 NY Open line", group=grpT)
showKillzone= input.bool(true,  "Shade 9:30-10:30 window",group=grpT)
showZones   = input.bool(true,  "Show S/D Zones",         group=grpT)
extendLines = input.bool(true,  "Extend levels right",    group=grpT)

// ---------- INPUTS: SESSIONS (exchange time) ----------
grpS = "Session Windows (exchange time)"
asiaSess   = input.session("2000-0200", "Asia Session",      group=grpS)
londonSess = input.session("0300-0800", "London Session",    group=grpS)
onSess     = input.session("1800-0930", "Overnight Session", group=grpS)
nyKill     = input.session("0930-1030", "NY Killzone",       group=grpS)
tz         = input.string("America/New_York", "Session Timezone", group=grpS)

// ---------- INPUTS: STYLE ----------
grpC = "Colors"
asiaCol   = input.color(#8B4500,  "Asia",      group=grpC)  // dark orange/brown
londonCol = input.color(#004D4D,  "London",    group=grpC)  // dark teal
onCol     = input.color(#3A3A3A,  "Overnight", group=grpC)  // dark gray
pdCol     = input.color(#4B0082,  "Prior Day", group=grpC)  // dark indigo
killCol   = input.color(color.new(color.blue, 90),   "Killzone Shade", group=grpC)
lineW     = input.int(2, "Line width (bold)", minval=1, maxval=5, group=grpC)

// ---------- HELPERS ----------
inSession(sess) => not na(time(timeframe.period, sess, tz))
sessStart(sess) => inSession(sess) and not inSession(sess)[1]

xtend = extendLines ? extend.right : extend.none

// creates/repositions a text label for a level line.
// Anchored a few bars to the RIGHT of the last bar so text sits in clear space
// past the price action. _isHigh=true -> label above the line; false -> below.
labelOffset = input.int(3, "Label offset (bars right)", minval=0, maxval=30, group="Display Toggles")
makeLabel(_lbl, _y, _txt, _col, _isHigh) =>
    if not na(_lbl)
        label.delete(_lbl)
    _style = _isHigh ? label.style_label_down : label.style_label_up
    label.new(bar_index + labelOffset, _y, _txt, xloc=xloc.bar_index, style=_style, color=color.new(_col, 100), textcolor=_col, size=size.small)

// same as makeLabel but with an extra horizontal stagger so a label can be
// pushed further right to clear other labels sitting at a similar price.
makeLabelStaggered(_lbl, _y, _txt, _col, _isHigh, _extra) =>
    if not na(_lbl)
        label.delete(_lbl)
    _style = _isHigh ? label.style_label_down : label.style_label_up
    label.new(bar_index + labelOffset + _extra, _y, _txt, xloc=xloc.bar_index, style=_style, color=color.new(_col, 100), textcolor=_col, size=size.small)

// =====================================================================
// SESSION RANGE TRACKER  (generic)
// Returns running hi/lo for the active session, plus persistent lines
// =====================================================================

// ----- ASIA -----
var float asiaHi = na
var float asiaLo = na
var line  asiaHiLn = na
var line  asiaLoLn = na
var label asiaHiLb = na
var label asiaLoLb = na
asiaActive = inSession(asiaSess)
if asiaActive and not asiaActive[1]
    asiaHi := high
    asiaLo := low
    if not na(asiaHiLn)
        line.set_extend(asiaHiLn, extend.none)
        line.set_extend(asiaLoLn, extend.none)
    asiaHiLn := showAsia ? line.new(bar_index, high, bar_index, high, color=asiaCol, width=lineW, style=line.style_solid, extend=xtend) : na
    asiaLoLn := showAsia ? line.new(bar_index, low,  bar_index, low,  color=asiaCol, width=lineW, style=line.style_solid, extend=xtend) : na
else if asiaActive
    asiaHi := math.max(asiaHi, high)
    asiaLo := math.min(asiaLo, low)
    if showAsia and not na(asiaHiLn)
        line.set_xy2(asiaHiLn, bar_index, asiaHi)
        line.set_y1(asiaHiLn, asiaHi)
        line.set_xy2(asiaLoLn, bar_index, asiaLo)
        line.set_y1(asiaLoLn, asiaLo)
if showAsia and barstate.islast and not na(asiaHiLn)
    asiaHiLb := makeLabel(asiaHiLb, asiaHi, "Asia High", asiaCol, true)
    asiaLoLb := makeLabel(asiaLoLb, asiaLo, "Asia Low", asiaCol, false)

// ----- LONDON -----
var float lonHi = na
var float lonLo = na
var line  lonHiLn = na
var line  lonLoLn = na
var label lonHiLb = na
var label lonLoLb = na
lonActive = inSession(londonSess)
if lonActive and not lonActive[1]
    lonHi := high
    lonLo := low
    if not na(lonHiLn)
        line.set_extend(lonHiLn, extend.none)
        line.set_extend(lonLoLn, extend.none)
    lonHiLn := showLondon ? line.new(bar_index, high, bar_index, high, color=londonCol, width=lineW, style=line.style_solid, extend=xtend) : na
    lonLoLn := showLondon ? line.new(bar_index, low,  bar_index, low,  color=londonCol, width=lineW, style=line.style_solid, extend=xtend) : na
else if lonActive
    lonHi := math.max(lonHi, high)
    lonLo := math.min(lonLo, low)
    if showLondon and not na(lonHiLn)
        line.set_xy2(lonHiLn, bar_index, lonHi)
        line.set_y1(lonHiLn, lonHi)
        line.set_xy2(lonLoLn, bar_index, lonLo)
        line.set_y1(lonLoLn, lonLo)
if showLondon and barstate.islast and not na(lonHiLn)
    lonHiLb := makeLabel(lonHiLb, lonHi, "London High", londonCol, true)
    lonLoLb := makeLabel(lonLoLb, lonLo, "London Low", londonCol, false)

// ----- OVERNIGHT (ONH/ONL) -----
var float onHi = na
var float onLo = na
var line  onHiLn = na
var line  onLoLn = na
var label onHiLb = na
var label onLoLb = na
onActive = inSession(onSess)
if onActive and not onActive[1]
    onHi := high
    onLo := low
    if not na(onHiLn)
        line.set_extend(onHiLn, extend.none)
        line.set_extend(onLoLn, extend.none)
    onHiLn := showON ? line.new(bar_index, high, bar_index, high, color=onCol, width=lineW, style=line.style_solid, extend=xtend) : na
    onLoLn := showON ? line.new(bar_index, low,  bar_index, low,  color=onCol, width=lineW, style=line.style_solid, extend=xtend) : na
else if onActive
    onHi := math.max(onHi, high)
    onLo := math.min(onLo, low)
    if showON and not na(onHiLn)
        line.set_xy2(onHiLn, bar_index, onHi)
        line.set_y1(onHiLn, onHi)
        line.set_xy2(onLoLn, bar_index, onLo)
        line.set_y1(onLoLn, onLo)
// Overnight labels: BOTH placed ABOVE their line (per request) and staggered
// further right so they clear the Asia/London labels that sit at similar prices.
if showON and barstate.islast and not na(onHiLn)
    onHiLb := makeLabelStaggered(onHiLb, onHi, "ONH", onCol, true, 6)
    onLoLb := makeLabelStaggered(onLoLb, onLo, "ONL", onCol, true, 6)

// =====================================================================
// PRIOR DAY H/L/C  -  drawn per-day with line objects so they only span
// the current session (not stretched across all chart history)
// =====================================================================
pdH = request.security(syminfo.tickerid, "D", high[1],  lookahead=barmerge.lookahead_on)
pdL = request.security(syminfo.tickerid, "D", low[1],   lookahead=barmerge.lookahead_on)
pdC = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)

newDay = ta.change(time("D")) != 0

var line pdHLn = na
var line pdLLn = na
var line pdCLn = na
var label pdHLb = na
var label pdLLb = na
var label pdCLb = na

if showPD and newDay
    // close out yesterday's lines so they stop at the day boundary
    if not na(pdHLn)
        line.set_extend(pdHLn, extend.none)
        line.set_extend(pdLLn, extend.none)
        line.set_extend(pdCLn, extend.none)
    pdHLn := line.new(bar_index, pdH, bar_index, pdH, color=pdCol, width=lineW, style=line.style_solid, extend=xtend)
    pdLLn := line.new(bar_index, pdL, bar_index, pdL, color=pdCol, width=lineW, style=line.style_solid, extend=xtend)
    pdCLn := line.new(bar_index, pdC, bar_index, pdC, color=pdCol, width=lineW, style=line.style_solid, extend=xtend)
else if showPD and not na(pdHLn)
    line.set_xy2(pdHLn, bar_index, pdH)
    line.set_y1(pdHLn, pdH)
    line.set_xy2(pdLLn, bar_index, pdL)
    line.set_y1(pdLLn, pdL)
    line.set_xy2(pdCLn, bar_index, pdC)
    line.set_y1(pdCLn, pdC)
if showPD and barstate.islast and not na(pdHLn)
    pdHLb := makeLabel(pdHLb, pdH, "Prior Day High", pdCol, true)
    pdLLb := makeLabel(pdLLb, pdL, "Prior Day Low", pdCol, false)
    pdCLb := makeLabel(pdCLb, pdC, "Prior Day Close", pdCol, true)

// =====================================================================
// 9:30 NY OPEN VERTICAL + KILLZONE SHADE
// =====================================================================
killActive = inSession(nyKill)
bgcolor(showKillzone and killActive ? killCol : na, title="NY Killzone")

nyOpenBar = inSession(nyKill) and not inSession(nyKill)[1]
var label nyLb = na
if showNYOpen and nyOpenBar
    nyLb := label.new(bar_index, high, "9:30", style=label.style_label_down, color=color.new(color.gray, 30), textcolor=color.white, size=size.small)

// =====================================================================
// INFO DASHBOARD (top-right)
// =====================================================================
grpD = "Dashboard"
showDash = input.bool(true, "Show Dashboard", group=grpD)
var table dash = na
if showDash and barstate.islast
    dash := table.new(position.top_right, 2, 7, border_width=1)
    table.cell(dash, 0, 0, "MYM NY-OPEN",   bgcolor=color.new(color.blue,30), text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 0, "Level",         bgcolor=color.new(color.blue,30), text_color=color.white, text_size=size.small)
    table.cell(dash, 0, 1, "Asia High",     text_color=asiaCol,   text_size=size.small)
    table.cell(dash, 1, 1, str.tostring(asiaHi, format.mintick), text_color=asiaCol, text_size=size.small)
    table.cell(dash, 0, 2, "Asia Low",      text_color=asiaCol,   text_size=size.small)
    table.cell(dash, 1, 2, str.tostring(asiaLo, format.mintick), text_color=asiaCol, text_size=size.small)
    table.cell(dash, 0, 3, "London High",   text_color=londonCol, text_size=size.small)
    table.cell(dash, 1, 3, str.tostring(lonHi, format.mintick),  text_color=londonCol, text_size=size.small)
    table.cell(dash, 0, 4, "London Low",    text_color=londonCol, text_size=size.small)
    table.cell(dash, 1, 4, str.tostring(lonLo, format.mintick),  text_color=londonCol, text_size=size.small)
    table.cell(dash, 0, 5, "ONH",           text_color=onCol,     text_size=size.small)
    table.cell(dash, 1, 5, str.tostring(onHi, format.mintick),   text_color=onCol, text_size=size.small)
    table.cell(dash, 0, 6, "ONL",           text_color=onCol,     text_size=size.small)
    table.cell(dash, 1, 6, str.tostring(onLo, format.mintick),   text_color=onCol, text_size=size.small)

// =====================================================================
// SUPPLY / DEMAND ZONE AUTO-DETECTION
// Detects base-then-impulse departures (RBR/DBR = demand, DBD/RBD = supply).
// A zone = the consolidation "base" candle range immediately preceding a
// strong impulse move. Zones stay drawn until MITIGATED (price trades back
// fully through them), so only UNMITIGATED zones remain on the chart.
// =====================================================================
grpZ = "Supply/Demand Zones"
impulseMult  = input.float(1.8,  "Impulse strength (x avg range)", group=grpZ, tooltip="How much bigger than average the departure candle must be to qualify as an impulse leg.")
baseMaxMult  = input.float(0.8,  "Base max size (x avg range)",    group=grpZ, tooltip="Max body size of the base candle relative to average range. Smaller = tighter base = stronger zone.")
zoneLookback = input.int(20,     "Avg range lookback",             group=grpZ)
maxZones     = input.int(6,      "Max zones to keep each side",    group=grpZ, minval=1, maxval=20)
demandCol    = input.color(color.new(color.green, 80), "Demand Zone", group=grpZ)
supplyCol    = input.color(color.new(color.red, 80),   "Supply Zone", group=grpZ)

avgRange = ta.sma(high - low, zoneLookback)

// Impulse candle = current candle with range >> average and a decisive body
upImpulse   = (close > open) and (high - low) > avgRange * impulseMult and (close - open) > (high - low) * 0.5
downImpulse = (close < open) and (high - low) > avgRange * impulseMult and (open - close) > (high - low) * 0.5

// Base candle = the prior candle, small-bodied (consolidation before the move)
baseIsSmall = math.abs(close[1] - open[1]) < avgRange * baseMaxMult

// Demand: small base, then an up-impulse departs from it
newDemand = showZones and upImpulse and baseIsSmall
// Supply: small base, then a down-impulse departs from it
newSupply = showZones and downImpulse and baseIsSmall

var box[] demandBoxes = array.new<box>()
var box[] supplyBoxes = array.new<box>()

// --- create demand zone (base candle's range) ---
if newDemand
    zTop = math.max(open[1], close[1])
    zBot = low[1]
    b = box.new(bar_index[1], zTop, bar_index, zBot, border_color=color.new(color.green, 40), bgcolor=demandCol, extend=extend.right)
    array.push(demandBoxes, b)
    if array.size(demandBoxes) > maxZones
        box.delete(array.shift(demandBoxes))

// --- create supply zone (base candle's range) ---
if newSupply
    zBot = math.min(open[1], close[1])
    zTop = high[1]
    b = box.new(bar_index[1], zTop, bar_index, zBot, border_color=color.new(color.red, 40), bgcolor=supplyCol, extend=extend.right)
    array.push(supplyBoxes, b)
    if array.size(supplyBoxes) > maxZones
        box.delete(array.shift(supplyBoxes))

// --- mitigation check: remove demand zones price has closed below, supply zones price has closed above ---
if array.size(demandBoxes) > 0
    for i = array.size(demandBoxes) - 1 to 0
        bx = array.get(demandBoxes, i)
        if close < box.get_bottom(bx)
            box.delete(bx)
            array.remove(demandBoxes, i)
        else
            box.set_right(bx, bar_index + 10)

if array.size(supplyBoxes) > 0
    for i = array.size(supplyBoxes) - 1 to 0
        bx = array.get(supplyBoxes, i)
        if close > box.get_top(bx)
            box.delete(bx)
            array.remove(supplyBoxes, i)
        else
            box.set_right(bx, bar_index + 10)

// =====================================================================
// ALERTS  -  fire when price breaks a key overnight/session level
// =====================================================================
alertcondition(ta.crossover(close, lonHi),  "Break London High", "MYM: price broke London High")
alertcondition(ta.crossunder(close, lonLo), "Break London Low",  "MYM: price broke London Low")
alertcondition(ta.crossover(close, asiaHi), "Break Asia High",   "MYM: price broke Asia High")
alertcondition(ta.crossunder(close, asiaLo),"Break Asia Low",    "MYM: price broke Asia Low")
alertcondition(ta.crossover(close, onHi),   "Break ONH",         "MYM: price broke Overnight High")
alertcondition(ta.crossunder(close, onLo),  "Break ONL",         "MYM: price broke Overnight Low")

// zone interaction alerts (fires when price enters the nearest unmitigated zone)
demandTap = showZones and array.size(demandBoxes) > 0 and low <= box.get_top(array.get(demandBoxes, array.size(demandBoxes)-1)) and high >= box.get_bottom(array.get(demandBoxes, array.size(demandBoxes)-1))
supplyTap = showZones and array.size(supplyBoxes) > 0 and high >= box.get_bottom(array.get(supplyBoxes, array.size(supplyBoxes)-1)) and low <= box.get_top(array.get(supplyBoxes, array.size(supplyBoxes)-1))
alertcondition(demandTap, "Tap Demand Zone", "MYM: price tapping latest demand zone")
alertcondition(supplyTap, "Tap Supply Zone", "MYM: price tapping latest supply zone")
````
