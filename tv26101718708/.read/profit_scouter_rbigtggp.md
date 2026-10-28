# Profit Scouter

- url: https://www.tradingview.com/script/rBIGtgGP-Profit-Scouter/
- type: indicator
- pine_id: PUB;486981ae29f1457da2523e3b5d8b0366
- version: 1.0

## Description

OVERVIEW
Profit Scouter is an intraday trade-signal indicator for 1–5 minute charts, designed around Micro Gold futures (MGC) but usable on other futures. It combines four Candle Range Theory (CRT) models and a New York Opening Range Breakout (ORB), then plots each signal as a complete trade plan: entry, stop loss and three take-profit levels, with built-in position sizing and a running scorecard.

SIGNAL MODELS
Each CRT model uses a reference candle's high, low and 50% midpoint:
- Daily CRT – previous trading day's range
- 4H CRT – previous 4-hour candle (anchored to New York 1/5/9 AM by default, or the exchange's 6 PM schedule)
- 8–9 AM CRT – the 8:00–9:00 AM New York candle
- Hourly CRT – the previous hour's candle
- NY ORB – first close beyond the opening range (default 9:30–9:45 AM New York)

A CRT signal requires price to sweep beyond the range high or low, then confirm a reversal back inside it. Three confirmation modes are available:
- CISD (default) – a close back through the open of the move that made the sweep
- HTF candle close – strict three-candle CRT: the reference timeframe's candle must close back inside the range, and entry is taken in the discount (longs) or premium (shorts) half
- Fast – the first lower-timeframe close back inside the range
If the sweep extends further than a set fraction of the range (default 50%), it is treated as a genuine breakout and the setup is cancelled.

TRADE PLAN
- Stop: just beyond the sweep wick for CRT trades; the ORB midpoint for ORB trades
- CRT targets: TP1 = 50% level, TP2 = opposite side of the range, TP3 = an extension beyond it
- ORB targets: 1R / 2R / 3R (adjustable)
- Management: 1/3 taken at each target; the stop can move to breakeven after TP1 and to TP1 after TP2 (both optional); the final third can exit at TP3 or trail by ATR
- Position size is calculated from your dollar risk per trade and the instrument's point value
When several models trigger at once, priority is Daily → 4H → 8–9 AM → Hourly → ORB, and only one trade is open at a time.

FILTERS
- Trading window and end-of-day exit (New York time)
- Entry block around the 8:30 AM data releases and on abnormally large candles
- Maximum and minimum stop size, minimum reward-to-risk to the opposite side of the range
- Daily trade limit and stop-after-losses limit
- Optional: market regime filter (higher-timeframe ADX + EMA stack, or ribbon direction), daily 50% premium/discount filter, minimum TP1 distance, extreme-volatility filter

VISUALS
- 8/13/21/34/55 EMA trend ribbon (lines, fill or cloud)
- Live trade zone with Entry / SL / TP tags; finished trades stay on the chart with hit targets marked ✅ and stopped trades ❌
- Optional CRT / ORB level lines and markers for setups that were filtered out (hover for the reason)
- Panel showing trend, regime, current signal, levels, targets hit, and results

SCORECARD
The panel tracks trade count, win rate, net R and average R per trade, overall and per model. These figures are hypothetical and based on simplifying assumptions: entries at the signal candle's close, a fixed round-trip cost per contract (default $3), scaling out in thirds, and the stop assumed to be hit first when a stop and target fall within the same candle. They do not account for slippage beyond the cost setting, partial fills or position-size rounding, and they only cover the history loaded on your chart. Use them to compare settings, not as a forecast of future results.

ALERTS
Create one alert with the condition "Any alert() function call" to receive entries (with SL and all targets), TP1/TP2 hits with stop-move instructions, and trade exits. Separate alert conditions for buy, sell, TP1, TP2 and trade closed are also available. Alerts only fire on live data, not on historical bars or Bar Replay.

NOTES
Signals are confirmed on candle close. This script is an analysis tool, not financial advice. Past signals and scorecard results do not guarantee future performance.

## Source Code

````pine
//@version=6
// MGC CRT + NY ORB (v10)
// v8 behavior by default + per-model scorecard + step-by-step alerts
// Optional: market regime filter, minimum TP1 distance
// For 1-5 minute charts on MGC. Educational use only, not financial advice.

indicator("Profit Scouter", overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 200)

tz = "America/New_York"

// ---------- Models ----------
grpM     = "Models"
useD     = input.bool(true, "Daily CRT (previous day)", group = grpM)
use4     = input.bool(true, "4H CRT", group = grpM)
h4Anchor = input.string("NY 1/5/9 AM", "4H candle anchor", options = ["NY 1/5/9 AM", "Exchange (6 PM)"], group = grpM)
use89    = input.bool(true, "8-9 AM CRT (NY 8:00-9:00 candle)", group = grpM)
use1H    = input.bool(true, "Hourly CRT (previous hour)", group = grpM)
useOrb   = input.bool(true, "NY ORB", group = grpM)
orStart  = input.int(930, "NY ORB start (HHMM)", minval = 0, maxval = 2359, group = grpM)
orEnd    = input.int(945, "NY ORB end (HHMM)", minval = 0, maxval = 2359, group = grpM)

grpC      = "CRT rules"
crtMode   = input.string("CISD", "CRT confirmation", options = ["CISD", "HTF candle close", "Fast"], group = grpC)
maxSweep  = input.float(0.5, "Max sweep depth (x range) before it counts as a breakout", minval = 0.05, step = 0.05, group = grpC)
tp3Ext    = input.float(0.25, "TP3 extension past range (x range)", minval = 0, step = 0.05, group = grpC)
minTp1R   = input.float(0.0, "Min distance to 50% TP1 (R), 0 = off", minval = 0, step = 0.1, group = grpC)
tp1Action = input.string("Use range end as TP1", "If the 50% is closer than that", options = ["Use range end as TP1", "Skip trade"], group = grpC)
useEq     = input.bool(false, "Daily 50% filter: longs in discount, shorts in premium", group = grpC)

// ---------- Market regime (optional) ----------
grpG       = "Market regime filter"
regimeMode = input.string("Off", "Regime filter", options = ["Off", "ADX regime", "Ribbon direction"], group = grpG)
regTf      = input.timeframe("15", "Regime timeframe (ADX mode)", group = grpG)
adxLen     = input.int(14, "ADX length", minval = 2, group = grpG)
adxTrend   = input.float(25, "Trending when ADX above", step = 1, group = grpG)
useVol     = input.bool(false, "Sit out when volatility is extreme", group = grpG)
volMult    = input.float(2.0, "Extreme = ATR above x times its 100-bar average", minval = 1, step = 0.25, group = grpG)

// ---------- Session (New York time, HHMM) ----------
grpS      = "Session (New York time, HHMM)"
sessStart = input.int(800,  "Trading start", minval = 0, maxval = 2359, group = grpS)
sessEnd   = input.int(1200, "No new entries after", minval = 0, maxval = 2359, group = grpS)
flatTime  = input.int(1300, "Close open trade at", minval = 0, maxval = 2359, group = grpS)
useNews   = input.bool(true, "Block entries around 8:30 data", group = grpS)
newsStart = input.int(828, "News block start", minval = 0, maxval = 2359, group = grpS)
newsEnd   = input.int(845, "News block end", minval = 0, maxval = 2359, group = grpS)

// ---------- Risk & trade management ----------
grpR         = "Risk & trade management"
bufTicks     = input.int(5, "Stop buffer beyond sweep (ticks)", minval = 0, group = grpR)
minStopTicks = input.int(15, "Minimum stop (ticks)", minval = 1, group = grpR)
maxStopTicks = input.int(100, "Maximum stop (ticks), else skip", minval = 1, group = grpR)
minRR        = input.float(1.5, "Min R to opposite side of range (CRT)", minval = 0.5, step = 0.25, group = grpR)
tp1R         = input.float(1.0, "ORB TP1 (R)", minval = 0.25, step = 0.25, group = grpR)
tp2R         = input.float(2.0, "ORB TP2 (R)", minval = 0.25, step = 0.25, group = grpR)
tp3R         = input.float(3.0, "ORB TP3 (R)", minval = 0.25, step = 0.25, group = grpR)
beMode       = input.string("After TP1", "Move stop to breakeven", options = ["After TP1", "After TP2", "Never"], group = grpR)
trailTP1     = input.bool(true, "Move stop to TP1 after TP2", group = grpR)
runnerMode   = input.string("Fixed TP3", "Final 1/3 exit", options = ["Fixed TP3", "Trail (ATR)"], group = grpR)
trailMult    = input.float(2.0, "Runner trail distance (x ATR)", minval = 0.5, step = 0.25, group = grpR)
riskDollars  = input.float(100, "Risk per trade ($)", minval = 1, group = grpR)
pointValue   = input.float(10.0, "$ per 1.0 point (MGC = 10)", minval = 0.01, group = grpR)
rtCost       = input.float(3.0, "Round-trip cost per contract ($)", minval = 0, step = 0.5, group = grpR)
atrLen       = input.int(14, "ATR length", minval = 1, group = grpR)
spikeMult    = input.float(3.0, "Skip if candle range > x ATR", step = 0.5, group = grpR)
maxTrades    = input.int(4, "Max trades per day", minval = 1, group = grpR)
maxLosses    = input.int(2, "Stop after losses per day", minval = 1, group = grpR)

// ---------- Visuals ----------
grpV        = "Visuals"
ribbonStyle = input.string("Lines + Fill", "Trend ribbon", options = ["Lines + Fill", "Lines", "Cloud", "Off"], group = grpV)
colorBars   = input.bool(false, "Color candles by trend", group = grpV)
bullCol     = input.color(color.rgb(0, 200, 83), "Bull color", group = grpV)
bearCol     = input.color(color.rgb(255, 23, 68), "Bear color", group = grpV)
entryCol    = input.color(color.rgb(41, 98, 255), "Entry color", group = grpV)
showHistory = input.bool(true, "Keep past trades on chart", group = grpV)
levelMode   = input.string("Off", "CRT / ORB levels", options = ["Off", "All"], group = grpV)
colD        = input.color(color.silver, "Daily level color", group = grpV)
col4        = input.color(color.aqua, "4H level color", group = grpV)
col89       = input.color(color.fuchsia, "8-9 AM level color", group = grpV)
colOR       = input.color(color.yellow, "ORB level color", group = grpV)
showSkips   = input.bool(false, "Show skipped setups (×)", group = grpV)
showSessBg  = input.bool(false, "Shade session / news window", group = grpV)
extendBars  = input.int(20, "Extend trade zone right (bars)", minval = 1, maxval = 200, group = grpV)
showPanel   = input.bool(true, "Show panel", group = grpV)
showModels  = input.bool(true, "Show per-model scorecard", group = grpV)
panelPos    = input.string("Bottom Right", "Panel position", options = ["Bottom Right", "Top Right", "Bottom Left", "Top Left"], group = grpV)

// ---------- Candle runs (for CISD) ----------
var float bearRunOpen = na
var float bullRunOpen = na
if close < open and not (close[1] < open[1])
    bearRunOpen := open
if close > open and not (close[1] > open[1])
    bullRunOpen := open

// ---------- Helpers ----------
px(float p) => str.tostring(p, format.mintick)

sgn(float v) => (v >= 0 ? "+" : "") + str.tostring(v, "#.##")

brk(float v) => nz(v, -1) != nz(v[1], -1) ? na : v

hideTag(label lb) =>
    label.set_text(lb, "")
    label.set_color(lb, color.new(color.black, 100))
    lb

histTag(label lb, string txt, color c) =>
    label.set_x(lb, bar_index)
    label.set_text(lb, txt)
    label.set_color(lb, color.new(color.black, 100))
    label.set_textcolor(lb, c)
    label.set_size(lb, size.tiny)
    lb

mName(int i) => i == 0 ? "Daily CRT" : i == 1 ? "4H CRT" : i == 2 ? "8-9 CRT" : i == 3 ? "1H CRT" : "NY ORB"

regFn() =>
    [dp, dm, a] = ta.dmi(adxLen, adxLen)
    e1 = ta.ema(close, 8)
    e2 = ta.ema(close, 21)
    e3 = ta.ema(close, 55)
    [a[1], e1[1] > e2[1] and e2[1] > e3[1], e1[1] < e2[1] and e2[1] < e3[1]]

// CRT engine. Returns [long, short, sweepLow, sweepHigh, rangeHigh, rangeLow]
crtSignal(float rH, float rL, bool act, bool kill) =>
    var bool  sweptL = false
    var bool  sweptH = false
    var float extL   = na
    var float extH   = na
    var float cisdL  = na
    var float cisdH  = na
    var bool  doneL  = false
    var bool  doneH  = false
    var bool  armL   = false
    var bool  armH   = false
    var float aH     = na
    var float aL     = na
    var float aExL   = na
    var float aExH   = na
    oH     = rH[1]
    oL     = rL[1]
    c2     = close[1]
    chg    = nz(rH, -1) != nz(oH, -1) or nz(rL, -1) != nz(oL, -1)
    strict = crtMode == "HTF candle close"
    if chg
        armL := false
        armH := false
        if strict and not na(oH) and not na(oL) and oH > oL
            if sweptL and not doneL and c2 > oL and c2 < oH
                armL := true
                aExL := extL
            if sweptH and not doneH and c2 < oH and c2 > oL
                armH := true
                aExH := extH
            aH := oH
            aL := oL
        sweptL := false
        sweptH := false
        extL   := na
        extH   := na
        cisdL  := na
        cisdH  := na
        doneL  := false
        doneH  := false
    if kill
        armL := false
        armH := false
    rng = rH - rL
    if not na(rng) and rng > 0
        if low < rL
            if na(extL) or low < extL
                extL  := low
                cisdL := bearRunOpen
            sweptL := true
        if high > rH
            if na(extH) or high > extH
                extH  := high
                cisdH := bullRunOpen
            sweptH := true
        if sweptL and rL - extL > maxSweep * rng
            doneL := true
        if sweptH and extH - rH > maxSweep * rng
            doneH := true
    bool longSig  = false
    bool shortSig = false
    if strict
        if armL and low < aExL
            armL := false
        if armH and high > aExH
            armH := false
        aMid = (aH + aL) / 2
        longSig  := act and armL and close > aL and close < aMid
        shortSig := act and armH and close < aH and close > aMid
        if longSig
            armL := false
        if shortSig
            armH := false
    else if not na(rng) and rng > 0
        trigL = crtMode == "CISD" ? math.max(rL, nz(cisdL, rL)) : rL
        trigH = crtMode == "CISD" ? math.min(rH, nz(cisdH, rH)) : rH
        longSig  := act and sweptL and not doneL and close > trigL and close > open
        shortSig := act and sweptH and not doneH and close < trigH and close < open
        if longSig
            doneL := true
        if shortSig
            doneH := true
    [longSig, shortSig, strict ? aExL : extL, strict ? aExH : extH, strict ? aH : rH, strict ? aL : rL]

levelTag(float y, string name, color c) =>
    var label lb = label.new(bar_index, close, "", style = label.style_label_left, color = color.new(color.black, 100), size = size.small)
    if barstate.islast
        label.set_xy(lb, bar_index + 2, na(y) ? close : y)
        label.set_text(lb, na(y) ? "" : name + " " + px(y))
        label.set_textcolor(lb, c)
    lb

// ---------- Time ----------
hrNY     = hour(time, tz)
hhmm     = hrNY * 100 + minute(time, tz)
dow      = dayofweek(time, tz)
weekday  = dow != dayofweek.saturday and dow != dayofweek.sunday
inSess   = weekday and hhmm >= sessStart and hhmm < sessEnd
inNews   = useNews and weekday and hhmm >= newsStart and hhmm < newsEnd
in89     = weekday and hhmm >= 800 and hhmm < 900
inOR     = weekday and hhmm >= orStart and hhmm < orEnd
pastFlat = hhmm >= flatTime and hhmm < 1800
newDay   = timeframe.change("D")
cross10  = hhmm >= 1000 and hhmm[1] < 1000

atr     = ta.atr(atrLen)
atrAvg  = ta.sma(atr, 100)
spike   = (high - low) > spikeMult * atr[1]
volHigh = useVol and not na(atrAvg) and atr > volMult * atrAvg
buf     = bufTicks * syminfo.mintick
minStop = minStopTicks * syminfo.mintick

// ---------- Daily range ----------
dH   = request.security(syminfo.tickerid, "D", high[1], lookahead = barmerge.lookahead_on)
dL   = request.security(syminfo.tickerid, "D", low[1],  lookahead = barmerge.lookahead_on)
dMid = (dH + dL) / 2

// ---------- 4H range ----------
xH = request.security(syminfo.tickerid, "240", high[1], lookahead = barmerge.lookahead_on)
xL = request.security(syminfo.tickerid, "240", low[1],  lookahead = barmerge.lookahead_on)

blk    = math.floor(((hrNY + 23) % 24) / 4)
newBlk = blk != blk[1]
var float cbH = na
var float cbL = na
var float pbH = na
var float pbL = na
if newBlk
    pbH := cbH
    pbL := cbL
    cbH := high
    cbL := low
else
    cbH := na(cbH) ? high : math.max(cbH, high)
    cbL := na(cbL) ? low  : math.min(cbL, low)

h4H = h4Anchor == "NY 1/5/9 AM" ? pbH : xH
h4L = h4Anchor == "NY 1/5/9 AM" ? pbL : xL
h4M = (h4H + h4L) / 2

// ---------- Hourly range ----------
newHr = hrNY != hrNY[1]
var float chH = na
var float chL = na
var float phH = na
var float phL = na
if newHr
    phH := chH
    phL := chL
    chH := high
    chL := low
else
    chH := na(chH) ? high : math.max(chH, high)
    chL := na(chL) ? low  : math.min(chL, low)

// ---------- Trend ribbon ----------
r1 = ta.ema(close, 8)
r2 = ta.ema(close, 13)
r3 = ta.ema(close, 21)
r4 = ta.ema(close, 34)
r5 = ta.ema(close, 55)
trendUp   = r1 > r5
rc        = trendUp ? bullCol : bearCol
showRib   = ribbonStyle != "Off"
showLines = ribbonStyle == "Lines + Fill" or ribbonStyle == "Lines"
showFill  = ribbonStyle == "Lines + Fill" or ribbonStyle == "Cloud"

p1 = plot(showRib ? r1 : na, "Ribbon 8",  color = color.new(rc, showLines ? 0  : 100), linewidth = 2)
p2 = plot(showRib ? r2 : na, "Ribbon 13", color = color.new(rc, showLines ? 10 : 100), linewidth = 2)
p3 = plot(showRib ? r3 : na, "Ribbon 21", color = color.new(rc, showLines ? 20 : 100), linewidth = 1)
p4 = plot(showRib ? r4 : na, "Ribbon 34", color = color.new(rc, showLines ? 30 : 100), linewidth = 1)
p5 = plot(showRib ? r5 : na, "Ribbon 55", color = color.new(rc, showLines ? 40 : 100), linewidth = 1)
fill(p1, p2, color = showFill ? color.new(rc, 50) : na)
fill(p2, p3, color = showFill ? color.new(rc, 62) : na)
fill(p3, p4, color = showFill ? color.new(rc, 74) : na)
fill(p4, p5, color = showFill ? color.new(rc, 84) : na)

barcolor(colorBars ? rc : na)

// ---------- Regime ----------
[rAdx, rUp, rDn] = request.security(syminfo.tickerid, regTf, regFn(), lookahead = barmerge.lookahead_on)

isAdxMode  = regimeMode == "ADX regime"
isRibMode  = regimeMode == "Ribbon direction"
regUp      = isAdxMode ? (rAdx >= adxTrend and rUp) : isRibMode ? trendUp : false
regDn      = isAdxMode ? (rAdx >= adxTrend and rDn) : isRibMode ? not trendUp : false
allowLong  = not regDn
allowShort = not regUp
orbOkLong  = regimeMode == "Off" or regUp
orbOkShort = regimeMode == "Off" or regDn
regTxt     = regimeMode == "Off" ? "Off" : regUp ? "Trending ↑" : regDn ? "Trending ↓" : "Range"

// ---------- Trade state ----------
var int    tDir     = 0
var int    tSel     = 0
var float  tEntry   = na
var float  tRisk    = na
var float  tSL      = na
var float  tSL0     = na
var float  tT1      = na
var float  tT2      = na
var float  tT3      = na
var float  tR1      = na
var float  tR2      = na
var float  tR3      = na
var int    tStage   = 0
var int    tBar     = na
var string tModel   = "-"
var string lastExit = "-"

var box   bxTP = na
var box   bxSL = na
var line  lE   = na
var line  lSL  = na
var line  lT1  = na
var line  lT2  = na
var line  lT3  = na
var label gE   = na
var label gSL  = na
var label gT1  = na
var label gT2  = na
var label gT3  = na

var int   tradesToday = 0
var int   lossesToday = 0
var float dayR        = 0.0
var int   totTrades   = 0
var int   totWins     = 0
var float totR        = 0.0

var array<int>   mTr  = array.new_int(5, 0)
var array<int>   mWin = array.new_int(5, 0)
var array<float> mNet = array.new_float(5, 0.0)

var float b89H = na
var float b89L = na
var float r89H = na
var float r89L = na
var float bOH  = na
var float bOL  = na
var float rOH  = na
var float rOL  = na
var bool  orUpDone = false
var bool  orDnDone = false

isTrail = runnerMode == "Trail (ATR)"

// ---------- Manage open trade ----------
float  result   = na
string exitTag  = ""
int    exitKind = 0   // 1 = SL, 2 = stop after TP, 3 = TP3, 4 = time
bool   tp1Now   = false
bool   tp2Now   = false
string stopMsg  = ""

if tDir != 0 and bar_index > tBar
    bool hitSL = tDir == 1 ? low  <= tSL : high >= tSL
    bool hitT1 = tDir == 1 ? high >= tT1 : low  <= tT1
    bool hitT2 = tDir == 1 ? high >= tT2 : low  <= tT2
    bool hitT3 = not isTrail and (tDir == 1 ? high >= tT3 : low <= tT3)
    float banked = tStage == 0 ? 0.0 : tStage == 1 ? tR1 / 3 : (tR1 + tR2) / 3
    float remain = tStage == 0 ? 1.0 : tStage == 1 ? 2.0 / 3 : 1.0 / 3
    if hitSL
        slR      = (tSL - tEntry) * tDir / tRisk
        result   := banked + remain * slR
        exitKind := tStage == 0 ? 1 : 2
        exitTag  := tStage == 0 ? "SL ❌" : tStage == 1 ? "Stop after TP1" : isTrail ? "Trail stop after TP2" : "Stop after TP2"
    else if hitT3
        result   := (tR1 + tR2 + tR3) / 3
        exitKind := 3
        exitTag  := "TP3 ✅"
    else if pastFlat or newDay
        openR    = (close - tEntry) * tDir / tRisk
        result   := banked + remain * openR
        exitKind := 4
        exitTag  := "TIME"
    else
        if tStage == 0 and hitT1
            tStage := 1
            tp1Now := true
            label.set_text(gT1, "TP1 ✅ " + px(tT1))
            if beMode == "After TP1"
                tSL     := tEntry
                stopMsg := "move stop to breakeven " + px(tEntry)
                label.set_text(gE, "ENTRY = STOP " + px(tEntry))
                hideTag(gSL)
        if tStage == 1 and hitT2
            tStage := 2
            tp2Now := true
            label.set_text(gT2, "TP2 ✅ " + px(tT2))
            if trailTP1
                tSL     := tT1
                stopMsg := "move stop to TP1 " + px(tT1)
                label.set_text(gE, "ENTRY " + px(tEntry))
                label.set_text(gT1, "TP1 ✅ = STOP " + px(tT1))
                hideTag(gSL)
            else if beMode != "Never"
                tSL     := tDir == 1 ? math.max(tSL, tEntry) : math.min(tSL, tEntry)
                stopMsg := "move stop to breakeven " + px(tEntry)
                label.set_text(gE, "ENTRY = STOP " + px(tEntry))
                hideTag(gSL)
        if tStage == 2 and isTrail
            trailLvl = close - tDir * trailMult * atr
            tSL := tDir == 1 ? math.max(tSL, trailLvl) : math.min(tSL, trailLvl)
            label.set_text(gT1, "TP1 ✅ " + px(tT1))
            label.set_text(gE, "ENTRY " + px(tEntry))
            label.set_text(gSL, "TRAIL " + px(tSL))
            label.set_color(gSL, bearCol)
        line.set_y1(lSL, tSL)
        line.set_y2(lSL, tSL)
        label.set_y(gSL, tSL)

// Step alerts
if tp1Now
    alert("MGC " + tModel + ": TP1 hit " + px(tT1) + " - take 1/3" + (stopMsg != "" and not tp2Now ? ", " + stopMsg : ""), alert.freq_once_per_bar_close)
if tp2Now
    alert("MGC " + tModel + ": TP2 hit " + px(tT2) + " - take 1/3" + (stopMsg != "" ? ", " + stopMsg : ""), alert.freq_once_per_bar_close)

bool closedNow = not na(result)

if tDir != 0 and not closedNow
    xr = bar_index + extendBars
    box.set_right(bxTP, xr)
    box.set_right(bxSL, xr)
    line.set_x2(lE, xr)
    line.set_x2(lSL, xr)
    line.set_x2(lT1, xr)
    line.set_x2(lT2, xr)
    line.set_x2(lT3, xr)
    label.set_x(gE, xr)
    label.set_x(gSL, xr)
    label.set_x(gT1, xr)
    label.set_x(gT2, xr)
    label.set_x(gT3, xr)

if closedNow
    result := result - rtCost / (tRisk * pointValue)
    totTrades += 1
    totR      += result
    dayR      += result
    if result > 0
        totWins += 1
    if result < 0
        lossesToday += 1

    mi = tSel - 1
    if mi >= 0 and mi <= 4
        array.set(mTr,  mi, array.get(mTr, mi) + 1)
        array.set(mNet, mi, array.get(mNet, mi) + result)
        if result > 0
            array.set(mWin, mi, array.get(mWin, mi) + 1)

    rTxt = sgn(result) + "R"
    lastExit := exitTag + " " + rTxt
    alert("MGC " + tModel + ": trade closed - " + lastExit, alert.freq_once_per_bar_close)

    t1Hit = tStage >= 1 or exitKind == 3
    t2Hit = tStage >= 2 or exitKind == 3
    t3Hit = exitKind == 3
    slHit = exitKind == 1
    unhit = color.new(color.gray, 40)

    box.set_right(bxTP, bar_index)
    box.set_right(bxSL, bar_index)
    box.set_bgcolor(bxTP, color.new(bullCol, 92))
    box.set_bgcolor(bxSL, color.new(bearCol, 92))
    line.set_x2(lE, bar_index)
    line.set_x2(lSL, bar_index)
    line.set_x2(lT1, bar_index)
    line.set_x2(lT2, bar_index)
    line.set_x2(lT3, bar_index)
    line.set_y1(lSL, tSL0)
    line.set_y2(lSL, tSL0)
    line.set_color(lSL, slHit ? bearCol : color.new(bearCol, 60))
    line.set_color(lT1, t1Hit ? bullCol : unhit)
    line.set_color(lT2, t2Hit ? bullCol : unhit)
    line.set_color(lT3, t3Hit ? bullCol : unhit)

    if showHistory
        label.set_y(gSL, tSL0)
        histTag(gE,  "Entry " + px(tEntry), entryCol)
        histTag(gSL, "SL "  + px(tSL0) + (slHit ? " ❌" : ""), slHit ? bearCol : unhit)
        histTag(gT1, "TP1 " + px(tT1)  + (t1Hit ? " ✅" : ""), t1Hit ? bullCol : unhit)
        histTag(gT2, "TP2 " + px(tT2)  + (t2Hit ? " ✅" : ""), t2Hit ? bullCol : unhit)
        histTag(gT3, "TP3 " + px(tT3)  + (t3Hit ? " ✅" : ""), t3Hit ? bullCol : unhit)
    else
        label.delete(gE)
        label.delete(gSL)
        label.delete(gT1)
        label.delete(gT2)
        label.delete(gT3)

    label.new(bar_index, tDir == 1 ? high : low, rTxt,
         style = tDir == 1 ? label.style_label_down : label.style_label_up,
         color = result > 0 ? color.new(bullCol, 30) : result < 0 ? color.new(bearCol, 30) : color.new(color.gray, 30),
         textcolor = color.white, size = size.tiny, tooltip = tModel + " exit: " + lastExit)
    tDir := 0

// ---------- Daily reset ----------
if newDay
    tradesToday := 0
    lossesToday := 0
    dayR        := 0.0
    r89H        := na
    r89L        := na
    rOH         := na
    rOL         := na
    orUpDone    := false
    orDnDone    := false

// ---------- Build 8-9 AM candle ----------
if in89 and not in89[1]
    b89H := high
    b89L := low
else if in89
    b89H := math.max(b89H, high)
    b89L := math.min(b89L, low)
if not in89 and in89[1]
    r89H := b89H
    r89L := b89L
if crtMode == "HTF candle close" and cross10
    r89H := na
    r89L := na
mid89 = (r89H + r89L) / 2

// ---------- Build NY opening range ----------
if inOR and not inOR[1]
    bOH := high
    bOL := low
else if inOR
    bOH := math.max(bOH, high)
    bOL := math.min(bOL, low)
if not inOR and inOR[1]
    rOH := bOH
    rOL := bOL
orMid = (rOH + rOL) / 2

// ---------- Signals ----------
canTrade = tDir == 0 and not closedNow and tradesToday < maxTrades and lossesToday < maxLosses
active   = inSess and not inNews and barstate.isconfirmed and canTrade

[dLong, dShort, dExL, dExH, dRH, dRL] = crtSignal(dH,   dL,   active and useD,  false)
[hLong, hShort, hExL, hExH, hRH, hRL] = crtSignal(h4H,  h4L,  active and use4,  false)
[eLong, eShort, eExL, eExH, eRH, eRL] = crtSignal(r89H, r89L, active and use89, newDay)
[gLong, gShort, gExL, gExH, gRH, gRL] = crtSignal(phH,  phL,  active and use1H, false)

orbL = active and useOrb and not na(rOH) and not orUpDone and close > rOH
orbS = active and useOrb and not na(rOL) and not orDnDone and close < rOL
if orbL
    orUpDone := true
if orbS
    orDnDone := true

dDir = dLong ? 1 : dShort ? -1 : 0
hDir = hLong ? 1 : hShort ? -1 : 0
eDir = eLong ? 1 : eShort ? -1 : 0
gDir = gLong ? 1 : gShort ? -1 : 0
oDir = orbL  ? 1 : orbS   ? -1 : 0

dOk = dDir == 1 ? allowLong : dDir == -1 ? allowShort : false
hOk = hDir == 1 ? allowLong : hDir == -1 ? allowShort : false
eOk = eDir == 1 ? allowLong : eDir == -1 ? allowShort : false
gOk = gDir == 1 ? allowLong : gDir == -1 ? allowShort : false
oOk = oDir == 1 ? orbOkLong : oDir == -1 ? orbOkShort : false
anyBlocked = (dDir != 0 and not dOk) or (hDir != 0 and not hOk) or (eDir != 0 and not eOk) or (gDir != 0 and not gOk) or (oDir != 0 and not oOk)

sel  = dOk ? 1 : hOk ? 2 : eOk ? 3 : gOk ? 4 : oOk ? 5 : 0
sDir = sel == 1 ? dDir : sel == 2 ? hDir : sel == 3 ? eDir : sel == 4 ? gDir : sel == 5 ? oDir : 0
modeTxt = crtMode == "HTF candle close" ? "HTF close" : crtMode
sTag = sel >= 1 and sel <= 4 ? mName(sel - 1) + " · " + modeTxt : "NY ORB"

sRH = sel == 1 ? dRH : sel == 2 ? hRH : sel == 3 ? eRH : gRH
sRL = sel == 1 ? dRL : sel == 2 ? hRL : sel == 3 ? eRL : gRL
sEx = sel == 1 ? (sDir == 1 ? dExL : dExH) : sel == 2 ? (sDir == 1 ? hExL : hExH) : sel == 3 ? (sDir == 1 ? eExL : eExH) : (sDir == 1 ? gExL : gExH)
sRng = sRH - sRL
crtRaw  = sDir == 1 ? close - (sEx - buf) : (sEx + buf) - close
crtRisk = math.max(crtRaw, minStop)
orbRisk = math.max(math.abs(close - orMid), minStop)

ext    = tp3Ext > 0 ? tp3Ext : 0.25
midLvl = (sRH + sRL) / 2
oppEnd = sDir == 1 ? sRH : sRL
crtR1  = (midLvl - close) * sDir / crtRisk
shiftT = sel >= 1 and sel <= 4 and crtR1 > 0 and crtR1 < minTp1R and tp1Action == "Use range end as TP1"

pRisk = sel == 5 ? orbRisk : crtRisk
pSL   = close - sDir * pRisk
pT1   = sel == 5 ? close + sDir * pRisk * tp1R : shiftT ? oppEnd : midLvl
pT2   = sel == 5 ? close + sDir * pRisk * tp2R : shiftT ? oppEnd + sDir * ext * sRng : oppEnd
pT3   = sel == 5 ? close + sDir * pRisk * tp3R : shiftT ? oppEnd + sDir * 2 * ext * sRng : oppEnd + sDir * tp3Ext * sRng
pQty  = sel != 0 ? math.floor(riskDollars / (pRisk * pointValue)) : 0

string why = ""
if sel != 0
    if spike
        why := "news/spike candle"
    else if volHigh
        why := "volatility extreme (ATR > " + str.tostring(volMult) + "x normal)"
    else if sel != 5 and crtR1 <= 0
        why := "price already past the 50% level"
    else if pRisk > maxStopTicks * syminfo.mintick or pQty < 1
        why := "stop too wide ($" + str.tostring(pRisk * pointValue, "#") + " per contract)"
    else if sel != 5 and (oppEnd - close) * sDir / pRisk < minRR
        why := "less than " + str.tostring(minRR) + "R to the other side"
    else if sel != 5 and crtR1 < minTp1R and tp1Action == "Skip trade"
        why := "50% TP1 only " + str.tostring(crtR1, "#.##") + "R away"
    else if useEq and not na(dMid) and ((sDir == 1 and close > dMid) or (sDir == -1 and close < dMid))
        why := sDir == 1 ? "long in daily premium (above 50%)" : "short in daily discount (below 50%)"

bool entered = false

if sel == 0 and anyBlocked and showSkips
    label.new(bar_index, high, "×", style = label.style_none, textcolor = color.gray, size = size.normal,
         tooltip = "Skipped: against the market regime (" + regTxt + ")")

if sel != 0 and why != ""
    if showSkips
        label.new(bar_index, sDir == 1 ? low : high, "×", style = label.style_none, textcolor = color.gray,
             size = size.normal, tooltip = sTag + (sDir == 1 ? " BUY" : " SELL") + " skipped: " + why)
else if sel != 0
    entered := true
    if not showHistory
        box.delete(bxTP)
        box.delete(bxSL)
        line.delete(lE)
        line.delete(lSL)
        line.delete(lT1)
        line.delete(lT2)
        line.delete(lT3)

    tDir   := sDir
    tSel   := sel
    tEntry := close
    tRisk  := pRisk
    tSL    := pSL
    tSL0   := pSL
    tT1    := pT1
    tT2    := pT2
    tT3    := pT3
    tR1    := (pT1 - close) * sDir / pRisk
    tR2    := (pT2 - close) * sDir / pRisk
    tR3    := (pT3 - close) * sDir / pRisk
    tStage := 0
    tBar   := bar_index
    tModel := sTag
    tradesToday += 1

    details = sTag + (sDir == 1 ? " BUY" : " SELL") + "\nRegime " + regTxt + "\nEntry " + px(tEntry) + "\nSL " + px(tSL) + " (" + str.tostring(pRisk, "#.#") + " pts)" + "\nTP1 " + px(tT1) + " (" + str.tostring(tR1, "#.#") + "R)" + (shiftT ? " range end, 50% too close" : "") + "\nTP2 " + px(tT2) + " (" + str.tostring(tR2, "#.#") + "R)" + "\nTP3 " + px(tT3) + (isTrail ? " (runner trails)" : " (" + str.tostring(tR3, "#.#") + "R)") + "\nQty " + str.tostring(pQty) + " ($" + str.tostring(pQty * pRisk * pointValue, "#") + " risk)"
    alert("MGC " + details, alert.freq_once_per_bar_close)
    label.new(bar_index, sDir == 1 ? low : high, sDir == 1 ? "BUY" : "SELL",
         style = sDir == 1 ? label.style_label_up : label.style_label_down,
         color = sDir == 1 ? bullCol : bearCol, textcolor = color.white,
         size = size.small, tooltip = details)

    xr = bar_index + extendBars
    bxTP := box.new(bar_index, math.max(tEntry, tT3), xr, math.min(tEntry, tT3), border_color = color.new(bullCol, 100), bgcolor = color.new(bullCol, 85))
    bxSL := box.new(bar_index, math.max(tEntry, tSL), xr, math.min(tEntry, tSL), border_color = color.new(bearCol, 100), bgcolor = color.new(bearCol, 85))
    lE   := line.new(bar_index, tEntry, xr, tEntry, color = entryCol, width = 2)
    lSL  := line.new(bar_index, tSL, xr, tSL, color = bearCol, width = 1)
    lT1  := line.new(bar_index, tT1, xr, tT1, color = color.new(bullCol, 30), width = 1)
    lT2  := line.new(bar_index, tT2, xr, tT2, color = color.new(bullCol, 30), width = 1)
    lT3  := line.new(bar_index, tT3, xr, tT3, color = color.new(bullCol, 30), width = 1, style = isTrail ? line.style_dotted : line.style_solid)
    gE   := label.new(xr, tEntry, "ENTRY " + px(tEntry), style = label.style_label_left, color = entryCol, textcolor = color.white, size = size.small)
    gSL  := label.new(xr, tSL,    "SL " + px(tSL),       style = label.style_label_left, color = bearCol,  textcolor = color.white, size = size.small)
    gT1  := label.new(xr, tT1,    "TP1 " + px(tT1),      style = label.style_label_left, color = bullCol,  textcolor = color.white, size = size.small)
    gT2  := label.new(xr, tT2,    "TP2 " + px(tT2),      style = label.style_label_left, color = bullCol,  textcolor = color.white, size = size.small)
    gT3  := label.new(xr, tT3,    (isTrail ? "TP3 (trail) " : "TP3 ") + px(tT3), style = label.style_label_left, color = bullCol, textcolor = color.white, size = size.small)

// ---------- Optional level lines ----------
lvl = levelMode == "All"
dHp = brk(dH)
dMp = brk(dMid)
dLp = brk(dL)
hHp = brk(h4H)
hMp = brk(h4M)
hLp = brk(h4L)
eHp = brk(r89H)
eMp = brk(mid89)
eLp = brk(r89L)
oHp = brk(rOH)
oMp = brk(orMid)
oLp = brk(rOL)

plot(lvl ? dHp : na, "Daily High", color = colD, linewidth = 2, style = plot.style_linebr)
plot(lvl ? dMp : na, "Daily 50%",  color = colD, style = plot.style_circles)
plot(lvl ? dLp : na, "Daily Low",  color = colD, linewidth = 2, style = plot.style_linebr)
plot(lvl ? hHp : na, "4H High",    color = col4, style = plot.style_linebr)
plot(lvl ? hMp : na, "4H 50%",     color = col4, style = plot.style_circles)
plot(lvl ? hLp : na, "4H Low",     color = col4, style = plot.style_linebr)
plot(lvl ? eHp : na, "8-9 High",   color = col89, style = plot.style_linebr)
plot(lvl ? eMp : na, "8-9 50%",    color = col89, style = plot.style_circles)
plot(lvl ? eLp : na, "8-9 Low",    color = col89, style = plot.style_linebr)
plot(lvl ? oHp : na, "ORB High",   color = colOR, style = plot.style_linebr)
plot(lvl ? oMp : na, "ORB 50%",    color = colOR, style = plot.style_circles)
plot(lvl ? oLp : na, "ORB Low",    color = colOR, style = plot.style_linebr)

levelTag(lvl ? dH    : na, "D High", colD)
levelTag(lvl ? dMid  : na, "D 50%",  colD)
levelTag(lvl ? dL    : na, "D Low",  colD)
levelTag(lvl ? h4H   : na, "4H High", col4)
levelTag(lvl ? h4M   : na, "4H 50%",  col4)
levelTag(lvl ? h4L   : na, "4H Low",  col4)
levelTag(lvl ? r89H  : na, "8-9 High", col89)
levelTag(lvl ? mid89 : na, "8-9 50%",  col89)
levelTag(lvl ? r89L  : na, "8-9 Low",  col89)
levelTag(lvl ? rOH   : na, "ORB High", colOR)
levelTag(lvl ? orMid : na, "ORB 50%",  colOR)
levelTag(lvl ? rOL   : na, "ORB Low",  colOR)

bgcolor(showSessBg ? (inNews ? color.new(color.red, 88) : inSess ? color.new(color.gray, 94) : na) : na)

// ---------- Panel ----------
pPos = panelPos == "Top Right" ? position.top_right : panelPos == "Bottom Left" ? position.bottom_left : panelPos == "Top Left" ? position.top_left : position.bottom_right
var table panel = table.new(pPos, 2, 18, border_width = 1, border_color = color.new(color.gray, 70))

hdrBg = color.rgb(20, 30, 120)
keyBg = color.new(color.black, 10)
valBg = color.new(color.rgb(30, 34, 45), 0)

cell(int r, string k, string v, color vbg, color vtxt) =>
    table.cell(panel, 0, r, k, text_color = color.white, bgcolor = keyBg, text_size = size.small, text_halign = text.align_left)
    table.cell(panel, 1, r, v, text_color = vtxt, bgcolor = vbg, text_size = size.small)

if showPanel and barstate.islast
    inTrade = tDir != 0
    sigTxt  = inTrade ? (tDir == 1 ? "🟢 BUY" : "🔴 SELL") : (tradesToday >= maxTrades or lossesToday >= maxLosses ? "Done for today" : inNews ? "News - wait" : volHigh ? "Volatility - wait" : inSess ? "Waiting" : "Closed")
    sigBg   = inTrade ? (tDir == 1 ? color.new(bullCol, 20) : color.new(bearCol, 20)) : valBg
    stopTxt = tSL == tEntry ? " · stop at BE" : tSL == tT1 ? " · stop at TP1" : isTrail and tStage == 2 ? " · trailing" : ""
    hitTxt  = inTrade ? (tStage == 0 ? "None yet" : (tStage == 1 ? "TP1 ✅" : "TP2 ✅") + stopTxt) : lastExit
    eqTxt   = na(dMid) ? "-" : close > dMid ? "Premium" : "Discount"
    winRate = totTrades > 0 ? totWins * 100.0 / totTrades : 0.0
    avgR    = totTrades > 0 ? totR / totTrades : 0.0
    regRule = regimeMode == "Off" ? "all trades" : regUp ? "longs only" : regDn ? "shorts only" : "CRT both ways, no ORB"
    regBg   = regUp ? color.new(bullCol, 20) : regDn ? color.new(bearCol, 20) : valBg

    table.cell(panel, 0, 0, "📊 Panel", text_color = color.white, bgcolor = hdrBg, text_size = size.small)
    table.cell(panel, 1, 0, "MGC CRT + ORB", text_color = color.white, bgcolor = hdrBg, text_size = size.small)
    cell(1,  "Trend:", trendUp ? "📈 Bullish" : "📉 Bearish", trendUp ? color.new(bullCol, 20) : color.new(bearCol, 20), color.white)
    cell(2,  "Regime:", regTxt + " · " + regRule, regBg, color.white)
    cell(3,  "Signal:", sigTxt, sigBg, color.white)
    cell(4,  "Model:", inTrade ? tModel : "Last: " + tModel, valBg, color.white)
    cell(5,  "Entry / SL:", na(tEntry) ? "-" : "🔵 " + px(tEntry) + "  🔴 " + px(tSL0), valBg, color.white)
    cell(6,  "TP1 / TP2 / TP3:", na(tT1) ? "-" : px(tT1) + " / " + px(tT2) + " / " + px(tT3), valBg, bullCol)
    cell(7,  "TP Hits:", hitTxt, valBg, color.white)
    cell(8,  "Daily 50%:", eqTxt, valBg, eqTxt == "Premium" ? bearCol : bullCol)
    cell(9,  "Today:", str.tostring(tradesToday) + " trades  " + sgn(dayR) + "R", valBg, dayR >= 0 ? bullCol : bearCol)
    cell(10, "History:", str.tostring(totTrades) + " trades  " + str.tostring(winRate, "#") + "%  " + sgn(totR) + "R", valBg, totR >= 0 ? bullCol : bearCol)
    cell(11, "Avg per trade:", sgn(avgR) + "R", valBg, avgR >= 0 ? bullCol : bearCol)

    if showModels
        table.cell(panel, 0, 12, "By model", text_color = color.white, bgcolor = hdrBg, text_size = size.small)
        table.cell(panel, 1, 12, "trades · win · net R", text_color = color.white, bgcolor = hdrBg, text_size = size.small)
        for i = 0 to 4
            n   = array.get(mTr, i)
            w   = n > 0 ? array.get(mWin, i) * 100.0 / n : 0.0
            net = array.get(mNet, i)
            isOn = i == 0 ? useD : i == 1 ? use4 : i == 2 ? use89 : i == 3 ? use1H : useOrb
            txt  = n == 0 ? (isOn ? "no trades yet" : "off") : str.tostring(n) + " · " + str.tostring(w, "#") + "% · " + sgn(net) + "R"
            cell(13 + i, mName(i) + ":", txt, valBg, n == 0 ? color.gray : net >= 0 ? bullCol : bearCol)

// ---------- Alerts ----------
// Simplest setup: one alert on this indicator with condition "Any alert() function call"
// (entry with SL/TPs, TP1, TP2, stop moves, exit). The conditions below are for separate alerts.
alertcondition(entered and tDir == 1,  "MGC Buy",  "MGC CRT/ORB: BUY")
alertcondition(entered and tDir == -1, "MGC Sell", "MGC CRT/ORB: SELL")
alertcondition(tp1Now, "MGC TP1 hit", "MGC CRT/ORB: TP1 hit")
alertcondition(tp2Now, "MGC TP2 hit", "MGC CRT/ORB: TP2 hit")
alertcondition(closedNow, "MGC Trade Closed", "MGC CRT/ORB: trade closed")
````
