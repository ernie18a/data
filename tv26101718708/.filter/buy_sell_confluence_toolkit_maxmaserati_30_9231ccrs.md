# Buy & Sell Confluence Toolkit @MaxMaserati 3.0

- url: https://www.tradingview.com/script/9231CCRS-Buy-Sell-Confluence-Toolkit-MaxMaserati-3-0/
- type: indicator
- pine_id: PUB;7e0adf6cc24e4aaeb84c21651a746a41
- version: 1.0

## Description

Buy & Sell Confluence Toolkit

Description:

This indicator is a customizable, multi-metric analytical tool designed to aggregate lagging, leading, and structural data into a single, objective confluence score. By normalizing the output of traditional technical indicators alongside proprietary price action and volume classification rules, the script provides a unified Bullish and Bearish percentage probability model to aid in objective decision-making.

Core Confluence Engine
The script mathematically evaluates the current state of eight configurable market variables. Users can independently adjust the "Weight" (0.0 to 5.0) of each variable to prioritize the metrics that fit their personal trading style. If a weight is set to 0.0, the variable is removed from the calculation.

MACD: Evaluates MACD vs. Signal line and Histogram polarity.

KDJ: Evaluates the K vs. D line and the fast J line trajectory.

RSI: Evaluates positioning relative to the midline, neutralizing the score if extreme overbought/oversold thresholds are breached.

CCI: Evaluates momentum while neutralizing extreme readings.

VWAP: Evaluates if price is trading above or below the anchored Volume Weighted Average Price.

Moving Average: Evaluates price position and slope trajectory relative to a customizable moving average (EMA, SMA, WMA, VWMA, or HMA).

Bollinger Bands: Evaluates the %B value to determine if price resides in the upper or lower deviation band.

Volume Tiers: Evaluates current volume relative to a Volume Moving Average, categorizing volume into specific multipliers (Climax, Whale, Mid, Low).

MMM Candle Classification [Reference @HTF MMM Candle Bias Pro @MaxMaserati 3.0]

The script evaluates price structure by classifying each candlestick's open and close relative to the preceding candle's range based on the Max Maserati Model principles:

Body Close (BC): Expansion candles that close beyond the previous candle's extreme.

Affinity Sweeps (AF): Rejection candles that sweep a previous extreme but close back inside the range.

Close Inside (CI): Equilibrium candles contained entirely within the previous range.
The script dynamically paints the candlesticks by merging this structural classification with the underlying Volume Tiers.

Signal Generation & Filters
Buy and Sell signals trigger when the aggregate weighted score breaches the user's defined "Threshold %" (default is 60%). The system includes optional filters to restrict signal generation in specific environments:

MA Trend Filter: When enabled, Buy signals only trigger when price is strictly above the MA; Sell signals only trigger when below.

Price Gate Filter: A secondary structural filter requiring price to be on the correct side of either the VWAP, an ATR Trailing Stop, or the Bollinger Band Basis line.

State Machine: Prevents redundant, consecutive signals by requiring an alternating state between Buys and Sells.

Visuals and Display

Master Toggles: A centralized menu allows users to quickly toggle the visibility of the primary plots, including the VWAP, Moving Average, Bollinger Bands, and the ATR Trailing Line. Price labels can be toggled on/off to display exact structural values on the right axis.

Live Dashboard: An on-chart table displays the exact raw value, determined state (Bullish/Bearish), and assigned weight of every indicator actively driving the confluence engine in real-time.

Disclaimer: This script aggregates lagging and leading indicators into a weighted probability model. It is designed to assist with objective decision-making and structural confluence, but it is not a standalone trading strategy. Always apply independent risk management and do not rely on automated signals in isolation.

## Source Code

````pine
//@version=6
indicator("Buy & Sell Confluence Toolkit @MaxMaserati 3.0", overlay=true, max_labels_count=500, max_lines_count=100)

// =========================================================================
// 🎛️ MASTER TOGGLES
// =========================================================================
grpMaster = "Master Toggles"
showSig   = input.bool(true,  "Show Buy/Sell Labels",   group=grpMaster)
colorCdl  = input.bool(true,  "Color Candles",          group=grpMaster)
showTable = input.bool(true,  "Show Dashboard",         group=grpMaster)
showVwap  = input.bool(true,  "Show VWAP",              group=grpMaster)
showAtr   = input.bool(false, "Show ATR Trail",         group=grpMaster)
showMA    = input.bool(false, "Show Moving Average",    group=grpMaster)
showBBL   = input.bool(false, "Show Bollinger Bands",   group=grpMaster)
showBG    = input.bool(false, "Show Trend Background",  group=grpMaster)

// =========================================================================
// 🎯 SIGNAL & FILTERS
// =========================================================================
grpSig      = "Signal Settings"
bullThresh  = input.float(60.0, "Buy Threshold %",    group=grpSig, minval=10.0, maxval=100.0, step=5.0)
bearThresh  = input.float(60.0, "Sell Threshold %",   group=grpSig, minval=10.0, maxval=100.0, step=5.0)
waitClose   = input.bool(true,  "Wait For Bar Close", group=grpSig)
useMaFilter = input.bool(false, "Require MA Trend",   group=grpSig)
useGate     = input.bool(false, "Require Price Gate", group=grpSig)
gateSource  = input.string("VWAP", "Gate Reference",  group=grpSig, options=["VWAP","ATR Trail","BB Mid"])

// =========================================================================
// ⚙️ INDICATOR WEIGHTS & SETTINGS
// =========================================================================
grpMacd  = "MACD"
macdFast = input.int(12,    "Fast Length",   group=grpMacd)
macdSlow = input.int(26,    "Slow Length",   group=grpMacd)
macdSig  = input.int(9,     "Signal Length", group=grpMacd)
macdWt   = input.float(1.0, "Weight",        group=grpMacd, minval=0.0, maxval=5.0, step=0.5)

grpKdj = "KDJ"
kdjLen = input.int(9,     "Period",   group=grpKdj)
kdjSmK = input.int(3,     "Smooth K", group=grpKdj)
kdjSmD = input.int(3,     "Smooth D", group=grpKdj)
kdjWt  = input.float(1.0, "Weight",   group=grpKdj, minval=0.0, maxval=5.0, step=0.5)

grpRsi = "RSI"
rsiLen = input.int(14,    "Period",     group=grpRsi)
rsiOB  = input.int(70,    "Overbought", group=grpRsi)
rsiOS  = input.int(30,    "Oversold",   group=grpRsi)
rsiWt  = input.float(1.0, "Weight",     group=grpRsi, minval=0.0, maxval=5.0, step=0.5)

grpCci = "CCI"
cciLen = input.int(20,    "Period",     group=grpCci)
cciOB  = input.int(100,   "Overbought", group=grpCci)
cciOS  = input.int(-100,  "Oversold",   group=grpCci)
cciWt  = input.float(1.0, "Weight",     group=grpCci, minval=0.0, maxval=5.0, step=0.5)

grpVwap     = "VWAP"
vwapAnchor  = input.string("D",   "Anchor",     group=grpVwap, options=["D","W","M","3M","12M"])
vwapSrc     = input.source(hlc3,  "Source",     group=grpVwap)
vwapWt      = input.float(2.0,    "Weight",     group=grpVwap, minval=0.0, maxval=5.0, step=0.5)
vwapWidth   = input.int(2,        "Line Width", group=grpVwap, minval=1, maxval=4)
showVwapLbl = input.bool(true,    "Show Label", group=grpVwap)
vwapBullC   = input.color(color.new(#00e676, 0), "Bullish Color", group=grpVwap)
vwapBearC   = input.color(color.new(#ff1744, 0), "Bearish Color", group=grpVwap)

grpMa     = "Moving Average"
maType    = input.string("EMA",   "Type",       group=grpMa, options=["EMA","SMA","WMA","VWMA","HMA"])
maLen     = input.int(200,        "Length",     group=grpMa, minval=1)
maSrc     = input.source(close,   "Source",     group=grpMa)
maWt      = input.float(1.5,      "Weight",     group=grpMa, minval=0.0, maxval=5.0, step=0.5)
maWidth   = input.int(2,          "Line Width", group=grpMa, minval=1, maxval=4)
showMALbl = input.bool(false,     "Show Label", group=grpMa)
maBullC   = input.color(color.new(#00e676, 30), "Bullish Color", group=grpMa)
maBearC   = input.color(color.new(#ff1744, 30), "Bearish Color", group=grpMa)

grpBb    = "Bollinger Bands"
useBB    = input.bool(true,  "Enable Score",  group=grpBb)
bbLen    = input.int(20,     "Length",        group=grpBb)
bbMult   = input.float(2.0,  "Std Dev",       group=grpBb, step=0.1)
bbWt     = input.float(1.0,  "Weight",        group=grpBb, minval=0.0, maxval=5.0, step=0.5)
bbUpperC = input.color(color.new(#2196f3, 60), "Upper Band", group=grpBb)
bbMidC   = input.color(color.new(#2196f3, 80), "Basis",      group=grpBb)
bbLowerC = input.color(color.new(#2196f3, 60), "Lower Band", group=grpBb)

grpVol    = "Volume Tiers"
volMaLen  = input.int(20,    "MA Length",         group=grpVol)
volWt     = input.float(1.0, "Weight",            group=grpVol, minval=0.0, maxval=5.0, step=0.5)
ultraMult = input.float(3.0, "Climax Multiplier", group=grpVol, step=0.1)
whaleMult = input.float(2.0, "Whale Multiplier",  group=grpVol, step=0.1)
midMult   = input.float(0.8, "Mid Multiplier",    group=grpVol, step=0.1)

grpAtr     = "ATR Trailing Stop"
trendAtrL  = input.int(14,     "Length",      group=grpAtr)
trendAtrM  = input.float(1.5,  "Multiplier",  group=grpAtr, step=0.1)
trendWidth = input.int(2,      "Line Width",  group=grpAtr, minval=1, maxval=4)
showAtrLbl = input.bool(true,  "Show Label",  group=grpAtr)
trendBullC = input.color(color.new(#00e676, 0), "Bullish Color", group=grpAtr)
trendBearC = input.color(color.new(#ff1744, 0), "Bearish Color", group=grpAtr)

// =========================================================================
// 🎨 VISUALS & UI SETTINGS
// =========================================================================
grpCdl = "Candle Colors"
c_bubc_climax = input.color(color.new(#00bcd4,  0), "BuBC Climax", group=grpCdl, inline="bubc")
c_bubc_whale  = input.color(color.new(#006400,  0), "Whale",       group=grpCdl, inline="bubc")
c_bubc_mid    = input.color(color.new(#00e676, 30), "Mid",         group=grpCdl, inline="bubc")
c_bubc_low    = input.color(color.new(#00e676, 72), "Low",         group=grpCdl, inline="bubc")
c_bebc_climax = input.color(color.new(#4a148c,  0), "BeBC Climax", group=grpCdl, inline="bebc")
c_bebc_whale  = input.color(color.new(#e91e63,  0), "Whale",       group=grpCdl, inline="bebc")
c_bebc_mid    = input.color(color.new(#ff1744, 30), "Mid",         group=grpCdl, inline="bebc")
c_bebc_low    = input.color(color.new(#ff1744, 72), "Low",         group=grpCdl, inline="bebc")
c_buaf_climax = input.color(color.new(#00bcd4, 10), "BuAF Climax", group=grpCdl, inline="buaf")
c_buaf_whale  = input.color(color.new(#00bcd4, 35), "Whale",       group=grpCdl, inline="buaf")
c_buaf_low    = input.color(color.new(#00bcd4, 65), "Low",         group=grpCdl, inline="buaf")
c_beaf_climax = input.color(color.new(#ff9800, 10), "BeAF Climax", group=grpCdl, inline="beaf")
c_beaf_whale  = input.color(color.new(#ff9800, 35), "Whale",       group=grpCdl, inline="beaf")
c_beaf_low    = input.color(color.new(#ff9800, 65), "Low",         group=grpCdl, inline="beaf")
c_cont_bull   = input.color(color.new(#2962ff, 75), "CI Bull",     group=grpCdl, inline="ci")
c_cont_bear   = input.color(color.new(#000000, 75), "CI Bear",     group=grpCdl, inline="ci")

grpUi = "UI & Background"
lblSzIn  = input.string("Tiny","Label Size",            group=grpUi, options=["Tiny","Small","Normal","Large"])
buyBGC   = input.color(color.new(#00e676, 0), "Buy BG",     group=grpUi, inline="lb1")
buyTxtC  = input.color(color.white,            "Text",       group=grpUi, inline="lb1")
sellBGC  = input.color(color.new(#ff1744, 0), "Sell BG",    group=grpUi, inline="lb2")
sellTxtC = input.color(color.white,            "Text",       group=grpUi, inline="lb2")
bullBGC  = input.color(color.new(#00e676, 92), "Bull BG",    group=grpUi, inline="bg")
bearBGC  = input.color(color.new(#ff1744, 92), "Bear BG",    group=grpUi, inline="bg")
tblPos   = input.string("Bottom Right", "Table Position", group=grpUi, options=["Bottom Right","Bottom Left","Top Right","Top Left","Middle Right","Middle Left"])
tblSzIn  = input.string("Small",        "Table Size",     group=grpUi, options=["Tiny","Small","Normal","Large"])

toSize(s) => s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Large" ? size.large : size.normal

// =========================================================================
// CANDLE CLASSIFICATION
// =========================================================================
_isBuBC = close > high[1] and close > open
_isBeBC = close < low[1]  and close < open
_isNBC  = not _isBuBC and not _isBeBC
_isBuAF = low  < low[1]  and close >= open and _isNBC
_isBeAF = high > high[1] and close <= open and _isNBC
_isCI   = high < high[1] and low > low[1]

// =========================================================================
// VOLUME TIERS
// =========================================================================
_vs     = ta.sma(volume, volMaLen)
_vIsU   = volume >= _vs * ultraMult
_vIsW   = volume >= _vs * whaleMult  and not _vIsU
_vIsM   = volume >= _vs * midMult    and not _vIsW and not _vIsU
_vIsLow = volume <  _vs * midMult
_vRat   = _vs > 0 ? volume / _vs : 1.0

color _cdlColor = na
if colorCdl
    if _isBuBC
        _cdlColor := _vIsU ? c_bubc_climax : _vIsW ? c_bubc_whale : _vIsM ? c_bubc_mid : c_bubc_low
    else if _isBeBC
        _cdlColor := _vIsU ? c_bebc_climax : _vIsW ? c_bebc_whale : _vIsM ? c_bebc_mid : c_bebc_low
    else if _isBuAF
        _cdlColor := (_vIsU or _vIsW) ? c_buaf_climax : _vIsM ? c_buaf_whale : c_buaf_low
    else if _isBeAF
        _cdlColor := (_vIsU or _vIsW) ? c_beaf_climax : _vIsM ? c_beaf_whale : c_beaf_low
    else
        _cdlColor := close >= open ? c_cont_bull : c_cont_bear
barcolor(_cdlColor)

// =========================================================================
// INDICATOR CALCULATIONS
// =========================================================================
// MACD
[macdLine, sigLine, hist] = ta.macd(close, macdFast, macdSlow, macdSig)
macdState = macdLine > sigLine and hist > 0 ? 2 : macdLine < sigLine and hist < 0 ? 0 : 1

// KDJ
_lo  = ta.lowest(low,   kdjLen)
_hi  = ta.highest(high, kdjLen)
_rk  = 100.0 * (close - _lo) / math.max(_hi - _lo, 1e-10)
_k   = ta.sma(_rk, kdjSmK)
_d   = ta.sma(_k,  kdjSmD)
_j   = 3.0 * _k - 2.0 * _d
kdjState = _k > _d and _j > _k ? 2 : _k < _d and _j < _k ? 0 : 1

// RSI
rsiVal   = ta.rsi(close, rsiLen)
rsiState = rsiVal >= rsiOB or rsiVal <= rsiOS ? 1 : rsiVal > 50 ? 2 : rsiVal < 50 ? 0 : 1

// CCI
cciVal   = ta.cci(hlc3, cciLen)
cciState = cciVal >= cciOB or cciVal <= cciOS ? 1 : cciVal > 0 ? 2 : cciVal < 0 ? 0 : 1

// VWAP
var float _vpv = 0.0
var float _vv  = 0.0
if timeframe.change(vwapAnchor)
    _vpv := vwapSrc * volume
    _vv  := volume
else
    _vpv += vwapSrc * volume
    _vv  += volume
_vwapVal  = _vv > 0 ? _vpv / _vv : na
_vwapBull = not na(_vwapVal) and close > _vwapVal
vwapState = _vwapBull ? 2 : not na(_vwapVal) and close < _vwapVal ? 0 : 1
_vwapClr  = _vwapBull ? vwapBullC : vwapBearC
plot(showVwap and not na(_vwapVal) ? _vwapVal : na, "VWAP", color=_vwapClr, linewidth=vwapWidth)

// Moving Average
calcMA(src, len, t) =>
    float out = na
    if t == "SMA"
        out := ta.sma(src, len)
    else if t == "WMA"
        out := ta.wma(src, len)
    else if t == "VWMA"
        out := ta.vwma(src, len)
    else if t == "HMA"
        out := ta.hma(src, len)
    else
        out := ta.ema(src, len)
    out
_maVal   = calcMA(maSrc, maLen, maType)
_maSlope = _maVal > _maVal[2]
_maBull  = close > _maVal and _maSlope
_maBear  = close < _maVal and not _maSlope
maState  = _maBull ? 2 : _maBear ? 0 : 1
_maClr   = _maBull ? maBullC : maBearC
plot(showMA ? _maVal : na, "MA", color=_maClr, linewidth=maWidth)

// Bollinger Bands
[_bbu, _bbm, _bbl2] = ta.bb(close, bbLen, bbMult)
_bbPct  = (_bbu - _bbl2) > 0 ? (close - _bbl2) / (_bbu - _bbl2) * 100 : 50.0
bbState = useBB ? (_bbPct > 60 ? 2 : _bbPct < 40 ? 0 : 1) : 1
plot(showBBL ? _bbu  : na, "BB Upper", color=bbUpperC, linewidth=1)
plot(showBBL ? _bbm  : na, "BB Basis", color=bbMidC,   linewidth=1)
plot(showBBL ? _bbl2 : na, "BB Lower", color=bbLowerC, linewidth=1)

// Volume State
volState = close > open and (_vIsM or _vIsW or _vIsU) ? 2 : close < open and (_vIsM or _vIsW or _vIsU) ? 0 : 1

// =========================================================================
// SCORE COMPUTATION
// =========================================================================
_bbWtA = useBB ? bbWt : 0.0
_totWt = macdWt + kdjWt + rsiWt + cciWt + vwapWt + maWt + volWt + _bbWtA

_bSc  = (macdState==2?macdWt:0.0) + (kdjState==2?kdjWt:0.0) + (rsiState==2?rsiWt:0.0) + (cciState==2?cciWt:0.0) + (vwapState==2?vwapWt:0.0) + (maState==2?maWt:0.0) + (volState==2?volWt:0.0) + (bbState==2?_bbWtA:0.0)
_seSc = (macdState==0?macdWt:0.0) + (kdjState==0?kdjWt:0.0) + (rsiState==0?rsiWt:0.0) + (cciState==0?cciWt:0.0) + (vwapState==0?vwapWt:0.0) + (maState==0?maWt:0.0) + (volState==0?volWt:0.0) + (bbState==0?_bbWtA:0.0)

bullPct = _totWt > 0 ? _bSc  / _totWt * 100 : 0.0
bearPct = _totWt > 0 ? _seSc / _totWt * 100 : 0.0

// =========================================================================
// ATR TRAIL & STATE MACHINE
// =========================================================================
_atr = ta.atr(trendAtrL)
var float trendLine = na
var int   trendDir  = 0

_rawBuyEdge  = bullPct >= bullThresh and bullPct[1] < bullThresh
_rawSellEdge = bearPct >= bearThresh and bearPct[1] < bearThresh

_barOk        = waitClose ? barstate.isconfirmed : true
_maFilterBuy  = not useMaFilter or close > _maVal
_maFilterSell = not useMaFilter or close < _maVal

var int lastSig = 0
_candleBuy  = _rawBuyEdge  and _barOk and _maFilterBuy  and lastSig != 1
_candleSell = _rawSellEdge and _barOk and _maFilterSell and lastSig != -1

if _candleBuy
    lastSig := 1
else if _candleSell
    lastSig := -1

if _candleBuy
    trendDir  := 1
    trendLine := low - _atr * trendAtrM
else if _candleSell
    trendDir  := -1
    trendLine := high + _atr * trendAtrM
else if trendDir == 1
    trendLine := math.max(nz(trendLine[1]), low - _atr * trendAtrM)
else if trendDir == -1
    trendLine := math.min(nz(trendLine[1]), high + _atr * trendAtrM)

_gateLine     = gateSource == "ATR Trail" ? trendLine : gateSource == "BB Mid" ? _bbm : _vwapVal
_gatePassBuy  = not useGate or na(_gateLine) or close > _gateLine
_gatePassSell = not useGate or na(_gateLine) or close < _gateLine

buySignal  = _candleBuy  and _gatePassBuy
sellSignal = _candleSell and _gatePassSell

_trendClr = trendDir >= 0 ? trendBullC : trendBearC
plot(showAtr and trendDir != 0 ? trendLine : na, "ATR Trail", color=_trendClr, linewidth=trendWidth)
bgcolor(showBG and lastSig != 0 ? (lastSig == 1 ? bullBGC : bearBGC) : na, title="Trend BG")

// =========================================================================
// LABELS
// =========================================================================
var label _vwapEndLbl = na
var label _maEndLbl   = na
var label _atrEndLbl  = na

if barstate.islast
    label.delete(_vwapEndLbl)
    label.delete(_maEndLbl)
    label.delete(_atrEndLbl)
    if showVwap and showVwapLbl and not na(_vwapVal)
        _vwapEndLbl := label.new(bar_index + 2, _vwapVal, "VWAP", xloc=xloc.bar_index, color=color.new(color.black, 100), textcolor=_vwapClr, style=label.style_label_left, size=size.tiny)
    if showMA and showMALbl
        _maEndLbl := label.new(bar_index + 2, _maVal, maType + str.tostring(maLen), xloc=xloc.bar_index, color=color.new(color.black, 100), textcolor=_maClr, style=label.style_label_left, size=size.tiny)
    if showAtr and showAtrLbl and not na(trendLine)
        _atrEndLbl := label.new(bar_index + 2, trendLine, "ATR Trail", xloc=xloc.bar_index, color=color.new(color.black, 100), textcolor=_trendClr, style=label.style_label_left, size=size.tiny)

_lblSz = toSize(lblSzIn)
if showSig and buySignal
    label.new(bar_index, low,  "BUY",  xloc=xloc.bar_index, yloc=yloc.belowbar, color=buyBGC,  textcolor=buyTxtC,  style=label.style_label_up,   size=_lblSz)
if showSig and sellSignal
    label.new(bar_index, high, "SELL", xloc=xloc.bar_index, yloc=yloc.abovebar, color=sellBGC, textcolor=sellTxtC, style=label.style_label_down, size=_lblSz)

// =========================================================================
// DASHBOARD TABLE
// =========================================================================
sClr(s) => s == 2 ? color.new(#00e676, 0) : s == 0 ? color.new(#ff1744, 0) : color.new(#ffab00, 0)
sChr(s) => s == 2 ? "▲" : s == 0 ? "▼" : "─"

mkBar(pct) =>
    int n = math.round(pct / 10)
    string b = ""
    for i = 1 to 10
        b := b + (i <= n ? "█" : "░")
    b

_tp = tblPos == "Bottom Left" ? position.bottom_left : tblPos == "Top Right" ? position.top_right : tblPos == "Top Left" ? position.top_left : tblPos == "Middle Right" ? position.middle_right : tblPos == "Middle Left" ? position.middle_left : position.bottom_right
var table tbl = table.new(_tp, 4, 12, bgcolor=color.new(#0d1117, 10), border_color=color.new(#30363d, 80), border_width=1, frame_color=color.new(#58a6ff, 60), frame_width=2)

hBG = color.new(#161b22, 0)
cBG = color.new(#0d1117, 20)
sBG = color.new(#1c2128, 0)

if showTable and barstate.islast
    _ts = toSize(tblSzIn)

    table.cell(tbl, 0, 0,  "INDICATOR",     text_color=#8b949e, text_size=_ts, bgcolor=hBG, text_halign=text.align_left)
    table.cell(tbl, 1, 0,  "SIG",           text_color=#8b949e, text_size=_ts, bgcolor=hBG)
    table.cell(tbl, 2, 0,  "WT",            text_color=#8b949e, text_size=_ts, bgcolor=hBG)
    table.cell(tbl, 3, 0,  "VALUE",         text_color=#8b949e, text_size=_ts, bgcolor=hBG)

    table.cell(tbl, 0, 1,  "MACD",          text_color=#58a6ff, text_size=_ts, bgcolor=hBG, text_halign=text.align_left)
    table.cell(tbl, 1, 1,  sChr(macdState), text_color=sClr(macdState), text_size=_ts, bgcolor=cBG)
    table.cell(tbl, 2, 1,  str.tostring(macdWt), text_color=#8b949e, text_size=_ts, bgcolor=cBG)
    table.cell(tbl, 3, 1,  str.tostring(math.round(hist, 4)), text_color=sClr(macdState), text_size=_ts, bgcolor=cBG)

    table.cell(tbl, 0, 2,  "KDJ",           text_color=#f0b429, text_size=_ts, bgcolor=hBG, text_halign=text.align_left)
    table.cell(tbl, 1, 2,  sChr(kdjState),  text_color=sClr(kdjState), text_size=_ts, bgcolor=cBG)
    table.cell(tbl, 2, 2,  str.tostring(kdjWt), text_color=#8b949e, text_size=_ts, bgcolor=cBG)
    table.cell(tbl, 3, 2,  "K:" + str.tostring(math.round(_k,1)) + " J:" + str.tostring(math.round(_j,1)), text_color=sClr(kdjState), text_size=_ts, bgcolor=cBG)

    table.cell(tbl, 0, 3,  "RSI",           text_color=#3fb950, text_size=_ts, bgcolor=hBG, text_halign=text.align_left)
    table.cell(tbl, 1, 3,  sChr(rsiState),  text_color=sClr(rsiState), text_size=_ts, bgcolor=cBG)
    table.cell(tbl, 2, 3,  str.tostring(rsiWt), text_color=#8b949e, text_size=_ts, bgcolor=cBG)
    table.cell(tbl, 3, 3,  str.tostring(math.round(rsiVal, 1)), text_color=sClr(rsiState), text_size=_ts, bgcolor=cBG)

    table.cell(tbl, 0, 4,  "CCI",           text_color=#bc8cff, text_size=_ts, bgcolor=hBG, text_halign=text.align_left)
    table.cell(tbl, 1, 4,  sChr(cciState),  text_color=sClr(cciState), text_size=_ts, bgcolor=cBG)
    table.cell(tbl, 2, 4,  str.tostring(cciWt), text_color=#8b949e, text_size=_ts, bgcolor=cBG)
    table.cell(tbl, 3, 4,  str.tostring(math.round(cciVal, 1)), text_color=sClr(cciState), text_size=_ts, bgcolor=cBG)

    table.cell(tbl, 0, 5,  "VWAP",          text_color=#ff9800, text_size=_ts, bgcolor=hBG, text_halign=text.align_left)
    table.cell(tbl, 1, 5,  sChr(vwapState), text_color=sClr(vwapState), text_size=_ts, bgcolor=cBG)
    table.cell(tbl, 2, 5,  str.tostring(vwapWt), text_color=#8b949e, text_size=_ts, bgcolor=cBG)
    table.cell(tbl, 3, 5,  not na(_vwapVal) ? str.tostring(math.round(_vwapVal, 2)) : "─", text_color=sClr(vwapState), text_size=_ts, bgcolor=cBG)

    table.cell(tbl, 0, 6,  maType + str.tostring(maLen), text_color=#e040fb, text_size=_ts, bgcolor=hBG, text_halign=text.align_left)
    table.cell(tbl, 1, 6,  sChr(maState),   text_color=sClr(maState), text_size=_ts, bgcolor=cBG)
    table.cell(tbl, 2, 6,  str.tostring(maWt), text_color=#8b949e, text_size=_ts, bgcolor=cBG)
    table.cell(tbl, 3, 6,  str.tostring(math.round(_maVal, 2)), text_color=sClr(maState), text_size=_ts, bgcolor=cBG)

    _volTierLbl = _vIsU ? "CLIMAX" : _vIsW ? "WHALE" : _vIsM ? "MID" : "LOW"
    table.cell(tbl, 0, 7,  "VOL " + _volTierLbl, text_color=#26c6da, text_size=_ts, bgcolor=hBG, text_halign=text.align_left)
    table.cell(tbl, 1, 7,  sChr(volState),  text_color=sClr(volState), text_size=_ts, bgcolor=cBG)
    table.cell(tbl, 2, 7,  str.tostring(volWt), text_color=#8b949e, text_size=_ts, bgcolor=cBG)
    table.cell(tbl, 3, 7,  str.tostring(math.round(_vRat, 1)) + "x", text_color=sClr(volState), text_size=_ts, bgcolor=cBG)

    _bbLbl = useBB ? "BB" : "BB OFF"
    _bbC   = useBB ? sClr(bbState) : color.new(#8b949e, 50)
    _bbChr = useBB ? sChr(bbState) : "─"
    table.cell(tbl, 0, 8,  _bbLbl,          text_color=#e91e63, text_size=_ts, bgcolor=hBG, text_halign=text.align_left)
    table.cell(tbl, 1, 8,  _bbChr,          text_color=_bbC, text_size=_ts, bgcolor=cBG)
    table.cell(tbl, 2, 8,  str.tostring(bbWt), text_color=#8b949e, text_size=_ts, bgcolor=cBG)
    table.cell(tbl, 3, 8,  str.tostring(math.round(_bbPct, 1)) + "%B", text_color=_bbC, text_size=_ts, bgcolor=cBG)

    _cdlTypeLbl = _isBuBC ? "BuBC" : _isBeBC ? "BeBC" : _isBuAF ? "BuAF" : _isBeAF ? "BeAF" : _isCI ? "CI" : "NBC"
    _cdlTypeClr = _isBuBC ? color.new(#00e676,0) : _isBeBC ? color.new(#ff1744,0) : _isBuAF ? color.new(#00bcd4,0) : _isBeAF ? color.new(#ff9800,0) : color.new(#787b86,0)
    table.cell(tbl, 0, 9,  "CANDLE",        text_color=#8b949e, text_size=_ts, bgcolor=hBG, text_halign=text.align_left)
    table.cell(tbl, 1, 9,  _cdlTypeLbl,     text_color=_cdlTypeClr, text_size=_ts, bgcolor=cBG)
    table.cell(tbl, 2, 9,  _vIsU ? "CLMX" : _vIsW ? "WHLE" : _vIsM ? "MID" : "LOW", text_color=#26c6da, text_size=_ts, bgcolor=cBG)
    table.cell(tbl, 3, 9,  str.tostring(math.round(_vRat,1)) + "x vol", text_color=#8b949e, text_size=_ts, bgcolor=cBG)

    _fltLbl   = useGate ? "GATE: " + gateSource : useMaFilter ? "FILTER: MA" : "NO FILTER"
    _fltClr   = useGate or useMaFilter ? color.new(#ffab00,0) : color.new(#8b949e,50)
    _closeLbl = waitClose ? "CLOSE CONF" : "LIVE"
    table.cell(tbl, 0, 10, _fltLbl,         text_color=_fltClr, text_size=_ts, bgcolor=sBG, text_halign=text.align_left)
    table.cell(tbl, 1, 10, _closeLbl,        text_color=waitClose ? color.new(#00e676,0) : color.new(#ffab00,0), text_size=_ts, bgcolor=sBG)
    table.cell(tbl, 2, 10, "",               text_color=#8b949e, text_size=_ts, bgcolor=sBG)
    table.cell(tbl, 3, 10, "",               text_color=#8b949e, text_size=_ts, bgcolor=sBG)

    _domBull  = bullPct >= bearPct
    _domPct   = _domBull ? bullPct : bearPct
    _scoreClr = _domBull ? color.new(#00e676, 0) : color.new(#ff1744, 0)
    _thr      = _domBull ? bullThresh : bearThresh
    _nextLbl  = _domBull ? "▲ BULL " + str.tostring(math.round(bullPct,0)) + "%" : "▼ BEAR " + str.tostring(math.round(bearPct,0)) + "%"
    table.cell(tbl, 0, 11, _nextLbl,        text_color=_scoreClr, text_size=_ts, bgcolor=sBG, text_halign=text.align_left)
    table.cell(tbl, 1, 11, mkBar(_domPct),  text_color=_scoreClr, text_size=_ts, bgcolor=sBG)
    table.cell(tbl, 2, 11, "THR",           text_color=#8b949e,   text_size=_ts, bgcolor=sBG)
    table.cell(tbl, 3, 11, str.tostring(math.round(_thr,0)) + "%", text_color=#8b949e, text_size=_ts, bgcolor=sBG)

// =========================================================================
// ALERTS
// =========================================================================
alertcondition(buySignal,  "HCT BUY Signal",  "High Confluence Toolkit: BUY signal fired")
alertcondition(sellSignal, "HCT SELL Signal", "High Confluence Toolkit: SELL signal fired")
````
