# Order Block Mitigation Profiler [forexobroker]

- url: https://www.tradingview.com/script/MWPYEMOT-Order-Block-Mitigation-Profiler-forexobroker/
- type: indicator
- pine_id: PUB;728951ee16d04f5480ad712d0935eeaf
- version: 1.0

## Description

Order Block Mitigation Profiler [forexobroker] locates institutional order blocks and tracks each one through a full lifecycle: OPEN (untouched), TOUCHED (price traded back in), and MITIGATED (price closed through). The unique angle is the dual-layer engine: instead of only firing the rare classic one-shot retest, a fresh block arms a persistent directional bias and entries are timed by an EMA reclaim inside that bias, keeping signal cadence usable on live charts.

🔶 ALGORITHM

1. Confirm swing structure with symmetric pivots (ta.pivothigh / ta.pivotlow), tracking the most recent confirmed swing high and low.
2. Detect a Break of Structure (BOS): close crosses the last confirmed swing pivot (close > lastPH while prior close was at or below it, mirrored for bearish).
3. Walk back up to OB Search Lookback bars from the BOS to find the last opposing-direction candle; that candle's high/low defines the order block.
4. Validate displacement: the impulse leg from the block must span at least Min Impulse x ATR, filtering out non-institutional moves.
5. Lifecycle state machine per block: state 1 (OPEN), 2 (TOUCHED on first retest), 3 (MITIGATED when the mitigation reference closes/wicks through).
6. Persistent bias: a freshly formed OB sets bias +1 / -1; the bias clears only when that block is mitigated.
7. Entry timing: within an active bias, an EMA reclaim (ta.crossover / ta.crossunder of close vs the Entry Reclaim EMA) fires the trade. Retest-Only Mode swaps this for the strict first-retest event.

🔶 SIGNAL LOGIC

- Buy: bullish bias active (fresh bull OB, not yet mitigated) and close crosses over the Entry Reclaim EMA (or, in Retest-Only Mode, the first bull OB retest), in session, with position not already long, after the cooldown window has elapsed, and only on barstate.isconfirmed; a position-lock state flips to LONG to prevent stacking.
- Sell: bearish bias active (fresh bear OB, not yet mitigated) and close crosses under the Entry Reclaim EMA (or the first bear OB retest), in session, position not already short, cooldown elapsed, on barstate.isconfirmed; position-lock flips to SHORT.
Only fires when a fresh, unmitigated order block has set directional bias.

🔶 INPUTS

- Structure: pivot length for swing confirmation (default 8), OB search lookback, and ATR length.
- Impulse filter: minimum impulse measured in ATR multiples to qualify a block (default 1.0x ATR).
- Mitigation rule: mitigate on close versus wick-through toggle (default close).
- Signal Logic: Entry Reclaim EMA length (default 9) and Retest-Only Mode toggle (default off = regime + EMA reclaim).
- Cooldown: minimum bars between signals (default 5).
- Filters: optional session restriction with a session window, and one-signal-per-block lock (default on).
- Visual: OB zone boxes, dashboard, 3-layer glow, buy/sell colors, and dashboard background.

🔶 ALERTS

OBM Buy, OBM Sell, OBM Any Signal, OBM Bull BOS, OBM Bear BOS, OBM Bull OB Formed, OBM Bear OB Formed, OBM Bull Mitigated, OBM Bear Mitigated, OBM Bull Retest, OBM Bear Retest, OBM Structure Break, OBM Webhook JSON.

🔶 LIMITATIONS

- Requires warm-up: pivots only confirm after Pivot Length bars on each side, so early chart history produces no structure.
- Defaults (ATR 14, impulse 1.0x) are tuned for liquid instruments; thin or low-volatility symbols may need a lower impulse multiple.
- Retest-Only Mode is intentionally rare and can go long stretches with no signal; the default regime + EMA reclaim mode trades more frequently.
- Non-repainting by design (pivots confirmed, signals on bar close), which means the swing that anchors a block appears Pivot Length bars after it actually formed.
- Order blocks are structural zones, not guaranteed reversals; the impulse and ATR filters reduce but do not eliminate false breaks.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Order Block Mitigation Profiler. A Break of Structure (BOS) occurs when close breaks
// the most recent confirmed swing pivot. The order block is the last opposing-direction candle
// immediately before the impulse that produced the BOS. Each block carries a lifecycle:
// OPEN (untouched) -> TOUCHED (price traded back into it) -> MITIGATED (price closed through it).
// Signals fire on the first retest of a still-fresh order block. ATR-filtered impulse keeps only
// institutional-grade displacement. Non-repainting: pivots are confirmed, signals on bar close.
indicator("Order Block Mitigation Profiler [forexobroker]", shorttitle="OBM [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

// ─── INPUTS ────────────────────────────────────────────────────────────────────
string g_calc = "Structure"
string g_sig  = "Signal Logic"
string g_filt = "Filters"
string g_vis  = "Visual"

int   i_piv     = input.int(8,    "Pivot Length",            minval=2,  maxval=30,  group=g_calc, tooltip="Bars each side for swing pivot confirmation. Larger = stronger structure.")
int   i_obLook  = input.int(10,   "OB Search Lookback",      minval=2,  maxval=30,  group=g_calc, tooltip="Bars scanned back from the BOS to find the last opposing candle.")
float i_impAtr  = input.float(1.0,"Min Impulse x ATR",       minval=0.2, maxval=5.0, step=0.1, group=g_calc, tooltip="The BOS impulse leg must span at least k x ATR to qualify.")
int   i_atrLen  = input.int(14,   "ATR Length",              minval=5,  maxval=50,  group=g_calc)
bool  i_mitClose= input.bool(true,"Mitigate on Close",                              group=g_calc, tooltip="On = block mitigated when close passes through. Off = wick through.")
int   i_emaLen  = input.int(9,    "Entry Reclaim EMA",       minval=2,  maxval=50,  group=g_sig, tooltip="Within an active OB bias, signals fire when close reclaims this EMA - keeps cadence high.")
bool  i_retOnly = input.bool(false,"Retest-Only Mode",                              group=g_sig, tooltip="On = strict ICT (only the first OB retest fires, rare). Off = regime + EMA reclaim (frequent, default).")
int   i_cooldown= input.int(5,    "Cooldown Bars",           minval=1,  maxval=40,  group=g_sig)
bool  i_useSess = input.bool(false,"Restrict to Session",                            group=g_filt, tooltip="Only allow signals inside the session window below.")
string i_sess   = input.session("0800-1700","Session Window",                       group=g_filt)
bool  i_oneShot = input.bool(true,"One Signal per Block",                            group=g_filt, tooltip="Fire only on the first retest of each block.")
bool  i_showBox = input.bool(true,"Show OB Zones",                                   group=g_vis)
bool  i_showTable=input.bool(true,"Show Dashboard",                                  group=g_vis)
bool  i_showGlow= input.bool(true,"Show 3-Layer Glow",                               group=g_vis)
color i_buyColor= input.color(#26a69a,"Buy Color (Teal)",                            group=g_vis)
color i_sellColor=input.color(#ef5350,"Sell Color (Red)",                            group=g_vis)
color i_dashBg  = input.color(color.new(#04141a, 18),"Dashboard BG",                 group=g_vis)

color c_white = #ffffff

// ─── STRUCTURE + ORDER BLOCK ───────────────────────────────────────────────────
float atr  = nz(ta.atr(i_atrLen), 0.0)
float ph   = ta.pivothigh(high, i_piv, i_piv)
float pl   = ta.pivotlow(low,   i_piv, i_piv)
var float lastPH = na
var float lastPL = na
if not na(ph)
    lastPH := ph
if not na(pl)
    lastPL := pl

bool bullBOS = not na(lastPH) and close > lastPH and close[1] <= lastPH
bool bearBOS = not na(lastPL) and close < lastPL and close[1] >= lastPL

bool inSession = not i_useSess or not na(time(timeframe.period, i_sess))

var float bullTop = na
var float bullBot = na
var int   bullSt  = 0
var float bearTop = na
var float bearBot = na
var int   bearSt  = 0
var int   blocksFormed = 0

if bullBOS
    float t = na
    float b = na
    for k = 1 to i_obLook
        if close[k] < open[k] and na(t)
            t := high[k]
            b := low[k]
    if not na(t) and (close - b) >= i_impAtr * atr
        bullTop := t
        bullBot := b
        bullSt  := 1
        blocksFormed += 1

if bearBOS
    float t = na
    float b = na
    for k = 1 to i_obLook
        if close[k] > open[k] and na(t)
            t := high[k]
            b := low[k]
    if not na(t) and (t - close) >= i_impAtr * atr
        bearTop := t
        bearBot := b
        bearSt  := 1
        blocksFormed += 1

bool bullRetest = bullSt == 1 and not na(bullTop) and low <= bullTop and high >= bullBot
bool bearRetest = bearSt == 1 and not na(bearTop) and high >= bearBot and low <= bearTop
if bullRetest
    bullSt := 2
if bearRetest
    bearSt := 2
float bullMitRef = i_mitClose ? close : low
float bearMitRef = i_mitClose ? close : high
if bullSt >= 1 and not na(bullBot) and bullMitRef < bullBot
    bullSt := 3
if bearSt >= 1 and not na(bearTop) and bearMitRef > bearTop
    bearSt := 3

// ─── BIAS REGIME + FREQUENT ENTRY (dual-layer) ────────────────────────────────
// A fresh order block sets the directional bias; it persists until the opposite
// block forms or the block is mitigated. Entries fire on EMA reclaim within bias.
var int bias = 0
if bullSt == 1 and bullSt[1] != 1
    bias := 1
if bearSt == 1 and bearSt[1] != 1
    bias := -1
if bullSt == 3 and bias == 1
    bias := 0
if bearSt == 3 and bias == -1
    bias := 0

float emaFast = ta.ema(close, i_emaLen)
bool  crossUp = ta.crossover(close, emaFast)
bool  crossDn = ta.crossunder(close, emaFast)

bool entryUp   = inSession and (i_retOnly ? bullRetest : (bias ==  1 and crossUp))
bool entryDown = inSession and (i_retOnly ? bearRetest : (bias == -1 and crossDn))

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

// ─── ZONES ─────────────────────────────────────────────────────────────────────
var box bullBox = na
var box bearBox = na
int lbox = math.max(0, bar_index - i_obLook)
if i_showBox and bullBOS and not na(bullTop)
    box.delete(bullBox)
    bullBox := box.new(lbox, bullTop, bar_index + 20, bullBot, border_color=color.new(i_buyColor, 30), bgcolor=color.new(i_buyColor, 85))
if i_showBox and bearBOS and not na(bearTop)
    box.delete(bearBox)
    bearBox := box.new(lbox, bearTop, bar_index + 20, bearBot, border_color=color.new(i_sellColor, 30), bgcolor=color.new(i_sellColor, 85))

// ─── VISUAL ───────────────────────────────────────────────────────────────────
plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.arrowup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.arrowup,   location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy",         shape.arrowup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="OBM", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.arrowdown, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.arrowdown, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell",        shape.arrowdown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="OBM", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(bullSt == 1 ? color.new(i_buyColor, 94) : bearSt == 1 ? color.new(i_sellColor, 94) : na)

// ─── DASHBOARD ────────────────────────────────────────────────────────────────
if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=i_dashBg, border_color=color.new(i_buyColor, 60), border_width=1)
    string bsTxt = bullSt == 1 ? "BULL OB OPEN" : bearSt == 1 ? "BEAR OB OPEN" : "NO FRESH OB"
    color  bsCol = bullSt == 1 ? i_buyColor : bearSt == 1 ? i_sellColor : color.gray
    table.cell(dash, 0, 0, "Order Block Mitigation", text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                  text_color=color.new(i_buyColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "Status",                 text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, bsTxt,                    text_color=bsCol, text_size=size.small)
    table.cell(dash, 0, 2, "Bull OB",                text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, na(bullTop) ? "-" : str.tostring(bullBot, "#.##") + "-" + str.tostring(bullTop, "#.##"), text_color=i_buyColor, text_size=size.small)
    table.cell(dash, 0, 3, "Bear OB",                text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, na(bearTop) ? "-" : str.tostring(bearBot, "#.##") + "-" + str.tostring(bearTop, "#.##"), text_color=i_sellColor, text_size=size.small)
    table.cell(dash, 0, 4, "Blocks Formed",          text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(blocksFormed), text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 5, "ATR",                    text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(atr, "#.#####"), text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 6, "Position",               text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",            text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

// ─── ALERTS ───────────────────────────────────────────────────────────────────
if buySignal
    alert('{"action":"BUY","indicator":"OBM","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"OBM","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                              "OBM Buy",            "Bull OB retest on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                             "OBM Sell",           "Bear OB retest on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,                "OBM Any Signal",     "Any OBM signal on {{ticker}} {{interval}}")
alertcondition(bullBOS,                                "OBM Bull BOS",       "Bullish break of structure on {{ticker}} {{interval}}")
alertcondition(bearBOS,                                "OBM Bear BOS",       "Bearish break of structure on {{ticker}} {{interval}}")
alertcondition(bullSt == 1 and bullSt[1] != 1,         "OBM Bull OB Formed", "Fresh bull order block on {{ticker}} {{interval}}")
alertcondition(bearSt == 1 and bearSt[1] != 1,         "OBM Bear OB Formed", "Fresh bear order block on {{ticker}} {{interval}}")
alertcondition(bullSt == 3 and bullSt[1] != 3,         "OBM Bull Mitigated", "Bull OB mitigated on {{ticker}} {{interval}}")
alertcondition(bearSt == 3 and bearSt[1] != 3,         "OBM Bear Mitigated", "Bear OB mitigated on {{ticker}} {{interval}}")
alertcondition(bullRetest,                             "OBM Bull Retest",    "Bull OB touched on {{ticker}} {{interval}}")
alertcondition(bearRetest,                             "OBM Bear Retest",    "Bear OB touched on {{ticker}} {{interval}}")
alertcondition(bullBOS or bearBOS,                     "OBM Structure Break","Structure broke on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,                "OBM Webhook JSON",   "{\"action\":\"signal\",\"indicator\":\"OBM\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
