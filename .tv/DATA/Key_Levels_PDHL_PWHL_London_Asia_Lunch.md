<!-- tradingview-pine-id: PUB;13de9e8ca7f04f8b8df7be43c2cf4549 -->
<!-- tradingview-pine-version: 3.0 -->
<!-- tradingviewscripts-format: 1 -->
# Key Levels - PDH/L, PWH/L, London, Asia, Lunch

Source: https://www.tradingview.com/script/L8QApcy1-Maverick-Trader-Key-Levels-PDH-L-PWH-L-London-Asia/

## Description

# Key Levels — PDH/L, PWH/L, London H/L, Asia H/L

## Overview

This indicator plots the four reference levels most intraday traders end up drawing by hand every morning: the previous day's high and low, the previous week's high and low, and the high and low of the London and Asia sessions. Every line is drawn automatically, updates as sessions develop, and carries a label at the right-hand edge of the chart.

The point of the tool is control over presentation. Each of the eight levels can be shown or hidden on its own, and each one has its own line color, its own label color, and its own label text. If you want a yellow Asia range with black text, previous-week levels twice as thick as everything else, and the previous-day low switched off entirely, all of that is a checkbox and a color picker away.

## Levels plotted

**Previous Day High / Low (PDH, PDL)** — taken from the last completed daily bar. The lines anchor to the open of the current day and project to the right.

**Previous Week High / Low (PWH, PWL)** — taken from the last completed weekly bar, anchored to the open of the current week.

**London Session High / Low** — the range of the London window, tracked live as the session unfolds. Once London closes, the levels freeze and stay on the chart until the next London session opens.

**Asia Session High / Low** — same behavior, over the Asia window.

Session levels require an intraday chart. On daily timeframes and above they are hidden automatically, since a session range cannot be resolved from a bar that contains the whole session.

## Session windows and timezone

London defaults to 02:00–05:00 and Asia to 20:00–00:00, both in New York time. Both windows are editable, and the timezone is a dropdown covering the common exchange and trading-desk zones. If you define your sessions differently, or you want to repurpose one of the two windows for a different session entirely, change the times and rename the labels to match.

## Labels

Labels sit past the right end of each line, clear of price action. Highs are placed above their line and lows below, so a tight range does not stack two labels on top of each other.

Four sizes are available: tiny, small, normal, and large.

Two label styles are available. Plain text is the default — just the text, no background, colored however you set it. Boxed labels put the text in a filled callout using the line color as the background and the label color as the font, which is the better choice when you want a strong contrast like black on yellow.

For plain text, the vertical clearance between the label and its line is set as a multiple of ATR(14) rather than a fixed number of points, so the spacing looks the same whether you are on an index future or a low-priced instrument.

## Settings

**General**
- Session timezone
- Label size — tiny / small / normal / large
- Boxed labels — on or off
- Extend lines right — how far past the last bar the lines project, in bars
- Label gap — spacing between the end of the line and its label, in bars
- Label offset — vertical clearance above highs and below lows, as a multiple of ATR(14)

**Session windows**
- London and Asia time windows

**Per section (Previous Day, Previous Week, London, Asia)**
- Show high — independent on/off
- Show low — independent on/off
- Line color for the high and for the low
- Label color for the high and for the low
- Line width, 1 through 5
- Line style — solid, dashed, or dotted
- Label text for the high and for the low

## Notes

Previous-day and previous-week values come from completed higher-timeframe bars only, so those lines do not repaint. Session high and low levels do move while their session is open — that is the intended behavior, since a session range is not final until the session closes. After the close, they hold until the next session begins.

This indicator marks reference levels. It generates no signals, no entries, and no exits, and makes no claim about what price will do at any of these levels. How you use them is up to your own method.

---

## Source Code

````pine
//@version=6
// Maverick Trader Key Levels — PDH/PDL, PWH/PWL, London H/L, Asia H/L, Lunch H/L
indicator("Key Levels - PDH/L, PWH/L, London, Asia, Lunch", "Key Levels", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ══════════════════════════ GENERAL ══════════════════════════
gGen     = "General"
tzIn     = input.string("America/New_York", "Session timezone", options = ["America/New_York", "America/Chicago", "America/Los_Angeles", "America/Santo_Domingo", "Europe/London", "Asia/Tokyo", "UTC"], group = gGen)
lblSizeI = input.string("Small", "Label size", options = ["Tiny", "Small", "Normal", "Large"], group = gGen)
boxed    = input.bool(false, "Boxed labels", tooltip = "Off = plain text. On = filled box using the line color as background, label color as the font.", group = gGen)
extBars  = input.int(10, "Extend lines right (bars)", minval = 0, maxval = 200, group = gGen)
gapBars  = input.int(3, "Label gap from line end (bars)", minval = 0, maxval = 50, group = gGen)
padMult  = input.float(0.10, "Label offset from line (x ATR14)", minval = 0.0, maxval = 2.0, step = 0.05, tooltip = "Plain-text labels only. Highs sit above the line, lows below.", group = gGen)

// ══════════════════════ SESSION WINDOWS ══════════════════════
gSess    = "Session windows"
lonSess  = input.session("0200-0500", "London", group = gSess)
asiaSess = input.session("2000-0000", "Asia", group = gSess)
lchSess  = input.session("1200-1330", "Lunch", tooltip = "End time is exclusive, so 1200-1330 covers 12:00 through 13:29.", group = gSess)

// ═══════════════════════ PREVIOUS DAY ════════════════════════
gPD    = "Previous Day"
pdHOn  = input.bool(true, "High", inline = "pdo", group = gPD)
pdLOn  = input.bool(true, "Low",  inline = "pdo", group = gPD)
pdHC   = input.color(#f23645, "Line   High", inline = "pdc", group = gPD)
pdLC   = input.color(#089981, "Low",         inline = "pdc", group = gPD)
pdHLC  = input.color(#f23645, "Label  High", inline = "pdl", group = gPD)
pdLLC  = input.color(#089981, "Low",         inline = "pdl", group = gPD)
pdW    = input.int(1, "Width", minval = 1, maxval = 5, inline = "pds", group = gPD)
pdS    = input.string("Solid", "Style", options = ["Solid", "Dashed", "Dotted"], inline = "pds", group = gPD)
pdHT   = input.string("PDH", "Text", inline = "pdt", group = gPD)
pdLT   = input.string("PDL", "", inline = "pdt", group = gPD)

// ══════════════════════ PREVIOUS WEEK ════════════════════════
gPW    = "Previous Week"
pwHOn  = input.bool(true, "High", inline = "pwo", group = gPW)
pwLOn  = input.bool(true, "Low",  inline = "pwo", group = gPW)
pwHC   = input.color(#ff9800, "Line   High", inline = "pwc", group = gPW)
pwLC   = input.color(#2962ff, "Low",         inline = "pwc", group = gPW)
pwHLC  = input.color(#ff9800, "Label  High", inline = "pwl", group = gPW)
pwLLC  = input.color(#2962ff, "Low",         inline = "pwl", group = gPW)
pwW    = input.int(2, "Width", minval = 1, maxval = 5, inline = "pws", group = gPW)
pwS    = input.string("Solid", "Style", options = ["Solid", "Dashed", "Dotted"], inline = "pws", group = gPW)
pwHT   = input.string("PWH", "Text", inline = "pwt", group = gPW)
pwLT   = input.string("PWL", "", inline = "pwt", group = gPW)

// ═════════════════════════ LONDON ════════════════════════════
gLN    = "London Session"
lnHOn  = input.bool(true, "High", inline = "lno", group = gLN)
lnLOn  = input.bool(true, "Low",  inline = "lno", group = gLN)
lnHC   = input.color(#9c27b0, "Line   High", inline = "lnc", group = gLN)
lnLC   = input.color(#9c27b0, "Low",         inline = "lnc", group = gLN)
lnHLC  = input.color(#9c27b0, "Label  High", inline = "lnl", group = gLN)
lnLLC  = input.color(#9c27b0, "Low",         inline = "lnl", group = gLN)
lnW    = input.int(1, "Width", minval = 1, maxval = 5, inline = "lns", group = gLN)
lnS    = input.string("Dashed", "Style", options = ["Solid", "Dashed", "Dotted"], inline = "lns", group = gLN)
lnHT   = input.string("LDN H", "Text", inline = "lnt", group = gLN)
lnLT   = input.string("LDN L", "", inline = "lnt", group = gLN)

// ══════════════════════════ ASIA ═════════════════════════════
gAS    = "Asia Session"
asHOn  = input.bool(true, "High", inline = "aso", group = gAS)
asLOn  = input.bool(true, "Low",  inline = "aso", group = gAS)
asHC   = input.color(#ffeb3b, "Line   High", inline = "asc", group = gAS)
asLC   = input.color(#ffeb3b, "Low",         inline = "asc", group = gAS)
asHLC  = input.color(#000000, "Label  High", inline = "asl", group = gAS)
asLLC  = input.color(#000000, "Low",         inline = "asl", group = gAS)
asW    = input.int(1, "Width", minval = 1, maxval = 5, inline = "ass", group = gAS)
asS    = input.string("Dotted", "Style", options = ["Solid", "Dashed", "Dotted"], inline = "ass", group = gAS)
asHT   = input.string("ASIA H", "Text", inline = "ast", group = gAS)
asLT   = input.string("ASIA L", "", inline = "ast", group = gAS)

// ═════════════════════════ LUNCH ═════════════════════════════
gLC    = "Lunch"
lcHOn  = input.bool(true, "High", inline = "lco", group = gLC)
lcLOn  = input.bool(true, "Low",  inline = "lco", group = gLC)
lcHC   = input.color(#26c6da, "Line   High", inline = "lcc", group = gLC)
lcLC   = input.color(#26c6da, "Low",         inline = "lcc", group = gLC)
lcHLC  = input.color(#26c6da, "Label  High", inline = "lcl", group = gLC)
lcLLC  = input.color(#26c6da, "Low",         inline = "lcl", group = gLC)
lcW    = input.int(1, "Width", minval = 1, maxval = 5, inline = "lcs", group = gLC)
lcS    = input.string("Dashed", "Style", options = ["Solid", "Dashed", "Dotted"], inline = "lcs", group = gLC)
lcHT   = input.string("LUNCH H", "Text", inline = "lct", group = gLC)
lcLT   = input.string("LUNCH L", "", inline = "lct", group = gLC)

// ═══════════════════════ HELPERS ═════════════════════════════
lsz = switch lblSizeI
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    =>          size.large

styOf(string s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

msBar  = timeframe.in_seconds(timeframe.period) * 1000
rightT = time + extBars * msBar
lblT   = rightT + gapBars * msBar
pad    = nz(ta.atr(14)) * padMult

// One persistent line + label per call site
f_level(bool show, float lvl, int t1, string txt, color col, color lblCol, int w, string sty, bool isHigh) =>
    var line  ln = na
    var label lb = na
    if show and not na(lvl) and not na(t1)
        if na(ln)
            ln := line.new(t1, lvl, rightT, lvl, xloc = xloc.bar_time)
            lb := label.new(lblT, lvl, txt, xloc = xloc.bar_time)
        line.set_xy1(ln, t1, lvl)
        line.set_xy2(ln, rightT, lvl)
        line.set_color(ln, col)
        line.set_width(ln, w)
        line.set_style(ln, styOf(sty))
        float ly = boxed ? lvl : (isHigh ? lvl + pad : lvl - pad)
        label.set_xy(lb, lblT, ly)
        label.set_text(lb, txt)
        label.set_size(lb, lsz)
        label.set_style(lb, boxed ? (isHigh ? label.style_label_down : label.style_label_up) : label.style_none)
        label.set_color(lb, boxed ? col : color.new(color.black, 100))
        label.set_textcolor(lb, lblCol)
        true
    else if not na(ln)
        line.delete(ln)
        label.delete(lb)
        ln := na
        lb := na
        true

// ═══════════════════ PREV DAY / PREV WEEK ════════════════════
[pdh, pdl] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[pwh, pwl] = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead = barmerge.lookahead_on)

var int dayT = na
if timeframe.change("D")
    dayT := time

var int wkT = na
if timeframe.change("W")
    wkT := time

// ═════════════════════ SESSION HIGH/LOW ══════════════════════
sessOK = timeframe.isintraday

inLon = sessOK and not na(time(timeframe.period, lonSess, tzIn))
var float lonH = na
var float lonL = na
var int   lonT = na
if inLon and not inLon[1]
    lonH := high
    lonL := low
    lonT := time
else if inLon
    lonH := math.max(lonH, high)
    lonL := math.min(lonL, low)

inAsia = sessOK and not na(time(timeframe.period, asiaSess, tzIn))
var float asiaH = na
var float asiaL = na
var int   asiaT = na
if inAsia and not inAsia[1]
    asiaH := high
    asiaL := low
    asiaT := time
else if inAsia
    asiaH := math.max(asiaH, high)
    asiaL := math.min(asiaL, low)

inLch = sessOK and not na(time(timeframe.period, lchSess, tzIn))
var float lchH = na
var float lchL = na
var int   lchT = na
if inLch and not inLch[1]
    lchH := high
    lchL := low
    lchT := time
else if inLch
    lchH := math.max(lchH, high)
    lchL := math.min(lchL, low)

// ═══════════════════════════ DRAW ════════════════════════════
f_level(pdHOn,            pdh,   dayT,  pdHT, pdHC, pdHLC, pdW, pdS, true)
f_level(pdLOn,            pdl,   dayT,  pdLT, pdLC, pdLLC, pdW, pdS, false)
f_level(pwHOn,            pwh,   wkT,   pwHT, pwHC, pwHLC, pwW, pwS, true)
f_level(pwLOn,            pwl,   wkT,   pwLT, pwLC, pwLLC, pwW, pwS, false)
f_level(lnHOn and sessOK, lonH,  lonT,  lnHT, lnHC, lnHLC, lnW, lnS, true)
f_level(lnLOn and sessOK, lonL,  lonT,  lnLT, lnLC, lnLLC, lnW, lnS, false)
f_level(asHOn and sessOK, asiaH, asiaT, asHT, asHC, asHLC, asW, asS, true)
f_level(asLOn and sessOK, asiaL, asiaT, asLT, asLC, asLLC, asW, asS, false)
f_level(lcHOn and sessOK, lchH,  lchT,  lcHT, lcHC, lcHLC, lcW, lcS, true)
f_level(lcLOn and sessOK, lchL,  lchT,  lcLT, lcLC, lcLLC, lcW, lcS, false)
````
