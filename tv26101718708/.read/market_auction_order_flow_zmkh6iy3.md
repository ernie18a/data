# Market Auction Order Flow

- url: https://www.tradingview.com/script/zMKh6Iy3-Market-Auction-Order-Flow/
- type: indicator
- pine_id: PUB;0bc97053de734d5e91a984f1dd28cdd9
- version: 1.0

## Description

# Market Auction Order Flow (MAOF)

**Market Auction Order Flow** is an all-in-one auction-theory and order-flow toolkit built around a single analytical framework: price seeks value through auction, and order flow reveals who is winning that auction in real time.

The eight modules are not an arbitrary collection of tools. They form a three-layer pipeline:

- **Context layer** (Modules 01, 02, 03, 08) establishes where value is. VWAP provides a dynamic fair-value reference — where price *should* be given the session's traded volume. The Volume Profile provides empirical confirmation — where price *was actually accepted* by the market, as measured by volume distribution. When VWAP and the Volume Profile's Point of Control or Value Area edges coincide, that confluence identifies a level with both theoretical and empirical support. Initial Balance and HTF Candle Profiles extend this context to the daily structure and higher timeframes.
- **Pressure layer** (Modules 04, 05, 07) measures what is happening inside each bar — intrabar delta (buy volume minus sell volume), PVSRA volume classification, and per-bar delta labels reveal institutional activity, exhaustion, and divergences invisible on a plain price chart.
- **Signal layer** (Module 06) acts only when context and pressure align: the SSL Channel crossover provides a directional trigger, and the delta confirmation requirement (from Module 04) ensures that a signal fires only when order flow supports the move. Without the pressure layer feeding the signal layer, the SSL crossover is no different from any other moving-average crossover.

Each module can be toggled independently — from a minimal VWAP-only setup to the full pipeline — so traders can use only the layers relevant to their workflow.

---

## Modules

### 01 · VWAP with State Cloud
Session-anchored VWAP (or Week / Month / Quarter / Year / Earnings / Dividends / Splits anchor) with up to three standard-deviation or percentage-based band pairs. The **state cloud** classifies price as Discovery Up, Discovery Down, or Balance relative to the bands, and highlights:
- **Failed breakout markers** — wick penetrates a band but close rejects back inside (configurable minimum penetration % and cooldown bars)
- **Return-to-VWAP markers** — price crosses back through the VWAP line after a discovery move, signaling potential mean reversion

The state cloud turns VWAP from a static level into a dynamic market condition classifier, distinguishing trending (discovery) from mean-reverting (balance) environments bar by bar.

### 02 · Periodic Volume Profile
An extended version of TradingView's built-in Periodic Volume Profile, rebuilt with additional configuration options and integrated into the MAOF context layer. Resets on a configurable anchor period (Session / Day / Week / Month, or any custom timeframe). Features:
- Up/Down, Total, or Delta volume display modes
- POC, VAH, VAL level lines with optional right-extension
- **Developing POC and Developing Value Area** overlays — tracks the POC and Value Area as they build in real time within the current period (not available in the built-in)
- **Adaptive row density** ("Rows per Percent") — row count scales with profile range instead of being fixed, keeping histogram granularity consistent across different volatility periods
- **Bar-level fallback mode** — computes a per-bar approximation for 1-min charts without Premium intrabar data access
- Adjustable value area %, profile width, and placement

The profile identifies the price range where the majority of volume traded (the Value Area), distinguishing accepted price levels from those the market visited but rejected. As an integrated module, the intrabar data computed here also feeds Module 06's signal confirmation logic.

### 03 · Initial Balance
Auto-detects the correct IB session window for each instrument class (equity indices, metals, energies, grains, softs, forex) or accepts a custom window. Draws:
- IB High / Low / Mid levels
- ×2 and ×3 range extensions
- 50 % midpoint levels between extensions
- Optional IB zone tint and 20-day IB-Delta statistics table

The Initial Balance is the range established in the first hour of the regular trading session. Auction theory treats IB extensions as directional breakouts: price that moves beyond 2× or 3× the initial range signals a one-timeframing market with strong directional conviction.

### 04 · Volume Delta Engine
Intrabar delta computation engine that powers the signal system. Calculates smoothed delta EMA and detects **exhaustion flips** — moments when cumulative delta swings from an extreme (configurable threshold) to a zero-line crossover. An exhaustion flip signals that aggressive directional buyers or sellers have been absorbed, creating conditions for a reversal. This module feeds its delta state directly into Module 06.

### 05 · PVSRA (Price Volume Spread Range Analysis)
Classifies each bar by volume intensity relative to its 10-bar average:
- **Level 2 (200 %)** — climactic volume (green/red) — potential institutional activity
- **Level 1 (150 %)** — above-average volume (blue/fuchsia)
- **Normal** — standard volume

An optional spread×volume override promotes bars to Level 2 when the combined metric reaches a local extreme, identifying bars where both price spread and volume simultaneously spike — a signature of large-order absorption or distribution. Can override candle colors or use a separate symbol as the volume source.

### 06 · SSL Channel Signal Engine
Generates long/short trade signals using SSL Channel crossovers with mandatory **delta confirmation** from Module 04:
- **Pending signals** appear when the SSL Channel line crosses, opening a confirmation window
- **Confirmed signals** fire only when delta polarity aligns with the SSL direction within the expiry window
- Alternating mode (L→S→L) prevents consecutive same-direction signals
- Configurable cooldown between signals to filter noise

The confirmation requirement is the core design decision: an SSL crossover that occurs while delta is opposing the move is filtered out as a likely false breakout. Only when directional price structure (SSL) and order flow pressure (delta) agree does the signal print.

### 07 · Delta Display (Real-Time Order Flow Labels)
Per-bar labels showing:
- **DV (Delta Volume)** — buy volume minus sell volume, with optional DV%, total volume, and momentum arrows (▲▼)
- **DT (Delta Ticks)** — uptick count minus downtick count, with optional DT%, total ticks, and momentum arrows
- **POC line** — short horizontal line at the highest-volume price level within each bar
- **Divergence highlighting** — label color changes when delta polarity conflicts with bar direction (e.g., positive DV on a red bar signals hidden buying pressure despite price declining)

Delta divergences at key context levels (VWAP, Value Area edges, IB boundaries) are among the highest-probability setups in the auction-theory framework.

### 08 · HTF Candle Volume Profile
A 1-minute chart shows tick-level detail but hides what the Daily or Weekly candle looks like — you would normally have to switch timeframes to see it. Module 08 solves this by rendering up to three completed higher-timeframe candles (default: Daily / Weekly / Monthly) directly on the current chart, positioned to the right of live price as reference panels.

Each HTF candle is paired with its own Volume Profile histogram, showing where volume was distributed *within that candle's timespan* — not just the candle's open/high/low/close, but the price levels where the most buying and selling actually occurred. POC, VAH, and VAL level lines extend left across the chart to the candle's start bar, creating visible reference zones anchored to higher-timeframe market structure.

In auction theory, higher-timeframe value areas carry the most weight: a Weekly POC represents an entire week's worth of volume acceptance. When intraday price approaches a Weekly POC or Daily VAL, that level is likely to produce a reaction. Module 08 makes these levels visible on a 1-minute chart without leaving it.

---

## Key Features
- **Fully modular** — enable only what you need; disable the rest for a clean chart
- **Extensive customization** — every module has dedicated Core and Style setting groups with full color, width, and style control
- **Multi-timeframe awareness** — from intrabar delta resolution up to Monthly candle profiles
- **Auto-adaptive** — IB windows auto-detect by instrument class, delta LTF adapts to chart timeframe
- **Built-in alerts** — Long, Short, Pending Long, Pending Short alert conditions

## Recommended Timeframes
Designed primarily for **intraday futures trading** (1 min – 15 min charts), but compatible with any timeframe and instrument. Volume Profile and Delta modules benefit most from intrabar data available on lower timeframes.

---

## How to Use

1. Add the indicator to your chart
2. Open Settings and enable/disable modules to suit your workflow
3. Each module has a **Core** group (logic settings) and a **Style** group (visual settings)
4. Start with VWAP + Volume Profile + Delta Display for a solid auction-theory foundation
5. Add SSL Signal Engine when you want trade entry signals filtered by delta confirmation
6. Use Initial Balance and HTF Candle VP to anchor intraday analysis to higher-timeframe value areas
7. Set up alerts via TradingView's alert system using the built-in alert conditions

---

## Credits & Acknowledgments

### Libraries
This indicator uses the following open-source Pine Script™ libraries by **[AustrianTradingMachine](https://www.tradingview.com/u/AustrianTradingMachine/)**:
- **LibTmFr** — Timeframe utilities (period detection, auto LTF selection)
- **LibBrSt** — Bar statistics and real estimators
- **LibProf** — Profile computation engine
- **LibVPrf** — Volume Profile data structures and rendering

### Module origins
- **Module 03 — Initial Balance:** Based on [Initial Balance Wave Map](https://www.tradingview.com/v/YT6IrC8d/) by **[traderdrysdale](https://www.tradingview.com/u/traderdrysdale/)** (open-source), which itself builds on the foundation by **@noop-noop**
- **Module 05 — PVSRA:** Based on the Price Volume Spread Range Analysis methodology
- **Module 06 — SSL Channel:** Based on the SSL Channel concept originally developed by ErwinBeckers
- **Module 01 — VWAP:** Extends TradingView's built-in VWAP with custom state-cloud classification, failed-breakout detection, and return-to-VWAP logic
- **Module 02 — Periodic Volume Profile:** Extends TradingView's built-in Periodic Volume Profile with Developing POC/VA overlays, adaptive row density, bar-level fallback mode, and Session anchor support
- **Module 08 — HTF Candle Volume Profile:** Based on [HTF Candle Volume Profile](https://www.tradingview.com/v/yMqxwltF/) by **ChartPrime** (open-source), modified to integrate Volume Profile histograms (POC, VAH, VAL) per HTF candle and to support up to three independent higher timeframes simultaneously

## Source Code

````pine
//@version=6
indicator("Market Auction Order Flow", shorttitle="MAOF", overlay=true, max_bars_back=5000, max_lines_count=500, max_labels_count=500, max_boxes_count=500, max_polylines_count=100)

// ============================================================================
// CONSTANTS
// ============================================================================
int VP_BINS_MIN = 8
int VP_BINS_MAX = 80
int VP_MAX_POLYLINES = 100
int VP_MAX_POINTS = 10000
int VP_MAX_LEVEL_LINES_PER_TYPE = 120

import AustrianTradingMachine/LibTmFr/2 as LibTmFr
import AustrianTradingMachine/LibBrSt/2 as LibBrSt
import AustrianTradingMachine/LibProf/1 as LibProf
import AustrianTradingMachine/LibVPrf/3 as LibVPrf

enum VPPrfDisp
    upDn = "Up/Down"
    total = "Total"
    delta = "Delta"

enum VPProfSide
    right = "Right"
    left = "Left"

string vp_chart_tf_global = timeframe.main_period

// ============================================================================
// MODULE 01 - VWAP (CORE)
// ============================================================================
string g_vwap_core = "01 VWAP - Core"
string g_vwap_style = "01 VWAP - Style"
string g_vwap_state = "01 VWAP - State Cloud"

bool vwap_enable = input.bool(true, "Enable VWAP module", group=g_vwap_core, tooltip="Master switch for VWAP calculations and visuals.")
bool vwap_hide_on_dwm = input.bool(false, "Hide on 1D or Above", group=g_vwap_core, tooltip="When enabled, VWAP will be hidden on Daily/Weekly/Monthly charts.")
string vwap_anchor = input.string("Session", "Anchor Period", options=["Session", "Week", "Month", "Quarter", "Year", "Decade", "Century", "Earnings", "Dividends", "Splits"], group=g_vwap_core, tooltip="Controls when VWAP resets.")
vwap_src = input.source(hlc3, "Source", group=g_vwap_core, tooltip="Price source used for VWAP.")
int vwap_offset = input.int(0, "Offset", group=g_vwap_core, tooltip="Plot offset in bars.")
string vwap_calc_mode = input.string("Standard Deviation", "Bands Calculation Mode", options=["Standard Deviation", "Percentage"], group=g_vwap_core, tooltip="Standard Deviation uses stdev distance. Percentage uses VWAP * %.")

bool vwap_show_band_1 = input.bool(true, "Band #1", group=g_vwap_core, inline="vwap_b1", tooltip="Enable first VWAP band pair.")
float vwap_band_mult_1 = input.float(1.0, "Multiplier", group=g_vwap_core, inline="vwap_b1", minval=0.0, step=0.25, tooltip="Distance multiplier for band #1.")
bool vwap_show_band_2 = input.bool(true, "Band #2", group=g_vwap_core, inline="vwap_b2", tooltip="Enable second VWAP band pair.")
float vwap_band_mult_2 = input.float(2.0, "Multiplier", group=g_vwap_core, inline="vwap_b2", minval=0.0, step=0.25, tooltip="Distance multiplier for band #2.")
bool vwap_show_band_3 = input.bool(false, "Band #3", group=g_vwap_core, inline="vwap_b3", tooltip="Enable third VWAP band pair.")
float vwap_band_mult_3 = input.float(3.0, "Multiplier", group=g_vwap_core, inline="vwap_b3", minval=0.0, step=0.25, tooltip="Distance multiplier for band #3.")

bool vwap_show_state_cloud = input.bool(true, "Show state cloud", group=g_vwap_state)
bool vwap_cloud_use_band2 = input.bool(true, "Use Band #2 for discovery cloud", group=g_vwap_state)
bool vwap_cloud_step = input.bool(true, "Stepline cloud edges", group=g_vwap_state)
bool vwap_show_state_bg = input.bool(false, "Show state background", group=g_vwap_state)
bool vwap_show_failed_breakout = input.bool(true, "Show failed breakout markers", group=g_vwap_state)
float vwap_failed_min_pct = input.float(0.05, "Min penetration (%)", minval=0.0, maxval=1.0, step=0.01, group=g_vwap_state, tooltip="Wick must exceed the band by at least this % of price. Filters weak touches.")
int vwap_failed_cooldown = input.int(5, "Cooldown bars", minval=1, maxval=50, group=g_vwap_state, tooltip="Minimum bars between markers on the same side. Consolidates rejection episodes.")
bool vwap_show_return_to_vwap = input.bool(true, "Show return-to-VWAP markers", group=g_vwap_state)

color vwap_line_color = input.color(#2962FF, "VWAP color", group=g_vwap_style, tooltip="Main VWAP line color.")
int vwap_line_width = input.int(2, "VWAP width", minval=1, maxval=5, group=g_vwap_style, tooltip="Main VWAP line width.")
color vwap_b1_up_color = input.color(color.new(color.green, 0), "Band #1 Upper color", group=g_vwap_style)
color vwap_b1_dn_color = input.color(color.new(color.green, 0), "Band #1 Lower color", group=g_vwap_style)
color vwap_b2_up_color = input.color(color.new(color.aqua, 0), "Band #2 Upper color", group=g_vwap_style)
color vwap_b2_dn_color = input.color(color.new(color.aqua, 0), "Band #2 Lower color", group=g_vwap_style)
color vwap_b3_up_color = input.color(color.new(color.teal, 0), "Band #3 Upper color", group=g_vwap_style)
color vwap_b3_dn_color = input.color(color.new(color.teal, 0), "Band #3 Lower color", group=g_vwap_style)
color vwap_fill_b1 = input.color(color.new(color.green, 90), "Band #1 fill", group=g_vwap_style)
color vwap_fill_b2 = input.color(color.new(color.aqua, 92), "Band #2 fill", group=g_vwap_style)
color vwap_fill_b3 = input.color(color.new(color.teal, 94), "Band #3 fill", group=g_vwap_style)
color vwap_cloud_up = input.color(color.new(#00a67e, 80), "Discovery UP cloud", group=g_vwap_style)
color vwap_cloud_dn = input.color(color.new(#c62828, 80), "Discovery DOWN cloud", group=g_vwap_style)
color vwap_cloud_bal = input.color(color.new(#2962FF, 88), "Balance cloud", group=g_vwap_style)
color vwap_bg_up = input.color(color.new(color.green, 93), "UP background", group=g_vwap_style)
color vwap_bg_dn = input.color(color.new(color.red, 93), "DOWN background", group=g_vwap_style)
color vwap_failed_up_color = input.color(color.new(color.red, 0), "Failed-up marker", group=g_vwap_style)
color vwap_failed_dn_color = input.color(color.new(color.lime, 0), "Failed-down marker", group=g_vwap_style)
color vwap_retest_color = input.color(color.new(color.yellow, 0), "Return-to-VWAP marker", group=g_vwap_style)

// ============================================================================
// MODULE 02 - PERIODIC VOLUME PROFILE (LIGHTWEIGHT)
// ============================================================================
string g_vp_core = "02 Periodic VP - Core"
string g_vp_style = "02 Periodic VP - Style"

bool vp_enable = input.bool(true, "Enable Periodic VP module", group=g_vp_core, tooltip="Master switch for Periodic Volume Profile module.")
int vp_period = input.int(1, "Period", minval=1, maxval=50, group=g_vp_core, inline="vpPeriod", tooltip="How many anchor units to combine into one profile period.")
string vp_anchor_unit = input.string("Day", "", options=["Session", "Day", "Week", "Month"], group=g_vp_core, inline="vpPeriod", tooltip="Anchor unit for each profile period.")
VPPrfDisp vp_volume_mode = input.enum(VPPrfDisp.upDn, "Volume", group=g_vp_core, tooltip="Up/Down shows buy-sell split. Total shows combined volume. Delta shows net volume.")
int vp_val_area = input.int(70, "Value Area Volume", minval=0, maxval=100, group=g_vp_core, tooltip="Percent of total profile volume used for VAH/VAL.")
bool vp_rows_dynamic = input.bool(false, "Rows per Percent", group=g_vp_core, tooltip="Adaptive row density based on profile range. Disable for fixed row count.")
int vp_profile_rows = input.int(300, "Row Size", minval=20, maxval=500, group=g_vp_core, tooltip="Number of profile rows (bins). Higher values increase detail and compute load.")
int vp_bar_rows = input.int(24, "Rows per Bar", minval=8, maxval=80, group=g_vp_core, tooltip="Intrabar rows used by the profile engine.")
bool vp_custom_ltf = input.bool(false, "Use custom Intra-Bar Timeframe", group=g_vp_core, tooltip="Enable manual lower timeframe for profile building.")
string vp_manual_ltf = input.timeframe("1", "Intra-Bar Timeframe", group=g_vp_core, tooltip="Manual intra-bar timeframe. Must be lower than chart timeframe.")
bool vp_bar_fallback = input.bool(false, "Bar-level fallback (1min / low TF)", group=g_vp_core,
     tooltip="On 1-min charts or any TF where intrabar data is unavailable, builds the profile from OHLCV bar data instead. Less precise than intrabar VP, but works without Premium subscription.")
bool vp_custom_anchor_tf = input.bool(false, "Use custom Anchor Timeframe", group=g_vp_core, tooltip="Override Period/Unit with an explicit anchor timeframe.")
string vp_manual_anchor_tf = input.timeframe("D", "Anchor Timeframe", group=g_vp_core, tooltip="Manual anchor timeframe. Must be higher than chart timeframe.")
bool vp_extend_poc = input.bool(true, "Extend POC Right", group=g_vp_core)
bool vp_extend_vah = input.bool(false, "Extend VAH Right", group=g_vp_core)
bool vp_extend_val = input.bool(false, "Extend VAL Right", group=g_vp_core)

bool vp_show_profile = input.bool(true, "Volume profile", group=g_vp_style)
bool vp_show_profile_values = input.bool(false, "Values", group=g_vp_style)
float vp_prof_width_pct = input.float(25, "Width (% of the box)", minval=1, maxval=100, step=1, group=g_vp_style)
VPProfSide vp_prof_side = input.enum(VPProfSide.left, "Placement", group=g_vp_style)
color vp_buy_color = input.color(color.new(#16e016, 0), "Up Volume", group=g_vp_style)
color vp_sell_color = input.color(color.new(#c218c2, 0), "Down Volume", group=g_vp_style)
color vp_va_up_color = input.color(color.new(#2bd62b, 0), "Value Area Up", group=g_vp_style)
color vp_va_dn_color = input.color(color.new(#a020d0, 0), "Value Area Down", group=g_vp_style)
color vp_hist_box_color = input.color(color.new(#000000, 100), "Histogram Box", group=g_vp_style)
bool vp_show_vah_line = input.bool(true, "VAH", group=g_vp_style, inline="vpVAH")
color vp_vah_color = input.color(color.new(color.yellow, 0), "", group=g_vp_style, inline="vpVAH")
string vp_vah_style = input.string("Dashed", "", options=["Solid", "Dashed", "Dotted"], group=g_vp_style, inline="vpVAH")
bool vp_show_val_line = input.bool(true, "VAL", group=g_vp_style, inline="vpVAL")
color vp_val_color = input.color(color.new(color.yellow, 0), "", group=g_vp_style, inline="vpVAL")
string vp_val_style = input.string("Dashed", "", options=["Solid", "Dashed", "Dotted"], group=g_vp_style, inline="vpVAL")
bool vp_show_poc_line = input.bool(true, "POC", group=g_vp_style, inline="vpPOC")
color vp_poc_color = input.color(color.new(color.white, 0), "", group=g_vp_style, inline="vpPOC")
string vp_poc_style = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group=g_vp_style, inline="vpPOC")
int vp_level_width = input.int(1, "Level line width", minval=1, maxval=4, group=g_vp_style)
bool vp_show_dev_poc = input.bool(false, "Developing POC", group=g_vp_style)
bool vp_show_dev_va = input.bool(false, "Developing VA", group=g_vp_style)
color vp_dev_poc_color = input.color(color.new(color.gray, 35), "Developing POC color", group=g_vp_style)
color vp_dev_va_color = input.color(color.new(color.aqua, 50), "Developing VA color", group=g_vp_style)


// ============================================================================
// MODULE 03 - INITIAL BALANCE
// ============================================================================
string g_ib_core = "03 Initial Balance - Core"
string g_ib_display = "03 Initial Balance - Display"
string g_ib_style = "03 Initial Balance - Style"

bool ib_enable = input.bool(true, "Enable Initial Balance module", group=g_ib_core, tooltip="Master switch for Initial Balance calculations and drawings.")
bool ib_manual_override = input.bool(false, "Manual session override", group=g_ib_core, tooltip="When enabled, uses Custom Session instead of auto session detection.")
string ib_manual_session = input.session("0930-1030", "Custom Session (ET)", group=g_ib_core, tooltip="Initial Balance window used when manual override is enabled.")

bool ib_draw_extras = input.bool(true, "Plot x2 / x3 extensions", group=g_ib_display, tooltip="Draws projection levels at 2x and 3x IB range.")
bool ib_draw_mid_points = input.bool(true, "Plot 50% mid-levels", group=g_ib_display, tooltip="Draws midpoint levels inside and around the IB range.")
bool ib_shade_window = input.bool(false, "Highlight IB window", group=g_ib_display, tooltip="Background highlight while IB session is active.")
bool ib_render_labels = input.bool(true, "Show price labels", group=g_ib_display, tooltip="Prints price labels next to IB levels.")
bool ib_shade_zones = input.bool(true, "Tint IB high-low area", group=g_ib_display, tooltip="Fills the IB range with a translucent zone color.")
bool ib_this_day_only = input.bool(true, "Keep only today's levels", group=g_ib_display, tooltip="Deletes previous IB lines and keeps only the latest set.")
bool ib_this_zone_only = input.bool(false, "Keep only today's tinted zone", group=g_ib_display, tooltip="Deletes prior IB zone boxes when a new IB session completes.")
bool ib_show_delta_info = input.bool(false, "Show 20-day IB-Delta stats", group=g_ib_display, tooltip="Displays IB range statistics table from recent sessions.")

string ib_lbl_size_opt = input.string("Small", "Label size", options=["Auto","Huge","Large","Normal","Small","Tiny"], group=g_ib_style)
int ib_line_width = input.int(1, "Line width", minval=1, maxval=4, group=g_ib_style)
color ib_clr_high = input.color(color.new(color.green, 0), "High-side color", group=g_ib_style)
color ib_clr_low = input.color(color.new(color.red, 0), "Low-side color", group=g_ib_style)
color ib_clr_mid = input.color(#ffa726, "Mid-level color", group=g_ib_style)
string ib_extend_opt = input.string("Right", "Extend lines", options=["Right","Left","Both","None"], group=g_ib_style)
string ib_main_style = input.string("Solid", "Main level style", options=["Solid","Dashed","Dotted"], group=g_ib_style)
string ib_ext_style = input.string("Dashed", "x2/x3 level style", options=["Solid","Dashed","Dotted"], group=g_ib_style)
string ib_mid_style = input.string("Dotted", "Mid-level style", options=["Solid","Dashed","Dotted"], group=g_ib_style)
color ib_zone_tint = input.color(#b8851faa, "Zone fill color", group=g_ib_style)

// ============================================================================
// MODULE 04 - VOLUME DELTA (DATA & FLIP MARKERS)
// ============================================================================
string g_delta_core  = "04 Volume Delta - Core"
string g_delta_style = "04 Volume Delta - Style"

bool   delta_enable            = input.bool(true, "Enable Volume Delta module", group=g_delta_core, tooltip="Master switch for intrabar delta signal engine.")
string delta_tf_mode           = input.string("Auto (chart aware)", "Delta timeframe mode", options=["Auto (chart aware)", "Manual"], group=g_delta_core, tooltip="Auto mode adapts the lower timeframe to the chart. Manual mode uses the exact value below.")
string delta_ltf_manual        = input.timeframe("1", "Manual delta source timeframe", group=g_delta_core, tooltip="Used only in Manual mode. Must be lower than chart timeframe.")
int    delta_smooth_len        = input.int(5,     "Delta EMA length",          minval=1,   maxval=100,  group=g_delta_core, tooltip="Smoothing length applied to bar delta.")
int    delta_exhaust_lookback  = input.int(16,    "Exhaustion lookback bars",  minval=2,   maxval=200,  group=g_delta_core, tooltip="Window used to detect prior positive/negative exhaustion.")
float  delta_exhaust_threshold = input.float(150.0, "Exhaustion threshold (abs)", minval=0.0, step=10.0, group=g_delta_core, tooltip="Minimum absolute delta extreme required before a flip signal is valid.")

bool  delta_show_flip_markers = input.bool(true, "Show flip markers", group=g_delta_style)
color delta_flip_up_color     = input.color(color.new(color.aqua,   0), "Flip up marker color",   group=g_delta_style)
color delta_flip_dn_color     = input.color(color.new(color.orange, 0), "Flip down marker color", group=g_delta_style)

// ============================================================================
// MODULE 05 - PVSRA
// ============================================================================
string g_pvsra_core = "05 PVSRA - Core"
string g_pvsra_style = "05 PVSRA - Style"

bool pvsra_enable = input.bool(false, "Enable PVSRA module", group=g_pvsra_core, tooltip="Master switch for PVSRA volume-spread classification.")
bool pvsra_override_candles = input.bool(true, "Override candles with PVSRA color", group=g_pvsra_core, tooltip="Recolors chart candles with PVSRA state colors.")
bool pvsra_override_symbol = input.bool(false, "Override symbol", group=g_pvsra_core, inline="pvsra_sym", tooltip="Use a separate symbol as PVSRA source.")
string pvsra_symbol = input.symbol("BINANCE:BTCUSDTPERP", "", group=g_pvsra_core, inline="pvsra_sym")
int pvsra_avg_len = input.int(10, "Average volume length", minval=2, maxval=200, group=g_pvsra_core, tooltip="Lookback for average volume baseline.")
float pvsra_lvl1_mult = input.float(1.5, "Level-1 threshold (x avg vol)", minval=1.0, step=0.1, group=g_pvsra_core, tooltip="Volume multiple for 150% bar classification.")
float pvsra_lvl2_mult = input.float(2.0, "Level-2 threshold (x avg vol)", minval=1.0, step=0.1, group=g_pvsra_core, tooltip="Volume multiple for 200% bar classification.")
bool pvsra_use_spread_x_vol = input.bool(true, "Use spread*volume override for level-2", group=g_pvsra_core, tooltip="Promotes bar to level-2 when spread*volume reaches local extreme.")

color pvsra_bull_200 = input.color(color.new(color.lime, 0), "Bull 200%", group=g_pvsra_style, inline="pvsra_200")
color pvsra_bear_200 = input.color(color.new(color.red, 0), "Bear 200%", group=g_pvsra_style, inline="pvsra_200")
color pvsra_bull_150 = input.color(color.new(color.blue, 0), "Bull 150%", group=g_pvsra_style, inline="pvsra_150")
color pvsra_bear_150 = input.color(color.new(color.fuchsia, 0), "Bear 150%", group=g_pvsra_style, inline="pvsra_150")
color pvsra_bull_norm = input.color(color.new(#999999, 0), "Bull normal", group=g_pvsra_style, inline="pvsra_n")
color pvsra_bear_norm = input.color(color.new(#4d4d4d, 0), "Bear normal", group=g_pvsra_style, inline="pvsra_n")

// ============================================================================
// MODULE 06 - SSL CHANNEL SIGNAL ENGINE
// ============================================================================
string g_ssl_core  = "06 SSL Signal - Core"
string g_ssl_style = "06 SSL Signal - Style"

bool  ssl_enable        = input.bool(true,  "Enable SSL Signal module",    group=g_ssl_core, tooltip="Master switch for SSL Channel signal generation.")
int   ssl_len           = input.int(10,     "SSL Period",                  group=g_ssl_core, minval=1, maxval=500, tooltip="SMA period for high/low channels.")
int   ssl_expiry_bars   = input.int(3,      "Signal expiry (bars)",        group=g_ssl_core, minval=1, maxval=20,  tooltip="Bars to wait for delta confirmation before invalidating the pending signal.")
bool  ssl_require_delta = input.bool(true,  "Require delta confirmation",  group=g_ssl_core, tooltip="Long requires positive delta EMA, short requires negative delta EMA.")
bool  ssl_use_exhaust   = input.bool(false, "Delta: exhaustion flip mode", group=g_ssl_core, tooltip="Stricter confirmation — requires full exhaustion+flip instead of just delta direction.")
bool  ssl_alternate     = input.bool(true,  "Alternate signals (L→S→L)",  group=g_ssl_core, tooltip="Prevents two consecutive signals in the same direction.")
int   ssl_cooldown      = input.int(2,      "Cooldown bars",               group=g_ssl_core, minval=1, maxval=50,  tooltip="Minimum bars between confirmed signals.")
bool  ssl_show_lines    = input.bool(false, "Show SSL lines",              group=g_ssl_core, tooltip="Plots sslUp/sslDown channel lines on the chart.")

bool  ssl_show_labels         = input.bool(true, "Show confirmed labels",  group=g_ssl_style)
bool  ssl_show_pending        = input.bool(true, "Show pending labels",    group=g_ssl_style)
bool  ssl_pending_flash       = input.bool(true, "Flash pending labels",   group=g_ssl_style)
color ssl_long_color          = input.color(color.new(color.lime,  0),  "Long label color",    group=g_ssl_style)
color ssl_short_color         = input.color(color.new(color.red,   0),  "Short label color",   group=g_ssl_style)
color ssl_pending_long_color  = input.color(color.new(color.green, 60), "Pending long color",  group=g_ssl_style)
color ssl_pending_short_color = input.color(color.new(color.red,   60), "Pending short color", group=g_ssl_style)
color ssl_line_up_color       = input.color(color.new(color.teal,   0), "SSL Up line color",   group=g_ssl_style)
color ssl_line_dn_color       = input.color(color.new(color.orange, 0), "SSL Down line color", group=g_ssl_style)

// ============================================================================
// MODULE 07 - DELTA DISPLAY (REAL-TIME ORDER FLOW LABELS)
// ============================================================================
string g_dd_core  = "07 Delta Display - Core"
string g_dd_style = "07 Delta Display - Style"

bool   dd_enable       = input.bool(true,  "Enable Delta Display module", group=g_dd_core,
     tooltip="Master switch for the real-time volume delta visualization layer. Displays DV, DT, and POC data as per-bar labels and lines. This module is purely visual — it does not affect the signal engine.")
bool   dd_show_dv      = input.bool(true,  "Show DV",                    group=g_dd_core,
     tooltip="Displays delta volume (buy volume minus sell volume) as a number in a label below each bar.")
bool   dd_show_dv_pct  = input.bool(true,  "Show DV%",                   group=g_dd_core,
     tooltip="Displays delta volume as a percentage of total bar volume, below each bar. Useful for judging relative aggression.")
bool   dd_show_tot_vol = input.bool(true,  "Show total volume",           group=g_dd_core,
     tooltip="Displays the total volume of the bar below each bar, alongside DV values.")
bool   dd_dv_arrows    = input.bool(true,  "DV ▲▼ arrows",               group=g_dd_core,
     tooltip="Appends ▲ to the DV label when DV+ is increasing, or ▼ when DV– is deepening between consecutive bars.")
bool   dd_dv_seps      = input.bool(true,  "Show separators (DV)",        group=g_dd_core,
     tooltip="Adds a visual separator line between DV, total volume, and DV% values in the label below the bar.")
bool   dd_show_dt      = input.bool(true,  "Show DT",                    group=g_dd_core,
     tooltip="Displays delta ticks (uptick count minus downtick count) as a number in a label above each bar. Reflects order-flow aggression independent of volume size.")
bool   dd_show_dt_pct  = input.bool(false, "Show DT%",                   group=g_dd_core,
     tooltip="Displays delta ticks as a percentage of total tick count above each bar.")
bool   dd_show_tot_tck = input.bool(false, "Show total ticks",            group=g_dd_core,
     tooltip="Displays total tick count (upticks + downticks) above each bar.")
bool   dd_dt_arrows    = input.bool(true,  "DT ▲▼ arrows",               group=g_dd_core,
     tooltip="Appends ▲ to the DT label when DT+ is increasing, or ▼ when DT– is deepening between bars.")
bool   dd_dt_seps      = input.bool(true,  "Show separators (DT)",        group=g_dd_core,
     tooltip="Adds a visual separator line between DT, total ticks, and DT% values in the label above the bar.")
bool   dd_show_poc     = input.bool(true,  "Show POC line",               group=g_dd_core,
     tooltip="Draws a short horizontal line at the price of the highest-volume tick for each bar (intrabar Point of Control).")
bool   dd_show_div     = input.bool(true,  "Show divergences",            group=g_dd_core,
     tooltip="Changes the label color when delta polarity conflicts with bar direction — e.g., positive DV on a down bar indicates hidden buying.")
int    dd_visible      = input.int(50,     "Visible past bars",           group=g_dd_core, minval=0, maxval=245,
     tooltip="Number of closed bars for which DV/DT labels and POC lines remain visible. Reduce if chart performance degrades.")

string dd_txt_size    = input.string("small", "Text size", group=g_dd_style,
     options=["tiny", "small", "normal", "large"],
     tooltip="Font size for DV and DT label text.")
int    dd_dv_prec     = input.int(0, "DV precision", group=g_dd_style, minval=0, maxval=6,
     tooltip="Decimal places shown for volume values in DV labels. Use 0 for whole numbers (most crypto/equity charts).")
color  dd_c_dv_bull   = input.color(#008000ff, "DV ▲",          inline="dd_dv", group=g_dd_style,
     tooltip="Label color when delta volume is positive (buyers dominant).")
color  dd_c_dv_bear   = input.color(#C90707ff, "▼",             inline="dd_dv", group=g_dd_style)
color  dd_c_dv_div    = input.color(#FF8000ff, "div",           inline="dd_dv", group=g_dd_style,
     tooltip="Label color when DV polarity conflicts with the bar's direction (divergence).")
color  dd_c_dt_bull   = input.color(#00FF00ff, "DT ▲",          inline="dd_dt", group=g_dd_style,
     tooltip="Label color when delta ticks is positive (more upticks than downticks).")
color  dd_c_dt_bear   = input.color(#FF0080ff, "▼",             inline="dd_dt", group=g_dd_style)
color  dd_c_dt_div    = input.color(#FF8000ff, "div",           inline="dd_dt", group=g_dd_style,
     tooltip="Label color when DT polarity conflicts with the bar's direction (divergence).")
color  dd_c_poc_bull  = input.color(#00FF00ff, "POC ▲",         inline="dd_poc", group=g_dd_style,
     tooltip="POC line color on bars where close >= open.")
color  dd_c_poc_bear  = input.color(#FF0080ff, "▼",             inline="dd_poc", group=g_dd_style)
color  dd_c_poc_neu   = input.color(#808080ff, "•",             inline="dd_poc", group=g_dd_style,
     tooltip="POC line color when bar direction is neutral (no clear up/down).")
bool   dd_poc_div_on  = input.bool(true, "POC divergence", group=g_dd_style,
     tooltip="When enabled, uses a separate color for the POC line when the POC did not move in the same direction as the bar.")
color  dd_c_poc_div   = input.color(#FF8000ff, "POC div color", group=g_dd_style,
     tooltip="POC line color when POC direction diverges from bar direction.")
int    dd_poc_w       = input.int(2, "POC line width", group=g_dd_style, minval=1, maxval=4,
     tooltip="Thickness of the per-bar POC line (1–4 pixels).")

// ============================================================================
// MODULE 08 — HTF CANDLE VOLUME PROFILE
// ============================================================================
string g_htf_core  = "08 HTF Candle VP - Core"
string g_htf_c1    = "08 HTF Candle VP - Candle 1"
string g_htf_c2    = "08 HTF Candle VP - Candle 2"
string g_htf_c3    = "08 HTF Candle VP - Candle 3"
string g_htf_style = "08 HTF Candle VP - Style"

bool   htf_enable   = input.bool(true,  "Enable HTF Candle VP module", group=g_htf_core,
     tooltip="Shows the last completed candle for each configured timeframe with its Volume Profile (POC/VAH/VAL), projected to the right of the chart.")
int    htf_bins     = input.int(20,  "Profile Bins",         group=g_htf_core, minval=5,  maxval=50,
     tooltip="Number of price levels in each Volume Profile histogram.")
int    htf_width    = input.int(15,  "Profile Width (bars)", group=g_htf_core, minval=3,  maxval=50,
     tooltip="Maximum horizontal width of each histogram in bars.")
int    htf_offset   = input.int(20,  "Projection Offset",    group=g_htf_core, minval=5,  maxval=150,
     tooltip="Bars to the right of the last bar where the first slot begins.")
int    htf_va_pct   = input.int(70,  "Value Area %",         group=g_htf_core, minval=50, maxval=100,
     tooltip="Percentage of total volume defining the Value Area (VAH/VAL).")
int    htf_slot_gap = input.int(5,   "Slot gap (bars)",      group=g_htf_core, minval=1,  maxval=20,
     tooltip="Gap in bars between consecutive candle slots.")
bool   htf_show_poc    = input.bool(true, "POC", group=g_htf_core, inline="htf_lvls",
     tooltip="Draw POC level line extending left to candle start on the live chart.")
bool   htf_show_vah    = input.bool(true, "VAH", group=g_htf_core, inline="htf_lvls",
     tooltip="Draw VAH level line.")
bool   htf_show_val    = input.bool(true, "VAL", group=g_htf_core, inline="htf_lvls",
     tooltip="Draw VAL level line.")
bool   htf_lbl_poc  = input.bool(true, "POC label",  group=g_htf_core, inline="htf_lbls")
bool   htf_lbl_vah  = input.bool(true, "VAH label",  group=g_htf_core, inline="htf_lbls")
bool   htf_lbl_val  = input.bool(true, "VAL label",  group=g_htf_core, inline="htf_lbls")
bool   htf_lbl_hilo = input.bool(false, "H/L labels", group=g_htf_core, inline="htf_lbls2")
bool   htf_lbl_tf   = input.bool(true, "TF label",   group=g_htf_core, inline="htf_lbls2")

bool   htf_c1_on   = input.bool(true,     "Enable",  group=g_htf_c1, inline="htf_c1h")
string htf_c1_tf   = input.timeframe("D", "TF",      group=g_htf_c1, inline="htf_c1h")
color  htf_c1_bull = input.color(color.new(#00bcd4, 0), "Bull", group=g_htf_c1, inline="htf_c1c")
color  htf_c1_bear = input.color(color.new(#ff5722, 0), "Bear", group=g_htf_c1, inline="htf_c1c")

bool   htf_c2_on   = input.bool(true,     "Enable",  group=g_htf_c2, inline="htf_c2h")
string htf_c2_tf   = input.timeframe("W", "TF",      group=g_htf_c2, inline="htf_c2h")
color  htf_c2_bull = input.color(color.new(#4caf50, 0), "Bull", group=g_htf_c2, inline="htf_c2c")
color  htf_c2_bear = input.color(color.new(#f44336, 0), "Bear", group=g_htf_c2, inline="htf_c2c")

bool   htf_c3_on   = input.bool(true,     "Enable",  group=g_htf_c3, inline="htf_c3h")
string htf_c3_tf   = input.timeframe("M", "TF",      group=g_htf_c3, inline="htf_c3h")
color  htf_c3_bull = input.color(color.new(#9c27b0, 0), "Bull", group=g_htf_c3, inline="htf_c3c")
color  htf_c3_bear = input.color(color.new(#e91e63, 0), "Bear", group=g_htf_c3, inline="htf_c3c")

color  htf_poc_color = input.color(color.orange,               "POC", group=g_htf_style, inline="htf_poc")
string htf_poc_style = input.string("Dashed", "",              options=["Solid","Dashed","Dotted"], group=g_htf_style, inline="htf_poc")
color  htf_vah_color = input.color(color.new(color.yellow, 0), "VAH", group=g_htf_style, inline="htf_vah")
string htf_vah_style = input.string("Dotted", "",              options=["Solid","Dashed","Dotted"], group=g_htf_style, inline="htf_vah")
color  htf_val_color = input.color(color.new(color.yellow, 0), "VAL", group=g_htf_style, inline="htf_val")
string htf_val_style = input.string("Dotted", "",              options=["Solid","Dashed","Dotted"], group=g_htf_style, inline="htf_val")
int    htf_level_width = input.int(1, "Level line width", minval=1, maxval=4, group=g_htf_style)
bool   htf_show_hilo   = input.bool(true, "Show H/L boundary lines", group=g_htf_style,
     tooltip="Draws candle High and Low level lines extending from the candle start to the profile slot.")

// ============================================================================
// HELPERS
// ============================================================================
f_line_style(string s) =>
    s == "Solid" ? line.style_solid : s == "Dotted" ? line.style_dotted : line.style_dashed

f_line_extend(string s) =>
    s == "Right" ? extend.right : s == "Left" ? extend.left : s == "Both" ? extend.both : extend.none

f_lbl_size(string s) =>
    s == "Huge" ? size.huge : s == "Large" ? size.large : s == "Small" ? size.small : s == "Tiny" ? size.tiny : s == "Auto" ? size.auto : size.normal

f_vp_line_style(string s) =>
    s == "Dotted" ? line.style_dotted : s == "Dashed" ? line.style_dashed : line.style_solid

f_vp_anchor_tf() =>
    vp_custom_anchor_tf ? vp_manual_anchor_tf : vp_anchor_unit == "Session" ? "D" : str.tostring(vp_period) + (vp_anchor_unit == "Day" ? "D" : vp_anchor_unit == "Week" ? "W" : "M")

f_vp_create_profile(series int rows) =>
    LibVPrf.create(
      bins      = rows,
      upper     = 10.0,
      lower     = 1.0,
      valueArea = vp_val_area,
      dynamic   = true,
      isLog     = false,
      allot     = LibVPrf.AllotMode.pdf,
      estimator = LibBrSt.RealEst.t4Skew,
      split     = LibVPrf.SplitMode.dynamic,
      trendLen  = 3)

f_vp_intbar_calc() =>
    var series bool vldPrd = false
    series bool reset = LibTmFr.isNewPeriod(vp_chart_tf_global)
    series bool multiple = LibTmFr.isMultipleTF(vp_chart_tf_global)
    vldPrd := not multiple ? false : reset ? true : vldPrd

    var LibVPrf.VPrf ibProf = f_vp_create_profile(vp_bar_rows)
    if reset
        ibProf.clear()
        ibProf.setBounds(
          upper = math.max(high, open + (syminfo.mintick / 2)),
          lower = math.min(low, open - (syminfo.mintick / 2)))

    ibProf.addBar()
    if vldPrd
        [upper, lower] = ibProf.getBounds()
        [ibProf.getBuyVol(), ibProf.getSellVol(), upper, lower]
    else
        [na, na, na, na]

f_vp_bar_profile() =>
    LibVPrf.VPrf _p = f_vp_create_profile(vp_bar_rows)
    _p.setBounds(
        upper = math.max(high, open + syminfo.mintick),
        lower = math.min(low,  open - syminfo.mintick))
    _p.addBar()
    [_u, _l] = _p.getBounds()
    [_p.getBuyVol(), _p.getSellVol(), _u, _l]

f_auto_delta_ltf() =>
    int chart_sec = timeframe.in_seconds(timeframe.period)
    chart_sec >= 86400 ? "15" : chart_sec >= 14400 ? "5" : chart_sec >= 3600 ? "3" : chart_sec >= 900 ? "1" : "1"

f_clear_line_array(array<line> arr) =>
    int sz = array.size(arr)
    if sz > 0
        for i = 0 to sz - 1
            line.delete(array.get(arr, i))
    array.clear(arr)

f_trim_line_array(array<line> arr, int max_size) =>
    while array.size(arr) > max_size
        line.delete(array.shift(arr))

f_clear_box_array(array<box> arr) =>
    int sz = array.size(arr)
    if sz > 0
        for i = 0 to sz - 1
            box.delete(array.get(arr, i))
    array.clear(arr)

f_ib_auto_session(int offset_h, int offset_m) =>
    string t = syminfo.ticker
    bool is_eq = str.contains(t, "ES") or str.contains(t, "NQ") or str.contains(t, "YM") or str.contains(t, "RTY")
    bool is_gc = str.contains(t, "GC") or str.contains(t, "MGC") or str.contains(t, "XAUUSD") or str.contains(t, "GOLD")
    bool is_si = str.contains(t, "SI") or str.contains(t, "XAGUSD")
    bool is_pl = str.contains(t, "PL")
    bool is_hg = str.contains(t, "HG")
    bool is_cl = str.contains(t, "CL") or str.contains(t, "NG") or str.contains(t, "HO") or str.contains(t, "RB")
    bool is_dx = str.contains(t, "DX")
    bool is_fx = str.contains(t, "6E") or str.contains(t, "6B") or str.contains(t, "6A") or str.contains(t, "ZB") or str.contains(t, "ZN")
    bool is_gr = str.contains(t, "ZW") or str.contains(t, "ZS") or str.contains(t, "ZC")
    bool is_ct = str.contains(t, "CT")
    bool is_sb = str.contains(t, "SB")
    bool is_kc = str.contains(t, "KC")
    bool is_cc = str.contains(t, "CC")

    string base = is_eq ? "0830-0930" : is_gc or is_pl ? "0820-0920" : is_si ? "0825-0925" : is_hg ? "0810-0910" : is_cl ? "0900-1000" : is_dx or is_kc ? "0800-0900" : is_fx ? "0820-0920" : is_gr ? "0930-1030" : is_ct ? "1030-1130" : is_sb ? "0810-0910" : is_cc ? "0800-0900" : "0930-1030"

    float start_hhmm = str.tonumber(str.substring(base, 0, 4))
    float end_hhmm = str.tonumber(str.substring(base, 5, 9))

    int start_h = int(math.floor(start_hhmm / 100)) + offset_h
    int start_m = int(start_hhmm - math.floor(start_hhmm / 100) * 100) + offset_m
    int end_h = int(math.floor(end_hhmm / 100)) + offset_h
    int end_m = int(end_hhmm - math.floor(end_hhmm / 100) * 100) + offset_m

    start_h := start_m >= 60 ? start_h + 1 : start_m < 0 ? start_h - 1 : start_h
    start_m := start_m >= 60 ? start_m - 60 : start_m < 0 ? start_m + 60 : start_m
    end_h := end_m >= 60 ? end_h + 1 : end_m < 0 ? end_h - 1 : end_h
    end_m := end_m >= 60 ? end_m - 60 : end_m < 0 ? end_m + 60 : end_m

    str.tostring(start_h * 100 + start_m, "0000") + "-" + str.tostring(end_h * 100 + end_m, "0000")

f_calc_vp_range(int from_idx, int len, int bins, float va_pct) =>
    float lo = low[from_idx]
    float hi = high[from_idx]

    int max_i = from_idx + len - 1
    for i = from_idx to max_i
        lo := math.min(lo, low[i])
        hi := math.max(hi, high[i])

    float step = (hi - lo) / math.max(bins - 1, 1)
    step := step == 0.0 ? syminfo.mintick : step

    float[] vols = array.new_float(bins, 0.0)

    for i = from_idx to max_i
        float bLo = low[i]
        float bHi = high[i]
        float bVol = volume[i]

        if bHi == bLo
            int idx = int(math.round((close[i] - lo) / step))
            idx := math.max(0, math.min(bins - 1, idx))
            array.set(vols, idx, array.get(vols, idx) + bVol)
        else
            for j = 0 to bins - 1
                float lvl = lo + step * j
                if lvl >= bLo and lvl < bHi
                    array.set(vols, j, array.get(vols, j) + bVol)

    float mx = array.max(vols)
    int pi = array.indexof(vols, mx)
    float poc = lo + step * pi

    float mx2 = 0.0
    int hvn_i = pi
    for j = 0 to bins - 1
        float vj = array.get(vols, j)
        if j != pi and vj > mx2
            mx2 := vj
            hvn_i := j
    float hvn = lo + step * hvn_i

    float tot = array.sum(vols)
    float tgt = tot * va_pct / 100.0
    int up_i = pi
    int dn_i = pi
    float vs = mx

    while vs < tgt
        float up_v = up_i < bins - 1 ? array.get(vols, up_i + 1) : 0.0
        float dn_v = dn_i > 0 ? array.get(vols, dn_i - 1) : 0.0
        if up_v == 0.0 and dn_v == 0.0
            break
        if up_v >= dn_v
            vs += up_v
            up_i += 1
        else
            vs += dn_v
            dn_i -= 1

    float vah = lo + step * up_i
    float val = lo + step * dn_i
    [poc, vah, val, hvn]

// ============================================================================
// VWAP CALC
// ============================================================================
bool vwap_new_period = switch vwap_anchor
    "Earnings" =>
        float new_earnings_actual = request.earnings(syminfo.tickerid, earnings.actual, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
        float new_earnings_standardized = request.earnings(syminfo.tickerid, earnings.standardized, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
        not na(new_earnings_actual) or not na(new_earnings_standardized)
    "Dividends" =>
        float new_dividends = request.dividends(syminfo.tickerid, dividends.gross, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
        not na(new_dividends)
    "Splits" =>
        float new_split = request.splits(syminfo.tickerid, splits.denominator, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
        not na(new_split)
    "Session" => timeframe.change("D")
    "Week" => timeframe.change("W")
    "Month" => timeframe.change("M")
    "Quarter" => timeframe.change("3M")
    "Year" => timeframe.change("12M")
    "Decade" => timeframe.change("12M") and year % 10 == 0
    "Century" => timeframe.change("12M") and year % 100 == 0
    => false

bool vwap_is_esd_anchor = vwap_anchor == "Earnings" or vwap_anchor == "Dividends" or vwap_anchor == "Splits"
if na(vwap_src[1]) and not vwap_is_esd_anchor
    vwap_new_period := true

float vwap_value = na
float vwap_upper_1 = na
float vwap_lower_1 = na
float vwap_upper_2 = na
float vwap_lower_2 = na
float vwap_upper_3 = na
float vwap_lower_3 = na

if vwap_enable and not (vwap_hide_on_dwm and timeframe.isdwm)
    [vwap_raw, stdev_upper_raw, _] = ta.vwap(vwap_src, vwap_new_period, 1)
    vwap_value := vwap_raw
    float stdev_abs = stdev_upper_raw - vwap_raw
    float band_basis = vwap_calc_mode == "Standard Deviation" ? stdev_abs : vwap_raw * 0.01

    vwap_upper_1 := vwap_raw + band_basis * vwap_band_mult_1
    vwap_lower_1 := vwap_raw - band_basis * vwap_band_mult_1
    vwap_upper_2 := vwap_raw + band_basis * vwap_band_mult_2
    vwap_lower_2 := vwap_raw - band_basis * vwap_band_mult_2
    vwap_upper_3 := vwap_raw + band_basis * vwap_band_mult_3
    vwap_lower_3 := vwap_raw - band_basis * vwap_band_mult_3

bool vwap_ready = not na(vwap_upper_1) and not na(vwap_lower_1)

int STATE_UP = 1
int STATE_DN = -1
int STATE_BAL = 0
int vwap_state = vwap_ready ? (close > vwap_upper_1 ? STATE_UP : close < vwap_lower_1 ? STATE_DN : STATE_BAL) : STATE_BAL

float vwap_failed_min_abs_up = vwap_ready ? vwap_upper_1 * vwap_failed_min_pct / 100.0 : 0.0
float vwap_failed_min_abs_dn = vwap_ready ? vwap_lower_1 * vwap_failed_min_pct / 100.0 : 0.0
bool vwap_pen_up = vwap_ready and (high - vwap_upper_1) >= vwap_failed_min_abs_up and close < vwap_upper_1
bool vwap_pen_dn = vwap_ready and (vwap_lower_1 - low)  >= vwap_failed_min_abs_dn and close > vwap_lower_1
var int vwap_last_fail_up_bar = -99999
var int vwap_last_fail_dn_bar = -99999
bool vwap_failed_breakout_up = vwap_pen_up and (bar_index - vwap_last_fail_up_bar) >= vwap_failed_cooldown
bool vwap_failed_breakout_dn = vwap_pen_dn and (bar_index - vwap_last_fail_dn_bar) >= vwap_failed_cooldown
if vwap_failed_breakout_up
    vwap_last_fail_up_bar := bar_index
if vwap_failed_breakout_dn
    vwap_last_fail_dn_bar := bar_index
bool vwap_cross_up_raw = ta.crossover(close, vwap_value)
bool vwap_cross_dn_raw = ta.crossunder(close, vwap_value)
bool vwap_cross_up = vwap_ready and vwap_cross_up_raw
bool vwap_cross_dn = vwap_ready and vwap_cross_dn_raw

float vwap_up_outer = vwap_cloud_use_band2 and not na(vwap_upper_2) ? vwap_upper_2 : vwap_upper_1
float vwap_dn_outer = vwap_cloud_use_band2 and not na(vwap_lower_2) ? vwap_lower_2 : vwap_lower_1
float vwap_up_mid = (vwap_upper_1 + vwap_up_outer) * 0.5
float vwap_dn_mid = (vwap_lower_1 + vwap_dn_outer) * 0.5

// ============================================================================
// PERIODIC VP CALC
// ============================================================================
string vp_chart_tf = vp_chart_tf_global
string vp_ib_tf = vp_custom_ltf ? vp_manual_ltf : LibTmFr.autoLTF(vp_chart_tf)
string vp_anchor_tf = f_vp_anchor_tf()
int vp_chart_sec = timeframe.in_seconds(vp_chart_tf)
bool vp_ib_uses_seconds = str.contains(str.upper(vp_ib_tf), "S")
string vp_ib_tf_no_seconds = vp_ib_uses_seconds ? "1" : vp_ib_tf
bool vp_ib_tf_valid = timeframe.in_seconds(vp_ib_tf_no_seconds) < vp_chart_sec
bool vp_anchor_tf_valid = timeframe.in_seconds(vp_anchor_tf) > vp_chart_sec

string vp_ib_tf_eff = vp_ib_tf_valid ? vp_ib_tf_no_seconds : "1"
string vp_anchor_tf_eff = vp_anchor_tf_valid ? vp_anchor_tf : (vp_chart_sec < timeframe.in_seconds("D") ? "D" : vp_chart_sec < timeframe.in_seconds("W") ? "W" : "M")

f_vp_ib_convert() =>
    request.security(syminfo.tickerid, vp_ib_tf_eff, f_vp_intbar_calc(), barmerge.gaps_off, barmerge.lookahead_off)

[vp_a_buy, vp_a_sell, vp_upper, vp_lower] = if vp_enable
    f_vp_ib_convert()
else
    [na, na, na, na]

bool vp_use_fallback = vp_enable and vp_bar_fallback and not vp_ib_tf_valid
[_fb_buy, _fb_sell, _fb_u, _fb_l] = f_vp_bar_profile()
if vp_use_fallback
    vp_a_buy  := _fb_buy
    vp_a_sell := _fb_sell
    vp_upper  := _fb_u
    vp_lower  := _fb_l

var LibVPrf.VPrf vp_period_profile = f_vp_create_profile(vp_profile_rows)
LibVPrf.VPrf vp_flash_profile = vp_period_profile.clone()

var bool vp_draw_period = false
var bool vp_valid_period = false
var int vp_reset_bar = na
var int vp_reset_time = na
var int vp_prev_start_bar = na
var int vp_prev_end_bar = na
int vp_start_bar = na
int vp_end_bar = na
int vp_start_time = na
int vp_end_time = na
if vp_enable and na(vp_reset_bar)
    vp_reset_bar := bar_index
    vp_reset_time := time
    vp_valid_period := true
bool vp_new_period_raw = LibTmFr.isNewPeriod(vp_anchor_tf_eff)
bool vp_new_period = vp_enable and vp_new_period_raw
if vp_new_period
    vp_draw_period := vp_valid_period
    vp_valid_period := true

    if not na(vp_reset_bar)
        vp_prev_start_bar := vp_reset_bar
        vp_prev_end_bar   := bar_index - 1
        vp_start_bar := vp_reset_bar
        vp_end_bar   := bar_index - 1
        vp_start_time := vp_reset_time
        vp_end_time   := time[1] + timeframe.in_seconds() * 1000
    vp_reset_bar := bar_index
    vp_reset_time := time

    vp_period_profile.clear()
    vp_period_profile.setBounds(
      upper = nz(vp_upper, math.max(high, open + (syminfo.mintick / 2))),
      lower = nz(vp_lower, math.min(low, open - (syminfo.mintick / 2))))

var float vp_cur_poc = na
var float vp_cur_vah = na
var float vp_cur_val = na
if vp_enable and vp_valid_period
    if not na(vp_a_buy) and not na(vp_reset_bar)
        vp_period_profile.merge(
          buyVol = vp_a_buy,
          sellVol = vp_a_sell,
          upper = vp_upper,
          lower = vp_lower,
          cvd = 0,
          cvdHi = 0,
          cvdLo = 0)

        if vp_rows_dynamic
            [up, lo] = vp_period_profile.getBounds()
            float move_size = (up - lo) / up
            vp_period_profile.setBins(math.max(1, int(vp_profile_rows * move_size * 100)))

        [_, _poc] = vp_period_profile.getPoc()
        [_, _va_up, _, _va_lo] = vp_period_profile.getValueArea()
        vp_cur_poc := _poc
        vp_cur_vah := _va_up
        vp_cur_val := _va_lo
    else if na(vp_reset_bar)
        vp_valid_period := false

if vp_enable and barstate.islast
    if vp_reset_bar == bar_index
        vp_flash_profile := vp_period_profile
    else if not na(vp_a_buy)
        vp_flash_profile.merge(
          buyVol = vp_a_buy,
          sellVol = vp_a_sell,
          upper = vp_upper,
          lower = vp_lower,
          cvd = 0,
          cvdHi = 0,
          cvdLo = 0)

        if vp_rows_dynamic
            [up, lo] = vp_flash_profile.getBounds()
            float move_size = (up - lo) / up
            vp_flash_profile.setBins(math.max(1, int(vp_profile_rows * move_size * 100)))

    vp_draw_period := vp_valid_period
    vp_end_bar := bar_index
    vp_start_bar := vp_reset_bar
    vp_start_time := vp_reset_time
    vp_end_time := time + timeframe.in_seconds() * 1000

    // Keep visible key levels in sync with the actually rendered profile.
    if vp_draw_period and not na(vp_start_bar) and not na(vp_end_bar) and vp_end_bar >= vp_start_bar
        [_, _poc_live] = vp_flash_profile.getPoc()
        [_, _va_up_live, _, _va_lo_live] = vp_flash_profile.getValueArea()
        vp_cur_poc := _poc_live
        vp_cur_vah := _va_up_live
        vp_cur_val := _va_lo_live

var float vp_prev_poc = na
var float vp_prev_vah = na
var float vp_prev_val = na
if vp_new_period
    vp_prev_poc := vp_cur_poc[1]
    vp_prev_vah := vp_cur_vah[1]
    vp_prev_val := vp_cur_val[1]

var line vp_ext_poc = na
var line vp_ext_vah = na
var line vp_ext_val = na
if vp_enable and vp_new_period
    if vp_extend_poc and not na(vp_prev_poc)
        line.delete(vp_ext_poc)
        vp_ext_poc := line.new(bar_index, vp_prev_poc, bar_index + 1, vp_prev_poc, extend=extend.right, color=vp_poc_color, style=f_vp_line_style(vp_poc_style), width=vp_level_width)
    if vp_extend_vah and not na(vp_prev_vah)
        line.delete(vp_ext_vah)
        vp_ext_vah := line.new(bar_index, vp_prev_vah, bar_index + 1, vp_prev_vah, extend=extend.right, color=vp_vah_color, style=f_vp_line_style(vp_vah_style), width=vp_level_width)
    if vp_extend_val and not na(vp_prev_val)
        line.delete(vp_ext_val)
        vp_ext_val := line.new(bar_index, vp_prev_val, bar_index + 1, vp_prev_val, extend=extend.right, color=vp_val_color, style=f_vp_line_style(vp_val_style), width=vp_level_width)
if not vp_enable or not vp_extend_poc
    line.delete(vp_ext_poc)
    vp_ext_poc := na
if not vp_enable or not vp_extend_vah
    line.delete(vp_ext_vah)
    vp_ext_vah := na
if not vp_enable or not vp_extend_val
    line.delete(vp_ext_val)
    vp_ext_val := na

// ============================================================================
// INITIAL BALANCE CALC
// ============================================================================
string ib_window = ib_manual_override ? ib_manual_session : f_ib_auto_session(0, 0)
bool ib_active = ib_enable and not na(time(timeframe.period, ib_window))

var float ib_delta = na
var int ib_bars_count = 0
var float ib_high = na
var float ib_low = na
var float ib_mid = na
var array<float> ib_delta_buffer = array.new_float(20)

var line ib_ln_h = na
var line ib_ln_l = na
var line ib_ln_m = na
var line ib_ln_h2 = na
var line ib_ln_l2 = na
var line ib_ln_h3 = na
var line ib_ln_l3 = na
var line ib_ln_hm = na
var line ib_ln_lm = na

var label ib_lb_h = na
var label ib_lb_l = na
var label ib_lb_m = na
var label ib_lb_h2 = na
var label ib_lb_l2 = na
var label ib_lb_h3 = na
var label ib_lb_l3 = na
var label ib_lb_hm = na
var label ib_lb_lm = na

var box ib_zone_box = na

f_calc_ib(int n) =>
    float hi = high[1]
    float lo = low[1]
    for i = 1 to n
        hi := math.max(hi, high[i])
        lo := math.min(lo, low[i])
    [hi, lo, (hi + lo) / 2.0]

bgcolor(ib_shade_window and ib_enable and ib_active ? color.new(color.purple, 82) : na, title="IB Window")

if ib_active
    ib_bars_count += 1

if ib_active[1] and not ib_active
    [_ib_high, _ib_low, _ib_mid] = f_calc_ib(ib_bars_count)
    ib_high := _ib_high
    ib_low := _ib_low
    ib_mid := _ib_mid
    ib_delta := ib_high - ib_low

    if array.size(ib_delta_buffer) >= 20
        array.shift(ib_delta_buffer)
    array.push(ib_delta_buffer, ib_delta)

    if ib_this_day_only
        line.delete(ib_ln_h), line.delete(ib_ln_l), line.delete(ib_ln_m)
        line.delete(ib_ln_h2), line.delete(ib_ln_l2), line.delete(ib_ln_h3), line.delete(ib_ln_l3)
        line.delete(ib_ln_hm), line.delete(ib_ln_lm)
        label.delete(ib_lb_h), label.delete(ib_lb_l), label.delete(ib_lb_m)
        label.delete(ib_lb_h2), label.delete(ib_lb_l2), label.delete(ib_lb_h3), label.delete(ib_lb_l3)
        label.delete(ib_lb_hm), label.delete(ib_lb_lm)

    if ib_shade_zones and ib_this_zone_only
        box.delete(ib_zone_box)

    ib_ext_mode = f_line_extend(ib_extend_opt)
    ib_main_ln_style = f_line_style(ib_main_style)
    ib_ext_ln_style = f_line_style(ib_ext_style)
    ib_mid_ln_style = f_line_style(ib_mid_style)

    ib_ln_h := line.new(bar_index[ib_bars_count], ib_high, bar_index, ib_high, width=ib_line_width, extend=ib_ext_mode, color=ib_clr_high, style=ib_main_ln_style)
    ib_ln_l := line.new(bar_index[ib_bars_count], ib_low, bar_index, ib_low, width=ib_line_width, extend=ib_ext_mode, color=ib_clr_low, style=ib_main_ln_style)

    if ib_draw_mid_points
        ib_ln_m := line.new(bar_index[ib_bars_count], ib_mid, bar_index, ib_mid, width=ib_line_width, extend=ib_ext_mode, color=ib_clr_mid, style=ib_mid_ln_style)

    if ib_draw_extras
        ib_ln_h2 := line.new(bar_index[ib_bars_count], ib_high + ib_delta, bar_index, ib_high + ib_delta, width=ib_line_width, extend=ib_ext_mode, color=ib_clr_high, style=ib_ext_ln_style)
        ib_ln_l2 := line.new(bar_index[ib_bars_count], ib_low - ib_delta, bar_index, ib_low - ib_delta, width=ib_line_width, extend=ib_ext_mode, color=ib_clr_low, style=ib_ext_ln_style)
        ib_ln_h3 := line.new(bar_index[ib_bars_count], ib_high + ib_delta * 2.0, bar_index, ib_high + ib_delta * 2.0, width=ib_line_width, extend=ib_ext_mode, color=ib_clr_high, style=ib_ext_ln_style)
        ib_ln_l3 := line.new(bar_index[ib_bars_count], ib_low - ib_delta * 2.0, bar_index, ib_low - ib_delta * 2.0, width=ib_line_width, extend=ib_ext_mode, color=ib_clr_low, style=ib_ext_ln_style)
        if ib_draw_mid_points
            ib_ln_hm := line.new(bar_index[ib_bars_count], ib_high + ib_delta / 2.0, bar_index, ib_high + ib_delta / 2.0, width=ib_line_width, extend=ib_ext_mode, color=ib_clr_mid, style=ib_mid_ln_style)
            ib_ln_lm := line.new(bar_index[ib_bars_count], ib_low - ib_delta / 2.0, bar_index, ib_low - ib_delta / 2.0, width=ib_line_width, extend=ib_ext_mode, color=ib_clr_mid, style=ib_mid_ln_style)

    if ib_render_labels
        label_size = f_lbl_size(ib_lbl_size_opt)
        ib_lb_h := label.new(bar_index[ib_bars_count], ib_high, "IB High\n" + str.tostring(ib_high), textcolor=ib_clr_high, style=label.style_none, size=label_size)
        ib_lb_l := label.new(bar_index[ib_bars_count], ib_low, "IB Low\n" + str.tostring(ib_low), textcolor=ib_clr_low, style=label.style_none, size=label_size)
        if ib_draw_mid_points
            ib_lb_m := label.new(bar_index[ib_bars_count], ib_mid, "Mid 50%\n" + str.tostring(ib_mid) + "\nDelta=" + str.tostring(ib_delta), textcolor=ib_clr_mid, style=label.style_none, size=label_size)
        if ib_draw_extras
            ib_lb_h2 := label.new(bar_index[ib_bars_count], ib_high + ib_delta, "High x2\n" + str.tostring(ib_high + ib_delta), textcolor=ib_clr_high, style=label.style_none, size=label_size)
            ib_lb_l2 := label.new(bar_index[ib_bars_count], ib_low - ib_delta, "Low x2\n" + str.tostring(ib_low - ib_delta), textcolor=ib_clr_low, style=label.style_none, size=label_size)
            ib_lb_h3 := label.new(bar_index[ib_bars_count], ib_high + ib_delta * 2.0, "High x3\n" + str.tostring(ib_high + ib_delta * 2.0), textcolor=ib_clr_high, style=label.style_none, size=label_size)
            ib_lb_l3 := label.new(bar_index[ib_bars_count], ib_low - ib_delta * 2.0, "Low x3\n" + str.tostring(ib_low - ib_delta * 2.0), textcolor=ib_clr_low, style=label.style_none, size=label_size)

    if ib_shade_zones
        ib_zone_box := box.new(bar_index[ib_bars_count], ib_high, bar_index, ib_low, bgcolor=ib_zone_tint, border_color=color.new(color.black, 100))

    ib_bars_count := 0

if ib_enable and not ib_active and not ib_active[1]
    line.set_x2(ib_ln_h, bar_index), line.set_x2(ib_ln_l, bar_index)
    if ib_draw_mid_points
        line.set_x2(ib_ln_m, bar_index)
    if ib_draw_extras
        line.set_x2(ib_ln_h2, bar_index), line.set_x2(ib_ln_l2, bar_index)
        line.set_x2(ib_ln_h3, bar_index), line.set_x2(ib_ln_l3, bar_index)
        if ib_draw_mid_points
            line.set_x2(ib_ln_hm, bar_index), line.set_x2(ib_ln_lm, bar_index)

f_ib_sentiment() =>
    float hi = array.size(ib_delta_buffer) > 0 ? array.max(ib_delta_buffer) : na
    float lo = array.size(ib_delta_buffer) > 0 ? array.min(ib_delta_buffer) : na
    float avg = array.size(ib_delta_buffer) > 0 ? array.avg(ib_delta_buffer) : na
    float diff_hi = math.abs(ib_delta - hi)
    float diff_lo = math.abs(ib_delta - lo)
    float diff_av = math.abs(ib_delta - avg)
    diff_hi < diff_lo and diff_hi < diff_av ? "Wide" : diff_lo < diff_hi and diff_lo < diff_av ? "Narrow" : "Average"

var table ib_stat_tbl = table.new(position.bottom_left, 2, 6)
if ib_enable and ib_show_delta_info and array.size(ib_delta_buffer) > 0 and not na(ib_delta)
    table.cell(ib_stat_tbl, 0, 0, "IB-Delta Stats", bgcolor=color.black, text_color=color.white)
    table.cell(ib_stat_tbl, 0, 1, "20-day Max", bgcolor=color.black, text_color=color.white)
    table.cell(ib_stat_tbl, 1, 1, str.tostring(array.max(ib_delta_buffer), "#.####"), bgcolor=color.black, text_color=ib_clr_high)
    table.cell(ib_stat_tbl, 0, 2, "20-day Mean", bgcolor=color.black, text_color=color.white)
    table.cell(ib_stat_tbl, 1, 2, str.tostring(array.avg(ib_delta_buffer), "#.####"), bgcolor=color.black, text_color=ib_clr_mid)
    table.cell(ib_stat_tbl, 0, 3, "20-day Min", bgcolor=color.black, text_color=color.white)
    table.cell(ib_stat_tbl, 1, 3, str.tostring(array.min(ib_delta_buffer), "#.####"), bgcolor=color.black, text_color=ib_clr_low)
    table.cell(ib_stat_tbl, 0, 4, "Today Delta", bgcolor=color.black, text_color=color.white)
    table.cell(ib_stat_tbl, 1, 4, str.tostring(ib_delta), bgcolor=color.black, text_color=color.blue)
    table.cell(ib_stat_tbl, 0, 5, "Status", bgcolor=color.black, text_color=color.white)
    table.cell(ib_stat_tbl, 1, 5, f_ib_sentiment(), bgcolor=color.black, text_color=color.white)

// ============================================================================
// PVSRA CALC
// ============================================================================
f_pvsra_src(float s) =>
    request.security(pvsra_override_symbol ? pvsra_symbol : syminfo.tickerid, "", s, barmerge.gaps_off, barmerge.lookahead_off)

float pvsra_vol = pvsra_enable ? (pvsra_override_symbol ? f_pvsra_src(volume) : volume) : volume
float pvsra_hi = pvsra_enable ? (pvsra_override_symbol ? f_pvsra_src(high) : high) : high
float pvsra_lo = pvsra_enable ? (pvsra_override_symbol ? f_pvsra_src(low) : low) : low
float pvsra_cl = pvsra_enable ? (pvsra_override_symbol ? f_pvsra_src(close) : close) : close
float pvsra_op = pvsra_enable ? (pvsra_override_symbol ? f_pvsra_src(open) : open) : open

float pvsra_av = ta.sma(pvsra_vol, pvsra_avg_len)
float pvsra_value2 = pvsra_vol * (pvsra_hi - pvsra_lo)
float pvsra_hi_value2 = ta.highest(pvsra_value2, pvsra_avg_len)
bool pvsra_lvl2 = pvsra_vol >= pvsra_av * pvsra_lvl2_mult or (pvsra_use_spread_x_vol and pvsra_value2 >= pvsra_hi_value2)
bool pvsra_lvl1 = not pvsra_lvl2 and pvsra_vol >= pvsra_av * pvsra_lvl1_mult
bool pvsra_bull = pvsra_cl > pvsra_op

color pvsra_color = pvsra_bull ? (pvsra_lvl2 ? pvsra_bull_200 : pvsra_lvl1 ? pvsra_bull_150 : pvsra_bull_norm) : (pvsra_lvl2 ? pvsra_bear_200 : pvsra_lvl1 ? pvsra_bear_150 : pvsra_bear_norm)
bool pvsra_directional_long = pvsra_bull and (pvsra_lvl1 or pvsra_lvl2)
bool pvsra_directional_short = (not pvsra_bull) and (pvsra_lvl1 or pvsra_lvl2)

// ============================================================================
// DELTA ENGINE CALC
// ============================================================================
string delta_ltf_eff = delta_tf_mode == "Auto (chart aware)" ? f_auto_delta_ltf() : delta_ltf_manual
int delta_chart_sec = timeframe.in_seconds(timeframe.period)
int delta_ltf_sec = timeframe.in_seconds(delta_ltf_eff)
bool delta_ltf_valid = not na(delta_ltf_sec) and not na(delta_chart_sec) and delta_ltf_sec < delta_chart_sec
array<float> delta_c_arr = array.new_float()
array<float> delta_o_arr = array.new_float()
array<float> delta_v_arr = array.new_float()
if delta_enable and delta_ltf_valid
    delta_c_arr := request.security_lower_tf(syminfo.tickerid, delta_ltf_eff, close)
    delta_o_arr := request.security_lower_tf(syminfo.tickerid, delta_ltf_eff, open)
    delta_v_arr := request.security_lower_tf(syminfo.tickerid, delta_ltf_eff, volume)

float delta_bar = 0.0
if delta_enable
    if delta_ltf_valid
        int delta_arr_sz = array.size(delta_c_arr)
        if delta_arr_sz > 0
            for i = 0 to delta_arr_sz - 1
                float c = array.get(delta_c_arr, i)
                float o = array.get(delta_o_arr, i)
                float v = array.get(delta_v_arr, i)
                delta_bar += c >= o ? v : -v
        else
            delta_bar := close >= open ? volume : -volume
    else
        delta_bar := close >= open ? volume : -volume

float delta_ema = ta.ema(delta_bar, delta_smooth_len)

// ============================================================================
// MODULE 06 - SSL CHANNEL — COMPUTATION
// ============================================================================
float ssl_smaHigh = ta.sma(high, ssl_len)
float ssl_smaLow  = ta.sma(low,  ssl_len)
var int ssl_hlv = 0
ssl_hlv := close > ssl_smaHigh ? 1 : close < ssl_smaLow ? -1 : ssl_hlv[1]
float ssl_up   = ssl_hlv < 0 ? ssl_smaLow  : ssl_smaHigh
float ssl_down = ssl_hlv < 0 ? ssl_smaHigh : ssl_smaLow

bool ssl_long_state  = ssl_up > ssl_down
bool ssl_short_state = ssl_up < ssl_down
bool ssl_long_cross  = ssl_enable and ssl_long_state  and not ssl_long_state[1]
bool ssl_short_cross = ssl_enable and ssl_short_state and not ssl_short_state[1]

bool delta_flip_up = ta.crossover(delta_ema, 0.0)
bool delta_flip_dn = ta.crossunder(delta_ema, 0.0)
bool delta_had_neg_exhaust = ta.lowest(delta_ema, delta_exhaust_lookback)[1] <= -delta_exhaust_threshold
bool delta_had_pos_exhaust = ta.highest(delta_ema, delta_exhaust_lookback)[1] >= delta_exhaust_threshold

bool ssl_delta_ok_long  = not ssl_require_delta or not delta_enable or (ssl_use_exhaust ? (delta_flip_up and delta_had_neg_exhaust) : delta_ema > 0)
bool ssl_delta_ok_short = not ssl_require_delta or not delta_enable or (ssl_use_exhaust ? (delta_flip_dn and delta_had_pos_exhaust) : delta_ema < 0)

var int   ssl_pending_dir    = 0
var int   ssl_pending_bar    = na
var label ssl_pending_label  = na
var int   ssl_last_long_bar  = -99999
var int   ssl_last_short_bar = -99999
var int   ssl_last_dir       = 0

bool ssl_long_signal  = false
bool ssl_short_signal = false

bool ssl_cooldown_ok_long  = bar_index - ssl_last_long_bar  >= ssl_cooldown
bool ssl_cooldown_ok_short = bar_index - ssl_last_short_bar >= ssl_cooldown
bool ssl_alt_ok_long  = not ssl_alternate or ssl_last_dir != 1
bool ssl_alt_ok_short = not ssl_alternate or ssl_last_dir != -1

if ssl_enable
    if ssl_pending_dir != 0
        bool ssl_timeout   = bar_index - ssl_pending_bar >= ssl_expiry_bars
        bool ssl_flip_away = ssl_pending_dir == 1 ? ssl_short_cross : ssl_long_cross
        if ssl_pending_dir == 1 and ssl_delta_ok_long
            ssl_long_signal   := true
            label.delete(ssl_pending_label)
            ssl_pending_label := na
            ssl_pending_dir   := 0
        else if ssl_pending_dir == -1 and ssl_delta_ok_short
            ssl_short_signal  := true
            label.delete(ssl_pending_label)
            ssl_pending_label := na
            ssl_pending_dir   := 0
        else if ssl_timeout or ssl_flip_away
            label.delete(ssl_pending_label)
            ssl_pending_label := na
            ssl_pending_dir   := 0
        else if ssl_show_pending and not na(ssl_pending_label)
            bool blink_on = not ssl_pending_flash or bar_index % 2 == 0
            label.set_color(ssl_pending_label, ssl_pending_dir == 1 ? (blink_on ? ssl_pending_long_color : color.new(ssl_pending_long_color, 78)) : (blink_on ? ssl_pending_short_color : color.new(ssl_pending_short_color, 78)))
    if ssl_pending_dir == 0
        if ssl_long_cross and ssl_cooldown_ok_long and ssl_alt_ok_long
            ssl_pending_dir  := 1
            ssl_pending_bar  := bar_index
            if ssl_show_pending
                ssl_pending_label := label.new(bar_index, low, "long?", style=label.style_label_up, color=ssl_pending_long_color, textcolor=color.white, size=size.tiny)
        else if ssl_short_cross and ssl_cooldown_ok_short and ssl_alt_ok_short
            ssl_pending_dir  := -1
            ssl_pending_bar  := bar_index
            if ssl_show_pending
                ssl_pending_label := label.new(bar_index, high, "short?", style=label.style_label_down, color=ssl_pending_short_color, textcolor=color.white, size=size.tiny)

if ssl_long_signal
    ssl_last_long_bar := bar_index
    ssl_last_dir      := 1
if ssl_short_signal
    ssl_last_short_bar := bar_index
    ssl_last_dir       := -1

// ============================================================================
// MODULE 07 - DELTA DISPLAY — COMPUTATION
// ============================================================================

// varip variables persist across intrabar ticks (reset via barstate.isnew).
// On historical bars, direction is approximated by close vs open.
// On realtime bars, direction tracks tick-by-tick price movement.

varip bool  dd_dvUp      = false
varip bool  dd_dvDn      = false
varip float dd_prevClose = 0.0
varip float dd_deltaVol  = 0.0
varip float dd_lastVol   = 0.0
varip int   dd_ticksUp   = 0
varip int   dd_ticksDn   = 0
varip float[] dd_wCloses = array.new_float()
varip float[] dd_volumes = array.new_float()

if dd_enable
    if barstate.isnew
        dd_deltaVol  := 0.0
        dd_lastVol   := 0.0
        dd_ticksUp   := 0
        dd_ticksDn   := 0
        dd_prevClose := open
        array.clear(dd_wCloses)
        array.clear(dd_volumes)

    // Determine tick direction
    if barstate.isrealtime
        bool _flat = close == dd_prevClose
        dd_dvUp := _flat ? dd_dvUp : close > dd_prevClose
        dd_dvDn := _flat ? dd_dvDn : close < dd_prevClose
    else
        bool _hist_flat = close == open
        dd_dvUp := not _hist_flat ? close > open : close == dd_prevClose ? dd_dvUp : close > dd_prevClose
        dd_dvDn := not dd_dvUp
    dd_prevClose := close

    float _newVol = math.max(0.0, nz(volume) - dd_lastVol)
    if dd_dvUp
        dd_deltaVol += _newVol
        dd_ticksUp  += 1
    else if dd_dvDn
        dd_deltaVol -= _newVol
        dd_ticksDn  += 1

    // POC: volume-weighted average of per-tick close prices
    array.push(dd_wCloses, close * _newVol)
    array.push(dd_volumes, _newVol)

    dd_lastVol := nz(volume)

// ————— Derived values (computed every bar/tick regardless of dd_enable for clean na handling)
float dd_totalVol   = nz(volume)
float dd_dvPct      = dd_enable and dd_totalVol > 0 ? 100.0 * math.abs(dd_deltaVol) / dd_totalVol : 0.0
float dd_deltaTicks = float(dd_ticksUp - dd_ticksDn)
float dd_totalTicks = float(dd_ticksUp + dd_ticksDn)
float dd_dtPct      = dd_enable and dd_totalTicks > 0 ? 100.0 * math.abs(dd_deltaTicks) / dd_totalTicks : 0.0

// POC price
float dd_poc = na
if dd_enable and array.size(dd_volumes) > 0
    float _sumWC = 0.0
    float _sumV  = 0.0
    for i = 0 to array.size(dd_volumes) - 1
        _sumWC += array.get(dd_wCloses, i)
        _sumV  += array.get(dd_volumes, i)
    dd_poc := _sumV > 0.0 ? _sumWC / _sumV : close

// ————— Bar direction (robust: handles flat bars by referencing previous close)
var bool dd_barUp = false
var bool dd_barDn = false
bool _dd_flat     = close == open
bool _dd_noChange = close == close[1]
dd_barUp := close > open or (_dd_flat and (close > nz(close[1], close) or (_dd_noChange and dd_barUp)))
dd_barDn := close < open or (_dd_flat and (close < nz(close[1], close) or (_dd_noChange and dd_barDn)))

// ————— POC direction (for divergence check)
bool dd_pocHigher = not na(dd_poc) and not na(dd_poc[1]) and dd_poc > dd_poc[1]
bool dd_pocLower  = not na(dd_poc) and not na(dd_poc[1]) and dd_poc < dd_poc[1]

// ————— Divergence flags
bool dd_dvDiv  = dd_enable and dd_show_div and ((dd_deltaVol  > 0 and dd_barDn) or (dd_deltaVol  < 0 and dd_barUp))
bool dd_dtDiv  = dd_enable and dd_show_div and ((dd_deltaTicks > 0 and dd_barDn) or (dd_deltaTicks < 0 and dd_barUp))
bool dd_pocDiv = dd_enable and dd_poc_div_on and ((dd_pocHigher and close < open) or (dd_pocLower and close > open))

// ————— Arrow conditions (comparing consecutive confirmed bar values)
bool dd_dvHigher = dd_deltaVol   > dd_deltaVol[1]   and dd_deltaVol   > 0 and dd_deltaVol[1]   > 0
bool dd_dvLower  = dd_deltaVol   < dd_deltaVol[1]   and dd_deltaVol   < 0 and dd_deltaVol[1]   < 0
bool dd_dtHigher = dd_deltaTicks > dd_deltaTicks[1]  and dd_deltaTicks > 0 and dd_deltaTicks[1] > 0
bool dd_dtLower  = dd_deltaTicks < dd_deltaTicks[1]  and dd_deltaTicks < 0 and dd_deltaTicks[1] < 0

// ————— Label colors
color dd_cLabelDV = dd_dvDiv ? dd_c_dv_div : dd_deltaVol  >= 0 ? dd_c_dv_bull : dd_c_dv_bear
color dd_cLabelDT = dd_dtDiv ? dd_c_dt_div : dd_deltaTicks >= 0 ? dd_c_dt_bull : dd_c_dt_bear
color dd_cPoc     = dd_pocDiv ? dd_c_poc_div : dd_pocHigher ? dd_c_poc_bull : dd_pocLower ? dd_c_poc_bear : dd_c_poc_neu

// ————— Label text builders
string DD_SEP    = "⸺\n"
string _dvPrec   = "0" + (dd_dv_prec == 0 ? "" : ".") + str.repeat("0", dd_dv_prec)
string _dvArrow  = dd_dv_arrows ? (dd_dvHigher ? "▲" : dd_dvLower ? "▼" : "") : ""
string _dtArrow  = dd_dt_arrows ? (dd_dtHigher ? "▲" : dd_dtLower ? "▼" : "") : ""
string _dvStr    = dd_show_dv      ? str.tostring(dd_deltaVol,   _dvPrec) + _dvArrow + "\n" : ""
string _tvStr    = dd_show_tot_vol ? (dd_dv_seps ? DD_SEP : "") + str.tostring(dd_totalVol, _dvPrec) + "\n" : ""
string _dvPctStr = dd_show_dv_pct  ? (dd_dv_seps and dd_show_tot_vol ? "=\n" : "") + str.tostring(dd_dvPct, "#") + "%" : ""
string dd_lblDV  = _dvStr + _tvStr + _dvPctStr
string _dtStr    = dd_show_dt      ? str.tostring(dd_deltaTicks, "#") + _dtArrow + "\n" : ""
string _ttStr    = dd_show_tot_tck ? (dd_dt_seps ? DD_SEP : "") + str.tostring(dd_totalTicks, "#") + "\n" : ""
string _dtPctStr = dd_show_dt_pct  ? (dd_dt_seps and dd_show_tot_tck ? "=\n" : "") + str.tostring(dd_dtPct, "#") + "%" : ""
string dd_lblDT  = _dtStr + _ttStr + _dtPctStr

// ============================================================================
// MODULE 07 - DELTA DISPLAY — VISUALS
// ============================================================================

// Realtime floating labels (updated every tick on the current bar)
var label dd_rt_lbl_dv = label.new(na, na, "", style=label.style_label_up,   color=color(na), textcolor=dd_c_dv_bull, size=dd_txt_size)
var label dd_rt_lbl_dt = label.new(na, na, "", style=label.style_label_down, color=color(na), textcolor=dd_c_dt_bull, size=dd_txt_size)
var line  dd_rt_poc    = line.new(na, na, na, na, width=2)

if dd_enable
    label.set_xy(dd_rt_lbl_dv, bar_index, low)
    label.set_text(dd_rt_lbl_dv, dd_lblDV)
    label.set_textcolor(dd_rt_lbl_dv, dd_cLabelDV)
    label.set_size(dd_rt_lbl_dv, dd_txt_size)

    label.set_xy(dd_rt_lbl_dt, bar_index, high)
    label.set_text(dd_rt_lbl_dt, dd_lblDT)
    label.set_textcolor(dd_rt_lbl_dt, dd_cLabelDT)
    label.set_size(dd_rt_lbl_dt, dd_txt_size)

// Realtime floating POC line (updated every tick)
if dd_enable and dd_show_poc and not na(dd_poc)
    line.set_xy1(dd_rt_poc, bar_index - 1, dd_poc)
    line.set_xy2(dd_rt_poc, bar_index,     dd_poc)
    line.set_color(dd_rt_poc, dd_cPoc)
    line.set_width(dd_rt_poc, dd_poc_w)

// On bar close (realtime confirmed): commit labels and POC to history arrays
if dd_enable and barstate.isrealtime and barstate.isconfirmed
    var label[] dd_hist_dv  = array.new_label(dd_visible)
    var label[] dd_hist_dt  = array.new_label(dd_visible)
    var line[]  dd_hist_poc = array.new_line(dd_visible)

    label.delete(array.shift(dd_hist_dv))
    array.push(dd_hist_dv, label.new(bar_index, low,  dd_lblDV,
         style=label.style_label_up,   color=color(na), textcolor=dd_cLabelDV, size=dd_txt_size))

    label.delete(array.shift(dd_hist_dt))
    array.push(dd_hist_dt, label.new(bar_index, high, dd_lblDT,
         style=label.style_label_down, color=color(na), textcolor=dd_cLabelDT, size=dd_txt_size))

    if dd_show_poc and not na(dd_poc)
        line.delete(array.shift(dd_hist_poc))
        array.push(dd_hist_poc, line.new(bar_index - 1, dd_poc, bar_index, dd_poc,
             color=dd_cPoc, width=dd_poc_w))

// ============================================================================
// VISUALS - VWAP
// ============================================================================
plot(vwap_enable ? vwap_value : na, "VWAP", color=vwap_line_color, linewidth=vwap_line_width, offset=vwap_offset)

b1_up = plot(vwap_enable and vwap_show_band_1 ? vwap_upper_1 : na, "VWAP Upper #1", color=vwap_b1_up_color, offset=vwap_offset)
b1_dn = plot(vwap_enable and vwap_show_band_1 ? vwap_lower_1 : na, "VWAP Lower #1", color=vwap_b1_dn_color, offset=vwap_offset)
fill(b1_up, b1_dn, color=vwap_enable and vwap_show_band_1 ? vwap_fill_b1 : na, title="VWAP Fill #1")

b2_up = plot(vwap_enable and vwap_show_band_2 ? vwap_upper_2 : na, "VWAP Upper #2", color=vwap_b2_up_color, offset=vwap_offset)
b2_dn = plot(vwap_enable and vwap_show_band_2 ? vwap_lower_2 : na, "VWAP Lower #2", color=vwap_b2_dn_color, offset=vwap_offset)
fill(b2_up, b2_dn, color=vwap_enable and vwap_show_band_2 ? vwap_fill_b2 : na, title="VWAP Fill #2")

b3_up = plot(vwap_enable and vwap_show_band_3 ? vwap_upper_3 : na, "VWAP Upper #3", color=vwap_b3_up_color, offset=vwap_offset)
b3_dn = plot(vwap_enable and vwap_show_band_3 ? vwap_lower_3 : na, "VWAP Lower #3", color=vwap_b3_dn_color, offset=vwap_offset)
fill(b3_up, b3_dn, color=vwap_enable and vwap_show_band_3 ? vwap_fill_b3 : na, title="VWAP Fill #3")

st_up_top = plot(vwap_enable and vwap_show_state_cloud and vwap_state == STATE_UP ? vwap_up_outer : na, "State UP Top", color=color.new(color.green, 100), style=vwap_cloud_step ? plot.style_stepline : plot.style_line)
st_up_bot = plot(vwap_enable and vwap_show_state_cloud and vwap_state == STATE_UP ? vwap_upper_1 : na, "State UP Bottom", color=color.new(color.green, 100), style=vwap_cloud_step ? plot.style_stepline : plot.style_line)
fill(st_up_top, st_up_bot, color=vwap_cloud_up, title="State Cloud UP")

st_dn_top = plot(vwap_enable and vwap_show_state_cloud and vwap_state == STATE_DN ? vwap_lower_1 : na, "State DOWN Top", color=color.new(color.red, 100), style=vwap_cloud_step ? plot.style_stepline : plot.style_line)
st_dn_bot = plot(vwap_enable and vwap_show_state_cloud and vwap_state == STATE_DN ? vwap_dn_outer : na, "State DOWN Bottom", color=color.new(color.red, 100), style=vwap_cloud_step ? plot.style_stepline : plot.style_line)
fill(st_dn_top, st_dn_bot, color=vwap_cloud_dn, title="State Cloud DOWN")

st_bal_top = plot(vwap_enable and vwap_show_state_cloud and vwap_state == STATE_BAL ? vwap_upper_1 : na, "State BAL Top", color=color.new(color.blue, 100), style=vwap_cloud_step ? plot.style_stepline : plot.style_line)
st_bal_bot = plot(vwap_enable and vwap_show_state_cloud and vwap_state == STATE_BAL ? vwap_lower_1 : na, "State BAL Bottom", color=color.new(color.blue, 100), style=vwap_cloud_step ? plot.style_stepline : plot.style_line)
fill(st_bal_top, st_bal_bot, color=vwap_cloud_bal, title="State Cloud BAL")

bgcolor(vwap_enable and vwap_show_state_bg ? (vwap_state == STATE_UP ? vwap_bg_up : vwap_state == STATE_DN ? vwap_bg_dn : na) : na, title="VWAP State BG")

plotshape(vwap_enable and vwap_show_failed_breakout and vwap_failed_breakout_up, title="Failed Breakout Up", style=shape.xcross, location=location.abovebar, color=vwap_failed_up_color, size=size.tiny, text="x")
plotshape(vwap_enable and vwap_show_failed_breakout and vwap_failed_breakout_dn, title="Failed Breakout Down", style=shape.xcross, location=location.belowbar, color=vwap_failed_dn_color, size=size.tiny, text="x")
plotshape(vwap_enable and vwap_show_return_to_vwap and vwap_cross_up, title="Return To VWAP Up", style=shape.circle, location=location.belowbar, color=vwap_retest_color, size=size.tiny, text="R")
plotshape(vwap_enable and vwap_show_return_to_vwap and vwap_cross_dn, title="Return To VWAP Down", style=shape.circle, location=location.abovebar, color=vwap_retest_color, size=size.tiny, text="R")

// ============================================================================
// VISUALS - VP
// ============================================================================
var array<polyline> vp_all_polylines = array.new<polyline>()
var polyline vp_active_buy_poly    = na
var polyline vp_active_sell_poly   = na
var polyline vp_active_va_buy_poly = na
var polyline vp_active_va_sel_poly = na
var int vp_active_start_bar = na
var VPPrfDisp vp_active_mode = VPPrfDisp.upDn

if vp_enable and vp_show_profile and not na(vp_start_bar) and not na(vp_end_bar) and vp_end_bar >= vp_start_bar and vp_draw_period
    float vp_max_vol = 0.0
    int vp_bins = vp_flash_profile.getBins()

    for i = 0 to vp_bins - 1
        float b_vol = vp_flash_profile.getBinBuyVol(i)
        float s_vol = vp_flash_profile.getBinSellVol(i)
        float cur_vol = vp_volume_mode == VPPrfDisp.delta ? math.abs(b_vol - s_vol) : b_vol + s_vol
        vp_max_vol := math.max(vp_max_vol, cur_vol)

    if vp_max_vol > 0 and vp_bins > 0
        float bar_width = float(vp_end_time - vp_start_time) * vp_prof_width_pct / 100.0
        int x_base = vp_prof_side == VPProfSide.left ? vp_start_time : vp_end_time
        float direction = vp_prof_side == VPProfSide.left ? 1.0 : -1.0

        bool same_period = not na(vp_active_start_bar) and vp_active_start_bar == vp_start_bar and vp_active_mode == vp_volume_mode
        [_, _draw_vah, _, _draw_val] = vp_flash_profile.getValueArea()
        float draw_val = nz(_draw_val, 1.0e10)
        float draw_vah = nz(_draw_vah, -1.0e10)

        int req_poly = vp_volume_mode == VPPrfDisp.upDn ? 4 : vp_volume_mode == VPPrfDisp.total ? 1 : 2

        array<chart.point> b_points    = array.new<chart.point>()
        array<chart.point> s_points    = array.new<chart.point>()
        array<chart.point> va_b_points = array.new<chart.point>()
        array<chart.point> va_s_points = array.new<chart.point>()
        [first_up, first_lo] = vp_flash_profile.getBinBnds(0)
        float y_first = first_lo + (first_up - first_lo) * 0.025
        [last_up, last_lo] = vp_flash_profile.getBinBnds(vp_bins - 1)
        float y_last = last_up - (last_up - last_lo) * 0.025

        if vp_volume_mode == VPPrfDisp.upDn
            // ── base buy (full profile, outside-VA color) ──────────────────
            array.push(b_points, chart.point.from_time(x_base, y_first))
            for i = 0 to vp_bins - 1
                [bin_up, bin_lo] = vp_flash_profile.getBinBnds(i)
                float buy_vol   = vp_flash_profile.getBinBuyVol(i)
                float buy_width = bar_width * (buy_vol / vp_max_vol)
                float x_end     = x_base + direction * buy_width
                array.push(b_points, chart.point.from_time(int(x_end), bin_lo))
                array.push(b_points, chart.point.from_time(int(x_end), bin_up))
            array.push(b_points, chart.point.from_time(x_base, y_last))
            // ── base sell ──────────────────────────────────────────────────
            for i = 0 to vp_bins - 1
                [bin_up, bin_lo] = vp_flash_profile.getBinBnds(i)
                float buy_vol    = vp_flash_profile.getBinBuyVol(i)
                float sell_vol   = vp_flash_profile.getBinSellVol(i)
                float buy_width  = bar_width * (buy_vol  / vp_max_vol)
                float sell_width = bar_width * (sell_vol / vp_max_vol)
                float sell_x_start = x_base + direction * buy_width
                float sell_x_end   = sell_x_start + direction * sell_width
                array.push(s_points, chart.point.from_time(int(sell_x_end), bin_lo))
                array.push(s_points, chart.point.from_time(int(sell_x_end), bin_up))
            for i = vp_bins - 1 to 0
                [bin_up, bin_lo] = vp_flash_profile.getBinBnds(i)
                float buy_vol    = vp_flash_profile.getBinBuyVol(i)
                float buy_width  = bar_width * (buy_vol / vp_max_vol)
                float sell_x_start = x_base + direction * buy_width
                array.push(s_points, chart.point.from_time(int(sell_x_start), bin_up))
                array.push(s_points, chart.point.from_time(int(sell_x_start), bin_lo))
            // ── VA overlay: find range, then build staircases ──────────────
            int va_first = -1
            int va_last  = -1
            for i = 0 to vp_bins - 1
                [bin_up, bin_lo] = vp_flash_profile.getBinBnds(i)
                if bin_up > draw_val and bin_lo < draw_vah
                    if va_first < 0
                        va_first := i
                    va_last := i
            if va_first >= 0
                [_fup, _flo] = vp_flash_profile.getBinBnds(va_first)
                [_lup, _llo] = vp_flash_profile.getBinBnds(va_last)
                float va_y_first = _flo + (_fup - _flo) * 0.025
                float va_y_last  = _lup - (_lup - _llo) * 0.025
                // VA buy staircase (same pattern as base, VA bins only)
                array.push(va_b_points, chart.point.from_time(x_base, va_y_first))
                for i = va_first to va_last
                    [bin_up, bin_lo] = vp_flash_profile.getBinBnds(i)
                    float buy_vol   = vp_flash_profile.getBinBuyVol(i)
                    float buy_width = bar_width * (buy_vol / vp_max_vol)
                    float x_end     = x_base + direction * buy_width
                    array.push(va_b_points, chart.point.from_time(int(x_end), bin_lo))
                    array.push(va_b_points, chart.point.from_time(int(x_end), bin_up))
                array.push(va_b_points, chart.point.from_time(x_base, va_y_last))
                // VA sell staircase: forward (outer edge) then backward (buy edge)
                for i = va_first to va_last
                    [bin_up, bin_lo] = vp_flash_profile.getBinBnds(i)
                    float buy_vol    = vp_flash_profile.getBinBuyVol(i)
                    float sell_vol   = vp_flash_profile.getBinSellVol(i)
                    float buy_width  = bar_width * (buy_vol  / vp_max_vol)
                    float sell_width = bar_width * (sell_vol / vp_max_vol)
                    float sx0 = x_base + direction * buy_width
                    float sx1 = sx0    + direction * sell_width
                    array.push(va_s_points, chart.point.from_time(int(sx1), bin_lo))
                    array.push(va_s_points, chart.point.from_time(int(sx1), bin_up))
                int n_va = va_last - va_first
                for j = 0 to n_va
                    int k = va_last - j
                    [bin_up, bin_lo] = vp_flash_profile.getBinBnds(k)
                    float buy_vol   = vp_flash_profile.getBinBuyVol(k)
                    float buy_width = bar_width * (buy_vol / vp_max_vol)
                    float sx0 = x_base + direction * buy_width
                    array.push(va_s_points, chart.point.from_time(int(sx0), bin_up))
                    array.push(va_s_points, chart.point.from_time(int(sx0), bin_lo))

        else if vp_volume_mode == VPPrfDisp.total
            array.push(b_points, chart.point.from_time(x_base, y_first))
            for i = 0 to vp_bins - 1
                [bin_up, bin_lo] = vp_flash_profile.getBinBnds(i)
                float total_vol   = vp_flash_profile.getBinBuyVol(i) + vp_flash_profile.getBinSellVol(i)
                float total_width = bar_width * (total_vol / vp_max_vol)
                float x_end       = x_base + direction * total_width
                array.push(b_points, chart.point.from_time(int(x_end), bin_lo))
                array.push(b_points, chart.point.from_time(int(x_end), bin_up))
            array.push(b_points, chart.point.from_time(x_base, y_last))
        else
            array.push(b_points, chart.point.from_time(x_base, y_first))
            array.push(s_points, chart.point.from_time(x_base, y_first))
            for i = 0 to vp_bins - 1
                [bin_up, bin_lo] = vp_flash_profile.getBinBnds(i)
                float buy_vol    = vp_flash_profile.getBinBuyVol(i)
                float sell_vol   = vp_flash_profile.getBinSellVol(i)
                float delta_vol  = buy_vol - sell_vol
                float delta_width = bar_width * (math.abs(delta_vol) / vp_max_vol)
                if delta_vol >= 0
                    float x_end = x_base + direction * delta_width
                    array.push(b_points, chart.point.from_time(int(x_end), bin_lo))
                    array.push(b_points, chart.point.from_time(int(x_end), bin_up))
                    array.push(s_points, chart.point.from_time(x_base, bin_lo))
                    array.push(s_points, chart.point.from_time(x_base, bin_up))
                else
                    float x_end = x_base - direction * delta_width
                    array.push(s_points, chart.point.from_time(int(x_end), bin_lo))
                    array.push(s_points, chart.point.from_time(int(x_end), bin_up))
                    array.push(b_points, chart.point.from_time(x_base, bin_lo))
                    array.push(b_points, chart.point.from_time(x_base, bin_up))
            array.push(b_points, chart.point.from_time(x_base, y_last))
            array.push(s_points, chart.point.from_time(x_base, y_last))

        if math.max(array.size(b_points), array.size(s_points)) > VP_MAX_POINTS
            runtime.error("PVP polyline exceeded point limit. Reduce Row Size.")

        if same_period
            polyline.delete(vp_active_buy_poly)
            polyline.delete(vp_active_sell_poly)
            polyline.delete(vp_active_va_buy_poly)
            polyline.delete(vp_active_va_sel_poly)
            vp_active_buy_poly    := na
            vp_active_sell_poly   := na
            vp_active_va_buy_poly := na
            vp_active_va_sel_poly := na
        else
            if not na(vp_active_buy_poly)
                array.push(vp_all_polylines, vp_active_buy_poly)
            if not na(vp_active_sell_poly)
                array.push(vp_all_polylines, vp_active_sell_poly)
            if not na(vp_active_va_buy_poly)
                array.push(vp_all_polylines, vp_active_va_buy_poly)
            if not na(vp_active_va_sel_poly)
                array.push(vp_all_polylines, vp_active_va_sel_poly)
            vp_active_buy_poly    := na
            vp_active_sell_poly   := na
            vp_active_va_buy_poly := na
            vp_active_va_sel_poly := na
            while array.size(vp_all_polylines) > 96 - req_poly
                polyline.delete(array.shift(vp_all_polylines))

        // Base layer: full histogram in outside-VA colors
        if array.size(b_points) > 2
            vp_active_buy_poly := polyline.new(points=b_points, closed=true, xloc=xloc.bar_time, line_color=vp_hist_box_color, fill_color=vp_buy_color, line_style=line.style_solid, line_width=1)
        if array.size(s_points) > 2
            vp_active_sell_poly := polyline.new(points=s_points, closed=true, xloc=xloc.bar_time, line_color=vp_hist_box_color, fill_color=vp_sell_color, line_style=line.style_solid, line_width=1)
        // VA overlay: value area staircase in brighter colors (drawn on top)
        color va_no_border = color.new(color.black, 100)
        if array.size(va_b_points) > 2
            vp_active_va_buy_poly := polyline.new(points=va_b_points, closed=true, xloc=xloc.bar_time, line_color=va_no_border, fill_color=vp_va_up_color, line_style=line.style_solid, line_width=1)
        if array.size(va_s_points) > 2
            vp_active_va_sel_poly := polyline.new(points=va_s_points, closed=true, xloc=xloc.bar_time, line_color=va_no_border, fill_color=vp_va_dn_color, line_style=line.style_solid, line_width=1)

        vp_active_start_bar := vp_start_bar
        vp_active_mode := vp_volume_mode
else if (not vp_enable or not vp_show_profile) and (array.size(vp_all_polylines) > 0 or not na(vp_active_buy_poly) or not na(vp_active_sell_poly))
    while array.size(vp_all_polylines) > 0
        polyline.delete(array.shift(vp_all_polylines))
    polyline.delete(vp_active_buy_poly)
    polyline.delete(vp_active_sell_poly)
    polyline.delete(vp_active_va_buy_poly)
    polyline.delete(vp_active_va_sel_poly)
    vp_active_buy_poly    := na
    vp_active_sell_poly   := na
    vp_active_va_buy_poly := na
    vp_active_va_sel_poly := na
    vp_active_start_bar := na

var line vp_line_poc = na
var line vp_line_vah = na
var line vp_line_val = na
var line vp_line_dev_poc = na
var line vp_line_dev_vah = na
var line vp_line_dev_val = na

if barstate.islast
    bool vp_line_ready = vp_enable and vp_draw_period and not na(vp_start_bar) and not na(vp_end_bar) and vp_end_bar >= vp_start_bar
    int vp_x1 = vp_start_bar
    int vp_x2 = vp_line_ready ? (vp_end_bar > vp_start_bar ? vp_end_bar : vp_start_bar + 1) : na
    int vp_dev_x1 = vp_line_ready ? math.max(vp_x2 - 2, vp_x1) : na
    int vp_dev_x2 = vp_line_ready ? vp_x2 + 1 : na

    if vp_line_ready and vp_show_poc_line and not na(vp_cur_poc)
        line.delete(vp_line_poc)
        vp_line_poc := line.new(vp_x1, vp_cur_poc, vp_x2, vp_cur_poc, xloc=xloc.bar_index, extend=extend.none, color=vp_poc_color, width=vp_level_width, style=f_vp_line_style(vp_poc_style))
    else
        line.delete(vp_line_poc)
        vp_line_poc := na

    if vp_line_ready and vp_show_vah_line and not na(vp_cur_vah)
        line.delete(vp_line_vah)
        vp_line_vah := line.new(vp_x1, vp_cur_vah, vp_x2, vp_cur_vah, xloc=xloc.bar_index, extend=extend.none, color=vp_vah_color, width=vp_level_width, style=f_vp_line_style(vp_vah_style))
    else
        line.delete(vp_line_vah)
        vp_line_vah := na

    if vp_line_ready and vp_show_val_line and not na(vp_cur_val)
        line.delete(vp_line_val)
        vp_line_val := line.new(vp_x1, vp_cur_val, vp_x2, vp_cur_val, xloc=xloc.bar_index, extend=extend.none, color=vp_val_color, width=vp_level_width, style=f_vp_line_style(vp_val_style))
    else
        line.delete(vp_line_val)
        vp_line_val := na

    if vp_line_ready and vp_show_dev_poc and not na(vp_cur_poc)
        line.delete(vp_line_dev_poc)
        vp_line_dev_poc := line.new(vp_dev_x1, vp_cur_poc, vp_dev_x2, vp_cur_poc, xloc=xloc.bar_index, extend=extend.right, color=vp_dev_poc_color, width=1, style=line.style_solid)
    else
        line.delete(vp_line_dev_poc)
        vp_line_dev_poc := na

    if vp_line_ready and vp_show_dev_va and not na(vp_cur_vah)
        line.delete(vp_line_dev_vah)
        vp_line_dev_vah := line.new(vp_dev_x1, vp_cur_vah, vp_dev_x2, vp_cur_vah, xloc=xloc.bar_index, extend=extend.right, color=vp_dev_va_color, width=1, style=line.style_solid)
    else
        line.delete(vp_line_dev_vah)
        vp_line_dev_vah := na

    if vp_line_ready and vp_show_dev_va and not na(vp_cur_val)
        line.delete(vp_line_dev_val)
        vp_line_dev_val := line.new(vp_dev_x1, vp_cur_val, vp_dev_x2, vp_cur_val, xloc=xloc.bar_index, extend=extend.right, color=vp_dev_va_color, width=1, style=line.style_solid)
    else
        line.delete(vp_line_dev_val)
        vp_line_dev_val := na

// ============================================================================
// VISUALS - VP HISTORICAL LEVEL LINES (POC / VAH / VAL per completed period)
// ============================================================================
var array<line> vp_hist_poc_lines = array.new<line>()
var array<line> vp_hist_vah_lines = array.new<line>()
var array<line> vp_hist_val_lines = array.new<line>()

if vp_enable and vp_new_period and vp_draw_period and not na(vp_prev_start_bar) and not na(vp_prev_end_bar) and not na(vp_prev_poc)
    int hx1 = vp_prev_start_bar
    int hx2 = vp_prev_end_bar
    if vp_show_poc_line
        while array.size(vp_hist_poc_lines) >= VP_MAX_LEVEL_LINES_PER_TYPE
            line.delete(array.shift(vp_hist_poc_lines))
        array.push(vp_hist_poc_lines, line.new(hx1, vp_prev_poc, hx2, vp_prev_poc, xloc=xloc.bar_index, extend=extend.none, color=vp_poc_color, width=vp_level_width, style=f_vp_line_style(vp_poc_style)))
    if vp_show_vah_line and not na(vp_prev_vah)
        while array.size(vp_hist_vah_lines) >= VP_MAX_LEVEL_LINES_PER_TYPE
            line.delete(array.shift(vp_hist_vah_lines))
        array.push(vp_hist_vah_lines, line.new(hx1, vp_prev_vah, hx2, vp_prev_vah, xloc=xloc.bar_index, extend=extend.none, color=vp_vah_color, width=vp_level_width, style=f_vp_line_style(vp_vah_style)))
    if vp_show_val_line and not na(vp_prev_val)
        while array.size(vp_hist_val_lines) >= VP_MAX_LEVEL_LINES_PER_TYPE
            line.delete(array.shift(vp_hist_val_lines))
        array.push(vp_hist_val_lines, line.new(hx1, vp_prev_val, hx2, vp_prev_val, xloc=xloc.bar_index, extend=extend.none, color=vp_val_color, width=vp_level_width, style=f_vp_line_style(vp_val_style)))

else if not vp_enable
    while array.size(vp_hist_poc_lines) > 0
        line.delete(array.shift(vp_hist_poc_lines))
    while array.size(vp_hist_vah_lines) > 0
        line.delete(array.shift(vp_hist_vah_lines))
    while array.size(vp_hist_val_lines) > 0
        line.delete(array.shift(vp_hist_val_lines))

// ============================================================================

// ============================================================================
// VISUALS - PVSRA
// ============================================================================
barcolor(pvsra_enable and pvsra_override_candles ? pvsra_color : na, title="PVSRA Bar Color")

// ============================================================================
// VISUALS - DELTA FLIP MARKERS
// ============================================================================
plot(delta_enable ? delta_bar : na, "Delta Bar (Data Window)", color=color.new(color.white, 100), display=display.data_window)
plot(delta_enable ? delta_ema : na, "Delta EMA (Data Window)", color=color.new(color.white, 100), display=display.data_window)

plotshape(delta_enable and delta_show_flip_markers and delta_flip_up, title="Delta Flip Up",   style=shape.triangleup,   location=location.belowbar, color=delta_flip_up_color, size=size.tiny)
plotshape(delta_enable and delta_show_flip_markers and delta_flip_dn, title="Delta Flip Down", style=shape.triangledown, location=location.abovebar, color=delta_flip_dn_color, size=size.tiny)

// ============================================================================
// VISUALS - SSL SIGNALS
// ============================================================================
plot(ssl_enable and ssl_show_lines ? ssl_up   : na, "SSL Up",   color=ssl_line_up_color, linewidth=1)
plot(ssl_enable and ssl_show_lines ? ssl_down : na, "SSL Down", color=ssl_line_dn_color, linewidth=1)

plotshape(ssl_enable and ssl_show_labels and ssl_long_signal,  title="SSL Long",  style=shape.labelup,   location=location.belowbar, color=ssl_long_color,  textcolor=color.white, text="long")
plotshape(ssl_enable and ssl_show_labels and ssl_short_signal, title="SSL Short", style=shape.labeldown, location=location.abovebar, color=ssl_short_color, textcolor=color.white, text="short")

// ============================================================================
// MODULE 08 — HTF CANDLE VP — TRACKING VARS
// ============================================================================
var float htf_c1_rtH = na
var float htf_c1_rtL = na
var float htf_c1_rtO = na
var int   htf_c1_rtS = na
var array<float> htf_c1_aH = array.new_float()
var array<float> htf_c1_aL = array.new_float()
var array<float> htf_c1_aO = array.new_float()
var array<float> htf_c1_aC = array.new_float()
var array<int>   htf_c1_aS = array.new_int()
var array<int>   htf_c1_aE = array.new_int()

var float htf_c2_rtH = na
var float htf_c2_rtL = na
var float htf_c2_rtO = na
var int   htf_c2_rtS = na
var array<float> htf_c2_aH = array.new_float()
var array<float> htf_c2_aL = array.new_float()
var array<float> htf_c2_aO = array.new_float()
var array<float> htf_c2_aC = array.new_float()
var array<int>   htf_c2_aS = array.new_int()
var array<int>   htf_c2_aE = array.new_int()

var float htf_c3_rtH = na
var float htf_c3_rtL = na
var float htf_c3_rtO = na
var int   htf_c3_rtS = na
var array<float> htf_c3_aH = array.new_float()
var array<float> htf_c3_aL = array.new_float()
var array<float> htf_c3_aO = array.new_float()
var array<float> htf_c3_aC = array.new_float()
var array<int>   htf_c3_aS = array.new_int()
var array<int>   htf_c3_aE = array.new_int()

var array<box>   htf_c1_boxes  = array.new<box>()
var array<line>  htf_c1_lines  = array.new<line>()
var array<label> htf_c1_labels = array.new<label>()
var array<box>   htf_c2_boxes  = array.new<box>()
var array<line>  htf_c2_lines  = array.new<line>()
var array<label> htf_c2_labels = array.new<label>()
var array<box>   htf_c3_boxes  = array.new<box>()
var array<line>  htf_c3_lines  = array.new<line>()
var array<label> htf_c3_labels = array.new<label>()

float htf_atr200 = ta.atr(200)

// ============================================================================
// MODULE 08 — HTF CANDLE VP — PER-BAR TRACKING
// ============================================================================
if htf_enable and htf_c1_on
    if na(htf_c1_rtS)
        htf_c1_rtH := high
        htf_c1_rtL := low
        htf_c1_rtO := open
        htf_c1_rtS := bar_index
    if timeframe.change(htf_c1_tf)
        htf_c1_aO.push(htf_c1_rtO)
        htf_c1_aC.push(close[1])
        htf_c1_aH.push(htf_c1_rtH)
        htf_c1_aL.push(htf_c1_rtL)
        htf_c1_aS.push(htf_c1_rtS)
        htf_c1_aE.push(bar_index)
        htf_c1_rtH := high
        htf_c1_rtL := low
        htf_c1_rtO := open
        htf_c1_rtS := bar_index
    htf_c1_rtH := math.max(nz(htf_c1_rtH, high), high)
    htf_c1_rtL := math.min(nz(htf_c1_rtL, low),  low)

if htf_enable and htf_c2_on
    if na(htf_c2_rtS)
        htf_c2_rtH := high
        htf_c2_rtL := low
        htf_c2_rtO := open
        htf_c2_rtS := bar_index
    if timeframe.change(htf_c2_tf)
        htf_c2_aO.push(htf_c2_rtO)
        htf_c2_aC.push(close[1])
        htf_c2_aH.push(htf_c2_rtH)
        htf_c2_aL.push(htf_c2_rtL)
        htf_c2_aS.push(htf_c2_rtS)
        htf_c2_aE.push(bar_index)
        htf_c2_rtH := high
        htf_c2_rtL := low
        htf_c2_rtO := open
        htf_c2_rtS := bar_index
    htf_c2_rtH := math.max(nz(htf_c2_rtH, high), high)
    htf_c2_rtL := math.min(nz(htf_c2_rtL, low),  low)

if htf_enable and htf_c3_on
    if na(htf_c3_rtS)
        htf_c3_rtH := high
        htf_c3_rtL := low
        htf_c3_rtO := open
        htf_c3_rtS := bar_index
    if timeframe.change(htf_c3_tf)
        htf_c3_aO.push(htf_c3_rtO)
        htf_c3_aC.push(close[1])
        htf_c3_aH.push(htf_c3_rtH)
        htf_c3_aL.push(htf_c3_rtL)
        htf_c3_aS.push(htf_c3_rtS)
        htf_c3_aE.push(bar_index)
        htf_c3_rtH := high
        htf_c3_rtL := low
        htf_c3_rtO := open
        htf_c3_rtS := bar_index
    htf_c3_rtH := math.max(nz(htf_c3_rtH, high), high)
    htf_c3_rtL := math.min(nz(htf_c3_rtL, low),  low)

// ============================================================================
// VISUALS — HTF CANDLE VP — HELPERS
// ============================================================================
htf_clearSlot(boxes, lines, labels) =>
    f_clear_box_array(boxes)
    f_clear_line_array(lines)
    for lb in labels
        label.delete(lb)
    labels.clear()

htf_drawSlot(float c_h, float c_l, float c_o, float c_c, int c_s, int c_e,
             int slotX, color bull, color bear, string tfLabel, boxes, lines, labels) =>
    bool isBull = c_c >= c_o
    color cCol  = isBull ? bull : bear

    lines.push(line.new(slotX, c_h, slotX, c_l, color=color.new(cCol, 30), width=2))
    boxes.push(box.new(slotX - 1, math.max(c_o, c_c), slotX + 1, math.min(c_o, c_c),
         bgcolor=cCol, border_color=cCol))

    float binSize = c_h > c_l ? (c_h - c_l) / htf_bins : syminfo.mintick
    array<float> vols = array.new_float(htf_bins, 0.0)
    int lookback = bar_index - c_s
    for k = 0 to math.min(lookback, 4999)
        int idx = bar_index - k
        if idx >= c_s and idx < c_e
            int bi = int(math.floor((close[k] - c_l) / binSize))
            bi := math.max(0, math.min(bi, htf_bins - 1))
            vols.set(bi, vols.get(bi) + volume[k])

    float maxVol = vols.max()
    int pocIdx = maxVol > 0 ? vols.indexof(maxVol) : htf_bins / 2

    float tot = vols.sum()
    float tgt = tot * htf_va_pct / 100.0
    int vaUp = pocIdx
    int vaDn = pocIdx
    float vs  = nz(maxVol)
    if tot > 0
        while vs < tgt
            float upV = vaUp < htf_bins - 1 ? vols.get(vaUp + 1) : 0.0
            float dnV = vaDn > 0           ? vols.get(vaDn - 1) : 0.0
            if upV == 0.0 and dnV == 0.0
                break
            if upV >= dnV
                vs  += upV
                vaUp += 1
            else
                vs  += dnV
                vaDn -= 1

    float pocPrice = c_l + binSize * pocIdx + binSize * 0.5
    float vahPrice = c_l + binSize * (vaUp + 1)
    float valPrice = c_l + binSize * vaDn

    int baseX = slotX - 2
    for i = 0 to htf_bins - 1
        float bVol  = vols.get(i)
        float binLo = c_l + binSize * i
        float binHi = binLo + binSize
        int   barW  = maxVol > 0 ? math.max(1, int(math.round(bVol / maxVol * htf_width))) : 1
        bool  isPoc = i == pocIdx
        bool  isVA  = i >= vaDn and i <= vaUp and not isPoc
        int   transp = isPoc ? 10 : isVA ? 45 : 72
        color bgc    = isPoc ? color.new(htf_poc_color, transp) : color.new(cCol, transp)
        boxes.push(box.new(baseX - barW, binHi, baseX, binLo,
             bgcolor=bgc, border_color=color.new(chart.bg_color, 0)))

    // Clamp the left anchor within max_bars_back window to avoid out-of-range errors
    // (monthly candles on low TF charts can start >5000 bars ago)
    int safe_c_s = math.max(bar_index - 4990, c_s)

    if htf_show_poc
        lines.push(line.new(safe_c_s, pocPrice, slotX + 1, pocPrice,
             xloc=xloc.bar_index, color=htf_poc_color,
             style=f_vp_line_style(htf_poc_style), width=htf_level_width))
        if htf_lbl_poc
            labels.push(label.new(safe_c_s, pocPrice,
                 "POC " + str.tostring(pocPrice, format.mintick) + "  " + tfLabel,
                 style=label.style_label_right, color=color.new(color.black, 100),
                 textcolor=htf_poc_color, size=size.small))

    if htf_show_vah
        lines.push(line.new(safe_c_s, vahPrice, slotX + 1, vahPrice,
             xloc=xloc.bar_index, color=htf_vah_color,
             style=f_vp_line_style(htf_vah_style), width=htf_level_width))
        if htf_lbl_vah
            labels.push(label.new(safe_c_s, vahPrice,
                 "VAH " + str.tostring(vahPrice, format.mintick) + "  " + tfLabel,
                 style=label.style_label_right, color=color.new(color.black, 100),
                 textcolor=htf_vah_color, size=size.small))

    if htf_show_val
        lines.push(line.new(safe_c_s, valPrice, slotX + 1, valPrice,
             xloc=xloc.bar_index, color=htf_val_color,
             style=f_vp_line_style(htf_val_style), width=htf_level_width))
        if htf_lbl_val
            labels.push(label.new(safe_c_s, valPrice,
                 "VAL " + str.tostring(valPrice, format.mintick) + "  " + tfLabel,
                 style=label.style_label_right, color=color.new(color.black, 100),
                 textcolor=htf_val_color, size=size.small))

    if htf_show_hilo
        color hiloCol = color.new(cCol, 50)
        lines.push(line.new(safe_c_s, c_h, slotX + 1, c_h,
             xloc=xloc.bar_index, color=hiloCol, style=line.style_dotted, width=1))
        lines.push(line.new(safe_c_s, c_l, slotX + 1, c_l,
             xloc=xloc.bar_index, color=hiloCol, style=line.style_dotted, width=1))
        if htf_lbl_hilo
            labels.push(label.new(safe_c_s, c_h,
                 "H " + str.tostring(c_h, format.mintick) + "  " + tfLabel,
                 style=label.style_label_right, color=color.new(color.black, 100),
                 textcolor=hiloCol, size=size.tiny))
            labels.push(label.new(safe_c_s, c_l,
                 "L " + str.tostring(c_l, format.mintick) + "  " + tfLabel,
                 style=label.style_label_right, color=color.new(color.black, 100),
                 textcolor=hiloCol, size=size.tiny))

    if htf_lbl_tf
        labels.push(label.new(slotX, c_h + nz(htf_atr200) * 0.3, tfLabel,
             style=label.style_label_down, color=color.new(color.black, 100),
             textcolor=chart.fg_color, size=size.small))

// ============================================================================
// VISUALS — HTF CANDLE VP — BARSTATE.ISLAST
// ============================================================================
if barstate.islast and htf_enable
    int slotW = htf_width + 5 + htf_slot_gap
    int s1X   = bar_index + htf_offset + slotW / 2
    int s2X   = s1X + slotW
    int s3X   = s2X + slotW

    if htf_c1_on
        htf_clearSlot(htf_c1_boxes, htf_c1_lines, htf_c1_labels)
        if not na(htf_c1_rtS)
            htf_drawSlot(htf_c1_rtH, htf_c1_rtL, htf_c1_rtO, close,
                         htf_c1_rtS, bar_index + 1,
                         s1X, htf_c1_bull, htf_c1_bear, htf_c1_tf,
                         htf_c1_boxes, htf_c1_lines, htf_c1_labels)
    else
        htf_clearSlot(htf_c1_boxes, htf_c1_lines, htf_c1_labels)

    if htf_c2_on
        htf_clearSlot(htf_c2_boxes, htf_c2_lines, htf_c2_labels)
        if not na(htf_c2_rtS)
            htf_drawSlot(htf_c2_rtH, htf_c2_rtL, htf_c2_rtO, close,
                         htf_c2_rtS, bar_index + 1,
                         s2X, htf_c2_bull, htf_c2_bear, htf_c2_tf,
                         htf_c2_boxes, htf_c2_lines, htf_c2_labels)
    else
        htf_clearSlot(htf_c2_boxes, htf_c2_lines, htf_c2_labels)

    if htf_c3_on
        htf_clearSlot(htf_c3_boxes, htf_c3_lines, htf_c3_labels)
        if not na(htf_c3_rtS)
            htf_drawSlot(htf_c3_rtH, htf_c3_rtL, htf_c3_rtO, close,
                         htf_c3_rtS, bar_index + 1,
                         s3X, htf_c3_bull, htf_c3_bear, htf_c3_tf,
                         htf_c3_boxes, htf_c3_lines, htf_c3_labels)
    else
        htf_clearSlot(htf_c3_boxes, htf_c3_lines, htf_c3_labels)

// ============================================================================
// ALERTS
// ============================================================================
alertcondition(ssl_long_signal,              "MAOF Long",         "Market Auction Order Flow: LONG signal")
alertcondition(ssl_short_signal,             "MAOF Short",        "Market Auction Order Flow: SHORT signal")
alertcondition(ssl_long_signal or ssl_short_signal, "MAOF Signal", "Market Auction Order Flow: Signal")
alertcondition(ssl_pending_dir == 1,         "MAOF Pending Long",  "Market Auction Order Flow: Pending LONG")
alertcondition(ssl_pending_dir == -1,        "MAOF Pending Short", "Market Auction Order Flow: Pending SHORT")
````
