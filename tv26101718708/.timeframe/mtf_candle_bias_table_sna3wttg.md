# MTF Candle Bias Table

- url: https://www.tradingview.com/script/sNA3wTTg-MTF-Candle-Bias-Table/
- type: indicator
- pine_id: PUB;2e32d97b3b5d46c494762279047e2ac1
- version: 2.0

## Description

MTF Candle Bias Table
Brought to my attention by Max Algo — credit and appreciation to them for sharing this.

A clean, at-a-glance multi-timeframe dashboard that tells you where price is biased across up to 7 timeframes simultaneously — no more flipping between charts.
What it shows:
For each timeframe you choose, the table displays:

Candle — whether the current candle is bullish or bearish (close vs. open)
Bias — directional bias based on whether price has breached the prior bar's high or low
Trend — whether price is trading above or below a configurable EMA (default 50)
Hold/Fade — whether price is holding the bias level or fading it
Score — a confluence score (0–3) combining candle, trend, and hold alignment
Accuracy % — a rolling back-tested accuracy rate showing how often the bias predicted the next candle's direction correctly, over a selectable lookback period (1 day to 1 month)

A Bias Score row at the bottom gives you an instant bull vs. bear count across all visible timeframes, color-coded green or red based on overall market lean.
A session label (NY Open, Midday, PM Close, Globex, Overnight) keeps you oriented in the trading day at all times.
Customization:

Enable/disable any of the 7 timeframes individually
Toggle columns on/off (Trend, Hold, Score, Accuracy)
Vertical or Horizontal table layout
Symbols-only mode for a more compact view
Full color and position control

Great for confluence-based trading — use it to quickly confirm whether multiple timeframes agree before entering a trade.

Here's a breakdown of each feature straight from the logic in the code:

TREND
The trend column compares the current closing price to an EMA (default 50, but you can change the length). If close is above the EMA, it shows "↑ ABOVE" (bullish). If close is below the EMA, it shows "↓ BELOW" (bearish). This is calculated on each timeframe independently, so your 1m and 1D can show completely different trend readings. It's essentially asking: is price on the right side of the moving average on this timeframe?

HOLD vs. FADE
This column is tied directly to the Bias. Once a bias is established (bull or bear), Hold/Fade tells you whether price is respecting that bias level or failing it.

If the bias is bullish (price broke the prior bar's high), Hold checks whether the current close is still above that prior bar's high. If yes → ✓ HOLD. If not → ✗ FADE.
If the bias is bearish (price broke the prior bar's low), it checks whether the current close is still below that prior bar's low. If yes → ✓ HOLD. If not → ✗ FADE.
If there's no bias (neutral), it just shows a dash.

Think of it as a confidence check — a bias that's holding is stronger than one that's already fading.

SCORE (0–3)
The score is a simple confluence counter that adds up how many things are aligned with the bias. It scores a point for each of the following:

Candle agrees with bias — the current candle is bullish and bias is bullish, or both bearish
Trend agrees with bias — price is on the correct side of the EMA relative to the bias direction
Hold is active — price is holding the bias level (not fading)

So a score of 3/3 means everything is aligned: the bias is set, the candle confirms it, the trend supports it, and price is holding the level. A score of 0 or a dash means the bias exists but nothing else is confirming it. Neutral biases always show a dash regardless.

ACCURACY %
This is the most unique feature. It tracks, historically, how often the bias on each timeframe correctly predicted the direction of the next completed candle. Here's how it works:

Each time a new bar closes on a given timeframe, the indicator looks back at what the bias signal was on the previous completed bar
It then checks whether that bias was correct — did a bullish bias lead to a bullish close? Did a bearish bias lead to a bearish close?
It keeps a rolling log of those results (1 = correct, 0 = wrong) and calculates the percentage of correct predictions
The lookback window is controlled by your Accuracy Period setting (1 Day, 3 Days, 1 Week, 2 Weeks, or 1 Month), and it automatically scales the number of bars based on the timeframe

The color coding gives you a quick read:

🟢 Green (60%+) — the bias signal has been reliably predictive
🟡 Yellow (50–59%) — marginally better than a coin flip
🔴 Red (below 50%) — the signal has been more wrong than right recently

This helps you know which timeframes are currently giving trustworthy signals and which ones to treat with skepticism.

## Source Code

````pine
//@version=6
indicator("MTF Candle Bias Table", overlay=true, max_bars_back=5000)

// ─────────────────────────────────────────────
//  TIMEFRAME INPUTS
// ─────────────────────────────────────────────
var string GRP_TF = "Timeframes"
show1 = input.bool(true, "Show TF 1", inline="tf1", group=GRP_TF)
tf1   = input.timeframe("1",   "", inline="tf1", group=GRP_TF)
show2 = input.bool(true, "Show TF 2", inline="tf2", group=GRP_TF)
tf2   = input.timeframe("5",   "", inline="tf2", group=GRP_TF)
show3 = input.bool(true, "Show TF 3", inline="tf3", group=GRP_TF)
tf3   = input.timeframe("15",  "", inline="tf3", group=GRP_TF)
show4 = input.bool(true, "Show TF 4", inline="tf4", group=GRP_TF)
tf4   = input.timeframe("60",  "", inline="tf4", group=GRP_TF)
show5 = input.bool(true, "Show TF 5", inline="tf5", group=GRP_TF)
tf5   = input.timeframe("240", "", inline="tf5", group=GRP_TF)
show6 = input.bool(true, "Show TF 6", inline="tf6", group=GRP_TF)
tf6   = input.timeframe("D",   "", inline="tf6", group=GRP_TF)
show7 = input.bool(true, "Show TF 7", inline="tf7", group=GRP_TF)
tf7   = input.timeframe("W",   "", inline="tf7", group=GRP_TF)

// ─────────────────────────────────────────────
//  EMA
// ─────────────────────────────────────────────
var string GRP_EMA = "EMA Trend Filter"
emaLen = input.int(50, "EMA Length", minval=1, group=GRP_EMA)

// ─────────────────────────────────────────────
//  DISPLAY INPUTS
// ─────────────────────────────────────────────
var string GRP_D = "Display"
tablePos     = input.string("Top Right", "Table Position", options=["Top Right","Top Left","Bottom Right","Bottom Left","Top Center","Bottom Center"], group=GRP_D)
tableSz      = input.string("Small",     "Table Size",     options=["Tiny","Small","Normal","Large","Huge"], group=GRP_D)
layout       = input.string("Vertical",  "Layout",         options=["Vertical","Horizontal"], group=GRP_D)
symbolsOnly  = input.bool(false, "Symbols only (no words)", group=GRP_D)
tableBgColor = input.color(color.new(#0D0D0D, 20), "Table Background",    group=GRP_D)
tableHdrBg   = input.color(color.new(#1A237E,  0), "Header Background",   group=GRP_D)
tableHdrText = input.color(color.new(#E8EAF6,  0), "Header Text",         group=GRP_D)
tableTfBg    = input.color(color.new(#1C2833,  0), "TF Label Background", group=GRP_D)
tableTfText  = input.color(color.new(#B0BEC5,  0), "TF Label Text",       group=GRP_D)

var string GRP_C = "Columns"
showTrend    = input.bool(true, "Show Trend",          group=GRP_C)
showHold     = input.bool(true, "Show Hold",           group=GRP_C)
showColScore = input.bool(true, "Show Score",          group=GRP_C)
showAccuracy = input.bool(true, "Show Accuracy %",     group=GRP_C)
showNeutral  = input.bool(true, "Show Neutral",        group=GRP_C)
showScore    = input.bool(true, "Show Bias Score row", group=GRP_C)

var string GRP_A = "Accuracy Settings"
accPeriod = input.string("1 Week", "Accuracy Period", options=["1 Day","3 Days","1 Week","2 Weeks","1 Month"], group=GRP_A)

// ─────────────────────────────────────────────
//  SESSION HOUR ACCURACY INPUTS (8AM-4PM ET)
// ─────────────────────────────────────────────
var string GRP_SA = "8AM-4PM Session Accuracy (1H)"
showSessAcc = input.bool(true, "Show Session Accuracy Table", group=GRP_SA)
sessAccPos  = input.string("Bottom Left", "Session Table Position",
              options=["Top Right","Top Left","Bottom Right","Bottom Left","Top Center","Bottom Center"], group=GRP_SA)
edgeThresh  = input.float(5.0, "Edge Threshold %", minval=0.0, maxval=20.0, step=1.0, group=GRP_SA,
              tooltip="Min % difference between Bull and Bear accuracy to show a directional edge.")

// ─────────────────────────────────────────────
//  KEY LEVELS & VWAP INPUTS
// ─────────────────────────────────────────────
var string GRP_KL = "Key Levels and VWAP"
showVwapCol   = input.bool(true,  "Show VWAP Column in Main Table",  group=GRP_KL)
showKeyLevels = input.bool(true,  "Show Key Levels Table",           group=GRP_KL)
klPos         = input.string("Bottom Right", "Key Levels Table Position",
                options=["Top Right","Top Left","Bottom Right","Bottom Left","Top Center","Bottom Center"], group=GRP_KL)
proximityPct  = input.float(0.25, "Proximity Alert %", minval=0.05, maxval=2.0, step=0.05, group=GRP_KL,
                tooltip="Warn when price is within this % of PDH, PDL, PDMid, PWH, or PWL.")
showPDLines   = input.bool(true,  "Plot Prior Day H/L/Mid Lines",    group=GRP_KL)
showPWLines   = input.bool(false, "Plot Prior Week H/L Lines",       group=GRP_KL)

// ─────────────────────────────────────────────
//  ACCURACY PERIOD -> DAYS
// ─────────────────────────────────────────────
accDays = switch accPeriod
    "1 Day"   => 1
    "3 Days"  => 3
    "1 Week"  => 7
    "2 Weeks" => 14
    "1 Month" => 30
    => 7

// ─────────────────────────────────────────────
//  BARS PER DAY PER TF
// ─────────────────────────────────────────────
barsPerDay(simple string tf) =>
    switch tf
        "1"   => 1380
        "2"   => 690
        "3"   => 460
        "5"   => 276
        "10"  => 138
        "15"  => 92
        "30"  => 46
        "45"  => 30
        "60"  => 23
        "120" => 11
        "180" => 7
        "240" => 5
        "360" => 3
        "480" => 2
        "720" => 1
        "D"   => 1
        "W"   => 1
        "M"   => 1
        => 23

maxSig(simple string tf) =>
    math.min(2000, math.max(5, accDays * barsPerDay(tf)))

// ─────────────────────────────────────────────
//  TEXT SIZE
// ─────────────────────────────────────────────
txtSize = switch tableSz
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    "Huge"   => size.huge
    => size.small

// ─────────────────────────────────────────────
//  COLORS
// ─────────────────────────────────────────────
C_BULL_BG         = color.new(#00C853, 0)
C_BEAR_BG         = color.new(#D50000, 0)
C_NEUT_BG         = color.new(#455A64, 0)
C_BULL_TEXT       = color.new(#E8F5E9, 0)
C_BEAR_TEXT       = color.new(#FFEBEE, 0)
C_NEUT_TEXT       = color.new(#ECEFF1, 0)
C_CBULL_BG        = color.new(#1B5E20, 0)
C_CBEAR_BG        = color.new(#7B1414, 0)
C_CBULL_TEXT      = color.new(#A5D6A7, 0)
C_CBEAR_TEXT      = color.new(#EF9A9A, 0)
C_TREND_BULL_BG   = color.new(#004D40, 0)
C_TREND_BEAR_BG   = color.new(#4A0000, 0)
C_TREND_BULL_TEXT = color.new(#80CBC4, 0)
C_TREND_BEAR_TEXT = color.new(#FF8A80, 0)
C_HOLD_YES_BG     = color.new(#0D47A1, 0)
C_HOLD_YES_TEXT   = color.new(#BBDEFB, 0)
C_HOLD_FADE_BG    = color.new(#E65100, 0)
C_HOLD_FADE_TEXT  = color.new(#FFF3E0, 0)
C_HOLD_NA_BG      = color.new(#263238, 0)
C_HOLD_NA_TEXT    = color.new(#607D8B, 0)
C_S3_BG           = color.new(#00E676, 0)
C_S3_TEXT         = color.new(#003300, 0)
C_S2_BG           = color.new(#FFD600, 0)
C_S2_TEXT         = color.new(#332900, 0)
C_S1_BG           = color.new(#FF6D00, 0)
C_S1_TEXT         = color.new(#FFF8F0, 0)
C_S0_BG           = color.new(#263238, 0)
C_S0_TEXT         = color.new(#78909C, 0)
C_HEADER_BG       = tableHdrBg
C_HEADER_TXT      = tableHdrText
C_SCORE_BG        = color.new(#212121, 0)
C_SCORE_TXT       = color.new(#CFD8DC, 0)
C_TF_BG           = tableTfBg
C_TF_TEXT         = tableTfText
C_SESS_BG         = color.new(#0D1117, 0)
C_VWAP_ABOVE_BG   = color.new(#00695C, 0)
C_VWAP_ABOVE_TEXT = color.new(#80CBC4, 0)
C_VWAP_BELOW_BG   = color.new(#4A148C, 0)
C_VWAP_BELOW_TEXT = color.new(#CE93D8, 0)
C_KL_NEAR_BG      = color.new(#E65100, 0)
C_KL_NEAR_TEXT    = color.new(#FFF3E0, 0)
C_KL_WATCH_BG     = color.new(#F9A825, 0)
C_KL_WATCH_TEXT   = color.new(#1A1200, 0)
C_KL_CLEAR_BG     = color.new(#1B5E20, 0)
C_KL_CLEAR_TEXT   = color.new(#A5D6A7, 0)
C_KL_PRICE_BG     = color.new(#0D1117, 0)
C_KL_PRICE_TEXT   = color.new(#CFD8DC, 0)

// ─────────────────────────────────────────────
//  TF LABEL
// ─────────────────────────────────────────────
tfLabel(tf) =>
    switch tf
        "1"   => "1m"
        "3"   => "3m"
        "5"   => "5m"
        "10"  => "10m"
        "15"  => "15m"
        "30"  => "30m"
        "45"  => "45m"
        "60"  => "1H"
        "120" => "2H"
        "180" => "3H"
        "240" => "4H"
        "360" => "6H"
        "480" => "8H"
        "720" => "12H"
        "D"   => "1D"
        "W"   => "1W"
        "M"   => "1M"
        => tf

// ─────────────────────────────────────────────
//  LIVE DATA FUNCTION
//  Now also returns the TF close for VWAP comparison
// ─────────────────────────────────────────────
getData(simple string tf, simple int emaLength) =>
    [ph, pl, ch, cl, co, cc, ev] = request.security(
         syminfo.tickerid, tf,
         [high[1], low[1], high, low, open, close, ta.ema(close, emaLength)],
         barmerge.gaps_off, barmerge.lookahead_on)
    breachHigh = ch > ph
    breachLow  = cl < pl
    bias = 0
    if breachHigh and not breachLow
        bias := 1
    else if breachLow and not breachHigh
        bias := -1
    candle = cc >= co ? 1 : -1
    trend  = cc >= ev ? 1 : -1
    hold   = bias == 1 ? cc > ph : bias == -1 ? cc < pl : false
    [bias, candle, trend, hold, cc]

// ─────────────────────────────────────────────
//  ACCURACY DATA FUNCTION
// ─────────────────────────────────────────────
getAccuracyData(simple string tf) =>
    [ph2, pl2, ph1, pl1, co1, cc1] = request.security(
         syminfo.tickerid, tf,
         [high[2], low[2], high[1], low[1], open[1], close[1]],
         barmerge.gaps_off, barmerge.lookahead_on)
    valid    = not na(ph2) and not na(pl2) and not na(ph1) and not na(pl1)
    bHigh    = valid and ph1 > ph2
    bLow     = valid and pl1 < pl2
    prevBias = 0
    if bHigh and not bLow
        prevBias := 1
    else if bLow and not bHigh
        prevBias := -1
    bullClose = not na(cc1) and not na(co1) and cc1 >= co1
    isCorrect = prevBias != 0 and ((prevBias == 1 and bullClose) or (prevBias == -1 and not bullClose))
    [prevBias, isCorrect]

// ─────────────────────────────────────────────
//  KEY LEVELS & VWAP
// ─────────────────────────────────────────────
vwapVal = ta.vwap(hlc3)

pdHigh = request.security(syminfo.tickerid, "D", high[1], barmerge.gaps_off, barmerge.lookahead_on)
pdLow  = request.security(syminfo.tickerid, "D", low[1],  barmerge.gaps_off, barmerge.lookahead_on)
pdMid  = (pdHigh + pdLow) / 2.0
pwHigh = request.security(syminfo.tickerid, "W", high[1], barmerge.gaps_off, barmerge.lookahead_on)
pwLow  = request.security(syminfo.tickerid, "W", low[1],  barmerge.gaps_off, barmerge.lookahead_on)

// Distance % from current close to a level (positive = price is above the level)
distPct(level) =>
    not na(level) and level != 0 ? (close - level) / level * 100.0 : float(na)

// 2 = at/very near (<=half threshold), 1 = approaching (<=threshold), 0 = clear
proxStatus(dist) =>
    if na(dist)
        -1
    else
        absDist = math.abs(dist)
        if absDist <= proximityPct * 0.5
            2
        else if absDist <= proximityPct
            1
        else
            0

proxBg(status) =>
    status == 2 ? C_KL_NEAR_BG : status == 1 ? C_KL_WATCH_BG : C_KL_CLEAR_BG

proxTxt(status) =>
    status == 2 ? C_KL_NEAR_TEXT : status == 1 ? C_KL_WATCH_TEXT : C_KL_CLEAR_TEXT

proxLabel(dist, status) =>
    if na(dist) or status == -1
        "—"
    else
        prefix = dist >= 0 ? "+" : ""
        str.tostring(dist, prefix + "#.##") + "%"

// ─────────────────────────────────────────────
//  PLOT KEY LEVEL LINES ON CHART
// ─────────────────────────────────────────────
plot(showPDLines ? pdHigh : na, "PDH", color=color.new(#EF5350, 55), linewidth=1, style=plot.style_line)
plot(showPDLines ? pdLow  : na, "PDL", color=color.new(#66BB6A, 55), linewidth=1, style=plot.style_line)
plot(showPDLines ? pdMid  : na, "PDM", color=color.new(#78909C, 65), linewidth=1, style=plot.style_stepline)
plot(showPWLines ? pwHigh : na, "PWH", color=color.new(#EF9A9A, 45), linewidth=2, style=plot.style_line)
plot(showPWLines ? pwLow  : na, "PWL", color=color.new(#A5D6A7, 45), linewidth=2, style=plot.style_line)

// ─────────────────────────────────────────────
//  COMPUTE LIVE DATA
// ─────────────────────────────────────────────
[b1, c1, tr1, h1, cc1] = getData(tf1, emaLen)
[b2, c2, tr2, h2, cc2] = getData(tf2, emaLen)
[b3, c3, tr3, h3, cc3] = getData(tf3, emaLen)
[b4, c4, tr4, h4, cc4] = getData(tf4, emaLen)
[b5, c5, tr5, h5, cc5] = getData(tf5, emaLen)
[b6, c6, tr6, h6, cc6] = getData(tf6, emaLen)
[b7, c7, tr7, h7, cc7] = getData(tf7, emaLen)

// VWAP bias per TF: is that TF's close above or below session VWAP?
vw1 = not na(cc1) and not na(vwapVal) ? (cc1 >= vwapVal ? 1 : -1) : 0
vw2 = not na(cc2) and not na(vwapVal) ? (cc2 >= vwapVal ? 1 : -1) : 0
vw3 = not na(cc3) and not na(vwapVal) ? (cc3 >= vwapVal ? 1 : -1) : 0
vw4 = not na(cc4) and not na(vwapVal) ? (cc4 >= vwapVal ? 1 : -1) : 0
vw5 = not na(cc5) and not na(vwapVal) ? (cc5 >= vwapVal ? 1 : -1) : 0
vw6 = not na(cc6) and not na(vwapVal) ? (cc6 >= vwapVal ? 1 : -1) : 0
vw7 = not na(cc7) and not na(vwapVal) ? (cc7 >= vwapVal ? 1 : -1) : 0

// ─────────────────────────────────────────────
//  DETECT NEW COMPLETED HTF BAR
// ─────────────────────────────────────────────
newBar1 = ta.change(time(tf1)) > 0
newBar2 = ta.change(time(tf2)) > 0
newBar3 = ta.change(time(tf3)) > 0
newBar4 = ta.change(time(tf4)) > 0
newBar5 = ta.change(time(tf5)) > 0
newBar6 = ta.change(time(tf6)) > 0
newBar7 = ta.change(time(tf7)) > 0

// ─────────────────────────────────────────────
//  ACCURACY DATA FOR COMPLETED BARS
// ─────────────────────────────────────────────
[pb1, cor1] = getAccuracyData(tf1)
[pb2, cor2] = getAccuracyData(tf2)
[pb3, cor3] = getAccuracyData(tf3)
[pb4, cor4] = getAccuracyData(tf4)
[pb5, cor5] = getAccuracyData(tf5)
[pb6, cor6] = getAccuracyData(tf6)
[pb7, cor7] = getAccuracyData(tf7)

// ─────────────────────────────────────────────
//  ROLLING ACCURACY ARRAYS
// ─────────────────────────────────────────────
var array<int> acc1 = array.new<int>()
var array<int> acc2 = array.new<int>()
var array<int> acc3 = array.new<int>()
var array<int> acc4 = array.new<int>()
var array<int> acc5 = array.new<int>()
var array<int> acc6 = array.new<int>()
var array<int> acc7 = array.new<int>()

maxSig1 = maxSig(tf1)
maxSig2 = maxSig(tf2)
maxSig3 = maxSig(tf3)
maxSig4 = maxSig(tf4)
maxSig5 = maxSig(tf5)
maxSig6 = maxSig(tf6)
maxSig7 = maxSig(tf7)

if newBar1 and pb1 != 0
    array.push(acc1, cor1 ? 1 : 0)
    if array.size(acc1) > maxSig1
        array.shift(acc1)
if newBar2 and pb2 != 0
    array.push(acc2, cor2 ? 1 : 0)
    if array.size(acc2) > maxSig2
        array.shift(acc2)
if newBar3 and pb3 != 0
    array.push(acc3, cor3 ? 1 : 0)
    if array.size(acc3) > maxSig3
        array.shift(acc3)
if newBar4 and pb4 != 0
    array.push(acc4, cor4 ? 1 : 0)
    if array.size(acc4) > maxSig4
        array.shift(acc4)
if newBar5 and pb5 != 0
    array.push(acc5, cor5 ? 1 : 0)
    if array.size(acc5) > maxSig5
        array.shift(acc5)
if newBar6 and pb6 != 0
    array.push(acc6, cor6 ? 1 : 0)
    if array.size(acc6) > maxSig6
        array.shift(acc6)
if newBar7 and pb7 != 0
    array.push(acc7, cor7 ? 1 : 0)
    if array.size(acc7) > maxSig7
        array.shift(acc7)

// ─────────────────────────────────────────────
//  ACCURACY CALCULATION
// ─────────────────────────────────────────────
calcAcc(arr) =>
    n = array.size(arr)
    if n == 0
        float(na)
    else
        s = 0
        for k = 0 to n - 1
            s += array.get(arr, k)
        float(s) / float(n) * 100.0

pct1 = calcAcc(acc1)
pct2 = calcAcc(acc2)
pct3 = calcAcc(acc3)
pct4 = calcAcc(acc4)
pct5 = calcAcc(acc5)
pct6 = calcAcc(acc6)
pct7 = calcAcc(acc7)

// ─────────────────────────────────────────────
//  SESSION HOUR ACCURACY (8AM-4PM ET, 1H)
//  Index: 0=8AM 1=9AM 2=10AM 3=11AM
//         4=12PM 5=1PM 6=2PM 7=3PM
// ─────────────────────────────────────────────
[sa_ph2, sa_pl2, sa_ph1, sa_pl1, sa_co1, sa_cc1, sa_bartime] = request.security(
    syminfo.tickerid, "60",
    [high[2], low[2], high[1], low[1], open[1], close[1], time[1]],
    barmerge.gaps_off, barmerge.lookahead_on)

newHourBar   = ta.change(time("60")) > 0
sa_hr        = hour(sa_bartime, "America/New_York")
sa_valid     = not na(sa_ph2) and not na(sa_pl2) and not na(sa_ph1) and not na(sa_pl1)
sa_bHigh     = sa_valid and sa_ph1 > sa_ph2
sa_bLow      = sa_valid and sa_pl1 < sa_pl2
sa_bias      = 0
if sa_bHigh and not sa_bLow
    sa_bias := 1
else if sa_bLow and not sa_bHigh
    sa_bias := -1
sa_bullClose = not na(sa_cc1) and not na(sa_co1) and sa_cc1 >= sa_co1
sa_correct   = sa_bias != 0 and ((sa_bias == 1 and sa_bullClose) or (sa_bias == -1 and not sa_bullClose))
sa_inWindow  = not na(sa_hr) and sa_hr >= 8 and sa_hr <= 15

var int[] sa_bull_tot = array.new<int>(8, 0)
var int[] sa_bull_cor = array.new<int>(8, 0)
var int[] sa_bear_tot = array.new<int>(8, 0)
var int[] sa_bear_cor = array.new<int>(8, 0)

if newHourBar and sa_bias != 0 and sa_inWindow
    idx = sa_hr - 8
    if idx >= 0 and idx <= 7
        if sa_bias == 1
            array.set(sa_bull_tot, idx, array.get(sa_bull_tot, idx) + 1)
            if sa_correct
                array.set(sa_bull_cor, idx, array.get(sa_bull_cor, idx) + 1)
        else
            array.set(sa_bear_tot, idx, array.get(sa_bear_tot, idx) + 1)
            if sa_correct
                array.set(sa_bear_cor, idx, array.get(sa_bear_cor, idx) + 1)

// ─────────────────────────────────────────────
//  ARRAYS FOR DRAW LOOP
// ─────────────────────────────────────────────
tfs     = array.from(tf1,   tf2,   tf3,   tf4,   tf5,   tf6,   tf7)
shows   = array.from(show1, show2, show3, show4, show5, show6, show7)
biases  = array.from(b1,    b2,    b3,    b4,    b5,    b6,    b7)
candles = array.from(c1,    c2,    c3,    c4,    c5,    c6,    c7)
trends  = array.from(tr1,   tr2,   tr3,   tr4,   tr5,   tr6,   tr7)
holds   = array.from(h1,    h2,    h3,    h4,    h5,    h6,    h7)
vwaps   = array.from(vw1,   vw2,   vw3,   vw4,   vw5,   vw6,   vw7)
pcts    = array.from(pct1,  pct2,  pct3,  pct4,  pct5,  pct6,  pct7)
sizes   = array.from(array.size(acc1), array.size(acc2), array.size(acc3),
          array.size(acc4), array.size(acc5), array.size(acc6), array.size(acc7))

// ─────────────────────────────────────────────
//  VISIBLE TF COUNT & BIAS SCORE
// ─────────────────────────────────────────────
visibleCount = 0
bullCount    = 0
bearCount    = 0
for i = 0 to 6
    if array.get(shows, i)
        visibleCount += 1
        v = array.get(biases, i)
        if v == 1
            bullCount += 1
        else if v == -1
            bearCount += 1

// ─────────────────────────────────────────────
//  CONFLUENCE SCORE
// ─────────────────────────────────────────────
getScore(bias, candle, trend, hold) =>
    if bias == 0
        -1
    else
        s = 0
        if (bias == 1 and candle == 1) or (bias == -1 and candle == -1)
            s += 1
        if (bias == 1 and trend == 1) or (bias == -1 and trend == -1)
            s += 1
        if hold
            s += 1
        s

// ─────────────────────────────────────────────
//  SESSION DETECTION
// ─────────────────────────────────────────────
etTime = hour(time, "America/New_York") * 100 + minute(time, "America/New_York")
var string sessLabel = "OVERNIGHT"
var color  sessColor = color.new(#546E7A, 0)
if etTime >= 930 and etTime < 1100
    sessLabel := symbolsOnly ? "★" : "★ NY OPEN"
    sessColor := color.new(#FFD600, 0)
else if etTime >= 1500 and etTime < 1600
    sessLabel := symbolsOnly ? "▣" : "PM CLOSE"
    sessColor := color.new(#FF7043, 0)
else if etTime >= 1100 and etTime < 1500
    sessLabel := symbolsOnly ? "◈" : "NY MIDDAY"
    sessColor := color.new(#42A5F5, 0)
else if etTime >= 600 and etTime < 930
    sessLabel := symbolsOnly ? "◌" : "GLOBEX"
    sessColor := color.new(#78909C, 0)
else
    sessLabel := symbolsOnly ? "◯" : "OVERNIGHT"
    sessColor := color.new(#546E7A, 0)

// ─────────────────────────────────────────────
//  TABLE POSITION
// ─────────────────────────────────────────────
pos = switch tablePos
    "Top Right"     => position.top_right
    "Top Left"      => position.top_left
    "Bottom Right"  => position.bottom_right
    "Bottom Left"   => position.bottom_left
    "Top Center"    => position.top_center
    "Bottom Center" => position.bottom_center
    => position.top_right

// ─────────────────────────────────────────────
//  LABEL / COLOR HELPERS
// ─────────────────────────────────────────────
biasLabel(b) =>
    if symbolsOnly
        b == 1 ? "▲" : b == -1 ? "▼" : "●"
    else
        b == 1 ? "▲ BULL" : b == -1 ? "▼ BEAR" : showNeutral ? "● NEUT" : "—"
biasColor(b) =>
    b == 1 ? C_BULL_BG : b == -1 ? C_BEAR_BG : C_NEUT_BG
biasTextColor(b) =>
    b == 1 ? C_BULL_TEXT : b == -1 ? C_BEAR_TEXT : C_NEUT_TEXT
candleLabel(c) =>
    symbolsOnly ? (c == 1 ? "▲" : "▼") : (c == 1 ? "▲ BULL" : "▼ BEAR")
candleColor(c) =>
    c == 1 ? C_CBULL_BG : C_CBEAR_BG
candleTextColor(c) =>
    c == 1 ? C_CBULL_TEXT : C_CBEAR_TEXT
trendLabel(tr) =>
    symbolsOnly ? (tr == 1 ? "↑" : "↓") : (tr == 1 ? "↑ ABOVE" : "↓ BELOW")
trendColor(tr) =>
    tr == 1 ? C_TREND_BULL_BG : C_TREND_BEAR_BG
trendTextColor(tr) =>
    tr == 1 ? C_TREND_BULL_TEXT : C_TREND_BEAR_TEXT
holdLabel(h, b) =>
    if symbolsOnly
        b == 0 ? "—" : h ? "✓" : "✗"
    else
        b == 0 ? "—" : h ? "✓ HOLD" : "✗ FADE"
holdBg(h, b) =>
    b == 0 ? C_HOLD_NA_BG : h ? C_HOLD_YES_BG : C_HOLD_FADE_BG
holdTxt(h, b) =>
    b == 0 ? C_HOLD_NA_TEXT : h ? C_HOLD_YES_TEXT : C_HOLD_FADE_TEXT
vwapLabel(vw) =>
    symbolsOnly ? (vw == 1 ? "↑" : vw == -1 ? "↓" : "—") : (vw == 1 ? "↑ ABOVE" : vw == -1 ? "↓ BELOW" : "—")
vwapBg(vw) =>
    vw == 1 ? C_VWAP_ABOVE_BG : vw == -1 ? C_VWAP_BELOW_BG : C_HOLD_NA_BG
vwapTxt(vw) =>
    vw == 1 ? C_VWAP_ABOVE_TEXT : vw == -1 ? C_VWAP_BELOW_TEXT : C_HOLD_NA_TEXT
scoreLabel(s) =>
    if symbolsOnly
        s == 3 ? "●●●" : s == 2 ? "●●" : s == 1 ? "●" : "—"
    else
        s == -1 ? "—" : str.tostring(s) + " / 3"
scoreBg(s) =>
    s == 3 ? C_S3_BG : s == 2 ? C_S2_BG : s == 1 ? C_S1_BG : C_S0_BG
scoreTxt(s) =>
    s == 3 ? C_S3_TEXT : s == 2 ? C_S2_TEXT : s == 1 ? C_S1_TEXT : C_S0_TEXT
accLabel(pct, n) =>
    if na(pct) or n == 0
        "—"
    else
        str.tostring(math.round(pct)) + "%\nn=" + str.tostring(n)
accLabelH(pct, n) =>
    na(pct) or n == 0 ? "—" : str.tostring(math.round(pct)) + "% n=" + str.tostring(n)
accBg(pct) =>
    if na(pct)
        color.new(#263238, 0)
    else if pct >= 60.0
        color.new(#1B5E20, 0)
    else if pct >= 50.0
        color.new(#3E2723, 0)
    else
        color.new(#7B1414, 0)
accTxt(pct) =>
    if na(pct)
        color.new(#607D8B, 0)
    else if pct >= 60.0
        color.new(#A5D6A7, 0)
    else if pct >= 50.0
        color.new(#FFD54F, 0)
    else
        color.new(#EF9A9A, 0)
accHdr = symbolsOnly ? "%" : "ACC " + accPeriod

// ─────────────────────────────────────────────
//  SCORE STRING & OVERALL BG
// ─────────────────────────────────────────────
scoreStr = symbolsOnly ? "🟢" + str.tostring(bullCount) + " 🔴" + str.tostring(bearCount) : "🟢 " + str.tostring(bullCount) + "  /  🔴 " + str.tostring(bearCount)
var color overallBg = color.new(#263238, 0)
if bullCount > bearCount
    overallBg := color.new(#1B5E20, 20)
else if bearCount > bullCount
    overallBg := color.new(#B71C1C, 20)
else
    overallBg := color.new(#263238, 0)

// ─────────────────────────────────────────────
//  TABLE HANDLES
// ─────────────────────────────────────────────
var table t  = na
var table st = na
var table kl = na

// ─────────────────────────────────────────────
//  DRAW TABLES
// ─────────────────────────────────────────────
if barstate.islast or barstate.isrealtime

    if not na(t)
        table.delete(t)
    if not na(st)
        table.delete(st)
    if not na(kl)
        table.delete(kl)

    // ══════════════════════════════════════════
    //  VERTICAL LAYOUT
    // ══════════════════════════════════════════
    if layout == "Vertical"

        vCols = 3 + (showTrend ? 1 : 0) + (showHold ? 1 : 0) + (showVwapCol ? 1 : 0) + (showColScore ? 1 : 0) + (showAccuracy ? 1 : 0)
        vRows = 2 + visibleCount + (showScore ? 1 : 0)

        t := table.new(pos, vCols, vRows, bgcolor=tableBgColor, border_width=1, border_color=color.new(#37474F, 60), frame_color=color.new(#37474F, 30), frame_width=2)

        table.cell(t, 0, 0, symbolsOnly ? "S" : "SESSION", text_color=color.new(#546E7A, 0), bgcolor=C_SESS_BG, text_size=txtSize, text_halign=text.align_center)
        table.cell(t, 1, 0, sessLabel, text_color=sessColor, bgcolor=C_SESS_BG, text_size=txtSize, text_halign=text.align_center)
        table.cell(t, 2, 0, symbolsOnly ? str.tostring(emaLen) : "EMA " + str.tostring(emaLen), text_color=color.new(#7986CB, 0), bgcolor=C_SESS_BG, text_size=txtSize, text_halign=text.align_center)
        for fc = 3 to vCols - 1
            table.cell(t, fc, 0, "", text_color=color.new(#546E7A, 0), bgcolor=C_SESS_BG, text_size=txtSize, text_halign=text.align_center)

        table.cell(t, 0, 1, "TF",                                   text_color=C_HEADER_TXT, bgcolor=C_HEADER_BG, text_size=txtSize, text_halign=text.align_center)
        table.cell(t, 1, 1, symbolsOnly ? "C" : "CANDLE",           text_color=C_HEADER_TXT, bgcolor=C_HEADER_BG, text_size=txtSize, text_halign=text.align_center)
        table.cell(t, 2, 1, symbolsOnly ? "B" : "BIAS",             text_color=C_HEADER_TXT, bgcolor=C_HEADER_BG, text_size=txtSize, text_halign=text.align_center)
        vHdrCol = 3
        if showTrend
            table.cell(t, vHdrCol, 1, symbolsOnly ? "TR" : "TREND", text_color=C_HEADER_TXT, bgcolor=C_HEADER_BG, text_size=txtSize, text_halign=text.align_center)
            vHdrCol += 1
        if showHold
            table.cell(t, vHdrCol, 1, symbolsOnly ? "H" : "HOLD",   text_color=C_HEADER_TXT, bgcolor=C_HEADER_BG, text_size=txtSize, text_halign=text.align_center)
            vHdrCol += 1
        if showVwapCol
            table.cell(t, vHdrCol, 1, "VWAP",                       text_color=C_HEADER_TXT, bgcolor=C_HEADER_BG, text_size=txtSize, text_halign=text.align_center)
            vHdrCol += 1
        if showColScore
            table.cell(t, vHdrCol, 1, symbolsOnly ? "SC" : "SCORE", text_color=C_HEADER_TXT, bgcolor=C_HEADER_BG, text_size=txtSize, text_halign=text.align_center)
            vHdrCol += 1
        if showAccuracy
            table.cell(t, vHdrCol, 1, accHdr,                       text_color=C_HEADER_TXT, bgcolor=C_HEADER_BG, text_size=txtSize, text_halign=text.align_center)

        vRow = 2
        for i = 0 to 6
            if array.get(shows, i)
                tf  = array.get(tfs,     i)
                b   = array.get(biases,  i)
                c   = array.get(candles, i)
                tr  = array.get(trends,  i)
                h   = array.get(holds,   i)
                vw  = array.get(vwaps,   i)
                s   = getScore(b, c, tr, h)
                pct = array.get(pcts,    i)
                n   = array.get(sizes,   i)
                table.cell(t, 0, vRow, tfLabel(tf),    text_color=C_TF_TEXT,         bgcolor=C_TF_BG,       text_size=txtSize, text_halign=text.align_center)
                table.cell(t, 1, vRow, candleLabel(c), text_color=candleTextColor(c), bgcolor=candleColor(c), text_size=txtSize, text_halign=text.align_center)
                table.cell(t, 2, vRow, biasLabel(b),   text_color=biasTextColor(b),   bgcolor=biasColor(b),  text_size=txtSize, text_halign=text.align_center)
                vDataCol = 3
                if showTrend
                    table.cell(t, vDataCol, vRow, trendLabel(tr),  text_color=trendTextColor(tr), bgcolor=trendColor(tr), text_size=txtSize, text_halign=text.align_center)
                    vDataCol += 1
                if showHold
                    table.cell(t, vDataCol, vRow, holdLabel(h, b), text_color=holdTxt(h, b),      bgcolor=holdBg(h, b),  text_size=txtSize, text_halign=text.align_center)
                    vDataCol += 1
                if showVwapCol
                    table.cell(t, vDataCol, vRow, vwapLabel(vw),   text_color=vwapTxt(vw),        bgcolor=vwapBg(vw),    text_size=txtSize, text_halign=text.align_center)
                    vDataCol += 1
                if showColScore
                    table.cell(t, vDataCol, vRow, scoreLabel(s),   text_color=scoreTxt(s),        bgcolor=scoreBg(s),    text_size=txtSize, text_halign=text.align_center)
                    vDataCol += 1
                if showAccuracy
                    table.cell(t, vDataCol, vRow, accLabel(pct, n), text_color=accTxt(pct),       bgcolor=accBg(pct),    text_size=txtSize, text_halign=text.align_center)
                vRow += 1

        if showScore
            vScoreRow = vRows - 1
            table.cell(t, 0, vScoreRow, symbolsOnly ? "B" : "BIAS", text_color=C_SCORE_TXT, bgcolor=C_SCORE_BG, text_size=txtSize, text_halign=text.align_center)
            for sc = 1 to vCols - 2
                table.cell(t, sc, vScoreRow, "", text_color=C_SCORE_TXT, bgcolor=C_SCORE_BG, text_size=txtSize, text_halign=text.align_center)
            table.cell(t, vCols - 1, vScoreRow, scoreStr, text_color=C_SCORE_TXT, bgcolor=overallBg, text_size=txtSize, text_halign=text.align_center)

    // ══════════════════════════════════════════
    //  HORIZONTAL LAYOUT
    // ══════════════════════════════════════════
    else

        hCols = 1 + visibleCount
        hRows = 4 + (showTrend ? 1 : 0) + (showHold ? 1 : 0) + (showVwapCol ? 1 : 0) + (showColScore ? 1 : 0) + (showAccuracy ? 1 : 0) + (showScore ? 1 : 0)

        t := table.new(pos, hCols, hRows, bgcolor=tableBgColor, border_width=1, border_color=color.new(#37474F, 60), frame_color=color.new(#37474F, 30), frame_width=2)

        table.cell(t, 0, 0, symbolsOnly ? str.tostring(emaLen) : "EMA " + str.tostring(emaLen), text_color=color.new(#7986CB, 0), bgcolor=C_SESS_BG, text_size=txtSize, text_halign=text.align_center)
        table.cell(t, 1, 0, sessLabel, text_color=sessColor, bgcolor=C_SESS_BG, text_size=txtSize, text_halign=text.align_center)
        for hsc = 2 to hCols - 1
            table.cell(t, hsc, 0, "", text_color=color.new(#546E7A, 0), bgcolor=C_SESS_BG, text_size=txtSize, text_halign=text.align_center)

        table.cell(t, 0, 1, "", text_color=C_HEADER_TXT, bgcolor=C_HEADER_BG, text_size=txtSize, text_halign=text.align_center)
        hTfCol = 1
        for i = 0 to 6
            if array.get(shows, i)
                table.cell(t, hTfCol, 1, tfLabel(array.get(tfs, i)), text_color=C_TF_TEXT, bgcolor=C_TF_BG, text_size=txtSize, text_halign=text.align_center)
                hTfCol += 1

        table.cell(t, 0, 2, symbolsOnly ? "C" : "CANDLE", text_color=C_HEADER_TXT, bgcolor=C_HEADER_BG, text_size=txtSize, text_halign=text.align_center)
        hTfCol := 1
        for i = 0 to 6
            if array.get(shows, i)
                c = array.get(candles, i)
                table.cell(t, hTfCol, 2, candleLabel(c), text_color=candleTextColor(c), bgcolor=candleColor(c), text_size=txtSize, text_halign=text.align_center)
                hTfCol += 1

        table.cell(t, 0, 3, symbolsOnly ? "B" : "BIAS", text_color=C_HEADER_TXT, bgcolor=C_HEADER_BG, text_size=txtSize, text_halign=text.align_center)
        hTfCol := 1
        for i = 0 to 6
            if array.get(shows, i)
                b = array.get(biases, i)
                table.cell(t, hTfCol, 3, biasLabel(b), text_color=biasTextColor(b), bgcolor=biasColor(b), text_size=txtSize, text_halign=text.align_center)
                hTfCol += 1

        hOptRow = 4
        if showTrend
            table.cell(t, 0, hOptRow, symbolsOnly ? "TR" : "TREND", text_color=C_HEADER_TXT, bgcolor=C_HEADER_BG, text_size=txtSize, text_halign=text.align_center)
            hTfCol := 1
            for i = 0 to 6
                if array.get(shows, i)
                    tr = array.get(trends, i)
                    table.cell(t, hTfCol, hOptRow, trendLabel(tr), text_color=trendTextColor(tr), bgcolor=trendColor(tr), text_size=txtSize, text_halign=text.align_center)
                    hTfCol += 1
            hOptRow += 1
        if showHold
            table.cell(t, 0, hOptRow, symbolsOnly ? "H" : "HOLD", text_color=C_HEADER_TXT, bgcolor=C_HEADER_BG, text_size=txtSize, text_halign=text.align_center)
            hTfCol := 1
            for i = 0 to 6
                if array.get(shows, i)
                    b = array.get(biases, i)
                    h = array.get(holds,  i)
                    table.cell(t, hTfCol, hOptRow, holdLabel(h, b), text_color=holdTxt(h, b), bgcolor=holdBg(h, b), text_size=txtSize, text_halign=text.align_center)
                    hTfCol += 1
            hOptRow += 1
        if showVwapCol
            table.cell(t, 0, hOptRow, "VWAP", text_color=C_HEADER_TXT, bgcolor=C_HEADER_BG, text_size=txtSize, text_halign=text.align_center)
            hTfCol := 1
            for i = 0 to 6
                if array.get(shows, i)
                    vw = array.get(vwaps, i)
                    table.cell(t, hTfCol, hOptRow, vwapLabel(vw), text_color=vwapTxt(vw), bgcolor=vwapBg(vw), text_size=txtSize, text_halign=text.align_center)
                    hTfCol += 1
            hOptRow += 1
        if showColScore
            table.cell(t, 0, hOptRow, symbolsOnly ? "SC" : "SCORE", text_color=C_HEADER_TXT, bgcolor=C_HEADER_BG, text_size=txtSize, text_halign=text.align_center)
            hTfCol := 1
            for i = 0 to 6
                if array.get(shows, i)
                    b  = array.get(biases,  i)
                    c  = array.get(candles, i)
                    tr = array.get(trends,  i)
                    h  = array.get(holds,   i)
                    s  = getScore(b, c, tr, h)
                    table.cell(t, hTfCol, hOptRow, scoreLabel(s), text_color=scoreTxt(s), bgcolor=scoreBg(s), text_size=txtSize, text_halign=text.align_center)
                    hTfCol += 1
            hOptRow += 1
        if showAccuracy
            table.cell(t, 0, hOptRow, accHdr, text_color=C_HEADER_TXT, bgcolor=C_HEADER_BG, text_size=txtSize, text_halign=text.align_center)
            hTfCol := 1
            for i = 0 to 6
                if array.get(shows, i)
                    pct = array.get(pcts, i)
                    table.cell(t, hTfCol, hOptRow, accLabelH(pct, array.get(sizes, i)), text_color=accTxt(pct), bgcolor=accBg(pct), text_size=txtSize, text_halign=text.align_center)
                    hTfCol += 1
            hOptRow += 1
        if showScore
            table.cell(t, 0, hOptRow, symbolsOnly ? "B" : "BIAS", text_color=C_SCORE_TXT, bgcolor=C_SCORE_BG, text_size=txtSize, text_halign=text.align_center)
            table.cell(t, 1, hOptRow, scoreStr, text_color=C_SCORE_TXT, bgcolor=overallBg, text_size=txtSize, text_halign=text.align_center)
            for hsc = 2 to hCols - 1
                table.cell(t, hsc, hOptRow, "", text_color=C_SCORE_TXT, bgcolor=C_SCORE_BG, text_size=txtSize, text_halign=text.align_center)

    // ══════════════════════════════════════════
    //  SESSION ACCURACY TABLE (8AM-4PM ET, 1H)
    //  Rows: 0=title 1=header 2-9=hours 10=total
    //  Cols: HOUR | BULL% | BEAR% | EDGE
    // ══════════════════════════════════════════
    if showSessAcc

        saPos = switch sessAccPos
            "Top Right"     => position.top_right
            "Top Left"      => position.top_left
            "Bottom Right"  => position.bottom_right
            "Bottom Left"   => position.bottom_left
            "Top Center"    => position.top_center
            "Bottom Center" => position.bottom_center
            => position.bottom_left

        st := table.new(saPos, 4, 11, bgcolor=tableBgColor,
             border_width=1, border_color=color.new(#37474F, 60),
             frame_color=color.new(#37474F, 30), frame_width=2)

        table.cell(st, 0, 0, "8AM-4PM ET", text_color=color.new(#7986CB, 0), bgcolor=C_SESS_BG, text_size=txtSize, text_halign=text.align_center)
        table.cell(st, 1, 0, "1H BIAS",    text_color=color.new(#7986CB, 0), bgcolor=C_SESS_BG, text_size=txtSize, text_halign=text.align_center)
        table.cell(st, 2, 0, "ACCURACY",   text_color=color.new(#7986CB, 0), bgcolor=C_SESS_BG, text_size=txtSize, text_halign=text.align_center)
        table.cell(st, 3, 0, "",           text_color=color.new(#7986CB, 0), bgcolor=C_SESS_BG, text_size=txtSize, text_halign=text.align_center)
        table.cell(st, 0, 1, "HOUR",    text_color=C_HEADER_TXT, bgcolor=C_HEADER_BG, text_size=txtSize, text_halign=text.align_center)
        table.cell(st, 1, 1, "🟢 BULL", text_color=C_HEADER_TXT, bgcolor=C_HEADER_BG, text_size=txtSize, text_halign=text.align_center)
        table.cell(st, 2, 1, "🔴 BEAR", text_color=C_HEADER_TXT, bgcolor=C_HEADER_BG, text_size=txtSize, text_halign=text.align_center)
        table.cell(st, 3, 1, "EDGE",    text_color=C_HEADER_TXT, bgcolor=C_HEADER_BG, text_size=txtSize, text_halign=text.align_center)

        hourLabels = array.from("8AM", "9AM", "10AM", "11AM", "12PM", "1PM", "2PM", "3PM")
        tot_bull_total = 0
        tot_bull_cor   = 0
        tot_bear_total = 0
        tot_bear_cor   = 0

        for i = 0 to 7
            bTot = array.get(sa_bull_tot, i)
            bCor = array.get(sa_bull_cor, i)
            rTot = array.get(sa_bear_tot, i)
            rCor = array.get(sa_bear_cor, i)
            tot_bull_total += bTot
            tot_bull_cor   += bCor
            tot_bear_total += rTot
            tot_bear_cor   += rCor
            bullPct = bTot > 0 ? float(bCor) / float(bTot) * 100.0 : float(na)
            bearPct = rTot > 0 ? float(rCor) / float(rTot) * 100.0 : float(na)
            bullStr = na(bullPct) ? "—" : str.tostring(math.round(bullPct)) + "%\nn=" + str.tostring(bTot)
            bearStr = na(bearPct) ? "—" : str.tostring(math.round(bearPct)) + "%\nn=" + str.tostring(rTot)
            edgeStr = "—"
            edgeBg  = color.new(#263238, 0)
            edgeTxt = color.new(#607D8B, 0)
            if not na(bullPct) and not na(bearPct)
                if bullPct >= bearPct + edgeThresh
                    edgeStr := "▲ BULL"
                    edgeBg  := C_BULL_BG
                    edgeTxt := C_BULL_TEXT
                else if bearPct >= bullPct + edgeThresh
                    edgeStr := "▼ BEAR"
                    edgeBg  := C_BEAR_BG
                    edgeTxt := C_BEAR_TEXT
                else
                    edgeStr := "~~ EVEN"
                    edgeBg  := C_NEUT_BG
                    edgeTxt := C_NEUT_TEXT
            else if not na(bullPct)
                edgeStr := "▲ BULL"
                edgeBg  := C_BULL_BG
                edgeTxt := C_BULL_TEXT
            else if not na(bearPct)
                edgeStr := "▼ BEAR"
                edgeBg  := C_BEAR_BG
                edgeTxt := C_BEAR_TEXT
            row = i + 2
            table.cell(st, 0, row, array.get(hourLabels, i), text_color=C_TF_TEXT,      bgcolor=C_TF_BG,       text_size=txtSize, text_halign=text.align_center)
            table.cell(st, 1, row, bullStr,                  text_color=accTxt(bullPct), bgcolor=accBg(bullPct), text_size=txtSize, text_halign=text.align_center)
            table.cell(st, 2, row, bearStr,                  text_color=accTxt(bearPct), bgcolor=accBg(bearPct), text_size=txtSize, text_halign=text.align_center)
            table.cell(st, 3, row, edgeStr,                  text_color=edgeTxt,         bgcolor=edgeBg,         text_size=txtSize, text_halign=text.align_center)

        totBullPct = tot_bull_total > 0 ? float(tot_bull_cor) / float(tot_bull_total) * 100.0 : float(na)
        totBearPct = tot_bear_total > 0 ? float(tot_bear_cor) / float(tot_bear_total) * 100.0 : float(na)
        totBullStr = na(totBullPct) ? "—" : str.tostring(math.round(totBullPct)) + "%\nn=" + str.tostring(tot_bull_total)
        totBearStr = na(totBearPct) ? "—" : str.tostring(math.round(totBearPct)) + "%\nn=" + str.tostring(tot_bear_total)
        totEdgeStr = "—"
        totEdgeBg  = color.new(#263238, 0)
        totEdgeTxt = color.new(#607D8B, 0)
        if not na(totBullPct) and not na(totBearPct)
            if totBullPct >= totBearPct + edgeThresh
                totEdgeStr := "▲ BULL"
                totEdgeBg  := C_BULL_BG
                totEdgeTxt := C_BULL_TEXT
            else if totBearPct >= totBullPct + edgeThresh
                totEdgeStr := "▼ BEAR"
                totEdgeBg  := C_BEAR_BG
                totEdgeTxt := C_BEAR_TEXT
            else
                totEdgeStr := "~~ EVEN"
                totEdgeBg  := C_NEUT_BG
                totEdgeTxt := C_NEUT_TEXT
        table.cell(st, 0, 10, "TOTAL",    text_color=C_SCORE_TXT,        bgcolor=C_SCORE_BG,        text_size=txtSize, text_halign=text.align_center)
        table.cell(st, 1, 10, totBullStr, text_color=accTxt(totBullPct),  bgcolor=accBg(totBullPct),  text_size=txtSize, text_halign=text.align_center)
        table.cell(st, 2, 10, totBearStr, text_color=accTxt(totBearPct),  bgcolor=accBg(totBearPct),  text_size=txtSize, text_halign=text.align_center)
        table.cell(st, 3, 10, totEdgeStr, text_color=totEdgeTxt,          bgcolor=totEdgeBg,          text_size=txtSize, text_halign=text.align_center)

    // ══════════════════════════════════════════
    //  KEY LEVELS TABLE
    //  Rows: 0=title 1=header
    //        2=PDH 3=PDL 4=PDMid 5=PWH 6=PWL
    //  Cols: LEVEL | PRICE | DIST% | STATUS
    //
    //  STATUS color coding:
    //    🔴 NEAR  = within half the threshold
    //    🟡 WATCH = within the full threshold
    //    🟢 CLEAR = beyond the threshold
    //
    //  DIST% is positive when price is ABOVE
    //  the level, negative when BELOW.
    //  A bull bias fading near PDH with DIST%
    //  near zero is a high-probability failure.
    // ══════════════════════════════════════════
    if showKeyLevels

        klPosVal = switch klPos
            "Top Right"     => position.top_right
            "Top Left"      => position.top_left
            "Bottom Right"  => position.bottom_right
            "Bottom Left"   => position.bottom_left
            "Top Center"    => position.top_center
            "Bottom Center" => position.bottom_center
            => position.bottom_right

        kl := table.new(klPosVal, 4, 7, bgcolor=tableBgColor,
             border_width=1, border_color=color.new(#37474F, 60),
             frame_color=color.new(#37474F, 30), frame_width=2)

        table.cell(kl, 0, 0, "KEY",     text_color=color.new(#7986CB, 0), bgcolor=C_SESS_BG, text_size=txtSize, text_halign=text.align_center)
        table.cell(kl, 1, 0, "LEVELS",  text_color=color.new(#7986CB, 0), bgcolor=C_SESS_BG, text_size=txtSize, text_halign=text.align_center)
        table.cell(kl, 2, 0, str.tostring(proximityPct, "#.##") + "% ZONE", text_color=color.new(#7986CB, 0), bgcolor=C_SESS_BG, text_size=txtSize, text_halign=text.align_center)
        table.cell(kl, 3, 0, "",        text_color=color.new(#7986CB, 0), bgcolor=C_SESS_BG, text_size=txtSize, text_halign=text.align_center)

        table.cell(kl, 0, 1, "LEVEL",  text_color=C_HEADER_TXT, bgcolor=C_HEADER_BG, text_size=txtSize, text_halign=text.align_center)
        table.cell(kl, 1, 1, "PRICE",  text_color=C_HEADER_TXT, bgcolor=C_HEADER_BG, text_size=txtSize, text_halign=text.align_center)
        table.cell(kl, 2, 1, "DIST %", text_color=C_HEADER_TXT, bgcolor=C_HEADER_BG, text_size=txtSize, text_halign=text.align_center)
        table.cell(kl, 3, 1, "STATUS", text_color=C_HEADER_TXT, bgcolor=C_HEADER_BG, text_size=txtSize, text_halign=text.align_center)

        klLevels  = array.from("PDH", "PDL", "PDMid", "PWH", "PWL")
        klValues  = array.from(pdHigh, pdLow, pdMid, pwHigh, pwLow)
        klLblBgs  = array.from(
             color.new(#4A0000, 0),
             color.new(#1B5E20, 0),
             color.new(#1C2833, 0),
             color.new(#4A0000, 30),
             color.new(#1B5E20, 30))
        klLblTxts = array.from(
             color.new(#EF9A9A, 0),
             color.new(#A5D6A7, 0),
             color.new(#B0BEC5, 0),
             color.new(#EF9A9A, 30),
             color.new(#A5D6A7, 30))

        for r = 0 to 4
            lvl    = array.get(klValues,  r)
            dist   = distPct(lvl)
            status = proxStatus(dist)
            pStr   = not na(lvl) ? str.tostring(lvl, format.mintick) : "—"
            dStr   = proxLabel(dist, status)
            sStr   = status == 2 ? "⚠ NEAR" : status == 1 ? "~ WATCH" : status == 0 ? "✓ CLEAR" : "—"
            table.cell(kl, 0, r + 2, array.get(klLevels, r), text_color=array.get(klLblTxts, r), bgcolor=array.get(klLblBgs, r), text_size=txtSize, text_halign=text.align_center)
            table.cell(kl, 1, r + 2, pStr,  text_color=C_KL_PRICE_TEXT,  bgcolor=C_KL_PRICE_BG,   text_size=txtSize, text_halign=text.align_center)
            table.cell(kl, 2, r + 2, dStr,  text_color=proxTxt(status),  bgcolor=proxBg(status),   text_size=txtSize, text_halign=text.align_center)
            table.cell(kl, 3, r + 2, sStr,  text_color=proxTxt(status),  bgcolor=proxBg(status),   text_size=txtSize, text_halign=text.align_center)
````
