# Breaker Block Reversal Engine [forexobroker]

- url: https://www.tradingview.com/script/5msciWFP-Breaker-Block-Reversal-Engine-forexobroker/
- type: indicator
- pine_id: PUB;430df5fe915f4ee2bf5c8f46130ac58b
- version: 1.0

## Description

Breaker Block Reversal Engine [forexobroker] trades the polarity flip of a failed order block: when price closes straight through an order block instead of respecting it, that zone flips polarity and the level that trapped one side now fuels the other. The unique angle is treating the flip as a persistent regime, then timing entries with an EMA reclaim inside the active breaker bias rather than waiting only for the rarer classic retest.

🔶 ALGORITHM

1. Confirm swing structure with symmetric pivots and track the most recent confirmed swing high and low.
2. Detect a structural break: close crosses the last confirmed swing low (down break) or swing high (up break).
3. Find the origin candle by scanning back up to OB Search Lookback bars for the last opposing candle; validate the impulse with Min Impulse x ATR.
4. Polarity flip: a bearish origin OB becomes a BULLISH breaker once the break reference (close or high) closes above its top; a bullish origin OB becomes a BEAR breaker once price closes below its bottom. Confirm-on-close toggle controls strictness.
5. Retest detection uses a Retest Buffer x ATR tolerance band drawn around the flipped breaker.
6. Persistent breaker bias: a flip arms bias +1 / -1; the regime clears when that breaker is retested (one-shot) or the opposite breaker flips.
7. Entry timing: within an active breaker bias, an EMA reclaim (ta.crossover / ta.crossunder of close vs the Entry Reclaim EMA) fires the trade. Retest-Only Mode swaps this for the strict breaker-zone retest.

🔶 SIGNAL LOGIC

- Buy: a bear order block has flipped to a bull breaker (bias +1) and close crosses over the Entry Reclaim EMA (or, in Retest-Only Mode, the bull breaker retest), in session, position not already long, after the cooldown window, only on barstate.isconfirmed; position-lock flips to LONG.
- Sell: a bull order block has flipped to a bear breaker (bias -1) and close crosses under the Entry Reclaim EMA (or the bear breaker retest), in session, position not already short, cooldown elapsed, on barstate.isconfirmed; position-lock flips to SHORT.
Only fires when a breaker has flipped polarity and set directional bias.

🔶 INPUTS

- Structure: pivot length for swing confirmation (default 7), OB search lookback, and ATR length.
- Impulse filter: minimum impulse in ATR multiples to qualify the origin (default 1.0x ATR).
- Retest tolerance: buffer added around the breaker on retest in ATR multiples (default 0.10x ATR).
- Break confirmation: confirm-on-close toggle for the polarity flip (default on).
- Signal Logic: Entry Reclaim EMA length (default 9) and Retest-Only Mode toggle (default off).
- Cooldown: minimum bars between signals (default 6).
- Filters: optional session restriction and one-signal-per-breaker lock (default on).
- Visual: breaker zone boxes, dashboard, 3-layer glow, buy/sell colors, dashboard background.

🔶 ALERTS

BBR Buy, BBR Sell, BBR Any Signal, BBR Down Break, BBR Up Break, BBR Bull Flip, BBR Bear Flip, BBR Bull Retest, BBR Bear Retest, BBR Bull OB Set, BBR Bear OB Set, BBR Structure, BBR Webhook JSON.

🔶 LIMITATIONS

- Requires warm-up: pivots confirm only after Pivot Length bars on each side, so early history yields no structure.
- Defaults are tuned for liquid instruments; the impulse and retest-buffer ATR multiples may need adjustment on thin symbols.
- Retest-Only Mode is intentionally rare; the default EMA-reclaim regime mode trades more frequently.
- Non-repainting by design (pivots confirmed, signals on bar close); the anchoring swing appears Pivot Length bars after it formed.
- A breaker is a probabilistic zone, not a guaranteed reversal; polarity flips can fail in strong trends.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Breaker Block Reversal Engine. A breaker block is an order block that FAILED: price
// closed straight through it instead of respecting it. The failed bearish OB (last up-candle
// before a down move) becomes a BULLISH breaker once price closes above its top — it then acts as
// support on the next retest from above. Mirror logic for bearish breakers. Polarity flip is the
// edge: the zone that trapped one side now fuels the other. Non-repainting: pivots confirmed,
// signals on bar close, ATR-filtered impulse. Signals consume their bias so the engine immediately
// re-arms for the next setup instead of locking on a single regime.
indicator("Breaker Block Reversal Engine [forexobroker]", shorttitle="BBR [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc = "Structure"
string g_sig  = "Signal Logic"
string g_filt = "Filters"
string g_vis  = "Visual"

int   i_piv     = input.int(5,    "Pivot Length",         minval=2,  maxval=30, group=g_calc, tooltip="Bars each side for swing pivot confirmation. Lower = more frequent structural breaks.")
int   i_obLook  = input.int(20,   "OB Search Lookback",   minval=2,  maxval=50, group=g_calc, tooltip="Bars scanned back to locate the origin candle.")
float i_impAtr  = input.float(0.5,"Min Impulse x ATR",    minval=0.0, maxval=5.0, step=0.1, group=g_calc, tooltip="Required distance (in ATR) from OB origin to current close on the break. 0 disables the filter.")
int   i_atrLen  = input.int(14,   "ATR Length",           minval=5,  maxval=50, group=g_calc)
float i_retBuf  = input.float(0.25,"Retest Buffer x ATR", minval=0.0, maxval=2.0, step=0.05, group=g_calc, tooltip="Tolerance added around the breaker on retest.")
int   i_maxAge  = input.int(120,  "Breaker Max Age (bars)", minval=10, maxval=500, group=g_calc, tooltip="Stale breakers/bias are cleared after this many bars without a signal, so the engine can re-arm on fresh structure.")
bool  i_clsBrk  = input.bool(true,"Confirm Flip on Close", group=g_calc, tooltip="On = polarity flips only when CLOSE passes through. Off = wick-touch flip (more aggressive).")
string i_trig   = input.string("Either (Recommended)", "Signal Trigger", options=["Either (Recommended)", "Retest Only", "EMA Reclaim Only"], group=g_sig, tooltip="Either = fires on whichever happens first — breaker-zone retest OR EMA reclaim during bias.")
int   i_emaLen  = input.int(9,    "Entry Reclaim EMA",    minval=2,  maxval=50, group=g_sig, tooltip="After a breaker flips, a close-cross of this EMA in the breaker direction times the entry.")
int   i_cooldown= input.int(10,   "Cooldown Bars",        minval=1,  maxval=200, group=g_sig)
bool  i_useSess = input.bool(false,"Restrict to Session", group=g_filt)
string i_sess   = input.session("0000-2400","Session Window", group=g_filt)
bool  i_showBox = input.bool(true,"Show Breaker Zones",   group=g_vis)
bool  i_showTable=input.bool(true,"Show Dashboard",       group=g_vis)
bool  i_showGlow= input.bool(true,"Show 3-Layer Glow",    group=g_vis)
color i_buyColor= input.color(#00c2a8,"Buy Color",        group=g_vis)
color i_sellColor=input.color(#ff5d6c,"Sell Color",       group=g_vis)
color i_dashBg  = input.color(color.new(#0a0820, 16),"Dashboard BG", group=g_vis)

color c_white = #ffffff

float atr  = nz(ta.atr(i_atrLen), 0.0)
float ph   = ta.pivothigh(high, i_piv, i_piv)
float pl   = ta.pivotlow(low,   i_piv, i_piv)
var float lastPH = na
var float lastPL = na
if not na(ph)
    lastPH := ph
if not na(pl)
    lastPL := pl

bool downBreak = not na(lastPL) and close < lastPL and close[1] >= lastPL
bool upBreak   = not na(lastPH) and close > lastPH and close[1] <= lastPH
bool inSession = not i_useSess or not na(time(timeframe.period, i_sess))

// Bear OB origin = last up-candle before a down break (will become a BULL breaker once reclaimed).
var float bbTop    = na
var float bbBot    = na
var int   bbState  = 0   // 0 none, 1 OB formed (pre-flip), 2 flipped to bull breaker, 3 retested
var int   bbBorn   = 0
var float sbTop    = na
var float sbBot    = na
var int   sbState  = 0
var int   sbBorn   = 0
var int   breakersFlipped = 0

int obLookSafe = math.min(i_obLook, bar_index)
if downBreak
    float t = na
    float b = na
    if obLookSafe >= 1
        for k = 1 to obLookSafe
            if close[k] > open[k] and na(t)
                t := high[k]
                b := low[k]
    if not na(t) and (b - close) >= i_impAtr * atr
        bbTop := t
        bbBot := b
        bbState := 1
        bbBorn := bar_index
if upBreak
    float t = na
    float b = na
    if obLookSafe >= 1
        for k = 1 to obLookSafe
            if close[k] < open[k] and na(t)
                t := high[k]
                b := low[k]
    if not na(t) and (close - t) >= i_impAtr * atr
        sbTop := t
        sbBot := b
        sbState := 1
        sbBorn := bar_index

// Age out stale state so the engine cannot lock up indefinitely on a single zone.
if bbState > 0 and (bar_index - bbBorn) > i_maxAge
    bbState := 0
    bbTop := na
    bbBot := na
if sbState > 0 and (bar_index - sbBorn) > i_maxAge
    sbState := 0
    sbTop := na
    sbBot := na

float brkRef  = i_clsBrk ? close : high
float brkRefD = i_clsBrk ? close : low
bool bullFlip = bbState == 1 and not na(bbTop) and brkRef > bbTop
bool bearFlip = sbState == 1 and not na(sbBot) and brkRefD < sbBot
if bullFlip
    bbState := 2
    breakersFlipped += 1
if bearFlip
    sbState := 2
    breakersFlipped += 1

float buf = i_retBuf * atr
bool bullBrkRetest = bbState == 2 and not na(bbTop) and low <= bbTop + buf and high >= bbBot - buf
bool bearBrkRetest = sbState == 2 and not na(sbBot) and high >= sbBot - buf and low <= sbTop + buf
if bullBrkRetest
    bbState := 3
if bearBrkRetest
    sbState := 3

// Directional bias: armed by a flip, expires with the breaker's max age.
var int bias    = 0
var int biasBar = 0
if bullFlip
    bias := 1
    biasBar := bar_index
if bearFlip
    bias := -1
    biasBar := bar_index
if bias != 0 and (bar_index - biasBar) > i_maxAge
    bias := 0

float emaFast = ta.ema(close, i_emaLen)
bool  crossUp = ta.crossover(close, emaFast)
bool  crossDn = ta.crossunder(close, emaFast)
bool emaReclaimUp = bias ==  1 and crossUp
bool emaReclaimDn = bias == -1 and crossDn
bool fireUp   = i_trig == "Retest Only" ? bullBrkRetest : i_trig == "EMA Reclaim Only" ? emaReclaimUp : (bullBrkRetest or emaReclaimUp)
bool fireDown = i_trig == "Retest Only" ? bearBrkRetest : i_trig == "EMA Reclaim Only" ? emaReclaimDn : (bearBrkRetest or emaReclaimDn)
bool entryUp   = inSession and fireUp
bool entryDown = inSession and fireDown

var int lastSignalBar = -100000
bool cooldownOk = (bar_index - lastSignalBar) >= i_cooldown
bool confirmed  = barstate.isconfirmed
bool buySignal  = entryUp   and cooldownOk and confirmed
bool sellSignal = entryDown and cooldownOk and confirmed and not buySignal
// Consume bias on signal so the engine immediately re-arms for the next setup rather than
// holding the same regime indefinitely (this was the source of the prior 20k-bar dead zone).
if buySignal
    lastSignalBar := bar_index
    bias := 0
    bbState := 0
    bbTop := na
    bbBot := na
if sellSignal
    lastSignalBar := bar_index
    bias := 0
    sbState := 0
    sbTop := na
    sbBot := na

var int posState = 0
if buySignal
    posState := 1
if sellSignal
    posState := -1

var box bbBox = na
var box sbBox = na
if i_showBox and bullFlip and not na(bbTop)
    box.delete(bbBox)
    bbBox := box.new(math.max(0, bar_index - i_obLook), bbTop, bar_index + 25, bbBot, border_color=color.new(i_buyColor, 25), bgcolor=color.new(i_buyColor, 82))
if i_showBox and bearFlip and not na(sbTop)
    box.delete(sbBox)
    sbBox := box.new(math.max(0, bar_index - i_obLook), sbTop, bar_index + 25, sbBot, border_color=color.new(i_sellColor, 25), bgcolor=color.new(i_sellColor, 82))

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.diamond, location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.diamond, location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy",         shape.diamond, location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="BBR", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.diamond, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.diamond, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell",        shape.diamond, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="BBR", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(bias == 1 ? color.new(i_buyColor, 94) : bias == -1 ? color.new(i_sellColor, 94) : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=i_dashBg, border_color=color.new(i_buyColor, 55), border_width=2)
    string st = bbState == 2 ? "BULL BREAKER" : sbState == 2 ? "BEAR BREAKER" : bias == 1 ? "BULL BIAS" : bias == -1 ? "BEAR BIAS" : "WAITING FLIP"
    color  sc = bbState == 2 or bias == 1 ? i_buyColor : sbState == 2 or bias == -1 ? i_sellColor : color.gray
    table.cell(dash, 0, 0, "Breaker Block Reversal", text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                  text_color=color.new(i_buyColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "Phase",                  text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, st,                       text_color=sc, text_size=size.small)
    table.cell(dash, 0, 2, "Bull Breaker",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, na(bbTop) ? "-" : str.tostring(bbBot, "#.##") + "-" + str.tostring(bbTop, "#.##"), text_color=i_buyColor, text_size=size.small)
    table.cell(dash, 0, 3, "Bear Breaker",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, na(sbTop) ? "-" : str.tostring(sbBot, "#.##") + "-" + str.tostring(sbTop, "#.##"), text_color=i_sellColor, text_size=size.small)
    table.cell(dash, 0, 4, "Breakers Flipped",       text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(breakersFlipped), text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 5, "ATR",                    text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(atr, "#.#####"), text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 6, "Position",               text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",            text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, lastSignalBar < 0 ? "none yet" : str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"BBR","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"BBR","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                          "BBR Buy",           "Bull breaker retest on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                         "BBR Sell",          "Bear breaker retest on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,            "BBR Any Signal",    "Any BBR signal on {{ticker}} {{interval}}")
alertcondition(downBreak,                          "BBR Down Break",    "Down structural break on {{ticker}} {{interval}}")
alertcondition(upBreak,                            "BBR Up Break",      "Up structural break on {{ticker}} {{interval}}")
alertcondition(bullFlip,                           "BBR Bull Flip",     "Bear OB flipped to bull breaker on {{ticker}} {{interval}}")
alertcondition(bearFlip,                           "BBR Bear Flip",     "Bull OB flipped to bear breaker on {{ticker}} {{interval}}")
alertcondition(bullBrkRetest,                      "BBR Bull Retest",   "Bull breaker touched on {{ticker}} {{interval}}")
alertcondition(bearBrkRetest,                      "BBR Bear Retest",   "Bear breaker touched on {{ticker}} {{interval}}")
alertcondition(bbState == 1 and bbState[1] != 1,   "BBR Bull OB Set",   "Pre-flip bull origin set on {{ticker}} {{interval}}")
alertcondition(sbState == 1 and sbState[1] != 1,   "BBR Bear OB Set",   "Pre-flip bear origin set on {{ticker}} {{interval}}")
alertcondition(downBreak or upBreak,               "BBR Structure",     "Structure broke on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,            "BBR Webhook JSON",  "{\"action\":\"signal\",\"indicator\":\"BBR\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
