# Fibonacci Time Window [forexobroker]

- url: https://www.tradingview.com/script/eSPS2ytY-Fibonacci-Time-Window-forexobroker/
- type: indicator
- pine_id: PUB;a7d2f5ba6ff841268bf9f72b81c778c7
- version: 1.0

## Description

Fibonacci Time Window [forexobroker] projects expected reversal-time windows by taking the bar-distance between the last two confirmed swing pivots as a base cycle and extending it forward by Fibonacci ratios. The unique angle is that it works on the time axis rather than the price axis: signals only arm when price is inside a projected Fib time window and a reclaim-EMA cross aligns with the trend.

🔶 ALGORITHM

1. Detect confirmed swing pivots with ta.pivothigh / ta.pivotlow over the pivot length (lag of pivot-length bars by construction, so non-repainting).
2. Base cycle = bar-distance between the two most recent confirmed pivots.
3. Project three forward time targets from the latest pivot bar: pivot bar + round(base cycle x ratio) for Fib Ratio 1 (1.0), Fib Ratio 2 (1.618), and Fib Ratio 3 (2.618).
4. A time window is open when the current bar is within Window Tolerance bars of any of the three projected targets.
5. Directional bias inside a window comes from price vs the trend EMA (above = up, below = down).
6. Entry timing: while in a window and aligned with the trend direction, a close crossover (long) or crossunder (short) of the reclaim EMA fires the signal. Cooldown, position-lock, and bar-close confirmation apply.

🔶 SIGNAL LOGIC

- Buy: in-session AND price inside a projected Fib time window AND trend direction = up AND close crosses over the reclaim EMA AND position not already long AND cooldown elapsed AND barstate.isconfirmed (then position locks long).
- Sell: in-session AND price inside a projected Fib time window AND trend direction = down AND close crosses under the reclaim EMA AND position not already short AND cooldown elapsed AND barstate.isconfirmed (then position locks short).
- Only fires while price is inside one of the three projected Fibonacci time windows.

🔶 INPUTS

- Time Cycle group: bars each side to confirm swing pivots that set the base cycle; default Pivot Length 8.
- Fib ratios: three time-projection multipliers of the base cycle; defaults Fib Ratio 1 1.0, Fib Ratio 2 1.618, Fib Ratio 3 2.618.
- Window tolerance: bars of slack around each projected time target; default Window Tolerance 2.
- Trend EMA: defines directional bias inside a window; default Trend EMA 34.
- Volatility reference: ATR length for window-line height and dashboard; default ATR Length 14.
- Signal Logic group: entry reclaim EMA and cooldown; default Entry Reclaim EMA 9.
- Cooldown: minimum bars between signals; default Cooldown Bars 5.
- Filters group: optional session restriction and session window; default Restrict to Session off.
- Visual group: time-window lines, dashboard, 3-layer glow, buy/sell colors, dashboard background.

🔶 ALERTS

FTW Buy, FTW Sell, FTW Any Signal, FTW Window Open, FTW Window Close, FTW Window 1, FTW Window 1.618, FTW Window 2.618, FTW New Pivot Hi, FTW New Pivot Lo, FTW EMA Up, FTW EMA Down, FTW Webhook JSON.

🔶 LIMITATIONS

- Swing pivots are confirmed with a lag of Pivot Length bars, so the base cycle and projected windows update only after that confirmation delay.
- The script needs at least two confirmed pivots before any time window can be projected, so early bars are a warm-up "warming up" state.
- Fibonacci time windows quantise to integer bars via rounding, so projected targets snap to whole-bar positions.
- Time-cycle projection is a heuristic timing aid, not a forecast; a window marks elevated reversal odds, not a guaranteed turn.
- Default pivot and ratio settings are tuned for liquid instruments; entries confirm on bar close, adding one-bar lag versus intrabar price.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Fibonacci Time Window. Markets tend to turn not only at Fib PRICE levels but at
// Fib TIME intervals. The bar-distance between the last two confirmed swing pivots is the base
// cycle; it is projected forward by Fibonacci ratios (1.0, 1.618, 2.618) to mark expected
// reversal-time windows. A signal fires only when price is inside a projected time window AND
// a reclaim-EMA cross aligns with the prevailing trend. Non-repainting: pivots confirmed.
indicator("Fibonacci Time Window [forexobroker]", shorttitle="FTW [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc = "Time Cycle"
string g_sig  = "Signal Logic"
string g_filt = "Filters"
string g_vis  = "Visual"

int   i_piv     = input.int(8,    "Pivot Length",          minval=2,  maxval=40, group=g_calc, tooltip="Bars each side to confirm the swing pivots that set the base cycle.")
float i_fib1    = input.float(1.0,"Fib Ratio 1",           minval=0.5, maxval=5.0, step=0.1, group=g_calc)
float i_fib2    = input.float(1.618,"Fib Ratio 2",         minval=0.5, maxval=5.0, step=0.001, group=g_calc)
float i_fib3    = input.float(2.618,"Fib Ratio 3",         minval=0.5, maxval=5.0, step=0.001, group=g_calc)
int   i_tol     = input.int(2,    "Window Tolerance",      minval=0,  maxval=10, group=g_calc, tooltip="Bars of slack around each projected time window.")
int   i_trendEma= input.int(34,   "Trend EMA",             minval=5,  maxval=200, group=g_calc, tooltip="Defines the directional bias inside a time window.")
int   i_atrLen  = input.int(14,   "ATR Length",            minval=5,  maxval=50, group=g_calc)
int   i_emaLen  = input.int(9,    "Entry Reclaim EMA",     minval=2,  maxval=50, group=g_sig, tooltip="Inside a time window, a close-cross of this EMA in the trend direction times the entry.")
int   i_cooldown= input.int(5,    "Cooldown Bars",         minval=1,  maxval=40, group=g_sig)
bool  i_useSess = input.bool(false,"Restrict to Session",                         group=g_filt)
string i_sess   = input.session("0000-2400","Session Window",                     group=g_filt)
bool  i_showLn  = input.bool(true,"Show Time Windows",                             group=g_vis)
bool  i_showTable=input.bool(true,"Show Dashboard",                                group=g_vis)
bool  i_showGlow= input.bool(true,"Show 3-Layer Glow",                             group=g_vis)
color i_buyColor= input.color(#c8b6ff,"Buy Color",                                 group=g_vis)
color i_sellColor=input.color(#ffafcc,"Sell Color",                                group=g_vis)
color i_dashBg  = input.color(color.new(#160a26, 14),"Dashboard BG",              group=g_vis)

color c_white = #ffffff

float atr = nz(ta.atr(i_atrLen), 0.0)
float ph  = ta.pivothigh(high, i_piv, i_piv)
float pl  = ta.pivotlow(low,   i_piv, i_piv)

var int pivBar = na
var int prevPivBar = na
var int baseDur = 0
if not na(ph) or not na(pl)
    prevPivBar := pivBar
    pivBar := bar_index - i_piv
    if not na(prevPivBar)
        baseDur := pivBar - prevPivBar

var int t1 = na
var int t2 = na
var int t3 = na
if baseDur > 0 and (not na(ph) or not na(pl))
    t1 := pivBar + int(math.round(baseDur * i_fib1))
    t2 := pivBar + int(math.round(baseDur * i_fib2))
    t3 := pivBar + int(math.round(baseDur * i_fib3))

bool nearT1 = not na(t1) and math.abs(bar_index - t1) <= i_tol
bool nearT2 = not na(t2) and math.abs(bar_index - t2) <= i_tol
bool nearT3 = not na(t3) and math.abs(bar_index - t3) <= i_tol
bool inWindow = nearT1 or nearT2 or nearT3
bool  inSession = not i_useSess or not na(time(timeframe.period, i_sess))

float trend   = ta.ema(close, i_trendEma)
int   tdir    = close > trend ? 1 : close < trend ? -1 : 0
float emaFast = ta.ema(close, i_emaLen)
bool  crossUp = ta.crossover(close, emaFast)
bool  crossDn = ta.crossunder(close, emaFast)
bool entryUp   = inSession and inWindow and tdir ==  1 and crossUp
bool entryDown = inSession and inWindow and tdir == -1 and crossDn

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

var line l1 = na
var line l2 = na
var line l3 = na
float yLo = close - 4.0 * atr
float yHi = close + 4.0 * atr
if i_showLn and baseDur > 0 and (not na(ph) or not na(pl))
    line.delete(l1)
    line.delete(l2)
    line.delete(l3)
    l1 := line.new(t1, yLo, t1, yHi, color=color.new(i_buyColor, 30), width=1, style=line.style_dashed)
    l2 := line.new(t2, yLo, t2, yHi, color=color.new(#f4d35e, 30), width=1, style=line.style_dashed)
    l3 := line.new(t3, yLo, t3, yHi, color=color.new(i_sellColor, 30), width=1, style=line.style_dashed)

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.cross, location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.cross, location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy",         shape.cross, location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="FTW", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.cross, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.cross, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell",        shape.cross, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="FTW", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(inWindow ? color.new(#f4d35e, 88) : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=i_dashBg, border_color=color.new(i_buyColor, 50), border_width=1)
    string st = inWindow ? "IN TIME WINDOW" : not na(t1) ? "AWAITING WINDOW" : "WARMING UP"
    color  sc = inWindow ? #f4d35e : not na(t1) ? color.silver : color.gray
    table.cell(dash, 0, 0, "Fibonacci Time Window", text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                 text_color=color.new(i_buyColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "State",                 text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, st,                      text_color=sc, text_size=size.small)
    table.cell(dash, 0, 2, "Base Cycle",            text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(baseDur) + "b", text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 3, "Next Window",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, na(t1) ? "-" : str.tostring(math.max(0, (nearT1 ? t1 : nearT2 ? t2 : t3) - bar_index)) + "b", text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 4, "Trend Dir",             text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, tdir == 1 ? "UP" : tdir == -1 ? "DOWN" : "FLAT", text_color=tdir == 1 ? i_buyColor : tdir == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 5, "ATR",                   text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(atr, "#.#####"), text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 6, "Position",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"FTW","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"FTW","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                          "FTW Buy",            "Time-window long on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                         "FTW Sell",           "Time-window short on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,            "FTW Any Signal",     "Any FTW signal on {{ticker}} {{interval}}")
alertcondition(inWindow and not inWindow[1],       "FTW Window Open",    "Entered a Fib time window on {{ticker}} {{interval}}")
alertcondition(not inWindow and inWindow[1],       "FTW Window Close",   "Left a Fib time window on {{ticker}} {{interval}}")
alertcondition(nearT1,                             "FTW Window 1",       "In the 1.0 time window on {{ticker}} {{interval}}")
alertcondition(nearT2,                             "FTW Window 1.618",   "In the 1.618 time window on {{ticker}} {{interval}}")
alertcondition(nearT3,                             "FTW Window 2.618",   "In the 2.618 time window on {{ticker}} {{interval}}")
alertcondition(not na(ph),                         "FTW New Pivot Hi",   "New swing high pivot on {{ticker}} {{interval}}")
alertcondition(not na(pl),                         "FTW New Pivot Lo",   "New swing low pivot on {{ticker}} {{interval}}")
alertcondition(crossUp,                            "FTW EMA Up",         "Reclaim EMA crossed up on {{ticker}} {{interval}}")
alertcondition(crossDn,                            "FTW EMA Down",       "Reclaim EMA crossed down on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,            "FTW Webhook JSON",   "{\"action\":\"signal\",\"indicator\":\"FTW\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
