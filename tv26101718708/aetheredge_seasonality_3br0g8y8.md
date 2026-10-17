# AetherEdge - Seasonality

- url: https://www.tradingview.com/script/3Br0G8Y8/
- type: indicator
- pine_id: PUB;a05a635e01fa49a282d8c7ddfa4a1cff
- version: 1.0

## Description

🖊️ Overview

Seasonality tools show raw averages and let you fool yourself with three-sample "edges." AE-SEAS measures the time-of-day / day-of-week / month return profile properly, with significance. It learns each bucket's mean return, win-rate, sample count and t-stat, and shrinks small-sample buckets toward the global mean (empirical Bayes) to prevent overfitting — answering "which time periods have a real edge" with data.

🔶 Key Features

Time-of-period profiles — learned mean return and win-rate by hour / weekday / month
Significance (t-stat) — separates a real edge from noise (don't trust raw averages)
Empirical-Bayes shrinkage — small-sample buckets shrink toward the global mean (anti-overfitting)
Current-bucket bias — the shrunk expected return, win-rate and significance for the bucket you're in
Heatmap table — all buckets at a glance, current one highlighted
Signals + alerts on entering a significant-edge bucket; bar-close accumulation — no repaint

🧠 Technical Architecture

Bucket statistics: each time bucket (hour 0–23 / weekday / month) accumulates the bar's return, yielding mean, variance, sample count, win-rate and a t-stat (mean ÷ standard error). Larger |t| = a less-likely-to-be-chance edge.
ML (empirical-Bayes shrinkage = regularized estimation): shrunk mean = global mean + (bucket mean − global mean) × n/(n+k). Low-sample buckets shrink hard toward the global mean; well-sampled buckets approach the raw value. This stops a five-sample bucket from masquerading as a strong signal — regularized estimation, not raw counting, is the "ML."
Timezone: buckets are computed in the selected timezone (Exchange / UTC / NY / London / Tokyo).
Honest scope: regularized per-bucket statistics (empirical-Bayes shrinkage + t-test) (no RL). Not deep learning, not a guarantee.

⚙️ Recommended Settings & Tuning Guide (crypto 15m–4H)

Key parameters: active profile (hour/weekday/month), timezone, shrinkage strength k, significance threshold |t|, min samples.
Profile: "Hour" for crypto intraday, "Weekday" for weekly tendencies, "Month" for the long run (higher timeframes)
Timezone: UTC is standard for crypto; exchange TZ for equities
Higher shrinkage k pulls small samples harder toward the global mean (conservative)
Significance |t| defaults to 2.0 (≈95%); use 2.5–3.0 to be stricter
Longer history / timeframe means more samples per bucket and higher reliability

💡 How to Use in Practice

Use the heatmap table to spot hours/days with a large mean and a ✦ (significant)
Reference the current-bucket bias as the backdrop for the period you're in
Treat entering a significant bull/bear bucket as a trend/caution cue
Ignore buckets with low sample count (n) or small t
Combine with AE-VOL (volatility) or AE-CVD (flow) to layer time × context

⚠️ Important Notes

Seasonality is a historical tendency with no guarantee of persistence (structural shifts break it)
Low-sample buckets remain uncertain even after shrinkage (always check n and t)
Needs a learning period (warmup) and ample history; accumulation resets on timeframe/timezone change
Probability, not a guarantee — always do your own due diligence and use risk management

🚨 Disclaimer

This indicator is for educational and informational purposes only and is not financial advice or a recommendation to buy or sell. No method guarantees future profits; past performance does not indicate future results, and trading carries the risk of loss. All decisions are your own — use proper validation and disciplined risk management.

## Source Code

````pine
// ============================================================================
//  AetherEdge - Seasonality  (AE-SEAS)  |  AetherEdge Series
//  Which hours, days and months actually have an edge -- with significance
//
//  Seasonality tools show raw averages and let you fool yourself with three-
//  sample "edges." AE-SEAS measures the time-of-day / day-of-week / month
//  return profile properly:
//
//    * STATS : for every time bucket it accumulates mean return, win-rate,
//      sample count and a t-STATISTIC, so you can tell a real edge from noise.
//    * SHRINKAGE : small-sample buckets are pulled toward the global mean by
//      EMPIRICAL-BAYES shrinkage (weight n/(n+k)), so a bucket with five prints
//      can't masquerade as a strong signal. This is the "ML" -- regularized
//      estimation, not raw counting.
//
//  Outputs a heatmap profile table (current bucket highlighted), the current
//  bucket's shrunk expected return, win-rate and significance, and a seasonal
//  bias when the edge clears a t-threshold. Honest scope: regularized per-bucket
//  statistics -- not a neural net, not a guarantee, no RL. Accumulation gates on
//  bar close.
// ============================================================================

//@version=6
indicator("AetherEdge - Seasonality", "AE-SEAS", overlay = true)

// ----------------------------------------------------------------------------
//  THEME
// ----------------------------------------------------------------------------
cGold = #d4af37
cBg0  = #080b0a
cBg1  = #0f1614
cTxt  = #eef2f0
cBull = #26a69a
cBear = #ef5350
cWait = #8d99a6
cViolet = #b06fd6

// ----------------------------------------------------------------------------
//  INPUTS
// ----------------------------------------------------------------------------
grpS = "Seasonality"
profile = input.string("Hour", "Active profile", options = ["Hour","Weekday","Month"], group = grpS)
tzSel = input.string("UTC", "Timezone", options = ["Exchange","UTC","America/New_York","Europe/London","Asia/Tokyo"], group = grpS)
kShrink = input.float(30.0, "Shrinkage strength k", minval = 0.0, step = 5.0, group = grpS)
tThr = input.float(2.0, "Significance |t| >=", minval = 0.0, step = 0.1, group = grpS)
minN = input.int(20, "Min samples for bias", minval = 1, group = grpS)
warmup = input.int(200, "Warmup bars", minval = 30, group = grpS)

grpUI = "Display"
showSig = input.bool(true, "Show seasonal bias signals", group = grpUI)
showHUD = input.bool(true, "Show profile table", group = grpUI)
hudSize = input.string("tiny", "Table size", options = ["tiny","small","normal","large"], group = grpUI)
tblPos = input.string("top_right", "Table position", options = ["top_right","top_left","bottom_right","bottom_left","middle_right"], group = grpUI)

// ----------------------------------------------------------------------------
//  HELPERS
// ----------------------------------------------------------------------------
f_clamp(float x, float lo, float hi) => math.max(lo, math.min(hi, x))
f_txtSize() => hudSize == "tiny" ? size.tiny : hudSize == "small" ? size.small : hudSize == "large" ? size.large : size.normal
f_pos() => tblPos == "top_left" ? position.top_left : tblPos == "bottom_right" ? position.bottom_right : tblPos == "bottom_left" ? position.bottom_left : tblPos == "middle_right" ? position.middle_right : position.top_right

f_wdName(int i) => i == 0 ? "Sun" : i == 1 ? "Mon" : i == 2 ? "Tue" : i == 3 ? "Wed" : i == 4 ? "Thu" : i == 5 ? "Fri" : "Sat"
f_moName(int i) => i == 0 ? "Jan" : i == 1 ? "Feb" : i == 2 ? "Mar" : i == 3 ? "Apr" : i == 4 ? "May" : i == 5 ? "Jun" : i == 6 ? "Jul" : i == 7 ? "Aug" : i == 8 ? "Sep" : i == 9 ? "Oct" : i == 10 ? "Nov" : "Dec"
f_label(int i) => profile == "Hour" ? (str.tostring(i) + ":00") : profile == "Weekday" ? f_wdName(i) : f_moName(i)

// ----------------------------------------------------------------------------
//  TIME BUCKETS
// ----------------------------------------------------------------------------
tz = tzSel == "Exchange" ? syminfo.timezone : tzSel
hr = hour(time, tz)
dw = dayofweek(time, tz) - 1
mo = month(time, tz) - 1

// ----------------------------------------------------------------------------
//  PER-BUCKET ACCUMULATORS  (count / sum / sumSq / positive)
// ----------------------------------------------------------------------------
var array<float> hCount = array.new_float(24, 0.0)
var array<float> hSum = array.new_float(24, 0.0)
var array<float> hSq = array.new_float(24, 0.0)
var array<float> hPos = array.new_float(24, 0.0)
var array<float> dCount = array.new_float(7, 0.0)
var array<float> dSum = array.new_float(7, 0.0)
var array<float> dSq = array.new_float(7, 0.0)
var array<float> dPos = array.new_float(7, 0.0)
var array<float> mCount = array.new_float(12, 0.0)
var array<float> mSum = array.new_float(12, 0.0)
var array<float> mSq = array.new_float(12, 0.0)
var array<float> mPos = array.new_float(12, 0.0)
var float gSum = 0.0
var float gCount = 0.0

f_acc(array<float> cnt, array<float> sm, array<float> sq, array<float> ps, int b, float r) =>
    array.set(cnt, b, array.get(cnt, b) + 1.0)
    array.set(sm, b, array.get(sm, b) + r)
    array.set(sq, b, array.get(sq, b) + r * r)
    array.set(ps, b, array.get(ps, b) + (r > 0.0 ? 1.0 : 0.0))

ret = nz((close / close[1] - 1.0) * 100.0, 0.0)
if barstate.isconfirmed and bar_index > 1
    f_acc(hCount, hSum, hSq, hPos, hr, ret)
    f_acc(dCount, dSum, dSq, dPos, dw, ret)
    f_acc(mCount, mSum, mSq, mPos, mo, ret)
    gSum += ret
    gCount += 1.0

gMean = gCount > 0.0 ? gSum / gCount : 0.0

// active profile references
nB = profile == "Hour" ? 24 : profile == "Weekday" ? 7 : 12
actCount = profile == "Hour" ? hCount : profile == "Weekday" ? dCount : mCount
actSum = profile == "Hour" ? hSum : profile == "Weekday" ? dSum : mSum
actSq = profile == "Hour" ? hSq : profile == "Weekday" ? dSq : mSq
actPos = profile == "Hour" ? hPos : profile == "Weekday" ? dPos : mPos
int curB = profile == "Hour" ? hr : profile == "Weekday" ? dw : mo

// stats for one bucket
f_mean(array<float> cnt, array<float> sm, int b) =>
    n = array.get(cnt, b)
    n > 0.0 ? array.get(sm, b) / n : 0.0

f_shrunk(array<float> cnt, array<float> sm, int b) =>
    n = array.get(cnt, b)
    mu = n > 0.0 ? array.get(sm, b) / n : gMean
    gMean + (mu - gMean) * n / (n + kShrink)

f_tstat(array<float> cnt, array<float> sm, array<float> sq, int b) =>
    n = array.get(cnt, b)
    float t = 0.0
    if n > 1.0
        mu = array.get(sm, b) / n
        v = math.max(array.get(sq, b) / n - mu * mu, 0.0)
        se = math.sqrt(v) / math.sqrt(n)
        t := mu / math.max(se, 1e-8)
    t

// ----------------------------------------------------------------------------
//  CURRENT BUCKET BIAS
// ----------------------------------------------------------------------------
curShrunk = f_shrunk(actCount, actSum, curB)
curN = array.get(actCount, curB)
curWin = curN > 0.0 ? array.get(actPos, curB) / curN * 100.0 : na
curT = f_tstat(actCount, actSum, actSq, curB)
warmOK = bar_index > warmup

sigEdge = warmOK and curN >= minN and math.abs(curT) >= tThr
longSeas = sigEdge and curShrunk > 0.0
shortSeas = sigEdge and curShrunk < 0.0
newBucket = curB != curB[1]

bullSig = showSig and longSeas and newBucket
bearSig = showSig and shortSeas and newBucket

plotshape(bullSig ? low : na, "Seasonal long", shape.triangleup, location.belowbar, color.new(cBull, 0), size = size.small)
plotshape(bearSig ? high : na, "Seasonal short", shape.triangledown, location.abovebar, color.new(cBear, 0), size = size.small)

// ----------------------------------------------------------------------------
//  PROFILE TABLE (heatmap)
// ----------------------------------------------------------------------------
f_heat(float mu) =>
    a = f_clamp(85.0 - math.abs(mu) * 220.0, 20.0, 88.0)
    mu >= 0.0 ? color.new(cBull, int(a)) : color.new(cBear, int(a))

var table tbl = table.new(f_pos(), 5, 27, bgcolor = cBg1, frame_color = cGold, frame_width = 2, border_color = color.new(cGold, 75), border_width = 1)
if showHUD and barstate.islast
    ts = f_txtSize()
    table.cell(tbl, 0, 0, "AE-SEAS", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(tbl, 1, 0, "Mean%", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(tbl, 2, 0, "Win%", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(tbl, 3, 0, "n", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(tbl, 4, 0, "t", text_color = cGold, bgcolor = cBg0, text_size = ts)
    for i = 0 to nB - 1
        n = array.get(actCount, i)
        mu = f_shrunk(actCount, actSum, i)
        wr = n > 0.0 ? array.get(actPos, i) / n * 100.0 : na
        tv = f_tstat(actCount, actSum, actSq, i)
        isCur = i == curB
        lblCol = isCur ? cGold : cTxt
        rowBg = isCur ? color.new(cViolet, 70) : na
        table.cell(tbl, 0, i + 1, f_label(i), text_color = lblCol, bgcolor = rowBg, text_size = ts)
        table.cell(tbl, 1, i + 1, str.tostring(mu, "#.###"), text_color = cBg0, bgcolor = f_heat(mu), text_size = ts)
        table.cell(tbl, 2, i + 1, na(wr) ? "-" : str.tostring(math.round(wr)), text_color = na(wr) ? cWait : wr >= 50.0 ? cBull : cBear, bgcolor = rowBg, text_size = ts)
        table.cell(tbl, 3, i + 1, str.tostring(int(n)), text_color = cWait, bgcolor = rowBg, text_size = ts)
        table.cell(tbl, 4, i + 1, math.abs(tv) >= tThr ? "✦" : str.tostring(tv, "#.#"), text_color = math.abs(tv) >= tThr ? cGold : cWait, bgcolor = rowBg, text_size = ts)

// ----------------------------------------------------------------------------
//  HUD SUMMARY (compact, separate table)
// ----------------------------------------------------------------------------
biasTxt = longSeas ? "LONG" : shortSeas ? "SHORT" : "—"
biasCol = longSeas ? cBull : shortSeas ? cBear : cWait
var table sb = table.new(tblPos == "top_left" or tblPos == "bottom_left" ? position.bottom_left : position.bottom_right, 2, 6, bgcolor = cBg1, frame_color = cGold, frame_width = 2, border_color = color.new(cGold, 60), border_width = 1)
if showHUD and barstate.islast
    ts = f_txtSize()
    table.cell(sb, 0, 0, "Now: " + f_label(curB), text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(sb, 1, 0, biasTxt, text_color = biasCol, bgcolor = cBg0, text_size = ts)
    table.cell(sb, 0, 1, "Exp return", text_color = cTxt, text_size = ts)
    table.cell(sb, 1, 1, (curShrunk >= 0 ? "+" : "") + str.tostring(curShrunk, "#.###") + "%", text_color = curShrunk >= 0 ? cBull : cBear, text_size = ts)
    table.cell(sb, 0, 2, "Win rate", text_color = cTxt, text_size = ts)
    table.cell(sb, 1, 2, na(curWin) ? "-" : str.tostring(math.round(curWin)) + "%", text_color = cTxt, text_size = ts)
    table.cell(sb, 0, 3, "Significance t", text_color = cTxt, text_size = ts)
    table.cell(sb, 1, 3, str.tostring(curT, "#.##") + (math.abs(curT) >= tThr ? " ✦" : ""), text_color = math.abs(curT) >= tThr ? cGold : cWait, text_size = ts)
    table.cell(sb, 0, 4, "Samples", text_color = cTxt, text_size = ts)
    table.cell(sb, 1, 4, str.tostring(int(curN)), text_color = cWait, text_size = ts)
    table.cell(sb, 0, 5, "Profile", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(sb, 1, 5, warmOK ? profile : "learning", text_color = warmOK ? cTxt : cWait, bgcolor = cBg0, text_size = ts)

// ----------------------------------------------------------------------------
//  ALERTS
// ----------------------------------------------------------------------------
alertcondition(bullSig, "AE-SEAS Seasonal long", "AE-SEAS: entering a bucket with a significant bullish seasonal edge")
alertcondition(bearSig, "AE-SEAS Seasonal short", "AE-SEAS: entering a bucket with a significant bearish seasonal edge")
````
