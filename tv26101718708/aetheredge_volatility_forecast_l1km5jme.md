# AetherEdge - Volatility Forecast

- url: https://www.tradingview.com/script/L1KM5jMe/
- type: indicator
- pine_id: PUB;9c90888870de4f15b74e74109a52025c
- version: 1.0

## Description

🖊️ Overview

ATR shows yesterday's volatility; AE-VOL forecasts the next move and states the uncertainty honestly. An adaptive EWMA variance model estimates forward volatility, drawn on price as a conformal-calibrated expected-range envelope, alongside a volatility regime and a vol-targeted position-size readout.

🔶 Key Features

Adaptive vol forecast — the EWMA decay λ is learned online and reacts to volatility clustering
Calibrated range envelope — the N-bar range is statistically calibrated to hit a target coverage
Forward cone — projects the forecast range into the future
Volatility regime — low/normal/high with expanding ↑ / contracting ↓
Expected move — next-bar ±% and N-bar ±%
Vol-targeted sizing — a multiple that shrinks when forecast vol is high, grows when low
Alerts on regime change; bar-close updates — no repaint

🧠 Technical Architecture

Vol model (adaptive EWMA): h_t = λ·h_{t-1} + (1-λ)·r² (RiskMetrics — a GARCH(1,1) special case with ω≈0; reactivity = 1-λ, persistence = λ). The single decay λ is learned online by quasi-likelihood (QLIKE) with a recursive derivative. A full 3-parameter GARCH has a flat, ill-conditioned likelihood that single-pass SGD won't recover, so AE-VOL adapts one well-conditioned parameter — robust and honest. Returns are in % for numerical stability.
Calibration (split-conformal): the forecast is wrapped in a distribution-free band — the (1-α) quantile of realized standardized moves rescales the envelope so coverage matches the target empirically (fat tails included). No lookahead: the standardizer is the forecast made N bars ago.
Sizing: multiple = clamp(target vol / forecast vol, min, max).
Honest scope: an EWMA variance recursion + one online-adapted parameter + nonparametric conformal calibration (this tool uses no RL). Not deep learning, not a guarantee.

⚙️ Recommended Settings & Tuning Guide (crypto 15m–4H)

Key parameters: decay learning rate, initial λ, horizon N, band significance (1-α), calibration window, target per-bar vol %.
Initial λ ≈ 0.94 is standard; it auto-adjusts (higher-vol assets converge to lower λ = more reactive)
N is how far ahead you care about; 5–20 bars for 15m–1H
Calibration window ≈ 200; longer is steadier, shorter tracks the recent regime
Target vol % is the per-bar vol you want per position; 0.5–1.5% for crypto 15m–1H
Band significance defaults to 0.90 (10% expected outside); the HUD shows realized coverage

💡 How to Use in Practice

Use the range envelope for take-profit/stop or range judgment (outside the band = statistically unusual)
Regime HIGH favors breakout/trend; LOW (squeeze) flags reversal/range setups
Use the size multiple for vol-targeted money management (auto-smaller in high vol)
The closer coverage is to target, the more trustworthy the band; if it drifts, adjust N or the window
Combine with AE-BPE (breakout probability) or AE-AVP (volume profile) to layer regime × level

⚠️ Important Notes

Needs a learning period (warmup); λ re-learns on timeframe/parameter change
The envelope is a probabilistic range, not a guarantee that price stays inside
The vol forecast gives magnitude, not direction
Probability, not a guarantee — always do your own due diligence and use risk management

🚨 Disclaimer

This indicator is for educational and informational purposes only and is not financial advice or a recommendation to buy or sell. No method guarantees future profits; past performance does not indicate future results, and trading carries the risk of loss. All decisions are your own — use proper validation and disciplined risk management.

## Source Code

````pine
// ============================================================================
//  AetherEdge - Volatility Forecast  (AE-VOL)  |  AetherEdge Series
//  Adaptive EWMA volatility with a CALIBRATED expected-range envelope
//
//  ATR tells you yesterday's volatility; AE-VOL forecasts the next move and
//  states the uncertainty honestly:
//
//    * ML : an ADAPTIVE EWMA variance -- h_t = lambda*h_{t-1} + (1-lambda)*r^2
//      (RiskMetrics, i.e. a GARCH(1,1) special case with omega ~ 0; reactivity
//      = 1-lambda, persistence = lambda). The single decay lambda is LEARNED
//      ONLINE by quasi-likelihood (QLIKE) gradient descent with a recursive
//      derivative -- one well-conditioned parameter, so it stays stable. The
//      forecast volatility reacts to clustering.
//    * CALIBRATION : the forecast is wrapped in a SPLIT-CONFORMAL band -- the
//      (1-alpha) quantile of realized standardized moves rescales the envelope
//      so its coverage matches the target empirically (fat tails included). No
//      lookahead: the standardizer is the forecast made N bars ago.
//
//  Outputs an N-bar expected-range envelope on price, a volatility regime, the
//  expected next-bar / N-bar move, and a VOL-TARGETED position-size readout
//  (size down when forecast vol is high, up when low). Honest scope: an EWMA
//  variance recursion with one online-adapted parameter + nonparametric
//  conformal calibration -- not a neural net, not a guarantee. Updates gate on
//  bar close.
// ============================================================================

//@version=6
indicator("AetherEdge - Volatility Forecast", "AE-VOL", overlay = true, max_lines_count = 20)

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
grpG = "Volatility model (adaptive EWMA)"
lrG    = input.float(0.02, "Decay learning rate", minval = 0.0001, step = 0.005, group = grpG)
lamInit = input.float(0.94, "Initial decay λ", minval = 0.50, maxval = 0.995, step = 0.005, group = grpG)
warmup = input.int(120, "Warmup bars", minval = 20, group = grpG)

grpF = "Forecast envelope"
horizonN = input.int(10, "Forecast horizon N (bars)", minval = 1, group = grpF)
alphaConf = input.float(0.10, "Band significance (1-alpha coverage)", minval = 0.01, maxval = 0.5, step = 0.01, group = grpF)
calibN   = input.int(200, "Calibration window", minval = 20, group = grpF)
showCone = input.bool(true, "Project forward cone", group = grpF)

grpS = "Position sizing"
targetVolPct = input.float(1.0, "Target per-bar volatility (%)", minval = 0.05, step = 0.05, group = grpS)
minSize = input.float(0.25, "Min size multiple", minval = 0.05, step = 0.05, group = grpS)
maxSize = input.float(3.0, "Max size multiple", minval = 1.0, step = 0.5, group = grpS)

grpV = "Visual"
showBands = input.bool(true, "Show envelope bands", group = grpV)

grpUI = "Dashboard"
showHUD = input.bool(true, "Show HUD", group = grpUI)
hudSize = input.string("small", "Table size", options = ["tiny","small","normal","large"], group = grpUI)

// ----------------------------------------------------------------------------
//  HELPERS
// ----------------------------------------------------------------------------
f_clamp(float x, float lo, float hi) => math.max(lo, math.min(hi, x))
f_txtSize() => hudSize == "tiny" ? size.tiny : hudSize == "small" ? size.small : hudSize == "large" ? size.large : size.normal

f_quantile(array<float> arr, float a) =>
    float q = na
    int nn = array.size(arr)
    if nn > 0
        c = array.copy(arr)
        array.sort(c, order.ascending)
        int rank = int(math.ceil((1.0 - a) * (nn + 1)))
        rank := math.max(1, math.min(nn, rank))
        q := array.get(c, rank - 1)
    q

// ----------------------------------------------------------------------------
//  ADAPTIVE EWMA VARIANCE  (RiskMetrics / GARCH(1,1) with omega~0)
//  decay lambda learned online by QLIKE gradient with a recursive derivative
// ----------------------------------------------------------------------------
f_logit(float p) => math.log(p / (1.0 - p))

r = nz((close / close[1] - 1.0) * 100.0, 0.0)

var float theta = na         // logit(lambda)
var float hvar  = na         // variance forecast for the CURRENT bar (made last bar)
var float dHt   = 0.0        // recursive derivative  d h / d theta

if barstate.isconfirmed
    if na(hvar)
        theta := f_logit(f_clamp(lamInit, 0.5, 0.995))
        hvar  := math.max(r * r, 0.04)
        dHt   := 0.0
    else
        hf = math.max(hvar, 1e-6)
        gL = f_clamp((hf - r * r) / (hf * hf), -5.0, 5.0)     // dQLIKE/dh
        theta := f_clamp(theta - lrG * gL * dHt, -2.0, 6.0)
        lamU = 1.0 / (1.0 + math.exp(-theta))
        dlam = lamU * (1.0 - lamU)
        dHt  := f_clamp(dlam * (hvar - r * r) + lamU * dHt, -1e6, 1e6)
        hvar := lamU * hvar + (1.0 - lamU) * (r * r)

float lamNow = na(theta) ? lamInit : 1.0 / (1.0 + math.exp(-theta))
float sigBar = math.sqrt(math.max(nz(hvar, 0.04), 1e-8))   // forecast per-bar vol (%)
warmOK = bar_index > warmup

// ----------------------------------------------------------------------------
//  CONFORMAL ENVELOPE  (calibrate the N-bar move scale)
// ----------------------------------------------------------------------------
var array<float> calib = array.new_float(0)
sqrtN = math.sqrt(horizonN)

if barstate.isconfirmed and bar_index > horizonN
    realizedN = (close / close[horizonN] - 1.0) * 100.0
    scaleN = math.max(math.sqrt(math.max(nz(hvar[horizonN], 0.04), 1e-8)) * sqrtN, 1e-6)
    array.push(calib, math.abs(realizedN) / scaleN)
    if array.size(calib) > calibN
        array.shift(calib)

qConf = nz(f_quantile(calib, alphaConf), 1.65)
halfPct = qConf * sigBar * sqrtN                          // half-width of the N-bar envelope (%)
upBand = close * (1.0 + halfPct / 100.0)
dnBand = close * (1.0 - halfPct / 100.0)

// coverage check (band made N bars ago vs realized)
var int covHit = 0
var int covTot = 0
if barstate.isconfirmed and bar_index > horizonN + calibN
    realizedN2 = math.abs((close / close[horizonN] - 1.0) * 100.0)
    bandNago = nz(qConf[horizonN], 1.65) * math.sqrt(math.max(nz(hvar[horizonN], 0.04), 1e-8)) * sqrtN
    covTot += 1
    covHit += realizedN2 <= bandNago ? 1 : 0
covRate = covTot > 0 ? covHit / covTot : na

// ----------------------------------------------------------------------------
//  REGIME + POSITION SIZING
// ----------------------------------------------------------------------------
volPct = ta.percentrank(sigBar, 100)
int regime = volPct < 33.0 ? 0 : volPct < 66.0 ? 1 : 2
expanding = sigBar > sigBar[5]
sizeMult = f_clamp(targetVolPct / math.max(sigBar, 1e-6), minSize, maxSize)

// ----------------------------------------------------------------------------
//  PLOTS
// ----------------------------------------------------------------------------
bandCol = regime == 2 ? cBear : regime == 0 ? cBull : cViolet
plot(showBands and warmOK ? upBand : na, "Upper envelope", color = color.new(bandCol, 20), linewidth = 1)
plot(showBands and warmOK ? dnBand : na, "Lower envelope", color = color.new(bandCol, 20), linewidth = 1)

var line coneU = na
var line coneL = na
if showCone and warmOK and barstate.islast
    if not na(coneU)
        line.delete(coneU)
    if not na(coneL)
        line.delete(coneL)
    int proj = math.min(horizonN, 500)
    coneU := line.new(bar_index, close, bar_index + proj, upBand, xloc = xloc.bar_index, color = color.new(bandCol, 0), width = 2, style = line.style_dashed)
    coneL := line.new(bar_index, close, bar_index + proj, dnBand, xloc = xloc.bar_index, color = color.new(bandCol, 0), width = 2, style = line.style_dashed)

// ----------------------------------------------------------------------------
//  HUD
// ----------------------------------------------------------------------------
regTxt = regime == 0 ? "LOW" : regime == 1 ? "NORMAL" : "HIGH"
regCol = regime == 0 ? cBull : regime == 1 ? cViolet : cBear

var table hud = table.new(position.top_right, 2, 11, bgcolor = cBg1, frame_color = cGold, frame_width = 2, border_color = color.new(cGold, 60), border_width = 1)
if showHUD and barstate.islast
    ts = f_txtSize()
    table.cell(hud, 0, 0, "AE-VOL", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 1, 0, "VOL FORECAST", text_color = cWait, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 0, 1, "Forecast vol", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 1, str.tostring(sigBar, "#.##") + "% /bar", text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 2, "Regime", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 2, regTxt + (expanding ? " ↑" : " ↓"), text_color = regCol, text_size = ts)
    table.cell(hud, 0, 3, "Next bar", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 3, "±" + str.tostring(qConf * sigBar, "#.#") + "%", text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 4, str.tostring(horizonN) + "-bar range", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 4, "±" + str.tostring(halfPct, "#.#") + "%", text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 5, "Upper / Lower", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 5, str.tostring(upBand, format.mintick) + " / " + str.tostring(dnBand, format.mintick), text_color = cWait, text_size = ts)
    table.cell(hud, 0, 6, "Coverage", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 6, na(covRate) ? "-" : str.tostring(math.round(covRate * 100)) + "% / " + str.tostring(math.round((1 - alphaConf) * 100)) + "%", text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 7, "Size x (vol-tgt)", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 7, str.tostring(sizeMult, "#.##"), text_color = sizeMult >= 1 ? cBull : cBear, text_size = ts)
    table.cell(hud, 0, 8, "Decay λ", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 8, str.tostring(lamNow, "#.###"), text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 9, "Reactivity", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 9, str.tostring(1.0 - lamNow, "#.###"), text_color = lamNow < 0.85 ? cViolet : cTxt, text_size = ts)
    table.cell(hud, 0, 10, "Model", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 1, 10, warmOK ? "live" : "learning", text_color = warmOK ? cBull : cWait, bgcolor = cBg0, text_size = ts)

// ----------------------------------------------------------------------------
//  ALERTS
// ----------------------------------------------------------------------------
alertcondition(warmOK and regime == 2 and regime[1] != 2, "AE-VOL High-vol regime", "AE-VOL: entered a high-volatility regime")
alertcondition(warmOK and regime == 0 and regime[1] != 0, "AE-VOL Low-vol regime", "AE-VOL: entered a low-volatility (squeeze) regime")
````
