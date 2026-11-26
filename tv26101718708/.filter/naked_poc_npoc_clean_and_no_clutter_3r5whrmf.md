# Naked POC (nPOC) (Clean and No Clutter)

- url: https://www.tradingview.com/script/3r5whRmf-Naked-POC-nPOC-Clean-and-No-Clutter/
- type: indicator
- pine_id: PUB;d2e214e15da94c61a5ea72543888c3e4
- version: 2.0

## Description

TradingView's built-in Session Volume Profile is powerful — but it plasters a full histogram over your chart for every session. When you're reading price action in real time, that's a lot of noise for one number that actually matters: the POC.

This indicator strips it down. No histogram. No boxes. Just the levels that are still unvisited — the ones that actually have magnetic pull on price.

[b]━━ WHAT IS A NAKED POC? ━━[/b]

The Point of Control (POC) is the price where the most volume traded during a session. A POC is [i]naked[/i] when price has not revisited it since the session closed. Naked POCs are unfilled magnets. Once price touches one, it is automatically removed from the chart.

[b]━━ VOLUME DISTRIBUTION ━━[/b]

Most volume profile tools distribute each bar's volume uniformly across its high-low range. This indicator uses a [b]close-weighted triangular distribution[/b] — bins near the bar's close receive more weight than bins at the extremes. The POC lands closer to where price repeatedly settled, not just where it briefly spiked.

[b]━━ SETTINGS ━━[/b]

[list]
[*][b]TPO Bins[/b] — resolution of the volume calculation (20–500). Higher = more precise POC location.
[*][b]Max Visible nPOCs[/b] — cap on how many naked levels are shown at once. Default: 15.
[*][b]Max Age (days)[/b] — automatically expires levels older than N days regardless of fill. Default: 7.
[*][b]Extend Forward (hours)[/b] — how far the dashed line extends to the right.
[*][b]Remove When Filled[/b] — toggle whether levels disappear on touch or stay permanently.
[*][b]Color[/b] — fully customizable.
[/list]

[b]Recommended timeframe:[/b] 1H – 4H

A warning label appears automatically if the indicator is applied to an incompatible timeframe.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © cliteka-cell

//@version=6
indicator("Naked POC (nPOC) — Daily", shorttitle="nPOC", overlay=true,
          max_lines_count=500, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════════════════
// WHAT IS AN nPOC?
//
// The Point of Control (POC) is the price level with the highest traded
// volume during a session — the "fairest" price the market agreed on that day.
//
// A Naked POC (nPOC) is a POC that price has not returned to since it
// was established. These levels act as strong magnets — price tends to
// revisit and react at them. Once price touches an nPOC, it is "filled"
// and removed from the chart.
//
// HOW IT WORKS:
//   At the close of each day, the script divides the day's price range
//   into bins (TPO buckets) and distributes volume proportionally across
//   the high-low range of each bar. The bin with the highest accumulated
//   volume becomes the POC. If price never returns to that level, it
//   remains on the chart as a dashed line until filled.
//
// RECOMMENDED TIMEFRAME: 5m to 4H (any intraday)
// ═══════════════════════════════════════════════════════════════════════════

// ── Inputs ───────────────────────────────────────────────────────────────────
var g = "Naked POC Settings"

show_npoc     = input.bool(true,  "Show Naked Daily POCs",                        group=g)
delete_filled = input.bool(true,  "Remove nPOC When Price Fills It",              group=g)
npoc_bins     = input.int (100,   "TPO Bins (resolution)",  minval=20, maxval=500, group=g)
max_npocs     = input.int (15,    "Max Visible nPOCs",      minval=1,  maxval=50,  group=g)
extend_fwd    = input.int (30,    "Extend Lines Forward (hours)", minval=1, maxval=300, group=g)
max_age_days  = input.int (7,     "Max Age (days)",               minval=1, maxval=30,  group=g)
c_npoc        = input.color(color.new(color.fuchsia, 0), "nPOC Line Color",       group=g)
show_label    = input.bool(true,  "Show 'nPOC' Labels",                           group=g)

// ── Constants ─────────────────────────────────────────────────────────────────
hour_ms = 1000 * 60 * 60

// ── Timeframe guard ───────────────────────────────────────────────────────────
is_valid = timeframe.isintraday

if barstate.islast and not is_valid
    label.new(bar_index, high,
              "⚠️  nPOC requires an intraday timeframe (seconds - hours).",
              xloc=xloc.bar_index, color=color.red, textcolor=color.white,
              style=label.style_label_left, size=size.normal)

// ── Day boundary ──────────────────────────────────────────────────────────────
is_new_day = ta.change(time("D")) != 0

var int day_start_bar      = na
var int prev_day_start_bar = na

if is_new_day
    prev_day_start_bar := day_start_bar
    day_start_bar      := bar_index

// ── Storage arrays ────────────────────────────────────────────────────────────
var array<float> npoc_vals  = array.new<float>(0)
var array<int>   npoc_times = array.new<int>(0)
var array<line>  npoc_lines = array.new<line>(0)
var array<label> npoc_lbls  = array.new<label>(0)

// ── POC calculation for the completed day ─────────────────────────────────────
if is_valid and is_new_day and not na(prev_day_start_bar) and show_npoc

    int bars_in_day = bar_index - prev_day_start_bar

    if bars_in_day > 0
        // Find day's high and low
        float d_high = high[1]
        float d_low  = low[1]
        for i = 1 to bars_in_day
            d_high := math.max(d_high, high[i])
            d_low  := math.min(d_low,  low[i])

        float prange = d_high - d_low

        if prange > 0
            float bsize = prange / npoc_bins

            // Distribute volume into bins proportionally across each bar's range
            array<float> vbins = array.new<float>(npoc_bins, 0.0)
            for i = 1 to bars_in_day
                int   bLo  = math.max(0, math.min(npoc_bins - 1, math.floor((low[i]  - d_low) / bsize)))
                int   bHi  = math.max(0, math.min(npoc_bins - 1, math.floor((high[i] - d_low) / bsize)))
                int   bCls = math.max(0, math.min(npoc_bins - 1, math.floor((close[i] - d_low) / bsize)))
                // Triangular distribution — weight each bin by proximity to close
                // Bins near the close receive more volume than bins at the extremes
                float wSum = 0.0
                for b = bLo to bHi
                    float bin_mid = d_low + b * bsize + bsize / 2
                    float dist    = math.abs(bin_mid - close[i])
                    float bar_rng = math.max(high[i] - low[i], bsize)
                    wSum += math.max(0.0, 1.0 - dist / bar_rng)
                for b = bLo to bHi
                    float bin_mid = d_low + b * bsize + bsize / 2
                    float dist    = math.abs(bin_mid - close[i])
                    float bar_rng = math.max(high[i] - low[i], bsize)
                    float weight  = wSum > 0.0 ? math.max(0.0, 1.0 - dist / bar_rng) / wSum : 1.0 / math.max(1, bHi - bLo + 1)
                    vbins.set(b, vbins.get(b) + volume[i] * weight)

            // Find the bin with the highest volume — that's the POC
            float mVol = 0.0
            int   pIdx = 0
            for i = 0 to npoc_bins - 1
                if vbins.get(i) > mVol
                    mVol := vbins.get(i)
                    pIdx := i

            float d_poc = d_low + pIdx * bsize + bsize / 2
            int   ext_t = time + extend_fwd * hour_ms

            // Drop oldest nPOC when cap is reached
            if npoc_vals.size() >= max_npocs
                line.delete(npoc_lines.shift())
                label.delete(npoc_lbls.shift())
                npoc_vals.shift()
                npoc_times.shift()

            // Draw the nPOC line and label
            npoc_vals.push(d_poc)
            npoc_times.push(time)
            npoc_lines.push(line.new(
                 x1=time - hour_ms, y1=d_poc,
                 x2=ext_t,          y2=d_poc,
                 xloc=xloc.bar_time,
                 color=c_npoc, style=line.style_dashed, width=1))
            npoc_lbls.push(label.new(
                 x=ext_t, y=d_poc, text=show_label ? "nPOC" : "",
                 xloc=xloc.bar_time,
                 color=color.new(color.black, 100),
                 textcolor=c_npoc,
                 style=label.style_label_left,
                 size=size.tiny))

// ── Extend lines and check for fills on every confirmed bar ───────────────────
if barstate.isconfirmed and npoc_vals.size() > 0
    int ext_t = time + extend_fwd * hour_ms
    for i = npoc_vals.size() - 1 to 0
        float val = npoc_vals.get(i)
        line  ln  = npoc_lines.get(i)
        label lb  = npoc_lbls.get(i)

        // Extend line to stay ahead of price
        line.set_x2(ln, ext_t)
        label.set_x(lb, ext_t)

        // Remove if older than max_age_days
        int age_ms = max_age_days * 24 * hour_ms
        if time - npoc_times.get(i) > age_ms
            line.delete(ln), label.delete(lb)
            npoc_vals.remove(i), npoc_lines.remove(i), npoc_lbls.remove(i), npoc_times.remove(i)

        // Price has revisited this POC — it's no longer "naked"
        else if low <= val and high >= val
            if delete_filled
                line.delete(ln)
                label.delete(lb)
            npoc_vals.remove(i)
            npoc_lines.remove(i)
            npoc_lbls.remove(i)
            npoc_times.remove(i)
````
