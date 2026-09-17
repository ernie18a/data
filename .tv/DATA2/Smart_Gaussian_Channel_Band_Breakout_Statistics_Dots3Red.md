<!-- tradingview-pine-id: PUB;b2e12625cace42aab85588525e4002c0 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Smart Gaussian Channel - Band & Breakout Statistics [Dots3Red]

Source: https://www.tradingview.com/script/iINHzWlt-Smart-Gaussian-Channel-Band-Breakout-Statistics-Dots3Red/

## Description

🔔 GAUSSIAN CHANNEL AI — BAND & BREAKOUT STATISTICS [Dots3Red]
The Gaussian Channel is one of the most-followed tools, and this indicator goes a step further and keeps score: how often does each band actually hold, how often does a breakout genuinely continue, and how often has the filter's own direction call been right?

✨ WHY THIS MATTERS
A smooth channel is only useful if you know how much to trust it. Most Gaussian Channel scripts leave that entirely to feel, but nothing tells you whether the upper band has actually been holding lately or getting run through. This script tracks three separate things continuously and reports them plainly:

📊 Band respect — "Upper Band: 58% rejected (n=33)"
📊 Breakout follow-through — "Breakouts ▲: 61% continued (n=18)"
📊 Flip win rate — did the filter's last direction change actually hold up?

Nothing here is a prediction. It is a running record of what has already happened on this specific chart, so you can judge the channel's current reliability instead of assuming it.

⚙️ HOW IT WORKS
🔔 The Gaussian filter — a proper Ehlers-style low-lag filter, cascaded through up to 4 poles for extra smoothness. The same cascade applied to true range sets the band width, scaled by a multiplier. This is standard signal-processing math — the same construction behind the well-known versions of this tool. It is a fixed formula, not a model that adapts on its own.

📏 Band respect grading — every time price wicks into a band without closing beyond it, that's logged as a touch. The script then watches what happens next: if price moves back away from the band by a meaningful distance, it's graded a rejection; if price later closes through, it's graded a break. The running percentage accumulates per band, separately for upper and lower.

🚀 Breakout follow-through grading — a genuine close beyond a band (not just a wick) starts a separate track: does price keep moving in that direction by a further meaningful distance, or does it fall back inside the channel? Measured independently for upward and downward breakouts, since a channel can behave very differently on each side.

🔄 Flip grading — every time the filter's direction turns, the turn is checked a set number of bars later: did price actually end up where the new direction implied? The running win rate is a direct, honest answer to "when this line flips, how often has it been right so far."

🔒 Non-repainting — all grading happens strictly on confirmed bars. Nothing here retroactively changes what already printed.

🧭 HOW TO USE
1️⃣ Read the band stats before assuming a level will hold. If the upper band shows "72% rejected (n=40)," that's a meaningfully different situation than "48% rejected (n=12)" — same-looking channel, very different track record.

2️⃣ Use breakout stats to judge whether a close beyond the channel deserves attention. A high continuation rate on breakouts in one direction, paired with a low one in the other, tells you this instrument doesn't behave symmetrically — worth knowing before treating both sides the same way.

3️⃣ Check the flip win rate as context, not a green light. A filter flip that's been correct 40% of the time recently deserves more skepticism than one running at 65%. The count (n=) tells you how much to trust that percentage itself.

4️⃣ Let the sample sizes build up. Early on a fresh chart, expect small n values and treat the percentages as provisional until they've accumulated real history.

5️⃣ Adjust the poles and sampling period to the timeframe. Fewer poles and a shorter period track price more closely with less lag; more poles and a longer period produce a smoother, slower-reacting channel. Neither is universally correct — it depends on how much noise you want filtered out.

🛠️ SETTINGS
🔔 Gaussian Filter
• Source, Sampling Period, Poles, Band Multiplier — the core filter construction

🎯 Statistics Engine
• Touch Tolerance, Rejection Distance — define what counts as a touch and a genuine rejection
• Breakout Continuation, Outcome Window — define what counts as real follow-through
• Flip Grading Window — how far ahead a direction flip is checked

🎨 Visualization
• Channel Fill toggle and transparency
• Touch / Breakout Markers toggle, with independent line widths and marker sizing

🎨 Colors
• Rising / Falling / Flat channel colors
• Independent touch-marker and breakout-marker colors for each side
• Full dashboard color control — background, borders, header, and the good/bad outcome indicators

🖥️ Dashboard
• Show/hide, position — current channel direction plus all three statistic layers in one place

📝 NOTES
The statistics are cumulative from when the indicator was added to the chart — they are not a backtest over the full available history unless you scroll back far enough for the script to process it. A small sample size on any row means that particular statistic is still developing; treat it accordingly.

⚠️ DISCLAIMER
This is an analytical and visualization tool. It does not generate trade signals and does not constitute financial advice. Historical band, breakout, and flip statistics do not guarantee future performance.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Dots3Red
// TradingView: https://www.tradingview.com/u/Dots3Red/

//@version=6
indicator("Smart Gaussian Channel - Band & Breakout Statistics [Dots3Red]",
          shorttitle = "Smart Gaussian [D3R]",
          overlay    = true,
          max_labels_count = 500)

C_BAR = #b2b5be

// INPUTS
GRP_GC  = "🔔 Gaussian Filter"
GRP_ST  = "🎯 Statistics Engine"
GRP_VIS = "🎨 Visualization"
GRP_COL = "🎨 Colors"
GRP_HUD = "🖥️ Dashboard"

src_in   = input.source(hlc3, "Source", group=GRP_GC)
gc_len   = input.int(144, "Sampling Period", minval=10, maxval=500, group=GRP_GC,
           tooltip="The Gaussian filter's cycle period. 144 is the widely used default for this channel type.")
gc_poles = input.int(4, "Poles", minval=1, maxval=4, group=GRP_GC,
           tooltip="Number of filter poles. More poles = smoother filter with slightly more lag.")
gc_mult  = input.float(1.414, "Band Multiplier", minval=0.5, maxval=5.0, step=0.1, group=GRP_GC,
           tooltip="Band distance = multiplier × Gaussian-filtered true range.")

touch_tol    = input.float(0.15, "Touch Tolerance (×ATR)", minval=0.05, maxval=1.0, step=0.05, group=GRP_ST)
reject_atr   = input.float(1.0, "Rejection Distance (×ATR)", minval=0.3, maxval=5.0, step=0.1, group=GRP_ST,
               tooltip="After a band touch, price must move back inside at least this far to grade as a rejection.")
brk_confirm  = input.float(1.0, "Breakout Continuation (×ATR)", minval=0.3, maxval=5.0, step=0.1, group=GRP_ST,
               tooltip="After a close outside the channel, price must continue this much further to grade as follow-through.")
outcome_bars = input.int(10, "Outcome Window (bars)", minval=3, maxval=50, group=GRP_ST)
flip_grade_bars = input.int(15, "Flip Grading Window (bars)", minval=5, maxval=100, group=GRP_ST,
               tooltip="Bars after a filter direction flip over which the flip is graded correct or not.")

show_fill  = input.bool(true, "Channel Fill", group=GRP_VIS)
show_marks = input.bool(true, "Touch / Breakout Markers", group=GRP_VIS)
filt_width_in  = input.int(2, "Filter Line Width", minval=1, maxval=4, group=GRP_VIS)
band_width_in  = input.int(1, "Band Line Width", minval=1, maxval=4, group=GRP_VIS)
fill_trans_in  = input.int(90, "Fill Transparency", minval=50, maxval=99, group=GRP_VIS,
               tooltip="Higher = more transparent / subtler fill.")
marker_size_in = input.string("Tiny", "Marker Label Size", options=["Tiny","Small","Normal"], group=GRP_VIS)

col_rising  = input.color(#00f0ff, "Rising Channel", group=GRP_COL)
col_falling = input.color(#ff00aa, "Falling Channel", group=GRP_COL)
col_flat    = input.color(#64748b, "Flat Channel", group=GRP_COL)
col_touch_up   = input.color(#ff00aa, "Upper Touch Marker", inline="tm", group=GRP_COL)
col_touch_dn   = input.color(#00f0ff, "Lower Touch Marker", inline="tm", group=GRP_COL)
col_break_up   = input.color(#00c896, "Upper Breakout Marker", inline="bm", group=GRP_COL)
col_break_dn   = input.color(#ff4466, "Lower Breakout Marker", inline="bm", group=GRP_COL)

col_good = input.color(#00c896, "Dashboard: Good Outcome", inline="dg", group=GRP_COL)
col_bad  = input.color(#ff4466, "Dashboard: Bad Outcome", inline="dg", group=GRP_COL)
col_dash_bg          = input.color(color.new(#131722, 5), "Dashboard Background", group=GRP_COL)
col_dash_border      = input.color(color.new(#334155, 0), "Dashboard Border", group=GRP_COL)
col_dash_header_bg   = input.color(color.new(#1e293b, 0), "Dashboard Header Background", inline="dh", group=GRP_COL)
col_dash_header_text = input.color(#f8fafc, "Dashboard Header Text", inline="dh", group=GRP_COL)
col_dash_label_text  = input.color(color.new(#94a3b8, 0), "Dashboard Row Label Text", group=GRP_COL)
col_dash_row_bg      = input.color(color.new(#1e293b, 40), "Dashboard Row Background", group=GRP_COL)

show_hud = input.bool(true, "Show Dashboard", group=GRP_HUD)
hud_pos  = input.string("Top Right", "Position",
           options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=GRP_HUD)
color_bars_to_gray = input.bool(false, "Color bars to gray")




f_hud_pos(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        => position.bottom_left

f_marker_size(string s) =>
    switch s
        "Small"  => size.small
        "Normal" => size.normal
        => size.tiny

resolved_hud_pos    = f_hud_pos(hud_pos)
resolved_mark_size  = f_marker_size(marker_size_in)


// EHLERS GAUSSIAN FILTER 
f_gauss_alpha(int period, int poles) =>
    float b = (1.0 - math.cos(2.0 * math.pi / float(period))) / (math.pow(1.414, 2.0 / float(poles)) - 1.0)
    -b + math.sqrt(b * b + 2.0 * b)

float alpha = f_gauss_alpha(gc_len, gc_poles)
float one_m = 1.0 - alpha

var float s1 = na
var float s2 = na
var float s3 = na
var float s4 = na
s1 := alpha * src_in + one_m * nz(s1[1], src_in)
s2 := alpha * s1     + one_m * nz(s2[1], s1)
s3 := alpha * s2     + one_m * nz(s3[1], s2)
s4 := alpha * s3     + one_m * nz(s4[1], s3)
float filt = gc_poles == 1 ? s1 : gc_poles == 2 ? s2 : gc_poles == 3 ? s3 : s4

float tr_src = ta.tr(true)
var float t1 = na
var float t2 = na
var float t3 = na
var float t4 = na
t1 := alpha * tr_src + one_m * nz(t1[1], tr_src)
t2 := alpha * t1     + one_m * nz(t2[1], t1)
t3 := alpha * t2     + one_m * nz(t3[1], t2)
t4 := alpha * t3     + one_m * nz(t4[1], t3)
float filt_tr = gc_poles == 1 ? t1 : gc_poles == 2 ? t2 : gc_poles == 3 ? t3 : t4

float band_up = filt + filt_tr * gc_mult
float band_dn = filt - filt_tr * gc_mult

bool filt_rising  = filt > filt[1]
bool filt_falling = filt < filt[1]

atr_raw = ta.atr(14)


// STATISTICS ENGINE 

var int   up_pend_bar   = na
var float up_pend_lvl   = na
var int   dn_pend_bar   = na
var float dn_pend_lvl   = na

var int up_touches = 0
var int up_rejects = 0
var int dn_touches = 0
var int dn_rejects = 0

var int   bo_up_bar   = na
var float bo_up_ref   = na
var int   bo_dn_bar   = na
var float bo_dn_ref   = na

var int bo_up_total = 0
var int bo_up_cont  = 0
var int bo_dn_total = 0
var int bo_dn_cont  = 0

// Flip grading
var int   flip_bar   = na
var float flip_price = na
var int   flip_dir   = 0
var int flips_total   = 0
var int flips_correct = 0

if barstate.isconfirmed
   
    if not na(up_pend_bar)
        bool rejected = (up_pend_lvl - close) >= reject_atr * atr_raw
        bool broke    = close > up_pend_lvl + touch_tol * atr_raw and close > band_up
        bool timed    = (bar_index - up_pend_bar) >= outcome_bars
        if rejected
            up_touches += 1
            up_rejects += 1
            up_pend_bar := na
        else if broke or timed
            up_touches += 1
            up_pend_bar := na

    if not na(dn_pend_bar)
        bool rejected_d = (close - dn_pend_lvl) >= reject_atr * atr_raw
        bool broke_d    = close < dn_pend_lvl - touch_tol * atr_raw and close < band_dn
        bool timed_d    = (bar_index - dn_pend_bar) >= outcome_bars
        if rejected_d
            dn_touches += 1
            dn_rejects += 1
            dn_pend_bar := na
        else if broke_d or timed_d
            dn_touches += 1
            dn_pend_bar := na

    if na(up_pend_bar) and high >= band_up - touch_tol * atr_raw and close < band_up
        up_pend_bar := bar_index
        up_pend_lvl := band_up
        if show_marks
            label.new(bar_index, high + atr_raw * 0.3, "◦",
                      style=label.style_label_down,
                      color=color.new(#000000, 100), textcolor=col_touch_up, size=resolved_mark_size)

    if na(dn_pend_bar) and low <= band_dn + touch_tol * atr_raw and close > band_dn
        dn_pend_bar := bar_index
        dn_pend_lvl := band_dn
        if show_marks
            label.new(bar_index, low - atr_raw * 0.3, "◦",
                      style=label.style_label_up,
                      color=color.new(#000000, 100), textcolor=col_touch_dn, size=resolved_mark_size)

    if not na(bo_up_bar)
        bool cont  = (close - bo_up_ref) >= brk_confirm * atr_raw
        bool fail  = close < band_up
        bool timed = (bar_index - bo_up_bar) >= outcome_bars
        if cont
            bo_up_total += 1
            bo_up_cont  += 1
            bo_up_bar := na
        else if fail or timed
            bo_up_total += 1
            bo_up_bar := na

    if not na(bo_dn_bar)
        bool cont_d  = (bo_dn_ref - close) >= brk_confirm * atr_raw
        bool fail_d  = close > band_dn
        bool timed_d2 = (bar_index - bo_dn_bar) >= outcome_bars
        if cont_d
            bo_dn_total += 1
            bo_dn_cont  += 1
            bo_dn_bar := na
        else if fail_d or timed_d2
            bo_dn_total += 1
            bo_dn_bar := na

    bool closed_above = close > band_up and close[1] <= band_up[1]
    bool closed_below = close < band_dn and close[1] >= band_dn[1]

    if closed_above and na(bo_up_bar)
        bo_up_bar := bar_index
        bo_up_ref := close
        // A confirmed close above also resolves any pending upper touch as a break
        if not na(up_pend_bar)
            up_touches += 1
            up_pend_bar := na
        if show_marks
            label.new(bar_index, high + atr_raw * 0.8, "▲BO",
                      style=label.style_label_down,
                      color=color.new(#000000, 100), textcolor=col_break_up, size=resolved_mark_size)

    if closed_below and na(bo_dn_bar)
        bo_dn_bar := bar_index
        bo_dn_ref := close
        if not na(dn_pend_bar)
            dn_touches += 1
            dn_pend_bar := na
        if show_marks
            label.new(bar_index, low - atr_raw * 0.8, "▼BO",
                      style=label.style_label_up,
                      color=color.new(#000000, 100), textcolor=col_break_dn, size=resolved_mark_size)

    bool flipped_up   = filt_rising  and not filt_rising[1]
    bool flipped_down = filt_falling and not filt_falling[1]

    if not na(flip_bar) and (bar_index - flip_bar) >= flip_grade_bars
        flips_total += 1
        bool was_correct = flip_dir == 1 ? close > flip_price : close < flip_price
        if was_correct
            flips_correct += 1
        flip_bar := na

    if (flipped_up or flipped_down) and na(flip_bar)
        flip_bar   := bar_index
        flip_price := close
        flip_dir   := flipped_up ? 1 : -1


// VISUALS
color ch_col = filt_rising ? col_rising : filt_falling ? col_falling : col_flat

p_f  = plot(filt,    "Gaussian Filter", color=ch_col, linewidth=filt_width_in)
p_up = plot(band_up, "Upper Band",      color=color.new(ch_col, 55), linewidth=band_width_in)
p_dn = plot(band_dn, "Lower Band",      color=color.new(ch_col, 55), linewidth=band_width_in)

fill(p_up, p_f, top_color = show_fill ? color.new(ch_col, math.min(99, fill_trans_in + 7)) : na,
     bottom_color = show_fill ? color.new(ch_col, fill_trans_in - 3) : na,
     top_value=band_up, bottom_value=filt, title="Upper Fill")
fill(p_f, p_dn, top_color = show_fill ? color.new(ch_col, fill_trans_in - 3) : na,
     bottom_color = show_fill ? color.new(ch_col, math.min(99, fill_trans_in + 7)) : na,
     top_value=filt, bottom_value=band_dn, title="Lower Fill")


// DASHBOARD
var table hud = table.new(resolved_hud_pos, 2, 8,
                           bgcolor=col_dash_bg, border_color=col_dash_border,
                           border_width=1, frame_color=col_dash_border, frame_width=2)

if show_hud and barstate.islast
    table.cell(hud, 0, 0, "SMART GAUSSIAN  [D3R]", text_color=col_dash_header_text,
               bgcolor=col_dash_header_bg, text_size=11, text_halign=text.align_center)
    table.merge_cells(hud, 0, 0, 1, 0)

    table.cell(hud, 0, 1, "Channel", text_color=col_dash_label_text, bgcolor=col_dash_row_bg, text_size=11)
    table.cell(hud, 1, 1, filt_rising ? "▲ RISING" : filt_falling ? "▼ FALLING" : "FLAT",
               text_color=ch_col, bgcolor=col_dash_row_bg,
               text_size=11, text_halign=text.align_center)

    string up_s = up_touches > 0 ? str.tostring(math.round(float(up_rejects) / float(up_touches) * 100.0)) + "% rejected (n=" + str.tostring(up_touches) + ")" : "—"
    table.cell(hud, 0, 2, "Upper Band", text_color=col_dash_label_text, bgcolor=col_dash_row_bg, text_size=11)
    table.cell(hud, 1, 2, up_s,
               text_color=up_touches > 0 ? col_bad : col_dash_label_text,
               bgcolor=col_dash_row_bg, text_size=11, text_halign=text.align_center)

    string dn_s = dn_touches > 0 ? str.tostring(math.round(float(dn_rejects) / float(dn_touches) * 100.0)) + "% rejected (n=" + str.tostring(dn_touches) + ")" : "—"
    table.cell(hud, 0, 3, "Lower Band", text_color=col_dash_label_text, bgcolor=col_dash_row_bg, text_size=11)
    table.cell(hud, 1, 3, dn_s,
               text_color=dn_touches > 0 ? col_good : col_dash_label_text,
               bgcolor=col_dash_row_bg, text_size=11, text_halign=text.align_center)

    string bu_s = bo_up_total > 0 ? str.tostring(math.round(float(bo_up_cont) / float(bo_up_total) * 100.0)) + "% continued (n=" + str.tostring(bo_up_total) + ")" : "—"
    table.cell(hud, 0, 4, "Breakouts ▲", text_color=col_dash_label_text, bgcolor=col_dash_row_bg, text_size=11)
    table.cell(hud, 1, 4, bu_s,
               text_color=bo_up_total > 0 ? col_good : col_dash_label_text,
               bgcolor=col_dash_row_bg, text_size=11, text_halign=text.align_center)

    string bd_s = bo_dn_total > 0 ? str.tostring(math.round(float(bo_dn_cont) / float(bo_dn_total) * 100.0)) + "% continued (n=" + str.tostring(bo_dn_total) + ")" : "—"
    table.cell(hud, 0, 5, "Breakouts ▼", text_color=col_dash_label_text, bgcolor=col_dash_row_bg, text_size=11)
    table.cell(hud, 1, 5, bd_s,
               text_color=bo_dn_total > 0 ? col_bad : col_dash_label_text,
               bgcolor=col_dash_row_bg, text_size=11, text_halign=text.align_center)

    string fl_s = flips_total > 0 ? str.tostring(math.round(float(flips_correct) / float(flips_total) * 100.0)) + "% (n=" + str.tostring(flips_total) + ")" : "—"
    table.cell(hud, 0, 6, "Flip Win Rate", text_color=col_dash_label_text, bgcolor=col_dash_row_bg, text_size=11)
    table.cell(hud, 1, 6, fl_s,
               text_color=flips_total > 0 ? (float(flips_correct) / float(flips_total) >= 0.5 ? col_good : col_bad) : col_dash_label_text,
               bgcolor=col_dash_row_bg, text_size=11, text_halign=text.align_center)

barcolor(color_bars_to_gray ? C_BAR:na)

// ALERTS
bool closed_above_a = barstate.isconfirmed and close > band_up and close[1] <= band_up[1]
bool closed_below_a = barstate.isconfirmed and close < band_dn and close[1] >= band_dn[1]
bool flip_up_a      = barstate.isconfirmed and filt_rising and not filt_rising[1]
bool flip_dn_a      = barstate.isconfirmed and filt_falling and not filt_falling[1]

alertcondition(closed_above_a, "Close Above Channel", "D3R Gaussian AI: price closed above the upper band — check breakout continuation stats")
alertcondition(closed_below_a, "Close Below Channel", "D3R Gaussian AI: price closed below the lower band — check breakout continuation stats")
alertcondition(flip_up_a,      "Filter Turned Up",    "D3R Gaussian AI: gaussian filter turned upward")
alertcondition(flip_dn_a,      "Filter Turned Down",  "D3R Gaussian AI: gaussian filter turned downward")
````
