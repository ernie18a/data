# Kalman Trend State [forexobroker]

- url: https://www.tradingview.com/script/8ywFwsOx-Kalman-Trend-State-forexobroker/
- type: indicator
- pine_id: PUB;54e8416187704919b1774a849bf901a8
- version: 1.0

## Description

Kalman Trend State applies a recursive Kalman filter to price, treating the unobserved trend as a hidden state with two components: instantaneous price level and per-bar velocity. Unlike a moving average, the filter's smoothing gain updates bar-by-bar from the residuals (innovation), so it adapts to volatility automatically without any length knob.

🔶 ALGORITHM

1. State [px, vx] tracks price and velocity. Transition F = [[1,1],[0,1]] (constant-velocity model).
2. Process noise Q is ATR-adaptive: Q = q_base + q_scale * (ATR / close). Higher volatility = larger Q = faster adaptation.
3. Measurement noise R is fixed (user input). Higher R = filter trusts the model more, smoother output.
4. At each bar: predict (px, P) -> measure close -> update gain K = P_pred * H' / S where S = P_pred[0,0] + R -> correct (px, vx, P).
5. The innovation z-score (close - prediction) / sigma quantifies how well the filter is tracking.

🔶 SIGNAL LOGIC

- Buy: velocity > k * ATR AND |innovation z| <= sigma gate AND close crosses Kalman line up AND not already long AND cooldown elapsed AND barstate.isconfirmed.
- Sell: mirror with velocity < -k * ATR.
- Position-lock state machine prevents same-side over-firing.

🔶 INPUTS

- Process Noise Base Q (default 0.001)
- Q ATR-Pct Scale (default 0.01)
- Measurement Noise R (default 1.0)
- Velocity Threshold x ATR (default 0.10)
- Innovation Sigma Gate (default 1.0)
- Cooldown Bars (default 4)
- Visual: 3-layer glow toggle, Kalman line toggle, dashboard toggle, buy / sell colors

🔶 ALERTS

KTS Buy, KTS Sell, KTS Any Signal, KTS Trend Up Start, KTS Trend Down Start, KTS Clean Fit, KTS Cross Up, KTS Cross Down, KTS Webhook JSON.

🔶 LIMITATIONS

- Kalman is optimal under linear-Gaussian assumptions; price is heavy-tailed, so the filter occasionally lags during regime breaks.
- Warm-up: about 14 bars (ATR seed). Earlier bars have NaN-guarded fallbacks but signals stay flat.
- Defaults tuned for liquid majors and indices on 5m-1H. Re-tune R for tick-driven micro-instruments.
- Velocity threshold scales with ATR but the filter itself does not change shape; for highly seasonal assets, a session-aware variant may help.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Recursive Kalman filter on hidden state [price, velocity]. Process noise Q adapts to
// ATR % so the filter trusts data more in calm regimes and trusts the model more in volatile ones.
// The filter outputs a smoothed price estimate and an estimated per-bar velocity. The dual-layer
// signal architecture is: (1) regime gate — velocity magnitude must exceed k * ATR, (2) entry
// trigger — price crosses the Kalman line in the regime direction, with the innovation z-score
// inside +-1 sigma proving the filter is tracking cleanly. A position-lock state machine prevents
// same-side over-firing. Different from a moving average: the smoothing gain is updated bar-by-bar
// from residuals, so it adapts to volatility automatically.
indicator("Kalman Trend State [forexobroker]", shorttitle="KTS [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

// ─── INPUTS ────────────────────────────────────────────────────────────────────
string g_calc   = "Kalman Filter"
string g_signal = "Signal Logic"
string g_visual = "Visual"

float i_qBase    = input.float(0.001, "Process Noise Base (Q)",     minval=0.00001, maxval=0.1,  step=0.0001, group=g_calc,   tooltip="Base process noise. Higher = more responsive to fast moves; lower = smoother.")
float i_qScale   = input.float(0.01,  "Q x ATR Pct Scale",          minval=0.0,     maxval=0.5,  step=0.01,   group=g_calc,   tooltip="Scales process noise by atr/close so the filter auto-adapts across symbols and timeframes.")
float i_rNoise   = input.float(1.0,   "Measurement Noise (R)",      minval=0.01,    maxval=10.0, step=0.1,    group=g_calc,   tooltip="Observation noise. Higher = filter trusts the model; lower = trusts price more.")
float i_velThr   = input.float(0.10,  "Velocity Threshold x ATR",   minval=0.01,    maxval=1.00, step=0.01,   group=g_signal, tooltip="|velocity| must exceed k x ATR for a 'trending' regime. ATR-adaptive across instruments.")
float i_innovK   = input.float(1.0,   "Innovation Sigma Gate",      minval=0.5,     maxval=3.0,  step=0.1,    group=g_signal, tooltip="Entry only fires when |innovation| <= k x sigma (filter is tracking cleanly).")
int   i_cooldown = input.int(4,       "Cooldown Bars",              minval=1,       maxval=20,                              group=g_signal)
bool  i_showTable = input.bool(true,  "Show Dashboard",                                                                     group=g_visual)
bool  i_showGlow  = input.bool(true,  "Show 3-Layer Glow",                                                                  group=g_visual)
bool  i_showLine  = input.bool(true,  "Show Kalman Line",                                                                   group=g_visual)
color i_buyColor  = input.color(#00e676, "Buy Color",                                                                       group=g_visual)
color i_sellColor = input.color(#ff1744, "Sell Color",                                                                      group=g_visual)

color c_white = #ffffff

// ─── ADAPTIVE NOISE ────────────────────────────────────────────────────────────
float atr14  = nz(ta.atr(14), 0.0)
float atrPct = atr14 / close
float qAdapt = i_qBase + i_qScale * atrPct

// ─── KALMAN STATE [price, velocity] ────────────────────────────────────────────
var float px  = 0.0
var float vx  = 0.0
var float p00 = 1.0
var float p01 = 0.0
var float p10 = 0.0
var float p11 = 1.0

if barstate.isfirst
    px := close
    vx := 0.0
    p00 := 1.0
    p01 := 0.0
    p10 := 0.0
    p11 := 1.0

float pxPred  = px + vx
float vxPred  = vx
float p00Pred = p00 + p01 + p10 + p11 + qAdapt
float p01Pred = p01 + p11
float p10Pred = p10 + p11
float p11Pred = p11 + qAdapt

float innov  = close - pxPred
float sInno  = p00Pred + i_rNoise
float k0     = p00Pred / sInno
float k1     = p10Pred / sInno

px := pxPred + k0 * innov
vx := vxPred + k1 * innov
p00 := (1 - k0) * p00Pred
p01 := (1 - k0) * p01Pred
p10 := p10Pred  - k1 * p00Pred
p11 := p11Pred  - k1 * p01Pred

float innoSigma = math.sqrt(math.max(sInno, 1e-10))
float innoZ     = innov / innoSigma

// ─── REGIME + ENTRY (DUAL-LAYER) ──────────────────────────────────────────────
float velThr    = i_velThr * atr14
bool  trendUp   = vx >  velThr
bool  trendDown = vx < -velThr
bool  cleanFit  = math.abs(innoZ) <= i_innovK
bool  crossUp   = ta.crossover(close, px)
bool  crossDn   = ta.crossunder(close, px)
bool  entryUp   = trendUp   and cleanFit and crossUp
bool  entryDown = trendDown and cleanFit and crossDn

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

// ─── VISUAL ───────────────────────────────────────────────────────────────────
color lineCol = trendUp ? i_buyColor : trendDown ? i_sellColor : color.new(color.gray, 40)
plot(i_showLine ? px : na, "Kalman", color=lineCol, linewidth=3)

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy Signal",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="KTS up", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.triangledown, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.triangledown, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell Signal", shape.triangledown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="KTS dn", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(trendUp ? color.new(i_buyColor, 95) : trendDown ? color.new(i_sellColor, 95) : na)

// ─── DASHBOARD ────────────────────────────────────────────────────────────────
if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=color.new(color.black, 20), border_color=color.new(color.white, 80), border_width=1)
    string regimeTxt = trendUp ? "TRENDING UP" : trendDown ? "TRENDING DOWN" : "NEUTRAL"
    color  regimeCol = trendUp ? i_buyColor : trendDown ? i_sellColor : color.gray
    string fitTxt    = cleanFit ? "CLEAN" : "NOISY"
    color  fitCol    = cleanFit ? color.white : color.gray
    table.cell(dash, 0, 0, "Kalman Trend State",     text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                  text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 0, 1, "Velocity",               text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(vx, "0.0000"),     text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 2, "Vel Threshold",          text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(velThr, "0.0000"), text_color=color.gray, text_size=size.small)
    table.cell(dash, 0, 3, "Innovation Z",           text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(innoZ, "0.00"),    text_color=fitCol, text_size=size.small)
    table.cell(dash, 0, 4, "Filter Fit",             text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, fitTxt,                   text_color=fitCol, text_size=size.small)
    table.cell(dash, 0, 5, "Regime",                 text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, regimeTxt,                text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 6, "Position",               text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",            text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

// ─── ALERTS ───────────────────────────────────────────────────────────────────
if buySignal
    alert('{"action":"BUY","indicator":"KTS","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"velocity":' + str.tostring(vx, "0.0000") + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"KTS","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"velocity":' + str.tostring(vx, "0.0000") + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                                  "KTS Buy",              "Kalman trend up on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                                 "KTS Sell",             "Kalman trend down on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,                    "KTS Any Signal",       "Any KTS signal on {{ticker}} {{interval}}")
alertcondition(trendUp     and not trendUp[1],             "KTS Trend Up Start",   "Kalman entered trending-up regime on {{ticker}} {{interval}}")
alertcondition(trendDown   and not trendDown[1],           "KTS Trend Down Start", "Kalman entered trending-down regime on {{ticker}} {{interval}}")
alertcondition(cleanFit    and not cleanFit[1],            "KTS Clean Fit",        "Kalman fit returned to clean on {{ticker}} {{interval}}")
alertcondition(crossUp,                                    "KTS Cross Up",         "Close crossed Kalman line up on {{ticker}} {{interval}}")
alertcondition(crossDn,                                    "KTS Cross Down",       "Close crossed Kalman line down on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,                    "KTS Webhook JSON",     "{\"action\":\"signal\",\"indicator\":\"KTS\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
