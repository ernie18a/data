# Confluence Conviction Engine [forexobroker]

- url: https://www.tradingview.com/script/pKaPFFIg-Confluence-Conviction-Engine-forexobroker/
- type: indicator
- pine_id: PUB;ac1470cded534cc49f76ab04fbc9be3c
- version: 1.0

## Description

Confluence Conviction Engine [forexobroker] runs a 4-factor confluence vote across regime, acceleration, signal, and momentum, then turns the net tally into a conviction score from -4 to +4. The unique angle is that a trade only fires when conviction meets a user threshold AND a reclaim-EMA cross prints in the same direction, so weak single-factor agreement is filtered out before any signal.

🔶 ALGORITHM

1. Factor 1 REGIME: +1 if price is above the slow regime EMA, -1 if below.
2. Factor 2 ACCELERATION: compute momentum as the N-bar price rate of change; +1 if its current value rose versus the prior bar, -1 if it fell.
3. Factor 3 SIGNAL: +1 if price is above the fast signal EMA, -1 if below.
4. Factor 4 MOMENTUM: +1 if RSI is above 50, -1 if below.
5. Net vote = sum of the four factor votes (range -4..+4). Conviction = absolute net vote; bias = sign of net vote.
6. With bias set and conviction at or above the minimum, a close crossover (long) or crossunder (short) of the reclaim EMA times the entry. Signals respect a bar cooldown, position-lock, and bar-close confirmation. Non-repainting.

🔶 SIGNAL LOGIC

- Buy: in-session AND bias = +1 AND conviction >= Min Conviction AND close crosses over the reclaim EMA AND position not already long AND cooldown elapsed AND barstate.isconfirmed (then position locks long).
- Sell: in-session AND bias = -1 AND conviction >= Min Conviction AND close crosses under the reclaim EMA AND position not already short AND cooldown elapsed AND barstate.isconfirmed (then position locks short).
- Only fires when net 4-factor conviction reaches the configured threshold.

🔶 INPUTS

- Conviction group: regime trend EMA for Factor 1; default Regime Trend EMA 50.
- Momentum length: ROC lookback whose change forms Factor 2 acceleration; default Momentum Length 12.
- Fast signal EMA: price-vs-EMA test for Factor 3; default Fast Signal EMA 9.
- RSI length: oscillator for the Factor 4 above/below-50 vote; default RSI Length 14.
- Min Conviction: required absolute net vote (1-4) to allow a trade; default Min Conviction 3.
- Volatility reference: ATR length for the dashboard reference; default ATR Length 14.
- Signal Logic group: entry reclaim EMA and cooldown; default Entry Reclaim EMA 9.
- Cooldown: minimum bars between signals; default Cooldown Bars 5.
- Filters group: optional session restriction and session window; default Restrict to Session off.
- Visual group: dashboard, 3-layer glow, reclaim EMA, buy/sell colors, dashboard background.

🔶 ALERTS

CCE Buy, CCE Sell, CCE Any Signal, CCE Full Bull, CCE Full Bear, CCE Edge On, CCE Bias Bull, CCE Bias Bear, CCE EMA Up, CCE EMA Down, CCE Vote Change, CCE RSI Mid, CCE Webhook JSON.

🔶 LIMITATIONS

- The slowest factor (regime EMA) needs its full length to stabilise, so early bars under-report conviction.
- Conviction measures present agreement among four factors; it is a confluence gauge, not a probability or forecast of the next move.
- All four factors are price-derived and can correlate during strong trends, so a full +/-4 vote is not four independent confirmations.
- Default lengths are tuned for liquid instruments; very low timeframes can produce rapid vote flips.
- Entries confirm on bar close, so the reclaim-EMA cross is acknowledged with one-bar lag versus intrabar price.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Confluence Conviction Engine. Four independent factors each vote +1 (bullish) or
// -1 (bearish): (1) REGIME = price vs a slow trend EMA; (2) ACCELERATION = sign of momentum's
// rate of change; (3) SIGNAL = price vs a fast EMA; (4) MOMENTUM = RSI above/below 50. The net
// vote (-4..+4) is the conviction. A trade only fires when |conviction| meets the threshold
// AND a reclaim-EMA cross prints in that direction. Non-repainting, bar-close.
indicator("Confluence Conviction Engine [forexobroker]", shorttitle="CCE [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc = "Conviction"
string g_sig  = "Signal Logic"
string g_filt = "Filters"
string g_vis  = "Visual"

int   i_regEma  = input.int(50,   "Regime Trend EMA",      minval=10, maxval=300, group=g_calc, tooltip="Factor 1: price above/below this EMA.")
int   i_momLen  = input.int(12,   "Momentum Length",       minval=2,  maxval=60, group=g_calc, tooltip="Factor 2: ROC over this length, its change = acceleration.")
int   i_fastEma = input.int(9,    "Fast Signal EMA",       minval=2,  maxval=50, group=g_calc, tooltip="Factor 3: price above/below this EMA.")
int   i_rsiLen  = input.int(14,   "RSI Length",            minval=2,  maxval=50, group=g_calc, tooltip="Factor 4: RSI above/below 50.")
int   i_minScore= input.int(3,    "Min Conviction",        minval=1,  maxval=4, group=g_sig, tooltip="Require |net vote| of at least this (1-4) to trade.")
int   i_atrLen  = input.int(14,   "ATR Length",            minval=5,  maxval=50, group=g_calc)
int   i_emaLen  = input.int(9,    "Entry Reclaim EMA",     minval=2,  maxval=50, group=g_sig, tooltip="Close-cross of this EMA in the conviction direction times the entry.")
int   i_cooldown= input.int(5,    "Cooldown Bars",         minval=1,  maxval=40, group=g_sig)
bool  i_useSess = input.bool(false,"Restrict to Session",                         group=g_filt)
string i_sess   = input.session("0000-2400","Session Window",                     group=g_filt)
bool  i_showTable=input.bool(true,"Show Dashboard",                                group=g_vis)
bool  i_showGlow= input.bool(true,"Show 3-Layer Glow",                             group=g_vis)
bool  i_showEma = input.bool(true,"Show Reclaim EMA",                              group=g_vis)
color i_buyColor= input.color(#00f5d4,"Buy Color",                                 group=g_vis)
color i_sellColor=input.color(#f15bb5,"Sell Color",                                group=g_vis)
color i_dashBg  = input.color(color.new(#0a061c, 14),"Dashboard BG",              group=g_vis)

color c_white = #ffffff

float atr   = nz(ta.atr(i_atrLen), 0.0)
float regE  = ta.ema(close, i_regEma)
float roc   = close - close[i_momLen]
float fastE = ta.ema(close, i_fastEma)
float rsi   = ta.rsi(close, i_rsiLen)
bool  inSession = not i_useSess or not na(time(timeframe.period, i_sess))

int fRegime = close > regE ? 1 : close < regE ? -1 : 0
int fAccel  = roc > nz(roc[1]) ? 1 : roc < nz(roc[1]) ? -1 : 0
int fSignal = close > fastE ? 1 : close < fastE ? -1 : 0
int fMom    = rsi > 50.0 ? 1 : rsi < 50.0 ? -1 : 0
int netScore= fRegime + fAccel + fSignal + fMom
int conv    = math.abs(netScore)
int bias    = netScore > 0 ? 1 : netScore < 0 ? -1 : 0

float emaFast = ta.ema(close, i_emaLen)
bool  crossUp = ta.crossover(close, emaFast)
bool  crossDn = ta.crossunder(close, emaFast)
bool entryUp   = inSession and bias ==  1 and conv >= i_minScore and crossUp
bool entryDown = inSession and bias == -1 and conv >= i_minScore and crossDn

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

plot(i_showEma ? emaFast : na, "Reclaim EMA", color=bias == 1 ? color.new(i_buyColor, 30) : bias == -1 ? color.new(i_sellColor, 30) : color.new(color.gray, 50), linewidth=2)

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.diamond, location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.diamond, location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy",         shape.diamond, location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="CCE", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.diamond, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.diamond, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell",        shape.diamond, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="CCE", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(conv >= i_minScore and bias == 1 ? color.new(i_buyColor, 92) : conv >= i_minScore and bias == -1 ? color.new(i_sellColor, 92) : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 9, bgcolor=i_dashBg, border_color=color.new(i_buyColor, 50), border_width=2)
    string ct = bias == 1 ? "BULL x" + str.tostring(conv) : bias == -1 ? "BEAR x" + str.tostring(conv) : "NO EDGE"
    color  cc = bias == 1 ? i_buyColor : bias == -1 ? i_sellColor : color.gray
    table.cell(dash, 0, 0, "Conviction Engine",     text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                 text_color=color.new(i_buyColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "Conviction",            text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, ct,                      text_color=cc, text_size=size.small)
    table.cell(dash, 0, 2, "Net Vote",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(netScore),  text_color=netScore >= 0 ? i_buyColor : i_sellColor, text_size=size.small)
    table.cell(dash, 0, 3, "Regime",                text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, fRegime == 1 ? "BULL" : fRegime == -1 ? "BEAR" : "-", text_color=fRegime == 1 ? i_buyColor : i_sellColor, text_size=size.small)
    table.cell(dash, 0, 4, "Acceleration",          text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, fAccel == 1 ? "UP" : fAccel == -1 ? "DOWN" : "-", text_color=fAccel == 1 ? i_buyColor : i_sellColor, text_size=size.small)
    table.cell(dash, 0, 5, "Signal",                text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, fSignal == 1 ? "BULL" : fSignal == -1 ? "BEAR" : "-", text_color=fSignal == 1 ? i_buyColor : i_sellColor, text_size=size.small)
    table.cell(dash, 0, 6, "Momentum",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, fMom == 1 ? "BULL" : fMom == -1 ? "BEAR" : "-", text_color=fMom == 1 ? i_buyColor : i_sellColor, text_size=size.small)
    table.cell(dash, 0, 7, "Position",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 8, "Last Signal",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 8, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"CCE","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"conviction":' + str.tostring(conv) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"CCE","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"conviction":' + str.tostring(conv) + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                          "CCE Buy",            "High-conviction long on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                         "CCE Sell",           "High-conviction short on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,            "CCE Any Signal",     "Any CCE signal on {{ticker}} {{interval}}")
alertcondition(netScore == 4 and netScore[1] != 4, "CCE Full Bull",      "All four factors bullish on {{ticker}} {{interval}}")
alertcondition(netScore == -4 and netScore[1] != -4,"CCE Full Bear",     "All four factors bearish on {{ticker}} {{interval}}")
alertcondition(conv >= i_minScore and conv[1] < i_minScore, "CCE Edge On","Conviction reached threshold on {{ticker}} {{interval}}")
alertcondition(bias == 1 and bias[1] != 1,         "CCE Bias Bull",      "Conviction bias turned bullish on {{ticker}} {{interval}}")
alertcondition(bias == -1 and bias[1] != -1,       "CCE Bias Bear",      "Conviction bias turned bearish on {{ticker}} {{interval}}")
alertcondition(crossUp,                            "CCE EMA Up",         "Reclaim EMA crossed up on {{ticker}} {{interval}}")
alertcondition(crossDn,                            "CCE EMA Down",       "Reclaim EMA crossed down on {{ticker}} {{interval}}")
alertcondition(netScore != netScore[1],            "CCE Vote Change",    "Conviction vote changed on {{ticker}} {{interval}}")
alertcondition(ta.cross(rsi, 50),                  "CCE RSI Mid",        "RSI crossed 50 on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,            "CCE Webhook JSON",   "{\"action\":\"signal\",\"indicator\":\"CCE\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
