# AetherEdge - VECTOR | Conformal Forecast

- url: https://www.tradingview.com/script/M0KTXsDX/
- type: indicator
- pine_id: PUB;5800e978ff4c4d009f7beffaff9900b6
- version: 1.0

## Description

🖊️ Overview

AE-VECTOR forecasts the move over the next H bars and attaches a calibrated prediction interval to the target. A point estimate alone cannot be trusted or sized. AE-VECTOR learns the expected move with online regression and uses conformal prediction to draw a band around the target within which the realized value lands roughly 1 − α of the time. Its essence is quantifying the uncertainty of the forecast, not just its center.

🔶 Key Features

Online linear regression that learns the H-bar move (in ATR units) — m̂
A calibrated target band via conformal regression (target ± q·ATR, coverage ≈ 1 − α)
The band is volatility-normalized, so it widens in high vol and tightens in low vol automatically
A target cone at the right edge (projection line + band box + target/coverage label)
A highly selective signal that fires only when decisive (even the pessimistic band end is beyond price)
A gold HUD showing direction, predicted move, target, band width, coverage, and decisiveness
No repaint — signals gate on bar close; labels use the H-bar-lagged realized move

🧠 Technical Architecture

Regression: trend slope, RSI momentum, short momentum, range position, and volatility regime are standardized (EWMA), and a linear model m̂ = w·x + b is trained by SGD (squared loss, L2). The label is the realized H-bar move (ATR units); the current forecast uses no future data.
Conformal target band: the realized absolute residuals of past forecasts (in ATR units, i.e. volatility-normalized) are stored in a rolling calibration set. For a new forecast, the (1 − α) empirical quantile q gives the band target ± q·ATR. By the split (inductive) conformal guarantee, the realized value falls inside this band with coverage calibrated to about 1 − α.
Honest scope: a linear regressor plus inductive conformal prediction — not a neural network, and not a guarantee of the point estimate. What is guaranteed is the band's coverage.

⚙️ Recommended Settings & Tuning Guide

Key parameters: H (horizon), α (band coverage = 1 − α), moveThr (minimum predicted move), lr (learning rate), warmup.
Lower α → wider, higher-coverage band (conservative); higher → tighter band
H: small (5–8) for scalping, large (20–40) for swing
Crypto starting points (tune on your chart):
BTC / ETH (1H–4H): defaults are the baseline (H = 10, α = 0.10)
SOL / XRP and high-vol alts: moveThr ≈ 0.8 to filter small noisy forecasts; α = 0.08 for a slightly wider band
Scalping (5–15m): H = 5–8, lr = 0.02 for fast adaptation
Swing (daily): H = 20–40, raise calibN to stabilize the quantile estimate
Requiring "decisive" narrows to confident targets where even the pessimistic band end favors the trade

💡 How to Use in Practice

As a target: the cone's center line is the target, the band its uncertainty — an objective basis for take-profit levels and R:R
Reading band width: narrow = stable forecast (model confident), wide = uncertain (stand aside or downsize)
Decisive signals: a calibrated, strong condition that the target sits beyond price even pessimistically — useful at the start of a move
What coverage means: a 90% band has historically contained ~90% of realized values — a calibrated expectation
Multi-timeframe: target direction from a higher-timeframe VECTOR, timing on a lower one
Combinations: pair with AE-QUORUM's directional probability or AE-HELM's trade management, and design exits with VECTOR's band

⚠️ Important Notes

Learning period: until both the regression and the calibration spin up (warmup + minCalib bars), the target shows "warming" and no signals fire
Learning reset: changing inputs, symbol, or timeframe re-learns the internal state
The band is guaranteed, not the center: the point estimate can be wrong, and during shocks the band can briefly under-cover
Linear extrapolation has limits: it is weak to sharp regime changes and unforeseen news — treat it as a projection of the current state

🚨 Disclaimer

This indicator is for educational and informational purposes only and is not financial advice or a recommendation to buy or sell. No method guarantees future profits; past performance does not indicate future results, and trading carries the risk of loss. All trading decisions are your own — use proper backtesting and disciplined risk management.

## Source Code

````pine
// ============================================================================
//  AE-VECTOR  |  AetherEdge Series
//  Online price-move forecast with conformal (calibrated) target bands
//
//  A single point estimate is only half the story -- without calibrated
//  uncertainty it is impossible to size or trust. AE-VECTOR forecasts the
//  H-bar move and wraps it in a distribution-free prediction interval:
//
//    * ML  : an ONLINE LINEAR REGRESSION (SGD + L2) over standardized features
//      predicts the move (in ATR units) over the next H bars. Trained on the
//      realized H-bar move, so no lookahead. Output = expected move m-hat.
//
//    * Conformal : SPLIT-CONFORMAL regression over a rolling set of realized,
//      volatility-normalized absolute residuals. The (1 - alpha) empirical
//      quantile q gives a target band  target +/- q*ATR  whose true coverage is
//      approximately 1 - alpha -- a calibrated landing zone, not a guess.
//
//  A signal fires only when the band is *decisive* (even the pessimistic end of
//  the projected target sits beyond current price). Honest scope: a linear
//  regressor + inductive conformal prediction -- not a neural net, not a
//  guarantee of the point estimate. No-repaint: features use closed data,
//  labels are H-bar lagged, signals gate on barstate.isconfirmed.
// ============================================================================

//@version=6
indicator("AetherEdge - VECTOR | Conformal Forecast", "AE-VECTOR", overlay = true, max_lines_count = 100, max_labels_count = 100, max_boxes_count = 100)

// ----------------------------------------------------------------------------
//  THEME / PALETTE  (AetherEdge gold-frame HUD)
// ----------------------------------------------------------------------------
cGold    = #d4af37
cBg0     = #080b0a
cBg1     = #0f1614
cTxt     = #eef2f0
cBull    = #26a69a
cBear    = #ef5350
cWait    = #8d99a6

// ----------------------------------------------------------------------------
//  INPUTS
// ----------------------------------------------------------------------------
grpM = "Forecast model"
src      = input.source(close, "Source", group = grpM)
hzn      = input.int(10, "Forecast horizon H (bars)", minval = 1, maxval = 100, group = grpM, tooltip = "Predicts the move over the next H bars. Labels use the already-realized H-bar move (no lookahead).")
atrLen   = input.int(14, "ATR length", minval = 1, group = grpM)
lr       = input.float(0.01,  "Learning rate", minval = 0.0001, step = 0.002, group = grpM)
l2       = input.float(0.0005, "L2 regularization", minval = 0.0, step = 0.0005, group = grpM)
ewmaA    = input.float(0.02, "Standardization EWMA", minval = 0.001, maxval = 0.5, step = 0.005, group = grpM)
warmup   = input.int(150, "Warmup bars", minval = 20, group = grpM)

grpC = "Conformal target band"
alpha    = input.float(0.10, "Significance alpha (band = 1-alpha)", minval = 0.01, maxval = 0.5, step = 0.01, group = grpC, tooltip = "Lower alpha = wider, higher-coverage band. 0.10 targets ~90% coverage.")
calibN   = input.int(200, "Calibration window", minval = 30, group = grpC)
minCalib = input.int(50,  "Min calibration before signals", minval = 10, group = grpC)

grpS = "Signals"
moveThr  = input.float(0.5, "Min predicted move (ATR)", minval = 0.0, step = 0.1, group = grpS)
requireDecisive = input.bool(true, "Require decisive band", group = grpS, tooltip = "Long only if the band's lower bound is still above price (and mirror for shorts).")

grpV = "Projection"
showProj = input.bool(true, "Show target projection", group = grpV)

grpUI = "Dashboard"
showHUD = input.bool(true, "Show HUD", group = grpUI)
hudSize = input.string("normal", "HUD size", options = ["tiny","small","normal","large"], group = grpUI)

// ----------------------------------------------------------------------------
//  HELPERS
// ----------------------------------------------------------------------------
f_clamp(float x, float lo, float hi) => math.max(lo, math.min(hi, x))

f_statsUpdate(array<float> mean, array<float> varr, array<float> x, float a) =>
    for i = 0 to array.size(x) - 1
        v  = array.get(x, i)
        m0 = array.get(mean, i)
        m1 = m0 + a * (v - m0)
        d  = v - m1
        vr = (1.0 - a) * (array.get(varr, i) + a * d * d)
        array.set(mean, i, m1)
        array.set(varr, i, vr)

f_standardize(array<float> x, array<float> mean, array<float> varr) =>
    out = array.new_float(0)
    for i = 0 to array.size(x) - 1
        sd = math.sqrt(math.max(array.get(varr, i), 1e-10))
        array.push(out, f_clamp((array.get(x, i) - array.get(mean, i)) / sd, -6.0, 6.0))
    out

// Linear regression forward pass (w[0] = bias).
f_predict(array<float> w, array<float> x) =>
    z = array.get(w, 0)
    for i = 0 to array.size(x) - 1
        z += array.get(w, i + 1) * array.get(x, i)
    z

// One SGD step on squared loss with L2 (gradient w.r.t. prediction is the residual).
f_train(array<float> w, array<float> x, float y, float lrr, float l2r) =>
    pred = f_predict(w, x)
    err  = pred - y
    array.set(w, 0, array.get(w, 0) - lrr * err)
    for i = 0 to array.size(x) - 1
        g = err * array.get(x, i) + l2r * array.get(w, i + 1)
        array.set(w, i + 1, array.get(w, i + 1) - lrr * g)

// (1 - alpha) empirical quantile of a calibration array.
f_quantile(array<float> arr, float a) =>
    float q = na
    int n = array.size(arr)
    if n > 0
        c = array.copy(arr)
        array.sort(c, order.ascending)
        int rank = int(math.ceil((1.0 - a) * (n + 1)))
        rank := math.max(1, math.min(n, rank))
        q := array.get(c, rank - 1)
    q

// ----------------------------------------------------------------------------
//  FEATURES  (raw, then EWMA-standardized)
// ----------------------------------------------------------------------------
int NF = 5
atr     = ta.atr(atrLen)
atrSafe = math.max(nz(atr, nz(ta.tr, close * 0.001)), 1e-8)

fx1 = nz(f_clamp((ta.ema(src, 8) - ta.ema(src, 21)) / atrSafe, -6.0, 6.0))      // trend slope
fx2 = nz(f_clamp((ta.rsi(src, 14) - 50.0) / 50.0, -6.0, 6.0))                   // momentum (RSI)
fx3 = nz(f_clamp((src - src[5]) / (atrSafe * math.sqrt(5)), -6.0, 6.0))         // short momentum
hh  = ta.highest(high, 50)
ll  = ta.lowest(low, 50)
fx4 = nz(f_clamp((src - math.avg(hh, ll)) / math.max((hh - ll) / 2.0, 1e-8), -6.0, 6.0))  // range position
fx5 = nz(f_clamp((atrSafe - ta.sma(atrSafe, 50)) / math.max(ta.stdev(atrSafe, 50), 1e-8), -6.0, 6.0))  // volatility regime

var array<float> w     = array.new_float(NF + 1, 0.0)
var array<float> fMean = array.new_float(NF, 0.0)
var array<float> fVar  = array.new_float(NF, 1.0)

xRaw    = array.from(fx1, fx2, fx3, fx4, fx5)
xLagRaw = array.from(fx1[hzn], fx2[hzn], fx3[hzn], fx4[hzn], fx5[hzn])

if barstate.isconfirmed
    f_statsUpdate(fMean, fVar, xRaw, ewmaA)
xStd = f_standardize(xRaw, fMean, fVar)

// ----------------------------------------------------------------------------
//  ONLINE REGRESSION  (predict the H-bar move in ATR units)
// ----------------------------------------------------------------------------
mHat = f_predict(w, xStd)

if barstate.isconfirmed and bar_index > hzn and not na(close[hzn])
    moveLabel = (close - close[hzn]) / atrSafe          // realized H-bar move (ATR units)
    xLagStd = f_standardize(xLagRaw, fMean, fVar)
    f_train(w, xLagStd, moveLabel, lr, l2)

// ----------------------------------------------------------------------------
//  CONFORMAL TARGET BAND  (volatility-normalized split conformal)
// ----------------------------------------------------------------------------
var array<float> calib = array.new_float(0)

// Realized absolute residual of the prediction made H bars ago (already in ATR units).
if barstate.isconfirmed and bar_index > hzn and not na(close[hzn]) and not na(mHat[hzn])
    realizedMove = (close - close[hzn]) / atrSafe
    resid = math.abs(realizedMove - mHat[hzn])
    array.push(calib, resid)
    if array.size(calib) > calibN
        array.shift(calib)

qBand = f_quantile(calib, alpha)                        // band half-width in ATR units
calibReady = array.size(calib) >= minCalib

targetPrice = close + mHat * atrSafe
bandUp = targetPrice + nz(qBand) * atrSafe
bandLo = targetPrice - nz(qBand) * atrSafe

// ----------------------------------------------------------------------------
//  SIGNALS  (no-repaint: confirmed bars, decisive calibrated band)
// ----------------------------------------------------------------------------
warmOK = bar_index > warmup and calibReady
dirUp  = mHat > 0

decisiveLong  = not requireDecisive or bandLo > close   // even pessimistic target above price
decisiveShort = not requireDecisive or bandUp < close

longSig  = barstate.isconfirmed and warmOK and dirUp and not dirUp[1] and mHat > moveThr  and decisiveLong
shortSig = barstate.isconfirmed and warmOK and not dirUp and dirUp[1] and mHat < -moveThr and decisiveShort

plotshape(longSig,  title = "Long",  style = shape.triangleup,   location = location.belowbar, color = cBull, size = size.small, text = "BUY",  textcolor = cBull)
plotshape(shortSig, title = "Short", style = shape.triangledown, location = location.abovebar, color = cBear, size = size.small, text = "SELL", textcolor = cBear)

// ----------------------------------------------------------------------------
//  PROJECTION CONE  (redrawn at the last bar)
// ----------------------------------------------------------------------------
var line  tgtLine  = na
var box   bandBox  = na
var label tgtLabel = na

if showProj and barstate.islast and calibReady
    tCol = mHat >= 0 ? cBull : cBear
    if na(tgtLine)
        tgtLine  := line.new(bar_index, close, bar_index + hzn, targetPrice, xloc = xloc.bar_index, color = tCol, width = 2, style = line.style_dashed)
        bandBox  := box.new(bar_index, bandUp, bar_index + hzn, bandLo, xloc = xloc.bar_index, border_color = color.new(tCol, 60), bgcolor = color.new(tCol, 90))
        tgtLabel := label.new(bar_index + hzn, targetPrice, "", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(tCol, 20), textcolor = cBg0, size = size.small)
    else
        line.set_xy1(tgtLine, bar_index, close)
        line.set_xy2(tgtLine, bar_index + hzn, targetPrice)
        line.set_color(tgtLine, tCol)
        box.set_lefttop(bandBox, bar_index, bandUp)
        box.set_rightbottom(bandBox, bar_index + hzn, bandLo)
        box.set_border_color(bandBox, color.new(tCol, 60))
        box.set_bgcolor(bandBox, color.new(tCol, 90))
        label.set_xy(tgtLabel, bar_index + hzn, targetPrice)
        label.set_color(tgtLabel, color.new(tCol, 20))
        label.set_text(tgtLabel, str.tostring(targetPrice, format.mintick) + "  (" + str.tostring(math.round((1.0 - alpha) * 100)) + "% +/-" + str.tostring(nz(qBand), "#.#") + " ATR)")

// ----------------------------------------------------------------------------
//  HUD DASHBOARD  (gold frame)
// ----------------------------------------------------------------------------
f_txtSize() => hudSize == "tiny" ? size.tiny : hudSize == "small" ? size.small : hudSize == "large" ? size.large : size.normal

dirTxt = mHat > 0 ? "UP" : mHat < 0 ? "DOWN" : "flat"
dirCol = mHat > 0 ? cBull : mHat < 0 ? cBear : cWait
decisive = (mHat > 0 and bandLo > close) or (mHat < 0 and bandUp < close)

var table hud = table.new(position.top_right, 2, 9, bgcolor = cBg1, frame_color = cGold, frame_width = 2, border_color = color.new(cGold, 60), border_width = 1)

if showHUD and barstate.islast
    ts = f_txtSize()
    table.cell(hud, 0, 0, "AE-VECTOR", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 1, 0, "FORECAST", text_color = cWait, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 0, 1, "Direction", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 1, dirTxt,      text_color = dirCol, text_size = ts)
    table.cell(hud, 0, 2, "Pred move", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 2, str.tostring(mHat, "#.##") + " ATR", text_color = dirCol, text_size = ts)
    table.cell(hud, 0, 3, "Target",    text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 3, calibReady ? str.tostring(targetPrice, format.mintick) : "warming", text_color = dirCol, text_size = ts)
    table.cell(hud, 0, 4, "Band +/-",  text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 4, calibReady ? str.tostring(nz(qBand), "#.##") + " ATR" : "-", text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 5, "Coverage",  text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 5, str.tostring(math.round((1.0 - alpha) * 100)) + "%", text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 6, "Decisive",  text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 6, calibReady ? (decisive ? "YES" : "no") : "-", text_color = decisive ? dirCol : cWait, text_size = ts)
    table.cell(hud, 0, 7, "Calib n",   text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 7, str.tostring(array.size(calib)), text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 8, "Model",     text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 1, 8, warmOK ? "live" : "learning", text_color = warmOK ? cBull : cWait, bgcolor = cBg0, text_size = ts)

// ----------------------------------------------------------------------------
//  ALERTS
// ----------------------------------------------------------------------------
alertcondition(longSig,  "AE-VECTOR Long",  "AE-VECTOR long (decisive up target)")
alertcondition(shortSig, "AE-VECTOR Short", "AE-VECTOR short (decisive down target)")

if longSig
    alert("AE-VECTOR BUY | move " + str.tostring(mHat, "#.##") + " ATR | target " + str.tostring(targetPrice, format.mintick), alert.freq_once_per_bar_close)
if shortSig
    alert("AE-VECTOR SELL | move " + str.tostring(mHat, "#.##") + " ATR | target " + str.tostring(targetPrice, format.mintick), alert.freq_once_per_bar_close)
````
