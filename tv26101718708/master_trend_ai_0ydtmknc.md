# Master Trend AI

- url: https://www.tradingview.com/script/0YDtMKNc-Master-Trend-AI/
- type: indicator
- pine_id: PUB;35c9d2208a94480fa29c3471f36b5217
- version: 1.0

## Description

[b]Master Trend · AI[/b] is a standalone overlay companion to the [b]Master Trend[/b] indicator. It runs three independent machine-learning algorithms on the same channel features and consolidates their signals into a single on-chart table.

[b]─── How it works ───[/b]

[b]KNN Lorentzian Classifier[/b]
Searches the last N bars for the k historical states most similar to the current market (RSI, smoothed RSI, ATR ratio, position inside the Master Trend channel). Each matched bar is labelled bullish or bearish based on its 4-bar forward return. The majority vote determines the prediction and confidence score.

[b]Linear Regression Forecast[/b]
Fits a least-squares line to the last N closing prices and projects it forward. A dashed line on the chart shows the projected price target. The table shows the expected percentage change from the current close.

[b]Naive Bayes Classifier[/b]
Estimates Gaussian probability distributions of RSI and volatility features, separately for bull and bear historical bars. Applies Bayes' theorem via log-likelihood to produce a calibrated probability P(bull) / P(bear).

[b]─── Table (top-right corner) ───[/b]

Three columns — KNN · LinReg · Bayes — with three rows:
[list]
[*][b]Signal[/b] — ▲ BULL / ▼ BEAR / ● NEUT  (LinReg shows ▲ UP / ▼ DOWN)
[*][b]Strength[/b] — KNN: vote confidence %;  LinReg: projected Δ%;  Bayes: class probability %
[*][b]Detail[/b] — KNN: votes / k;  LinReg: target price;  Bayes: raw p-value
[/list]

[b]─── Setup ───[/b]
[list=1]
[*]Add [b]Master Trend[/b] to the chart.
[*]Add [b]Master Trend · AI[/b] as a second overlay on the same chart.
[*]Open the [i]"Trend (sync with Master Trend)"[/i] group and match [b]Length[/b] and [b]Multiplier[/b] to your Master Trend settings. The AI channel feature depends on these values being identical.
[/list]

[b]─── Alerts ───[/b]
[list]
[*][b]AI+Trend LONG[/b] — KNN predicts bullish and Master Trend fires a long signal simultaneously.
[*][b]AI+Trend SHORT[/b] — KNN predicts bearish and Master Trend fires a short signal simultaneously.
[/list]

[b]─── Notes ───[/b]
[list]
[*]All three models are recalculated on every bar from scratch — no external data, no repainting from lookahead.
[*]KNN and Naive Bayes share the same Lookback / Step parameters for consistency; LinReg has its own length.
[*]Signals become active after [i]Lookback bars[/i] have elapsed from the chart's first bar.
[/list]

## Source Code

````pine
// © steveast
// Master Trend · AI — KNN Lorentzian Classifier + Linear Regression Forecast + Naive Bayes
// Overlay companion to Master Trend. Sync "Trend Channel" settings with the main indicator.

//@version=6
indicator("Master Trend · AI", shorttitle="MT·AI", overlay=true, max_bars_back=2000)

//=========================================================================================================
// ─── TREND (replicated from Master Trend — keep settings in sync)
//=========================================================================================================

smaIn        = input.int(48,   title="Length",            minval=1, group="Trend (sync with Master Trend)", inline="trend")
mtMultiplier = input.int(3,    title="Multiplier",        minval=1, group="Trend (sync with Master Trend)", inline="trend")
mtUseChannel = input.bool(true, title="The Master Filter", group="Trend (sync with Master Trend)")

tema1 = ta.ema(close, 20)
tema2 = ta.ema(tema1, 20)
tema3 = ta.ema(tema2, 20)
tema  = 3 * (tema1 - tema2) + tema3

temaUp = tema >= tema[3]

maSeries   = temaUp ? high : low
sma1Result = ta.sma(maSeries, smaIn)

longSignal  = ta.crossunder(sma1Result, tema)
shortSignal = ta.crossover(sma1Result, tema)

var bool isLong = true
isLong := not isLong and longSignal ? true : isLong and shortSignal ? false : isLong

atr    = ta.atr(365) * mtMultiplier
delta  = ta.ema(atr, 50)
delta2 = delta / 2

highMax = math.max(close, open)
lowMax  = math.min(close, open)

var float highLine = na
var float lowLine  = na
highLine := na(highLine) ? highMax : highMax > highLine or highMax < highLine - delta ? highMax : highLine
lowLine  := na(lowLine)  ? lowMax  : lowMax  < lowLine  or lowMax  > lowLine  + delta ? lowMax  : lowLine

highLine := lowLine + delta + 1 > highLine ? lowLine + delta : highLine
lowLine  := highLine - delta - 1 < lowLine ? highLine - delta : lowLine

highTrigger = highMax == highLine
lowTrigger  = lowMax  == lowLine

float middleLine = na
middleLine := lowTrigger  ? lowMax  + delta2 : highTrigger ? lowMax     : middleLine[1]
middleLine := highTrigger ? highMax - delta2 : lowTrigger  ? middleLine : middleLine[1]

var bool channelInLong = true
channelInLong := highTrigger and not channelInLong and isLong ? true : lowTrigger and channelInLong and not isLong ? false : channelInLong
channelLongSignal  = channelInLong and not channelInLong[1]
channelShortSignal = not channelInLong and channelInLong[1]

longSignal  := mtUseChannel ? isLong and channelLongSignal      : longSignal
shortSignal := mtUseChannel ? not isLong and channelShortSignal : shortSignal

isLong := not isLong and longSignal ? true : isLong and shortSignal ? false : isLong

//=========================================================================================================
// ─── AI · KNN LORENTZIAN CLASSIFIER
//=========================================================================================================

group_knn = "AI · KNN Classifier"
showKnn   = input.bool(true, "Show AI signal", group=group_knn)
knnK      = input.int(8,   "Neighbors (k)",   group=group_knn, minval=3,   maxval=20)
knnMax    = input.int(500, "Lookback bars",    group=group_knn, minval=100, maxval=2000, tooltip="Number of historical bars to search for nearest neighbors.")
knnStep   = input.int(4,   "Step",            group=group_knn, minval=1,   maxval=20,  tooltip="Skip bars between candidates to reduce serial correlation.")

knnF1 = ta.rsi(close, 14) / 100.0
knnF2 = ta.ema(ta.rsi(close, 9), 3) / 100.0
knnF3 = ta.atr(14) / math.max(ta.ema(ta.atr(14), 50), 1e-10)
knnF4 = math.max(-3.0, math.min(3.0, (close - nz(middleLine, close)) / math.max(delta2, 1e-10)))

max_bars_back(knnF1, 2000)
max_bars_back(knnF2, 2000)
max_bars_back(knnF3, 2000)
max_bars_back(knnF4, 2000)

var float knnScore  = 0.0
var int   knnSignal = 0

if showKnn and bar_index >= knnMax
    _kDists  = array.new<float>()
    _kLabels = array.new<int>()

    for i = knnStep to knnMax by knnStep
        if i >= 5
            d = math.log(1 + math.abs(knnF1 - knnF1[i])) + math.log(1 + math.abs(knnF2 - knnF2[i])) + math.log(1 + math.abs(knnF3 - knnF3[i])) + math.log(1 + math.abs(knnF4 - knnF4[i]))
            lbl = close[i - 4] > close[i] ? 1 : -1

            if _kDists.size() < knnK
                _kDists.push(d)
                _kLabels.push(lbl)
            else
                worstDist = array.max(_kDists)
                if d < worstDist
                    idx = array.indexof(_kDists, worstDist)
                    _kDists.set(idx, d)
                    _kLabels.set(idx, lbl)

    vote = 0
    for j = 0 to _kLabels.size() - 1
        vote += _kLabels.get(j)
    knnScore  := float(vote)
    knnSignal := vote > 0 ? 1 : vote < 0 ? -1 : 0

knnBull   = knnSignal ==  1
knnBear   = knnSignal == -1
knnBgBull = color.new(color.teal, 85)
knnBgBear = color.new(color.red,  85)

bgcolor(showKnn and knnBull ? knnBgBull : showKnn and knnBear ? knnBgBear : na, title="KNN background")

//=========================================================================================================
// ─── AI · LINEAR REGRESSION FORECAST
//=========================================================================================================

group_lr = "AI · LinReg Forecast"
showLR   = input.bool(true, "Show LinReg forecast", group=group_lr)
lrLen    = input.int(50, "Regression length", group=group_lr, minval=10, maxval=500, tooltip="Number of bars used to fit the regression line.")
lrFwd    = input.int(10, "Forecast bars",     group=group_lr, minval=1,  maxval=100, tooltip="How many bars ahead to project the regression line.")

lrNow      = ta.linreg(close, lrLen, 0)
lrSlope    = lrNow - ta.linreg(close, lrLen, 1)
lrForecast = lrNow + lrSlope * lrFwd

lrBull      = lrSlope > 0
lrChangePct = (lrForecast - close) / close * 100

var line _lrLine = na
if showLR and barstate.islast
    line.delete(_lrLine)
    _lrLine := line.new(bar_index, lrNow, bar_index + lrFwd, lrForecast, color=lrBull ? color.new(color.teal, 20) : color.new(color.red, 20), width=2, style=line.style_dashed)

//=========================================================================================================
// ─── AI · NAIVE BAYES CLASSIFIER
//=========================================================================================================

group_nb = "AI · Naive Bayes"
showNB   = input.bool(true, "Show Naive Bayes", group=group_nb)
nbMax    = input.int(500, "Lookback bars", group=group_nb, minval=100, maxval=2000, tooltip="Historical window for computing class statistics.")
nbStep   = input.int(4,   "Step",          group=group_nb, minval=1,   maxval=20,  tooltip="Bar skip between samples to reduce serial correlation.")

var float nbProbBull = 0.5
var float nbProbBear = 0.5
var int   nbSignal   = 0

if showNB and bar_index >= nbMax
    _nB  = 0
    _nR  = 0
    _m1b = 0.0
    _m2b = 0.0
    _m3b = 0.0
    _m1r = 0.0
    _m2r = 0.0
    _m3r = 0.0
    _s1b = 0.0
    _s2b = 0.0
    _s3b = 0.0
    _s1r = 0.0
    _s2r = 0.0
    _s3r = 0.0

    _start = math.max(nbStep, 5)
    for i = _start to nbMax by nbStep
        _lbl = close[i - 4] > close[i] ? 1 : -1
        _f1  = knnF1[i]
        _f2  = knnF2[i]
        _f3  = knnF3[i]
        if _lbl == 1
            _nB += 1
            _d1 = _f1 - _m1b
            _m1b += _d1 / _nB
            _s1b += _d1 * (_f1 - _m1b)
            _d2 = _f2 - _m2b
            _m2b += _d2 / _nB
            _s2b += _d2 * (_f2 - _m2b)
            _d3 = _f3 - _m3b
            _m3b += _d3 / _nB
            _s3b += _d3 * (_f3 - _m3b)
        else
            _nR += 1
            _d1 = _f1 - _m1r
            _m1r += _d1 / _nR
            _s1r += _d1 * (_f1 - _m1r)
            _d2 = _f2 - _m2r
            _m2r += _d2 / _nR
            _s2r += _d2 * (_f2 - _m2r)
            _d3 = _f3 - _m3r
            _m3r += _d3 / _nR
            _s3r += _d3 * (_f3 - _m3r)

    _total = math.max(_nB + _nR, 1)
    _eps   = 1e-8

    _v1b = math.max(_nB > 1 ? _s1b / (_nB - 1) : 0.01, _eps)
    _v2b = math.max(_nB > 1 ? _s2b / (_nB - 1) : 0.01, _eps)
    _v3b = math.max(_nB > 1 ? _s3b / (_nB - 1) : 0.01, _eps)
    _v1r = math.max(_nR > 1 ? _s1r / (_nR - 1) : 0.01, _eps)
    _v2r = math.max(_nR > 1 ? _s2r / (_nR - 1) : 0.01, _eps)
    _v3r = math.max(_nR > 1 ? _s3r / (_nR - 1) : 0.01, _eps)

    _cf1 = knnF1
    _cf2 = knnF2
    _cf3 = knnF3

    _llb = math.log(math.max(_nB, 1) / _total) - 0.5 * math.log(2 * math.pi * _v1b) - (_cf1 - _m1b) * (_cf1 - _m1b) / (2 * _v1b) - 0.5 * math.log(2 * math.pi * _v2b) - (_cf2 - _m2b) * (_cf2 - _m2b) / (2 * _v2b) - 0.5 * math.log(2 * math.pi * _v3b) - (_cf3 - _m3b) * (_cf3 - _m3b) / (2 * _v3b)
    _llr = math.log(math.max(_nR, 1) / _total) - 0.5 * math.log(2 * math.pi * _v1r) - (_cf1 - _m1r) * (_cf1 - _m1r) / (2 * _v1r) - 0.5 * math.log(2 * math.pi * _v2r) - (_cf2 - _m2r) * (_cf2 - _m2r) / (2 * _v2r) - 0.5 * math.log(2 * math.pi * _v3r) - (_cf3 - _m3r) * (_cf3 - _m3r) / (2 * _v3r)

    _llmax = math.max(_llb, _llr)
    _pb    = math.exp(_llb - _llmax)
    _pr    = math.exp(_llr - _llmax)
    _psum  = _pb + _pr

    nbProbBull := _pb / _psum
    nbProbBear := _pr / _psum
    nbSignal   := nbProbBull > 0.55 ? 1 : nbProbBear > 0.55 ? -1 : 0

//=========================================================================================================
// ─── COMBINED AI TABLE
//=========================================================================================================

var table _aiTable = na
if showKnn or showLR or showNB
    if na(_aiTable)
        _aiTable := table.new(position.top_right, 4, 4, bgcolor=color.new(color.black, 70), border_color=color.new(color.white, 80), border_width=1, frame_color=color.new(color.white, 80), frame_width=1)

    if barstate.islast
        knnPredTxt   = knnBull ? "▲ BULL" : knnBear ? "▼ BEAR" : "● NEUT"
        knnPredColor = knnBull ? color.teal : knnBear ? color.red : color.yellow
        knnConfPct   = knnK > 0 ? math.round(math.abs(knnScore) / knnK * 100) : 0

        lrPredTxt   = lrBull ? "▲ UP" : "▼ DOWN"
        lrPredColor = lrBull ? color.teal : color.red
        lrChangeTxt = (lrChangePct >= 0 ? "+" : "") + str.tostring(math.round(lrChangePct, 2)) + "%"
        lrTargetTxt = str.tostring(math.round(lrForecast, 2))

        nbBull      = nbSignal == 1
        nbBear      = nbSignal == -1
        nbPredTxt   = nbBull ? "▲ BULL" : nbBear ? "▼ BEAR" : "● NEUT"
        nbPredColor = nbBull ? color.teal : nbBear ? color.red : color.yellow
        nbPct       = math.round(math.max(nbProbBull, nbProbBear) * 100)

        table.cell(_aiTable, 0, 0, "",         text_color=color.white,  bgcolor=color.new(color.gray, 60),  text_size=size.tiny)
        table.cell(_aiTable, 1, 0, "KNN",      text_color=color.white,  bgcolor=color.new(color.blue, 50),  text_size=size.tiny)
        table.cell(_aiTable, 2, 0, "LinReg",   text_color=color.white,  bgcolor=color.new(color.blue, 50),  text_size=size.tiny)
        table.cell(_aiTable, 3, 0, "Bayes",    text_color=color.white,  bgcolor=color.new(color.blue, 50),  text_size=size.tiny)

        table.cell(_aiTable, 0, 1, "Signal",   text_color=color.silver, bgcolor=color.new(color.black, 70), text_size=size.tiny)
        table.cell(_aiTable, 1, 1, knnPredTxt, text_color=knnPredColor, bgcolor=color.new(color.black, 50), text_size=size.tiny)
        table.cell(_aiTable, 2, 1, lrPredTxt,  text_color=lrPredColor,  bgcolor=color.new(color.black, 50), text_size=size.tiny)
        table.cell(_aiTable, 3, 1, nbPredTxt,  text_color=nbPredColor,  bgcolor=color.new(color.black, 50), text_size=size.tiny)

        table.cell(_aiTable, 0, 2, "Strength", text_color=color.silver, bgcolor=color.new(color.black, 70), text_size=size.tiny)
        table.cell(_aiTable, 1, 2, str.tostring(knnConfPct) + "%", text_color=knnPredColor, bgcolor=color.new(color.black, 70), text_size=size.tiny)
        table.cell(_aiTable, 2, 2, lrChangeTxt,                    text_color=lrPredColor,  bgcolor=color.new(color.black, 70), text_size=size.tiny)
        table.cell(_aiTable, 3, 2, str.tostring(nbPct) + "%",      text_color=nbPredColor,  bgcolor=color.new(color.black, 70), text_size=size.tiny)

        table.cell(_aiTable, 0, 3, "Detail",    text_color=color.silver, bgcolor=color.new(color.black, 70), text_size=size.tiny)
        table.cell(_aiTable, 1, 3, str.tostring(int(knnScore)) + "/" + str.tostring(knnK),               text_color=knnPredColor, bgcolor=color.new(color.black, 70), text_size=size.tiny)
        table.cell(_aiTable, 2, 3, lrTargetTxt,                                                           text_color=lrPredColor,  bgcolor=color.new(color.black, 70), text_size=size.tiny)
        table.cell(_aiTable, 3, 3, "p=" + str.tostring(math.round(math.max(nbProbBull, nbProbBear), 2)), text_color=nbPredColor,  bgcolor=color.new(color.black, 70), text_size=size.tiny)

alertcondition(showKnn and knnBull and longSignal,  title="AI+Trend LONG",  message="AI+Trend confirmed LONG {{ticker}}:{{interval}} {{close}}")
alertcondition(showKnn and knnBear and shortSignal, title="AI+Trend SHORT", message="AI+Trend confirmed SHORT {{ticker}}:{{interval}} {{close}}")
````
