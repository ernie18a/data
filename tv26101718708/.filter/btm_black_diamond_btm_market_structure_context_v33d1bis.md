# BTM = Black Diamond - BTM - Market Structure Context

- url: https://www.tradingview.com/script/v33D1biS-BTM-Black-Diamond-BTM-Market-Structure-Context/
- type: indicator
- pine_id: PUB;cac3ad36d71f45b2b5d4332ad91b292f
- version: 1.0

## Description

Black Diamond - Market Structure Context is a charting tool that maps market structure, key levels and multi-timeframe trend in one place. It is designed to give context, not to generate trade signals. There are no BUY/SELL arrows, no entry/stop/target boxes and no setup grades - the decisions stay with you.

WHAT IT SHOWS

Market structure
- Swing highs and lows labelled HH, HL, LH and LL.
- BOS (break of structure): a candle closes through the most recent swing in the direction of the current structure, so the structure continues.
- CHOCH (change of character): a candle closes through the most recent swing against the current structure, so the structure flips.
- A dashed line connects each broken swing to the candle that broke it.
- Each swing can only be broken once, and breaks are always measured against the latest swing, so the structure never gets stuck on old levels.

Retest zones
- After every break, a zone is drawn around the broken level (± a fraction of ATR).
- The zone stays active until price closes through it, the opposite side breaks, or it expires after a set number of bars.
- When price returns to the zone and closes back out of it, a small "retest held" note appears, stating whether that is with or against the daily trend.

Key levels
- Previous day high and low.
- Asian session range (23:00-07:00 London time).
- Optional markers for sweeps of these levels (a wick through the level with a close back inside).

Fair value gaps
- Three-candle imbalances above a minimum size (in ATR), removed once price trades back into them.

EMAs
- 20, 50 and 238 EMAs with adjustable colours.

Dashboard
- Daily, H4 and H1 trend (20/50 EMA relationship).
- Current structure and the last break (BOS or CHOCH).
- EMA 20 vs 50, and price vs the 238 EMA.
- Volatility (ATR percentile: low, normal, high).
- Current session (Asia, London, New York, Late US).

HOW TO USE IT
Use it to read the market rather than to trigger trades. Typical questions it helps answer:
- Is structure bullish or bearish, and did it just change?
- Is price returning to a level it recently broke?
- Does the lower-timeframe move agree with the daily and H4 trend?
- Where are the obvious reference levels for today?

NON-REPAINTING NOTES
- Higher-timeframe trends use the last closed bar of that timeframe, so they do not change after the fact.
- BOS, CHOCH, retest notes and alerts are only confirmed when the candle closes.
- Swings need a set number of bars on each side to be confirmed (default 5). Their labels are drawn back on the swing candle, so on historical bars they appear earlier than they could have been known in real time. Keep this in mind when reviewing past price action.

ALERTS
- BOS
- CHOCH
- Retest held (any)
- Retest held with the daily trend
- Previous-day or Asian level sweep

SETTINGS
Every component can be switched on or off: swing labels, breaks, retest zones and notes, previous-day levels, Asian range, sweeps, fair value gaps, EMAs and the dashboard. Swing strength, zone size, zone expiry, FVG size and dashboard position and text size are adjustable.

DISCLAIMER
This indicator is for chart analysis and education only. It does not provide trading signals or financial advice. Past price behaviour does not guarantee future results. Always test any approach yourself and manage your risk.

## Source Code

````pine
//@version=6
// Black Diamond - Market Structure Context
// A plain charting indicator: it describes structure, trend and key levels and
// leaves trade decisions to you. It deliberately has no BUY/SELL signals, no
// entry/stop/target boxes and no setup grades - backtesting (2017-2026, FOREX.com
// XAUUSD/EURUSD/US30) found no reliable edge in mechanical signals from this logic.
// The one consistent finding was that structure retests WITH the daily trend
// behaved better than those against it, so that context is shown on the chart.
indicator("BTM = Black Diamond - BTM - Market Structure Context", shorttitle="BD Structure", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

// ── Inputs ──────────────────────────────────────────────────────────────────
G_STR = "Market Structure"
G_ZONE = "Retest Zones"
G_LVL = "Key Levels"
G_FVG = "Fair Value Gaps"
G_EMA = "EMAs"
G_DASH = "Dashboard"

pivotLen = input.int(5, "Swing Strength (bars each side)", minval=2, maxval=20, group=G_STR, tooltip="A swing is only confirmed this many bars after it forms. Labels are drawn back on the swing bar, so on history they appear earlier than they could have been known live.")
showSwingLabels = input.bool(true, "Show HH / HL / LH / LL", group=G_STR)
showBreaks = input.bool(true, "Show BOS / CHOCH", group=G_STR, tooltip="CHOCH = close through the latest swing against the current structure (structure flips). BOS = close through it with the structure (structure continues).")
maxStructLabels = input.int(80, "Max Structure Labels Kept", minval=10, maxval=200, group=G_STR)

showZones = input.bool(true, "Show Retest Zones", group=G_ZONE, tooltip="After a break, the broken level ± a fraction of ATR, until price closes through it, the opposite side breaks, or it expires.")
zoneAtrMult = input.float(0.5, "Zone Half-Height (ATR)", minval=0.1, step=0.1, group=G_ZONE)
zoneMaxBars = input.int(50, "Zone Expiry (bars)", minval=5, group=G_ZONE)
showRetestNotes = input.bool(true, "Show Retest Notes", group=G_ZONE, tooltip="Marks when price comes back into a retest zone and closes back out of it, and whether that is with or against the daily trend. Context only, not a trade signal.")

showPrevDay = input.bool(true, "Previous Day High / Low", group=G_LVL)
showAsia = input.bool(true, "Asian Range (23:00-07:00 London)", group=G_LVL)
showSweeps = input.bool(false, "Mark Sweeps of These Levels", group=G_LVL, tooltip="A wick through the level with a close back inside. Backtesting found sweeps did not improve results, so this is off by default.")

showFvg = input.bool(true, "Show Fair Value Gaps", group=G_FVG)
fvgMinAtr = input.float(0.10, "Minimum Gap Size (ATR)", minval=0.0, step=0.05, group=G_FVG)
fvgMax = input.int(15, "Maximum Active Gaps", minval=1, maxval=50, group=G_FVG)
fvgExtend = input.int(20, "Extend Right (bars)", minval=1, maxval=200, group=G_FVG)

showEmas = input.bool(true, "Show 20 / 50 / 238 EMAs", group=G_EMA)
ema20Color = input.color(color.rgb(196, 181, 253), "EMA 20", group=G_EMA, inline="ema")
ema50Color = input.color(color.rgb(147, 51, 234), "EMA 50", group=G_EMA, inline="ema")
ema238Color = input.color(color.rgb(255, 211, 0), "EMA 238", group=G_EMA, inline="ema")

showDash = input.bool(true, "Show Dashboard", group=G_DASH)
dashPosChoice = input.string("Top Right", "Position", options=["Top Left", "Top Center", "Top Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=G_DASH)
dashSizeChoice = input.string("Small", "Text Size", options=["Tiny", "Small", "Normal"], group=G_DASH)

// ── Colours ─────────────────────────────────────────────────────────────────
colBull = color.rgb(38, 166, 120)
colBear = color.rgb(230, 80, 80)
colFlat = color.rgb(120, 128, 140)
colBlack = color.rgb(10, 8, 14)
colBlackAlt = color.rgb(20, 14, 30)
colPurple = color.rgb(109, 40, 217)
colPurpleDeep = color.rgb(59, 7, 100)
colLavender = color.rgb(196, 181, 253)
colMuted = color.rgb(140, 130, 165)

atr = ta.atr(14)
tfSec = timeframe.in_seconds()

// ── EMAs ────────────────────────────────────────────────────────────────────
ema20 = ta.ema(close, 20)
ema50 = ta.ema(close, 50)
ema238 = ta.ema(close, 238)
plot(showEmas ? ema20 : na, "EMA 20", color=ema20Color, linewidth=1)
plot(showEmas ? ema50 : na, "EMA 50", color=ema50Color, linewidth=1)
plot(showEmas ? ema238 : na, "EMA 238", color=ema238Color, linewidth=2)

// ── Higher-timeframe trend (last CLOSED bar - does not repaint) ─────────────
f_trend() =>
    f = ta.ema(close, 20)
    s = ta.ema(close, 50)
    f > s and close > s ? 1 : f < s and close < s ? -1 : 0

dTrend = request.security(syminfo.tickerid, "D", f_trend()[1], lookahead=barmerge.lookahead_on)
h4Trend = request.security(syminfo.tickerid, "240", f_trend()[1], lookahead=barmerge.lookahead_on)
h1Trend = request.security(syminfo.tickerid, "60", f_trend()[1], lookahead=barmerge.lookahead_on)
dValid = tfSec <= 86400
h4Valid = tfSec <= 14400
h1Valid = tfSec <= 3600

// ── Market structure ────────────────────────────────────────────────────────
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float swingHigh = na
var int swingHighBar = na
var float swingLow = na
var int swingLowBar = na
var bool highBroken = true
var bool lowBroken = true
var int trend = 0
var string lastEvent = "-"
var array<label> structLabels = array.new<label>()
var array<line> structLines = array.new<line>()

f_keepLabel(label lb) =>
    array.push(structLabels, lb)
    while array.size(structLabels) > maxStructLabels
        label.delete(array.shift(structLabels))

f_keepLine(line ln) =>
    array.push(structLines, ln)
    while array.size(structLines) > maxStructLabels
        line.delete(array.shift(structLines))

if not na(ph)
    if showSwingLabels and not na(swingHigh)
        isHH = ph > swingHigh
        f_keepLabel(label.new(bar_index - pivotLen, ph, isHH ? "HH" : "LH", style=label.style_label_down, color=color.new(color.black, 100), textcolor=isHH ? colBull : colBear, size=size.small))
    swingHigh := ph
    swingHighBar := bar_index - pivotLen
    highBroken := false

if not na(pl)
    if showSwingLabels and not na(swingLow)
        isHL = pl > swingLow
        f_keepLabel(label.new(bar_index - pivotLen, pl, isHL ? "HL" : "LL", style=label.style_label_up, color=color.new(color.black, 100), textcolor=isHL ? colBull : colBear, size=size.small))
    swingLow := pl
    swingLowBar := bar_index - pivotLen
    lowBroken := false

bullBreak = barstate.isconfirmed and not highBroken and not na(swingHigh) and close > swingHigh
bearBreak = barstate.isconfirmed and not bullBreak and not lowBroken and not na(swingLow) and close < swingLow
bullChoch = bullBreak and trend != 1
bearChoch = bearBreak and trend != -1
bullBos = bullBreak and trend == 1
bearBos = bearBreak and trend == -1

if bullBreak and showBreaks
    f_keepLine(line.new(swingHighBar, swingHigh, bar_index, swingHigh, color=colBull, style=line.style_dashed))
    f_keepLabel(label.new(int(math.round((swingHighBar + bar_index) / 2)), swingHigh, bullChoch ? "CHOCH" : "BOS", style=label.style_label_down, color=color.new(color.black, 100), textcolor=colBull, size=size.small))
if bearBreak and showBreaks
    f_keepLine(line.new(swingLowBar, swingLow, bar_index, swingLow, color=colBear, style=line.style_dashed))
    f_keepLabel(label.new(int(math.round((swingLowBar + bar_index) / 2)), swingLow, bearChoch ? "CHOCH" : "BOS", style=label.style_label_up, color=color.new(color.black, 100), textcolor=colBear, size=size.small))

// ── Retest zones ────────────────────────────────────────────────────────────
var float buyTop = na
var float buyBottom = na
var int buyBar = na
var bool buyActive = false
var box buyBox = na
var float sellTop = na
var float sellBottom = na
var int sellBar = na
var bool sellActive = false
var box sellBox = na
var array<box> zoneBoxes = array.new<box>()
var array<label> noteLabels = array.new<label>()

f_keepBox(box bx) =>
    array.push(zoneBoxes, bx)
    while array.size(zoneBoxes) > 40
        box.delete(array.shift(zoneBoxes))

f_keepNote(label lb) =>
    array.push(noteLabels, lb)
    while array.size(noteLabels) > 60
        label.delete(array.shift(noteLabels))

if bullBreak
    sellActive := false
    buyTop := swingHigh + atr * zoneAtrMult
    buyBottom := swingHigh - atr * zoneAtrMult
    buyBar := bar_index
    buyActive := true
    buyBox := na
    if showZones
        buyBox := box.new(swingHighBar, buyTop, bar_index, buyBottom, bgcolor=color.new(colBull, 88), border_color=color.new(colBull, 65), text="retest zone", text_color=color.new(colBull, 30), text_size=size.tiny, text_halign=text.align_left)
        f_keepBox(buyBox)
    highBroken := true
    trend := 1
    lastEvent := bullChoch ? "Bull CHOCH" : "Bull BOS"

if bearBreak
    buyActive := false
    sellTop := swingLow + atr * zoneAtrMult
    sellBottom := swingLow - atr * zoneAtrMult
    sellBar := bar_index
    sellActive := true
    sellBox := na
    if showZones
        sellBox := box.new(swingLowBar, sellTop, bar_index, sellBottom, bgcolor=color.new(colBear, 88), border_color=color.new(colBear, 65), text="retest zone", text_color=color.new(colBear, 30), text_size=size.tiny, text_halign=text.align_left)
        f_keepBox(sellBox)
    lowBroken := true
    trend := -1
    lastEvent := bearChoch ? "Bear CHOCH" : "Bear BOS"

f_dailyContext(int dir) =>
    not dValid ? "" : dTrend == dir ? "with daily trend" : dTrend == -dir ? "against daily trend" : "daily trend flat"

buyRetest = barstate.isconfirmed and buyActive and bar_index > buyBar and low <= buyTop and close > open and close > buyTop
sellRetest = barstate.isconfirmed and sellActive and bar_index > sellBar and high >= sellBottom and close < open and close < sellBottom
buyRetestWith = buyRetest and dValid and dTrend == 1
sellRetestWith = sellRetest and dValid and dTrend == -1

if buyRetest
    if showRetestNotes
        ctx = f_dailyContext(1)
        f_keepNote(label.new(bar_index, low, "retest held" + (ctx == "" ? "" : "\n" + ctx), style=label.style_label_up, color=color.new(dTrend == 1 ? colBull : colFlat, 35), textcolor=color.white, size=size.tiny, tooltip="Price returned to the broken high and closed back above the zone. Context only, not a trade signal."))
    buyActive := false
if sellRetest
    if showRetestNotes
        ctx = f_dailyContext(-1)
        f_keepNote(label.new(bar_index, high, "retest held" + (ctx == "" ? "" : "\n" + ctx), style=label.style_label_down, color=color.new(dTrend == -1 ? colBear : colFlat, 35), textcolor=color.white, size=size.tiny, tooltip="Price returned to the broken low and closed back below the zone. Context only, not a trade signal."))
    sellActive := false

if buyActive and barstate.isconfirmed and (close < buyBottom or bar_index - buyBar > zoneMaxBars)
    buyActive := false
if sellActive and barstate.isconfirmed and (close > sellTop or bar_index - sellBar > zoneMaxBars)
    sellActive := false

if buyActive and not na(buyBox)
    box.set_right(buyBox, bar_index)
if sellActive and not na(sellBox)
    box.set_right(sellBox, bar_index)

// ── Key levels ──────────────────────────────────────────────────────────────
pdh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
pdl = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)
showPdLines = showPrevDay and timeframe.isintraday
plot(showPdLines and ta.change(pdh) == 0 ? pdh : na, "Previous Day High", color=color.new(color.orange, 20), style=plot.style_linebr)
plot(showPdLines and ta.change(pdl) == 0 ? pdl : na, "Previous Day Low", color=color.new(color.aqua, 20), style=plot.style_linebr)

asianSession = not na(time(timeframe.period, "2300-0700", "Europe/London"))
asianStart = asianSession and not asianSession[1]
var float asianHigh = na
var float asianLow = na
if asianStart
    asianHigh := high
    asianLow := low
else if asianSession
    asianHigh := math.max(asianHigh, high)
    asianLow := math.min(asianLow, low)
showAsiaLines = showAsia and timeframe.isintraday and tfSec <= 3600
plot(showAsiaLines and not asianStart ? asianHigh : na, "Asian High", color=color.new(color.fuchsia, 30), style=plot.style_linebr)
plot(showAsiaLines and not asianStart ? asianLow : na, "Asian Low", color=color.new(color.fuchsia, 30), style=plot.style_linebr)

newDay = timeframe.change("D")
var bool pdhSwept = false
var bool pdlSwept = false
var bool asiaHighSwept = false
var bool asiaLowSwept = false
if newDay
    pdhSwept := false
    pdlSwept := false
if asianStart
    asiaHighSwept := false
    asiaLowSwept := false
pdhSweep = barstate.isconfirmed and timeframe.isintraday and not pdhSwept and high > pdh and close < pdh
pdlSweep = barstate.isconfirmed and timeframe.isintraday and not pdlSwept and low < pdl and close > pdl
asiaHighSweep = barstate.isconfirmed and showAsiaLines and not asianSession and not asiaHighSwept and high > asianHigh and close < asianHigh
asiaLowSweep = barstate.isconfirmed and showAsiaLines and not asianSession and not asiaLowSwept and low < asianLow and close > asianLow
if pdhSweep
    pdhSwept := true
if pdlSweep
    pdlSwept := true
if asiaHighSweep
    asiaHighSwept := true
if asiaLowSweep
    asiaLowSwept := true
plotshape(showSweeps and (pdhSweep or asiaHighSweep), "Sweep of High", shape.xcross, location.abovebar, color.new(color.orange, 20), size=size.tiny)
plotshape(showSweeps and (pdlSweep or asiaLowSweep), "Sweep of Low", shape.xcross, location.belowbar, color.new(color.aqua, 20), size=size.tiny)

// ── Fair value gaps ─────────────────────────────────────────────────────────
var array<box> fvgBoxes = array.new<box>()
var array<float> fvgTops = array.new<float>()
var array<float> fvgBottoms = array.new<float>()
var array<int> fvgTypes = array.new<int>()

bullGap = showFvg and barstate.isconfirmed and low > high[2] and low - high[2] >= atr * fvgMinAtr
bearGap = showFvg and barstate.isconfirmed and high < low[2] and low[2] - high >= atr * fvgMinAtr

f_addGap(float top, float bottom, int typ) =>
    c = typ == 1 ? colBull : colBear
    array.push(fvgBoxes, box.new(bar_index - 2, top, bar_index + fvgExtend, bottom, bgcolor=color.new(c, 85), border_color=color.new(c, 70), text="FVG", text_color=color.new(c, 30), text_size=size.tiny, text_halign=text.align_right))
    array.push(fvgTops, top)
    array.push(fvgBottoms, bottom)
    array.push(fvgTypes, typ)
    while array.size(fvgBoxes) > fvgMax
        box.delete(array.shift(fvgBoxes))
        array.shift(fvgTops)
        array.shift(fvgBottoms)
        array.shift(fvgTypes)

if array.size(fvgBoxes) > 0
    for i = array.size(fvgBoxes) - 1 to 0
        typ = array.get(fvgTypes, i)
        filled = typ == 1 ? low <= array.get(fvgTops, i) : high >= array.get(fvgBottoms, i)
        if filled
            box.delete(array.get(fvgBoxes, i))
            array.remove(fvgBoxes, i)
            array.remove(fvgTops, i)
            array.remove(fvgBottoms, i)
            array.remove(fvgTypes, i)
        else
            box.set_right(array.get(fvgBoxes, i), bar_index + fvgExtend)

if bullGap
    f_addGap(low, high[2], 1)
if bearGap
    f_addGap(low[2], high, -1)

// ── Dashboard ───────────────────────────────────────────────────────────────
atrRank = ta.percentrank(atr, 500)
dashPos = dashPosChoice == "Top Left" ? position.top_left : dashPosChoice == "Top Center" ? position.top_center : dashPosChoice == "Top Right" ? position.top_right : dashPosChoice == "Bottom Left" ? position.bottom_left : dashPosChoice == "Bottom Center" ? position.bottom_center : position.bottom_right
dashSize = dashSizeChoice == "Tiny" ? size.tiny : dashSizeChoice == "Normal" ? size.normal : size.small
dashSmall = dashSizeChoice == "Normal" ? size.small : size.tiny
var table dash = table.new(dashPos, 2, 12, bgcolor=colBlack, frame_color=colPurple, frame_width=2, border_color=colPurpleDeep, border_width=1)

f_trendText(int t, bool valid) => not valid ? "n/a" : t == 1 ? "▲ Up" : t == -1 ? "▼ Down" : "■ Flat"
f_trendColor(int t, bool valid) => not valid ? colMuted : t == 1 ? colBull : t == -1 ? colBear : colMuted
f_row(int row, string name, string value, color valueColor) =>
    table.cell(dash, 0, row, name, text_color=colLavender, bgcolor=colBlack, text_size=dashSize, text_halign=text.align_left)
    table.cell(dash, 1, row, value, text_color=valueColor, bgcolor=colBlackAlt, text_size=dashSize, text_halign=text.align_left)

if barstate.isfirst
    table.merge_cells(dash, 0, 0, 1, 0)
    table.merge_cells(dash, 0, 1, 1, 1)
    table.merge_cells(dash, 0, 11, 1, 11)

if barstate.islast and not showDash
    table.clear(dash, 0, 0, 1, 11)

if barstate.islast
    if showDash
        hr = hour(time, "Europe/London")
        session = not timeframe.isintraday ? "n/a" : hr >= 7 and hr < 12 ? "London" : hr >= 12 and hr < 17 ? "New York" : hr >= 17 and hr < 23 ? "Late US" : "Asia"
        volText = na(atrRank) ? "n/a" : atrRank >= 75 ? "High" : atrRank <= 25 ? "Low" : "Normal"
        volColor = na(atrRank) ? colMuted : atrRank >= 75 ? color.rgb(251, 146, 60) : atrRank <= 25 ? colMuted : colLavender
        structText = trend == 1 ? "▲ Bullish" : trend == -1 ? "▼ Bearish" : "-"
        structColor = trend == 1 ? colBull : trend == -1 ? colBear : colMuted
        emaStackText = ema20 > ema50 ? "▲ 20 above 50" : ema20 < ema50 ? "▼ 20 below 50" : "■ Level"
        emaStackColor = ema20 > ema50 ? colBull : ema20 < ema50 ? colBear : colMuted
        ema238Text = close > ema238 ? "▲ Above" : close < ema238 ? "▼ Below" : "■ At"
        ema238TextColor = close > ema238 ? colBull : close < ema238 ? colBear : colMuted
        table.cell(dash, 0, 0, "◆ BLACK DIAMOND", text_color=color.white, bgcolor=colPurple, text_size=dashSize)
        table.cell(dash, 0, 1, syminfo.ticker + "  ·  " + timeframe.period, text_color=colLavender, bgcolor=colPurpleDeep, text_size=dashSmall)
        f_row(2, "Daily trend", f_trendText(dTrend, dValid), f_trendColor(dTrend, dValid))
        f_row(3, "H4 trend", f_trendText(h4Trend, h4Valid), f_trendColor(h4Trend, h4Valid))
        f_row(4, "H1 trend", f_trendText(h1Trend, h1Valid), f_trendColor(h1Trend, h1Valid))
        f_row(5, "Structure", structText, structColor)
        f_row(6, "Last break", lastEvent, colLavender)
        f_row(7, "EMA 20 / 50", emaStackText, emaStackColor)
        f_row(8, "Price vs EMA 238", ema238Text, ema238TextColor)
        f_row(9, "Volatility", volText, volColor)
        f_row(10, "Session", session, colLavender)
        table.cell(dash, 0, 11, "context only · not trade signals", text_color=colMuted, bgcolor=colBlack, text_size=dashSmall)

// ── Alerts ──────────────────────────────────────────────────────────────────
alertcondition(bullBos or bearBos, "BOS", "Break of structure on {{ticker}} ({{interval}}).")
alertcondition(bullChoch or bearChoch, "CHOCH", "Change of character on {{ticker}} ({{interval}}).")
alertcondition(buyRetest or sellRetest, "Retest Held (any)", "Price retested a broken level and held on {{ticker}} ({{interval}}).")
alertcondition(buyRetestWith or sellRetestWith, "Retest Held With Daily Trend", "Retest of a broken level held, in the direction of the daily trend, on {{ticker}} ({{interval}}).")
alertcondition(pdhSweep or pdlSweep or asiaHighSweep or asiaLowSweep, "Level Sweep", "Previous-day or Asian level swept on {{ticker}} ({{interval}}).")
````
