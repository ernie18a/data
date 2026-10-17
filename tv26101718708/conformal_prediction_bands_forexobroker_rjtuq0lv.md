# Conformal Prediction Bands [forexobroker]

- url: https://www.tradingview.com/script/rJtuQ0LV-Conformal-Prediction-Bands-forexobroker/
- type: indicator
- pine_id: PUB;75acb271a032453a82e5e8c173cc8088
- version: 1.0

## Description

Conformal Prediction Bands [forexobroker] applies split-conformal inference — a distribution-free framework from Vovk, Shafer, and Lei et al. — to a simple EMA forecaster, giving prediction bands with finite-sample coverage guarantees under exchangeability. A 21-period EMA is the point forecast; the most recent N absolute residuals form the calibration set; the (1-alpha)-quantile of those residuals is the band half-width q. The result is upper and lower bands that, under standard assumptions, contain the next close (1-alpha) of the time. The unique angle is replacing standard-deviation bands (Bollinger, Keltner) with a quantile-based, assumption-light interval drawn from a peer-reviewed statistical framework.

🔶 ALGORITHM

1. Base forecast yhat = ta.ema(close, base EMA length default 21).
2. Each confirmed bar appends |close - yhat| to a rolling calibration set of size N (default 200).
3. The calibration set is sorted; q is the (1-alpha)*100 percentile via linear interpolation.
4. Bands: upper = yhat + q, lower = yhat - q. The band half-width q is symmetric by construction.
5. The slope of yhat over the last several bars (default 3) is computed as the trend filter.
6. Entry on a confirmed band breakout in the slope direction; cooldown and position state flip-prevention stop double-firing.
7. Empirical coverage is displayed in the dashboard so the user can monitor whether realised coverage matches the target.

🔶 SIGNAL LOGIC

- Buy: close > upper band AND slope of yhat over slope length is positive AND calibration set has at least 20 samples AND session filter passes AND position is not already long AND cooldown bars elapsed AND barstate.isconfirmed.
- Sell: close < lower band AND slope of yhat is negative AND calibration set has at least 20 samples AND session filter passes AND position is not already short AND cooldown bars elapsed AND barstate.isconfirmed.

The band break is the trigger, the slope is the trend filter, the calibration size gate avoids early-history false signals.

🔶 INPUTS

- Conformal Calculation group: base EMA length default 21, calibration size N default 200, alpha default 0.1 (90% bands).
- Signal Logic group: trend slope bars default 3, cooldown bars default 15.
- Filters group: session restriction (default 0000-2400).
- Visual group: dashboard, 3-layer glow, band fill toggle, midline color, band color, buy and sell colors.

🔶 ALERTS

CPB Buy, CPB Sell, CPB Any Signal, CPB Above Band, CPB Below Band, CPB Upper Cross, CPB Lower Cross, CPB Bands Widening, CPB Bands Tightening, CPB Inside Bands, CPB Webhook JSON.

🔶 LIMITATIONS

- Conformal coverage guarantees assume exchangeability of residuals; in trending or regime-shifting markets residuals are correlated and empirical coverage can drift below the target.
- The calibration set is a rolling window, not held-out i.i.d. data, so this is a streaming approximation of split-conformal inference rather than a strict implementation.
- The base predictor is a simple EMA; a poor base forecast inflates residuals and widens the bands, weakening sensitivity to genuine breakouts.
- The bands are symmetric by construction; for instruments with strong return asymmetry (e.g. crypto with rare large jumps) the upper and lower coverage can differ in practice.
- Calibration sizes below roughly 50 produce noisy quantiles and the script gates entries at 20 to avoid early-history false signals; expect no entries until calibration is filled.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Conformal Prediction Bands. Split-conformal inference (Vovk, Shafer, Lei et al.) builds
// distribution-free prediction intervals from any base forecaster. Here the base forecaster is a
// 21-EMA. The most recent N=200 absolute residuals |close - EMA| form the calibration set; the
// (1-alpha)-quantile of those residuals is q. Upper and lower bands are EMA +/- q with finite-sample
// coverage 1-alpha (default 90%) under exchangeability. A close breakout above the upper band in an
// up-trending EMA is a continuation long; below the lower band in a down-trending EMA is a
// continuation short. Non-repainting: residuals use confirmed bars; signals only on barstate.isconfirmed.
indicator("Conformal Prediction Bands [forexobroker]", shorttitle="CPB [fob]", overlay=true, max_bars_back=500, max_lines_count=500)

string g_calc = "Conformal Calculation"
string g_sig  = "Signal Logic"
string g_filt = "Filters"
string g_vis  = "Visual"

int   i_emaLen   = input.int(21,    "Base EMA Length",       minval=2,   maxval=200, group=g_calc, tooltip="Base point-forecast underlying the prediction bands.")
int   i_calLen   = input.int(200,   "Calibration Size N",    minval=20,  maxval=500, group=g_calc, tooltip="Number of recent absolute residuals used to compute the conformal quantile.")
float i_alpha    = input.float(0.1, "Alpha (1 - coverage)",  minval=0.01, maxval=0.5, step=0.01, group=g_calc, tooltip="Miscoverage rate. 0.1 = 90% bands, 0.2 = 80% bands, 0.05 = 95% bands.")
int   i_slopeLen = input.int(3,     "Trend Slope Bars",      minval=1,   maxval=20,  group=g_sig)
int   i_cooldown = input.int(5,     "Cooldown Bars",         minval=1,   maxval=60,  group=g_sig)
bool  i_useSess  = input.bool(false,"Restrict to Session",                            group=g_filt)
string i_sess    = input.session("0000-2400","Session Window",                       group=g_filt)
bool  i_showTable= input.bool(true, "Show Dashboard",                                 group=g_vis)
bool  i_showGlow = input.bool(true, "Show 3-Layer Glow",                              group=g_vis)
bool  i_showFill = input.bool(true, "Fill Band Interior",                             group=g_vis)
color i_buyColor = input.color(#39ff14,"Buy Color",                                   group=g_vis)
color i_sellColor= input.color(#ff2d78,"Sell Color",                                  group=g_vis)
color i_midColor = input.color(#00d4ff,"EMA Midline",                                 group=g_vis)
color i_bandColor= input.color(color.new(#00d4ff, 80),"Band Color",                   group=g_vis)
color i_dashBg   = input.color(color.new(#0c1810, 16),"Dashboard BG",                 group=g_vis)

color c_white = #ffffff

float yhat = ta.ema(close, i_emaLen)
float absRes = math.abs(close - yhat)

var float[] cal = array.new_float(0)
if barstate.isconfirmed and not na(absRes)
    array.push(cal, absRes)
    if array.size(cal) > i_calLen
        array.shift(cal)

// (1-alpha) percentile of calibration residuals
float coverPct = (1.0 - i_alpha) * 100.0
float q = 0.0
if array.size(cal) > 0
    var float[] sorted = array.new_float(0)
    array.clear(sorted)
    for k = 0 to array.size(cal) - 1
        array.push(sorted, array.get(cal, k))
    array.sort(sorted)
    int   sz  = array.size(sorted)
    float idx = (coverPct / 100.0) * (sz - 1)
    int   lo  = math.floor(idx)
    int   hi  = math.min(lo + 1, sz - 1)
    float frac= idx - lo
    q := array.get(sorted, lo) + frac * (array.get(sorted, hi) - array.get(sorted, lo))

float upper = yhat + q
float lower = yhat - q
float slope = yhat - yhat[i_slopeLen]

bool inSession = not i_useSess or not na(time(timeframe.period, i_sess))

// Signal boost: high-conviction band breakout PLUS frequent trend-pullback re-entry
// (close reclaiming the EMA midline in the slope direction). Both keep the conformal identity.
bool breakoutUp = close > upper and slope > 0
bool breakoutDn = close < lower and slope < 0
bool reclaimUp  = ta.crossover(close, yhat) and slope > 0
bool reclaimDn  = ta.crossunder(close, yhat) and slope < 0
bool entryUp   = inSession and (breakoutUp or reclaimUp) and array.size(cal) >= 20
bool entryDown = inSession and (breakoutDn or reclaimDn) and array.size(cal) >= 20

var int posState      = 0
var int lastSignalBar = 0
bool cooldownOk = (bar_index - lastSignalBar) >= i_cooldown
bool confirmed  = barstate.isconfirmed
bool buySignal  = entryUp   and posState <= 0 and cooldownOk and confirmed
bool sellSignal = entryDown and posState >= 0 and cooldownOk and confirmed
if buySignal
    posState := 1
    lastSignalBar := bar_index
if sellSignal
    posState := -1
    lastSignalBar := bar_index

float coverEst = 0.0
if array.size(cal) > 0
    int hits = 0
    for k = 0 to array.size(cal) - 1
        if array.get(cal, k) <= q
            hits += 1
    coverEst := hits / array.size(cal) * 100.0

p_mid   = plot(yhat,  "EMA Midline", color=i_midColor, linewidth=2)
p_upper = plot(upper, "Upper Band",  color=color.new(i_buyColor, 0), linewidth=1)
p_lower = plot(lower, "Lower Band",  color=color.new(i_sellColor, 0), linewidth=1)
fill(p_upper, p_lower, color=i_showFill ? i_bandColor : na)

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy",         shape.triangleup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="CPB", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.triangledown, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.triangledown, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell",        shape.triangledown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="CPB", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 9, bgcolor=i_dashBg, border_color=color.new(i_midColor, 55), border_width=1)
    string st = close > upper ? "ABOVE BAND" : close < lower ? "BELOW BAND" : "INSIDE"
    color  sc = close > upper ? i_buyColor : close < lower ? i_sellColor : color.silver
    table.cell(dash, 0, 0, "Conformal Prediction Bands", text_color=i_midColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                      text_color=color.new(i_midColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "State",                      text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, st,                           text_color=sc, text_size=size.small)
    table.cell(dash, 0, 2, "EMA Midline",                text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(yhat, "#.##"),   text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 3, "q (band half-width)",        text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(q, "#.####"),    text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 4, "Alpha",                      text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(i_alpha, "#.##"),text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 5, "Target Coverage",            text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(coverPct, "#.#") + "%", text_color=i_buyColor, text_size=size.small)
    table.cell(dash, 0, 6, "Empirical Coverage",         text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, str.tostring(coverEst, "#.#") + "%", text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 7, "Calibration Size",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(array.size(cal)), text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 8, "Position",                   text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 8, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"CPB","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"CPB","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                          "CPB Buy",            "Conformal upper-band breakout long on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                         "CPB Sell",           "Conformal lower-band breakout short on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,            "CPB Any Signal",     "Any CPB signal on {{ticker}} {{interval}}")
alertcondition(close > upper,                      "CPB Above Band",     "Price above conformal upper band on {{ticker}} {{interval}}")
alertcondition(close < lower,                      "CPB Below Band",     "Price below conformal lower band on {{ticker}} {{interval}}")
alertcondition(ta.crossover(close, upper),         "CPB Upper Cross",    "Close crossed upper band on {{ticker}} {{interval}}")
alertcondition(ta.crossunder(close, lower),        "CPB Lower Cross",    "Close crossed lower band on {{ticker}} {{interval}}")
alertcondition(q > q[1],                           "CPB Bands Widening", "Conformal bands widening on {{ticker}} {{interval}}")
alertcondition(q < q[1],                           "CPB Bands Tightening","Conformal bands tightening on {{ticker}} {{interval}}")
alertcondition(close >= lower and close <= upper,  "CPB Inside Bands",   "Price inside conformal bands on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,            "CPB Webhook JSON",   "{\"action\":\"signal\",\"indicator\":\"CPB\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
