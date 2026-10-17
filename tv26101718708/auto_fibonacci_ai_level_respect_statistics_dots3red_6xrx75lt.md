# Auto Fibonacci AI - Level Respect Statistics [Dots3Red]

- url: https://www.tradingview.com/script/6XRX75lt-Auto-Fibonacci-AI-Level-Respect-Statistics-Dots3Red/
- type: indicator
- pine_id: PUB;5f03e06266e44518b1f161e71c95ee24
- version: 2.0

## Description

[b]📐 AUTO FIBONACCI AI - LEVEL RESPECT STATISTICS [Dots3Red][/b]
Fibonacci retracement is one of the most widely used tools in trading. It is also one of the least verified. "The 0.618 is the golden pocket" gets repeated everywhere and tested nowhere. This script keeps score — not universally, but specifically for the chart you are actually looking at.


[b]✨ WHY THIS IS DIFFERENT[/b]
Every other Fibonacci tool draws the levels and stops there. Whether those levels actually work on this instrument, this timeframe, this market condition is left entirely to assumption. This script treats that as a question worth answering. Every touch of every level is graded: did price reject cleanly, or push through? The results accumulate directly in each level's label:

📊 [b]0.618  |  71% bounced  (n=24)[/b]

That means: on this chart, at this timeframe, price has touched the 0.618 level 24 times across all the swings this script has processed. 71% of those touches resulted in a genuine rejection. 29% broke through. That is a real measurement, not a theoretical assumption.


[b]⚙️ HOW IT WORKS[/b]
📐 [b]Auto swing detection[/b] — the script identifies the most recent confirmed pivot high and pivot low using a configurable lookback. A minimum swing size filter (in ATR units) rejects small, noisy movements — only swings that represent genuine market structure anchor the Fibonacci grid. Swings are confirmed only on closed bars, so the anchor never changes retroactively.

📏 [b]Retracement levels[/b] — the standard five levels are drawn from the detected swing: 0.236, 0.382, 0.500, 0.618, and 0.786. The 0.618 is highlighted in amber since it receives the most attention from traders and institutions. Each level accumulates its own separate statistics.

🎯 [b]Touch grading[/b] — every time price approaches a level within a configurable tolerance, a touch is recorded and enters a pending state. Within the outcome window (configurable bars), it resolves as one of three outcomes:
• [b]Bounce[/b] — price moved cleanly away from the level without breaking it
• [b]Break[/b] — price closed convincingly through the level
• [b]Timeout[/b] — neither happened clearly enough to call; counted as a touch but not a bounce or break

Each resolved touch feeds into that level's cumulative percentage — and the labels update to show the live result.

🟢 [b]Extension targets[/b] — when price breaks past the swing's extreme (not just retracing to it but genuinely continuing through), the script activates two extension targets: 1.272 and 1.618. These are the levels most commonly used as continuation targets after a structural break. Each is tracked in its own way: did price actually reach 1.272 after the break? 1.618? Over time, the extension labels show:

📊 [b]1.272  |  hit 64%  (n=11)[/b]
📊 [b]1.618  |  hit 41%  (n=11)[/b]

That's a concrete answer to "how far does price usually go when it breaks the swing?" — specific to this chart, not assumed from theory.

🔒 [b]Non-repainting[/b] — pivots only confirm after the required bars on each side have closed. The swing anchor only updates when a new qualifying pivot is confirmed. Grading only happens on confirmed bars. The levels and statistics reflect what actually happened, not what the current bar is doing in real time.


[b]🧭 HOW TO USE[/b]
1️⃣ [b]Let the sample size build before trusting the percentages.[/b] A level that shows "0% bounced (n=2)" is meaningless — two touches is noise. The labels deliberately show the N= count so you can judge reliability yourself. A consistent reading across 15+ touches is worth paying attention to; 3-5 touches is still developing.

2️⃣ [b]Compare across levels.[/b] If 0.382 shows 40% bounced on this chart while 0.618 shows 74% bounced, that's telling you something specific about which pullback depth this market tends to respect. That difference is invisible to a plain Fibonacci tool.

3️⃣ [b]Use extension hit rates for target selection.[/b] If 1.272 has been reached in 64% of breakout cases but 1.618 only in 41%, the first extension is the more realistic target on this chart — and the second, while possible, has historically been hit less than half the time. This is not a rule; it is an observation about past behavior on this specific chart.

4️⃣ [b]Adjust settings to the timeframe.[/b] The defaults (pivot leg 8, minimum swing 3× ATR) are calibrated for mid-range timeframes — 15-minute through 4-hour — where Fibonacci retracement is most actively watched by swing traders and where enough swings complete regularly to build meaningful sample counts. On faster timeframes, reduce both settings so smaller swings qualify. On slower ones, increase them to filter noise.

5️⃣ [b]The statistics describe the past, not the future.[/b] A high bounce rate at 0.618 means price has historically respected this level on this chart. It is not a promise that the current touch will also bounce. Use the percentages as context — one input among many — not as an automatic signal.


[b]🛠️ SETTINGS[/b]
📐 [b]Swing Detection[/b]
• Pivot Leg — bars required on each side to confirm a swing pivot
• Min Swing Size — smallest qualifying swing in ATR units; filters out noise

🎯 [b]Level Grading[/b]
• Touch Tolerance — how close price must come to a level to count as a touch
• Break Buffer — how far past a level close must clear to grade as a break
• Bounce Distance — how far price must move away, cleanly, to grade as a bounce
• Outcome Window — bars allowed for a touch to resolve
• Extension Window — bars allowed for an extension target to be reached after a break

🎨 [b]Visualization[/b]
• Show Extension Targets — toggle the 1.272 / 1.618 green lines
• Per-Level Stat Labels — toggle the bounce-rate text on each level

🖥️ [b]Dashboard[/b]
• Show / hide, position — swing direction and per-level bounce rates in a compact table

[b]📝 NOTES[/b]
The script tracks one active Fibonacci grid at a time — the most recent qualifying swing. When a new swing confirms, the grid shifts and per-level statistics carry forward from all previous swings on the chart. The statistics are global across all swings processed since the indicator was added to the chart, not per-swing.

Statistics are most meaningful on timeframes where Fibonacci retracement is genuinely watched and defended by real market participants — typically 15-minute through 4-hour. Very short timeframes will accumulate sample counts quickly but the measurements may reflect microstructure noise rather than true level respect. Very long timeframes will take extended real-world time to build enough data to be informative.

[b]⚠️ DISCLAIMER[/b]
This is an analytical and visualization tool. It does not generate trade signals and does not constitute financial advice. Historical bounce and hit rates do not guarantee how price will behave at any specific future level touch.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Dots3Red
// TradingView: https://www.tradingview.com/u/Dots3Red/

//@version=6
indicator("Auto Fibonacci AI - Level Respect Statistics [Dots3Red]",
          shorttitle = "Auto Fib AI [D3R]",
          overlay    = true,
          max_lines_count  = 500,
          max_labels_count = 500)

// INPUTS
GRP_DET = "📐 Swing Detection"
GRP_TCH = "🎯 Level Grading"
GRP_VIS = "🎨 Visualization"
GRP_COL = "🎨 Colors"
GRP_HUD = "🖥️ Dashboard"

pivot_leg   = input.int(8, "Pivot Leg (bars each side)", minval=3, maxval=30, group=GRP_DET,
              tooltip="Bars required on each side to confirm a swing pivot. Larger = bigger, more significant swings.")
min_swing_atr = input.float(3.0, "Min Swing Size (×ATR)", minval=0.5, maxval=20.0, step=0.5, group=GRP_DET,
              tooltip="Swings smaller than this are ignored — tiny swings produce meaningless fib structures.")

touch_tol   = input.float(0.2, "Touch Tolerance (×ATR)", minval=0.05, maxval=1.0, step=0.05, group=GRP_TCH)
break_buf   = input.float(0.3, "Break Buffer (×ATR)", minval=0.05, maxval=1.5, step=0.05, group=GRP_TCH,
              tooltip="Close must clear a level by this margin to grade the touch as a break.")
bounce_atr  = input.float(1.0, "Bounce Distance (×ATR)", minval=0.3, maxval=5.0, step=0.1, group=GRP_TCH,
              tooltip="Price must move away from the level at least this far, without breaking, to grade as a bounce.")
outcome_bars = input.int(10, "Outcome Window (bars)", minval=3, maxval=50, group=GRP_TCH)
ext_window  = input.int(40, "Extension Window (bars)", minval=10, maxval=200, group=GRP_TCH,
              tooltip="Bars after a swing-extreme break within which extension targets must be reached to count as hit.")

show_ext    = input.bool(true, "Show Extension Targets", group=GRP_VIS)
show_stats  = input.bool(true, "Per-Level Stat Labels", group=GRP_VIS)
swing_width_in = input.int(2, "Swing Line Width", minval=1, maxval=4, group=GRP_VIS)
fib_width_in   = input.int(1, "Fib Level Line Width", minval=1, maxval=4, group=GRP_VIS)
fib_618_width_in = input.int(1, "0.618 Line Width (Golden Ratio)", minval=1, maxval=4, group=GRP_VIS,
              tooltip="Independent width for the 0.618 level, since it's typically the most watched.")
ext_width_in   = input.int(1, "Extension Line Width", minval=1, maxval=4, group=GRP_VIS)
label_size_in  = input.string("Small", "Stat Label Size", options=["Tiny","Small","Normal","Large"], group=GRP_VIS)
line_style_in  = input.string("Dotted", "Fib Level Line Style", options=["Solid","Dashed","Dotted"], group=GRP_VIS)

col_swing_up   = input.color(#00f0ff, "Swing High Line (Up-Swing)", group=GRP_COL)
col_swing_dn   = input.color(#ff00aa, "Swing Low Line (Down-Swing)", group=GRP_COL)
col_swing_base = input.color(#64748b, "Swing Base Line", group=GRP_COL)
col_fib        = input.color(#94a3b8, "Fib Levels (default)", group=GRP_COL)
col_618        = input.color(#ffb700, "0.618 Level (Golden Ratio)", group=GRP_COL)
col_ext        = input.color(#00c896, "Extension Lines", group=GRP_COL)

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


f_line_style(string s) =>
    switch s
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        => line.style_dotted

f_label_size(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

f_hud_pos(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        => position.bottom_left

resolved_line_style = f_line_style(line_style_in)
resolved_label_size = f_label_size(label_size_in)
resolved_hud_pos    = f_hud_pos(hud_pos)


atr_raw = ta.atr(14)
ph = ta.pivothigh(high, pivot_leg, pivot_leg)
pl = ta.pivotlow(low,  pivot_leg, pivot_leg)


// FIB LEVELS
var float[] FIB_R = array.from(0.236, 0.382, 0.5, 0.618, 0.786)
var float[] FIB_E = array.from(1.272, 1.618)

var int[] lvl_touches = array.new<int>(5, 0)
var int[] lvl_bounces = array.new<int>(5, 0)

var int ext_attempts = 0
var int ext_hit_1    = 0
var int ext_hit_2    = 0

var bool  fib_active  = false
var bool  fib_is_up   = false
var float fib_hi      = na
var float fib_lo      = na
var int   fib_hi_bar  = na
var int   fib_lo_bar  = na

var float last_ph = na
var int   last_ph_bar = na
var float last_pl = na
var int   last_pl_bar = na

var int   pend_bar   = na
var int   pend_lvl   = na
var float pend_price = na

var int   extp_bar = na
var float extp_t1  = na
var float extp_t2  = na
var bool  extp_hit1 = false

var line[]  fib_lines  = array.new<line>()
var label[] fib_labels = array.new<label>()

f_lvl_price(int i) =>
    float r = array.get(FIB_R, i)
    fib_is_up ? fib_hi - (fib_hi - fib_lo) * r : fib_lo + (fib_hi - fib_lo) * r

f_ext_price(int i) =>
    float r = array.get(FIB_E, i)
    fib_is_up ? fib_hi + (fib_hi - fib_lo) * (r - 1.0) : fib_lo - (fib_hi - fib_lo) * (r - 1.0)

f_clear_fib() =>
    if array.size(fib_lines) > 0
        for i = 0 to array.size(fib_lines) - 1
            line.delete(array.get(fib_lines, i))
        array.clear(fib_lines)
    if array.size(fib_labels) > 0
        for i = 0 to array.size(fib_labels) - 1
            label.delete(array.get(fib_labels, i))
        array.clear(fib_labels)

f_draw_fib() =>
    f_clear_fib()
    int x1 = math.min(fib_hi_bar, fib_lo_bar)
    int x2 = bar_index + 10
    array.push(fib_lines, line.new(x1, fib_is_up ? fib_hi : fib_lo, x2, fib_is_up ? fib_hi : fib_lo,
               color=color.new(fib_is_up ? col_swing_up : col_swing_dn, 30), width=swing_width_in))
    array.push(fib_lines, line.new(x1, fib_is_up ? fib_lo : fib_hi, x2, fib_is_up ? fib_lo : fib_hi,
               color=color.new(col_swing_base, 55), width=swing_width_in))
    for i = 0 to 4
        float lp = f_lvl_price(i)
        bool is_618 = i == 3
        color lc = is_618 ? col_618 : col_fib
        int   lw = is_618 ? fib_618_width_in : fib_width_in
        array.push(fib_lines, line.new(x1, lp, x2, lp,
                   color=color.new(lc, is_618 ? 20 : 40), width=lw,
                   style=resolved_line_style))
        if show_stats
            int t = array.get(lvl_touches, i)
            int b = array.get(lvl_bounces, i)
            string s = str.tostring(array.get(FIB_R, i), "#.###")
            if t > 0
                float pct = float(b) / float(t) * 100.0
                s := s + "  |  " + str.tostring(math.round(pct)) + "% bounced (n=" + str.tostring(t) + ")"
            else
                s := s + "  |  no touches yet"
            color stat_c = t == 0 ? lc : (float(b) / float(t) >= 0.5 ? col_good : col_bad)
            array.push(fib_labels, label.new(x2, lp, s,
                       style=label.style_label_left,
                       color=color.new(#000000, 100),
                       textcolor=stat_c, size=resolved_label_size))
    if show_ext
        for i = 0 to 1
            float ep = f_ext_price(i)
            array.push(fib_lines, line.new(x1, ep, x2, ep,
                       color=color.new(col_ext, 60), width=ext_width_in, style=line.style_dashed))
            string es = str.tostring(array.get(FIB_E, i), "#.###")
            color ext_c = col_ext
            if ext_attempts > 0
                int hits = i == 0 ? ext_hit_1 : ext_hit_2
                float epct = float(hits) / float(ext_attempts) * 100.0
                es := es + "  |  hit " + str.tostring(math.round(epct)) + "% (n=" + str.tostring(ext_attempts) + ")"
                ext_c := epct >= 50 ? col_good : col_bad
            array.push(fib_labels, label.new(x2, ep, es,
                       style=label.style_label_left,
                       color=color.new(#000000, 100),
                       textcolor=ext_c, size=resolved_label_size))
    true


if barstate.isconfirmed

    bool rebuilt = false
    if not na(ph)
        last_ph     := ph
        last_ph_bar := bar_index - pivot_leg
        rebuilt := true
    if not na(pl)
        last_pl     := pl
        last_pl_bar := bar_index - pivot_leg
        rebuilt := true

    if rebuilt and not na(last_ph) and not na(last_pl)
        if math.abs(last_ph - last_pl) >= min_swing_atr * atr_raw
            fib_active := true
            fib_is_up  := last_ph_bar > last_pl_bar
            fib_hi     := last_ph
            fib_lo     := last_pl
            fib_hi_bar := last_ph_bar
            fib_lo_bar := last_pl_bar
            pend_bar   := na
            extp_bar   := na
            extp_hit1  := false
            f_draw_fib()

    if fib_active and not na(pend_bar)
        float lv = pend_price
        bool is_from_above = fib_is_up
        bool broke = is_from_above ? close < lv - break_buf * atr_raw : close > lv + break_buf * atr_raw
        bool bounced = is_from_above ? (close - lv) >= bounce_atr * atr_raw : (lv - close) >= bounce_atr * atr_raw
        bool timed_out = (bar_index - pend_bar) >= outcome_bars
        if broke or bounced or timed_out
            array.set(lvl_touches, pend_lvl, array.get(lvl_touches, pend_lvl) + 1)
            if bounced
                array.set(lvl_bounces, pend_lvl, array.get(lvl_bounces, pend_lvl) + 1)
            pend_bar := na
            f_draw_fib()

    if fib_active and na(pend_bar)
        int   best_i = na
        float best_d = touch_tol * atr_raw
        for i = 0 to 4
            float lp = f_lvl_price(i)
            float d = fib_is_up ? math.abs(low - lp) : math.abs(high - lp)
            bool correct_side = fib_is_up ? close > lp : close < lp
            if d <= best_d and correct_side
                best_d := d
                best_i := i
        if not na(best_i)
            pend_bar   := bar_index
            pend_lvl   := best_i
            pend_price := f_lvl_price(best_i)

    if fib_active and na(extp_bar)
        bool broke_extreme = fib_is_up ? close > fib_hi + break_buf * atr_raw : close < fib_lo - break_buf * atr_raw
        if broke_extreme
            extp_bar  := bar_index
            extp_t1   := f_ext_price(0)
            extp_t2   := f_ext_price(1)
            extp_hit1 := false
            ext_attempts += 1

    if not na(extp_bar)
        bool hit1 = fib_is_up ? high >= extp_t1 : low <= extp_t1
        bool hit2 = fib_is_up ? high >= extp_t2 : low <= extp_t2
        if hit1 and not extp_hit1
            ext_hit_1 += 1
            extp_hit1 := true
        if hit2
            ext_hit_2 += 1
            extp_bar := na
            f_draw_fib()
        else if (bar_index - extp_bar) >= ext_window
            extp_bar := na
            f_draw_fib()


// DASHBOARD
var table hud = table.new(resolved_hud_pos, 2, 10,
                           bgcolor=col_dash_bg, border_color=col_dash_border,
                           border_width=1, frame_color=col_dash_border, frame_width=2)

if show_hud and barstate.islast
    table.cell(hud, 0, 0, "AUTO FIB AI [D3R]", text_color=col_dash_header_text,
               bgcolor=col_dash_header_bg, text_size=11, text_halign=text.align_center)
    table.merge_cells(hud, 0, 0, 1, 0)

    table.cell(hud, 0, 1, "Swing", text_color=col_dash_label_text, bgcolor=col_dash_row_bg, text_size=11)
    table.cell(hud, 1, 1, not fib_active ? "—" : fib_is_up ? "▲ UP" : "▼ DOWN",
               text_color=not fib_active ? col_dash_label_text : fib_is_up ? col_swing_up : col_swing_dn,
               bgcolor=col_dash_row_bg, text_size=11, text_halign=text.align_center)

    for i = 0 to 4
        int t = array.get(lvl_touches, i)
        int b = array.get(lvl_bounces, i)
        string rowlab = str.tostring(array.get(FIB_R, i), "#.###")
        string rowval = t > 0 ? str.tostring(math.round(float(b) / float(t) * 100.0)) + "%  (n=" + str.tostring(t) + ")" : "—"
        color rc = t == 0 ? col_dash_label_text : float(b) / float(t) >= 0.5 ? col_good : col_bad
        table.cell(hud, 0, 2 + i, rowlab, text_color=i == 3 ? col_618 : col_dash_label_text,
                   bgcolor=col_dash_row_bg, text_size=11)
        table.cell(hud, 1, 2 + i, rowval, text_color=rc,
                   bgcolor=col_dash_row_bg, text_size=11, text_halign=text.align_center)

    string e1 = ext_attempts > 0 ? str.tostring(math.round(float(ext_hit_1) / float(ext_attempts) * 100.0)) + "% / " + str.tostring(math.round(float(ext_hit_2) / float(ext_attempts) * 100.0)) + "%" : "—"
    table.cell(hud, 0, 7, "Ext 1.272/1.618", text_color=col_dash_label_text, bgcolor=col_dash_row_bg, text_size=11)
    table.cell(hud, 1, 7, e1 + (ext_attempts > 0 ? "  (n=" + str.tostring(ext_attempts) + ")" : ""),
               text_color=ext_attempts > 0 ? col_ext : col_dash_label_text,
               bgcolor=col_dash_row_bg, text_size=11, text_halign=text.align_center)


// ALERTS
bool touch_now = fib_active and not na(pend_bar) and pend_bar == bar_index
bool extreme_broken_now = not na(extp_bar) and extp_bar == bar_index

alertcondition(touch_now,          "Fib Level Touch",    "D3R Auto Fib: price touched a fibonacci level — check its measured bounce rate")
alertcondition(extreme_broken_now, "Swing Extreme Break","D3R Auto Fib: swing extreme broken — extension targets active")
````
