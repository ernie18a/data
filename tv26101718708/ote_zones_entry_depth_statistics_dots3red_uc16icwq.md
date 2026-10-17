# OTE Zones - Entry Depth Statistics [Dots3Red]

- url: https://www.tradingview.com/script/UC16IcWq-OTE-Zones-Entry-Depth-Statistics-Dots3Red/
- type: indicator
- pine_id: PUB;52654304446047cbb7d7929115c5bf87
- version: 1.0

## Description

📏 [b]OTE ZONES — ENTRY DEPTH STATISTICS [Dots3Red][/b]
The Optimal Trade Entry zone, the 61.8% to 79% retracement pocket of a confirmed structural swing , is one of the most repeated ideas in ICT-style trading. Whether entries deeper in that pocket actually perform differently than shallow ones is rarely tested. This script checks it directly.

✨ [b]WHY THIS MATTERS[/b]
"Deeper is better" is one of those trading assumptions that gets repeated until it sounds like fact. Nobody actually measures it, chart by chart, because doing so by hand would mean logging every swing, every retracement touch, and every outcome, by eye, over months. This script does that logging automatically and keeps the running score in view at all times.

📊 [b]Every OTE touch, graded and tallied by depth[/b]

Each of the three retracement levels — shallow, mid, deep — carries its own independent, continuously updating count of touches and continuations. Example of the shape of the output:

0.618 (shallow): 55% continued (n=24)
0.705 (mid): 61% continued (n=19)
0.79 (deep): 64% continued (n=11)

That's not a guarantee of what those numbers will read on your chart — it updates continuously and is specific to the instrument, timeframe, and settings it's run with.

⚙️ [b]HOW IT WORKS[/b]
📐 [b]Structural swing detection[/b] — pivots are confirmed and a swing only qualifies once price has genuinely broken structure (closed beyond the prior pivot) and the leg is large enough, relative to ATR, to represent a real impulse rather than noise.

📏 [b]Three independent OTE levels[/b] — shallow, mid, and deep retracement levels (defaults at 0.618 / 0.705 / 0.79, all independently editable) drawn as a zone between the swing's high and low.

🎯 [b]Touch detection[/b] — when price re-enters the zone and comes within tolerance of one of the three levels, that touch is logged against its specific tier — nearest untested tier first.

🔒 [b]Rolling, honest grading[/b] — each logged touch is graded only once its outcome window has closed: either price continued a defined distance in the original swing direction (counted as a continuation), or the window elapsed without that happening (counted as a non-continuation). A zone that gets invalidated — price closing back through the swing's origin — is discarded rather than graded, since the setup itself failed before conclusion.

🔒 [b]Non-repainting[/b] — the swing, the zone, and every grading decision are all confirmed-bar only.

🧭 [b]HOW TO USE[/b]
1️⃣ [b]Let touches accumulate before reading the tiers.[/b] A tier showing "no touches yet" or a low n is not yet a meaningful statistic — the more touches logged, the more the percentage reflects a real tendency rather than a coincidence.

2️⃣ [b]Compare the three tiers against each other, not against a fixed benchmark.[/b] The useful information is whether percentages step upward from shallow to deep, stay flat, or don't behave the way the "deeper is better" assumption predicts — any of those outcomes is a real answer.

3️⃣ [b]Use the zone drawing as the visual reference, the dashboard as the running scoreboard.[/b] The chart shows where the current zone and levels sit; the table tracks history across every zone this chart has produced.

4️⃣ [b]Treat a tier's win rate as descriptive, not predictive.[/b] It describes what has happened at that depth on this chart historically — not a guaranteed outcome for the next touch.

5️⃣ [b]Adjust the levels to match your own framework.[/b] The three retracement percentages are inputs, not fixed constants — if your own approach uses different levels, set them and let the tool measure against your own definition.

⏱️ [b]WHICH TIMEFRAMES WORK BEST[/b]
This method needs a meaningful number of resolved swings and touches to say anything statistically useful, which makes [b]15-minute through 4-hour[/b] the most balanced range — frequent enough for genuine structural swings to recur and build a sample within a reasonable window, while each swing still reflects real, settled price behavior rather than noise. Very short timeframes produce many low-quality swings even with the size filter; daily and higher timeframes produce meaningful swings too infrequently to build a sample in a practical amount of time.

🛠️ [b]SETTINGS[/b]
📐 [b]Swing & Structure[/b] — pivot leg length, minimum swing size (×ATR)
📏 [b]OTE Levels[/b] — shallow, mid, and deep retracement levels, independently editable
🎯 [b]Outcome Grading[/b] — touch tolerance, continuation confirmation distance, invalidation buffer, outcome window (bars)
🎨 [b]Visualization[/b] — zone fill, tier stat labels, independent bullish/bearish colors
🖥️ [b]Dashboard[/b] — show/hide, position — active zone direction, per-tier continuation rate and sample size, total touches

📝 [b]NOTES[/b]
The percentages shown are specific to this chart, this timeframe, and these settings — they do not transfer to other instruments or configurations. The point of the tool is not to assert which retracement depth is "correct," but to replace that assumption with a measured answer for the chart you're actually trading.

⚠️ [b]DISCLAIMER[/b]
This is an analytical and visualization tool. It does not generate trade signals and does not constitute financial advice. Historical statistics do not guarantee future performance.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Dots3Red
// TradingView: https://www.tradingview.com/u/Dots3Red/

//@version=6
indicator("OTE Zones - Entry Depth Statistics [Dots3Red]",
          shorttitle = "OTE Zones [D3R]",
          overlay    = true,
          max_lines_count  = 500,
          max_boxes_count  = 500,
          max_labels_count = 500)
          



// COLORS
C_NEUTRAL = color.new(#64748b, 0)
C_GREEN   = color.new(#00c896, 0)
C_RED     = color.new(#ff4466, 0)
C_AMBER   = color.new(#ffb700, 0)
C_BG      = color.new(#131722, 5)
C_TXT     = color.new(#f8fafc, 0)
C_DIM     = color.new(#94a3b8, 0)
C_BORD    = color.new(#334155, 0)


// INPUTS
GRP_SW  = "📐 Swing & Structure"
GRP_OTE = "📏 OTE Levels"
GRP_ST  = "🎯 Outcome Grading"
GRP_VIS = "🎨 Visualization"
GRP_COL = "🎨 Colors"
GRP_HUD = "🖥️ Dashboard"

pivot_leg     = input.int(8, "Pivot Leg (bars each side)", minval=3, maxval=30, group=GRP_SW)
min_swing_atr = input.float(3.0, "Min Swing Size (×ATR)", minval=0.5, maxval=20.0, step=0.5, group=GRP_SW,
                tooltip="Swings smaller than this are ignored — the OTE concept needs a real impulse leg to be meaningful.")

ote_shallow = input.float(0.618, "Shallow Level", minval=0.5, maxval=0.9, step=0.001, group=GRP_OTE)
ote_mid     = input.float(0.705, "Mid Level", minval=0.5, maxval=0.9, step=0.001, group=GRP_OTE)
ote_deep    = input.float(0.79,  "Deep Level", minval=0.5, maxval=0.95, step=0.001, group=GRP_OTE)

touch_tol    = input.float(0.15, "Touch Tolerance (×ATR)", minval=0.05, maxval=1.0, step=0.05, group=GRP_ST)
outcome_atr  = input.float(1.0, "Continuation Confirmation (×ATR)", minval=0.3, maxval=5.0, step=0.1, group=GRP_ST,
               tooltip="Price must move this far back in the original swing direction to grade the touch as continued.")
invalid_atr  = input.float(0.5, "Invalidation Buffer (×ATR)", minval=0.1, maxval=3.0, step=0.1, group=GRP_ST,
               tooltip="Price closing beyond the swing origin by this margin invalidates the zone entirely.")
outcome_bars = input.int(15, "Outcome Window (bars)", minval=5, maxval=100, group=GRP_ST)

show_zone   = input.bool(true, "OTE Zone Fill", group=GRP_VIS)
show_labels = input.bool(true, "Tier Stat Labels", group=GRP_VIS)

col_bull_zone = input.color(#00f0ff, "Bullish OTE Zone", group=GRP_COL)
col_bear_zone = input.color(#ff00aa, "Bearish OTE Zone", group=GRP_COL)

show_hud = input.bool(true, "Show Dashboard", group=GRP_HUD)
hud_pos  = input.string("Top Right", "Position",
           options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=GRP_HUD)


// CONTEXT
atr_raw = ta.atr(14)
ph = ta.pivothigh(high, pivot_leg, pivot_leg)
pl = ta.pivotlow(low,  pivot_leg, pivot_leg)


var float last_ph = na
var int   last_ph_bar = na
var float last_pl = na
var int   last_pl_bar = na

var bool  ote_active = false
var bool  ote_is_bull = false   
var float swing_hi = na
var float swing_lo = na
var int   swing_hi_bar = na
var int   swing_lo_bar = na

f_ote_price(float r) =>
    ote_is_bull ? swing_hi - (swing_hi - swing_lo) * r : swing_lo + (swing_hi - swing_lo) * r

// Drawing storage
var box   ote_box = na
var line[] ote_lines = array.new<line>()
var label[] ote_labels = array.new<label>()

var int   pend_bar  = na
var float pend_ref  = na
var int   pend_tier = na

var int[] tier_total     = array.new<int>(3, 0)
var int[] tier_continued = array.new<int>(3, 0)

f_clear_ote() =>
    if not na(ote_box)
        box.delete(ote_box)
    if array.size(ote_lines) > 0
        for i = 0 to array.size(ote_lines) - 1
            line.delete(array.get(ote_lines, i))
        array.clear(ote_lines)
    if array.size(ote_labels) > 0
        for i = 0 to array.size(ote_labels) - 1
            label.delete(array.get(ote_labels, i))
        array.clear(ote_labels)

f_draw_ote() =>
    f_clear_ote()
    int x1 = math.min(swing_hi_bar, swing_lo_bar)
    int x2 = bar_index + 15
    color zc = ote_is_bull ? col_bull_zone : col_bear_zone

    float shallow_p = f_ote_price(ote_shallow)
    float deep_p    = f_ote_price(ote_deep)
    float top = math.max(shallow_p, deep_p)
    float bot = math.min(shallow_p, deep_p)

    box new_box = show_zone ? box.new(x1, top, x2, bot,
                           border_color=color.new(zc, 55), bgcolor=color.new(zc, 88)) : na

    float levels3 = f_ote_price(ote_shallow)
    float levelm  = f_ote_price(ote_mid)
    float leveld  = f_ote_price(ote_deep)
    array.push(ote_lines, line.new(x1, levels3, x2, levels3, color=color.new(zc, 30), width=1, style=line.style_dashed))
    array.push(ote_lines, line.new(x1, levelm,  x2, levelm,  color=color.new(zc, 15), width=2))
    array.push(ote_lines, line.new(x1, leveld,  x2, leveld,  color=color.new(zc, 30), width=1, style=line.style_dashed))

    if show_labels
        for i = 0 to 2
            int t = array.get(tier_total, i)
            int c = array.get(tier_continued, i)
            string tname = i == 0 ? str.tostring(ote_shallow) : i == 1 ? str.tostring(ote_mid) : str.tostring(ote_deep)
            string s = tname
            if t > 0
                s := s + "  |  " + str.tostring(math.round(float(c) / float(t) * 100.0)) + "% continued (n=" + str.tostring(t) + ")"
            else
                s := s + "  |  no touches yet"
            float ly = i == 0 ? levels3 : i == 1 ? levelm : leveld
            array.push(ote_labels, label.new(x2, ly, s,
                       style=label.style_label_left,
                       color=color.new(#000000, 100), textcolor=zc, size=11))

    new_box


bool new_ote = false

if barstate.isconfirmed

    // UPDATE PIVOTS 
    if not na(ph)
        last_ph     := ph
        last_ph_bar := bar_index - pivot_leg
    if not na(pl)
        last_pl     := pl
        last_pl_bar := bar_index - pivot_leg

    bool bull_break = not na(last_ph) and not na(last_pl) and last_pl_bar > last_ph_bar and close > last_ph and close[1] <= last_ph
    bool bear_break = not na(last_ph) and not na(last_pl) and last_ph_bar > last_pl_bar and close < last_pl and close[1] >= last_pl

    if bull_break and math.abs(close - last_pl) >= min_swing_atr * atr_raw
        ote_active   := true
        ote_is_bull  := true
        swing_hi     := close
        swing_hi_bar := bar_index
        swing_lo     := last_pl
        swing_lo_bar := last_pl_bar
        pend_bar     := na
        new_ote      := true
        ote_box      := f_draw_ote()

    if bear_break and math.abs(last_ph - close) >= min_swing_atr * atr_raw
        ote_active   := true
        ote_is_bull  := false
        swing_lo     := close
        swing_lo_bar := bar_index
        swing_hi     := last_ph
        swing_hi_bar := last_ph_bar
        pend_bar     := na
        new_ote      := true
        ote_box      := f_draw_ote()

    // GRADE PENDING TOUCH 
    if ote_active and not na(pend_bar)
        bool continued = ote_is_bull ? (close - pend_ref) >= outcome_atr * atr_raw
                                      : (pend_ref - close) >= outcome_atr * atr_raw
        bool timed = (bar_index - pend_bar) >= outcome_bars
        if continued or timed
            array.set(tier_total, pend_tier, array.get(tier_total, pend_tier) + 1)
            if continued
                array.set(tier_continued, pend_tier, array.get(tier_continued, pend_tier) + 1)
            pend_bar := na
            ote_box  := f_draw_ote()

    if ote_active and na(pend_bar)
        float p_shallow = f_ote_price(ote_shallow)
        float p_mid     = f_ote_price(ote_mid)
        float p_deep    = f_ote_price(ote_deep)
        float px = ote_is_bull ? low : high
        bool correct_side = ote_is_bull ? close > swing_lo : close < swing_hi

        if correct_side
            if math.abs(px - p_deep) <= touch_tol * atr_raw
                pend_bar := bar_index
                pend_ref := close
                pend_tier := 2
            else if math.abs(px - p_mid) <= touch_tol * atr_raw
                pend_bar := bar_index
                pend_ref := close
                pend_tier := 1
            else if math.abs(px - p_shallow) <= touch_tol * atr_raw
                pend_bar := bar_index
                pend_ref := close
                pend_tier := 0

    // INVALIDATION: price closes beyond the swing origin 
    bool invalidated = ote_active and (ote_is_bull ? close < swing_lo - invalid_atr * atr_raw
                                                    : close > swing_hi + invalid_atr * atr_raw)
    if invalidated
        ote_active := false
        pend_bar   := na
        f_clear_ote()
        ote_box    := na

    // EXTEND ZONE WHILE ACTIVE 
    if ote_active and not invalidated and not new_ote
        if not na(ote_box)
            box.set_right(ote_box, bar_index + 15)
        if array.size(ote_lines) > 0
            for i = 0 to array.size(ote_lines) - 1
                line.set_x2(array.get(ote_lines, i), bar_index + 15)
        if array.size(ote_labels) > 0
            for i = 0 to array.size(ote_labels) - 1
                label.set_x(array.get(ote_labels, i), bar_index + 16)


// DASHBOARD
f_hud_pos(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        =>                position.bottom_left

var table hud = table.new(f_hud_pos(hud_pos), 2, 6,
                           bgcolor=C_BG, border_color=C_BORD,
                           border_width=1, frame_color=C_BORD, frame_width=2)

if show_hud and barstate.islast
    table.cell(hud, 0, 0, "OTE AI [D3R]", text_color=C_TXT,
               bgcolor=color.new(#1e293b, 0), text_size=11, text_halign=text.align_center)
    table.merge_cells(hud, 0, 0, 1, 0)

    table.cell(hud, 0, 1, "Active Zone", text_color=C_DIM, bgcolor=color.new(#1e293b, 40), text_size=11)
    table.cell(hud, 1, 1, not ote_active ? "—" : ote_is_bull ? "▲ Bullish" : "▼ Bearish",
               text_color=not ote_active ? C_DIM : ote_is_bull ? col_bull_zone : col_bear_zone,
               bgcolor=color.new(#1e293b, 40), text_size=11, text_halign=text.align_center)

    for i = 0 to 2
        int t = array.get(tier_total, i)
        int c = array.get(tier_continued, i)
        string lbl = i == 0 ? str.tostring(ote_shallow) : i == 1 ? str.tostring(ote_mid) : str.tostring(ote_deep)
        string rowval = t > 0 ? str.tostring(math.round(float(c) / float(t) * 100.0)) + "%  (n=" + str.tostring(t) + ")" : "—"
        color rc = t == 0 ? C_DIM : float(c) / float(t) >= 0.5 ? C_GREEN : C_RED
        table.cell(hud, 0, 2 + i, lbl, text_color=C_DIM,
                   bgcolor=color.new(i % 2 == 0 ? #1e293b : #0f172a, 40), text_size=11)
        table.cell(hud, 1, 2 + i, rowval, text_color=rc,
                   bgcolor=color.new(i % 2 == 0 ? #1e293b : #0f172a, 40), text_size=11, text_halign=text.align_center)

    int gt = array.get(tier_total,0) + array.get(tier_total,1) + array.get(tier_total,2)
    table.cell(hud, 0, 5, "Total Touches", text_color=C_DIM, bgcolor=color.new(#1e293b, 40), text_size=11)
    table.cell(hud, 1, 5, str.tostring(gt), text_color=C_TXT, bgcolor=color.new(#1e293b, 40), text_size=11, text_halign=text.align_center)


// ALERTS
alertcondition(new_ote, "New OTE Zone", "D3R OTE AI: new optimal trade entry zone formed after a structure break")
````
