# Probability Clouds + Entry Level [Rider Algo]

- url: https://www.tradingview.com/script/tgkBvcdZ-Probability-Clouds-Entry-Level-Rider-Algo/
- type: indicator
- pine_id: PUB;7c42db665d624a74b3db509532fe67ef
- version: 1.0

## Description

Probability Clouds + Entry Level [Rider Algo]

Probability Clouds draws a weather-style forecast to the right of the last candle: clouds that show where price is likely to close over the next few candles, levels that show how likely price is to touch each price, and an entry planner that shows how often a limit order fills and whether the target or the stop usually comes first. Like a weather map, it does not promise rain or sun; it shows how much it usually rains on days like today.

═══════════════════════════════════════════════════════════════════════════

[b]HOW IT WORKS[/b]

Everything is learned from the chart you are looking at, using only its own history.

1. Every past candle is described by four features: trend (distance to the EMA 50), short-term momentum (last 5 candles), position inside the 20-candle range, and volatility regime (ATR 14 vs ATR 100).
2. For the current candle, the script finds the past moments that looked most similar on those features (200 by default).
3. It blends what price did after those moments with what it did after every past candle, so the forecast stays specific without trusting a small sample.
4. Moves are measured in ATR, so calm and wild periods compare, and are converted back to prices at today's volatility.

Only past candles whose full outcome has already closed are used. The forecast never looks at future data.

═══════════════════════════════════════════════════════════════════════════

[b]WHAT YOU SEE ON THE CHART[/b]

[b]The clouds (where price may CLOSE)[/b]
- [i]Inner cloud[/i]: the range where the close landed 50% of the time in similar past situations.
- [i]Middle cloud[/i]: 80% of the time. [i]Outer cloud[/i]: 90% of the time.
- [i]Dotted line[/i]: the most likely path.
A wide cloud means large moves are normal right now; a narrow one means the market usually stays quiet in this kind of situation. A lean up or down reflects how similar moments resolved: treat it as context, not as a signal.

[b]The touch levels (where price may REACH)[/b]
Dashed lines labelled 75%, 50% and 25%: the share of similar past situations in which price touched that level (a wick is enough) before the cloud ended. Use them to judge whether a limit order is likely to fill, whether a take-profit is realistic in the time you plan to hold, and where normal noise ends for a stop.

[b]The entry planner (Trade odds)[/b]
Choose Long or Short, an entry (now, or a limit at the 75%, 50% or 25% level), a stop and a target in ATR. The script replays that exact trade on the same similar past moments and shows:
- [i]Entry fills[/i]: how often price reached the entry within the cloud's candles.
- [i]Target first[/i] / [i]Stop first[/i]: once filled, which one came first. A candle that touches both counts as the stop.
- [i]Neither[/i]: still open when the cloud ends.
- [i]Result per $ risked[/i]: the average outcome in units of risk, with open trades valued at the last close. Fees are not included.
The plan is drawn as green and red boxes, like TradingView's position tool. A result near zero means a fair bet: the odds help you place and size orders, they do not create an edge.

[b]Freeze at a candle[/b]
The forecast normally starts from the last close, so it moves with every new candle. Turn on [i]Freeze at a candle[/i] and pick the day you placed your order: the clouds, levels and plan stay fixed from that close, new candles appear inside the frozen cloud, and the table tracks the order: waiting, filled, target, stop or expired.

[b]The table[/b]
The 80% zone, the most likely close, the 50% touch levels, the entry planner and the [i]Track record[/i]: the latest candles are forecast again with only the data available at each moment and checked, so you can verify the calibration on the exact symbol and timeframe you trade. The Full table adds the 50% and 90% zones and every touch level.

═══════════════════════════════════════════════════════════════════════════

[b]HOW TO USE IT[/b]

1. Check the [i]Track record[/i]. If the 80% zone held close to 80% of the time, the clouds are well calibrated on that chart; if much lower, give the levels extra room.
2. Read the width of the cloud before the lean. It tells you how far price usually travels from here.
3. Set your entry, stop and target in the entry planner and check how often it fills and which side usually comes first. Match [i]Candles ahead[/i] to how long you plan to hold.
4. Once the order is placed, freeze the forecast on that day and follow its status in the table.

The clouds forecast ranges, not direction. Combine them with your own trend or signal tool.

═══════════════════════════════════════════════════════════════════════════

[b]INPUTS[/b]

[b]1 · Forecast[/b]
- [b]Candles ahead[/b] (default 5): how many candles the cloud projects.
- [b]History to learn from[/b] (default 2000 candles; about 310 are needed).
- [b]Similar moments[/b] (default 200): fewer = more specific but noisier.
- [b]Freeze at a candle[/b] (off by default) and its date.
- [b]Weight of similar moments[/b] (default 50%): 0% gives a pure volatility cloud; 100% uses only the similar moments.

[b]2 · Clouds[/b] and [b]3 · Touch levels[/b]
- Show or hide each element, pick colors, and choose the three [b]Chances (%)[/b] (default 75, 50 and 25).

[b]4 · Trade odds[/b]
- [b]Plan[/b] (Long, Short or Off), [b]Entry[/b], [b]Stop[/b] and [b]Target[/b] in ATR (defaults: Long, limit at the 50% level, 1.5 and 1.5 ATR) and [b]Draw the plan[/b].

[b]5 · Table[/b]
- [b]Content[/b] (Compact or Full), [b]Position[/b], [b]Size[/b] and [b]Track record[/b] (default 250 candles; 0 loads faster).

═══════════════════════════════════════════════════════════════════════════

[b]TECHNICAL NOTES[/b]

- Pine Script v6.
- Non-repainting after the close: the forecast follows the live candle while it is open and is fixed once it closes. A frozen forecast and every track-record forecast use only the data available at that candle.
- Works on any symbol and timeframe with enough history and adapts to each chart: the same settings give different clouds on a calm stock and a volatile altcoin.

═══════════════════════════════════════════════════════════════════════════

[b]PART OF THE RIDER ALGO ECOSYSTEM[/b]

- Use with [b]Strategy #1 - Sudden Moves towards Optimizer Lines [Rider Algo][/b] to check how likely a limit order at the Optimizer Line is to be reached within the next few candles.
- Use with [b]Strategy #2 [Rider Algo][/b] to see whether its targets sit inside the range price usually covers after similar setups.
- Use with [b]Rider Algo - Volatility Regime Detector[/b]: in Compression the clouds narrow, in Expansion and Chaos they widen, which helps size stops and targets for the current regime.

═══════════════════════════════════════════════════════════════════════════

[b]DISCLAIMER[/b]

This indicator is a technical analysis tool designed to estimate the range of likely price outcomes and the odds of a planned trade from a chart's own history. It does NOT provide buy or sell signals, and it does NOT constitute financial, investment, or trading advice of any kind. Past patterns do not guarantee future market behavior. Always conduct your own analysis and consult with a qualified financial advisor before making any trading decisions. Use this tool at your own risk. The author is not responsible for any financial losses incurred from the use of this indicator.

## Source Code

````pine
//@version=6
indicator("Probability Clouds + Entry Level [Rider Algo]", shorttitle="RA Clouds", overlay=true, max_lines_count=20, max_labels_count=30, max_boxes_count=10, max_polylines_count=10)

// Developed by Rider Algo
//
// How it works (validated 2026-10-16 on 12 assets: BTC, ETH, SOL, ADA, XRP, SPY, QQQ, NVDA, AAPL, TSLA, gold, EURUSD;
// 1D, 4H and 1W; ~90,000 out-of-sample forecasts):
//   1. Every past candle is described by 4 features: trend (distance to EMA 50), 5-candle momentum, position in the
//      20-candle range and volatility regime (ATR 14 vs ATR 100). Distances are measured in ATR, so calm and wild
//      periods are comparable.
//   2. For the current candle, the 200 most similar past candles are found (nearest neighbours).
//   3. What price did over the next N candles after those moments (in ATR) is blended 50/50 with what it did after
//      every past candle. The blend's percentiles are the clouds; the highs and lows reached are the touch levels.
//   Only candles whose whole outcome is already closed are used, so the forecast never looks into the future.
//   4. Trade odds replay a planned entry, stop and target over the same past moments (validated on the same 12
//      assets: predicted vs real fill, target-first and stop-first rates matched within 1-2 points).

//──────────────────────────────────────────────
// QUICK GUIDE
//──────────────────────────────────────────────
groupGuide = "Quick Guide"

quickGuide = input.string("Hover the (i) on the right", "How to read it", group=groupGuide, display=display.none, tooltip="1. The clouds show where the price is likely to CLOSE in each of the next candles. Inner cloud = 50% of the time, middle = 80%, outer = 90%. The dotted line is the most likely path.\n2. The dashed lines are levels with a 75%, 50% and 25% chance of being TOUCHED (a wick is enough) before the cloud ends. Use them to place limit orders, take-profits and stops outside the normal noise.\n3. The cloud is learned from this chart's own history: the past moments most similar to now, blended with all past moves.\n4. Trade odds: pick an entry, stop and target; the table shows how often the entry fills and, once filled, how often the target or the stop came first in similar past moments.\n5. The table shows the track record on this chart: how often the 80% cloud really contained the price.\nClouds forecast RANGES, not direction: a wide cloud means big moves are likely, up or down.")

//──────────────────────────────────────────────
// 1 · FORECAST SETTINGS
//──────────────────────────────────────────────
groupFc = "1 · Forecast"

horizon  = input.int(5, "Candles ahead", minval=1, maxval=20, group=groupFc, tooltip="How many candles the cloud projects. Validated on 5. Longer horizons give wider clouds.")
lookback = input.int(2000, "History to learn from (candles)", minval=300, maxval=4500, step=100, group=groupFc, tooltip="How many past candles are searched. If the chart has fewer, it uses all it has. Needs at least about 320 candles.")
kInput   = input.int(200, "Similar moments", minval=30, maxval=500, step=10, group=groupFc, tooltip="How many of the past moments most similar to now shape the cloud. Fewer = more specific but noisier. With a short history it uses a quarter of the candles available.")
freeze   = input.bool(false, "Freeze at a candle", group=groupFc, inline="fz", tooltip="Off: the forecast moves with every new candle (it always starts from the last close).\nOn: the clouds, levels and trade plan stay fixed from the close of the chosen candle, using only what was known that day. New candles appear inside the frozen cloud and the table shows the status of the order: waiting, filled, target, stop or expired.")
freezeAt = input.time(timestamp("2026-10-01T00:00:00"), "", group=groupFc, inline="fz")
wInput   = input.int(50, "Weight of similar moments (%)", minval=0, maxval=100, step=10, group=groupFc, tooltip="0% = every past candle counts the same (a pure volatility cloud).\n100% = only the similar moments count.\n50% was the most accurate in the tests.")

//──────────────────────────────────────────────
// 2 · CLOUDS
//──────────────────────────────────────────────
groupCl = "2 · Clouds"

showClouds = input.bool(true, "Show clouds", group=groupCl)
show90     = input.bool(true, "Show outer cloud (90%)", group=groupCl)
showPath   = input.bool(true, "Show most likely path", group=groupCl, tooltip="Dotted line: the middle of the clouds. Half of the time price closes above it, half below.")
cloudColor = input.color(#7c8cff, "Cloud color", group=groupCl)

//──────────────────────────────────────────────
// 3 · TOUCH LEVELS
//──────────────────────────────────────────────
groupTl = "3 · Touch levels"

showTouch = input.bool(true, "Show touch levels", group=groupTl, tooltip="Dashed lines above and below price. Each one says how likely price is to reach it (a wick is enough) within the next candles of the cloud.")
pHi       = input.int(75, "Chances (%)", minval=5, maxval=95, step=5, group=groupTl, inline="tp")
pMd       = input.int(50, "", minval=5, maxval=95, step=5, group=groupTl, inline="tp")
pLo       = input.int(25, "", minval=5, maxval=95, step=5, group=groupTl, inline="tp", tooltip="The three chances drawn on each side. 75% = very likely to be touched (close to price). 25% = a stretch.")
upColor   = input.color(#1be5a4, "Colors: Up", group=groupTl, inline="tc")
dnColor   = input.color(#f4362a, "Down", group=groupTl, inline="tc")

//──────────────────────────────────────────────
// 4 · TRADE ODDS
//──────────────────────────────────────────────
groupTo = "4 · Trade odds"

planSide  = input.string("Long", "Plan", options=["Long", "Short", "Off"], group=groupTo, tooltip="Replays a trade over the cloud's candles on the same similar past moments: how often the entry fills and, once filled, how often the target or the stop comes first. Off = hide.")
planEntry = input.string("Limit at 50% level", "Entry", options=["At close (now)", "Limit at 75% level", "Limit at 50% level", "Limit at 25% level"], group=groupTo, tooltip="At close: enter now at the current price.\nLimit at X% level: a limit order at the price that is touched X% of the time within the cloud's candles (below price for Long, above for Short).")
planStop  = input.float(1.5, "Stop (ATR from entry)", minval=0.25, maxval=10, step=0.25, group=groupTo, tooltip="ATR = how much this asset normally moves per candle. The table shows every distance in % too.")
planTgt   = input.float(1.5, "Target (ATR from entry)", minval=0.25, maxval=20, step=0.25, group=groupTo)
showPlan  = input.bool(true, "Draw the plan", group=groupTo, tooltip="Green box = entry to target, red box = entry to stop, like TradingView's position tool.")

//──────────────────────────────────────────────
// 5 · TABLE
//──────────────────────────────────────────────
groupTb = "5 · Table"

showTable = input.bool(true, "Show table", group=groupTb)
tableMode = input.string("Compact", "Content", options=["Compact", "Full"], group=groupTb, tooltip="Compact: the 80% zone, the most likely close, the 50% touch levels, the trade odds and the track record.\nFull: adds the 50% and 90% zones, every touch level and the odds of closing higher.")
tblPosIn  = input.string("Top Right", "Position", options=["Top Right", "Middle Right", "Top Left", "Bottom Left", "Bottom Right"], group=groupTb, inline="tbl")
tblSizeIn = input.string("Small", "Size", options=["Tiny", "Small", "Normal"], group=groupTb, inline="tbl")
trackN    = input.int(250, "Track record (past forecasts)", minval=0, maxval=1000, step=50, group=groupTb, tooltip="How many of the latest candles are forecast again and checked against what really happened. 0 = off (loads faster).")

tblSize = tblSizeIn == "Tiny" ? size.tiny : tblSizeIn == "Normal" ? size.normal : size.small
tblPos = switch tblPosIn
    "Top Right"    => position.top_right
    "Middle Right" => position.middle_right
    "Top Left"     => position.top_left
    "Bottom Left"  => position.bottom_left
    "Bottom Right" => position.bottom_right

//──────────────────────────────────────────────
// FEATURES AND OUTCOMES
//──────────────────────────────────────────────
H         = horizon
MIN_CAND  = 150   // fewest past candles needed to draw a cloud
WARMUP    = 150   // candles skipped at the start of the chart (indicators still warming up)

atr14  = ta.atr(14)
atr100 = ta.atr(100)
ema50  = ta.ema(close, 50)
hh20   = ta.highest(high, 20)
ll20   = ta.lowest(low, 20)

fTrend = (close - ema50) / atr14
fMom   = (close - close[5]) / atr14
fRange = hh20 - ll20 > 0 ? (close - ll20) / (hh20 - ll20) : 0.5
fVol   = math.log(atr14 / atr100)
featOk = not na(fTrend) and not na(fMom) and not na(fVol) and atr14 > 0

// Outcome of the candle H bars ago, known at this candle: highest high and lowest low reached since then, in its ATR
outUp = (ta.highest(high, H) - close[H]) / atr14[H]
outDn = (ta.lowest(low, H) - close[H]) / atr14[H]

// Memory of every closed candle. The forecast reads these arrays instead of using [] on series: inside a function,
// [] walks back through the function's own calls, not through the chart (warning CW10003), and the forecast only
// runs on the last candles.
CAP = lookback + trackN + H + 10
var array<float> aClose = array.new<float>()
var array<float> aAtr   = array.new<float>()
var array<float> aHigh  = array.new<float>()
var array<float> aLow   = array.new<float>()
var array<float> aF1    = array.new<float>()
var array<float> aF2    = array.new<float>()
var array<float> aF3    = array.new<float>()
var array<float> aF4    = array.new<float>()
var array<bool>  aOk    = array.new<bool>()
var array<float> aUp    = array.new<float>()   // outUp / outDn stored at the candle where they become known
var array<float> aDn    = array.new<float>()
var int lastBar = -1                           // bar_index of the newest stored candle

// Running mean and spread of each feature, to weigh the 4 features equally
var float sN = 0.0
var float s1 = 0.0
var float s2 = 0.0
var float s3 = 0.0
var float s4 = 0.0
var float q1 = 0.0
var float q2 = 0.0
var float q3 = 0.0
var float q4 = 0.0
if barstate.isconfirmed
    aClose.push(close)
    aAtr.push(atr14)
    aHigh.push(high)
    aLow.push(low)
    aF1.push(fTrend)
    aF2.push(fMom)
    aF3.push(fRange)
    aF4.push(fVol)
    aOk.push(featOk)
    aUp.push(outUp)
    aDn.push(outDn)
    lastBar := bar_index
    if aClose.size() > CAP
        aClose.shift()
        aAtr.shift()
        aHigh.shift()
        aLow.shift()
        aF1.shift()
        aF2.shift()
        aF3.shift()
        aF4.shift()
        aOk.shift()
        aUp.shift()
        aDn.shift()

if barstate.isconfirmed and featOk
    sN += 1
    s1 += fTrend
    q1 += fTrend * fTrend
    s2 += fMom
    q2 += fMom * fMom
    s3 += fRange
    q3 += fRange * fRange
    s4 += fVol
    q4 += fVol * fVol

f_sd(float s, float q, float n) => math.sqrt(math.max(q / n - math.pow(s / n, 2), 1e-12))
f_idx(int b) => aClose.size() - 1 - (lastBar - b)   // array position of the candle with bar_index b

//──────────────────────────────────────────────
// FORECAST ENGINE
//──────────────────────────────────────────────
var array<float> QS = array.from(0.05, 0.10, 0.25, 0.50, 0.75, 0.90, 0.95)   // rows of the band matrix
probs = array.from(pHi / 100.0, pMd / 100.0, pLo / 100.0)

type Forecast
    matrix<float> band   // 7 percentiles (QS) x H candles, in ATR from the current close
    array<float>  up     // touch levels above, one per chance in probs, in ATR
    array<float>  dn     // touch levels below
    float         pUp    // chance of closing higher after H candles
    int           nCand  // past candles searched
    int           nNb    // similar moments used
    bool          oOn    // trade odds computed
    float         oE     // entry, stop and target in ATR from the current close (mirrored for Short)
    float         oS
    float         oT
    float         oFill  // chance the entry fills within H candles
    float         oWin   // once filled: target first
    float         oLoss  // once filled: stop first
    float         oR     // once filled: average result per $ risked (open trades valued at the last candle)

// Percentile of an ascending array, linear interpolation
f_quant(array<float> sorted, float p) =>
    int n = sorted.size()
    float pos = p * (n - 1)
    int lo = int(math.floor(pos))
    int hi = math.min(lo + 1, n - 1)
    sorted.get(lo) + (sorted.get(hi) - sorted.get(lo)) * (pos - lo)

f_blendQ(array<float> nb, array<float> all, float p, float w) => w * f_quant(nb, p) + (1 - w) * f_quant(all, p)

// One past moment replayed as a trade (Long logic; Short is mirrored). Same counting as the Rider Algo strategies:
// a candle that touches the stop counts as a loss even if it also reaches the target, and on the fill candle the
// target only counts if the candle closes beyond it. Trades still open after H candles are valued at that close.
f_sim(int k0, float e, float s, float tg, bool market, bool isLong) =>
    float c0 = aClose.get(k0)
    float a0 = aAtr.get(k0)
    bool filled = market
    int res = 0
    float clEnd = 0.0
    for h = 1 to H
        float hi = (aHigh.get(k0 + h) - c0) / a0
        float lo = (aLow.get(k0 + h) - c0) / a0
        float cl = (aClose.get(k0 + h) - c0) / a0
        if not isLong
            float tmp = hi
            hi := -lo
            lo := -tmp
            cl := -cl
        clEnd := cl
        if res == 0
            bool fillBar = false
            if not filled and lo <= e
                filled := true
                fillBar := true
            if filled
                if lo <= s
                    res := -1
                else if (fillBar ? cl >= tg : hi >= tg)
                    res := 1
    float risk = e - s
    float rr = not filled ? 0.0 : res == 1 ? (tg - e) / risk : res == -1 ? -1.0 : (clEnd - e) / risk
    [filled, res, rr]

// full = true computes every candle of the cloud and the trade odds; false only the last candle (track record)
f_forecast(bool full) =>
    Forecast fc = na
    // candidates: candles whose H next candles are all closed, inside the history window
    int cMax = bar_index - H - 1
    int cMin = math.max(math.max(bar_index - lookback, lastBar - aClose.size() + 1), WARMUP)
    if featOk and sN > 1 and cMax - cMin + 1 >= MIN_CAND
        float sd1 = f_sd(s1, q1, sN)
        float sd2 = f_sd(s2, q2, sN)
        float sd3 = f_sd(s3, q3, sN)
        float sd4 = f_sd(s4, q4, sN)
        array<int> offs = array.new<int>()   // array positions of the candidates
        array<float> dist = array.new<float>()
        for c = cMin to cMax
            int k0 = f_idx(c)
            if aOk.get(k0)
                float d = math.pow((aF1.get(k0) - fTrend) / sd1, 2) + math.pow((aF2.get(k0) - fMom) / sd2, 2) + math.pow((aF3.get(k0) - fRange) / sd3, 2) + math.pow((aF4.get(k0) - fVol) / sd4, 2)
                offs.push(k0)
                dist.push(d)
        int n = offs.size()
        if n >= MIN_CAND
            int k = math.min(kInput, math.max(20, int(math.floor(n / 4))))
            array<int> idx = dist.sort_indices(order.ascending)
            float w = wInput / 100.0
            matrix<float> band = matrix.new<float>(7, H, na)
            float pUp = na
            int hFrom = full ? 1 : H
            for h = hFrom to H
                array<float> zAll = array.new<float>(n, 0.0)
                array<float> zNb = array.new<float>(k, 0.0)
                for j = 0 to n - 1
                    int k0 = offs.get(j)
                    zAll.set(j, (aClose.get(k0 + h) - aClose.get(k0)) / aAtr.get(k0))
                for r = 0 to k - 1
                    zNb.set(r, zAll.get(idx.get(r)))
                if h == H
                    float upAll = 0.0
                    float upNb = 0.0
                    for j = 0 to n - 1
                        upAll += zAll.get(j) > 0 ? 1 : 0
                    for r = 0 to k - 1
                        upNb += zNb.get(r) > 0 ? 1 : 0
                    pUp := w * upNb / k + (1 - w) * upAll / n
                zAll.sort()
                zNb.sort()
                for q = 0 to 6
                    band.set(q, h - 1, f_blendQ(zNb, zAll, QS.get(q), w))
            // touch levels: highest high / lowest low reached within the H candles after each past moment
            array<float> uAll = array.new<float>(n, 0.0)
            array<float> dAll = array.new<float>(n, 0.0)
            for j = 0 to n - 1
                int k0 = offs.get(j)
                uAll.set(j, aUp.get(k0 + H))
                dAll.set(j, aDn.get(k0 + H))
            array<float> uNb = array.new<float>(k, 0.0)
            array<float> dNb = array.new<float>(k, 0.0)
            for r = 0 to k - 1
                int jj = idx.get(r)
                uNb.set(r, uAll.get(jj))
                dNb.set(r, dAll.get(jj))
            uAll.sort()
            dAll.sort()
            uNb.sort()
            dNb.sort()
            array<float> upLv = array.new<float>()
            array<float> dnLv = array.new<float>()
            for p in probs
                upLv.push(f_blendQ(uNb, uAll, 1 - p, w))
                dnLv.push(f_blendQ(dNb, dAll, p, w))
            // trade odds on the same past moments
            bool oOn = full and planSide != "Off"
            float oE = na
            float oS = na
            float oT = na
            float oFill = na
            float oWin = na
            float oLoss = na
            float oR = na
            if oOn
                bool isLong = planSide == "Long"
                bool market = planEntry == "At close (now)"
                float pE = planEntry == "Limit at 75% level" ? 0.75 : planEntry == "Limit at 50% level" ? 0.50 : 0.25
                // entry in mirrored ATR units: Long buys below price, Short sells above
                oE := market ? 0.0 : isLong ? f_blendQ(dNb, dAll, pE, w) : -f_blendQ(uNb, uAll, 1 - pE, w)
                oS := oE - planStop
                oT := oE + planTgt
                array<int> fArr = array.new<int>(n, 0)
                array<int> resArr = array.new<int>(n, 0)
                array<float> rArr = array.new<float>(n, 0.0)
                float fAll = 0.0
                float winAll = 0.0
                float lossAll = 0.0
                float rAll = 0.0
                for j = 0 to n - 1
                    [fl, rs, rr] = f_sim(offs.get(j), oE, oS, oT, market, isLong)
                    fArr.set(j, fl ? 1 : 0)
                    resArr.set(j, rs)
                    rArr.set(j, rr)
                    fAll += fl ? 1 : 0
                    winAll += fl and rs == 1 ? 1 : 0
                    lossAll += fl and rs == -1 ? 1 : 0
                    rAll += rr
                float fNb = 0.0
                float winNb = 0.0
                float lossNb = 0.0
                float rNb = 0.0
                for r = 0 to k - 1
                    int jj = idx.get(r)
                    bool fl2 = fArr.get(jj) == 1
                    fNb += fl2 ? 1 : 0
                    winNb += fl2 and resArr.get(jj) == 1 ? 1 : 0
                    lossNb += fl2 and resArr.get(jj) == -1 ? 1 : 0
                    rNb += rArr.get(jj)
                oFill := w * fNb / k + (1 - w) * fAll / n
                if oFill > 0
                    oWin := (w * winNb / k + (1 - w) * winAll / n) / oFill
                    oLoss := (w * lossNb / k + (1 - w) * lossAll / n) / oFill
                    oR := (w * rNb / k + (1 - w) * rAll / n) / oFill
            fc := Forecast.new(band, upLv, dnLv, pUp, n, k, oOn, oE, oS, oT, oFill, oWin, oLoss, oR)
    fc

//──────────────────────────────────────────────
// TRACK RECORD (forecasts frozen at each candle close, checked H candles later)
//──────────────────────────────────────────────
var array<int>   tBar = array.new<int>()
var array<float> tLo  = array.new<float>()   // 80% zone, in ATR from that close
var array<float> tHi  = array.new<float>()
var array<float> tU   = array.new<float>()   // 3 touch levels above per forecast, in ATR
var array<float> tD   = array.new<float>()   // 3 touch levels below per forecast, in ATR

if trackN > 0 and barstate.isconfirmed and bar_index >= last_bar_index - trackN - H
    Forecast f = f_forecast(false)
    if not na(f)
        tBar.push(bar_index)
        tLo.push(f.band.get(1, H - 1))
        tHi.push(f.band.get(5, H - 1))
        for p = 0 to 2
            tU.push(f.up.get(p))
            tD.push(f.dn.get(p))
        if tBar.size() > trackN + H
            tBar.shift()
            tLo.shift()
            tHi.shift()
            for p = 0 to 2
                tU.shift()
                tD.shift()

//──────────────────────────────────────────────
// FROZEN FORECAST (optional): made at the chosen candle's close and kept fixed
//──────────────────────────────────────────────
var Forecast fz = na
var int fzBar = na
var float fzClose = na
var float fzAtr = na
var int fzTime = na
if freeze and na(fz) and barstate.isconfirmed and time >= freezeAt
    fz := f_forecast(true)
    fzBar := bar_index
    fzClose := close
    fzAtr := atr14
    fzTime := time
frozen = freeze and not na(fz)
// origin of everything drawn: the last close (live) or the frozen candle
oX = frozen ? fzBar : bar_index
oC = frozen ? fzClose : close
oA = frozen ? fzAtr : atr14

//──────────────────────────────────────────────
// FORMATTING
//──────────────────────────────────────────────
f_px(float x) => str.tostring(x, format.mintick)
f_pct(float x) => (x >= 0 ? "+" : "") + str.tostring(x, math.abs(x) < 1 ? "0.00" : "0.0") + "%"
f_mv(float px) => f_pct((px - oC) / oC * 100)
f_rate(float x) => str.tostring(math.round(x * 100)) + "%"
f_y(matrix<float> bd, int q, int h) => oC + bd.get(q, h - 1) * oA   // price of percentile row q at candle h
f_rateNa(float x) => na(x) ? "–" : f_rate(x)
f_planPx(float a) => oC + (planSide == "Long" ? 1.0 : -1.0) * a * oA   // plan level (mirrored ATR) to price

//──────────────────────────────────────────────
// DRAWING (last candle only)
//──────────────────────────────────────────────
var array<polyline> polys = array.new<polyline>()
var array<line>     lns   = array.new<line>()
var array<label>    lbls  = array.new<label>()
var array<box>      bxs   = array.new<box>()
var table tbl = na

if barstate.islast
    for pl in polys
        pl.delete()
    polys.clear()
    for ln in lns
        ln.delete()
    lns.clear()
    for lb in lbls
        lb.delete()
    lbls.clear()
    for bx in bxs
        bx.delete()
    bxs.clear()
    if not na(tbl)
        tbl.delete()
    tbl := showTable ? table.new(tblPos, 3, 22, border_width=1) : na

    Forecast fc = frozen ? fz : f_forecast(true)

    // Status of the frozen order, replayed on the real candles after the frozen one (same rules as the odds)
    string fzStatus = ""
    int seen = 0
    int fillB = na
    int resB = na
    int res = 0
    if frozen and not na(fc) and fc.oOn
        bool isLong = planSide == "Long"
        bool filled = planEntry == "At close (now)"
        fillB := filled ? fzBar : na
        float lastCl = na
        bool tooOld = fzBar < lastBar - aClose.size() + 1
        if not tooOld
            for h = 1 to H
                int b = fzBar + h
                if b <= bar_index
                    bool closedBar = b <= lastBar
                    float hiP = closedBar ? aHigh.get(f_idx(b)) : high
                    float loP = closedBar ? aLow.get(f_idx(b)) : low
                    float clP = closedBar ? aClose.get(f_idx(b)) : close
                    float hi = (hiP - fzClose) / fzAtr
                    float lo = (loP - fzClose) / fzAtr
                    float cl = (clP - fzClose) / fzAtr
                    if not isLong
                        float tmp = hi
                        hi := -lo
                        lo := -tmp
                        cl := -cl
                    seen := h
                    lastCl := cl
                    if res == 0
                        bool fillBar = false
                        if not filled and lo <= fc.oE
                            filled := true
                            fillBar := true
                            fillB := b
                        if filled
                            if lo <= fc.oS
                                res := -1
                                resB := b
                            else if (fillBar ? cl >= fc.oT : hi >= fc.oT)
                                res := 1
                                resB := b
            string candleTxt = " (candle " + str.tostring(seen) + " of " + str.tostring(H) + ")"
            fzStatus := res == 1 ? "Target reached on candle " + str.tostring(resB - fzBar) : res == -1 ? "Stop hit on candle " + str.tostring(resB - fzBar) : filled and seen >= H ? "Ended open at " + (((lastCl - fc.oE) / (fc.oE - fc.oS)) >= 0 ? "+" : "") + str.tostring((lastCl - fc.oE) / (fc.oE - fc.oS), "0.00") + " R" : filled ? "Filled · open" + candleTxt : seen >= H ? "Not filled · expired" : "Waiting to fill" + candleTxt
        else
            fzStatus := "Frozen candle is too old for the stored history"

    // Track record: forecasts whose H candles have all closed
    int nEval = 0
    int held = 0
    array<int> hits = array.new<int>(3, 0)
    if tBar.size() > 0
        for s = 0 to tBar.size() - 1
            int b = tBar.get(s)
            if b + H <= lastBar
                int kb = f_idx(b)
                int ke = f_idx(b + H)
                float zEnd = (aClose.get(ke) - aClose.get(kb)) / aAtr.get(kb)
                nEval += 1
                held += zEnd >= tLo.get(s) and zEnd <= tHi.get(s) ? 1 : 0
                for p = 0 to 2
                    hits.set(p, hits.get(p) + (aUp.get(ke) >= tU.get(s * 3 + p) ? 1 : 0) + (aDn.get(ke) <= tD.get(s * 3 + p) ? 1 : 0))

    if not na(fc)
        // Clouds: one closed, curved shape per zone, from the current close to the last candle and back
        if showClouds
            for z = (show90 ? 0 : 1) to 2
                int qLo = z
                int qHi = 6 - z
                int tr = z == 0 ? 88 : z == 1 ? 80 : 68
                array<chart.point> pts = array.new<chart.point>()
                pts.push(chart.point.from_index(oX, oC))
                for h = 1 to H
                    pts.push(chart.point.from_index(oX + h, f_y(fc.band, qHi, h)))
                for h = H to 1
                    pts.push(chart.point.from_index(oX + h, f_y(fc.band, qLo, h)))
                polys.push(polyline.new(pts, curved=true, closed=true, line_color=color.new(cloudColor, 100), fill_color=color.new(cloudColor, tr)))

        if showPath
            array<chart.point> mid = array.new<chart.point>()
            mid.push(chart.point.from_index(oX, oC))
            for h = 1 to H
                mid.push(chart.point.from_index(oX + h, f_y(fc.band, 3, h)))
            polys.push(polyline.new(mid, curved=true, closed=false, line_color=cloudColor, line_style=line.style_dotted, line_width=2))

        // Touch levels
        if showTouch
            for p = 0 to 2
                int pct = math.round(probs.get(p) * 100)
                float yU = oC + fc.up.get(p) * oA
                float yD = oC + fc.dn.get(p) * oA
                lns.push(line.new(oX, yU, oX + H, yU, color=color.new(upColor, 25), style=line.style_dashed, width=1))
                lns.push(line.new(oX, yD, oX + H, yD, color=color.new(dnColor, 25), style=line.style_dashed, width=1))
                lbls.push(label.new(oX + H, yU, "↑ " + str.tostring(pct) + "% · " + f_px(yU), style=label.style_label_left, color=color.new(upColor, 100), textcolor=upColor, size=size.small, tooltip=str.tostring(pct) + "% chance that price touches " + f_px(yU) + " (" + f_mv(yU) + ") within the next " + str.tostring(H) + " candles."))
                lbls.push(label.new(oX + H, yD, "↓ " + str.tostring(pct) + "% · " + f_px(yD), style=label.style_label_left, color=color.new(dnColor, 100), textcolor=dnColor, size=size.small, tooltip=str.tostring(pct) + "% chance that price touches " + f_px(yD) + " (" + f_mv(yD) + ") within the next " + str.tostring(H) + " candles."))

        // Trade plan, drawn like TradingView's position tool
        if showPlan and fc.oOn
            float pxE = f_planPx(fc.oE)
            float pxS = f_planPx(fc.oS)
            float pxT = f_planPx(fc.oT)
            bxs.push(box.new(oX + 1, math.max(pxE, pxT), oX + H, math.min(pxE, pxT), border_color=color.new(#1be5a4, 40), bgcolor=color.new(#1be5a4, 82), text="TARGET " + f_rateNa(fc.oWin), text_size=size.small, text_color=chart.fg_color, text_halign=text.align_left, text_valign=planSide == "Long" ? text.align_top : text.align_bottom))
            bxs.push(box.new(oX + 1, math.max(pxE, pxS), oX + H, math.min(pxE, pxS), border_color=color.new(#f4362a, 40), bgcolor=color.new(#f4362a, 82), text="STOP " + f_rateNa(fc.oLoss), text_size=size.small, text_color=chart.fg_color, text_halign=text.align_left, text_valign=planSide == "Long" ? text.align_bottom : text.align_top))

        // Frozen order: where it filled and how it ended
        if frozen and fc.oOn
            if not na(fillB) and fillB > fzBar
                lbls.push(label.new(fillB, f_planPx(fc.oE), "FILLED", style=planSide == "Long" ? label.style_label_up : label.style_label_down, color=color.new(cloudColor, 0), textcolor=color.white, size=size.tiny))
            if not na(resB)
                bool won = res == 1
                lbls.push(label.new(resB, f_planPx(won ? fc.oT : fc.oS), won ? "✓ TARGET" : "✗ STOP", style=(planSide == "Long") == won ? label.style_label_down : label.style_label_up, color=won ? #1be5a4 : #f4362a, textcolor=color.black, size=size.tiny))

    // Table
    if showTable
        color hdrBg = color.new(#1e222d, 0)
        color rowBg = color.new(#131722, 10)
        color txt   = color.white
        color dim   = color.white   // light text everywhere: these charts are usually dark
        string hz   = str.tostring(H) + (H == 1 ? " candle" : " candles")
        tbl.cell(0, 0, frozen ? "☁ Probability Clouds · frozen at " + str.format_time(fzTime, "yyyy-MM-dd", syminfo.timezone) + " · " + str.tostring(math.min(bar_index - fzBar, H)) + " of " + hz : "☁ Probability Clouds · next " + hz, text_color=txt, bgcolor=hdrBg, text_size=tblSize, tooltip="Where price is likely to be over the next " + hz + ", learned from this chart's history. Ranges, not direction.")
        tbl.merge_cells(0, 0, 2, 0)
        int r = 1
        if na(fc)
            tbl.cell(0, r, "Not enough history yet: needs about " + str.tostring(WARMUP + MIN_CAND + H + 1) + " candles.", text_color=dim, bgcolor=rowBg, text_size=tblSize)
            tbl.merge_cells(0, r, 2, r)
        else
            bool full = tableMode == "Full"
            // Zones where the close of the last cloud candle lands
            for z = (full ? 2 : 1) to (full ? 0 : 1)
                int qLo = z
                int qHi = 6 - z
                string zn = z == 2 ? "50%" : z == 1 ? "80%" : "90%"
                float lo = f_y(fc.band, qLo, H)
                float hi = f_y(fc.band, qHi, H)
                tbl.cell(0, r, "Closes in " + zn + " zone", text_color=txt, bgcolor=rowBg, text_halign=text.align_left, text_size=tblSize, tooltip=zn + " of the time, the close " + hz + " from now landed inside this range.")
                tbl.cell(1, r, f_px(lo) + " – " + f_px(hi), text_color=cloudColor, bgcolor=rowBg, text_size=tblSize)
                tbl.cell(2, r, f_mv(lo) + " / " + f_mv(hi), text_color=dim, bgcolor=rowBg, text_size=tblSize)
                r += 1
            float med = f_y(fc.band, 3, H)
            tbl.cell(0, r, "Most likely close", text_color=txt, bgcolor=rowBg, text_halign=text.align_left, text_size=tblSize, tooltip="The middle of the cloud: half of the time the close landed above it, half below.")
            tbl.cell(1, r, f_px(med), text_color=cloudColor, bgcolor=rowBg, text_size=tblSize)
            tbl.cell(2, r, f_mv(med), text_color=dim, bgcolor=rowBg, text_size=tblSize)
            r += 1
            for p = 0 to 2
                if full or p == 1
                    int pct = math.round(probs.get(p) * 100)
                    float yU = oC + fc.up.get(p) * oA
                    float yD = oC + fc.dn.get(p) * oA
                    tbl.cell(0, r, "Touches ↑ / ↓ (" + str.tostring(pct) + "%)", text_color=txt, bgcolor=rowBg, text_halign=text.align_left, text_size=tblSize, tooltip=str.tostring(pct) + "% chance that price reaches each level (a wick is enough) within the next " + hz + ".")
                    tbl.cell(1, r, f_px(yU) + " / " + f_px(yD), text_color=txt, bgcolor=rowBg, text_size=tblSize)
                    tbl.cell(2, r, f_mv(yU) + " / " + f_mv(yD), text_color=dim, bgcolor=rowBg, text_size=tblSize)
                    r += 1
            if full
                string lean = fc.pUp >= 0.57 ? "leaning up" : fc.pUp <= 0.43 ? "leaning down" : "neutral"
                tbl.cell(0, r, "Closes higher", text_color=txt, bgcolor=rowBg, text_halign=text.align_left, text_size=tblSize, tooltip="Share of similar past moments (blended with all history) that closed higher " + hz + " later. In the tests this was close to a coin flip: use the clouds for ranges, not as a buy or sell signal.")
                tbl.cell(1, r, f_rate(fc.pUp), text_color=txt, bgcolor=rowBg, text_size=tblSize)
                tbl.cell(2, r, lean, text_color=dim, bgcolor=rowBg, text_size=tblSize)
                r += 1
            // Trade odds
            if fc.oOn
                bool mkt = planEntry == "At close (now)"
                float pxE = f_planPx(fc.oE)
                float pxS = f_planPx(fc.oS)
                float pxT = f_planPx(fc.oT)
                string how = mkt ? "enter now" : "limit at " + str.replace(str.replace(planEntry, "Limit at ", ""), " level", "") + " level"
                tbl.cell(0, r, planSide + " plan · " + how + " · stop " + str.tostring(planStop) + " / target " + str.tostring(planTgt) + " ATR", text_color=txt, bgcolor=hdrBg, text_halign=text.align_left, text_size=tblSize, tooltip="The planned trade replayed on the same similar past moments, over the next " + hz + ". Change it in Settings → 4 · Trade odds.")
                tbl.merge_cells(0, r, 2, r)
                r += 1
                tbl.cell(0, r, "Entry fills", text_color=txt, bgcolor=rowBg, text_halign=text.align_left, text_size=tblSize, tooltip="How often price reached the entry within the next " + hz + ".")
                tbl.cell(1, r, f_rateNa(fc.oFill), text_color=txt, bgcolor=rowBg, text_size=tblSize)
                tbl.cell(2, r, f_px(pxE) + " (" + f_mv(pxE) + ")", text_color=dim, bgcolor=rowBg, text_size=tblSize)
                r += 1
                tbl.cell(0, r, "Target first", text_color=txt, bgcolor=rowBg, text_halign=text.align_left, text_size=tblSize, tooltip="Once filled: how often the target came before the stop.")
                tbl.cell(1, r, f_rateNa(fc.oWin), text_color=#1be5a4, bgcolor=rowBg, text_size=tblSize)
                tbl.cell(2, r, f_px(pxT) + " (" + f_mv(pxT) + ")", text_color=dim, bgcolor=rowBg, text_size=tblSize)
                r += 1
                tbl.cell(0, r, "Stop first", text_color=txt, bgcolor=rowBg, text_halign=text.align_left, text_size=tblSize, tooltip="Once filled: how often the stop came before the target. A candle that touches both counts as stop.")
                tbl.cell(1, r, f_rateNa(fc.oLoss), text_color=#f4362a, bgcolor=rowBg, text_size=tblSize)
                tbl.cell(2, r, f_px(pxS) + " (" + f_mv(pxS) + ")", text_color=dim, bgcolor=rowBg, text_size=tblSize)
                r += 1
                tbl.cell(0, r, "Neither in " + hz, text_color=txt, bgcolor=rowBg, text_halign=text.align_left, text_size=tblSize, tooltip="Once filled: still open when the cloud ends.")
                tbl.cell(1, r, na(fc.oWin) ? "–" : f_rate(math.max(1 - fc.oWin - fc.oLoss, 0)), text_color=txt, bgcolor=rowBg, text_size=tblSize)
                tbl.cell(2, r, "", bgcolor=rowBg)
                r += 1
                if frozen
                    tbl.cell(0, r, "Order status", text_color=txt, bgcolor=rowBg, text_halign=text.align_left, text_size=tblSize, tooltip="The frozen plan replayed on the real candles after the frozen one, with the same rules as the odds. The current candle counts as it is now.")
                    tbl.cell(1, r, fzStatus, text_color=res == 1 ? #1be5a4 : res == -1 ? #f4362a : color.yellow, bgcolor=rowBg, text_size=tblSize)
                    tbl.merge_cells(1, r, 2, r)
                    r += 1
                tbl.cell(0, r, "Result per $ risked", text_color=txt, bgcolor=rowBg, text_halign=text.align_left, text_size=tblSize, tooltip="Average result of the filled trades, in units of what the stop risks (+1 = won as much as the risk). Trades still open are valued at the last candle's close. Fees not included. Near 0 = a fair bet: the odds help you size and place orders, they do not create an edge.")
                tbl.cell(1, r, na(fc.oR) ? "–" : (fc.oR >= 0 ? "+" : "") + str.tostring(fc.oR, "0.00"), text_color=na(fc.oR) ? txt : fc.oR >= 0 ? #1be5a4 : #f4362a, bgcolor=rowBg, text_size=tblSize)
                tbl.cell(2, r, "reward:risk 1:" + str.tostring(planTgt / planStop, "0.0#"), text_color=dim, bgcolor=rowBg, text_size=tblSize)
                r += 1
            // Track record
            if trackN > 0 and nEval > 0
                bool fewEval = nEval < 50
                color trTxt = fewEval ? color.orange : txt
                tbl.cell(0, r, "Track record (" + str.tostring(nEval) + ")", text_color=trTxt, bgcolor=hdrBg, text_halign=text.align_left, text_size=tblSize, tooltip="The last " + str.tostring(nEval) + " candles of this chart were forecast again with only the data available at the time, and checked " + hz + " later." + (fewEval ? " Fewer than 50 forecasts: not reliable yet." : ""))
                tbl.cell(1, r, "80% zone held " + f_rate(held / (1.0 * nEval)), text_color=trTxt, bgcolor=hdrBg, text_size=tblSize, tooltip="Should be close to 80%. Much lower = this market is moving more than its history suggests: give the clouds extra room.")
                tbl.cell(2, r, "50% touch hit " + f_rate(hits.get(1) / (2.0 * nEval)), text_color=trTxt, bgcolor=hdrBg, text_size=tblSize, tooltip="Should be close to " + str.tostring(math.round(probs.get(1) * 100)) + "%." + (full ? "" : " Switch the table to Full to see every level."))
                r += 1
                if full
                    string allHits = ""
                    for p = 0 to 2
                        allHits += (p > 0 ? " · " : "") + str.tostring(math.round(probs.get(p) * 100)) + "% → " + f_rate(hits.get(p) / (2.0 * nEval))
                    tbl.cell(0, r, "Touch levels: expected → real", text_color=trTxt, bgcolor=hdrBg, text_halign=text.align_left, text_size=tblSize)
                    tbl.cell(1, r, allHits, text_color=trTxt, bgcolor=hdrBg, text_size=tblSize)
                    tbl.merge_cells(1, r, 2, r)
                    r += 1
            tbl.cell(0, r, "Learned from " + str.tostring(fc.nCand) + " candles · " + str.tostring(fc.nNb) + " similar", text_color=dim, bgcolor=rowBg, text_halign=text.align_left, text_size=size.tiny)
            tbl.merge_cells(0, r, 2, r)
````
