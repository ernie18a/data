# Inversion FVG Tracker [forexobroker]

- url: https://www.tradingview.com/script/GNoodBCF-Inversion-FVG-Tracker-forexobroker/
- type: indicator
- pine_id: PUB;c989f16ed0e74439a3fefd4d48fe2d09
- version: 1.0

## Description

Inversion FVG Tracker [forexobroker] detects 3-candle Fair Value Gaps, watches for them to be fully mitigated, and then trades the inversion: a filled bullish FVG flips into resistance and a filled bearish FVG flips into support. Signals fire on the retest of an inverted gap. The unique angle is the full lifecycle state machine (fresh, inverted, retested) combined with an ATR-scaled minimum gap so micro-gaps are ignored.

🔶 ALGORITHM

1. ATR (default 14) is computed for gap-size scaling.
2. A bullish FVG forms when the current low is above the high two bars back and the gap spans at least the minimum (default 0.10 x ATR). A bearish FVG mirrors this with the current high below the low two bars back.
3. The most recent bull and bear FVG are tracked with a state value: fresh, mitigated/inverted, or retested.
4. Unmitigated FVGs older than the max age (default 60 bars) are discarded.
5. Mitigation uses close by default: a bull FVG closing fully below its bottom inverts to resistance; a bear FVG closing fully above its top inverts to support.
6. A retest buffer (default 0.10 x ATR) defines the inverted-zone test; an inverted bull FVG retested from below is bearish, an inverted bear FVG retested is bullish.
7. An inversion arms a persistent bias (bear FVG to support is bullish, bull FVG to resistance is bearish) that holds until the opposite inversion; entries then time off a reclaim EMA (default 9).

🔶 SIGNAL LOGIC

- Buy: in retest-only mode, an inverted bear-FVG retest (support); otherwise active inversion bias is bullish AND close crosses over the reclaim EMA, AND session filter passes AND position is not already long AND cooldown bars elapsed AND barstate.isconfirmed.
- Sell: in retest-only mode, an inverted bull-FVG retest (resistance); otherwise active inversion bias is bearish AND close crosses under the reclaim EMA, AND session filter passes AND position is not already short AND cooldown bars elapsed AND barstate.isconfirmed.

Only fires once an FVG has actually inverted to arm the bias.

🔶 INPUTS

- FVG group: minimum gap size as a multiple of ATR; default 0.10.
- ATR Length: volatility reference for gap and buffer scaling; default 14.
- Mitigate on Close: when on, an FVG inverts only when close passes fully through it; default on.
- Retest Buffer x ATR: tolerance around the inverted zone; default 0.10.
- FVG Max Age (bars): unmitigated gaps older than this are dropped; default 60.
- Signal Logic group: entry reclaim EMA default 9, retest-only mode default off, cooldown bars default 5.
- Filters group: optional session restriction; window default 0000-2400.
- Visual group: FVG zone boxes, dashboard, 3-layer glow, buy/sell colors, dashboard background.

🔶 ALERTS

IFT Buy, IFT Sell, IFT Any Signal, IFT Bull FVG, IFT Bear FVG, IFT Bull Inverted, IFT Bear Inverted, IFT Inv Bull Test, IFT Inv Bear Test, IFT Any FVG, IFT Inversion Live, IFT Webhook JSON.

🔶 LIMITATIONS

- A 3-candle FVG needs the two trailing bars, so the earliest chart bars produce no gaps.
- Only the most recent bull and bear FVG are tracked; older overlapping gaps are not retained.
- Defaults are tuned for liquid instruments; wide-spread or gappy symbols may need a larger minimum gap.
- Unmitigated gaps expire by age, so a very slow return to a valid gap can miss the inversion window.
- The non-retest-only path uses a fast EMA cross and can fire extra entries inside one inversion bias.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Inversion Fair Value Gap Tracker. A 3-candle FVG is a price inefficiency: a bullish
// FVG exists when low[0] > high[2] (a gap the middle candle leaves unfilled); bearish FVG when
// high[0] < low[2]. Once price closes through and fully mitigates an FVG, it INVERTS: a filled
// bullish FVG flips to act as resistance, a filled bearish FVG flips to support. Signals fire on
// the retest of an inverted FVG. ATR-scaled minimum gap size filters micro-gaps. Non-repainting.
indicator("Inversion FVG Tracker [forexobroker]", shorttitle="IFT [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc = "FVG"
string g_sig  = "Signal Logic"
string g_filt = "Filters"
string g_vis  = "Visual"

float i_minGap  = input.float(0.10,"Min Gap x ATR",        minval=0.0, maxval=3.0, step=0.05, group=g_calc, tooltip="Gap must span at least k x ATR to register.")
int   i_atrLen  = input.int(14,   "ATR Length",            minval=5,  maxval=50, group=g_calc)
bool  i_clsFill = input.bool(true,"Mitigate on Close",                          group=g_calc, tooltip="On = FVG inverts when CLOSE passes fully through it.")
float i_retBuf  = input.float(0.10,"Retest Buffer x ATR",  minval=0.0, maxval=2.0, step=0.05, group=g_calc)
int   i_expBars = input.int(60,   "FVG Max Age (bars)",    minval=5,  maxval=200, group=g_calc, tooltip="Unmitigated FVGs older than this are discarded.")
int   i_emaLen  = input.int(9,    "Entry Reclaim EMA",     minval=2,  maxval=50, group=g_sig, tooltip="After an FVG inverts, a close-cross of this EMA in the inverted-bias direction times the entry.")
bool  i_retOnly = input.bool(false,"Retest-Only Mode",                            group=g_sig, tooltip="On = fire strictly on the inverted-FVG retest (rarer, classic). Off = EMA reclaim inside the active inversion bias (more signals).")
int   i_cooldown= input.int(5,    "Cooldown Bars",         minval=1,  maxval=40, group=g_sig)
bool  i_useSess = input.bool(false,"Restrict to Session",                        group=g_filt)
string i_sess   = input.session("0000-2400","Session Window",                   group=g_filt)
bool  i_showBox = input.bool(true,"Show FVG Zones",                              group=g_vis)
bool  i_showTable=input.bool(true,"Show Dashboard",                              group=g_vis)
bool  i_showGlow= input.bool(true,"Show 3-Layer Glow",                           group=g_vis)
color i_buyColor= input.color(#10b981,"Buy Color",                               group=g_vis)
color i_sellColor=input.color(#e11d6f,"Sell Color",                              group=g_vis)
color i_dashBg  = input.color(color.new(#04140d, 15),"Dashboard BG",             group=g_vis)

color c_white = #ffffff

float atr = nz(ta.atr(i_atrLen), 0.0)

// Bull FVG: low[0] > high[2]; Bear FVG: high[0] < low[2]
bool bullFVG = low > high[2] and (low - high[2]) >= i_minGap * atr
bool bearFVG = high < low[2] and (low[2] - high) >= i_minGap * atr

// Track the most-recent bull and bear FVG with state: 1 fresh, 2 mitigated/inverted, 3 retested
var float buFvgTop = na
var float buFvgBot = na
var int   buFvgSt  = 0
var int   buFvgAge = 0
var float beFvgTop = na
var float beFvgBot = na
var int   beFvgSt  = 0
var int   beFvgAge = 0
var int   gapsFormed = 0

if bullFVG
    buFvgTop := low
    buFvgBot := high[2]
    buFvgSt  := 1
    buFvgAge := 0
    gapsFormed += 1
if bearFVG
    beFvgTop := low[2]
    beFvgBot := high
    beFvgSt  := 1
    beFvgAge := 0
    gapsFormed += 1
buFvgAge += 1
beFvgAge += 1
if buFvgSt == 1 and buFvgAge > i_expBars
    buFvgSt := 0
if beFvgSt == 1 and beFvgAge > i_expBars
    beFvgSt := 0

float fillRef = i_clsFill ? close : low
float fillRefH= i_clsFill ? close : high
// Bull FVG mitigated when price closes below its bottom -> inverts to RESISTANCE (bearish)
if buFvgSt == 1 and not na(buFvgBot) and fillRef < buFvgBot
    buFvgSt := 2
// Bear FVG mitigated when price closes above its top -> inverts to SUPPORT (bullish)
if beFvgSt == 1 and not na(beFvgTop) and fillRefH > beFvgTop
    beFvgSt := 2

float buf = i_retBuf * atr
// Inverted bull FVG = resistance: short on retest of [bot, top] from below
bool invBullRetest = buFvgSt == 2 and not na(buFvgTop) and high >= buFvgBot - buf and close < buFvgTop + buf
// Inverted bear FVG = support: long on retest
bool invBearRetest = beFvgSt == 2 and not na(beFvgBot) and low <= beFvgTop + buf and close > beFvgBot - buf
if invBullRetest
    buFvgSt := 3
if invBearRetest
    beFvgSt := 3

bool inSession = not i_useSess or not na(time(timeframe.period, i_sess))
// An FVG inverting arms a persistent bias (bear FVG -> support = bullish;
// bull FVG -> resistance = bearish) until the opposite inversion fires.
var int bias = 0
if beFvgSt == 2 and beFvgSt[1] == 1
    bias := 1
if buFvgSt == 2 and buFvgSt[1] == 1
    bias := -1
float emaFast = ta.ema(close, i_emaLen)
bool  crossUp = ta.crossover(close, emaFast)
bool  crossDn = ta.crossunder(close, emaFast)
bool entryUp   = inSession and (i_retOnly ? invBearRetest : (bias ==  1 and crossUp))
bool entryDown = inSession and (i_retOnly ? invBullRetest : (bias == -1 and crossDn))

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

var box buBox = na
var box beBox = na
if i_showBox and bullFVG
    box.delete(buBox)
    buBox := box.new(math.max(0, bar_index - 2), low, bar_index + 18, high[2], border_color=color.new(i_buyColor, 35), bgcolor=color.new(i_buyColor, 86))
if i_showBox and bearFVG
    box.delete(beBox)
    beBox := box.new(math.max(0, bar_index - 2), low[2], bar_index + 18, high, border_color=color.new(i_sellColor, 35), bgcolor=color.new(i_sellColor, 86))

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy",         shape.triangleup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="IFT", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.triangledown, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.triangledown, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell",        shape.triangledown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="IFT", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(bias == 1 ? color.new(i_buyColor, 94) : bias == -1 ? color.new(i_sellColor, 94) : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=i_dashBg, border_color=color.new(i_buyColor, 55), border_width=1)
    string st = buFvgSt == 2 ? "BULL FVG INVERTED" : beFvgSt == 2 ? "BEAR FVG INVERTED" : (buFvgSt == 1 or beFvgSt == 1) ? "FVG OPEN" : "NO FVG"
    color  sc = buFvgSt == 2 ? i_sellColor : beFvgSt == 2 ? i_buyColor : color.gray
    table.cell(dash, 0, 0, "Inversion FVG Tracker", text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                 text_color=color.new(i_buyColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "State",                 text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, st,                      text_color=sc, text_size=size.small)
    table.cell(dash, 0, 2, "Bull FVG",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, na(buFvgTop) ? "-" : str.tostring(buFvgBot, "#.##") + "-" + str.tostring(buFvgTop, "#.##"), text_color=i_buyColor, text_size=size.small)
    table.cell(dash, 0, 3, "Bear FVG",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, na(beFvgTop) ? "-" : str.tostring(beFvgBot, "#.##") + "-" + str.tostring(beFvgTop, "#.##"), text_color=i_sellColor, text_size=size.small)
    table.cell(dash, 0, 4, "Gaps Formed",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(gapsFormed), text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 5, "ATR",                   text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(atr, "#.#####"), text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 6, "Position",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"IFT","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"IFT","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                          "IFT Buy",           "Inverted bear FVG support long on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                         "IFT Sell",          "Inverted bull FVG resistance short on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,            "IFT Any Signal",    "Any IFT signal on {{ticker}} {{interval}}")
alertcondition(bullFVG,                            "IFT Bull FVG",      "Bullish FVG formed on {{ticker}} {{interval}}")
alertcondition(bearFVG,                            "IFT Bear FVG",      "Bearish FVG formed on {{ticker}} {{interval}}")
alertcondition(buFvgSt == 2 and buFvgSt[1] == 1,   "IFT Bull Inverted", "Bull FVG inverted to resistance on {{ticker}} {{interval}}")
alertcondition(beFvgSt == 2 and beFvgSt[1] == 1,   "IFT Bear Inverted", "Bear FVG inverted to support on {{ticker}} {{interval}}")
alertcondition(invBullRetest,                      "IFT Inv Bull Test", "Inverted bull FVG retested on {{ticker}} {{interval}}")
alertcondition(invBearRetest,                      "IFT Inv Bear Test", "Inverted bear FVG retested on {{ticker}} {{interval}}")
alertcondition(bullFVG or bearFVG,                 "IFT Any FVG",       "Any FVG formed on {{ticker}} {{interval}}")
alertcondition(buFvgSt == 2 or beFvgSt == 2,       "IFT Inversion Live","An inverted FVG is active on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,            "IFT Webhook JSON",  "{\"action\":\"signal\",\"indicator\":\"IFT\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
