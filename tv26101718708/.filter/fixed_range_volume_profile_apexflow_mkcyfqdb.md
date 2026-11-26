# Fixed Range Volume Profile [ApexFlow]

- url: https://www.tradingview.com/script/MKcYFqdB-Fixed-Range-Volume-Profile-ApexFlow/
- type: indicator
- pine_id: PUB;dbfa97904e1545ccb8147f4033e57adf
- version: 1.0

## Description

━━━━━━━━━━━━━━━━━━━━
[b]📊 WHAT THIS INDICATOR DOES[/b]
━━━━━━━━━━━━━━━━━━━━

[b]Fixed Range Volume Profile (FRVP)[/b] distributes traded volume across discrete price levels over a user-defined lookback window. It identifies the [b][color=#F5C518]Point of Control (POC)[/color][/b], [b][color=#00E676]Value Area High (VAH)[/color][/b], and [b][color=#FF5252]Value Area Low (VAL)[/color][/b] — the three levels used by institutional order flow analysts to determine where the majority of market participation occurred within any given range.

━━━━━━━━━━━━━━━━━━━━
[b]⚙️ METHODOLOGY[/b]
━━━━━━━━━━━━━━━━━━━━

[b]📦 PRICE BINS[/b]
The high-to-low price range of the lookback window is divided into [i]N[/i] equal-height rows (default: [b]24[/b]). Each row represents a discrete price bucket.

[b]📐 VOLUME DISTRIBUTION — ACCURATE MODE[/b]
When [i]"Accurate Distribution"[/i] is enabled, each bar's volume is spread proportionally across all rows whose price range overlaps with that bar's high-to-low span. The weight assigned to each row equals:

[i]overlap / (bar_high − bar_low) × bar_volume[/i]

This mirrors how footprint charts distribute volume and produces a more precise profile than HLC3 bucket placement alone.

[b]⚡ VOLUME DISTRIBUTION — FAST MODE[/b]
When Accurate mode is off, each bar's volume is allocated to a single row using the bar's [i]typical price: (High + Low + Close) / 3[/i]. Faster on large lookbacks.

[b]🎯 [color=#F5C518]POINT OF CONTROL (POC)[/color][/b]
The row with the [b]highest accumulated volume[/b]. Represents the price level with the greatest degree of two-sided market activity. [b]POC acts as a magnetic reference for price[/b] — markets frequently return to test it during subsequent sessions.

[b]📦 VALUE AREA (VA)[/b]
Starting from the POC row, adjacent rows are added in order of highest volume — expanding upward or downward, whichever row holds more volume at each step — until the cumulative volume of selected rows reaches the user-defined percentage of total volume (default: [b]70%[/b]). This mirrors the [i]CME Group standard[/i] for Market Profile value area construction.

[i]VAH = top of the highest included row[/i]
[i]VAL = bottom of the lowest included row[/i]

[b]📏 RANGE HIGH / LOW[/b]
The absolute high and low of all bars in the lookback window. Displayed as dotted reference lines when enabled.

━━━━━━━━━━━━━━━━━━━━
[b]🖥️ VISUAL COMPONENTS[/b]
━━━━━━━━━━━━━━━━━━━━

[b]▶ Right Histogram[/b] — volume bars drawn to the right of current price, scaled to the highest-volume row. [b][color=#F5C518]POC row[/color][/b] highlighted in gold, [b][color=#00BCD4]value area rows[/color][/b] in teal, non-value area rows in grey.

[b]▶ Value Area Zone[/b] — a semi-transparent box spanning [color=#00E676]VAH[/color] to [color=#FF5252]VAL[/color] across the entire range. Provides immediate visual context for the [i]accepted range of market activity[/i].

[b]▶ POC Band[/b] — a narrow band centered on the [color=#F5C518]POC line[/color] showing the exact price-row boundaries of the control point.

[b]▶ Key Level Lines[/b] — [b][color=#F5C518]POC[/color][/b] (bold solid), [b][color=#00E676]VAH[/color][/b] (dashed), [b][color=#FF5252]VAL[/color][/b] (dashed), Range H/L (dotted). All extend right by a configurable number of bars.

[b]▶ Labels[/b] — live price values pinned to the right end of each line.

━━━━━━━━━━━━━━━━━━━━
[b]🔧 SETTINGS[/b]
━━━━━━━━━━━━━━━━━━━━

[b]PROFILE[/b]
• [b]Lookback Bars[/b] — number of bars the profile covers [i](20–500, default 100)[/i]
• [b]Rows[/b] — price bucket resolution [i](10–100, default 24)[/i]
• [b]Value Area %[/b] — percentage of volume defining the accepted value area [i](default 70)[/i]
• [b]Accurate Distribution[/b] — spread volume across bar range vs. HLC3 bucket placement

[b]DISPLAY[/b]
• [b]Right Histogram[/b] — toggle the volume bars
• [b]Value Area Zone[/b] — toggle the VA fill box
• [b]POC Band[/b] — toggle the POC price-row highlight band
• [b]Range H/L[/b] — toggle the range extreme lines
• [b]Histogram Width (bars)[/b] — horizontal size of the volume bars [i](5–150)[/i]
• [b]Extend Right (bars)[/b] — how far key level lines project beyond current price [i](10–300)[/i]

[b]COLORS[/b]
All elements are independently color-configurable including transparency.

━━━━━━━━━━━━━━━━━━━━
[b]📈 HOW TO USE[/b]
━━━━━━━━━━━━━━━━━━━━

[b]🧲 [color=#F5C518]POC as a Magnet[/color][/b] — price tends to revisit the [b]POC[/b] after extended moves away from it. A failed auction above [color=#00E676]VAH[/color] or below [color=#FF5252]VAL[/color] often results in a rotation back through the value area toward [color=#F5C518]POC[/color].

[b]⚖️ Value Area as Acceptance / Rejection[/b] — price trading [i]inside[/i] the value area signals balanced, two-sided activity (consolidation). Price trading [i]outside and rejecting[/i] signals one-sided pressure (trend continuation). Price [i]breaking outside and holding[/i] signals value migration.

[b]🔑 [color=#00E676]VAH[/color] / [color=#FF5252]VAL[/color] as Reaction Levels[/b] — institutional participants often defend [color=#00E676]VAH[/color] and [color=#FF5252]VAL[/color] as reference points for entries, scaling, or stops. Watch for reaction candles at these levels.

[b]🔭 Adjust Lookback to Context[/b]
• [i]Intraday scalping:[/i] 30–60 bars on 1–5 min
• [i]Swing setups:[/i] 50–200 bars on 1H–4H
• [i]Directional bias:[/i] 100–500 bars on Daily

━━━━━━━━━━━━━━━━━━━━
[b]📝 NOTES[/b]
━━━━━━━━━━━━━━━━━━━━

• Calculation runs on the [b]last bar only[/b] — zero performance impact on historical bars.
• Profile updates on [b]every tick[/b] of the current bar, keeping all levels live.
• Histogram draws into future bar space to [b]avoid obscuring price candles[/b].
• On instruments without reliable volume data [i](e.g. some forex pairs)[/i], Fast Mode produces acceptable results as the distribution difference is minimal.

## Source Code

````pine
//@version=6
// © ApexFlow
// This source code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
indicator("Fixed Range Volume Profile [ApexFlow]", overlay=true, max_boxes_count=500, max_lines_count=20, max_labels_count=20)

// ═══════════════════════════════════════════════════════════════════════════════
// SETTINGS
// ═══════════════════════════════════════════════════════════════════════════════
g1 = "Profile"
lookback = input.int  (100,  "Lookback Bars",          minval=20, maxval=500, group=g1)
n_rows   = input.int  (24,   "Rows",                   minval=10, maxval=100, group=g1)
va_pct   = input.float(70.0, "Value Area %",           minval=50, maxval=95,  step=5, group=g1)
accurate = input.bool (true, "Accurate distribution (spread volume across bar range)", group=g1)

g2 = "Display"
show_hist  = input.bool(true, "Right Histogram",   group=g2)
show_zone  = input.bool(true, "Value Area Zone",   group=g2)
show_pocbd = input.bool(true, "POC Band",          group=g2)
show_hl    = input.bool(true, "Range H/L",         group=g2)
hist_w     = input.int (40,   "Histogram Width (bars)", minval=5,  maxval=150, group=g2)
ext_r      = input.int (60,   "Extend Right (bars)",    minval=10, maxval=300, group=g2)

g3 = "Colors"
c_poc    = input.color(color.new(#F5C518, 0),  "POC line",       group=g3)
c_vah    = input.color(color.new(#00E676, 0),  "VAH line",       group=g3)
c_val    = input.color(color.new(#FF5252, 0),  "VAL line",       group=g3)
c_va     = input.color(color.new(#00BCD4, 55), "Histogram VA",   group=g3)
c_nva    = input.color(color.new(#607D8B, 80), "Histogram non-VA", group=g3)
c_poc_bg = input.color(color.new(#F5C518, 35), "Histogram POC row", group=g3)
c_zone   = input.color(color.new(#00BCD4, 88), "VA zone fill",   group=g3)
c_pocbd  = input.color(color.new(#F5C518, 80), "POC band fill",  group=g3)
c_hl     = input.color(color.new(#787B86, 60), "Range H/L",      group=g3)

// ═══════════════════════════════════════════════════════════════════════════════
// DRAWING STORAGE (persist across ticks, rebuilt on the last bar)
// ═══════════════════════════════════════════════════════════════════════════════
var array<box>   _bx = array.new<box>()
var array<line>  _ln = array.new<line>()
var array<label> _lb = array.new<label>()

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN — last bar only
// ═══════════════════════════════════════════════════════════════════════════════
if barstate.islast

    // ── 1. Clear previous drawings (for-in is safe on empty arrays) ────────────
    for b in _bx
        box.delete(b)
    array.clear(_bx)
    for l in _ln
        line.delete(l)
    array.clear(_ln)
    for lab in _lb
        label.delete(lab)
    array.clear(_lb)

    // ── 2. Effective lookback & price range ────────────────────────────────────
    int lb = math.min(lookback, bar_index + 1)
    float rhi = high
    float rlo = low
    for i = 1 to lb - 1
        rhi := math.max(rhi, nz(high[i], rhi))
        rlo := math.min(rlo, nz(low[i],  rlo))
    float bsz = math.max((rhi - rlo) / n_rows, syminfo.mintick)

    // ── 3. Volume bins ─────────────────────────────────────────────────────────
    // accurate: spread each bar's volume across the rows its high-low range touches
    // fast:     dump each bar's volume into its HLC3 bucket
    array<float> vb = array.new<float>(n_rows, 0.0)
    for i = 0 to lb - 1
        float v = nz(volume[i])
        if v > 0
            float bh  = nz(high[i])
            float bl  = nz(low[i])
            float rng = bh - bl
            if accurate and rng > 0
                for r = 0 to n_rows - 1
                    float row_lo = rlo + r * bsz
                    float row_hi = row_lo + bsz
                    float ov     = math.min(bh, row_hi) - math.max(bl, row_lo)
                    if ov > 0
                        array.set(vb, r, array.get(vb, r) + v * (ov / rng))
            else
                float tp  = (bh + bl + nz(close[i])) / 3.0
                int   idx = math.max(0, math.min(n_rows - 1, int(math.floor((tp - rlo) / bsz))))
                array.set(vb, idx, array.get(vb, idx) + v)

    // ── 4. POC ─────────────────────────────────────────────────────────────────
    float mvol  = array.max(vb)
    int   poc_i = array.indexof(vb, mvol)
    float poc_p = rlo + (poc_i + 0.5) * bsz

    // ── 5. Value Area (expand out from POC until va_pct% of volume captured) ────
    float tgt = array.sum(vb) * (va_pct / 100.0)
    float acc = mvol
    int   ui  = poc_i
    int   di  = poc_i
    while acc < tgt
        float uv = ui < n_rows - 1 ? array.get(vb, ui + 1) : 0.0
        float dv = di > 0          ? array.get(vb, di - 1) : 0.0
        if uv + dv == 0.0
            break
        if uv >= dv
            ui  += 1
            acc += uv
        else
            di  -= 1
            acc += dv
    float vah_p = rlo + (ui + 1) * bsz
    float val_p = rlo + di * bsz

    // ── 6. Coordinates ─────────────────────────────────────────────────────────
    int x1 = bar_index - lb + 1          // start of the measured range
    int x2 = bar_index + ext_r           // right extension (labels / line ends)
    int hs = bar_index + 2               // histogram start (right of price)
    // Range outline — very faint border, no fill
    array.push(_bx, box.new(x1, rhi, bar_index, rlo, bgcolor=color.new(color.white, 100), border_color=color.new(color.white, 85), border_width=1))
    // ── 7. Value Area ZONE + POC band (drawn over the price action) ────────────
    if show_zone
        array.push(_bx, box.new(x1, vah_p, x2, val_p, bgcolor=c_zone, border_color=color.new(c_vah, 70), border_width=1))
    if show_pocbd
        array.push(_bx, box.new(x1, poc_p + bsz * 0.5, x2, poc_p - bsz * 0.5, bgcolor=c_pocbd, border_color=color.new(color.white, 100)))

    // ── 8. Right histogram ─────────────────────────────────────────────────────
    if show_hist
        for i = 0 to n_rows - 1
            float blo_p = rlo + i * bsz
            float bhi_p = blo_p + bsz
            float bv    = array.get(vb, i)
            int   bw    = mvol > 0 ? math.max(2, int(math.round(bv / mvol * hist_w))) : 2
            color bgc   = i == poc_i         ? c_poc_bg :
                          i >= di and i <= ui ? c_va     : c_nva
            array.push(_bx, box.new(hs, bhi_p, hs + bw, blo_p, bgcolor=bgc, border_color=color.new(color.white, 92), border_width=1))

    // ── 9. Key level lines (POC = bold main line) ──────────────────────────────
    array.push(_ln, line.new(x1, poc_p, x2, poc_p, color=c_poc, width=3))
    array.push(_ln, line.new(x1, vah_p, x2, vah_p, color=c_vah, width=1, style=line.style_dashed))
    array.push(_ln, line.new(x1, val_p, x2, val_p, color=c_val, width=1, style=line.style_dashed))
    if show_hl
        array.push(_ln, line.new(x1, rhi, x2, rhi, color=c_hl, width=1, style=line.style_dotted))
        array.push(_ln, line.new(x1, rlo, x2, rlo, color=c_hl, width=1, style=line.style_dotted))

    // ── 10. Labels (pinned at the right) ───────────────────────────────────────
    array.push(_lb, label.new(x2, poc_p, "POC  " + str.tostring(poc_p, format.mintick), color=c_poc, textcolor=color.black, style=label.style_label_left, size=size.small))
    array.push(_lb, label.new(x2, vah_p, "VAH  " + str.tostring(vah_p, format.mintick), color=c_vah, textcolor=color.black, style=label.style_label_left, size=size.small))
    array.push(_lb, label.new(x2, val_p, "VAL  " + str.tostring(val_p, format.mintick), color=c_val, textcolor=color.black, style=label.style_label_left, size=size.small))
    if show_hl
        array.push(_lb, label.new(x2, rhi, "RNG H  " + str.tostring(rhi, format.mintick), color=c_hl, textcolor=color.white, style=label.style_label_left, size=size.tiny))
        array.push(_lb, label.new(x2, rlo, "RNG L  " + str.tostring(rlo, format.mintick), color=c_hl, textcolor=color.white, style=label.style_label_left, size=size.tiny))
````
