# Hawkes Flow Ignite [forexobroker]

- url: https://www.tradingview.com/script/QCX4uWcs-Hawkes-Flow-Ignite-forexobroker/
- type: indicator
- pine_id: PUB;280412724fad45b3aa1d2dd9006fa682
- version: 1.0

## Description

Hawkes Flow Ignite models order-flow clustering with a self-exciting Poisson (Hawkes) process. Each volume burst raises the intensity lambda(t), which then decays exponentially with user-set half-life. Sustained activity = sustained intensity. Signals fire on strong directional bars within a cluster regime.

🔶 ALGORITHM

1. Burst event: volume > sma(volume, N) + k * stdev(volume, N).
2. Intensity update: lambda[t] = decay * lambda[t-1] + (burst ? 1 : 0), where decay = exp(-ln(2) / halflife).
3. Cluster regime active when lambda > sma(lambda, 100) + k * stdev(lambda, 100).
4. Strong bar detection: |close - open| > k * ATR, with sign giving direction.

🔶 SIGNAL LOGIC

- Buy: cluster active AND (close - open) > k * ATR AND not already long AND cooldown elapsed AND barstate.isconfirmed.
- Sell: cluster active AND (close - open) < -k * ATR.
- Position-lock state machine.

🔶 INPUTS

- Volume Window (default 20)
- Burst k (default 1.5 sigma)
- Decay Half-Life (default 15 bars)
- Intensity Threshold k (default 1.0)
- Bar Strength x ATR (default 0.30)
- Cooldown Bars (default 4)
- Visual: dashboard, glow, buy / sell colors

🔶 ALERTS

HFI Buy, HFI Sell, HFI Any Signal, HFI Cluster Start, HFI Cluster End, HFI Burst, HFI Strong Up Bar, HFI Strong Dn Bar, HFI Webhook JSON.

🔶 LIMITATIONS

- Forex tick volume is broker-aggregated and noisy; performance is best on instruments with reliable volume (futures, crypto, equities).
- Half-life is a fixed parameter; real Hawkes processes use a learned kernel that varies by event type.
- Cluster gate plus strong-bar gate is conservative; for higher cadence reduce bar-strength k.
- Burst threshold uses fixed sigma; some sessions naturally have higher z-scores than others.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Hawkes self-exciting point process applied to volume bursts. The intensity lambda(t)
// increases each time a volume burst arrives, then decays exponentially with half-life H. This
// captures order-flow clustering — institutions trading together produce intensity bursts that
// linger. Bursts are defined as volume above sma + k*stdev. Signals fire when intensity exceeds
// its rolling threshold (cluster active) AND a strong directional bar prints (close-open > k*ATR).
// Position-lock prevents over-firing within the same cluster.
indicator("Hawkes Flow Ignite [forexobroker]", shorttitle="HFI [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc   = "Hawkes Process"
string g_signal = "Signal Logic"
string g_visual = "Visual"

int   i_volLen   = input.int(20,    "Volume Window",         minval=10, maxval=100, group=g_calc)
float i_burstK   = input.float(1.5, "Burst k (vol > mean + k*sd)", minval=0.5, maxval=4.0, step=0.1, group=g_calc, tooltip="Z-score threshold for a volume bar to count as a burst event.")
int   i_halfLife = input.int(15,    "Decay Half-Life (bars)", minval=3, maxval=50, group=g_calc, tooltip="Bars over which an excitation decays to half. Smaller = faster reset.")
float i_intK     = input.float(1.0, "Intensity Threshold k", minval=0.2, maxval=4.0, step=0.1, group=g_signal, tooltip="Cluster regime when intensity > mean + k*sd.")
float i_barK     = input.float(0.30,"Bar Strength x ATR",    minval=0.05, maxval=2.0, step=0.05, group=g_signal, tooltip="Entry only on bars where |close-open| >= k*ATR.")
int   i_cooldown = input.int(4,     "Cooldown Bars",         minval=1, maxval=20, group=g_signal)
bool  i_showTable = input.bool(true, "Show Dashboard", group=g_visual)
bool  i_showGlow  = input.bool(true, "Show 3-Layer Glow", group=g_visual)
color i_buyColor  = input.color(#00e676, "Buy Color",  group=g_visual)
color i_sellColor = input.color(#ff1744, "Sell Color", group=g_visual)

color c_white = #ffffff

// ─── HAWKES INTENSITY ──────────────────────────────────────────────────────────
float volMa  = ta.sma(volume, i_volLen)
float volSd  = ta.stdev(volume, i_volLen)
bool  burst  = volume > volMa + i_burstK * volSd
float decay  = math.exp(-math.log(2.0) / i_halfLife)
var float lambda = 0.0
lambda := decay * nz(lambda[1], 0.0) + (burst ? 1.0 : 0.0)

float lambdaMa = ta.sma(lambda, 100)
float lambdaSd = ta.stdev(lambda, 100)
bool  cluster  = lambda > lambdaMa + i_intK * lambdaSd

// ─── ENTRY TRIGGER ─────────────────────────────────────────────────────────────
float atr14 = nz(ta.atr(14), 0.0)
float bodyAbs = math.abs(close - open)
bool  strongUp   = (close - open) >  i_barK * atr14
bool  strongDown = (close - open) < -i_barK * atr14
bool  entryUp    = cluster and strongUp
bool  entryDown  = cluster and strongDown

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

// ─── VISUAL ────────────────────────────────────────────────────────────────────
plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.flag, location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.flag, location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy Signal",  shape.flag, location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="HFI up", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.flag, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.flag, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell Signal", shape.flag, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="HFI dn", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(cluster ? color.new(close > open ? i_buyColor : i_sellColor, 92) : na)

// ─── DASHBOARD ────────────────────────────────────────────────────────────────
if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=color.new(color.black, 20), border_color=color.new(color.white, 80), border_width=1)
    string regimeTxt = cluster ? "CLUSTER ACTIVE" : "QUIET"
    color  regimeCol = cluster ? (close > open ? i_buyColor : i_sellColor) : color.gray
    table.cell(dash, 0, 0, "Hawkes Flow Ignite", text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",              text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 0, 1, "Intensity",          text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(lambda, "0.000"),    text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 2, "Threshold",          text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(lambdaMa + i_intK * lambdaSd, "0.000"), text_color=color.gray, text_size=size.small)
    table.cell(dash, 0, 3, "Burst Now",          text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, burst ? "YES" : "NO", text_color=burst ? c_white : color.gray, text_size=size.small)
    table.cell(dash, 0, 4, "Half-Life",          text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(i_halfLife) + " bars", text_color=color.gray, text_size=size.small)
    table.cell(dash, 0, 5, "Regime",             text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, regimeTxt,            text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 6, "Position",           text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",        text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"HFI","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"intensity":' + str.tostring(lambda, "0.000") + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"HFI","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"intensity":' + str.tostring(lambda, "0.000") + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                                  "HFI Buy",            "Hawkes cluster bull on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                                 "HFI Sell",           "Hawkes cluster bear on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,                    "HFI Any Signal",     "Any HFI signal on {{ticker}} {{interval}}")
alertcondition(cluster and not cluster[1],                 "HFI Cluster Start",  "Cluster regime entered on {{ticker}} {{interval}}")
alertcondition(not cluster and cluster[1],                 "HFI Cluster End",    "Cluster regime ended on {{ticker}} {{interval}}")
alertcondition(burst,                                      "HFI Burst",          "Volume burst on {{ticker}} {{interval}}")
alertcondition(strongUp,                                   "HFI Strong Up Bar",  "Strong up bar on {{ticker}} {{interval}}")
alertcondition(strongDown,                                 "HFI Strong Dn Bar",  "Strong down bar on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,                    "HFI Webhook JSON",   "{\"action\":\"signal\",\"indicator\":\"HFI\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
