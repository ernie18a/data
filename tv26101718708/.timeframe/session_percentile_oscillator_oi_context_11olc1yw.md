# Session Percentile Oscillator + OI Context

- url: https://www.tradingview.com/script/11olC1Yw-Session-Percentile-Oscillator-OI-Context/
- type: indicator
- pine_id: PUB;e69bf4e9311949bba7ca94a3e97dc4af
- version: 1.0

## Description

# Session Percentile Oscillator with OI Context

The Session Percentile Oscillator measures how much the current trading session has expanded relative to historical sessions of the same type (Asia, London, New York AM, Lunch, and New York PM).

Instead of looking at raw volatility, the indicator normalizes each session's range by ATR and compares it against historical observations. The result is a percentile score between 0 and 100.

A reading of:

* 20 means the current session is larger than only 20% of comparable historical sessions.
* 80 means the current session is larger than 80% of comparable historical sessions.
* 95 means the current session is larger than 95% of comparable historical sessions.

The goal is not to predict direction, but to measure how much effort is entering the market.

## OI Context Engine

The percentile line and velocity histogram are colored using aggregated Open Interest data collected from multiple derivatives exchanges.

The indicator combines:

* Aggregated Open Interest
* Volume Delta (CVD)
* OBV
* Price direction

to classify activity into:

* Green = Long building
* Red = Short building
* Aqua = Short covering
* Blue = Aggressive short squeeze
* Orange = Long liquidation

Unlike traditional OI indicators, mixed conditions are resolved using a probability engine and price/OI fallback logic, which prevents neutral gray states and keeps market positioning easier to read.

## Percentile Velocity Histogram

The histogram below the oscillator represents percentile velocity.

It measures how quickly the session percentile is changing.

* Positive values indicate expanding effort.
* Negative values indicate fading effort.

This is often useful for spotting acceleration before price fully reacts.

## ⚡ Effort Expansion

One of the key features of the indicator is the Effort Expansion warning.

The signal appears when the percentile slope is rising unusually fast compared to its own historical behavior.

Rather than using a fixed threshold, the indicator compares the current percentile slope against a rolling history and identifies situations where effort is expanding faster than normal.

The signal does not predict bullish or bearish direction.

It simply warns that market effort is increasing aggressively and that traders should pay closer attention to price structure, support/resistance, and OI context.

## D — Effort Divergence

The indicator can display effort divergences.

Bearish Divergence (D):

* Price makes a higher high.
* Percentile effort fails to make a higher high.

Bullish Divergence (D):

* Price makes a lower low.
* Percentile effort fails to make a lower low.

These signals can help identify weakening participation behind price extremes.

## E — Exhaustion / Absorption

The optional E marker appears when:

* Percentile effort remains elevated.
* Price produces little result.

This condition can indicate absorption, exhaustion, or inefficient effort where substantial market activity is producing limited directional progress.

## How To Use

The oscillator is best used as a market participation and effort tool.

Typical workflow:

1. Identify whether effort is expanding or contracting.
2. Use OI colors to understand who is likely driving the move.
3. Watch for ⚡ Effort Expansion events.
4. Use D and E markers to identify divergence or exhaustion.
5. Use price action and market structure to determine direction.

The indicator is designed to answer a different question than traditional oscillators:

"How much effort is entering the market relative to what is normally observed during this session?"

## Source Code

````pine
//@version=6
indicator("Session Percentile Oscillator + OI Context", overlay=false, max_bars_back=5000, dynamic_requests=true)

import TradingView/ta/8 as tvTa

// ─────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────
GP_SESS = "Sessions"
GP_FILT = "Filters"
GP_OSC  = "Oscillator"
GP_OI   = "OI Context"

enAsia     = input.bool(true, "Asia", group=GP_SESS)
asiaTime   = input.session("1900-0200", "Asia Time", group=GP_SESS)

enLondon   = input.bool(true, "London", group=GP_SESS)
londonTime = input.session("0200-0830", "London Time", group=GP_SESS)

enNYAM     = input.bool(true, "NY AM", group=GP_SESS)
nyamTime   = input.session("0830-1200", "NY AM Time", group=GP_SESS)

enLunch    = input.bool(true, "NY Lunch", group=GP_SESS)
lunchTime  = input.session("1200-1330", "NY Lunch Time", group=GP_SESS)

enNYPM     = input.bool(true, "NY PM", group=GP_SESS)
nypmTime   = input.session("1330-1600", "NY PM Time", group=GP_SESS)

wdSun = input.bool(false, "Sun", inline="wd", group=GP_FILT)
wdMon = input.bool(true,  "Mon", inline="wd", group=GP_FILT)
wdTue = input.bool(true,  "Tue", inline="wd", group=GP_FILT)
wdWed = input.bool(true,  "Wed", inline="wd", group=GP_FILT)
wdThu = input.bool(true,  "Thu", inline="wd", group=GP_FILT)
wdFri = input.bool(true,  "Fri", inline="wd", group=GP_FILT)
wdSat = input.bool(false, "Sat", inline="wd", group=GP_FILT)

atrLen = input.int(14, "ATR Length", minval=5, maxval=50, group=GP_FILT)

showPctLine = input.bool(true, "Plot Session Percentile", group=GP_OSC)
showVelLine = input.bool(true, "Plot Percentile Velocity", group=GP_OSC)
velLookback = input.int(3, "Velocity Lookback", minval=1, maxval=50, group=GP_OSC)

smoothMode = input.string("Rational Quadratic", "Smoothing", options=["None", "SMA", "EMA", "RMA", "Rational Quadratic"], group=GP_OSC)
smoothLen  = input.int(5, "Smooth Length", minval=1, maxval=100, group=GP_OSC)
rqWeight   = input.float(0.5, "RQ Relative Weight", minval=0.1, step=0.1, group=GP_OSC)

colorLineByOI = input.bool(true, "Color percentile line by OI state", group=GP_OI)
showOIBack    = input.bool(false, "Background Color", group=GP_OI)
showRegimeBg  = input.bool(false, "Background Color", group=GP_OSC)

typ2 = input.string("COIN", "OI Units", options=["USD", "COIN"], group=GP_OI)

ex1 = input.bool(true,  "Binance", group=GP_OI)
ex2 = input.bool(true,  "Bybit",   group=GP_OI)
ex3 = input.bool(true,  "OKX",     group=GP_OI)
ex5 = input.bool(true,  "Bitget",  group=GP_OI)
ex6 = input.bool(true,  "Kraken",  group=GP_OI)
ex7 = input.bool(true,  "HTX",     group=GP_OI)
ex8 = input.bool(true,  "Deribit", group=GP_OI)

lenEMA = input.int(21, "OI/CVD/OBV EMA", minval=1, group=GP_OI)
lenROC = input.int(5, "Slope ROC", minval=1, group=GP_OI)
thr    = input.float(0.0, "Slope Threshold", step=0.01, group=GP_OI)

volLen = input.int(20, "Volume MA Length", minval=1, group=GP_OI)
atrLenOI = input.int(14, "OI ATR Length", minval=1, group=GP_OI)

shortLiqVolMult   = input.float(1.5, "Blue squeeze volume multiplier", minval=0.1, step=0.1, group=GP_OI)
shortLiqAtrMult   = input.float(0.8, "Blue squeeze body ATR multiplier", minval=0.1, step=0.1, group=GP_OI)
shortLiqOiDropPct = input.float(0.5, "Blue squeeze OI drop %", minval=0.05, step=0.05, group=GP_OI)

cBullOI     = input.color(#2962ffa7, "Fallback bull OI build color", group=GP_OI)
cBearOI     = input.color(#e91e62a6, "Fallback bear OI unwind color", group=GP_OI)
cLongBuild  = input.color(color.lime,   "Green: price↑ + OI↑", group=GP_OI)
cShortBuild = input.color(color.red,    "Red: price↓ + OI↑", group=GP_OI)
cShortCover = input.color(color.aqua,   "Aqua: price↑ + OI↓", group=GP_OI)
cShortLiq   = input.color(color.blue,   "Blue: strong short covering", group=GP_OI)
cLongLiq    = input.color(color.orange, "Orange: price↓ + OI↓", group=GP_OI)
enableMixedOverride = input.bool(true, "Override mixed with price/OI logic", group=GP_OI)

// ─────────────────────────────────────────────
// Effort Expansion / Divergence / Exhaustion
// ─────────────────────────────────────────────
GP_INS = "Effort Signals"

showEffortExpansionTable = input.bool(true, "Show ⚡ Effort Expansion table", group=GP_INS)
expansionTextSize        = input.string("normal", "Expansion table text size", options=["tiny", "small", "normal", "large"], group=GP_INS)

showDivergenceMarkers = input.bool(true, "Show D divergence markers", group=GP_INS)
showExhaustionMarkers = input.bool(true, "Show E exhaustion marker", group=GP_INS)

priceRocLen = input.int(3, "Price ROC length", minval=1, maxval=50, group=GP_INS)
divLookback = input.int(20, "Divergence lookback", minval=5, maxval=100, group=GP_INS)

highEffortMin = input.float(70.0, "High effort threshold", minval=0, maxval=100, step=1, group=GP_INS)
lowResultPct  = input.float(0.20, "Low price result %", minval=0.01, step=0.01, group=GP_INS)

// Aggressive effort expansion = percentile slope is strong versus its own recent history.
effortSlopeLen      = input.int(3, "Effort slope length", minval=1, maxval=50, group=GP_INS)
effortSlopeHistLen  = input.int(200, "Effort slope history", minval=50, maxval=2000, group=GP_INS)
effortSlopeRankThr  = input.float(90.0, "Aggressive slope rank", minval=50, maxval=100, step=1, group=GP_INS)
minEffortSlope      = input.float(8.0, "Minimum effort slope", minval=0.1, step=0.5, group=GP_INS)
requireAcceleration = input.bool(true, "Require positive acceleration", group=GP_INS)

// ─────────────────────────────────────────────
// Smoothing
// ─────────────────────────────────────────────
rationalQuadratic(series float src, int lookback, float relativeWeight) =>
    currentWeight = 0.0
    cumulativeWeight = 0.0
    for i = 0 to lookback
        y = nz(src[i])
        w = math.pow(1 + math.pow(i, 2) / (math.pow(lookback, 2) * 2 * relativeWeight), -relativeWeight)
        currentWeight += y * w
        cumulativeWeight += w
    cumulativeWeight != 0 ? currentWeight / cumulativeWeight : src

smooth(series float src) =>
    switch smoothMode
        "SMA" => ta.sma(src, smoothLen)
        "EMA" => ta.ema(src, smoothLen)
        "RMA" => ta.rma(src, smoothLen)
        "Rational Quadratic" => rationalQuadratic(src, smoothLen, rqWeight)
        => src

// ─────────────────────────────────────────────
// Session types
// ─────────────────────────────────────────────
type Rec
    int wkday
    float normRng

type Sess
    bool on
    string name
    array<Rec> hist
    float cHi
    float cLo
    int cBar
    bool act
    float dHi
    float dLo
    bool dDone

mkSess(bool enabled, string name) =>
    Sess.new(enabled, name, array.new<Rec>(), na, na, na, false, na, na, false)

wdPass(int wd) =>
    switch wd
        1 => wdSun
        2 => wdMon
        3 => wdTue
        4 => wdWed
        5 => wdThu
        6 => wdFri
        7 => wdSat
        => false

method reset(Sess s) =>
    s.cHi   := high
    s.cLo   := low
    s.cBar  := bar_index
    s.act   := true
    s.dDone := false

method update(Sess s) =>
    s.cHi := math.max(s.cHi, high)
    s.cLo := math.min(s.cLo, low)

method closeSession(Sess s) =>
    s.dHi   := s.cHi
    s.dLo   := s.cLo
    s.dDone := true
    s.act   := false

method resetDay(Sess s) =>
    s.dHi   := na
    s.dLo   := na
    s.dDone := false

method currentNorm(Sess s, float dATR) =>
    s.act and not na(dATR) and dATR > 0 ? (s.cHi - s.cLo) / dATR : na

method currentPercentile(Sess s, float dATR) =>
    curNorm = s.currentNorm(dATR)
    if na(curNorm) or s.hist.size() == 0
        na
    else
        below = 0
        total = 0
        for j = 0 to s.hist.size() - 1
            r = s.hist.get(j)
            if wdPass(r.wkday)
                total += 1
                if r.normRng <= curNorm
                    below += 1
        total > 0 ? below * 100.0 / total : na

// ─────────────────────────────────────────────
// ATR and trading day
// ─────────────────────────────────────────────
atr = ta.atr(atrLen)
dATR = request.security(syminfo.tickerid, "D", atr[1], lookahead=barmerge.lookahead_on)

tdShift = 6 * 3600 * 1000
tdDate  = 10000 * year(time + tdShift, "America/New_York") + 100 * month(time + tdShift, "America/New_York") + dayofmonth(time + tdShift, "America/New_York")
tdWk    = dayofweek(time + tdShift, "America/New_York")

// ─────────────────────────────────────────────
// Sessions
// ─────────────────────────────────────────────
var Sess sAsia   = mkSess(enAsia,   "Asia")
var Sess sLondon = mkSess(enLondon, "London")
var Sess sNYAM   = mkSess(enNYAM,   "NY AM")
var Sess sLunch  = mkSess(enLunch,  "NY Lunch")
var Sess sNYPM   = mkSess(enNYPM,   "NY PM")

var array<Sess> ss = array.new<Sess>()

if barstate.isfirst
    array.push(ss, sAsia)
    array.push(ss, sLondon)
    array.push(ss, sNYAM)
    array.push(ss, sLunch)
    array.push(ss, sNYPM)

inAsia   = enAsia   and not na(time(timeframe.period, asiaTime,   "America/New_York"))
inLondon = enLondon and not na(time(timeframe.period, londonTime, "America/New_York"))
inNYAM   = enNYAM   and not na(time(timeframe.period, nyamTime,   "America/New_York"))
inLunch  = enLunch  and not na(time(timeframe.period, lunchTime,  "America/New_York"))
inNYPM   = enNYPM   and not na(time(timeframe.period, nypmTime,   "America/New_York"))

isIn(int i) =>
    switch i
        0 => inAsia
        1 => inLondon
        2 => inNYAM
        3 => inLunch
        => inNYPM

for i = 0 to 4
    s = ss.get(i)
    if not s.on
        continue

    inn = isIn(i)

    if inn and not s.act
        s.reset()
    else if inn and s.act
        s.update()
    else if not inn and s.act
        s.closeSession()

var int pTdDate = na
var int pTdWk   = na

if na(pTdDate)
    pTdDate := tdDate
    pTdWk   := tdWk
else if tdDate != pTdDate
    for i = 0 to 4
        s = ss.get(i)

        if s.dDone and not na(dATR) and dATR > 0
            rng  = s.dHi - s.dLo
            nRng = rng / dATR
            s.hist.push(Rec.new(pTdWk, nRng))

        if not s.act
            s.resetDay()

    pTdDate := tdDate
    pTdWk   := tdWk

// ─────────────────────────────────────────────
// Active session percentile
// ─────────────────────────────────────────────
float activePct = na

for i = 0 to 4
    s = ss.get(i)
    if s.on and s.act
        activePct := s.currentPercentile(dATR)

pctSmooth = smooth(activePct)
pctVelocity = pctSmooth - pctSmooth[velLookback]

// ─────────────────────────────────────────────
// OI Context Engine
// ─────────────────────────────────────────────
eps = 1e-10
barsBack = 10000

f_oiConvert(_v, _ex, _app) =>
    tmp = ((_app == "USD.P" and (_ex == "Binance" or _ex == "Bybit" or _ex == "Kraken")) or _ex == "OKX" or _ex == "Deribit") ?
      _v * (_ex == "Binance" ? (syminfo.basecurrency == "BTC" ? 100 : 10) : 1) / close : _v
    typ2 == "USD" ? tmp * close : tmp

var string[] appendixes = array.from("USDT.P", "USD.P", "USDC.P", "USD.PM")
var string[] exchangeNames = array.from("Binance", "Bybit", "OKX", "Bitget", "Kraken", "HTX", "Deribit")

sumO = 0.0
sumH = 0.0
sumL = 0.0
sumC = 0.0
sources = 0

for exIdx = 0 to array.size(exchangeNames) - 1
    exName = array.get(exchangeNames, exIdx)
    exEnabled =
         exIdx == 0 ? ex1 :
         exIdx == 1 ? ex2 :
         exIdx == 2 ? ex3 :
         exIdx == 3 ? ex5 :
         exIdx == 4 ? ex6 :
         exIdx == 5 ? ex7 :
         ex8

    if exEnabled
        for appIdx = 0 to array.size(appendixes) - 1
            app = array.get(appendixes, appIdx)
            sym = exName + ":" + syminfo.basecurrency + app + "_OI"
            [o_, h_, l_, c_] = request.security(sym, timeframe.period, [open, high, low, close], ignore_invalid_symbol=true, calc_bars_count=barsBack)
            if not na(c_)
                sumO += f_oiConvert(o_, exName, app)
                sumH += f_oiConvert(h_, exName, app)
                sumL += f_oiConvert(l_, exName, app)
                sumC += f_oiConvert(c_, exName, app)
                sources += 1

oiO = sumO
oiC = sumC
deltaOI = oiC - oiO

var float cumVol = 0.0
cumVol += nz(volume)

obv = ta.cum(math.sign(ta.change(close)) * volume)

[cvdOpenRaw, cvdMaxRaw, cvdMinRaw, cvdLastRaw] = tvTa.requestVolumeDelta("1", "")

var float cvdCum = 0.0
bool dataAppeared = not na(cvdLastRaw) and na(cvdLastRaw[1])
bool anchorChange = timeframe.change(timeframe.period) or dataAppeared
float cvdOpenTmp = anchorChange ? 0.0 : nz(cvdCum[1])
cvdCum := cvdOpenTmp + nz(cvdLastRaw)

oi_s   = ta.ema(oiC, lenEMA)
oi_roc = ta.roc(oi_s, lenROC)

obv_s   = ta.ema(obv, lenEMA)
obv_roc = ta.roc(obv_s, lenROC)

cvd_s   = ta.ema(cvdCum, lenEMA)
cvd_roc = ta.roc(cvd_s, lenROC)

obvUp = obv_roc >  thr
obvDn = obv_roc < -thr
cvdUp = cvd_roc >  thr
cvdDn = cvd_roc < -thr

priceUpBar = close > close[1]
priceDnBar = close < close[1]
oiUpBar    = deltaOI > 0
oiDnBar    = deltaOI < 0

bullForceScore = (priceUpBar ? 2 : 0) + (cvdUp ? 1 : 0) + (obvUp ? 1 : 0)
bearForceScore = (priceDnBar ? 2 : 0) + (cvdDn ? 1 : 0) + (obvDn ? 1 : 0)

probBullForce = bullForceScore > bearForceScore
probBearForce = bearForceScore > bullForceScore

probLongBuild  = oiUpBar and probBullForce
probShortBuild = oiUpBar and probBearForce
probShortCover = oiDnBar and probBullForce
probLongLiq    = oiDnBar and probBearForce

volMA = ta.sma(volume, volLen)
atrOI = ta.atr(atrLenOI)
body = math.abs(close - open)
oiDeltaPct = oiO != 0 ? deltaOI / oiO * 100.0 : 0.0

shortLiqBar =
     probShortCover and
     volume > volMA * shortLiqVolMult and
     body > atrOI * shortLiqAtrMult and
     math.abs(oiDeltaPct) > shortLiqOiDropPct

// Same fallback logic as the Smart OI code:
// 1) Keep confident probability classifications untouched.
// 2) If evidence is still mixed, optionally apply simple price/OI common sense.
// 3) If still mixed, use OI direction fallback instead of gray.
systemCertain =
     shortLiqBar or
     probLongBuild or
     probShortBuild or
     probShortCover or
     probLongLiq

mixedOverrideAllowed = enableMixedOverride and not systemCertain

csLongBuild  = mixedOverrideAllowed and priceUpBar and oiUpBar
csShortBuild = mixedOverrideAllowed and priceDnBar and oiUpBar
csShortCover = mixedOverrideAllowed and priceUpBar and oiDnBar
csLongLiq    = mixedOverrideAllowed and priceDnBar and oiDnBar

oiColRaw =
     shortLiqBar                     ? cShortLiq :
     (probLongBuild  or csLongBuild)  ? cLongBuild :
     (probShortBuild or csShortBuild) ? cShortBuild :
     (probShortCover or csShortCover) ? cShortCover :
     (probLongLiq    or csLongLiq)    ? cLongLiq :
     oiUpBar                         ? cBullOI :
     oiDnBar                         ? cBearOI :
     na

// No gray segments/bars: true flat OI inherits the previous OI color.
var color oiCol = color.white
oiCol := na(oiColRaw) ? nz(oiCol[1], color.white) : oiColRaw

lineCol = colorLineByOI ? oiCol : color.white

// ─────────────────────────────────────────────
// Effort Expansion + Price Divergence Engine
// ─────────────────────────────────────────────
f_size(_s) =>
    _s == "tiny" ? size.tiny :
     _s == "small" ? size.small :
     _s == "large" ? size.large :
     size.normal

priceRoc = ta.roc(close, priceRocLen)
priceAbsRoc = math.abs(priceRoc)

// Aggressive effort expansion. Direction is intentionally NOT predicted here.
// The table only says effort is expanding fast; price action / OI context dictates direction.
pctSlope = pctSmooth - pctSmooth[effortSlopeLen]
pctSlopeRank = ta.percentrank(pctSlope, effortSlopeHistLen)
pctAcceleration = pctSlope - nz(pctSlope[1])

effortExpansion =
     not na(pctSlopeRank) and
     pctSlope > minEffortSlope and
     pctSlopeRank >= effortSlopeRankThr and
     (not requireAcceleration or pctAcceleration > 0)

// Exhaustion / absorption: high percentile effort, but price barely moves.
exhaustion = pctSmooth >= highEffortMin and priceAbsRoc <= lowResultPct

// Price/effort divergence using recent extremes.
priceHH = close > ta.highest(close[1], divLookback)
priceLL = close < ta.lowest(close[1], divLookback)
effortLH = pctSmooth < ta.highest(pctSmooth[1], divLookback)
effortHL = pctSmooth > ta.lowest(pctSmooth[1], divLookback)

bearEffortDiv = priceHH and effortLH
bullEffortDiv = priceLL and effortHL

expansionTableText = "⚡ EFFORT EXPANSION"
// ─────────────────────────────────────────────
// Plots
// ─────────────────────────────────────────────
hline(0,   "0",   color=color.new(color.gray, 80))
hline(20,  "Compression", color=color.new(color.green, 50))
hline(50,  "Midline", color=color.new(color.gray, 60))
hline(80,  "Expansion", color=color.new(color.red, 50))
hline(100, "100", color=color.new(color.gray, 80))

plot(showPctLine ? pctSmooth : na, "Smoothed Session Percentile", color=lineCol, linewidth=3)

plot(showVelLine ? pctVelocity : na, "Percentile Velocity", color=color.new(lineCol, 35), linewidth=2, style=plot.style_columns)

bgcolor(showOIBack ? color.new(oiCol, 90) : na)

bgcolor(showRegimeBg and pctSmooth <= 20 ? color.new(color.green, 94) : showRegimeBg and pctSmooth >= 80 ? color.new(color.red, 94) : na)

// Clean markers only: D = divergence, E = exhaustion. No B / B+ / LE-HR signals.
plotshape(showExhaustionMarkers and exhaustion ? 50 : na,
     title="E exhaustion / absorption",
     style=shape.diamond,
     location=location.absolute,
     color=color.yellow,
     text="E",
     textcolor=color.black,
     size=size.tiny)

plotshape(showDivergenceMarkers and bearEffortDiv,
     title="Bearish effort divergence",
     style=shape.labeldown,
     location=location.top,
     color=color.red,
     text="D",
     textcolor=color.white,
     size=size.tiny)

plotshape(showDivergenceMarkers and bullEffortDiv,
     title="Bullish effort divergence",
     style=shape.labelup,
     location=location.bottom,
     color=color.lime,
     text="D",
     textcolor=color.black,
     size=size.tiny)

// ─────────────────────────────────────────────
// Top-center one-line effort expansion table
// ─────────────────────────────────────────────
var table expansionTable = table.new(position.top_center, 1, 1, border_width=1, bgcolor=color.new(color.black, 100))

if barstate.islast
    table.clear(expansionTable, 0, 0, 0, 0)
    if showEffortExpansionTable and effortExpansion
        table.cell(
             expansionTable,
             0,
             0,
             expansionTableText,
             text_color=color.black,
             bgcolor=color.new(color.yellow, 0),
             text_size=f_size(expansionTextSize),
             text_halign=text.align_center)
// ─────────────────────────────────────────────
// Alerts
// ─────────────────────────────────────────────
alertcondition(ta.crossover(pctSmooth, 20), "Percentile leaving compression", "Session percentile crossed above 20 on {{ticker}}")
alertcondition(ta.crossover(pctSmooth, 80), "Session expansion", "Session percentile crossed above 80 on {{ticker}}")
alertcondition(ta.crossover(pctVelocity, 20), "Percentile velocity surge", "Session percentile velocity surged on {{ticker}}")

alertcondition(effortExpansion, "⚡ Effort Expansion", "Aggressive percentile rise on {{ticker}}. Direction should be judged from price action / OI context.")
alertcondition(exhaustion, "E exhaustion / absorption", "High session effort but low price result on {{ticker}}")
alertcondition(bearEffortDiv, "Bearish D effort divergence", "Price made HH while effort made LH on {{ticker}}")
alertcondition(bullEffortDiv, "Bullish D effort divergence", "Price made LL while effort made HL on {{ticker}}")
````
