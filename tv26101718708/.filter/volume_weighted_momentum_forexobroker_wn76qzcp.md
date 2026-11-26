# Volume Weighted Momentum [forexobroker]

- url: https://www.tradingview.com/script/wn76Qzcp-Volume-Weighted-Momentum-forexobroker/
- type: indicator
- pine_id: PUB;258db7bb5f884049a9e184e9d6883d8c
- version: 1.0

## Description

Volume Weighted Momentum [forexobroker] is a rate-of-change oscillator weighted by each bar's volume: moves made on heavy volume count more than moves on thin volume. The oscillator's zero line defines a momentum regime, and an ATR-normalised reading grades its strength. The regime sets the bias and a reclaim-EMA cross times entries, or a raw zero-line cross in Cross-Only mode.

🔶 ALGORITHM

1. ROC = close - close[ROC Length].
2. Volume-weighted ROC over the VW Average Window: VWM = sum(ROC * volume) / sum(volume).
3. ATR-normalised reading vwmN = VWM / ATR for strength grading.
4. Regime: VWM > 0 = momentum up (+1), VWM < 0 = momentum down (-1).
5. A magnitude gate optionally requires abs(VWM) >= Min |VWM| x ATR before entries are allowed.
6. A reclaim EMA times the entry: a confirmed close-cross in the regime direction triggers (or, in Zero-Cross-Only Mode, the VWM zero-line cross itself). Cooldown, bar-close confirmation and a position-lock finalise the signal so it never repaints intrabar.

🔶 SIGNAL LOGIC

- Buy: in-session AND magnitude OK AND (Zero-Cross-Only: VWM crosses above zero) OR (regime up AND close crosses over the reclaim EMA) AND position not already long AND cooldown elapsed AND barstate.isconfirmed.
- Sell: in-session AND magnitude OK AND (Zero-Cross-Only: VWM crosses below zero) OR (regime down AND close crosses under the reclaim EMA) AND position not already short AND cooldown elapsed AND barstate.isconfirmed.
Only fires while the volume-weighted momentum magnitude clears the optional ATR gate.

🔶 INPUTS

- Momentum group: ROC Length over which the rate of change is measured (default 10).
- Momentum group: VW Average Window the volume-weighted ROC is averaged over (default 20).
- Momentum group: Min |VWM| x ATR, an optional ATR-unit magnitude gate (default 0.0).
- Momentum group: ATR Length used for normalisation and the gate (default 14).
- Signal Logic group: Entry Reclaim EMA whose close-cross times entries (default 9).
- Signal Logic group: Zero-Cross-Only Mode and Cooldown Bars between signals (default 5).
- Filters group: optional session restriction with a configurable window (default off).
- Visual group: dashboard, 3-layer glow, reclaim-EMA plot and buy/sell colors (dashboard default on).

🔶 ALERTS

VWM Buy, VWM Sell, VWM Any Signal, VWM Zero Up, VWM Zero Down, VWM Bull Regime, VWM Bear Regime, VWM EMA Up, VWM EMA Down, VWM Strong, VWM Regime Flip, VWM Any Zero Cross, VWM Webhook JSON.

🔶 LIMITATIONS

- Needs warm-up bars before the ROC lookback and VW averaging window are fully populated.
- Volume-based, so it requires a real volume feed; on forex it falls back to broker tick-volume, which is a proxy only.
- Volume weighting reflects participation, not true bid/ask order flow.
- ATR-normalisation requires a valid ATR; very early bars may read zero magnitude.
- Defaults are tuned for liquid instruments and intraday/swing timeframes; thin symbols may need a longer averaging window.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Volume-Weighted Momentum. A rate-of-change is weighted by each bar's volume and
// averaged over a window: moves made on heavy volume count more than moves on thin volume.
// The resulting oscillator's zero line defines a momentum regime; an ATR-normalised reading
// grades its strength. The regime sets the bias and a reclaim-EMA cross times entries (or a
// raw zero-line cross in Cross-Only mode). Non-repainting, bar-close, volume-adaptive.
indicator("Volume Weighted Momentum [forexobroker]", shorttitle="VWM [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc = "Momentum"
string g_sig  = "Signal Logic"
string g_filt = "Filters"
string g_vis  = "Visual"

int   i_roc     = input.int(10,   "ROC Length",            minval=1,  maxval=60, group=g_calc, tooltip="Bars over which the rate of change is measured.")
int   i_vwWin   = input.int(20,   "VW Average Window",     minval=3,  maxval=100, group=g_calc, tooltip="Window the volume-weighted ROC is averaged over.")
float i_minMag  = input.float(0.0,"Min |VWM| x ATR",       minval=0.0, maxval=3.0, step=0.05, group=g_calc, tooltip="Optional minimum |VWM| (ATR units) to allow entries.")
int   i_atrLen  = input.int(14,   "ATR Length",            minval=5,  maxval=50, group=g_calc)
int   i_emaLen  = input.int(9,    "Entry Reclaim EMA",     minval=2,  maxval=50, group=g_sig, tooltip="After VWM sets a bias, a close-cross of this EMA in that direction times the entry.")
bool  i_xOnly   = input.bool(false,"Zero-Cross-Only Mode",                        group=g_sig, tooltip="On = fire on the VWM zero-line cross itself. Off = EMA reclaim inside the active VWM bias (more signals).")
int   i_cooldown= input.int(5,    "Cooldown Bars",         minval=1,  maxval=40, group=g_sig)
bool  i_useSess = input.bool(false,"Restrict to Session",                         group=g_filt)
string i_sess   = input.session("0000-2400","Session Window",                     group=g_filt)
bool  i_showTable=input.bool(true,"Show Dashboard",                                group=g_vis)
bool  i_showGlow= input.bool(true,"Show 3-Layer Glow",                             group=g_vis)
bool  i_showEma = input.bool(true,"Show Reclaim EMA",                              group=g_vis)
color i_buyColor= input.color(#80ffdb,"Buy Color",                                 group=g_vis)
color i_sellColor=input.color(#ff7096,"Sell Color",                                group=g_vis)
color i_dashBg  = input.color(color.new(#04161a, 14),"Dashboard BG",              group=g_vis)

color c_white = #ffffff

float atr   = nz(ta.atr(i_atrLen), 0.0)
float roc   = close - close[i_roc]
float vw    = nz(volume, 0.0)
float num   = math.sum(roc * vw, i_vwWin)
float den   = math.sum(vw, i_vwWin)
float vwm   = den > 0 ? num / den : 0.0
float vwmN  = atr > 0 ? vwm / atr : 0.0
bool  inSession = not i_useSess or not na(time(timeframe.period, i_sess))

int regime = vwm > 0 ? 1 : vwm < 0 ? -1 : 0
bool magOk = atr <= 0 or math.abs(vwm) >= i_minMag * atr
float emaFast = ta.ema(close, i_emaLen)
bool  crossUp = ta.crossover(close, emaFast)
bool  crossDn = ta.crossunder(close, emaFast)
bool zUp = ta.crossover(vwm, 0.0)
bool zDn = ta.crossunder(vwm, 0.0)
bool entryUp   = inSession and magOk and (i_xOnly ? zUp : (regime ==  1 and crossUp))
bool entryDown = inSession and magOk and (i_xOnly ? zDn : (regime == -1 and crossDn))

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

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy",         shape.triangleup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="VWM", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.triangledown, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.triangledown, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell",        shape.triangledown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="VWM", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(regime == 1 ? color.new(i_buyColor, 94) : regime == -1 ? color.new(i_sellColor, 94) : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=i_dashBg, border_color=color.new(i_buyColor, 50), border_width=1)
    string rt = regime == 1 ? "MOMENTUM UP" : regime == -1 ? "MOMENTUM DOWN" : "FLAT"
    color  rc = regime == 1 ? i_buyColor : regime == -1 ? i_sellColor : color.gray
    table.cell(dash, 0, 0, "VW Momentum",           text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                 text_color=color.new(i_buyColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "Regime",                text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, rt,                      text_color=rc, text_size=size.small)
    table.cell(dash, 0, 2, "VWM",                   text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(vwm, "#.#####"), text_color=vwm >= 0 ? i_buyColor : i_sellColor, text_size=size.small)
    table.cell(dash, 0, 3, "VWM / ATR",             text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(vwmN, "0.00"), text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 4, "Mag OK",                text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, magOk ? "YES" : "NO",    text_color=magOk ? i_buyColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 5, "ROC / Win",             text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(i_roc) + " / " + str.tostring(i_vwWin), text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 6, "Position",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"VWM","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"VWM","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                          "VWM Buy",            "VW-momentum long on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                         "VWM Sell",           "VW-momentum short on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,            "VWM Any Signal",     "Any VWM signal on {{ticker}} {{interval}}")
alertcondition(zUp,                                "VWM Zero Up",        "VWM crossed above zero on {{ticker}} {{interval}}")
alertcondition(zDn,                                "VWM Zero Down",      "VWM crossed below zero on {{ticker}} {{interval}}")
alertcondition(regime == 1 and regime[1] != 1,     "VWM Bull Regime",    "Momentum regime turned up on {{ticker}} {{interval}}")
alertcondition(regime == -1 and regime[1] != -1,   "VWM Bear Regime",    "Momentum regime turned down on {{ticker}} {{interval}}")
alertcondition(crossUp,                            "VWM EMA Up",         "Reclaim EMA crossed up on {{ticker}} {{interval}}")
alertcondition(crossDn,                            "VWM EMA Down",       "Reclaim EMA crossed down on {{ticker}} {{interval}}")
alertcondition(math.abs(vwm) >= i_minMag * atr,    "VWM Strong",         "VW momentum magnitude is strong on {{ticker}} {{interval}}")
alertcondition(regime != regime[1],                "VWM Regime Flip",    "VW momentum regime flipped on {{ticker}} {{interval}}")
alertcondition(zUp or zDn,                         "VWM Any Zero Cross", "Any VWM zero-line cross on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,            "VWM Webhook JSON",   "{\"action\":\"signal\",\"indicator\":\"VWM\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
