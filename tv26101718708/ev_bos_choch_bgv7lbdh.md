# EV BOS + CHoCH 

- url: https://www.tradingview.com/script/Bgv7LBDh-EV-BOS-CHoCH/
- type: indicator
- pine_id: PUB;04bffd70d91340148d7f840990ad83dc
- version: 1.0

## Description

This indicator is designed to identify market structure shifts through Break of Structure (BOS) and Change of Character (CHoCH) using confirmed swing highs and lows. It provides a clear and objective way to read price structure by distinguishing between continuation moves and genuine directional changes.

BOS events represent structural continuation, occurring when price breaks a previous swing level in the direction of the prevailing bias. CHoCH events highlight potential trend reversals, triggering when price breaks a key level against the current structural bias. This distinction allows traders to better contextualize momentum, trend strength, and possible regime changes.

All calculations are based on confirmed pivots, ensuring the indicator is fully non-repainting and reliable in live market conditions. Break confirmation can be evaluated using candle closes or wicks, depending on user preference, and optional level lines can be drawn to visualize the exact structure point that was broken.
Apr 8
Release Notes
EV BOS + CHoCH PRO automatically maps market structure in real time, identifying Break of Structure (BOS) and Change of Character (CHoCH) events at both external and internal levels — the foundation of Smart Money and ICT-based analysis.

What makes it different:

HH / HL / LH / LL labels — every swing high and low is automatically classified and labeled, so you can read market structure at a glance without manually marking pivots
External + Internal structure — two independent pivot lengths run simultaneously. External structure tracks the major swings; internal structure catches early signals inside the larger move, labeled as iBOS and iCH in dotted lines
Strong Break detection ⚡ — when price closes beyond the broken level by a configurable ATR multiple, the line is solid and tagged with ⚡, distinguishing conviction breaks from marginal ones
CHoCH identifies bias flips — while BOS confirms trend continuation, CHoCH signals a genuine reversal of the prevailing structure bias
BOS run counter — the dashboard tracks how many consecutive BOS events have occurred in the same direction, helping gauge trend strength and potential exhaustion
Bias dashboard — always shows external bias, internal bias, BOS run count, and the last structural event
Settings:

External and internal pivot lengths configured independently
Break confirmation: Close (stricter) or Wick (faster)
Strong break ATR multiplier
Toggle internal structure, swing labels, level lines, and dashboard independently
Full color control for BOS up/down, CHoCH up/down, and internal structure
Alerts (6 conditions):

BOS Up / BOS Down
CHoCH Up / CHoCH Down
Strong Break (either direction)
Any CHoCH (combined)

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © EV Quant Lab

//@version=6
indicator("EV BOS + CHoCH ", shorttitle="BOS", overlay=true, max_labels_count=500, max_lines_count=500)

// ─────────────────────────────────────────────
// GROUPS
// ─────────────────────────────────────────────
g1 = "Structure"
g2 = "Internal Structure"
g3 = "Visual"
g4 = "Dashboard"
g5 = "Alerts"

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
pivotLen    = input.int(5,     "Pivot Length (External)",  minval=1, maxval=20, group=g1)
breakMode   = input.string("Close", "Break Confirmation",  options=["Close","Wick"], group=g1)
showLevels  = input.bool(true, "Draw Broken Level Line",   group=g1)
showSwings  = input.bool(true, "Show HH/HL/LH/LL Labels", group=g1)
atrLen      = input.int(14,    "ATR Length",               minval=1, group=g1)
strongMult  = input.float(0.5, "Strong Break Min (ATR)",   minval=0.0, step=0.1, group=g1)

intPivLen   = input.int(2,     "Pivot Length (Internal)",  minval=1, maxval=10, group=g2)
showInt     = input.bool(true, "Show Internal Structure",  group=g2)

showLabels  = input.bool(true,  "Show BOS/CHoCH Labels",  group=g3)
lvlWidth    = input.int(2,      "Line Width",              minval=1, maxval=4, group=g3)
txtSize     = input.string("small", "Label Size",          options=["tiny","small","normal"], group=g3)
colBOSUp    = input.color(color.new(#00c853, 0), "BOS Up",    group=g3)
colBOSDown  = input.color(color.new(#f44336, 0), "BOS Down",  group=g3)
colCHUp     = input.color(color.new(#26c6da, 0), "CHoCH Up",  group=g3)
colCHDown   = input.color(color.new(#ff9800, 0), "CHoCH Down",group=g3)
colIntUp    = input.color(color.new(#00c853, 60),"Int Up",    group=g3)
colIntDown  = input.color(color.new(#f44336, 60),"Int Down",  group=g3)

showDash    = input.bool(true, "Show Bias Dashboard", group=g4)

alertBOS    = input.bool(true, "Alert: BOS",         group=g5)
alertCHoCH  = input.bool(true, "Alert: CHoCH",       group=g5)
alertStrong = input.bool(true, "Alert: Strong Break", group=g5)

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────
atr = ta.atr(atrLen)
f_size(s) => s == "tiny" ? size.tiny : s == "small" ? size.small : size.normal

f_draw(txt, col, lvl, t1, _isUp, strong) =>
    if showLevels and not na(t1)
        st = strong ? line.style_solid : line.style_dashed
        line.new(x1=t1, y1=lvl, x2=time, y2=lvl, xloc=xloc.bar_time,
            extend=extend.none, color=col, width=lvlWidth, style=st)
    if showLabels
        sTag = strong ? " ⚡" : ""
        label.new(x=time, y=lvl, xloc=xloc.bar_time,
            style=_isUp ? label.style_label_up : label.style_label_down,
            text=txt + sTag, textcolor=color.white, color=col, size=f_size(txtSize))

f_int_draw(txt, col, lvl, t1, isUp) =>
    if showLevels and not na(t1)
        line.new(x1=t1, y1=lvl, x2=time, y2=lvl, xloc=xloc.bar_time,
            extend=extend.none, color=col, width=1, style=line.style_dotted)
    label.new(x=time, y=lvl, xloc=xloc.bar_time,
        style=isUp ? label.style_label_up : label.style_label_down,
        text=txt, textcolor=color.white, color=col, size=size.tiny)

// ─────────────────────────────────────────────
// PIVOTS
// ─────────────────────────────────────────────
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low,   pivotLen, pivotLen)
pivotTime = time[pivotLen]

iPH = ta.pivothigh(high, intPivLen, intPivLen)
iPL = ta.pivotlow(low,   intPivLen, intPivLen)
iPT = time[intPivLen]

// ─────────────────────────────────────────────
// EXTERNAL STRUCTURE STATE
// ─────────────────────────────────────────────
var float lastHigh   = na
var int   lastHighT  = na
var bool  highBroken = false
var float lastLow    = na
var int   lastLowT   = na
var bool  lowBroken  = false
var int   bias       = 0
var int   bosCount   = 0
var string lastEvent = "—"

if not na(ph)
    if showSwings and not na(lastHigh)
        isHH = ph > lastHigh
        lbl  = isHH ? "HH" : "LH"
        col  = isHH ? color.new(#f44336, 10) : color.new(#ff9800, 10)
        yOff = ph + atr[pivotLen] * 0.4
        label.new(bar_index - pivotLen, yOff, lbl,
            style=label.style_label_down,
            textcolor=color.white, color=col, size=size.small)
    lastHigh   := ph
    lastHighT  := pivotTime
    highBroken := false

if not na(pl)
    if showSwings and not na(lastLow)
        isLL = pl < lastLow
        lbl  = isLL ? "LL" : "HL"
        col  = isLL ? color.new(#00c853, 10) : color.new(#26c6da, 10)
        yOff = pl - atr[pivotLen] * 0.4
        label.new(bar_index - pivotLen, yOff, lbl,
            style=label.style_label_up,
            textcolor=color.white, color=col, size=size.small)
    lastLow   := pl
    lastLowT  := pivotTime
    lowBroken := false

brkUp = breakMode == "Close" ? close : high
brkDn = breakMode == "Close" ? close : low

breakH = not na(lastHigh) and not highBroken and brkUp > lastHigh
breakL = not na(lastLow)  and not lowBroken  and brkDn < lastLow

isCHoCHUp   = breakH and bias == -1
isBOSUp     = breakH and bias != -1
isCHoCHDown = breakL and bias ==  1
isBOSDown   = breakL and bias !=  1

isStrongUp   = breakH and (close - lastHigh) >= atr * strongMult
isStrongDown = breakL and (lastLow  - close) >= atr * strongMult

if breakH
    highBroken := true
    bosCount   := bias == 1 ? bosCount + 1 : 1
    bias       := 1
    lastEvent  := isCHoCHUp ? "CHoCH ▲" : "BOS ▲"

if breakL
    lowBroken := true
    bosCount  := bias == -1 ? bosCount + 1 : 1
    bias      := -1
    lastEvent := isCHoCHDown ? "CHoCH ▼" : "BOS ▼"

if isBOSUp
    f_draw("BOS ▲", colBOSUp, lastHigh, lastHighT, true, isStrongUp)
if isCHoCHUp
    f_draw("CHoCH ▲", colCHUp, lastHigh, lastHighT, true, isStrongUp)
if isBOSDown
    f_draw("BOS ▼", colBOSDown, lastLow, lastLowT, false, isStrongDown)
if isCHoCHDown
    f_draw("CHoCH ▼", colCHDown, lastLow, lastLowT, false, isStrongDown)

// ─────────────────────────────────────────────
// INTERNAL STRUCTURE STATE
// ─────────────────────────────────────────────
var float iLastHigh   = na
var int   iLastHighT  = na
var bool  iHighBroken = false
var float iLastLow    = na
var int   iLastLowT   = na
var bool  iLowBroken  = false
var int   iBias       = 0

if not na(iPH)
    iLastHigh   := iPH
    iLastHighT  := iPT
    iHighBroken := false
if not na(iPL)
    iLastLow   := iPL
    iLastLowT  := iPT
    iLowBroken := false

if showInt
    iBrkH = not na(iLastHigh) and not iHighBroken and brkUp > iLastHigh
    iBrkL = not na(iLastLow)  and not iLowBroken  and brkDn < iLastLow

    iCHUp    = iBrkH and iBias == -1
    iBOSUp   = iBrkH and iBias != -1
    iCHDown  = iBrkL and iBias ==  1
    iBOSDown = iBrkL and iBias !=  1

    if iBrkH
        iHighBroken := true
        iBias := 1
    if iBrkL
        iLowBroken := true
        iBias := -1

    if iBOSUp
        f_int_draw("iBOS ▲", colIntUp,   iLastHigh, iLastHighT, true)
    if iCHUp
        f_int_draw("iCH ▲",  colIntUp,   iLastHigh, iLastHighT, true)
    if iBOSDown
        f_int_draw("iBOS ▼", colIntDown, iLastLow,  iLastLowT,  false)
    if iCHDown
        f_int_draw("iCH ▼",  colIntDown, iLastLow,  iLastLowT,  false)

// ─────────────────────────────────────────────
// DASHBOARD
// ─────────────────────────────────────────────
var table dash = table.new(position.top_right, 2, 5,
    bgcolor=color.new(#1a1a2e, 5),
    border_color=color.new(color.white, 70), border_width=1,
    frame_color=color.new(color.white, 50), frame_width=1)

if barstate.islast and showDash
    hdr = color.new(#0d0d1f, 0)
    bg  = color.new(#1a1a2e, 0)

    table.cell(dash, 0, 0, "EV BOS PRO", text_color=color.white, text_size=size.small, bgcolor=hdr, text_halign=text.align_center)
    table.merge_cells(dash, 0, 0, 1, 0)

    biasStr = bias ==  1 ? "Bullish ▲" : bias == -1 ? "Bearish ▼" : "Neutral —"
    biasCl  = bias ==  1 ? color.new(#00c853, 0) : bias == -1 ? color.new(#f44336, 0) : color.gray
    table.cell(dash, 0, 1, "Bias",    text_color=color.gray,  text_size=size.tiny,  bgcolor=bg)
    table.cell(dash, 1, 1, biasStr,   text_color=biasCl,      text_size=size.small, bgcolor=bg, text_halign=text.align_center)

    table.cell(dash, 0, 2, "BOS Run", text_color=color.gray,  text_size=size.tiny,  bgcolor=bg)
    table.cell(dash, 1, 2, str.tostring(bosCount) + " consec.", text_color=color.white, text_size=size.small, bgcolor=bg, text_halign=text.align_center)

    table.cell(dash, 0, 3, "Last",    text_color=color.gray,  text_size=size.tiny,  bgcolor=bg)
    table.cell(dash, 1, 3, lastEvent, text_color=color.white, text_size=size.small, bgcolor=bg, text_halign=text.align_center)

    intStr = iBias ==  1 ? "Bullish ▲" : iBias == -1 ? "Bearish ▼" : "Neutral —"
    intCl  = iBias ==  1 ? color.new(#00c853, 60) : iBias == -1 ? color.new(#f44336, 60) : color.gray
    table.cell(dash, 0, 4, "Int Bias", text_color=color.gray, text_size=size.tiny,  bgcolor=bg)
    table.cell(dash, 1, 4, intStr,     text_color=intCl,      text_size=size.small, bgcolor=bg, text_halign=text.align_center)

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────
alertcondition(alertBOS   and isBOSUp,                       title="BOS Up",       message="BOS Up on {{ticker}} {{interval}}")
alertcondition(alertBOS   and isBOSDown,                     title="BOS Down",     message="BOS Down on {{ticker}} {{interval}}")
alertcondition(alertCHoCH and isCHoCHUp,                     title="CHoCH Up",     message="CHoCH Up — bias flipped bullish on {{ticker}} {{interval}}")
alertcondition(alertCHoCH and isCHoCHDown,                   title="CHoCH Down",   message="CHoCH Down — bias flipped bearish on {{ticker}} {{interval}}")
alertcondition(alertStrong and (isStrongUp or isStrongDown),  title="Strong Break", message="Strong structure break on {{ticker}} {{interval}}")
alertcondition(alertCHoCH and (isCHoCHUp or isCHoCHDown),    title="Any CHoCH",    message="CHoCH detected on {{ticker}} {{interval}}")
````
