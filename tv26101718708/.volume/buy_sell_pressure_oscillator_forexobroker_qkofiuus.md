# Buy Sell Pressure Oscillator [forexobroker]

- url: https://www.tradingview.com/script/qkOFiUus-Buy-Sell-Pressure-Oscillator-forexobroker/
- type: indicator
- pine_id: PUB;2f4a4ba7bcc3498a88c496d2b92ffabb
- version: 1.0

## Description

Buy Sell Pressure Oscillator [forexobroker] splits each bar's volume into estimated buy volume and estimated sell volume using where price closed within the bar's range, then smooths the net difference into a normalised -100..100 pressure oscillator. The oscillator's sign sets a pressure regime; a reclaim-EMA cross times entries, or the raw zero-line cross in Zero-Cross-Only mode. It turns raw volume into a directional read of who is in control.

🔶 ALGORITHM

1. Compute the close position in range: (close - low) / (high - low), defaulting to 0.5 on a zero-range bar.
2. Estimate buy volume = volume x close-position, and sell volume = volume x (1 - close-position).
3. Take the net buy-minus-sell volume and smooth it with an EMA over the Pressure Smoothing length.
4. Normalise the smoothed net by average volume over the Volume Norm Length and scale to a -100..100 oscillator.
5. The oscillator sign sets the pressure regime (positive = buy, negative = sell); |oscillator| above Strong Pressure flags a strong regime.
6. Inside the active regime, a close-cross of the Entry Reclaim EMA times the entry; in Zero-Cross-Only mode the oscillator's zero-line cross fires instead.

🔶 SIGNAL LOGIC

- Buy: in-session AND regime tradable AND (Zero-Cross-Only: oscillator crosses above zero; else buy regime AND close crosses over reclaim EMA) AND not already long AND cooldown elapsed AND barstate.isconfirmed (position-locked).
- Sell: in-session AND regime tradable AND (Zero-Cross-Only: oscillator crosses below zero; else sell regime AND close crosses under reclaim EMA) AND not already short AND cooldown elapsed AND barstate.isconfirmed (position-locked).
Only fires when the pressure regime is tradable (or strong, if Require Strong Pressure is on).

🔶 INPUTS

- Pressure: EMA smoothing applied to net buy-minus-sell volume; default Pressure Smoothing = 14.
- Pressure: average-volume length the pressure is normalised by; default Volume Norm Length = 20.
- Pressure: Strong Pressure threshold on the |oscillator|; default Strong Pressure = 25.0.
- Pressure: ATR length for context; default ATR Length = 14.
- Signal Logic: Entry Reclaim EMA that times the entry inside the regime; default Entry Reclaim EMA = 9.
- Signal Logic: Zero-Cross-Only mode and Require Strong Pressure toggles; both default off.
- Signal Logic: Cooldown bars between signals; default Cooldown Bars = 5.
- Filters / Visual: optional session window, dashboard, 3-layer glow, reclaim-EMA plot, and colors; dashboard default on.

🔶 ALERTS

BSP Buy, BSP Sell, BSP Any Signal, BSP Zero Up, BSP Zero Down, BSP Strong Buy, BSP Strong Sell, BSP EMA Up, BSP EMA Down, BSP Bull Regime, BSP Bear Regime, BSP Any Zero Cross, BSP Webhook JSON.

🔶 LIMITATIONS

- The buy/sell split is an estimate from close-in-range, not true order-flow tick data.
- Requires a real volume feed; symbols with no or synthetic volume produce a meaningless oscillator.
- Needs warm-up bars for the smoothing EMA and the volume normalisation window.
- Strong-pressure default is tuned for liquid instruments; thin markets may need a different threshold.
- The reclaim EMA adds deliberate entry lag versus the raw zero-cross, by design.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Buy Sell Pressure Oscillator. Each bar's volume is split into estimated BUY volume
// (volume x close-position-in-range) and SELL volume (the complement). Their difference is
// smoothed into a net-pressure oscillator and normalised by average volume to a -100..100
// scale. The oscillator's sign sets a pressure regime; a reclaim-EMA cross times entries, or
// the raw zero-line cross in Cross-Only mode. Non-repainting, bar-close, volume-driven.
indicator("Buy Sell Pressure Oscillator [forexobroker]", shorttitle="BSP [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc = "Pressure"
string g_sig  = "Signal Logic"
string g_filt = "Filters"
string g_vis  = "Visual"

int   i_smooth  = input.int(14,   "Pressure Smoothing",    minval=2,  maxval=60, group=g_calc, tooltip="EMA length applied to net buy-minus-sell volume.")
int   i_volMa   = input.int(20,   "Volume Norm Length",    minval=5,  maxval=100, group=g_calc, tooltip="Average volume the pressure is normalised by.")
float i_strong  = input.float(25.0,"Strong Pressure",      minval=5.0, maxval=90.0, step=5.0, group=g_calc, tooltip="|oscillator| above this = strong-pressure regime.")
int   i_atrLen  = input.int(14,   "ATR Length",            minval=5,  maxval=50, group=g_calc)
int   i_emaLen  = input.int(9,    "Entry Reclaim EMA",     minval=2,  maxval=50, group=g_sig, tooltip="After pressure sets a bias, a close-cross of this EMA in that direction times the entry.")
bool  i_xOnly   = input.bool(false,"Zero-Cross-Only Mode",                        group=g_sig, tooltip="On = fire on the pressure zero-line cross. Off = EMA reclaim inside the active pressure bias (more signals).")
bool  i_strongOnly=input.bool(false,"Require Strong Pressure",                    group=g_sig, tooltip="On = only trade when |oscillator| exceeds the strong threshold.")
int   i_cooldown= input.int(5,    "Cooldown Bars",         minval=1,  maxval=40, group=g_sig)
bool  i_useSess = input.bool(false,"Restrict to Session",                         group=g_filt)
string i_sess   = input.session("0000-2400","Session Window",                     group=g_filt)
bool  i_showTable=input.bool(true,"Show Dashboard",                                group=g_vis)
bool  i_showGlow= input.bool(true,"Show 3-Layer Glow",                             group=g_vis)
bool  i_showEma = input.bool(true,"Show Reclaim EMA",                              group=g_vis)
color i_buyColor= input.color(#2ec4b6,"Buy Color",                                 group=g_vis)
color i_sellColor=input.color(#ff5a5f,"Sell Color",                                group=g_vis)
color i_dashBg  = input.color(color.new(#06161a, 14),"Dashboard BG",              group=g_vis)

color c_white = #ffffff

float atr   = nz(ta.atr(i_atrLen), 0.0)
float rngBar= high - low
float cp    = rngBar > 0 ? (close - low) / rngBar : 0.5
float buyV  = nz(volume, 0.0) * cp
float sellV = nz(volume, 0.0) * (1.0 - cp)
float net   = ta.ema(buyV - sellV, i_smooth)
float vMa   = ta.sma(volume, i_volMa)
float bsp   = vMa > 0 ? 100.0 * net / vMa : 0.0
bool  inSession = not i_useSess or not na(time(timeframe.period, i_sess))

int regime = bsp > 0 ? 1 : bsp < 0 ? -1 : 0
bool strong = math.abs(bsp) >= i_strong
bool tradable = not i_strongOnly or strong
float emaFast = ta.ema(close, i_emaLen)
bool  crossUp = ta.crossover(close, emaFast)
bool  crossDn = ta.crossunder(close, emaFast)
bool zUp = ta.crossover(bsp, 0.0)
bool zDn = ta.crossunder(bsp, 0.0)
bool entryUp   = inSession and tradable and (i_xOnly ? zUp : (regime ==  1 and crossUp))
bool entryDown = inSession and tradable and (i_xOnly ? zDn : (regime == -1 and crossDn))

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

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.arrowup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.arrowup,   location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy",         shape.arrowup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="BSP", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.arrowdown, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.arrowdown, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell",        shape.arrowdown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="BSP", textcolor=c_white)

barcolor(bsp >= i_strong ? color.new(i_buyColor, 35) : bsp <= -i_strong ? color.new(i_sellColor, 35) : na)
bgcolor(regime == 1 ? color.new(i_buyColor, 94) : regime == -1 ? color.new(i_sellColor, 94) : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=i_dashBg, border_color=color.new(i_buyColor, 50), border_width=1)
    string rt = regime == 1 ? (strong ? "STRONG BUY" : "BUY PRESSURE") : regime == -1 ? (strong ? "STRONG SELL" : "SELL PRESSURE") : "BALANCED"
    color  rc = regime == 1 ? i_buyColor : regime == -1 ? i_sellColor : color.gray
    table.cell(dash, 0, 0, "Buy/Sell Pressure",     text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                 text_color=color.new(i_buyColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "Pressure",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, rt,                      text_color=rc, text_size=size.small)
    table.cell(dash, 0, 2, "BSP",                   text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(bsp, "0.0"), text_color=bsp >= 0 ? i_buyColor : i_sellColor, text_size=size.small)
    table.cell(dash, 0, 3, "Buy Vol %",             text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(cp * 100, "#") + "%", text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 4, "Strong",                text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, strong ? "YES" : "NO",   text_color=strong ? i_buyColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 5, "ATR",                   text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(atr, "#.#####"), text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 6, "Position",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"BSP","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"BSP","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                          "BSP Buy",            "Buy-pressure long on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                         "BSP Sell",           "Sell-pressure short on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,            "BSP Any Signal",     "Any BSP signal on {{ticker}} {{interval}}")
alertcondition(zUp,                                "BSP Zero Up",        "Pressure crossed above zero on {{ticker}} {{interval}}")
alertcondition(zDn,                                "BSP Zero Down",      "Pressure crossed below zero on {{ticker}} {{interval}}")
alertcondition(bsp >= i_strong and bsp[1] < i_strong,   "BSP Strong Buy",  "Strong buy pressure on {{ticker}} {{interval}}")
alertcondition(bsp <= -i_strong and bsp[1] > -i_strong, "BSP Strong Sell", "Strong sell pressure on {{ticker}} {{interval}}")
alertcondition(crossUp,                            "BSP EMA Up",         "Reclaim EMA crossed up on {{ticker}} {{interval}}")
alertcondition(crossDn,                            "BSP EMA Down",       "Reclaim EMA crossed down on {{ticker}} {{interval}}")
alertcondition(regime == 1 and regime[1] != 1,     "BSP Bull Regime",    "Pressure regime turned buy on {{ticker}} {{interval}}")
alertcondition(regime == -1 and regime[1] != -1,   "BSP Bear Regime",    "Pressure regime turned sell on {{ticker}} {{interval}}")
alertcondition(zUp or zDn,                          "BSP Any Zero Cross", "Any pressure zero-line cross on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,            "BSP Webhook JSON",   "{\"action\":\"signal\",\"indicator\":\"BSP\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
