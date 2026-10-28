# Auction Shelf Ledger [forexobroker]

- url: https://www.tradingview.com/script/TCIIxp2q-Auction-Shelf-Ledger-forexobroker/
- type: indicator
- pine_id: PUB;685a75e35ff2490d9aa2b382017d1e57
- version: 1.0

## Description

Auction Shelf Ledger [forexobroker] maintains a running ledger of defended price levels by clustering confirmed pivots into shelves and scoring each shelf by how many times it has been touched and how much volume accumulated there. When price tests a strong shelf and rejects it, the indicator trades away from that defended liquidity. The unique angle is treating repeated pivot touches plus volume as evidence of a real auction battleground rather than drawing a fresh line on every pivot.

🔶 ALGORITHM

1. ATR (default 14) is computed for adaptive distance scaling.
2. Confirmed pivot highs and lows (default pivot length 6) are detected with full left/right confirmation.
3. Each new pivot is registered against the ledger: if it falls within the cluster tolerance (default 0.5 x ATR) of an existing shelf, that shelf is reinforced (touch count and volume sum grow, price re-centered); otherwise a new shelf is created.
4. The ledger is capped at the max shelves tracked (default 8); the oldest shelf is shifted out when full.
5. The nearest shelf whose touch count meets the strong threshold (default 2) is selected as the active level.
6. A reject buffer (default 0.15 x ATR) defines the test zone; price entering it then closing back away marks a rejection up or down.
7. A rejection arms a persistent directional bias that holds until the opposite rejection fires; entries then time off a reclaim EMA (default 9) within that bias.

🔶 SIGNAL LOGIC

- Buy: in rejection-only mode, a fresh upward shelf rejection; otherwise active rejection bias is bullish AND close crosses over the reclaim EMA, AND session filter passes AND position is not already long AND cooldown bars elapsed AND barstate.isconfirmed.
- Sell: in rejection-only mode, a fresh downward shelf rejection; otherwise active rejection bias is bearish AND close crosses under the reclaim EMA, AND session filter passes AND position is not already short AND cooldown bars elapsed AND barstate.isconfirmed.

Only fires once a strong shelf has been tested and rejected to set the active bias.

🔶 INPUTS

- Shelves group: pivot length for detecting raw pivots; default 6.
- Cluster Tol x ATR: distance within which pivots merge into one shelf; default 0.5.
- Min Touches (strong): touches required before a shelf is tradable; default 2.
- Max Shelves Tracked: ledger capacity; default 8.
- Reject Buffer x ATR: test-zone width around a shelf; default 0.15.
- ATR Length: volatility reference for all scaling; default 14.
- Signal Logic group: entry reclaim EMA default 9, rejection-only mode default off, cooldown bars default 5.
- Filters and Visual groups: session restriction (default 0000-2400), shelf lines, dashboard, 3-layer glow, colors.

🔶 ALERTS

ASL Buy, ASL Sell, ASL Any Signal, ASL Shelf Test, ASL Reject Up, ASL Reject Down, ASL New High Pivot, ASL New Low Pivot, ASL Strong Shelf, ASL Ledger Full, ASL At Shelf, ASL Webhook JSON.

🔶 LIMITATIONS

- Pivots are confirmed, so shelves print with pivot-length lag and are not drawn in real time at the extreme.
- A shelf needs several touches to become tradable; early chart history may have no strong shelf yet.
- Defaults are tuned for liquid instruments; very low-volume symbols weaken the volume component of shelf strength.
- The ledger is capacity-limited, so on long ranges the oldest shelves are discarded even if still relevant.
- The non-rejection-only path uses a fast EMA cross and can produce extra entries inside a single bias.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Auction Shelf Ledger. Confirmed pivots are clustered: a new pivot within k x ATR of
// an existing shelf reinforces it (touch count + volume sum grow); otherwise a new shelf is born.
// A shelf with enough touches and accumulated volume is a defended auction level. Signals fire
// when price tests a strong shelf and rejects it (touches the shelf then closes back away),
// trading away from defended liquidity. Non-repainting: pivots confirmed, signal on bar close.
indicator("Auction Shelf Ledger [forexobroker]", shorttitle="ASL [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc = "Shelves"
string g_sig  = "Signal Logic"
string g_filt = "Filters"
string g_vis  = "Visual"

int   i_piv     = input.int(6,    "Pivot Length",          minval=2,  maxval=30, group=g_calc)
float i_clustK  = input.float(0.5,"Cluster Tol x ATR",     minval=0.1, maxval=3.0, step=0.1, group=g_calc, tooltip="Pivots within k x ATR merge into the same shelf.")
int   i_minTouch= input.int(2,    "Min Touches (strong)",  minval=2,  maxval=10, group=g_calc, tooltip="Touches required for a shelf to be tradable.")
int   i_maxShelf= input.int(8,    "Max Shelves Tracked",   minval=2,  maxval=20, group=g_calc)
float i_rejBuf  = input.float(0.15,"Reject Buffer x ATR",  minval=0.0, maxval=2.0, step=0.05, group=g_calc)
int   i_atrLen  = input.int(14,   "ATR Length",            minval=5,  maxval=50, group=g_calc)
int   i_emaLen  = input.int(9,    "Entry Reclaim EMA",     minval=2,  maxval=50, group=g_sig, tooltip="After a shelf rejects price, a close-cross of this EMA in the rejection direction times the entry.")
bool  i_retOnly = input.bool(false,"Rejection-Only Mode",                         group=g_sig, tooltip="On = fire strictly on the shelf-rejection bar (rarer, classic). Off = EMA reclaim inside the active rejection bias (more signals).")
int   i_cooldown= input.int(5,    "Cooldown Bars",         minval=1,  maxval=40, group=g_sig)
bool  i_useSess = input.bool(false,"Restrict to Session",                        group=g_filt)
string i_sess   = input.session("0000-2400","Session Window",                   group=g_filt)
bool  i_showLvl = input.bool(true,"Show Shelf Lines",                            group=g_vis)
bool  i_showTable=input.bool(true,"Show Dashboard",                              group=g_vis)
bool  i_showGlow= input.bool(true,"Show 3-Layer Glow",                           group=g_vis)
color i_buyColor= input.color(#4ade80,"Buy Color",                               group=g_vis)
color i_sellColor=input.color(#f472b6,"Sell Color",                              group=g_vis)
color i_dashBg  = input.color(color.new(#0c1810, 16),"Dashboard BG",             group=g_vis)

color c_white = #ffffff

float atr = nz(ta.atr(i_atrLen), 0.0)
float ph  = ta.pivothigh(high, i_piv, i_piv)
float pl  = ta.pivotlow(low,   i_piv, i_piv)

var float[] shelfPrice = array.new_float(0)
var int[]   shelfTouch = array.new_int(0)
var float[] shelfVol   = array.new_float(0)

f_register(float px) =>
    int merged = -1
    if array.size(shelfPrice) > 0
        for j = 0 to array.size(shelfPrice) - 1
            if math.abs(px - array.get(shelfPrice, j)) <= i_clustK * atr
                merged := j
    if merged >= 0
        array.set(shelfTouch, merged, array.get(shelfTouch, merged) + 1)
        array.set(shelfVol,   merged, array.get(shelfVol, merged) + volume)
        array.set(shelfPrice, merged, (array.get(shelfPrice, merged) + px) / 2.0)
    else
        array.push(shelfPrice, px)
        array.push(shelfTouch, 1)
        array.push(shelfVol,   volume)
        if array.size(shelfPrice) > i_maxShelf
            array.shift(shelfPrice)
            array.shift(shelfTouch)
            array.shift(shelfVol)
    merged

if not na(ph)
    f_register(ph)
if not na(pl)
    f_register(pl)

// Find the nearest strong shelf and test for rejection
float nearPx = na
int   nearTch = 0
float nearDist = 1e20
if array.size(shelfPrice) > 0
    for j = 0 to array.size(shelfPrice) - 1
        if array.get(shelfTouch, j) >= i_minTouch
            float d = math.abs(close - array.get(shelfPrice, j))
            if d < nearDist
                nearDist := d
                nearPx := array.get(shelfPrice, j)
                nearTch := array.get(shelfTouch, j)

float buf = i_rejBuf * atr
bool atShelf   = not na(nearPx) and low <= nearPx + buf and high >= nearPx - buf
bool rejUp     = atShelf and close > nearPx + buf and close > open
bool rejDown   = atShelf and close < nearPx - buf and close < open
bool inSession = not i_useSess or not na(time(timeframe.period, i_sess))

// A shelf rejection arms a persistent directional bias until the opposite
// rejection fires; entries then time off an EMA reclaim within that bias.
var int bias = 0
if rejUp
    bias := 1
if rejDown
    bias := -1
float emaFast = ta.ema(close, i_emaLen)
bool  crossUp = ta.crossover(close, emaFast)
bool  crossDn = ta.crossunder(close, emaFast)
bool entryUp   = inSession and (i_retOnly ? rejUp   : (bias ==  1 and crossUp))
bool entryDown = inSession and (i_retOnly ? rejDown : (bias == -1 and crossDn))

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

var line shelfLn = na
if i_showLvl and not na(nearPx) and (rejUp or rejDown)
    line.delete(shelfLn)
    shelfLn := line.new(math.max(0, bar_index - 1), nearPx, bar_index + 12, nearPx, color=color.new(rejUp ? i_buyColor : i_sellColor, 0), width=2)

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.circle, location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.circle, location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy",         shape.circle, location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="ASL", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.circle, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.circle, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell",        shape.circle, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="ASL", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(bias == 1 ? color.new(i_buyColor, 94) : bias == -1 ? color.new(i_sellColor, 94) : atShelf ? color.new(color.gray, 90) : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=i_dashBg, border_color=color.new(i_buyColor, 55), border_width=1)
    string st = rejUp ? "REJECTED UP" : rejDown ? "REJECTED DOWN" : atShelf ? "AT SHELF" : "NO TEST"
    color  sc = rejUp ? i_buyColor : rejDown ? i_sellColor : color.gray
    table.cell(dash, 0, 0, "Auction Shelf Ledger", text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                text_color=color.new(i_buyColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "State",                text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, st,                     text_color=sc, text_size=size.small)
    table.cell(dash, 0, 2, "Nearest Shelf",        text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, na(nearPx) ? "-" : str.tostring(nearPx, "#.##"), text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 3, "Shelf Touches",        text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(nearTch),  text_color=nearTch >= i_minTouch ? i_buyColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 4, "Shelves Tracked",      text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(array.size(shelfPrice)), text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 5, "ATR",                  text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(atr, "#.#####"), text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 6, "Position",             text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",          text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"ASL","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"ASL","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                          "ASL Buy",           "Shelf rejection long on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                         "ASL Sell",          "Shelf rejection short on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,            "ASL Any Signal",    "Any ASL signal on {{ticker}} {{interval}}")
alertcondition(atShelf and not atShelf[1],         "ASL Shelf Test",    "Price testing a shelf on {{ticker}} {{interval}}")
alertcondition(rejUp,                              "ASL Reject Up",     "Shelf rejected upward on {{ticker}} {{interval}}")
alertcondition(rejDown,                            "ASL Reject Down",   "Shelf rejected downward on {{ticker}} {{interval}}")
alertcondition(not na(ph),                         "ASL New High Pivot","New pivot high on {{ticker}} {{interval}}")
alertcondition(not na(pl),                         "ASL New Low Pivot", "New pivot low on {{ticker}} {{interval}}")
alertcondition(nearTch >= i_minTouch,              "ASL Strong Shelf",  "Strong shelf in play on {{ticker}} {{interval}}")
alertcondition(array.size(shelfPrice) >= i_maxShelf,"ASL Ledger Full",  "Shelf ledger at capacity on {{ticker}} {{interval}}")
alertcondition(atShelf,                            "ASL At Shelf",      "Price inside a shelf zone on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,            "ASL Webhook JSON",  "{\"action\":\"signal\",\"indicator\":\"ASL\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
