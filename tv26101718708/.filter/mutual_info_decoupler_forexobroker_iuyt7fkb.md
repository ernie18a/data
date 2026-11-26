# Mutual Info Decoupler [forexobroker]

- url: https://www.tradingview.com/script/iUYt7Fkb-Mutual-Info-Decoupler-forexobroker/
- type: indicator
- pine_id: PUB;06830137aee042838af2c7a21fff1912
- version: 1.0

## Description

Mutual Info Decoupler measures the information-theoretic dependence between price returns and volume over a rolling window. High MI = price moves explained by volume (informed flow). Low MI = price and volume decoupled (noise). Signals fire on EMA cross within a coupled regime, where the move is statistically grounded.

🔶 ALGORITHM

1. Bin returns into 3 quantile classes (low / mid / high) using +/- 0.5 sigma boundaries.
2. Bin volume into 3 classes (low / mid / high) using volume_avg * 0.7 and 1.3 boundaries.
3. Build 3x3 joint count matrix; derive marginals P(r) and P(v).
4. MI = sum_{r,v} P(r,v) * log( P(r,v) / (P(r) * P(v)) ) in nats.
5. Coupled regime when MI >= threshold.

🔶 SIGNAL LOGIC

- Buy: coupled AND close > SMA AND close crosses EMA up AND not already long AND cooldown elapsed AND barstate.isconfirmed.
- Sell: coupled AND close < SMA AND close crosses EMA down.
- Position-lock state machine.

🔶 INPUTS

- MI Window (default 60)
- Pullback EMA Length (default 8)
- Min MI (default 0.05 nats)
- Cooldown Bars (default 4)
- Visual: dashboard, glow, EMA toggle, buy / sell colors

🔶 ALERTS

MID Buy, MID Sell, MID Any Signal, MID Coupled On, MID Coupled Off, MID High MI, MID Cross Up, MID Cross Down, MID Webhook JSON.

🔶 LIMITATIONS

- 3x3 binning is coarse; finer resolution needs much more history to avoid empty cells.
- Forex tick volume is broker-aggregated and noisy; instruments with reliable volume produce more meaningful MI.
- MI is symmetric and dimension-free but does not tell direction; directional gating uses SMA bias.
- Window N = 60 is a balance between estimator stability and adaptiveness; longer windows produce smoother MI but slower regime detection.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Mutual information between price returns and volume over a rolling window. Returns
// and volume are each binned into 3 quantile buckets (low / mid / high). The 3x3 joint
// distribution gives MI = sum p(r,v) * log(p(r,v) / (p(r)*p(v))). High MI = price moves are
// explained by volume (institutional / informed flow). Low MI = noise. Signals fire on close/EMA
// cross within a high-MI regime — coupling validates the move. Distinct from any volume oscillator:
// MI captures statistical dependence in any direction, not just same-sign agreement.
indicator("Mutual Info Decoupler [forexobroker]", shorttitle="MID [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc   = "Mutual Information"
string g_signal = "Signal Logic"
string g_visual = "Visual"

int   i_winLen   = input.int(60,    "MI Window", minval=20, maxval=200, group=g_calc)
int   i_emaLen   = input.int(8,     "Pullback EMA Length", minval=3, maxval=50, group=g_signal)
float i_miThr    = input.float(0.05,"Min MI (nats)", minval=0.0, maxval=0.5, step=0.01, group=g_signal, tooltip="Mutual information lower bound for 'coupled' regime. 0 = independent.")
int   i_cooldown = input.int(4,    "Cooldown Bars", minval=1, maxval=20, group=g_signal)
bool  i_showTable = input.bool(true, "Show Dashboard", group=g_visual)
bool  i_showGlow  = input.bool(true, "Show 3-Layer Glow", group=g_visual)
bool  i_showEma   = input.bool(true, "Show Pullback EMA", group=g_visual)
color i_buyColor  = input.color(#39ff14, "Buy Color",  group=g_visual)
color i_sellColor = input.color(#ff2d78, "Sell Color", group=g_visual)

color c_white = #ffffff

// ─── BIN RETURNS AND VOLUME, COMPUTE MI ────────────────────────────────────────
int N = i_winLen
// Pre-compute bin boundaries from window stats
float retSd = ta.stdev(close - close[1], N)
float volMa = ta.sma(volume, N)
float retLo = -0.5 * retSd
float retHi =  0.5 * retSd
float volLo = volMa * 0.7
float volHi = volMa * 1.3

// 3x3 joint: r_bin in {0,1,2}, v_bin in {0,1,2}
var int[] joint = array.new_int(9, 0)
for k = 0 to 8
    array.set(joint, k, 0)

for k = 0 to N - 1
    float r = nz(close[k]) - nz(close[k + 1])
    float v = nz(volume[k])
    int rb = r < retLo ? 0 : r > retHi ? 2 : 1
    int vb = v < volLo ? 0 : v > volHi ? 2 : 1
    int idx = rb * 3 + vb
    array.set(joint, idx, array.get(joint, idx) + 1)

// Marginals
int totalC = 0
for k = 0 to 8
    totalC += array.get(joint, k)
float pR0 = (array.get(joint, 0) + array.get(joint, 1) + array.get(joint, 2)) / float(math.max(totalC, 1))
float pR1 = (array.get(joint, 3) + array.get(joint, 4) + array.get(joint, 5)) / float(math.max(totalC, 1))
float pR2 = (array.get(joint, 6) + array.get(joint, 7) + array.get(joint, 8)) / float(math.max(totalC, 1))
float pV0 = (array.get(joint, 0) + array.get(joint, 3) + array.get(joint, 6)) / float(math.max(totalC, 1))
float pV1 = (array.get(joint, 1) + array.get(joint, 4) + array.get(joint, 7)) / float(math.max(totalC, 1))
float pV2 = (array.get(joint, 2) + array.get(joint, 5) + array.get(joint, 8)) / float(math.max(totalC, 1))

float mi = 0.0
for rb = 0 to 2
    for vb = 0 to 2
        float pij = array.get(joint, rb * 3 + vb) / float(math.max(totalC, 1))
        float pi = rb == 0 ? pR0 : rb == 1 ? pR1 : pR2
        float pj = vb == 0 ? pV0 : vb == 1 ? pV1 : pV2
        if pij > 0 and pi > 0 and pj > 0
            mi += pij * math.log(pij / (pi * pj))

// ─── REGIME + ENTRY ───────────────────────────────────────────────────────────
float ema     = ta.ema(close, i_emaLen)
float sma     = ta.sma(close, 20)
bool  coupled = mi >= i_miThr
bool  trendUp = coupled and close > sma
bool  trendDn = coupled and close < sma
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

color emaCol = coupled ? (close > sma ? i_buyColor : i_sellColor) : color.new(color.gray, 50)
plot(i_showEma ? ema : na, "EMA", color=emaCol, linewidth=2)

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy Signal",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="MID up", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.triangledown, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.triangledown, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell Signal", shape.triangledown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="MID dn", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(coupled ? color.new(close > sma ? i_buyColor : i_sellColor, 95) : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=color.new(color.black, 20), border_color=color.new(color.white, 80), border_width=1)
    string regimeTxt = coupled ? "COUPLED" : "DECOUPLED"
    color  regimeCol = coupled ? (close > sma ? i_buyColor : i_sellColor) : color.gray
    table.cell(dash, 0, 0, "Mutual Info Decoupler", text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                 text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 0, 1, "MI (nats)",             text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(mi, "0.000"),  text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 2, "Threshold",             text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(i_miThr, "0.00"), text_color=color.gray, text_size=size.small)
    table.cell(dash, 0, 3, "Window",                text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(N) + " bars",     text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 4, "Bias",                  text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, close > sma ? "UP" : "DOWN",   text_color=close > sma ? i_buyColor : i_sellColor, text_size=size.small)
    table.cell(dash, 0, 5, "Regime",                text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, regimeTxt,               text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 6, "Position",              text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",           text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"MID","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"mi":' + str.tostring(mi, "0.000") + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"MID","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"mi":' + str.tostring(mi, "0.000") + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                                  "MID Buy",          "MI coupled bull on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                                 "MID Sell",         "MI coupled bear on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,                    "MID Any Signal",   "Any MID signal on {{ticker}} {{interval}}")
alertcondition(coupled and not coupled[1],                 "MID Coupled On",   "Coupled regime entered on {{ticker}} {{interval}}")
alertcondition(not coupled and coupled[1],                 "MID Coupled Off",  "Coupled regime ended on {{ticker}} {{interval}}")
alertcondition(mi >= 0.15,                                 "MID High MI",      "MI >= 0.15 on {{ticker}} {{interval}}")
alertcondition(crossUp,                                    "MID Cross Up",     "Close crossed EMA up on {{ticker}} {{interval}}")
alertcondition(crossDn,                                    "MID Cross Down",   "Close crossed EMA down on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,                    "MID Webhook JSON", "{\"action\":\"signal\",\"indicator\":\"MID\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
