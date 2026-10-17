# Convex Hull Channel [forexobroker]

- url: https://www.tradingview.com/script/ABGW7xgv-Convex-Hull-Channel-forexobroker/
- type: indicator
- pine_id: PUB;f74c2993a3344f34ab30d0fdcac95376
- version: 1.0

## Description

🔶 OVERVIEW

Convex Hull Channel forms a tight envelope from the rolling maximum of body-tops (max of open and close) and minimum of body-bottoms (min of open and close), filtering wick spikes that classic Donchian channels reward. An expansion regime, defined as channel width above its 50-bar average, gates breakout signals to high-volatility periods only.

🔶 ALGORITHM

1. body_high = max(open, close); body_low = min(open, close).
2. upper = ta.highest(body_high, N); lower = ta.lowest(body_low, N).
3. width = upper - lower; expansion regime when width >= width_avg * (1 + k).
4. Buy break: close crosses prior bar's upper envelope inside expansion regime.
5. Sell break: close crosses prior bar's lower envelope inside expansion regime.

🔶 SIGNAL LOGIC

- Buy: expansion AND close crosses upper[1] AND not already long AND cooldown elapsed AND barstate.isconfirmed.
- Sell: expansion AND close crosses lower[1] AND mirror conditions.
- Position-lock state machine.

🔶 INPUTS

- Envelope Window (default 20)
- Min Width Excess (default 0.20)
- Cooldown Bars (default 4)
- Visual: dashboard, glow, envelope bands, buy / sell colors

🔶 ALERTS

CHC Buy, CHC Sell, CHC Any Signal, CHC Expansion On, CHC Expansion Off, CHC Upper Cross, CHC Lower Cross, CHC Outside, CHC Webhook JSON.

🔶 LIMITATIONS

- Body-only envelope gives fewer false breaks than wick-inclusive Donchian, but can miss legitimate moves that close back inside the body range.
- Expansion regime is rolling-average relative; a long quiet period followed by even modest expansion will fire whereas absolute-width logic might not.
- Cross-of-prior-bar (upper[1]) introduces a 1-bar delay vs immediate-bar break; intentional, reduces noise.
- Defaults tuned for 15m-1H on majors and indices; very fast scalping timeframes may want a smaller window.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Body-based convex envelope channel — uses max(open, close) for the upper envelope
// and min(open, close) for the lower one over a rolling window. Discounts wick spikes (which
// classic Donchian rewards). The envelope width is compared to its 50-bar average; expansion
// regime fires when the envelope is wider than its average, gating breakout signals to high-
// volatility periods only. Signals fire on close break of the prior bar's envelope. Distinct
// from Donchian: Donchian uses raw highs and lows; this uses bodies only, filtering false breaks.
indicator("Convex Hull Channel [forexobroker]", shorttitle="CHC [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc   = "Envelope"
string g_signal = "Signal Logic"
string g_visual = "Visual"

int   i_winLen   = input.int(20,    "Envelope Window", minval=8, maxval=100, group=g_calc)
float i_widthK   = input.float(0.20,"Min Width Excess", minval=0.05, maxval=2.0, step=0.05, group=g_signal, tooltip="Channel width must exceed (1 + k) x its 50-bar average to qualify as expansion. Filters squeezes.")
int   i_cooldown = input.int(4,    "Cooldown Bars", minval=1, maxval=20, group=g_signal)
bool  i_showTable = input.bool(true, "Show Dashboard", group=g_visual)
bool  i_showGlow  = input.bool(true, "Show 3-Layer Glow", group=g_visual)
bool  i_showBands = input.bool(true, "Show Envelope Bands", group=g_visual)
color i_buyColor  = input.color(#1de9b6, "Buy Color",  group=g_visual)
color i_sellColor = input.color(#ff5252, "Sell Color", group=g_visual)

color c_white = #ffffff

// ─── BODY-BASED ENVELOPE ──────────────────────────────────────────────────────
float bodyHi = math.max(open, close)
float bodyLo = math.min(open, close)
float upper  = ta.highest(bodyHi, i_winLen)
float lower  = ta.lowest(bodyLo,  i_winLen)
float mid    = (upper + lower) / 2.0
float width  = upper - lower

// ─── REGIME + ENTRY ───────────────────────────────────────────────────────────
float widthMa = ta.sma(width, 50)
bool  expansion = width >= widthMa * (1.0 + i_widthK)

bool  crossUp = ta.crossover(close, upper[1])
bool  crossDn = ta.crossunder(close, lower[1])
bool  entryUp   = expansion and crossUp
bool  entryDown = expansion and crossDn

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
plot(i_showBands ? upper : na, "Upper", color=color.new(i_buyColor, 30),  linewidth=2)
plot(i_showBands ? lower : na, "Lower", color=color.new(i_sellColor, 30), linewidth=2)
plot(i_showBands ? mid   : na, "Mid",   color=color.new(color.gray, 50),  linewidth=1)

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy Signal",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="CHC up", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.triangledown, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.triangledown, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell Signal", shape.triangledown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="CHC dn", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(expansion ? color.new(color.gray, 96) : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=color.new(color.black, 20), border_color=color.new(color.white, 80), border_width=1)
    string regimeTxt = expansion ? "EXPANSION" : "SQUEEZE"
    color  regimeCol = expansion ? c_white : color.gray
    table.cell(dash, 0, 0, "Convex Hull Channel", text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",               text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 0, 1, "Upper",               text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(upper, "#.##"),     text_color=i_buyColor, text_size=size.small)
    table.cell(dash, 0, 2, "Lower",               text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(lower, "#.##"),     text_color=i_sellColor, text_size=size.small)
    table.cell(dash, 0, 3, "Width",               text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(width, "#.######"), text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 4, "Width Avg",           text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(widthMa, "#.######"), text_color=color.gray, text_size=size.small)
    table.cell(dash, 0, 5, "Regime",              text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, regimeTxt,             text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 6, "Position",            text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",         text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"CHC","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"upper":' + str.tostring(upper, "#.##") + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"CHC","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"lower":' + str.tostring(lower, "#.##") + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                                  "CHC Buy",          "Convex Hull bull break on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                                 "CHC Sell",         "Convex Hull bear break on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,                    "CHC Any Signal",   "Any CHC signal on {{ticker}} {{interval}}")
alertcondition(expansion and not expansion[1],             "CHC Expansion On", "Channel expansion entered on {{ticker}} {{interval}}")
alertcondition(not expansion and expansion[1],             "CHC Expansion Off","Channel expansion ended on {{ticker}} {{interval}}")
alertcondition(crossUp,                                    "CHC Upper Cross",  "Close crossed upper envelope on {{ticker}} {{interval}}")
alertcondition(crossDn,                                    "CHC Lower Cross",  "Close crossed lower envelope on {{ticker}} {{interval}}")
alertcondition(close > upper or close < lower,             "CHC Outside",      "Close outside envelope on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,                    "CHC Webhook JSON", "{\"action\":\"signal\",\"indicator\":\"CHC\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
