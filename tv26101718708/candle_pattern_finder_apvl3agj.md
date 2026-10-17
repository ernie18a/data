# Candle Pattern Finder

- url: https://www.tradingview.com/script/APVL3aGJ-Candle-Pattern-Finder/
- type: indicator
- pine_id: PUB;61a3122065d142de86545e5821fa18d5
- version: 1.0

## Description

This indicator searches historical price data to find candle sequences that most closely resemble a recent pattern. It compares the shape of a configurable number of recent candles against hundreds of historical windows using z-score normalization; focuses on the shape of the move rather than price level. The three closest matches are identified and highlighted directly on the chart. 

Once the matches are found, the indicator projects forward from each one, showing how price behaved in the bars that followed. The three individual paths are drawn in lighter lines, while a weighted consensus of all three is drawn prominently in orange. A percentage label at the end of the consensus line shows the projected move from the pattern's anchor price. Optionally, consensus can be disabled and only the closest matching pattern will be displayed.

A pattern offset control lets you shift the examined window back in time. With an offset of zero the indicator analyzes the most recent candles as normal. Increasing the offset slides the pattern window back by that many bars, with the projection lines shifting back to match — useful for visually checking what the indicator would have predicted at a specific point in the past and whether that prediction played out.

The indicator is fully configurable: pattern length, lookback depth, projection length, and all colors can be adjusted from the settings panel. Match regions are highlighted with shaded boxes so you can quickly locate in history where the matched patterns occurred.

This is just a tool that displays similarities, and should not be relied upon as an accurate prediction of future movement.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © obsirk

//@version=6
indicator("Candle Pattern Finder", overlay=true, max_bars_back=1000, max_lines_count=500, max_labels_count=20, max_boxes_count=10)

// ─── Inputs ───────────────────────────────────────────────────────────────────
n_candles      = input.int(5,   "Pattern length (candles)",  minval=2,  maxval=20,  group="Pattern")
lookback       = input.int(300, "Lookback period (bars)",    minval=20, maxval=800, group="Pattern")
pattern_offset = input.int(0,   "Pattern offset (bars)",     minval=0,  maxval=200, group="Pattern")
project_bars   = input.int(10,  "Projection bars",           minval=1,  maxval=50,  group="Projection")
show_match     = input.bool(true,  "Highlight match regions",  group="Display")
col_up         = input.color(color.new(color.lime,   20), "Up color",       group="Display")
col_dn         = input.color(color.new(color.red,    20), "Down color",     group="Display")
col_match      = input.color(color.new(color.blue,   80), "Match region",   group="Display")
show_consensus = input.bool(true,  "Show consensus path",      group="Consensus")
col_consensus  = input.color(color.new(color.orange,  0), "Consensus color", group="Consensus")

// ─── Main logic — runs once on the final bar ──────────────────────────────────
if barstate.islast

    // 1. Z-score stats for the current pattern window
    curr_sum = 0.0
    for i = 0 to n_candles - 1
        curr_sum += close[pattern_offset + i]
    curr_mean = curr_sum / n_candles

    curr_var = 0.0
    for i = 0 to n_candles - 1
        curr_var += math.pow(close[pattern_offset + i] - curr_mean, 2)
    curr_std = math.sqrt(curr_var / n_candles)

    // 2. Pass 1 — find the single best matching window (off1)
    best_dist = 1e10
    off1      = n_candles + 1

    for offset = n_candles + 1 to n_candles + lookback
        if offset > pattern_offset + n_candles
            hs = 0.0
            for i = 0 to n_candles - 1
                hs += close[offset + i]
            hm = hs / n_candles
            hv = 0.0
            for i = 0 to n_candles - 1
                hv += math.pow(close[offset + i] - hm, 2)
            hstd = math.sqrt(hv / n_candles)
            d = 0.0
            for i = 0 to n_candles - 1
                zc = curr_std > 0 ? (close[pattern_offset + i] - curr_mean) / curr_std : 0.0
                zh = hstd > 0 ? (close[offset + i] - hm) / hstd : 0.0
                d += math.pow(zc - zh, 2)
            if d < best_dist
                best_dist := d
                off1      := offset

    // 3. Passes 2 and 3 — next two best matches, each non-overlapping with all prior
    off2 = off1
    off3 = off1

    if show_consensus
        // Pass 2: skip any candidate whose window overlaps off1 or the pattern window
        d2 = 1e10
        for offset = n_candles + 1 to n_candles + lookback
            if offset > pattern_offset + n_candles and math.abs(offset - off1) >= n_candles
                hs = 0.0
                for i = 0 to n_candles - 1
                    hs += close[offset + i]
                hm = hs / n_candles
                hv = 0.0
                for i = 0 to n_candles - 1
                    hv += math.pow(close[offset + i] - hm, 2)
                hstd = math.sqrt(hv / n_candles)
                d = 0.0
                for i = 0 to n_candles - 1
                    zc = curr_std > 0 ? (close[pattern_offset + i] - curr_mean) / curr_std : 0.0
                    zh = hstd > 0 ? (close[offset + i] - hm) / hstd : 0.0
                    d += math.pow(zc - zh, 2)
                if d < d2
                    d2   := d
                    off2 := offset

        // Pass 3: skip candidates overlapping off1, off2, or the pattern window
        d3 = 1e10
        for offset = n_candles + 1 to n_candles + lookback
            if offset > pattern_offset + n_candles and math.abs(offset - off1) >= n_candles and math.abs(offset - off2) >= n_candles
                hs = 0.0
                for i = 0 to n_candles - 1
                    hs += close[offset + i]
                hm = hs / n_candles
                hv = 0.0
                for i = 0 to n_candles - 1
                    hv += math.pow(close[offset + i] - hm, 2)
                hstd = math.sqrt(hv / n_candles)
                d = 0.0
                for i = 0 to n_candles - 1
                    zc = curr_std > 0 ? (close[pattern_offset + i] - curr_mean) / curr_std : 0.0
                    zh = hstd > 0 ? (close[offset + i] - hm) / hstd : 0.0
                    d += math.pow(zc - zh, 2)
                if d < d3
                    d3   := d
                    off3 := offset

    // 4. Match region highlights
    if show_match
        hi1 = 0.0
        lo1 = 1e10
        for i = 0 to n_candles - 1
            hi1 := math.max(hi1, high[off1 + i])
            lo1 := math.min(lo1, low[off1 + i])
        box.new(bar_index - off1 - n_candles + 1, hi1, bar_index - off1, lo1, bgcolor=col_match, border_color=color.new(color.blue, 30), border_width=1)
        label.new(bar_index - off1 - (n_candles - 1) / 2, hi1, "Match 1  (score: " + str.tostring(math.round(best_dist, 3)) + ")", style=label.style_label_up, color=color.new(color.blue, 40), textcolor=color.white, size=size.small)

    if show_match and show_consensus
        hi2 = 0.0
        lo2 = 1e10
        for i = 0 to n_candles - 1
            hi2 := math.max(hi2, high[off2 + i])
            lo2 := math.min(lo2, low[off2 + i])
        box.new(bar_index - off2 - n_candles + 1, hi2, bar_index - off2, lo2, bgcolor=color.new(color.blue, 88), border_color=color.new(color.blue, 55), border_width=1)
        label.new(bar_index - off2 - (n_candles - 1) / 2, hi2, "Match 2", style=label.style_label_up, color=color.new(color.blue, 55), textcolor=color.white, size=size.small)

        hi3 = 0.0
        lo3 = 1e10
        for i = 0 to n_candles - 1
            hi3 := math.max(hi3, high[off3 + i])
            lo3 := math.min(lo3, low[off3 + i])
        box.new(bar_index - off3 - n_candles + 1, hi3, bar_index - off3, lo3, bgcolor=color.new(color.blue, 93), border_color=color.new(color.blue, 70), border_width=1)
        label.new(bar_index - off3 - (n_candles - 1) / 2, hi3, "Match 3", style=label.style_label_up, color=color.new(color.blue, 70), textcolor=color.white, size=size.small)

    // 5. Projections
    if show_consensus
        // Three individual paths (light) + averaged consensus (prominent)
        ref1 = close[off1]
        ref2 = close[off2]
        ref3 = close[off3]
        prev1 = close[pattern_offset]
        prev2 = close[pattern_offset]
        prev3 = close[pattern_offset]
        prev_cons = close[pattern_offset]

        for k = 1 to project_bars
            v1 = off1 - k >= 0
            v2 = off2 - k >= 0
            v3 = off3 - k >= 0
            p1 = v1 ? close[pattern_offset] * (close[off1 - k] / ref1) : prev1
            p2 = v2 ? close[pattern_offset] * (close[off2 - k] / ref2) : prev2
            p3 = v3 ? close[pattern_offset] * (close[off3 - k] / ref3) : prev3

            n_valid = (v1 ? 1 : 0) + (v2 ? 1 : 0) + (v3 ? 1 : 0)
            cons_k  = n_valid > 0 ? ((v1 ? p1 : 0.0) + (v2 ? p2 : 0.0) + (v3 ? p3 : 0.0)) / n_valid : prev_cons

            line.new(bar_index - pattern_offset + k - 1, prev1, bar_index - pattern_offset + k, p1, color=color.new(p1 >= prev1 ? col_up : col_dn, 65), width=1)
            line.new(bar_index - pattern_offset + k - 1, prev2, bar_index - pattern_offset + k, p2, color=color.new(p2 >= prev2 ? col_up : col_dn, 65), width=1)
            line.new(bar_index - pattern_offset + k - 1, prev3, bar_index - pattern_offset + k, p3, color=color.new(p3 >= prev3 ? col_up : col_dn, 65), width=1)
            line.new(bar_index - pattern_offset + k - 1, prev_cons, bar_index - pattern_offset + k, cons_k, color=col_consensus, width=3)

            prev1     := p1
            prev2     := p2
            prev3     := p3
            prev_cons := cons_k

        pct_cons = (prev_cons / close[pattern_offset] - 1) * 100
        lbl_cons = (pct_cons >= 0 ? "▲ +" : "▼ ") + str.tostring(math.round(pct_cons, 2)) + "% consensus"
        label.new(bar_index - pattern_offset + project_bars, prev_cons, lbl_cons, style=label.style_label_left, color=col_consensus, textcolor=color.black, size=size.normal)

    else
        // Single best-match projection (original behavior)
        ref1   = close[off1]
        prev_p = close[pattern_offset]
        fp     = close[pattern_offset]
        lk     = 0

        for k = 1 to project_bars
            if off1 - k >= 0
                pk  = close[pattern_offset] * (close[off1 - k] / ref1)
                col = pk >= prev_p ? col_up : col_dn
                line.new(bar_index - pattern_offset + k - 1, prev_p, bar_index - pattern_offset + k, pk, color=col, width=2)
                prev_p := pk
                fp     := pk
                lk     := k

        if lk > 0
            pct = (fp / close[pattern_offset] - 1) * 100
            lbl = (pct >= 0 ? "▲ +" : "▼ ") + str.tostring(math.round(pct, 2)) + "%"
            label.new(bar_index - pattern_offset + lk, fp, lbl, style=label.style_label_left, color=fp >= close[pattern_offset] ? col_up : col_dn, textcolor=color.white, size=size.normal)
````
