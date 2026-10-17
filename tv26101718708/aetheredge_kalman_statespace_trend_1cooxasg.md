# AetherEdge - KALMAN | State-Space Trend

- url: https://www.tradingview.com/script/1coOxasg/
- type: indicator
- pine_id: PUB;5039caa3d9cc4554b01262a2e979290f
- version: 1.0

## Description

🖊️ Overview

AE-KALMAN treats price as a noisy observation and recursively estimates the true underlying trend level and velocity (slope) behind it with a two-state Kalman filter. Rather than averaging the past like a moving average, it runs a predict → observe → correct cycle on every bar. Crucially, the filter re-estimates how noisy the market is from its own forecast residuals, so it adapts automatically as volatility shifts. The lag-versus-smoothness trade-off is resolved probabilistically instead of by a fixed setting — that is the essence of AE-KALMAN.

🔶 Key Features

A slope-colored Kalman trend line estimating level and velocity (slope) simultaneously
Predictive bands whose width adapts to the predictive variance S — not a fixed multiplier
Shock detection via a standardized innovation "surprise" z-score — flags moves and regime breaks the model did not expect, with a marker and background tint
Innovation-based adaptive measurement noise — the filter learns the market's noise level from its own residuals and self-tunes (toggle)
A multi-step forecast ray (level + n·slope) with the projected price labeled
A gold-framed HUD showing trend, velocity, surprise z, Kalman gain, band width, noise, and forecast
No repaint — every signal is gated on bar close
Process/measurement noise is ATR-scaled, aligning automatically with each symbol's volatility

🧠 Technical Architecture

The state-space model is a local linear trend. The state vector is x = [level, slope], with transition F = [[1,1],[0,1]] (level advances by slope; slope is a random walk) and observation H = [1,0] (price = level + measurement noise). Each bar runs the standard recursion:
Predict: level' = level + slope; covariance P' = F·P·Fᵀ + Q
Update: innovation y = price − level'; predictive variance S = P'₁₁ + R; Kalman gain K = P'·Hᵀ / S; state correction x = x' + K·y; covariance P = (I − K·H)·P'
The 2×2 case is implemented in closed form by hand, so it needs no matrix inversion and stays numerically transparent.
Adaptive noise: the observed innovation variance estimates S = P'₁₁ + R, so R ≈ Var(y) − P'₁₁ is tracked online with an EWMA (with a floor). The filter therefore behaves smoothly in quiet conditions and responsively when the market turns turbulent.
Regime adaptation: velocity = slope ÷ ATR is compared against a dead-zone (slopeThr) to classify UP / DOWN / FLAT, while the magnitude of the surprise z = y ÷ √S detects shocks (news, fast moves).
Honest scope: this is a linear-Gaussian state-space filter (Kalman) — not a neural network and not a crystal ball. The forecast is a linear extrapolation of the current state.

⚙️ Recommended Settings & Tuning Guide

The defaults are tuned for crypto. The parameters that matter most are measurement noise (measR), process noise (procLvl / procSlp), band width (bandMult), the flat dead-zone (slopeThr), and the shock threshold (shockThr).
Smoother / slower: raise measR / lower procLvl
Faster / more reactive: raise procLvl / lower measR
procSlp controls how quickly trend direction may change — smaller keeps direction stable
Crypto starting points (tune on your chart):
BTC / ETH (1H–4H): defaults are a solid baseline; raise procLvl toward 0.4 to catch turns faster
SOL / XRP and high-volatility alts: wicky and noisy — use measR 2.0–2.5 and slopeThr 0.03–0.05 to suppress false FLAT/flip reads
Scalping (1–15m): raise procLvl (0.5+) for responsiveness; bandMult 1.5–2.0 for reversion entries
Swing (daily): lower procSlp (0.01–0.02) to stabilize slope; raise measR for a smoother line
For volatile crypto, keep adaptive noise ON; switch it off only when you want a fixed, predictable feel

💡 How to Use in Practice

Trend-following: ride the line color (velocity sign) and the UP/DN signals; treat FLAT as a range/stand-aside state
Mean-reversion: taps of the upper/lower predictive band flag overextension; because band width scales with S, small stretches in low vol and large stretches in high vol are judged on the same footing
S/R flips & breakouts: a decisive close through the Kalman level with a velocity flip marks the start of a regime change
Shock markers: highlight news, liquidations, and fakeouts — useful as an overextension warning or the onset of a volatility expansion
Forecast ray: the extrapolation of current level + velocity, handy for higher-timeframe bias and rough targets
Multi-timeframe: read directional velocity from a higher-timeframe AE-KALMAN and time entries on a lower one; agreement of both line colors is a high-confidence filter
Combinations: pair with AE-STRATA (SMC structure + ML/RL) and act only when Kalman velocity and STRATA's smart-money probability agree

⚠️ Important Notes

Initial convergence: from a large initial uncertainty, the filter takes a few dozen bars to settle — wait for values to stabilize at the start of history or right after switching symbols
Lag vs smoothness is a trade-off: smoother means slower; faster means noisier — there is no universal setting
The forecast is not a guarantee: it is a linear extrapolation (level + n·slope) and will miss sharp turns; treat it as a projection of the current state only
Parameter sensitivity: optimal noise settings vary by timeframe and symbol — always tune on the chart

🚨 Disclaimer

This indicator is provided for educational and informational purposes only and is not financial advice or a recommendation to buy or sell. No method guarantees future profits; past performance does not indicate future results, and trading carries the risk of loss. All trading decisions are your own — please use proper backtesting and disciplined risk management.

## Source Code

````pine
// ============================================================================
//  AE-KALMAN  |  AetherEdge Series
//  Kalman-filter adaptive trend estimator (state-space)
//
//  A genuine 2-state KALMAN FILTER on a local-linear-trend model:
//      state  x = [ level , slope ]^T
//      F = [[1,1],[0,1]]   (level advances by slope; slope is a random walk)
//      H = [1,0]           (we observe price = level + noise)
//  The full predict/update recursion is implemented by hand in closed form for
//  the 2x2 case (no matrix inversion needed), so it is numerically transparent.
//
//  What it gives that a moving average cannot:
//    * a principled, volatility-aware estimate of trend LEVEL and SLOPE (velocity)
//    * dynamic bands from the predictive variance S (not a fixed multiple)
//    * a standardized INNOVATION ("surprise") z-score to flag shocks / regime
//      breaks the model did not expect
//    * an optional INNOVATION-BASED ADAPTIVE measurement noise (the filter
//      re-estimates how noisy price is from its own residuals)
//    * a short multi-step forecast ray from the current level + slope
//
//  Honest scope: a linear Gaussian state-space filter (Kalman). It is NOT a
//  neural net and does not guarantee forecasts. No-repaint: closed bars are
//  fixed once formed; all signals are gated on barstate.isconfirmed.
// ============================================================================

//@version=6
indicator("AetherEdge - KALMAN | State-Space Trend", "AE-KALMAN", overlay = true, max_lines_count = 100, max_labels_count = 100)

// ----------------------------------------------------------------------------
//  THEME / PALETTE  (AetherEdge gold-frame HUD)
// ----------------------------------------------------------------------------
cGold    = #d4af37
cBg0     = #080b0a
cBg1     = #0f1614
cTxt     = #eef2f0
cBull    = #26a69a
cBear    = #ef5350
cShock   = #e040fb
cNeutral = #8d99a6

// ----------------------------------------------------------------------------
//  INPUTS
// ----------------------------------------------------------------------------
grpF = "Filter"
src      = input.source(close, "Source", group = grpF)
atrLen   = input.int(14, "ATR length (noise scaling)", minval = 1, group = grpF, tooltip = "Process/measurement noise are scaled by ATR so the filter adapts to each market's volatility.")

grpN = "Noise model (lower = smoother / slower)"
measR    = input.float(1.5, "Measurement noise (ATR x)", minval = 0.01, step = 0.1, group = grpN, tooltip = "How noisy price is assumed to be. Higher -> trust price less -> smoother line.")
procLvl  = input.float(0.30, "Process noise: level (ATR x)", minval = 0.0, step = 0.05, group = grpN, tooltip = "How fast the level is allowed to move. Higher -> more responsive.")
procSlp  = input.float(0.03, "Process noise: slope (ATR x)", minval = 0.0, step = 0.01, group = grpN, tooltip = "How fast the slope (velocity) is allowed to change.")

grpA = "Adaptive noise (innovation-based)"
adaptR   = input.bool(true, "Adapt measurement noise from residuals", group = grpA, tooltip = "Re-estimates R as Var(innovation) - predicted variance (EWMA). A standard adaptive-Kalman technique.")
adaptA   = input.float(0.05, "Adaptation EWMA", minval = 0.001, maxval = 0.5, step = 0.005, group = grpA)
minRx    = input.float(0.25, "Adaptive R floor (ATR x)", minval = 0.01, step = 0.05, group = grpA)

grpB = "Bands & regime"
showBands= input.bool(true, "Show predictive bands", group = grpB)
bandMult = input.float(2.0, "Band width (sqrt(S) x)", minval = 0.1, step = 0.1, group = grpB)
slopeThr = input.float(0.02, "Flat-zone slope (ATR/bar)", minval = 0.0, step = 0.01, group = grpB, tooltip = "Velocity below this magnitude is treated as FLAT (no trend).")
shockThr = input.float(2.5, "Shock |innovation z|", minval = 1.0, step = 0.1, group = grpB)

grpFc = "Forecast"
showFc   = input.bool(true, "Show forecast ray", group = grpFc)
fcLen    = input.int(10, "Forecast bars", minval = 1, maxval = 100, group = grpFc, tooltip = "Projects level + n*slope into the future. A linear extrapolation of the current state, not a guarantee.")

grpS = "Signals"
showSig  = input.bool(true, "Show trend-flip signals", group = grpS)
showShock= input.bool(true, "Show shock markers", group = grpS)

grpUI = "Dashboard"
showHUD  = input.bool(true, "Show HUD", group = grpUI)
hudSize  = input.string("normal", "HUD size", options = ["tiny","small","normal","large"], group = grpUI)

// ----------------------------------------------------------------------------
//  HELPERS
// ----------------------------------------------------------------------------
f_clamp(float x, float lo, float hi) => math.max(lo, math.min(hi, x))

// ----------------------------------------------------------------------------
//  VOLATILITY (robust to warmup na)
// ----------------------------------------------------------------------------
atr     = ta.atr(atrLen)
atrSafe = math.max(nz(atr, nz(ta.tr, close * 0.001)), 1e-8)

// ----------------------------------------------------------------------------
//  KALMAN STATE  (covariance P = [[p11,p12],[p12,p22]])
// ----------------------------------------------------------------------------
var float level = na
var float slope = na
var float p11   = na
var float p12   = na
var float p22   = na
var float ewmaY2  = na     // EWMA of squared innovation (for adaptive R)
var float ewmaP11 = na     // EWMA of predicted obs-variance term

// One-time initialization: lock onto the first price with large uncertainty.
if na(level)
    level   := src
    slope   := 0.0
    p11     := math.pow(atrSafe, 2) * 100.0
    p12     := 0.0
    p22     := math.pow(atrSafe, 2)
    ewmaY2  := math.pow(atrSafe, 2)
    ewmaP11 := p11

// Time-varying, ATR-scaled noise covariances.
q1 = math.pow(procLvl * atrSafe, 2)      // process noise on level
q2 = math.pow(procSlp * atrSafe, 2)      // process noise on slope

// --- PREDICT STEP -----------------------------------------------------------
// x_pred = F x ; P_pred = F P F^T + Q  (closed form for F = [[1,1],[0,1]])
levelPred = level + slope
slopePred = slope
p11Pred   = p11 + 2.0 * p12 + p22 + q1
p12Pred   = p12 + p22
p22Pred   = p22 + q2

// Innovation (uses only the prediction -> available before the update).
y = src - levelPred

// --- ADAPTIVE MEASUREMENT NOISE --------------------------------------------
// Observed innovation variance estimates S = p11Pred + R, so R ~ Var(y) - p11Pred.
float Rused = math.pow(measR * atrSafe, 2)
if adaptR
    Rused := math.max(ewmaY2 - ewmaP11, math.pow(minRx * atrSafe, 2))

// --- UPDATE STEP ------------------------------------------------------------
S  = p11Pred + Rused                     // innovation variance (H P H^T + R)
k1 = p11Pred / S                         // Kalman gain (level)
k2 = p12Pred / S                         // Kalman gain (slope)

level := levelPred + k1 * y
slope := slopePred + k2 * y
// P = (I - K H) P_pred  with K H = [[k1,0],[k2,0]]
p11   := (1.0 - k1) * p11Pred
p12   := (1.0 - k1) * p12Pred
p22   := p22Pred - k2 * p12Pred

// Maintain EWMA estimators for the adaptive path (after we have y / p11Pred).
if not na(level)
    ewmaY2  := (1.0 - adaptA) * ewmaY2  + adaptA * y * y
    ewmaP11 := (1.0 - adaptA) * ewmaP11 + adaptA * p11Pred

// ----------------------------------------------------------------------------
//  DERIVED METRICS
// ----------------------------------------------------------------------------
velocity = slope / atrSafe                       // trend velocity in ATR/bar
innovZ   = y / math.sqrt(math.max(S, 1e-12))     // standardized surprise
band     = bandMult * math.sqrt(math.max(S, 1e-12))
upper    = level + band
lower    = level - band

trendUp  = velocity >  slopeThr
trendDn  = velocity < -slopeThr
isShock  = math.abs(innovZ) > shockThr

trendCol = trendUp ? cBull : trendDn ? cBear : cNeutral

// ----------------------------------------------------------------------------
//  PLOTS
// ----------------------------------------------------------------------------
plot(level, "Kalman level", color = trendCol, linewidth = 2)
pUp = plot(showBands ? upper : na, "Upper", color = color.new(trendCol, 70))
pLo = plot(showBands ? lower : na, "Lower", color = color.new(trendCol, 70))
fill(pUp, pLo, color = showBands ? color.new(trendCol, 92) : na, title = "Band fill")

// Shock background tint.
bgcolor(showShock and isShock ? color.new(cShock, 88) : na, title = "Shock tint")

// ----------------------------------------------------------------------------
//  SIGNALS  (no-repaint: confirmed bars only)
// ----------------------------------------------------------------------------
longFlip  = barstate.isconfirmed and trendUp and not trendUp[1]
shortFlip = barstate.isconfirmed and trendDn and not trendDn[1]

plotshape(showSig and longFlip,  title = "Trend up",   style = shape.triangleup,   location = location.belowbar, color = cBull,  size = size.small, text = "UP",   textcolor = cBull)
plotshape(showSig and shortFlip, title = "Trend down", style = shape.triangledown, location = location.abovebar, color = cBear,  size = size.small, text = "DN",   textcolor = cBear)
plotshape(showShock and barstate.isconfirmed and isShock, title = "Shock", style = shape.diamond, location = location.top, color = cShock, size = size.tiny)

// ----------------------------------------------------------------------------
//  FORECAST RAY  (level + n*slope projected forward; redrawn at the last bar)
// ----------------------------------------------------------------------------
var line  fcLine  = na
var label fcLabel = na
if showFc and barstate.islast
    projEnd = level + fcLen * slope
    if na(fcLine)
        fcLine  := line.new(bar_index, level, bar_index + fcLen, projEnd, xloc = xloc.bar_index, color = cGold, width = 2, style = line.style_dashed)
        fcLabel := label.new(bar_index + fcLen, projEnd, "", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(cGold, 20), textcolor = cBg0, size = size.small)
    else
        line.set_xy1(fcLine, bar_index, level)
        line.set_xy2(fcLine, bar_index + fcLen, projEnd)
        label.set_xy(fcLabel, bar_index + fcLen, projEnd)
        label.set_text(fcLabel, str.tostring(projEnd, format.mintick))

// ----------------------------------------------------------------------------
//  HUD DASHBOARD  (gold frame)
// ----------------------------------------------------------------------------
f_txtSize() => hudSize == "tiny" ? size.tiny : hudSize == "small" ? size.small : hudSize == "large" ? size.large : size.normal

trendTxt = trendUp ? "UP" : trendDn ? "DOWN" : "FLAT"
projHud  = level + fcLen * slope

var table hud = table.new(position.top_right, 2, 9, bgcolor = cBg1, frame_color = cGold, frame_width = 2, border_color = color.new(cGold, 60), border_width = 1)

if showHUD and barstate.islast
    ts = f_txtSize()
    table.cell(hud, 0, 0, "AE-KALMAN", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 1, 0, "STATE-SPACE", text_color = cNeutral, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 0, 1, "Trend",        text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 1, trendTxt,       text_color = trendCol, text_size = ts)
    table.cell(hud, 0, 2, "Velocity",     text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 2, str.tostring(velocity, "#.###") + " ATR/bar", text_color = trendCol, text_size = ts)
    table.cell(hud, 0, 3, "Surprise (z)", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 3, str.tostring(innovZ, "#.##"), text_color = isShock ? cShock : cTxt, text_size = ts)
    table.cell(hud, 0, 4, "Kalman gain",  text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 4, str.tostring(k1, "#.##"), text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 5, "Band (±)",     text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 5, str.tostring(band / atrSafe, "#.##") + " ATR", text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 6, "Meas noise",   text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 6, (adaptR ? "auto " : "") + str.tostring(math.sqrt(Rused) / atrSafe, "#.##") + " ATR", text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 7, "Shock",        text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 7, isShock ? "ACTIVE" : "quiet", text_color = isShock ? cShock : cNeutral, text_size = ts)
    table.cell(hud, 0, 8, "Fcst " + str.tostring(fcLen), text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 1, 8, str.tostring(projHud, format.mintick), text_color = projHud > level ? cBull : cBear, bgcolor = cBg0, text_size = ts)

// ----------------------------------------------------------------------------
//  ALERTS
// ----------------------------------------------------------------------------
alertcondition(longFlip,  "AE-KALMAN Trend Up",   "AE-KALMAN trend flipped up")
alertcondition(shortFlip, "AE-KALMAN Trend Down", "AE-KALMAN trend flipped down")
alertcondition(barstate.isconfirmed and isShock, "AE-KALMAN Shock", "AE-KALMAN innovation shock")

if longFlip
    alert("AE-KALMAN UP | vel " + str.tostring(velocity, "#.###") + " ATR/bar", alert.freq_once_per_bar_close)
if shortFlip
    alert("AE-KALMAN DOWN | vel " + str.tostring(velocity, "#.###") + " ATR/bar", alert.freq_once_per_bar_close)
````
