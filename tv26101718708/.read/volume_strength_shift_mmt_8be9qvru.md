# Volume Strength Shift [MMT]

- url: https://www.tradingview.com/script/8be9qvRu-Volume-Strength-Shift-MMT/
- type: indicator
- pine_id: PUB;00b35ca7daf24e8d9ea5ecf8d61ba191
- version: 1.0

## Description

[b]Volume Strength Shift [MMT][/b] helps you see when buying or selling pressure is starting to take control. It breaks each candle’s volume into a bull side and a bear side, then highlights when one side begins to dominate.

This indicator is built to make volume easier to read at a glance. Green areas show bullish strength, red areas show bearish strength, and the shift arrows point out when momentum is changing. The smoothed delta line, bull ratio line, and scaled CVD line give you extra confirmation without making the chart too complicated. TradingView’s own volume delta tools also focus on comparing buying and selling pressure to help traders judge sentiment and momentum.

[b]How to Use It[/b]

[list]
[*]Look for a bull shift when the indicator turns green and the bullish arrow appears.
[*]Look for a bear shift when the indicator turns red and the bearish arrow appears.
[*]Use the background tint to quickly see which side is in control.
[*]Use the CVD and bull ratio lines to confirm whether strength is building or fading.
[/list]

[b]Best For[/b]

Spotting momentum shifts early.
[list]
[*]Confirming entries on CBC or other momentum-based strategies.
[*]Filtering out weak or low-conviction moves.
[*]Understanding whether volume is supporting the current trend.
[/list]

[b]What It Shows[/b]

[list]
[*][b]Histogram bars[/b]: volume strength by direction.
[*][b]Smoothed delta[/b]: the main trend of volume pressure.
[*][b]Bull ratio line[/b]: how much of volume is leaning bullish.
[*][b]Scaled CVD line[/b]: the running balance of buying vs. selling pressure.
[*][b]Shift arrows[/b]: when dominance changes from one side to the other.
[/list]

[b]Simple Idea[/b]

If price is moving up but the indicator is still red or neutral, the move may be weak. If price flips up and the indicator turns green at the same time, that gives you stronger confirmation that buyers are stepping in.

## Source Code

````pine
//@version=5
indicator("Volume Strength Shift [MMT]", shorttitle="VSS [MMT]", overlay=false, max_bars_back=500)

// ══════════════════════════════════════════════════════════
//  G R O U P S   &   I N P U T S
// ══════════════════════════════════════════════════════════
grp_vol = "Volume Settings"
length       = input.int(13,    "Smoothing Length",    minval=1,  group=grp_vol)
ma_type      = input.string("EMA", "MA Type",          options=["EMA","SMA","WMA","RMA"], group=grp_vol)
show_cvd     = input.bool(true, "Show Scaled CVD Line", group=grp_vol)
show_ratio   = input.bool(true, "Show Bull Ratio Line", group=grp_vol)

grp_vis = "Visual Settings"
bull_col     = input.color(#8db47e,                    "Bull Color",          group=grp_vis)
bear_col     = input.color(#de727b,                    "Bear Color",          group=grp_vis)
neutral_col  = input.color(#787b86,                    "Neutral Color",       group=grp_vis)
bg_bull      = input.color(color.new(#8db47e, 92),     "Bull BG Color",       group=grp_vis)
bg_bear      = input.color(color.new(#de727b, 92),     "Bear BG Color",       group=grp_vis)
show_bg      = input.bool(true,  "Color Background by Dominance", group=grp_vis)

grp_sig = "Signal Settings"
show_signals  = input.bool(true,  "Show Shift Arrows",  group=grp_sig)
thresh_mult   = input.float(0.05, "Signal Threshold (×Avg Vol)", minval=0.0, step=0.01,
     tooltip="Minimum delta EMA as a fraction of avg volume before a shift fires. Reduces noise.", group=grp_sig)

// ══════════════════════════════════════════════════════════
//  H E L P E R
// ══════════════════════════════════════════════════════════
ma(src, len, t) =>
    switch t
        "EMA" => ta.ema(src, len)
        "SMA" => ta.sma(src, len)
        "WMA" => ta.wma(src, len)
        "RMA" => ta.rma(src, len)

// ══════════════════════════════════════════════════════════
//  V O L U M E   D E C O M P O S I T I O N
//  Uses close position within the high/low range.
//  close @ high  → 100% bull   |   close @ low → 100% bear
// ══════════════════════════════════════════════════════════
full_range = high - low
bull_pct   = full_range > 0 ? (close - low) / full_range : 0.5
bull_vol   = volume * bull_pct
bear_vol   = volume * (1.0 - bull_pct)

// ══════════════════════════════════════════════════════════
//  D E L T A   &   S M O O T H I N G
// ══════════════════════════════════════════════════════════
delta        = bull_vol - bear_vol               // + = bull dominated, - = bear dominated
delta_smooth = ma(delta, length, ma_type)
avg_vol      = ta.sma(volume, length)
threshold    = avg_vol * thresh_mult             // adaptive signal noise filter

// Bull ratio: how much of total volume belongs to buyers (centered at 0)
bull_ratio_raw    = volume > 0 ? (bull_vol / volume * 100) - 50 : 0.0
bull_ratio_smooth = ma(bull_ratio_raw, length, ma_type)

// ══════════════════════════════════════════════════════════
//  C U M U L A T I V E   V O L U M E   D E L T A  (scaled)
// ══════════════════════════════════════════════════════════
cvd          = ta.cum(delta)
cvd_lo       = ta.lowest(cvd, 200)
cvd_hi       = ta.highest(cvd, 200)
cvd_range    = math.max(cvd_hi - cvd_lo, 1.0)
delta_scale  = ta.highest(math.abs(delta), 50)
// Normalize CVD to [-delta_scale, +delta_scale] so it overlays the histogram
cvd_scaled   = ((cvd - cvd_lo) / cvd_range * 2 - 1) * delta_scale

// ══════════════════════════════════════════════════════════
//  D O M I N A N C E   &   S H I F T   D E T E C T I O N
// ══════════════════════════════════════════════════════════
bull_dom   = delta_smooth >  threshold
bear_dom   = delta_smooth < -threshold

// Acceleration: delta expanding in the same direction as dominance
bull_accel = delta > delta[1] and delta > 0
bear_accel = delta < delta[1] and delta < 0

// Shift: first bar entering dominance zone
shift_bull = bull_dom and not bull_dom[1]
shift_bear = bear_dom and not bear_dom[1]

// ══════════════════════════════════════════════════════════
//  H I S T O G R A M   C O L O R I N G
//  Full intensity on acceleration, dimmed on deceleration
// ══════════════════════════════════════════════════════════
hist_col = delta > 0
     ? (bull_accel ? bull_col                  : color.new(bull_col,  30))
     : (bear_accel ? bear_col                  : color.new(bear_col,  30))


// ══════════════════════════════════════════════════════════
//  P L O T S
// ══════════════════════════════════════════════════════════
// Background dominance tint
bgcolor(show_bg ? (bull_dom ? bg_bull : bear_dom ? bg_bear : na) : na,
     title="Dominance Background")

// Reference lines
hline(0,   "Zero",          color=color.new(color.white, 60), linestyle=hline.style_dashed, linewidth=1)

// Volume Delta Histogram
plot(delta, "Volume Delta", style=plot.style_columns, color=hist_col, linewidth=1)

// Smoothed Delta (main signal line)
plot(delta_smooth, "Delta MA",       color=color.new(color.white, 10),                                  linewidth=2)

// Bull Ratio centered at 0 (scaled to be readable next to histogram)
plot(show_ratio ? bull_ratio_smooth / 50 * delta_scale : na,
     "Bull Ratio (scaled)", color=color.new(#f9a825, 45), linewidth=1, style=plot.style_line)

// CVD Line (scaled to histogram space)
plot(show_cvd ? cvd_scaled : na,
     "CVD (scaled)", color=color.new(#ba68c8, 40), linewidth=1, style=plot.style_line)

// ── Shift Arrows ─────────────────────────────────────────
plotshape(show_signals and shift_bull, "Shift → Bull",
     style=shape.triangleup,   location=location.bottom,
     color=bull_col, size=size.small)

plotshape(show_signals and shift_bear, "Shift → Bear",
     style=shape.triangledown, location=location.top,
     color=bear_col, size=size.small)

// ══════════════════════════════════════════════════════════
//  I N F O   T A B L E   (top-right, last bar only)
// ══════════════════════════════════════════════════════════
var table tbl = table.new(position.top_right, 2, 6,
     bgcolor=color.new(#0d1117, 65),
     border_color=color.new(color.white, 75), border_width=1,
     frame_color=color.new(color.white, 60), frame_width=1)

if barstate.islast
    dom_txt   = bull_dom ? "🟢 BULL" : bear_dom ? "🔴 BEAR" : "⚪ NEUTRAL"
    dom_col   = bull_dom ? bull_col  : bear_dom ? bear_col  : neutral_col
    ratio_txt = str.tostring(math.round(bull_ratio_smooth + 50, 1)) + "% Bull"
    sft_txt   = shift_bull ? "↑ Bull" : shift_bear ? "↓ Bear" : "—"
    sft_col   = shift_bull ? bull_col : shift_bear ? bear_col : color.new(color.white, 50)
    accel_txt = bull_accel ? "▲ Buying" : bear_accel ? "▼ Selling" : "—"

    // Header row
    table.cell(tbl, 0, 0, "Metric",     text_color=color.new(color.white, 30), text_size=size.small,
         bgcolor=color.new(#1e2329, 30))
    table.cell(tbl, 1, 0, "Value",      text_color=color.new(color.white, 30), text_size=size.small,
         bgcolor=color.new(#1e2329, 30))
    // Rows
    table.cell(tbl, 0, 1, "Dominance",  text_color=color.new(color.white, 20), text_size=size.small)
    table.cell(tbl, 1, 1, dom_txt,      text_color=dom_col,                    text_size=size.small)
    table.cell(tbl, 0, 2, "Bull Ratio", text_color=color.new(color.white, 20), text_size=size.small)
    table.cell(tbl, 1, 2, ratio_txt,    text_color=#f9a825,                    text_size=size.small)
    table.cell(tbl, 0, 3, "Delta EMA",  text_color=color.new(color.white, 20), text_size=size.small)
    table.cell(tbl, 1, 3, str.tostring(math.round(delta_smooth, 0)),
         text_color=delta_smooth > 0 ? bull_col : bear_col,                    text_size=size.small)
    table.cell(tbl, 0, 4, "Momentum",   text_color=color.new(color.white, 20), text_size=size.small)
    table.cell(tbl, 1, 4, accel_txt,    text_color=color.new(color.white, 20), text_size=size.small)
    table.cell(tbl, 0, 5, "Last Shift", text_color=color.new(color.white, 20), text_size=size.small)
    table.cell(tbl, 1, 5, sft_txt,      text_color=sft_col,                    text_size=size.small)

// ══════════════════════════════════════════════════════════
//  A L E R T S
// ══════════════════════════════════════════════════════════
alertcondition(shift_bull,               "VSS: Shift → Bull",        "Volume strength shifting to BUYERS.")
alertcondition(shift_bear,               "VSS: Shift → Bear",        "Volume strength shifting to SELLERS.")
alertcondition(bull_accel and bull_dom,  "VSS: Bull Acceleration",   "Bull volume accelerating while dominant.")
alertcondition(bear_accel and bear_dom,  "VSS: Bear Acceleration",   "Bear volume accelerating while dominant.")
````
