# Inverse-Variance Slope Spectrum [forexobroker]

- url: https://www.tradingview.com/script/ZLems1nI-Inverse-Variance-Slope-Spectrum-forexobroker/
- type: indicator
- pine_id: PUB;5b17b8eb084b4f1996dca3d082e6147d
- version: 1.0

## Description

Inverse-Variance Slope Spectrum [forexobroker] runs five linear regressions of different lengths in parallel and blends their slopes into a single consensus, trusting each regression in proportion to how well it actually fits the data. The result is a noise-robust trend estimate whose sign sets the bias, with an adaptive linear-regression signal line timing entries. It is a statistically weighted answer to the classic problem of picking one regression length.

🔶 ALGORITHM

1. For each of five regression lengths, compute the slope as ta.linreg(close, L, 0) minus ta.linreg(close, L, 1).
2. For each length, compute the price-vs-bar-index correlation r, and a residual variance = price variance x (1 - r^2).
3. Assign each regression a weight of 1 / residual variance, so tighter-fitting lengths count more.
4. Combine the five slopes into an inverse-variance-weighted consensus slope.
5. The consensus slope's sign sets the regime/bias (positive = up, negative = down); an optional Min |Slope| x ATR gate filters weak slopes.
6. A close-cross of the adaptive linear-regression signal line in the bias direction times the entry. ATR is tracked for context.

🔶 SIGNAL LOGIC

- Buy: in-session AND |consensus slope| passes the ATR gate AND slope regime is up AND close crosses over the signal line AND not already long AND cooldown elapsed AND barstate.isconfirmed (position-locked).
- Sell: in-session AND |consensus slope| passes the ATR gate AND slope regime is down AND close crosses under the signal line AND not already short AND cooldown elapsed AND barstate.isconfirmed (position-locked).
Only fires when the consensus slope regime agrees with the signal-line cross.

🔶 INPUTS

- Spectrum: five regression lengths forming the slope spectrum; default Reg Length 1 = 10 (through Reg Length 5 = 89).
- Spectrum: Adaptive Signal Linreg length used as the entry signal line; default Adaptive Signal Linreg = 20.
- Spectrum: ATR length for the slope gate and context; default ATR Length = 14.
- Signal Logic: Min |Slope| x ATR optional minimum consensus-slope magnitude; default Min |Slope| x ATR = 0.0 (off).
- Signal Logic: Cooldown bars between signals; default Cooldown Bars = 5.
- Filters: optional session restriction with a session window; default Restrict to Session off.
- Visual: signal-line plot, dashboard, 3-layer glow, and buy/sell/background colors; signal line default on.
- Visual: dashboard reports regime, consensus slope, slope/ATR, signal line and weight sum; dashboard default on.

🔶 ALERTS

IVS Buy, IVS Sell, IVS Any Signal, IVS Slope Bull, IVS Slope Bear, IVS Signal Up, IVS Signal Down, IVS Slope Zero, IVS Strong Slope, IVS Regime Flip, IVS Any Signal Cross, IVS Webhook JSON.

🔶 LIMITATIONS

- Computational cost is higher than a single regression: it runs five regressions plus correlation and variance each bar.
- Needs warm-up bars up to the longest regression length before the consensus stabilises.
- Inverse-variance weighting reduces but does not eliminate lag inherent to linear regression.
- The consensus describes trend slope, not magnitude of future move; ranging markets can still whipsaw.
- Defaults are tuned for liquid instruments; very noisy symbols may need a Min |Slope| gate.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Inverse-Variance Slope Spectrum. Five linear regressions of different lengths are
// run in parallel. Each contributes a slope, and is trusted in proportion to how well it fits
// (weight = 1 / residual variance, where residual variance = price variance x (1 - r^2)). The
// inverse-variance-weighted consensus slope is a noise-robust trend estimate; its sign is the
// bias and an adaptive linreg signal line times entries. Non-repainting, bar-close.
indicator("Inverse-Variance Slope Spectrum [forexobroker]", shorttitle="IVS [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc = "Spectrum"
string g_sig  = "Signal Logic"
string g_filt = "Filters"
string g_vis  = "Visual"

int   i_l1      = input.int(10,   "Reg Length 1",          minval=4,  maxval=200, group=g_calc, tooltip="Shortest regression in the spectrum.")
int   i_l2      = input.int(20,   "Reg Length 2",          minval=4,  maxval=200, group=g_calc)
int   i_l3      = input.int(34,   "Reg Length 3",          minval=4,  maxval=200, group=g_calc)
int   i_l4      = input.int(55,   "Reg Length 4",          minval=4,  maxval=200, group=g_calc)
int   i_l5      = input.int(89,   "Reg Length 5",          minval=4,  maxval=200, group=g_calc, tooltip="Longest regression in the spectrum.")
int   i_sigLen  = input.int(20,   "Adaptive Signal Linreg",minval=4,  maxval=100, group=g_calc, tooltip="Linreg length used as the entry signal line.")
int   i_atrLen  = input.int(14,   "ATR Length",            minval=5,  maxval=50, group=g_calc)
float i_minSlope= input.float(0.0,"Min |Slope| x ATR",     minval=0.0, maxval=2.0, step=0.05, group=g_sig, tooltip="Optional minimum |consensus slope| (ATR units).")
int   i_cooldown= input.int(5,    "Cooldown Bars",         minval=1,  maxval=40, group=g_sig)
bool  i_useSess = input.bool(false,"Restrict to Session",                         group=g_filt)
string i_sess   = input.session("0000-2400","Session Window",                     group=g_filt)
bool  i_showLine= input.bool(true,"Show Signal Line",                              group=g_vis)
bool  i_showTable=input.bool(true,"Show Dashboard",                                group=g_vis)
bool  i_showGlow= input.bool(true,"Show 3-Layer Glow",                             group=g_vis)
color i_buyColor= input.color(#80ed99,"Buy Color",                                 group=g_vis)
color i_sellColor=input.color(#ff5d8f,"Sell Color",                                group=g_vis)
color i_dashBg  = input.color(color.new(#0a1a0e, 14),"Dashboard BG",              group=g_vis)

color c_white = #ffffff

float atr = nz(ta.atr(i_atrLen), 0.0)

f_sw(simple int L) =>
    float sl  = ta.linreg(close, L, 0) - ta.linreg(close, L, 1)
    float r   = ta.correlation(close, bar_index, L)
    float rv  = ta.variance(close, L) * (1.0 - math.min(0.999, r * r))
    float w   = 1.0 / (rv + 1e-10)
    [sl, w]

[s1, w1] = f_sw(i_l1)
[s2, w2] = f_sw(i_l2)
[s3, w3] = f_sw(i_l3)
[s4, w4] = f_sw(i_l4)
[s5, w5] = f_sw(i_l5)
float wsum = nz(w1) + nz(w2) + nz(w3) + nz(w4) + nz(w5)
float slope = wsum > 0 ? (nz(s1) * nz(w1) + nz(s2) * nz(w2) + nz(s3) * nz(w3) + nz(s4) * nz(w4) + nz(s5) * nz(w5)) / wsum : 0.0

float sigLine = ta.linreg(close, i_sigLen, 0)
bool  inSession = not i_useSess or not na(time(timeframe.period, i_sess))

int regime = slope > 0 ? 1 : slope < 0 ? -1 : 0
bool slopeOk = atr <= 0 or math.abs(slope) >= i_minSlope * atr
bool xUp = ta.crossover(close, sigLine)
bool xDn = ta.crossunder(close, sigLine)
bool entryUp   = inSession and slopeOk and regime ==  1 and xUp
bool entryDown = inSession and slopeOk and regime == -1 and xDn

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

plot(i_showLine ? sigLine : na, "Signal Line", color=regime == 1 ? color.new(i_buyColor, 20) : regime == -1 ? color.new(i_sellColor, 20) : color.new(color.gray, 50), linewidth=2)

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy",         shape.triangleup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="IVS", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.triangledown, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.triangledown, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell",        shape.triangledown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="IVS", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(regime == 1 ? color.new(i_buyColor, 94) : regime == -1 ? color.new(i_sellColor, 94) : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=i_dashBg, border_color=color.new(i_buyColor, 50), border_width=1)
    string rt = regime == 1 ? "SLOPE UP" : regime == -1 ? "SLOPE DOWN" : "FLAT"
    color  rc = regime == 1 ? i_buyColor : regime == -1 ? i_sellColor : color.gray
    table.cell(dash, 0, 0, "Inv-Var Slope Spectrum",text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                 text_color=color.new(i_buyColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "Regime",                text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, rt,                      text_color=rc, text_size=size.small)
    table.cell(dash, 0, 2, "Consensus Slope",       text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(slope, "#.#####"), text_color=slope >= 0 ? i_buyColor : i_sellColor, text_size=size.small)
    table.cell(dash, 0, 3, "Slope / ATR",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(atr > 0 ? slope / atr : 0, "0.000"), text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 4, "Signal Line",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(sigLine, "#.##"), text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 5, "Weight Sum",            text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(wsum, "#.##"), text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 6, "Position",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"IVS","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"IVS","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                          "IVS Buy",            "Spectrum-up long on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                         "IVS Sell",           "Spectrum-down short on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,            "IVS Any Signal",     "Any IVS signal on {{ticker}} {{interval}}")
alertcondition(regime == 1 and regime[1] != 1,     "IVS Slope Bull",     "Consensus slope turned up on {{ticker}} {{interval}}")
alertcondition(regime == -1 and regime[1] != -1,   "IVS Slope Bear",     "Consensus slope turned down on {{ticker}} {{interval}}")
alertcondition(xUp,                                "IVS Signal Up",      "Price crossed signal line up on {{ticker}} {{interval}}")
alertcondition(xDn,                                "IVS Signal Down",    "Price crossed signal line down on {{ticker}} {{interval}}")
alertcondition(ta.cross(slope, 0),                 "IVS Slope Zero",     "Consensus slope crossed zero on {{ticker}} {{interval}}")
alertcondition(math.abs(slope) >= i_minSlope * atr,"IVS Strong Slope",   "Consensus slope magnitude is strong on {{ticker}} {{interval}}")
alertcondition(regime != regime[1],                "IVS Regime Flip",    "Slope regime flipped on {{ticker}} {{interval}}")
alertcondition(ta.cross(close, sigLine),           "IVS Any Signal Cross","Any signal-line cross on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,            "IVS Webhook JSON",   "{\"action\":\"signal\",\"indicator\":\"IVS\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
