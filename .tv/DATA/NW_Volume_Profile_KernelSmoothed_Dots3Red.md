<!-- tradingview-pine-id: PUB;48a2426a66c2427784288916babaafff -->
<!-- tradingviewscripts-format: 1 -->
# NW Volume Profile — Kernel-Smoothed [Dots3Red]

Source: https://www.tradingview.com/script/wqEZomb4-NW-Volume-Profile-Kernel-Smoothed-Dots3Red/

## Description

📊 NW VOLUME PROFILE - KERNEL-SMOOTHED [Dots3Red]
A volume profile answers a different question than a normal chart. Instead of "how much traded today," it asks "how much traded at each price." This version applies Nadaraya-Watson kernel smoothing to that profile before reading any level off it — turning a jagged, noisy histogram into the actual underlying distribution of where volume concentrated.

🎯 WHY THIS MATTERS
A raw volume profile is built from independent price bins — each one only knows its own volume, nothing about its neighbors. That makes it noisy: a single oversized candle can create a spike that looks like an important level but is really just where one bar happened to land. Reading real structure off a raw histogram means squinting past that noise.

This script smooths the profile before drawing anything. Every bin's displayed value becomes a weighted average of its neighborhood — nearby bins count heavily, distant bins barely at all, following a Gaussian curve. The lumps from individual candles melt away, and what's left is the true shape of the distribution that was underneath the noise the whole time. All the levels described below — POC, Value Area, HVN, LVN — are read from that smoothed curve, not the raw one.

🧮 HOW THE SMOOTHING WORKS
Each price bin's raw volume gets replaced by:

smoothed(i) = Σⱼ w(i,j) · raw[j] / Σⱼ w(i,j)

where w(i,j) is a Gaussian weight based on how many bins apart i and j are, controlled by the Bandwidth setting. A small bandwidth stays close to the raw histogram; a large one produces one broad, simplified hump. This is genuine kernel regression applied across the price axis, not a moving average or a visual blur — it's the same mathematical technique used in the smoothed lines several Dots3Red scripts already use for slope/trend estimation, applied here to a distribution instead of a time series.

Toggle "Show Raw Histogram Behind" to see the original jagged bars faintly displayed underneath the smoothed profile — a direct before/after comparison on your own chart.

📏 WHAT EACH LEVEL MEANS
🟡 POC (Point of Control) — the single price with the highest smoothed volume. The market's center of gravity for the current window; price tends to be pulled back toward it.

🔵 Value Area — the price region around the POC containing a configurable share of total volume (default 70%). Price trading inside it is trading at a level the market recently agreed was fair — chop and rotation are common here. Price breaking out of it is the market rejecting that agreement, which is often when moves extend rather than stall.

🟢 HVN (High Volume Node) — a secondary local peak in the smoothed distribution. Acts like a sticky zone; price tends to slow down or pause when revisiting one.

🔴 LVN (Low Volume Node) — a local trough where very little volume ever traded. Acts like a thin spot; price tends to move through it quickly rather than lingering, since few positions were ever opened there.

HVN and LVN are drawn as full-width dotted lines across the chart (not just labels at the profile edge), specifically so they stay visible and trackable even after price has moved well away from where the profile itself was drawn.

🧭 HOW TO USE
👀 Start with where price sits relative to the Value Area. Inside it: expect rotation and two-way trade. Outside it: the move has already broken from recent consensus, which historically has more follow-through than reversion.

🧲 Treat POC as a magnet, not a wall. It is the level most likely to be revisited, not a guaranteed reversal point. How price behaves when it gets there — accepted or rejected — is the actual signal, not the level itself.

🐌 Expect hesitation at HVNs. A move approaching an HVN from your prior window is approaching a zone where the market has previously done a lot of business — some slowing or consolidation there is common.

⚡ Expect speed through LVNs. A thin zone with very little historical volume tends to get crossed quickly rather than acting as support or resistance. If price is moving toward one, a fast move through it before finding real support/resistance at the next node is a reasonable expectation.

🔧 Adjust Bandwidth to match what you're looking for. A tighter bandwidth reveals more granular structure (closer to raw); a wider one collapses the profile into its dominant, unmistakable levels. There's no universally correct setting — it depends on whether you want detail or clarity.

💡 EXAMPLE
Say the profile shows POC at 61,200, a Value Area from 60,400 to 62,100, and an LVN line sitting at 59,800. Price later drops to 60,450 — right at the edge of the Value Area. Two distinct scenarios are now readable from the profile: if price holds and turns back up, the 61,200 POC above is the natural target the market has repeatedly gravitated toward. If instead price breaks below 60,400, the empty LVN at 59,800 offers little historical volume to slow the decline — a fast move through that zone before finding the next real level is the more likely path. Same chart, two different expectations, both read directly off the same profile without any additional indicator.

⚙️ SETTINGS
📊 Profile
• Lookback (bars) — size of the rolling window the profile is built from
• Price Bins — vertical resolution of the profile
• Body Volume Only — distribute volume across the candle body instead of the full high-low range

🧮 Kernel Smoothing
• Bandwidth — width of the Gaussian kernel in bin units; controls detail vs. simplification

📏 Levels
• Value Area % — share of total volume the Value Area is expanded to contain
• Node Detection Leg — how many neighboring bins define a local peak/trough
• LVN Max Ratio of POC — how thin a trough must be, relative to POC, to count as an LVN

🎨 Visualization
• Show Raw Histogram Behind, POC Line, Value Area, HVN/LVN Marks — each independently toggleable
• Profile Width — how far the profile extends horizontally

🖥️ Dashboard
• Show/hide, position — displays current POC, Value Area bounds, node counts, and the active window/bandwidth settings

📝 NOTES
This profile is a rolling window — its levels update as the window slides forward with each new bar, which is expected behavior for a volume profile rather than a repainting signal (nothing appears and then vanishes; the underlying window is simply moving). Thin-volume symbols will produce a ragged profile regardless of smoothing settings — this tool is most informative on liquid instruments with consistent volume.

⚠️ DISCLAIMER
This is an analytical and visualization tool. It does not generate trade signals and does not constitute financial advice. Historical volume concentration at a given level does not guarantee how price will behave there in the future.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Dots3Red
// TradingView: https://www.tradingview.com/u/Dots3Red/

//@version=6
indicator("NW Volume Profile — Kernel-Smoothed [Dots3Red]",
          shorttitle = "NW VP [D3R]",
          overlay    = true,
          max_boxes_count  = 500,
          max_lines_count  = 500,
          max_labels_count = 500)


// COLORS
C_BULL    = color.new(#00f0ff, 0)
C_BEAR    = color.new(#ff00aa, 0)
C_GREEN   = color.new(#00c896, 0)
C_RED     = color.new(#ff4466, 0)
C_AMBER   = color.new(#ffb700, 0)
C_NEUTRAL = color.new(#64748b, 0)
C_BG      = color.new(#131722, 5)
C_TXT     = color.new(#f8fafc, 0)
C_DIM     = color.new(#94a3b8, 0)
C_BORD    = color.new(#334155, 0)


// INPUTS
GRP_PROF = "📊 Profile"
GRP_NW   = "🧮 Kernel Smoothing"
GRP_LVL  = "📏 Levels"
GRP_VIS  = "🎨 Visualization"
GRP_HUD  = "🖥️ Dashboard"

lookback  = input.int(200, "Lookback (bars)",   minval=20, maxval=1000, group=GRP_PROF,
            tooltip="How many bars back the profile window covers. The profile slides forward with each new bar.")
n_bins    = input.int(60,  "Price Bins",        minval=10, maxval=120, group=GRP_PROF,
            tooltip="Number of horizontal price rows the range is split into.")
use_body  = input.bool(false, "Body Volume Only", group=GRP_PROF,
            tooltip="ON: distribute volume across the candle body (open-close). OFF: across the full high-low range.")

bandwidth = input.float(3.0, "Kernel Bandwidth (bins)", minval=0.5, maxval=15.0, step=0.5, group=GRP_NW,
            tooltip="Width of the Gaussian kernel in bin units. Larger = smoother curve, fewer but stronger nodes. Smaller = closer to the raw histogram.")

va_pct    = input.float(70.0, "Value Area %", minval=40.0, maxval=95.0, step=5.0, group=GRP_LVL)
node_leg  = input.int(2, "Node Detection Leg (bins)", minval=1, maxval=6, group=GRP_LVL,
            tooltip="A bin is an HVN/LVN if it is the max/min among this many bins on each side of it on the smoothed curve.")
lvn_max_ratio = input.float(0.35, "LVN Max Ratio of POC", minval=0.05, maxval=0.8, step=0.05, group=GRP_LVL,
            tooltip="A local minimum only counts as an LVN if its smoothed volume is below this fraction of the POC volume.")

prof_width = input.int(35, "Profile Width (% of window)", minval=10, maxval=70, group=GRP_VIS,
            tooltip="Horizontal extent of the profile as a percentage of the lookback window.")
show_raw   = input.bool(false, "Show Raw Histogram Behind", group=GRP_VIS,
            tooltip="Draw the unsmoothed histogram faintly behind the smoothed profile for comparison.")
show_poc   = input.bool(true, "POC Line",        group=GRP_VIS)
show_va    = input.bool(true, "Value Area",      group=GRP_VIS)
show_nodes = input.bool(true, "HVN / LVN Marks", group=GRP_VIS)

show_hud = input.bool(true, "Show Dashboard", group=GRP_HUD)
hud_pos  = input.string("Bottom Right", "Position",
           options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=GRP_HUD)


// DRAWING STORAGE 
var box[]   bin_boxes  = array.new<box>()
var box[]   raw_boxes  = array.new<box>()
var line[]  lvl_lines  = array.new<line>()
var label[] lvl_labels = array.new<label>()
var box     va_box     = na

f_clear_drawings() =>
    if array.size(bin_boxes) > 0
        for i = 0 to array.size(bin_boxes) - 1
            box.delete(array.get(bin_boxes, i))
        array.clear(bin_boxes)
    if array.size(raw_boxes) > 0
        for i = 0 to array.size(raw_boxes) - 1
            box.delete(array.get(raw_boxes, i))
        array.clear(raw_boxes)
    if array.size(lvl_lines) > 0
        for i = 0 to array.size(lvl_lines) - 1
            line.delete(array.get(lvl_lines, i))
        array.clear(lvl_lines)
    if array.size(lvl_labels) > 0
        for i = 0 to array.size(lvl_labels) - 1
            label.delete(array.get(lvl_labels, i))
        array.clear(lvl_labels)
    if not na(va_box)
        box.delete(va_box)


// PROFILE COMPUTATION — runs fully on the last bar, redrawn as the window slides
var float poc_price = na
var float vah_price = na
var float val_price = na
var int   hvn_count = 0
var int   lvn_count = 0

if barstate.islast
    f_clear_drawings()

    int win = math.min(lookback, bar_index + 1)

    // Window price range
    float range_hi = high
    float range_lo = low
    for k = 0 to win - 1
        range_hi := math.max(range_hi, high[k])
        range_lo := math.min(range_lo, low[k])

    float bin_h = (range_hi - range_lo) / float(n_bins)

    if bin_h > 0
        // RAW PROFILE: distribute each bar's volume across its bins 
        float[] raw = array.new<float>(n_bins, 0.0)
        for k = 0 to win - 1
            float bar_hi = use_body ? math.max(open[k], close[k]) : high[k]
            float bar_lo = use_body ? math.min(open[k], close[k]) : low[k]
            if bar_hi <= bar_lo
                bar_hi := bar_lo + bin_h * 0.01
            float bar_v = nz(volume[k])
            int i_lo = math.max(0, math.min(n_bins - 1, int(math.floor((bar_lo - range_lo) / bin_h))))
            int i_hi = math.max(0, math.min(n_bins - 1, int(math.floor((bar_hi - range_lo) / bin_h))))
            int spread = i_hi - i_lo + 1
            float v_per = bar_v / float(spread)
            for b = i_lo to i_hi
                array.set(raw, b, array.get(raw, b) + v_per)

        // NADARAYA-WATSON SMOOTHING across bins
        float[] smooth = array.new<float>(n_bins, 0.0)
        for i = 0 to n_bins - 1
            float num = 0.0
            float den = 0.0
            for j = 0 to n_bins - 1
                float d = float(i - j) / bandwidth
                float w = math.exp(-(d * d) / 2.0)
                num += w * array.get(raw, j)
                den += w
            array.set(smooth, i, den > 0 ? num / den : 0.0)

        //  POC 
        int   poc_i = 0
        float poc_v = 0.0
        float sm_total = 0.0
        for i = 0 to n_bins - 1
            float v = array.get(smooth, i)
            sm_total += v
            if v > poc_v
                poc_v := v
                poc_i := i
        poc_price := range_lo + (float(poc_i) + 0.5) * bin_h

        // - VALUE AREA: expand from POC until >= va_pct of total 
        float va_target = sm_total * va_pct / 100.0
        float va_sum    = poc_v
        int   va_up     = poc_i
        int   va_dn     = poc_i
        while va_sum < va_target and (va_up < n_bins - 1 or va_dn > 0)
            float v_up = va_up < n_bins - 1 ? array.get(smooth, va_up + 1) : -1.0
            float v_dn = va_dn > 0          ? array.get(smooth, va_dn - 1) : -1.0
            if v_up >= v_dn and v_up >= 0
                va_up += 1
                va_sum += v_up
            else if v_dn >= 0
                va_dn -= 1
                va_sum += v_dn
            else
                break
        vah_price := range_lo + (float(va_up) + 1.0) * bin_h
        val_price := range_lo + float(va_dn) * bin_h

        //  HVN / LVN: local extrema of the smoothed curve 
        int[] hvn_bins = array.new<int>()
        int[] lvn_bins = array.new<int>()
        for i = node_leg to n_bins - 1 - node_leg
            float vi = array.get(smooth, i)
            bool is_max = true
            bool is_min = true
            for s = 1 to node_leg
                if array.get(smooth, i - s) >= vi or array.get(smooth, i + s) >= vi
                    is_max := false
                if array.get(smooth, i - s) <= vi or array.get(smooth, i + s) <= vi
                    is_min := false
            if is_max and i != poc_i
                array.push(hvn_bins, i)
            if is_min and vi < poc_v * lvn_max_ratio
                array.push(lvn_bins, i)
        hvn_count := array.size(hvn_bins)
        lvn_count := array.size(lvn_bins)

        //  DRAWING 
        int right_x  = bar_index
        int max_w    = math.max(5, math.round(float(win) * float(prof_width) / 100.0))
        int left_ref = bar_index - win + 1

        if show_va
            va_box := box.new(left_ref, vah_price, right_x, val_price,
                              border_color=color.new(C_NEUTRAL, 70),
                              bgcolor=color.new(C_NEUTRAL, 92),
                              border_width=1)

        for i = 0 to n_bins - 1
            float y_lo = range_lo + float(i) * bin_h
            float y_hi = y_lo + bin_h
            float v    = array.get(smooth, i)
            int   w_px = poc_v > 0 ? math.max(1, math.round(v / poc_v * float(max_w))) : 1
            bool  in_va = i >= va_dn and i <= va_up
            color bin_c = i == poc_i ? C_AMBER : in_va ? C_BULL : C_NEUTRAL
            int   bin_t = i == poc_i ? 25 : in_va ? 55 : 75

            if show_raw
                float rv = array.get(raw, i)
                int rw = poc_v > 0 ? math.max(1, math.round(rv / poc_v * float(max_w))) : 1
                array.push(raw_boxes, box.new(
                     right_x - rw, y_hi, right_x, y_lo,
                     border_color=color.new(C_DIM, 90),
                     bgcolor=color.new(C_DIM, 93)))

            array.push(bin_boxes, box.new(
                 right_x - w_px, y_hi, right_x, y_lo,
                 border_color=color.new(bin_c, math.min(95, bin_t + 15)),
                 bgcolor=color.new(bin_c, bin_t)))

        if show_poc
            array.push(lvl_lines, line.new(
                 left_ref, poc_price, right_x, poc_price,
                 color=color.new(C_AMBER, 15), width=2))
            array.push(lvl_labels, label.new(
                 left_ref, poc_price, "POC " + str.tostring(poc_price, format.mintick),
                 style=label.style_label_right,
                 color=color.new(#000000, 100), textcolor=C_AMBER, size=10))

        if show_va
            array.push(lvl_lines, line.new(
                 left_ref, vah_price, right_x, vah_price,
                 color=color.new(C_BULL, 45), width=1, style=line.style_dashed))
            array.push(lvl_lines, line.new(
                 left_ref, val_price, right_x, val_price,
                 color=color.new(C_BULL, 45), width=1, style=line.style_dashed))
            array.push(lvl_labels, label.new(
                 left_ref, vah_price, "VAH " + str.tostring(vah_price, format.mintick),
                 style=label.style_label_right,
                 color=color.new(#000000, 100), textcolor=C_BULL, size=10))
            array.push(lvl_labels, label.new(
                 left_ref, val_price, "VAL " + str.tostring(val_price, format.mintick),
                 style=label.style_label_right,
                 color=color.new(#000000, 100), textcolor=C_BULL, size=10))

        if show_nodes
            if hvn_count > 0
                for hh = 0 to hvn_count - 1
                    int bi = array.get(hvn_bins, hh)
                    float py = range_lo + (float(bi) + 0.5) * bin_h
                    array.push(lvl_lines, line.new(
                        left_ref, py, right_x, py,
                        color=color.new(C_GREEN, 55), width=2, style=line.style_dotted))
                    array.push(lvl_labels, label.new(
                        right_x + 2, py, "HVN",
                        style=label.style_label_left,
                        color=color.new(#000000, 100), textcolor=C_GREEN, size=10))
            if lvn_count > 0
                for ll = 0 to lvn_count - 1
                    int bi = array.get(lvn_bins, ll)
                    float py = range_lo + (float(bi) + 0.5) * bin_h
                    array.push(lvl_lines, line.new(
                        left_ref, py, right_x, py,
                        color=color.new(C_RED, 55), width=2, style=line.style_dotted))
                    array.push(lvl_labels, label.new(
                        right_x + 2, py, "LVN",
                        style=label.style_label_left,
                        color=color.new(#000000, 100), textcolor=C_RED, size=10))


// DASHBOARD
f_hud_pos(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        =>                position.bottom_left

var table hud = table.new(f_hud_pos(hud_pos), 2, 8,
                           bgcolor=C_BG, border_color=C_BORD,
                           border_width=1, frame_color=C_BORD, frame_width=2)

if show_hud and barstate.islast
    table.cell(hud, 0, 0, "NW VOLUME PROFILE [D3R]", text_color=C_TXT,
               bgcolor=color.new(#1e293b, 0), text_size=11, text_halign=text.align_center)
    table.merge_cells(hud, 0, 0, 1, 0)

    table.cell(hud, 0, 1, "POC", text_color=C_DIM, bgcolor=color.new(#1e293b, 40), text_size=11)
    table.cell(hud, 1, 1, na(poc_price) ? "—" : str.tostring(poc_price, format.mintick),
               text_color=C_AMBER, bgcolor=color.new(#1e293b, 40),
               text_size=11, text_halign=text.align_center, text_formatting=text.format_bold)

    table.cell(hud, 0, 2, "Value Area", text_color=C_DIM, bgcolor=color.new(#0f172a, 40), text_size=11)
    table.cell(hud, 1, 2, na(vah_price) ? "—" : str.tostring(val_price, format.mintick) + " – " + str.tostring(vah_price, format.mintick),
               text_color=C_BULL, bgcolor=color.new(#0f172a, 40),
               text_size=11, text_halign=text.align_center)

    table.cell(hud, 0, 3, "Nodes", text_color=C_DIM, bgcolor=color.new(#1e293b, 40), text_size=11)
    table.cell(hud, 1, 3, "HVN " + str.tostring(hvn_count) + "   LVN " + str.tostring(lvn_count),
               text_color=C_TXT, bgcolor=color.new(#1e293b, 40),
               text_size=11, text_halign=text.align_center)

    table.cell(hud, 0, 4, "Window", text_color=C_DIM, bgcolor=color.new(#0f172a, 40), text_size=11)
    table.cell(hud, 1, 4, str.tostring(math.min(lookback, bar_index + 1)) + " bars × " + str.tostring(n_bins) + " bins",
               text_color=C_DIM, bgcolor=color.new(#0f172a, 40),
               text_size=11, text_halign=text.align_center)

    table.cell(hud, 0, 5, "Bandwidth", text_color=C_DIM, bgcolor=color.new(#1e293b, 40), text_size=11)
    table.cell(hud, 1, 5, str.tostring(bandwidth, "#.#") + " bins (Gaussian)",
               text_color=C_DIM, bgcolor=color.new(#1e293b, 40),
               text_size=11, text_halign=text.align_center)


// ALERTS 
bool cross_poc_up = not na(poc_price) and ta.crossover(close, poc_price)
bool cross_poc_dn = not na(poc_price) and ta.crossunder(close, poc_price)
bool exit_va_up   = not na(vah_price) and ta.crossover(close, vah_price)
bool exit_va_dn   = not na(val_price) and ta.crossunder(close, val_price)

alertcondition(cross_poc_up, "Cross Above POC", "D3R NW VP: price crossed above the POC")
alertcondition(cross_poc_dn, "Cross Below POC", "D3R NW VP: price crossed below the POC")
alertcondition(exit_va_up,   "Exit VA Upward",  "D3R NW VP: price closed above the Value Area High")
alertcondition(exit_va_dn,   "Exit VA Downward","D3R NW VP: price closed below the Value Area Low")
````
