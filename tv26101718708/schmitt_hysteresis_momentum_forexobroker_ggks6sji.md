# Schmitt Hysteresis Momentum [forexobroker]

- url: https://www.tradingview.com/script/GGKS6sjI-Schmitt-Hysteresis-Momentum-forexobroker/
- type: indicator
- pine_id: PUB;41800f40fa5f4a4799d3c8a19f560057
- version: 1.0

## Description

Schmitt Hysteresis Momentum applies a textbook control-theory Schmitt trigger to rate of change. Two ATR-scaled thresholds (one positive, one negative) form a hysteresis band: state flips up only when RoC clears the upper threshold, flips down only when RoC clears the lower. Within a held state, EMA crosses provide entry timing — multiple entries per state without flip-flop.

🔶 ALGORITHM

1. RoC = (close - close[N]) / close[N].
2. Adaptive thresholds: upper = +k * (atr / close); lower = -k * (atr / close).
3. State machine: state := +1 if RoC > upper, -1 if RoC < lower, hold previous otherwise.
4. EMA cross within state direction provides the entry trigger.

🔶 SIGNAL LOGIC

- Buy: state == +1 AND close crosses EMA up AND not already long AND cooldown elapsed AND barstate.isconfirmed.
- Sell: state == -1 AND close crosses EMA down.
- Position-lock state machine.

🔶 INPUTS

- RoC Lookback (default 10)
- Pullback EMA Length (default 8)
- Threshold k x ATR Pct (default 0.30)
- Cooldown Bars (default 4)
- Visual: dashboard, glow, EMA toggle, buy / sell colors

🔶 ALERTS

SHM Buy, SHM Sell, SHM Any Signal, SHM Bull Lock, SHM Bear Lock, SHM Upper Cross, SHM Lower Cross, SHM EMA Up, SHM Webhook JSON.

🔶 LIMITATIONS

- Hysteresis prevents flip-flop but slightly lags one-shot regime changes vs single-threshold logic.
- ATR-scaled thresholds are stationarised by atr_pct; very low-volatility periods can leave the state stuck for many bars without entries.
- RoC lookback length affects responsiveness; defaults assume 5m to 1H bars.
- This is a momentum-state engine, not a trend-strength meter; it tells you what regime you are in, not how strong it is.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Schmitt trigger (control-theory hysteresis) on rate-of-change. Two adaptive
// thresholds, both scaled to ATR percent: enter bull state when RoC > +k*atr_pct, enter bear
// state when RoC < -k*atr_pct, hold the previous state in between. This is the textbook way to
// avoid flip-flop near a single threshold and is widely used in noise-tolerant signal processing.
// Within a held state, signals fire on close-EMA cross — so each state can produce multiple
// entries as price oscillates around the trend. Distinct from any threshold-cross indicator: the
// hysteresis band is the entire mechanism.
indicator("Schmitt Hysteresis Momentum [forexobroker]", shorttitle="SHM [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc   = "Schmitt Trigger"
string g_signal = "Signal Logic"
string g_visual = "Visual"

int   i_rocLen   = input.int(10,    "RoC Lookback", minval=2, maxval=50, group=g_calc)
int   i_emaLen   = input.int(8,     "Pullback EMA Length", minval=3, maxval=50, group=g_signal)
float i_thrK     = input.float(0.30,"Threshold k x ATR%%", minval=0.05, maxval=2.0, step=0.05, group=g_signal, tooltip="Upper threshold = +k*atr/close. Lower = -k*atr/close. Hysteresis between.")
int   i_cooldown = input.int(4,    "Cooldown Bars", minval=1, maxval=20, group=g_signal)
bool  i_showTable = input.bool(true, "Show Dashboard", group=g_visual)
bool  i_showGlow  = input.bool(true, "Show 3-Layer Glow", group=g_visual)
bool  i_showEma   = input.bool(true, "Show Pullback EMA", group=g_visual)
color i_buyColor  = input.color(#00e676, "Buy Color",  group=g_visual)
color i_sellColor = input.color(#ff1744, "Sell Color", group=g_visual)

color c_white = #ffffff

// ─── ROC + ADAPTIVE THRESHOLDS ────────────────────────────────────────────────
float atr14  = nz(ta.atr(14), 0.0)
float atrPct = atr14 / close
float roc    = (close - close[i_rocLen]) / close[i_rocLen]
float upThr  =  i_thrK * atrPct
float dnThr  = -i_thrK * atrPct

// ─── SCHMITT REGIME ───────────────────────────────────────────────────────────
var int regime = 0
if roc >  upThr
    regime := 1
else if roc < dnThr
    regime := -1

// ─── ENTRY ────────────────────────────────────────────────────────────────────
float ema     = ta.ema(close, i_emaLen)
bool  crossUp = ta.crossover(close, ema)
bool  crossDn = ta.crossunder(close, ema)
bool entryUp   = regime ==  1 and crossUp
bool entryDown = regime == -1 and crossDn

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

color emaCol = regime ==  1 ? i_buyColor : regime == -1 ? i_sellColor : color.new(color.gray, 50)
plot(i_showEma ? ema : na, "Pullback EMA", color=emaCol, linewidth=2)

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.square, location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.square, location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy Signal",  shape.square, location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="SHM up", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.square, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.square, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell Signal", shape.square, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="SHM dn", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(regime == 1 ? color.new(i_buyColor, 94) : regime == -1 ? color.new(i_sellColor, 94) : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=color.new(color.black, 20), border_color=color.new(color.white, 80), border_width=1)
    string regimeTxt = regime ==  1 ? "BULL HOLD" : regime == -1 ? "BEAR HOLD" : "NEUTRAL"
    color  regimeCol = regime ==  1 ? i_buyColor : regime == -1 ? i_sellColor : color.gray
    table.cell(dash, 0, 0, "Schmitt Hysteresis Momentum", text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                       text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 0, 1, "RoC",                         text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(roc, "0.0000"),          text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 2, "Upper Thr",                   text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(upThr, "0.0000"),        text_color=color.gray, text_size=size.small)
    table.cell(dash, 0, 3, "Lower Thr",                   text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(dnThr, "0.0000"),        text_color=color.gray, text_size=size.small)
    table.cell(dash, 0, 4, "ATR Pct",                     text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(atrPct * 100, "0.000") + "%", text_color=color.gray, text_size=size.small)
    table.cell(dash, 0, 5, "Regime",                      text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, regimeTxt,                     text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 6, "Position",                    text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",                 text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"SHM","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"roc":' + str.tostring(roc, "0.0000") + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"SHM","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"roc":' + str.tostring(roc, "0.0000") + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                                  "SHM Buy",          "Schmitt bull hold + cross on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                                 "SHM Sell",         "Schmitt bear hold + cross on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,                    "SHM Any Signal",   "Any SHM signal on {{ticker}} {{interval}}")
alertcondition(regime ==  1 and regime[1] !=  1,           "SHM Bull Lock",    "Schmitt bull state locked on {{ticker}} {{interval}}")
alertcondition(regime == -1 and regime[1] != -1,           "SHM Bear Lock",    "Schmitt bear state locked on {{ticker}} {{interval}}")
alertcondition(roc >  upThr and roc[1] <= upThr,           "SHM Upper Cross",  "RoC crossed upper threshold on {{ticker}} {{interval}}")
alertcondition(roc <  dnThr and roc[1] >= dnThr,           "SHM Lower Cross",  "RoC crossed lower threshold on {{ticker}} {{interval}}")
alertcondition(crossUp,                                    "SHM EMA Up",       "Close crossed EMA up on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,                    "SHM Webhook JSON", "{\"action\":\"signal\",\"indicator\":\"SHM\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
