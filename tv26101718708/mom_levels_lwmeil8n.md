# MoM LEVELS

- url: https://www.tradingview.com/script/lwMEIL8n-MoM-LEVELS/
- type: indicator
- pine_id: PUB;0efff50a980d4e3f9ba621246b7a8817
- version: 1.0

## Description

Session highs and lows, the previous day's range, and the daily directional flip — all on one chart, all labelled in a single aligned column where price isn't in the way.

[b]What it draws[/b]
Previous Day High (PDH)
Previous Day Low (PDL)
[i]the prior daily candle's range, refreshed at each new daily open.[/i]

Asia High / Low
London High / Low
New York High / Low

Each session's extremes are tracked live while the session is open, then frozen at session close and extended to the right as a reference for the rest of the day. Every level has its own on/off toggle and its own colour and line style, so you can build the exact set you trade without editing code.

[b]The daily flip line[/b]
This marks the level where the daily candle's direction changes — the line you watch for continuation or reversal.

Daily candle bullish → a red line sits at the body bottom (the daily open).
Daily candle bearish → a green line sits at the body top (the daily open).
It's drawn when direction flips and extends until the next flip, so the current flip level is always on screen. Direction is defined as close versus open; if you'd rather use close versus previous close, that's a one-line change.

Clean, aligned labels
Every level's text sits in one vertical column at a fixed distance to the right of the live candle, on a transparent background — no boxes, no pills, no lines running through the words. Nine levels, nine tags, one clean stack.

Padding control sets how many bars right of the live candle the column sits.
Text Align chooses whether text grows away from or toward the column.
Master toggle, colour and size for all text.
Every label's wording is editable in settings — rename anything to suit your own shorthand.
Settings overview

Previous Day — on/off, PDH and PDL text
Asia / London / NY — on/off, session window, high/low text
Daily Flip — on/off, style, width, both flip texts
Text Display — show/hide, colour, size, padding, alignment
Style — line width, line style, per-level colours

[b]Good to know[/b]
Session times are entered in exchange time, not local time — the defaults (1800-0000 Asia, 0700-1000 London, 1330-1600 NY) are common FX/crypto windows, so adjust them to match your broker and instrument.

The label column anchors to the live bar and shifts right one bar as new candles form; Pine has no way to pin text to the pane's right edge, so Padding is the control for how far out the column sits. Levels are frozen at session close, which means toggling a session off hides new lines but won't delete ones already drawn.

[b]Alerts[/b]
New Day — fires when a new daily session begins.
Daily Flip — fires when the daily candle changes direction.
Disclaimer
This indicator is provided for educational and informational purposes only. It is not financial advice and does not constitute a recommendation to buy or sell any instrument. Trading involves risk of loss. Do your own research and manage your own risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MarkLeRoy

//@version=6
indicator("MoM LEVELS", overlay=true, max_lines_count=500)

// ============================================================================
// INPUTS
// ============================================================================
grpPD = "Previous Day"
showPDH = input.bool(true,  "Previous Day High", group=grpPD)
showPDL = input.bool(true,  "Previous Day Low",  group=grpPD)
lblPDH  = input.string("PDH", "Text: Prev Day High", group=grpPD)
lblPDL  = input.string("PDL", "Text: Prev Day Low",  group=grpPD)

grpAsia = "Asia Session"
showAsia = input.bool(true, "Asia High / Low", group=grpAsia)
asiaSess = input.session("1800-0000", "Asia Session (exch time)", group=grpAsia)
lblAsiaH = input.string("Asia High", "Text: Asia High", group=grpAsia)
lblAsiaL = input.string("Asia Low",  "Text: Asia Low",  group=grpAsia)

grpLon = "London Session"
showLon = input.bool(true, "London High / Low", group=grpLon)
lonSess = input.session("0700-1000", "London Session (exch time)", group=grpLon)
lblLonH = input.string("London High", "Text: London High", group=grpLon)
lblLonL = input.string("London Low",  "Text: London Low",  group=grpLon)

grpNY = "New York Session"
showNY = input.bool(true, "New York High / Low", group=grpNY)
nySess = input.session("1330-1600", "New York Session (exch time)", group=grpNY)
lblNyH = input.string("NY High", "Text: NY High", group=grpNY)
lblNyL = input.string("NY Low",  "Text: NY Low",  group=grpNY)

grpFlip = "Daily Flip Line"
showFlip  = input.bool(true, "Show Daily Flip Line", group=grpFlip)
flipStyle = input.string("Dashed", "Flip Line Style", options=["Solid", "Dashed", "Dotted"], group=grpFlip)
flipWidth = input.int(2, "Flip Line Width", minval=1, maxval=5, group=grpFlip)
lblBullFlip = input.string("Bull Flip", "Text: bullish daily", group=grpFlip)
lblBearFlip = input.string("Bear Flip", "Text: bearish daily", group=grpFlip)

grpText = "Text Display"
showText  = input.bool(true, "Show Level Text", group=grpText)
textColor = input.color(color.new(color.black, 0), "Text Colour", group=grpText)
textSize  = input.string("Small", "Text Size", options=["Tiny", "Small", "Normal", "Large"], group=grpText)
// Padding: how far RIGHT of the current (live) candle the text column sits.
padBars   = input.int(20, "Padding (bars right of live candle)", minval=0, maxval=300, group=grpText)
alignMode = input.string("Left", "Text Align", options=["Left", "Right"], group=grpText)

grpStyle = "Style"
lineWidth = input.int(1, "Level Line Width", minval=1, maxval=5, group=grpStyle)
lineStyle = input.string("Dashed", "Level Line Style", options=["Solid", "Dashed", "Dotted"], group=grpStyle)
colPDH   = input.color(color.new(color.blue, 0),  "Prev Day High", group=grpStyle)
colPDL   = input.color(color.new(color.blue, 0),  "Prev Day Low",  group=grpStyle)
colAsiaH = input.color(color.new(color.orange, 0), "Asia High", group=grpStyle)
colAsiaL = input.color(color.new(color.orange, 0), "Asia Low",  group=grpStyle)
colLonH  = input.color(color.new(color.purple, 0), "London High", group=grpStyle)
colLonL  = input.color(color.new(color.purple, 0), "London Low",  group=grpStyle)
colNYH   = input.color(color.new(color.red, 0),    "New York High", group=grpStyle)
colNYL   = input.color(color.new(color.red, 0),    "New York Low",  group=grpStyle)
colBullFlip = input.color(color.new(color.green, 0), "Flip line (bullish daily)", group=grpStyle)
colBearFlip = input.color(color.new(color.red, 0),   "Flip line (bearish daily)", group=grpStyle)

// ============================================================================
// HELPERS
// ============================================================================
styleOf(string s) =>
    s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted

sizeOf(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : size.large

lvlStyle = styleOf(lineStyle)
flStyle  = styleOf(flipStyle)
txtSize  = sizeOf(textSize)

// ---------------------------------------------------------------------------
// SHARED RIGHT EDGE
// All lines end here and all text sits here, so everything lines up in one
// vertical column at a fixed distance from the live candle.
// ---------------------------------------------------------------------------
rightEdge = bar_index + padBars

txtStyle = alignMode == "Left" ? label.style_label_left : label.style_label_right

drawText(label lb, float lvl, string txt) =>
    label.delete(lb)
    if showText and not na(lvl) and txt != ""
        label.new(rightEdge, lvl, txt,
                  style=txtStyle, color=color.new(color.black, 100),
                  textcolor=textColor, size=txtSize)
    else
        label(na)

// ============================================================================
// PREVIOUS DAY HIGH / LOW
// ============================================================================
pdh = request.security(syminfo.tickerid, "D", high[1],  barmerge.gaps_off, barmerge.lookahead_on)
pdl = request.security(syminfo.tickerid, "D", low[1],   barmerge.gaps_off, barmerge.lookahead_on)
isNewDay = ta.change(time("D")) != 0

var line  lnPDH = na
var line  lnPDL = na
var label txPDH = na
var label txPDL = na

if showPDH and isNewDay
    lnPDH := line.new(bar_index, pdh, rightEdge, pdh, color=colPDH, width=lineWidth, style=lvlStyle)
    lnPDL := line.new(bar_index, pdl, rightEdge, pdl, color=colPDL, width=lineWidth, style=lvlStyle)

if not na(lnPDH)
    line.set_x2(lnPDH, rightEdge)
    line.set_y1(lnPDH, pdh)
    line.set_y2(lnPDH, pdh)
if not na(lnPDL)
    line.set_x2(lnPDL, rightEdge)
    line.set_y1(lnPDL, pdl)
    line.set_y2(lnPDL, pdl)

txPDH := drawText(txPDH, pdh, lblPDH)
txPDL := drawText(txPDL, pdl, lblPDL)

// ============================================================================
// SESSION HIGH / LOW  (Asia, London, NY)
// ============================================================================
inSess(string sess) => not na(time(timeframe.period, sess))

asiaIn = inSess(asiaSess)
lonIn  = inSess(lonSess)
nyIn   = inSess(nySess)

var float asiaH = na, var float asiaL = na
var float lonH  = na, var float lonL  = na
var float nyH   = na, var float nyL   = na

if asiaIn
    asiaH := na(asiaH) ? high : math.max(asiaH, high)
    asiaL := na(asiaL) ? low  : math.min(asiaL, low)
if lonIn
    lonH := na(lonH) ? high : math.max(lonH, high)
    lonL := na(lonL) ? low  : math.min(lonL, low)
if nyIn
    nyH := na(nyH) ? high : math.max(nyH, high)
    nyL := na(nyL) ? low  : math.min(nyL, low)

asiaStart = asiaIn  and not asiaIn[1]
lonStart  = lonIn   and not lonIn[1]
nyStart   = nyIn    and not nyIn[1]
asiaEnd   = not asiaIn and asiaIn[1]
lonEnd    = not lonIn  and lonIn[1]
nyEnd     = not nyIn   and nyIn[1]

var line  lnAsiaH = na, var line  lnAsiaL = na
var line  lnLonH  = na, var line  lnLonL  = na
var line  lnNyH   = na, var line  lnNyL   = na
var label txAsiaH = na, var label txAsiaL = na
var label txLonH  = na, var label txLonL  = na
var label txNyH   = na, var label txNyL   = na

if asiaStart
    asiaH := high, asiaL := low
if lonStart
    lonH := high, lonL := low
if nyStart
    nyH := high, nyL := low

if asiaEnd and showAsia
    lnAsiaH := line.new(bar_index, asiaH, rightEdge, asiaH, color=colAsiaH, width=lineWidth, style=lvlStyle)
    lnAsiaL := line.new(bar_index, asiaL, rightEdge, asiaL, color=colAsiaL, width=lineWidth, style=lvlStyle)
if lonEnd and showLon
    lnLonH := line.new(bar_index, lonH, rightEdge, lonH, color=colLonH, width=lineWidth, style=lvlStyle)
    lnLonL := line.new(bar_index, lonL, rightEdge, lonL, color=colLonL, width=lineWidth, style=lvlStyle)
if nyEnd and showNY
    lnNyH := line.new(bar_index, nyH, rightEdge, nyH, color=colNYH, width=lineWidth, style=lvlStyle)
    lnNyL := line.new(bar_index, nyL, rightEdge, nyL, color=colNYL, width=lineWidth, style=lvlStyle)

txAsiaH := drawText(txAsiaH, asiaH, lblAsiaH)
txAsiaL := drawText(txAsiaL, asiaL, lblAsiaL)
txLonH  := drawText(txLonH,  lonH,  lblLonH)
txLonL  := drawText(txLonL,  lonL,  lblLonL)
txNyH   := drawText(txNyH,   nyH,   lblNyH)
txNyL   := drawText(txNyL,   nyL,   lblNyL)

extend(line ln, float lvl) =>
    if not na(ln)
        line.set_x2(ln, rightEdge)
        line.set_y1(ln, lvl)
        line.set_y2(ln, lvl)

extend(lnAsiaH, asiaH)
extend(lnAsiaL, asiaL)
extend(lnLonH,  lonH)
extend(lnLonL,  lonL)
extend(lnNyH,   nyH)
extend(lnNyL,   nyL)

// ============================================================================
// DAILY FLIP LINE
// bullish daily -> red line at body bottom (open)
// bearish daily -> green line at body top (open)
// ============================================================================
dOpen  = request.security(syminfo.tickerid, "D", open,  barmerge.gaps_off, barmerge.lookahead_on)
dClose = request.security(syminfo.tickerid, "D", close, barmerge.gaps_off, barmerge.lookahead_on)
dBull  = dClose > dOpen

dFlip = dBull != dBull[1]

var line  lnFlip = na
var label txFlip = na
var color flipCol = na

if showFlip and dFlip
    flipCol := dBull ? colBearFlip : colBullFlip
    lnFlip  := line.new(bar_index, dOpen, rightEdge, dOpen, color=flipCol, width=flipWidth, style=flStyle)
    txFlip  := drawText(txFlip, dOpen, dBull ? lblBearFlip : lblBullFlip)

if not na(lnFlip)
    line.set_x2(lnFlip, rightEdge)
    line.set_y1(lnFlip, dOpen)
    line.set_y2(lnFlip, dOpen)

// keep the flip text tracking its label text even after the flip bar
txFlip := drawText(txFlip, dOpen, dBull ? lblBearFlip : lblBullFlip)

// ============================================================================
// ALERTS
// ============================================================================
alertcondition(isNewDay, "New Day", "New daily session started")
alertcondition(dFlip, "Daily Flip", "Daily candle flipped direction")
````
