<!-- tradingview-pine-id: PUB;dba2006ff583470dbbe956447dff6b6c -->
<!-- tradingviewscripts-format: 1 -->
# AI Predictive Flow (Zeiierman)

Source: https://www.tradingview.com/script/qaaxkW1P-AI-Predictive-Flow-Zeiierman/

## Description

█ Overview
AI Predictive Flow (Zeiierman) is a pattern-based oscillator that estimates future price direction by comparing the current market state to similar historical conditions.

Instead of relying on traditional indicators like momentum or moving averages alone, the script builds a multi-feature representation of price behavior and uses a k-Nearest Neighbors (kNN) model to identify past patterns that closely resemble the present.

From those matches, it derives an expected forward return, which is then transformed into a smooth oscillator and a predicted trend regime.

The result is a forward-looking signal that reflects a data-driven expectation based on similar past patterns, not just current price movement.
[image]https://www.tradingview.com/x/bC7hAAfo/[/image]

█ How It Works

⚪Feature Extraction (Market State Model)
The script converts price into a compact feature set that describes the current market state.

It uses four core features:

[*]Short-term return
[*]Momentum
[*]RSI bias
[*]EMA spread

These are created inside the feature function:
[pine]feat(shift, mode) =>
    c  = close[shift]
    c1 = close[shift + 1]
    cm = close[shift + momLn]
    ef = ta.ema(close, fLen)[shift]
    es = ta.ema(close, sLen)[shift]
    r  = ta.rsi(close, rsiLn)[shift]

    float v = 0.0
    if mode == 1
        v := c1 != 0 ? math.log(c / c1) : 0.0
    else if mode == 2
        v := cm != 0 ? (c - cm) / cm : 0.0
    else if mode == 3
        v := (r - 50.0) / 50.0
    else
        v := c != 0 ? (ef - es) / c : 0.0
    v[/pine]
Each feature captures a different dimension of price behavior:

[*]return measures immediate movement
[*]momentum measures directional displacement
[*]RSI bias measures internal pressure
[*]EMA spread measures trend structure

These values are then stacked across multiple bars to form the pattern used for comparison.

⚪Pattern Memory (Historical Pattern Library)
The script stores rolling sequences of each feature into separate matrices so the current market state can be compared against past states.

That process is built here:
[pine]pushFeat(mat, mode) =>
    vals = array.new<float>(tot, 0.0)

    for i = 0 to tot - 1
        array.set(vals, tot - 1 - i, feat(i, mode))

    cur = array.slice(vals, tot - len, tot)
    old = array.slice(vals, 0, len)

    matrix<float> out = matrix.new<float>(1, len, 0.0)
    for i = 0 to len - 1
        matrix.set(out, 0, i, array.get(cur, i))

    hist = array.new<float>(len, 0.0)
    for i = 0 to len - 1
        array.set(hist, i, array.get(old, i))

    if mat.rows() >= mem
        mat.remove_row(0)

    mat.add_row(mat.rows(), hist)

    out[/pine]
This creates:

[*]a current feature row
[*]a rolling history of prior feature patterns

So rather than comparing single-bar values, the model compares multi-bar pattern structure.

⚪Pattern Matching Engine (kNN Distance Model)
Once the current feature pattern is built, it is compared to all stored historical patterns.

Distance is measured feature-by-feature across the full pattern length:
[pine]getDist(matrix<float> a1, matrix<float> a2, matrix<float> a3, matrix<float> a4, matrix<float> b1, matrix<float> b2, matrix<float> b3, matrix<float> b4) =>
    out = array.new<float>(b1.rows(), 0.0)

    for i = 0 to b1.rows() - 1
        s = 0.0
        d1 = a1.diff(b1.submatrix(i, i + 1)).row(0)
        d2 = a2.diff(b2.submatrix(i, i + 1)).row(0)
        d3 = a3.diff(b3.submatrix(i, i + 1)).row(0)
        d4 = a4.diff(b4.submatrix(i, i + 1)).row(0)

        for j = 0 to len - 1
            s += math.pow(d1.get(j), 2) * 0.25 +
                 math.pow(d2.get(j), 2) * 0.25 +
                 math.pow(d3.get(j), 2) * 0.25 +
                 math.pow(d4.get(j), 2) * 0.25

        out.set(i, math.sqrt(s))

    out[/pine]
This produces a similarity score for every stored pattern. A smaller distance means the past setup looked more like the present one.

⚪Prediction Model (kNN Forward Expectation)

After the distances are ranked, the script selects the nearest neighbors and averages their future outcomes.

The kNN model is implemented here:
[pine]knn(dist, n) =>
    ix = dist.sort_indices()
    useN = math.min(n, ix.size())
    sumD = 0.0
    avg  = 0.0

    for i = 0 to useN - 1
        sumD += dist.get(ix.get(i))

    if useN > 0
        for i = 0 to useN - 1
            d = dist.get(ix.get(i))
            w = useN > 1 ? (sumD != 0 ? (1 - d / sumD) : 1.0) : 1.0
            avg += Y.get(ix.get(i)) * w

    avg[/pine]
The forward return used for comparison is defined here:
[pine]y := math.log(base) - math.log(base[ahead])[/pine]
This represents the forward return following each historical pattern. The result is a weighted expectation of future movement, not just a reading of current trend.

⚪Predictive Oscillator
The raw kNN prediction is smoothed and transformed into the main oscillator and signal line.

[pine]pred_ = ta.ema(pred, smth)

if not na(pred)
    predSm := smth > 1 ? pred_ : pred

osc  = ta.ema(predSm, oscLn)
sig  = ta.ema(osc, sigLn)
hist = osc - sig[/pine]
This creates:

[*]Oscillator = smoothed expected return
[*]Signal line = secondary smoothing for crossover confirmation
[*]Histogram = distance between oscillator and signal

⚪Predicted Trend Regime 
Beyond the oscillator, the script also builds a broader trend regime using the predicted price path.

First, the raw prediction is converted into a projected price line:
[pine]predLine := base + base * (math.exp(pred) - 1)[/pine]
Then a regime band is created using ATR:
[pine]hiRef = predLine + bandM * atr
loRef = predLine - bandM * atr

if ta.highest(hiRef, regLn) == hiRef
    trendUp := true
if ta.lowest(loRef, regLn) == loRef
    trendUp := false[/pine]
This background state represents:

[*]bullish predicted regime when the projected path is pressing into new highs
[*]bearish predicted regime when the projected path is pressing into new lows

So the background is not showing the raw price trend. It is showing the model’s predicted regime bias.

█ How to Use

⚪ Read the Oscillator

[*]Above 0 → bullish expectation
[*]Below 0 → bearish expectation
[*]Near 0 → neutral/low conviction

[image]https://www.tradingview.com/x/w3gmY7um/[/image]

[*]Far from 0 → strong directional push

[image]https://www.tradingview.com/x/9kgGcjoF/[/image]
Use crossovers for entry timing:

[*]Bullish crossover → potential upward continuation
[*]Bearish crossover → potential downward continuation

[image]https://www.tradingview.com/x/C1qe9TyN/[/image]

⚪ Use the Predicted Trend Regime

The background highlights the model’s broader directional bias:

[*]Green → predicted bullish regime
[*]Red → predicted bearish regime

Regime shifts often indicate:

[*]early trend transitions
[*]continuation confirmation
[*]structural changes in expectation

[image]https://www.tradingview.com/x/7KpVH8qL/[/image]

⚪ Combine Signals

Best use comes from alignment:

[*]Oscillator above zero + bullish regime + signal → strong continuation bias
[*]Oscillator below zero + bearish regime + signal → strong downside bias
[*]Divergence between the two → caution / mixed signals

[image]https://www.tradingview.com/x/CstJzqTM/[/image]

█ Settings

[*]Pattern Length – Controls how many bars define the current pattern. Higher values capture more structure, lower values increase responsiveness.
[*]Memory Size – Number of historical patterns stored for comparison. Larger values improve context but increase computation.
[*]Neighbors (k) – Number of closest matches used in prediction. Lower values are more reactive, higher values are smoother.
[*]Prediction Smoothing – EMA smoothing applied to the raw prediction. Reduces noise at the cost of lag.
[*]Signal Length – Smoothing of the signal line used for crossover signals.

-----------------
Disclaimer

The content provided in my scripts, indicators, ideas, algorithms, and systems is for educational and informational purposes only. It does not constitute financial advice, investment recommendations, or a solicitation to buy or sell any financial instruments. I will not accept liability for any loss or damage, including without limitation any loss of profit, which may arise directly or indirectly from the use of or reliance on such information.

All investments involve risk, and the past performance of a security, industry, sector, market, financial product, trading strategy, backtest, or individual's trading does not guarantee future results or returns. Investors are fully responsible for any investment decisions they make. Such decisions should be based solely on an evaluation of their financial circumstances, investment objectives, risk tolerance, and liquidity needs.

---

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © Zeiierman {
//@version=6
indicator("AI Predictive Flow (Zeiierman)", overlay = false)
//}

// ~~ Tooltips {
t1  = "Number of bars used to build the pattern compared against past patterns. Lower values run faster. Higher values capture more structure but increase load."
t2  = "Number of historical patterns stored in memory for kNN comparison. This is one of the biggest speed drivers. Lower values are faster."
t3  = "How many nearest historical matches are used for the prediction. Lower values react faster. Higher values smooth the result by averaging more neighbors."
t4  = "EMA smoothing applied to the raw prediction before plotting the oscillator. Higher values reduce noise but add lag."
t5  = "Smoothing length of the signal line. Higher values produce fewer but slower crossovers."

t6  = "Show or hide the main oscillator plot."
t7  = "Show or hide the signal line."
t8  = "Show or hide the histogram."
t9  = "Show or hide bullish and bearish regime background coloring."
t10 = "Show or hide bullish and bearish crossover markers."

t11 = "Color used when the oscillator is above zero."
t12 = "Color used when the oscillator is below zero."
t13 = "Color of the signal line."
t14 = "Color used for positive histogram bars."
t15 = "Color used for negative histogram bars."
t16 = "Background color used during bullish regime state."
t17 = "Background color used during bearish regime state."
t18 = "Color used for bullish crossover markers."
t19 = "Color used for bearish crossover markers."
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Main inputs {
len   = input.int(10, "Pattern Length", minval = 5, tooltip = t1, group = "Main Settings")
mem   = input.int(20, "Memory Size", minval = 10, tooltip = t2, group = "Main Settings")
k     = input.int(5, "Neighbors", minval = 1, maxval = 20, tooltip = t3, group = "Main Settings")
smth  = input.int(5, "Prediction Smoothing", minval = 1, tooltip = t4, group = "Main Settings")
sigLn = input.int(5, "Signal Length", minval = 1, tooltip = t5, group = "Main Settings")
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Style inputs {
showOsc   = input.bool(true, "Show Oscillator", tooltip = t6, group = "Style")
showSig   = input.bool(true, "Show Signal", tooltip = t7, group = "Style")
showHist  = input.bool(true, "Show Histogram", tooltip = t8, group = "Style")
showBg    = input.bool(true, "Show Predicted Trend Regime", tooltip = t9, group = "Style")
showMarks = input.bool(true, "Show Markers", tooltip = t10, group = "Style")

oscUpCol  = input.color(color.rgb(175, 255, 105), "Oscillator Up Color", tooltip = t11, group = "Style")
oscDnCol  = input.color(color.rgb(255, 71, 80), "Oscillator Down Color", tooltip = t12, group = "Style")
sigCol    = input.color(color.new(color.gray, 20), "Signal Color", tooltip = t13, group = "Style")
histUpCol = input.color(color.new(color.rgb(175, 255, 105), 20), "Histogram Up Color", tooltip = t14, group = "Style")
histDnCol = input.color(color.new(color.rgb(255, 71, 80), 20), "Histogram Down Color", tooltip = t15, group = "Style")
bgUpCol   = input.color(color.new(color.rgb(175, 255, 105), 92), "Predicted Trend Regime Bull Color", tooltip = t16, group = "Style")
bgDnCol   = input.color(color.new(color.rgb(255, 71, 80), 92), "Predicted Trend Regime Bear Color", tooltip = t17, group = "Style")
bullMkCol = input.color(color.rgb(175, 255, 105), "Bull Marker Color", tooltip = t18, group = "Style")
bearMkCol = input.color(color.rgb(255, 71, 80), "Bear Marker Color", tooltip = t19, group = "Style")
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Fixed internals {
momLn = 5
rsiLn = 14
emaLn = 14
fLen  = 10
sLen  = 30
atrLn = 100
bandM = 2.0
regLn = 30
oscLn = 3
ahead = 2
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Storage {
var Y  = array.new<float>()
var M1 = matrix.new<float>()
var M2 = matrix.new<float>()
var M3 = matrix.new<float>()
var M4 = matrix.new<float>()

var matrix<float> F1 = matrix.new<float>()
var matrix<float> F2 = matrix.new<float>()
var matrix<float> F3 = matrix.new<float>()
var matrix<float> F4 = matrix.new<float>()

var array<float> ds = array.new<float>()

var float pred     = na
var float predLine = na
var float predSm   = na
var float y        = na
var bool trendUp   = false
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Base {
base = ta.ema(close, emaLn)
atr  = ta.atr(atrLn)
tot  = len + ahead
enough = bar_index > (tot + math.max(momLn, sLen) + ahead + 5)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Feature function {
feat(shift, mode) =>
    c  = close[shift]
    c1 = close[shift + 1]
    cm = close[shift + momLn]
    ef = ta.ema(close, fLen)[shift]
    es = ta.ema(close, sLen)[shift]
    r  = ta.rsi(close, rsiLn)[shift]

    float v = 0.0
    if mode == 1
        v := c1 != 0 ? math.log(c / c1) : 0.0
    else if mode == 2
        v := cm != 0 ? (c - cm) / cm : 0.0
    else if mode == 3
        v := (r - 50.0) / 50.0
    else
        v := c != 0 ? (ef - es) / c : 0.0
    v
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Build feature history {
pushFeat(mat, mode) =>
    vals = array.new<float>(tot, 0.0)

    for i = 0 to tot - 1
        array.set(vals, tot - 1 - i, feat(i, mode))

    cur = array.slice(vals, tot - len, tot)
    old = array.slice(vals, 0, len)

    matrix<float> out = matrix.new<float>(1, len, 0.0)
    for i = 0 to len - 1
        matrix.set(out, 0, i, array.get(cur, i))

    hist = array.new<float>(len, 0.0)
    for i = 0 to len - 1
        array.set(hist, i, array.get(old, i))

    if mat.rows() >= mem
        mat.remove_row(0)

    mat.add_row(mat.rows(), hist)

    out
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Distance calc {
getDist(matrix<float> a1, matrix<float> a2, matrix<float> a3, matrix<float> a4, matrix<float> b1, matrix<float> b2, matrix<float> b3, matrix<float> b4) =>
    out = array.new<float>(b1.rows(), 0.0)

    for i = 0 to b1.rows() - 1
        s = 0.0
        d1 = a1.diff(b1.submatrix(i, i + 1)).row(0)
        d2 = a2.diff(b2.submatrix(i, i + 1)).row(0)
        d3 = a3.diff(b3.submatrix(i, i + 1)).row(0)
        d4 = a4.diff(b4.submatrix(i, i + 1)).row(0)

        for j = 0 to len - 1
            s += math.pow(d1.get(j), 2) * 0.25 +
                 math.pow(d2.get(j), 2) * 0.25 +
                 math.pow(d3.get(j), 2) * 0.25 +
                 math.pow(d4.get(j), 2) * 0.25

        out.set(i, math.sqrt(s))

    out
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ kNN {
knn(dist, n) =>
    ix = dist.sort_indices()
    useN = math.min(n, ix.size())
    sumD = 0.0
    avg  = 0.0

    for i = 0 to useN - 1
        sumD += dist.get(ix.get(i))

    if useN > 0
        for i = 0 to useN - 1
            d = dist.get(ix.get(i))
            w = useN > 1 ? (sumD != 0 ? (1 - d / sumD) : 1.0) : 1.0
            avg += Y.get(ix.get(i)) * w

    avg
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Main {
if barstate.isconfirmed and enough
    y := math.log(base) - math.log(base[ahead])

    F1 := pushFeat(M1, 1)
    F2 := pushFeat(M2, 2)
    F3 := pushFeat(M3, 3)
    F4 := pushFeat(M4, 4)

    if Y.size() >= mem
        Y.shift()
    Y.push(y)

    ds := getDist(F1, F2, F3, F4, M1, M2, M3, M4)
    pred := knn(ds, k)
    predLine := base + base * (math.exp(pred) - 1)

pred_ = ta.ema(pred, smth)

if not na(pred)
    predSm := smth > 1 ? pred_ : pred
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Regime {
hiRef = predLine + bandM * atr
loRef = predLine - bandM * atr

if ta.highest(hiRef, regLn) == hiRef
    trendUp := true
if ta.lowest(loRef, regLn) == loRef
    trendUp := false
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Oscillator {
osc  = ta.ema(predSm, oscLn)
sig  = ta.ema(osc, sigLn)
hist = osc - sig
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Signals {
bull = ta.crossover(osc, sig) and sig >= 0
bear = ta.crossunder(osc, sig) and sig <= 0
up0  = ta.crossover(osc, 0)
dn0  = ta.crossunder(osc, 0)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Plots {
hline(0, "Zero", color.new(chart.fg_color, 60))

plot(showOsc ? osc : na, "Osc", color = osc >= 0 ? oscUpCol : oscDnCol, linewidth = 2)
plot(showSig ? sig : na, "Signal", color = sigCol, linewidth = 1)
plot(showHist ? hist : na, "Hist", style = plot.style_columns, color = hist >= 0 ? histUpCol : histDnCol)

bgcolor(showBg ? (trendUp ? bgUpCol : bgDnCol) : na, title="Predicted Trend Regime")

plotshape(showMarks and bull, title = "Bull", style = shape.triangleup, location = location.bottom, color = bullMkCol, size = size.tiny)
plotshape(showMarks and bear, title = "Bear", style = shape.triangledown, location = location.top, color = bearMkCol, size = size.tiny)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Alerts {
oscBull  = osc >= 0 and osc[1] < 0
oscBear  = osc <= 0 and osc[1] > 0
bgBull   = trendUp and not trendUp[1]
bgBear   = not trendUp and trendUp[1]
sigBull  = sig >= 0 and sig[1] < 0
sigBear  = sig <= 0 and sig[1] > 0
histBull = hist >= 0 and hist[1] < 0
histBear = hist <= 0 and hist[1] > 0

alertcondition(bull, "Bullish Cross", "Oscillator crossed above signal")
alertcondition(bear, "Bearish Cross", "Oscillator crossed below signal")
alertcondition(up0, "Bullish Zero Cross", "Oscillator crossed above zero")
alertcondition(dn0, "Bearish Zero Cross", "Oscillator crossed below zero")

alertcondition(oscBull, "Oscillator Turned Bullish", "Oscillator changed to bullish color state")
alertcondition(oscBear, "Oscillator Turned Bearish", "Oscillator changed to bearish color state")

alertcondition(sigBull, "Signal Turned Bullish", "Signal line crossed above zero")
alertcondition(sigBear, "Signal Turned Bearish", "Signal line crossed below zero")

alertcondition(histBull, "Histogram Turned Positive", "Histogram crossed above zero")
alertcondition(histBear, "Histogram Turned Negative", "Histogram crossed below zero")

alertcondition(bgBull, "Background Turned Bullish", "Background changed to bullish regime")
alertcondition(bgBear, "Background Turned Bearish", "Background changed to bearish regime")
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
````
