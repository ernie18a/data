# Mitigation Block Sentinel [forexobroker]

- url: https://www.tradingview.com/script/zh60wRVC-Mitigation-Block-Sentinel-forexobroker/
- type: indicator
- pine_id: PUB;cf6dd77ade0d40d8b149551ab4561a80
- version: 1.0

## Description

Mitigation Block Sentinel [forexobroker] locates mitigation blocks: a bullish block is the last down-close candle before an up-displacement that breaks recent structure, the zone where trapped longs were mitigated and from which price tends to launch again (mirror for bearish). The block arms a directional bias, and entries time off an EMA reclaim inside that bias or a strict block retest in Retest-Only mode. A live dashboard tracks both block zones and the current bias.

🔶 ALGORITHM

1. Compute ATR and the prior N-bar structural high and low (structure lookback).
2. A bullish impulse = up candle whose body >= k x ATR that closes above the prior structural high; bearish is the mirror below the prior structural low.
3. Mitigation-block origin scan: from the impulse, scan back up to the block-scan-back limit for the nearest opposite-close candle; its high/low becomes the block top/bottom.
4. The fresh block is armed; a retest occurs when price trades back into the block extended by a retest buffer of k x ATR.
5. A fresh block arms a persistent directional bias that holds until the opposite block forms.
6. Entry timing: an EMA reclaim (close crossing the entry-reclaim EMA in the block direction), or a strict block retest in Retest-Only Mode.

🔶 SIGNAL LOGIC

- Buy: bias == bullish AND close crosses over the reclaim EMA (or a bullish block retest in Retest-Only Mode), in session, with no active long, cooldown elapsed, and barstate.isconfirmed; position locks long.
- Sell: bias == bearish AND close crosses under the reclaim EMA (or a bearish block retest in Retest-Only Mode), in session, with no active short, cooldown elapsed, and barstate.isconfirmed; position locks short.
Only fires while the persistent block bias agrees with the entry direction.

🔶 INPUTS

- Block group: structure lookback for the high/low the impulse must break (default 10).
- Block group: impulse body multiple of ATR for the launch candle (default 1.0).
- Block group: block scan-back bars to find the origin candle (default 6).
- Block group: retest buffer multiple of ATR (default 0.10) and ATR length (default 14).
- Signal Logic group: entry reclaim EMA length (default 9).
- Signal Logic group: Retest-Only Mode toggle (default off) and cooldown bars (default 5).
- Filters group: restrict-to-session toggle and session window (default 0000-2400).
- Visual group: show block zones, dashboard, and 3-layer glow (all default on).
- Visual group: buy color, sell color, and dashboard background.

🔶 ALERTS

MBS Buy, MBS Sell, MBS Any Signal, MBS Bull Block, MBS Bear Block, MBS Bull Retest, MBS Bear Retest, MBS Any Block, MBS EMA Up, MBS EMA Down, MBS Bias Bull, MBS Bias Bear, MBS Webhook JSON.

🔶 LIMITATIONS

- Needs warm-up bars for ATR and the structural lookback before blocks can form.
- The origin scan only reaches back the block-scan-back limit; a block whose origin sits beyond that window is missed.
- ATR-adaptive defaults are tuned for liquid instruments; thin symbols may need the impulse body multiple retuned.
- The persistent bias holds until an opposite block forms, so it can remain stale through extended ranges.
- Signals confirm on bar close; block zones are redrawn on each new block and are not guaranteed support or resistance.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Mitigation Block Sentinel. A bullish mitigation block is the last down-close candle
// before an up-displacement that breaks recent structure - the zone where trapped longs were
// mitigated and from which price tends to launch again. Mirror for bearish blocks. The block
// arms a directional bias; entries time off an EMA reclaim inside that bias (or a strict block
// retest in Retest-Only mode). Non-repainting: structure & impulse confirmed on bar close.
indicator("Mitigation Block Sentinel [forexobroker]", shorttitle="MBS [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc = "Block"
string g_sig  = "Signal Logic"
string g_filt = "Filters"
string g_vis  = "Visual"

int   i_struct  = input.int(10,   "Structure Lookback",    minval=3,  maxval=60, group=g_calc, tooltip="Bars used for the high/low the impulse must break.")
float i_impK    = input.float(1.0,"Impulse Body x ATR",    minval=0.3, maxval=5.0, step=0.1, group=g_calc, tooltip="The launch candle body must be at least k x ATR.")
int   i_blkScan = input.int(6,    "Block Scan Back",       minval=1,  maxval=20, group=g_calc, tooltip="Bars scanned back from the impulse to find the origin block candle.")
float i_retBuf  = input.float(0.10,"Retest Buffer x ATR",  minval=0.0, maxval=2.0, step=0.05, group=g_calc)
int   i_atrLen  = input.int(14,   "ATR Length",            minval=5,  maxval=50, group=g_calc)
int   i_emaLen  = input.int(9,    "Entry Reclaim EMA",     minval=2,  maxval=50, group=g_sig, tooltip="After a block forms, a close-cross of this EMA in the block direction times the entry.")
bool  i_retOnly = input.bool(false,"Retest-Only Mode",                            group=g_sig, tooltip="On = fire strictly on the block retest (rarer, classic). Off = EMA reclaim inside the active block bias (more signals).")
int   i_cooldown= input.int(5,    "Cooldown Bars",         minval=1,  maxval=40, group=g_sig)
bool  i_useSess = input.bool(false,"Restrict to Session",                          group=g_filt)
string i_sess   = input.session("0000-2400","Session Window",                      group=g_filt)
bool  i_showBox = input.bool(true,"Show Block Zones",                               group=g_vis)
bool  i_showTable=input.bool(true,"Show Dashboard",                                 group=g_vis)
bool  i_showGlow= input.bool(true,"Show 3-Layer Glow",                              group=g_vis)
color i_buyColor= input.color(#3ddc97,"Buy Color",                                  group=g_vis)
color i_sellColor=input.color(#f7768e,"Sell Color",                                 group=g_vis)
color i_dashBg  = input.color(color.new(#071a14, 14),"Dashboard BG",               group=g_vis)

color c_white = #ffffff

float atr   = nz(ta.atr(i_atrLen), 0.0)
float hiN   = ta.highest(high, i_struct)[1]
float loN   = ta.lowest(low,  i_struct)[1]
float body  = math.abs(close - open)
bool  inSession = not i_useSess or not na(time(timeframe.period, i_sess))

bool impUp   = atr > 0 and close > open and body >= i_impK * atr and close > hiN
bool impDown = atr > 0 and close < open and body >= i_impK * atr and close < loN

// Origin block = nearest opposite-close candle before the impulse
var float buBlkTop = na
var float buBlkBot = na
var int   buBlkSt  = 0   // 0 none, 1 armed, 2 retested
var float beBlkTop = na
var float beBlkBot = na
var int   beBlkSt  = 0
var int   blocksFound = 0

if impUp
    float t = na
    float b = na
    for k = 1 to i_blkScan
        if close[k] < open[k] and na(t)
            t := high[k]
            b := low[k]
    if not na(t)
        buBlkTop := t
        buBlkBot := b
        buBlkSt  := 1
        blocksFound += 1
if impDown
    float t = na
    float b = na
    for k = 1 to i_blkScan
        if close[k] > open[k] and na(t)
            t := high[k]
            b := low[k]
    if not na(t)
        beBlkTop := t
        beBlkBot := b
        beBlkSt  := 1
        blocksFound += 1

float buf = i_retBuf * atr
bool buRetest = buBlkSt == 1 and not na(buBlkTop) and low <= buBlkTop + buf and high >= buBlkBot - buf
bool beRetest = beBlkSt == 1 and not na(beBlkTop) and high >= beBlkBot - buf and low <= beBlkTop + buf
if buRetest
    buBlkSt := 2
if beRetest
    beBlkSt := 2

// A fresh block arms a persistent bias until the opposite block forms.
var int bias = 0
if impUp
    bias := 1
if impDown
    bias := -1
float emaFast = ta.ema(close, i_emaLen)
bool  crossUp = ta.crossover(close, emaFast)
bool  crossDn = ta.crossunder(close, emaFast)
bool entryUp   = inSession and (i_retOnly ? buRetest : (bias ==  1 and crossUp))
bool entryDown = inSession and (i_retOnly ? beRetest : (bias == -1 and crossDn))

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
if i_showBox and impUp and not na(buBlkTop)
    box.delete(buBox)
    buBox := box.new(math.max(0, bar_index - i_blkScan), buBlkTop, bar_index + 20, buBlkBot, border_color=color.new(i_buyColor, 25), bgcolor=color.new(i_buyColor, 84))
if i_showBox and impDown and not na(beBlkTop)
    box.delete(beBox)
    beBox := box.new(math.max(0, bar_index - i_blkScan), beBlkTop, bar_index + 20, beBlkBot, border_color=color.new(i_sellColor, 25), bgcolor=color.new(i_sellColor, 84))

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.square, location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.square, location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy",         shape.square, location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="MBS", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.square, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.square, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell",        shape.square, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="MBS", textcolor=c_white)

barcolor(impUp ? i_buyColor : impDown ? i_sellColor : na)
bgcolor(bias == 1 ? color.new(i_buyColor, 94) : bias == -1 ? color.new(i_sellColor, 94) : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=i_dashBg, border_color=color.new(i_buyColor, 50), border_width=1)
    string bt = bias == 1 ? "BULL BLOCK" : bias == -1 ? "BEAR BLOCK" : "NEUTRAL"
    color  bc = bias == 1 ? i_buyColor : bias == -1 ? i_sellColor : color.gray
    table.cell(dash, 0, 0, "Mitigation Block",      text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                 text_color=color.new(i_buyColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "Bias",                  text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, bt,                      text_color=bc, text_size=size.small)
    table.cell(dash, 0, 2, "Bull Block",            text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, na(buBlkTop) ? "-" : str.tostring(buBlkBot, "#.##") + "-" + str.tostring(buBlkTop, "#.##"), text_color=i_buyColor, text_size=size.small)
    table.cell(dash, 0, 3, "Bear Block",            text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, na(beBlkTop) ? "-" : str.tostring(beBlkBot, "#.##") + "-" + str.tostring(beBlkTop, "#.##"), text_color=i_sellColor, text_size=size.small)
    table.cell(dash, 0, 4, "Blocks Found",          text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(blocksFound), text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 5, "ATR",                   text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(atr, "#.#####"), text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 6, "Position",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"MBS","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"MBS","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                          "MBS Buy",            "Bullish mitigation block entry on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                         "MBS Sell",           "Bearish mitigation block entry on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,            "MBS Any Signal",     "Any MBS signal on {{ticker}} {{interval}}")
alertcondition(impUp,                              "MBS Bull Block",     "Bullish mitigation block formed on {{ticker}} {{interval}}")
alertcondition(impDown,                            "MBS Bear Block",     "Bearish mitigation block formed on {{ticker}} {{interval}}")
alertcondition(buRetest,                           "MBS Bull Retest",    "Bullish block retested on {{ticker}} {{interval}}")
alertcondition(beRetest,                           "MBS Bear Retest",    "Bearish block retested on {{ticker}} {{interval}}")
alertcondition(impUp or impDown,                   "MBS Any Block",      "Any mitigation block formed on {{ticker}} {{interval}}")
alertcondition(crossUp,                            "MBS EMA Up",         "Reclaim EMA crossed up on {{ticker}} {{interval}}")
alertcondition(crossDn,                            "MBS EMA Down",       "Reclaim EMA crossed down on {{ticker}} {{interval}}")
alertcondition(bias == 1 and bias[1] != 1,         "MBS Bias Bull",      "Block bias turned bullish on {{ticker}} {{interval}}")
alertcondition(bias == -1 and bias[1] != -1,       "MBS Bias Bear",      "Block bias turned bearish on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,            "MBS Webhook JSON",   "{\"action\":\"signal\",\"indicator\":\"MBS\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
