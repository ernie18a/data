# ICT Sessions & Killzones [JOAT]

- url: https://www.tradingview.com/script/PpEL69sS-ICT-Sessions-Killzones-JOAT/
- type: indicator
- pine_id: PUB;697db9bfb9174216998631891d30b716
- version: 1.0

## Description

[b]ICT Sessions and Killzones [JOAT][/b]
[i]Maps the trading day into sessions and killzones, then shows where each session's liquidity rests and when the next session raids it.[/i]

[image]https://www.tradingview.com/x/pxvn13So/[/image]

[b]What it is[/b]
Intraday price is organised by time: different sessions have different behaviour, and each one leaves liquidity that the next session hunts. This indicator frames when the market is active and where that liquidity sits, so the raids become obvious in advance. It is an original session-mapping tool built around the widely-taught concept of session killzones and inter-session liquidity.

[b]How it works[/b]
• [b]Session boxes[/b] — Asia, London, New York AM and New York PM are each boxed from their own high to their own low across their clock window. The box is that session's realised range, and its edges are the liquidity the following sessions tend to seek.

• [b]Liquidity lines[/b] — every completed session leaves its high and low as thin levels extended to the right. Resting buy-side liquidity sits at the highs, sell-side at the lows, each labelled.

• [b]Sweeps[/b] — when a later session trades through a prior session's high or low, that raid is tagged, marking where stops were likely taken.

• [b]Classic reference levels[/b] — the previous day's high and low and the midnight open are drawn as the anchor points this style of analysis leans on.

• [b]Bias read[/b] — a simple, transparent read from the midnight open and the most recent killzone sweep-and-reclaim prints an understated directional tag. This tool is about mapping context and timing; it deliberately shows direction rather than full trade management.

[b]The dashboard[/b]
An adjustable session-clock panel shows which session is currently active, the countdown context of the day, the most recent liquidity event, the current bias, and the reference levels in play, so the state of the day is readable at a glance.

[b]How to use it[/b]
• Set the session windows and timezone to your market.
• Watch for a session to sweep the prior session's high or low and then reclaim — that is the timing this map is built to highlight.
• Use it as a context and timing layer beneath your own entry method, or alongside a structure or entry tool.

[b]Settings[/b]
Session windows and timezone, which sessions and reference levels to display, sweep marking, bias options, plus full visual and dashboard controls.

[b]Originality and usefulness[/b]
The contribution is a single, coherent map of session ranges, inter-session liquidity, sweeps and classic reference levels, with a transparent bias read — assembled so a trader can see the day's liquidity structure and timing without cluttering the chart. Everything evaluates on confirmed bars and does not repaint.

[b]Notes and limitations[/b]
• Session times depend on the timezone and the instrument's trading hours; set them correctly for your market.
• The bias read is intentionally simple context, not a standalone trade signal.
• This tool maps liquidity and timing; it does not place stops or targets for you.
• Educational and analytical tool, not financial advice.

[i]— made with passion by officialjackofalltrades[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6

indicator("ICT Sessions & Killzones [JOAT]", "Sessions KZ [JOAT]", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ─────────────────────────────────────────────────────────────────────────
//  PALETTE  (clean black / white / grey)
// ─────────────────────────────────────────────────────────────────────────
WHITE  = #F5F7FA
LGREY  = #C7CDD6
MGREY  = #8A93A3
DGREY  = #4A505C
INK    = #14181F
PAPER  = #FFFFFF

// ─────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────
gGen   = "General"
tz      = input.string("America/New_York", "Session timezone", options = ["America/New_York", "America/Chicago", "Europe/London", "Europe/Berlin", "Asia/Tokyo", "Asia/Shanghai", "Australia/Sydney", "UTC"], group = gGen)
keepDays= input.int(3, "Days of history to keep", minval = 1, maxval = 10, group = gGen, tooltip = "Older session boxes and their liquidity lines are pruned beyond this many days.")
extBars = input.int(24, "Level extension (bars)", minval = 2, maxval = 200, group = gGen)

gAsia  = "Asia"
asiaOn  = input.bool(true, "Asia", inline = "as", group = gAsia)
asiaSes = input.session("2000-0000", "", inline = "as", group = gAsia)
asiaCol = input.color(color.new(#8A93A3, 90), "Shade", group = gAsia)

gLon   = "London"
lonOn   = input.bool(true, "London", inline = "lo", group = gLon)
lonSes  = input.session("0200-0500", "", inline = "lo", group = gLon)
lonCol  = input.color(color.new(#4A505C, 90), "Shade", group = gLon)

gNYa   = "New York AM"
nyaOn   = input.bool(true, "New York AM", inline = "na", group = gNYa)
nyaSes  = input.session("0700-1000", "", inline = "na", group = gNYa)
nyaCol  = input.color(color.new(#14181F, 90), "Shade", group = gNYa)

gNYp   = "New York PM"
nypOn   = input.bool(true, "New York PM", inline = "np", group = gNYp)
nypSes  = input.session("1330-1600", "", inline = "np", group = gNYp)
nypCol  = input.color(color.new(#8A93A3, 92), "Shade", group = gNYp)

gLvl   = "Classic Levels"
showPDH = input.bool(true, "Previous day high / low", group = gLvl)
showMid = input.bool(true, "Midnight (00:00) open", group = gLvl)

gVis   = "Visuals"
showBox = input.bool(true, "Session boxes", group = gVis)
showLiq = input.bool(true, "Session high / low lines", group = gVis)
showSwp = input.bool(true, "Sweep tags", group = gVis)
paintOn = input.bool(true, "Paint monochrome candles", group = gVis)
showSig = input.bool(true, "Bias BUY / SELL tags", group = gVis)
showHUD = input.bool(true, "Dashboard", group = gVis)
hudPos  = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gVis)

// ─────────────────────────────────────────────────────────────────────────
//  HELPERS  (declared before first use)
// ─────────────────────────────────────────────────────────────────────────
f_pos(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.middle_right

f_price(float p) =>
    str.tostring(p, format.mintick)

// prune paired arrays of boxes / lines / labels beyond the day cap.
// each array is pruned independently so toggles that fill only some of them
// (e.g. boxes on, lines off) never shift an empty array.
f_prune(array<box> bxs, array<line> his, array<line> los, array<label> lbs, array<label> lhs, array<label> lls, int cap) =>
    while array.size(bxs) > cap
        box.delete(array.shift(bxs))
    while array.size(his) > cap
        line.delete(array.shift(his))
    while array.size(los) > cap
        line.delete(array.shift(los))
    while array.size(lbs) > cap
        label.delete(array.shift(lbs))
    while array.size(lhs) > cap
        label.delete(array.shift(lhs))
    while array.size(lls) > cap
        label.delete(array.shift(lls))

newDay = timeframe.change("D")

// ─────────────────────────────────────────────────────────────────────────
//  SESSION STATE  (one generic tracker per session, updated inline)
// ─────────────────────────────────────────────────────────────────────────
// Asia
var bool  asIn = false
var float asHi = na
var float asLo = na
var int   asL  = na
var array<box>   asBx = array.new<box>()
var array<line>  asHl = array.new<line>()
var array<line>  asLl = array.new<line>()
var array<label> asLb = array.new<label>()
var array<label> asLh = array.new<label>()
var array<label> asLo2 = array.new<label>()
// London
var bool  loIn = false
var float loHi = na
var float loLo = na
var int   loL  = na
var array<box>   loBx = array.new<box>()
var array<line>  loHl = array.new<line>()
var array<line>  loLl = array.new<line>()
var array<label> loLb = array.new<label>()
var array<label> loLh = array.new<label>()
var array<label> loLo2 = array.new<label>()
// NY AM
var bool  naIn = false
var float naHi = na
var float naLo = na
var int   naL  = na
var array<box>   naBx = array.new<box>()
var array<line>  naHl = array.new<line>()
var array<line>  naLl = array.new<line>()
var array<label> naLb = array.new<label>()
var array<label> naLh = array.new<label>()
var array<label> naLo2 = array.new<label>()
// NY PM
var bool  npIn = false
var float npHi = na
var float npLo = na
var int   npL  = na
var array<box>   npBx = array.new<box>()
var array<line>  npHl = array.new<line>()
var array<line>  npLl = array.new<line>()
var array<label> npLb = array.new<label>()
var array<label> npLh = array.new<label>()
var array<label> npLo2 = array.new<label>()

// active flags (confirmed via time() being non-na inside the session window)
asActive = asiaOn and not na(time(timeframe.period, asiaSes, tz))
loActive = lonOn  and not na(time(timeframe.period, lonSes,  tz))
naActive = nyaOn  and not na(time(timeframe.period, nyaSes,  tz))
npActive = nypOn  and not na(time(timeframe.period, nypSes,  tz))

// ─────────────────────────────────────────────────────────────────────────
//  ASIA  — track while active, finalise on close of the window
// ─────────────────────────────────────────────────────────────────────────
if asActive and not asIn
    asIn := true
    asHi := high
    asLo := low
    asL  := bar_index
else if asActive and asIn
    asHi := math.max(asHi, high)
    asLo := math.min(asLo, low)
if asIn and not asActive
    asIn := false
    if showBox
        bx = box.new(asL, asHi, bar_index - 1, asLo, border_color = color.new(INK, 40), border_width = 1, bgcolor = asiaCol)
        array.push(asBx, bx)
        array.push(asLb, label.new(asL, asHi, "Asia  " + f_price(asHi - asLo), style = label.style_label_lower_right, color = color.new(PAPER, 100), textcolor = MGREY, size = size.tiny))
    if showLiq
        array.push(asHl, line.new(bar_index - 1, asHi, bar_index - 1 + extBars, asHi, color = color.new(INK, 30), width = 1))
        array.push(asLl, line.new(bar_index - 1, asLo, bar_index - 1 + extBars, asLo, color = color.new(INK, 30), width = 1))
        array.push(asLh,  label.new(bar_index - 1 + extBars, asHi, " Asia H " + f_price(asHi), style = label.style_label_left,  color = color.new(PAPER, 100), textcolor = MGREY, size = size.tiny))
        array.push(asLo2, label.new(bar_index - 1 + extBars, asLo, " Asia L " + f_price(asLo), style = label.style_label_left,  color = color.new(PAPER, 100), textcolor = MGREY, size = size.tiny))

// ─────────────────────────────────────────────────────────────────────────
//  LONDON
// ─────────────────────────────────────────────────────────────────────────
if loActive and not loIn
    loIn := true
    loHi := high
    loLo := low
    loL  := bar_index
else if loActive and loIn
    loHi := math.max(loHi, high)
    loLo := math.min(loLo, low)
if loIn and not loActive
    loIn := false
    if showBox
        bx = box.new(loL, loHi, bar_index - 1, loLo, border_color = color.new(INK, 40), border_width = 1, bgcolor = lonCol)
        array.push(loBx, bx)
        array.push(loLb, label.new(loL, loHi, "London  " + f_price(loHi - loLo), style = label.style_label_lower_right, color = color.new(PAPER, 100), textcolor = DGREY, size = size.tiny))
    if showLiq
        array.push(loHl, line.new(bar_index - 1, loHi, bar_index - 1 + extBars, loHi, color = color.new(INK, 25), width = 1))
        array.push(loLl, line.new(bar_index - 1, loLo, bar_index - 1 + extBars, loLo, color = color.new(INK, 25), width = 1))
        array.push(loLh,  label.new(bar_index - 1 + extBars, loHi, " London H " + f_price(loHi), style = label.style_label_left, color = color.new(PAPER, 100), textcolor = DGREY, size = size.tiny))
        array.push(loLo2, label.new(bar_index - 1 + extBars, loLo, " London L " + f_price(loLo), style = label.style_label_left, color = color.new(PAPER, 100), textcolor = DGREY, size = size.tiny))

// ─────────────────────────────────────────────────────────────────────────
//  NEW YORK AM
// ─────────────────────────────────────────────────────────────────────────
if naActive and not naIn
    naIn := true
    naHi := high
    naLo := low
    naL  := bar_index
else if naActive and naIn
    naHi := math.max(naHi, high)
    naLo := math.min(naLo, low)
if naIn and not naActive
    naIn := false
    if showBox
        bx = box.new(naL, naHi, bar_index - 1, naLo, border_color = color.new(INK, 20), border_width = 1, bgcolor = nyaCol)
        array.push(naBx, bx)
        array.push(naLb, label.new(naL, naHi, "NY AM  " + f_price(naHi - naLo), style = label.style_label_lower_right, color = color.new(PAPER, 100), textcolor = INK, size = size.tiny))
    if showLiq
        array.push(naHl, line.new(bar_index - 1, naHi, bar_index - 1 + extBars, naHi, color = color.new(INK, 15), width = 1))
        array.push(naLl, line.new(bar_index - 1, naLo, bar_index - 1 + extBars, naLo, color = color.new(INK, 15), width = 1))
        array.push(naLh,  label.new(bar_index - 1 + extBars, naHi, " NY AM H " + f_price(naHi), style = label.style_label_left, color = color.new(PAPER, 100), textcolor = INK, size = size.tiny))
        array.push(naLo2, label.new(bar_index - 1 + extBars, naLo, " NY AM L " + f_price(naLo), style = label.style_label_left, color = color.new(PAPER, 100), textcolor = INK, size = size.tiny))

// ─────────────────────────────────────────────────────────────────────────
//  NEW YORK PM
// ─────────────────────────────────────────────────────────────────────────
if npActive and not npIn
    npIn := true
    npHi := high
    npLo := low
    npL  := bar_index
else if npActive and npIn
    npHi := math.max(npHi, high)
    npLo := math.min(npLo, low)
if npIn and not npActive
    npIn := false
    if showBox
        bx = box.new(npL, npHi, bar_index - 1, npLo, border_color = color.new(INK, 40), border_width = 1, bgcolor = nypCol)
        array.push(npBx, bx)
        array.push(npLb, label.new(npL, npHi, "NY PM  " + f_price(npHi - npLo), style = label.style_label_lower_right, color = color.new(PAPER, 100), textcolor = MGREY, size = size.tiny))
    if showLiq
        array.push(npHl, line.new(bar_index - 1, npHi, bar_index - 1 + extBars, npHi, color = color.new(INK, 30), width = 1))
        array.push(npLl, line.new(bar_index - 1, npLo, bar_index - 1 + extBars, npLo, color = color.new(INK, 30), width = 1))
        array.push(npLh,  label.new(bar_index - 1 + extBars, npHi, " NY PM H " + f_price(npHi), style = label.style_label_left, color = color.new(PAPER, 100), textcolor = MGREY, size = size.tiny))
        array.push(npLo2, label.new(bar_index - 1 + extBars, npLo, " NY PM L " + f_price(npLo), style = label.style_label_left, color = color.new(PAPER, 100), textcolor = MGREY, size = size.tiny))

// prune every session set to keep only the last N days
cap = keepDays
f_prune(asBx, asHl, asLl, asLb, asLh, asLo2, cap)
f_prune(loBx, loHl, loLl, loLb, loLh, loLo2, cap)
f_prune(naBx, naHl, naLl, naLb, naLh, naLo2, cap)
f_prune(npBx, npHl, npLl, npLb, npLh, npLo2, cap)

// ─────────────────────────────────────────────────────────────────────────
//  PREVIOUS-DAY HIGH / LOW  +  MIDNIGHT OPEN  (classic ICT levels)
// ─────────────────────────────────────────────────────────────────────────
var float dHi = na
var float dLo = na
var float curHi = na
var float curLo = na
var float pdh = na
var float pdl = na
if newDay
    dHi := high
    dLo := low
    pdh := curHi
    pdl := curLo
    curHi := high
    curLo := low
else
    curHi := math.max(nz(curHi, high), high)
    curLo := math.min(nz(curLo, low), low)

var float midOpen = na
midSess = not na(time(timeframe.period, "0000-0001", tz))
if midSess and (na(midOpen[1]) or newDay)
    midOpen := open

var line pdhLn = na
var line pdlLn = na
var line midLn = na
var label pdhLb = na
var label pdlLb = na
var label midLb = na
if showPDH and barstate.islast and not na(pdh)
    if na(pdhLn)
        pdhLn := line.new(bar_index, pdh, bar_index + extBars, pdh, color = color.new(DGREY, 20), style = line.style_dashed, width = 1)
        pdhLb := label.new(bar_index + extBars, pdh, " PDH " + f_price(pdh), style = label.style_label_left, color = color.new(PAPER, 100), textcolor = DGREY, size = size.tiny)
        pdlLn := line.new(bar_index, pdl, bar_index + extBars, pdl, color = color.new(DGREY, 20), style = line.style_dashed, width = 1)
        pdlLb := label.new(bar_index + extBars, pdl, " PDL " + f_price(pdl), style = label.style_label_left, color = color.new(PAPER, 100), textcolor = DGREY, size = size.tiny)
    line.set_xy1(pdhLn, bar_index, pdh)
    line.set_xy2(pdhLn, bar_index + extBars, pdh)
    label.set_xy(pdhLb, bar_index + extBars, pdh)
    label.set_text(pdhLb, " PDH " + f_price(pdh))
    line.set_xy1(pdlLn, bar_index, pdl)
    line.set_xy2(pdlLn, bar_index + extBars, pdl)
    label.set_xy(pdlLb, bar_index + extBars, pdl)
    label.set_text(pdlLb, " PDL " + f_price(pdl))

if showMid and barstate.islast and not na(midOpen)
    if na(midLn)
        midLn := line.new(bar_index, midOpen, bar_index + extBars, midOpen, color = color.new(INK, 25), style = line.style_dotted, width = 1)
        midLb := label.new(bar_index + extBars, midOpen, " 00:00 " + f_price(midOpen), style = label.style_label_left, color = color.new(PAPER, 100), textcolor = INK, size = size.tiny)
    line.set_xy1(midLn, bar_index, midOpen)
    line.set_xy2(midLn, bar_index + extBars, midOpen)
    label.set_xy(midLb, bar_index + extBars, midOpen)
    label.set_text(midLb, " 00:00 " + f_price(midOpen))

// ─────────────────────────────────────────────────────────────────────────
//  SWEEP DETECTION  (a later session raids a prior session's level)
// ─────────────────────────────────────────────────────────────────────────
// reference the most recently finalised prior session high / low to raid
var float refHi = na
var float refLo = na
if not asIn and not na(asHi)
    refHi := asHi
    refLo := asLo
if not loIn and not na(loHi)
    refHi := loHi
    refLo := loLo
if not naIn and not na(naHi)
    refHi := naHi
    refLo := naLo

var bool refHiSwept = false
var bool refLoSwept = false
if newDay
    refHiSwept := false
    refLoSwept := false
// also re-arm when the reference rolls to a newer session's level, so each
// later session's distinct high/low can be raided and tagged (not just once/day)
if refHi != refHi[1]
    refHiSwept := false
if refLo != refLo[1]
    refLoSwept := false

sweepUp = showSwp and not na(refHi) and not refHiSwept and high > refHi and close < refHi
sweepDn = showSwp and not na(refLo) and not refLoSwept and low  < refLo and close > refLo
if sweepUp
    refHiSwept := true
if sweepDn
    refLoSwept := true

// ─────────────────────────────────────────────────────────────────────────
//  BIAS  +  RECLAIM SIGNAL  (midnight open + killzone sweep & reclaim)
// ─────────────────────────────────────────────────────────────────────────
// day bias: price relative to the midnight open, confirmed on close
biasUp = not na(midOpen) and close > midOpen
biasDn = not na(midOpen) and close < midOpen
bias   = biasUp ? 1 : biasDn ? -1 : 0

inKZ = naActive or loActive or npActive     // a killzone is live
// BUY: sell-side raided (sweepDn) then price reclaims above the swept low with up-bias
buySig  = showSig and sweepDn and biasUp and close > open
// SELL: buy-side raided (sweepUp) then price rejects below the swept high with down-bias
sellSig = showSig and sweepUp and biasDn and close < open

var int lastSigDir = 0
if buySig
    lastSigDir := 1
if sellSig
    lastSigDir := -1

// ─────────────────────────────────────────────────────────────────────────
//  SWEEP TAGS  +  SIGNAL PLOTS  (global scope, constant sizes)
// ─────────────────────────────────────────────────────────────────────────
plotshape(sweepUp, "Sweep high", style = shape.xcross, location = location.abovebar, color = MGREY, size = size.tiny)
plotshape(sweepDn, "Sweep low",  style = shape.xcross, location = location.belowbar, color = MGREY, size = size.tiny)
plotshape(buySig,  "BUY",  style = shape.labelup,   location = location.belowbar, color = WHITE, textcolor = INK,   text = "BUY",  size = size.tiny)
plotshape(sellSig, "SELL", style = shape.labeldown, location = location.abovebar, color = INK,   textcolor = WHITE, text = "SELL", size = size.tiny)

// ─────────────────────────────────────────────────────────────────────────
//  MONOCHROME CANDLE PAINT  (white up / grey down)
// ─────────────────────────────────────────────────────────────────────────
upBar = close >= open
barcolor(paintOn ? (upBar ? WHITE : MGREY) : na, title = "Monochrome candles")

// light bias wash on the active killzone
bgcolor(inKZ ? color.new(MGREY, 96) : na, title = "Killzone shade")

// ─────────────────────────────────────────────────────────────────────────
//  DASHBOARD  (understated white / grey, black text)
// ─────────────────────────────────────────────────────────────────────────
// current active session name + its live range
curSes = npActive ? "New York PM" : naActive ? "New York AM" : loActive ? "London" : asActive ? "Asia" : "—"
curLo2 = npActive ? npLo : naActive ? naLo : loActive ? loLo : asActive ? asLo : na
curHi2 = npActive ? npHi : naActive ? naHi : loActive ? loHi : asActive ? asHi : na
rngTxt = na(curHi2) or na(curLo2) ? "—" : f_price(curHi2 - curLo2)
biasTxt= bias == 1 ? "BULLISH" : bias == -1 ? "BEARISH" : "NEUTRAL"
biasClr= bias == 1 ? INK : bias == -1 ? MGREY : MGREY
sigTxt = lastSigDir == 1 ? "BUY" : lastSigDir == -1 ? "SELL" : "Waiting"

// per-session status glyph (● active / ○ idle) and realised range
asDot = asActive ? "●" : "○"
loDot = loActive ? "●" : "○"
naDot = naActive ? "●" : "○"
npDot = npActive ? "●" : "○"
asRng = na(asHi) or na(asLo) ? "—" : f_price(asHi - asLo)
loRng = na(loHi) or na(loLo) ? "—" : f_price(loHi - loLo)
naRng = na(naHi) or na(naLo) ? "—" : f_price(naHi - naLo)
npRng = na(npHi) or na(npLo) ? "—" : f_price(npHi - npLo)

// dashboard is fully adjustable — reposition (hudPos) and resize text (hudSize)
hudSize = input.string("Normal", "Dashboard text size", options = ["Tiny", "Small", "Normal", "Large"], group = "Dashboard")
hudTS = hudSize == "Tiny" ? size.tiny : hudSize == "Small" ? size.small : hudSize == "Large" ? size.large : size.normal

// ── SESSION CLOCK — a filled/empty dot per session, plus range + bias ──
f_clockRow(table t, int r, string dot, string name, string rng, bool live, color surf) =>
    dotClr = live ? INK : LGREY
    nmClr  = live ? INK : MGREY
    table.cell(t, 0, r, "  " + dot,   text_color = dotClr, text_halign = text.align_center, bgcolor = surf, text_size = hudTS)
    table.cell(t, 1, r, name,         text_color = nmClr,  text_halign = text.align_left,   bgcolor = surf, text_size = hudTS)
    table.cell(t, 2, r, rng + "  ",   text_color = nmClr,  text_halign = text.align_right,  bgcolor = surf, text_size = hudTS)

var table hud = na
if showHUD and barstate.islast
    if not na(hud)
        table.delete(hud)
    hud := table.new(f_pos(hudPos), 3, 8, bgcolor = color.new(PAPER, 4), frame_color = color.new(DGREY, 40), frame_width = 1, border_color = color.new(LGREY, 40), border_width = 1)
    HEAD = color.new(INK, 6)
    SURF = color.new(PAPER, 4)
    SUR2 = color.new(LGREY, 88)
    // full-width title bar (3 cols share the header colour)
    table.cell(hud, 0, 0, "  ◷", text_color = WHITE, text_halign = text.align_left, bgcolor = HEAD, text_size = hudTS)
    table.cell(hud, 1, 0, "SESSION CLOCK", text_color = WHITE, text_halign = text.align_left, bgcolor = HEAD, text_size = hudTS)
    table.cell(hud, 2, 0, curSes == "—" ? "idle  " : "live  ", text_color = LGREY, text_halign = text.align_right, bgcolor = HEAD, text_size = hudTS)
    // one row per session — filled dot = active now
    f_clockRow(hud, 1, asDot, "Asia",     asRng, asActive, SURF)
    f_clockRow(hud, 2, loDot, "London",   loRng, loActive, SUR2)
    f_clockRow(hud, 3, naDot, "NY AM",    naRng, naActive, SURF)
    f_clockRow(hud, 4, npDot, "NY PM",    npRng, npActive, SUR2)
    // current range + day bias + last signal
    table.cell(hud, 0, 5, "  ▸", text_color = MGREY, text_halign = text.align_center, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 5, "Current range", text_color = MGREY, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 2, 5, rngTxt + "  ", text_color = INK, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 6, "  ▸", text_color = MGREY, text_halign = text.align_center, bgcolor = SUR2, text_size = hudTS)
    table.cell(hud, 1, 6, "Day bias", text_color = MGREY, text_halign = text.align_left, bgcolor = SUR2, text_size = hudTS)
    table.cell(hud, 2, 6, biasTxt + "  ", text_color = biasClr, text_halign = text.align_right, bgcolor = SUR2, text_size = hudTS)
    table.cell(hud, 0, 7, "  ▸", text_color = LGREY, text_halign = text.align_center, bgcolor = HEAD, text_size = hudTS)
    table.cell(hud, 1, 7, "Signal", text_color = LGREY, text_halign = text.align_left, bgcolor = HEAD, text_size = hudTS)
    table.cell(hud, 2, 7, sigTxt + "  ", text_color = WHITE, text_halign = text.align_right, bgcolor = HEAD, text_size = hudTS)

// ─────────────────────────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────────────────────────
alertcondition(buySig,  "Buy",  "Sessions KZ: sell-side sweep reclaimed with bullish day bias")
alertcondition(sellSig, "Sell", "Sessions KZ: buy-side sweep rejected with bearish day bias")
alertcondition(sweepUp or sweepDn, "Sweep", "Sessions KZ: a prior session level was swept")
alertcondition(naActive and not naActive[1], "NY AM open", "Sessions KZ: New York AM killzone has opened")
alertcondition(loActive and not loActive[1], "London open", "Sessions KZ: London killzone has opened")
````
