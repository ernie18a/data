# ORB 15 Min Pro Max Way

- url: https://www.tradingview.com/script/KhKOWKqM-ORB-15-Min-Pro-Max-Way/
- type: indicator
- pine_id: PUB;bc10770e939b4d4fb7dbd5eb92aa4d41
- version: 1.0

## Description

ORB 15-Min Pro — Max Way

Opening Range Breakout tool built around a simple rule set: mark the first 15 minutes of the session (wicks included), then wait for a 15-minute candle close outside that range before calling anything a breakout. Wick pokes don't count.

What it draws

The opening range as a shaded zone extended across the session, with solid high/low lines and a dashed midline. The zone is green when today's range formed above yesterday's, red when below.
Triangle markers on the exact candle where a breakout is confirmed (up = buy, down = sell).
BNR labels when price breaks out, pulls back to the broken level, holds it, and closes back in the breakout direction.
An X-cross when a breakout fails and price closes back inside the range. Failed moves often rotate to the midline or the other side of the range, so these are worth watching as reversal context.
Stepped take-profit levels after each breakout, spaced by a configurable percentage of the range width (default 50%). When one is reached, the next plots. "Adaptive" mode keeps only the nearest levels on screen, "Extended" keeps them all.
A status table with the current bias (above/below midline, inside/outside range), range levels, and the next target in each direction.
Key detail: multi-timeframe confirmation. If your chart is on 1m, 2m, or 5m for execution, the script still waits for the 15-minute bar to close outside the range before signaling. It reads only completed 15m bars, so confirmed signals do not repaint. On a 15m or higher chart it uses the chart's own closes.

Sessions. Defaults to the NYSE open (09:30–09:45 New York time), but the range window is an input — set it to 18:00–18:15 for the Globex open or 03:00–03:15 for London. A separate trading-window input controls how late in the session signals may fire (default: until noon).

Optional filters, all off by default: breakout-candle volume vs. the opening-range average, session VWAP alignment, an EMA trend filter, and a range-quality filter that skips days when the opening range is unusually narrow or wide relative to the 14-day daily ATR. The base configuration is pure price action.

Alerts are included for all six events: buy, sell, both retests, and both failed breakouts.

What this is not. It's an indicator, not a strategy — there is no backtest attached and no performance claim implied. Breakouts fail regularly, especially on range-bound days; the failed-breakout markers exist precisely because of that. Test it on your own symbols and timeframes before trading it, and manage risk accordingly.

Credits. The opening range breakout concept goes back decades (Toby Crabel, Mark Fisher). The midline emphasis, 15-minute close confirmation, and failed-move logic follow the approach Max Options Trading teaches publicly. The zone/target presentation is inspired by LuxAlgo's open-source "Opening Range with Breakouts & Targets." The code itself is original.

## Source Code

````pine
//@version=6
// ORB 15-Min — "Max Way" signals with LuxAlgo-style plotting
//
// Signal engine (Big Daddy Max / Max Options Trading):
//  - Opening range = FIRST 15-minute candle of the session, WICKS INCLUDED
//  - ORB High / Low / Midline ("hidden liquidity") + midline bias gauge
//  - Signal = a 15-MINUTE candle CLOSE outside the range (never a wick poke),
//    confirmed even when the chart is on the 1m/2m execution timeframe
//  - Break & Retest (BNR) and Failed-Breakout reversal signals
//
// Plotting (LuxAlgo "Opening Range with Breakouts & Targets" style):
//  - Shaded opening-range zone extended across the session,
//    green when today's range is above yesterday's, red when below
//  - Triangle breakout markers on the exact signal candle
//  - Dynamic take-profit target lines stepped in % of the range width;
//    when one is reached the next plots (Adaptive keeps chart clean,
//    Extended keeps every level)
//  - Optional session moving average (resets at the opening range start)
indicator("ORB 15-Min Pro — Max Way", shorttitle="ORB MaxWay", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=250)

// === INPUTS: Opening Range ===
grpOR       = "Opening Range"
orSession   = input.session("0930-0945", "Opening Range Window", group=grpOR, tooltip="First 15 minutes of the session. NY open = 0930-0945. Globex open = 1800-1815. London = 0300-0315 (all in the timezone below).")
tradeWin    = input.session("0945-1200", "Trading Window (signals allowed)", group=grpOR, tooltip="Signals only fire inside this window.")
tzInput     = input.string("America/New_York", "Session Timezone", group=grpOR)
showHistory = input.bool(true, "Show Historical Sessions", group=grpOR, tooltip="OFF: only today's range and targets stay on the chart (clean look).")

// === INPUTS: Signals ===
grpS        = "Signals"
confMode    = input.string("15-min close (Max Way)", "Breakout Confirmation", options=["15-min close (Max Way)", "Chart timeframe close"], group=grpS, tooltip="Max Way: the breakout only counts when a 15-MINUTE candle closes outside the range, even if your chart is on 1m/2m for execution. Chart timeframe close: any chart candle closing outside the range triggers.")
showRetest  = input.bool(true, "Break & Retest (BNR) Signals", group=grpS, tooltip="After a confirmed breakout, price pulls back to the broken ORB line, holds it, and closes back in the breakout direction.")
showFailed  = input.bool(true, "Failed-Breakout Reversal Signals", group=grpS, tooltip="After a confirmed breakout, a close back INSIDE the range flags the failed move — expect rotation toward the midline / other side.")
onePerDay   = input.bool(false, "Only First Breakout of the Day", group=grpS, tooltip="ON: one breakout signal per day total. OFF: up to one long AND one short per day.")

// === INPUTS: Targets (LuxAlgo style) ===
grpT        = "Targets"
showTgts    = input.bool(true, "Show Breakout Targets", group=grpT)
tgtPct      = input.float(50.0, "Target Step (% of range width)", minval=5.0, step=5.0, group=grpT, tooltip="Each target sits this % of the opening-range width beyond the last level. When one is reached, the next plots.")
tgtCrossSrc = input.string("High/Low", "Target Cross Source", options=["High/Low", "Close"], group=grpT, tooltip="High/Low: a wick touch validates the target. Close: requires a candle close beyond it.")
tgtMode     = input.string("Adaptive", "Target Display", options=["Adaptive", "Extended"], group=grpT, tooltip="Adaptive: only the most recent targets stay visible. Extended: every reached level persists for the session.")

// === INPUTS: Bias / Session MA ===
grpB        = "Bias & Session MA"
showBiasBg  = input.bool(false, "Shade Background by Midline Bias", group=grpB, tooltip="Above midline = bullish tint, below = bearish tint. OFF by default — the range zone itself is now color-coded like LuxAlgo.")
showSMA     = input.bool(false, "Session Moving Average", group=grpB, tooltip="Average price since the opening range began. Resets every session. Use as trend filter or trailing level after a breakout.")

// === INPUTS: Optional Filters (all OFF = pure Max Way, candles only) ===
grpF        = "Optional Filters (research add-ons)"
useVolFlt   = input.bool(false, "Volume Confirmation", group=grpF, tooltip="Breakout candle volume must exceed the opening-range average by the multiplier below.")
volMult     = input.float(1.5, "Volume Multiplier (x OR average)", minval=0.5, step=0.1, group=grpF)
useVwapFlt  = input.bool(false, "VWAP Alignment", group=grpF, tooltip="Longs only above session VWAP, shorts only below.")
useEmaFlt   = input.bool(false, "EMA Trend Filter", group=grpF, tooltip="Longs above the EMA, shorts below.")
emaLen      = input.int(21, "EMA Length", minval=1, group=grpF)
useRngFlt   = input.bool(false, "Range Quality Filter (vs daily ATR)", group=grpF, tooltip="Skip days when the opening range is abnormally narrow or wide vs the 14-day ATR.")
minRngAtr   = input.float(0.15, "Min OR Width (x daily ATR)", minval=0.0, step=0.05, group=grpF)
maxRngAtr   = input.float(1.00, "Max OR Width (x daily ATR)", minval=0.1, step=0.05, group=grpF)

// === INPUTS: Display ===
grpD        = "Display"
showMid     = input.bool(true, "Show ORB Midline", group=grpD)
showTable   = input.bool(true, "Show Status Table", group=grpD)
colUp       = input.color(#089981, "Bullish Color", group=grpD)
colDn       = input.color(#f23645, "Bearish Color", group=grpD)

// === SESSION DETECTION ===
inOR      = not na(time(timeframe.period, orSession, tzInput))
inTradeW  = not na(time(timeframe.period, tradeWin, tzInput))
newDay    = ta.change(time("D")) != 0

// === OPENING RANGE STATE ===
var float orHigh     = na
var float orLow      = na
var float orVolSum   = 0.0
var int   orBarCount = 0
var int   orStartBar = na
var bool  orSeen     = false
var bool  longFired  = false
var bool  shortFired = false
var bool  longFailed  = false
var bool  shortFailed = false
var bool  longRetested  = false
var bool  shortRetested = false
var int   activeDir  = 0
var float prevOrMid  = na

// === DRAWING HANDLES (current session) ===
var box   orBox   = na
var line  lnHigh  = na
var line  lnLow   = na
var line  lnMid   = na
var array<line> upTgtLines = array.new<line>()
var array<line> dnTgtLines = array.new<line>()

// === TARGET STATE ===
var int   upTgtCnt = 0
var int   dnTgtCnt = 0
var float upTgtLvl = na
var float dnTgtLvl = na

// === SESSION MA STATE ===
var float smaSum = 0.0
var int   smaCnt = 0

if newDay
    // remember yesterday's range mean for the green/red zone bias
    prevOrMid := orSeen ? (orHigh + orLow) / 2.0 : prevOrMid
    if not showHistory
        box.delete(orBox)
        line.delete(lnHigh)
        line.delete(lnLow)
        line.delete(lnMid)
        for ln in upTgtLines
            line.delete(ln)
        for ln in dnTgtLines
            line.delete(ln)
    array.clear(upTgtLines)
    array.clear(dnTgtLines)
    orBox         := na
    lnHigh        := na
    lnLow         := na
    lnMid         := na
    orHigh        := na
    orLow         := na
    orVolSum      := 0.0
    orBarCount    := 0
    orStartBar    := na
    orSeen        := false
    longFired     := false
    shortFired    := false
    longFailed    := false
    shortFailed   := false
    longRetested  := false
    shortRetested := false
    activeDir     := 0
    upTgtCnt      := 0
    dnTgtCnt      := 0
    upTgtLvl      := na
    dnTgtLvl      := na

if inOR
    if not orSeen
        orStartBar := bar_index
        smaSum     := 0.0
        smaCnt     := 0
    orSeen     := true
    orHigh     := na(orHigh) ? high : math.max(orHigh, high)
    orLow      := na(orLow) ? low : math.min(orLow, low)
    orVolSum   += volume
    orBarCount += 1

if orSeen
    smaSum += close
    smaCnt += 1
sessionMA = smaCnt > 0 ? smaSum / smaCnt : na

orDone   = orSeen and not inOR and not na(orHigh)
orMid    = (orHigh + orLow) / 2.0
orRange  = orHigh - orLow
orAvgVol = orBarCount > 0 ? orVolSum / orBarCount : na

// === 15-MINUTE CONFIRMED CLOSE (non-repainting: uses last COMPLETED 15m bar) ===
chartBelow15 = timeframe.in_seconds() < 15 * 60
htfClose15   = request.security(syminfo.tickerid, "15", close[1], lookahead=barmerge.lookahead_on)
htfTime15    = request.security(syminfo.tickerid, "15", time[1], lookahead=barmerge.lookahead_on)
new15Close   = ta.change(htfTime15) != 0

// === OPTIONAL FILTERS ===
vwapVal  = ta.vwap(hlc3)
emaVal   = ta.ema(close, emaLen)
dailyAtr = request.security(syminfo.tickerid, "D", ta.atr(14)[1], lookahead=barmerge.lookahead_on)

volOK       = not useVolFlt or (not na(orAvgVol) and volume >= volMult * orAvgVol)
rangeOK     = not useRngFlt or (not na(dailyAtr) and orRange >= minRngAtr * dailyAtr and orRange <= maxRngAtr * dailyAtr)
vwapOKLong  = not useVwapFlt or close > vwapVal
vwapOKShort = not useVwapFlt or close < vwapVal
emaOKLong   = not useEmaFlt or close > emaVal
emaOKShort  = not useEmaFlt or close < emaVal

// === BREAKOUT CONFIRMATION (candle CLOSE beyond the range — never a wick) ===
useHtf     = confMode == "15-min close (Max Way)" and chartBelow15
longBreak  = useHtf ? (new15Close and htfClose15 > orHigh) : close > orHigh
shortBreak = useHtf ? (new15Close and htfClose15 < orLow) : close < orLow

dayBudgetOK = not onePerDay or (not longFired and not shortFired)

buySignal  = orDone and inTradeW and not longFired and longBreak and volOK and vwapOKLong and emaOKLong and rangeOK and dayBudgetOK
sellSignal = orDone and inTradeW and not shortFired and shortBreak and volOK and vwapOKShort and emaOKShort and rangeOK and dayBudgetOK and not buySignal

if buySignal
    longFired := true
    activeDir := 1
if sellSignal
    shortFired := true
    activeDir  := -1

// === BREAK & RETEST (BNR): pullback holds the broken ORB line ===
retestLong  = showRetest and orDone and inTradeW and longFired and not longFailed and not longRetested and not buySignal and low <= orHigh and close > orHigh
retestShort = showRetest and orDone and inTradeW and shortFired and not shortFailed and not shortRetested and not sellSignal and high >= orLow and close < orLow
if retestLong
    longRetested := true
if retestShort
    shortRetested := true

// === FAILED-BREAKOUT REVERSALS ===
insideClose = useHtf ? (new15Close and htfClose15 < orHigh and htfClose15 > orLow) : (close < orHigh and close > orLow)
failedLong  = showFailed and orDone and longFired and not longFailed and activeDir == 1 and insideClose
failedShort = showFailed and orDone and shortFired and not shortFailed and activeDir == -1 and insideClose
if failedLong
    longFailed := true
    activeDir  := 0
if failedShort
    shortFailed := true
    activeDir   := 0

// === MAX BIAS GAUGE ===
bias = not orDone ? 0 : close > orHigh ? 2 : close > orMid ? 1 : close >= orLow ? -1 : -2
biasTxt = bias == 2 ? "UPTREND — above ORB" : bias == 1 ? "Bullish — above midline" : bias == -1 ? "Bearish — below midline" : bias == -2 ? "DOWNTREND — below ORB" : "—"
biasBg = not showBiasBg or bias == 0 ? na : bias == 2 ? color.new(colUp, 85) : bias == 1 ? color.new(colUp, 94) : bias == -1 ? color.new(colDn, 94) : color.new(colDn, 85)
bgcolor(biasBg, title="Midline Bias Shading")

// === LUX-STYLE RANGE ZONE (green above yesterday's range, red below) ===
zoneBull = na(prevOrMid) or orMid >= prevOrMid
zoneCol  = zoneBull ? colUp : colDn
orJustDone = orDone and not orDone[1]
if orJustDone
    orBox  := box.new(orStartBar, orHigh, bar_index, orLow, border_color=color.new(zoneCol, 100), bgcolor=color.new(zoneCol, 88))
    lnHigh := line.new(orStartBar, orHigh, bar_index, orHigh, color=zoneCol, width=2)
    lnLow  := line.new(orStartBar, orLow, bar_index, orLow, color=zoneCol, width=2)
    lnMid  := showMid ? line.new(orStartBar, orMid, bar_index, orMid, color=color.new(zoneCol, 40), width=1, style=line.style_dashed) : na
else if orDone and not na(orBox)
    box.set_right(orBox, bar_index)
    line.set_x2(lnHigh, bar_index)
    line.set_x2(lnLow, bar_index)
    if not na(lnMid)
        line.set_x2(lnMid, bar_index)

// === LUX-STYLE DYNAMIC TARGETS (% of range width, stepped as they're hit) ===
tgtStep = orRange * tgtPct / 100.0
newUpTgt(float lvl) =>
    ln = line.new(bar_index, lvl, bar_index + 1, lvl, color=color.new(colUp, 30), width=1, style=line.style_dotted)
    array.push(upTgtLines, ln)
    if tgtMode == "Adaptive"
        while array.size(upTgtLines) > 2
            line.delete(array.shift(upTgtLines))
newDnTgt(float lvl) =>
    ln = line.new(bar_index, lvl, bar_index + 1, lvl, color=color.new(colDn, 30), width=1, style=line.style_dotted)
    array.push(dnTgtLines, ln)
    if tgtMode == "Adaptive"
        while array.size(dnTgtLines) > 2
            line.delete(array.shift(dnTgtLines))

if showTgts and buySignal
    upTgtCnt := 1
    upTgtLvl := orHigh + tgtStep
    newUpTgt(upTgtLvl)
if showTgts and sellSignal
    dnTgtCnt := 1
    dnTgtLvl := orLow - tgtStep
    newDnTgt(dnTgtLvl)

upCrossVal = tgtCrossSrc == "Close" ? close : high
dnCrossVal = tgtCrossSrc == "Close" ? close : low
if showTgts and upTgtCnt > 0 and not na(upTgtLvl) and upCrossVal >= upTgtLvl
    upTgtCnt += 1
    upTgtLvl := orHigh + tgtStep * upTgtCnt
    newUpTgt(upTgtLvl)
if showTgts and dnTgtCnt > 0 and not na(dnTgtLvl) and dnCrossVal <= dnTgtLvl
    dnTgtCnt += 1
    dnTgtLvl := orLow - tgtStep * dnTgtCnt
    newDnTgt(dnTgtLvl)

// extend active target lines to the current bar
if array.size(upTgtLines) > 0
    for ln in upTgtLines
        line.set_x2(ln, bar_index)
if array.size(dnTgtLines) > 0
    for ln in dnTgtLines
        line.set_x2(ln, bar_index)

// === PLOTS ===
plot(useVwapFlt ? vwapVal : na, "Session VWAP", color=color.new(color.orange, 0), linewidth=1)
plot(useEmaFlt ? emaVal : na, "EMA Filter", color=color.new(color.purple, 30), linewidth=1)
plot(showSMA and orSeen ? sessionMA : na, "Session MA", color=color.new(color.aqua, 20), linewidth=1, style=plot.style_linebr)

// === SIGNALS (Lux-style triangles on the exact breakout candle) ===
plotshape(buySignal, "Buy Signal", style=shape.triangleup, location=location.belowbar, color=colUp, size=size.small)
plotshape(sellSignal, "Sell Signal", style=shape.triangledown, location=location.abovebar, color=colDn, size=size.small)
plotshape(retestLong, "Retest Long (BNR)", style=shape.labelup, location=location.belowbar, color=color.new(colUp, 30), textcolor=color.white, text="BNR", size=size.tiny)
plotshape(retestShort, "Retest Short (BNR)", style=shape.labeldown, location=location.abovebar, color=color.new(colDn, 30), textcolor=color.white, text="BNR", size=size.tiny)
plotshape(failedLong, "Failed Long Breakout", style=shape.xcross, location=location.abovebar, color=color.new(colDn, 0), size=size.tiny)
plotshape(failedShort, "Failed Short Breakout", style=shape.xcross, location=location.belowbar, color=color.new(colUp, 0), size=size.tiny)

// === STATUS TABLE ===
var table info = table.new(position.top_right, 2, 8, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.new(color.gray, 60))
if showTable and barstate.islast
    statusTxt = inOR ? "Range forming…" : not orSeen ? "Waiting for open" : activeDir == 1 ? "LONG breakout active" : activeDir == -1 ? "SHORT breakout active" : (longFailed or shortFailed) ? "Breakout FAILED — back inside" : inTradeW ? "Armed — waiting for 15m close" : "Window closed"
    table.cell(info, 0, 0, "ORB Max Way", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 0, statusTxt, text_color=color.yellow, text_size=size.small)
    table.cell(info, 0, 1, "Bias", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 1, biasTxt, text_color=bias > 0 ? colUp : bias < 0 ? colDn : color.gray, text_size=size.small)
    table.cell(info, 0, 2, "ORB High", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 2, na(orHigh) ? "—" : str.tostring(orHigh, format.mintick), text_color=colUp, text_size=size.small)
    table.cell(info, 0, 3, "ORB Midline", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 3, na(orHigh) ? "—" : str.tostring(orMid, format.mintick), text_color=color.yellow, text_size=size.small)
    table.cell(info, 0, 4, "ORB Low", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 4, na(orLow) ? "—" : str.tostring(orLow, format.mintick), text_color=colDn, text_size=size.small)
    table.cell(info, 0, 5, "Range Width", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 5, na(orHigh) ? "—" : str.tostring(orRange, format.mintick), text_color=color.white, text_size=size.small)
    table.cell(info, 0, 6, "Next Target ↑", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 6, na(upTgtLvl) ? "—" : str.tostring(upTgtLvl, format.mintick) + " (T" + str.tostring(upTgtCnt) + ")", text_color=colUp, text_size=size.small)
    table.cell(info, 0, 7, "Next Target ↓", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 7, na(dnTgtLvl) ? "—" : str.tostring(dnTgtLvl, format.mintick) + " (T" + str.tostring(dnTgtCnt) + ")", text_color=colDn, text_size=size.small)

// === ALERTS ===
alertcondition(buySignal, "ORB Buy Signal", "ORB BUY {{ticker}} @ {{close}} — 15m close above opening range high")
alertcondition(sellSignal, "ORB Sell Signal", "ORB SELL {{ticker}} @ {{close}} — 15m close below opening range low")
alertcondition(retestLong, "ORB Retest Long (BNR)", "ORB BNR LONG {{ticker}} @ {{close}} — ORB High held as support after breakout")
alertcondition(retestShort, "ORB Retest Short (BNR)", "ORB BNR SHORT {{ticker}} @ {{close}} — ORB Low held as resistance after breakdown")
alertcondition(failedLong, "ORB Failed Long (bearish)", "ORB FAILED LONG {{ticker}} @ {{close}} — closed back inside range, watch midline / short side")
alertcondition(failedShort, "ORB Failed Short (bullish)", "ORB FAILED SHORT {{ticker}} @ {{close}} — closed back inside range, watch midline / long side")
````
