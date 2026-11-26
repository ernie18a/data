# KRT  Kalman Regime Tricolor

- url: https://www.tradingview.com/script/RlabzWDu/
- type: indicator
- pine_id: PUB;ba5635f104d64cbba9b9e4199cfe9fc3
- version: 1.0

## Description

# 📊 KRT — Kalman Regime · Tricolor

**Designed and statistically validated for 🥇 GOLD and Ξ ETHEREUM.** A regime compass, not a buy signal: KRT reads the market on three layers — background regime, trend, your candle — and shows you which way the wind blows at every moment: 🟢 long · 🔴 short · 🔵 wait.

**⚡ ZERO lookahead, ZERO repaint.** Every signal appears in real time using only the information available at that moment, and whatever is printed at a bar close never changes afterwards. Many indicators look perfect because they quietly redraw the past — KRT is built for the opposite: what you see in replay is exactly what you would have seen live.

## ⚡ Quick start (30 seconds)

The colored BACKGROUND = the underlying regime.
Green 🟢 = bull regime installed → longs carry. Red 🔴 = bear regime installed → shorts carry. No color = no regime → caution.

The CURVE trails price like a stop line: below the candles in an uptrend, above them in a downtrend. Price crossing the curve = the reversal.

The curve's intensity = the strength of the authorization.
BRIGHT = trend aligned with the regime. Pale = secondary bias only. Blue = wait.

THE MARKERS — one single rule:
SOLID green or red marker (big triangle OR diamond) = GO. Blue = wait. Small = provisional.

🟢▲ / 🔴▼ BIG triangle — GO: reversal confirmed AND regime aligned.
🟢◆ / 🔴◆ Diamond — Deferred GO: the regime installs while the trend already points that way (often follows a big blue triangle). Same strength as a big colored triangle.
🔵▲ / 🔵▼ BIG blue triangle — reversal confirmed but no regime behind it → wait (a diamond will tell you if it becomes a GO).
▵▿ Small triangles (any color) — early alerts on your chart, ahead of confirmation. Provisional.

No thinking required: solid + colored = apply your strategy · blue = patience · small = not yet.

Drop it on gold or Ethereum, chart timeframe 5m–15m. Run YOUR strategy on top: KRT gives the direction, you handle entries, stops and exits.

## ⚠️ Before you use it

This is an indicator, NOT a strategy: it provides no entry or exit points.

Validated with permutation tests on gold and Ethereum. On Bitcoin the detection displays but the statistical edge is not demonstrated; on major forex pairs it is absent. Test it yourself before using it elsewhere.

The background regime changes slowly (weeks): that is by design — it filters, it does not scalp.

## 🔍 Understanding the display (going deeper)

THE THREE LAYERS

Regime (background, default 8H) — a slow Kalman trend filter with hysteresis: the background only colors once the regime is installed (default 3 days, adjustable). Locked at its own bar close: it does not flicker and does not repaint.

Trend (curve, default 1H) — the exact price level that would flip the trend filter, computed in advance: the distance between price and curve measures the strength of the trend.

Your candle (the chart) — the curve is monitored at your chart's granularity: you see the flip before the 1H close (small triangles), the close confirms it (big triangles).

HOW TO READ IT

Green background + bright green curve + GO = every layer agrees: the most favorable long context. Mirror in red for shorts.

Pale green curve = uptrend without an installed regime — weak bias.

Pale red curve = intraday "breather" (recurring windows of weakness inside an uptrend) — a short-lived bias, not an invitation to swing short.

Blue = no statistical edge. The best trade is often no trade.

After a bullish GO, price often retests the curve before continuing: aim for the retest rather than the impulse.

TIMEFRAMES & SETTINGS

Chart from 1m to 1H (5m–15m recommended).

Trend TF / Regime TF: the only settings an advanced user may change (swing trading: 4H/D).

Regime installation age (default 72h): higher = rarer, more reliable background; lower = more reactive, more false regimes.

Everything else (q values, thresholds, windows): the calibrated and validated core of the model — keep the defaults.

---

KRT is a decision-support tool based on historical data. Past performance does not guarantee future results. Manage your risk.

## Source Code

````pine
//@version=6
// =====================================================================
// KRT — Kalman Regime · Tricolor
// © Sharplosc
// This source code is subject to the terms of the Mozilla Public
// License 2.0 at https://mozilla.org/MPL/2.0/
//
// A regime compass, not an entry signal. Three layers:
//  · BACKGROUND (regime, default 8H): slow Kalman trend filter with
//    hysteresis — green = bull regime installed (longs carry),
//    red = bear regime installed (shorts carry), no color = no regime.
//  · CURVE (trend, default 1H): the exact price level that would flip
//    the trend filter, computed in advance — the price crossing the
//    curve IS the reversal — tracked at your chart's granularity so
//    you see the flip before the higher-timeframe close.
//  · MARKERS — one rule: SOLID green/red marker (big triangle OR
//    diamond) = GO · blue = wait · small = early, provisional.
// NO LOOKAHEAD, NO REPAINT: whatever is printed at a bar close never
// changes afterwards.
// Designed and statistically validated on GOLD and ETHEREUM. This is
// an indicator, not a strategy: apply your own entries, exits and risk.
// =====================================================================
indicator("KRT — Kalman Regime Tricolor", overlay = true)

// ── Inputs
htf     = input.timeframe("60",  "Trend timeframe (curve)")
htf2    = input.timeframe("480", "Regime timeframe (background)")
qFast   = input.float(0.003,     "Trend q (curve reactivity)", step = 0.0005)
qSlow   = input.float(0.000001,  "Slow authorization q")
qGate   = input.float(0.0003,    "Regime q")
aThr    = input.float(2.0,       "Curve hysteresis threshold ±", step = 0.5)
gIn     = input.float(1.0,       "Regime entry threshold")
gOut    = input.float(0.0,       "Regime exit threshold")
gAgeH   = input.float(72.0,      "Regime installation age (hours)")
rWin    = input.int(500,         "Noise estimation window (bars)", minval = 50)
restH0  = input.int(7,           "Breather window start (GMT hour)", 0, 23)
restH1  = input.int(15,          "Breather window end (GMT hour)",   0, 23)
freshH  = input.float(3.0,       "Breather: fresh leg (hours)")
chuteK  = input.float(20.0,      "Breather: free fall (ATR)")
smooth  = input.bool(true,       "Smooth curve")
smoothK = input.float(1.0,       "Smoothing strength (trend candles)", minval = 0.2, maxval = 3.0, step = 0.2)
showPre = input.bool(true,       "Chart alerts (small triangles)")
showBg  = input.bool(true,       "Regime background")

// =====================================================================
// Kalman local-linear-trend -> t-stat + flip levels (caller's timeframe)
// =====================================================================
f_base() =>
    lr = math.log(close) - math.log(close[1])
    var arr = array.new_float()
    if bar_index > 0 and not na(lr)
        array.push(arr, lr * lr)
        if array.size(arr) > rWin
            array.shift(arr)
    R = array.size(arr) > 20 ? array.median(arr) : (na(lr) ? 1e-8 : lr * lr)
    R := math.max(R, 1e-12)
    // fast Kalman (curve)
    var float fl = na
    var float fs = 0.0
    var float f00 = 1e-4
    var float f01 = 0.0
    var float f10 = 0.0
    var float f11 = 1e-4
    if na(fl)
        fl := math.log(close)
    qf = qFast * R
    fxl = fl + fs
    fxs = fs
    a00 = f00 + f10 + f01 + f11
    a01 = f01 + f11
    a10 = f10 + f11
    a11 = f11 + qf
    Sf = a00 + R
    Kf0 = a00 / Sf
    Kf1 = a10 / Sf
    fP11n = a11 - Kf1 * a01
    fsd = math.sqrt(math.max(fP11n, 1e-24))
    logLm = Kf1 > 1e-15 ? fxl + (-aThr * fsd - fxs) / Kf1 : na
    logLp = Kf1 > 1e-15 ? fxl + ( aThr * fsd - fxs) / Kf1 : na
    fyr = math.log(close) - fxl
    fl := fxl + Kf0 * fyr
    fs := fxs + Kf1 * fyr
    f00 := a00 - Kf0 * a00
    f01 := a01 - Kf0 * a01
    f10 := a10 - Kf1 * a00
    f11 := fP11n
    tFast = fs / fsd
    // slow Kalman (secondary authorization)
    var float sl = na
    var float ss = 0.0
    var float s00 = 1e-4
    var float s01 = 0.0
    var float s10 = 0.0
    var float s11 = 1e-4
    if na(sl)
        sl := math.log(close)
    qs = qSlow * R
    sxl = sl + ss
    sxs = ss
    b00 = s00 + s10 + s01 + s11
    b01 = s01 + s11
    b10 = s10 + s11
    b11 = s11 + qs
    Ss = b00 + R
    Ks0 = b00 / Ss
    Ks1 = b10 / Ss
    sP11n = b11 - Ks1 * b01
    logL0 = Ks1 > 1e-15 ? sxl - sxs / Ks1 : na
    syr = math.log(close) - sxl
    sl := sxl + Ks0 * syr
    ss := sxs + Ks1 * syr
    s00 := b00 - Ks0 * b00
    s01 := b01 - Ks0 * b01
    s10 := b10 - Ks1 * b00
    s11 := sP11n
    var int st = 1
    if st == 1 and tFast < -aThr
        st := -1
    else if st == -1 and tFast > aThr
        st := 1
    atrH = ta.sma(math.abs(close - close[1]), 24)
    [math.exp(logLm), math.exp(logLp), math.exp(logL0), atrH, st]

f_gate() =>
    lr = math.log(close) - math.log(close[1])
    var arr = array.new_float()
    if bar_index > 0 and not na(lr)
        array.push(arr, lr * lr)
        if array.size(arr) > rWin
            array.shift(arr)
    R = array.size(arr) > 20 ? array.median(arr) : (na(lr) ? 1e-8 : lr * lr)
    R := math.max(R, 1e-12)
    var float gl = na
    var float gs = 0.0
    var float g00 = 1e-4
    var float g01 = 0.0
    var float g10 = 0.0
    var float g11 = 1e-4
    if na(gl)
        gl := math.log(close)
    qg = qGate * R
    gxl = gl + gs
    gxs = gs
    c00 = g00 + g10 + g01 + g11
    c01 = g01 + g11
    c10 = g10 + g11
    c11 = g11 + qg
    Sg = c00 + R
    Kg0 = c00 / Sg
    Kg1 = c10 / Sg
    gP11n = c11 - Kg1 * c01
    gsd = math.sqrt(math.max(gP11n, 1e-24))
    gyr = math.log(close) - gxl
    gl := gxl + Kg0 * gyr
    gs := gxs + Kg1 * gyr
    g00 := c00 - Kg0 * c00
    g01 := c01 - Kg0 * c01
    g10 := c10 - Kg1 * c00
    g11 := gP11n
    gs / gsd

[Lm, Lp, L0, atrH, stH1live] = request.security(syminfo.tickerid, htf,  f_base(), lookahead = barmerge.lookahead_off)
tGate                        = request.security(syminfo.tickerid, htf2, f_gate(), lookahead = barmerge.lookahead_off)

// trend confirmation locked at the trend-TF close (no repaint)
var int stH1conf = 1
if timeframe.change(htf)
    stH1conf := nz(stH1live[1], 1)

// ── REGIME (background) : locked at its own bar close (no repaint,
// no intrabar flicker) + hysteresis + installation age
var float tGateConf = 0.0
if timeframe.change(htf2)
    tGateConf := nz(tGate[1], tGateConf)
var int gBull = 0
var int gBear = 0
var int tBullOn = na
var int tBearOn = na
if gBull == 0 and tGateConf > gIn
    gBull := 1
    tBullOn := time
else if gBull == 1 and tGateConf < -gOut
    gBull := 0
if gBear == 0 and tGateConf < -gIn
    gBear := 1
    tBearOn := time
else if gBear == 1 and tGateConf > gOut
    gBear := 0
bull3 = gBull == 1 and not na(tBullOn) and (time - tBullOn) / 3600000.0 >= gAgeH
bear3 = gBear == 1 and not na(tBearOn) and (time - tBearOn) / 3600000.0 >= gAgeH

// ── REAL TIME on the chart: price crossing the frozen flip levels
var int rtState = 1
var int lastFlip = na
if not na(Lm) and not na(Lp)
    if rtState == 1 and close < Lm
        rtState := -1
        lastFlip := time
    else if rtState == -1 and close > Lp
        rtState := 1
        lastFlip := time
if na(lastFlip)
    lastFlip := time

curveRT = stH1conf == 1 ? Lm : Lp
ageHrt  = (time - lastFlip) / 3600000.0
forceRT = na(atrH) or atrH <= 0 ? 0.0 : (close - curveRT) / atrH
hGmtC   = hour(time, "GMT")
restiC  = hGmtC >= restH0 and hGmtC < restH1
slowUpC = not na(L0) and close > L0
respirC = restiC or ageHrt <= freshH or forceRT < -chuteK

// display state: color = role · intensity = strength of authorization
//  2 bright green · 1 pale green · 0 blue · -1 pale red · -2 bright red
vis = rtState == 1 and bull3 ? 2 : rtState == -1 and bear3 ? -2 :
      rtState == 1 and slowUpC ? 1 : rtState == -1 and respirC ? -1 : 0

// =====================================================================
// RENDERING
// =====================================================================
flipRT = rtState != rtState[1]
flipH1 = stH1conf != stH1conf[1]
gap    = na(time[1]) or (time - time[1]) > timeframe.in_seconds() * 1000 * 3
cut    = flipRT or flipH1 or gap
nHtf   = math.max(1, math.round(timeframe.in_seconds(htf) / timeframe.in_seconds()))
alphaS = 2.0 / (nHtf * smoothK + 1)
var float sm = na
sm := na(sm) or cut ? curveRT : sm + alphaS * (curveRT - sm)
disp = smooth ? sm : curveRT
dispP = (cut or na(disp)) ? na : disp

colVif  = vis == 2 ? color.teal : vis == -2 ? color.red : na
colPale = vis == 1 ? color.new(color.teal, 55) : vis == -1 ? color.new(color.red, 55) : vis == 0 ? color.new(color.blue, 45) : na
plot(not na(colVif)  ? dispP : na, "Curve (full authorization)", color = colVif,  linewidth = 3, style = plot.style_linebr)
plot(na(colVif)      ? dispP : na, "Curve (bias / wait)",        color = colPale, linewidth = 2, style = plot.style_linebr)

// background = installed regime
bgcolor(showBg and bull3 ? color.new(color.teal, 91) : showBg and bear3 ? color.new(color.red, 91) : na)

// small triangles = chart alerts (colored by the state they land in)
rtUp = rtState == 1 and rtState[1] == -1
rtDn = rtState == -1 and rtState[1] == 1
colRtUp = bull3 ? color.new(color.teal, 30) : color.new(color.blue, 30)
colRtDn = bear3 ? color.new(color.red, 30)  : color.new(color.blue, 30)
plotshape(showPre and rtUp, "Chart alert up",   style = shape.triangleup,   location = location.belowbar, color = colRtUp, size = size.tiny)
plotshape(showPre and rtDn, "Chart alert down", style = shape.triangledown, location = location.abovebar, color = colRtDn, size = size.tiny)

// ── UNIFIED MARKERS — one rule, no thinking required:
//  SMALL triangle (any color) = early chart alert, provisional
//  BIG triangle (any color)   = reversal CONFIRMED at the trend TF:
//     green/red (regime aligned) = GO · blue (no regime) = WAIT
//  DIAMOND green/red = DEFERRED GO: the regime installs while the trend
//     already points that way (often follows a big blue triangle).
//  RULE: SOLID green/red marker (triangle OR diamond) = GO.
h1Up = stH1conf == 1 and stH1conf[1] == -1
h1Dn = stH1conf == -1 and stH1conf[1] == 1
plotshape(h1Up and bull3,     "GO long (confirmed + regime)",  style = shape.triangleup,   location = location.belowbar, color = color.teal, size = size.normal)
plotshape(h1Dn and bear3,     "GO short (confirmed + regime)", style = shape.triangledown, location = location.abovebar, color = color.red,  size = size.normal)
plotshape(h1Up and not bull3, "Confirmed long — WAIT for regime",  style = shape.triangleup,   location = location.belowbar, color = color.blue, size = size.normal)
plotshape(h1Dn and not bear3, "Confirmed short — WAIT for regime", style = shape.triangledown, location = location.abovebar, color = color.blue, size = size.normal)

// diamond = deferred GO (regime installs, trend already aligned)
goDiffL = bull3 and not bull3[1] and stH1conf == 1
goDiffS = bear3 and not bear3[1] and stH1conf == -1
plotshape(goDiffL, "GO long (regime installs)",  style = shape.diamond, location = location.belowbar, color = color.teal, size = size.normal)
plotshape(goDiffS, "GO short (regime installs)", style = shape.diamond, location = location.abovebar, color = color.red,  size = size.normal)

// =====================================================================
// ALERTS
// =====================================================================
alertcondition(rtUp, "Chart alert: bullish flip", "KRT: bullish crossing on chart (early, to be confirmed)")
alertcondition(rtDn, "Chart alert: bearish flip", "KRT: bearish crossing on chart (early, to be confirmed)")
alertcondition((h1Up and bull3) or goDiffL, "GO LONG",  "KRT: GO long — trend confirmed + regime installed")
alertcondition((h1Dn and bear3) or goDiffS, "GO SHORT", "KRT: GO short — trend confirmed + regime installed")
alertcondition(bull3 and not bull3[1], "Bull regime installed", "KRT: background turns GREEN — longs carry")
alertcondition(bear3 and not bear3[1], "Bear regime installed", "KRT: background turns RED — shorts carry")
````
