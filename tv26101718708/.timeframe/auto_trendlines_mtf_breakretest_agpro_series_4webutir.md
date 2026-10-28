# Auto Trendlines MTF - Break/Retest [AGPro Series]

- url: https://www.tradingview.com/script/4WebUTIR-Auto-Trendlines-MTF-Break-Retest-AGPro-Series/
- type: indicator
- pine_id: PUB;2dae9108f8bf43d7b1a155515c5c17ca
- version: 3.0

## Description

Auto Trendlines MTF - Break/Retest [AGPro Series]

🔹 OVERVIEW

Auto Trendlines MTF - Break/Retest is a multi-timeframe trendline visualization engine that automatically detects and draws the most structurally significant trendlines across three complementary scales: Micro (current timeframe), Meso (intermediate pivots), and Mega (HTF weekly/monthly overlay). Instead of relying on a single pivot scan, the engine builds a ranked candidate pool from each scale and selects the lines that best represent the active market structure around current price.

The script is designed as a pure analytical visualization tool — it does not generate trading decisions, forecasts, or directional recommendations. Its purpose is to give the chart a clean, hand-drawn-quality trendline layer that updates automatically as new pivots form.


🎯 UNIQUE EDGE

Most auto-trendline tools scan one timeframe and draw whatever fits. This engine operates differently in four specific ways:

• Three-scale MTF engine. Micro pivots on the current TF, Meso pivots with wider sensitivity, and Mega trendlines derived from Weekly/Monthly HTF pivots are computed independently and rendered together with a visual hierarchy (Mega dominant, Meso intermediate, Micro active).

• Log-space geometry. All trendline math runs in log-price space, so long-dated diagonals on volatile assets (crypto, growth stocks) do not distort visually when the chart is viewed in logarithmic mode.

• Touch-weighted ranking with violation penalty. Each candidate line is scored by touch count, line age, slope sanity, price proximity, and intra-line violations. Weak geometry, over-sloped lines, and frequently violated lines are demoted automatically.

• Q quality score (0–100) and confluence tags (x2/x3). Every drawn line carries a Q score that blends touches, freshness, geometry, relevance, and violations into a single number. Confluence tags surface when a Micro line and a Meso line sit within the same ATR band near price, highlighting multi-scale structure overlap.


🧠 METHODOLOGY

1. Pivot detection. Separate pivot streams are maintained for Micro (tight sensitivity), Meso (wider sensitivity), and Mega (HTF pivots via request.security).

2. Candidate generation. For each scale, the engine pairs anchor pivots with subsequent pivots to form line candidates, discards over-sloped ones, and computes touches, violations, and break status in log space.

3. Ranking. Candidates are scored by a weighted combination of touch count, time span, slope sanity, relevance to current price (distance in ATR), and violation count. The best non-duplicate lines are kept per scale.

4. Clutter guards. A minimum ATR separation rule prevents near-duplicate lines from stacking. Smart Focus hides far-from-price lines in Minimal/Balanced density modes to keep the chart readable.

5. Stability mode. In Locked mode, selected lines persist bar-to-bar and are only replaced when they break or fall out of the candidate pool — reducing visual repainting on lower TFs.

6. Break/Retest detection. Once a line is drawn, the engine tracks close-based breaks (with configurable tolerance) and subsequent retests within a time window, emitting labeled signals on TF ≤ 1D.


⚙️ SIGNALS & ALERTS

Break and retest events are plotted for each scale with short ASCII tags:

• µR / µS = Micro Resistance / Support break
• mR / mS = Meso Resistance / Support break
• MR / MS = Mega Resistance / Support break
• rµ / rm / rM = retest on Micro / Meso / Mega respectively

A dedicated alertcondition is exposed for every break and retest event, plus two aggregate alerts (Any BR, Any RT) for users who prefer a single alert stream. A Min Q filter lets the user suppress low-quality signals.


🛠️ KEY INPUTS

• Profile Mode. Auto by Timeframe or Manual (Clean Trader, Balanced, Analyst, Presentation, Custom).
• Density Override. Minimal, Balanced, or Bold visual density.
• Line Weight Override. UltraThin, Thin, or Normal.
• Labels / Signals / Stability / Broken-line behavior. All individually overridable.
• Mega Overlay. Full (lines + cloud + label), Lines Only, or Off.
• Advanced panels. Micro Engine, Meso Engine, Mega Engine, Ranking, Visuals, and Signals each expose their own fine-tuning controls for experienced users.
• HUD. Position, theme (Classic Gray, Premium Accent, Color Coded, Showcase), and text size.


📘 HOW TO USE

• Add the script to any liquid symbol and start on a 1H or 4H chart.
• Leave Profile Mode on "Auto by Timeframe" for a balanced default that adapts to the active TF.
• Read the HUD in the top-right corner to see the active profile, how many Micro/Meso lines are drawn, whether Mega is active, and current Q scores.
• When a line carries a Q score above ~65 and a Conf tag (x2 or x3) appears nearby, that zone is a multi-scale structural pocket — use it as a planning reference, not as a trade trigger on its own.
• Use the Break/Retest tags for situational awareness around drawn lines; combine with your own confirmation logic before acting.


⚠️ LIMITATIONS & TRANSPARENCY

• Lines are drawn from historical pivots and can only confirm after a pivot is established. The engine avoids repainting in Locked mode but cannot predict future pivots.
• Q scores and confluence tags describe structural quality, not directional probability. A high-Q line can still break.
• Mega lines depend on HTF pivot availability; on very young symbols or thin charts, Mega may fall back to a Macro-pivot source or remain hidden.
• The script is published as Public, Open Source so that every ranking rule, weight, and threshold is fully auditable in the source code.


🛡️ RISK DISCLOSURE

This script is a visualization and analysis tool only. It is not financial advice, not a trading strategy, and not a signal service. No performance claims are made or implied. Past structural behavior of trendlines does not guarantee future behavior. All trading decisions, risk sizing, and execution remain the sole responsibility of the user.

## Source Code

````pine
// ─────────────────────────────────────────────────
// Auto Trendlines MTF - Break/Retest [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 10.2
//
// Multi-timeframe auto trendline break and retest planner for TradingView.
// Detects Micro, Meso, and Mega trendlines using log-space geometry and
// touch-weighted ranking, then converts break quality, retest behavior,
// trendline side, and next-action state into a clean execution panel.
// Built for analytical chart planning, not prediction or automated trading.
// ─────────────────────────────────────────────────

//@version=6
indicator("Auto Trendlines MTF - Break/Retest [AGPro Series]", shorttitle="AG Pro ATL", overlay=true, max_lines_count=500, max_labels_count=500, max_bars_back=5000)

grp_qs = "Quick Setup (Presets)"

profile_mode = input.string("Auto by Timeframe", "Profile Mode", options=["Auto by Timeframe","Manual"], group=grp_qs)
auto_tf_map  = input.string("Classic", "Auto TF Map", options=["Classic","Aggressive Clean","Full Context"], group=grp_qs)
manual_profile = input.string("Balanced", "Manual Profile", options=["Clean Trader","Balanced","Analyst","Presentation","Custom (Advanced)"], group=grp_qs)

density_override = input.string("Balanced", "Density Override", options=["Auto","Minimal","Balanced","Bold"], group=grp_qs)
line_weight_override = input.string("Auto", "Line Weight", options=["Auto","UltraThin","Thin","Normal"], group=grp_qs)
labels_override = input.string("On", "Labels", options=["Auto","Off","On"], group=grp_qs)
signals_override = input.string("On", "Signals (<=1D)", options=["Auto","Off","On"], group=grp_qs)
stability_override = input.string("Locked", "Line Stability Override", options=["Auto","Dynamic","Locked"], group=grp_qs)
broken_override = input.string("Keep Broken", "Broken Lines Override", options=["Auto","Replace","Keep Broken"], group=grp_qs)
mega_overlay_override = input.string("Lines Only", "Mega Overlay", options=["Auto","Full","Lines Only","Off"], group=grp_qs)

grp_core = "Advanced — Micro Engine"
len          = input.int(5,  "Pivot Sensitivity", minval=2, group=grp_core)
min_dist     = input.int(10, "Min Pivot Gap (bars)", minval=5, group=grp_core)
micro_anchor_n = input.int(6, "Anchor Candidates", minval=1, maxval=20, group=grp_core)
top_n        = input.int(3,  "Max Active Lines", minval=1, maxval=5, group=grp_core)
min_touch    = input.int(2,  "Min Touches", minval=2, group=grp_core)
use_log      = input.bool(true, "Logarithmic Geometry", group=grp_core)
float LOG_CAP = 30.0
use_body     = input.bool(true, "Liquidity Mode (Ignore Wicks)", group=grp_core)
tol_micro    = input.float(0.35, "Micro Touch Tol (%)", step=0.05, group=grp_core) / 100.0
slope_max    = input.float(0.20, "Max Slope (log/bar)", step=0.01, group=grp_core)
dup_slope    = input.float(0.06, "Dedup (Slope %)", step=0.01, group=grp_core)
dup_price    = input.float(0.35, "Dedup (Price %)", step=0.05, group=grp_core) / 100.0

grp_rank = "Advanced — Relevance / Ranking"
use_relevance   = input.bool(true, "Prefer Lines Near Price", group=grp_rank)
rel_strength    = input.float(0.55, "Relevance Strength (0-1)", minval=0.0, maxval=1.0, step=0.05, group=grp_rank)
rel_decay_atr   = input.float(0.35, "Relevance Decay (per ATR)", minval=0.05, maxval=2.0, step=0.05, group=grp_rank)

fp_guard_on = input.bool(true, "First-Paint Guard (avoid empty on load)", group=grp_rank)

min_sep_atr = input.float(0.30, "Clutter Guard — Min Separation (ATR)", minval=0.0, maxval=2.0, step=0.05, group=grp_rank)
slope_sanity = input.float(0.25, "Slope Sanity Penalty (0-1)", minval=0.0, maxval=1.0, step=0.05, group=grp_rank)
pool_mult = input.int(4, "Candidate Pool Multiplier", minval=2, maxval=8, group=grp_rank)

clean_autofill  = input.bool(true, "Clean Profile Auto-Fill", group=grp_rank)

qtag_mode = input.string("Minimal", "Q Tags", options=["Off","Minimal","Detailed"], group=grp_rank)
qtag_min_q = input.int(60, "Min Q Tag (0-100)", minval=0, maxval=100, group=grp_rank)
qtag_near_atr = 6.0
qtag_show_grade = false

qtag_fade_far = true
qtag_far_alpha = 22

qtag_show_low = true
qtag_low_alpha = 25

qstyle_on = true
qstyle_strength = 0.70
qstyle_range = 32

smart_focus_bal = true
focus_atr_bal = 12.0

show_confluence = input.bool(true, "Conf Tags (x2/x3)", group=grp_rank)
confluence_band_atr = input.float(0.9, "Conf Band (ATR)", minval=0.1, maxval=5.0, step=0.1, group=grp_rank)
confluence_near_atr = input.float(10.0, "Conf Dist Limit (ATR)", minval=0.0, maxval=40.0, step=0.5, group=grp_rank)

smart_focus = input.bool(true, "Smart Focus (Near Price) — Minimal", group=grp_rank)
focus_atr = input.float(8.0, "Focus Range (ATR) — Minimal", minval=0.0, maxval=30.0, step=0.5, group=grp_rank)

grp_mega = "Advanced — Mega (HTF Overlay)"
show_mega     = input.bool(true, "Show Mega Trends", group=grp_mega)
show_mega2    = input.bool(false, "Show Secondary Mega", group=grp_mega)
mega_tf       = input.string("W", "Mega TF", options=["W","M"], group=grp_mega)
mega_len      = input.int(5, "HTF Pivot Sensitivity", minval=2, group=grp_mega)
mega_mem      = input.int(600, "HTF Pivot Memory", minval=120, maxval=2000, group=grp_mega)
mega_min_bars = input.int(8, "Min Distance (HTF bars)", minval=6, group=grp_mega)
mega_anchor_n = input.int(10, "Anchor Candidates", minval=3, maxval=30, group=grp_mega)
mega_source   = input.string("Auto", "Mega Source", options=["Auto","HTF","Macro"], group=grp_mega)
macro_len      = input.int(18, "Macro Pivot Sens (fallback)", minval=4, maxval=60, group=grp_mega)
macro_mem      = input.int(900, "Macro Pivot Mem (fallback)", minval=200, maxval=2500, group=grp_mega)
tol_mega      = input.float(1.20, "Mega Touch Tol (%)", step=0.10, group=grp_mega) / 100.0
mega_tol_mult = input.float(1.0, "Mega Tol Mult", step=0.25, group=grp_mega)
mega_min_touch = input.int(2, "Mega Min Touches", minval=2, group=grp_mega)
mega_touch_pw = input.float(3.0, "Touch Weight Power", step=0.2, group=grp_mega)
mega_slope_d  = input.float(0.20, "Mega Max Slope (log/day)", step=0.01, group=grp_mega)
mega_extreme_boost = input.float(0.80, "Mega Extreme Anchor Bias", step=0.10, group=grp_mega)
mega_long_bonus    = input.float(0.35, "Mega Long-Length Bonus", step=0.05, group=grp_mega)
show_mega_cloud = input.bool(false,  "Mega Cloud (ATR Zone)", group=grp_mega)
mega_cloud_mult = input.float(1.0,  "Cloud Width (ATR x)", step=0.25, group=grp_mega)
mega_cloud_alpha = input.int(84,    "Cloud Alpha", minval=60, maxval=95, group=grp_mega)

grp_vis = "Advanced — Visuals"
show_ext  = input.bool(true, "Extend Right", group=grp_vis)
proj_horizon = input.int(0, "Proj Horizon (bars)", minval=0, maxval=2000, group=grp_vis)
show_lbl  = input.bool(true, "Labels", group=grp_vis)
lbl_size_opt = input.string("Normal", "Label Size", options=["Tiny","Small","Normal","Large"], group=grp_vis)
planner_label_mode = input.string("Key Events", "Planner Labels", options=["Off","Key Events","All Events"], group=grp_vis, tooltip="Controls the premium planner labels printed for major break/retest state changes. Key Events keeps the chart clean while preserving visible decision markers.")
planner_max_labels = input.int(8, "Max Planner Labels", minval=2, maxval=20, group=grp_vis, tooltip="Limits the number of visible planner labels so older labels are removed automatically and the chart remains readable.")
mega_lbl_pos = "Middle"
mega_lbl_gap_bars = 22
mega_lbl_bg = 76

grp_hud = "Panel / Status"
show_hud = input.bool(true, "Show Panel", group=grp_hud, tooltip="Shows or hides the AGPro decision panel. The panel is enabled by default for public-release readability.")
hud_pos_opt = input.string("Top Right", "Panel Location", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=grp_hud, tooltip="Selects where the decision panel is placed on the chart.")
hud_theme = input.string("AGPro Dark", "Panel Theme", options=["AGPro Dark","Light Slate","Color Coded","Showcase"], group=grp_hud, tooltip="Controls the panel color treatment while keeping the merged blue AGPro title row intact.")
hud_txt_size = input.string("Normal", "Panel Font Size", options=["Small","Normal","Large"], group=grp_hud, tooltip="Adjusts panel text size for different chart layouts.")
hud_bg_tr = hud_theme == "Light Slate" ? 0 : hud_theme == "AGPro Dark" ? 4 : 8

active_spotlight = input.bool(true, "Active Structure Spotlight", group=grp_vis)
vis_density = input.string("Balanced", "Visual Density", options=["Minimal","Balanced","Bold"], group=grp_vis)
micro_lbl_pos = "Left"
micro_lbl_gap_bars = 10

auto_lbl_avoid = true
lbl_stagger_atr = 0.12

grp_sig = "Advanced — Stability & Signals"
repaint_mode = input.string("Locked", "Line Stability", options=["Dynamic","Locked"], group=grp_sig)
replace_broken = input.bool(false, "Replace Broken Lines", group=grp_sig)
break_mode = input.string("Close", "Break Detect Mode", options=["Close","Wick","HL2"], group=grp_sig)
sig_close_only = input.bool(true, "Signals: Close Only", group=grp_sig)
sig_scope = input.string("Primary only", "Signal Scope (Micro/Meso)", options=["Primary only","Top 2","Top 3"], group=grp_sig)
dyn_alerts = input.bool(false, "Dynamic Alerts (alert)", group=grp_sig)
sig_cooldown = 3
sig_min_q = input.int(55, "Min Q for Signals (0-100)", minval=0, maxval=100, group=grp_sig)

sig_conf_filter = "Off"
micro_break_tol = input.float(0.25, "Micro Break Tol (%)", step=0.05, group=grp_sig) / 100.0
mega_break_tol  = input.float(0.60, "Mega Break Tol (%)", step=0.10, group=grp_sig) / 100.0
micro_retest_window = input.int(12, "Micro Retest Window (bars)", minval=1, group=grp_sig)
meso_retest_window  = input.int(18, "Meso Retest Window (bars)",  minval=1, group=grp_sig)
mega_retest_window  = input.int(24, "Mega Retest Window (bars)",  minval=1, group=grp_sig)
retest_tol      = input.float(0.20, "Retest Tolerance (%)", step=0.05, group=grp_sig) / 100.0
show_sig        = input.bool(true, "Signals (Break/Retest) <= 1D", group=grp_sig)
meso_sig = false
sig_size_opt = "Small"
max_lookback    = input.int(4500, "Max Trend Lookback (bars)", minval=500, maxval=5000, group=grp_sig)

grp_meso = "Advanced — Meso Engine"
show_meso      = input.bool(true, "Show Meso Trends", group=grp_meso)
meso_len       = input.int(9,  "Pivot Sensitivity (Meso)", minval=2, group=grp_meso)
meso_min_dist  = input.int(18, "Min Pivot Gap (bars)", minval=8, group=grp_meso)
meso_anchor_n  = input.int(6,  "Anchor Candidates", minval=1, maxval=30, group=grp_meso)
meso_top_n     = input.int(2,  "Max Active Meso Lines", minval=1, maxval=5, group=grp_meso)
meso_min_touch = input.int(2,  "Meso Min Touches", minval=2, group=grp_meso)
meso_tol       = input.float(0.45, "Meso Touch Tol (%)", step=0.05, group=grp_meso) / 100.0
meso_break_tol = input.float(0.40, "Meso Break Tol (%)", step=0.05, group=grp_meso) / 100.0
meso_slope_max = input.float(0.15, "Max Slope Meso (log/bar)", step=0.01, group=grp_meso)
meso_dup_slope = input.float(0.06, "Dedup (Slope %) - Meso", step=0.01, group=grp_meso)
meso_dup_price = input.float(0.45, "Dedup (Price %) - Meso", step=0.05, group=grp_meso) / 100.0
float atr14_cs      = ta.atr(14)
float atr14_cs_safe = math.max(atr14_cs, syminfo.mintick)

f_auto_profile() =>
    string p = "Balanced"
    bool intr = timeframe.isintraday
    int  m    = timeframe.multiplier

    if intr
        if auto_tf_map == "Aggressive Clean"
            p := m <= 240 ? "Clean Trader" : "Balanced"
        else if auto_tf_map == "Full Context"
            p := m <= 30 ? "Balanced" : m <= 240 ? "Analyst" : "Analyst"
        else
            p := m <= 30 ? "Clean Trader" : m <= 240 ? "Balanced" : "Analyst"
    else if timeframe.isdaily
        p := auto_tf_map == "Aggressive Clean" ? "Clean Trader" : "Balanced"
    else if timeframe.isweekly
        p := auto_tf_map == "Aggressive Clean" ? "Balanced" : "Analyst"
    else if timeframe.ismonthly
        p := "Presentation"

    p

string profile_eff = profile_mode == "Auto by Timeframe" ? f_auto_profile() : manual_profile
bool   prof_custom = profile_eff == "Custom (Advanced)"
bool   prof_clean  = profile_eff == "Clean Trader"
bool   prof_bal    = profile_eff == "Balanced"
bool   prof_anal   = profile_eff == "Analyst"
bool   prof_pres   = profile_eff == "Presentation"

string vis_density_eff =
     density_override != "Auto" ? density_override :
     prof_custom ? vis_density :
     prof_clean ? "Minimal" :
     prof_pres  ? "Bold" :
     "Balanced"

string line_weight_eff =
     line_weight_override != "Auto" ? line_weight_override :
     prof_custom ? "Normal" :
     prof_clean ? "UltraThin" :
     "Thin"

float width_mult_eff =
     line_weight_eff == "UltraThin" ? 0.70 :
     line_weight_eff == "Thin"      ? 0.85 :
     1.00

bool show_lbl_eff =
     labels_override == "On"  ? true :
     labels_override == "Off" ? false :
     prof_custom ? show_lbl :
     prof_pres or prof_anal

bool show_sig_eff =
     signals_override == "On"  ? true :
     signals_override == "Off" ? false :
     prof_custom ? show_sig :
     not prof_clean

bool show_meso_sig_eff = show_sig_eff and (prof_custom ? meso_sig : (prof_pres or prof_anal))

string repaint_mode_eff =
     stability_override != "Auto" ? stability_override :
     prof_custom ? repaint_mode :
     "Locked"

bool replace_broken_eff =
     broken_override == "Replace"    ? true :
     broken_override == "Keep Broken"? false :
     prof_custom ? replace_broken :
     true

int top_n_eff =
     prof_custom ? top_n :
     prof_clean ? 2 :
     prof_anal  ? 4 :
     3

int meso_top_n_eff =
     prof_custom ? meso_top_n :
     prof_clean ? 1 :
     prof_pres  ? 3 :
     2

bool show_meso_eff =
     prof_custom ? show_meso :
     prof_clean ? false :
     show_meso

int fp_min_bars = 650
bool fp_thin_hist = fp_guard_on and bar_index < fp_min_bars

bool use_relevance_eff =
     prof_custom ? use_relevance :
     true

float rel_strength_eff =
     not use_relevance_eff ? 0.0 :
     prof_custom ? rel_strength :
     prof_clean ? 0.70 :
     prof_anal  ? 0.35 :
     0.50

float rel_decay_eff =
     prof_custom ? rel_decay_atr :
     rel_decay_atr

float min_sep_atr_eff =
     prof_custom ? min_sep_atr :
     prof_clean ? 0.38 :
     prof_anal  ? 0.15 :
     0.28

float slope_sanity_eff =
     prof_custom ? slope_sanity :
     prof_clean ? 0.30 :
     prof_anal  ? 0.15 :
     0.22

int pool_mult_eff =
     prof_custom ? pool_mult :
     (prof_anal or prof_pres) ? math.max(pool_mult, 4) :
     pool_mult

bool clean_autofill_eff =
     prof_custom ? clean_autofill :
     prof_clean
if fp_thin_hist
    min_sep_atr_eff := min_sep_atr_eff * 0.65
    slope_sanity_eff := slope_sanity_eff * 0.75
    pool_mult_eff := math.min(pool_mult_eff + 2, 8)
    clean_autofill_eff := true

bool tf_low  = timeframe.isintraday and timeframe.multiplier <= 60
bool tf_mid  = timeframe.isintraday and timeframe.multiplier > 60 and timeframe.multiplier <= 240

string mega_mode_eff =
     mega_overlay_override != "Auto" ? mega_overlay_override :
     prof_custom ? "Auto" :
     (prof_clean or tf_low) ? "Lines Only" :
     (vis_density_eff == "Minimal") ? "Lines Only" :
     tf_mid ? "Full" :
     "Full"

bool show_mega_eff  = show_mega  and mega_mode_eff != "Off"
bool show_mega2_eff = show_mega2 and show_mega_eff and mega_mode_eff == "Full" and not (prof_clean and not prof_custom)

bool show_mega_cloud_eff =
     show_mega_cloud and show_mega_eff and mega_mode_eff == "Full" and (vis_density_eff != "Minimal") and not tf_low and not (prof_clean and not prof_custom)

// AGPro brand palette
c_res  = color.rgb(244, 114, 182)   // bearColor  #F472B6
c_sup  = color.rgb(34, 197, 166)    // bullColor  #22C5A6
c_resM = c_res
c_supM = c_sup
c_mega = color.rgb(129, 140, 248)   // accentColor #818CF8
c_ag_blue = color.rgb(37, 99, 235)  // headerBg   #2563EB
c_header_text = color.rgb(245, 247, 250)
c_panel_bg = color.rgb(15, 23, 42)
c_panel_border = color.rgb(51, 65, 85)
c_panel_label = color.rgb(148, 163, 184)
c_panel_value = color.rgb(226, 232, 240)
c_neutral = color.rgb(245, 189, 92)

f_hud_pos(simple string s) =>
    s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Left" ? position.bottom_left : position.top_right

var table hud = na
var bool hud_rendered_once = false
var string hud_last_sig = ""
var string hud_last_pos_opt = ""

f_tf_ms(tf) =>
    float s = timeframe.in_seconds(tf)
    float ms = na(s) or s <= 0 ? (tf == "M" ? 30.0 * 86400000.0 : tf == "W" ? 7.0 * 86400000.0 : 86400000.0) : s * 1000.0
    ms

f_step_ms() =>
    float s = timeframe.in_seconds(timeframe.period)
    float ms = na(s) or s <= 0 ? 60000.0 : s * 1000.0
    int(ms)

f_lbl_size(simple string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : size.large

float mega_tf_ms_cs  = f_tf_ms(mega_tf)
int   step_ms_cs     = f_step_ms()
lbl_size_eff_cs      = f_lbl_size(lbl_size_opt)

f_val(x) => use_log ? math.log(math.max(x, 1e-10)) : x
f_inv(x) => use_log ? math.exp(math.max(-LOG_CAP, math.min(LOG_CAP, x))) : x
f_tol_micro(p) => p * tol_micro
f_tol_meso(p) => p * meso_tol
f_tol_mega(p)  => p * tol_mega * mega_tol_mult

f_star_str(int n) =>
    n == 5 ? "★★★★★" :
     n == 4 ? "★★★★" :
     n == 3 ? "★★★" :
     n == 2 ? "★★" : "★"

f_mega_star_count(int tc, bool bk, float bars_len) =>
    int st = tc >= 10 ? 5 : tc >= 7 ? 4 : tc >= 5 ? 3 : tc >= 3 ? 2 : 1
    if bars_len >= 16
        st += 1
    if bars_len >= 32
        st += 1
    if bk
        st -= 1
    st := math.max(1, math.min(5, st))
    st

f_grade(int q) =>
    q >= 85 ? "A" : q >= 70 ? "B" : q >= 55 ? "C" : "D"

f_score_tier(int q) =>
    q >= 75 ? "Strong" : q >= 60 ? "Valid" : q >= 45 ? "Early" : "Weak"

f_q_line(int t1, int t2, int tot, int viol, float slope, float y_now, float atr_safe, int touch_floor, float slope_cap) =>
    float touchN = math.min(1.0, math.max(0.0, (float(tot) - float(touch_floor)) / 6.0))
    float touchS = 30.0 * touchN

    int   age    = math.max(0, bar_index - t1)
    float freshS = 20.0 * math.exp(-float(age) / 250.0)

    float slopeFrac = math.min(1.0, math.abs(slope) / math.max(slope_cap, 1e-12))
    float geomS     = 15.0 * (1.0 - math.pow(slopeFrac, 1.2))

    float distAtr = atr_safe > 0 ? math.abs(y_now - close) / atr_safe : 10.0
    float relS    = 10.0 * math.exp(-distAtr * 0.55)

    float violP = 25.0 * math.min(1.0, float(viol) / 3.0)

    float qf = touchS + freshS + geomS + relS - violP
    int q = int(math.round(math.max(0.0, math.min(100.0, qf))))
    q

f_q_micro(int t1, int t2, int tot, int viol, float slope, float y_now, float atr_safe, float slope_cap) =>
    f_q_line(t1, t2, tot, viol, slope, y_now, atr_safe, min_touch, slope_cap)

var float[] ph_price = array.new_float()
var float[] ph_body  = array.new_float()
var int[]   ph_time  = array.new_int()

var float[] pl_price = array.new_float()
var float[] pl_body  = array.new_float()
var int[]   pl_time  = array.new_int()

ph = ta.pivothigh(high, len, len)
pl = ta.pivotlow(low,  len, len)

int MAX_MICRO_MEM = int(math.round(math.max(400.0, math.min(1200.0, float(max_lookback) * 0.25))))

if not na(ph)
    array.unshift(ph_price, f_val(ph))
    array.unshift(ph_body,  f_val(math.max(open[len], close[len])))
    array.unshift(ph_time,  bar_index[len])
    if array.size(ph_price) > MAX_MICRO_MEM
        array.pop(ph_price)
        array.pop(ph_body)
        array.pop(ph_time)
    while array.size(ph_time) > 0 and (bar_index - array.get(ph_time, array.size(ph_time)-1)) > max_lookback
        array.pop(ph_price)
        array.pop(ph_body)
        array.pop(ph_time)

if not na(pl)
    array.unshift(pl_price, f_val(pl))
    array.unshift(pl_body,  f_val(math.min(open[len], close[len])))
    array.unshift(pl_time,  bar_index[len])
    if array.size(pl_price) > MAX_MICRO_MEM
        array.pop(pl_price)
        array.pop(pl_body)
        array.pop(pl_time)
    while array.size(pl_time) > 0 and (bar_index - array.get(pl_time, array.size(pl_time)-1)) > max_lookback
        array.pop(pl_price)
        array.pop(pl_body)
        array.pop(pl_time)

var float[] phm_price = array.new_float()
var float[] phm_body  = array.new_float()
var int[]   phm_time  = array.new_int()

var float[] plm_price = array.new_float()
var float[] plm_body  = array.new_float()
var int[]   plm_time  = array.new_int()

phm = ta.pivothigh(high, meso_len, meso_len)
plm = ta.pivotlow(low,  meso_len, meso_len)

MAX_MESO_MEM = 600

if show_meso_eff and not na(phm)
    array.unshift(phm_price, f_val(phm))
    array.unshift(phm_body,  f_val(math.max(open[meso_len], close[meso_len])))
    array.unshift(phm_time,  bar_index[meso_len])
    if array.size(phm_price) > MAX_MESO_MEM
        array.pop(phm_price)
        array.pop(phm_body)
        array.pop(phm_time)
    while array.size(phm_time) > 0 and (bar_index - array.get(phm_time, array.size(phm_time)-1)) > max_lookback
        array.pop(phm_price)
        array.pop(phm_body)
        array.pop(phm_time)

if show_meso_eff and not na(plm)
    array.unshift(plm_price, f_val(plm))
    array.unshift(plm_body,  f_val(math.min(open[meso_len], close[meso_len])))
    array.unshift(plm_time,  bar_index[meso_len])
    while array.size(plm_time) > 0 and (bar_index - array.get(plm_time, array.size(plm_time)-1)) > max_lookback
        array.pop(plm_price)
        array.pop(plm_body)
        array.pop(plm_time)
    if array.size(plm_price) > MAX_MESO_MEM
        array.pop(plm_price)
        array.pop(plm_body)
        array.pop(plm_time)

var float[] mxh_p = array.new_float()
var float[] mxh_b = array.new_float()
var int[]   mxh_t = array.new_int()

var float[] mxl_p = array.new_float()
var float[] mxl_b = array.new_float()
var int[]   mxl_t = array.new_int()

var float[] macro_ph_price = mxh_p
var float[] macro_ph_body  = mxh_b
var int[]   macro_ph_time  = mxh_t
var float[] macro_pl_price = mxl_p
var float[] macro_pl_body  = mxl_b
var int[]   macro_pl_time  = mxl_t

mxh = ta.pivothigh(high, macro_len, macro_len)
mxl = ta.pivotlow(low,  macro_len, macro_len)

if not na(mxh)
    array.unshift(mxh_p, f_val(mxh))
    array.unshift(mxh_b, f_val(math.max(open[macro_len], close[macro_len])))
    array.unshift(mxh_t, time[macro_len])
    if array.size(mxh_p) > macro_mem
        array.pop(mxh_p)
        array.pop(mxh_b)
        array.pop(mxh_t)

if not na(mxl)
    array.unshift(mxl_p, f_val(mxl))
    array.unshift(mxl_b, f_val(math.min(open[macro_len], close[macro_len])))
    array.unshift(mxl_t, time[macro_len])
    if array.size(mxl_p) > macro_mem
        array.pop(mxl_p)
        array.pop(mxl_b)
        array.pop(mxl_t)

int POOL = 10
var line[]  res_core = array.new_line()
var line[]  res_glow = array.new_line()
var label[] res_lbl  = array.new_label()

var line[]  sup_core = array.new_line()
var line[]  sup_glow = array.new_line()
var label[] sup_lbl  = array.new_label()

int POOL_MESO = 8
var line[]  resM_core = array.new_line()
var line[]  resM_glow = array.new_line()
var label[] resM_lbl  = array.new_label()

var line[]  supM_core = array.new_line()
var line[]  supM_glow = array.new_line()
var label[] supM_lbl  = array.new_label()
f_init_pool(c_arr, g_arr, l_arr, k) =>
    if barstate.isfirst
        for _ = 1 to k
            array.push(c_arr, line.new(na, na, na, na))
            array.push(g_arr, line.new(na, na, na, na))
            array.push(l_arr, label.new(na, na, "", style=label.style_label_left, textcolor=color.new(color.white, 0), color=color.new(color.black, 100), size=size.tiny))

f_reset(i, c_arr, g_arr, l_arr) =>
    if i < array.size(c_arr)
        line.set_xy1(array.get(c_arr, i), na, na)
        line.set_xy2(array.get(c_arr, i), na, na)
        line.set_xy1(array.get(g_arr, i), na, na)
        line.set_xy2(array.get(g_arr, i), na, na)
        label.set_xy(array.get(l_arr, i), na, na)
        label.set_text(array.get(l_arr, i), "")

f_init_pool(res_core, res_glow, res_lbl, POOL)
f_init_pool(sup_core, sup_glow, sup_lbl, POOL)
f_init_pool(resM_core, resM_glow, resM_lbl, POOL_MESO)
f_init_pool(supM_core, supM_glow, supM_lbl, POOL_MESO)

var label qtagR_lbl = na
var label qtagS_lbl = na
var label qtagMR_lbl = na
var label qtagMS_lbl = na

var label confR_lbl = na
var label confS_lbl = na
var int   confR_cnt = 0
var int   confS_cnt = 0
if barstate.isfirst
    qtagR_lbl := label.new(bar_index, close, "", style=label.style_label_down, textcolor=c_res, color=color.new(color.black, 100), size=size.small)
    qtagS_lbl := label.new(bar_index, close, "", style=label.style_label_up,   textcolor=c_sup, color=color.new(color.black, 100), size=size.small)
    qtagMR_lbl := label.new(bar_index, close, "", style=label.style_label_down, textcolor=c_resM, color=color.new(color.black, 100), size=size.small)
    qtagMS_lbl := label.new(bar_index, close, "", style=label.style_label_up,   textcolor=c_supM, color=color.new(color.black, 100), size=size.small)
    confR_lbl := label.new(bar_index, close, "", style=label.style_label_down, textcolor=c_res, color=color.new(color.black, 100), size=size.tiny)
    confS_lbl := label.new(bar_index, close, "", style=label.style_label_up,   textcolor=c_sup, color=color.new(color.black, 100), size=size.tiny)

f_ensure_size_int(int[] a, int n) =>
    while array.size(a) > n
        array.pop(a)
    while array.size(a) < n
        array.push(a, na)

f_ensure_size_float(float[] a, int n) =>
    while array.size(a) > n
        array.pop(a)
    while array.size(a) < n
        array.push(a, na)

f_ensure_size_bool(bool[] a, int n) =>
    while array.size(a) > n
        array.pop(a)
    while array.size(a) < n
        array.push(a, false)
f_has_slot_int(int[] a, int idx) =>
    bool _ok = false
    if idx >= 0 and idx < array.size(a)
        _ok := not na(array.get(a, idx))
    _ok

f_ai(int[] a, int idx) =>
    idx >= 0 and idx < array.size(a) ? array.get(a, idx) : na

f_af(float[] a, int idx) =>
    idx >= 0 and idx < array.size(a) ? array.get(a, idx) : na

f_ab(bool[] a, int idx) =>
    idx >= 0 and idx < array.size(a) ? array.get(a, idx) : false

var int[]   microR_t2 = array.new_int()
var float[] microR_p2 = array.new_float()
var int[]   microR_t1 = array.new_int()
var float[] microR_p1 = array.new_float()
var int[]   microR_tc = array.new_int()
var float[] microR_sl = array.new_float()
var float[] microR_y  = array.new_float()
var bool[]  microR_br = array.new_bool()

var int[]   microS_t2 = array.new_int()
var float[] microS_p2 = array.new_float()
var int[]   microS_t1 = array.new_int()
var float[] microS_p1 = array.new_float()
var int[]   microS_tc = array.new_int()
var float[] microS_sl = array.new_float()
var float[] microS_y  = array.new_float()
var bool[]  microS_br = array.new_bool()

var int[]   microR_vi = array.new_int()
var int[]   microR_q  = array.new_int()

var int[]   microS_vi = array.new_int()
var int[]   microS_q  = array.new_int()

var int[]   mesoR_q  = array.new_int()

var int[]   mesoS_q  = array.new_int()

var int[]   mesoR_t2 = array.new_int()
var float[] mesoR_p2 = array.new_float()
var int[]   mesoR_t1 = array.new_int()
var float[] mesoR_p1 = array.new_float()
var int[]   mesoR_tc = array.new_int()
var float[] mesoR_sl = array.new_float()
var float[] mesoR_y  = array.new_float()
var bool[]  mesoR_br = array.new_bool()

var int[]   mesoS_t2 = array.new_int()
var float[] mesoS_p2 = array.new_float()
var int[]   mesoS_t1 = array.new_int()
var float[] mesoS_p1 = array.new_float()
var int[]   mesoS_tc = array.new_int()
var float[] mesoS_sl = array.new_float()
var float[] mesoS_y  = array.new_float()
var bool[]  mesoS_br = array.new_bool()

f_break_src_up() => break_mode == "Close" ? close : break_mode == "HL2" ? hl2 : high
f_break_src_dn() => break_mode == "Close" ? close : break_mode == "HL2" ? hl2 : low

f_is_break(bool is_res, float y_line, float tol_pct) =>
    bool ok = not sig_close_only or barstate.isconfirmed
    float up = f_break_src_up()
    float dn = f_break_src_dn()
    ok and (is_res ? (up > (y_line * (1.0 + tol_pct))) : (dn < (y_line * (1.0 - tol_pct))))
f_is_retest(bool is_res, float y_line) =>
    bool ok = not sig_close_only or barstate.isconfirmed
    ok and (is_res ? (low <= (y_line * (1.0 + retest_tol)) and close > y_line) : (high >= (y_line * (1.0 - retest_tol)) and close < y_line))
f_render_line(i, is_res, t2, p2, t1, p1, tc, slope, bool broken, bool is_meso, int qv_in) =>
    int w_core = is_meso ? (tc >= 6 ? 3 : tc >= 4 ? 2 : 1) : (tc >= 6 ? 4 : tc >= 4 ? 3 : 2)
    int w_glow = math.min(4, w_core + 1)

    bool _dens_min  = vis_density_eff == "Minimal"
    bool _dens_bal  = vis_density_eff == "Balanced"
    bool _dens_bold = vis_density_eff == "Bold"
    if _dens_min
        w_core := math.max(1, w_core - 1)
    else if _dens_bold
        w_core := math.min(6, w_core + 1)
    w_glow := math.min(5, w_core + 1)

    w_core := math.max(1, int(math.round(float(w_core) * width_mult_eff)))
    w_glow := math.min(5, math.max(1, w_core + 1))

    if i > 0 and not _dens_min
        if w_core > 1
            w_core -= 1
        if i > 1 and w_core > 1 and not _dens_bold and not _dens_bal
            w_core -= 1
    w_glow := math.min(5, math.max(1, w_core + (i == 0 ? 1 : 0)))

    st_base = tc >= 3 ? line.style_solid : line.style_dashed
    st = broken ? line.style_dotted : st_base

    color base = is_res ? c_res : c_sup
    int alpha_core = is_meso ? 45 : 0
    if _dens_min
        alpha_core += is_meso ? 20 : 10
    int alpha_final = broken ? (is_meso ? 82 : 75) : alpha_core
    if _dens_min
        alpha_final := math.min(95, alpha_final + 5)

    int alpha_glow = broken ? 90 : (is_meso ? 86 : 78)
    if qstyle_on and qv_in > 0 and not broken
        float _qn = math.min(1.0, math.max(0.0, float(qv_in) / 100.0))
        int   _extra = int(math.round(qstyle_strength * (1.0 - _qn) * float(qstyle_range)))
        alpha_final := math.min(95, alpha_final + _extra)
        alpha_glow  := math.min(95, alpha_glow  + int(math.round(qstyle_strength * (1.0 - _qn) * float(qstyle_range) * 0.40)))

    if i > 0
        int _rf = i == 1 ? (is_meso ? 5 : 7) : (is_meso ? 8 : 10)
        if _dens_min
            _rf := math.max(0, _rf - 1)
        alpha_final := math.min(96, alpha_final + _rf)
        alpha_glow  := math.min(97, alpha_glow + (i == 1 ? 6 : 10))
    if broken
        if w_core > 1
            w_core -= 1
        alpha_final := math.min(97, alpha_final + (i > 0 ? 4 : 2))
        alpha_glow  := math.min(98, alpha_glow + 2)

    bool _spot = active_spotlight and not broken and i == 0
    if _spot
        w_core := math.min(6, w_core + (is_meso ? 1 : 2))
        w_glow := math.min(6, math.max(w_glow, w_core + 1))
        alpha_final := math.max(0, alpha_final - (is_meso ? 12 : 18))
        alpha_glow  := math.max(0, alpha_glow  - (is_meso ? 10 : 14))
        st := line.style_solid
    else if active_spotlight and not broken and i > 0
        alpha_final := math.min(97, alpha_final + (is_meso ? 12 : 16))
        alpha_glow  := math.min(98, alpha_glow  + (is_meso ? 10 : 14))

    color col_core = color.new(base, alpha_final)
    color col_glow = color.new(base, alpha_glow)

    float y_now = f_inv(p2 + slope * float(bar_index - t2))
    int   x2 = show_ext ? bar_index : t1
    if show_ext and proj_horizon > 0
        x2 := bar_index + proj_horizon
    float y2 = show_ext ? f_inv(p2 + slope * float(x2 - t2)) : f_inv(p1)

    float _atrF = atr14_cs_safe
    float _distA = not na(y_now) ? (math.abs(y_now - close) / _atrF) : 0.0
    bool  _focus_hide = false
    if _distA > 0
        if smart_focus and _dens_min and focus_atr > 0
            _focus_hide := i > 0 and _distA > focus_atr
        else if smart_focus_bal and _dens_bal and focus_atr_bal > 0
            int _minRank = is_meso ? 1 : 2
            _focus_hide := i >= _minRank and _distA > focus_atr_bal

    line  lc = is_meso ? (is_res ? array.get(resM_core, i) : array.get(supM_core, i)) : (is_res ? array.get(res_core, i) : array.get(sup_core, i))
    line  lg = is_meso ? (is_res ? array.get(resM_glow, i) : array.get(supM_glow, i)) : (is_res ? array.get(res_glow, i) : array.get(sup_glow, i))
    label lb = is_meso ? (is_res ? array.get(resM_lbl,  i) : array.get(supM_lbl,  i)) : (is_res ? array.get(res_lbl,  i) : array.get(sup_lbl,  i))

    bool _too_old = (bar_index - t2) > max_lookback or (bar_index - t1) > max_lookback or _focus_hide
    if _too_old
        line.set_xy1(lc, na, na)
        line.set_xy2(lc, na, na)
        line.set_xy1(lg, na, na)
        line.set_xy2(lg, na, na)
        label.set_xy(lb, na, na)
        label.set_text(lb, "")
    else
        line.set_xy1(lc, t2, f_inv(p2))
        line.set_xy2(lc, x2, y2)
        line.set_color(lc, col_core)
        line.set_width(lc, w_core)
        line.set_style(lc, st)
        line.set_extend(lc, (show_ext and proj_horizon == 0) ? extend.right : extend.none)
        bool _hide_glow = active_spotlight ? (not _spot) : ((_dens_min and not _spot) or (_dens_bal and i > 1 and not _spot))
        if _hide_glow
            line.set_xy1(lg, na, na)
            line.set_xy2(lg, na, na)
        else
            line.set_xy1(lg, t2, f_inv(p2))
            line.set_xy2(lg, x2, y2)
            line.set_color(lg, col_glow)
            line.set_width(lg, w_glow)
            line.set_style(lg, line.style_solid)
            line.set_extend(lg, (show_ext and proj_horizon == 0) ? extend.right : extend.none)

        if show_lbl_eff
            float yL = f_inv(p2 + slope * float(bar_index - t2))
            int   xL = bar_index
            if micro_lbl_pos == "Left"
                xL := t2
                yL := f_inv(p2)
            else if micro_lbl_pos == "Middle"
                xL := int(math.round((t2 + bar_index) / 2.0))
                yL := f_inv(p2 + slope * float(xL - t2))
            else
                int _gap = micro_lbl_gap_bars
                if auto_lbl_avoid and _gap == 0
                    _gap := 3
                if show_ext and _gap > 0
                    xL := bar_index + _gap * (i + 1)
                    yL := f_inv(p2 + slope * float(xL - t2))
                if auto_lbl_avoid and lbl_stagger_atr > 0 and not (show_ext and _gap > 0)
                    float _step = atr14_cs_safe * lbl_stagger_atr
                    yL += (is_res ? 1.0 : -1.0) * _step * float(i)
                if auto_lbl_avoid
                    if show_ext and _gap > 0 and i > 0
                        xL += i > 1 ? 2 : 1
                    if lbl_stagger_atr > 0
                        yL += (is_res ? 1.0 : -1.0) * (atr14_cs_safe * lbl_stagger_atr * 0.30) * float(i + 1)
                if show_ext
                    int _lblCap = proj_horizon > 0 ? (bar_index + proj_horizon + 4) : (bar_index + 40)
                    xL := math.min(xL, _lblCap)

            string side = is_res ? "R" : "S"
            string pref = is_meso ? "M " : ""
            string qpref = "Q"
            string txt  = pref + side + str.tostring(tc)
            int qv = qv_in
            if qtag_mode != "Off"
                if i == 0 and qv > 0
                    txt += " " + qpref + str.tostring(qv)
            if broken
                txt += " x"

            label.set_xy(lb, xL, yL)
            label.set_text(lb, txt)
            label.set_style(lb, is_res ? label.style_label_down : label.style_label_up)
            int _lblA  = i == 0 ? 0 : i == 1 ? (is_meso ? 14 : 10) : (is_meso ? 28 : 22)
            int _lblBg = i == 0 ? 90 : i == 1 ? 92 : 94
            if broken
                _lblA := math.min(90, _lblA + 12)
                _lblBg := math.min(98, _lblBg + 2)
            label.set_textcolor(lb, _spot ? color.new(color.white, 0) : color.new(base, _lblA))
            label.set_color(lb, _spot ? color.new(base, 68) : color.new(color.black, _lblBg))
            label.set_size(lb, lbl_size_eff_cs)
        else
            label.set_xy(lb, na, na)
            label.set_text(lb, "")

f_swap_float(float[] a, int i, int j) =>
    float tmp = array.get(a, i)
    array.set(a, i, array.get(a, j))
    array.set(a, j, tmp)

f_swap_int(int[] a, int i, int j) =>
    int tmp = array.get(a, i)
    array.set(a, i, array.get(a, j))
    array.set(a, j, tmp)

f_swap_bool(bool[] a, int i, int j) =>
    bool tmp = array.get(a, i)
    array.set(a, i, array.get(a, j))
    array.set(a, j, tmp)

f_scan(is_res) =>
    float[] src_p = is_res ? ph_price : pl_price
    float[] src_b = is_res ? ph_body  : pl_body
    int[]   src_t = is_res ? ph_time  : pl_time

    for i = 0 to POOL - 1
        f_reset(i, is_res ? res_core : sup_core, is_res ? res_glow : sup_glow, is_res ? res_lbl : sup_lbl)

    int n = array.size(src_p)
    if n >= 2

        float _atr      = atr14_cs
        float _atr_safe = atr14_cs_safe
        bool  _use_rel  = rel_strength_eff > 0
        int anchors = math.min(micro_anchor_n, n - 1)
        int limit   = math.min(n - 1, 250)
        int keepN   = math.min(40, top_n_eff * pool_mult_eff)

        float[] scores = array.new_float()
        float[] p2s    = array.new_float()
        int[]   t2s    = array.new_int()
        float[] p1s    = array.new_float()
        int[]   t1s    = array.new_int()
        int[]   tots   = array.new_int()
        float[] slps   = array.new_float()
        float[] ynows  = array.new_float()

        int[]   vios   = array.new_int()
        bool[]  bks    = array.new_bool()
        int[]   qs     = array.new_int()

        for j = 0 to anchors - 1
            float p1 = array.get(src_p, j)
            int   t1 = array.get(src_t, j)

            for i = j + 1 to limit
                float p2 = array.get(src_p, i)
                int   t2 = array.get(src_t, i)

                if (t1 - t2) > min_dist and (bar_index - t2) <= max_lookback and (bar_index - t1) <= max_lookback
                    float slope = (p1 - p2) / float(t1 - t2)

                    if math.abs(slope) > 0.000001 and math.abs(slope) < slope_max
                        bool bk = false
                        int  tc = 0
                        int  viol = 0

                        for k = 0 to i - 1
                            if k != j
                                int   tk = array.get(src_t, k)
                                float pk_body = use_body ? array.get(src_b, k) : array.get(src_p, k)
                                float body_real = f_inv(pk_body)

                                float lk_log  = p2 + slope * float(tk - t2)
                                float lk_real = f_inv(lk_log)

                                float tol = f_tol_micro(lk_real)

                                bool between = tk < t1
                                if between
                                    if is_res and body_real > (lk_real + tol)
                                        viol += 1
                                    if (not is_res) and body_real < (lk_real - tol)
                                        viol += 1
                                else
                                    if is_res and body_real > (lk_real + tol)
                                        bk := true
                                    if (not is_res) and body_real < (lk_real - tol)
                                        bk := true

                                float wick_real = f_inv(array.get(src_p, k))
                                if math.abs(wick_real - lk_real) <= tol
                                    tc += 1

                        int tot = 2 + tc
                        if tot >= min_touch
                            float time_w  = math.log(1 + float(t1 - t2))
                            float touch_w = math.pow(float(tot), 2.6)
                            float sc      = touch_w * time_w

                            sc := sc / (1.0 + viol * 0.75)
                            if bk
                                sc := sc * 0.70

                            float y_now_log = p2 + slope * float(bar_index - t2)
                            float y_now     = f_inv(y_now_log)

                            if slope_sanity_eff > 0
                                float slope_frac = math.min(math.abs(slope) / math.max(slope_max, 1e-12), 1.0)
                                float slope_fac  = 1.0 - slope_sanity_eff * math.pow(slope_frac, 1.35)
                                sc := sc * math.max(slope_fac, 0.10)

                            if _use_rel
                                float dist_atr = math.abs(y_now - close) / _atr_safe
                                float prox     = math.exp(-dist_atr * rel_decay_eff)
                                float rel_fac  = (1.0 - rel_strength_eff) + (rel_strength_eff * prox)
                                sc := sc * rel_fac

                            int q = f_q_line(t1, t2, tot, viol, slope, y_now, _atr_safe, min_touch, slope_max)

                            bool dup = false
                            int n_d = array.size(slps)
                            if n_d > 0
                                for d = 0 to n_d - 1
                                    float ex_s = array.get(slps, d)
                                    float ex_y = array.get(ynows, d)
                                    bool slope_close = math.abs(slope - ex_s) < (math.max(math.abs(ex_s), 1e-12) * dup_slope)
                                    bool y_close     = math.abs(y_now - ex_y) < (ex_y * dup_price)
                                    bool sep_close   = (min_sep_atr_eff > 0) and (math.abs(y_now - ex_y) < (_atr_safe * min_sep_atr_eff))
                                    if (slope_close and y_close) or sep_close
                                        dup := true
                                        break

                            if not dup
                                array.push(scores, sc)
                                array.push(p2s,    p2)
                                array.push(t2s,    t2)
                                array.push(p1s,    p1)
                                array.push(t1s,    t1)
                                array.push(tots,   tot)
                                array.push(slps,   slope)
                                array.push(ynows,  y_now)
                                array.push(vios,   viol)
                                array.push(bks,    bk)
                                array.push(qs,     q)

                                int pos = array.size(scores) - 1
                                while pos > 0
                                    if array.get(scores, pos) > array.get(scores, pos - 1)
                                        f_swap_float(scores, pos, pos - 1)
                                        f_swap_float(p2s,    pos, pos - 1)
                                        f_swap_int(t2s,      pos, pos - 1)
                                        f_swap_float(p1s,    pos, pos - 1)
                                        f_swap_int(t1s,      pos, pos - 1)
                                        f_swap_int(tots,     pos, pos - 1)
                                        f_swap_float(slps,   pos, pos - 1)
                                        f_swap_float(ynows,  pos, pos - 1)
                                        f_swap_int(vios,     pos, pos - 1)
                                        f_swap_bool(bks,     pos, pos - 1)
                                        f_swap_int(qs,       pos, pos - 1)
                                        pos -= 1
                                    else
                                        break

                                if array.size(scores) > keepN
                                    array.pop(scores)
                                    array.pop(p2s)
                                    array.pop(t2s)
                                    array.pop(p1s)
                                    array.pop(t1s)
                                    array.pop(tots)
                                    array.pop(slps)
                                    array.pop(ynows)
                                    array.pop(qs)
                                    array.pop(vios)
                                    array.pop(bks)

        bool locked = repaint_mode_eff == "Locked"
        int nslots = top_n_eff

        if locked
            if is_res
                f_ensure_size_int(microR_t2, nslots)
                f_ensure_size_float(microR_p2, nslots)
                f_ensure_size_int(microR_t1, nslots)
                f_ensure_size_float(microR_p1, nslots)
                f_ensure_size_int(microR_tc, nslots)
                f_ensure_size_int(microR_vi, nslots)
                f_ensure_size_int(microR_q,  nslots)
                f_ensure_size_float(microR_sl, nslots)
                f_ensure_size_float(microR_y, nslots)
                f_ensure_size_bool(microR_br, nslots)
            else
                f_ensure_size_int(microS_t2, nslots)
                f_ensure_size_float(microS_p2, nslots)
                f_ensure_size_int(microS_t1, nslots)
                f_ensure_size_float(microS_p1, nslots)
                f_ensure_size_int(microS_tc, nslots)
                f_ensure_size_int(microS_vi, nslots)
                f_ensure_size_int(microS_q,  nslots)
                f_ensure_size_float(microS_sl, nslots)
                f_ensure_size_float(microS_y, nslots)
                f_ensure_size_bool(microS_br, nslots)

            for x = 0 to nslots - 1
                if is_res
                    int t2 = x < array.size(microR_t2) ? array.get(microR_t2, x) : na
                    if not na(t2)
                        float p2 = x < array.size(microR_p2) ? array.get(microR_p2, x) : na
                        float sl = x < array.size(microR_sl) ? array.get(microR_sl, x) : na
                        float yL = f_inv(p2 + sl * float(bar_index - t2))
                        array.set(microR_y, x, yL)
                        array.set(microR_br, x, f_is_break(true, yL, micro_break_tol))
                else
                    int t2 = x < array.size(microS_t2) ? array.get(microS_t2, x) : na
                    if not na(t2)
                        float p2 = x < array.size(microS_p2) ? array.get(microS_p2, x) : na
                        float sl = x < array.size(microS_sl) ? array.get(microS_sl, x) : na
                        float yL = f_inv(p2 + sl * float(bar_index - t2))
                        array.set(microS_y, x, yL)
                        array.set(microS_br, x, f_is_break(false, yL, micro_break_tol))

        if not locked
            int[] sel_idx = array.new_int()
            int candN = array.size(p2s)
            float min_sep = _atr_safe * min_sep_atr_eff

            if candN > 0
                for ci = 0 to candN - 1
                    if array.size(sel_idx) < nslots
                        float cy = array.get(ynows, ci)
                        bool ok = true
                        if min_sep_atr_eff > 0 and array.size(sel_idx) > 0
                            for sj = 0 to array.size(sel_idx) - 1
                                float ey = array.get(ynows, array.get(sel_idx, sj))
                                if math.abs(cy - ey) < min_sep
                                    ok := false
                                    break
                        if ok
                            array.push(sel_idx, ci)

                if array.size(sel_idx) < 1
                    array.push(sel_idx, 0)

                if array.size(sel_idx) < nslots
                    for ci = 0 to candN - 1
                        if array.size(sel_idx) < nslots
                            bool used = false
                            for sj = 0 to array.size(sel_idx) - 1
                                if array.get(sel_idx, sj) == ci
                                    used := true
                            if not used
                                array.push(sel_idx, ci)

            for x = 0 to nslots - 1
                if x < array.size(sel_idx)
                    int si = array.get(sel_idx, x)
                    float _p2  = array.get(p2s, si)
                    int   _t2  = array.get(t2s, si)
                    float _p1  = array.get(p1s, si)
                    int   _t1  = array.get(t1s, si)
                    int   _tot = array.get(tots, si)
                    float _m   = array.get(slps, si)
                    int _q = array.get(qs, si)

                    f_render_line(x, is_res, _t2, _p2, _t1, _p1, _tot, _m, false, false, _q)

            if is_res
                f_ensure_size_int(microR_t2, nslots)
                f_ensure_size_float(microR_p2, nslots)
                f_ensure_size_int(microR_t1, nslots)
                f_ensure_size_float(microR_p1, nslots)
                f_ensure_size_int(microR_tc, nslots)
                f_ensure_size_float(microR_sl, nslots)
                f_ensure_size_float(microR_y, nslots)
                f_ensure_size_bool(microR_br, nslots)
                for x = 0 to nslots - 1
                    if x < array.size(sel_idx)
                        int si = array.get(sel_idx, x)
                        array.set(microR_t2, x, array.get(t2s, si))
                        array.set(microR_p2, x, array.get(p2s, si))
                        array.set(microR_t1, x, array.get(t1s, si))
                        array.set(microR_p1, x, array.get(p1s, si))
                        array.set(microR_tc, x, array.get(tots, si))
                        array.set(microR_vi, x, array.get(vios, si))
                        array.set(microR_q,  x, array.get(qs,  si))
                        array.set(microR_sl, x, array.get(slps, si))
                        array.set(microR_y,  x, array.get(ynows, si))
                        array.set(microR_br, x, f_is_break(true, array.get(ynows, si), micro_break_tol))
                    else
                        array.set(microR_t2, x, na)
                        array.set(microR_p2, x, na)
                        array.set(microR_t1, x, na)
                        array.set(microR_p1, x, na)
                        array.set(microR_tc, x, 0)
                        array.set(microR_vi, x, 0)
                        array.set(microR_q,  x, 0)
                        array.set(microR_sl, x, na)
                        array.set(microR_y,  x, na)
                        array.set(microR_br, x, false)
            else
                f_ensure_size_int(microS_t2, nslots)
                f_ensure_size_float(microS_p2, nslots)
                f_ensure_size_int(microS_t1, nslots)
                f_ensure_size_float(microS_p1, nslots)
                f_ensure_size_int(microS_tc, nslots)
                f_ensure_size_float(microS_sl, nslots)
                f_ensure_size_float(microS_y, nslots)
                f_ensure_size_bool(microS_br, nslots)
                for x = 0 to nslots - 1
                    if x < array.size(sel_idx)
                        int si = array.get(sel_idx, x)
                        array.set(microS_t2, x, array.get(t2s, si))
                        array.set(microS_p2, x, array.get(p2s, si))
                        array.set(microS_t1, x, array.get(t1s, si))
                        array.set(microS_p1, x, array.get(p1s, si))
                        array.set(microS_tc, x, array.get(tots, si))
                        array.set(microS_vi, x, array.get(vios, si))
                        array.set(microS_q,  x, array.get(qs,  si))
                        array.set(microS_sl, x, array.get(slps, si))
                        array.set(microS_y,  x, array.get(ynows, si))
                        array.set(microS_br, x, f_is_break(false, array.get(ynows, si), micro_break_tol))
                    else
                        array.set(microS_t2, x, na)
                        array.set(microS_p2, x, na)
                        array.set(microS_t1, x, na)
                        array.set(microS_p1, x, na)
                        array.set(microS_tc, x, 0)
                        array.set(microS_vi, x, 0)
                        array.set(microS_q,  x, 0)
                        array.set(microS_sl, x, na)
                        array.set(microS_y,  x, na)
                        array.set(microS_br, x, false)
        else
            int cand_idx = 0
            for x = 0 to nslots - 1
                bool keep = false
                if is_res
                    keep := (x < array.size(microR_t2) ? not na(array.get(microR_t2, x)) : false) and not (replace_broken_eff and (x < array.size(microR_br) ? array.get(microR_br, x) : false))
                else
                    keep := (x < array.size(microS_t2) ? not na(array.get(microS_t2, x)) : false) and not (replace_broken_eff and (x < array.size(microS_br) ? array.get(microS_br, x) : false))
                if not keep
                    bool assigned = false
                    while (cand_idx < array.size(p2s)) and (not assigned)
                        float c_p2  = array.get(p2s, cand_idx)
                        int   c_t2  = array.get(t2s, cand_idx)
                        float c_p1  = array.get(p1s, cand_idx)
                        int   c_t1  = array.get(t1s, cand_idx)
                        int   c_tc  = array.get(tots, cand_idx)
                        float c_sl  = array.get(slps, cand_idx)
                        float c_y   = array.get(ynows, cand_idx)
                        int   c_q   = array.get(qs,   cand_idx)
                        int   c_vi  = array.get(vios, cand_idx)
                        bool dup = false
                        for y = 0 to nslots - 1
                            if is_res ? (y < array.size(microR_t2) ? not na(array.get(microR_t2, y)) : false) : false
                                float ex_s = array.get(microR_sl, y)
                                float ex_y = array.get(microR_y,  y)
                                bool slope_close = math.abs(c_sl - ex_s) < (math.max(math.abs(ex_s), 1e-12) * dup_slope)
                                bool y_close     = math.abs(c_y  - ex_y) < (math.max(ex_y, 1e-12) * dup_price)
                                bool sep_close   = (min_sep_atr_eff > 0) and (math.abs(c_y - ex_y) < (_atr_safe * min_sep_atr_eff))
                                if (slope_close and y_close) or sep_close
                                    dup := true
                            if (not is_res) ? (y < array.size(microS_t2) ? not na(array.get(microS_t2, y)) : false) : false
                                float ex_s = array.get(microS_sl, y)
                                float ex_y = array.get(microS_y,  y)
                                bool slope_close = math.abs(c_sl - ex_s) < (math.max(math.abs(ex_s), 1e-12) * dup_slope)
                                bool y_close     = math.abs(c_y  - ex_y) < (math.max(ex_y, 1e-12) * dup_price)
                                bool sep_close   = (min_sep_atr_eff > 0) and (math.abs(c_y - ex_y) < (_atr_safe * min_sep_atr_eff))
                                if (slope_close and y_close) or sep_close
                                    dup := true
                        if not dup
                            if is_res
                                array.set(microR_t2, x, c_t2)
                                array.set(microR_p2, x, c_p2)
                                array.set(microR_t1, x, c_t1)
                                array.set(microR_p1, x, c_p1)
                                array.set(microR_tc, x, c_tc)
                                array.set(microR_vi, x, c_vi)
                                array.set(microR_q,  x, c_q)
                                array.set(microR_sl, x, c_sl)
                                array.set(microR_y,  x, c_y)
                                array.set(microR_br, x, f_is_break(true, c_y, micro_break_tol))
                            else
                                array.set(microS_t2, x, c_t2)
                                array.set(microS_p2, x, c_p2)
                                array.set(microS_t1, x, c_t1)
                                array.set(microS_p1, x, c_p1)
                                array.set(microS_tc, x, c_tc)
                                array.set(microS_vi, x, c_vi)
                                array.set(microS_q,  x, c_q)
                                array.set(microS_sl, x, c_sl)
                                array.set(microS_y,  x, c_y)
                                array.set(microS_br, x, f_is_break(false, c_y, micro_break_tol))
                            assigned := true
                        cand_idx += 1
                    if not assigned
                        if is_res
                            array.set(microR_t2, x, na)
                            array.set(microR_p2, x, na)
                            array.set(microR_t1, x, na)
                            array.set(microR_p1, x, na)
                            array.set(microR_tc, x, 0)
                            array.set(microR_vi, x, 0)
                            array.set(microR_q,  x, 0)
                            array.set(microR_sl, x, na)
                            array.set(microR_y, x, na)
                            array.set(microR_br, x, false)
                        else
                            array.set(microS_t2, x, na)
                            array.set(microS_p2, x, na)
                            array.set(microS_t1, x, na)
                            array.set(microS_p1, x, na)
                            array.set(microS_tc, x, 0)
                            array.set(microS_vi, x, 0)
                            array.set(microS_q,  x, 0)
                            array.set(microS_sl, x, na)
                            array.set(microS_y, x, na)
                            array.set(microS_br, x, false)
            for x = 0 to nslots - 1
                if is_res
                    int _t2 = x < array.size(microR_t2) ? array.get(microR_t2, x) : na
                    if not na(_t2)
                        float _p2 = x < array.size(microR_p2) ? array.get(microR_p2, x) : na
                        int   _t1 = x < array.size(microR_t1) ? array.get(microR_t1, x) : na
                        float _p1 = x < array.size(microR_p1) ? array.get(microR_p1, x) : na
                        int   _tc = x < array.size(microR_tc) ? array.get(microR_tc, x) : 0
                        float _sl = x < array.size(microR_sl) ? array.get(microR_sl, x) : na
                        float yL = f_inv(_p2 + _sl * float(bar_index - _t2))
                        array.set(microR_y,  x, yL)
                        bool br = f_is_break(true, yL, micro_break_tol)
                        array.set(microR_br, x, br)
                        int _q = x < array.size(microR_q) ? array.get(microR_q, x) : 0

                        f_render_line(x, true, _t2, _p2, _t1, _p1, _tc, _sl, br, false, _q)
                else
                    int _t2 = x < array.size(microS_t2) ? array.get(microS_t2, x) : na
                    if not na(_t2)
                        float _p2 = x < array.size(microS_p2) ? array.get(microS_p2, x) : na
                        int   _t1 = x < array.size(microS_t1) ? array.get(microS_t1, x) : na
                        float _p1 = x < array.size(microS_p1) ? array.get(microS_p1, x) : na
                        int   _tc = x < array.size(microS_tc) ? array.get(microS_tc, x) : 0
                        float _sl = x < array.size(microS_sl) ? array.get(microS_sl, x) : na
                        float yL = f_inv(_p2 + _sl * float(bar_index - _t2))
                        array.set(microS_y,  x, yL)
                        bool br = f_is_break(false, yL, micro_break_tol)
                        array.set(microS_br, x, br)
                        int _q = x < array.size(microS_q) ? array.get(microS_q, x) : 0

                        f_render_line(x, false, _t2, _p2, _t1, _p1, _tc, _sl, br, false, _q)
f_scan_meso(is_res) =>
    float[] src_p = is_res ? phm_price : plm_price
    float[] src_b = is_res ? phm_body  : plm_body
    int[]   src_t = is_res ? phm_time  : plm_time

    for i = 0 to POOL_MESO - 1
        f_reset(i, is_res ? resM_core : supM_core, is_res ? resM_glow : supM_glow, is_res ? resM_lbl : supM_lbl)

    int n = array.size(src_p)
    if n >= 2

        float _atr      = atr14_cs
        float _atr_safe = atr14_cs_safe
        bool  _use_rel  = rel_strength_eff > 0
        int anchors = math.min(meso_anchor_n, n - 1)
        int limit   = math.min(n - 1, 250)
        int keepNM  = math.min(30, meso_top_n_eff * pool_mult_eff)

        float[] scores = array.new_float()
        float[] p2s    = array.new_float()
        int[]   t2s    = array.new_int()
        float[] p1s    = array.new_float()
        int[]   t1s    = array.new_int()
        int[]   tots   = array.new_int()
        float[] slps   = array.new_float()
        float[] ynows  = array.new_float()

        int[]   vios   = array.new_int()
        bool[]  bks    = array.new_bool()
        int[]   qs     = array.new_int()

        for j = 0 to anchors - 1
            float p1 = array.get(src_p, j)
            int   t1 = array.get(src_t, j)

            for i = j + 1 to limit
                float p2 = array.get(src_p, i)
                int   t2 = array.get(src_t, i)

                if (t1 - t2) > meso_min_dist and (bar_index - t2) <= max_lookback and (bar_index - t1) <= max_lookback
                    float slope = (p1 - p2) / float(t1 - t2)

                    if math.abs(slope) > 0.000001 and math.abs(slope) < meso_slope_max
                        bool bk = false
                        int  tc = 0
                        int  viol = 0

                        for k = 0 to i - 1
                            if k != j
                                int   tk = array.get(src_t, k)
                                float pk_body = use_body ? array.get(src_b, k) : array.get(src_p, k)
                                float body_real = f_inv(pk_body)

                                float lk_log  = p2 + slope * float(tk - t2)
                                float lk_real = f_inv(lk_log)

                                float tol = f_tol_meso(lk_real)

                                bool between = tk < t1
                                if between
                                    if is_res and body_real > (lk_real + tol)
                                        viol += 1
                                    if (not is_res) and body_real < (lk_real - tol)
                                        viol += 1
                                else
                                    if is_res and body_real > (lk_real + tol)
                                        bk := true
                                    if (not is_res) and body_real < (lk_real - tol)
                                        bk := true

                                float wick_real = f_inv(array.get(src_p, k))
                                if math.abs(wick_real - lk_real) <= tol
                                    tc += 1

                        int tot = 2 + tc
                        if tot >= meso_min_touch
                            float time_w  = math.log(1 + float(t1 - t2))
                            float touch_w = math.pow(float(tot), 2.6)
                            float sc      = touch_w * time_w

                            sc := sc / (1.0 + viol * 0.75)
                            if bk
                                sc := sc * 0.70

                            float y_now_log = p2 + slope * float(bar_index - t2)
                            float y_now     = f_inv(y_now_log)

                            if slope_sanity_eff > 0
                                float slope_frac = math.min(math.abs(slope) / math.max(meso_slope_max, 1e-12), 1.0)
                                float slope_fac  = 1.0 - slope_sanity_eff * math.pow(slope_frac, 1.35)
                                sc := sc * math.max(slope_fac, 0.10)

                            if _use_rel
                                float dist_atr = math.abs(y_now - close) / _atr_safe
                                float prox     = math.exp(-dist_atr * rel_decay_eff)
                                float rel_fac  = (1.0 - rel_strength_eff) + (rel_strength_eff * prox)
                                sc := sc * rel_fac

                            int q = f_q_line(t1, t2, tot, viol, slope, y_now, _atr_safe, meso_min_touch, meso_slope_max)

                            bool dup = false
                            int n_d = array.size(slps)
                            if n_d > 0
                                for d = 0 to n_d - 1
                                    float ex_s = array.get(slps, d)
                                    float ex_y = array.get(ynows, d)
                                    bool slope_close = math.abs(slope - ex_s) < (math.max(math.abs(ex_s), 1e-12) * meso_dup_slope)
                                    bool y_close     = math.abs(y_now - ex_y) < (ex_y * meso_dup_price)
                                    bool sep_close   = (min_sep_atr_eff > 0) and (math.abs(y_now - ex_y) < (_atr_safe * min_sep_atr_eff))
                                    if (slope_close and y_close) or sep_close
                                        dup := true
                                        break

                            if not dup
                                array.push(scores, sc)
                                array.push(p2s,    p2)
                                array.push(t2s,    t2)
                                array.push(p1s,    p1)
                                array.push(t1s,    t1)
                                array.push(tots,   tot)
                                array.push(slps,   slope)
                                array.push(ynows,  y_now)
                                array.push(qs,     q)

                                int pos = array.size(scores) - 1
                                while pos > 0
                                    if array.get(scores, pos) > array.get(scores, pos - 1)
                                        f_swap_float(scores, pos, pos - 1)
                                        f_swap_float(p2s,    pos, pos - 1)
                                        f_swap_int(t2s,      pos, pos - 1)
                                        f_swap_float(p1s,    pos, pos - 1)
                                        f_swap_int(t1s,      pos, pos - 1)
                                        f_swap_int(tots,     pos, pos - 1)
                                        f_swap_float(slps,   pos, pos - 1)
                                        f_swap_float(ynows,  pos, pos - 1)
                                        f_swap_int(qs,       pos, pos - 1)
                                        pos -= 1
                                    else
                                        break
                                if array.size(scores) > keepNM
                                    array.pop(scores)
                                    array.pop(p2s)
                                    array.pop(t2s)
                                    array.pop(p1s)
                                    array.pop(t1s)
                                    array.pop(tots)
                                    array.pop(slps)
                                    array.pop(ynows)
                                    array.pop(qs)

        bool locked = repaint_mode_eff == "Locked"
        int nslots = meso_top_n_eff

        if locked
            if is_res
                f_ensure_size_int(mesoR_t2, nslots)
                f_ensure_size_float(mesoR_p2, nslots)
                f_ensure_size_int(mesoR_t1, nslots)
                f_ensure_size_float(mesoR_p1, nslots)
                f_ensure_size_int(mesoR_tc, nslots)
                f_ensure_size_int(mesoR_q,  nslots)
                f_ensure_size_float(mesoR_sl, nslots)
                f_ensure_size_float(mesoR_y, nslots)
                f_ensure_size_bool(mesoR_br, nslots)
            else
                f_ensure_size_int(mesoS_t2, nslots)
                f_ensure_size_float(mesoS_p2, nslots)
                f_ensure_size_int(mesoS_t1, nslots)
                f_ensure_size_float(mesoS_p1, nslots)
                f_ensure_size_int(mesoS_tc, nslots)
                f_ensure_size_int(mesoS_q,  nslots)
                f_ensure_size_float(mesoS_sl, nslots)
                f_ensure_size_float(mesoS_y, nslots)
                f_ensure_size_bool(mesoS_br, nslots)

            for x = 0 to nslots - 1
                if is_res ? (x < array.size(mesoR_t2) ? not na(array.get(mesoR_t2, x)) : false) : false
                    float yL = f_inv(array.get(mesoR_p2, x) + array.get(mesoR_sl, x) * float(bar_index - array.get(mesoR_t2, x)))
                    array.set(mesoR_y, x, yL)
                    array.set(mesoR_br, x, f_is_break(true, yL, meso_break_tol))
                if (not is_res) ? (x < array.size(mesoS_t2) ? not na(array.get(mesoS_t2, x)) : false) : false
                    float yL = f_inv(array.get(mesoS_p2, x) + array.get(mesoS_sl, x) * float(bar_index - array.get(mesoS_t2, x)))
                    array.set(mesoS_y, x, yL)
                    array.set(mesoS_br, x, f_is_break(false, yL, meso_break_tol))

        if not locked
            int[] sel_idx = array.new_int()
            int candN = array.size(p2s)
            float min_sep = _atr_safe * min_sep_atr_eff

            if candN > 0
                for ci = 0 to candN - 1
                    if array.size(sel_idx) < nslots
                        float cy = array.get(ynows, ci)
                        bool ok = true
                        if min_sep_atr_eff > 0 and array.size(sel_idx) > 0
                            for sj = 0 to array.size(sel_idx) - 1
                                float ey = array.get(ynows, array.get(sel_idx, sj))
                                if math.abs(cy - ey) < min_sep
                                    ok := false
                                    break
                        if ok
                            array.push(sel_idx, ci)

                if array.size(sel_idx) < 1
                    array.push(sel_idx, 0)

                if array.size(sel_idx) < nslots
                    for ci = 0 to candN - 1
                        if array.size(sel_idx) < nslots
                            bool used = false
                            for sj = 0 to array.size(sel_idx) - 1
                                if array.get(sel_idx, sj) == ci
                                    used := true
                            if not used
                                array.push(sel_idx, ci)

            for x = 0 to nslots - 1
                if x < array.size(sel_idx)
                    int si = array.get(sel_idx, x)
                    float _p2  = array.get(p2s, si)
                    int   _t2  = array.get(t2s, si)
                    float _p1  = array.get(p1s, si)
                    int   _t1  = array.get(t1s, si)
                    int   _tot = array.get(tots, si)
                    float _m   = array.get(slps, si)
                    int _q = array.get(qs, si)

                    f_render_line(x, is_res, _t2, _p2, _t1, _p1, _tot, _m, false, true, _q)
            if is_res
                f_ensure_size_int(mesoR_t2, nslots)
                f_ensure_size_float(mesoR_p2, nslots)
                f_ensure_size_int(mesoR_t1, nslots)
                f_ensure_size_float(mesoR_p1, nslots)
                f_ensure_size_int(mesoR_tc, nslots)
                f_ensure_size_int(mesoR_q,  nslots)
                f_ensure_size_float(mesoR_sl, nslots)
                f_ensure_size_float(mesoR_y, nslots)
                f_ensure_size_bool(mesoR_br, nslots)
                for x = 0 to nslots - 1
                    if x < array.size(sel_idx)
                        int si = array.get(sel_idx, x)
                        array.set(mesoR_t2, x, array.get(t2s, si))
                        array.set(mesoR_p2, x, array.get(p2s, si))
                        array.set(mesoR_t1, x, array.get(t1s, si))
                        array.set(mesoR_p1, x, array.get(p1s, si))
                        array.set(mesoR_tc, x, array.get(tots, si))
                        array.set(mesoR_q,  x, array.get(qs,   si))
                        array.set(mesoR_sl, x, array.get(slps, si))
                        array.set(mesoR_y,  x, array.get(ynows, si))
                        array.set(mesoR_br, x, f_is_break(true, array.get(ynows, si), meso_break_tol))
                    else
                        array.set(mesoR_t2, x, na)
                        array.set(mesoR_p2, x, na)
                        array.set(mesoR_t1, x, na)
                        array.set(mesoR_p1, x, na)
                        array.set(mesoR_tc, x, 0)
                        array.set(mesoR_q,  x, 0)
                        array.set(mesoR_sl, x, na)
                        array.set(mesoR_y,  x, na)
                        array.set(mesoR_br, x, false)
            else
                f_ensure_size_int(mesoS_t2, nslots)
                f_ensure_size_float(mesoS_p2, nslots)
                f_ensure_size_int(mesoS_t1, nslots)
                f_ensure_size_float(mesoS_p1, nslots)
                f_ensure_size_int(mesoS_tc, nslots)
                f_ensure_size_int(mesoS_q,  nslots)
                f_ensure_size_float(mesoS_sl, nslots)
                f_ensure_size_float(mesoS_y, nslots)
                f_ensure_size_bool(mesoS_br, nslots)
                for x = 0 to nslots - 1
                    if x < array.size(sel_idx)
                        int si = array.get(sel_idx, x)
                        array.set(mesoS_t2, x, array.get(t2s, si))
                        array.set(mesoS_p2, x, array.get(p2s, si))
                        array.set(mesoS_t1, x, array.get(t1s, si))
                        array.set(mesoS_p1, x, array.get(p1s, si))
                        array.set(mesoS_tc, x, array.get(tots, si))
                        array.set(mesoS_q,  x, array.get(qs,   si))
                        array.set(mesoS_sl, x, array.get(slps, si))
                        array.set(mesoS_y,  x, array.get(ynows, si))
                        array.set(mesoS_br, x, f_is_break(false, array.get(ynows, si), meso_break_tol))
                    else
                        array.set(mesoS_t2, x, na)
                        array.set(mesoS_p2, x, na)
                        array.set(mesoS_t1, x, na)
                        array.set(mesoS_p1, x, na)
                        array.set(mesoS_tc, x, 0)
                        array.set(mesoS_q,  x, 0)
                        array.set(mesoS_sl, x, na)
                        array.set(mesoS_y,  x, na)
                        array.set(mesoS_br, x, false)
        else
            int cand_idx = 0
            for x = 0 to nslots - 1
                bool keep = false
                if is_res
                    keep := (x < array.size(mesoR_t2) ? not na(array.get(mesoR_t2, x)) : false) and not (replace_broken_eff and (x < array.size(mesoR_br) ? array.get(mesoR_br, x) : false))
                else
                    keep := (x < array.size(mesoS_t2) ? not na(array.get(mesoS_t2, x)) : false) and not (replace_broken_eff and (x < array.size(mesoS_br) ? array.get(mesoS_br, x) : false))
                if not keep
                    bool assigned = false
                    while (cand_idx < array.size(p2s)) and (not assigned)
                        float c_p2  = array.get(p2s, cand_idx)
                        int   c_t2  = array.get(t2s, cand_idx)
                        float c_p1  = array.get(p1s, cand_idx)
                        int   c_t1  = array.get(t1s, cand_idx)
                        int   c_tc  = array.get(tots, cand_idx)
                        float c_sl  = array.get(slps, cand_idx)
                        float c_y   = array.get(ynows, cand_idx)
                        int   c_q   = array.get(qs,   cand_idx)
                        bool dup = false
                        for y = 0 to nslots - 1
                            if is_res ? (y < array.size(mesoR_t2) ? not na(array.get(mesoR_t2, y)) : false) : false
                                float ex_s = array.get(mesoR_sl, y)
                                float ex_y = array.get(mesoR_y,  y)
                                bool slope_close = math.abs(c_sl - ex_s) < (math.max(math.abs(ex_s), 1e-12) * meso_dup_slope)
                                bool y_close     = math.abs(c_y  - ex_y) < (math.max(ex_y, 1e-12) * meso_dup_price)
                                bool sep_close   = (min_sep_atr_eff > 0) and (math.abs(c_y - ex_y) < (_atr_safe * min_sep_atr_eff))
                                if (slope_close and y_close) or sep_close
                                    dup := true
                            if (not is_res) ? (y < array.size(mesoS_t2) ? not na(array.get(mesoS_t2, y)) : false) : false
                                float ex_s = array.get(mesoS_sl, y)
                                float ex_y = array.get(mesoS_y,  y)
                                bool slope_close = math.abs(c_sl - ex_s) < (math.max(math.abs(ex_s), 1e-12) * meso_dup_slope)
                                bool y_close     = math.abs(c_y  - ex_y) < (math.max(ex_y, 1e-12) * meso_dup_price)
                                bool sep_close   = (min_sep_atr_eff > 0) and (math.abs(c_y - ex_y) < (_atr_safe * min_sep_atr_eff))
                                if (slope_close and y_close) or sep_close
                                    dup := true
                        if not dup
                            if is_res
                                array.set(mesoR_t2, x, c_t2)
                                array.set(mesoR_p2, x, c_p2)
                                array.set(mesoR_t1, x, c_t1)
                                array.set(mesoR_p1, x, c_p1)
                                array.set(mesoR_tc, x, c_tc)
                                array.set(mesoR_q,  x, c_q)
                                array.set(mesoR_sl, x, c_sl)
                                array.set(mesoR_y,  x, c_y)
                                array.set(mesoR_br, x, f_is_break(true, c_y, meso_break_tol))
                            else
                                array.set(mesoS_t2, x, c_t2)
                                array.set(mesoS_p2, x, c_p2)
                                array.set(mesoS_t1, x, c_t1)
                                array.set(mesoS_p1, x, c_p1)
                                array.set(mesoS_tc, x, c_tc)
                                array.set(mesoS_q,  x, c_q)
                                array.set(mesoS_sl, x, c_sl)
                                array.set(mesoS_y,  x, c_y)
                                array.set(mesoS_br, x, f_is_break(false, c_y, meso_break_tol))
                            assigned := true
                        cand_idx += 1
                    if not assigned
                        if is_res
                            array.set(mesoR_t2, x, na)
                            array.set(mesoR_p2, x, na)
                            array.set(mesoR_t1, x, na)
                            array.set(mesoR_p1, x, na)
                            array.set(mesoR_tc, x, 0)
                            array.set(mesoR_q,  x, 0)
                            array.set(mesoR_sl, x, na)
                            array.set(mesoR_y, x, na)
                            array.set(mesoR_br, x, false)
                        else
                            array.set(mesoS_t2, x, na)
                            array.set(mesoS_p2, x, na)
                            array.set(mesoS_t1, x, na)
                            array.set(mesoS_p1, x, na)
                            array.set(mesoS_tc, x, 0)
                            array.set(mesoS_q,  x, 0)
                            array.set(mesoS_sl, x, na)
                            array.set(mesoS_y, x, na)
                            array.set(mesoS_br, x, false)
            for x = 0 to nslots - 1
                if is_res ? (x < array.size(mesoR_t2) ? not na(array.get(mesoR_t2, x)) : false) : false
                    int   _t2 = array.get(mesoR_t2, x)
                    float _p2 = array.get(mesoR_p2, x)
                    int   _t1 = array.get(mesoR_t1, x)
                    float _p1 = array.get(mesoR_p1, x)
                    int   _tc = array.get(mesoR_tc, x)
                    float _sl = array.get(mesoR_sl, x)
                    float yL = f_inv(_p2 + _sl * float(bar_index - _t2))
                    array.set(mesoR_y,  x, yL)
                    bool br = f_is_break(true, yL, meso_break_tol)
                    array.set(mesoR_br, x, br)
                    int _q = x < array.size(mesoR_q) ? array.get(mesoR_q, x) : 0

                    f_render_line(x, true, _t2, _p2, _t1, _p1, _tc, _sl, br, true, _q)
                if (not is_res) ? (x < array.size(mesoS_t2) ? not na(array.get(mesoS_t2, x)) : false) : false
                    int   _t2 = array.get(mesoS_t2, x)
                    float _p2 = array.get(mesoS_p2, x)
                    int   _t1 = array.get(mesoS_t1, x)
                    float _p1 = array.get(mesoS_p1, x)
                    int   _tc = array.get(mesoS_tc, x)
                    float _sl = array.get(mesoS_sl, x)
                    float yL = f_inv(_p2 + _sl * float(bar_index - _t2))
                    array.set(mesoS_y,  x, yL)
                    bool br = f_is_break(false, yL, meso_break_tol)
                    array.set(mesoS_br, x, br)
                    int _q = x < array.size(mesoS_q) ? array.get(mesoS_q, x) : 0

                    f_render_line(x, false, _t2, _p2, _t1, _p1, _tc, _sl, br, true, _q)

var int _lastScanBar = na
var int _lastPivSig  = na

int  _pivSig      = array.size(ph_time) + array.size(pl_time) + array.size(phm_time) + array.size(plm_time)
int scan_cadence_eff = tf_low ? 2 : 1
scan_cadence_eff := (prof_clean and not prof_custom and tf_low) ? 4 : scan_cadence_eff

bool do_micro_scan = barstate.islast and (na(_lastScanBar) or _pivSig != _lastPivSig or (not na(_lastScanBar) and (bar_index - _lastScanBar) >= scan_cadence_eff))

if do_micro_scan
    _lastScanBar := bar_index
    _lastPivSig  := _pivSig
    f_scan(true)
    f_scan(false)
    if show_meso_eff
        f_scan_meso(true)
        f_scan_meso(false)
    else
        for i = 0 to POOL_MESO - 1
            f_reset(i, resM_core, resM_glow, resM_lbl)
            f_reset(i, supM_core, supM_glow, supM_lbl)

        if (prof_clean and clean_autofill_eff) or fp_thin_hist
            bool _microR_ok = f_has_slot_int(microR_t2, 0)
            bool _microS_ok = f_has_slot_int(microS_t2, 0)
            if not _microR_ok
                f_scan_meso(true)
            if not _microS_ok
                f_scan_meso(false)

if barstate.islast
    bool _q_on = qtag_mode != "Off"
    confR_cnt := 0
    confS_cnt := 0
    if not na(qtagR_lbl) and not na(qtagS_lbl)
        float _atrqs = atr14_cs_safe
        int _colPad   = (qtag_mode == "Detailed" ? 2 : 0) + (lbl_size_opt == "Large" ? 2 : lbl_size_opt == "Tiny" ? -1 : 0)
        int _colQRaw  = show_ext ? (show_lbl_eff ? math.max(1, micro_lbl_gap_bars + 6 + _colPad) : math.max(1, 2 + _colPad)) : 0
        int _colCap   = show_ext ? math.max(6, (proj_horizon > 0 ? proj_horizon + 8 : 28)) : 0
        int _colQ     = show_ext ? math.min(_colQRaw, _colCap) : 0
        int _confSep  = (qtag_mode == "Detailed" ? 5 : 4) + (lbl_size_opt == "Large" ? 1 : 0)
        int _colConfR = show_ext ? math.max(_colQ + _confSep, micro_lbl_gap_bars + 12 + _colPad) : 0
        int _colConf  = show_ext ? math.min(_colConfR, _colCap + 8) : 0
        qtag_sz = lbl_size_eff_cs
        if vis_density_eff == "Minimal" and lbl_size_opt != "Large"
            qtag_sz := lbl_size_opt == "Normal" ? size.small : lbl_size_eff_cs
        conf_sz = qtag_sz
        if lbl_size_opt == "Large"
            conf_sz := size.small

        bool  _hasR  = f_has_slot_int(microR_t2, 0)
        float _yR    = _hasR ? f_af(microR_y, 0) : na
        bool  _brR   = _hasR ? f_ab(microR_br, 0) : false
        bool  _hasS  = f_has_slot_int(microS_t2, 0)
        float _yS    = _hasS ? f_af(microS_y, 0) : na
        bool  _brS   = _hasS ? f_ab(microS_br, 0) : false

        if _q_on
            int   _qR    = _hasR ? array.get(microR_q,  0) : na
            int   _tR    = _hasR ? array.get(microR_tc, 0) : 0
            bool  _nearR = qtag_near_atr <= 0 ? true : (not na(_yR) and (math.abs(_yR - close) / _atrqs <= qtag_near_atr))
            bool  _baseR   = _hasR and not _brR and not na(_yR) and not na(_qR)
            bool  _strongR = _baseR and _qR >= qtag_min_q
            bool  _okR     = _baseR and (_strongR or qtag_show_low)
            bool  _showR   = _okR and (_nearR or qtag_fade_far)
            if _showR
                int _xR = bar_index + _colQ
                int _aR_far = (qtag_fade_far and not _nearR and qtag_near_atr > 0) ? qtag_far_alpha : 0
                int _aR_low = (qtag_show_low and not _strongR) ? qtag_low_alpha : 0
                int _aR = math.max(_aR_far, _aR_low)
                string _txR = "Q" + str.tostring(_qR) + (qtag_show_grade ? (" " + f_grade(_qR)) : "")
                if qtag_mode == "Detailed"
                    _txR += " • " + str.tostring(_tR) + "T"
                label.set_xy(qtagR_lbl, _xR, _yR)
                label.set_text(qtagR_lbl, _txR)
                label.set_textcolor(qtagR_lbl, color.new(c_res, math.max(0, _aR - 8)))
                label.set_color(qtagR_lbl, color.new(color.rgb(20, 24, 30), vis_density_eff == "Minimal" ? 84 : 86))
                label.set_size(qtagR_lbl, qtag_sz)
            else
                label.set_xy(qtagR_lbl, na, na)
                label.set_text(qtagR_lbl, "")

            int   _qS    = _hasS ? array.get(microS_q,  0) : na
            int   _tS    = _hasS ? array.get(microS_tc, 0) : 0
            bool  _nearS = qtag_near_atr <= 0 ? true : (not na(_yS) and (math.abs(_yS - close) / _atrqs <= qtag_near_atr))
            bool  _baseS   = _hasS and not _brS and not na(_yS) and not na(_qS)
            bool  _strongS = _baseS and _qS >= qtag_min_q
            bool  _okS     = _baseS and (_strongS or qtag_show_low)
            bool  _showS   = _okS and (_nearS or qtag_fade_far)
            if _showS
                int _xS = bar_index + _colQ
                int _aS_far = (qtag_fade_far and not _nearS and qtag_near_atr > 0) ? qtag_far_alpha : 0
                int _aS_low = (qtag_show_low and not _strongS) ? qtag_low_alpha : 0
                int _aS = math.max(_aS_far, _aS_low)
                string _txS = "Q" + str.tostring(_qS) + (qtag_show_grade ? (" " + f_grade(_qS)) : "")
                if qtag_mode == "Detailed"
                    _txS += " • " + str.tostring(_tS) + "T"
                label.set_xy(qtagS_lbl, _xS, _yS)
                label.set_text(qtagS_lbl, _txS)
                label.set_textcolor(qtagS_lbl, color.new(c_sup, math.max(0, _aS - 8)))
                label.set_color(qtagS_lbl, color.new(color.rgb(20, 24, 30), vis_density_eff == "Minimal" ? 84 : 86))
                label.set_size(qtagS_lbl, qtag_sz)
            else
                label.set_xy(qtagS_lbl, na, na)
                label.set_text(qtagS_lbl, "")

        else
            label.set_xy(qtagR_lbl, na, na)
            label.set_text(qtagR_lbl, "")
            label.set_xy(qtagS_lbl, na, na)
            label.set_text(qtagS_lbl, "")

        bool do_conf_calc = show_confluence or (sig_conf_filter != "Off")
        if do_conf_calc and not na(confR_lbl) and not na(confS_lbl)
            float _atrCs = atr14_cs_safe
            float _band  = confluence_band_atr * _atrCs

            int   _rc = 0
            int   _r_micro = 0
            int   _r_meso  = 0
            float _rmin = na
            float _rmax = na

            if _hasR and not _brR and not na(_yR)
                _rc += 1
                _r_micro += 1
                _rmin := na(_rmin) ? _yR : math.min(_rmin, _yR)
                _rmax := na(_rmax) ? _yR : math.max(_rmax, _yR)

            bool _hasR1 = f_has_slot_int(microR_t2, 1)
            float _yR1  = _hasR1 ? array.get(microR_y, 1) : na
            bool  _brR1 = _hasR1 ? array.get(microR_br, 1) : false
            if _hasR1 and not _brR1 and not na(_yR1)
                _rc += 1
                _r_micro += 1
                _rmin := na(_rmin) ? _yR1 : math.min(_rmin, _yR1)
                _rmax := na(_rmax) ? _yR1 : math.max(_rmax, _yR1)

            bool _hasMRc = show_meso_eff and f_has_slot_int(mesoR_t2, 0)
            float _yMRc  = _hasMRc ? f_af(mesoR_y, 0) : na
            bool  _brMRc = _hasMRc ? f_ab(mesoR_br, 0) : false
            if _hasMRc and not _brMRc and not na(_yMRc)
                _rc += 1
                _r_meso += 1
                _rmin := na(_rmin) ? _yMRc : math.min(_rmin, _yMRc)
                _rmax := na(_rmax) ? _yMRc : math.max(_rmax, _yMRc)

            float _yRmid = (not na(_rmin) and not na(_rmax)) ? ((_rmin + _rmax) / 2.0) : na
            bool  _rNear = confluence_near_atr <= 0 ? true : (not na(_yRmid) and (math.abs(_yRmid - close) / _atrCs <= confluence_near_atr))
            bool  _rOK   = _rc >= 2 and _r_micro >= 1 and _r_meso >= 1 and _rNear and not na(_rmin) and not na(_rmax) and (_rmax - _rmin) <= _band
            confR_cnt := _rOK ? _rc : 0
            if _rOK
                int _xCR = bar_index + _colConf
                label.set_xy(confR_lbl, _xCR - 1, _yRmid)
                label.set_text(confR_lbl, "x" + str.tostring(_rc))
                label.set_textcolor(confR_lbl, color.new(c_res, _rc >= 3 ? 10 : 28))
                label.set_color(confR_lbl, color.new(color.rgb(20, 24, 30), _rc >= 3 ? 80 : 84))
                label.set_size(confR_lbl, conf_sz)
            else
                label.set_xy(confR_lbl, na, na)
                label.set_text(confR_lbl, "")

            int   _sc = 0
            int   _s_micro = 0
            int   _s_meso  = 0
            float _smin = na
            float _smax = na

            if _hasS and not _brS and not na(_yS)
                _sc += 1
                _s_micro += 1
                _smin := na(_smin) ? _yS : math.min(_smin, _yS)
                _smax := na(_smax) ? _yS : math.max(_smax, _yS)

            bool _hasS1 = f_has_slot_int(microS_t2, 1)
            float _yS1  = _hasS1 ? array.get(microS_y, 1) : na
            bool  _brS1 = _hasS1 ? array.get(microS_br, 1) : false
            if _hasS1 and not _brS1 and not na(_yS1)
                _sc += 1
                _s_micro += 1
                _smin := na(_smin) ? _yS1 : math.min(_smin, _yS1)
                _smax := na(_smax) ? _yS1 : math.max(_smax, _yS1)

            bool _hasMSc = show_meso_eff and f_has_slot_int(mesoS_t2, 0)
            float _yMSc  = _hasMSc ? f_af(mesoS_y, 0) : na
            bool  _brMSc = _hasMSc ? f_ab(mesoS_br, 0) : false
            if _hasMSc and not _brMSc and not na(_yMSc)
                _sc += 1
                _s_meso += 1
                _smin := na(_smin) ? _yMSc : math.min(_smin, _yMSc)
                _smax := na(_smax) ? _yMSc : math.max(_smax, _yMSc)

            float _ySmid = (not na(_smin) and not na(_smax)) ? ((_smin + _smax) / 2.0) : na
            bool  _sNear = confluence_near_atr <= 0 ? true : (not na(_ySmid) and (math.abs(_ySmid - close) / _atrCs <= confluence_near_atr))
            bool  _sOK   = _sc >= 2 and _s_micro >= 1 and _s_meso >= 1 and _sNear and not na(_smin) and not na(_smax) and (_smax - _smin) <= _band
            confS_cnt := _sOK ? _sc : 0
            if _sOK
                int _xCS = bar_index + _colConf
                label.set_xy(confS_lbl, _xCS - 1, _ySmid)
                label.set_text(confS_lbl, "x" + str.tostring(_sc))
                label.set_textcolor(confS_lbl, color.new(c_sup, _sc >= 3 ? 10 : 28))
                label.set_color(confS_lbl, color.new(color.rgb(20, 24, 30), _sc >= 3 ? 80 : 84))
                label.set_size(confS_lbl, conf_sz)
            else
                label.set_xy(confS_lbl, na, na)
                label.set_text(confS_lbl, "")

        if not show_confluence
            label.set_xy(confR_lbl, na, na)
            label.set_text(confR_lbl, "")
            label.set_xy(confS_lbl, na, na)
            label.set_text(confS_lbl, "")

        bool _meso_q = (qtag_mode == "Detailed") and show_meso_eff
        if _meso_q and not na(qtagMR_lbl) and not na(qtagMS_lbl)
            bool  _hasMR  = f_has_slot_int(mesoR_t2, 0)
            float _yMR    = _hasMR ? f_af(mesoR_y, 0) : na
            bool  _brMR   = _hasMR ? f_ab(mesoR_br, 0) : false
            int   _qMR    = _hasMR ? array.get(mesoR_q,  0) : na
            int   _tMR    = _hasMR ? array.get(mesoR_tc, 0) : 0
            bool  _nearMR = qtag_near_atr <= 0 ? true : (not na(_yMR) and (math.abs(_yMR - close) / _atrqs <= qtag_near_atr))
            bool  _okMR   = _hasMR and not _brMR and not na(_yMR) and not na(_qMR) and _qMR >= qtag_min_q
            bool  _showMR = _okMR and (_nearMR or qtag_fade_far)
            if _showMR
                int _xMR = bar_index + _colQ
                int _aMR = (qtag_fade_far and not _nearMR and qtag_near_atr > 0) ? qtag_far_alpha : 0
                string _txMR = "mQ" + str.tostring(_qMR) + (qtag_show_grade ? (" " + f_grade(_qMR)) : "")
                if qtag_mode == "Detailed"
                    _txMR += " • " + str.tostring(_tMR) + "T"
                label.set_xy(qtagMR_lbl, _xMR, _yMR)
                label.set_text(qtagMR_lbl, _txMR)
                label.set_textcolor(qtagMR_lbl, color.new(c_resM, math.max(0, _aMR - 8)))
                label.set_color(qtagMR_lbl, color.new(color.rgb(20, 24, 30), vis_density_eff == "Minimal" ? 86 : 88))
                label.set_size(qtagMR_lbl, qtag_sz)
            else
                label.set_xy(qtagMR_lbl, na, na)
                label.set_text(qtagMR_lbl, "")

            bool  _hasMS  = f_has_slot_int(mesoS_t2, 0)
            float _yMS    = _hasMS ? f_af(mesoS_y, 0) : na
            bool  _brMS   = _hasMS ? f_ab(mesoS_br, 0) : false
            int   _qMS    = _hasMS ? array.get(mesoS_q,  0) : na
            int   _tMS    = _hasMS ? array.get(mesoS_tc, 0) : 0
            bool  _nearMS = qtag_near_atr <= 0 ? true : (not na(_yMS) and (math.abs(_yMS - close) / _atrqs <= qtag_near_atr))
            bool  _okMS   = _hasMS and not _brMS and not na(_yMS) and not na(_qMS) and _qMS >= qtag_min_q
            bool  _showMS = _okMS and (_nearMS or qtag_fade_far)
            if _showMS
                int _xMS = bar_index + _colQ
                int _aMS = (qtag_fade_far and not _nearMS and qtag_near_atr > 0) ? qtag_far_alpha : 0
                string _txMS = "mQ" + str.tostring(_qMS) + (qtag_show_grade ? (" " + f_grade(_qMS)) : "")
                if qtag_mode == "Detailed"
                    _txMS += " • " + str.tostring(_tMS) + "T"
                label.set_xy(qtagMS_lbl, _xMS, _yMS)
                label.set_text(qtagMS_lbl, _txMS)
                label.set_textcolor(qtagMS_lbl, color.new(c_supM, math.max(0, _aMS - 8)))
                label.set_color(qtagMS_lbl, color.new(color.rgb(20, 24, 30), vis_density_eff == "Minimal" ? 86 : 88))
                label.set_size(qtagMS_lbl, qtag_sz)
            else
                label.set_xy(qtagMS_lbl, na, na)
                label.set_text(qtagMS_lbl, "")
        else
            if not na(qtagMR_lbl)
                label.set_xy(qtagMR_lbl, na, na)
                label.set_text(qtagMR_lbl, "")
            if not na(qtagMS_lbl)
                label.set_xy(qtagMS_lbl, na, na)
                label.set_text(qtagMS_lbl, "")

    else
        confR_cnt := 0
        confS_cnt := 0
        if not na(qtagR_lbl)
            label.set_xy(qtagR_lbl, na, na)
            label.set_text(qtagR_lbl, "")
        if not na(qtagS_lbl)
            label.set_xy(qtagS_lbl, na, na)
            label.set_text(qtagS_lbl, "")
        if not na(qtagMR_lbl)
            label.set_xy(qtagMR_lbl, na, na)
            label.set_text(qtagMR_lbl, "")
        if not na(qtagMS_lbl)
            label.set_xy(qtagMS_lbl, na, na)
            label.set_text(qtagMS_lbl, "")
        if not na(confR_lbl)
            label.set_xy(confR_lbl, na, na)
            label.set_text(confR_lbl, "")
        if not na(confS_lbl)
            label.set_xy(confS_lbl, na, na)
            label.set_text(confS_lbl, "")

f_htf_ph() =>
    float _ph = ta.pivothigh(high, mega_len, mega_len)
    float _bd = na(_ph) ? na : math.max(open[mega_len], close[mega_len])
    int   _tm = na(_ph) ? na : time[mega_len]
    [_ph, _bd, _tm]

f_htf_pl() =>
    float _pl = ta.pivotlow(low, mega_len, mega_len)
    float _bd = na(_pl) ? na : math.min(open[mega_len], close[mega_len])
    int   _tm = na(_pl) ? na : time[mega_len]
    [_pl, _bd, _tm]

_bm_gaps_off = barmerge.gaps_off
_bm_look_off = barmerge.lookahead_off
[phH, phB, phT] = request.security(syminfo.tickerid, mega_tf, f_htf_ph(), _bm_gaps_off, _bm_look_off)
[plH, plB, plT] = request.security(syminfo.tickerid, mega_tf, f_htf_pl(), _bm_gaps_off, _bm_look_off)
atr_htf = request.security(syminfo.tickerid, mega_tf, ta.atr(14), _bm_gaps_off, _bm_look_off)
float atr_htf_safe   = math.max(nz(atr_htf), syminfo.mintick)
float atr_htf_pct_cs = atr_htf_safe / math.max(close, 1e-10)

f_mega_push(float[] ap, float[] ab, int[] at, float pv, float bv, int tv) =>
    array.unshift(ap, f_val(pv))
    array.unshift(ab, f_val(bv))
    array.unshift(at, tv)
    if array.size(ap) > mega_mem
        array.pop(ap)
        array.pop(ab)
        array.pop(at)

var float[] mph_p = array.new_float()
var float[] mph_b = array.new_float()
var int[]   mph_t = array.new_int()

var float[] mpl_p = array.new_float()
var float[] mpl_b = array.new_float()
var int[]   mpl_t = array.new_int()

var int last_phT = na
var int last_plT = na
bool mega_updated = false

if show_mega_eff and not na(phH) and phT != last_phT
    f_mega_push(mph_p, mph_b, mph_t, phH, phB, phT)
    last_phT := phT
    mega_updated := true

if show_mega_eff and not na(plH) and plT != last_plT
    f_mega_push(mpl_p, mpl_b, mpl_t, plH, plB, plT)
    last_plT := plT
    mega_updated := true

var line  mega_res_c1 = line.new(na, na, na, na, xloc=xloc.bar_time)
var line  mega_res_g1 = line.new(na, na, na, na, xloc=xloc.bar_time)
var line  mega_res_c1b = line.new(na, na, na, na, xloc=xloc.bar_time)
var line  mega_res_g1b = line.new(na, na, na, na, xloc=xloc.bar_time)
var label mega_res_l1 = label.new(na, na, "", xloc=xloc.bar_time, style=label.style_label_left, textcolor=color.new(color.white, 0), color=color.new(color.black, 100), size=size.tiny)

var line  mega_res_c2 = line.new(na, na, na, na, xloc=xloc.bar_time)
var line  mega_res_g2 = line.new(na, na, na, na, xloc=xloc.bar_time)
var line  mega_res_c2b = line.new(na, na, na, na, xloc=xloc.bar_time)
var line  mega_res_g2b = line.new(na, na, na, na, xloc=xloc.bar_time)
var label mega_res_l2 = label.new(na, na, "", xloc=xloc.bar_time, style=label.style_label_left, textcolor=color.new(color.white, 0), color=color.new(color.black, 100), size=size.tiny)

var line  mega_sup_c1 = line.new(na, na, na, na, xloc=xloc.bar_time)
var line  mega_sup_g1 = line.new(na, na, na, na, xloc=xloc.bar_time)
var line  mega_sup_c1b = line.new(na, na, na, na, xloc=xloc.bar_time)
var line  mega_sup_g1b = line.new(na, na, na, na, xloc=xloc.bar_time)
var label mega_sup_l1 = label.new(na, na, "", xloc=xloc.bar_time, style=label.style_label_left, textcolor=color.new(color.white, 0), color=color.new(color.black, 100), size=size.tiny)

var line  mega_sup_c2 = line.new(na, na, na, na, xloc=xloc.bar_time)
var line  mega_sup_g2 = line.new(na, na, na, na, xloc=xloc.bar_time)
var line  mega_sup_c2b = line.new(na, na, na, na, xloc=xloc.bar_time)
var line  mega_sup_g2b = line.new(na, na, na, na, xloc=xloc.bar_time)
var label mega_sup_l2 = label.new(na, na, "", xloc=xloc.bar_time, style=label.style_label_left, textcolor=color.new(color.white, 0), color=color.new(color.black, 100), size=size.tiny)// MEGA CLOUD (ATR Zone) — primary + optional secondary
var line mega_res_u1 = line.new(na, na, na, na, xloc=xloc.bar_time)
var line mega_res_d1 = line.new(na, na, na, na, xloc=xloc.bar_time)
var linefill mega_res_f1 = linefill.new(mega_res_u1, mega_res_d1, color.new(c_mega, 90))

var line mega_sup_u1 = line.new(na, na, na, na, xloc=xloc.bar_time)
var line mega_sup_d1 = line.new(na, na, na, na, xloc=xloc.bar_time)
var linefill mega_sup_f1 = linefill.new(mega_sup_u1, mega_sup_d1, color.new(c_mega, 90))

var line mega_res_u2 = line.new(na, na, na, na, xloc=xloc.bar_time)
var line mega_res_d2 = line.new(na, na, na, na, xloc=xloc.bar_time)
var linefill mega_res_f2 = linefill.new(mega_res_u2, mega_res_d2, color.new(c_mega, 95))

var line mega_sup_u2 = line.new(na, na, na, na, xloc=xloc.bar_time)
var line mega_sup_d2 = line.new(na, na, na, na, xloc=xloc.bar_time)
var linefill mega_sup_f2 = linefill.new(mega_sup_u2, mega_sup_d2, color.new(c_mega, 95))

f_hide_ln(line l) =>
    int _x1 = line.get_x1(l)
    int _x2 = line.get_x2(l)
    if not na(_x1) or not na(_x2)
        line.set_xy1(l, na, na)
        line.set_xy2(l, na, na)

f_hide_ln2(line a, line b) =>
    f_hide_ln(a)
    f_hide_ln(b)

f_hide_ln4(line a, line b, line c, line d) =>
    f_hide_ln(a)
    f_hide_ln(b)
    f_hide_ln(c)
    f_hide_ln(d)

f_hide_lbl(label lb) =>
    int _x = label.get_x(lb)
    string _t = label.get_text(lb)
    if not na(_x) or str.length(_t) > 0
        label.set_xy(lb, na, na)
        label.set_text(lb, "")

f_hide_split(lc1, lc2, lg1, lg2, lb) =>
    f_hide_ln4(lc1, lc2, lg1, lg2)
    f_hide_lbl(lb)
f_line_apply(line ln, int x1, float y1, int x2, float y2, color col, int wid, stl, ex) =>
    int   _cx1 = line.get_x1(ln)
    int   _cx2 = line.get_x2(ln)
    float _cy1 = line.get_y1(ln)
    float _cy2 = line.get_y2(ln)
    bool  _set1 = na(_cx1) or _cx1 != x1 or na(_cy1) or _cy1 != y1
    bool  _set2 = na(_cx2) or _cx2 != x2 or na(_cy2) or _cy2 != y2
    if _set1
        line.set_xy1(ln, x1, y1)
    if _set2
        line.set_xy2(ln, x2, y2)
    line.set_color(ln, col)
    line.set_width(ln, wid)
    line.set_style(ln, stl)
    line.set_extend(ln, ex)

f_hide_mega_all() =>
    f_hide_split(mega_res_c1, mega_res_c1b, mega_res_g1, mega_res_g1b, mega_res_l1)
    f_hide_split(mega_res_c2, mega_res_c2b, mega_res_g2, mega_res_g2b, mega_res_l2)
    f_hide_split(mega_sup_c1, mega_sup_c1b, mega_sup_g1, mega_sup_g1b, mega_sup_l1)
    f_hide_split(mega_sup_c2, mega_sup_c2b, mega_sup_g2, mega_sup_g2b, mega_sup_l2)

    f_hide_ln2(mega_res_u1, mega_res_d1)
    f_hide_ln2(mega_sup_u1, mega_sup_d1)
    f_hide_ln2(mega_res_u2, mega_res_d2)
    f_hide_ln2(mega_sup_u2, mega_sup_d2)

f_select_mega(bool is_res, float[] ap, float[] ab, int[] at, bool ban_on, float ban_slope_ms, float ban_y_now) =>
    bool  found = false
    int   best_t2 = na
    float best_p2 = na
    int   best_t1 = na
    float best_p1 = na
    int   best_tc = 0
    bool  best_bk = false
    float best_sc = na
    float best_slope_ms = na
    float best_y_now = na

    float best_sc_soft = na
    int   best_t2_soft = na
    float best_p2_soft = na
    int   best_t1_soft = na
    float best_p1_soft = na
    int   best_tc_soft = 0
    bool  best_bk_soft = false
    float best_slope_ms_soft = na
    float best_y_now_soft = na

    int n = array.size(ap)
    float atrp_htf   = atr_htf_pct_cs

    float ban_slope_k = 0.25
    float ban_y_k     = 0.03
    float side        = is_res ? 1.0 : -1.0

    if n >= 2
        float tf_ms  = mega_tf_ms_cs
        int   anchors = math.min(mega_anchor_n, n - 1)

        float p_ext = array.get(ap, 0)
        if anchors > 1
            for e = 1 to anchors - 1
                float pe = array.get(ap, e)
                p_ext := is_res ? math.max(p_ext, pe) : math.min(p_ext, pe)

        for j = 0 to anchors - 1
            float p1 = array.get(ap, j)
            int   t1 = array.get(at, j)

            for i = j + 1 to n - 1
                float p2 = array.get(ap, i)
                int   t2 = array.get(at, i)

                if (t1 - t2) > (mega_min_bars * tf_ms)
                    float slope_ms  = (p1 - p2) / (t1 - t2)
                    float slope_day = slope_ms * 86400000.0

                    if math.abs(slope_day) < mega_slope_d and math.abs(slope_ms) > 0.0
                        float y_now_log = p2 + slope_ms * (time - t2)
                        float y_now     = f_inv(y_now_log)

                        bool banned = false
                        if ban_on and not na(ban_slope_ms) and not na(ban_y_now)
                            bool slope_sim = math.abs(slope_ms - ban_slope_ms) < (math.max(math.abs(ban_slope_ms), 1e-12) * ban_slope_k)
                            bool y_sim     = math.abs(y_now - ban_y_now) < (ban_y_now * ban_y_k)
                            banned := slope_sim and y_sim

                        if not banned
                            bool bk = false
                            int  tc = 0
                            int  viol = 0

                            for k = 0 to i - 1
                                if k != j
                                    int   tk = array.get(at, k)
                                    float lk_log  = p2 + slope_ms * (tk - t2)
                                    float lk_real = f_inv(lk_log)
                                    float tol_base = f_tol_mega(lk_real)

                                    float tol  = math.max(tol_base, lk_real * atrp_htf * 0.85)

                                    float body_log  = use_body ? array.get(ab, k) : array.get(ap, k)
                                    float body_real = f_inv(body_log)
                                    bool  body_break = side * (body_real - lk_real) > tol
                                    bool  between = tk < t1

                                    if between
                                        if body_break
                                            viol += 1
                                    else
                                        if body_break
                                            bk := true

                                    float wick_real = f_inv(array.get(ap, k))
                                    if math.abs(wick_real - lk_real) <= tol
                                        tc += 1

                            float cur_tol_base = f_tol_mega(y_now)
                            float cur_tol      = math.max(cur_tol_base, y_now * atrp_htf * 0.85)
                            if side * (close - y_now) > cur_tol
                                bk := true

                            int tot = 2 + tc
                            if tot >= mega_min_touch
                                float time_w  = math.log(1 + (t1 - t2) / tf_ms)
                                float touch_w = math.pow(tot, mega_touch_pw)
                                float sc      = touch_w * time_w

                                if mega_long_bonus > 0
                                    float len_norm = (t1 - t2) / (mega_min_bars * tf_ms)
                                    sc := sc * (1.0 + mega_long_bonus * math.log(1.0 + len_norm))

                                if mega_extreme_boost > 0
                                    float dist_ext = math.abs(p1 - p_ext)
                                    sc := sc * (1.0 + mega_extreme_boost / (1.0 + dist_ext * 12.0))

                                if bk
                                    sc := sc * 0.65

                                float sc_soft = sc / (1.0 + viol * 0.85)

                                if viol <= 2 and (na(best_sc) or sc > best_sc)
                                    best_sc := sc
                                    best_t2 := t2
                                    best_p2 := p2
                                    best_t1 := t1
                                    best_p1 := p1
                                    best_tc := tot
                                    best_bk := bk
                                    best_slope_ms := slope_ms
                                    best_y_now := y_now
                                    found := true

                                if na(best_sc_soft) or sc_soft > best_sc_soft
                                    best_sc_soft := sc_soft
                                    best_t2_soft := t2
                                    best_p2_soft := p2
                                    best_t1_soft := t1
                                    best_p1_soft := p1
                                    best_tc_soft := tot
                                    best_bk_soft := bk
                                    best_slope_ms_soft := slope_ms
                                    best_y_now_soft := y_now

    if (not found) and (not na(best_sc_soft))
        found := true
        best_t2 := best_t2_soft
        best_p2 := best_p2_soft
        best_t1 := best_t1_soft
        best_p1 := best_p1_soft
        best_tc := best_tc_soft
        best_bk := best_bk_soft
        best_slope_ms := best_slope_ms_soft
        best_y_now := best_y_now_soft

    if (not found) and na(best_sc_soft) and n >= 2
        float _tf_ms = mega_tf_ms_cs
        int   _t1 = array.get(at, 0)
        float _p1 = array.get(ap, 0)
        int   _t2 = array.get(at, n - 1)
        float _p2 = array.get(ap, n - 1)

        if (_t1 > _t2) and ((_t1 - _t2) > (_tf_ms * 3.0))
            float _slope_ms = (_p1 - _p2) / math.max(float(_t1 - _t2), 1.0)
            float _y_now    = f_inv(_p2 + _slope_ms * float(time - _t2))
            bool  _bk       = f_is_break(is_res, _y_now, mega_break_tol)

            found := true
            best_t2 := _t2
            best_p2 := _p2
            best_t1 := _t1
            best_p1 := _p1
            best_tc := 2
            best_bk := _bk
            best_slope_ms := _slope_ms
            best_y_now := _y_now

    [found, best_t2, best_p2, best_t1, best_p1, best_tc, best_bk, best_slope_ms, best_y_now]

f_mega_lbl_txt(string tag, int tc, string stars, int t2_ms) =>
    tag + str.tostring(tc) + "x  " + stars + "\n" + str.format("{0,date,yyyy-MM-dd}", t2_ms)

f_draw_mega(lcL, lcR, lgL, lgR, lb, t2, p2, t1, p1, tc, bk, is_res, is_secondary) =>
    color base = c_mega
    int   wC   = is_secondary ? (bk ? 1 : 2) : (bk ? 2 : 4)
    int   wG   = is_secondary ? 2 : 4
    color colC = is_secondary ? color.new(base, bk ? 88 : 82) : (bk ? color.new(base, 70) : base)
    color colG = is_secondary ? color.new(base, 97) : (bk ? color.new(base, 97) : color.new(base, 86))
    st         = is_secondary ? line.style_dashed : (bk ? line.style_dotted : line.style_solid)
    exRight    = show_ext ? extend.right : extend.none

    int step_ms = step_ms_cs
    int gap_ms  = mega_lbl_gap_bars * step_ms
    int xA      = t2
    int xB      = time
    float rr    = mega_lbl_pos == "Left" ? 0.20 : mega_lbl_pos == "Middle" ? 0.50 : 0.80
    int lx_raw  = xA + int(float(xB - xA) * rr)
    float lx_f  = math.max(float(xA + gap_ms * 2), math.min(float(xB - gap_ms * 2), float(lx_raw)))
    int   lx    = int(math.round(lx_f))

    float denom    = math.max(float(t1 - t2), 1.0)
    float slope_ms = (p1 - p2) / denom

    float yA = f_inv(p2)
    int   xL = lx - gap_ms / 2
    int   xR = lx + gap_ms / 2
    float yL = f_inv(p2 + slope_ms * (xL - t2))
    float yR = f_inv(p2 + slope_ms * (xR - t2))
    float yB = f_inv(p2 + slope_ms * (xB - t2))
    float ly = f_inv(p2 + slope_ms * (lx - t2))

    bool can_split = (xB - xA) > (gap_ms * 6)

    if can_split
        f_line_apply(lcL, xA, yA, xL, yL, colC, wC, st, extend.none)
        f_line_apply(lcR, xR, yR, xB, yB, colC, wC, st, exRight)
    else
        f_line_apply(lcL, xA, yA, xB, yB, colC, wC, st, exRight)
        f_hide_ln(lcR)

    if can_split
        f_line_apply(lgL, xA, yA, xL, yL, colG, wG, line.style_solid, extend.none)
        f_line_apply(lgR, xR, yR, xB, yB, colG, wG, line.style_solid, exRight)
    else
        f_line_apply(lgL, xA, yA, xB, yB, colG, wG, line.style_solid, exRight)
        f_hide_ln(lgR)

    if show_lbl_eff
        string tag = (is_res ? "MEGA R" : "MEGA S") + (is_secondary ? "2 " : "1 ")
        float tf_ms = mega_tf_ms_cs
        float bars_len = (t1 - t2) / tf_ms
        int stars_n = f_mega_star_count(tc, bk, bars_len)
        string stars = f_star_str(stars_n)
        string lbl_txt = f_mega_lbl_txt(tag, tc, stars, t2)

        label.set_xy(lb, lx, ly)
        label.set_text(lb, lbl_txt)
        label.set_size(lb, lbl_size_eff_cs)
        label.set_textcolor(lb, colC)
        label.set_color(lb, color.new(color.white, mega_lbl_bg))
    else
        f_hide_lbl(lb)

f_draw_cloud(line lu, line ld, linefill lf, int t2, float p2, int t1, float p1, bool is_secondary) =>
    float pct  = atr_htf_pct_cs
    float band = math.min(0.30, math.max(0.0, pct * mega_cloud_mult))
    float k_up = 1.0 + band
    float k_dn = math.max(0.01, 1.0 - band)

    float y2  = f_inv(p2)
    float y1  = f_inv(p1)
    float y2u = y2 * k_up
    float y2d = y2 * k_dn
    float y1u = y1 * k_up
    float y1d = y1 * k_dn

    int alpha = is_secondary ? math.min(97, mega_cloud_alpha + 8) : mega_cloud_alpha
    exRight   = show_ext ? extend.right : extend.none
    color hid = color.new(c_mega, 100)

    f_line_apply(lu, t2, y2u, t1, y1u, hid, 1, line.style_solid, exRight)
    f_line_apply(ld, t2, y2d, t1, y1d, hid, 1, line.style_solid, exRight)
    linefill.set_color(lf, color.new(c_mega, alpha))

var bool  lockMegaR_ok = false
var int   lockMegaR_t2 = na
var float lockMegaR_p2 = na
var int   lockMegaR_t1 = na
var float lockMegaR_p1 = na
var int   lockMegaR_tc = 0
var bool  lockMegaR_bk = false
var float lockMegaR_s  = na

var bool  lockMegaS_ok = false
var int   lockMegaS_t2 = na
var float lockMegaS_p2 = na
var int   lockMegaS_t1 = na
var float lockMegaS_p1 = na
var int   lockMegaS_tc = 0
var bool  lockMegaS_bk = false
var float lockMegaS_s  = na

bool mega_visual_refresh = barstate.islast and (not show_ext)
if not show_mega_eff
    f_hide_mega_all()
else if mega_updated or do_micro_scan or mega_visual_refresh
    f_hide_mega_all()

    bool used_macro_R = false
    bool used_macro_S = false

    float[] r_p = mph_p
    float[] r_b = mph_b
    int[]   r_t = mph_t

    float[] s_p = mpl_p
    float[] s_b = mpl_b
    int[]   s_t = mpl_t

    if mega_source == "Macro" or (mega_source == "Auto" and array.size(mph_p) < 2)
        used_macro_R := true
        r_p := mxh_p
        r_b := mxh_b
        r_t := mxh_t

    if mega_source == "Macro" or (mega_source == "Auto" and array.size(mpl_p) < 2)
        used_macro_S := true
        s_p := mxl_p
        s_b := mxl_b
        s_t := mxl_t

    bool okR1 = false
    int   t2R1 = na
    float p2R1 = na
    int   t1R1 = na
    float p1R1 = na
    int   tcR1 = 0
    bool  bkR1 = false
    float sR1  = na
    float yR1  = na

    bool useLock = repaint_mode_eff == "Locked"
    float yR_lock  = lockMegaR_ok ? f_inv(lockMegaR_p2 + lockMegaR_s * float(time - lockMegaR_t2)) : na
    bool  brR_lock = lockMegaR_ok ? f_is_break(true, yR_lock, mega_break_tol) : false
    bool  needR1   = (not useLock) or (not lockMegaR_ok) or (replace_broken_eff and brR_lock)

    if needR1
        [okR1, t2R1, p2R1, t1R1, p1R1, tcR1, bkR1, sR1, yR1] = f_select_mega(true, r_p, r_b, r_t, false, 0.0, 0.0)
        if (not okR1) and (array.size(macro_ph_price) >= 2)
            used_macro_R := true
            [okR1, t2R1, p2R1, t1R1, p1R1, tcR1, bkR1, sR1, yR1] = f_select_mega(true, macro_ph_price, macro_ph_body, macro_ph_time, false, 0.0, 0.0)
        lockMegaR_ok := okR1
        if okR1
            lockMegaR_t2 := t2R1, lockMegaR_p2 := p2R1, lockMegaR_t1 := t1R1, lockMegaR_p1 := p1R1
            lockMegaR_tc := tcR1, lockMegaR_bk := bkR1, lockMegaR_s  := sR1
        else
            lockMegaR_t2 := na, lockMegaR_p2 := na, lockMegaR_t1 := na, lockMegaR_p1 := na
            lockMegaR_tc := 0,  lockMegaR_bk := false,  lockMegaR_s  := na
    else
        okR1 := true
        t2R1 := lockMegaR_t2, p2R1 := lockMegaR_p2, t1R1 := lockMegaR_t1, p1R1 := lockMegaR_p1
        tcR1 := lockMegaR_tc, bkR1 := lockMegaR_bk, sR1 := lockMegaR_s
        yR1  := f_inv(p2R1 + sR1 * float(time - t2R1))

    if okR1
        f_draw_mega(mega_res_c1, mega_res_c1b, mega_res_g1, mega_res_g1b, mega_res_l1, t2R1, p2R1, t1R1, p1R1, tcR1, bkR1, true, false)
        if show_mega_cloud_eff
            f_draw_cloud(mega_res_u1, mega_res_d1, mega_res_f1, t2R1, p2R1, t1R1, p1R1, false)

    if show_mega2_eff and okR1
        [okR2, t2R2, p2R2, t1R2, p1R2, tcR2, bkR2, sR2, yR2] = f_select_mega(true,  r_p, r_b, r_t, true, sR1, yR1)
        if okR2
            f_draw_mega(mega_res_c2, mega_res_c2b, mega_res_g2, mega_res_g2b, mega_res_l2, t2R2, p2R2, t1R2, p1R2, tcR2, bkR2, true, true)
            f_hide_ln2(mega_res_u2, mega_res_d2)
            linefill.set_color(mega_res_f2, color.new(c_mega, 100))

    bool okS1 = false
    int   t2S1 = na
    float p2S1 = na
    int   t1S1 = na
    float p1S1 = na
    int   tcS1 = 0
    bool  bkS1 = false
    float sS1  = na
    float yS1  = na

    float yS_lock  = lockMegaS_ok ? f_inv(lockMegaS_p2 + lockMegaS_s * float(time - lockMegaS_t2)) : na
    bool  brS_lock = lockMegaS_ok ? f_is_break(false, yS_lock, mega_break_tol) : false
    bool  needS1   = (not useLock) or (not lockMegaS_ok) or (replace_broken_eff and brS_lock)

    if needS1
        [okS1, t2S1, p2S1, t1S1, p1S1, tcS1, bkS1, sS1, yS1] = f_select_mega(false, s_p, s_b, s_t, false, 0.0, 0.0)
        if (not okS1) and (array.size(macro_pl_price) >= 2)
            used_macro_S := true
            [okS1, t2S1, p2S1, t1S1, p1S1, tcS1, bkS1, sS1, yS1] = f_select_mega(false, macro_pl_price, macro_pl_body, macro_pl_time, false, 0.0, 0.0)
        lockMegaS_ok := okS1
        if okS1
            lockMegaS_t2 := t2S1, lockMegaS_p2 := p2S1, lockMegaS_t1 := t1S1, lockMegaS_p1 := p1S1
            lockMegaS_tc := tcS1, lockMegaS_bk := bkS1, lockMegaS_s  := sS1
        else
            lockMegaS_t2 := na, lockMegaS_p2 := na, lockMegaS_t1 := na, lockMegaS_p1 := na
            lockMegaS_tc := 0,  lockMegaS_bk := false,  lockMegaS_s  := na
    else
        okS1 := true
        t2S1 := lockMegaS_t2, p2S1 := lockMegaS_p2, t1S1 := lockMegaS_t1, p1S1 := lockMegaS_p1
        tcS1 := lockMegaS_tc, bkS1 := lockMegaS_bk, sS1 := lockMegaS_s
        yS1  := f_inv(p2S1 + sS1 * float(time - t2S1))

    if okS1
        f_draw_mega(mega_sup_c1, mega_sup_c1b, mega_sup_g1, mega_sup_g1b, mega_sup_l1, t2S1, p2S1, t1S1, p1S1, tcS1, bkS1, false, false)
        if show_mega_cloud_eff
            f_draw_cloud(mega_sup_u1, mega_sup_d1, mega_sup_f1, t2S1, p2S1, t1S1, p1S1, false)

    if show_mega2_eff and okS1
        [okS2, t2S2, p2S2, t1S2, p1S2, tcS2, bkS2, sS2, yS2] = f_select_mega(false, s_p, s_b, s_t, true, sS1, yS1)
        if okS2
            f_draw_mega(mega_sup_c2, mega_sup_c2b, mega_sup_g2, mega_sup_g2b, mega_sup_l2, t2S2, p2S2, t1S2, p1S2, tcS2, bkS2, false, true)
            f_hide_ln2(mega_sup_u2, mega_sup_d2)
            linefill.set_color(mega_sup_f2, color.new(c_mega, 100))

f_y_line_bar(float p2, float sl, int t2) => f_inv(p2 + sl * float(bar_index - t2))
f_y_line_time(float p2, float sl_ms, int t2_ms) => f_inv(p2 + sl_ms * float(time - t2_ms))

f_sig_evt_msg(bool enabled, bool trig, string code, string evt, float yv, int qv, float atr_safe) =>
    string out = ""
    if enabled and trig and not na(yv)
        float d = math.abs(yv - close) / atr_safe
        out := code + " " + evt + " @" + str.tostring(yv, format.price) + " d" + str.tostring(d, format.mintick) + "A"
        if not na(qv)
            out += " Q" + str.tostring(qv) + (qtag_show_grade ? f_grade(qv) : "")
        out += "; "
    out

f_sig_evt_tag(bool enabled, bool trig, string txt) =>
    (enabled and trig) ? (txt + "; ") : ""

f_cd_pass(int last_bar) =>
    na(last_bar) or (bar_index - last_bar > sig_cooldown)

f_scope_slots(string scope) =>
    scope == "Top 3" ? 3 : scope == "Top 2" ? 2 : 1

f_q_ok(int qv) =>
    sig_min_q <= 0 ? true : (not na(qv) and qv >= sig_min_q)

f_br_edge_evt(bool base_ok, bool break_now, bool prev) =>
    base_ok and break_now and not prev

f_rt_evt(bool q_ok, bool done, int br_bar, int win, bool is_res, float yv) =>
    q_ok and (not done) and (not na(br_bar)) and (bar_index - br_bar <= win) and f_is_retest(is_res, yv)

f_q0(int[] aq) =>
    array.size(aq) > 0 ? array.get(aq, 0) : 0

f_qpair_txt(int qA, int qB) =>
    (qA > 0 ? str.tostring(qA) : "--") + "/" + (qB > 0 ? str.tostring(qB) : "--")

float _sig_conf_atr_cs = atr14_cs_safe

f_sig_conf_ok_micro_res(int slot, int need) =>
    if need <= 0
        true
    else
        bool _hasBase = f_has_slot_int(microR_t2, slot)
        float _yBase  = _hasBase ? f_af(microR_y, slot)  : na
        bool  _brBase = _hasBase ? f_ab(microR_br, slot) : false

        bool  _hasM   = show_meso_eff and f_has_slot_int(mesoR_t2, 0)
        float _yM     = _hasM ? f_af(mesoR_y, 0)  : na
        bool  _brM    = _hasM ? f_ab(mesoR_br, 0) : false

        bool _ok = false
        if _hasBase and not _brBase and not na(_yBase) and _hasM and not _brM and not na(_yM)
            float _atrCs = _sig_conf_atr_cs
            float _band  = confluence_band_atr * _atrCs

            float _min2 = math.min(_yBase, _yM)
            float _max2 = math.max(_yBase, _yM)
            float _mid2 = (_min2 + _max2) / 2.0
            bool  _near2 = confluence_near_atr <= 0 ? true : (math.abs(_mid2 - close) / _atrCs <= confluence_near_atr)
            bool  _pairOK = (_max2 - _min2) <= _band

            if need == 2
                _ok := _pairOK and _near2
            else
                bool _extraFound = false
                for j = 0 to 2
                    if j != slot
                        bool _hasX = f_has_slot_int(microR_t2, j)
                        float _yX  = _hasX ? f_af(microR_y, j)  : na
                        bool  _brX = _hasX ? f_ab(microR_br, j) : false
                        if _hasX and not _brX and not na(_yX)
                            float _min3 = math.min(_min2, _yX)
                            float _max3 = math.max(_max2, _yX)
                            if (_max3 - _min3) <= _band
                                float _mid3 = (_min3 + _max3) / 2.0
                                bool  _near3 = confluence_near_atr <= 0 ? true : (math.abs(_mid3 - close) / _atrCs <= confluence_near_atr)
                                if _near3
                                    _extraFound := true
                _ok := _pairOK and _near2 and _extraFound
        _ok

f_sig_conf_ok_micro_sup(int slot, int need) =>
    if need <= 0
        true
    else
        bool _hasBase = f_has_slot_int(microS_t2, slot)
        float _yBase  = _hasBase ? f_af(microS_y, slot)  : na
        bool  _brBase = _hasBase ? f_ab(microS_br, slot) : false

        bool  _hasM   = show_meso_eff and f_has_slot_int(mesoS_t2, 0)
        float _yM     = _hasM ? f_af(mesoS_y, 0)  : na
        bool  _brM    = _hasM ? f_ab(mesoS_br, 0) : false

        bool _ok = false
        if _hasBase and not _brBase and not na(_yBase) and _hasM and not _brM and not na(_yM)
            float _atrCs = _sig_conf_atr_cs
            float _band  = confluence_band_atr * _atrCs

            float _min2 = math.min(_yBase, _yM)
            float _max2 = math.max(_yBase, _yM)
            float _mid2 = (_min2 + _max2) / 2.0
            bool  _near2 = confluence_near_atr <= 0 ? true : (math.abs(_mid2 - close) / _atrCs <= confluence_near_atr)
            bool  _pairOK = (_max2 - _min2) <= _band

            if need == 2
                _ok := _pairOK and _near2
            else
                bool _extraFound = false
                for j = 0 to 2
                    if j != slot
                        bool _hasX = f_has_slot_int(microS_t2, j)
                        float _yX  = _hasX ? f_af(microS_y, j)  : na
                        bool  _brX = _hasX ? f_ab(microS_br, j) : false
                        if _hasX and not _brX and not na(_yX)
                            float _min3 = math.min(_min2, _yX)
                            float _max3 = math.max(_max2, _yX)
                            if (_max3 - _min3) <= _band
                                float _mid3 = (_min3 + _max3) / 2.0
                                bool  _near3 = confluence_near_atr <= 0 ? true : (math.abs(_mid3 - close) / _atrCs <= confluence_near_atr)
                                if _near3
                                    _extraFound := true
                _ok := _pairOK and _near2 and _extraFound
        _ok

int _sigN = f_scope_slots(sig_scope)

var bool[] _prev_microR_break = array.new_bool(3, false)
var bool[] _prev_microS_break = array.new_bool(3, false)

var int[]   microR_br_bar      = array.new_int(3, na)
var int[]   microR_br_t2       = array.new_int(3, na)
var float[] microR_br_p2       = array.new_float(3, na)
var float[] microR_br_sl       = array.new_float(3, na)
var bool[]  microR_retest_done = array.new_bool(3, false)

var int[]   microS_br_bar      = array.new_int(3, na)
var int[]   microS_br_t2       = array.new_int(3, na)
var float[] microS_br_p2       = array.new_float(3, na)
var float[] microS_br_sl       = array.new_float(3, na)
var bool[]  microS_retest_done = array.new_bool(3, false)

bool micro_res_break  = false
bool micro_sup_break  = false
bool micro_res_retest = false
bool micro_sup_retest = false

int  _sigConfNeed = sig_conf_filter == "x3" ? 3 : sig_conf_filter == "x2" ? 2 : 0

for i = 0 to 2
    if i < _sigN
        int   microR_t2_i = f_ai(microR_t2, i)
        float microR_p2_i = f_af(microR_p2, i)
        float microR_sl_i = f_af(microR_sl, i)
        bool  microR_active_i = not na(microR_t2_i) and not na(microR_p2_i) and not na(microR_sl_i)
        float microR_y_now_i = microR_active_i ? f_y_line_bar(microR_p2_i, microR_sl_i, microR_t2_i) : na
        bool microR_break_now_i = microR_active_i ? f_is_break(true, microR_y_now_i, micro_break_tol) : false
        int microR_break_now_i_q_i = f_ai(microR_q, i)
        bool microR_break_now_i_q_ok = f_q_ok(microR_break_now_i_q_i)

        bool _sigConfOK_R_i = f_sig_conf_ok_micro_res(i, _sigConfNeed)
        bool prevR = f_ab(_prev_microR_break, i)
        bool brR_evt = f_br_edge_evt(_sigConfOK_R_i and microR_break_now_i_q_ok, microR_break_now_i, prevR)
        micro_res_break := micro_res_break or brR_evt
        array.set(_prev_microR_break, i, microR_break_now_i)

        if brR_evt
            array.set(microR_br_bar, i, bar_index)
            array.set(microR_br_t2,  i, microR_t2_i)
            array.set(microR_br_p2,  i, microR_p2_i)
            array.set(microR_br_sl,  i, microR_sl_i)
            array.set(microR_retest_done, i, false)

        int   brR_bar_i  = f_ai(microR_br_bar, i)
        int   brR_t2_i   = f_ai(microR_br_t2, i)
        float brR_p2_i   = f_af(microR_br_p2, i)
        float brR_sl_i   = f_af(microR_br_sl, i)
        bool  doneR_i    = f_ab(microR_retest_done, i)
        float brR_y_i    = not na(brR_t2_i) ? f_y_line_bar(brR_p2_i, brR_sl_i, brR_t2_i) : na
        bool  retR_evt   = f_rt_evt(microR_break_now_i_q_ok, doneR_i, brR_bar_i, micro_retest_window, true, brR_y_i)

        if retR_evt
            array.set(microR_retest_done, i, true)
        micro_res_retest := micro_res_retest or retR_evt

        int   microS_t2_i = f_ai(microS_t2, i)
        float microS_p2_i = f_af(microS_p2, i)
        float microS_sl_i = f_af(microS_sl, i)
        bool  microS_active_i = not na(microS_t2_i) and not na(microS_p2_i) and not na(microS_sl_i)
        float microS_y_now_i = microS_active_i ? f_y_line_bar(microS_p2_i, microS_sl_i, microS_t2_i) : na
        bool microS_break_now_i = microS_active_i ? f_is_break(false, microS_y_now_i, micro_break_tol) : false
        int microS_break_now_i_q_i = f_ai(microS_q, i)
        bool microS_break_now_i_q_ok = f_q_ok(microS_break_now_i_q_i)

        bool _sigConfOK_S_i = f_sig_conf_ok_micro_sup(i, _sigConfNeed)
        bool prevS = f_ab(_prev_microS_break, i)
        bool brS_evt = f_br_edge_evt(_sigConfOK_S_i and microS_break_now_i_q_ok, microS_break_now_i, prevS)
        micro_sup_break := micro_sup_break or brS_evt
        array.set(_prev_microS_break, i, microS_break_now_i)

        if brS_evt
            array.set(microS_br_bar, i, bar_index)
            array.set(microS_br_t2,  i, microS_t2_i)
            array.set(microS_br_p2,  i, microS_p2_i)
            array.set(microS_br_sl,  i, microS_sl_i)
            array.set(microS_retest_done, i, false)

        int   brS_bar_i  = f_ai(microS_br_bar, i)
        int   brS_t2_i   = f_ai(microS_br_t2, i)
        float brS_p2_i   = f_af(microS_br_p2, i)
        float brS_sl_i   = f_af(microS_br_sl, i)
        bool  doneS_i    = f_ab(microS_retest_done, i)
        float brS_y_i    = not na(brS_t2_i) ? f_y_line_bar(brS_p2_i, brS_sl_i, brS_t2_i) : na
        bool  retS_evt   = f_rt_evt(microS_break_now_i_q_ok, doneS_i, brS_bar_i, micro_retest_window, false, brS_y_i)

        if retS_evt
            array.set(microS_retest_done, i, true)
        micro_sup_retest := micro_sup_retest or retS_evt

int _mesoSigN = _sigN

var bool[] _prev_mesoR_break = array.new_bool(3, false)
var bool[] _prev_mesoS_break = array.new_bool(3, false)

var int[]   mesoR_br_bar      = array.new_int(3, na)
var int[]   mesoR_br_t2       = array.new_int(3, na)
var float[] mesoR_br_p2       = array.new_float(3, na)
var float[] mesoR_br_sl       = array.new_float(3, na)
var bool[]  mesoR_retest_done = array.new_bool(3, false)

var int[]   mesoS_br_bar      = array.new_int(3, na)
var int[]   mesoS_br_t2       = array.new_int(3, na)
var float[] mesoS_br_p2       = array.new_float(3, na)
var float[] mesoS_br_sl       = array.new_float(3, na)
var bool[]  mesoS_retest_done = array.new_bool(3, false)

bool meso_res_break  = false
bool meso_sup_break  = false
bool meso_res_retest = false
bool meso_sup_retest = false

for i = 0 to 2
    if i < _mesoSigN
        int   mesoR_t2_i = f_ai(mesoR_t2, i)
        float mesoR_p2_i = f_af(mesoR_p2, i)
        float mesoR_sl_i = f_af(mesoR_sl, i)
        bool  mesoR_active_i = show_meso_eff and not na(mesoR_t2_i) and not na(mesoR_p2_i) and not na(mesoR_sl_i)
        float mesoR_y_now_i = mesoR_active_i ? f_y_line_time(mesoR_p2_i, mesoR_sl_i, mesoR_t2_i) : na
        bool mesoR_break_now_i = mesoR_active_i ? f_is_break(true, mesoR_y_now_i, meso_break_tol) : false
        int mesoR_break_now_i_q_i = f_ai(mesoR_q, i)
        bool mesoR_break_now_i_q_ok = f_q_ok(mesoR_break_now_i_q_i)

        bool prevR = f_ab(_prev_mesoR_break, i)
        bool brR_evt = f_br_edge_evt(mesoR_break_now_i_q_ok, mesoR_break_now_i, prevR)
        meso_res_break := meso_res_break or brR_evt
        array.set(_prev_mesoR_break, i, mesoR_break_now_i)

        if brR_evt
            array.set(mesoR_br_bar, i, bar_index)
            array.set(mesoR_br_t2,  i, mesoR_t2_i)
            array.set(mesoR_br_p2,  i, mesoR_p2_i)
            array.set(mesoR_br_sl,  i, mesoR_sl_i)
            array.set(mesoR_retest_done, i, false)

        int   brR_bar_i  = f_ai(mesoR_br_bar, i)
        int   brR_t2_i   = f_ai(mesoR_br_t2, i)
        float brR_p2_i   = f_af(mesoR_br_p2, i)
        float brR_sl_i   = f_af(mesoR_br_sl, i)
        bool  doneR_i    = f_ab(mesoR_retest_done, i)
        float brR_y_i    = not na(brR_t2_i) ? f_y_line_time(brR_p2_i, brR_sl_i, brR_t2_i) : na
        bool  retR_evt   = f_rt_evt(mesoR_break_now_i_q_ok, doneR_i, brR_bar_i, meso_retest_window, true, brR_y_i)

        if retR_evt
            array.set(mesoR_retest_done, i, true)
        meso_res_retest := meso_res_retest or retR_evt

        int   mesoS_t2_i = f_ai(mesoS_t2, i)
        float mesoS_p2_i = f_af(mesoS_p2, i)
        float mesoS_sl_i = f_af(mesoS_sl, i)
        bool  mesoS_active_i = show_meso_eff and not na(mesoS_t2_i) and not na(mesoS_p2_i) and not na(mesoS_sl_i)
        float mesoS_y_now_i = mesoS_active_i ? f_y_line_time(mesoS_p2_i, mesoS_sl_i, mesoS_t2_i) : na
        bool mesoS_break_now_i = mesoS_active_i ? f_is_break(false, mesoS_y_now_i, meso_break_tol) : false
        int mesoS_break_now_i_q_i = f_ai(mesoS_q, i)
        bool mesoS_break_now_i_q_ok = f_q_ok(mesoS_break_now_i_q_i)

        bool prevS = f_ab(_prev_mesoS_break, i)
        bool brS_evt = f_br_edge_evt(mesoS_break_now_i_q_ok, mesoS_break_now_i, prevS)
        meso_sup_break := meso_sup_break or brS_evt
        array.set(_prev_mesoS_break, i, mesoS_break_now_i)

        if brS_evt
            array.set(mesoS_br_bar, i, bar_index)
            array.set(mesoS_br_t2,  i, mesoS_t2_i)
            array.set(mesoS_br_p2,  i, mesoS_p2_i)
            array.set(mesoS_br_sl,  i, mesoS_sl_i)
            array.set(mesoS_retest_done, i, false)

        int   brS_bar_i  = f_ai(mesoS_br_bar, i)
        int   brS_t2_i   = f_ai(mesoS_br_t2, i)
        float brS_p2_i   = f_af(mesoS_br_p2, i)
        float brS_sl_i   = f_af(mesoS_br_sl, i)
        bool  doneS_i    = f_ab(mesoS_retest_done, i)
        float brS_y_i    = not na(brS_t2_i) ? f_y_line_time(brS_p2_i, brS_sl_i, brS_t2_i) : na
        bool  retS_evt   = f_rt_evt(mesoS_break_now_i_q_ok, doneS_i, brS_bar_i, meso_retest_window, false, brS_y_i)

        if retS_evt
            array.set(mesoS_retest_done, i, true)
        meso_sup_retest := meso_sup_retest or retS_evt

bool megaR_active = lockMegaR_ok and not na(lockMegaR_t2) and not na(lockMegaR_s)
bool megaS_active = lockMegaS_ok and not na(lockMegaS_t2) and not na(lockMegaS_s)
float megaR_y_now = megaR_active ? f_y_line_time(lockMegaR_p2, lockMegaR_s, lockMegaR_t2) : na
float megaS_y_now = megaS_active ? f_y_line_time(lockMegaS_p2, lockMegaS_s, lockMegaS_t2) : na
bool megaR_break_now = megaR_active ? f_is_break(true,  megaR_y_now, mega_break_tol) : false
bool megaS_break_now = megaS_active ? f_is_break(false, megaS_y_now, mega_break_tol) : false

var bool _prev_megaR_break = false
var bool _prev_megaS_break = false
bool mega_res_break = f_br_edge_evt(true, megaR_break_now, _prev_megaR_break)
bool mega_sup_break = f_br_edge_evt(true, megaS_break_now, _prev_megaS_break)
_prev_megaR_break := megaR_break_now
_prev_megaS_break := megaS_break_now

var int   megaR_br_bar = na
var int   megaR_br_t2  = na
var float megaR_br_p2  = na
var float megaR_br_s   = na
var bool  megaR_retest_done = false

var int   megaS_br_bar = na
var int   megaS_br_t2  = na
var float megaS_br_p2  = na
var float megaS_br_s   = na
var bool  megaS_retest_done = false

if mega_res_break
    megaR_br_bar := bar_index
    megaR_br_t2  := lockMegaR_t2
    megaR_br_p2  := lockMegaR_p2
    megaR_br_s   := lockMegaR_s
    megaR_retest_done := false

if mega_sup_break
    megaS_br_bar := bar_index
    megaS_br_t2  := lockMegaS_t2
    megaS_br_p2  := lockMegaS_p2
    megaS_br_s   := lockMegaS_s
    megaS_retest_done := false

float megaR_br_y = not na(megaR_br_t2) ? f_y_line_time(megaR_br_p2, megaR_br_s, megaR_br_t2) : na
float megaS_br_y = not na(megaS_br_t2) ? f_y_line_time(megaS_br_p2, megaS_br_s, megaS_br_t2) : na
bool mega_res_retest = f_rt_evt(true, megaR_retest_done, megaR_br_bar, mega_retest_window, true, megaR_br_y)
bool mega_sup_retest = f_rt_evt(true, megaS_retest_done, megaS_br_bar, mega_retest_window, false, megaS_br_y)
if mega_res_retest
    megaR_retest_done := true
if mega_sup_retest
    megaS_retest_done := true

bool _sig_tf_ok = timeframe.isintraday or timeframe.isdaily
bool show_sig_tf = show_sig_eff and _sig_tf_ok
bool show_meso_sig_tf = show_sig_tf and show_meso_sig_eff

var int _lb_micro_res_break  = na
var int _lb_micro_sup_break  = na
var int _lb_micro_res_retest = na
var int _lb_micro_sup_retest = na
var int _lb_meso_res_break   = na
var int _lb_meso_sup_break   = na
var int _lb_meso_res_retest  = na
var int _lb_meso_sup_retest  = na
var int _lb_mega_res_break   = na
var int _lb_mega_sup_break   = na
var int _lb_mega_res_retest  = na
var int _lb_mega_sup_retest  = na

if sig_cooldown > 0
    bool _t_mrb = micro_res_break and f_cd_pass(_lb_micro_res_break)
    bool _t_msb = micro_sup_break and f_cd_pass(_lb_micro_sup_break)
    bool _t_mrr = micro_res_retest and f_cd_pass(_lb_micro_res_retest)
    bool _t_msr = micro_sup_retest and f_cd_pass(_lb_micro_sup_retest)

    bool _t_xrb = meso_res_break and f_cd_pass(_lb_meso_res_break)
    bool _t_xsb = meso_sup_break and f_cd_pass(_lb_meso_sup_break)
    bool _t_xrr = meso_res_retest and f_cd_pass(_lb_meso_res_retest)
    bool _t_xsr = meso_sup_retest and f_cd_pass(_lb_meso_sup_retest)

    bool _t_grb = mega_res_break and f_cd_pass(_lb_mega_res_break)
    bool _t_gsb = mega_sup_break and f_cd_pass(_lb_mega_sup_break)
    bool _t_grr = mega_res_retest and f_cd_pass(_lb_mega_res_retest)
    bool _t_gsr = mega_sup_retest and f_cd_pass(_lb_mega_sup_retest)

    if _t_mrb
        _lb_micro_res_break := bar_index
    if _t_msb
        _lb_micro_sup_break := bar_index
    if _t_mrr
        _lb_micro_res_retest := bar_index
    if _t_msr
        _lb_micro_sup_retest := bar_index

    if _t_xrb
        _lb_meso_res_break := bar_index
    if _t_xsb
        _lb_meso_sup_break := bar_index
    if _t_xrr
        _lb_meso_res_retest := bar_index
    if _t_xsr
        _lb_meso_sup_retest := bar_index

    if _t_grb
        _lb_mega_res_break := bar_index
    if _t_gsb
        _lb_mega_sup_break := bar_index
    if _t_grr
        _lb_mega_res_retest := bar_index
    if _t_gsr
        _lb_mega_sup_retest := bar_index

    micro_res_break  := _t_mrb
    micro_sup_break  := _t_msb
    micro_res_retest := _t_mrr
    micro_sup_retest := _t_msr

    meso_res_break  := _t_xrb
    meso_sup_break  := _t_xsb
    meso_res_retest := _t_xrr
    meso_sup_retest := _t_xsr

    mega_res_break  := _t_grb
    mega_sup_break  := _t_gsb
    mega_res_retest := _t_grr
    mega_sup_retest := _t_gsr
bool sigTiny   = sig_size_opt == "Tiny"
bool sigSmall  = sig_size_opt == "Small"
bool sigNormal = sig_size_opt == "Normal"

bool _ev_mr_b  = show_sig_tf and micro_res_break
bool _ev_ms_b  = show_sig_tf and micro_sup_break
bool _ev_mr_r  = show_sig_tf and micro_res_retest
bool _ev_ms_r  = show_sig_tf and micro_sup_retest
bool _ev_xr_b  = show_meso_sig_tf and meso_res_break
bool _ev_xs_b  = show_meso_sig_tf and meso_sup_break
bool _ev_xr_r  = show_meso_sig_tf and meso_res_retest
bool _ev_xs_r  = show_meso_sig_tf and meso_sup_retest
bool _ev_MR_b  = show_sig_tf and mega_res_break
bool _ev_MS_b  = show_sig_tf and mega_sup_break
bool _ev_MR_r  = show_sig_tf and mega_res_retest
bool _ev_MS_r  = show_sig_tf and mega_sup_retest

plotshape(_ev_mr_b and sigTiny, style=shape.triangleup, location=location.abovebar, size=size.tiny, text="MiR")
plotshape(_ev_mr_b and sigSmall, style=shape.triangleup, location=location.abovebar, size=size.small, text="MiR")
plotshape(_ev_mr_b and sigNormal, style=shape.triangleup, location=location.abovebar, size=size.normal, text="MiR")

plotshape(_ev_ms_b and sigTiny, style=shape.triangledown, location=location.belowbar, size=size.tiny, text="MiS")
plotshape(_ev_ms_b and sigSmall, style=shape.triangledown, location=location.belowbar, size=size.small, text="MiS")
plotshape(_ev_ms_b and sigNormal, style=shape.triangledown, location=location.belowbar, size=size.normal, text="MiS")

plotshape(_ev_mr_r and sigTiny, style=shape.circle, location=location.abovebar, size=size.tiny, text="rMi")
plotshape(_ev_mr_r and sigSmall, style=shape.circle, location=location.abovebar, size=size.small, text="rMi")
plotshape(_ev_mr_r and sigNormal, style=shape.circle, location=location.abovebar, size=size.normal, text="rMi")

plotshape(_ev_ms_r and sigTiny, style=shape.circle, location=location.belowbar, size=size.tiny, text="rMi")
plotshape(_ev_ms_r and sigSmall, style=shape.circle, location=location.belowbar, size=size.small, text="rMi")
plotshape(_ev_ms_r and sigNormal, style=shape.circle, location=location.belowbar, size=size.normal, text="rMi")

plotshape(_ev_xr_b and sigTiny, style=shape.triangleup, location=location.abovebar, size=size.tiny, text="MeR")
plotshape(_ev_xr_b and sigSmall, style=shape.triangleup, location=location.abovebar, size=size.small, text="MeR")
plotshape(_ev_xr_b and sigNormal, style=shape.triangleup, location=location.abovebar, size=size.normal, text="MeR")

plotshape(_ev_xs_b and sigTiny, style=shape.triangledown, location=location.belowbar, size=size.tiny, text="MeS")
plotshape(_ev_xs_b and sigSmall, style=shape.triangledown, location=location.belowbar, size=size.small, text="MeS")
plotshape(_ev_xs_b and sigNormal, style=shape.triangledown, location=location.belowbar, size=size.normal, text="MeS")

plotshape(_ev_xr_r and sigTiny, style=shape.circle, location=location.abovebar, size=size.tiny, text="rMe")
plotshape(_ev_xr_r and sigSmall, style=shape.circle, location=location.abovebar, size=size.small, text="rMe")
plotshape(_ev_xr_r and sigNormal, style=shape.circle, location=location.abovebar, size=size.normal, text="rMe")

plotshape(_ev_xs_r and sigTiny, style=shape.circle, location=location.belowbar, size=size.tiny, text="rMe")
plotshape(_ev_xs_r and sigSmall, style=shape.circle, location=location.belowbar, size=size.small, text="rMe")
plotshape(_ev_xs_r and sigNormal, style=shape.circle, location=location.belowbar, size=size.normal, text="rMe")

plotshape(_ev_MR_b and sigTiny, style=shape.triangleup, location=location.abovebar, size=size.tiny, text="MR")
plotshape(_ev_MR_b and sigSmall, style=shape.triangleup, location=location.abovebar, size=size.small, text="MR")
plotshape(_ev_MR_b and sigNormal, style=shape.triangleup, location=location.abovebar, size=size.normal, text="MR")

plotshape(_ev_MS_b and sigTiny, style=shape.triangledown, location=location.belowbar, size=size.tiny, text="MS")
plotshape(_ev_MS_b and sigSmall, style=shape.triangledown, location=location.belowbar, size=size.small, text="MS")
plotshape(_ev_MS_b and sigNormal, style=shape.triangledown, location=location.belowbar, size=size.normal, text="MS")

plotshape(_ev_MR_r and sigTiny, style=shape.circle, location=location.abovebar, size=size.tiny, text="rM")
plotshape(_ev_MR_r and sigSmall, style=shape.circle, location=location.abovebar, size=size.small, text="rM")
plotshape(_ev_MR_r and sigNormal, style=shape.circle, location=location.abovebar, size=size.normal, text="rM")

plotshape(_ev_MS_r and sigTiny, style=shape.circle, location=location.belowbar, size=size.tiny, text="rM")
plotshape(_ev_MS_r and sigSmall, style=shape.circle, location=location.belowbar, size=size.small, text="rM")
plotshape(_ev_MS_r and sigNormal, style=shape.circle, location=location.belowbar, size=size.normal, text="rM")

alertcondition(_ev_mr_b, "ATL Micro R BR", "Micro R BR {{ticker}} {{interval}}")
alertcondition(_ev_ms_b, "ATL Micro S BR", "Micro S BR {{ticker}} {{interval}}")
alertcondition(_ev_mr_r, "ATL Micro R RT", "Micro R RT {{ticker}} {{interval}}")
alertcondition(_ev_ms_r, "ATL Micro S RT", "Micro S RT {{ticker}} {{interval}}")
alertcondition(_ev_xr_b, "ATL Meso R BR", "Meso R BR {{ticker}} {{interval}}")
alertcondition(_ev_xs_b, "ATL Meso S BR", "Meso S BR {{ticker}} {{interval}}")
alertcondition(_ev_xr_r, "ATL Meso R RT", "Meso R RT {{ticker}} {{interval}}")
alertcondition(_ev_xs_r, "ATL Meso S RT", "Meso S RT {{ticker}} {{interval}}")

alertcondition(_ev_MR_b, "ATL MR BR", "MR BR {{ticker}} {{interval}}")
alertcondition(_ev_MS_b, "ATL MS BR", "MS BR {{ticker}} {{interval}}")
alertcondition(_ev_MR_r, "ATL MR RT", "MR RT {{ticker}} {{interval}}")
alertcondition(_ev_MS_r, "ATL MS RT", "MS RT {{ticker}} {{interval}}")

bool any_break_evt  = (_ev_mr_b or _ev_ms_b or _ev_MR_b or _ev_MS_b) or (_ev_xr_b or _ev_xs_b)
bool any_retest_evt = (_ev_mr_r or _ev_ms_r or _ev_MR_r or _ev_MS_r) or (_ev_xr_r or _ev_xs_r)

alertcondition(any_break_evt, "ATL Any BR", "Any BR {{ticker}} {{interval}}")
alertcondition(any_retest_evt, "ATL Any RT", "Any RT {{ticker}} {{interval}}")

bool _anyDynEvt = any_break_evt or any_retest_evt
if dyn_alerts and barstate.isconfirmed and _anyDynEvt
    float _as = atr14_cs_safe
    string _m = ""

    float _yMR0 = f_has_slot_int(microR_t2, 0) ? f_af(microR_y, 0) : na
    float _yMS0 = f_has_slot_int(microS_t2, 0) ? f_af(microS_y, 0) : na
    int   _qMR0 = f_has_slot_int(microR_t2, 0) ? array.get(microR_q, 0) : na
    int   _qMS0 = f_has_slot_int(microS_t2, 0) ? array.get(microS_q, 0) : na

    _m += f_sig_evt_msg(show_sig_tf, micro_res_break,  "MiR", "BR",  _yMR0, _qMR0, _as)
    _m += f_sig_evt_msg(show_sig_tf, micro_sup_break,  "MiS", "BR",  _yMS0, _qMS0, _as)
    _m += f_sig_evt_msg(show_sig_tf, micro_res_retest, "MiR", "RT", _yMR0, _qMR0, _as)
    _m += f_sig_evt_msg(show_sig_tf, micro_sup_retest, "MiS", "RT", _yMS0, _qMS0, _as)

    float _yMeR0 = f_has_slot_int(mesoR_t2, 0) ? f_af(mesoR_y, 0) : na
    float _yMeS0 = f_has_slot_int(mesoS_t2, 0) ? f_af(mesoS_y, 0) : na
    int   _qMeR0 = f_has_slot_int(mesoR_t2, 0) ? array.get(mesoR_q, 0) : na
    int   _qMeS0 = f_has_slot_int(mesoS_t2, 0) ? array.get(mesoS_q, 0) : na

    _m += f_sig_evt_msg(show_meso_sig_tf, meso_res_break,  "MeR", "BR",  _yMeR0, _qMeR0, _as)
    _m += f_sig_evt_msg(show_meso_sig_tf, meso_sup_break,  "MeS", "BR",  _yMeS0, _qMeS0, _as)
    _m += f_sig_evt_msg(show_meso_sig_tf, meso_res_retest, "MeR", "RT", _yMeR0, _qMeR0, _as)
    _m += f_sig_evt_msg(show_meso_sig_tf, meso_sup_retest, "MeS", "RT", _yMeS0, _qMeS0, _as)

    if str.length(_m) > 0
        alert(_m + syminfo.ticker + " (" + timeframe.period + ")", alert.freq_once_per_bar_close)

float _omr_y0 = f_has_slot_int(microR_t2, 0) ? f_af(microR_y, 0) : na
float _oms_y0 = f_has_slot_int(microS_t2, 0) ? f_af(microS_y, 0) : na

var int   _omr_oc = 0
var int   _oms_oc = 0
var int   _omr_rt_bar = na
var int   _oms_rt_bar = na
var float _omr_rt_y = na
var float _oms_rt_y = na
var bool  _omr_over = false
var bool  _oms_over = false
var int   _omr_prev = 0
var int   _oms_prev = 0
var string _last_outcome = "Waiting"
var int   _last_outcome_bar = na

float _oa = atr14_cs_safe * 0.35
if micro_res_break
    _omr_oc := 0
    _omr_rt_bar := na
    _omr_rt_y := na
    _omr_over := false
if micro_sup_break
    _oms_oc := 0
    _oms_rt_bar := na
    _oms_rt_y := na
    _oms_over := false
if micro_res_retest and not na(_omr_y0)
    _omr_oc := 1
    _omr_rt_bar := bar_index
    _omr_rt_y := _omr_y0
    _omr_over := false
if micro_sup_retest and not na(_oms_y0)
    _oms_oc := 1
    _oms_rt_bar := bar_index
    _oms_rt_y := _oms_y0
    _oms_over := false
if _omr_oc == 1 and not na(_omr_rt_y)
    bool _fail = close < _omr_rt_y or low < (_omr_rt_y - _oa)
    _omr_over := _omr_over or (low < _omr_rt_y)
    if _fail
        _omr_oc := 4
    else if bar_index - _omr_rt_bar >= 1
        _omr_oc := _omr_over ? 3 : 2
if _oms_oc == 1 and not na(_oms_rt_y)
    bool _fail = close > _oms_rt_y or high > (_oms_rt_y + _oa)
    _oms_over := _oms_over or (high > _oms_rt_y)
    if _fail
        _oms_oc := 4
    else if bar_index - _oms_rt_bar >= 1
        _oms_oc := _oms_over ? 3 : 2

bool _ev_omr_h = _omr_oc == 2 and _omr_prev != 2
bool _ev_omr_o = _omr_oc == 3 and _omr_prev != 3
bool _ev_omr_f = _omr_oc == 4 and _omr_prev != 4
bool _ev_oms_h = _oms_oc == 2 and _oms_prev != 2
bool _ev_oms_o = _oms_oc == 3 and _oms_prev != 3
bool _ev_oms_f = _oms_oc == 4 and _oms_prev != 4

int _omr_q = f_q0(microR_q)
int _oms_q = f_q0(microS_q)
int _omr_evq = _omr_q + (_omr_oc == 2 ? 10 : _omr_oc == 3 ? 3 : _omr_oc == 4 ? -8 : 0)
int _oms_evq = _oms_q + (_oms_oc == 2 ? 10 : _oms_oc == 3 ? 3 : _oms_oc == 4 ? -8 : 0)
string _omr_g = _omr_evq >= 80 ? "A" : _omr_evq >= 62 ? "B" : "C"
string _oms_g = _oms_evq >= 80 ? "A" : _oms_evq >= 62 ? "B" : "C"

color _omr_col = _omr_g == "A" ? color.new(color.lime, 0) : _omr_g == "B" ? color.new(color.orange, 0) : color.new(color.red, 0)
color _oms_col = _oms_g == "A" ? color.new(color.lime, 0) : _oms_g == "B" ? color.new(color.orange, 0) : color.new(color.red, 0)
plotshape(_ev_omr_h, style=shape.labeldown, location=location.abovebar, size=size.tiny, text="H", color=_omr_col, textcolor=color.white)
plotshape(_ev_omr_o, style=shape.labeldown, location=location.abovebar, size=size.tiny, text="O", color=_omr_col, textcolor=color.white)
plotshape(_ev_omr_f, style=shape.labeldown, location=location.abovebar, size=size.tiny, text="F", color=_omr_col, textcolor=color.white)
plotshape(_ev_oms_h, style=shape.labelup, location=location.belowbar, size=size.tiny, text="H", color=_oms_col, textcolor=color.white)
plotshape(_ev_oms_o, style=shape.labelup, location=location.belowbar, size=size.tiny, text="O", color=_oms_col, textcolor=color.white)
plotshape(_ev_oms_f, style=shape.labelup, location=location.belowbar, size=size.tiny, text="F", color=_oms_col, textcolor=color.white)

if _ev_omr_h
    _last_outcome := "R-" + "H" + _omr_g
    _last_outcome_bar := bar_index
else if _ev_omr_o
    _last_outcome := "R-" + "O" + _omr_g
    _last_outcome_bar := bar_index
else if _ev_omr_f
    _last_outcome := "R-" + "F" + _omr_g
    _last_outcome_bar := bar_index
else if _ev_oms_h
    _last_outcome := "S-" + "H" + _oms_g
    _last_outcome_bar := bar_index
else if _ev_oms_o
    _last_outcome := "S-" + "O" + _oms_g
    _last_outcome_bar := bar_index
else if _ev_oms_f
    _last_outcome := "S-" + "F" + _oms_g
    _last_outcome_bar := bar_index

_omr_prev := _omr_oc
_oms_prev := _oms_oc

int _panel_micro_q = math.max(f_q0(microR_q), f_q0(microS_q))
int _panel_meso_q = math.max(f_q0(mesoR_q), f_q0(mesoS_q))
int _panel_base_q = math.max(_panel_micro_q, _panel_meso_q)
int _panel_rt_q = math.max(_omr_evq, _oms_evq)
int _panel_raw_q = math.max(_panel_base_q, _panel_rt_q)
int _planner_score = _panel_raw_q > 0 ? int(math.round(math.max(0.0, math.min(100.0, float(_panel_raw_q) * 1.35 + 12.0)))) : 0

bool _rt_hold = _omr_oc == 2 or _oms_oc == 2
bool _rt_overlap = _omr_oc == 3 or _oms_oc == 3
bool _rt_fail = _omr_oc == 4 or _oms_oc == 4
bool _last_res_live = _omr_oc > 0 and (_oms_oc == 0 or nz(_omr_rt_bar, -1) >= nz(_oms_rt_bar, -1))
bool _last_sup_live = _oms_oc > 0 and (_omr_oc == 0 or nz(_oms_rt_bar, -1) > nz(_omr_rt_bar, -1))
bool _res_context = _last_res_live or (not _last_sup_live and f_q0(microR_q) >= f_q0(microS_q))
bool _planner_has_context = _panel_raw_q > 0 or any_break_evt or any_retest_evt

string _planner_tf = (_ev_MR_b or _ev_MS_b or _ev_MR_r or _ev_MS_r) ? "Mega" : show_meso_eff and _panel_meso_q > _panel_micro_q ? "Meso" : "Micro"
_planner_tf := _panel_base_q == 0 and _omr_oc == 0 and _oms_oc == 0 ? "Building" : _planner_tf

string _planner_side = _panel_base_q == 0 and _omr_oc == 0 and _oms_oc == 0 ? "Building" : _last_res_live ? "Resistance Break" : _last_sup_live ? "Support Break" : _res_context ? "Resistance Watch" : "Support Watch"
string _planner_retest = _rt_fail ? "FAILED" : _rt_hold ? "HELD" : _rt_overlap ? "OVERLAP" : any_retest_evt ? "TESTING" : any_break_evt ? "AWAITING" : "WATCHING"
string _planner_action = not _planner_has_context ? "BUILDING" : _rt_fail ? "INVALIDATED" : _rt_hold and _planner_score >= sig_min_q ? "READY" : (_rt_overlap or any_retest_evt or any_break_evt) ? "MONITOR" : "WAIT"
string _planner_score_txt = _planner_score > 0 ? (str.tostring(_planner_score) + "/100 " + f_score_tier(_planner_score)) : "Building"

color _planner_score_col = _planner_score >= 75 ? c_sup : _planner_score >= sig_min_q ? c_neutral : c_res
color _planner_action_col = _planner_action == "READY" ? c_sup : _planner_action == "INVALIDATED" ? c_res : _planner_action == "MONITOR" ? c_mega : _planner_action == "WAIT" ? c_neutral : c_panel_value
bool _planner_bullish = str.contains(_planner_side, "Resistance")
color _planner_side_col = _planner_side == "Building" ? c_panel_value : _planner_side == "Resistance Watch" ? c_res : _planner_side == "Support Watch" ? c_sup : _planner_bullish ? c_sup : c_res

var string _planner_prev_action = ""
bool _planner_ready_evt = _planner_action == "READY" and _planner_prev_action != "READY"
bool _planner_invalid_evt = _planner_action == "INVALIDATED" and _planner_prev_action != "INVALIDATED"
bool _planner_review_evt = _planner_action == "MONITOR" and _planner_prev_action != "MONITOR"

var label[] _planner_labels = array.new_label()

f_plan_label(label[] arr, bool cond, bool bullish, string txt, color bg) =>
    if cond and planner_label_mode != "Off"
        float y = bullish ? low - atr14_cs_safe * 0.55 : high + atr14_cs_safe * 0.55
        label lb = label.new(bar_index, y, txt, style=bullish ? label.style_label_up : label.style_label_down, textcolor=c_header_text, color=color.new(bg, 0), size=lbl_size_eff_cs)
        array.unshift(arr, lb)
        while array.size(arr) > planner_max_labels
            label.delete(array.pop(arr))
    0

f_plan_label(_planner_labels, _planner_ready_evt, _planner_bullish, "READY " + _planner_score_txt, _planner_bullish ? c_sup : c_res)
f_plan_label(_planner_labels, _planner_invalid_evt, not _planner_bullish, "INVALIDATED", c_res)
f_plan_label(_planner_labels, planner_label_mode == "All Events" and _planner_review_evt, _planner_bullish, "MONITOR " + _planner_score_txt, c_mega)

bool _planner_state_evt = _planner_ready_evt or _planner_invalid_evt or _planner_review_evt
alertcondition(_planner_state_evt, "ATL Planner State Change", "Auto Trendlines MTF planner state changed on {{ticker}} {{interval}}")

_planner_prev_action := _planner_action

f_hud_title(table tb, int row, string title, ts) =>
    table.merge_cells(tb, 0, row, 1, row)
    table.cell(tb, 0, row, title, text_color=c_header_text, bgcolor=c_ag_blue, text_size=ts, text_halign=text.align_center)

f_panel_row_bg(string k, int row) =>
    bool _light = hud_theme == "Light Slate"
    bool _coded = hud_theme == "Color Coded" or hud_theme == "Showcase"
    color _base = _light ? (row % 2 == 0 ? color.rgb(248, 250, 252) : color.rgb(241, 245, 249)) : (row % 2 == 0 ? c_panel_bg : color.rgb(30, 41, 59))
    if _coded
        color _seed =
             k == "Active TF" ? c_mega :
             k == "Trendline Side" ? color.rgb(56, 189, 248) :
             k == "Break Quality" ? c_neutral :
             k == "Retest" ? color.rgb(45, 212, 191) :
             k == "Action" ? _planner_action_col :
             c_panel_border
        _base := color.new(_seed, hud_theme == "Showcase" ? 18 : 34)
    _base

f_hud_row(table tb, int row, string k, string v, color vcol, ts) =>
    bool _light = hud_theme == "Light Slate"
    color _bg = f_panel_row_bg(k, row)
    color _key_col = _light ? color.rgb(71, 85, 105) : c_panel_label
    color _val_col = _light and k != "Action" and k != "Break Quality" ? color.rgb(15, 23, 42) : vcol
    table.cell(tb, 0, row, k, text_color=_key_col, bgcolor=_bg, text_size=ts)
    table.cell(tb, 1, row, v, text_color=_val_col, bgcolor=_bg, text_size=ts, text_halign=text.align_right)

if show_hud
    bool _hud_pos_changed = not na(hud) and hud_last_pos_opt != "" and hud_last_pos_opt != hud_pos_opt
    if _hud_pos_changed
        table.delete(hud)
        hud := na
        hud_rendered_once := false
        hud_last_sig := ""
    if na(hud)
        hud := table.new(f_hud_pos(hud_pos_opt), 2, 6, bgcolor=c_panel_bg, frame_color=c_panel_border, frame_width=1, border_color=c_panel_border, border_width=1)
        hud_last_pos_opt := hud_pos_opt

    if barstate.islast and not na(hud) and (barstate.isconfirmed or not barstate.isrealtime or not hud_rendered_once)
        ts = hud_txt_size == "Small" ? size.small : hud_txt_size == "Large" ? size.large : size.normal
        string hud_sig_all = _planner_tf + "|" + _planner_side + "|" + _planner_score_txt + "|" + _planner_retest + "|" + _planner_action + "|" + hud_theme + "|" + hud_txt_size
        bool hud_need_redraw = (not hud_rendered_once) or (hud_sig_all != hud_last_sig)
        if hud_need_redraw
            table.clear(hud, 0, 0, 1, 5)
            f_hud_title(hud, 0, "AG Pro Auto Trendlines MTF", ts)
            f_hud_row(hud, 1, "Active TF", _planner_tf, c_panel_value, ts)
            f_hud_row(hud, 2, "Trendline Side", _planner_side, _planner_side_col, ts)
            f_hud_row(hud, 3, "Break Quality", _planner_score_txt, _planner_score_col, ts)
            f_hud_row(hud, 4, "Retest", _planner_retest, _planner_retest == "HELD" ? c_sup : _planner_retest == "FAILED" ? c_res : _planner_retest == "OVERLAP" ? c_neutral : c_panel_value, ts)
            f_hud_row(hud, 5, "Action", _planner_action, _planner_action_col, ts)
            hud_last_sig := hud_sig_all
        hud_rendered_once := true
else
    if barstate.islast and not na(hud)
        table.clear(hud, 0, 0, 1, 5)
        table.delete(hud)
        hud := na
    hud_rendered_once := false
    hud_last_sig := ""
    hud_last_pos_opt := ""
````
