# Gemini Quant OS 6-in-1 Signal

- url: https://www.tradingview.com/script/VfQtQKaG/
- type: indicator
- pine_id: PUB;6ba06c25acd64693895c873d6faea279
- version: 1.0

## Description

Gemini Quant OS — 6-in-1 Core

Overview

Gemini Quant OS — 6-in-1 Core is a multi-market analytical framework designed to help traders identify market structure, trend conditions, volatility expansion, and potential trading opportunities across multiple asset classes.

The framework supports:

Forex

Gold

Indices

Crypto

Commodities

Equities


This script is part of the broader Gemini Quant OS ecosystem.


---

Core Concepts

The framework combines multiple technical components into a single structured decision-making system, including:

trend strength analysis

EMA structure

volatility expansion

ATR-based risk zones

breakout confirmation

adaptive market regime filtering

momentum alignment

multi-timeframe bias detection


The dashboard dynamically adapts to different market conditions and attempts to classify whether the market is:

trending

ranging

volatile

mixed



---

Features

Multi-market compatibility

Signal dashboard

Adaptive market bias

Buy/Sell signal detection

ATR-based SL/TP framework

Trend and momentum filtering

Volatility condition analysis



---

Best Use Cases

Best suited for:

H1–D1 analysis

swing trading

momentum trading

volatility expansion environments

structured discretionary trading



---

Notes

This script is designed as an educational and analytical framework.

Not financial advice.

## Source Code

````pine
//@version=6
indicator("Gemini Quant OS 6-in-1 Signal", overlay=true, max_labels_count=500, max_lines_count=500)

//====================================================
// 0) 基本設定
//====================================================
grp0 = "0) Basic"
useLong = input.bool(true, "Enable BUY", group=grp0)
useShort = input.bool(true, "Enable SELL", group=grp0)
showPanel = input.bool(true, "Show Decision Panel", group=grp0)
showMarks = input.bool(true, "Show BUY / SELL Marks", group=grp0)
showLines = input.bool(true, "Show SL / TP Lines", group=grp0)

//====================================================
// 1) Preset
//====================================================
grp1 = "1) Adaptive Preset"
preset = input.string("Balanced", "Mode", options=["Conservative", "Balanced", "Aggressive"], group=grp1)

//====================================================
// 2) Core Inputs
//====================================================
grp2 = "2) Engine"
emaFastLen = input.int(20, "EMA Fast", minval=2, group=grp2)
emaSlowLen = input.int(50, "EMA Slow", minval=3, group=grp2)
adxLen = input.int(14, "ADX Length", minval=1, group=grp2)
adxSmooth = input.int(14, "ADX Smoothing", minval=1, group=grp2)
atrLen = input.int(14, "ATR Length", minval=1, group=grp2)
rngLen = input.int(20, "Breakout Lookback", minval=5, group=grp2)
vwapLen = input.int(100, "VWAP StdDev Lookback", minval=20, group=grp2)

//====================================================
// 3) Thresholds
//====================================================
grp3 = "3) Threshold"
trendAdxBase = input.float(20.0, "Trend ADX >", step=0.5, group=grp3)
rangeAdxBase = input.float(15.0, "Range ADX <", step=0.5, group=grp3)
emaDistBase = input.float(0.15, "EMA Distance % >", step=0.01, group=grp3)
zScoreBase = input.float(1.20, "Mean Reversion Z", step=0.1, group=grp3)
riskATRBase = input.float(1.50, "SL = ATR x", step=0.1, group=grp3)
rrBase = input.float(2.00, "RR", step=0.1, group=grp3)

//====================================================
// 4) Preset Adjust
//====================================================
float trendAdx = trendAdxBase
float rangeAdx = rangeAdxBase
float emaDist = emaDistBase
float zScoreTh = zScoreBase
float riskATR = riskATRBase
float rr = rrBase

if preset == "Conservative"
    trendAdx := trendAdxBase + 5.0
    rangeAdx := rangeAdxBase - 2.0
    emaDist := emaDistBase + 0.08
    zScoreTh := zScoreBase + 0.3
    riskATR := riskATRBase + 0.3
    rr := rrBase - 0.2
else if preset == "Aggressive"
    trendAdx := trendAdxBase - 5.0
    rangeAdx := rangeAdxBase + 2.0
    emaDist := math.max(0.03, emaDistBase - 0.05)
    zScoreTh := math.max(0.5, zScoreBase - 0.3)
    riskATR := math.max(0.5, riskATRBase - 0.3)
    rr := rrBase + 0.5

//====================================================
// 5) Helpers
//====================================================
f_fmtPx(float x) =>
    string out = "—"
    if not na(x)
        out := str.tostring(x, format.mintick)
    out

f_fmtPct(float x) =>
    string out = "—"
    if not na(x)
        out := str.tostring(x, "#.0") + "%"
    out

f_has(string t, string k) =>
    str.contains(str.upper(t), str.upper(k))

f_isPrecious(string tid) =>
    bool out = false
    if f_has(tid, "XAU")
        out := true
    else if f_has(tid, "XAG")
        out := true
    else if f_has(tid, "GOLD")
        out := true
    else if f_has(tid, "SILVER")
        out := true
    out

f_isIndex(string tid) =>
    bool out = false
    if f_has(tid, "SPX")
        out := true
    else if f_has(tid, "SP500")
        out := true
    else if f_has(tid, "US500")
        out := true
    else if f_has(tid, "NAS100")
        out := true
    else if f_has(tid, "US100")
        out := true
    else if f_has(tid, "NDX")
        out := true
    else if f_has(tid, "DJI")
        out := true
    else if f_has(tid, "US30")
        out := true
    else if f_has(tid, "HSI")
        out := true
    else if f_has(tid, "HK50")
        out := true
    else if f_has(tid, "HSTECH")
        out := true
    else if f_has(tid, "CHINAH")
        out := true
    else if f_has(tid, "A50")
        out := true
    else if f_has(tid, "CSI")
        out := true
    else if f_has(tid, "DE40")
        out := true
    else if f_has(tid, "GER40")
        out := true
    else if f_has(tid, "UK100")
        out := true
    else if f_has(tid, "JP225")
        out := true
    else if f_has(tid, "AUS200")
        out := true
    else if f_has(tid, "VIX")
        out := true
    else if f_has(tid, "USDX")
        out := true
    else if f_has(tid, "DXY")
        out := true
    out

f_catAuto() =>
    string tid = str.upper(syminfo.tickerid)
    string typ = str.lower(syminfo.type)
    string out = "COMMODITIES"

    if f_isPrecious(tid)
        out := "RESOURCES"
    else if typ == "forex"
        out := "FX"
    else if typ == "crypto"
        out := "CRYPTO"
    else if typ == "stock"
        out := "STOCKS"
    else if typ == "index"
        out := "INDICES"
    else if f_isIndex(tid)
        out := "INDICES"
    else
        out := "COMMODITIES"

    out

f_regimeLabel(int reg) =>
    string out = "UNCLEAR"
    if reg == 1
        out := "TREND"
    else if reg == 2
        out := "RANGE"
    else if reg == 3
        out := "VOL"
    else
        out := "UNCLEAR"
    out

f_marketLabel(int reg) =>
    string out = "Mixed"
    if reg == 1
        out := "Trending"
    else if reg == 2
        out := "Ranging"
    else if reg == 3
        out := "Volatile"
    else
        out := "Mixed"
    out

f_biasLabel(int bias) =>
    string out = "NEUTRAL"
    if bias > 0
        out := "BULL"
    else if bias < 0
        out := "BEAR"
    else
        out := "NEUTRAL"
    out

f_actionColor(string txt) =>
    color out = color.rgb(90, 95, 105)
    if txt == "BUY"
        out := color.rgb(0, 170, 90)
    else if txt == "SELL"
        out := color.rgb(220, 60, 60)
    else if txt == "HOLD LONG"
        out := color.rgb(0, 130, 70)
    else if txt == "HOLD SHORT"
        out := color.rgb(150, 40, 40)
    else if txt == "WAIT(VOL)"
        out := color.rgb(180, 120, 0)
    else
        out := color.rgb(90, 95, 105)
    out

//====================================================
// 6) Core Engine
//====================================================
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

[diPlus, diMinus, adxVal] = ta.dmi(adxLen, adxSmooth)

atrVal = ta.atr(atrLen)
distPc = math.abs(emaFast - emaSlow) / math.max(close, syminfo.mintick) * 100.0

bool isTrend = false
bool isRange = false
bool isVol = false

if adxVal > trendAdx and distPc > emaDist
    isTrend := true
else if adxVal < rangeAdx
    isRange := true
else
    isVol := true

int regime = 0
if isTrend
    regime := 1
else if isRange
    regime := 2
else
    regime := 3

int bias = 0
if emaFast > emaSlow
    bias := 1
else if emaFast < emaSlow
    bias := -1
else
    bias := 0

hh = ta.highest(high, rngLen)
ll = ta.lowest(low, rngLen)

vwapVal = ta.vwap(hlc3)
devVal = ta.stdev(hlc3 - vwapVal, vwapLen)

float zScore = na
if not na(devVal)
    zScore := (close - vwapVal) / math.max(devVal, syminfo.mintick)

bool bullBreak = false
bool bearBreak = false
bool meanLong = false
bool meanShort = false

if isTrend and bias == 1 and close > hh[1]
    bullBreak := true
if isTrend and bias == -1 and close < ll[1]
    bearBreak := true
if isRange and not na(zScore) and zScore < -zScoreTh and close > close[1]
    meanLong := true
if isRange and not na(zScore) and zScore > zScoreTh and close < close[1]
    meanShort := true

int signal = 0
if (bullBreak or meanLong) and useLong
    signal := 1
else if (bearBreak or meanShort) and useShort
    signal := -1
else
    signal := 0

//====================================================
// 7) Strategy Label
//====================================================
string strategy = "WAIT"

if bullBreak
    strategy := "TREND BUY (Breakout)"
else if bearBreak
    strategy := "TREND SELL (Breakout)"
else if meanLong
    strategy := "MEAN REV LONG"
else if meanShort
    strategy := "MEAN REV SHORT"
else if regime == 3
    strategy := "WAIT(VOL)"
else
    strategy := "WAIT"

//====================================================
// 8) Position State
//====================================================
var int pos = 0
var float entry = na
var float sl = na
var float tp = na

bool newBuy = signal == 1 and signal[1] != 1
bool newSell = signal == -1 and signal[1] != -1

if newBuy and pos <= 0
    pos := 1
    entry := close
    sl := entry - atrVal * riskATR
    tp := entry + (entry - sl) * rr

if newSell and pos >= 0
    pos := -1
    entry := close
    sl := entry + atrVal * riskATR
    tp := entry - (sl - entry) * rr

if pos == 1
    if low <= sl or high >= tp
        pos := 0
        entry := na
        sl := na
        tp := na

if pos == -1
    if high >= sl or low <= tp
        pos := 0
        entry := na
        sl := na
        tp := na

//====================================================
// 9) Action
//====================================================
string action = "WAIT"

if newBuy
    action := "BUY"
else if newSell
    action := "SELL"
else if pos == 1
    action := "HOLD LONG"
else if pos == -1
    action := "HOLD SHORT"
else if regime == 3
    action := "WAIT(VOL)"
else
    action := "WAIT"

//====================================================
// 10) Win Probability
//====================================================
float winProb = 50.0

if isTrend
    winProb += 8.0
if isRange
    winProb += 5.0
if bias != 0
    winProb += 5.0
if bullBreak or bearBreak
    winProb += 8.0
if meanLong or meanShort
    winProb += 6.0
if not na(zScore)
    winProb += math.min(math.abs(zScore) * 1.5, 6.0)
if regime == 3
    winProb -= 6.0

if preset == "Conservative"
    winProb += 3.0
else if preset == "Aggressive"
    winProb -= 3.0

winProb := math.max(5.0, math.min(95.0, winProb))

//====================================================
// 11) Marks
//====================================================
plotshape(showMarks and newBuy, title="BUY", location=location.belowbar, color=color.green, style=shape.labelup, text="BUY", textcolor=color.white, size=size.small)
plotshape(showMarks and newSell, title="SELL", location=location.abovebar, color=color.red, style=shape.labeldown, text="SELL", textcolor=color.white, size=size.small)

//====================================================
// 12) SL / TP Lines
//====================================================
var line slLine = na
var line tpLine = na

if showLines
    if newBuy or newSell
        if not na(slLine)
            line.delete(slLine)
            slLine := na
        if not na(tpLine)
            line.delete(tpLine)
            tpLine := na
        if not na(sl)
            slLine := line.new(bar_index, sl, bar_index + 1, sl, extend=extend.right, color=color.red, width=2, style=line.style_dashed)
        if not na(tp)
            tpLine := line.new(bar_index, tp, bar_index + 1, tp, extend=extend.right, color=color.green, width=2, style=line.style_dashed)

    if pos == 0
        if not na(slLine)
            line.delete(slLine)
            slLine := na
        if not na(tpLine)
            line.delete(tpLine)
            tpLine := na
else
    if not na(slLine)
        line.delete(slLine)
        slLine := na
    if not na(tpLine)
        line.delete(tpLine)
        tpLine := na

//====================================================
// 13) Panel
//====================================================
var table dash = table.new(position.top_right, 2, 11, border_width=1)

bgHdr = color.rgb(20, 60, 110)
bgKey = color.rgb(25, 30, 40)
bgVal = color.rgb(15, 18, 24)
txtCol = color.white

f_row(table tb, int r, string k, string v, color bgv) =>
    table.cell(tb, 0, r, k, bgcolor=bgKey, text_color=txtCol)
    table.cell(tb, 1, r, v, bgcolor=bgv, text_color=txtCol)

if barstate.islast
    if showPanel
        table.cell(dash, 0, 0, "Gemini EasyMode", bgcolor=bgHdr, text_color=txtCol)
        table.cell(dash, 1, 0, syminfo.ticker, bgcolor=bgHdr, text_color=txtCol)

        f_row(dash, 1, "Category", f_catAuto(), bgVal)
        f_row(dash, 2, "Market", f_marketLabel(regime), bgVal)
        f_row(dash, 3, "Trend", f_regimeLabel(regime), bgVal)
        f_row(dash, 4, "Bias", f_biasLabel(bias), bgVal)
        f_row(dash, 5, "Strategy", strategy, bgVal)
        f_row(dash, 6, "Adaptive", preset, bgVal)
        f_row(dash, 7, "Action", action, f_actionColor(action))
        f_row(dash, 8, "Win %", f_fmtPct(winProb), bgVal)
        f_row(dash, 9, "SL", f_fmtPx(sl), bgVal)
        f_row(dash, 10, "TP", f_fmtPx(tp), bgVal)
````
