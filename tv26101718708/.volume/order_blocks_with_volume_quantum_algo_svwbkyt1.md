# Order Blocks with Volume [Quantum Algo]

- url: https://www.tradingview.com/script/SVWBkYT1-Order-Blocks-with-Volume-Quantum-Algo/
- type: indicator
- pine_id: PUB;8f5eee2c5cc74862a76133d5127354cc
- version: 2.0

## Description

[b]Order Blocks with Volume [Quantum Algo]
[/b]
[b]OVERVIEW
[/b]This indicator finds order blocks — the candles where a directional move originated before price broke market structure — and measures the buy and sell volume that traded inside each one. Every zone is drawn as a box that extends forward until price returns to it, and each active zone is labelled with its total volume and its buy/sell split, so you can tell at a glance which blocks were built on heavy participation and which were not.

It is built entirely from price and volume on the chart you apply it to. There is no repainting of confirmed zones: detection runs only on closed bars.


[b]HOW DETECTION WORKS
[/b]1. Market structure. Confirmed swing highs and swing lows are located using a pivot of configurable length (Swing Length). A larger value isolates more significant structure and produces fewer, larger zones.

2. Break of structure. When a candle closes above the most recent confirmed swing high (bullish) or below the most recent confirmed swing low (bearish), the indicator treats it as a break of structure and looks for the order block that produced the move.

3. The order block candle. Starting from the breakout, the script steps back over the impulse candles and marks the last opposite-close candle before the move began — the last down-close candle for a bullish block, the last up-close candle for a bearish block. This is the origin of the displacement and the level price often revisits.

4. Zone range. The block is drawn from that candle using either its full high-to-low range (Wick) or its open-to-close body (Body).


[b]VOLUME ENGINE
[/b]For each order block candle the indicator estimates how much of the traded volume was buying versus selling, using where the candle closed within its own range:
- Buy volume is weighted by how close the candle closed to its high.
- Sell volume is weighted by how close it closed to its low.

This split is shown two ways:
- Buy / Sell volume bars: two horizontal bars anchored at the left of the zone — buy on the top half, sell on the bottom half — with lengths proportional to each side. The Volume Bar Length setting controls how long they can extend (they are automatically kept inside the zone).
- Volume label: written inside the zone on the right edge, showing the total volume of the block and the buy% / sell% balance.

Volume strength is the block's volume divided by the average volume over a configurable baseline (Volume Baseline Length). It is used by the optional filter below to keep only the heaviest blocks.


[b]ZONE LIFECYCLE
[/b]- Active. A live zone extends to the current bar and shows its volume bars and label.
- Mitigation. When price first trades back into a zone, the 50% line marks the equilibrium and an alert can fire.
- Invalidation. A zone is invalidated when price moves through its far edge. The source can be a wick touch or a candle close (Invalidation Source).
- Breaker. If "Flip Broken Zones to Breaker Blocks" is on, an invalidated zone is kept and re-coloured as a breaker, since broken support can act as resistance and vice versa.
- Historic. If "Keep Invalidated Zones (Historic)" is on, finished zones are frozen at the bar they died, re-coloured neutral, and their volume bars and text are removed to keep the chart clean.
- If neither option is on, invalidated zones are removed.

To avoid clutter the indicator will not stack a new zone on top of an existing active zone in the same area, limits the number of active zones per side, and automatically drops any zone older than the drawing range.


[b]ON-CHART ELEMENTS
[/b]- Coloured boxes: bullish and bearish order blocks (and a neutral colour for breaker/historic).
- Two inner bars per active zone: buy (top) and sell (bottom) volume.
- A dotted line through the middle of active zones: the 50% mitigation / equilibrium level.
- Text inside active zones: total volume and buy% / sell%.


[b]SETTINGS
[/b]
Structure & Detection
- Swing Length — pivot length used to define structure. Higher = larger, more significant zones.
- Impulse Lookback (bars) — how far back to search for the origin candle after a break of structure.
- Zone Range — Wick (full range) or Body (open-to-close).
- Max Active Zones / Side — cap on simultaneously active zones per direction.

Invalidation
- Invalidation Source — Wick (a high/low piercing the zone) or Close (a candle closing beyond it).
- Flip Broken Zones to Breaker Blocks — keep and re-colour broken zones as breakers.
- Keep Invalidated Zones (Historic) — freeze finished zones instead of deleting them.

Volume Engine
- Show Volume Label — write volume and buy/sell% inside active zones.
- Show Buy / Sell Volume Bars — draw the proportional buy/sell bars.
- Volume Baseline Length — averaging length used to rate volume strength.
- Volume Bar Length (bars) — maximum length of the buy/sell bars.

Filters
- Only Show High-Volume Zones — hide blocks below the strength threshold.
- Min Volume Strength (x avg) — threshold as a multiple of average volume.
- Filter Oversized Zones — skip blocks taller than the ATR limit.
- Max Zone Height (ATR x) — the height limit, in multiples of ATR.

Style
- Bullish Zone, Bearish Zone, Buy Volume, Sell Volume, Breaker / Historic, Text — colours.
- Zone Extension (bars) — how far active zones project past the current bar.
- Show 50% Mitigation Line — toggle the equilibrium line.


[b]ALERTS
[/b]Alerts are raised through the alert() function for two events: an order block being tapped (mitigation) and an order block being broken (breaker formed). To use them, create an alert on the indicator and choose the "Any alert() function call" condition.


[b]HOW TO USE
[/b]Order blocks mark areas where significant orders were likely placed. Traders commonly watch for price to return to an un-mitigated block and react there, and use the buy/sell volume split and strength to judge how meaningful a block is — a block built on high, one-sided volume is generally treated as more significant than a thin one. Combine the zones with your own confirmation and risk management; this tool highlights levels, it does not generate buy or sell signals.


[b]DISCLAIMER[/b]
[i]
Nothing here is financial advice or a guarantee of any outcome. Past behaviour of price around order blocks does not predict future results. Always do your own research and manage risk.[/i]

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════════
//  Order Blocks with Volume [Quantum Algo]
//
//  Detects order blocks at breaks of market structure and profiles the
//  buy/sell volume captured inside each zone. The block is the last
//  opposite-close candle before the displacement that broke structure.
//  Zones extend forward until mitigated. Original implementation.
// ════════════════════════════════════════════════════════════════════════

indicator("Order Blocks with Volume [Quantum Algo]", shorttitle = "Order Blocks with Volume [Quantum Algo]", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500, max_bars_back = 5000)

// ──────────────────────────── Inputs ────────────────────────────
gS = "Structure & Detection"
pivotLen = input.int(10, "Swing Length",           minval = 2, maxval = 50, group = gS, tooltip = "Higher = larger, more significant order blocks. Lower = faster, more zones.")
obSearch = input.int(15, "Impulse Lookback (bars)", minval = 3, maxval = 60, group = gS, tooltip = "How far back to search for the last opposite candle before the impulse.")
obSource = input.string("Wick", "Zone Range",       options = ["Wick", "Body"], group = gS, tooltip = "Wick = full candle range. Body = open-to-close range.")
maxZones = input.int(4,  "Max Active Zones / Side",  minval = 1, maxval = 20, group = gS)

gI = "Invalidation"
invalMethod  = input.string("Wick", "Invalidation Source", options = ["Wick", "Close"], group = gI, tooltip = "Wick invalidates when a high/low pierces the zone. Close requires a candle to close beyond it.")
showBreakers = input.bool(true,  "Flip Broken Zones to Breaker Blocks", group = gI)
showHistoric = input.bool(true,  "Keep Invalidated Zones (Historic)",   group = gI)

gV = "Volume Engine"
showVolInfo = input.bool(true, "Show Volume Label",            group = gV)
showVolBars = input.bool(true, "Show Buy / Sell Volume Bars",  group = gV)
volMaLen    = input.int(20, "Volume Baseline Length", minval = 1, group = gV)
volBarMax   = input.int(30, "Volume Bar Length (bars)", minval = 2, maxval = 150, group = gV)

gF = "Filters"
useVolFilter = input.bool(false, "Only Show High-Volume Zones",  group = gF)
minVolStr    = input.float(1.5, "Min Volume Strength (x avg)", minval = 0.0, step = 0.1, group = gF, tooltip = "Hide order blocks whose volume is below this multiple of average volume.")
useAtrFilter = input.bool(true,  "Filter Oversized Zones",  group = gF)
atrMult      = input.float(3.0,  "Max Zone Height (ATR x)", minval = 0.5, step = 0.5, group = gF)

gC = "Style"
bullCol    = input.color(color.new(#089981, 82), "Bullish Zone",       inline = "z", group = gC)
bearCol    = input.color(color.new(#f23645, 82), "Bearish Zone",       inline = "z", group = gC)
buyCol     = input.color(color.new(#089981, 45), "Buy Volume",         inline = "b", group = gC)
sellCol    = input.color(color.new(#f23645, 45), "Sell Volume",        inline = "b", group = gC)
breakCol   = input.color(color.new(#787b86, 85), "Breaker / Historic", group = gC)
txtCol     = input.color(color.new(#000000, 0),  "Text",               group = gC)
extendBars = input.int(20, "Zone Extension (bars)", minval = 1, maxval = 200, group = gC)
showMid    = input.bool(true, "Show 50% Mitigation Line", group = gC)

const int maxAge = 5000   // drop zones older than this many bars (keeps drawings valid + chart clean)

// ──────────────────────────── Type ────────────────────────────
type OB
    float  top
    float  bottom
    int    startBar
    string dir          // "Bull" | "Bear"
    float  vol
    float  buyVol
    float  sellVol
    float  strength
    bool   mitigated = false
    bool   breaker   = false
    bool   historic  = false
    int    endBar    = na
    box    zoneBox   = na
    box    buyBox    = na
    box    sellBox   = na
    line   midLine   = na

// ──────────────────────────── State ────────────────────────────
var array<OB> bullOBs = array.new<OB>()
var array<OB> bearOBs = array.new<OB>()

avgVol = ta.sma(volume, volMaLen)
atrVal = ta.atr(14)

// Swing structure
ph = ta.pivothigh(pivotLen, pivotLen)
pl = ta.pivotlow(pivotLen, pivotLen)

var float swH = na
var float swL = na
var bool  swHBroken = true
var bool  swLBroken = true

if not na(ph)
    swH := ph
    swHBroken := false
if not na(pl)
    swL := pl
    swLBroken := false

// ──────────────────────────── Helpers ────────────────────────────
f_buyVol(int i) =>
    float rng = high[i] - low[i]
    rng <= 0 ? volume[i] / 2.0 : volume[i] * (close[i] - low[i]) / rng

f_sellVol(int i) =>
    float rng = high[i] - low[i]
    rng <= 0 ? volume[i] / 2.0 : volume[i] * (high[i] - close[i]) / rng

f_deleteOB(OB o) =>
    box.delete(o.zoneBox)
    box.delete(o.buyBox)
    box.delete(o.sellBox)
    line.delete(o.midLine)

f_passFilters(float t, float b, float strength) =>
    bool ok = true
    if useAtrFilter and (t - b) > atrVal * atrMult
        ok := false
    if useVolFilter and strength < minVolStr
        ok := false
    ok

// Does the proposed zone overlap an existing active zone on this side?
f_overlapsActive(array<OB> arr, float t, float b) =>
    bool hit = false
    if arr.size() > 0
        for i = 0 to arr.size() - 1
            OB o = arr.get(i)
            if not o.historic and not o.breaker
                if math.max(b, o.bottom) <= math.min(t, o.top)
                    hit := true
    hit

// Last opposite-close candle before the impulse (the order block)
f_findOBCandle(bool bull) =>
    int idx = na
    int i = 1
    if bull
        while i <= obSearch and close[i] >= open[i]
            i := i + 1
        idx := i <= obSearch ? i : na
    if not bull
        while i <= obSearch and close[i] <= open[i]
            i := i + 1
        idx := i <= obSearch ? i : na
    idx

f_addOB(string dir, int candleIdx) =>
    int   sBar = bar_index - candleIdx
    float t = obSource == "Wick" ? high[candleIdx] : math.max(open[candleIdx], close[candleIdx])
    float b = obSource == "Wick" ? low[candleIdx]  : math.min(open[candleIdx], close[candleIdx])
    float v  = volume[candleIdx]
    float bv = f_buyVol(candleIdx)
    float sv = f_sellVol(candleIdx)
    float base = avgVol[candleIdx]
    float strength = base > 0 ? v / base : 0.0
    bool dup = dir == "Bull" ? f_overlapsActive(bullOBs, t, b) : f_overlapsActive(bearOBs, t, b)
    if f_passFilters(t, b, strength) and not dup
        OB o = OB.new(top = t, bottom = b, startBar = sBar, dir = dir, vol = v, buyVol = bv, sellVol = sv, strength = strength)
        if dir == "Bull"
            bullOBs.unshift(o)
        if dir == "Bear"
            bearOBs.unshift(o)

// ──────────────────────────── Lifecycle ────────────────────────────
f_updateSide(array<OB> arr, bool bull) =>
    if arr.size() > 0
        for i = arr.size() - 1 to 0
            OB o = arr.get(i)
            if (bar_index - o.startBar) > maxAge
                arr.remove(i)
                f_deleteOB(o)
            else if not o.historic
                bool doBreaker  = false
                bool doHistoric = false
                bool doKill     = false
                bool doMitigate = false
                if not o.breaker
                    bool violated = bull ? (invalMethod == "Wick" ? low : close) < o.bottom : (invalMethod == "Wick" ? high : close) > o.top
                    if violated
                        doBreaker  := showBreakers
                        doHistoric := not showBreakers and showHistoric
                        doKill     := not showBreakers and not showHistoric
                    else
                        doMitigate := (high >= o.bottom and low <= o.top) and not o.mitigated
                else
                    bool breakerGone = bull ? (invalMethod == "Wick" ? high : close) > o.top : (invalMethod == "Wick" ? low : close) < o.bottom
                    doHistoric := breakerGone and showHistoric
                    doKill     := breakerGone and not showHistoric
                if doBreaker
                    o.breaker := true
                    alert("Order block broken — breaker block formed.", alert.freq_once_per_bar)
                if doHistoric
                    o.historic := true
                    o.endBar := bar_index
                if doMitigate
                    o.mitigated := true
                    alert("Price tapped an order block.", alert.freq_once_per_bar)
                if doKill
                    arr.remove(i)
                    f_deleteOB(o)

f_capSide(array<OB> arr) =>
    int storeCap = (showHistoric or showBreakers) ? maxZones * 3 : maxZones
    while arr.size() > storeCap
        OB o = arr.pop()
        f_deleteOB(o)

// ──────────────────────────── Render ────────────────────────────
f_render(OB o) =>
    color zc = (o.breaker or o.historic) ? breakCol : (o.dir == "Bull" ? bullCol : bearCol)
    int   leftX  = o.startBar
    int   rightX = na(o.endBar) ? bar_index + extendBars : o.endBar
    float mid = (o.top + o.bottom) / 2.0

    // Zone box — extends right to the live bar while active, freezes when invalidated
    if na(o.zoneBox)
        o.zoneBox := box.new(na, na, na, na, xloc = xloc.bar_index, border_width = 1)
    box.set_lefttop(o.zoneBox, leftX, o.top)
    box.set_rightbottom(o.zoneBox, rightX, o.bottom)
    box.set_bgcolor(o.zoneBox, zc)
    box.set_border_color(o.zoneBox, color.new(zc, 25))

    // 50% mitigation (equilibrium) line
    bool showML = showMid and not o.breaker and not o.historic
    if showML and na(o.midLine)
        o.midLine := line.new(na, na, na, na, xloc = xloc.bar_index, style = line.style_dotted, width = 1)
    if showML
        line.set_xy1(o.midLine, leftX, mid)
        line.set_xy2(o.midLine, rightX, mid)
        line.set_color(o.midLine, color.new(zc, 0))
    if not showML and not na(o.midLine)
        line.delete(o.midLine)
        o.midLine := na

    // Buy / Sell volume bars (anchored at the OB origin)
    bool showVB = showVolBars and o.vol > 0 and not o.breaker and not o.historic
    if showVB and na(o.buyBox)
        o.buyBox := box.new(na, na, na, na, xloc = xloc.bar_index, border_width = 1)
    if showVB and na(o.sellBox)
        o.sellBox := box.new(na, na, na, na, xloc = xloc.bar_index, border_width = 1)
    if showVB
        int span  = math.min(volBarMax, math.max(2, rightX - leftX - 1))
        int buyW  = math.max(1, int(math.round((o.buyVol  / o.vol) * span)))
        int sellW = math.max(1, int(math.round((o.sellVol / o.vol) * span)))
        box.set_lefttop(o.buyBox, leftX, o.top)
        box.set_rightbottom(o.buyBox, leftX + buyW, mid)
        box.set_bgcolor(o.buyBox, buyCol)
        box.set_border_color(o.buyBox, color.new(buyCol, 0))
        box.set_lefttop(o.sellBox, leftX, mid)
        box.set_rightbottom(o.sellBox, leftX + sellW, o.bottom)
        box.set_bgcolor(o.sellBox, sellCol)
        box.set_border_color(o.sellBox, color.new(sellCol, 0))
    if not showVB and not na(o.buyBox)
        box.delete(o.buyBox)
        o.buyBox := na
    if not showVB and not na(o.sellBox)
        box.delete(o.sellBox)
        o.sellBox := na

    // Volume info written INSIDE the zone, anchored to the right edge
    string txt = ""
    if showVolInfo and not o.historic
        float buyPct = o.vol > 0 ? (o.buyVol / o.vol) * 100.0 : 50.0
        txt := str.tostring(o.vol, format.volume) + "\nBuy " + str.tostring(buyPct, "#") + "%   Sell " + str.tostring(100.0 - buyPct, "#") + "%"
    box.set_text(o.zoneBox, txt)
    box.set_text_color(o.zoneBox, txtCol)
    box.set_text_size(o.zoneBox, size.small)
    box.set_text_halign(o.zoneBox, text.align_right)
    box.set_text_valign(o.zoneBox, text.align_center)

f_renderSide(array<OB> arr) =>
    if arr.size() > 0
        for i = 0 to arr.size() - 1
            f_render(arr.get(i))

// ──────────────────────────── Main ────────────────────────────
if barstate.isconfirmed
    // Detect breaks of structure → spawn new order blocks
    if not na(swH) and not swHBroken and close > swH
        swHBroken := true
        int idxBull = f_findOBCandle(true)
        if not na(idxBull)
            f_addOB("Bull", idxBull)
    if not na(swL) and not swLBroken and close < swL
        swLBroken := true
        int idxBear = f_findOBCandle(false)
        if not na(idxBear)
            f_addOB("Bear", idxBear)

    // Maintain zone lifecycle (remove stale + handle invalidation)
    f_updateSide(bullOBs, true)
    f_updateSide(bearOBs, false)
    f_capSide(bullOBs)
    f_capSide(bearOBs)

// Render (also on the live bar so zones track the current candle)
if barstate.isconfirmed or barstate.islast
    f_renderSide(bullOBs)
    f_renderSide(bearOBs)
````
