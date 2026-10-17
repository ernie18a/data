# NYO Day-Type Early Read

- url: https://www.tradingview.com/script/KFjJm4cz-NYO-Day-Type-Early-Read/
- type: indicator
- pine_id: PUB;0cf6ae49da314c9ca161cd4ca12ff686
- version: 1.0

## Description

Chart: put it on a 1-, 3-, or 5-minute ES chart (the opening-range needs to be ≤ your read window — don't use a 15-min chart, the box won't finish until 9:45's next bar). RTH or full-session (ETH) chart both work — it detects the 9:30 cash open itself.
At 9:45 ET the table freezes and an alert fires. Top row is your go/no-go:
TRADE (green) — trend/directional setup. Worth engaging, trade with the lean shown.
CAUTION (orange) — either volatile two-sided (wide but choppy) or mixed/neutral. Tradeable but reduce size / be selective.
SKIP (red) — quiet rotational compression. The classic chop-trap day; sit out.
The blue lines are prior-day RTH high/low, purple are the overnight high/low — your context for whether price has broken out.

## Source Code

````pine
//@version=6
indicator("NYO Day-Type Early Read", overlay=true, max_boxes_count=20, max_lines_count=50)

// ───────────── Inputs ─────────────
g1 = "Session / Opening Range"
orMin   = input.int(15, "Opening Range (minutes after open)", group=g1, minval=1)
rthSess = input.session("0930-1600", "RTH Session", group=g1)
tz      = input.string("America/New_York", "Timezone", group=g1)

g2 = "Thresholds"
nDays    = input.int(20, "Avg OR lookback (days)", group=g2, minval=2)
orExpand = input.float(1.2, "OR Expansion (x avg)", group=g2, step=0.05)
orQuiet  = input.float(0.8, "OR Compression (x avg)", group=g2, step=0.05)
convHi   = input.float(0.70, "Directional conviction (close loc in OR)", group=g2, step=0.01)

g3 = "Display"
showOR     = input.bool(true, "Draw opening-range box", group=g3)
showLevels = input.bool(true, "Plot prior-day & overnight range", group=g3)

// ───────────── Session detection ─────────────
inSession  = not na(time(timeframe.period, rthSess, tz))
isOpenBar  = inSession and not inSession[1]

// ───────────── State ─────────────
var float orHigh = na, var float orLow = na, var float orLastClose = na
var float openPx = na, var int openTime = na, var bool readDone = false
var float curRTHhigh = na, var float curRTHlow = na, var float lastRTHclose = na
var float priorRTHhigh = na, var float priorRTHlow = na, var float priorRTHclose = na
var float onHigh = na, var float onLow = na
var float pON_H = na, var float pON_L = na
var float avgOR = na

// display vars (frozen at the read)
var string dtType   = "Waiting for open + " + str.tostring(orMin) + "min..."
var string dtVerdict = "—"
var string dtDir    = "—"
var string dtConf   = "—"
var color  dtColor  = color.gray
var float  orRatioV = na, var float clvV = na

// ───────────── Per-bar bookkeeping ─────────────
if isOpenBar
    // snapshot yesterday before reset
    priorRTHhigh := curRTHhigh
    priorRTHlow  := curRTHlow
    priorRTHclose := lastRTHclose
    pON_H := onHigh
    pON_L := onLow
    // start today
    curRTHhigh := high
    curRTHlow  := low
    orHigh := high
    orLow  := low
    openPx := open
    orLastClose := close
    openTime := time
    readDone := false
    dtType   := "Building (waiting 9:45)..."
    dtVerdict := "WAIT"
    dtColor  := color.gray
else if inSession
    curRTHhigh := math.max(curRTHhigh, high)
    curRTHlow  := math.min(curRTHlow, low)

if inSession
    lastRTHclose := close

// accumulate opening range during the first orMin minutes
if inSession and not isOpenBar and (time - openTime) < orMin * 60000
    orHigh := math.max(orHigh, high)
    orLow  := math.min(orLow, low)
    orLastClose := close

// overnight range tracking
if not inSession
    if inSession[1]
        onHigh := high
        onLow  := low
    else
        onHigh := math.max(onHigh, high)
        onLow  := math.min(onLow, low)

// ───────────── The 9:45 read ─────────────
orJustDone = inSession and not readDone and not na(openTime) and (time - openTime) >= orMin * 60000

if orJustDone
    orSize  = orHigh - orLow
    orRatio = na(avgOR) or avgOR == 0 ? 1.0 : orSize / avgOR
    clv     = orSize > 0 ? (orLastClose - orLow) / orSize : 0.5
    priceNow = orLastClose

    expansion   = orRatio >= orExpand
    compression = orRatio <= orQuiet
    directional = clv >= convHi or clv <= (1 - convHi)
    outPrior = (not na(priorRTHhigh) and priceNow > priorRTHhigh) or (not na(priorRTHlow) and priceNow < priorRTHlow)
    outON    = (not na(pON_H) and priceNow > pON_H) or (not na(pON_L) and priceNow < pON_L)

    trendScore = (expansion ? 1 : 0) + (directional ? 1 : 0) + (outPrior ? 1 : 0) + (outON ? 1 : 0)

    if compression and not directional
        dtType := "Quiet / Rotational"
        dtVerdict := "SKIP"
        dtColor := color.new(color.red, 0)
    else if trendScore >= 3
        dtType := "Trend Day (likely)"
        dtVerdict := "TRADE"
        dtColor := color.new(color.green, 0)
    else if trendScore == 2 and directional
        dtType := "Directional / Trending"
        dtVerdict := "TRADE"
        dtColor := color.new(color.green, 0)
    else if expansion and not directional
        dtType := "Volatile / Two-Sided"
        dtVerdict := "CAUTION"
        dtColor := color.new(color.orange, 0)
    else
        dtType := "Normal / Mixed"
        dtVerdict := "CAUTION"
        dtColor := color.new(color.orange, 0)

    dtDir := clv >= 0.60 ? "▲ Long lean" : clv <= 0.40 ? "▼ Short lean" : "↔ No clear lean"
    dtConf := trendScore >= 3 ? "High" : trendScore == 2 ? "Medium" : "Low"
    orRatioV := orRatio
    clvV := clv

    // update rolling average OR (after using prior value)
    alpha = 2.0 / (nDays + 1)
    avgOR := na(avgOR) ? orSize : avgOR + alpha * (orSize - avgOR)

    if showOR
        box.new(left=openTime, top=orHigh, right=time, bottom=orLow, xloc=xloc.bar_time, border_color=dtColor, bgcolor=color.new(dtColor, 85))

    alert("NYO Day Type: " + dtType + " | " + dtVerdict + " | " + dtDir, alert.freq_once_per_bar)

// ───────────── Context levels ─────────────
plot(showLevels ? priorRTHhigh : na, "Prior RTH High", color.new(color.blue, 40), 1, plot.style_stepline)
plot(showLevels ? priorRTHlow  : na, "Prior RTH Low",  color.new(color.blue, 40), 1, plot.style_stepline)
plot(showLevels ? pON_H : na, "Overnight High", color.new(color.purple, 50), 1, plot.style_stepline)
plot(showLevels ? pON_L : na, "Overnight Low",  color.new(color.purple, 50), 1, plot.style_stepline)

// ───────────── Verdict table ─────────────
var table t = table.new(position.top_right, 2, 6, border_width=1)
if barstate.islast
    table.cell(t, 0, 0, "NYO Read", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(t, 1, 0, dtVerdict, text_color=color.white, bgcolor=dtColor)
    table.cell(t, 0, 1, "Day Type", text_color=color.white, bgcolor=color.new(color.gray, 30))
    table.cell(t, 1, 1, dtType, text_color=color.white, bgcolor=color.new(color.gray, 60))
    table.cell(t, 0, 2, "Direction", text_color=color.white, bgcolor=color.new(color.gray, 30))
    table.cell(t, 1, 2, dtDir, text_color=color.white, bgcolor=color.new(color.gray, 60))
    table.cell(t, 0, 3, "Confidence", text_color=color.white, bgcolor=color.new(color.gray, 30))
    table.cell(t, 1, 3, dtConf, text_color=color.white, bgcolor=color.new(color.gray, 60))
    table.cell(t, 0, 4, "OR x avg", text_color=color.white, bgcolor=color.new(color.gray, 30))
    table.cell(t, 1, 4, na(orRatioV) ? "—" : str.tostring(orRatioV, "#.00"), text_color=color.white, bgcolor=color.new(color.gray, 60))
    table.cell(t, 0, 5, "OR close loc", text_color=color.white, bgcolor=color.new(color.gray, 30))
    table.cell(t, 1, 5, na(clvV) ? "—" : str.tostring(clvV, "#.00"), text_color=color.white, bgcolor=color.new(color.gray, 60))
````
