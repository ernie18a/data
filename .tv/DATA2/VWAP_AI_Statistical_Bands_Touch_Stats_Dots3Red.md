<!-- tradingview-pine-id: PUB;495533072a6f47fa921be322030b608f -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# VWAP AI - Statistical Bands & Touch Stats [Dots3Red]

Source: https://www.tradingview.com/script/Vs7khoJl-VWAP-AI-Statistical-Bands-Touch-Stats-Dots3Red/

## Description

⚓ VWAP AI - STATISTICAL BANDS & TOUCH STATS [Dots3Red]
VWAP's standard deviation bands are treated more or less as reliable support and resistance — on faith. This script checks that faith against the actual chart in front of you: every band touch is graded, every break beyond a band is graded, and the results accumulate into a running, honest record.

✨ WHY THIS MATTERS
VWAP tells you the volume-weighted average price — where the "center of gravity" of trading has actually been. The bands around it are meant to show how far price typically wanders from that center before snapping back. But "typically" varies enormously by instrument, session, and market condition, and no plain VWAP tool tells you what's actually been happening on your chart.

This script tracks it directly:
📊 +1σ  |  62% rejected  (n=41)

That means 41 touches of the +1σ band have been recorded on this chart, and 62% of them resulted in price genuinely rejecting back toward VWAP. Measured history, not an assumption baked into the tool.

⚙️ HOW IT WORKS
⚓ Anchoring — VWAP resets at the start of each new period. Session is the classic intraday default; Week and Month extend the same logic to longer views. Custom Bar anchors once, permanently, to a specific historical point you choose — useful for anchoring to an earnings date, a gap, or any event you want to measure from, rather than the calendar.

📏 Two-tier statistical bands — Band 1 and Band 2 are both standard-deviation multiples of VWAP, computed from a proper running variance (not an ATR approximation). Defaults are ±1σ and ±2σ, both fully adjustable.

🎯 Touch grading — when price wicks into a band without closing beyond it, that's logged as a touch. Within a configurable window, it resolves as:
• Rejection — price moved back toward VWAP by a meaningful distance
• Break — price closed convincingly through the band
• Timeout — neither happened clearly enough to call

🔄 Break-to-reversion tracking — separately, when price actually closes beyond Band 1, the script watches whether that move reverts back toward VWAP or continues away from it. This answers a different question than touch grading: not "did the band hold," but "once it didn't, did price come back anyway?"

🔒 Non-repainting — all grading happens strictly on confirmed bars.

🧭 HOW TO USE
1️⃣ Check the band stats before treating a level as reliable. "+1σ: 71% rejected (n=38)" and "+1σ: 44% rejected (n=12)" look like the same line on the chart but mean very different things about how much to lean on it.

2️⃣ Use break-reversion stats to judge a breakout beyond VWAP's range. If breaks above Band 1 have reverted back 65% of the time on this chart, that's useful context before assuming a fresh breakout will keep running.

3️⃣ Read Price vs VWAP as the simplest possible bias check. Above VWAP means the average buyer today is in profit; below means the average buyer is underwater. It's a blunt but genuinely useful read on crowd positioning.

4️⃣ Let sample sizes build before trusting the percentages. Every stat shows its N= specifically so you can judge reliability yourself — a handful of touches is not yet a pattern.

5️⃣ Match the anchor mode to what you're actually measuring. Session for pure intraday structure, Week or Month for a longer view, Custom Bar when you want to measure from one specific moment forward.

⏱️ WHICH TIMEFRAMES WORK BEST
Session-anchored VWAP is fundamentally an intraday tool — it was built for, and is most meaningful on, timeframes where a full session contains enough bars to form a real distribution: 1-minute through 1-hour is the classic and most effective range, which is exactly where VWAP sees the heaviest institutional and day-trading use.

On daily or weekly charts, a Session anchor resets so frequently relative to the bar size that it stops being meaningful — you'd see very few bars per session. For higher-timeframe or swing-style use, switch the anchor to Week, Month, or Custom Bar instead, so the accumulation window actually spans enough bars to produce a meaningful VWAP and band structure.

The touch and break statistics also need enough occurrences to mean anything — a fast-moving intraday chart will accumulate a useful sample size in days; a slow higher-timeframe anchor will take considerably longer.

🛠️ SETTINGS
⚓ Anchoring — Session / Week / Month / Custom Bar, source price

📏 Bands — Band 1 and Band 2 standard-deviation multipliers, Band 2 visibility toggle

🎯 Touch Statistics — Touch Tolerance, Rejection Distance, Reversion Distance, Outcome Window

🎨 Visualization — independent Band 1 / Band 2 touch marker toggles, Dot or Triangle marker style, marker size, VWAP and band line widths, independent fill transparency per band tier

🎨 Colors — VWAP line, Band 1 lines, Band 2 lines, upper/lower touch markers, Price Above/Below VWAP indicator, and full dashboard color control (background, border, header, row styling)

🖥️ Dashboard — show/hide, position — current VWAP value, price position, all four band stats, and both break-reversion stats in one place

📝 NOTES
Statistics accumulate from when the indicator is added to the chart and reset only when explicitly cleared by reloading. A Custom Bar anchor never resets on its own, it measures continuously from the point you chose. Band 2 statistics take meaningfully longer to build a useful sample than Band 1, simply because price reaches ±2σ far less often than ±1σ.

⚠️ DISCLAIMER
This is an analytical and visualization tool. It does not generate trade signals and does not constitute financial advice. Historical rejection and reversion rates do not guarantee future performance.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Dots3Red
// TradingView: https://www.tradingview.com/u/Dots3Red/

//@version=6
indicator("VWAP AI - Statistical Bands & Touch Stats [Dots3Red]",
          shorttitle = "VWAP AI [D3R]",
          overlay    = true,
          max_labels_count = 500)


// INPUTS
GRP_ANC = "⚓ Anchoring"
GRP_BND = "📏 Bands"
GRP_ST  = "🎯 Touch Statistics"
GRP_VIS = "🎨 Visualization"
GRP_COL = "🎨 Colors"
GRP_HUD = "🖥️ Dashboard"

anchor_mode = input.string("Session", "Anchor", options=["Session", "Week", "Month", "Custom Bar"], group=GRP_ANC,
              tooltip="Session/Week/Month reset automatically at each new period. Custom Bar anchors once to a fixed point you set below and never resets.")
custom_anchor_bar = input.int(0, "Custom Anchor (bars back)", minval=0, maxval=5000, group=GRP_ANC)
src_in = input.source(hlc3, "Source", group=GRP_ANC)

band1_mult = input.float(1.0, "Band 1 (×σ)", minval=0.1, maxval=5.0, step=0.1, group=GRP_BND)
band2_mult = input.float(2.0, "Band 2 (×σ)", minval=0.1, maxval=6.0, step=0.1, group=GRP_BND)
show_band2 = input.bool(true, "Show Band 2", group=GRP_BND)

touch_tol    = input.float(0.15, "Touch Tolerance (×ATR)", minval=0.05, maxval=1.0, step=0.05, group=GRP_ST)
reject_atr   = input.float(1.0, "Rejection Distance (×ATR)", minval=0.3, maxval=5.0, step=0.1, group=GRP_ST,
               tooltip="After a band touch, price must move back toward VWAP at least this far to grade as a rejection.")
revert_atr   = input.float(1.0, "Reversion Distance (×ATR)", minval=0.3, maxval=5.0, step=0.1, group=GRP_ST,
               tooltip="After a close beyond a band, price must return at least this far toward VWAP to grade as reversion.")
outcome_bars = input.int(15, "Outcome Window (bars)", minval=3, maxval=100, group=GRP_ST)

show_fill  = input.bool(true, "Band Fill", group=GRP_VIS)
show_marks = input.bool(true, "Band 1 Touch Markers", group=GRP_VIS)
show_marks_b2 = input.bool(false, "Band 2 Touch Markers", group=GRP_VIS)
marker_style_in = input.string("Dot", "Marker Style", options=["Dot","Triangle"], group=GRP_VIS)
marker_size_in  = input.string("Tiny", "Marker Size", options=["Tiny","Small","Normal"], group=GRP_VIS)
vwap_width_in  = input.int(2, "VWAP Line Width", minval=1, maxval=4, group=GRP_VIS)
band_width_in  = input.int(1, "Band Line Width", minval=1, maxval=4, group=GRP_VIS)
fill_trans_in  = input.int(93, "Band 1 Fill Transparency", minval=50, maxval=99, group=GRP_VIS)
fill_trans_b2_in = input.int(95, "Band 2 Fill Transparency", minval=50, maxval=99, group=GRP_VIS)

col_vwap    = input.color(#ffb700, "VWAP Line", group=GRP_COL)
col_band1   = input.color(#00f0ff, "Band 1 Lines", group=GRP_COL)
col_band2   = input.color(#ff00aa, "Band 2 Lines", group=GRP_COL)
col_touch_up = input.color(#ff00aa, "Upper Touch Marker", inline="tm", group=GRP_COL)
col_touch_dn = input.color(#00f0ff, "Lower Touch Marker", inline="tm", group=GRP_COL)
col_above    = input.color(#00f0ff, "Price Above VWAP", inline="pv", group=GRP_COL)
col_below    = input.color(#ff00aa, "Price Below VWAP", inline="pv", group=GRP_COL)

col_dash_bg          = input.color(color.new(#131722, 5), "Dashboard Background", group=GRP_COL)
col_dash_border      = input.color(color.new(#334155, 0), "Dashboard Border", group=GRP_COL)
col_dash_header_bg   = input.color(color.new(#1e293b, 0), "Dashboard Header Background", inline="dh", group=GRP_COL)
col_dash_header_text = input.color(#f8fafc, "Dashboard Header Text", inline="dh", group=GRP_COL)
col_dash_label_text  = input.color(color.new(#94a3b8, 0), "Dashboard Row Label Text", group=GRP_COL)
col_dash_row_bg      = input.color(color.new(#1e293b, 40), "Dashboard Row Background", group=GRP_COL)
col_dash_amber       = input.color(#ffb700, "Dashboard: Break-Reversion Stat", group=GRP_COL)

show_hud = input.bool(true, "Show Dashboard", group=GRP_HUD)
hud_pos  = input.string("Top Right", "Position",
           options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=GRP_HUD)


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

resolved_hud_pos = f_hud_pos(hud_pos)
resolved_mk_size = f_marker_size(marker_size_in)

f_draw_touch(int b, float y, color c, bool is_upper) =>
    if marker_style_in == "Triangle"
        int newSize=2
        if marker_size_in=="Tiny"
            newSize:=2
        else if marker_size_in=="Small"
            newSize:=3
        else if marker_size_in=="Normal"
            newSize:=4

        label.new(b, y, "", style = is_upper ? label.style_triangledown : label.style_triangleup,
                  color=c, size=newSize)
    else
        label.new(b, y, "◦", style = is_upper ? label.style_label_down : label.style_label_up,
                  color=color.new(#000000, 100), textcolor=c, size=resolved_mk_size)


atr_raw = ta.atr(14)

bool new_session = ta.change(time("D")) != 0
bool new_week    = ta.change(time("W")) != 0
bool new_month    = ta.change(time("M")) != 0

bool custom_anchor_hit = bar_index == (last_bar_index - custom_anchor_bar)

bool do_reset = switch anchor_mode
    "Session"    => new_session
    "Week"       => new_week
    "Month"      => new_month
    "Custom Bar" => custom_anchor_hit
    => new_session


var float cum_pv  = 0.0
var float cum_vol = 0.0
var float cum_pv2 = 0.0

float v = nz(volume, 1.0)

if do_reset
    cum_pv  := 0.0
    cum_vol := 0.0
    cum_pv2 := 0.0

cum_pv  += src_in * v
cum_vol += v
cum_pv2 += src_in * src_in * v

float vwap_val = cum_vol > 0 ? cum_pv / cum_vol : src_in
float variance = cum_vol > 0 ? math.max(cum_pv2 / cum_vol - vwap_val * vwap_val, 0.0) : 0.0
float stdev    = math.sqrt(variance)

float b1_up = vwap_val + stdev * band1_mult
float b1_dn = vwap_val - stdev * band1_mult
float b2_up = vwap_val + stdev * band2_mult
float b2_dn = vwap_val - stdev * band2_mult


// TOUCH STATISTICS ENGINE
var int p1u_bar = na
var int p1d_bar = na
var int p2u_bar = na
var int p2d_bar = na

var int t1u = 0, var int r1u = 0
var int t1d = 0, var int r1d = 0
var int t2u = 0, var int r2u = 0
var int t2d = 0, var int r2d = 0

// Break -> reversion tracking (band 1 only)
var int   brk_up_bar = na
var float brk_up_ref = na
var int   brk_dn_bar = na
var float brk_dn_ref = na
var int brk_up_total = 0, var int brk_up_revert = 0
var int brk_dn_total = 0, var int brk_dn_revert = 0

if barstate.isconfirmed

    if not na(p1u_bar)
        bool rej = (b1_up - close) >= reject_atr * atr_raw or close < vwap_val
        bool brk = close > b1_up + touch_tol * atr_raw
        bool tmo = (bar_index - p1u_bar) >= outcome_bars
        if rej or brk or tmo
            t1u += 1
            if rej
                r1u += 1
            p1u_bar := na

    if not na(p1d_bar)
        bool rej_d = (close - b1_dn) >= reject_atr * atr_raw or close > vwap_val
        bool brk_d = close < b1_dn - touch_tol * atr_raw
        bool tmo_d = (bar_index - p1d_bar) >= outcome_bars
        if rej_d or brk_d or tmo_d
            t1d += 1
            if rej_d
                r1d += 1
            p1d_bar := na

    if not na(p2u_bar)
        bool rej2 = (b2_up - close) >= reject_atr * atr_raw or close < b1_up
        bool tmo2 = (bar_index - p2u_bar) >= outcome_bars
        if rej2 or tmo2
            t2u += 1
            if rej2
                r2u += 1
            p2u_bar := na

    if not na(p2d_bar)
        bool rej2d = (close - b2_dn) >= reject_atr * atr_raw or close > b1_dn
        bool tmo2d = (bar_index - p2d_bar) >= outcome_bars
        if rej2d or tmo2d
            t2d += 1
            if rej2d
                r2d += 1
            p2d_bar := na

    // Detect new touches: wick reaches the band, close stays inside it
    if na(p1u_bar) and high >= b1_up - touch_tol * atr_raw and close < b1_up
        p1u_bar := bar_index
        if show_marks
            f_draw_touch(bar_index, high + atr_raw * 0.3, col_touch_up, true)
    if na(p1d_bar) and low <= b1_dn + touch_tol * atr_raw and close > b1_dn
        p1d_bar := bar_index
        if show_marks
            f_draw_touch(bar_index, low - atr_raw * 0.3, col_touch_dn, false)
    if show_band2 and na(p2u_bar) and high >= b2_up - touch_tol * atr_raw and close < b2_up
        p2u_bar := bar_index
        if show_marks_b2
            f_draw_touch(bar_index, high + atr_raw * 0.3, color.new(col_touch_up, 45), true)
    if show_band2 and na(p2d_bar) and low <= b2_dn + touch_tol * atr_raw and close > b2_dn
        p2d_bar := bar_index
        if show_marks_b2
            f_draw_touch(bar_index, low - atr_raw * 0.3, color.new(col_touch_dn, 45), false)

    if not na(brk_up_bar)
        bool reverted = (brk_up_ref - close) >= revert_atr * atr_raw or close < vwap_val
        bool timed3 = (bar_index - brk_up_bar) >= outcome_bars
        if reverted or timed3
            brk_up_total += 1
            if reverted
                brk_up_revert += 1
            brk_up_bar := na

    if not na(brk_dn_bar)
        bool reverted_d = (close - brk_dn_ref) >= revert_atr * atr_raw or close > vwap_val
        bool timed4 = (bar_index - brk_dn_bar) >= outcome_bars
        if reverted_d or timed4
            brk_dn_total += 1
            if reverted_d
                brk_dn_revert += 1
            brk_dn_bar := na

    bool new_brk_up = close > b1_up and close[1] <= b1_up[1]
    bool new_brk_dn = close < b1_dn and close[1] >= b1_dn[1]
    if new_brk_up and na(brk_up_bar)
        brk_up_bar := bar_index
        brk_up_ref := close
    if new_brk_dn and na(brk_dn_bar)
        brk_dn_bar := bar_index
        brk_dn_ref := close


// VISUALS 
plot(vwap_val, "VWAP", color=col_vwap, linewidth=vwap_width_in)

p_b1u = plot(b1_up, "Band +1", color=color.new(col_band1, 45), linewidth=band_width_in)
p_b1d = plot(b1_dn, "Band -1", color=color.new(col_band1, 45), linewidth=band_width_in)
p_b2u = plot(show_band2 ? b2_up : na, "Band +2", color=color.new(col_band2, 60), linewidth=band_width_in)
p_b2d = plot(show_band2 ? b2_dn : na, "Band -2", color=color.new(col_band2, 60), linewidth=band_width_in)

fill(p_b1u, p_b1d, color = show_fill ? color.new(col_vwap, fill_trans_in) : na, title="Band 1 Fill")
fill(p_b1u, p_b2u, color = show_fill and show_band2 ? color.new(col_band2, fill_trans_b2_in) : na, title="Upper Band 2 Fill")
fill(p_b1d, p_b2d, color = show_fill and show_band2 ? color.new(col_band1, fill_trans_b2_in) : na, title="Lower Band 2 Fill")


// DASHBOARD
var table hud = table.new(resolved_hud_pos, 2, 9,
                           bgcolor=col_dash_bg, border_color=col_dash_border,
                           border_width=1, frame_color=col_dash_border, frame_width=2)

if show_hud and barstate.islast
    table.cell(hud, 0, 0, "VWAP AI [D3R]", text_color=col_dash_header_text,
               bgcolor=col_dash_header_bg, text_size=11, text_halign=text.align_center)
    table.merge_cells(hud, 0, 0, 1, 0)

    table.cell(hud, 0, 1, "VWAP", text_color=col_dash_label_text, bgcolor=col_dash_row_bg, text_size=11)
    table.cell(hud, 1, 1, str.tostring(vwap_val, format.mintick),
               text_color=col_vwap, bgcolor=col_dash_row_bg, text_size=11, text_halign=text.align_center)

    table.cell(hud, 0, 2, "Price vs VWAP", text_color=col_dash_label_text, bgcolor=col_dash_row_bg, text_size=11)
    table.cell(hud, 1, 2, close > vwap_val ? "▲ Above" : "▼ Below",
               text_color=close > vwap_val ? col_above : col_below,
               bgcolor=col_dash_row_bg, text_size=11, text_halign=text.align_center)

    string s1u = t1u > 0 ? str.tostring(math.round(float(r1u)/float(t1u)*100.0)) + "% (n=" + str.tostring(t1u) + ")" : "—"
    table.cell(hud, 0, 3, "+1σ Rejected", text_color=col_dash_label_text, bgcolor=col_dash_row_bg, text_size=11)
    table.cell(hud, 1, 3, s1u, text_color=t1u>0 ? col_touch_up : col_dash_label_text, bgcolor=col_dash_row_bg, text_size=11, text_halign=text.align_center)

    string s1d = t1d > 0 ? str.tostring(math.round(float(r1d)/float(t1d)*100.0)) + "% (n=" + str.tostring(t1d) + ")" : "—"
    table.cell(hud, 0, 4, "-1σ Rejected", text_color=col_dash_label_text, bgcolor=col_dash_row_bg, text_size=11)
    table.cell(hud, 1, 4, s1d, text_color=t1d>0 ? col_touch_dn : col_dash_label_text, bgcolor=col_dash_row_bg, text_size=11, text_halign=text.align_center)

    string s2u = t2u > 0 ? str.tostring(math.round(float(r2u)/float(t2u)*100.0)) + "% (n=" + str.tostring(t2u) + ")" : "—"
    table.cell(hud, 0, 5, "+2σ Rejected", text_color=col_dash_label_text, bgcolor=col_dash_row_bg, text_size=11)
    table.cell(hud, 1, 5, s2u, text_color=t2u>0 ? col_touch_up : col_dash_label_text, bgcolor=col_dash_row_bg, text_size=11, text_halign=text.align_center)

    string s2d = t2d > 0 ? str.tostring(math.round(float(r2d)/float(t2d)*100.0)) + "% (n=" + str.tostring(t2d) + ")" : "—"
    table.cell(hud, 0, 6, "-2σ Rejected", text_color=col_dash_label_text, bgcolor=col_dash_row_bg, text_size=11)
    table.cell(hud, 1, 6, s2d, text_color=t2d>0 ? col_touch_dn : col_dash_label_text, bgcolor=col_dash_row_bg, text_size=11, text_halign=text.align_center)

    string sbu = brk_up_total > 0 ? str.tostring(math.round(float(brk_up_revert)/float(brk_up_total)*100.0)) + "% (n=" + str.tostring(brk_up_total) + ")" : "—"
    table.cell(hud, 0, 7, "▲ Break Reverts", text_color=col_dash_label_text, bgcolor=col_dash_row_bg, text_size=11)
    table.cell(hud, 1, 7, sbu, text_color=brk_up_total>0 ? col_dash_amber : col_dash_label_text, bgcolor=col_dash_row_bg, text_size=11, text_halign=text.align_center)

    string sbd = brk_dn_total > 0 ? str.tostring(math.round(float(brk_dn_revert)/float(brk_dn_total)*100.0)) + "% (n=" + str.tostring(brk_dn_total) + ")" : "—"
    table.cell(hud, 0, 8, "▼ Break Reverts", text_color=col_dash_label_text, bgcolor=col_dash_row_bg, text_size=11)
    table.cell(hud, 1, 8, sbd, text_color=brk_dn_total>0 ? col_dash_amber : col_dash_label_text, bgcolor=col_dash_row_bg, text_size=11, text_halign=text.align_center)


// ALERTS
alertcondition(ta.crossover(close, vwap_val),  "Cross Above VWAP", "D3R VWAP AI: price crossed above VWAP")
alertcondition(ta.crossunder(close, vwap_val), "Cross Below VWAP", "D3R VWAP AI: price crossed below VWAP")
````
