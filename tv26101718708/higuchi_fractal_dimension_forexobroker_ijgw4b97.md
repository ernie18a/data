# Higuchi Fractal Dimension [forexobroker]

- url: https://www.tradingview.com/script/iJGW4b97-Higuchi-Fractal-Dimension-forexobroker/
- type: indicator
- pine_id: PUB;d12b34a90a2642678cbd699bab29179e
- version: 1.0

## Description

Higuchi Fractal Dimension estimates the fractal dimension D of the price curve in a bounded [1, 2] interval: D close to 1 means smooth and trending, D close to 2 means jagged and random. The simplified two-scale variant (k = 1 and k = 4) gives a fast, deterministic estimator suitable for live charts.

🔶 ALGORITHM

1. L(1) = average absolute single-bar move over the window: sum |close[i] - close[i+1]| / (N - 1).
2. L(4) = average absolute four-bar move, normalised by step count.
3. Dimension D = log(L(1) / L(4)) / log(4) + 1, clipped to [1, 2].
4. Smooth regime when D <= threshold.
5. Direction comes from close vs trend SMA.

🔶 SIGNAL LOGIC

- Buy: smooth regime AND close > SMA AND close crosses SMA up AND not already long AND cooldown elapsed AND barstate.isconfirmed.
- Sell: smooth regime AND close < SMA AND close crosses SMA down.
- Position-lock state machine.

🔶 INPUTS

- Higuchi Window (default 60)
- Trend SMA Length (default 20)
- Smooth Threshold (default 1.65)
- Cooldown Bars (default 4)
- Visual: dashboard, glow, SMA toggle, buy / sell colors

🔶 ALERTS

HFD Buy, HFD Sell, HFD Any Signal, HFD Smooth On, HFD Smooth Off, HFD Strong Trend, HFD Strong Chop, HFD SMA Cross Up, HFD Webhook JSON.

🔶 LIMITATIONS

- Two-scale (k = 1, k = 4) approximation is faster but less accurate than the full Higuchi method (k = 1..k_max).
- D depends on price scale, partly mitigated by ratio formulation; on extremely thin instruments the estimator can saturate.
- Threshold 1.65 is calibrated to liquid majors / indices; faster instruments may need a lower threshold.
- "Random walk" is theoretical D = 1.5; real charts often show D between 1.4 and 1.7 even in clearly trending sessions.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Higuchi method for fractal dimension on the price curve. Computes the curve length
// at two scales (k=1 every-bar steps and k=4 every-fourth-bar steps), then derives the fractal
// dimension D from the slope of log(L(k)) vs log(k). D in [1, 2]: D ~ 1 means smooth/trending,
// D ~ 2 means random/jagged. Signals fire on close/SMA cross within a smooth (D <= threshold)
// regime — Higuchi tells you whether the market is currently behaving like a trend at all.
indicator("Higuchi Fractal Dimension [forexobroker]", shorttitle="HFD [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc   = "Higuchi"
string g_signal = "Signal Logic"
string g_visual = "Visual"

int   i_winLen   = input.int(60,    "Higuchi Window", minval=20, maxval=200, group=g_calc)
int   i_smaLen   = input.int(20,    "Trend SMA Length", minval=5, maxval=100, group=g_signal)
float i_dThr     = input.float(1.65,"Smooth Threshold (D <=)", minval=1.05, maxval=1.95, step=0.01, group=g_signal, tooltip="Below this = smooth/trending. Random walk hits ~1.5; pure trend ~1.0; pure noise ~2.0.")
int   i_cooldown = input.int(4,    "Cooldown Bars", minval=1, maxval=20, group=g_signal)
bool  i_showTable = input.bool(true, "Show Dashboard", group=g_visual)
bool  i_showGlow  = input.bool(true, "Show 3-Layer Glow", group=g_visual)
bool  i_showSma   = input.bool(true, "Show Trend SMA", group=g_visual)
color i_buyColor  = input.color(#00e676, "Buy Color",  group=g_visual)
color i_sellColor = input.color(#ff1744, "Sell Color", group=g_visual)

color c_white = #ffffff

// ─── HIGUCHI FRACTAL DIMENSION (2-scale: k=1 vs k=4) ───────────────────────────
int N = i_winLen
float L1 = 0.0
for i = 0 to N - 2
    L1 += math.abs(nz(close[i]) - nz(close[i + 1]))
L1 := (N - 1) > 0 ? L1 / (N - 1) : 0.0

float L4 = 0.0
int n4 = (N - 1) / 4
for i = 0 to n4 - 1
    L4 += math.abs(nz(close[i * 4]) - nz(close[(i + 1) * 4]))
L4 := n4 > 0 ? (L4 * (N - 1)) / (n4 * 4 * (N - 1)) : 0.0

float dim = (L1 > 0 and L4 > 0) ? math.log(L1 / L4) / math.log(4.0) + 1.0 : 1.5
dim := math.max(1.0, math.min(2.0, dim))

// ─── REGIME + ENTRY ───────────────────────────────────────────────────────────
float sma     = ta.sma(close, i_smaLen)
bool  smooth  = dim <= i_dThr
bool  trendUp = smooth and close > sma
bool  trendDn = smooth and close < sma
bool  crossUp = ta.crossover(close, sma)
bool  crossDn = ta.crossunder(close, sma)
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

color smaCol = smooth ? (close > sma ? i_buyColor : i_sellColor) : color.new(color.gray, 50)
plot(i_showSma ? sma : na, "Trend SMA", color=smaCol, linewidth=2)

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy Signal",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="HFD up", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.triangledown, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.triangledown, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell Signal", shape.triangledown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="HFD dn", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(smooth ? color.new(close > sma ? i_buyColor : i_sellColor, 95) : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=color.new(color.black, 20), border_color=color.new(color.white, 80), border_width=1)
    string regimeTxt = smooth ? "SMOOTH" : "JAGGED"
    color  regimeCol = smooth ? (close > sma ? i_buyColor : i_sellColor) : color.gray
    table.cell(dash, 0, 0, "Higuchi Fractal Dimension", text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                     text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 0, 1, "Dimension D",               text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(dim, "0.000"),         text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 2, "L(1)",                      text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(L1, "#.######"),       text_color=color.gray, text_size=size.small)
    table.cell(dash, 0, 3, "L(4)",                      text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(L4, "#.######"),       text_color=color.gray, text_size=size.small)
    table.cell(dash, 0, 4, "Threshold",                 text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(i_dThr, "0.00"),       text_color=color.gray, text_size=size.small)
    table.cell(dash, 0, 5, "Regime",                    text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, regimeTxt,                   text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 6, "Position",                  text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",               text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"HFD","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"D":' + str.tostring(dim, "0.000") + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"HFD","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"D":' + str.tostring(dim, "0.000") + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                                  "HFD Buy",         "Higuchi smooth bull on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                                 "HFD Sell",        "Higuchi smooth bear on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,                    "HFD Any Signal",  "Any HFD signal on {{ticker}} {{interval}}")
alertcondition(smooth and not smooth[1],                   "HFD Smooth On",   "Smooth regime entered on {{ticker}} {{interval}}")
alertcondition(not smooth and smooth[1],                   "HFD Smooth Off",  "Jagged regime entered on {{ticker}} {{interval}}")
alertcondition(dim <= 1.2,                                 "HFD Strong Trend","Very smooth (D <= 1.2) on {{ticker}} {{interval}}")
alertcondition(dim >= 1.8,                                 "HFD Strong Chop", "Very jagged (D >= 1.8) on {{ticker}} {{interval}}")
alertcondition(crossUp,                                    "HFD SMA Cross Up","Close crossed SMA up on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,                    "HFD Webhook JSON","{\"action\":\"signal\",\"indicator\":\"HFD\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
