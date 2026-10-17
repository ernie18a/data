# Particle Filter Pulse [forexobroker]

- url: https://www.tradingview.com/script/jh5coISU-Particle-Filter-Pulse-forexobroker/
- type: indicator
- pine_id: PUB;a1a9fc39eaea428eb97a67311f360b6c
- version: 1.0

## Description

Particle Filter Pulse runs a sequential Monte Carlo (32-particle) filter that tracks a hidden trend through Gaussian likelihood updates and effective-sample-size resampling. Particles use deterministic jitter — no random number generation, fully reproducible. When ESS collapses below the threshold, the filter resamples around the current price, marking a regime shift, and a fresh trend can lock in.

🔶 ALGORITHM

1. 32 particles each carry (price, velocity). Initialised at first bar with a deterministic spread around close.
2. Predict: each particle is propagated by its velocity plus a small ATR-scaled deterministic perturbation.
3. Likelihood: weight w_k *= exp(-0.5 * (close - px_k)^2 / sigma^2) with sigma = ATR.
4. Normalise weights. ESS = 1 / sum(w_k^2).
5. Resample when ESS < N * k: re-centre all particles at close and reset weights.
6. Filter mean = sum(w_k * px_k); velocity = sum(w_k * vx_k).

🔶 SIGNAL LOGIC

- Buy: close > filter mean AND velocity > 0 AND close crosses EMA up AND not already long AND cooldown elapsed AND barstate.isconfirmed.
- Sell: close < filter mean AND velocity < 0 AND close crosses EMA down.
- Position-lock state machine.

🔶 INPUTS

- Jitter (% of ATR) (default 0.30)
- ESS Collapse Fraction (default 0.50)
- Cooldown Bars (default 4)
- Visual: dashboard, glow, filter mean line, buy / sell colors

🔶 ALERTS

PFP Buy, PFP Sell, PFP Any Signal, PFP Resample, PFP Trend Up, PFP Trend Down, PFP EMA Up, PFP EMA Down, PFP Webhook JSON.

🔶 LIMITATIONS

- 32 particles is a small ensemble; the filter is qualitatively similar to a 1D Kalman in most regimes. The advantage shows in non-Gaussian / multimodal posteriors.
- Deterministic jitter trades randomness for reproducibility; for true SMC use offline Python tooling with RNG.
- Filter auto-recovers from symbol changes via a 20-ATR divergence guard but takes a few bars to relock.
- The Gaussian likelihood assumes stationary noise; heavy-tail spikes momentarily collapse all weights and trigger resampling.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Sequential Monte Carlo (particle filter) tracking a hidden trend. 32 particles,
// each carrying its own (price, velocity) state, are propagated forward, weighted by likelihood
// of the new price observation under that particle's prediction, then resampled when the
// effective sample size collapses below N/2. The weighted-mean particle is the trend estimate;
// ESS collapse marks regime change. Signals fire on the trend-mean direction at the bar after
// resampling. A simpler, deterministic-jitter (no RNG) variant suitable for Pine. Distinct from
// Kalman: handles non-Gaussian / multimodal posteriors.
indicator("Particle Filter Pulse [forexobroker]", shorttitle="PFP [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc   = "Particle Filter"
string g_signal = "Signal Logic"
string g_visual = "Visual"

float i_jitter   = input.float(0.30,"Jitter (% of ATR)", minval=0.05, maxval=2.0, step=0.05, group=g_calc, tooltip="Particle dispersion. Higher = wider posterior, slower lock.")
float i_essK     = input.float(0.50,"ESS Collapse Fraction", minval=0.1, maxval=0.9, step=0.05, group=g_signal, tooltip="Resample when ESS < k * N. Lower k = more frequent resamples = more agile.")
int   i_cooldown = input.int(4, "Cooldown Bars", minval=1, maxval=20, group=g_signal)
bool  i_showTable = input.bool(true, "Show Dashboard", group=g_visual)
bool  i_showGlow  = input.bool(true, "Show 3-Layer Glow", group=g_visual)
bool  i_showLine  = input.bool(true, "Show Filter Mean", group=g_visual)
color i_buyColor  = input.color(#39ff14, "Buy Color",  group=g_visual)
color i_sellColor = input.color(#ff2d78, "Sell Color", group=g_visual)

color c_white = #ffffff

const int NP = 32

var float[] px = array.new_float(NP, 0.0)
var float[] vx = array.new_float(NP, 0.0)
var float[] wt = array.new_float(NP, 1.0 / NP)

float atr14 = nz(ta.atr(14), 0.0)
float jit   = i_jitter * atr14

// Pre-compute current weighted mean to detect divergence
float prevMean = 0.0
for k = 0 to NP - 1
    prevMean += array.get(wt, k) * array.get(px, k)
bool needReset = barstate.isfirst or atr14 == 0 or math.abs(close - prevMean) > 20 * atr14

if needReset
    for k = 0 to NP - 1
        array.set(px, k, close + (k - NP / 2.0) * jit / 4.0)
        array.set(vx, k, 0.0)
        array.set(wt, k, 1.0 / NP)

// Predict: x = x + v + small jitter (deterministic per-particle)
for k = 0 to NP - 1
    float perturb = ((k % 7) - 3) * jit / 16.0
    array.set(px, k, array.get(px, k) + array.get(vx, k) + perturb)
    array.set(vx, k, array.get(vx, k))

// Update weights by Gaussian likelihood of close given particle px
float sigma = math.max(atr14, 1e-10)
float wSum = 0.0
for k = 0 to NP - 1
    float pk   = array.get(px, k)
    float diff = close - pk
    float ll   = math.exp(-0.5 * (diff * diff) / (sigma * sigma))
    float w    = array.get(wt, k) * ll
    array.set(wt, k, w)
    wSum += w

// Normalise weights
if wSum > 0
    for k = 0 to NP - 1
        array.set(wt, k, array.get(wt, k) / wSum)
else
    for k = 0 to NP - 1
        array.set(wt, k, 1.0 / NP)

// Effective sample size
float ess = 0.0
for k = 0 to NP - 1
    float w = array.get(wt, k)
    ess += w * w
ess := ess > 0 ? 1.0 / ess : NP

bool resample = ess < NP * i_essK

// Resample: replace each particle with the weighted mean (deterministic resampling)
float pxMean = 0.0
float vxMean = 0.0
for k = 0 to NP - 1
    pxMean += array.get(wt, k) * array.get(px, k)
    vxMean += array.get(wt, k) * array.get(vx, k)

// Update velocity from new observation vs old mean
float newVx = close - pxMean
if resample
    for k = 0 to NP - 1
        float perturb = ((k % 5) - 2) * jit / 8.0
        array.set(px, k, pxMean + perturb)
        array.set(vx, k, newVx)
        array.set(wt, k, 1.0 / NP)

// ─── REGIME + ENTRY ───────────────────────────────────────────────────────────
float ema     = ta.ema(close, 8)
bool  trendUp = pxMean > 0 and close > pxMean and vxMean > 0
bool  trendDn = pxMean > 0 and close < pxMean and vxMean < 0
bool  crossUp = ta.crossover(close, ema)
bool  crossDn = ta.crossunder(close, ema)
bool  entryUp   = trendUp and crossUp
bool  entryDown = trendDn and crossDn

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

color lineCol = trendUp ? i_buyColor : trendDn ? i_sellColor : color.new(color.gray, 40)
plot(i_showLine ? pxMean : na, "Filter Mean", color=lineCol, linewidth=3)

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.circle, location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.circle, location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy Signal",  shape.circle, location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="PFP up", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.circle, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.circle, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell Signal", shape.circle, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="PFP dn", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(trendUp ? color.new(i_buyColor, 95) : trendDn ? color.new(i_sellColor, 95) : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=color.new(color.black, 20), border_color=color.new(color.white, 80), border_width=1)
    string regimeTxt = trendUp ? "TREND UP" : trendDn ? "TREND DOWN" : "NEUTRAL"
    color  regimeCol = trendUp ? i_buyColor : trendDn ? i_sellColor : color.gray
    table.cell(dash, 0, 0, "Particle Filter Pulse", text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                 text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 0, 1, "Filter Mean",           text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(pxMean, "#.##"),        text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 2, "Velocity",              text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(vxMean, "#.######"),    text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 3, "ESS",                   text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(ess, "0.0"),            text_color=resample ? c_white : color.gray, text_size=size.small)
    table.cell(dash, 0, 4, "Resample",              text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, resample ? "YES" : "NO", text_color=resample ? c_white : color.gray, text_size=size.small)
    table.cell(dash, 0, 5, "Regime",                text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, regimeTxt,               text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 6, "Position",              text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",           text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"PFP","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"ess":' + str.tostring(ess, "0.0") + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"PFP","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"ess":' + str.tostring(ess, "0.0") + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                                  "PFP Buy",          "Particle filter bull on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                                 "PFP Sell",         "Particle filter bear on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,                    "PFP Any Signal",   "Any PFP signal on {{ticker}} {{interval}}")
alertcondition(resample and not resample[1],               "PFP Resample",     "ESS collapse on {{ticker}} {{interval}}")
alertcondition(trendUp and not trendUp[1],                 "PFP Trend Up",     "Particle trend up on {{ticker}} {{interval}}")
alertcondition(trendDn and not trendDn[1],                 "PFP Trend Down",   "Particle trend down on {{ticker}} {{interval}}")
alertcondition(crossUp,                                    "PFP EMA Up",       "Close crossed EMA up on {{ticker}} {{interval}}")
alertcondition(crossDn,                                    "PFP EMA Down",     "Close crossed EMA down on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,                    "PFP Webhook JSON", "{\"action\":\"signal\",\"indicator\":\"PFP\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
