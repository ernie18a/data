# Relative Volume Heat [forexobroker]

- url: https://www.tradingview.com/script/q0tjBd9j-Relative-Volume-Heat-forexobroker/
- type: indicator
- pine_id: PUB;453581b5f2464620b148f83edc62fade
- version: 1.0

## Description

Relative Volume Heat [forexobroker] turns raw volume into a participation regime. It measures how today's volume compares to its own recent baseline, then z-scores that ratio to classify the market as COLD, WARM or HOT. Directional entries are only allowed while the regime is HOT, so signals only print when real participation is behind the move. A heatmap background visualises regime intensity at a glance.

🔶 ALGORITHM

1. Compute RVOL = volume / SMA(volume, Volume MA Length).
2. Z-score the RVOL ratio over the RVOL Z Window: rz = (RVOL - mean) / stdev.
3. Classify the regime: rz >= Hot Z = HOT (2), rz >= Warm Z = WARM (1), else COLD (0).
4. A trend EMA defines directional bias: close above = up, below = down.
5. A separate reclaim EMA times the entry: a confirmed close-cross of it in the bias direction inside a HOT (or optionally WARM) regime is the trigger.
6. A cooldown, bar-close confirmation and a position-lock gate the final signal so it never repaints intrabar and never stacks the same side.

🔶 SIGNAL LOGIC

- Buy: in-session AND regime tradable AND trend direction up AND close crosses over the reclaim EMA AND position not already long AND cooldown elapsed AND barstate.isconfirmed.
- Sell: in-session AND regime tradable AND trend direction down AND close crosses under the reclaim EMA AND position not already short AND cooldown elapsed AND barstate.isconfirmed.
Only fires while the RVOL z-score regime is HOT (or WARM if "Trade Only When Hot" is off).

🔶 INPUTS

- RVOL group: Volume MA Length baseline for the relative-volume ratio (default 20).
- RVOL group: RVOL Z Window the ratio is z-scored over (default 50).
- RVOL group: Hot Z Threshold above which trading is enabled (default 1.0).
- RVOL group: Warm Z Threshold separating WARM from COLD (default 0.0).
- RVOL group: Trend EMA defining directional bias inside a hot regime (default 34).
- Signal Logic group: Entry Reclaim EMA whose close-cross times entries (default 9).
- Signal Logic group: Trade Only When Hot toggle and Cooldown Bars between signals (default 5).
- Filters group: optional session restriction with a configurable window (default off).
- Visual group: dashboard, 3-layer glow, heat background and buy/sell colors (dashboard default on).

🔶 ALERTS

RVH Buy, RVH Sell, RVH Any Signal, RVH Hot On, RVH Hot Off, RVH Warm, RVH Cold, RVH EMA Up, RVH EMA Down, RVH Trend Cross, RVH Hot Now, RVH Armed, RVH Webhook JSON.

🔶 LIMITATIONS

- Needs warm-up bars before the z-score window and trend EMA are fully populated.
- Volume-based, so it requires a real volume feed; on forex it falls back to broker tick-volume, which is a proxy only.
- COLD and WARM regimes intentionally suppress signals, so quiet markets produce few or no entries.
- Defaults are tuned for liquid instruments and intraday/swing timeframes; thin symbols may need a higher Volume MA Length.
- The regime classifies participation, not direction; bias still depends on the trend and reclaim EMAs.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Relative Volume Heat. RVOL = volume / its moving average; that ratio is then
// z-scored over a longer window to classify the regime: COLD, WARM or HOT. Real moves need
// participation, so directional entries are only allowed while the regime is HOT. Inside a hot
// regime a trend EMA defines direction and a close-cross of it times the entry. A heatmap
// background visualises the regime intensity. Non-repainting, bar-close, volume-adaptive.
indicator("Relative Volume Heat [forexobroker]", shorttitle="RVH [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc = "RVOL"
string g_sig  = "Signal Logic"
string g_filt = "Filters"
string g_vis  = "Visual"

int   i_volMa   = input.int(20,   "Volume MA Length",      minval=5,  maxval=100, group=g_calc, tooltip="Baseline for the relative-volume ratio.")
int   i_zLen    = input.int(50,   "RVOL Z Window",         minval=10, maxval=200, group=g_calc, tooltip="Window the RVOL ratio is z-scored over.")
float i_hotZ    = input.float(1.0,"Hot Z Threshold",       minval=0.0, maxval=4.0, step=0.1, group=g_calc, tooltip="RVOL z-score above this = HOT regime (trading enabled).")
float i_warmZ   = input.float(0.0,"Warm Z Threshold",      minval=-2.0, maxval=2.0, step=0.1, group=g_calc, tooltip="Z above this but below Hot = WARM.")
int   i_trendEma= input.int(34,   "Trend EMA",             minval=5,  maxval=200, group=g_calc, tooltip="Defines directional bias inside a hot regime.")
int   i_atrLen  = input.int(14,   "ATR Length",            minval=5,  maxval=50, group=g_calc)
int   i_emaLen  = input.int(9,    "Entry Reclaim EMA",     minval=2,  maxval=50, group=g_sig, tooltip="Close-cross of this EMA in the trend direction times the entry while HOT.")
bool  i_hotOnly = input.bool(true,"Trade Only When Hot",                          group=g_sig, tooltip="On = require HOT regime; Off = also allow WARM.")
int   i_cooldown= input.int(5,    "Cooldown Bars",         minval=1,  maxval=40, group=g_sig)
bool  i_useSess = input.bool(false,"Restrict to Session",                         group=g_filt)
string i_sess   = input.session("0000-2400","Session Window",                     group=g_filt)
bool  i_showTable=input.bool(true,"Show Dashboard",                                group=g_vis)
bool  i_showGlow= input.bool(true,"Show 3-Layer Glow",                             group=g_vis)
bool  i_showHeat= input.bool(true,"Show Heat Background",                           group=g_vis)
color i_buyColor= input.color(#ffb703,"Buy Color",                                 group=g_vis)
color i_sellColor=input.color(#fb5607,"Sell Color",                                group=g_vis)
color i_dashBg  = input.color(color.new(#1d0f00, 14),"Dashboard BG",              group=g_vis)

color c_white = #ffffff

float atr   = nz(ta.atr(i_atrLen), 0.0)
float vMa   = ta.sma(volume, i_volMa)
float rvol  = vMa > 0 ? volume / vMa : 0.0
float rMean = ta.sma(rvol, i_zLen)
float rStd  = ta.stdev(rvol, i_zLen)
float rz    = rStd > 0 ? (rvol - rMean) / rStd : 0.0
bool  inSession = not i_useSess or not na(time(timeframe.period, i_sess))

int regime = rz >= i_hotZ ? 2 : rz >= i_warmZ ? 1 : 0   // 2 hot, 1 warm, 0 cold
bool tradable = i_hotOnly ? regime == 2 : regime >= 1

float trend   = ta.ema(close, i_trendEma)
int   tdir    = close > trend ? 1 : close < trend ? -1 : 0
float emaFast = ta.ema(close, i_emaLen)
bool  crossUp = ta.crossover(close, emaFast)
bool  crossDn = ta.crossunder(close, emaFast)

bool entryUp   = inSession and tradable and tdir ==  1 and crossUp
bool entryDown = inSession and tradable and tdir == -1 and crossDn

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

color heat = regime == 2 ? color.new(#fb5607, 84) : regime == 1 ? color.new(#ffb703, 90) : na
bgcolor(i_showHeat ? heat : na)

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy",         shape.triangleup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="RVH", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.triangledown, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.triangledown, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell",        shape.triangledown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="RVH", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=i_dashBg, border_color=color.new(i_buyColor, 50), border_width=2)
    string rt = regime == 2 ? "HOT" : regime == 1 ? "WARM" : "COLD"
    color  rc = regime == 2 ? i_sellColor : regime == 1 ? i_buyColor : color.gray
    table.cell(dash, 0, 0, "Relative Volume Heat",  text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                 text_color=color.new(i_buyColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "Regime",                text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, rt,                      text_color=rc, text_size=size.small)
    table.cell(dash, 0, 2, "RVOL",                  text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(rvol, "0.00") + "x", text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 3, "RVOL Z",                text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(rz, "0.00"), text_color=rz >= i_hotZ ? i_sellColor : color.silver, text_size=size.small)
    table.cell(dash, 0, 4, "Trend Dir",             text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, tdir == 1 ? "UP" : tdir == -1 ? "DOWN" : "FLAT", text_color=tdir == 1 ? i_buyColor : tdir == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 5, "Tradable",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, tradable ? "YES" : "NO", text_color=tradable ? i_buyColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 6, "Position",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"RVH","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"RVH","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                          "RVH Buy",            "Hot-regime long on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                         "RVH Sell",           "Hot-regime short on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,            "RVH Any Signal",     "Any RVH signal on {{ticker}} {{interval}}")
alertcondition(regime == 2 and regime[1] != 2,     "RVH Hot On",         "Regime turned HOT on {{ticker}} {{interval}}")
alertcondition(regime != 2 and regime[1] == 2,     "RVH Hot Off",        "Regime left HOT on {{ticker}} {{interval}}")
alertcondition(regime == 1 and regime[1] != 1,     "RVH Warm",           "Regime turned WARM on {{ticker}} {{interval}}")
alertcondition(regime == 0 and regime[1] != 0,     "RVH Cold",           "Regime turned COLD on {{ticker}} {{interval}}")
alertcondition(crossUp,                            "RVH EMA Up",         "Reclaim EMA crossed up on {{ticker}} {{interval}}")
alertcondition(crossDn,                            "RVH EMA Down",       "Reclaim EMA crossed down on {{ticker}} {{interval}}")
alertcondition(ta.cross(close, trend),             "RVH Trend Cross",    "Price crossed trend EMA on {{ticker}} {{interval}}")
alertcondition(rz >= i_hotZ,                       "RVH Hot Now",        "RVOL z-score above hot threshold on {{ticker}} {{interval}}")
alertcondition(tradable and not tradable[1],       "RVH Armed",          "Regime became tradable on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,            "RVH Webhook JSON",   "{\"action\":\"signal\",\"indicator\":\"RVH\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
