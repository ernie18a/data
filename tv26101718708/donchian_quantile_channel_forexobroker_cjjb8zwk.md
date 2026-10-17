# Donchian Quantile Channel [forexobroker]

- url: https://www.tradingview.com/script/Cjjb8zWk-Donchian-Quantile-Channel-forexobroker/
- type: indicator
- pine_id: PUB;b3fdac9c37e74e54bce88f6610009c18
- version: 1.0

## Description

Donchian Quantile Channel [forexobroker] replaces the classic Donchian min/max envelope with robust order-statistics. The upper rail is the 90th-percentile high, the lower rail is the 10th-percentile low, and the middle spine is the 50th-percentile close, all measured over the same lookback. Channel width is then ranked against its own 200-bar history to mark expansion versus compression. Breakouts only fire when the channel is in the expansion half of its own history, which screens out quiet-channel pokes that classic Donchian treats the same as real range breaks.

🔶 ALGORITHM

1. A lookback N (default 50) defines the quantile window.
2. Upper rail = percentile_nearest_rank(high, N, 90); spine = percentile_nearest_rank(close, N, 50); lower rail = percentile_nearest_rank(low, N, 10). Using percentile_nearest_rank ignores single extreme prints that would otherwise pin a min/max envelope.
3. Width = upper - lower, ranked over the width-rank lookback (default 200 bars) using percentrank.
4. The expansion gate compares the current width rank to the Min Width Rank input (default 50). Above the threshold means the channel is wider than half its own history.
5. Crossovers of close against the upper or lower rail are detected with crossover/crossunder.
6. Signals only fire when a rail is broken inside the expansion regime, position state is flat or opposite, cooldown is satisfied and barstate.isconfirmed is true.

🔶 SIGNAL LOGIC

- Buy: close crosses above the upper quantile AND width rank is above the minimum AND session filter passes AND not already long AND cooldown bars elapsed AND barstate.isconfirmed.
- Sell: close crosses below the lower quantile AND width rank is above the minimum AND session filter passes AND not already short AND cooldown bars elapsed AND barstate.isconfirmed.

A single posState flag prevents same-side re-entry until the opposite signal resets it.

🔶 INPUTS

- Channel group: quantile lookback N default 50, upper percentile default 90, middle default 50, lower default 10, width-rank lookback default 200.
- Signal Logic group: min width rank percent (default 50) for the expansion gate, cooldown bars default 15.
- Filters group: session restriction toggle off by default with a 0000-2400 default window.
- Visual group: gradient fill, dashboard, 3-layer glow toggles plus full color overrides and dashboard background.

🔶 ALERTS

DQC Buy, DQC Sell, DQC Any Signal, DQC Upper Break, DQC Lower Break, DQC Spine Cross Up, DQC Spine Cross Dn, DQC Expansion, DQC Compression, DQC Extreme Width, DQC Extreme Squeeze, DQC Webhook JSON.

🔶 LIMITATIONS

- Percentile rails are step-like; on short lookbacks they move only when a window slot rolls off, so the channel can sit flat for several bars even as price moves.
- The expansion gate hides breakouts in quiet markets; on instruments that habitually trend on low realised range the filter will skip valid trades.
- Cooldown is a fixed bar count; it does not adapt to timeframe shifts.
- Percentiles are non-anticipatory but the channel itself only stabilises once N bars of history exist; early history shows wider, less reliable rails.
- The instrument target is ES; on illiquid symbols the upper/lower rails can be pinned to the same single print across multiple bars.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Donchian Quantile Channel. Replaces the classic Donchian min/max envelope with
// robust order-statistics: the upper rail is the 90th percentile of highs, the lower rail
// is the 10th percentile of lows, the spine is the 50th percentile of closes. Channel width
// is ranked against its own 200-bar history to flag expansion vs compression. Breakouts only
// fire when width is in the expansion half — a quiet-channel breakout is filtered out.
indicator("Donchian Quantile Channel [forexobroker]", shorttitle="DQC [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc = "Channel"
string g_sig  = "Signal Logic"
string g_filt = "Filters"
string g_vis  = "Visual"

int   i_len      = input.int(50,   "Quantile Lookback N",    minval=10, maxval=300, group=g_calc, tooltip="Window for the upper/middle/lower percentiles.")
int   i_upQ      = input.int(90,   "Upper Percentile",       minval=60, maxval=99, group=g_calc)
int   i_midQ     = input.int(50,   "Middle Percentile",      minval=20, maxval=80, group=g_calc)
int   i_lowQ     = input.int(10,   "Lower Percentile",       minval=1,  maxval=40, group=g_calc)
int   i_widthLen = input.int(200,  "Width Rank Lookback",    minval=50, maxval=500, group=g_calc, tooltip="Width is percentile-ranked over this window for the expansion filter.")
float i_widthMin = input.float(20, "Min Width Rank %",       minval=0,  maxval=99, group=g_sig, tooltip="Breakouts require width rank above this percentile (range expansion).")
int   i_cooldown = input.int(5,    "Cooldown Bars",          minval=1,  maxval=80, group=g_sig)
bool  i_useSess  = input.bool(false,"Restrict to Session",                          group=g_filt)
string i_sess    = input.session("0000-2400","Session Window",                      group=g_filt)
bool  i_showFill = input.bool(true,"Show Gradient Fill",                            group=g_vis)
bool  i_showTable= input.bool(true,"Show Dashboard",                                group=g_vis)
bool  i_showGlow = input.bool(true,"Show 3-Layer Glow",                             group=g_vis)
color i_buyColor = input.color(#4ade80, "Buy Color",                                group=g_vis)
color i_sellColor= input.color(#f472b6, "Sell Color",                               group=g_vis)
color i_midColor = input.color(#94a3b8, "Spine Color",                              group=g_vis)
color i_dashBg   = input.color(color.new(#0c1810, 16), "Dashboard BG",              group=g_vis)

color c_white = #ffffff

float upper  = ta.percentile_nearest_rank(high,  i_len, i_upQ)
float middle = ta.percentile_nearest_rank(close, i_len, i_midQ)
float lower  = ta.percentile_nearest_rank(low,   i_len, i_lowQ)

float width      = upper - lower
float widthRank  = ta.percentrank(width, i_widthLen)

bool  inSession  = not i_useSess or not na(time(timeframe.period, i_sess))
bool  expansion  = widthRank >= i_widthMin

bool  brokeUp    = ta.crossover(close, upper)
bool  brokeDown  = ta.crossunder(close, lower)

var int posState      = 0
var int lastSignalBar = 0
bool cooldownOk = (bar_index - lastSignalBar) >= i_cooldown
bool confirmed  = barstate.isconfirmed

bool buySignal  = brokeUp   and expansion and inSession and posState <= 0 and cooldownOk and confirmed
bool sellSignal = brokeDown and expansion and inSession and posState >= 0 and cooldownOk and confirmed
if buySignal
    posState := 1
    lastSignalBar := bar_index
if sellSignal
    posState := -1
    lastSignalBar := bar_index

plot(upper,  "Upper",  color=color.new(i_buyColor, 0),  linewidth=2)
plot(middle, "Spine",  color=color.new(i_midColor, 20), linewidth=1)
plot(lower,  "Lower",  color=color.new(i_sellColor, 0), linewidth=2)

p_upper  = plot(upper,  display=display.none)
p_middle = plot(middle, display=display.none)
p_lower  = plot(lower,  display=display.none)
fill(p_upper,  p_middle, color=i_showFill ? color.new(i_buyColor,  88) : na, title="Upper Fill")
fill(p_middle, p_lower,  color=i_showFill ? color.new(i_sellColor, 88) : na, title="Lower Fill")

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.circle, location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.circle, location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy",         shape.circle, location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="DQC", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.circle, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.circle, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell",        shape.circle, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="DQC", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(expansion ? color.new(i_buyColor, 96) : color.new(color.gray, 96))

string regimeText = expansion ? "EXPANSION" : "COMPRESSION"
color  regimeCol  = expansion ? i_buyColor : color.gray
string posText    = close > middle ? "ABOVE SPINE" : close < middle ? "BELOW SPINE" : "AT SPINE"
color  posCol     = close > middle ? i_buyColor : close < middle ? i_sellColor : color.gray

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=i_dashBg, border_color=color.new(i_buyColor, 55), border_width=1)
    table.cell(dash, 0, 0, "Donchian Quantile Channel", text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                     text_color=color.new(i_buyColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "Upper Q",                   text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(upper,  "#.#####"), text_color=i_buyColor,  text_size=size.small)
    table.cell(dash, 0, 2, "Spine Q",                   text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(middle, "#.#####"), text_color=c_white,     text_size=size.small)
    table.cell(dash, 0, 3, "Lower Q",                   text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(lower,  "#.#####"), text_color=i_sellColor, text_size=size.small)
    table.cell(dash, 0, 4, "Width Rank %",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(widthRank, "#.#"), text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 5, "Regime",                    text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, regimeText,                  text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 6, "Spine Position",            text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posText,                     text_color=posCol, text_size=size.small)
    table.cell(dash, 0, 7, "State",                     text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"DQC","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"DQC","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                              "DQC Buy",            "DQC quantile breakout long on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                             "DQC Sell",           "DQC quantile breakout short on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,                "DQC Any Signal",     "Any DQC signal on {{ticker}} {{interval}}")
alertcondition(brokeUp,                                "DQC Upper Break",    "Close crossed upper quantile on {{ticker}} {{interval}}")
alertcondition(brokeDown,                              "DQC Lower Break",    "Close crossed lower quantile on {{ticker}} {{interval}}")
alertcondition(ta.crossover(close, middle),            "DQC Spine Cross Up", "Close crossed spine up on {{ticker}} {{interval}}")
alertcondition(ta.crossunder(close, middle),           "DQC Spine Cross Dn", "Close crossed spine down on {{ticker}} {{interval}}")
alertcondition(expansion and not expansion[1],         "DQC Expansion",      "Channel entered expansion regime on {{ticker}} {{interval}}")
alertcondition(not expansion and expansion[1],         "DQC Compression",    "Channel entered compression regime on {{ticker}} {{interval}}")
alertcondition(widthRank >= 90,                        "DQC Extreme Width",  "Width rank above 90 on {{ticker}} {{interval}}")
alertcondition(widthRank <= 10,                        "DQC Extreme Squeeze","Width rank below 10 on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,                "DQC Webhook JSON",   "{\"action\":\"signal\",\"indicator\":\"DQC\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
