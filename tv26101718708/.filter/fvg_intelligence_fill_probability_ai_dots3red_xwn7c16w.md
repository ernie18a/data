# FVG Intelligence - Fill Probability AI [Dots3Red]

- url: https://www.tradingview.com/script/Xwn7C16w-FVG-Intelligence-Fill-Probability-AI-Dots3Red/
- type: indicator
- pine_id: PUB;341b0b4d719e4d18b847647242788559
- version: 1.0

## Description

📦 [b]FVG INTELLIGENCE - FILL PROBABILITY AI [Dots3Red]
[/b]Every Fair Value Gap tool draws the gap. None of them tell you what usually happens to it. This script keeps records instead — every gap that appears on your chart is tracked all the way to its resolution, and when a new one forms, the script reports what the most similar past gaps on this chart actually did.

✨ [b]WHY THIS MATTERS[/b]
"Gaps get filled" is one of the most repeated assumptions in SMC trading — but it's rarely checked against the actual chart in front of you. Some instruments fill gaps quickly and reliably. Others leave them open for a long time, or never fill them at all. A gap formed on heavy volume during a strong trend behaves differently than one formed on quiet, choppy conditions.

This script doesn't assume any of that. It measures it. Every gap that resolves — filled or expired — becomes a data point: how big it was, what volume looked like when it formed, how volatile the market was, and where price sat relative to trend. When the next gap appears, the script finds the most similar historical gaps and reports their real outcomes.

📊 [i]Fill 74% | ~6 bars | N=52[/i][b][/b]
That reads as: of the 52 most similar gaps this chart has produced, 74% filled, taking about 6 bars on average. Measured history, not an assumption that "gaps always fill."


⚙️ [b]HOW IT WORKS[/b]
📦 [b]Detection[/b] — the standard 3-bar imbalance definition: a bullish gap exists when the current low sits above the high from two bars back, leaving an untraded price zone between them. Bearish gaps are the mirror. A minimum size filter (in ATR) discards micro-imbalances too small to carry real information.

🧠 [b]The KNN engine[/b] — every gap is stored as five measurements the moment it forms: direction, size relative to ATR, volume behavior, volatility context, and position relative to the trend. When the gap resolves, the actual outcome — filled or not, and how many bars it took — is recorded against those five measurements. A brand-new gap is compared against this stored history, and the K most similar past gaps vote on fill probability and expected duration.

🎯 [b]Fill definition[/b] — a gap counts as filled when price fully traverses it, reaching the far edge. This is the strictest standard (some traders count a midpoint touch as "filled" too) — deliberately conservative so the statistics mean exactly what they say.

📐 [b]Near edge vs. far edge[/b] — each gap is drawn with two distinct boundaries. The edge price actually returns to first (the "near" edge) is shown with a solid line; the origin edge (the "far" edge, the one that defines a full fill) is shown dashed and dimmer. The fill inside fades from strongest near the solid edge to faintest near the dashed one, visually encoding which boundary carries more weight.

🔒 [b]Non-repainting[/b] — detection, fill-checking, and outcome grading all happen strictly on confirmed bars. A gap's KNN read is calculated once, at the moment it forms, and its label stays fixed at that spot — it does not shift, recalculate, or repaint as the chart moves forward.


🧭 [b]HOW TO USE[/b]
1️⃣ [b]Check the sample count before trusting the percentage.[/b] "Fill 74% | N=52" is a real pattern; "Fill 74% | N=6" could easily be noise. The label always shows N so you can judge for yourself — the script won't display a probability at all until enough history exists ("Training…" appears instead).

2️⃣ [b]Use the average bars figure as a timing expectation, not a countdown.[/b] "~6 bars" is the mean of gaps that did fill — it tells you the typical pace, not a guaranteed deadline for this specific gap.

3️⃣ [b]Read the near/far edge distinction on the chart itself.[/b] The solid line is the boundary price will most likely interact with first; the dashed line is what a genuine full fill requires. A gap that's touched its solid edge but not yet reached the dashed one is still open, by this script's strict definition.

4️⃣ [b]Watch the dashboard's global fill rate for chart-level context.[/b] Beyond any single gap, it tracks what percentage of every recorded gap on this chart has filled overall — useful for gauging whether this instrument tends to leave gaps open or close them reliably.

5️⃣ [b]Adjust the fill window to the timeframe.[/b] A 30-bar window means something very different on a 1-minute chart versus a daily chart — tune it so "expired unfilled" reflects a genuinely meaningful amount of time for what you're trading.


🛠️ [b]SETTINGS[/b]
📦 [b]FVG Detection[/b]
• Min Gap Size — smallest imbalance the script will bother tracking
• Fill Window — bars allowed for a gap to fill before it's graded as expired
• Max Gaps Shown — how many open/recent gaps stay on the chart at once

📊 [b]KNN Engine[/b]
• K Neighbors — how many similar past gaps vote on the current one
• Max / Min Training Samples — memory cap and the minimum before probabilities display
• ATR Baseline Period, Trend MA Length — the context windows used in matching

🎨 [b]Visualization[/b]
• Keep Filled Gaps Visible — leave resolved gaps on the chart as faint gray outlines, or clear them for a cleaner view
• KNN Labels on Gaps — toggle the fill-probability readout
• Box Extension — how far each gap's zone projects forward while still open

🖥️ [b]Dashboard[/b]
• Show/hide, position — open gap count by direction, chart-wide fill rate, KNN training progress, and the active fill window


📝 [b]NOTES[/b]
Gap frequency and fill behavior vary significantly by instrument, timeframe, and market conditions — a volatile, fast-moving asset will accumulate the sample size needed for meaningful probabilities much faster than a slow, quiet one. On a new chart, expect a number of gaps to pass before the KNN read becomes genuinely informative rather than a placeholder.


⚠️ [b]DISCLAIMER[/b]
This is an analytical and visualization tool. It does not generate trade signals and does not constitute financial advice. Historical fill rates do not guarantee how any specific future gap will resolve.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Dots3Red
// TradingView: https://www.tradingview.com/u/Dots3Red/

//@version=6
indicator("FVG Intelligence - Fill Probability AI [Dots3Red]",
          shorttitle = "FVG AI [D3R]",
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

//cyber
C_CYBER_BULL_BG     = color.new(#00ffcc, 85) // Box fill (translucent)
C_CYBER_BULL_BORDER = color.new(#00ffcc, 20) // Glowing border
C_BAR = #b2b5be
C_CYBER_BEAR_BG     = color.new(#ff007f, 85) // Box fill (translucent)
C_CYBER_BEAR_BORDER = color.new(#ff007f, 20) // Glowing border


// INPUTS
GRP_FVG = "📦 FVG Detection"
GRP_KNN = "📊 KNN Engine"
GRP_VIS = "🎨 Visualization"
GRP_HUD = "🖥️ Dashboard"

min_gap_atr  = input.float(0.3, "Min Gap Size (×ATR)", minval=0.05, maxval=3.0, step=0.05, group=GRP_FVG,
               tooltip="Gaps smaller than this are ignored — micro-imbalances carry little information.")
outcome_bars = input.int(30, "Fill Window (bars)", minval=5, maxval=200, group=GRP_FVG,
               tooltip="Bars after creation within which a gap must fill to count as filled. Beyond this it grades as unfilled.")
max_tracked  = input.int(30, "Max Gaps Shown", minval=5, maxval=100, group=GRP_FVG)

knn_k         = input.int(15,  "K Neighbors",          minval=3, maxval=50, group=GRP_KNN)
knn_max_train = input.int(400, "Max Training Samples", minval=30, maxval=1000, group=GRP_KNN)
knn_min_train = input.int(15,  "Min Samples Before Display", minval=5, maxval=100, group=GRP_KNN)
atr_base_len  = input.int(50,  "ATR Baseline Period",  minval=10, group=GRP_KNN)
ma_len        = input.int(50,  "Trend MA Length",      minval=10, group=GRP_KNN)

show_filled   = input.bool(false, "Keep Filled Gaps Visible", group=GRP_VIS,
               tooltip="ON: filled gaps stay as faint outlines. OFF: filled gaps are removed, keeping the chart clean.")
show_labels   = input.bool(true, "KNN Labels on Gaps", group=GRP_VIS)
box_extend    = input.int(15, "Box Extension (bars)", minval=3, maxval=100, group=GRP_VIS)

show_hud = input.bool(true, "Show Dashboard", group=GRP_HUD)
hud_pos  = input.string("Top Right", "Position",
           options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=GRP_HUD)
colorBarsToGray = input.bool(false, "Color Bars to Gray", group=GRP_HUD)


// CORE SERIES
atr_raw     = ta.atr(14)
atr_base_ma = ta.sma(atr_raw, atr_base_len)
atr_ratio   = atr_raw / math.max(atr_base_ma, 1e-9)
vol_ma      = ta.sma(volume, 20)
vol_ratio   = vol_ma > 0 ? volume / vol_ma : 1.0
trend_ma    = ta.sma(close, ma_len)
price_vs_ma = (close - trend_ma) / math.max(atr_raw, 1e-9)


// KNN STORAGE
// [is_bull, gap_atr_norm, vol_ratio_norm, atr_ratio_norm, trend_pos_norm]
int KNN_STRIDE = 5
var float[] kf        = array.new<float>()
var float[] ko_filled = array.new<float>()
var float[] ko_bars   = array.new<float>()

f_feat(bool is_bull, float gap_atr, float vr, float ar, float tp) =>
    float f1 = is_bull ? 1.0 : 0.0
    float f2 = math.min(1.0, gap_atr / 3.0)
    float f3 = math.min(1.0, vr / 3.0)
    float f4 = math.min(1.0, ar / 3.0)
    float f5 = math.max(-1.0, math.min(1.0, tp / 3.0))
    [f1, f2, f3, f4, f5]

f_knn_push(float f1, float f2, float f3, float f4, float f5, float o_fill, float o_bars) =>
    array.push(kf, f1)
    array.push(kf, f2)
    array.push(kf, f3)
    array.push(kf, f4)
    array.push(kf, f5)
    array.push(ko_filled, o_fill)
    array.push(ko_bars,   o_bars)
    if array.size(ko_filled) > knn_max_train
        for _i = 0 to KNN_STRIDE - 1
            array.shift(kf)
        array.shift(ko_filled)
        array.shift(ko_bars)

f_knn_query(float f1, float f2, float f3, float f4, float f5) =>
    int   n        = array.size(ko_filled)
    int   ku       = math.min(knn_k, n)
    float fill_pct = 50.0
    float avg_bars = 0.0
    if n >= knn_min_train
        float[] ds = array.new<float>(n, 0.0)
        for i = 0 to n - 1
            int b = i * KNN_STRIDE
            float d = 0.0
            d += math.pow(array.get(kf, b)     - f1, 2.0)
            d += math.pow(array.get(kf, b + 1) - f2, 2.0)
            d += math.pow(array.get(kf, b + 2) - f3, 2.0)
            d += math.pow(array.get(kf, b + 3) - f4, 2.0)
            d += math.pow(array.get(kf, b + 4) - f5, 2.0)
            array.set(ds, i, math.sqrt(d))
        float[] dc = array.copy(ds)
        int[]   ix = array.new<int>(n, 0)
        for i = 0 to n - 1
            array.set(ix, i, i)
        float s_fill = 0.0
        float s_bars = 0.0
        int   n_fill = 0
        for k = 0 to ku - 1
            int mp = k
            float mv = array.get(dc, k)
            if k + 1 <= n - 1
                for j = k + 1 to n - 1
                    v = array.get(dc, j)
                    if v < mv
                        mv := v
                        mp := j
            float td = array.get(dc, k)
            array.set(dc, k, array.get(dc, mp))
            array.set(dc, mp, td)
            int ti = array.get(ix, k)
            array.set(ix, k, array.get(ix, mp))
            array.set(ix, mp, ti)
            ni = array.get(ix, k)
            float fv = array.get(ko_filled, ni)
            s_fill += fv
            if fv > 0.5
                s_bars += array.get(ko_bars, ni)
                n_fill += 1
        fill_pct := (s_fill / float(ku)) * 100.0
        avg_bars := n_fill > 0 ? s_bars / float(n_fill) : 0.0
    [fill_pct, avg_bars, n]


// FVG TYPE
type FVG
    bool  is_bull
    int   born_bar
    float top
    float bottom
    int   state
    float f1
    float f2
    float f3
    float f4
    float f5
    box   fade1
    box   fade2
    box   fade3
    box   fade4
    label lbl
    line  ln_top
    line  ln_bot

var FVG[] gaps = array.new<FVG>()

var int g_total   = 0
var int g_filled  = 0

f_gap_label(FVG g, float fill_pct, float avg_bars, int n) =>
    if not na(g.lbl)
        label.delete(g.lbl)
    string s = na
    if n >= knn_min_train
        s := "Fill " + str.tostring(math.round(fill_pct)) + "%"
        s := s + " | ~" + str.tostring(math.round(avg_bars)) + " bars"
        s := s + " | N=" + str.tostring(n)
    else
        s := "Training… (" + str.tostring(n) + "/" + str.tostring(knn_min_train) + ")"
    float y = (g.top + g.bottom) / 2.0
    g.lbl := label.new(bar_index , y, s,
                       style=label.style_label_left,
                       color=color.new(#000000, 100),
                       textcolor=g.is_bull ? C_GREEN : C_RED,
                       size=size.small)
    g


f_make_fades(bool is_bull, float top, float bottom, int x1, int x2, color c) =>
    float h = (top - bottom) / 4.0
    box b1 = na
    box b2 = na
    box b3 = na
    box b4 = na
    if is_bull
        b1 := box.new(x1, top,          x2, top - h,       border_color=color.new(c, 100), bgcolor=color.new(C_CYBER_BULL_BG, 65))
        b2 := box.new(x1, top - h,      x2, top - 2 * h,   border_color=color.new(c, 100), bgcolor=color.new(C_CYBER_BULL_BG, 78))
        b3 := box.new(x1, top - 2 * h,  x2, top - 3 * h,   border_color=color.new(c, 100), bgcolor=color.new(C_CYBER_BULL_BG, 88))
        b4 := box.new(x1, top - 3 * h,  x2, bottom,        border_color=color.new(c, 100), bgcolor=color.new(C_CYBER_BULL_BG, 95))
    else
        b1 := box.new(x1, bottom + h,       x2, bottom,          border_color=color.new(c, 100), bgcolor=color.new(C_CYBER_BEAR_BG, 65))
        b2 := box.new(x1, bottom + 2 * h,   x2, bottom + h,      border_color=color.new(c, 100), bgcolor=color.new(C_CYBER_BEAR_BG, 78))
        b3 := box.new(x1, bottom + 3 * h,   x2, bottom + 2 * h,  border_color=color.new(c, 100), bgcolor=color.new(C_CYBER_BEAR_BG, 88))
        b4 := box.new(x1, top,              x2, bottom + 3 * h,  border_color=color.new(c, 100), bgcolor=color.new(C_CYBER_BEAR_BG, 95))
    [b1, b2, b3, b4]

f_extend_fades(box b1, box b2, box b3, box b4, int x2) =>
    if not na(b1)
        box.set_right(b1, x2)
    if not na(b2)
        box.set_right(b2, x2)
    if not na(b3)
        box.set_right(b3, x2)
    if not na(b4)
        box.set_right(b4, x2)

f_delete_fades(box b1, box b2, box b3, box b4) =>
    if not na(b1)
        box.delete(b1)
    if not na(b2)
        box.delete(b2)
    if not na(b3)
        box.delete(b3)
    if not na(b4)
        box.delete(b4)

f_gray_fades(box b1, box b2, box b3, box b4) =>
    if not na(b1)
        box.set_bgcolor(b1, color.new(C_NEUTRAL, 92))
    if not na(b2)
        box.set_bgcolor(b2, color.new(C_NEUTRAL, 93))
    if not na(b3)
        box.set_bgcolor(b3, color.new(C_NEUTRAL, 95))
    if not na(b4)
        box.set_bgcolor(b4, color.new(C_NEUTRAL, 97))


// MAIN LOOP
bool new_bull_fvg = false
bool new_bear_fvg = false
bool any_fill     = false

if barstate.isconfirmed

    // DETECT NEW FVG (classic 3-bar imbalance) 
    float gap_bull = low - high[2]
    float gap_bear = low[2] - high

    if gap_bull > min_gap_atr * atr_raw
        [f1, f2, f3, f4, f5] = f_feat(true, gap_bull / math.max(atr_raw, 1e-9), vol_ratio, atr_ratio, price_vs_ma)
        [b1, b2, b3, b4] = f_make_fades(true, low, high[2], bar_index - 2, bar_index + box_extend, C_BULL)
        FVG g = FVG.new(true, bar_index, low, high[2], 0, f1, f2, f3, f4, f5, b1, b2, b3, b4, na, na, na)
        g.ln_top := line.new(bar_index - 2, g.top, bar_index + box_extend, g.top,
                             color=color.new(C_CYBER_BULL_BORDER, 0), width=1)
        g.ln_bot := line.new(bar_index - 2, g.bottom, bar_index + box_extend, g.bottom,
                             color=color.new(C_CYBER_BULL_BORDER, 60), width=1, style=line.style_dashed)
        if show_labels
            [fp, ab, n] = f_knn_query(f1, f2, f3, f4, f5)
            g := f_gap_label(g, fp, ab, n)
        array.push(gaps, g)
        new_bull_fvg := true

    if gap_bear > min_gap_atr * atr_raw
        [f1, f2, f3, f4, f5] = f_feat(false, gap_bear / math.max(atr_raw, 1e-9), vol_ratio, atr_ratio, price_vs_ma)
        [b1, b2, b3, b4] = f_make_fades(false, high, low[2], bar_index - 2, bar_index + box_extend, C_BEAR)
        FVG g = FVG.new(false, bar_index, low[2], high, 0, f1, f2, f3, f4, f5, b1, b2, b3, b4, na, na, na)
        g.ln_bot := line.new(bar_index - 2, g.bottom, bar_index + box_extend, g.bottom,
                             color=color.new(C_CYBER_BEAR_BORDER, 0), width=1)
        g.ln_top := line.new(bar_index - 2, g.top, bar_index + box_extend, g.top,
                             color=color.new(C_CYBER_BEAR_BORDER, 60), width=1, style=line.style_dashed)
        if show_labels
            [fp, ab, n] = f_knn_query(f1, f2, f3, f4, f5)
            g := f_gap_label(g, fp, ab, n)
        array.push(gaps, g)
        new_bear_fvg := true

    // TRACK OPEN GAPS: fill / expire 
    if array.size(gaps) > 0
        for i = 0 to array.size(gaps) - 1
            FVG g = array.get(gaps, i)
            if g.state == 0
                int age = bar_index - g.born_bar
                bool filled = g.is_bull ? low <= g.bottom : high >= g.top

                if filled
                    g.state := 1
                    g_total  += 1
                    g_filled += 1
                    any_fill := true
                    f_knn_push(g.f1, g.f2, g.f3, g.f4, g.f5, 1.0, float(age))
                    if not na(g.lbl)
                        label.delete(g.lbl)
                        g.lbl := na
                    if show_filled
                        f_gray_fades(g.fade1, g.fade2, g.fade3, g.fade4)
                        f_extend_fades(g.fade1, g.fade2, g.fade3, g.fade4, bar_index)
                        if not na(g.ln_top)
                            line.set_color(g.ln_top, color.new(C_NEUTRAL, 80))
                            line.set_x2(g.ln_top, bar_index)
                        if not na(g.ln_bot)
                            line.set_color(g.ln_bot, color.new(C_NEUTRAL, 80))
                            line.set_x2(g.ln_bot, bar_index)
                    else
                        f_delete_fades(g.fade1, g.fade2, g.fade3, g.fade4)
                        g.fade1 := na
                        g.fade2 := na
                        g.fade3 := na
                        g.fade4 := na
                        if not na(g.ln_top)
                            line.delete(g.ln_top)
                            g.ln_top := na
                        if not na(g.ln_bot)
                            line.delete(g.ln_bot)
                            g.ln_bot := na
                else if age >= outcome_bars
                    g.state := 2
                    g_total += 1
                    f_knn_push(g.f1, g.f2, g.f3, g.f4, g.f5, 0.0, float(outcome_bars))
                    f_extend_fades(g.fade1, g.fade2, g.fade3, g.fade4, bar_index)
                    if not na(g.ln_top)
                        line.set_x2(g.ln_top, bar_index)
                    if not na(g.ln_bot)
                        line.set_x2(g.ln_bot, bar_index)
                else
                    f_extend_fades(g.fade1, g.fade2, g.fade3, g.fade4, bar_index + box_extend)
                    if not na(g.ln_top)
                        line.set_x2(g.ln_top, bar_index + box_extend)
                    if not na(g.ln_bot)
                        line.set_x2(g.ln_bot, bar_index + box_extend)
                    //if not na(g.lbl)
                    //    label.set_x(g.lbl, bar_index + box_extend + 1)
                array.set(gaps, i, g)

    while array.size(gaps) > max_tracked
        FVG old = array.shift(gaps)
        f_delete_fades(old.fade1, old.fade2, old.fade3, old.fade4)
        if not na(old.lbl)
            label.delete(old.lbl)
        if not na(old.ln_top)
            line.delete(old.ln_top)
        if not na(old.ln_bot)
            line.delete(old.ln_bot)


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
    table.cell(hud, 0, 0, "FVG AI [D3R]", text_color=C_TXT,
               bgcolor=color.new(#1e293b, 0), text_size=11, text_halign=text.align_center)
    table.merge_cells(hud, 0, 0, 1, 0)

    int n_open = 0
    int n_bull = 0
    int n_bear = 0
    if array.size(gaps) > 0
        for _i = 0 to array.size(gaps) - 1
            FVG _g = array.get(gaps, _i)
            if _g.state == 0
                n_open += 1
                if _g.is_bull
                    n_bull += 1
                else
                    n_bear += 1

    table.cell(hud, 0, 1, "Open Gaps", text_color=C_DIM, bgcolor=color.new(#1e293b, 40), text_size=11)
    table.cell(hud, 1, 1, str.tostring(n_open) + "  (▲" + str.tostring(n_bull) + " ▼" + str.tostring(n_bear) + ")",
               text_color=C_TXT, bgcolor=color.new(#1e293b, 40),
               text_size=11, text_halign=text.align_center)

    float g_rate = g_total > 0 ? float(g_filled) / float(g_total) * 100.0 : na
    table.cell(hud, 0, 2, "Fill Rate", text_color=C_DIM, bgcolor=color.new(#0f172a, 40), text_size=11)
    table.cell(hud, 1, 2, na(g_rate) ? "—" : str.tostring(math.round(g_rate)) + "%  (n=" + str.tostring(g_total) + ")",
               text_color=na(g_rate) ? C_DIM : g_rate >= 50 ? C_GREEN : C_AMBER,
               bgcolor=color.new(#0f172a, 40), text_size=11, text_halign=text.align_center)

    int n_train = array.size(ko_filled)
    table.cell(hud, 0, 3, "KNN Samples", text_color=C_DIM, bgcolor=color.new(#1e293b, 40), text_size=11)
    table.cell(hud, 1, 3, str.tostring(n_train) + " / " + str.tostring(knn_max_train),
               text_color=n_train >= knn_min_train ? C_GREEN : C_AMBER,
               bgcolor=color.new(#1e293b, 40), text_size=11, text_halign=text.align_center)

    table.cell(hud, 0, 4, "Fill Window", text_color=C_DIM, bgcolor=color.new(#0f172a, 40), text_size=11)
    table.cell(hud, 1, 4, str.tostring(outcome_bars) + " bars",
               text_color=C_DIM, bgcolor=color.new(#0f172a, 40),
               text_size=11, text_halign=text.align_center)


alertcondition(new_bull_fvg, "New Bull FVG", "D3R FVG AI: new bullish fair value gap — check fill probability label")
alertcondition(new_bear_fvg, "New Bear FVG", "D3R FVG AI: new bearish fair value gap — check fill probability label")
alertcondition(any_fill,     "FVG Filled",   "D3R FVG AI: a fair value gap was just filled")

barcolor(colorBarsToGray ? C_BAR:na)
````
