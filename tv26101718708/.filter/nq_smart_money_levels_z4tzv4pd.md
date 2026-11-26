# NQ Smart Money Levels

- url: https://www.tradingview.com/script/Z4tzV4PD-NQ-Smart-Money-Levels/
- type: indicator
- pine_id: PUB;c64ab64c2b7d4c1686b936277e6213d5
- version: 1.0

## Description

NQ Smart Money Levels combines the key levels and concepts that intraday index-futures traders watch most, in one clean indicator.

Key levels:
- Previous day, week and month high/low (PDH/PDL, PWH/PWL, PMH/PML), calculated from completed periods only
- Daily, weekly and monthly open
- VWAP, EMA 50 and EMA 200

Sessions:
- Tokyo, London, NY AM and NY PM boxes showing each session's range
- Session times and timezone are adjustable
- NY Opening Range (5, 15 or 30 minutes) with OR High / OR Low lines

Market structure:
- BOS (break of structure) and CHoCH (change of character) based on confirmed swing points
- Each swing can be broken only once, so signals are not repeated

Fair Value Gaps:
- Bullish and bearish FVGs with a minimum size filter
- Gaps extend until fully filled and are then removed

Dashboard:
- Bias (VWAP + EMA 200 + EMA 50), structure direction, position vs VWAP and EMA 200, whether PDH/PDL were taken today, opening range values and the number of active FVGs

Alerts:
- Bullish / bearish bias, BOS, CHoCH and new FVGs

Notes:
- Designed for NQ / MNQ on intraday timeframes, but it works on any symbol. Adjust the minimum FVG size for other instruments.
- Swing points are confirmed after the selected swing length, so BOS/CHoCH appear with that delay by design.
- This is an analysis tool, not financial advice or a trading signal.

## Source Code

````pine
//@version=6
indicator("NQ Smart Money Levels", shorttitle = "NQ SMC", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 300)

// =====================================================
// INPUTS
// =====================================================
G_LVL  = "Key Levels"
G_MA   = "VWAP / EMA"
G_SES  = "Sessions"
G_OR   = "NY Opening Range"
G_STR  = "Market Structure"
G_FVG  = "Fair Value Gaps"
G_DASH = "Dashboard"

showPDH_PDL     = input.bool(true, "Previous Day High / Low",   group = G_LVL)
showPWH_PWL     = input.bool(true, "Previous Week High / Low",  group = G_LVL)
showPMH_PML     = input.bool(true, "Previous Month High / Low", group = G_LVL)
showDailyOpen   = input.bool(true, "Daily Open",   group = G_LVL)
showWeeklyOpen  = input.bool(true, "Weekly Open",  group = G_LVL)
showMonthlyOpen = input.bool(true, "Monthly Open", group = G_LVL)

showVWAP   = input.bool(true, "VWAP",    group = G_MA)
showEMA50  = input.bool(true, "EMA 50",  group = G_MA)
showEMA200 = input.bool(true, "EMA 200", group = G_MA)
showBiasBg = input.bool(true, "Bias background", group = G_MA)

sessionTZ  = input.string("America/New_York", "Session timezone", group = G_SES)
showTokyo  = input.bool(true, "Tokyo",  inline = "tk", group = G_SES)
tokyoSess  = input.session("2000-0000", "", inline = "tk", group = G_SES)
showLondon = input.bool(true, "London", inline = "ld", group = G_SES)
londonSess = input.session("0200-0500", "", inline = "ld", group = G_SES)
showNYAM   = input.bool(true, "NY AM",  inline = "am", group = G_SES)
nyAMSess   = input.session("0930-1100", "", inline = "am", group = G_SES)
showNYPM   = input.bool(true, "NY PM",  inline = "pm", group = G_SES)
nyPMSess   = input.session("1300-1600", "", inline = "pm", group = G_SES)

showOR    = input.bool(true, "Show opening range", group = G_OR)
orMinutes = input.int(15, "Opening range minutes", options = [5, 15, 30], group = G_OR)

showStructure         = input.bool(true, "Show BOS / CHoCH", group = G_STR)
structureLen          = input.int(5, "Swing length", minval = 2, group = G_STR)
showOnlyLastStructure = input.bool(true, "Show only the last BOS / CHoCH", group = G_STR)

showFVG    = input.bool(true, "Show FVGs", group = G_FVG)
maxFVGs    = input.int(5, "Max active FVGs per side", minval = 1, maxval = 20, group = G_FVG)
minFVGSize = input.float(5.0, "Minimum FVG size (points)", minval = 0.25, group = G_FVG)

showDashboard = input.bool(true, "Show dashboard", group = G_DASH)
dashPosIn     = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = G_DASH)
dashSizeIn    = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = G_DASH)

// =====================================================
// COLORS
// =====================================================
cPDH    = color.green
cPDL    = color.red
cPWH    = color.new(color.green, 25)
cPWL    = color.new(color.red, 25)
cPMH    = color.new(color.green, 55)
cPML    = color.new(color.red, 55)
cVWAP   = color.yellow
cEMA50  = color.aqua
cEMA200 = color.white
cNYPM   = #5b8def

// =====================================================
// KEY LEVELS (no repaint: previous-period values with lookahead_on)
// =====================================================
pdh = request.security(syminfo.tickerid, "D", high[1], lookahead = barmerge.lookahead_on)
pdl = request.security(syminfo.tickerid, "D", low[1],  lookahead = barmerge.lookahead_on)
pwh = request.security(syminfo.tickerid, "W", high[1], lookahead = barmerge.lookahead_on)
pwl = request.security(syminfo.tickerid, "W", low[1],  lookahead = barmerge.lookahead_on)
pmh = request.security(syminfo.tickerid, "M", high[1], lookahead = barmerge.lookahead_on)
pml = request.security(syminfo.tickerid, "M", low[1],  lookahead = barmerge.lookahead_on)

dailyOpen   = request.security(syminfo.tickerid, "D", open, lookahead = barmerge.lookahead_on)
weeklyOpen  = request.security(syminfo.tickerid, "W", open, lookahead = barmerge.lookahead_on)
monthlyOpen = request.security(syminfo.tickerid, "M", open, lookahead = barmerge.lookahead_on)

plot(showDailyOpen   ? dailyOpen   : na, "Daily Open",   color.gray,   1, plot.style_linebr)
plot(showWeeklyOpen  ? weeklyOpen  : na, "Weekly Open",  color.blue,   1, plot.style_linebr)
plot(showMonthlyOpen ? monthlyOpen : na, "Monthly Open", color.purple, 1, plot.style_linebr)

// Draws a level line + label that restarts every new day
f_line(bool _show, float _price, string _txt, color _col, int _width) =>
    var line  l  = na
    var label lb = na
    if timeframe.change("D")
        if not na(l)
            line.delete(l)
            l := na
        if not na(lb)
            label.delete(lb)
            lb := na
        if _show and not na(_price)
            l  := line.new(bar_index, _price, bar_index, _price, color = _col, width = _width)
            lb := label.new(bar_index, _price, _txt, style = label.style_label_left, color = _col, textcolor = color.white, size = size.small)
    if not na(l)
        line.set_x2(l, bar_index)
        label.set_x(lb, bar_index)
    _price

f_line(showPDH_PDL, pdh, "PDH", cPDH, 2)
f_line(showPDH_PDL, pdl, "PDL", cPDL, 2)
f_line(showPWH_PWL, pwh, "PWH", cPWH, 1)
f_line(showPWH_PWL, pwl, "PWL", cPWL, 1)
f_line(showPMH_PML, pmh, "PMH", cPMH, 1)
f_line(showPMH_PML, pml, "PML", cPML, 1)

// Today's running high / low (used to check if PDH / PDL were taken today)
var float dayHigh = na
var float dayLow  = na
if timeframe.change("D")
    dayHigh := high
    dayLow  := low
else
    dayHigh := math.max(nz(dayHigh, high), high)
    dayLow  := math.min(nz(dayLow, low), low)

// =====================================================
// VWAP / EMA
// =====================================================
vwapValue = ta.vwap(hlc3)
ema50     = ta.ema(close, 50)
ema200    = ta.ema(close, 200)

plot(showVWAP   ? vwapValue : na, "VWAP",    cVWAP,   2)
plot(showEMA50  ? ema50     : na, "EMA 50",  cEMA50,  1)
plot(showEMA200 ? ema200    : na, "EMA 200", cEMA200, 2)

// =====================================================
// BIAS ENGINE
// =====================================================
bullBias = close > vwapValue and close > ema200 and ema50 > ema200
bearBias = close < vwapValue and close < ema200 and ema50 < ema200

bgcolor(showBiasBg and bullBias ? color.new(color.green, 92) : na, title = "Bullish bias")
bgcolor(showBiasBg and bearBias ? color.new(color.red,   92) : na, title = "Bearish bias")

// =====================================================
// SESSION BOXES
// =====================================================
f_sessionBox(bool _show, string _session, string _name, color _col) =>
    inSess  = not na(time(timeframe.period, _session + ":1234567", sessionTZ))
    newSess = inSess and not inSess[1]

    var float hi = na
    var float lo = na
    var box   b  = na
    var label lb = na

    if newSess
        hi := high
        lo := low
        if _show
            b  := box.new(bar_index, hi, bar_index, lo, bgcolor = color.new(_col, 88), border_color = color.new(_col, 30))
            lb := label.new(bar_index, hi, _name, style = label.style_label_down, color = _col, textcolor = color.white, size = size.tiny)
    else if inSess and not na(hi)
        hi := math.max(hi, high)
        lo := math.min(lo, low)
        if not na(b)
            box.set_right(b, bar_index)
            box.set_top(b, hi)
            box.set_bottom(b, lo)
            label.set_x(lb, bar_index)
            label.set_y(lb, hi)
    inSess

f_sessionBox(showTokyo,  tokyoSess,  "Tokyo",  color.fuchsia)
f_sessionBox(showLondon, londonSess, "London", color.aqua)
f_sessionBox(showNYAM,   nyAMSess,   "NY AM",  color.orange)
f_sessionBox(showNYPM,   nyPMSess,   "NY PM",  cNYPM)

// =====================================================
// NY OPENING RANGE
// =====================================================
orSession = switch orMinutes
    5  => "0930-0935:1234567"
    15 => "0930-0945:1234567"
    => "0930-1000:1234567"

inOR  = not na(time(timeframe.period, orSession, sessionTZ))
newOR = inOR and not inOR[1]

var float orHigh      = na
var float orLow       = na
var line  orHighLine  = na
var line  orLowLine   = na
var label orHighLabel = na
var label orLowLabel  = na

if newOR
    orHigh := high
    orLow  := low
    line.delete(orHighLine)
    line.delete(orLowLine)
    label.delete(orHighLabel)
    label.delete(orLowLabel)
    orHighLine  := na
    orLowLine   := na
    orHighLabel := na
    orLowLabel  := na
    if showOR
        orHighLine  := line.new(bar_index, orHigh, bar_index, orHigh, color = color.orange, width = 2)
        orLowLine   := line.new(bar_index, orLow,  bar_index, orLow,  color = color.orange, width = 2)
        orHighLabel := label.new(bar_index, orHigh, "OR High", style = label.style_label_left, color = color.orange, textcolor = color.black, size = size.small)
        orLowLabel  := label.new(bar_index, orLow,  "OR Low",  style = label.style_label_left, color = color.orange, textcolor = color.black, size = size.small)
else if inOR
    orHigh := math.max(orHigh, high)
    orLow  := math.min(orLow, low)

if not na(orHighLine)
    line.set_x2(orHighLine, bar_index)
    line.set_y1(orHighLine, orHigh)
    line.set_y2(orHighLine, orHigh)
    label.set_x(orHighLabel, bar_index)
    label.set_y(orHighLabel, orHigh)

if not na(orLowLine)
    line.set_x2(orLowLine, bar_index)
    line.set_y1(orLowLine, orLow)
    line.set_y2(orLowLine, orLow)
    label.set_x(orLowLabel, bar_index)
    label.set_y(orLowLabel, orLow)

// =====================================================
// MARKET STRUCTURE: BOS / CHoCH
// Each swing can be broken only once (fixes repeated signals every bar)
// =====================================================
ph = ta.pivothigh(high, structureLen, structureLen)
pl = ta.pivotlow(low, structureLen, structureLen)

var float lastHigh       = na
var float lastLow        = na
var int   lastHighBar    = na
var int   lastLowBar     = na
var int   structureTrend = 0   // 1 bullish, -1 bearish, 0 undefined

if not na(ph)
    lastHigh    := ph
    lastHighBar := bar_index - structureLen
if not na(pl)
    lastLow    := pl
    lastLowBar := bar_index - structureLen

bullBreak = not na(lastHigh) and close > lastHigh
bearBreak = not na(lastLow)  and close < lastLow

bullCHoCH = bullBreak and structureTrend == -1
bullBOS   = bullBreak and structureTrend != -1
bearCHoCH = bearBreak and structureTrend == 1
bearBOS   = bearBreak and structureTrend != 1

var label lastStructureLabel = na
var line  lastStructureLine  = na

f_drawStructure(int fromBar, float price, string txt, color col) =>
    line  ln = line.new(fromBar, price, bar_index, price, color = col, width = 2)
    label lb = label.new(bar_index, price, txt, style = label.style_label_left, color = col, textcolor = color.white, size = size.small)
    [ln, lb]

if showStructure and (bullBreak or bearBreak)
    if showOnlyLastStructure
        line.delete(lastStructureLine)
        label.delete(lastStructureLabel)
    if bullBreak
        [ln, lb] = f_drawStructure(lastHighBar, lastHigh, bullCHoCH ? "CHoCH ↑" : "BOS ↑", color.green)
        lastStructureLine  := ln
        lastStructureLabel := lb
    if bearBreak
        [ln, lb] = f_drawStructure(lastLowBar, lastLow, bearCHoCH ? "CHoCH ↓" : "BOS ↓", color.red)
        lastStructureLine  := ln
        lastStructureLabel := lb

// Update state after drawing: a broken swing is consumed
if bullBreak
    structureTrend := 1
    lastHigh       := na
if bearBreak
    structureTrend := -1
    lastLow        := na

// =====================================================
// FAIR VALUE GAPS
// =====================================================
bullFVG = low > high[2] and (low - high[2]) >= minFVGSize
bearFVG = high < low[2] and (low[2] - high) >= minFVGSize

var array<box> bullFVGBoxes = array.new<box>()
var array<box> bearFVGBoxes = array.new<box>()

if showFVG and bullFVG
    bullFVGBoxes.push(box.new(bar_index - 2, low, bar_index, high[2], bgcolor = color.new(color.green, 85), border_color = color.new(color.green, 35)))

if showFVG and bearFVG
    bearFVGBoxes.push(box.new(bar_index - 2, low[2], bar_index, high, bgcolor = color.new(color.red, 85), border_color = color.new(color.red, 35)))

// Extend active FVGs, delete when fully filled
if bullFVGBoxes.size() > 0
    for i = bullFVGBoxes.size() - 1 to 0
        b = bullFVGBoxes.get(i)
        if low <= b.get_bottom()
            b.delete()
            bullFVGBoxes.remove(i)
        else
            b.set_right(bar_index)

if bearFVGBoxes.size() > 0
    for i = bearFVGBoxes.size() - 1 to 0
        b = bearFVGBoxes.get(i)
        if high >= b.get_top()
            b.delete()
            bearFVGBoxes.remove(i)
        else
            b.set_right(bar_index)

// Keep only the latest FVGs
while bullFVGBoxes.size() > maxFVGs
    bullFVGBoxes.shift().delete()
while bearFVGBoxes.size() > maxFVGs
    bearFVGBoxes.shift().delete()

// =====================================================
// DASHBOARD
// =====================================================
dashPos = switch dashPosIn
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_right

dSize = switch dashSizeIn
    "Tiny"   => size.tiny
    "Normal" => size.normal
    => size.small

var table dash = table.new(dashPos, 2, 10, bgcolor = color.new(#0b1220, 10), border_color = color.new(color.gray, 70), border_width = 1)

f_row(int r, string k, string v, color vbg) =>
    table.cell(dash, 0, r, k, text_color = color.silver, text_size = dSize, text_halign = text.align_left)
    table.cell(dash, 1, r, v, text_color = color.white, bgcolor = vbg, text_size = dSize)

f_dirColor(int d) =>
    d == 1 ? color.new(color.green, 30) : d == -1 ? color.new(color.red, 30) : color.new(color.gray, 60)

if showDashboard and barstate.islast
    int biasDir = bullBias ? 1 : bearBias ? -1 : 0
    table.cell(dash, 0, 0, "NQ SMART MONEY", text_color = color.white, text_size = dSize)
    table.merge_cells(dash, 0, 0, 1, 0)
    f_row(1, "Bias",      biasDir == 1 ? "Bullish" : biasDir == -1 ? "Bearish" : "Neutral", f_dirColor(biasDir))
    f_row(2, "Structure", structureTrend == 1 ? "Bullish" : structureTrend == -1 ? "Bearish" : "Neutral", f_dirColor(structureTrend))
    f_row(3, "VWAP",      close > vwapValue ? "Above" : "Below", na)
    f_row(4, "EMA 200",   close > ema200 ? "Above" : "Below", na)
    f_row(5, "PDH",       dayHigh >= pdh ? "Taken" : "Untouched", na)
    f_row(6, "PDL",       dayLow <= pdl ? "Taken" : "Untouched", na)
    f_row(7, "OR High",   na(orHigh) ? "-" : str.tostring(orHigh, format.mintick), na)
    f_row(8, "OR Low",    na(orLow) ? "-" : str.tostring(orLow, format.mintick), na)
    f_row(9, "Active FVGs", str.tostring(bullFVGBoxes.size()) + " bull / " + str.tostring(bearFVGBoxes.size()) + " bear", na)

// =====================================================
// ALERTS
// =====================================================
alertcondition(bullBias and not bullBias[1], "Bullish bias",      "{{ticker}}: bullish bias started")
alertcondition(bearBias and not bearBias[1], "Bearish bias",      "{{ticker}}: bearish bias started")
alertcondition(bullBOS,   "Bullish BOS",   "{{ticker}}: bullish break of structure")
alertcondition(bearBOS,   "Bearish BOS",   "{{ticker}}: bearish break of structure")
alertcondition(bullCHoCH, "Bullish CHoCH", "{{ticker}}: bullish change of character")
alertcondition(bearCHoCH, "Bearish CHoCH", "{{ticker}}: bearish change of character")
alertcondition(bullFVG,   "New bullish FVG", "{{ticker}}: new bullish fair value gap")
alertcondition(bearFVG,   "New bearish FVG", "{{ticker}}: new bearish fair value gap")
````
