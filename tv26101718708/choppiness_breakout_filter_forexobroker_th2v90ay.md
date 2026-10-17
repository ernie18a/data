# Choppiness Breakout Filter [forexobroker]

- url: https://www.tradingview.com/script/tH2V90Ay-Choppiness-Breakout-Filter-forexobroker/
- type: indicator
- pine_id: PUB;b67a71cdd54a42319a822f60535d8d55
- version: 1.0

## Description

Choppiness Breakout Filter [forexobroker] gates Donchian breakouts behind the Choppiness Index regime so that breaks are only taken when the market is trending, not ranging. The unique angle is that the same Donchian break is treated as a tradable signal in a low-CI trending regime but suppressed as noise when CI is high and the tape is choppy.

🔶 ALGORITHM

1. Compute the Choppiness Index over the CI length: 100 x log10(sum of true range / (highest high - lowest low)) / log10(length). Low CI = directional/trending, high CI = ranging/chop.
2. Classify regime: trending when CI is below the Trend CI threshold; choppy when CI is above the Chop CI threshold.
3. Build a Donchian channel from the prior bar's highest high and lowest low over the breakout lookback.
4. A trend-filtered break is up when regime is trending AND close exceeds the Donchian high; down when trending AND close is below the Donchian low. An up-break sets bias +1, a down-break sets bias -1, and a choppy regime resets bias to flat.
5. Entry timing: in Break-Only mode the signal is the filtered break bar itself; otherwise a close crossover (long) or crossunder (short) of the reclaim EMA in the prevailing bias direction times the entry. Cooldown, position-lock, and bar-close confirmation apply. Non-repainting.

🔶 SIGNAL LOGIC

- Buy: in-session AND ((Break-Only: trending up-break) OR (bias = +1 AND close crosses over the reclaim EMA)) AND position not already long AND cooldown elapsed AND barstate.isconfirmed (then position locks long).
- Sell: in-session AND ((Break-Only: trending down-break) OR (bias = -1 AND close crosses under the reclaim EMA)) AND position not already short AND cooldown elapsed AND barstate.isconfirmed (then position locks short).
- Only fires when the Choppiness Index regime gate is satisfied (breakouts blocked while choppy).

🔶 INPUTS

- Choppiness group: bars the Choppiness Index is computed over; default Choppiness Length 14.
- Trend gate: CI level below which breakouts are enabled; default Trend CI Threshold 45.0.
- Chop gate: CI level above which breakouts are blocked and bias resets; default Chop CI Threshold 61.8.
- Breakout lookback: Donchian length the close must break; default Breakout Lookback 20.
- Volatility reference: ATR length for the dashboard; default ATR Length 14.
- Signal Logic group: entry reclaim EMA, break-only mode, cooldown; default Entry Reclaim EMA 9.
- Cooldown: minimum bars between signals; default Cooldown Bars 5.
- Filters group: optional session restriction and session window; default Restrict to Session off.
- Visual group: Donchian display, dashboard, 3-layer glow, buy/sell colors, dashboard background.

🔶 ALERTS

CBF Buy, CBF Sell, CBF Any Signal, CBF Break Up, CBF Break Down, CBF Trend On, CBF Chop On, CBF EMA Up, CBF EMA Down, CBF CI Trend Cross, CBF Bias Bull, CBF Bias Bear, CBF Webhook JSON.

🔶 LIMITATIONS

- The Choppiness Index needs its full window to stabilise, so the first CI-length bars are warm-up and the regime read is unreliable there.
- The Donchian channel uses the prior bar's extremes, so the broken level is fixed one bar before the break confirms.
- The CI regime gate filters but does not predict; a trending classification describes recent directionality, not future follow-through.
- Default CI thresholds are tuned for liquid instruments; very low or very high volatility regimes may need re-tuning.
- Entries confirm on bar close, so the break or reclaim cross is acknowledged with one-bar lag versus intrabar price.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Choppiness Breakout Filter. The Choppiness Index measures how directional the last
// N bars were (low CI = trending, high CI = ranging/chop). Breakout entries are GATED to the
// trending regime only: a Donchian break taken while CI is below the trend threshold tends to
// follow through, while the same break in chop is noise. The break sets a bias; a reclaim-EMA
// cross times entries (or the raw break in Break-Only mode). Non-repainting, bar-close.
indicator("Choppiness Breakout Filter [forexobroker]", shorttitle="CBF [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc = "Choppiness"
string g_sig  = "Signal Logic"
string g_filt = "Filters"
string g_vis  = "Visual"

int   i_ciLen   = input.int(14,   "Choppiness Length",     minval=5,  maxval=100, group=g_calc, tooltip="Bars the Choppiness Index is computed over.")
float i_trendCI = input.float(45.0,"Trend CI Threshold",   minval=20.0, maxval=61.8, step=0.5, group=g_calc, tooltip="CI below this = trending regime (breakouts enabled).")
float i_chopCI  = input.float(61.8,"Chop CI Threshold",    minval=50.0, maxval=80.0, step=0.5, group=g_calc, tooltip="CI above this = ranging/chop (breakouts blocked).")
int   i_brkLen  = input.int(20,   "Breakout Lookback",     minval=3,  maxval=100, group=g_calc, tooltip="Donchian length the close must break.")
int   i_atrLen  = input.int(14,   "ATR Length",            minval=5,  maxval=50, group=g_calc)
int   i_emaLen  = input.int(9,    "Entry Reclaim EMA",     minval=2,  maxval=50, group=g_sig, tooltip="After a filtered break sets a bias, a close-cross of this EMA in that direction times the entry.")
bool  i_brkOnly = input.bool(false,"Break-Only Mode",                              group=g_sig, tooltip="On = fire on the breakout bar itself. Off = EMA reclaim inside the active break bias (more signals).")
int   i_cooldown= input.int(5,    "Cooldown Bars",         minval=1,  maxval=40, group=g_sig)
bool  i_useSess = input.bool(false,"Restrict to Session",                          group=g_filt)
string i_sess   = input.session("0000-2400","Session Window",                      group=g_filt)
bool  i_showLvl = input.bool(true,"Show Donchian",                                  group=g_vis)
bool  i_showTable=input.bool(true,"Show Dashboard",                                 group=g_vis)
bool  i_showGlow= input.bool(true,"Show 3-Layer Glow",                              group=g_vis)
color i_buyColor= input.color(#73d2de,"Buy Color",                                  group=g_vis)
color i_sellColor=input.color(#ff8fab,"Sell Color",                                 group=g_vis)
color i_dashBg  = input.color(color.new(#08131a, 14),"Dashboard BG",               group=g_vis)

color c_white = #ffffff

float atr   = nz(ta.atr(i_atrLen), 0.0)
float trSum = math.sum(ta.tr(true), i_ciLen)
float hh    = ta.highest(high, i_ciLen)
float ll    = ta.lowest(low,  i_ciLen)
float den   = hh - ll
float ci    = den > 0 ? 100.0 * math.log10(trSum / den) / math.log10(i_ciLen) : 50.0
bool  trending = ci < i_trendCI
bool  choppy   = ci > i_chopCI
bool  inSession = not i_useSess or not na(time(timeframe.period, i_sess))

float donHi = ta.highest(high, i_brkLen)[1]
float donLo = ta.lowest(low,  i_brkLen)[1]
bool brkUp = trending and close > donHi
bool brkDn = trending and close < donLo

var int bias = 0
if brkUp
    bias := 1
if brkDn
    bias := -1
if choppy
    bias := 0
float emaFast = ta.ema(close, i_emaLen)
bool  crossUp = ta.crossover(close, emaFast)
bool  crossDn = ta.crossunder(close, emaFast)
bool entryUp   = inSession and (i_brkOnly ? brkUp : (bias ==  1 and crossUp))
bool entryDown = inSession and (i_brkOnly ? brkDn : (bias == -1 and crossDn))

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

plot(i_showLvl ? donHi : na, "Donchian Hi", color=color.new(i_sellColor, 55), linewidth=1)
plot(i_showLvl ? donLo : na, "Donchian Lo", color=color.new(i_buyColor, 55), linewidth=1)

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.arrowup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.arrowup,   location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy",         shape.arrowup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="CBF", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.arrowdown, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.arrowdown, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell",        shape.arrowdown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="CBF", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(trending ? color.new(i_buyColor, 92) : choppy ? color.new(color.gray, 88) : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=i_dashBg, border_color=color.new(i_buyColor, 50), border_width=1)
    string rt = trending ? "TRENDING" : choppy ? "CHOPPY" : "TRANSITION"
    color  rc = trending ? i_buyColor : choppy ? color.gray : color.silver
    table.cell(dash, 0, 0, "Choppiness Breakout",   text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                 text_color=color.new(i_buyColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "Regime",                text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, rt,                      text_color=rc, text_size=size.small)
    table.cell(dash, 0, 2, "CI",                    text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(ci, "0.0"), text_color=trending ? i_buyColor : choppy ? color.gray : color.silver, text_size=size.small)
    table.cell(dash, 0, 3, "Bias",                  text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, bias == 1 ? "LONG" : bias == -1 ? "SHORT" : "FLAT", text_color=bias == 1 ? i_buyColor : bias == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 4, "Donchian",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(donLo, "#.##") + "-" + str.tostring(donHi, "#.##"), text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 5, "ATR",                   text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(atr, "#.#####"), text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 6, "Position",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"CBF","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"CBF","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                          "CBF Buy",            "Filtered breakout long on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                         "CBF Sell",           "Filtered breakout short on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,            "CBF Any Signal",     "Any CBF signal on {{ticker}} {{interval}}")
alertcondition(brkUp,                              "CBF Break Up",       "Trend-filtered up-break on {{ticker}} {{interval}}")
alertcondition(brkDn,                              "CBF Break Down",     "Trend-filtered down-break on {{ticker}} {{interval}}")
alertcondition(trending and not trending[1],       "CBF Trend On",       "Regime turned trending on {{ticker}} {{interval}}")
alertcondition(choppy and not choppy[1],           "CBF Chop On",        "Regime turned choppy on {{ticker}} {{interval}}")
alertcondition(crossUp,                            "CBF EMA Up",         "Reclaim EMA crossed up on {{ticker}} {{interval}}")
alertcondition(crossDn,                            "CBF EMA Down",       "Reclaim EMA crossed down on {{ticker}} {{interval}}")
alertcondition(ta.cross(ci, i_trendCI),            "CBF CI Trend Cross", "CI crossed the trend threshold on {{ticker}} {{interval}}")
alertcondition(bias == 1 and bias[1] != 1,         "CBF Bias Bull",      "Break bias turned bullish on {{ticker}} {{interval}}")
alertcondition(bias == -1 and bias[1] != -1,       "CBF Bias Bear",      "Break bias turned bearish on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,            "CBF Webhook JSON",   "{\"action\":\"signal\",\"indicator\":\"CBF\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
