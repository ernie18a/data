# Z-Score Mean Reversion Probability [Dots3Red]

- url: https://www.tradingview.com/script/vNCACKbz-Z-Score-Mean-Reversion-Probability-Dots3Red/
- type: indicator
- pine_id: PUB;bb03f86e9e0f48eaa99cf5b77eb0f9de
- version: 1.0

## Description

📊 [b]Z-Score Mean Reversion Probability [Dots3Red][/b]
This script measures how far price has stretched from its own average (z-score), then checks this chart's history to show how often price actually moved back after being that stretched — as a percentage, with the sample size next to it

✨ [b]WHY THIS MATTERS[/b]
Standard deviation bands and z-score oscillators all answer the same question — "how stretched is price right now?" — but none of them answer the question that actually matters to a trader: when it's been this stretched before, how often did it actually revert, and how fast? Without that number, a z-score of 2.5 is just a shape on a chart. This script turns it into a measured, bucket-specific probability, built from this chart's own history rather than a rule of thumb borrowed from somewhere else.

📊 [b]Two panes, one idea[/b]
The z-score line lives in its own pane, showing how stretched price is. The labels are drawn directly on the price chart, at the candle where a stretch met a bucket with a proven track record — so the reading and the price action it refers to are in the same place.

⚙️ [b]HOW IT WORKS[/b]
📐 [b]Rolling z-score[/b] — price's distance from its own rolling mean, measured in standard deviations, clamped at both ends so a single freak spike can't create an empty, meaningless bucket.

🗂️ [b]Bucketing[/b] — every z-score reading is sorted into a fixed-width bucket by how extreme it was. Each bucket keeps its own independent count of occurrences and reversion hits.

🎯 [b]Rolling, honest grading[/b] — a bucket is only updated once its outcome horizon has fully closed, using the z-score exactly as it stood at the time the reading occurred — never recalculated afterward with the benefit of hindsight. A bucket's probability is hidden until it has enough graded samples to mean something.

🔍 [b]The lookup[/b] — the current bar's z-score is sorted into its bucket, and that bucket's own measured reversion rate becomes the probability shown on the dashboard and, when it clears your confidence threshold, the label on the price chart.

🧹 [b]One label per stretch[/b] — while price stays stretched, a bucket can qualify on many consecutive bars. A configurable cooldown prints one label at the start of the stretch instead of a cluster, and the background tint still shows how long the stretch lasted.

🔒 [b]Non-repainting[/b] — bucketing, grading and every permanent label use confirmed bars only. An optional provisional "(live)" label can show on the still-forming bar; it is dimmed, can appear or disappear until the bar closes, and is replaced by a permanent label only if the reading still qualifies at the close. It can be switched off.

🧭 [b]HOW TO USE[/b]
1️⃣ [b]Wait for buckets to fill.[/b] A fresh chart shows "Collecting…" for a given z-score range until enough occurrences have been graded — the dashboard shows exactly how many samples the current bucket has versus the minimum required.

2️⃣ [b]Check Overall Accuracy before trusting any single reading.[/b] It's a scoreboard across every graded bucket on this chart, so a high sample count means the number is worth something.

3️⃣ [b]Use Min Confidence to filter noise.[/b] A label only prints when the current bucket's measured reversion rate clears your threshold (60% by default) — a bucket sitting near 50/50 isn't a real edge in either direction.

4️⃣ [b]Tune label density to your style.[/b] Lower Min Confidence, Min Samples or widen the bucket to see more labels; raise them to see fewer, better-supported ones. The cooldown setting controls how far apart labels sit.

5️⃣ [b]Treat the probability as a measured lean, not a forecast.[/b] It answers "what happened after price got this stretched, on this chart" — not a guarantee about this specific move.

6️⃣ [b]Different buckets can behave very differently.[/b] A moderate z-score of 1.5 might revert far more (or less) reliably than an extreme z-score of 3.0 — exactly the nuance a flat "z-score is high, expect reversion" rule misses. On strongly trending charts, rates near or below 50% are the tool telling you a stretch is not worth fading there.

⏱️ [b]WHICH TIMEFRAMES WORK BEST[/b]
This method needs enough historical occurrences per bucket to be meaningful, which makes [b]15-minute through 4-hour[/b] the most effective range — short enough to accumulate samples in a reasonable window, long enough that each reading reflects real, settled price behavior rather than noise. Daily charts work with lower sample minimums and wider buckets, at lower confidence.

🛠️ [b]SETTINGS[/b]
📐 [b]Statistics[/b] — mean/stdev lookback length, max z-score clamp, bucket width

📊 [b]Probability Engine[/b]
• Outcome Horizon — how many bars ahead reversion is checked, and the window each bucket is graded on
• Min Samples per Bucket — how many graded occurrences a bucket needs before its probability is shown
• Min Confidence to Signal — how lopsided a bucket's reversion rate must be before a label appears

🎨 [b]Visualization[/b] — z-score line color and thickness, background tint, price-chart labels, minimum bars between labels, optional live label

🖥️ [b]Dashboard[/b] — show/hide, position — current z-score, current bucket's sample count, its measured reversion probability and direction, overall accuracy with sample size, outcome horizon

🔔 [b]Alerts[/b] — bullish and bearish conditions, respecting the same label cooldown

📝 [b]NOTES[/b]
The probabilities shown are specific to this chart, this timeframe, and these settings — they do not transfer to other instruments or configurations. A z-score extreme that reverts reliably on one chart may behave completely differently on another; the honest way to know is to let each bucket fill and check its measured rate for the setup you're using.

⚠️ [b]DISCLAIMER[/b]
This is an analytical and visualization tool. It does not generate trade signals and does not constitute financial advice. Historical prediction accuracy does not guarantee future performance.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Dots3Red
// TradingView: https://www.tradingview.com/u/Dots3Red/

//@version=6
indicator("Statistical Reversion Probability [Dots3Red]",
          shorttitle = "Reversion Prob [D3R]",
          overlay    = false,
          max_labels_count = 500)

// COLORS
C_TXT   = color.new(#f8fafc, 0)
C_DIM    = color.new(#94a3b8, 0)
C_BG     = color.new(#131722, 5)
C_BORD   = color.new(#334155, 0)
C_BULL   = color.new(#00f0ff, 0)
C_BEAR   = color.new(#ff00aa, 0)
C_GOOD   = color.new(#00c896, 0)
C_BAD    = color.new(#ff4466, 0)


// INPUTS
GRP_STAT = "📐 Statistics"
GRP_ENG  = "📊 Probability Engine"
GRP_VIS  = "🎨 Visualization"
GRP_HUD  = "🖥️ Dashboard"

z_len     = input.int(50, "Mean / Stdev Length", minval=10, group=GRP_STAT,
            tooltip="Lookback used to compute the rolling mean and standard deviation that the z-score is measured against.")
max_z     = input.float(3.0, "Max Z-Score (clamp)", minval=1.0, step=0.5, group=GRP_STAT,
            tooltip="Z-score readings beyond this are clamped, so one freak spike doesn't create an empty, useless bucket.")
bucket_w  = input.float(0.5, "Bucket Width", minval=0.1, step=0.1, group=GRP_STAT,
            tooltip="Width of each z-score bucket. Narrower buckets are more precise but take longer to fill with samples.")

horizon       = input.int(10, "Outcome Horizon (bars)", minval=1, maxval=200, group=GRP_ENG,
                tooltip="How many bars ahead reversion is checked, and the window each bucket's probability is graded on.")
min_bucket_n  = input.int(20, "Min Samples per Bucket", minval=5, group=GRP_ENG,
                tooltip="A bucket's probability is only shown once it has been observed this many times.")
min_conf      = input.float(60, "Min Confidence to Signal (%)", minval=50, maxval=95, step=1, group=GRP_ENG,
                tooltip="A label only prints when the current bucket's measured reversion rate is at least this lopsided.")

z_col        = input.color(#f8fafc, "Z-Score Line Color", group=GRP_VIS)
z_width      = input.int(2, "Z-Score Line Thickness", minval=1, maxval=6, group=GRP_VIS)
show_bg      = input.bool(true, "Background Tint by Confidence", group=GRP_VIS)
show_labels  = input.bool(true, "Show Signal Labels (on price chart)", group=GRP_VIS)
lbl_gap      = input.int(8, "Min Bars Between Labels", minval=1, maxval=200, group=GRP_VIS,
               tooltip="After a label prints, no new label (or alert) can fire until this many bars have passed. Stops clusters of labels while z-score stays stretched. Set to 1 to label every qualifying bar.")
show_live    = input.bool(true, "Show Live Label on Forming Bar", group=GRP_VIS,
               tooltip="Shows a provisional label on the current, still-forming bar. It can appear and disappear until the bar closes. Confirmed labels never change.")

show_hud = input.bool(true, "Show Dashboard", group=GRP_HUD)
hud_pos  = input.string("Top Right", "Position",
           options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=GRP_HUD)


// Z-SCORE 
float basis = ta.sma(close, z_len)
float dev   = ta.stdev(close, z_len)
float z     = dev != 0 ? (close - basis) / dev : 0.0
float z_c   = math.max(-max_z, math.min(max_z, z))


// BUCKETING 
int n_buckets = int(math.round((2 * max_z) / bucket_w)) + 1

f_bucket(float zv) =>
    int idx = int(math.floor((zv + max_z) / bucket_w))
    math.max(0, math.min(n_buckets - 1, idx))

var float[] bucket_count = array.new<float>(n_buckets, 0.0)
var float[] bucket_hits  = array.new<float>(n_buckets, 0.0)

int cur_bucket = f_bucket(z_c)


var float total_count = 0.0
var float total_hits  = 0.0

if barstate.isconfirmed and bar_index >= horizon and not na(z_c[horizon])
    float past_z    = z_c[horizon]
    int   past_bkt  = f_bucket(past_z)
    float past_px   = close[horizon]
    float change    = close - past_px
    bool  has_dir   = past_z != 0
    bool  reverted  = past_z > 0 ? change < 0 : change > 0
    if has_dir
        array.set(bucket_count, past_bkt, array.get(bucket_count, past_bkt) + 1.0)
        total_count += 1.0
        if reverted
            array.set(bucket_hits, past_bkt, array.get(bucket_hits, past_bkt) + 1.0)
            total_hits += 1.0


// CURRENT SIGNAL 
float cur_n    = array.get(bucket_count, cur_bucket)
float cur_hits = array.get(bucket_hits, cur_bucket)
bool  enough_n = cur_n >= min_bucket_n
float cur_prob = enough_n ? cur_hits / cur_n * 100.0 : na

// direction implied by current z: positive z = stretched up = expect reversion DOWN; negative z = expect UP
int   dir      = z_c > 0 ? -1 : z_c < 0 ? 1 : 0
bool  signal   = enough_n and dir != 0 and cur_prob >= min_conf

color sig_col  = dir > 0 ? C_BULL : C_BEAR


// VISUALS 
plot(z_c, "Z-Score", color=z_col, linewidth=z_width)
hline(0, "Mean", color=color.new(C_DIM, 60), linestyle=hline.style_dashed)
hline(max_z,  "Upper Clamp", color=color.new(C_BEAR, 75), linestyle=hline.style_dotted)
hline(-max_z, "Lower Clamp", color=color.new(C_BULL, 75), linestyle=hline.style_dotted)

bgcolor(show_bg and signal ? color.new(sig_col, 82) : na)

var label live_lbl = na
if not na(live_lbl)
    label.delete(live_lbl)
    live_lbl := na

f_lbl_txt(int d, float p) =>
    (d > 0 ? "▲ " : "▼ ") + str.tostring(math.round(p)) + "%"


var int last_lbl_bar = na
bool gap_ok = na(last_lbl_bar) or (bar_index - last_lbl_bar >= lbl_gap)
bool fire   = signal and gap_ok

if show_labels and fire
    float ly = dir > 0 ? low : high
    lst = dir > 0 ? label.style_label_up : label.style_label_down
    if barstate.isconfirmed
        label.new(bar_index, ly, f_lbl_txt(dir, cur_prob),
                  style = lst, color = color.new(#000000, 100), textcolor = sig_col,
                  size = size.small, force_overlay = true)
    else if show_live and barstate.islast
        live_lbl := label.new(bar_index, ly, f_lbl_txt(dir, cur_prob) + " (live)",
                  style = lst, color = color.new(#000000, 100), textcolor = color.new(sig_col, 35),
                  size = size.small, force_overlay = true)


if fire and barstate.isconfirmed
    last_lbl_bar := bar_index


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
    table.cell(hud, 0, 0, "REVERSION PROB [D3R]", text_color=C_TXT,
               bgcolor=color.new(#1e293b, 0), text_size=11, text_halign=text.align_center)
    table.merge_cells(hud, 0, 0, 1, 0)

    table.cell(hud, 0, 1, "Z-Score", text_color=C_DIM, bgcolor=color.new(#1e293b, 40), text_size=11)
    table.cell(hud, 1, 1, str.tostring(z, "#.##"),
               text_color = z > 0 ? C_BEAR : z < 0 ? C_BULL : C_TXT,
               bgcolor=color.new(#1e293b, 40), text_size=11, text_halign=text.align_center)

    table.cell(hud, 0, 2, "Bucket Samples", text_color=C_DIM, bgcolor=color.new(#0f172a, 40), text_size=11)
    table.cell(hud, 1, 2, str.tostring(int(cur_n)) + (enough_n ? "" : " (min " + str.tostring(min_bucket_n) + ")"),
               text_color=C_TXT, bgcolor=color.new(#0f172a, 40), text_size=11, text_halign=text.align_center)

    string dir_txt = dir > 0 ? "Reverts Up" : dir < 0 ? "Reverts Down" : "—"
    table.cell(hud, 0, 3, "Reversion Prob", text_color=C_DIM, bgcolor=color.new(#1e293b, 40), text_size=11,
               tooltip="Measured rate, over this bucket's own history, that price moved the expected direction within " + str.tostring(horizon) + " bars.")
    table.cell(hud, 1, 3, not enough_n ? "Collecting…" : dir_txt + "  " + str.tostring(math.round(cur_prob)) + "%",
               text_color = not enough_n ? C_DIM : (cur_prob >= min_conf ? C_GOOD : C_DIM),
               bgcolor=color.new(#1e293b, 40), text_size=11, text_halign=text.align_center)

    float overall = total_count > 0 ? total_hits / total_count * 100.0 : na
    table.cell(hud, 0, 4, "Overall Accuracy", text_color=C_DIM, bgcolor=color.new(#0f172a, 40), text_size=11,
               tooltip="Across every bucket and every graded prediction on this chart.")
    table.cell(hud, 1, 4, na(overall) ? "—" : str.tostring(math.round(overall)) + "% (n=" + str.tostring(int(total_count)) + ")",
               text_color=na(overall) ? C_DIM : overall >= 50 ? C_GOOD : C_BAD,
               bgcolor=color.new(#0f172a, 40), text_size=11, text_halign=text.align_center)

    table.cell(hud, 0, 5, "Horizon", text_color=C_DIM, bgcolor=color.new(#1e293b, 40), text_size=11)
    table.cell(hud, 1, 5, str.tostring(horizon) + " bars",
               text_color=C_TXT, bgcolor=color.new(#1e293b, 40), text_size=11, text_halign=text.align_center)


// ALERTS
alertcondition(fire and dir > 0, "Reversion Probability — Bullish", "D3R Reversion Prob: high-confidence upward reversion signal")
alertcondition(fire and dir < 0, "Reversion Probability — Bearish", "D3R Reversion Prob: high-confidence downward reversion signal")
````
