# Volume Footprint Levels

- url: https://www.tradingview.com/script/uB6OGW3g-Volume-Footprint-Levels/
- type: indicator
- pine_id: PUB;9c61543daa75421185ce693003587dc1
- version: 3.0

## Description

[b]Volume Footprint Levels 🐾[/b]

[b]What it is[/b]

A support/resistance plotter that uses TradingView's [i]request.footprint()[/i] volume-at-price data to identify levels where aggressive volume actively defended or rejected price. Instead of drawing lines from raw highs/lows, it only marks zones where one side ([i]buyers or sellers[/i]) absorbed the other and price was pushed away — the kind of levels that tend to matter on retest.

[b]How defense is detected[/b]

For each bar, the script walks the footprint rows and looks for one-sided imbalance concentrated at the bar's wick zones:

[list=1]
[*][b]Buy defense (support)[/b] — heavy aggressive buying at the [i]bottom[/i] X% of the bar's range, where buy volume exceeds sell volume by the imbalance ratio, and the close has moved a configurable distance away from the lows.
[*][b]Sell defense (resistance)[/b] — heavy aggressive selling at the [i]top[/i] X% of the bar's range, where sell volume exceeds buy volume by the ratio, and the close has moved away from the highs.
[/list]

Qualifying rows are aggregated into a volume-weighted average price for the level, and the level only fires if the total defending volume clears a minimum threshold. Individual rows must also clear a minimum delta to count, which filters out thin-tape noise.

[b]Level lifecycle[/b]

Each detected level becomes a horizontal line projecting forward from the bar that created it:

[list=1]
[*][b]Merge / replace[/b] — a new level within [i]mergePoints[/i] of an existing one is suppressed, unless the new one has higher defending volume, in which case it replaces the weaker one in place.
[*][b]Touch tracking[/b] — every bar whose wick reaches within [i]touchTol[/i] of the level increments either the bullish (▲) or bearish (▼) touch counter depending on which side of the level the bar closed on. Counts render in the level's label.
[*][b]Break confirmation[/b] — a level is only removed once price closes beyond it (plus a buffer) for [i]breakBars[/i] consecutive bars. If price moves back inside before the count completes, the break counter resets. This stops single-wick fakeouts from killing valid levels.
[*][b]Cap[/b] — total active levels are pruned oldest-first to stay under [i]maxLevels[/i].
[/list]

[b]Exports[/b]

The four nearest supports and four nearest resistances (sorted by proximity to close) are plotted to the price scale and data window as [i]Sup 1–4[/i] / [i]Res 1–4[/i]. When [b]Enable JSON Alerts[/b] is on, each confirmed bar emits a structured JSON alert containing timestamp, ticker, timeframe, close, all eight ranked levels, active level count, and any new support/resistance created on that bar — designed for ingestion by an external webhook pipeline.

[b]What you see on the chart[/b]

Green lines for support, red for resistance, each tagged with a label showing defending volume and the running ▲/▼ touch counts. Hovering a label exposes a tooltip with the level type, exact price, volume, imbalance ratio at creation, and full touch breakdown. Line style, width, colors, and label size are all configurable.

[b]Intended use[/b]

A footprint-driven structure tool — the levels flag prices where aggressive flow has already been absorbed once, making them candidates for retest entries, target zones, or invalidation references. Best on instruments where TradingView's footprint data is dense ([i]liquid futures, major FX, large-cap equities[/i]); on thinner instruments or deep history the footprint resolution degrades, which is why [i]maxLookback[/i] is capped.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © gggoaaat

// ============================================================================
// FOOTPRINT LEVELS  |  Pine Script v6
// ----------------------------------------------------------------------------
// Uses TradingView footprint data (volume-at-price) to identify price levels
// being actively defended or rejected by aggressive volume.
//
// Defense: heavy one-sided volume at bar extremes, price closes away from it.
//   - Buy defense (support): aggressive buying at bar lows, close moves up
//   - Sell defense (resistance): aggressive selling at bar highs, close moves down
//
// Levels project forward as horizontal lines until price breaks through them.
// Touch counts track how many times price retests a level and holds.
// ============================================================================
//@version=6
indicator("Volume Footprint Levels", "🐾", overlay=true,
          max_lines_count=500, max_labels_count=500)

// ─────────────────────────────────────────────────────────────────────────────
// FOOTPRINT SETTINGS
// ─────────────────────────────────────────────────────────────────────────────
var string GF = "═══ Footprint"
ticksPerRow = input.int(5, "Ticks per Row", minval=1, group=GF,
              tooltip="Price aggregation. 1 = finest detail, 5+ = clustered rows.")
maxLookback = input.int(500, "Max Lookback Bars", minval=50, maxval=5000, group=GF,
              tooltip="Footprint accuracy degrades on deep history.")
preservePlots = input.bool(true, "Preserve Plots")              

// ─────────────────────────────────────────────────────────────────────────────
// DETECTION SETTINGS
// ─────────────────────────────────────────────────────────────────────────────
var string GD = "═══ Detection"
imbalanceRatio = input.float(2.5, "Imbalance Ratio", minval=1.5, maxval=10.0, step=0.1, group=GD,
                 tooltip="Buy volume must be X times sell volume (or vice versa) at a price row to qualify.")
minRowDelta    = input.int(5, "Min Row Delta", minval=0, group=GD,
                 tooltip="Individual row must have at least this much net delta to qualify.")
minTotalVol    = input.int(30, "Min Aggregated Volume", minval=1, group=GD,
                 tooltip="Total defending volume across qualifying rows must exceed this.")
wickPct        = input.float(35.0, "Wick Zone %", minval=10.0, maxval=50.0, step=5.0, group=GD,
                 tooltip="Only rows in the top/bottom X% of bar range qualify as defense zones.")
minCloseAway   = input.float(30.0, "Min Close Distance %", minval=10.0, maxval=80.0, step=5.0, group=GD,
                 tooltip="Close must be at least this % of bar range away from the defense zone.")

// ─────────────────────────────────────────────────────────────────────────────
// LEVEL MANAGEMENT
// ─────────────────────────────────────────────────────────────────────────────
var string GL = "═══ Levels"
maxLevels   = input.int(25, "Max Active Levels", minval=1, maxval=50, group=GL)
mergePoints = input.float(3.0, "Merge Distance (points)", minval=0.0, step=0.25, group=GL,
              tooltip="Suppress new level if within this distance of an existing one.\nIf new level is stronger, it replaces the old one.")
breakBuffer = input.float(2.0, "Break Buffer (points)", minval=0.0, step=0.25, group=GL,
              tooltip="Price must close beyond level by this many points to break it.")
breakBars   = input.int(2, "Break Confirm Bars", minval=1, maxval=10, group=GL,
              tooltip="Consecutive closes beyond level required to confirm a break.")

// ─────────────────────────────────────────────────────────────────────────────
// VISUAL SETTINGS
// ─────────────────────────────────────────────────────────────────────────────
var string GV = "═══ Visuals"
supportColor    = input.color(color.new(#00e676, 20), "Support Color", group=GV)
resistanceColor = input.color(color.new(#ff1744, 20), "Resistance Color", group=GV)
lineWidthBase   = input.int(2, "Line Width (base)", minval=1, maxval=4, group=GV)
lineStyle       = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group=GV)
showVolLabel    = input.bool(true, "Show Volume on Level", group=GV)
accumTouchVol   = input.bool(true, "Accumulate Touch Volume", group=GV,
                  tooltip="Add the footprint volume transacted at the level on each retest to the label, shown as (+N).")
showTouchLabels = input.bool(true, "Show Touch Counts", group=GV)
touchTol        = input.float(2.0, "Touch Tolerance (points)", minval=0.0, step=0.25, group=GV,
                  tooltip="Bar wick must reach within this distance of the level to count as a touch.")
labelSize       = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal", "Large"], group=GV)

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────
f_lineStyle() =>
    lineStyle == "Dotted" ? line.style_dotted :
     lineStyle == "Dashed" ? line.style_dashed :
     line.style_solid

f_labelSize() =>
    switch labelSize
        "Tiny"   => size.tiny
        "Normal" => size.normal
        "Large"  => size.large
        =>          size.small

// Total volume transacted at the footprint row nearest to a target price on the current bar.
f_volAtPrice(fp, float targetPrice) =>
    float v = 0.0
    if not na(fp)
        r = footprint.rows(fp)
        if array.size(r) > 0
            float bestDist = na
            for j = 0 to array.size(r) - 1
                volume_row vr = array.get(r, j)
                float rp = volume_row.down_price(vr)
                float d  = math.abs(rp - targetPrice)
                if na(bestDist) or d < bestDist
                    bestDist := d
                    v := volume_row.buy_volume(vr) + volume_row.sell_volume(vr)
    v

// ─────────────────────────────────────────────────────────────────────────────
// STATE
// ─────────────────────────────────────────────────────────────────────────────
// Level arrays
var line[]   lvlLines     = array.new<line>()
var float[]  lvlPrices    = array.new<float>()
var bool[]   lvlIsSupport = array.new<bool>()    // true = support, false = resistance
var float[]  lvlVolumes   = array.new<float>()   // defending volume (strength)
var float[]  lvlRatios    = array.new<float>()    // imbalance ratio at creation
var int[]    lvlBarIdx    = array.new<int>()      // bar_index when created

// Touch tracking
var label[]  touchLabels  = array.new<label>()
var int[]    bullTouches  = array.new<int>()
var int[]    bearTouches  = array.new<int>()
var float[]  retestVols   = array.new<float>()   // volume transacted at level on retests

// Break confirmation tracking
var int[]    breakCount   = array.new<int>()      // consecutive break bars

// Fetch footprint
footprintData = request.footprint(ticksPerRow, 70, 300)

bool isWithinLookback = (last_bar_index - bar_index) <= maxLookback

// ─────────────────────────────────────────────────────────────────────────────
// BREAK CHECK — remove levels price has traded through
// ─────────────────────────────────────────────────────────────────────────────
if array.size(lvlPrices) > 0
    for i = array.size(lvlPrices) - 1 to 0
        float lvlPrice = array.get(lvlPrices, i)
        bool  isSup    = array.get(lvlIsSupport, i)

        // Support broken: close below level - buffer
        // Resistance broken: close above level + buffer
        bool breaking = isSup ? (close < lvlPrice - breakBuffer) : (close > lvlPrice + breakBuffer)

        if breaking
            int cnt = array.get(breakCount, i) + 1
            if cnt >= breakBars
                // Confirmed break — remove level
                line.delete(array.remove(lvlLines, i))
                label.delete(array.remove(touchLabels, i))
                array.remove(lvlPrices, i)
                array.remove(lvlIsSupport, i)
                array.remove(lvlVolumes, i)
                array.remove(lvlRatios, i)
                array.remove(lvlBarIdx, i)
                array.remove(bullTouches, i)
                array.remove(bearTouches, i)
                array.remove(retestVols, i)
                array.remove(breakCount, i)
            else
                array.set(breakCount, i, cnt)
        else
            // Reset break counter if price moves back
            array.set(breakCount, i, 0)

// ─────────────────────────────────────────────────────────────────────────────
// EXTEND EXISTING LINES
// ─────────────────────────────────────────────────────────────────────────────
if array.size(lvlLines) > 0
    for i = 0 to array.size(lvlLines) - 1
        line.set_x2(array.get(lvlLines, i), bar_index)

// ─────────────────────────────────────────────────────────────────────────────
// DETECT DEFENDED LEVELS FROM FOOTPRINT
// ─────────────────────────────────────────────────────────────────────────────
var float newSupportPrice    = na
var float newSupportVol      = na
var float newSupportRatio    = na
var float newResistPrice     = na
var float newResistVol       = na
var float newResistRatio     = na

newSupportPrice := na
newSupportVol   := na
newSupportRatio := na
newResistPrice  := na
newResistVol    := na
newResistRatio  := na

if isWithinLookback and not na(footprintData) and array.size(footprint.rows(footprintData)) > 0
    rows     = footprint.rows(footprintData)
    rowCount = array.size(rows)
    barRange = high - low

    if barRange > 0
        float wickZone    = barRange * (wickPct / 100.0)
        float closeAwayPt = barRange * (minCloseAway / 100.0)

        // --- Aggregate defense volume at bottom (support) ---
        float defBuyVol     = 0.0
        float defBuyPriceWt = 0.0
        float defBuyMaxRat  = 0.0

        // --- Aggregate defense volume at top (resistance) ---
        float defSellVol     = 0.0
        float defSellPriceWt = 0.0
        float defSellMaxRat  = 0.0

        for i = 0 to rowCount - 1
            volume_row row = array.get(rows, i)

            float buyVol  = volume_row.buy_volume(row)
            float sellVol = volume_row.sell_volume(row)
            float price   = volume_row.down_price(row)
            float totalV  = buyVol + sellVol
            float delta   = math.abs(buyVol - sellVol)

            if delta >= minRowDelta and totalV > 0
                // Bottom zone — buyers defending (potential support)
                if price <= low + wickZone
                    float ratio = sellVol > 0 ? buyVol / sellVol : buyVol
                    if ratio >= imbalanceRatio
                        defBuyVol     += totalV
                        defBuyPriceWt += price * totalV
                        defBuyMaxRat  := math.max(defBuyMaxRat, ratio)

                // Top zone — sellers defending (potential resistance)
                if price >= high - wickZone
                    float ratio = buyVol > 0 ? sellVol / buyVol : sellVol
                    if ratio >= imbalanceRatio
                        defSellVol     += totalV
                        defSellPriceWt += price * totalV
                        defSellMaxRat  := math.max(defSellMaxRat, ratio)

        // --- Qualify support: enough volume AND close moved away from lows ---
        if defBuyVol >= minTotalVol and (close - low) >= closeAwayPt
            newSupportPrice := defBuyPriceWt / defBuyVol
            newSupportVol   := defBuyVol
            newSupportRatio := defBuyMaxRat

        // --- Qualify resistance: enough volume AND close moved away from highs ---
        if defSellVol >= minTotalVol and (high - close) >= closeAwayPt
            newResistPrice := defSellPriceWt / defSellVol
            newResistVol   := defSellVol
            newResistRatio := defSellMaxRat

// ─────────────────────────────────────────────────────────────────────────────
// CREATE NEW LEVELS (with merge/replace logic)
// ─────────────────────────────────────────────────────────────────────────────
f_addLevel(float price, bool isSupport, float vol, float ratio) =>
    // Check for nearby existing level
    int   mergeIdx  = -1
    float mergeDist = na

    if array.size(lvlPrices) > 0
        for i = 0 to array.size(lvlPrices) - 1
            float d = math.abs(price - array.get(lvlPrices, i))
            if d <= mergePoints
                if na(mergeDist) or d < mergeDist
                    mergeDist := d
                    mergeIdx  := i

    bool shouldDraw = true

    if mergeIdx >= 0
        // Nearby level exists — replace if new one is stronger
        float oldVol = array.get(lvlVolumes, mergeIdx)
        if vol > oldVol
            // Replace: delete old, draw new
            line.delete(array.get(lvlLines, mergeIdx))
            label.delete(array.get(touchLabels, mergeIdx))
            array.set(lvlPrices,    mergeIdx, price)
            array.set(lvlIsSupport, mergeIdx, isSupport)
            array.set(lvlVolumes,   mergeIdx, vol)
            array.set(lvlRatios,    mergeIdx, ratio)
            array.set(lvlBarIdx,    mergeIdx, bar_index)
            array.set(bullTouches,  mergeIdx, 0)
            array.set(bearTouches,  mergeIdx, 0)
            array.set(retestVols,   mergeIdx, 0)
            array.set(breakCount,   mergeIdx, 0)

            col = isSupport ? supportColor : resistanceColor
            ln = line.new(bar_index, price, bar_index + 1, price,
                  color=col, width=lineWidthBase, style=f_lineStyle())
            array.set(lvlLines, mergeIdx, ln)

            lblText = showVolLabel ? str.tostring(math.round(vol)) : ""
            lblCol  = color.new(isSupport ? supportColor : resistanceColor, 30)
            lbl = label.new(bar_index, price, text=lblText,
                  style=label.style_label_left, color=lblCol,
                  textcolor=color.white, size=f_labelSize())
            array.set(touchLabels, mergeIdx, lbl)
        // else: old level is stronger, skip
        shouldDraw := false

    if shouldDraw
        col = isSupport ? supportColor : resistanceColor
        ln = line.new(bar_index, price, bar_index + 1, price,
              color=col, width=lineWidthBase, style=f_lineStyle())
        array.push(lvlLines, ln)
        array.push(lvlPrices, price)
        array.push(lvlIsSupport, isSupport)
        array.push(lvlVolumes, vol)
        array.push(lvlRatios, ratio)
        array.push(lvlBarIdx, bar_index)
        array.push(breakCount, 0)

        // Touch label
        lblText = showVolLabel ? str.tostring(math.round(vol)) : "▲0 ▼0"
        lblCol  = color.new(isSupport ? supportColor : resistanceColor, 30)
        lbl = label.new(bar_index, price, text=lblText,
              style=label.style_label_left, color=lblCol,
              textcolor=color.white, size=f_labelSize())
        array.push(touchLabels, lbl)
        array.push(bullTouches, 0)
        array.push(bearTouches, 0)
        array.push(retestVols, 0)

        // Prune oldest if over cap
        while array.size(lvlLines) > maxLevels
            line.delete(array.shift(lvlLines))
            label.delete(array.shift(touchLabels))
            array.shift(lvlPrices)
            array.shift(lvlIsSupport)
            array.shift(lvlVolumes)
            array.shift(lvlRatios)
            array.shift(lvlBarIdx)
            array.shift(bullTouches)
            array.shift(bearTouches)
            array.shift(retestVols)
            array.shift(breakCount)

// Add support level
if not na(newSupportPrice)
    f_addLevel(newSupportPrice, true, newSupportVol, newSupportRatio)

// Add resistance level
if not na(newResistPrice)
    f_addLevel(newResistPrice, false, newResistVol, newResistRatio)

// ─────────────────────────────────────────────────────────────────────────────
// TOUCH DETECTION
// ─────────────────────────────────────────────────────────────────────────────
if array.size(lvlPrices) > 0
    for i = 0 to array.size(lvlPrices) - 1
        float lvl = array.get(lvlPrices, i)

        // Did this bar's range reach the level?
        bool reached = low <= lvl + touchTol and high >= lvl - touchTol

        if reached
            if close > lvl
                array.set(bullTouches, i, array.get(bullTouches, i) + 1)
            else if close < lvl
                array.set(bearTouches, i, array.get(bearTouches, i) + 1)

            // Accumulate the footprint volume transacted at the level on this retest
            if accumTouchVol
                float atLvl = f_volAtPrice(footprintData, lvl)
                array.set(retestVols, i, array.get(retestVols, i) + atLvl)

        // Update label
        lbl   = array.get(touchLabels, i)
        int bt = array.get(bullTouches, i)
        int st = array.get(bearTouches, i)
        float vol  = array.get(lvlVolumes, i)
        float rvol = array.get(retestVols, i)

        string volStr = str.tostring(math.round(vol))
        if accumTouchVol and rvol > 0
            volStr += " (+" + str.tostring(math.round(rvol)) + ")"

        string t = ""
        if showVolLabel and showTouchLabels
            t := volStr + "  ▲" + str.tostring(bt) + " ▼" + str.tostring(st)
        else if showVolLabel
            t := volStr
        else if showTouchLabels
            t := "▲" + str.tostring(bt) + " ▼" + str.tostring(st)

        label.set_xy(lbl, bar_index, lvl)
        label.set_text(lbl, t)

        float totVol = vol + rvol
        string tipDir = array.get(lvlIsSupport, i) ? "SUPPORT" : "RESISTANCE"
        label.set_tooltip(lbl, tipDir +
              "\nPrice     : " + str.tostring(lvl, format.mintick) +
              "\nDefense   : " + str.tostring(math.round(vol)) +
              "\nRetest Vol: " + str.tostring(math.round(rvol)) +
              "\nTotal Vol : " + str.tostring(math.round(totVol)) +
              "\nRatio     : " + str.tostring(math.round(array.get(lvlRatios, i), 1)) + "x" +
              "\nBullish   : " + str.tostring(bt) +
              "\nBearish   : " + str.tostring(st))

// ─────────────────────────────────────────────────────────────────────────────
// SORTED LEVEL EXPORT (nearest support/resistance levels)
// ─────────────────────────────────────────────────────────────────────────────
// Sort all active levels and export as support/resistance ranked by proximity
float sup1 = 0, float sup2 = 0, float sup3 = 0, float sup4 = 0
float res1 = 0, float res2 = 0, float res3 = 0, float res4 = 0

if array.size(lvlPrices) > 0
    // Separate into support and resistance arrays sorted by distance from close
    var float[] supPrices = array.new<float>()
    var float[] resPrices = array.new<float>()
    array.clear(supPrices)
    array.clear(resPrices)

    for i = 0 to array.size(lvlPrices) - 1
        float p = array.get(lvlPrices, i)
        if array.get(lvlIsSupport, i)
            array.push(supPrices, p)
        else
            array.push(resPrices, p)

    // Sort descending for support (nearest below first)
    array.sort(supPrices, order.descending)
    // Sort ascending for resistance (nearest above first)
    array.sort(resPrices, order.ascending)

    sup1 := array.size(supPrices) > 0 ? array.get(supPrices, 0) : 0
    sup2 := array.size(supPrices) > 1 ? array.get(supPrices, 1) : 0
    sup3 := array.size(supPrices) > 2 ? array.get(supPrices, 2) : 0
    sup4 := array.size(supPrices) > 3 ? array.get(supPrices, 3) : 0
    res1 := array.size(resPrices) > 0 ? array.get(resPrices, 0) : 0
    res2 := array.size(resPrices) > 1 ? array.get(resPrices, 1) : 0
    res3 := array.size(resPrices) > 2 ? array.get(resPrices, 2) : 0
    res4 := array.size(resPrices) > 3 ? array.get(resPrices, 3) : 0

// Plot to price scale + data window
plot(sup1, "Sup 1", supportColor, style = plot.style_circles, linewidth = 2, display=(preservePlots ? display.pane : display.none) + display.price_scale + display.data_window)
plot(sup2, "Sup 2", supportColor, style = plot.style_circles, linewidth = 2, display=(preservePlots ? display.pane : display.none) + display.price_scale + display.data_window)
plot(sup3, "Sup 3", supportColor, style = plot.style_circles, linewidth = 2, display=(preservePlots ? display.pane : display.none) + display.price_scale + display.data_window)
plot(sup4, "Sup 4", supportColor, style = plot.style_circles, linewidth = 2, display=(preservePlots ? display.pane : display.none) + display.price_scale + display.data_window)
plot(res1, "Res 1", resistanceColor,   style = plot.style_circles, linewidth = 2, display=(preservePlots ? display.pane : display.none) + display.price_scale + display.data_window)
plot(res2, "Res 2", resistanceColor,   style = plot.style_circles, linewidth = 2, display=(preservePlots ? display.pane : display.none) + display.price_scale + display.data_window)
plot(res3, "Res 3", resistanceColor,   style = plot.style_circles, linewidth = 2, display=(preservePlots ? display.pane : display.none) + display.price_scale + display.data_window)
plot(res4, "Res 4", resistanceColor,   style = plot.style_circles, linewidth = 2, display=(preservePlots ? display.pane : display.none) + display.price_scale + display.data_window)
````
