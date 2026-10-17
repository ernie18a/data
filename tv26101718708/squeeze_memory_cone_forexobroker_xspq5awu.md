# Squeeze Memory Cone [forexobroker]

- url: https://www.tradingview.com/script/xSPQ5awu-Squeeze-Memory-Cone-forexobroker/
- type: indicator
- pine_id: PUB;b4a60f4a56b8465285bec38705205b1f
- version: 1.0

## Description

Squeeze Memory Cone [forexobroker] detects a volatility squeeze when the Bollinger Bands sit fully inside the Keltner Channel, then projects a forward "memory cone" from the squeeze-release bar. The unique angle is that the cone half-width grows with the square root of bars elapsed since release, mirroring the typical post-squeeze expansion envelope, and that envelope plus the release direction frames every entry.

🔶 ALGORITHM

1. Build Bollinger Bands (SMA basis +/- stdev x BB mult) and a Keltner Channel (same basis +/- ATR-style range x KC mult) on the shared length.
2. Squeeze is ON when the upper BB is below the upper KC AND the lower BB is above the lower KC (volatility compression).
3. Release = squeeze was on last bar and is off this bar. On release, the linreg of detrended price (close minus its SMA) gives the expansion direction, which sets the bias; the release close anchors the cone base.
4. Project the memory cone forward: half-width = Cone Width x ATR x sqrt(bars since release), bounded by Cone Life bars. The cone is a sqrt-time expansion envelope, not a forecast line.
5. Entry timing: in Release-Only mode the signal is the directional release bar itself; otherwise, while the cone is active and bias is set, a close crossover (long) or crossunder (short) of the reclaim EMA times the entry. Cooldown, position-lock, and bar-close confirmation apply. Non-repainting.

🔶 SIGNAL LOGIC

- Buy: in-session AND ((Release-Only: squeeze released with positive momentum) OR (cone active AND bias = +1 AND close crosses over the reclaim EMA)) AND position not already long AND cooldown elapsed AND barstate.isconfirmed (then position locks long).
- Sell: in-session AND ((Release-Only: squeeze released with negative momentum) OR (cone active AND bias = -1 AND close crosses under the reclaim EMA)) AND position not already short AND cooldown elapsed AND barstate.isconfirmed (then position locks short).
- Only fires while the projected memory cone is active (or on the release bar in Release-Only mode).

🔶 INPUTS

- Squeeze group: shared length for Bollinger Bands and Keltner Channel; default BB/KC Length 20.
- BB width: standard-deviation multiplier for the Bollinger Bands; default BB StdDev Mult 2.0.
- KC width: ATR-range multiplier for the Keltner Channel; default KC ATR Mult 1.5.
- Cone life: bars the projected cone stays active after release; default Cone Life 30.
- Cone width: k in the k x ATR x sqrt(bars) half-width; default Cone Width x ATR 1.0.
- Volatility reference: ATR length for cone width and dashboard; default ATR Length 20.
- Signal Logic group: entry reclaim EMA, release-only mode, cooldown; default Entry Reclaim EMA 9.
- Cooldown: minimum bars between signals; default Cooldown Bars 5.
- Filters group: optional session restriction and session window; default Restrict to Session off.
- Visual group: memory cone, dashboard, 3-layer glow, buy/sell colors, dashboard background.

🔶 ALERTS

SMQ Buy, SMQ Sell, SMQ Any Signal, SMQ Squeeze On, SMQ Release, SMQ Release Up, SMQ Release Down, SMQ EMA Up, SMQ EMA Down, SMQ Cone Open, SMQ Cone Expire, SMQ Bias Flip, SMQ Webhook JSON.

🔶 LIMITATIONS

- The squeeze/cone logic needs a full BB/KC length to stabilise, so the first length bars are warm-up.
- The memory cone is a sqrt-time heuristic envelope of expected expansion, not a price forecast or target.
- Release direction is taken from a linreg of detrended price on the release bar and can be marginal when momentum is near zero.
- Default multipliers are tuned for liquid instruments; gappy symbols can trigger or break squeezes abruptly.
- Entries confirm on bar close, so the reclaim-EMA cross is acknowledged with one-bar lag versus intrabar price.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Squeeze Memory Cone. A volatility squeeze is detected when the Bollinger Bands sit
// fully inside the Keltner Channel (compression). When the squeeze RELEASES, the linreg of the
// detrended price gives the expansion direction. From the release bar a forward "memory cone"
// is projected: a band that widens with the square root of bars elapsed (the typical post-
// squeeze expansion envelope). Bias = release direction; reclaim-EMA cross times entries.
indicator("Squeeze Memory Cone [forexobroker]", shorttitle="SMQ [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc = "Squeeze"
string g_sig  = "Signal Logic"
string g_filt = "Filters"
string g_vis  = "Visual"

int   i_len     = input.int(20,   "BB/KC Length",          minval=5,  maxval=100, group=g_calc, tooltip="Length for both Bollinger Bands and Keltner Channel.")
float i_bbMult  = input.float(2.0,"BB StdDev Mult",        minval=1.0, maxval=4.0, step=0.1, group=g_calc)
float i_kcMult  = input.float(1.5,"KC ATR Mult",           minval=0.5, maxval=4.0, step=0.1, group=g_calc, tooltip="Squeeze = BB fully inside KC.")
int   i_coneLife= input.int(30,   "Cone Life (bars)",      minval=5,  maxval=100, group=g_calc, tooltip="Bars the projected cone stays active after release.")
float i_coneK   = input.float(1.0,"Cone Width x ATR",      minval=0.2, maxval=5.0, step=0.1, group=g_calc, tooltip="Cone half-width grows as k x ATR x sqrt(bars since release).")
int   i_atrLen  = input.int(20,   "ATR Length",            minval=5,  maxval=50, group=g_calc)
int   i_emaLen  = input.int(9,    "Entry Reclaim EMA",     minval=2,  maxval=50, group=g_sig, tooltip="After a release sets a bias, a close-cross of this EMA in that direction times the entry.")
bool  i_relOnly = input.bool(false,"Release-Only Mode",                            group=g_sig, tooltip="On = fire only on the squeeze-release bar. Off = EMA reclaim inside the active cone (more signals).")
int   i_cooldown= input.int(5,    "Cooldown Bars",         minval=1,  maxval=40, group=g_sig)
bool  i_useSess = input.bool(false,"Restrict to Session",                          group=g_filt)
string i_sess   = input.session("0000-2400","Session Window",                      group=g_filt)
bool  i_showCone= input.bool(true,"Show Memory Cone",                               group=g_vis)
bool  i_showTable=input.bool(true,"Show Dashboard",                                 group=g_vis)
bool  i_showGlow= input.bool(true,"Show 3-Layer Glow",                              group=g_vis)
color i_buyColor= input.color(#b8f2e6,"Buy Color",                                  group=g_vis)
color i_sellColor=input.color(#ffa5ab,"Sell Color",                                 group=g_vis)
color i_dashBg  = input.color(color.new(#04130f, 14),"Dashboard BG",               group=g_vis)

color c_white = #ffffff

float atr   = nz(ta.atr(i_atrLen), 0.0)
float basis = ta.sma(close, i_len)
float dev   = i_bbMult * ta.stdev(close, i_len)
float bbU   = basis + dev
float bbL   = basis - dev
float rng   = ta.sma(ta.tr(true), i_len)
float kcU   = basis + i_kcMult * rng
float kcL   = basis - i_kcMult * rng
bool  squeeze = bbU < kcU and bbL > kcL
bool  release = not squeeze and squeeze[1]
bool  inSession = not i_useSess or not na(time(timeframe.period, i_sess))

float mom = ta.linreg(close - ta.sma(close, i_len), i_len, 0)

var int   bias = 0
var float coneBase = na
var int   releaseBar = 0
if release
    bias := mom > 0 ? 1 : mom < 0 ? -1 : 0
    coneBase := close
    releaseBar := bar_index
int barsSince = bar_index - releaseBar
bool coneActive = not na(coneBase) and barsSince <= i_coneLife
if not coneActive
    bias := 0
float coneW = i_coneK * atr * math.sqrt(math.max(1, barsSince))
float coneU = coneActive ? coneBase + coneW : na
float coneL = coneActive ? coneBase - coneW : na

float emaFast = ta.ema(close, i_emaLen)
bool  crossUp = ta.crossover(close, emaFast)
bool  crossDn = ta.crossunder(close, emaFast)
bool relUp = release and mom > 0
bool relDn = release and mom < 0
bool entryUp   = inSession and (i_relOnly ? relUp : (coneActive and bias ==  1 and crossUp))
bool entryDown = inSession and (i_relOnly ? relDn : (coneActive and bias == -1 and crossDn))

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

pU = plot(i_showCone and coneActive ? coneU : na, "Cone Up", color=color.new(i_buyColor, 40), linewidth=1)
pL = plot(i_showCone and coneActive ? coneL : na, "Cone Low", color=color.new(i_sellColor, 40), linewidth=1)
fill(pU, pL, color=coneActive ? color.new(bias == 1 ? i_buyColor : bias == -1 ? i_sellColor : color.gray, 92) : na)

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.flag, location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.flag, location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy",         shape.flag, location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="SMQ", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.flag, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.flag, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell",        shape.flag, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="SMQ", textcolor=c_white)

barcolor(squeeze ? color.new(color.gray, 40) : na)
bgcolor(bias == 1 ? color.new(i_buyColor, 92) : bias == -1 ? color.new(i_sellColor, 92) : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=i_dashBg, border_color=color.new(i_buyColor, 50), border_width=1)
    string st = squeeze ? "SQUEEZE ON" : coneActive ? (bias == 1 ? "CONE UP" : "CONE DOWN") : "NEUTRAL"
    color  sc = squeeze ? color.gray : bias == 1 ? i_buyColor : bias == -1 ? i_sellColor : color.gray
    table.cell(dash, 0, 0, "Squeeze Memory Cone",   text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                 text_color=color.new(i_buyColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "State",                 text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, st,                      text_color=sc, text_size=size.small)
    table.cell(dash, 0, 2, "Squeeze",               text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, squeeze ? "ON" : "OFF",  text_color=squeeze ? color.orange : color.gray, text_size=size.small)
    table.cell(dash, 0, 3, "Momentum",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(mom, "#.#####"), text_color=mom >= 0 ? i_buyColor : i_sellColor, text_size=size.small)
    table.cell(dash, 0, 4, "Cone Age",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, coneActive ? str.tostring(barsSince) + "b" : "-", text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 5, "Cone Width",            text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, coneActive ? str.tostring(coneW, "#.##") : "-", text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 6, "Position",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"SMQ","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"SMQ","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                          "SMQ Buy",            "Squeeze-release long on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                         "SMQ Sell",           "Squeeze-release short on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,            "SMQ Any Signal",     "Any SMQ signal on {{ticker}} {{interval}}")
alertcondition(squeeze and not squeeze[1],         "SMQ Squeeze On",     "Volatility squeeze formed on {{ticker}} {{interval}}")
alertcondition(release,                            "SMQ Release",        "Squeeze released on {{ticker}} {{interval}}")
alertcondition(relUp,                              "SMQ Release Up",     "Squeeze released upward on {{ticker}} {{interval}}")
alertcondition(relDn,                              "SMQ Release Down",   "Squeeze released downward on {{ticker}} {{interval}}")
alertcondition(crossUp,                            "SMQ EMA Up",         "Reclaim EMA crossed up on {{ticker}} {{interval}}")
alertcondition(crossDn,                            "SMQ EMA Down",       "Reclaim EMA crossed down on {{ticker}} {{interval}}")
alertcondition(coneActive and not coneActive[1],   "SMQ Cone Open",      "Memory cone opened on {{ticker}} {{interval}}")
alertcondition(not coneActive and coneActive[1],   "SMQ Cone Expire",    "Memory cone expired on {{ticker}} {{interval}}")
alertcondition(bias != bias[1],                    "SMQ Bias Flip",      "Cone bias flipped on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,            "SMQ Webhook JSON",   "{\"action\":\"signal\",\"indicator\":\"SMQ\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
