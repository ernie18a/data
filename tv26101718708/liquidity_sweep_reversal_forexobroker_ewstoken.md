# Liquidity Sweep Reversal [forexobroker]

- url: https://www.tradingview.com/script/EWSTOkEN-Liquidity-Sweep-Reversal-forexobroker/
- type: indicator
- pine_id: PUB;044fcec0a04a496487e4ab8f030d21ab
- version: 1.0

## Description

Liquidity Sweep Reversal [forexobroker] detects stop-hunt sweeps: price wicks past a confirmed swing extreme to grab resting liquidity but the bar closes back inside, trapping breakout traders. The unique angle is ATR-scaled depth bounds (a minimum to filter noise and a maximum to reject genuine breaks) plus a persistent reversal bias armed by the sweep, with entries timed on an EMA reclaim instead of only the rarer classic sweep bar.

🔶 ALGORITHM

1. Confirm swing structure with symmetric pivots (ta.pivothigh / ta.pivotlow), tracking the latest confirmed swing high and swing low.
2. Detect a bullish sweep: low pierces the swing low by at least Min Sweep Depth x ATR but no more than Max Sweep Depth x ATR, and close finishes back above the swing low (optionally requiring a bullish reversal body). Bearish sweep is the mirror.
3. The maximum-depth bound rejects runaway moves that are real breaks rather than stop hunts.
4. Persistent reversal bias: a bullish sweep arms bias +1, a bearish sweep arms bias -1, holding until the opposite side sweeps.
5. Entry timing: within an active sweep bias, an EMA reclaim (ta.crossover / ta.crossunder of close vs the Entry Reclaim EMA) fires the trade. Sweep-Only Mode swaps this for the strict sweep+reclaim bar.

🔶 SIGNAL LOGIC

- Buy: bullish sweep bias active (swing low swept and reclaimed) and close crosses over the Entry Reclaim EMA (or, in Sweep-Only Mode, the sweep bar itself), in session, position not already long, after the cooldown window, only on barstate.isconfirmed; position-lock flips to LONG.
- Sell: bearish sweep bias active (swing high swept and reclaimed) and close crosses under the Entry Reclaim EMA (or the sweep bar itself), in session, position not already short, cooldown elapsed, on barstate.isconfirmed; position-lock flips to SHORT.
Only fires when a confirmed sweep has armed the matching reversal bias.

🔶 INPUTS

- Liquidity: pivot length for swing confirmation (default 6) and ATR length.
- Sweep depth: minimum sweep depth in ATR multiples (default 0.20x ATR) and maximum sweep depth to reject real breaks (default 3.0x ATR).
- Reclaim validity: reclaim-within-bars window and require-reversal-body toggle (default on).
- Signal Logic: Entry Reclaim EMA length (default 9) and Sweep-Only Mode toggle (default off).
- Cooldown: minimum bars between signals (default 5).
- Filters: optional session restriction with a session window.
- Visual: swept-level lines, dashboard, 3-layer glow, buy/sell colors, dashboard background.

🔶 ALERTS

LSR Buy, LSR Sell, LSR Any Signal, LSR Low Swept, LSR High Swept, LSR New Swing High, LSR New Swing Low, LSR Low Pierce, LSR High Pierce, LSR Any Sweep, LSR Sweep Tick, LSR Strong Bull, LSR Webhook JSON.

🔶 LIMITATIONS

- Requires warm-up: pivots confirm only after Pivot Length bars on each side, so early history produces no sweep targets.
- Defaults (ATR 14, min 0.20x, max 3.0x) are tuned for liquid instruments; volatile or thin symbols may need wider depth bounds.
- Sweep-Only Mode is intentionally rare; the default EMA-reclaim regime mode trades more frequently.
- Non-repainting by design (pivots confirmed, signal on bar close); the swing being swept appears Pivot Length bars after it formed.
- A sweep is a probabilistic trap, not a guaranteed reversal; in strong trends a level can be swept and continue rather than reverse.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Liquidity Sweep Reversal. Resting liquidity sits beyond confirmed swing pivots
// (stop clusters). A sweep occurs when price wicks past a prior swing extreme but the bar CLOSES
// back inside it — a stop-hunt that traps breakout traders. A sweep below a swing low that closes
// back above = bullish reversal; a sweep above a swing high that closes back below = bearish.
// ATR-scaled minimum wick depth filters noise. Non-repainting: pivots confirmed, signal on close.
indicator("Liquidity Sweep Reversal [forexobroker]", shorttitle="LSR [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc = "Liquidity"
string g_sig  = "Signal Logic"
string g_filt = "Filters"
string g_vis  = "Visual"

int   i_piv     = input.int(6,    "Pivot Length",          minval=2,  maxval=30, group=g_calc, tooltip="Bars each side to confirm the swing whose liquidity gets swept.")
float i_minWick = input.float(0.20,"Min Sweep Depth x ATR", minval=0.0, maxval=3.0, step=0.05, group=g_calc, tooltip="Wick must pierce the swing by at least k x ATR.")
float i_maxWick = input.float(3.0,"Max Sweep Depth x ATR",  minval=0.5, maxval=10.0, step=0.5, group=g_calc, tooltip="Reject runaway breaks (not a sweep, a real break).")
int   i_atrLen  = input.int(14,   "ATR Length",            minval=5,  maxval=50, group=g_calc)
int   i_validBars=input.int(3,    "Reclaim Within Bars",   minval=1,  maxval=10, group=g_calc, tooltip="Close must reclaim the level within this many bars of the wick.")
bool  i_needBody= input.bool(true,"Require Reversal Body",                       group=g_calc, tooltip="Confirmation bar must close in the reversal direction.")
int   i_emaLen  = input.int(9,    "Entry Reclaim EMA",     minval=2,  maxval=50, group=g_sig, tooltip="After a sweep arms a reversal bias, a close-cross of this EMA in that direction times the entry.")
bool  i_retOnly = input.bool(false,"Sweep-Only Mode",                            group=g_sig, tooltip="On = fire strictly on the sweep+reclaim bar (rarer, classic). Off = EMA reclaim inside the active sweep bias (more signals).")
int   i_cooldown= input.int(5,    "Cooldown Bars",         minval=1,  maxval=40, group=g_sig)
bool  i_useSess = input.bool(false,"Restrict to Session",                        group=g_filt)
string i_sess   = input.session("0000-2400","Session Window",                   group=g_filt)
bool  i_showLvl = input.bool(true,"Show Swept Levels",                           group=g_vis)
bool  i_showTable=input.bool(true,"Show Dashboard",                              group=g_vis)
bool  i_showGlow= input.bool(true,"Show 3-Layer Glow",                           group=g_vis)
color i_buyColor= input.color(#34d399,"Buy Color",                               group=g_vis)
color i_sellColor=input.color(#f87171,"Sell Color",                              group=g_vis)
color i_dashBg  = input.color(color.new(#06181a, 16),"Dashboard BG",             group=g_vis)

color c_white = #ffffff

float atr  = nz(ta.atr(i_atrLen), 0.0)
float ph   = ta.pivothigh(high, i_piv, i_piv)
float pl   = ta.pivotlow(low,   i_piv, i_piv)
var float swHigh = na
var float swLow  = na
if not na(ph)
    swHigh := ph
if not na(pl)
    swLow := pl

float minD = i_minWick * atr
float maxD = i_maxWick * atr

bool sweptLow  = not na(swLow)  and low  < swLow  - minD and low  > swLow  - maxD and close > swLow  and (not i_needBody or close > open)
bool sweptHigh = not na(swHigh) and high > swHigh + minD and high < swHigh + maxD and close < swHigh and (not i_needBody or close < open)
bool inSession = not i_useSess or not na(time(timeframe.period, i_sess))

// A confirmed sweep arms a persistent reversal bias until the opposite side sweeps.
var int bias = 0
if sweptLow
    bias := 1
if sweptHigh
    bias := -1
float emaFast = ta.ema(close, i_emaLen)
bool  crossUp = ta.crossover(close, emaFast)
bool  crossDn = ta.crossunder(close, emaFast)
bool entryUp   = inSession and (i_retOnly ? sweptLow  : (bias ==  1 and crossUp))
bool entryDown = inSession and (i_retOnly ? sweptHigh : (bias == -1 and crossDn))

var int posState      = 0
var int lastSignalBar = 0
var int sweepCount     = 0
bool cooldownOk = (bar_index - lastSignalBar) >= i_cooldown
bool confirmed  = barstate.isconfirmed
bool buySignal  = entryUp   and posState <= 0 and cooldownOk and confirmed
bool sellSignal = entryDown and posState >= 0 and cooldownOk and confirmed
if buySignal
    posState := 1
    lastSignalBar := bar_index
    sweepCount += 1
if sellSignal
    posState := -1
    lastSignalBar := bar_index
    sweepCount += 1

var line lvlLine = na
if i_showLvl and sweptLow and not na(swLow)
    line.delete(lvlLine)
    lvlLine := line.new(math.max(0, bar_index - 1), swLow, bar_index + 10, swLow, color=color.new(i_buyColor, 0), width=2, style=line.style_dashed)
if i_showLvl and sweptHigh and not na(swHigh)
    line.delete(lvlLine)
    lvlLine := line.new(math.max(0, bar_index - 1), swHigh, bar_index + 10, swHigh, color=color.new(i_sellColor, 0), width=2, style=line.style_dashed)

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.xcross, location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.xcross, location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy",         shape.xcross, location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="LSR", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.xcross, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.xcross, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell",        shape.xcross, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="LSR", textcolor=c_white)

barcolor(sweptLow ? i_buyColor : sweptHigh ? i_sellColor : na)
bgcolor(bias == 1 ? color.new(i_buyColor, 94) : bias == -1 ? color.new(i_sellColor, 94) : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=i_dashBg, border_color=color.new(i_buyColor, 55), border_width=1)
    string st = sweptLow ? "SWEEP LOW (BULL)" : sweptHigh ? "SWEEP HIGH (BEAR)" : "MONITORING"
    color  sc = sweptLow ? i_buyColor : sweptHigh ? i_sellColor : color.gray
    table.cell(dash, 0, 0, "Liquidity Sweep Reversal", text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                    text_color=color.new(i_buyColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "State",                    text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, st,                         text_color=sc, text_size=size.small)
    table.cell(dash, 0, 2, "Swing High",               text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, na(swHigh) ? "-" : str.tostring(swHigh, "#.##"), text_color=i_sellColor, text_size=size.small)
    table.cell(dash, 0, 3, "Swing Low",                text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, na(swLow) ? "-" : str.tostring(swLow, "#.##"), text_color=i_buyColor, text_size=size.small)
    table.cell(dash, 0, 4, "Sweeps",                   text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(sweepCount),   text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 5, "Min Depth",                text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(minD, "#.#####"), text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 6, "Position",                 text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"LSR","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"LSR","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                          "LSR Buy",           "Bullish liquidity sweep on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                         "LSR Sell",          "Bearish liquidity sweep on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,            "LSR Any Signal",    "Any LSR signal on {{ticker}} {{interval}}")
alertcondition(sweptLow,                           "LSR Low Swept",     "Swing low liquidity swept on {{ticker}} {{interval}}")
alertcondition(sweptHigh,                          "LSR High Swept",    "Swing high liquidity swept on {{ticker}} {{interval}}")
alertcondition(not na(ph),                         "LSR New Swing High","New swing high formed on {{ticker}} {{interval}}")
alertcondition(not na(pl),                         "LSR New Swing Low", "New swing low formed on {{ticker}} {{interval}}")
alertcondition(low < nz(swLow, low) - minD,        "LSR Low Pierce",    "Price piercing swing low on {{ticker}} {{interval}}")
alertcondition(high > nz(swHigh, high) + minD,     "LSR High Pierce",   "Price piercing swing high on {{ticker}} {{interval}}")
alertcondition(sweptLow or sweptHigh,              "LSR Any Sweep",     "Any liquidity sweep on {{ticker}} {{interval}}")
alertcondition(sweepCount >= 1 and sweepCount != sweepCount[1], "LSR Sweep Tick","Sweep counter advanced on {{ticker}} {{interval}}")
alertcondition(close > open and sweptLow,          "LSR Strong Bull",   "Strong bull sweep body on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,            "LSR Webhook JSON",  "{\"action\":\"signal\",\"indicator\":\"LSR\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
