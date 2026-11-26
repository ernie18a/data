# Big Trades (Intrabar Approximation)

- url: https://www.tradingview.com/script/d5y4RGUI-Big-Trades-Intrabar-Approximation/
- type: indicator
- pine_id: PUB;0ff91c7db8924b7ab9332d32fc57454f
- version: 1.0

## Description

Big Trades (Intrabar Approximation)

WHAT IT DOES
This indicator highlights moments of unusually high volume inside each bar and prints the volume directly on the chart at the price where it happened. It is inspired by the "big trades" displays found on order-flow platforms, rebuilt using the data available in Pine Script.

HOW IT WORKS
Pine Script does not provide individual trades (tick-by-tick prints). Instead, the script splits every chart bar into lower-timeframe intrabars (1 second by default) using request.security_lower_tf(), and flags the intrabars whose volume stands out.

- Each flagged intrabar is placed at the midpoint of its high and low.
- Green = the intrabar closed at or above its open (up-intrabar). Purple = it closed below its open (down-intrabar).
- Flagged intrabars that sit close to each other inside the same bar are merged into a single label, colored by whichever side had more volume. Hover a label to see the up/down breakdown.

THRESHOLD MODES
- Relative (default): shows intrabars whose volume is greater than a multiple (default 4x) of the recent average intrabar volume. The threshold adapts automatically, so it works in both quiet overnight sessions and busy cash-session opens.
- Absolute: a fixed volume threshold.
- Top N: always shows the N largest intrabars of every bar. Useful for studying structure, but in quiet bars these are not necessarily "big".

SETTINGS
- Intrabar timeframe: 1S gives the most detail. Seconds timeframes are only available on plans that support them; otherwise use a minute timeframe that is lower than your chart timeframe.
- Merge distance: in ticks. Auto uses 20% of ATR(14). Increase it if labels overlap, decrease it for more detail.
- Show buy/sell split: displays levels with both sides as up/down (for example 120/45).

LIMITATIONS
- Numbers are the total volume of an intrabar, not a single order. A 300 label on a 1-second intrabar can be one large order or many small ones.
- Up/down color is based on the intrabar's close versus open, not on the true aggressor side of each trade.
- TradingView keeps at most 500 labels per script, so labels on older bars are removed as new ones appear.
- Intrabar history is limited, so very old bars may show no labels.
- Empty bars simply mean no intrabar passed the threshold.

This script is for chart analysis and education only. It is not a trading signal and does not provide financial advice.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © YOUR_TRADINGVIEW_USERNAME

//@version=6
indicator("Big Trades (Intrabar Approximation)", shorttitle = "Big Trades", overlay = true, max_labels_count = 500, behind_chart = false)

// ── Inputs ──────────────────────────────────────────────
const string G_DATA  = "Data"
const string G_THR   = "Threshold"
const string G_VIEW  = "Display"

ltf        = input.timeframe("1S", "Intrabar timeframe", group = G_DATA,
             tooltip = "Resolution used to scan inside each chart bar. 1S gives the most detail (seconds timeframes require a plan that supports them). Must be lower than the chart timeframe.")
mode       = input.string("Relative", "Threshold mode", options = ["Relative", "Absolute", "Top N"], group = G_THR,
             tooltip = "Relative: show intrabars whose volume exceeds a multiple of the recent average intrabar volume (adapts to session activity).\nAbsolute: fixed volume threshold.\nTop N: always show the N largest intrabars of each bar.")
mult       = input.float(4.0, "Relative: multiple of average", minval = 1, step = 0.5, group = G_THR)
baseLen    = input.int(100, "Relative: averaging length (bars)", minval = 5, group = G_THR)
minVol     = input.int(100, "Absolute: minimum volume", minval = 1, group = G_THR)
topN       = input.int(2, "Top N: prints per bar", minval = 1, maxval = 10, group = G_THR)
mergeTicks = input.int(0, "Merge distance (ticks, 0 = auto)", minval = 0, group = G_VIEW,
             tooltip = "Prints closer than this distance inside the same bar are merged into one label. Auto = 20% of ATR(14).")
showBS     = input.bool(false, "Show buy/sell split", group = G_VIEW,
             tooltip = "When a merged level has both up and down intrabars, show them as buy/sell (e.g. 120/45) instead of the total.")
buyCol     = input.color(color.new(#1b7f3a, 0), "Up-intrabar color", group = G_VIEW)
sellCol    = input.color(color.new(#6a3fb5, 0), "Down-intrabar color", group = G_VIEW)
txtSize    = input.string(size.small, "Label size", options = [size.tiny, size.small, size.normal], group = G_VIEW)

// ── Validation ─────────────────────────────────────────
if timeframe.in_seconds(ltf) >= timeframe.in_seconds()
    runtime.error("Intrabar timeframe must be lower than the chart timeframe.")

// ── Merge distance (snapped to whole ticks) ────────────
atr     = ta.atr(14)
rawStep = mergeTicks > 0 ? mergeTicks * syminfo.mintick : nz(atr) * 0.2
step    = math.max(syminfo.mintick, math.round(rawStep / syminfo.mintick) * syminfo.mintick)

// ── Intrabar data ──────────────────────────────────────
[vols, opens, closes, highs, lows] = request.security_lower_tf(syminfo.tickerid, ltf, [volume, open, close, high, low])
nsub = vols.size()

// Rolling average volume per intrabar
var float base = na
if nsub > 0
    avgSub = vols.sum() / nsub
    alpha  = 2.0 / (baseLen + 1)
    base  := na(base) ? avgSub : base + (avgSub - base) * alpha

// ── Select prints ──────────────────────────────────────
sel = array.new<int>()
if nsub > 0
    if mode == "Top N"
        idx = vols.sort_indices(order.descending)
        for j = 0 to math.min(topN, nsub) - 1
            sel.push(idx.get(j))
    else
        thr = mode == "Absolute" ? float(minVol) : mult * nz(base, 1e10)
        for i = 0 to nsub - 1
            if vols.get(i) >= thr
                sel.push(i)

// ── Merge nearby prints by price ───────────────────────
buyMap  = map.new<float, float>()
sellMap = map.new<float, float>()
allMap  = map.new<float, bool>()

for i in sel
    v  = vols.get(i)
    px = math.round(((highs.get(i) + lows.get(i)) / 2) / step) * step
    allMap.put(px, true)
    if closes.get(i) >= opens.get(i)
        buyMap.put(px, nz(buyMap.get(px)) + v)
    else
        sellMap.put(px, nz(sellMap.get(px)) + v)

// ── Labels ─────────────────────────────────────────────
for k in allMap.keys()
    b   = nz(buyMap.get(k))
    s   = nz(sellMap.get(k))
    txt = showBS and b > 0 and s > 0 ? str.tostring(b, "#") + "/" + str.tostring(s, "#") : str.tostring(b + s, "#")
    label.new(bar_index, k, txt,
              style     = label.style_label_center,
              color     = b >= s ? buyCol : sellCol,
              textcolor = color.white,
              size      = txtSize,
              tooltip   = "Up: " + str.tostring(b, "#") + "  |  Down: " + str.tostring(s, "#"))
````
