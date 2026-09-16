<!-- tradingview-pine-id: PUB;a419e48f22b64e4a8be52d94e71d4d54 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Trendline Breakouts

Source: https://www.tradingview.com/script/UKPikQUU-Trendline-Breakouts/

## Description

Draw a trendline by hand and you will always find one that fits. That is the problem, not the skill.

This script does not let you go looking for it. It builds every line from real swing highs, keeps only the ones a later high confirms, and deletes any line that price has already traded through. The same rule runs on every chart, every timeframe, every time you load it.

How a line earns its place

Two swing highs propose a line. A third high has to land on it, inside the tolerance you set. If any bar in between traded through the line, the line never existed. Nothing here is drawn by eye and nothing is fitted after the fact.

The break ⚡, and what came after it

The first bar that trades above the line closes it and gets a triangle. From there the script assumes an entry at the break level and your stop distance below it, then measures the best move that break went on to produce before the stop was lost. The figure is printed next to the break.

 What you control

The touch tolerance, how much slack a line may absorb before it is invalidated, how far price must travel to confirm a break, when a quiet old line fades, and your stop. Tighten it for textbook lines. Loosen it and see how much structure survives.

📊 The panel

Lines found, how many are still unbroken right now, the risk you chose, and the average peak gain across the breaks on screen, always next to the number of breaks behind it. An average without its sample size tells you nothing.

⚠️ Read this part too

The peak gain is the best excursion after the break, not a realised return. It assumes you sold at the exact high, which you will not. Everything is recomputed on the bars you can see, so panning and zooming change the picture. This build measures on a linear price scale and reads bullish structure only.  

I hope this helps you to finally draw lines properly so you can trade them confidently.

---

## Source Code

````pine
//@version=6
// =============================================================================
//  Trendline Breakouts                              (Pine Script v6)
//
//  Draws the falling resistance lines that price has actually respected inside
//  the visible range and flags the bar where each one finally gives way to the
//  upside.
//
//  How it works
//    1. Local swing highs are collected across the visible bars only.
//    2. Every pair of highs defines a candidate line with a negative slope.
//    3. A line survives if at least one later high lands on it within the touch
//       tolerance and no bar has traded through it in the meantime.
//    4. The first bar that trades above the line closes it and is marked with a
//       triangle. From there the script measures the best excursion reached
//       before the stop distance is lost.
//
//  Limitations, stated up front
//    - Everything is recomputed on the visible range, so panning or zooming
//      changes what you see. It is a reading aid, not a backtest.
//    - The peak gain is the best excursion between the break and the stop, not
//      a realised return: it assumes an exit at the exact high of the move.
//    - Lines are measured on a linear price scale in this build.
//    - This build scans bullish structure only.
// =============================================================================
indicator("Trendline Breakouts", "Trendline Breakouts", overlay = true, max_bars_back = 5000, max_lines_count = 500, max_labels_count = 500)

// ============================ INPUT GROUPS ==================================
string G_TREND = "1. Trendline settings"
string G_RISK  = "2. Risk and performance"
string G_PANEL = "3. Panel"
string G_SCOPE = "4. Scope of this build"

// ------------------------- 1. Trendline settings ----------------------------
touch_tol_pct     = input.float(1.0, title = "Touch tolerance (%)",                     minval = 0.1, step = 0.1, group = G_TREND, tooltip = "How close a later pivot has to come to the projected line to count as a touch.")
break_tol_mid_pct = input.float(0.0, title = "Intermediate break tolerance (%)",        minval = 0.0, step = 0.1, group = G_TREND, tooltip = "Slack allowed while the line is still being built. Any excursion beyond it invalidates the line, so raising it keeps more lines alive.")
break_tol_end_pct = input.float(0.0, title = "Confirmation break tolerance (%)",        minval = 0.0, step = 0.1, group = G_TREND, tooltip = "How far price has to trade beyond the line before the break is treated as confirmed.")
fade_bars         = input.int(600,   title = "Bars before an unbroken line fades",      minval = 100, step = 100, group = G_TREND)
max_touch_gap     = input.int(150,   title = "Max bars between touches (fades beyond)", minval = 10,  step = 10,  group = G_TREND)
pivot_limit       = input.int(100,   title = "Pivot limit on screen",                   minval = 10,  maxval = 200, group = G_TREND, tooltip = "Caps how many pivots feed the search. Lower it if the script slows down on long ranges.")
col_resistance    = input.color(color.new(color.blue, 0), title = "Resistance line", group = G_TREND)

// ---------------------- 2. Risk and performance -----------------------------
stop_pct = input.float(5.0, title = "Stop loss after the break (%)", minval = 0.1, step = 0.5, group = G_RISK, tooltip = "Risk assumed on every break. The peak gain is measured from the break level until this stop is lost, so a wider stop gives the move more room and a longer measurement window.")

// ------------------------------- 3. Panel -----------------------------------
show_panel   = input.bool(true, title = "Show summary panel", group = G_PANEL)
panel_pos_in = input.string("Bottom right", title = "Panel position", options = ["Bottom right", "Top right", "Bottom left", "Top left"], group = G_PANEL)

// --------------------------- 4. Scope of this build -------------------------
// Fixed settings, listed so you can see exactly what this build covers and what
// it leaves out, with no guessing about hidden behaviour. Each one offers a
// single value, so they are read-only markers rather than switches. Only the
// price scale feeds the engine.
scale_mode = input.string("Linear",        title = "Price scale used for the maths", options = ["Linear"],        group = G_SCOPE, tooltip = "Trendline geometry is measured on a linear price scale in this build. On a logarithmic chart the drawn line will not sit exactly on the pivots it was built from.")
scope_dir  = input.string("Bullish only",  title = "Trend direction scanned",        options = ["Bullish only"],  group = G_SCOPE, tooltip = "Falling resistance broken to the upside. Rising support and its breakdowns are not scanned here.")
scope_dt   = input.string("Not included",  title = "Double tops",                    options = ["Not included"],  group = G_SCOPE)
scope_db   = input.string("Not included",  title = "Double bottoms",                 options = ["Not included"],  group = G_SCOPE)

// ======================= PRICE SCALE HELPERS =================================
// The whole engine runs through these two, so the maths and the drawing always
// agree on which scale a straight line means.
bool use_log = scale_mode == "Logarithmic"

f_scale(p)   => use_log ? math.log(math.max(p, 1e-10)) : p
f_unscale(y) => use_log ? math.exp(y) : y

// =============================== STATE =======================================
var array<line>  drawn_lines  = array.new<line>()
var array<label> drawn_labels = array.new<label>()

var table panel = table.new(panel_pos_in == "Top right" ? position.top_right : panel_pos_in == "Bottom left" ? position.bottom_left : panel_pos_in == "Top left" ? position.top_left : position.bottom_right, 2, 6, border_width = 1, border_color = color.new(color.gray, 80), frame_color = color.new(color.gray, 80), frame_width = 1, bgcolor = color.new(color.black, 90))

if barstate.islast
    float tol_touch = touch_tol_pct / 100.0
    float tol_mid   = break_tol_mid_pct / 100.0
    float tol_end   = break_tol_end_pct / 100.0
    float stop_val  = stop_pct / 100.0

    array<int>   raw_ph_idx = array.new<int>()
    array<float> raw_ph_px  = array.new<float>()

    float gain_sum   = 0.0
    int   breaks_n   = 0
    int   lines_n    = 0
    int   live_n     = 0

    // ------------- 1. Swing highs inside the visible range ------------------
    for i = 0 to 4999
        if time[i] < chart.left_visible_bar_time
            break
        if time[i] <= chart.right_visible_bar_time
            bool is_high = true

            for j = 1 to 5
                if i - j >= 0
                    if high[i - j] >= high[i]
                        is_high := false
                if i + j < 5000
                    if high[i + j] >= high[i]
                        is_high := false

            if is_high
                array.push(raw_ph_idx, bar_index - i)
                array.push(raw_ph_px, high[i])

    // ---------------------- 2. Sort oldest to newest ------------------------
    array<int>   ph_idx = array.new<int>()
    array<float> ph_px  = array.new<float>()
    if array.size(raw_ph_idx) > 0
        for i = array.size(raw_ph_idx) - 1 to 0
            array.push(ph_idx, array.get(raw_ph_idx, i))
            array.push(ph_px, array.get(raw_ph_px, i))

    // -------------------------- 3. Wipe the chart ---------------------------
    if array.size(drawn_lines) > 0
        for i = 0 to array.size(drawn_lines) - 1
            line.delete(array.get(drawn_lines, i))
        array.clear(drawn_lines)

    if array.size(drawn_labels) > 0
        for i = 0 to array.size(drawn_labels) - 1
            label.delete(array.get(drawn_labels, i))
        array.clear(drawn_labels)

    // ---------- 4. Falling resistance, broken to the upside -----------------
    int num_ph = math.min(array.size(ph_idx), pivot_limit)
    if num_ph >= 3
        for i = 0 to num_ph - 3
            for j = i + 1 to num_ph - 2
                int   idx1 = array.get(ph_idx, i)
                float p1   = array.get(ph_px, i)
                int   idx2 = array.get(ph_idx, j)
                float p2   = array.get(ph_px, j)

                float m = (f_scale(p2) - f_scale(p1)) / (idx2 - idx1)

                if m < 0
                    float b = f_scale(p1) - (m * idx1)

                    bool         validated  = false
                    array<int>   touch_idx  = array.new<int>()
                    int          last_touch = idx2

                    for k = j + 1 to num_ph - 1
                        int   idx_k = array.get(ph_idx, k)
                        float p_k   = array.get(ph_px, k)

                        float expected = f_unscale((m * idx_k) + b)

                        if math.abs(p_k - expected) <= (expected * tol_touch)
                            validated := true
                            array.push(touch_idx, idx_k)
                            last_touch := idx_k

                    if validated
                        bool broken_early = false
                        for x = idx1 to last_touch
                            int offset = bar_index - x
                            if offset >= 0 and offset < 5000
                                float projection = f_unscale((m * x) + b)
                                if high[offset] > projection * (1 + tol_mid)
                                    broken_early := true
                                    break

                        if not broken_early
                            int end_idx = bar_index
                            for x = last_touch + 1 to bar_index
                                int offset = bar_index - x
                                if offset >= 0 and offset < 5000
                                    float projection = f_unscale((m * x) + b)
                                    if high[offset] > projection * (1 + tol_end)
                                        end_idx := x
                                        break

                            float p_end = f_unscale((m * end_idx) + b)

                            int  idx3     = array.get(touch_idx, 0)
                            bool too_wide = (idx2 - idx1 > max_touch_gap) or (idx3 - idx2 > max_touch_gap)
                            bool too_old  = (end_idx == bar_index) and ((bar_index - idx1) >= fade_bars)
                            bool faded    = too_old or too_wide
                            color col     = faded ? color.new(col_resistance, 80) : col_resistance

                            array.push(drawn_lines, line.new(x1 = idx1, y1 = p1, x2 = end_idx, y2 = p_end, xloc = xloc.bar_index, color = col, width = 2, style = line.style_solid))
                            lines_n += 1

                            if end_idx != bar_index and not faded
                                array.push(drawn_labels, label.new(x = end_idx, y = p_end, text = "", xloc = xloc.bar_index, color = color.new(color.green, 70), style = label.style_triangleup, size = size.tiny))

                                float trigger = p_end * (1 + tol_end)
                                float best    = trigger

                                for x = end_idx to bar_index
                                    int offset = bar_index - x
                                    if offset >= 0 and offset < 5000
                                        if high[offset] > best
                                            best := high[offset]
                                        if low[offset] < trigger * (1 - stop_val)
                                            break

                                float gain_pct = ((best - trigger) / trigger) * 100
                                if gain_pct > 0
                                    array.push(drawn_labels, label.new(x = end_idx, y = trigger, text = "+" + str.tostring(gain_pct, "#.##") + "%", xloc = xloc.bar_index, color = color.new(color.green, 40), textcolor = color.white, style = label.style_label_lower_left, size = size.small))
                                    gain_sum += gain_pct
                                    breaks_n += 1

                            if end_idx == bar_index and not faded
                                live_n += 1

    // ----------------------------- 5. Panel ---------------------------------
    table.clear(panel, 0, 0, 1, 5)

    if show_panel
        float avg_gain = breaks_n > 0 ? gain_sum / breaks_n : 0.0

        table.cell(panel, 0, 0, "BULLISH TRENDLINES", text_color = color.white, text_size = size.small, text_halign = text.align_left, bgcolor = color.new(color.gray, 60))
        table.cell(panel, 1, 0, syminfo.ticker, text_color = color.white, text_size = size.small, bgcolor = color.new(color.gray, 60))

        table.cell(panel, 0, 1, "Lines found", text_color = color.silver, text_size = size.small, text_halign = text.align_left)
        table.cell(panel, 1, 1, str.tostring(lines_n), text_color = color.lime, text_size = size.small)

        table.cell(panel, 0, 2, "Still unbroken", text_color = color.silver, text_size = size.small, text_halign = text.align_left)
        table.cell(panel, 1, 2, str.tostring(live_n), text_color = color.lime, text_size = size.small)

        table.cell(panel, 0, 3, "Risk taken (stop)", text_color = color.silver, text_size = size.small, text_halign = text.align_left)
        table.cell(panel, 1, 3, str.tostring(stop_pct, "#.##") + "%", text_color = color.white, text_size = size.small)

        table.cell(panel, 0, 4, "Avg peak gain (n=" + str.tostring(breaks_n) + ")", text_color = color.silver, text_size = size.small, text_halign = text.align_left)
        table.cell(panel, 1, 4, str.tostring(avg_gain, "#.##") + "%", text_color = color.lime, text_size = size.small)
````
