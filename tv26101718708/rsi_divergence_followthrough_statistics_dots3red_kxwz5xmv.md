# RSI Divergence - Follow-Through Statistics [Dots3Red]

- url: https://www.tradingview.com/script/KxWz5Xmv-RSI-Divergence-Follow-Through-Statistics-Dots3Red/
- type: indicator
- pine_id: PUB;ac44bbb6725944f4b8876c5efeefcc1e
- version: 1.0

## Description

🔍 [b]RSI DIVERGENCE - FOLLOW-THROUGH STATISTICS [Dots3Red][/b]
This indicator detects regular (and optionally hidden) RSI divergences using confirmed pivots, and measures how often each type of divergence was followed by a meaningful move in its direction on the current chart, shown as a percentage with the sample size next to it.

✨ [b]WHY THIS MATTERS[/b]
RSI divergence is one of the most searched setups on TradingView, and plenty of tools draw it. Very few say how often a divergence actually led anywhere. On some instruments bullish divergences at lows work well; on others they fail again and again while price keeps grinding lower. This script keeps a running scoreboard per divergence type, so you can see what divergence has been worth on the chart in front of you.

⚙️ [b]HOW IT WORKS[/b]
📐 [b]Pivot-confirmed divergences[/b] — RSI swing lows and highs are found with a left/right pivot lookback. Two consecutive pivots within a configurable distance are compared with price at the same bars:
• Bullish: price lower low, RSI higher low
• Bearish: price higher high, RSI lower high
• Hidden bullish (optional): price higher low, RSI lower low
• Hidden bearish (optional): price lower high, RSI higher high

🎯 [b]Follow-through grading[/b] — from the close of the bar where the divergence is confirmed, each divergence is graded against two levels frozen at that moment:
• Followed through — price moves a set ATR distance in the divergence direction
• Failed — price breaks the pivot that formed the divergence first, or the resolve window runs out
If both happen on the same bar, it counts as failed. If price is already past the pivot at confirmation, it is counted as an immediate failure rather than skipped.

🔒 [b]Non-repainting[/b] — a pivot is only known after the right-side lookback has passed, so every divergence appears that many bars after its second pivot. Once drawn, it never moves or disappears. This delay is the honest cost of confirmation.

📈 [b]Drawn where you look[/b] — divergence lines on the RSI pane and on the price chart, with labels on the price chart showing the type's measured rate. Hidden divergences are drawn dashed.

🖥️ [b]Dashboard on the price chart[/b] — signals and follow-through rate per type, current RSI, and the grading target and window.

🧭 [b]HOW TO USE[/b]
1️⃣ [b]Check the rate before trusting a divergence.[/b] A bullish divergence on a chart where bullish divergences have followed through 60% of the time is very different from one where it's 35%.
2️⃣ [b]Let each type collect enough samples.[/b] Divergences are not frequent, so give the dashboard time, or use a longer chart history.
3️⃣ [b]Tune the target to how you trade.[/b] A larger ATR target asks more of each divergence and usually lowers the rate. Set it close to the move you would actually aim for.
4️⃣ [b]Remember the confirmation delay.[/b] With a right lookback of 5, the divergence appears 5 bars after the turn. Shorter lookbacks react faster but find noisier pivots.
5️⃣ [b]Use it as one piece of context.[/b] The rates describe how divergence has behaved on this chart. They do not predict the next one.

⏱️ [b]WHICH TIMEFRAMES WORK BEST[/b]
[b]15-minute through 4-hour[/b] gives the best balance between enough divergences to build a sample and pivots that reflect real swings. Daily works on instruments with long history.

🛠️ [b]SETTINGS[/b]
📐 [b]RSI[/b] — length, source, overbought and oversold levels
🔍 [b]Divergence Detection[/b] — pivot lookback left/right, min and max bars between pivots, include hidden divergences
🎯 [b]Follow-Through Grading[/b] — ATR length, follow-through target (× ATR), max bars to resolve, minimum samples to show a rate
🎨 [b]Visuals[/b] — RSI line color and thickness, level line color, bullish and bearish colors, divergence line thickness, lines on RSI, lines on price, labels on price
🖥️ [b]Dashboard[/b] — show/hide, position
🔔 [b]Alerts[/b] — bullish, bearish, hidden bullish and hidden bearish divergence confirmed

📝 [b]NOTES[/b]
All rates are specific to this chart, timeframe and settings, and do not transfer to other instruments or configurations. Alerts fire on confirmed bars; setting them to "Once Per Bar Close" matches how the script detects divergences.

⚠️ [b]DISCLAIMER[/b]
This is an analytical and visualization tool. It does not generate trade signals and does not constitute financial advice. Historical statistics do not guarantee future performance.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Dots3Red
// TradingView: https://www.tradingview.com/u/Dots3Red/

//@version=6
indicator("RSI Divergence - Follow-Through Statistics [Dots3Red]",
          shorttitle = "RSI Div Stats [D3R]",
          overlay    = false,
          max_labels_count = 500,
          max_lines_count  = 500)


// COLORS 
C_TXT   = color.new(#f8fafc, 0)
C_DIM   = color.new(#94a3b8, 0)
C_BG    = color.new(#131722, 5)
C_BORD  = color.new(#334155, 0)
C_GOOD  = color.new(#00c896, 0)
C_BAD   = color.new(#ff4466, 0)


// INPUTS
GRP_RSI = "📐 RSI"
GRP_DIV = "🔍 Divergence Detection"
GRP_ENG = "🎯 Follow-Through Grading"
GRP_VIS = "🎨 Visuals"
GRP_HUD = "🖥️ Dashboard"

rsi_len = input.int(14, "RSI Length", minval=2, group=GRP_RSI)
src     = input.source(close, "Source", group=GRP_RSI)
ob_lvl  = input.int(70, "Overbought", minval=50, maxval=100, group=GRP_RSI)
os_lvl  = input.int(30, "Oversold", minval=0, maxval=50, group=GRP_RSI)

lbL         = input.int(5, "Pivot Lookback Left", minval=1, maxval=50, group=GRP_DIV)
lbR         = input.int(5, "Pivot Lookback Right", minval=1, maxval=50, group=GRP_DIV,
              tooltip="A pivot is only confirmed this many bars after it forms, so every divergence appears this many bars after its second pivot. This delay is what makes it non-repainting.")
rng_min     = input.int(5, "Min Bars Between Pivots", minval=1, group=GRP_DIV)
rng_max     = input.int(60, "Max Bars Between Pivots", minval=5, group=GRP_DIV)
show_hidden = input.bool(false, "Include Hidden Divergences", group=GRP_DIV,
              tooltip="Hidden bullish: price higher low, RSI lower low. Hidden bearish: price lower high, RSI higher high. Usually read as trend continuation.")

atr_len = input.int(14, "ATR Length", minval=2, group=GRP_ENG)
tgt_atr = input.float(1.5, "Follow-Through Target (× ATR)", minval=0.2, step=0.1, group=GRP_ENG,
          tooltip="Success = price moves this far from the confirmation close in the divergence direction before breaking the divergence pivot.")
horizon = input.int(20, "Max Bars to Resolve", minval=3, maxval=200, group=GRP_ENG,
          tooltip="A divergence that reaches neither the target nor the pivot within this many bars counts as a failure.")
min_n   = input.int(10, "Min Samples to Show Rate", minval=3, group=GRP_ENG)

rsi_col    = input.color(#f8fafc, "RSI Line Color", group=GRP_VIS)
rsi_w      = input.int(2, "RSI Line Thickness", minval=1, maxval=6, group=GRP_VIS)
lvl_col    = input.color(#64748b, "OB / OS / Mid Line Color", group=GRP_VIS)
col_bull   = input.color(#00f0ff, "Bullish Color", group=GRP_VIS)
col_bear   = input.color(#ff00aa, "Bearish Color", group=GRP_VIS)
div_w      = input.int(2, "Divergence Line Thickness", minval=1, maxval=6, group=GRP_VIS)
show_rsi_l = input.bool(true, "Draw Lines on RSI", group=GRP_VIS)
show_px_l  = input.bool(true, "Draw Lines on Price Chart", group=GRP_VIS)
show_lbl   = input.bool(true, "Labels on Price Chart", group=GRP_VIS)

show_hud = input.bool(true, "Show Dashboard (on price chart)", group=GRP_HUD)
hud_pos  = input.string("Top Right", "Position",
           options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=GRP_HUD)


// RSI + PIVOTS 
float rsi = ta.rsi(src, rsi_len)
float atr = ta.atr(atr_len)
float pl  = ta.pivotlow(rsi, lbL, lbR)
float ph  = ta.pivothigh(rsi, lbL, lbR)
// lowest low / highest high of the bars between the pivot and confirmation,
// used to check whether the pivot was already broken before confirmation
float since_lo = ta.lowest(low, lbR)
float since_hi = ta.highest(high, lbR)


//  GRADING STATE 
// Slots: 0 = bullish regular, 1 = bearish regular,
//        2 = bullish hidden,  3 = bearish hidden
var int[]   p_bar = array.new<int>(4, -1)
var float[] p_tgt = array.new<float>(4, na)
var float[] p_inv = array.new<float>(4, na)
var float[] st_n  = array.new<float>(4, 0.0)
var float[] st_h  = array.new<float>(4, 0.0)

string[] names = array.from("Bull", "Bear", "H Bull", "H Bear")

f_rate(int i) =>
    float n = array.get(st_n, i)
    n >= min_n ? array.get(st_h, i) / n * 100.0 : na

f_rate_txt(int i) =>
    float r = f_rate(i)
    na(r) ? "" : " " + str.tostring(math.round(r)) + "%"


//RESOLVE OPEN DIVERGENCES 
if barstate.isconfirmed
    for i = 0 to 3
        int pb = array.get(p_bar, i)
        if pb >= 0 and bar_index > pb
            bool  bull  = i == 0 or i == 2
            float tg    = array.get(p_tgt, i)
            float iv    = array.get(p_inv, i)
            bool  hit_t = bull ? high >= tg : low <= tg
            bool  hit_s = bull ? low < iv   : high > iv
            bool  timed = bar_index - pb >= horizon
            if hit_t or hit_s or timed
                array.set(st_n, i, array.get(st_n, i) + 1.0)
                if hit_t and not hit_s
                    array.set(st_h, i, array.get(st_h, i) + 1.0)
                array.set(p_bar, i, -1)


f_register(int i, float pivot_px) =>
    if array.get(p_bar, i) < 0
        bool bull = i == 0 or i == 2
        bool already_broken = bull ? (since_lo < pivot_px or close < pivot_px) : (since_hi > pivot_px or close > pivot_px)
        if already_broken
            array.set(st_n, i, array.get(st_n, i) + 1.0)
        else
            array.set(p_bar, i, bar_index)
            array.set(p_tgt, i, bull ? close + tgt_atr * atr : close - tgt_atr * atr)
            array.set(p_inv, i, pivot_px)

f_draw(int b1, float r1, float p1, int b2, float r2, float p2, color c, bool hidden, bool bull, string txt) =>
    line_style = hidden ? line.style_dashed : line.style_solid
    if show_rsi_l
        line.new(b1, r1, b2, r2, color=c, width=div_w, style=line_style)
    if show_px_l
        line.new(b1, p1, b2, p2, color=c, width=div_w, style=line_style, force_overlay=true)
    if show_lbl
        label.new(b2, p2, txt,
                  style     = bull ? label.style_label_up : label.style_label_down,
                  color     = color.new(#000000, 100),
                  textcolor = c,
                  size      = size.small,
                  force_overlay = true)


// DETECTION (confirmed bars only) 
var float pl_r = na
var float pl_p = na
var int   pl_b = na
var float ph_r = na
var float ph_p = na
var int   ph_b = na

bool bull_reg = false
bool bull_hid = false
bool bear_reg = false
bool bear_hid = false

if barstate.isconfirmed and not na(pl)
    int   b = bar_index - lbR
    float r = rsi[lbR]
    float p = low[lbR]
    if not na(pl_b)
        int gap = b - pl_b
        if gap >= rng_min and gap <= rng_max
            if r > pl_r and p < pl_p
                bull_reg := true
                f_register(0, p)
                f_draw(pl_b, pl_r, pl_p, b, r, p, col_bull, false, true, "▲ Bull Div" + f_rate_txt(0))
            else if show_hidden and r < pl_r and p > pl_p
                bull_hid := true
                f_register(2, p)
                f_draw(pl_b, pl_r, pl_p, b, r, p, color.new(col_bull, 30), true, true, "▲ H Bull" + f_rate_txt(2))
    pl_b := b
    pl_r := r
    pl_p := p

if barstate.isconfirmed and not na(ph)
    int   b = bar_index - lbR
    float r = rsi[lbR]
    float p = high[lbR]
    if not na(ph_b)
        int gap = b - ph_b
        if gap >= rng_min and gap <= rng_max
            if r < ph_r and p > ph_p
                bear_reg := true
                f_register(1, p)
                f_draw(ph_b, ph_r, ph_p, b, r, p, col_bear, false, false, "▼ Bear Div" + f_rate_txt(1))
            else if show_hidden and r > ph_r and p < ph_p
                bear_hid := true
                f_register(3, p)
                f_draw(ph_b, ph_r, ph_p, b, r, p, color.new(col_bear, 30), true, false, "▼ H Bear" + f_rate_txt(3))
    ph_b := b
    ph_r := r
    ph_p := p


// RSI PANE 
plot(rsi, "RSI", color=rsi_col, linewidth=rsi_w)
hline(ob_lvl, "Overbought", color=lvl_col, linestyle=hline.style_dashed)
hline(50,     "Midline",    color=lvl_col, linestyle=hline.style_dotted)
hline(os_lvl, "Oversold",   color=lvl_col, linestyle=hline.style_dashed)


//  DASHBOARD 
f_hud_pos(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        =>                position.bottom_left

var table hud = table.new(f_hud_pos(hud_pos), 3, 8,
                          bgcolor=C_BG, border_color=C_BORD,
                          border_width=1, frame_color=C_BORD, frame_width=2,
                          force_overlay=true)

f_type_row(int row, int i, color bg) =>
    bool  enabled = i < 2 or show_hidden
    float n = array.get(st_n, i)
    float r = f_rate(i)
    color c = (i == 0 or i == 2) ? col_bull : col_bear
    table.cell(hud, 0, row, array.get(names, i), text_color = enabled ? c : C_DIM, bgcolor=bg, text_size=11)
    table.cell(hud, 1, row, enabled ? str.tostring(int(n)) : "—", text_color=C_TXT, bgcolor=bg, text_size=11, text_halign=text.align_center)
    table.cell(hud, 2, row, not enabled ? "off" : na(r) ? "Collecting…" : str.tostring(math.round(r)) + "%",
               text_color = not enabled or na(r) ? C_DIM : r >= 55 ? C_GOOD : r <= 45 ? C_BAD : C_TXT,
               bgcolor=bg, text_size=11, text_halign=text.align_center)

if show_hud and barstate.islast
    color bgA = color.new(#1e293b, 40)
    color bgB = color.new(#0f172a, 40)

    table.cell(hud, 0, 0, "RSI DIVERGENCE [D3R]", text_color=C_TXT,
               bgcolor=color.new(#1e293b, 0), text_size=11, text_halign=text.align_center)
    table.merge_cells(hud, 0, 0, 2, 0)

    table.cell(hud, 0, 1, "Type",    text_color=C_DIM, bgcolor=bgB, text_size=11)
    table.cell(hud, 1, 1, "Signals", text_color=C_DIM, bgcolor=bgB, text_size=11, text_halign=text.align_center)
    table.cell(hud, 2, 1, "Followed Through", text_color=C_DIM, bgcolor=bgB, text_size=11, text_halign=text.align_center,
               tooltip="Share of graded divergences where price moved " + str.tostring(tgt_atr) + "× ATR in the divergence direction before breaking the pivot, within " + str.tostring(horizon) + " bars.")

    f_type_row(2, 0, bgA)
    f_type_row(3, 1, bgB)
    f_type_row(4, 2, bgA)
    f_type_row(5, 3, bgB)

    table.cell(hud, 0, 6, "RSI Now", text_color=C_DIM, bgcolor=bgA, text_size=11)
    table.cell(hud, 1, 6, str.tostring(rsi, "#.#"),
               text_color = rsi >= ob_lvl ? col_bear : rsi <= os_lvl ? col_bull : C_TXT,
               bgcolor=bgA, text_size=11, text_halign=text.align_center)
    table.merge_cells(hud, 1, 6, 2, 6)

    table.cell(hud, 0, 7, "Target / Window", text_color=C_DIM, bgcolor=bgB, text_size=11)
    table.cell(hud, 1, 7, str.tostring(tgt_atr) + "× ATR / " + str.tostring(horizon) + " bars",
               text_color=C_TXT, bgcolor=bgB, text_size=11, text_halign=text.align_center)
    table.merge_cells(hud, 1, 7, 2, 7)


//  ALERTS 
alertcondition(bull_reg, "Bullish RSI Divergence", "D3R RSI Div: bullish regular divergence confirmed")
alertcondition(bear_reg, "Bearish RSI Divergence", "D3R RSI Div: bearish regular divergence confirmed")
alertcondition(bull_hid, "Hidden Bullish RSI Divergence", "D3R RSI Div: hidden bullish divergence confirmed")
alertcondition(bear_hid, "Hidden Bearish RSI Divergence", "D3R RSI Div: hidden bearish divergence confirmed")
````
