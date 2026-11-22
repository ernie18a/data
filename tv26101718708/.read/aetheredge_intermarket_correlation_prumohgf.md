# AetherEdge - Intermarket Correlation

- url: https://www.tradingview.com/script/PrUMOHgf/
- type: indicator
- pine_id: PUB;20a939a4d3e749a29fb02281304dac8b
- version: 1.0

## Description

🖊️ Overview

Correlation tables are static; AE-CORR learns which markets actually drive this symbol. Alongside rolling correlation and beta of the chart symbol versus six reference markets (BTC / ETH / crypto cap / DXY / Gold / S&P 500, etc.), an online regression learns each market's predictive weight, producing a next-bar return forecast (with a conformal-calibrated band) and an intermarket directional bias.

🔶 Key Features

Learned driver analysis — learns which markets drive the next move (identifies the dominant driver)
Rolling correlation + beta — live coupling and sensitivity per reference
1-bar lead-lag — how much a reference's prior move predicts the next bar (signed)
Predicted next-bar return — with a ± conformal band for honest uncertainty
Intermarket bias — long/short/flat from the structure
Coupling — overall co-movement strength (a risk-on/off gauge)
Chart triangles + alerts on bias flips; bar-close updates — no repaint

🧠 Technical Architecture

Stats: rolling correlation (ta.correlation) and beta = correlation × (chart σ / ref σ) (contemporaneous coupling and sensitivity).
ML (online linear regression): features are six standardized reference returns plus the chart's own momentum, trained on lag-1 (weights that predict the next bar, updated without lookahead). The learned weights expose each market's drive and sign; the largest is shown as the dominant driver. The live prediction estimates the next-bar return (%) from current returns.
Calibration (split-conformal): the (1-α) quantile of realized residuals forms the band, so predicted ± band matches the target coverage empirically.
Honest scope: linear regression over standard features + nonparametric conformal calibration (no RL). Not deep learning, not a guarantee.

⚙️ Recommended Settings & Tuning Guide (crypto 15m–4H)

Key parameters: reference timeframe, correlation length, standardization length, learning rate, band significance (1-α), calibration window, bias threshold (× vol), the six references.
Correlation length ≈ 50 is standard; shorter tracks recent coupling, longer is steadier
References are fully swappable (for crypto, BTC/ETH/TOTAL/DXY/GOLD/SPX are classics); blank = skipped
Bias threshold = how many multiples of normal vol the prediction must exceed (≈ 0.5)
Pin references to a higher timeframe for a macro-structure bias
⚠️ The number of referenced markets (security calls) is capped

💡 How to Use in Practice

Check the dominant driver and watch that market as a lead
Use the sign of correlation to design hedges/diversification (negative-corr markets as insurance)
Use predicted next ± band for short-term expectation and risk
Use the bias triangles as an intermarket filter on single-symbol signals
Combine with AE-VOL (volatility) or AE-BPE (breakout probability) to layer driver × level

⚠️ Important Notes

Needs a learning period (warmup); weights re-learn on reference/timeframe change
Correlation is not causation (coupling can break down)
The next-bar forecast is short-horizon and probabilistic — large shocks will miss
Probability, not a guarantee — always do your own due diligence and use risk management

🚨 Disclaimer

This indicator is for educational and informational purposes only and is not financial advice or a recommendation to buy or sell. No method guarantees future profits; past performance does not indicate future results, and trading carries the risk of loss. All decisions are your own — use proper validation and disciplined risk management.

## Source Code

````pine
// ============================================================================
//  AetherEdge - Intermarket Correlation  (AE-CORR)  |  AetherEdge Series
//  Which markets actually drive this one -- learned, not assumed
//
//  Correlation tables are static; AE-CORR adds a model that learns the
//  predictive structure across markets:
//
//    * STATS : rolling correlation and beta of the chart symbol vs each of six
//      reference markets (contemporaneous coupling and sensitivity).
//    * ML : an ONLINE LINEAR REGRESSION over standardized, lagged reference
//      returns learns which markets (and the chart's own momentum) predict the
//      NEXT-bar move. The learned weights expose the dominant driver and the
//      sign of each relationship -- a 1-bar lead-lag read that adapts as
//      regimes rotate. Trained on lag-1 features (no lookahead).
//    * CALIBRATION : the predicted next-bar return is wrapped in a SPLIT-
//      CONFORMAL band from realized residuals, so the stated range is honest.
//
//  Outputs a predicted next move +/- band, an intermarket directional bias, the
//  dominant driver, overall coupling, and a per-market table. Honest scope:
//  linear regression over standard features + nonparametric calibration -- not
//  a neural net, not a guarantee, no RL. Updates gate on bar close.
// ============================================================================

//@version=6
indicator("AetherEdge - Intermarket Correlation", "AE-CORR", overlay = true)

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
grpM = "Model"
refTF  = input.timeframe("", "Reference timeframe", group = grpM)
lenCorr = input.int(50, "Correlation length", minval = 5, group = grpM)
lenZ   = input.int(50, "Standardization length", minval = 5, group = grpM)
lr     = input.float(0.02, "Learning rate", minval = 0.0001, step = 0.005, group = grpM)
warmup = input.int(120, "Warmup bars", minval = 20, group = grpM)

grpF = "Forecast"
alphaConf = input.float(0.10, "Band significance (1-alpha)", minval = 0.01, maxval = 0.5, step = 0.01, group = grpF)
calibN   = input.int(200, "Calibration window", minval = 20, group = grpF)
biasMult = input.float(0.5, "Bias threshold (x vol)", minval = 0.0, step = 0.1, group = grpF)
showSig  = input.bool(true, "Show bias triangles", group = grpF)

grpR = "Reference markets"
sym1 = input.symbol("BINANCE:BTCUSDT", "Ref 1", group = grpR)
sym2 = input.symbol("BINANCE:ETHUSDT", "Ref 2", group = grpR)
sym3 = input.symbol("CRYPTOCAP:TOTAL", "Ref 3", group = grpR)
sym4 = input.symbol("TVC:DXY",         "Ref 4", group = grpR)
sym5 = input.symbol("TVC:GOLD",        "Ref 5", group = grpR)
sym6 = input.symbol("SP:SPX",          "Ref 6", group = grpR)

grpUI = "Dashboard"
showHUD = input.bool(true, "Show table", group = grpUI)
hudSize = input.string("small", "Table size", options = ["tiny","small","normal","large"], group = grpUI)
tblPos  = input.string("top_right", "Table position", options = ["top_right","top_left","bottom_right","bottom_left","middle_right"], group = grpUI)

// ----------------------------------------------------------------------------
//  HELPERS
// ----------------------------------------------------------------------------
f_clamp(float x, float lo, float hi) => math.max(lo, math.min(hi, x))
f_txtSize() => hudSize == "tiny" ? size.tiny : hudSize == "small" ? size.small : hudSize == "large" ? size.large : size.normal
f_pos() => tblPos == "top_left" ? position.top_left : tblPos == "bottom_right" ? position.bottom_right : tblPos == "bottom_left" ? position.bottom_left : tblPos == "middle_right" ? position.middle_right : position.top_right
f_tk(string s) =>
    p = str.pos(s, ":")
    s == "" ? "-" : na(p) ? s : str.substring(s, p + 1)

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

f_predLin(array<float> w, array<float> x) =>
    z = array.get(w, 0)
    for i = 0 to array.size(x) - 1
        z += array.get(w, i + 1) * array.get(x, i)
    z

f_trainLin(array<float> w, array<float> x, float target, float lrr) =>
    pred = f_predLin(w, x)
    err = pred - target
    array.set(w, 0, array.get(w, 0) - lrr * err)
    for i = 0 to array.size(x) - 1
        array.set(w, i + 1, array.get(w, i + 1) - lrr * err * array.get(x, i))

f_z(float x) => (x - ta.sma(x, lenZ)) / math.max(ta.stdev(x, lenZ), 1e-8)

// ----------------------------------------------------------------------------
//  RETURNS, CORRELATION, BETA
// ----------------------------------------------------------------------------
cr = nz((close / close[1] - 1.0) * 100.0, 0.0)
sdC = math.max(ta.stdev(cr, lenCorr), 1e-8)

rc1 = request.security(sym1 == "" ? syminfo.tickerid : sym1, refTF, close, lookahead = barmerge.lookahead_off)
rc2 = request.security(sym2 == "" ? syminfo.tickerid : sym2, refTF, close, lookahead = barmerge.lookahead_off)
rc3 = request.security(sym3 == "" ? syminfo.tickerid : sym3, refTF, close, lookahead = barmerge.lookahead_off)
rc4 = request.security(sym4 == "" ? syminfo.tickerid : sym4, refTF, close, lookahead = barmerge.lookahead_off)
rc5 = request.security(sym5 == "" ? syminfo.tickerid : sym5, refTF, close, lookahead = barmerge.lookahead_off)
rc6 = request.security(sym6 == "" ? syminfo.tickerid : sym6, refTF, close, lookahead = barmerge.lookahead_off)

rr1 = sym1 == "" ? 0.0 : nz((rc1 / rc1[1] - 1.0) * 100.0, 0.0)
rr2 = sym2 == "" ? 0.0 : nz((rc2 / rc2[1] - 1.0) * 100.0, 0.0)
rr3 = sym3 == "" ? 0.0 : nz((rc3 / rc3[1] - 1.0) * 100.0, 0.0)
rr4 = sym4 == "" ? 0.0 : nz((rc4 / rc4[1] - 1.0) * 100.0, 0.0)
rr5 = sym5 == "" ? 0.0 : nz((rc5 / rc5[1] - 1.0) * 100.0, 0.0)
rr6 = sym6 == "" ? 0.0 : nz((rc6 / rc6[1] - 1.0) * 100.0, 0.0)

cor1 = sym1 == "" ? na : ta.correlation(cr, rr1, lenCorr)
cor2 = sym2 == "" ? na : ta.correlation(cr, rr2, lenCorr)
cor3 = sym3 == "" ? na : ta.correlation(cr, rr3, lenCorr)
cor4 = sym4 == "" ? na : ta.correlation(cr, rr4, lenCorr)
cor5 = sym5 == "" ? na : ta.correlation(cr, rr5, lenCorr)
cor6 = sym6 == "" ? na : ta.correlation(cr, rr6, lenCorr)

bet1 = na(cor1) ? na : cor1 * sdC / math.max(ta.stdev(rr1, lenCorr), 1e-8)
bet2 = na(cor2) ? na : cor2 * sdC / math.max(ta.stdev(rr2, lenCorr), 1e-8)
bet3 = na(cor3) ? na : cor3 * sdC / math.max(ta.stdev(rr3, lenCorr), 1e-8)
bet4 = na(cor4) ? na : cor4 * sdC / math.max(ta.stdev(rr4, lenCorr), 1e-8)
bet5 = na(cor5) ? na : cor5 * sdC / math.max(ta.stdev(rr5, lenCorr), 1e-8)
bet6 = na(cor6) ? na : cor6 * sdC / math.max(ta.stdev(rr6, lenCorr), 1e-8)

// standardized features
z1 = f_z(rr1)
z2 = f_z(rr2)
z3 = f_z(rr3)
z4 = f_z(rr4)
z5 = f_z(rr5)
z6 = f_z(rr6)
zc = f_z(cr)

// ----------------------------------------------------------------------------
//  ONLINE LINEAR REGRESSION  (lagged intermarket features -> next chart move)
// ----------------------------------------------------------------------------
var array<float> w = array.new_float(8, 0.0)
warmOK = bar_index > warmup

if barstate.isconfirmed and bar_index > 2
    fl = array.from(z1[1], z2[1], z3[1], z4[1], z5[1], z6[1], zc[1])
    f_trainLin(w, fl, cr, lr)

predNext = f_predLin(w, array.from(z1, z2, z3, z4, z5, z6, zc))   // predicted next-bar return (%)

// conformal band on the prediction residual
var array<float> calib = array.new_float(0)
if barstate.isconfirmed and bar_index > 3
    array.push(calib, math.abs(cr - nz(predNext[1])))
    if array.size(calib) > calibN
        array.shift(calib)
qBand = nz(f_quantile(calib, alphaConf), math.abs(predNext))

// ----------------------------------------------------------------------------
//  DOMINANT DRIVER + COUPLING + BIAS
// ----------------------------------------------------------------------------
int domIdx = 0
float domAbs = 0.0
for i = 1 to 7
    a = math.abs(array.get(w, i))
    if a > domAbs
        domAbs := a
        domIdx := i
domLbl = domIdx == 7 ? "SELF" : domIdx == 1 ? f_tk(sym1) : domIdx == 2 ? f_tk(sym2) : domIdx == 3 ? f_tk(sym3) : domIdx == 4 ? f_tk(sym4) : domIdx == 5 ? f_tk(sym5) : f_tk(sym6)

float cSum = 0.0
int cCnt = 0
cSum += na(cor1) ? 0.0 : math.abs(cor1)
cCnt += na(cor1) ? 0 : 1
cSum += na(cor2) ? 0.0 : math.abs(cor2)
cCnt += na(cor2) ? 0 : 1
cSum += na(cor3) ? 0.0 : math.abs(cor3)
cCnt += na(cor3) ? 0 : 1
cSum += na(cor4) ? 0.0 : math.abs(cor4)
cCnt += na(cor4) ? 0 : 1
cSum += na(cor5) ? 0.0 : math.abs(cor5)
cCnt += na(cor5) ? 0 : 1
cSum += na(cor6) ? 0.0 : math.abs(cor6)
cCnt += na(cor6) ? 0 : 1
coupling = cCnt > 0 ? cSum / cCnt : na

thr = biasMult * ta.stdev(cr, lenZ)
longBias  = warmOK and predNext > thr
shortBias = warmOK and predNext < -thr

// ----------------------------------------------------------------------------
//  CHART SIGNALS
// ----------------------------------------------------------------------------
plotshape(showSig and longBias and not longBias[1] ? low : na, "Intermarket long", shape.triangleup, location.belowbar, color.new(cBull, 0), size = size.tiny)
plotshape(showSig and shortBias and not shortBias[1] ? high : na, "Intermarket short", shape.triangledown, location.abovebar, color.new(cBear, 0), size = size.tiny)

// ----------------------------------------------------------------------------
//  TABLE
// ----------------------------------------------------------------------------
f_corCol(float c) => na(c) ? cWait : c >= 0 ? color.new(cBull, int(f_clamp(85.0 - math.abs(c) * 70.0, 15.0, 85.0))) : color.new(cBear, int(f_clamp(85.0 - math.abs(c) * 70.0, 15.0, 85.0)))
f_cTxt(float v, string fmt) => na(v) ? "-" : str.tostring(v, fmt)

var table tbl = table.new(f_pos(), 4, 13, bgcolor = cBg1, frame_color = cGold, frame_width = 2, border_color = color.new(cGold, 70), border_width = 1)
if showHUD and barstate.islast
    ts = f_txtSize()
    table.cell(tbl, 0, 0, "AE-CORR", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(tbl, 1, 0, "Corr", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(tbl, 2, 0, "Beta", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(tbl, 3, 0, "Drive", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(tbl, 0, 1, f_tk(sym1), text_color = cTxt, text_size = ts)
    table.cell(tbl, 1, 1, f_cTxt(cor1, "#.##"), text_color = cBg0, bgcolor = f_corCol(cor1), text_size = ts)
    table.cell(tbl, 2, 1, f_cTxt(bet1, "#.##"), text_color = cTxt, text_size = ts)
    table.cell(tbl, 3, 1, str.tostring(array.get(w, 1), "#.##"), text_color = array.get(w, 1) >= 0 ? cBull : cBear, text_size = ts)
    table.cell(tbl, 0, 2, f_tk(sym2), text_color = cTxt, text_size = ts)
    table.cell(tbl, 1, 2, f_cTxt(cor2, "#.##"), text_color = cBg0, bgcolor = f_corCol(cor2), text_size = ts)
    table.cell(tbl, 2, 2, f_cTxt(bet2, "#.##"), text_color = cTxt, text_size = ts)
    table.cell(tbl, 3, 2, str.tostring(array.get(w, 2), "#.##"), text_color = array.get(w, 2) >= 0 ? cBull : cBear, text_size = ts)
    table.cell(tbl, 0, 3, f_tk(sym3), text_color = cTxt, text_size = ts)
    table.cell(tbl, 1, 3, f_cTxt(cor3, "#.##"), text_color = cBg0, bgcolor = f_corCol(cor3), text_size = ts)
    table.cell(tbl, 2, 3, f_cTxt(bet3, "#.##"), text_color = cTxt, text_size = ts)
    table.cell(tbl, 3, 3, str.tostring(array.get(w, 3), "#.##"), text_color = array.get(w, 3) >= 0 ? cBull : cBear, text_size = ts)
    table.cell(tbl, 0, 4, f_tk(sym4), text_color = cTxt, text_size = ts)
    table.cell(tbl, 1, 4, f_cTxt(cor4, "#.##"), text_color = cBg0, bgcolor = f_corCol(cor4), text_size = ts)
    table.cell(tbl, 2, 4, f_cTxt(bet4, "#.##"), text_color = cTxt, text_size = ts)
    table.cell(tbl, 3, 4, str.tostring(array.get(w, 4), "#.##"), text_color = array.get(w, 4) >= 0 ? cBull : cBear, text_size = ts)
    table.cell(tbl, 0, 5, f_tk(sym5), text_color = cTxt, text_size = ts)
    table.cell(tbl, 1, 5, f_cTxt(cor5, "#.##"), text_color = cBg0, bgcolor = f_corCol(cor5), text_size = ts)
    table.cell(tbl, 2, 5, f_cTxt(bet5, "#.##"), text_color = cTxt, text_size = ts)
    table.cell(tbl, 3, 5, str.tostring(array.get(w, 5), "#.##"), text_color = array.get(w, 5) >= 0 ? cBull : cBear, text_size = ts)
    table.cell(tbl, 0, 6, f_tk(sym6), text_color = cTxt, text_size = ts)
    table.cell(tbl, 1, 6, f_cTxt(cor6, "#.##"), text_color = cBg0, bgcolor = f_corCol(cor6), text_size = ts)
    table.cell(tbl, 2, 6, f_cTxt(bet6, "#.##"), text_color = cTxt, text_size = ts)
    table.cell(tbl, 3, 6, str.tostring(array.get(w, 6), "#.##"), text_color = array.get(w, 6) >= 0 ? cBull : cBear, text_size = ts)
    // summary
    biasTxt = longBias ? "LONG" : shortBias ? "SHORT" : "FLAT"
    biasCol = longBias ? cBull : shortBias ? cBear : cWait
    table.cell(tbl, 0, 7, "Pred next", text_color = cViolet, bgcolor = cBg0, text_size = ts)
    table.cell(tbl, 1, 7, (predNext >= 0 ? "+" : "") + str.tostring(predNext, "#.##") + "%", text_color = predNext >= 0 ? cBull : cBear, bgcolor = cBg0, text_size = ts)
    table.cell(tbl, 2, 7, "± band", text_color = cWait, bgcolor = cBg0, text_size = ts)
    table.cell(tbl, 3, 7, "±" + str.tostring(qBand, "#.##"), text_color = cTxt, bgcolor = cBg0, text_size = ts)
    table.cell(tbl, 0, 8, "Bias", text_color = cTxt, text_size = ts)
    table.cell(tbl, 1, 8, biasTxt, text_color = biasCol, text_size = ts)
    table.cell(tbl, 2, 8, "Driver", text_color = cTxt, text_size = ts)
    table.cell(tbl, 3, 8, domLbl, text_color = cGold, text_size = ts)
    table.cell(tbl, 0, 9, "Coupling", text_color = cTxt, text_size = ts)
    table.cell(tbl, 1, 9, na(coupling) ? "-" : str.tostring(coupling, "#.##"), text_color = cTxt, text_size = ts)
    table.cell(tbl, 2, 9, "Model", text_color = cGold, text_size = ts)
    table.cell(tbl, 3, 9, warmOK ? "live" : "learning", text_color = warmOK ? cBull : cWait, text_size = ts)

// ----------------------------------------------------------------------------
//  ALERTS
// ----------------------------------------------------------------------------
alertcondition(longBias and not longBias[1], "AE-CORR Long bias", "AE-CORR: intermarket structure turned bullish")
alertcondition(shortBias and not shortBias[1], "AE-CORR Short bias", "AE-CORR: intermarket structure turned bearish")
````
