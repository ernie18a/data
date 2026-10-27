# Anchored VWAP Bands - Band Reaction Statistics [Dots3Red]

- url: https://www.tradingview.com/script/uWBdzIxc-Anchored-VWAP-Bands-Band-Reaction-Statistics-Dots3Red/
- type: indicator
- pine_id: PUB;42ef380818b34fb3b5d69db42a52e385
- version: 1.0

## Description

📐 [b]ANCHORED VWAP BANDS - BAND REACTION STATISTICS [Dots3Red][/b]
This indicator draws an anchored VWAP (session, week or month) with three pairs of standard-deviation bands, and measures how often price pulled back toward VWAP after touching each band on the current chart, shown as a percentage with the sample size next to it.

✨ [b]WHY THIS MATTERS[/b]
VWAP bands are one of the most common intraday tools: many traders fade the outer bands and expect a return toward VWAP. Whether that actually happens depends heavily on the instrument and timeframe. On some charts a 2σ touch snaps back most of the time; on trending charts the same touch often keeps running. Instead of assuming the band "should" hold, this script keeps score of what each band has actually done on your chart.

⚙️ [b]HOW IT WORKS[/b]
📐 [b]Anchored VWAP[/b] — the volume-weighted average price restarts at the beginning of each session, week or month. Lines break cleanly at each reset so periods don't blur together.
📏 [b]Sigma bands[/b] — three upper and three lower bands at configurable multiples of the volume-weighted standard deviation (defaults 1σ, 2σ, 3σ).
🎯 [b]First-touch grading[/b] — a touch is the first bar whose wick reaches a band after being inside it on the previous bar. From the next bar on, it is graded against levels frozen at the moment of the touch:
• Reverted — price reaches the next inner level first (band 2 → band 1, band 1 → VWAP)
• Failed — price reaches the next outer level first, or the resolve window runs out
If both happen on the same bar, it counts as failed (the conservative choice).
⏳ [b]Early-period filter[/b] — right after each reset the bands are very narrow, so touches in the first few bars of a period are not graded.
🔒 [b]Non-repainting grading[/b] — touches are registered and graded on confirmed bars only, using levels as they stood at the time. The VWAP and bands themselves update live on the forming bar, as VWAP always does.
🖥️ [b]Dashboard[/b] — touches and reversion rate for each of the six bands, price's current distance from VWAP in σ, and the resolve window.

🧭 [b]HOW TO USE[/b]
1️⃣ [b]Let the sample build.[/b] Each band shows "Collecting…" until it has enough graded touches. Outer bands are touched less often, so they fill more slowly.
2️⃣ [b]Compare bands, not just one number.[/b] A chart where 1σ touches revert often but 3σ touches rarely do is telling you that extended moves tend to keep going there.
3️⃣ [b]Compare upper vs lower.[/b] On trending instruments the two sides often behave very differently, for example lower-band touches reverting far more often than upper-band touches in an uptrend.
4️⃣ [b]Match the anchor to your holding period.[/b] Session VWAP for intraday trades, weekly or monthly VWAP for swing context.
5️⃣ [b]Use it as context, not a trigger.[/b] The rates describe how price has behaved at these bands on this chart. They do not predict the next touch.

⏱️ [b]WHICH TIMEFRAMES WORK BEST[/b]
Session-anchored VWAP is designed for [b]intraday charts, 1-minute through 1-hour[/b]. Weekly and monthly anchors work well on 15-minute through 4-hour charts. On a daily chart a session anchor restarts every bar and is not meaningful.

🛠️ [b]SETTINGS[/b]
📐 [b]VWAP & Bands[/b] — anchor period, source, three band multipliers, bars to ignore after each reset
🎯 [b]Band Reaction Grading[/b] — max bars to resolve a touch, minimum touches to show a rate
🎨 [b]Visuals[/b] — VWAP color and thickness, upper/lower band colors and thickness, show band 3, band fills and transparency, touch labels and which band they start from
🖥️ [b]Dashboard[/b] — show/hide, position
🔔 [b]Alerts[/b] — upper band 2 touch, lower band 2 touch, VWAP cross

📝 [b]NOTES[/b]
VWAP requires volume data. On symbols where the data feed provides no volume, VWAP cannot be calculated. All rates are specific to this chart, timeframe, anchor and settings, and do not transfer to other instruments or configurations.

⚠️ [b]DISCLAIMER[/b]
This is an analytical and visualization tool. It does not generate trade signals and does not constitute financial advice. Historical statistics do not guarantee future performance.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Dots3Red
// TradingView: https://www.tradingview.com/u/Dots3Red/

//@version=6
indicator("Anchored VWAP Bands - Band Reaction Statistics [Dots3Red]",
          shorttitle = "VWAP Bands [D3R]",
          overlay    = true,
          max_labels_count = 500)


// COLORS (house palette)
C_TXT   = color.new(#f8fafc, 0)
C_DIM   = color.new(#94a3b8, 0)
C_BG    = color.new(#131722, 5)
C_BORD  = color.new(#334155, 0)
C_GOOD  = color.new(#00c896, 0)
C_BAD   = color.new(#ff4466, 0)
C_UP    = color.new(#ff00aa, 0)
C_DN    = color.new(#00f0ff, 0)


// INPUTS
GRP_VW  = "📐 VWAP & Bands"
GRP_ENG = "🎯 Band Reaction Grading"
GRP_VIS = "🎨 Visuals"
GRP_HUD = "🖥️ Dashboard"

anchor   = input.string("Session", "Anchor Period", options=["Session", "Week", "Month"], group=GRP_VW,
           tooltip="VWAP and its bands restart at the beginning of each period.")
src      = input.source(hlc3, "Source", group=GRP_VW)
m1       = input.float(1.0, "Band 1 (× σ)", minval=0.1, step=0.1, group=GRP_VW)
m2       = input.float(2.0, "Band 2 (× σ)", minval=0.1, step=0.1, group=GRP_VW)
m3       = input.float(3.0, "Band 3 (× σ)", minval=0.1, step=0.1, group=GRP_VW)
min_bars = input.int(5, "Ignore First N Bars of Each Period", minval=1, maxval=100, group=GRP_VW,
           tooltip="Bands are very narrow right after the anchor resets, so touches there are not meaningful and are not graded.")

horizon  = input.int(20, "Max Bars to Resolve a Touch", minval=3, maxval=200, group=GRP_ENG,
           tooltip="A touch that reaches neither the inner level nor the outer level within this many bars counts as a failed reversion.")
min_n    = input.int(15, "Min Touches to Show Rate", minval=5, group=GRP_ENG)

col_vwap  = input.color(#ffb700, "VWAP Color", group=GRP_VIS)
w_vwap    = input.int(2, "VWAP Thickness", minval=1, maxval=6, group=GRP_VIS)
col_up    = input.color(#ff00aa, "Upper Bands Color", group=GRP_VIS)
col_dn    = input.color(#00f0ff, "Lower Bands Color", group=GRP_VIS)
w_band    = input.int(1, "Band Thickness", minval=1, maxval=6, group=GRP_VIS)
show_b3   = input.bool(true, "Show Band 3", group=GRP_VIS)
show_fill = input.bool(true, "Fill Between Bands", group=GRP_VIS)
fill_tr   = input.int(92, "Fill Transparency", minval=50, maxval=100, group=GRP_VIS)
show_lbl  = input.bool(true, "Label Band Touches", group=GRP_VIS)
lbl_from  = input.string("Band 2", "Label Touches From", options=["Band 1", "Band 2", "Band 3"], group=GRP_VIS,
            tooltip="Only touches of this band and further out get a label on the chart. All touches are graded either way.")
lbl_up    = input.color(#ff00aa, "Upper Touch Label Color", group=GRP_VIS)
lbl_dn    = input.color(#00f0ff, "Lower Touch Label Color", group=GRP_VIS)

show_hud = input.bool(true, "Show Dashboard", group=GRP_HUD)
hud_pos  = input.string("Top Right", "Position",
           options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=GRP_HUD)


//  ANCHORED VWAP + SIGMA BANDS 
bool chg_d = timeframe.change("D")
bool chg_w = timeframe.change("W")
bool chg_m = timeframe.change("M")
bool new_anchor = anchor == "Session" ? chg_d : anchor == "Week" ? chg_w : chg_m

var bool has_vol = false
if nz(volume) > 0
    has_vol := true
float v = has_vol ? nz(volume) : 1.0

var float sum_pv  = 0.0
var float sum_v   = 0.0
var float sum_p2v = 0.0
var int   bars_in = 0

if new_anchor
    sum_pv  := src * v
    sum_v   := v
    sum_p2v := src * src * v
    bars_in := 0
else
    sum_pv  += src * v
    sum_v   += v
    sum_p2v += src * src * v
    bars_in += 1

float vw = sum_v > 0 ? sum_pv / sum_v : na
float sd = sum_v > 0 ? math.sqrt(math.max(0.0, sum_p2v / sum_v - vw * vw)) : na

float u1 = vw + m1 * sd
float u2 = vw + m2 * sd
float u3 = vw + m3 * sd
float l1 = vw - m1 * sd
float l2 = vw - m2 * sd
float l3 = vw - m3 * sd


//  BAND REACTION GRADING 
var int[]   p_bar = array.new<int>(6, -1)
var float[] p_tgt = array.new<float>(6, na)
var float[] p_stp = array.new<float>(6, na)
var float[] st_n  = array.new<float>(6, 0.0)
var float[] st_h  = array.new<float>(6, 0.0)

float[] lv_now  = array.from(u1, u2, u3, l1, l2, l3)
float[] lv_prev = array.from(u1[1], u2[1], u3[1], l1[1], l2[1], l3[1])
float[] lv_in   = array.from(vw, u1, u2, vw, l1, l2)
float[] lv_out  = array.from(u2, u3, u3 + (u3 - u2), l2, l3, l3 - (l2 - l3))

string[] names  = array.from("+B1", "+B2", "+B3", "−B1", "−B2", "−B3")

int lbl_min = lbl_from == "Band 1" ? 0 : lbl_from == "Band 2" ? 1 : 2

f_rate(int i) =>
    float n = array.get(st_n, i)
    n >= min_n ? array.get(st_h, i) / n * 100.0 : na

if barstate.isconfirmed
    for i = 0 to 5
        int pb = array.get(p_bar, i)
        if pb >= 0 and bar_index > pb
            bool  upper = i < 3
            float tg    = array.get(p_tgt, i)
            float sp    = array.get(p_stp, i)
            bool  hit_t = upper ? low <= tg  : high >= tg
            bool  hit_s = upper ? high >= sp : low <= sp
            bool  timed = bar_index - pb >= horizon
            if hit_t or hit_s or timed
                array.set(st_n, i, array.get(st_n, i) + 1.0)
                if hit_t and not hit_s
                    array.set(st_h, i, array.get(st_h, i) + 1.0)
                array.set(p_bar, i, -1)

    if not new_anchor and bars_in >= min_bars and sd > 0 and not na(sd[1])
        for i = 0 to 5
            bool  upper = i < 3
            float lv    = array.get(lv_now, i)
            float lp    = array.get(lv_prev, i)
            bool  touch = upper ? (high >= lv and high[1] < lp) : (low <= lv and low[1] > lp)
            if touch and array.get(p_bar, i) < 0
                array.set(p_bar, i, bar_index)
                array.set(p_tgt, i, array.get(lv_in, i))
                array.set(p_stp, i, array.get(lv_out, i))
                if show_lbl and (i % 3) >= lbl_min and (show_b3 or (i % 3) < 2)
                    float r = f_rate(i)
                    string t = array.get(names, i) + (na(r) ? "" : " " + str.tostring(math.round(r)) + "%")
                    label.new(bar_index, upper ? high : low, t,
                              style     = upper ? label.style_label_down : label.style_label_up,
                              color     = color.new(#000000, 100),
                              textcolor = upper ? lbl_up : lbl_dn,
                              size      = size.small)


//  PLOTS 
color c_vw = new_anchor ? na : col_vwap
color c_up = new_anchor ? na : col_up
color c_dn = new_anchor ? na : col_dn

p_vw = plot(vw, "VWAP", color=c_vw, linewidth=w_vwap)
p_u1 = plot(u1, "Upper Band 1", color=c_up, linewidth=w_band)
p_u2 = plot(u2, "Upper Band 2", color=c_up, linewidth=w_band)
p_u3 = plot(u3, "Upper Band 3", color=c_up, linewidth=w_band, display = show_b3 ? display.all : display.none)
p_l1 = plot(l1, "Lower Band 1", color=c_dn, linewidth=w_band)
p_l2 = plot(l2, "Lower Band 2", color=c_dn, linewidth=w_band)
p_l3 = plot(l3, "Lower Band 3", color=c_dn, linewidth=w_band, display = show_b3 ? display.all : display.none)

color f_up  = show_fill and not new_anchor ? color.new(col_up, fill_tr) : na
color f_dn  = show_fill and not new_anchor ? color.new(col_dn, fill_tr) : na
color f_up3 = show_fill and show_b3 and not new_anchor ? color.new(col_up, math.min(100, fill_tr + 4)) : na
color f_dn3 = show_fill and show_b3 and not new_anchor ? color.new(col_dn, math.min(100, fill_tr + 4)) : na

fill(p_u1, p_u2, color=f_up,  title="Upper Fill 1-2")
fill(p_u2, p_u3, color=f_up3, title="Upper Fill 2-3")
fill(p_l1, p_l2, color=f_dn,  title="Lower Fill 1-2")
fill(p_l2, p_l3, color=f_dn3, title="Lower Fill 2-3")


//  DASHBOARD 
f_hud_pos(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        =>                position.bottom_left

var table hud = table.new(f_hud_pos(hud_pos), 3, 10,
                          bgcolor=C_BG, border_color=C_BORD,
                          border_width=1, frame_color=C_BORD, frame_width=2)

f_band_row(int row, int i, color bg) =>
    float n = array.get(st_n, i)
    float r = f_rate(i)
    table.cell(hud, 0, row, array.get(names, i), text_color = i < 3 ? C_UP : C_DN, bgcolor=bg, text_size=size.small)
    table.cell(hud, 1, row, str.tostring(int(n)), text_color=C_TXT, bgcolor=bg, text_size=size.small, text_halign=text.align_center)
    table.cell(hud, 2, row, na(r) ? "Collecting…" : str.tostring(math.round(r)) + "%",
               text_color = na(r) ? C_DIM : r >= 55 ? C_GOOD : r <= 45 ? C_BAD : C_TXT,
               bgcolor=bg, text_size=size.small, text_halign=text.align_center)

if show_hud and barstate.islast
    color bgA = color.new(#1e293b, 40)
    color bgB = color.new(#0f172a, 40)

    table.cell(hud, 0, 0, (has_vol ? "VWAP BANDS [D3R] · " : "NO VOLUME · TWAP [D3R] · ") + anchor, text_color = has_vol ? C_TXT : C_BAD,
               bgcolor=color.new(#1e293b, 0), text_size=size.small, text_halign=text.align_center)
    table.merge_cells(hud, 0, 0, 2, 0)

    table.cell(hud, 0, 1, "Band",    text_color=C_DIM, bgcolor=bgB, text_size=size.small)
    table.cell(hud, 1, 1, "Touches", text_color=C_DIM, bgcolor=bgB, text_size=size.small, text_halign=text.align_center)
    table.cell(hud, 2, 1, "Reverted", text_color=C_DIM, bgcolor=bgB, text_size=size.small, text_halign=text.align_center,
               tooltip="Share of graded first touches where price reached the next inner level (band 1 → VWAP) before the next outer level, within " + str.tostring(horizon) + " bars.")

    f_band_row(2, 2, bgA)
    f_band_row(3, 1, bgB)
    f_band_row(4, 0, bgA)
    f_band_row(5, 3, bgB)
    f_band_row(6, 4, bgA)
    f_band_row(7, 5, bgB)

    float pos_sd = sd > 0 ? (close - vw) / sd : na
    table.cell(hud, 0, 8, "Price vs VWAP", text_color=C_DIM, bgcolor=bgA, text_size=size.small)
    table.cell(hud, 1, 8, na(pos_sd) ? "—" : (pos_sd >= 0 ? "+" : "") + str.tostring(pos_sd, "#.##") + " σ",
               text_color = na(pos_sd) ? C_DIM : pos_sd >= 0 ? C_UP : C_DN,
               bgcolor=bgA, text_size=size.small, text_halign=text.align_center)
    table.merge_cells(hud, 1, 8, 2, 8)

    bool tf_bad = anchor == "Session" and timeframe.in_seconds() >= timeframe.in_seconds("D")
    table.cell(hud, 0, 9, tf_bad ? "Use intraday chart" : "Resolve Window", text_color = tf_bad ? C_BAD : C_DIM, bgcolor=bgB, text_size=size.small)
    table.cell(hud, 1, 9, tf_bad ? "for Session VWAP" : str.tostring(horizon) + " bars", text_color = tf_bad ? C_BAD : C_TXT, bgcolor=bgB, text_size=size.small, text_halign=text.align_center)
    table.merge_cells(hud, 1, 9, 2, 9)


//  ALERTS 
alertcondition(ta.crossover(high, u2) and not new_anchor and bars_in >= min_bars, "Upper Band 2 Touch", "D3R VWAP Bands: price reached upper band 2")
alertcondition(ta.crossunder(low, l2) and not new_anchor and bars_in >= min_bars, "Lower Band 2 Touch", "D3R VWAP Bands: price reached lower band 2")
alertcondition(ta.cross(close, vw), "VWAP Cross", "D3R VWAP Bands: price crossed VWAP")
````
