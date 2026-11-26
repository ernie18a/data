# Accumulation Distribution Wave [forexobroker]

- url: https://www.tradingview.com/script/XsUprPyD-Accumulation-Distribution-Wave-forexobroker/
- type: indicator
- pine_id: PUB;6a0db32a30364af8949e3ce3297006d5
- version: 1.0

## Description

Accumulation Distribution Wave [forexobroker] tracks the classic Accumulation/Distribution line and turns its slope into an accumulation-vs-distribution wave regime. It also watches for a regular price/A-D divergence that flags hidden exhaustion. The wave regime sets the bias and a reclaim-EMA cross times entries, optionally gated to bars that show a confirming divergence.

🔶 ALGORITHM

1. Money flow multiplier = ((close-low) - (high-close)) / range, in [-1, +1].
2. A/D line accumulates money-flow-multiplier * volume bar by bar.
3. Wave = A/D minus an EMA of A/D (A/D Wave EMA). Wave > Min Wave Slope = accumulation (+1), wave < -Min Wave Slope = distribution (-1).
4. Divergence: over the Divergence Lookback, price at a new high while A/D is not = bearish; price at a new low while A/D is not = bullish.
5. A reclaim EMA times the entry: a confirmed close-cross in the wave-regime direction triggers, optionally requiring a same-side divergence (Divergence-Only Mode).
6. Cooldown, bar-close confirmation and a position-lock finalise the signal so it never repaints intrabar.

🔶 SIGNAL LOGIC

- Buy: in-session AND wave regime = accumulation AND close crosses over the reclaim EMA AND (Divergence-Only off OR bullish divergence present) AND position not already long AND cooldown elapsed AND barstate.isconfirmed.
- Sell: in-session AND wave regime = distribution AND close crosses under the reclaim EMA AND (Divergence-Only off OR bearish divergence present) AND position not already short AND cooldown elapsed AND barstate.isconfirmed.
Only fires while the A/D wave regime is non-flat.

🔶 INPUTS

- A/D group: A/D Wave EMA; A/D minus this EMA defines the wave (default 21).
- A/D group: Divergence Lookback comparing price vs A/D extremes (default 20).
- A/D group: Min Wave Slope, an optional minimum absolute wave in A/D units (default 0.0).
- A/D group: ATR Length for the reference table (default 14).
- Signal Logic group: Entry Reclaim EMA whose close-cross times entries (default 9).
- Signal Logic group: Divergence-Only Mode and Cooldown Bars between signals (default 5).
- Filters group: optional session restriction with a configurable window (default off).
- Visual group: dashboard, 3-layer glow, reclaim-EMA plot and buy/sell colors (dashboard default on).

🔶 ALERTS

ADW Buy, ADW Sell, ADW Any Signal, ADW Accum On, ADW Distrib On, ADW Bull Div, ADW Bear Div, ADW EMA Up, ADW EMA Down, ADW Wave Zero, ADW Any Div, ADW Regime Flip, ADW Webhook JSON.

🔶 LIMITATIONS

- The A/D line is a running cumulative sum, so absolute values depend on chart history length and warm-up.
- Volume-based, so it requires a real volume feed; on forex it falls back to broker tick-volume, which is a proxy only.
- Money-flow-multiplier signing is an estimate of accumulation, not true bid/ask delta.
- Divergence detection uses lookback extremes and can lag at sharp turns.
- Defaults are tuned for liquid instruments; thin symbols may need a longer wave EMA.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Accumulation Distribution Wave. The classic A/D line accumulates each bar's money
// flow multiplier x volume. Its slope (A/D minus a smoothed A/D) defines an accumulation vs
// distribution WAVE regime. A regular divergence between price and the A/D line (price makes a
// higher high while A/D does not, or the mirror) flags hidden exhaustion. The wave regime sets
// the bias; a reclaim-EMA cross times entries. Non-repainting, bar-close, volume-driven.
indicator("Accumulation Distribution Wave [forexobroker]", shorttitle="ADW [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc = "A/D"
string g_sig  = "Signal Logic"
string g_filt = "Filters"
string g_vis  = "Visual"

int   i_adEma   = input.int(21,   "A/D Wave EMA",          minval=3,  maxval=100, group=g_calc, tooltip="A/D minus this EMA of A/D defines the accumulation/distribution wave.")
int   i_divLb   = input.int(20,   "Divergence Lookback",   minval=5,  maxval=80, group=g_calc, tooltip="Bars compared for price vs A/D divergence.")
float i_slopeK  = input.float(0.0,"Min Wave Slope",        minval=0.0, maxval=5.0, step=0.1, group=g_calc, tooltip="Optional minimum |wave| (in A/D units, 0 = any).")
int   i_atrLen  = input.int(14,   "ATR Length",            minval=5,  maxval=50, group=g_calc)
int   i_emaLen  = input.int(9,    "Entry Reclaim EMA",     minval=2,  maxval=50, group=g_sig, tooltip="After the wave sets a bias, a close-cross of this EMA in that direction times the entry.")
bool  i_divOnly = input.bool(false,"Divergence-Only Mode",                        group=g_sig, tooltip="On = only fire when a price/A-D divergence is present in the bias direction.")
int   i_cooldown= input.int(5,    "Cooldown Bars",         minval=1,  maxval=40, group=g_sig)
bool  i_useSess = input.bool(false,"Restrict to Session",                         group=g_filt)
string i_sess   = input.session("0000-2400","Session Window",                     group=g_filt)
bool  i_showTable=input.bool(true,"Show Dashboard",                                group=g_vis)
bool  i_showGlow= input.bool(true,"Show 3-Layer Glow",                             group=g_vis)
bool  i_showEma = input.bool(true,"Show Reclaim EMA",                              group=g_vis)
color i_buyColor= input.color(#00d97e,"Buy Color",                                 group=g_vis)
color i_sellColor=input.color(#e5446d,"Sell Color",                                group=g_vis)
color i_dashBg  = input.color(color.new(#03130c, 14),"Dashboard BG",              group=g_vis)

color c_white = #ffffff

float atr   = nz(ta.atr(i_atrLen), 0.0)
float rngBar= high - low
float mfm   = rngBar > 0 ? ((close - low) - (high - close)) / rngBar : 0.0
var float ad = 0.0
ad := ad + mfm * nz(volume, 0.0)
float adEmaV= ta.ema(ad, i_adEma)
float wave  = ad - adEmaV
bool  inSession = not i_useSess or not na(time(timeframe.period, i_sess))

float pHi = ta.highest(close, i_divLb)
float pLo = ta.lowest(close, i_divLb)
float aHi = ta.highest(ad, i_divLb)
float aLo = ta.lowest(ad, i_divLb)
bool bearDiv = close >= pHi and ad < aHi
bool bullDiv = close <= pLo and ad > aLo

int regime = wave >  i_slopeK ? 1 : wave < -i_slopeK ? -1 : 0
float emaFast = ta.ema(close, i_emaLen)
bool  crossUp = ta.crossover(close, emaFast)
bool  crossDn = ta.crossunder(close, emaFast)
bool gateUp = not i_divOnly or bullDiv
bool gateDn = not i_divOnly or bearDiv
bool entryUp   = inSession and regime ==  1 and crossUp and gateUp
bool entryDown = inSession and regime == -1 and crossDn and gateDn

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

plot(i_showEma ? emaFast : na, "Reclaim EMA", color=regime == 1 ? color.new(i_buyColor, 30) : regime == -1 ? color.new(i_sellColor, 30) : color.new(color.gray, 50), linewidth=2)

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.circle, location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.circle, location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy",         shape.circle, location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="ADW", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.circle, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.circle, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell",        shape.circle, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="ADW", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(regime == 1 ? color.new(i_buyColor, 94) : regime == -1 ? color.new(i_sellColor, 94) : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=i_dashBg, border_color=color.new(i_buyColor, 50), border_width=1)
    string rt = regime == 1 ? "ACCUMULATION" : regime == -1 ? "DISTRIBUTION" : "FLAT WAVE"
    color  rc = regime == 1 ? i_buyColor : regime == -1 ? i_sellColor : color.gray
    table.cell(dash, 0, 0, "A/D Wave",              text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                 text_color=color.new(i_buyColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "Wave Regime",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, rt,                      text_color=rc, text_size=size.small)
    table.cell(dash, 0, 2, "Wave",                  text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(wave, "#"), text_color=wave >= 0 ? i_buyColor : i_sellColor, text_size=size.small)
    table.cell(dash, 0, 3, "Divergence",            text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, bullDiv ? "BULL" : bearDiv ? "BEAR" : "-", text_color=bullDiv ? i_buyColor : bearDiv ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 4, "A/D",                   text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(ad, "#"),   text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 5, "ATR",                   text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(atr, "#.#####"), text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 6, "Position",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"ADW","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"ADW","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                          "ADW Buy",            "Accumulation-wave long on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                         "ADW Sell",           "Distribution-wave short on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,            "ADW Any Signal",     "Any ADW signal on {{ticker}} {{interval}}")
alertcondition(regime == 1 and regime[1] != 1,     "ADW Accum On",       "Accumulation wave began on {{ticker}} {{interval}}")
alertcondition(regime == -1 and regime[1] != -1,   "ADW Distrib On",     "Distribution wave began on {{ticker}} {{interval}}")
alertcondition(bullDiv,                            "ADW Bull Div",       "Bullish A/D divergence on {{ticker}} {{interval}}")
alertcondition(bearDiv,                            "ADW Bear Div",       "Bearish A/D divergence on {{ticker}} {{interval}}")
alertcondition(crossUp,                            "ADW EMA Up",         "Reclaim EMA crossed up on {{ticker}} {{interval}}")
alertcondition(crossDn,                            "ADW EMA Down",       "Reclaim EMA crossed down on {{ticker}} {{interval}}")
alertcondition(ta.cross(wave, 0),                  "ADW Wave Zero",      "A/D wave crossed zero on {{ticker}} {{interval}}")
alertcondition(bullDiv or bearDiv,                 "ADW Any Div",        "Any A/D divergence on {{ticker}} {{interval}}")
alertcondition(regime != regime[1],                "ADW Regime Flip",    "A/D wave regime flipped on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,            "ADW Webhook JSON",   "{\"action\":\"signal\",\"indicator\":\"ADW\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
