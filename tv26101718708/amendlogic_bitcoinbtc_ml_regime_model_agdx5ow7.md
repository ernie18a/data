# [AmendLogic] Bitcoin/BTC ML Regime Model

- url: https://www.tradingview.com/script/aGdx5oW7-AmendLogic-Bitcoin-BTC-ML-Regime-Model/
- type: indicator
- pine_id: PUB;5e6b5b36d1b34a898101502b1cb5a3bd
- version: 1.0

## Description

The Bitcoin/BTC ML Regime Model is a machine learning inspired regime detection indicator designed to estimate the probability of future bullish or bearish market conditions.

Unlike traditional indicators that rely on a single technical signal, this model combines multiple market features, macroeconomic inputs, and adaptive learning techniques to evaluate the current Bitcoin market environment.

[b]How it works[/b]
The model continuously learns from historical price behavior using a walk-forward logistic regression approach. It evaluates a set of normalized features including:

[list]
[*]Short, medium, and long-term momentum
[*]RSI
[*]Distance from trend averages
[*]Volume behavior
[*]Volatility conditions
[*]U.S. Dollar Index (DXY)
[*]Treasury Inflation-Protected Securities (TIP)
[*]Higher timeframe trend structure
[/list]

These factors are combined into a probability score representing the estimated likelihood of upward price movement over a user-defined prediction horizon.

[b]Reliability Management[/b]
Machine learning models may underperform during changing market conditions. To address this, the indicator includes:

[list]
[*]Minimum training sample requirements
[*]Rolling hit-rate evaluation
[*]Automatic confidence validation
[*]Fallback regime logic when model reliability drops below a user-defined threshold
[/list]

This approach helps distinguish between periods where the model is performing acceptably and periods where additional caution may be warranted.

[b]Optional Demand Sensing Layer[/b]
An optional demand sensing component can be enabled to increase responsiveness to short-term momentum and volume shifts.

This layer acts as a supplementary heuristic filter and can be blended with the main model output through a configurable weighting system.

[b]Risk Filters[/b]
The indicator includes several safeguards designed to reduce noise:

[list]
[*]Anomaly detection based on abnormal price, volume, or volatility behavior
[*]Trend alignment filter using a higher-timeframe EMA
[*]Entry and exit hysteresis thresholds
[*]Minimum holding period logic
[/list]

[b]Visual Features[/b]
The script provides:

[list]
[*]Dynamic probability visualization
[*]Long, short, and neutral regime detection
[*]Price chart regime background coloring
[*]Long and short entry markers
[*]Model reliability monitoring
[*]Feature contribution analysis
[*]Real-time status dashboard
[/list]

[b]Information Display[/b]
The dashboard shows:

[list]
[*]Current operating mode (ML or fallback)
[*]Training sample count
[*]Historical hit rate
[*]Upside probability estimates
[*]Active anomaly status
[*]Dominant market drivers
[*]Current regime state
[/list]

[b]Interpretation[/b]
[list]
[*]Higher probability values indicate stronger bullish conditions according to the model.
[*]Lower probability values indicate stronger bearish conditions.
[*]Values near 50% indicate uncertainty or balanced market conditions.
[*]Long and short signals are generated only when probability thresholds and risk filters align.
[/list]

[b]Important[/b]
This indicator is designed for educational and analytical purposes only.

It does not predict future prices with certainty and should not be considered financial advice. All trading involves risk, and past performance of any model does not guarantee future results.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AmendLogic
//@version=6
indicator("[AmendLogic] Bitcoin/BTC ML Regime Model", overlay=false, max_bars_back=500)

// === Inputs ===
grpM = "Model"
H       = input.int(6, "Prediction horizon (bars)", minval=1, maxval=48, group=grpM)
K       = input.int(5, "Replay samples per bar", minval=1, maxval=20, group=grpM)
lr      = input.float(0.01, "Learning rate", minval=0.0001, step=0.001, group=grpM)
l2      = input.float(0.001, "L2 regularization", minval=0.0, step=0.0005, group=grpM)
zLen    = input.int(200, "Feature normalization length", minval=50, group=grpM)
minSamples = input.int(500, "Cold start: min training samples", minval=50, group=grpM)
hitLen  = input.int(100, "Reliability window (resolved predictions)", minval=20, group=grpM)
minHit  = input.float(0.52, "Min hit rate to trust the model", minval=0.4, maxval=0.7, step=0.01, group=grpM)

grpS = "Demand sensing (short-term layer)"
useSensing = input.bool(false, "Enable Demand Sensing (Heuristic Layer)", group=grpS)
wSense = input.float(0.15, "Weight of sensing layer", minval=0.0, maxval=0.5, step=0.05, group=grpS)

grpG = "Signals"
longThr  = input.float(0.58, "Long entry: P(up) >=", minval=0.5, maxval=0.9, step=0.01, group=grpG)
shortThr = input.float(0.42, "Short entry: P(up) <=", minval=0.1, maxval=0.5, step=0.01, group=grpG)
exitLong  = input.float(0.52, "Long exit: P(up) <", minval=0.4, maxval=0.7, step=0.01, group=grpG)
exitShort = input.float(0.48, "Short exit: P(up) >", minval=0.3, maxval=0.6, step=0.01, group=grpG)
reqTrend = input.bool(true, "Require daily trend (200 EMA) in trade direction", group=grpG)
minHold  = input.int(6, "Minimum hold (bars)", minval=0, group=grpG)

grpA = "Anomaly guard"
anomZ = input.float(3.0, "Anomaly threshold (z-score)", minval=2.0, step=0.5, group=grpA)

grpD = "Display"
showParts = input.bool(true, "Show model and sensing lines", group=grpD)
showHit   = input.bool(true, "Show hit rate line", group=grpD)
showBgPx  = input.bool(true, "Regime background on price chart", group=grpD)

// === Helper functions ===
f_sig(z) => 1.0 / (1.0 + math.exp(-math.max(-20.0, math.min(20.0, z))))
f_clip(x) => math.max(-3.0, math.min(3.0, nz(x)))
f_z(x, len) =>
    mu = ta.sma(x, len)
    sd = ta.stdev(x, len)
    sd > 0 ? (x - mu) / sd : 0.0
f_col(d) => d == 1 ? color.green : d == -1 ? color.red : color.gray

// === Continuous Macro Data (No Step-Functions) ===
// Multiplikator, um Tages-EMAs auf den aktuellen Chart-Timeframe umzurechnen (z.B. 8h -> x3)
tfMult = math.max(1, 86400 / timeframe.in_seconds(timeframe.period))

dxyClose = request.security("TVC:DXY", "", close)
tipClose = request.security("AMEX:TIP", "", close)

dxyEmaLen = math.round(50 * tfMult)
tipEmaLen = math.round(50 * tfMult)
pxEmaLen  = math.round(200 * tfMult)

dxRatio  = (dxyClose[1] / ta.ema(dxyClose, dxyEmaLen)[1] - 1) * 100
tipRatio = (tipClose[1] / ta.ema(tipClose, tipEmaLen)[1] - 1) * 100
pxRatio  = (close[1] / ta.ema(close, pxEmaLen)[1] - 1) * 100

// === Raw features ===
atrv   = ta.atr(14)
r1raw  = math.log(close / close[1])
r6raw  = math.log(close / close[6])
r21raw = math.log(close / close[21])
rsiv   = ta.rsi(close, 14)
emaD   = (close - ta.ema(close, math.round(50 * tfMult))) / atrv
atrPct = atrv / close

r1z   = f_z(r1raw, zLen)
r6z   = f_z(r6raw, zLen)
r21z  = f_z(r21raw, zLen)
emaDz = f_z(emaD, zLen)
volZ  = f_z(volume, zLen)
atrZ  = f_z(atrPct, zLen)
dxz   = f_z(dxRatio, zLen)
tipz  = f_z(tipRatio, zLen)
pxz   = f_z(pxRatio, zLen)

// === Feature vector ===
f1  = f_clip(r1z)
f2  = f_clip(r6z)
f3  = f_clip(r21z)
f4  = f_clip((rsiv - 50) / 25)
f5  = f_clip(emaDz)
f6  = f_clip(volZ)
f7  = f_clip(f1 * f6 / 3)
f8  = f_clip(atrZ)
f9  = f_clip(f2 * f8 / 3)
f10 = f_clip(dxz)
f11 = f_clip(tipz)
f12 = f_clip(pxz)
f13 = f_clip(f10 * f2 / 3)

N = 13
featNames = array.from("Return 1", "Return 6", "Return 21", "RSI", "Dist. EMA", "Volume", "Signed volume", "Volatility", "Mom x Vol", "DXY", "TIPS", "Daily trend", "DXY x Mom")

// === Unrolled Model State (Extreme Performance Boost) ===
var float w1 = 0.0, var float w2 = 0.0, var float w3 = 0.0, var float w4 = 0.0, var float w5 = 0.0
var float w6 = 0.0, var float w7 = 0.0, var float w8 = 0.0, var float w9 = 0.0, var float w10 = 0.0
var float w11 = 0.0, var float w12 = 0.0, var float w13 = 0.0
var float bias = 0.0
var int nTrain = 0

// === Fast Walk-Forward Training ===
if barstate.isconfirmed and bar_index >= zLen + 30 + H + K
    for k = 0 to K - 1
        // Direkter Variablen-Zugriff statt Array-Allokation in der Schleife
        xk1 = f1[H + k], xk2 = f2[H + k], xk3 = f3[H + k], xk4 = f4[H + k], xk5 = f5[H + k]
        xk6 = f6[H + k], xk7 = f7[H + k], xk8 = f8[H + k], xk9 = f9[H + k], xk10 = f10[H + k]
        xk11 = f11[H + k], xk12 = f12[H + k], xk13 = f13[H + k]
        
        y  = close[k] > close[H + k] ? 1.0 : 0.0
        
        zp = bias + (w1*xk1) + (w2*xk2) + (w3*xk3) + (w4*xk4) + (w5*xk5) + (w6*xk6) + (w7*xk7) + (w8*xk8) + (w9*xk9) + (w10*xk10) + (w11*xk11) + (w12*xk12) + (w13*xk13)
        err = f_sig(zp) - y
        
        bias -= lr * err
        w1  -= lr * (err * xk1 + l2 * w1)
        w2  -= lr * (err * xk2 + l2 * w2)
        w3  -= lr * (err * xk3 + l2 * w3)
        w4  -= lr * (err * xk4 + l2 * w4)
        w5  -= lr * (err * xk5 + l2 * w5)
        w6  -= lr * (err * xk6 + l2 * w6)
        w7  -= lr * (err * xk7 + l2 * w7)
        w8  -= lr * (err * xk8 + l2 * w8)
        w9  -= lr * (err * xk9 + l2 * w9)
        w10 -= lr * (err * xk10 + l2 * w10)
        w11 -= lr * (err * xk11 + l2 * w11)
        w12 -= lr * (err * xk12 + l2 * w12)
        w13 -= lr * (err * xk13 + l2 * w13)
        
    nTrain += 1

// === Prediction ===
zNow = bias + (w1*f1) + (w2*f2) + (w3*f3) + (w4*f4) + (w5*f5) + (w6*f6) + (w7*f7) + (w8*f8) + (w9*f9) + (w10*f10) + (w11*f11) + (w12*f12) + (w13*f13)
pModel = nTrain >= minSamples ? f_sig(zNow) : na

// === Reliability check ===
float resolved = na(pModel[H]) ? na : ((pModel[H] > 0.5) == (close > close[H]) ? 1.0 : 0.0)
hit  = ta.sma(resolved, hitLen)
mlOk = nTrain >= minSamples and not na(hit) and hit >= minHit

// === Fallback (cold start / unreliable model) ===
dTrend = pxRatio > 0 ? 1 : -1
dDx    = dxRatio < 0 ? 1 : -1
dTip   = tipRatio > 0 ? 1 : -1
pFb    = 0.5 + 0.2 * (2 * dTrend + dDx + dTip) / 4.0

// === Optional: Demand sensing ===
pSense = f_sig(0.8 * (f1 + f7) / 2)
pBase  = mlOk ? pModel : pFb
pFinal = useSensing ? ((1.0 - wSense) * pBase + wSense * pSense) : pBase

// === Anomaly guard ===
anom = math.abs(r1z) >= anomZ or volZ >= anomZ or atrZ >= anomZ

// === Signal logic (state machine with hysteresis) ===
longSig   = pFinal >= longThr  and not anom and (not reqTrend or dTrend == 1)
shortSig  = pFinal <= shortThr and not anom and (not reqTrend or dTrend == -1)
longExit  = pFinal < exitLong
shortExit = pFinal > exitShort

var int pos  = 0
var int held = 999
if barstate.isconfirmed
    held += 1
    int newPos = pos
    if pos == 1 and longExit
        newPos := 0
    if pos == -1 and shortExit
        newPos := 0
    if newPos == 0
        if longSig
            newPos := 1
        else if shortSig
            newPos := -1
    if newPos != pos and held >= minHold
        pos  := newPos
        held := 0

longEntry  = pos == 1  and pos[1] != 1
shortEntry = pos == -1 and pos[1] != -1

// === Visuals: pane ===
hline(50, "50%", color.new(color.gray, 50), hline.style_dotted)
pMain = plot(pFinal * 100, "P(up) final", mlOk ? color.new(color.blue, 0) : color.new(color.orange, 0), 2)
pMid  = plot(50, "Mid", display=display.none)
fill(pMain, pMid, pFinal >= 0.5 ? color.new(color.green, 85) : color.new(color.red, 85), "Bias fill")

plot(longThr * 100,  "Long entry",  color.new(color.green, 40), 1, plot.style_line)
plot(shortThr * 100, "Short entry", color.new(color.red, 40),   1, plot.style_line)
plot(exitLong * 100,  "Long exit",  color.new(color.green, 80), 1, plot.style_circles)
plot(exitShort * 100, "Short exit", color.new(color.red, 80),   1, plot.style_circles)

plot(pModel * 100, "P(up) model",   color.new(color.aqua, 30), 1, display=showParts ? display.all : display.none)
plot(pSense * 100, "P(up) sensing", color.new(color.purple, 40), 1, display=showParts ? display.all : display.none)
plot(hit * 100,    "Hit rate %",    color.new(color.yellow, 20), 1, display=showHit ? display.all : display.none)
plot(minHit * 100, "Min hit rate",  color.new(color.yellow, 70), 1, plot.style_circles, display=showHit ? display.all : display.none)

plotshape(anom, "Anomaly", shape.xcross, location.top, color.orange, size=size.tiny)
bgcolor(pos == 1 ? color.new(color.green, 92) : pos == -1 ? color.new(color.red, 92) : na, title="Regime (pane)")

// === Visuals: price chart ===
bgcolor(showBgPx ? (pos == 1 ? color.new(color.green, 92) : pos == -1 ? color.new(color.red, 92) : na) : na, title="Regime (price)", force_overlay=true)
plotshape(longEntry,  "ML Long",  shape.triangleup,   location.belowbar, color.green, size=size.small, text="L", force_overlay=true)
plotshape(shortEntry, "ML Short", shape.triangledown, location.abovebar, color.red,   size=size.small, text="S", force_overlay=true)

// === Table: Rebuild Arrays at barstate.islast for UI ===
var table t = table.new(position.top_right, 2, 10, border_width=1, force_overlay = true)
if barstate.islast
    w = array.from(w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13)
    xNow = array.from(f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12, f13)
    
    float bestA = 0.0
    float secA  = 0.0
    int bi = -1
    int si = -1
    for i = 0 to N - 1
        a = math.abs(array.get(w, i) * array.get(xNow, i))
        if a > bestA
            secA  := bestA
            si    := bi
            bestA := a
            bi    := i
        else if a > secA
            secA := a
            si   := i
    c1 = bi >= 0 ? array.get(w, bi) * array.get(xNow, bi) : 0.0
    c2 = si >= 0 ? array.get(w, si) * array.get(xNow, si) : 0.0

    table.cell(t, 0, 0, "Mode", text_color=color.white, bgcolor=color.gray)
    table.cell(t, 1, 0, mlOk ? "ML model" : "Fallback", text_color=color.white, bgcolor=mlOk ? color.green : color.orange)
    table.cell(t, 0, 1, "Samples", text_color=color.white, bgcolor=color.gray)
    table.cell(t, 1, 1, str.tostring(nTrain), text_color=color.white, bgcolor=color.gray)
    table.cell(t, 0, 2, "Hit rate", text_color=color.white, bgcolor=color.gray)
    table.cell(t, 1, 2, na(hit) ? "n/a" : str.tostring(hit * 100, "#.#") + "%", text_color=color.white, bgcolor=mlOk ? color.green : color.red)
    table.cell(t, 0, 3, "P(up) model", text_color=color.white, bgcolor=color.gray)
    table.cell(t, 1, 3, na(pModel) ? "n/a" : str.tostring(pModel * 100, "#") + "%", text_color=color.white, bgcolor=color.gray)
    table.cell(t, 0, 4, "P(up) sensing", text_color=color.white, bgcolor=color.gray)
    table.cell(t, 1, 4, str.tostring(pSense * 100, "#") + "%", text_color=color.white, bgcolor=color.gray)
    table.cell(t, 0, 5, "P(up) final", text_color=color.white, bgcolor=color.gray)
    table.cell(t, 1, 5, str.tostring(pFinal * 100, "#") + "%", text_color=color.white, bgcolor=f_col(pFinal >= longThr ? 1 : pFinal <= shortThr ? -1 : 0))
    table.cell(t, 0, 6, "Anomaly", text_color=color.white, bgcolor=color.gray)
    table.cell(t, 1, 6, anom ? "YES" : "none", text_color=color.white, bgcolor=anom ? color.orange : color.green)
    table.cell(t, 0, 7, "Driver 1", text_color=color.white, bgcolor=color.gray)
    table.cell(t, 1, 7, bi >= 0 ? array.get(featNames, bi) + (c1 > 0 ? " (+)" : " (-)") : "n/a", text_color=color.white, bgcolor=f_col(c1 > 0 ? 1 : c1 < 0 ? -1 : 0))
    table.cell(t, 0, 8, "Driver 2", text_color=color.white, bgcolor=color.gray)
    table.cell(t, 1, 8, si >= 0 ? array.get(featNames, si) + (c2 > 0 ? " (+)" : " (-)") : "n/a", text_color=color.white, bgcolor=f_col(c2 > 0 ? 1 : c2 < 0 ? -1 : 0))
    table.cell(t, 0, 9, "Position", text_color=color.white, bgcolor=color.gray)
    table.cell(t, 1, 9, pos == 1 ? "LONG" : pos == -1 ? "SHORT" : "NEUTRAL", text_color=color.white, bgcolor=f_col(pos))

// === Alerts ===
alertcondition(longEntry,  "ML Long",  "ML regime switched to LONG")
alertcondition(shortEntry, "ML Short", "ML regime switched to SHORT")
alertcondition(pos[1] != 0 and pos == 0, "ML Flat", "ML regime switched to NEUTRAL")
alertcondition(anom and not anom[1], "ML Anomaly", "Anomaly detected: new entries blocked")
````
