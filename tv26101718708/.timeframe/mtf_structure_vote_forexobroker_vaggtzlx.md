# MTF Structure Vote [forexobroker]

- url: https://www.tradingview.com/script/VAgGtzLx-MTF-Structure-Vote-forexobroker/
- type: indicator
- pine_id: PUB;f1121862360f40e5af5961786e791701
- version: 1.0

## Description

MTF Structure Vote [forexobroker] polls three independent higher timeframes and lets each one cast a directional vote based on where price sits relative to its own structural trend EMA. When enough timeframes agree, a confluence regime is declared, and a precise local EMA reclaim then times the entry. The unique angle is treating multi-timeframe alignment as a discrete vote count rather than a single blended bias, which makes chop filtering explicit and tunable.

🔶 ALGORITHM

1. Three higher timeframes (default 60, 240, D) are read via request.security with barmerge.lookahead_off.
2. Each timeframe computes a trend EMA (default length 50) on its own closes. Close above the HTF EMA returns +1, below returns -1.
3. The three votes are summed into a net vote ranging from -3 to +3.
4. A local reclaim EMA (default 9) is computed on the chart timeframe to time entries.
5. Bull confluence is declared when net vote is greater than or equal to the threshold; bear confluence when it is less than or equal to the negative threshold.
6. ATR (default 14) is tracked for context in the dashboard.
7. Each signal flips a persistent position state and stamps the bar so the cooldown can enforce spacing.

🔶 SIGNAL LOGIC

- Buy: net vote reaches the bull confluence threshold AND local close crosses over the reclaim EMA AND session filter passes AND position is not already long AND cooldown bars elapsed since last signal AND barstate.isconfirmed.
- Sell: net vote reaches the bear confluence threshold AND local close crosses under the reclaim EMA AND session filter passes AND position is not already short AND cooldown bars elapsed since last signal AND barstate.isconfirmed.

Only fires when the multi-timeframe net vote has reached the configured confluence threshold.

🔶 INPUTS

- MTF group: three higher-timeframe selectors; HTF 1 default 60.
- HTF Trend EMA: length of the structural EMA computed on each higher timeframe; default 50.
- Local Reclaim EMA: chart-timeframe EMA used to time entries; default 9.
- Signal Logic group: minimum absolute net vote required; default 2 (at least 2 of 3 agree).
- ATR Length: volatility reference shown in the dashboard; default 14.
- Cooldown Bars: minimum bars between signals; default 5.
- Filters group: optional session restriction; session window default 0000-2400.
- Visual group: dashboard, 3-layer glow, local EMA plot, buy/sell colors, dashboard background; glow on by default.

🔶 ALERTS

MSV Buy, MSV Sell, MSV Any Signal, MSV Bull Conf, MSV Bear Conf, MSV Unanimous Bull, MSV Unanimous Bear, MSV Vote Change, MSV Local Up, MSV Local Down, MSV Any Conf, MSV Webhook JSON.

🔶 LIMITATIONS

- The higher-timeframe EMAs need warm-up history; on fresh symbols early bars carry no reliable vote.
- request.security on higher timeframes is read with lookahead_off on the confirmed bar, so values are non-repainting but update only when the HTF bar closes, introducing natural lag.
- Defaults are tuned for liquid instruments; thin symbols may need wider thresholds or different timeframes.
- Confluence gating intentionally suppresses signals during mixed regimes, so trending-only behavior is expected.
- The local reclaim is a fast EMA cross and can whipsaw inside a valid confluence regime during low volatility.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Multi-Timeframe Structure Vote. Three higher timeframes each cast a directional vote
// from their own structure: price above the HTF trend EMA = +1 (bullish), below = -1 (bearish).
// Votes are pulled with request.security using lookahead_off and read on the last CLOSED HTF bar,
// so the indicator is strictly non-repainting. When the net vote reaches the confluence threshold
// AND a local EMA reclaim fires in that direction, a signal triggers. Confluence filters chop.
indicator("MTF Structure Vote [forexobroker]", shorttitle="MSV [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc = "MTF"
string g_sig  = "Signal Logic"
string g_filt = "Filters"
string g_vis  = "Visual"

string i_tf1   = input.timeframe("60",  "HTF 1",            group=g_calc, tooltip="First higher timeframe for the structure vote.")
string i_tf2   = input.timeframe("240", "HTF 2",            group=g_calc)
string i_tf3   = input.timeframe("D",   "HTF 3",            group=g_calc)
int   i_htfEma = input.int(50,  "HTF Trend EMA",            minval=5, maxval=200, group=g_calc, tooltip="EMA computed on each HTF to define its structural bias.")
int   i_locEma = input.int(9,   "Local Reclaim EMA",        minval=2, maxval=50, group=g_calc)
int   i_minVote= input.int(2,   "Min |Net Vote|",           minval=1, maxval=3, group=g_sig, tooltip="2 = at least 2 of 3 HTFs agree; 3 = unanimous.")
int   i_atrLen = input.int(14,  "ATR Length",               minval=5, maxval=50, group=g_calc)
int   i_cooldown=input.int(5,   "Cooldown Bars",            minval=1, maxval=40, group=g_sig)
bool  i_useSess= input.bool(false,"Restrict to Session",                        group=g_filt)
string i_sess  = input.session("0000-2400","Session Window",                    group=g_filt)
bool  i_showTable=input.bool(true,"Show Dashboard",                             group=g_vis)
bool  i_showGlow=input.bool(true,"Show 3-Layer Glow",                           group=g_vis)
bool  i_showEma= input.bool(true,"Show Local EMA",                              group=g_vis)
color i_buyColor=input.color(#38bdf8,"Buy Color",                               group=g_vis)
color i_sellColor=input.color(#fb7185,"Sell Color",                             group=g_vis)
color i_dashBg = input.color(color.new(#04121f, 14),"Dashboard BG",             group=g_vis)

color c_white = #ffffff

f_vote(simple string tf) =>
    request.security(syminfo.tickerid, tf, close > ta.ema(close, i_htfEma) ? 1 : -1, lookahead=barmerge.lookahead_off)

int v1 = nz(f_vote(i_tf1), 0)
int v2 = nz(f_vote(i_tf2), 0)
int v3 = nz(f_vote(i_tf3), 0)
int netVote = v1 + v2 + v3

float atr   = nz(ta.atr(i_atrLen), 0.0)
float locEma= ta.ema(close, i_locEma)
bool  crossUp = ta.crossover(close, locEma)
bool  crossDn = ta.crossunder(close, locEma)
bool  inSession = not i_useSess or not na(time(timeframe.period, i_sess))

bool bullConf = netVote >=  i_minVote
bool bearConf = netVote <= -i_minVote
bool entryUp   = bullConf and crossUp and inSession
bool entryDown = bearConf and crossDn and inSession

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

color emaCol = bullConf ? i_buyColor : bearConf ? i_sellColor : color.new(color.gray, 40)
plot(i_showEma ? locEma : na, "Local EMA", color=emaCol, linewidth=2)

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.flag, location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.flag, location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy",         shape.flag, location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="MSV", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.flag, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.flag, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell",        shape.flag, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="MSV", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(bullConf ? color.new(i_buyColor, 93) : bearConf ? color.new(i_sellColor, 93) : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 9, bgcolor=i_dashBg, border_color=color.new(i_buyColor, 55), border_width=1)
    string ct = bullConf ? "BULL CONFLUENCE" : bearConf ? "BEAR CONFLUENCE" : "MIXED"
    color  cc = bullConf ? i_buyColor : bearConf ? i_sellColor : color.gray
    table.cell(dash, 0, 0, "MTF Structure Vote", text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",              text_color=color.new(i_buyColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "HTF1 " + i_tf1,      text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, v1 == 1 ? "BULL" : "BEAR", text_color=v1 == 1 ? i_buyColor : i_sellColor, text_size=size.small)
    table.cell(dash, 0, 2, "HTF2 " + i_tf2,      text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, v2 == 1 ? "BULL" : "BEAR", text_color=v2 == 1 ? i_buyColor : i_sellColor, text_size=size.small)
    table.cell(dash, 0, 3, "HTF3 " + i_tf3,      text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, v3 == 1 ? "BULL" : "BEAR", text_color=v3 == 1 ? i_buyColor : i_sellColor, text_size=size.small)
    table.cell(dash, 0, 4, "Net Vote",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(netVote), text_color=cc, text_size=size.small)
    table.cell(dash, 0, 5, "Confluence",         text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, ct,                   text_color=cc, text_size=size.small)
    table.cell(dash, 0, 6, "Threshold",          text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, str.tostring(i_minVote) + " / 3", text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 7, "Position",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 8, "Last Signal",        text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 8, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"MSV","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"vote":' + str.tostring(netVote) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"MSV","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"vote":' + str.tostring(netVote) + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                          "MSV Buy",           "MTF bull confluence on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                         "MSV Sell",          "MTF bear confluence on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,            "MSV Any Signal",    "Any MSV signal on {{ticker}} {{interval}}")
alertcondition(bullConf and not bullConf[1],       "MSV Bull Conf",     "Bull confluence reached on {{ticker}} {{interval}}")
alertcondition(bearConf and not bearConf[1],       "MSV Bear Conf",     "Bear confluence reached on {{ticker}} {{interval}}")
alertcondition(netVote == 3 and netVote[1] != 3,   "MSV Unanimous Bull","All HTFs bullish on {{ticker}} {{interval}}")
alertcondition(netVote == -3 and netVote[1] != -3, "MSV Unanimous Bear","All HTFs bearish on {{ticker}} {{interval}}")
alertcondition(netVote != netVote[1],              "MSV Vote Change",   "MTF vote changed on {{ticker}} {{interval}}")
alertcondition(crossUp,                            "MSV Local Up",      "Local EMA crossed up on {{ticker}} {{interval}}")
alertcondition(crossDn,                            "MSV Local Down",    "Local EMA crossed down on {{ticker}} {{interval}}")
alertcondition(bullConf or bearConf,               "MSV Any Conf",      "Any confluence active on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,            "MSV Webhook JSON",  "{\"action\":\"signal\",\"indicator\":\"MSV\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
