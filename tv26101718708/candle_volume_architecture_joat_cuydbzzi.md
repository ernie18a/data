# Candle Volume Architecture [JOAT]

- url: https://www.tradingview.com/script/cUYdBzzi-Candle-Volume-Architecture-JOAT/
- type: indicator
- pine_id: PUB;236f09c50bda4818a8cd250f9d983a9c
- version: 1.0

## Description

[b]Candle Volume Architecture [JOAT][/b]

[b]Introduction[/b]

Candle Volume Architecture is an overlay indicator that constructs a price-based volume distribution profile for each detected swing, identifies the Point of Control (the price level with the highest bar density within that swing), calculates a configurable Value Area (default 70% of distribution), and renders these findings as a visual volume architecture directly on the price chart. Unlike traditional Volume Profile tools that require fixed time periods or session boundaries, this indicator auto-detects swings from price action and builds its distribution profile dynamically around each structural move.

Volume Profile is a professional tool used to identify price levels with the highest historical trading interest. The Point of Control is the level within any period where the most trading occurred — it functions as a gravitational center that price tends to revisit. The Value Area contains the majority of trading activity and often provides support and resistance as price moves away from and returns to it. This indicator applies these concepts to auto-detected price swings rather than calendar periods, aligning the profile with actual market structure rather than arbitrary time divisions.

[image]https://www.tradingview.com/x/FT535hdj/[/image]

[b]Core Concepts[/b]

[b]1. Swing Detection[/b]

Swings are detected by tracking when price makes a new extreme and then retreats. An upper swing is confirmed when the prior bar's high matched the N-bar highest high, but the current bar fails to match — indicating the swing high has been set. The same logic applies to lower swings. This produces swing high and low markers that update as new extremes form.

[b]2. Volume Distribution Profile[/b]

When a swing direction change is detected (bull to bear or bear to bull), the prior swing's price range is divided into a configurable number of bins (default 24). Each bin is populated by counting how many bars within the swing had their closing price fall within that bin's price range. The bin with the highest count becomes the Point of Control.

[pine]
bin_size = (real_top - real_bot) / i_bins
for j = 0 to bars_in_range
    idx = int((close[j] - real_bot) / bin_size)
    bins_count.set(idx, bins_count.get(idx) + 1)
[/pine]

[b]3. Point of Control (POC)[/b]

The POC is the bin with the highest bar count. It is rendered as a dual-width line (thin solid + thick shadow) that extends forward in time, providing a live reference for where the most concentrated activity occurred in the last swing.

[b]4. Value Area Calculation[/b]

Starting from the POC, the Value Area expands outward, adding the next highest-count bin on either side until the cumulative count reaches the configured percentage of total bars (default 70%). The Value Area is rendered as a transparent box covering the identified price range.

[b]5. Profile Bin Visualization[/b]

Each bin is rendered as a box whose right edge extends proportionally to its bar count (wider = more activity). Opacity scales with count, so the POC bin is fully opaque and low-count bins are more transparent. This produces a horizontal bar chart appearance directly on the price chart.

[b]Features[/b]

[list]
[*][b]Auto-Detected Swing Profiles:[/b] Profile builds and renders at each swing direction change
[*][b]Point of Control Line:[/b] Dual-width shadow line extending from each swing, updated to current bar
[*][b]Value Area Box:[/b] Transparent zone covering the configurable percentage of swing volume
[*][b]Opacity-Scaled Bin Bars:[/b] Visual profile bars with count-proportional width and transparency
[*][b]Swing Range Outline:[/b] Dashed box delineating each swing's high-to-low range
[*][b]Live Swing Direction Line:[/b] Current swing trend line drawn on the last bar
[*][b]POC Proximity Detection:[/b] Dashboard highlights when price is within 0.3 ATR of the active POC
[*][b]8-Row Dashboard:[/b] Swing trend, POC level, swing high/low, swing range, POC bias
[/list]

[b]Input Parameters[/b]

[list]
[*]Swing Length: N-bar highest/lowest lookback for swing detection (default: 80)
[*]Profile Bins: Number of price bins in the distribution (default: 24)
[*]POC Line Width: Width of the POC rendering line (default: 2)
[*]Value Area %: Percentage of distribution to include in the Value Area (default: 70%)
[*]Show Profiles: Filter to bull only, bear only, both, or none
[/list]

[image]https://www.tradingview.com/x/kOoPLusm/[/image]

[b]How to Use This Indicator[/b]

[b]POC as Reference[/b]
The active POC line represents the most contested price level of the last swing. Price frequently revisits this level. When price is above the POC, the POC functions as potential support. When price is below, potential resistance.

[b]Value Area as Context[/b]
Price outside the Value Area (above VAH or below VAL) represents a less-active price zone. Moves outside the Value Area that fail to hold can return toward the Value Area. Sustained acceptance outside the Value Area suggests a new distribution is forming.

[b]Profile Shape for Sentiment[/b]
A profile that is skewed toward the top of its range (POC near the high) suggests the swing was dominated by higher-price acceptance — bullish distribution. A POC near the swing low suggests bearish distribution.

[b]Limitations[/b]

[list]
[*]The distribution is built from closing prices within the swing range, not from actual volume at price. This is a close approximation but differs from true Volume Profile tools that use tick data
[*]The swing detection requires a minimum of swing-length bars before the first profile is generated
[*]On very fast timeframes (1 minute or lower), the swing lengths may be too short to produce meaningful distributions
[*]The maximum bars in range cap (500 bars) prevents the profile builder from analyzing excessively long swings that could cause performance issues
[/list]

[b]Originality Statement[/b]

Applying Volume Profile methodology to auto-detected price swings rather than fixed calendar periods produces profiles that are structurally relevant rather than time-arbitrary. The opacity-scaled bin rendering produces an intuitive visual representation where the most active levels are immediately obvious. The real-time POC proximity detection in the dashboard provides an active alert when price approaches the most significant level of the last swing.

[b]Disclaimer[/b]

This indicator is for educational and informational purposes only. The distribution profiles are approximations built from close price counts, not true order flow data. Point of Control and Value Area levels are historical references and do not guarantee future price reactions. Always apply proper risk management.

-Made with passion by officialjackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Candle Volume Architecture [JOAT]", shorttitle="CVA [JOAT]", overlay=true,
         max_boxes_count=500, max_lines_count=200, max_labels_count=100)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grp_p   = "Profile Settings"
i_len   = input.int(80,  "Swing Length",     minval=20, maxval=300, group=grp_p)
i_bins  = input.int(24,  "Profile Bins",     minval=8,  maxval=50,  group=grp_p)
i_poc_w = input.int(2,   "POC Line Width",   minval=1,  maxval=5,   group=grp_p)
i_va_pct= input.float(70.0, "Value Area %", minval=50, maxval=95, step=5, group=grp_p,
          tooltip="Percentage of volume to define the Value Area (industry standard: 70%)")
i_show  = input.string("Both", "Show Profiles",
          options=["Both","Bull Only","Bear Only","None"], group=grp_p)

grp_v   = "Visual Settings"
i_bull  = input.color(#00bfa5, "Bullish Color", group=grp_v)
i_bear  = input.color(#ef5350, "Bearish Color", group=grp_v)
i_dash  = input.bool(true, "Show Dashboard",   group=grp_v)
i_poc_l = input.bool(true, "Extend POC Line",  group=grp_v)
i_va    = input.bool(true, "Show Value Area",  group=grp_v)

// ─────────────────────────────────────────────────────────────────────────────
// SWING DETECTION
// ─────────────────────────────────────────────────────────────────────────────
highest_n = ta.highest(i_len)
lowest_n  = ta.lowest (i_len)

// Swing pivot — price was the extreme but now retreated
upper_trigger = high[1] == highest_n[1] and high < highest_n
lower_trigger = low[1]  == lowest_n[1]  and low  > lowest_n

var float swing_H     = na
var float swing_L     = na
var int   swing_H_bar = na
var int   swing_L_bar = na
var bool  trend       = false
var bool  trend_init  = false

var array<int>   H_bars = array.new<int>()
var array<int>   L_bars = array.new<int>()
var array<float> H_vals = array.new<float>()
var array<float> L_vals = array.new<float>()

if upper_trigger
    swing_H_bar := bar_index[1]
    swing_H     := highest_n[1]
    H_bars.push(swing_H_bar)
    H_vals.push(swing_H)

if lower_trigger
    swing_L_bar := bar_index[1]
    swing_L     := lowest_n[1]
    L_bars.push(swing_L_bar)
    L_vals.push(swing_L)

if high == highest_n
    trend      := true
    trend_init := true
if low  == lowest_n
    trend      := false
    trend_init := true

// ─────────────────────────────────────────────────────────────────────────────
// PROFILE BUILDER
// Called only on trend change to build the prior swing's volume distribution
// ─────────────────────────────────────────────────────────────────────────────
var line poc_line  = na
var line poc_ghost = na
var box  va_box    = na

if trend_init and trend != trend[1] and H_bars.size() > 0 and L_bars.size() > 0
    is_bull_profile = not trend   // We just switched to bear, so prior swing was bullish
    col = is_bull_profile ? i_bull : i_bear

    show_profile = i_show == "Both"
                 or (i_show == "Bull Only" and is_bull_profile)
                 or (i_show == "Bear Only" and not is_bull_profile)

    if show_profile
        h_bar = is_bull_profile ? H_bars.last() : H_bars.last()
        l_bar = is_bull_profile ? L_bars.last() : L_bars.last()
        hh    = is_bull_profile ? swing_H : swing_H
        ll    = is_bull_profile ? swing_L : swing_L

        // Reorder to ensure hh > ll
        real_top = math.max(hh, ll)
        real_bot = math.min(hh, ll)
        start_b  = math.min(h_bar, l_bar)
        end_b    = math.max(h_bar, l_bar)

        if real_top > real_bot and end_b > start_b
            bin_size = (real_top - real_bot) / i_bins
            var bins_count = array.new_int(0)
            bins_count.clear()
            for i = 0 to i_bins - 1
                bins_count.push(0)

            // Count closes per bin across the swing range
            bars_in_range = end_b - start_b
            if bars_in_range > 0 and bars_in_range <= 500
                for j = 0 to bars_in_range
                    c = close[j]
                    if not na(c) and c >= real_bot and c <= real_top
                        idx = int((c - real_bot) / bin_size)
                        idx := math.max(0, math.min(idx, i_bins - 1))
                        bins_count.set(idx, bins_count.get(idx) + 1)

                max_count = bins_count.max()
                poc_idx   = bins_count.indexof(max_count)
                poc_price = real_bot + bin_size * poc_idx + bin_size * 0.5

                // Value Area calculation (expand from POC until i_va_pct% of volume captured)
                total_count = 0
                for c_val in bins_count
                    total_count += c_val
                va_target = int(total_count * i_va_pct / 100)
                va_cum    = max_count
                va_hi_idx = poc_idx
                va_lo_idx = poc_idx

                // Expand VA upward and downward from POC
                while va_cum < va_target and (va_hi_idx < i_bins - 1 or va_lo_idx > 0)
                    up_val   = va_hi_idx < i_bins - 1 ? bins_count.get(va_hi_idx + 1) : 0
                    down_val = va_lo_idx > 0           ? bins_count.get(va_lo_idx - 1) : 0
                    if up_val >= down_val and va_hi_idx < i_bins - 1
                        va_hi_idx += 1
                        va_cum    += up_val
                    else if va_lo_idx > 0
                        va_lo_idx -= 1
                        va_cum    += down_val
                    else
                        break

                va_high = real_bot + bin_size * (va_hi_idx + 1)
                va_low  = real_bot + bin_size * va_lo_idx

                // Draw profile bins
                for i = 0 to i_bins - 1
                    bin_low_p  = real_bot + bin_size * i
                    bin_high_p = bin_low_p + bin_size
                    bin_val    = bins_count.get(i)
                    // Width proportional to frequency; right extends into future
                    width      = bin_val
                    opac_fill  = 100 - int(float(bin_val) / float(max_count) * 100)
                    opac_fill  := math.max(5, math.min(opac_fill, 85))
                    b_col      = i == poc_idx ? col : color.new(col, opac_fill)
                    border_col = color.new(col, math.max(0, opac_fill - 20))

                    box.new(start_b, bin_high_p, start_b + width, bin_low_p,
                            bgcolor=b_col, border_color=border_col, border_width=1)

                // Value Area box
                if i_va
                    va_box := box.new(start_b, va_high, end_b, va_low,
                                      bgcolor=color.new(col, 88),
                                      border_color=color.new(col, 50),
                                      border_style=line.style_dashed)

                // POC line
                if i_poc_l
                    line.delete(poc_line)
                    line.delete(poc_ghost)
                    poc_line  := line.new(start_b, poc_price, bar_index, poc_price,
                                          color=col, width=i_poc_w)
                    poc_ghost := line.new(start_b, poc_price, bar_index, poc_price,
                                          color=color.new(col, 60), width=i_poc_w + 4)

                // Swing range outline
                box.new(start_b, real_top, end_b, real_bot,
                        bgcolor=color.new(col, 97), border_color=color.new(col, 70),
                        border_width=1, border_style=line.style_dashed)

                // Pivot labels
                label.new(is_bull_profile ? l_bar : h_bar,
                          is_bull_profile ? real_bot : real_top,
                          text=is_bull_profile ? "L" : "H",
                          style=is_bull_profile ? label.style_label_up : label.style_label_down,
                          color=color.new(col, 0), textcolor=color.white, size=size.tiny)

// ─────────────────────────────────────────────────────────────────────────────
// EXTEND POC LINE
// ─────────────────────────────────────────────────────────────────────────────
if i_poc_l and not na(poc_line)
    poc_line.set_x2(bar_index)
    poc_ghost.set_x2(bar_index)

// ─────────────────────────────────────────────────────────────────────────────
// LIVE SWING DIRECTION LINE
// ─────────────────────────────────────────────────────────────────────────────
var line live_swing = na

if barstate.islast and trend_init and H_bars.size() > 0 and L_bars.size() > 0
    line.delete(live_swing)
    if trend
        live_swing := line.new(L_bars.last(), L_vals.last(), H_bars.last(), H_vals.last(),
                               color=i_bull, style=line.style_solid, width=1)
    else
        live_swing := line.new(H_bars.last(), H_vals.last(), L_bars.last(), L_vals.last(),
                               color=i_bear, style=line.style_solid, width=1)

// ─────────────────────────────────────────────────────────────────────────────
// POC PROXIMITY SCORING
// ─────────────────────────────────────────────────────────────────────────────
poc_price_live = not na(poc_line) ? poc_line.get_y1() : na
atr_ref        = ta.atr(14)
near_poc       = not na(poc_price_live) and math.abs(close - poc_price_live) < atr_ref * 0.3
poc_above      = not na(poc_price_live) and close > poc_price_live
poc_below      = not na(poc_price_live) and close < poc_price_live

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD
// ─────────────────────────────────────────────────────────────────────────────
var table _t = na
if i_dash and barstate.islast
    if na(_t)
        _t := table.new(position.top_right, 3, 8,
                        border_width=1, border_color=color.new(color.gray, 75),
                        frame_width=2,  frame_color=color.new(color.gray, 55))

    C0 = color.new(#0a1628, 0)
    C1 = color.new(#0f2341, 0)
    C2 = color.new(#152d52, 0)

    table.cell(_t, 0, 0, "CANDLE VOLUME ARCHITECTURE", bgcolor=C0,
               text_color=color.white, text_size=size.small)
    table.merge_cells(_t, 0, 0, 2, 0)

    table.cell(_t, 0, 1, "Swing Trend", bgcolor=C1, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 1, not trend_init ? "—" : trend ? "Bullish" : "Bearish",
               bgcolor=C1, text_color=not trend_init ? color.gray : trend ? i_bull : i_bear,
               text_size=size.small)
    table.merge_cells(_t, 1, 1, 2, 1)

    table.cell(_t, 0, 2, "POC Level", bgcolor=C2, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 2, not na(poc_price_live) ? str.tostring(poc_price_live, format.mintick) : "—",
               bgcolor=C2, text_color=color.white, text_size=size.small)
    table.cell(_t, 2, 2, near_poc ? "AT POC" : poc_above ? "Above" : "Below",
               bgcolor=near_poc ? color.new(#ffd54f, 40) : C2,
               text_color=near_poc ? #ffd54f : poc_above ? i_bull : i_bear, text_size=size.small)

    table.cell(_t, 0, 3, "Swing High", bgcolor=C1, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 3, not na(swing_H) ? str.tostring(swing_H, format.mintick) : "—",
               bgcolor=C1, text_color=i_bear, text_size=size.small)
    table.merge_cells(_t, 1, 3, 2, 3)

    table.cell(_t, 0, 4, "Swing Low", bgcolor=C2, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 4, not na(swing_L) ? str.tostring(swing_L, format.mintick) : "—",
               bgcolor=C2, text_color=i_bull, text_size=size.small)
    table.merge_cells(_t, 1, 4, 2, 4)

    swing_rng = not na(swing_H) and not na(swing_L) ? swing_H - swing_L : na
    table.cell(_t, 0, 5, "Swing Range", bgcolor=C1, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 5, not na(swing_rng) ? str.tostring(swing_rng, format.mintick) : "—",
               bgcolor=C1, text_color=color.white, text_size=size.small)
    table.merge_cells(_t, 1, 5, 2, 5)

    table.cell(_t, 0, 6, "POC Bias", bgcolor=C2, text_color=color.gray, text_size=size.small)
    bias_str = near_poc ? "Neutral / Balanced" : poc_above ? "Price Above POC" : "Price Below POC"
    bias_col = near_poc ? #ffd54f : poc_above ? i_bull : i_bear
    table.cell(_t, 1, 6, bias_str, bgcolor=C2, text_color=bias_col, text_size=size.small)
    table.merge_cells(_t, 1, 6, 2, 6)

    table.cell(_t, 0, 7, "jackofalltrades", bgcolor=C0,
               text_color=color.new(color.white, 60), text_size=size.tiny)
    table.merge_cells(_t, 0, 7, 2, 7)

// ─────────────────────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(near_poc and not near_poc[1],
               "CVA — Price At POC", "Price approaching Point of Control — {{ticker}}")
alertcondition(poc_above and not poc_above[1],
               "CVA — Price Above POC", "Price moved above POC — {{ticker}}")
alertcondition(poc_below and not poc_below[1],
               "CVA — Price Below POC", "Price moved below POC — {{ticker}}")
alertcondition(trend_init and trend != trend[1],
               "CVA — Swing Reversal", "Volume swing direction reversed — {{ticker}}")
````
