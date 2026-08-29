<!-- tradingview-pine-id: PUB;ff1a0136336340f38e908eeb12ea33aa -->
<!-- tradingviewscripts-format: 1 -->
# Volume Gaps & Imbalances (Zeiierman)

Source: https://www.tradingview.com/script/Q7YQQq7g-Volume-Gaps-Imbalances-Zeiierman/

## Description

█ Overview
Volume Gaps & Imbalances (Zeiierman) is an advanced market-structure and order-flow visualizer that maps where the market traded, where it did not, and how buyer-vs-seller pressure accumulated across the entire price range.
[image]https://www.tradingview.com/x/VDipHTvu/[/image] 
The core of the indicator is a price-by-price volume profile built from Bullish and Bearish volume assignments. The script highlights:

[*]True zero-volume voids (regions of no traded volume)
[*]Bull/Bear imbalance rows (horizontal volume slices)
[*]A multi-section Delta Panel, showing aggregated Buy–Sell pressure per vertical sector
[*]A clean separation between profile structure, volume efficiency, and delta flows

Together, these components reveal market inefficiencies, displacement zones, and fair-value regions that price tends to revisit — making it an exceptional tool for structural trading, order-flow analysis, and contextual confluence.
[image]https://www.tradingview.com/x/poAHDyhC/[/image]
Highlights

[*]Identifies true volume voids (untraded price regions), more precisely than standard FVG tools
[*]Plots Bull vs Bear volume at each price row for fine-grained imbalance reading
[*]Includes a sector-based Delta Grid that aggregates Buy–Sell dominance

█ How It Works
⚪ Profile Construction
The indicator scans a user-defined Lookback window and divides the full high–low range into Rows. Each bar's volume is allocated into the correct price bucket:

[*]Bullish volume when close > open
[*]Bearish volume when close <= open

This produces three values per price level:

[*]Bull Volume
[*]Bear Volume
[*]Total Volume & Imbalance Profile

Rows where no volume at all occurred are marked as volume gaps — signaling true untraded zones, often produced by impulsive imbalanced moves.

⚪ Zero-Volume Gaps (True Voids)
Unlike candle-based Fair Value Gaps (FVGs), volume gaps identify the deeper, structural inefficiency: Price moved so fast through a region that no trades occurred at those prices. These areas often attract revisits because liquidity never exchanged hands there.

⚪ Bull/Bear Volume Imbalance
Every price row is drawn using two colored horizontal segments:

[*]Bull segment proportional to bullish volume
[*]Bear segment proportional to bearish volume

This reveals where buyers or sellers dominated individual price levels.

⚪ Delta Panel
The full volume profile is cut into Summary Sections. For each block, the script computes: Δ = (Bull Volume − Bear Volume) ÷ Total Volume × 100%
█ How to Use

⚪ Spot True Voids & Inefficiencies
Zero-volume zones highlight where the price moved without trading. These areas often behave like:

[*]Refill zones during retracements
[*]Targets during displacement
[*]Thin regions price slices through quickly

Ideal for both SMC-style trading and structural mapping.
[image]https://www.tradingview.com/x/imPtynq5/[/image] 
⚪ Identify Bull/Bear Control at Each Price Level
Broad bullish segments show zones of buyer absorption, while wide bearish slices reveal seller control.

This helps you interpret:

[*]Where buyers supported the price
[*]Where sellers defended a level
[*]Which price levels matter for continuation or reversal

[image]https://www.tradingview.com/x/RyOzcWOW/[/image]
⚪ Use Delta Sectors for Contextual Direction
The delta panel shows where market pressure is accumulating, revealing whether the profile is dominated by:

[*]Bullish flow (positive delta)
[*]Bearish flow (negative delta)
[*]Neutral flow (balanced or minimal delta)

[image]https://www.tradingview.com/x/24lnhdEn/[/image]
█ Settings 

[*]Lookback – Number of bars scanned to build the profile.
[*]Rows – Vertical resolution of price bins.
[*]Source – Price source used to assign volume into rows.
[*]Summary Sections – Number of vertical delta sectors.
[*]Summary Width – Horizontal size of the delta bar panel.
[*]Gap From Profile – Distance between profile and delta grid.
[*]Show Delta Text – Toggle Δ% labels.

-----------------
Disclaimer

The content provided in my scripts, indicators, ideas, algorithms, and systems is for educational and informational purposes only. It does not constitute financial advice, investment recommendations, or a solicitation to buy or sell any financial instruments. I will not accept liability for any loss or damage, including without limitation any loss of profit, which may arise directly or indirectly from the use of or reliance on such information.

All investments involve risk, and the past performance of a security, industry, sector, market, financial product, trading strategy, backtest, or individual's trading does not guarantee future results or returns. Investors are fully responsible for any investment decisions they make. Such decisions should be based solely on an evaluation of their financial circumstances, investment objectives, risk tolerance, and liquidity needs.

---

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © Zeiierman {
//@version=6
indicator("Volume Gaps & Imbalances (Zeiierman)", overlay = true, max_boxes_count = 500)
// ~~ Tooltips {
var string t1  = "Number of historical bars used to build the volume profile and zero-volume gaps.\nHigher = smoother, more stable profile but heavier on performance."
var string t2  = "Number of price rows (bins) between the highest and lowest price in the lookback range.\nHigher = more detailed profile, lower = more compact."
var string t3  = "Price source used when assigning each bar to a price row in the profile (e.g. HLC3, Close)."
var string t4  = "Horizontal width in bars for the main volume profile drawn to the right of price."
var string t5  = "Fill color for the bullish portion of each price row (bars where Close > Open)."
var string t6  = "Fill color for the bearish portion of each price row (bars where Close <= Open)."
var string t7  = "Background color used to highlight zero-volume price gaps (no traded volume in that row)."
var string t8  = "Number of stacked sections in the delta panel.\nEach section aggregates Buy/Sell delta for a vertical slice of the full profile."
var string t9  = "Horizontal width in bars of the delta summary panel."
var string t10 = "Horizontal gap, in bars, between the main volume profile and the delta panel."
var string t11 = "Show or hide the Δ (delta) percentage text inside each delta bar."
var string t12 = "Color used when delta is positive in a section (Buy volume > Sell volume)."
var string t13 = "Color used when delta is negative in a section (Sell volume > Buy volume)."
var string t14 = "Background color of the delta panel and neutral areas when there is little or no delta."
var string t15 = "Text color for the Δ percentage labels inside the delta bars."
var string t16 = "Minimum visual size of any non-zero delta bar as a fraction of the panel width.\nUse a larger value to keep small deltas visible."
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Settings {
// ~~ Settings {
prd         = input.int(200, "Lookback", minval = 50, maxval = 2000, tooltip = t1, group = "Profile Settings")
rows        = input.int(50, "Rows", minval = 10, maxval = 100, inline = "a", tooltip = t2, group = "Profile Settings")
src         = input.source(hlc3, "", inline = "a", tooltip = t1 + "\n\n" + t2 + "\n\n" + t3, group = "Profile Settings")

width       = input.int(100, "Profile Placement", minval = 1, maxval = 500, tooltip = t4, group = "Profile Styling")
bull_color  = input.color(color.new(color.blue, 30), "Bull Color", inline = "prof_set", tooltip = t5, group = "Profile Styling")
bear_color  = input.color(color.new(color.orange, 30), "Bear Color", inline = "prof_set", tooltip = t6, group = "Profile Styling")
zone_color  = input.color(color.new(color.navy, 50), "Zero-Volume Zone", inline = "prof_set", tooltip = t5 + "\n\n" + t6 + "\n\n" + t7, group = "Profile Styling")

sum_sections   = input.int(20, "Summary Sections", minval = 1, maxval = 100, tooltip = t8, group = "Delta Summary")
sum_panel_w    = input.int(40, "Summary Width", minval = 10, maxval = 200, tooltip = t9, group = "Delta Summary")
sum_gap_x      = input.int(4,  "Gap From Profile", minval = 1, maxval = 50, tooltip = t10, group = "Delta Summary")
sum_show_label = input.bool(true, "Show Delta Text", tooltip = t11, group = "Delta Summary")

delta_pos_color  = input.color(color.new(color.lime, 20), "Delta Buy Color", tooltip = t12, group = "Delta Styling")
delta_neg_color  = input.color(color.new(color.red,  20), "Delta Sell Color", tooltip = t13, group = "Delta Styling")
delta_neutral_bg = input.color(color.new(color.gray, 90), "Delta Neutral BG", tooltip = t14, group = "Delta Styling")
delta_text_color = input.color(color.white, "Delta Text Color", tooltip = t15, group = "Delta Styling")
delta_min_frac   = input.float(0.2, "Delta Min Size (fraction of width)", minval = 0.0, maxval = 1.0, step = 0.1, tooltip = t16, group = "Delta Styling")
//~~}

// ~~ Variables {
b = bar_index

lvls        = array.new<float>()
bull_vols   = array.new<float>()
bear_vols   = array.new<float>()
zone        = array.new<box>()
//~~}

// ~~ Main {
hi = ta.highest(high, prd)
lo = ta.lowest(low, prd)

if barstate.islast
    // Clear old boxes & labels
    for e in box.all
        e.delete()
    for l in label.all
        label.delete(l)

    //Profile Range Box
    box.new(
         chart.point.from_index(b-prd,hi),
         chart.point.from_index(b+width,lo),
         color.new(chart.fg_color,50),
         2,
         line.style_dotted,
         bgcolor = color(na)
     )

    // Build levels
    step = (hi - lo) / rows
    for i = lo to hi by step
        lvls.push(i)
        bull_vols.push(0.0)
        bear_vols.push(0.0)

    // Volume assignment
    for i = prd to 0
        price   = src[i]
        is_bull = close[i] > open[i]
        for j = 0 to lvls.size() - 2
            levelLow  = lvls.get(j)
            levelHigh = lvls.get(j + 1)
            if price > levelLow and price <= levelHigh
                if is_bull
                    bull_vols.set(j, bull_vols.get(j) + volume[i])
                else
                    bear_vols.set(j, bear_vols.get(j) + volume[i])
                break

    // Calculate maxVol based on total volumes
    maxVol = 0.0
    for i = 0 to lvls.size() - 2
        vol_i = bull_vols.get(i) + bear_vols.get(i)
        if vol_i > maxVol
            maxVol := vol_i

    // Create profile
    for i = 0 to lvls.size() - 2
        bull_i = bull_vols.get(i)
        bear_i = bear_vols.get(i)
        vol_i  = bull_i + bear_i
        norm_v = maxVol > 0 ? math.round((vol_i / maxVol) * width) : 0

        if norm_v > 0
            norm_bull  = bull_i > 0 ? math.round((bull_i / vol_i) * norm_v) : 0
            norm_bear  = norm_v - norm_bull
            left_start = b + width - norm_v

            // Draw bull box
            if norm_bull > 0
                box.new(
                     left   = left_start,
                     top    = lvls.get(i + 1),
                     right  = left_start + norm_bull,
                     bottom = lvls.get(i),
                     border_color = color.new(chart.fg_color,90),
                     bgcolor = bull_color
                 )

            // Draw bear box
            if norm_bear > 0
                box.new(
                     left   = left_start + norm_bull,
                     top    = lvls.get(i + 1),
                     right  = b + width,
                     bottom = lvls.get(i),
                     border_color = color.new(chart.fg_color,90),
                     bgcolor = bear_color
                 )

        // Zero-volume zone
        if vol_i == 0
            zeroBox = box.new(
                 left   = b - prd,
                 top    = lvls.get(i + 1),
                 right  = b,
                 bottom = lvls.get(i),
                 border_color = na,
                 bgcolor = zone_color
             )
            zone.push(zeroBox)

    //Zone merge
    if zone.size() > 1
        i = 0
        while i < zone.size()
            currentBox = zone.get(i)
            currentTop = currentBox.get_top()

            // Look ahead to find the end of consecutive touching zones
            j = i + 1
            while j < zone.size()
                nextBox = zone.get(j)
                if math.abs(nextBox.get_bottom() - currentTop) > 1e-10
                    break
                currentTop := nextBox.get_top()
                j += 1

            chainLength = j - i

            if chainLength > 1
                // Merge all boxes into one big box
                firstBox = zone.get(i)
                lastBox  = zone.get(j - 1)

                mergedBox = box.new(
                     left   = b - prd,
                     top    = lastBox.get_top(),
                     right  = b,
                     bottom = firstBox.get_bottom(),
                     border_color = na,
                     bgcolor = zone_color
                 )

                // Delete old boxes (from last to first to preserve indices while removing)
                for k = j - 1 to i by 1
                    boxToDelete = zone.get(k)
                    boxToDelete.delete()
                    zone.remove(k)

                // Insert the merged box
                zone.insert(i, mergedBox)

                // Next iteration starts right after the newly inserted merged box
                i += 1
            else
                // No merge needed, move to next
                i += 1
    
    // Adjust left edges of final zones
    if zone.size()>0
        float epsilon = 1e-10
        for ii = 0 to zone.size() - 1
            currentBox = zone.get(ii)
            ztop = currentBox.get_top()
            zbot = currentBox.get_bottom()
            left_idx = b - prd
            for off = prd to 0 by 1
                if low[off] <= ztop + epsilon and high[off] >= zbot - epsilon or
                   high[off] >= zbot - epsilon and low[off] <= zbot + epsilon or
                   low[off] <= zbot + epsilon and high[off] >= ztop - epsilon
                    left_idx := b - off
                    break
            currentBox.set_left(left_idx)

    // Delta
    lvlCount = lvls.size()
    rowsUsed = lvlCount > 0 ? lvlCount - 1 : 0

    if rowsUsed > 0 and sum_sections > 0
        // rows per section
        secRows = math.max(1, math.floor(rowsUsed / sum_sections))

        baseLeft  = b + width + sum_gap_x
        baseRight = baseLeft + sum_panel_w

        for s = 0 to sum_sections - 1
            startIdx = s * secRows
            endIdx   = s == sum_sections - 1 ? rowsUsed - 1 : math.min(rowsUsed - 1, (s + 1) * secRows - 1)

            if startIdx > endIdx
                continue

            segBull = 0.0
            segBear = 0.0

            for j = startIdx to endIdx
                segBull += bull_vols.get(j)
                segBear += bear_vols.get(j)

            segTot = segBull + segBear
            if segTot <= 0
                continue

            // vertical range of this section
            segTop    = lvls.get(endIdx + 1)
            segBottom = lvls.get(startIdx)

            box.new(
                 left   = baseLeft,
                 top    = segTop,
                 right  = baseRight,
                 bottom = segBottom,
                 border_color = color.new(chart.fg_color, 70),
                 bgcolor = delta_neutral_bg
             )

            // Delta: (Bull - Bear) as % of total => [-100, +100]
            deltaPct = (segBull - segBear) / segTot * 100.0

            // bar length: abs(delta), with minimum visual size
            float barLenFrac = 0.0
            float barLen     = 0.0

            if deltaPct != 0
                norm       = math.abs(deltaPct) / 100.0
                barLenFrac := math.max(delta_min_frac, math.min(1.0, norm))
                barLen     := sum_panel_w * barLenFrac
            else
                barLenFrac := 0.0
                barLen     := 0.0

            // coordinates for the delta bar (always from the left)
            float dLeft  = baseLeft
            float dRight = baseLeft + barLen

            // choose color by sign
            colDelta = delta_neutral_bg
            if deltaPct > 0
                colDelta := delta_pos_color
            else if deltaPct < 0
                colDelta := delta_neg_color

            // if delta is exactly 0, still draw a very small neutral bar
            if deltaPct == 0
                dRight := baseLeft + 1

            // Delta bar (cast x-coordinates to int for box.new)
            deltaBox = box.new(
                 left   = int(math.round(dLeft)),
                 top    = segTop,
                 right  = int(math.round(dRight)),
                 bottom = segBottom,
                 border_color = color.new(chart.fg_color, 20),
                 bgcolor = colDelta
             )

            // Text inside the delta bar
            if sum_show_label
                txt = "Δ " + str.tostring(deltaPct, "#.0") + "%"
                box.set_text(deltaBox, txt)
                box.set_text_color(deltaBox, delta_text_color)
                box.set_text_halign(deltaBox, text.align_center)
                box.set_text_valign(deltaBox, text.align_center)
//~~}
````
