# MTF Confluence - Timeframe Alignment Statistics [Dots3Red]

- url: https://www.tradingview.com/script/A9ZUm1KH-MTF-Confluence-Timeframe-Alignment-Statistics-Dots3Red/
- type: indicator
- pine_id: PUB;4d598d7a1037462db75075d8929160c2
- version: 1.0

## Description

⏱️ [b]MTF CONFLUENCE - TIMEFRAME ALIGNMENT STATISTICS [Dots3Red][/b]
"Check the higher timeframe for confluence" is standard advice in almost every trading style. What's rarely measured is whether it actually matters on a given chart:
[i]Does price behave differently when all three timeframes agree versus when only one does?[/i]
This script tracks that directly instead of assuming the answer.

✨ [b]WHY THIS MATTERS[/b]
Multi-timeframe alignment is treated as an obvious edge, but "obvious" and "measured" are different things. A trader checking three timeframes by eye still has to decide, in the moment, whether 2-out-of-3 agreement is worth acting on and whether it behaves any differently than full 3-out-of-3 agreement. This script answers that with your own chart's history instead of a guess.

📊 [b]Three alignment tiers, each with its own track record[/b]
Every time your current chart and its two higher timeframes shift into a new combined alignment — 1-out-of-3, 2-out-of-3, or 3-out-of-3 — that specific tier is logged and later graded on whether price actually continued. Over time each tier builds its own independent continuation rate, so you can see whether stronger alignment genuinely performs better here, or whether it doesn't.

⚙️ [b]HOW IT WORKS[/b]
📐 [b]Directional classification per timeframe[/b] — the current chart and two higher timeframes you choose are each classified Bull, Bear, or Neutral, using price relative to a moving average, filtered by ADX so a directionless timeframe isn't forced into a false read.

🔢 [b]Confluence count[/b] — how many of the three timeframes agree with the current chart's direction, shown live as a simple count out of 3.

🎯 [b]Rolling, honest grading[/b] — a new alignment event (the confluence count reaching a new tier in a direction) is logged and only graded once price has either continued a defined distance in that direction or the outcome window has elapsed — never recalculated with hindsight.

🔒 [b]Non-repainting[/b] — every higher-timeframe read and every graded outcome is confirmed-bar only.

🎨 [b]Visual markers[/b] — a label appears at each new alignment event showing the count reached, and the background tints when full 3-out-of-3 alignment is active.

🧭 [b]HOW TO USE[/b]
1️⃣ [b]Let each tier accumulate events before trusting its percentage.[/b] A tier with a low n hasn't said anything meaningful yet — the dashboard shows the sample size next to every percentage for exactly this reason.

2️⃣ [b]Compare the tiers against each other.[/b] The point isn't a single number — it's whether 3/3 alignment actually continues more often than 2/3, or 1/3, on this specific chart. Any pattern (or lack of one) is a real answer.

3️⃣ [b]Read the dashboard for the full picture, the chart markers for the moment.[/b] The table tracks the running statistics across every event this chart has produced; the labels and background tint mark when a new alignment tier is active right now.

4️⃣ [b]Set your two higher timeframes to match your own trading horizon.[/b] A scalper's "higher timeframe" pairing looks nothing like a swing trader's — the statistics are only meaningful when the timeframes you choose reflect how you actually structure trades.

5️⃣ [b]Treat a tier's continuation rate as descriptive, not predictive.[/b] It reflects what has happened historically at that alignment level on this chart — not a guarantee for the next occurrence.

⏱️ [b]WHICH TIMEFRAMES WORK BEST[/b]
Applies to the current chart's timeframe generally, with [b]15-minute through 4-hour[/b] as the base chart giving the best balance — frequent enough for alignment events to recur and build a meaningful sample, while each event still reflects settled price behavior. The two higher timeframes should sit meaningfully above your base chart (e.g. 1H and 4H above a 15m chart, or 4H and Daily above a 1H chart) for the confluence read to add real information rather than three highly correlated copies of the same short-term move.

🛠️ [b]SETTINGS[/b]
⏱️ [b]Timeframes[/b] — two independently configurable higher timeframes

📐 [b]Classification[/b] — trend MA length (applied uniformly across all three timeframes), ADX length, minimum ADX for a directional read

🎯 [b]Outcome Grading[/b] — continuation confirmation distance (×ATR), outcome window (bars)

🎨 [b]Visualization[/b] — alignment change labels, background tint at full alignment, independent bullish/bearish colors

🖥️ [b]Dashboard[/b] — show/hide, position — each timeframe's current direction, live confluence count, per-tier continuation rate and sample size, total logged events

📝 [b]NOTES[/b]
The statistics shown are specific to this chart, this timeframe combination, and these settings — they do not transfer to other instruments or timeframe pairings. The goal isn't to assert that more alignment is always better, but to replace that assumption with a measured answer for the setup you're actually trading.

⚠️ [b]DISCLAIMER[/b]
This is an analytical and visualization tool. It does not generate trade signals and does not constitute financial advice. Historical statistics do not guarantee future performance.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Dots3Red
// TradingView: https://www.tradingview.com/u/Dots3Red/

//@version=6
indicator("MTF Confluence - Timeframe Alignment Statistics [Dots3Red]",
          shorttitle = "MTF Confluence [D3R]",
          overlay    = true,
          max_labels_count = 500)

// COLORS
C_BULL    = color.new(#39ff14, 0)
C_BEAR    = color.new(#ff003c, 0)
C_GREEN   = color.new(#00c896, 0)
C_RED     = color.new(#ff4466, 0)
C_AMBER   = color.new(#ffb700, 0)
C_NEUTRAL = color.new(#64748b, 0)
C_BG      = color.new(#131722, 5)
C_TXT     = color.new(#f8fafc, 0)
C_DIM     = color.new(#94a3b8, 0)
C_BORD    = color.new(#334155, 0)
C_BAR     = color.new(#b2b5be,0)


// INPUTS
GRP_TF  = "⏱️ Timeframes"
GRP_CLS = "📐 Classification"
GRP_ST  = "🎯 Outcome Grading"
GRP_VIS = "🎨 Visualization"
GRP_HUD = "🖥️ Dashboard"

htf1 = input.timeframe("60",  "Higher Timeframe 1", group=GRP_TF)
htf2 = input.timeframe("240", "Higher Timeframe 2", group=GRP_TF)

ma_len   = input.int(50, "Trend MA Length", minval=10, group=GRP_CLS,
           tooltip="Same MA length is applied on the current chart and both higher timeframes.")
adx_len  = input.int(14, "ADX Length", minval=5, group=GRP_CLS)
adx_min  = input.float(20.0, "Min ADX for a Directional Read", minval=10.0, maxval=40.0, step=1.0, group=GRP_CLS,
           tooltip="Below this ADX, a timeframe is classified Neutral rather than forced into a direction.")

outcome_atr  = input.float(1.5, "Continuation Confirmation (×ATR)", minval=0.3, maxval=5.0, step=0.1, group=GRP_ST,
              tooltip="Price must move this far in the aligned direction to grade the tier as continued.")
outcome_bars = input.int(15, "Outcome Window (bars)", minval=5, maxval=100, group=GRP_ST)

show_labels = input.bool(true, "Alignment Change Labels", group=GRP_VIS)
show_bg     = input.bool(true, "Background Tint at Full Alignment", group=GRP_VIS)
use_bars = input.bool(false, "Use Bars", group=GRP_VIS)
lbl_size = input.int(10, "Label Size", minval=3, maxval=12, group=GRP_VIS)


col_bull = input.color(#39ff14, "Bullish Alignment", group=GRP_VIS)
col_bear = input.color(#ff003c, "Bearish Alignment", group=GRP_VIS)

show_hud = input.bool(true, "Show Dashboard", group=GRP_HUD)
hud_pos  = input.string("Top Right", "Position",
           options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=GRP_HUD)


f_classify(float src, float ma, int adxv) =>
    src > ma and adxv >= adx_min ? 1 : src < ma and adxv >= adx_min ? -1 : 0

ma_cur = ta.sma(close, ma_len)
[_, _, adx_cur] = ta.dmi(adx_len, adx_len)
int dir_cur = f_classify(close, ma_cur, math.round(adx_cur))

f_htf_dir(string tf) =>
    float c  = request.security(syminfo.tickerid, tf, close, lookahead=barmerge.lookahead_off)
    float ma = request.security(syminfo.tickerid, tf, ta.sma(close, ma_len), lookahead=barmerge.lookahead_off)
    [_dp, _dm, adxv] = request.security(syminfo.tickerid, tf, ta.dmi(adx_len, adx_len), lookahead=barmerge.lookahead_off)
    f_classify(c, ma, math.round(adxv))

int dir_htf1 = f_htf_dir(htf1)
int dir_htf2 = f_htf_dir(htf2)


int bull_agree = (dir_cur == 1 ? 1 : 0) + (dir_htf1 == 1 ? 1 : 0) + (dir_htf2 == 1 ? 1 : 0)
int bear_agree = (dir_cur == -1 ? 1 : 0) + (dir_htf1 == -1 ? 1 : 0) + (dir_htf2 == -1 ? 1 : 0)

int   confluence   = dir_cur == 1 ? bull_agree : dir_cur == -1 ? bear_agree : 0
int   align_dir    = dir_cur
color align_col    = align_dir == 1 ? col_bull : align_dir == -1 ? col_bear : C_NEUTRAL


atr_raw = ta.atr(14)

var int   pend_bar  = na
var float pend_price = na
var int   pend_dir   = na
var int   pend_tier  = na    // 1, 2, or 3

var int[] tier_total     = array.new<int>(3, 0)
var int[] tier_continued = array.new<int>(3, 0)

bool new_alignment_event = false

if barstate.isconfirmed

    if not na(pend_bar)
        bool cont = pend_dir == 1 ? (close - pend_price) >= outcome_atr * atr_raw
                                   : (pend_price - close) >= outcome_atr * atr_raw
        bool timed = (bar_index - pend_bar) >= outcome_bars
        if cont or timed
            int ti = pend_tier - 1
            array.set(tier_total, ti, array.get(tier_total, ti) + 1)
            if cont
                array.set(tier_continued, ti, array.get(tier_continued, ti) + 1)
            pend_bar := na

    bool tier_changed = confluence != confluence[1] or align_dir != align_dir[1]
    if confluence >= 1 and tier_changed and na(pend_bar)
        pend_bar   := bar_index
        pend_price := close
        pend_dir   := align_dir
        pend_tier  := confluence
        new_alignment_event := true
        if show_labels
            label.new(bar_index, align_dir == 1 ? low : high,
                      (align_dir == 1 ? "▲ " : "▼ ") + str.tostring(confluence) + "/3",
                      style = align_dir == 1 ? label.style_label_up : label.style_label_down,
                      color=color.new(align_col, 82),
                      textcolor=align_col, size=lbl_size)


// VISUALS
bgcolor(show_bg and confluence == 3 ? color.new(align_col, 90) : na)


// DASHBOARD
f_hud_pos(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        =>                position.bottom_left

f_dir_str(int d) =>
    d == 1 ? "▲ Bull" : d == -1 ? "▼ Bear" : "— Neutral"
f_dir_col(int d) =>
    d == 1 ? col_bull : d == -1 ? col_bear : C_NEUTRAL

var table hud = table.new(f_hud_pos(hud_pos), 2, 9,
                           bgcolor=C_BG, border_color=C_BORD,
                           border_width=1, frame_color=C_BORD, frame_width=2)

if show_hud and barstate.islast
    table.cell(hud, 0, 0, "MTF CONFLUENCE [D3R]", text_color=C_TXT,
               bgcolor=color.new(#1e293b, 0), text_size=11, text_halign=text.align_center)
    table.merge_cells(hud, 0, 0, 1, 0)

    table.cell(hud, 0, 1, "Current TF", text_color=C_DIM, bgcolor=color.new(#1e293b, 40), text_size=11)
    table.cell(hud, 1, 1, f_dir_str(dir_cur), text_color=f_dir_col(dir_cur), bgcolor=color.new(#1e293b, 40), text_size=11, text_halign=text.align_center)

    table.cell(hud, 0, 2, htf1, text_color=C_DIM, bgcolor=color.new(#0f172a, 40), text_size=11)
    table.cell(hud, 1, 2, f_dir_str(dir_htf1), text_color=f_dir_col(dir_htf1), bgcolor=color.new(#0f172a, 40), text_size=11, text_halign=text.align_center)

    table.cell(hud, 0, 3, htf2, text_color=C_DIM, bgcolor=color.new(#1e293b, 40), text_size=11)
    table.cell(hud, 1, 3, f_dir_str(dir_htf2), text_color=f_dir_col(dir_htf2), bgcolor=color.new(#1e293b, 40), text_size=11, text_halign=text.align_center)

    table.cell(hud, 0, 4, "Confluence", text_color=C_DIM, bgcolor=color.new(#0f172a, 0), text_size=11, text_halign=text.align_center)
    table.cell(hud, 1, 4, str.tostring(confluence) + "/3", text_color=align_col, bgcolor=color.new(#0f172a, 0), text_size=11, text_halign=text.align_center)

    for i = 0 to 2
        int t = array.get(tier_total, i)
        int c = array.get(tier_continued, i)
        string rowval = t > 0 ? str.tostring(math.round(float(c) / float(t) * 100.0)) + "% (n=" + str.tostring(t) + ")" : "—"
        color rc = t == 0 ? C_DIM : float(c) / float(t) >= 0.5 ? C_GREEN : C_RED
        table.cell(hud, 0, 5 + i, str.tostring(i + 1) + "/3 aligned", text_color=C_DIM,
                   bgcolor=color.new(i % 2 == 0 ? #1e293b : #0f172a, 40), text_size=11)
        table.cell(hud, 1, 5 + i, rowval, text_color=rc,
                   bgcolor=color.new(i % 2 == 0 ? #1e293b : #0f172a, 40), text_size=11, text_halign=text.align_center)

    int gt = array.get(tier_total,0) + array.get(tier_total,1) + array.get(tier_total,2)
    table.cell(hud, 0, 8, "Total Events", text_color=C_DIM, bgcolor=color.new(#1e293b, 40), text_size=11)
    table.cell(hud, 1, 8, str.tostring(gt), text_color=C_TXT, bgcolor=color.new(#1e293b, 40), text_size=11, text_halign=text.align_center)

barcolor(use_bars ? C_BAR : na)

// ALERTS
bool full_align_bull = confluence == 3 and align_dir == 1 and new_alignment_event
bool full_align_bear = confluence == 3 and align_dir == -1 and new_alignment_event
alertcondition(full_align_bull, "Full Bullish Alignment", "D3R MTF Confluence: all 3 timeframes now aligned bullish")
alertcondition(full_align_bear, "Full Bearish Alignment", "D3R MTF Confluence: all 3 timeframes now aligned bearish")
````
