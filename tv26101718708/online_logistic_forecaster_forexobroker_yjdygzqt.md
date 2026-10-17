# Online Logistic Forecaster [forexobroker]

- url: https://www.tradingview.com/script/YJdYGzqt-Online-Logistic-Forecaster-forexobroker/
- type: indicator
- pine_id: PUB;82cf74f46cec439d948f51cff49d9679
- version: 1.0

## Description

Online Logistic Forecaster trains a single-feature logistic regression in real time via stochastic gradient descent. The feature is the standardised price-EMA distance; the target is "next bar closes higher". Each bar updates weight w := w - eta * (sigmoid(w * x) - y) * x. Forecast probability of next-bar up = sigmoid(w * x). Adaptive learning without batch training.

🔶 ALGORITHM

1. EMA = ema(close, len); ATR = atr(14).
2. Feature x = (close - EMA) / ATR (ATR-normalised distance).
3. Online SGD step: y_prev = (close[1] > close[2]); w := w - eta * (sigmoid(w * x[1]) - y_prev) * x[1].
4. Forecast: p_up = sigmoid(w * x).
5. Bull bias when p_up >= upper threshold; bear bias when <= lower threshold.

🔶 SIGNAL LOGIC

- Buy: bull bias edge (cross above upper threshold) AND not already long AND cooldown elapsed AND barstate.isconfirmed.
- Sell: bear bias edge.
- Position-lock state machine.

🔶 INPUTS

- Feature EMA Length (default 20)
- Learning Rate eta (default 0.05)
- Buy Probability (default 0.60)
- Sell Probability (default 0.40)
- Cooldown Bars (default 4)
- Visual: dashboard, glow, sigmoid line, buy / sell colors

🔶 ALERTS

OLF Buy, OLF Sell, OLF Any Signal, OLF Bull Edge, OLF Bear Edge, OLF High Conf Up, OLF High Conf Dn, OLF Strong Weight, OLF Webhook JSON.

🔶 LIMITATIONS

- One feature gives a 1D logistic forecast; multi-feature models would be more powerful but require explicit weight management.
- SGD with high eta can oscillate; defaults (eta = 0.05) balance convergence vs adaptation.
- The model needs warm-up of dozens of bars before w stabilises; early bars produce noisy forecasts.
- The "sigmoid line" visual is anchored at the EMA and scaled by ATR — purely informational.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Online logistic regression forecaster. The feature is the standardised price-EMA
// distance, the target is whether the next bar closes higher. Each bar updates the weight w via
// stochastic gradient descent on the logistic loss: w := w - eta * (sigmoid(w * x) - y) * x.
// Forecast probability of next bar up = sigmoid(w * current_x). Bayesian-style adaptive learner
// without batch training. Signals fire on probability threshold cross.
indicator("Online Logistic Forecaster [forexobroker]", shorttitle="OLF [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc = "Logistic"
string g_sig  = "Signal"
string g_vis  = "Visual"

int   i_emaLen   = input.int(20,   "Feature EMA Length",  minval=5, maxval=100, group=g_calc)
float i_eta      = input.float(0.05,"Learning Rate eta",  minval=0.001, maxval=0.5, step=0.001, group=g_calc)
float i_thrUp    = input.float(0.60,"Buy Probability",    minval=0.50, maxval=0.95, step=0.01, group=g_sig)
float i_thrDn    = input.float(0.40,"Sell Probability",   minval=0.05, maxval=0.50, step=0.01, group=g_sig)
int   i_cooldown = input.int(4,    "Cooldown Bars",       minval=1, maxval=20, group=g_sig)
bool  i_showTable= input.bool(true,"Show Dashboard",                            group=g_vis)
bool  i_showGlow = input.bool(true,"Show 3-Layer Glow",                         group=g_vis)
bool  i_showSig  = input.bool(true,"Show Sigmoid Line",                         group=g_vis)
color i_buyColor = input.color(#00e676,"Buy Color (Mint)",                      group=g_vis)
color i_sellColor= input.color(#ff1744,"Sell Color (Crimson)",                  group=g_vis)

color c_white  = #ffffff
color c_dashBg = color.new(#001f0a, 22)

// ─── FEATURE + ONLINE WEIGHT UPDATE ────────────────────────────────────────────
float ema    = ta.ema(close, i_emaLen)
float feat   = (close - ema) / nz(ta.atr(14), 1.0)  // ATR-normalised distance

var float w = 0.0
// Update with previous bar: feat[1] -> y = (close > close[1] ? 1 : 0)
int yPrev = nz(close[1], 0) > nz(close[2], 0) ? 1 : 0
float xPrev = nz(feat[1], 0.0)
float zPrev = w * xPrev
float pPrev = 1.0 / (1.0 + math.exp(-zPrev))
w := w - i_eta * (pPrev - yPrev) * xPrev

// Forecast for next bar
float z = w * feat
float pUp = 1.0 / (1.0 + math.exp(-z))

bool  bullBias = pUp >= i_thrUp
bool  bearBias = pUp <= i_thrDn

bool  bullEdge = bullBias and not bullBias[1]
bool  bearEdge = bearBias and not bearBias[1]

var int posState      = 0
var int lastSignalBar = 0
bool cooldownOk = (bar_index - lastSignalBar) >= i_cooldown
bool confirmed  = barstate.isconfirmed
bool buySignal  = bullEdge and posState <= 0 and cooldownOk and confirmed
bool sellSignal = bearEdge and posState >= 0 and cooldownOk and confirmed
if buySignal
    posState := 1
    lastSignalBar := bar_index
if sellSignal
    posState := -1
    lastSignalBar := bar_index

// ─── VISUAL: diamond with probability label ────────────────────────────────────
plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.diamond, location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.diamond, location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy",         shape.diamond, location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="OLF P+", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.diamond, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.diamond, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell",        shape.diamond, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="OLF P-", textcolor=c_white)

// Sigmoid line: visualizes pUp around EMA (scaled vertical)
float sigVis = ema + (pUp - 0.5) * 4.0 * nz(ta.atr(14), 0.0)
plot(i_showSig ? sigVis : na, "Sigmoid", color=color.new(pUp > 0.5 ? i_buyColor : i_sellColor, 30), linewidth=2, style=plot.style_circles)
plot(ema, "Feature EMA", color=color.new(color.silver, 60), linewidth=1)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(bullBias ? color.new(i_buyColor, 95) : bearBias ? color.new(i_sellColor, 95) : na)

// ─── DASHBOARD (top-center, mint/crimson, 8 rows) ─────────────────────────────
if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=c_dashBg, border_color=color.new(i_buyColor, 60), border_width=1)
    string regimeTxt = bullBias ? "BULL FORECAST" : bearBias ? "BEAR FORECAST" : "NEUTRAL"
    color  regimeCol = bullBias ? i_buyColor : bearBias ? i_sellColor : color.silver
    table.cell(dash, 0, 0, "Online Logistic Forecaster", text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                      text_color=color.new(i_buyColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "P(next up)",                 text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(pUp, "0.000"),   text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 2, "Weight w",                   text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(w, "0.000"),     text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 3, "Feature x",                  text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(feat, "0.00"),   text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 4, "Threshold +/-",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(i_thrUp, "0.00") + " / " + str.tostring(i_thrDn, "0.00"), text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 5, "Forecast",                   text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, regimeTxt,                    text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 6, "Position",                   text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",                text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"OLF","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"prob":' + str.tostring(pUp, "0.000") + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"OLF","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"prob":' + str.tostring(pUp, "0.000") + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                                  "OLF Buy",          "Logistic forecast bull on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                                 "OLF Sell",         "Logistic forecast bear on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,                    "OLF Any Signal",   "Any OLF signal on {{ticker}} {{interval}}")
alertcondition(bullBias and not bullBias[1],               "OLF Bull Edge",    "Probability crossed buy threshold on {{ticker}} {{interval}}")
alertcondition(bearBias and not bearBias[1],               "OLF Bear Edge",    "Probability crossed sell threshold on {{ticker}} {{interval}}")
alertcondition(pUp >= 0.8,                                 "OLF High Conf Up", "Forecast P(up) >= 0.80 on {{ticker}} {{interval}}")
alertcondition(pUp <= 0.2,                                 "OLF High Conf Dn", "Forecast P(up) <= 0.20 on {{ticker}} {{interval}}")
alertcondition(math.abs(w) > 1.0,                          "OLF Strong Weight","|w| > 1 on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,                    "OLF Webhook JSON", "{\"action\":\"signal\",\"indicator\":\"OLF\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
