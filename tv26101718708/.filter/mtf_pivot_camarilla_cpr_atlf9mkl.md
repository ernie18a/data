# MTF Pivot+ (Camarilla & CPR)

- url: https://www.tradingview.com/script/ATlF9mkl-mtf-pivot-camarilla-cpr/
- type: indicator
- pine_id: PUB;c161dbbd65364a959b581894e7e4f6c7
- version: 35.0

## Description

[b]MTF Pivot+[/b] is an advanced indicator that combines Camarilla levels and Central Pivot Range (CPR) zones with multi-timeframe (MTF) analysis. It equips traders with a powerful toolkit to identify key support and resistance zones, analyze market trends, and pinpoint precision entry areas for both day trading and swing trading!

[b]Key Features:[/b]
[list]
[*]⏱️ [b]Smart Auto-Timeframe:[/b] Automatically selects the optimal higher timeframe for calculating levels based on your current chart (e.g., Daily levels for intraday charts up to 30m).
[*]🎯 [b]Central Pivot Range (CPR):[/b] Displays the CPR zone (CP, BC, TC) with built-in trend analysis. The zone automatically changes color depending on its shift relative to the previous period (bullish, bearish, or flat).
[*]📊 [b]Camarilla Pivot Levels:[/b] Comprehensive calculation of internal levels (R1-R2 / S1-S2), key reversal zones (R3 / S3), breakout extremes (R4 / S4), and extended targets (R5-R6 / S5-S6).
[*]🔄 [b]Dynamic (Rolling) Pivots:[/b] Option to calculate levels from the previous day's close for daily dynamic updates, while still maintaining the true highs and lows of the higher timeframe.
[*]💱 [b]Advanced Futures Support:[/b] Seamlessly use continuous contracts and calculate pivots based on the Last Traded Price (LTP) instead of exchange settlement prices.
[*]🎛️ [b]MTF Dashboard:[/b] A compact, sleek on-chart panel showing the current price's position relative to the Central Pivot (CP) across Daily, Weekly, and Monthly timeframes at a single glance.
[*]🔔 [b]Comprehensive Alerts System:[/b] Built-in alerts with a smart "cooldown" feature for CPR crosses, touches of reversal zones, R4/S4 breakouts, and previous period High/Low breaches.
[*]🎨 [b]Highly Customizable:[/b] Easily toggle specific levels or features on/off (for example, enabling HLC mode hides main levels) to keep your charts clean, focused, and informative!
[/list]
⚠️ [b]Disclaimer:[/b]
This indicator is provided solely for educational and informational purposes. It does not constitute financial, investment, or trading advice.

[b]Please keep the following important points in mind:[/b]
[list]
[*][b]High Risks:[/b] Trading in financial markets (cryptocurrencies, forex, stocks, futures) involves a high level of risk and may result in the partial or total loss of your capital.
[*][b]No Guarantees:[/b] Indicators are based on the mathematical analysis of past price data. Past price movements and successful level tests do not guarantee future profits.
[*][b]Do Your Own Research (DYOR):[/b] Never make trading decisions based solely on the readings of a single indicator. Always conduct your own comprehensive market analysis, consider the overall context, and employ strict risk management.
[*][b]Responsibility:[/b] You use this script entirely at your own risk.
[/list]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © vasilidimov

//@version=6
indicator("Camarilla MTF Pivots+: Confluence, Anchored VWAP, ATR & Synergy Score", "MTF Pivots+ ᴾᴿᴼ", overlay = true)

// ===========================================================================================================
// BLOCK 1: CUSTOM TYPES AND UI SETTINGS
// ===========================================================================================================

// --- 1.1 Custom Data Types ---
// All pivot levels of a single period
type PivotLevels
    float r5
    float r4_5
    float r4
    float r3_5
    float r3
    float r2
    float r1
    float cp
    float bc
    float tc
    float s1
    float s2
    float s3
    float s3_5
    float s4
    float s4_5
    float s5

// Visual configuration parameters for draw_elements
type DrawConfig
    bool   show_lbl
    bool   show_cpr
    bool   show_cams
    bool   show_hlc
    bool   show_targets
    string line_style   // line style (line.style_*)
    string lbl_size     // label size (size.*)
    int    lbl_transp   // label transparency (0-75)
    // Line colors
    color  col_cp
    color  col_r1
    color  col_r2
    color  col_r3_5     // R3–R3.5 resistance zone color (both lines + fill)
    color  col_r4
    color  col_r4_5
    color  col_r5
    color  col_s1
    color  col_s2
    color  col_s3_5     // S3–S3.5 support zone color (both lines + fill)
    color  col_s4
    color  col_s4_5
    color  col_s5
    color  col_high
    color  col_low
    color  col_close

// HLC coordinates and time boundaries for drawing lines
type HlcData
    float h          // period high
    float l          // period low
    float c          // period close
    int   x_start    // timestamp of the left boundary of HLC lines
    int   x_end      // timestamp of the right boundary of HLC lines

// Numeric factors for the Synergy Score
type SynergyFactors
    int p_d
    int p_w
    int p_m
    int v_d      // D-VWAP match flag (0/1)
    int v_w      // W-VWAP match flag (0/1)
    int v_m      // M-VWAP match flag (0/1)
    int v_y      // Y-VWAP / bands match flag (0/1)
    int dir_d    // D-factor direction: 0=none, 1=exact, 2=VWAP below level, 3=VWAP above level
    int dir_w    // W-factor direction (same encoding)
    int dir_m    // M-factor direction (same encoding)
    int dir_y    // Y-factor direction (same encoding)
    int sigma_y  // Y-factor sigma level: 0 = main VWAP line, 1/2/3 = ±1σ/2σ/3σ

// --- 1.2 Constants: Setting Groups ---
var grp_main      = '⚙️ Main Settings'
var grp_futures   = '🔗 Futures Contracts'
var grp_add       = '📐 Level Display'
var grp_vwap      = '⚓ Anchored VWAP & Bands'
var grp_conf      = '🧩 MTF Confluence'
var grp_atr       = '🪫 ATR Exhaustion Filter'
var grp_synergy   = '🏅 Synergy Score'
var grp_alerts    = '🔔 Notification System'
var grp_style     = '🎨 Visuals'
var grp_cpr       = 'CPR Zone & Relationship'
var grp_lvl_1_2   = 'Inner Levels (R1-R2 / S1-S2)'
var grp_lvl_3_5   = 'Reversal Zones (R3-R3.5 / S3-S3.5)'
var grp_lvl_4     = 'Extreme Levels (R4 / S4)'
var grp_lvl_4_5_5 = 'Target Levels (R4.5-R5 / S4.5-S5)'
var grp_lvl_mmc   = 'HLC / VWAP + Bands (Y)'

// --- 1.3 Constants: Tooltip Texts ---
// Group: Main Settings
var tt_tf      = 'Auto mode:\n' +
  ' • 1m – 30m   → Daily pivots\n' +
  ' • 31m – 23h  → Weekly pivots\n' +
  ' • 1D+ / 1W+  → Monthly pivots\n\n' +
  '⚠️ "Off" completely disables Camarilla/CPR levels, MTF Confluence, ATR Exhaustion, Synergy Score, ' +
  'and their related alerts/warnings.'

var tt_cam_mult = 'Camarilla Multiplier (standard 1.1):\n' +
  ' • 1.1 — Classic (Forex)\n' +
  ' • 1.13 — Adaptive (Stocks, ETFs)\n' +
  ' • 1.272 — Fibonacci Root (Indices, Commodities)\n' +
  ' • 1.414 — Gann Geometry (BTC, ETH)\n' +
  ' • 1.618 — Golden Ratio (Altcoins)\n\n' +
  '💡 With the "1.1" multiplier, R5/S5 levels are calculated using the original Murrey Math formula. ' +
  'For other multipliers, a linear progression is used to maintain symmetry.'

var tt_period   = 'Display mode:\n' +
  ' • Current period (real-time)\n' +
  ' • Previous period (history)\n' +
  ' • Projection (forecast)\n\n' +
  '⚠️ Advanced analytics (MTF Confluence, VWAP + Bands (Y), ATR Exhaustion, Synergy Score, and alerts) ' +
  'only work in "Current" mode.'

var tt_dash     = 'Multi-timeframe trend panel. VWAP sets the direction, CPR zone sets the strength.\n\n' +
  '💡 The (Y) row represents the annual macro context. The ±1σ bands act as the CPR.\n\n' +
  'States:\n' +
  ' • ↗ / ↘ — price is trending and located above/below the CPR zone\n' +
  ' • ⤴ / ⤵ — price is trending but located inside or on the opposite side of the CPR\n' +
  ' • ⇅ — price is near VWAP (within typical movement)\n\n' +
  '💡 The (RS) column duplicates the "CPR Shift (CPR Relationship)" feature. ' +
  'Auto-detection of narrow CPR (1D): ⧗ — volatility compression before a possible move.\n\n' +
  '💡 The (Σ) column in the (Y) row shows current price deviation from the Yearly VWAP. ' +
  'In other rows, it shows the deviation of their central pivot (CP). A deviation > ±2σ indicates overheating (reversal risk ⚠).'

var tt_rel      = 'Colors the CPR based on the Central Pivot (CP) shift relative to the previous period:\n' +
  ' • Green — Bullish\n' +
  ' • Red — Bearish\n' +
  ' • Gray — Flat'

var tt_roll     = 'Hybrid pivot calculation:\n' +
  ' • High / Low — for the entire period (week/month)\n' +
  ' • Close — rolling, from the Daily TF (updates daily)\n\n' +
  '⚠️ Disables MTF Confluence search. Alerts trigger on the current (daily updated) Rolling level values.'

// Group: Futures Contracts
var tt_last       = 'Use Last Traded Price (LTP) instead of Settlement price.\n\n' +
  '💡 For Daily pivots only — switches the calculation to 1440 min. Recommended for CME/NYMEX. Disable for MOEX and Crypto.'

var tt_continuous = 'Convert ticker to a continuous futures contract (adds "1!").\n\n' +
  '💡 Recommended for CME/NYMEX. Disable for MOEX and Crypto.'

// Group: Level Display
var tt_cpr     = 'Central Pivot Range (CP, TC, BC).\n\n' +
  '💡 A narrow CPR often precedes momentum, while a wide CPR indicates consolidation.'

var tt_cams    = 'Inner Camarilla levels (R1-R2 / S1-S2). Used for trading inside the range.\n\n' +
  '⚠️ Not used in advanced analytics.'

var tt_targets = 'Target levels (R4.5-R5 / S4.5-S5). Take-profit zones during a strong trend.\n\n' +
  '💡 Level 4.5 is built on a derivative Fibonacci coefficient (1.168) and often acts as a liquidity-grab zone after an R4/S4 breakout.'

var tt_hlc     = 'Structural HLC levels of the previous period — High, Low, and Close.\n\n' +
  '⚠️ Hides main pivots when enabled. Extends into the current period for proper visualization.'

// Group: Anchored VWAP & Bands
var tt_vwap_view         = 'Plot a single Anchored VWAP line of your choice:\n' +
  ' • Daily / Weekly / Monthly — from the start of the respective period\n' +
  ' • Yearly — from January 1st of the current year\n\n' +
  '💡 This setting only controls the visual line on the chart (does not affect confluence, synergy, or alerts). ' +
  'A fixed calculation base (15m for D/W/M, 60m for Y) protects the line from distortion when changing the chart TF.\n\n' +
  '⚠️ On charts without volume (Forex/CFD), VWAP acts as a Moving Average (SMA).'

var tt_vwap_y_bands_draw = 'Plot Yearly VWAP standard deviation bands: ±1σ, ±2σ, ±3σ.\n\n' +
  '⚠️ Requires "Yearly" to be selected in Anchored VWAP.'

// Group: MTF Confluence
var tt_conf_en       = 'Compare current pivots with higher TF extremes and pivots (1D, 1W, 1M).\n\n' +
  'Marker example: Ⓜ S4\n' +
  ' • Ⓜ — Monthly timeframe\n' +
  ' • S4 — Extreme support level\n\n' +
  '⚠️ Does not work in Rolling mode.'

var tt_conf_vwap     = 'Integrate VWAP into the confluence matrix.\n\n' +
  'Marker example: Ⓜ↓ ⱽᵂᴬᴾ\n' +
  ' • Ⓜ — Monthly VWAP\n' +
  ' • ⱽᵂᴬᴾ — Level match\n' +
  ' • ↓ ⱽᵂᴬᴾ — VWAP is below the level\n' +
  ' • ↑ ⱽᵂᴬᴾ — VWAP is above the level\n\n' +
  '💡 Continues to work in Rolling mode.'

var tt_vwap_y_bands  = 'Integrate Yearly VWAP Bands (±1σ, ±2σ, ±3σ) into the confluence matrix.\n\n' +
  'Marker example: Ⓨ↓ ⱽᵂᴬᴾ⁺²σ\n' +
  ' • ⁺²σ — Upper VWAP band (+2σ)\n' +
  ' • ↓ — Band is below the level\n\n' +
  '⚠️ Requires "VWAP in Confluence" to be enabled.'

var tt_mtf_preset    = 'Tolerance profiles (~10% of Daily ATR):\n' +
  ' • Low (Stocks, ETFs): 0.05% / 0.10%\n' +
  ' • Medium (Forex, Indices): 0.10% / 0.20%\n' +
  ' • High (Commodities, BTC): 0.30% / 0.50%\n' +
  ' • Very High (Altcoins): 0.70% / 1.20%\n\n' +
  '💡 Values are in the format: Levels / VWAP. In "Manual" mode, tolerances are set via sliders.'

var tt_conf_tol      = 'Manual capture tolerance for levels (% of asset price). ' +
  'Recommended to set 5–15% of the Daily ATR.'

var tt_conf_vwap_tol = 'Manual capture tolerance for the dynamic VWAP / Bands line (%). ' +
  'Recommended to set 1.5–2 times larger than the level tolerance.'

// Group: ATR Exhaustion
var tt_atr_filter = 'ATR Exhaustion Filter (price overheating).\n\n' +
  'Marker example: ▾ 68.2% ᴬᵀᴿ ᴰ\n' +
  ' • ▾ / ▴ — Active level\n' +
  ' • ▿ / ▵ — Level tested\n' +
  ' • ᴬᵀᴿ ᴰ / ᴬᵀᴿ ᴾ — Calculation base: Daily (D) or Pivot TF (P)\n\n' +
  '💡 ATR data for Synergy is calculated independently of this toggle.'

var tt_atr_tf     = 'ATR Calculation Base:\n' +
  ' • Daily — Fixed 1D\n' +
  ' • Pivot TF — Synchronized with the period\n\n' +
  '💡 The Synergy gate (⋈) does not depend on this setting: its reference point is always from the start of its pivot period ' +
  '(without a daily reset), and the ATR value is always Daily.'

var tt_atr_period = 'Average True Range period (standard 14):\n' +
  ' • Lower — Higher sensitivity\n' +
  ' • Higher — Stronger smoothing'

var tt_atr_mult   = 'Exhaustion Threshold (× ATR):\n' +
  ' • 1.0 = 100% of average move\n' +
  ' • 0.6–0.8 — Early warning\n' +
  ' • 1.3–1.5 — Strict filter'

// Group: Synergy Score
var tt_synergy_en    = 'Shows the ⋈ icon next to a level indicating high confidence (MTF Confluence + VWAP + Bands (Y) + ATR).\n\n' +
  '⚠️ In Rolling mode, structural MTF confluences (pivots) are disabled, but dynamic levels (VWAP) still contribute points.'

var tt_synergy_score = 'Displays the exact numeric score next to the Synergy icon (e.g., ⋈⁵·⁷⁵).\n\n' +
  '💡 Useful for understanding level strength and fine-tuning the minimum threshold.'

var tt_synergy_thr   = 'Minimum total score to assign the status:\n' +
  ' • 2.0–3.5 — Aggressive\n' +
  ' • 5.0 — Moderate\n' +
  ' • 6.5–8.0 — Conservative\n' +
  ' • 10.0 — Very Strict\n\n' +
  '💡 The score is not the only condition: it requires at least 2 independent confirmations ' +
  '(pivots / VWAP from different TFs) and passing the ATR filter (gate): ≥30% of the daily move.'

// Group: Alerts
var tt_alert_cpr  = 'Alert when the Close price crosses the central pivot (CP).\n\n' +
  '⚠️ Requires enabled pivots (does not work in "Off" mode).'

var tt_alert_rev  = 'Alert when candle wicks (High/Low) touch reversal zones (R3 / S3).\n\n' +
  '⚠️ Requires enabled pivots (does not work in "Off" mode).'

var tt_alert_last = 'Alert when candle wicks (High/Low) touch extreme breakout levels (R4 / S4).\n\n' +
  '⚠️ Requires enabled pivots (does not work in "Off" mode).'

var tt_alert_ext  = 'Alert when candle wicks (High/Low) touch extended levels (R4.5 / S4.5).\n\n' +
  '⚠️ Requires enabled pivots (does not work in "Off" mode).'

var tt_alert_max  = 'Alert when candle wicks (High/Low) touch outermost levels (R5 / S5).\n\n' +
  '⚠️ Requires enabled pivots (does not work in "Off" mode).'

var tt_alert_hl   = 'Alert when candle wicks (High/Low) break the previous period\'s High or Low.\n\n' +
  '⚠️ Requires enabled pivots (does not work in "Off" mode).'

var tt_alert_vwap       = 'Alert when the Close price breaks the Anchored VWAP line (from period start or year).\n\n' +
  '💡 Tied to the pivot calculation period (Daily / Weekly / Monthly). Works even if VWAP and pivot drawing is off.'

var tt_alert_vwap_bands = 'Alert when the Close price breaks one of the Yearly VWAP bands (±1σ/±2σ/±3σ).\n\n' +
  '💡 Cooldown is tracked independently for each band. Works even if VWAP Bands (Y) and pivot drawing is off.'

var tt_cooldown         = 'Minimum interval between repeating alerts of the same type (in current TF bars).\n\n' +
  '💡 A value of 5 on a 1H chart = 5 hours.'

// Group: Visuals
var tt_lbl        = 'Displays price labels with names next to the levels on the chart. Example: Ⓓ R4 (85.99)'
var tt_lbl_transp = 'Transparency of label text and markers:\n' +
  ' • 0 — Opaque\n' +
  ' • 75 — Maximum transparency'

// --- 1.4 Main Calculation Parameters (Inputs) ---
in_tf_sel       = input.string('Auto', 'Pivot Calculation Period', options=['Auto', 'Daily', 'Weekly', 'Monthly', 'Off'], group=grp_main, tooltip=tt_tf)
in_camarilla_mult_str = input.string('Classic (1.1)', 'Camarilla Multiplier', options=['Classic (1.1)', 'Adaptive (1.13)', 'Fibonacci Root (1.272)', 'Gann Geometry (1.414)', 'Golden Ratio (1.618)'], group=grp_main, tooltip=tt_cam_mult)

var float CAM_MULT = switch in_camarilla_mult_str
    'Classic (1.1)'            => 1.1
    'Adaptive (1.13)'          => 1.13
    'Fibonacci Root (1.272)'   => 1.272
    'Gann Geometry (1.414)'    => 1.414
    'Golden Ratio (1.618)'     => 1.618
    => 1.1

// Flag for R5/S5 logic branching (Murrey vs Linear progression)
bool is_classic_mult = in_camarilla_mult_str == 'Classic (1.1)'

in_period       = input.string('Current', 'Display Mode', options=['Current', 'Previous', 'Projection'], group=grp_main, tooltip=tt_period)
in_mtf_dash     = input.bool(false, 'Trend Panel (MTF Dashboard)', group=grp_main, tooltip=tt_dash)
in_cpr_analysis = input.bool(false, 'CPR Shift (CPR Relationship)', group=grp_main, tooltip=tt_rel)
in_rolling      = input.bool(false, 'Rolling Calculation (Rolling Pivots)', group=grp_main, tooltip=tt_roll)

// --- 1.5 Futures Settings ---
in_last_trd   = input.bool(false, 'Last Traded Price (LTP)', group=grp_futures, tooltip=tt_last)
in_continuous = input.bool(false, 'Continuous Contract', group=grp_futures, tooltip=tt_continuous)

// --- 1.6 Auto-Timeframe Logic ---
var string calc_auto_tf = switch
    timeframe.isseconds                                  => 'D'  // Second charts -> Daily pivots
    timeframe.isintraday and timeframe.multiplier <= 30  => 'D'  // 1m-30m        -> Daily pivots
    timeframe.isintraday                                 => 'W'  // 31m-23h59m    -> Weekly pivots
    timeframe.isdaily                                    => 'M'  // Daily         -> Monthly pivots
    timeframe.isweekly                                   => 'M'  // Weekly        -> Monthly pivots (max supported TF)
    =>                                                      'M'  // Default       -> Monthly pivots

// Master "pivots off" flag. When "Off" is selected, in_tf itself still resolves exactly like
// "Auto" (see below) — intentionally: all internal TF comparisons (is_vis, tf_marker,
// alert_tf_label, the VWAP source picked for the breakout alert, etc.) stay valid and never
// break on na/empty string. The actual disabling of levels/confluence/ATR/synergy/alerts is
// done surgically via checking in_pivots_off at the relevant places further down in the code.
bool in_pivots_off = in_tf_sel == 'Off'

// Determine the final pivot timeframe
var string in_tf = switch in_tf_sel
    'Daily'   => 'D'
    'Weekly'  => 'W'
    'Monthly' => 'M'
    => calc_auto_tf  // 'Auto' and 'Off': applies the timeframe selected by logic above

// --- 1.7 Kill Switch: Monthly and Higher TFs ---
// If true, disables ATR, drawing, and alerts. request.security still executes
// (Pine limitation), but all dependent operations are blocked by this flag
var bool is_chart_monthly_or_higher = timeframe.in_seconds() >= timeframe.in_seconds('1M')

// --- 1.8 Level Display Toggles ---
in_cpr     = input.bool(true,  'CPR Zone', group=grp_add, tooltip=tt_cpr)
in_cams    = input.bool(false, 'Inner Levels (R1-R2 / S1-S2)', group=grp_add, tooltip=tt_cams)
in_targets = input.bool(true,  'Target Levels (R4.5-R5 / S4.5-S5)', group=grp_add, tooltip=tt_targets)
in_hlc     = input.bool(false, 'Structural Levels (HLC)', group=grp_add, tooltip=tt_hlc)

// --- 1.9 Anchored VWAP & Bands Toggles ---
in_vwap_view         = input.string('Off', 'Anchored VWAP', options=['Off', 'Daily', 'Weekly', 'Monthly', 'Yearly'], group=grp_vwap, tooltip=tt_vwap_view, display=display.none)
in_vwap_y_bands_draw = input.bool(false, 'VWAP Bands (Y)', group=grp_vwap, tooltip=tt_vwap_y_bands_draw)

// Auto-disable VWAP based on chart TF
// Blocks drawing if chart TF is equal to or higher than the VWAP period (line collapses to a point). 
// Checks for Monthly/Yearly are duplicated over the general Kill Switch for flag autonomy.
var bool in_vwap_show_d = in_vwap_view == 'Daily'   and not (timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly)
var bool in_vwap_show_w = in_vwap_view == 'Weekly'  and not (timeframe.isweekly or timeframe.ismonthly)
var bool in_vwap_show_m = in_vwap_view == 'Monthly' and not timeframe.ismonthly
var bool in_vwap_show_y = in_vwap_view == 'Yearly'

// --- 1.10 MTF Confluence Settings ---
in_mtf_conf          = input.bool(false, 'MTF Pivot Confluence', group=grp_conf, tooltip=tt_conf_en)
in_mtf_conf_vwap     = input.bool(false, 'VWAP in Confluence', group=grp_conf, tooltip=tt_conf_vwap)
in_vwap_y_bands      = input.bool(false, 'VWAP Bands (Y) in Confluence', group=grp_conf, tooltip=tt_vwap_y_bands)
in_mtf_preset        = input.string('Manual', 'Tolerance Profile', options=['Manual', 'Low', 'Medium', 'High', 'Very High'], group=grp_conf, tooltip=tt_mtf_preset, display=display.none)
in_mtf_conf_tol      = input.float(0.03, 'Level Tolerance (%)', minval=0.01, maxval=2.0, step=0.01, group=grp_conf, tooltip=tt_conf_tol, display=display.none)
in_mtf_conf_vwap_tol = input.float(0.05, 'VWAP / Bands Tolerance (%)', minval=0.01, maxval=3.0, step=0.01, group=grp_conf, tooltip=tt_conf_vwap_tol, display=display.none)

// Final tolerance based on preset (~10% of daily ATR). VWAP tolerance is doubled
var float calc_conf_tol = switch in_mtf_preset
    'Low'       => 0.05   // Stocks, ETFs (ATR ~0.5%)
    'Medium'    => 0.10   // Forex majors, Indices (ATR ~1%)
    'High'      => 0.30   // Commodities, BTC (ATR ~3%)
    'Very High' => 0.70   // Altcoins (ATR ~7%)
    => in_mtf_conf_tol

var float calc_conf_vwap_tol = switch in_mtf_preset
    'Low'       => 0.10
    'Medium'    => 0.20
    'High'      => 0.50
    'Very High' => 1.20
    => in_mtf_conf_vwap_tol

// --- 1.11 ATR Exhaustion Settings ---
in_atr_filter  = input.bool(false, 'ATR Exhaustion Filter', group=grp_atr, tooltip=tt_atr_filter)
in_atr_tf_mode = input.string('Daily', 'ATR Calculation Base', options=['Daily', 'Pivot TF'], group=grp_atr, tooltip=tt_atr_tf, display=display.none)
in_atr_period  = input.int(14, 'ATR Period', minval=1, maxval=50, step=1, group=grp_atr, tooltip=tt_atr_period, display=display.none)
in_atr_mult    = input.float(1.0, 'Exhaustion Threshold (× ATR)', minval=0.1, maxval=3.0, step=0.1, group=grp_atr, tooltip=tt_atr_mult, display=display.none)

// --- 1.12 Synergy Score Settings ---
in_synergy_en     = input.bool(false, 'Level Synergy Filter (⋈)', group=grp_synergy, tooltip=tt_synergy_en)
in_syn_score_show = input.bool(false, 'Display Exact Score (Debug)', group=grp_synergy, tooltip=tt_synergy_score)
in_synergy_thr    = input.float(5.0, 'Min. Synergy Score', minval=2.0, maxval=10.0, step=0.5, group=grp_synergy, tooltip=tt_synergy_thr, display=display.none)

// --- 1.13 Alerts Settings ---
in_alert_cpr  = input.bool(true, 'CP Breakout', group=grp_alerts, tooltip=tt_alert_cpr)
in_alert_rev  = input.bool(true, 'R3 / S3 Zone Touch', group=grp_alerts, tooltip=tt_alert_rev)
in_alert_last = input.bool(true, 'R4 / S4 Level Touch', group=grp_alerts, tooltip=tt_alert_last)
in_alert_ext  = input.bool(false, 'R4.5 / S4.5 Level Touch', group=grp_alerts, tooltip=tt_alert_ext)
in_alert_max  = input.bool(false, 'R5 / S5 Level Touch', group=grp_alerts, tooltip=tt_alert_max)
in_alert_hl   = input.bool(true, 'Period High / Low Breakout', group=grp_alerts, tooltip=tt_alert_hl)
in_alert_vwap       = input.bool(false, 'VWAP Breakout', group=grp_alerts, tooltip=tt_alert_vwap)
in_alert_vwap_bands = input.bool(false, 'VWAP Bands (Y) Breakout', group=grp_alerts, tooltip=tt_alert_vwap_bands)
in_cooldown         = input.int(5, 'Alert Cooldown (Bars)', minval=1, maxval=50, step=1, group=grp_alerts, tooltip=tt_cooldown, display=display.none)

// --- 1.14 Visual Style Settings ---
in_show_lbl   = input.bool(true, 'Price Labels', group=grp_style, tooltip=tt_lbl)
in_lbl_size   = input.string('Normal', 'Label Size', options=['Small', 'Normal', 'Large', 'Huge'], group=grp_style, display=display.none)
in_lbl_transp = input.int(25, 'Label Transparency (%)', minval=0, maxval=75, step=5, group=grp_style, tooltip=tt_lbl_transp, display=display.none)
in_line_style = input.string('Solid', 'Line Style', options=['Solid', 'Dashed', 'Dotted'], group=grp_style, display=display.none)
in_line_width = input.int(1, 'Line Width', minval=1, maxval=4, step=1, group=grp_style, display=display.none)
in_vwap_width = input.int(2, 'VWAP / Bands Width', minval=1, maxval=4, step=1, group=grp_style, display=display.none)
in_dash_size  = input.string('Normal', 'MTF Panel Size', options=['Small', 'Normal'], group=grp_style, display=display.none)

// Define visual styles
var style_line = switch in_line_style
    'Solid'   => line.style_solid
    'Dashed'  => line.style_dashed
    'Dotted'  => line.style_dotted
    => line.style_solid

var style_lbl_size = switch in_lbl_size
    'Small'   => size.small
    'Normal'  => size.normal
    'Large'   => size.large
    'Huge'    => size.huge
    => size.normal

var style_dash_size = in_dash_size == 'Small' ? size.small : size.normal

// --- 1.15 Color Settings ---
// CPR Zone
c_cp       = input.color(color.new(#5d606b, 70), '', inline="lp", group=grp_cpr)
c_cpr_bear = input.color(color.new(#b22833, 90), '', inline="lp", group=grp_cpr)
c_cpr_bull = input.color(color.new(#056656, 90), '', inline="lp", group=grp_cpr)
c_cpr_neu  = input.color(color.new(#5d606b, 90), '', inline="lp", group=grp_cpr)

// R1-R2 / S1-S2 Levels
c_r1 = input.color(color.new(#b22833, 70), '', inline="l1_2", group=grp_lvl_1_2)
c_r2 = input.color(color.new(#b22833, 70), '', inline="l1_2", group=grp_lvl_1_2)
c_s1 = input.color(color.new(#056656, 70), '', inline="l1_2", group=grp_lvl_1_2)
c_s2 = input.color(color.new(#056656, 70), '', inline="l1_2", group=grp_lvl_1_2)

// R3-R3.5 / S3-S3.5 Support & Resistance Zones
c_r3_5 = input.color(color.new(#b22833, 70), '', inline="l3-3_5", group=grp_lvl_3_5)
c_s3_5 = input.color(color.new(#056656, 70), '', inline="l3-3_5", group=grp_lvl_3_5)

// Extreme R4 / S4 Levels
c_r4 = input.color(color.new(#b78f2b, 70), '', inline="l4", group=grp_lvl_4)
c_s4 = input.color(color.new(#b78f2b, 70), '', inline="l4", group=grp_lvl_4)

// Target R4.5-R5 / S4.5-S5 Levels
c_r4_5 = input.color(color.new(#b22833, 70), '', inline="l4_5_5", group=grp_lvl_4_5_5)
c_r5   = input.color(color.new(#b22833, 70), '', inline="l4_5_5", group=grp_lvl_4_5_5)
c_s4_5 = input.color(color.new(#056656, 70), '', inline="l4_5_5", group=grp_lvl_4_5_5)
c_s5   = input.color(color.new(#056656, 70), '', inline="l4_5_5", group=grp_lvl_4_5_5)

// HLC Levels
c_high   = input.color(color.new(#4665ac, 70), '', inline="lmmc", group=grp_lvl_mmc)
c_low    = input.color(color.new(#4665ac, 70), '', inline="lmmc", group=grp_lvl_mmc)
c_close  = input.color(color.new(#4665ac, 70), '', inline="lmmc", group=grp_lvl_mmc)

// VWAP + Bands (Y) Levels
c_vwap         = input.color(color.new(#c2185b, 60), '', inline="lmmc", group=grp_lvl_mmc)
c_vwap_y_bands = input.color(color.new(#393c47, 40), '', inline="lmmc", group=grp_lvl_mmc)


// ===========================================================================================================
// BLOCK 2: MATH AND INTERNAL FUNCTIONS
// ===========================================================================================================

// --- 2.1 Mathematical Pivot Calculation ---
// Safety threshold for H/L ratio (used in the classic Murrey formula for R5)
var float MAX_R5_HL_RATIO = 5.0
// Single function for symmetrical protection against negative levels.
f_floor_protect(v) => v > 0 ? v : na

// Calculate levels: Camarilla (R3-R4/S3-S4), CPR (CP/BC/TC), Classic (R1-R2/S1-S2) and Medians (R3.5/S3.5)
calc_pivots(h, l, c) =>
    rng  = h - l
    // Base levels with adaptive CAM_MULT multiplier
    _r4  = c + rng * (CAM_MULT / 2)
    _r3  = c + rng * (CAM_MULT / 4)
    _s3  = c - rng * (CAM_MULT / 4)
    _s4  = c - rng * (CAM_MULT / 2)
    // R5 and S5: logic branching (Murrey for 1.1, Linear for others)
    float _r5 = na
    float _s5 = na
    if is_classic_mult
        _r5 := (l > 0 and (h / l) <= MAX_R5_HL_RATIO) ? (h / l) * c : na
        float _s5_calc = not na(_r5) ? c - (_r5 - c) : na
        _s5 := f_floor_protect(_s5_calc)
    else
        _r5 := c + rng * CAM_MULT
        _s5 := f_floor_protect(c - rng * CAM_MULT)
    // Precalculate CP and BC
    _cp  = (h + l + c) / 3
    _bc  = (h + l) / 2
    _tc  = 2 * _cp - _bc
    // S1-S4.5 are protected from dropping into negative territory via f_floor_protect
    _s1      = f_floor_protect(c - rng * (CAM_MULT / 12))
    _s2      = f_floor_protect(c - rng * (CAM_MULT / 6))
    _s3_5    = f_floor_protect(_s3 - (_s3 - _s4) / 2)
    _s4_prot = f_floor_protect(_s4)
    _s4_5    = f_floor_protect(_s4 - 1.168 * (_s3 - _s4))

    // Object assembly
    PivotLevels.new(
         r5   = _r5,
         r4_5 = _r4 + 1.168 * (_r4 - _r3),
         r4   = _r4,
         r3_5 = _r4 - (_r4 - _r3) / 2,
         r3   = _r3,
         r2   = c + rng * (CAM_MULT / 6),
         r1   = c + rng * (CAM_MULT / 12),
         cp   = _cp,
         bc   = _bc,
         tc   = _tc,
         s1   = _s1,
         s2   = _s2,
         s3   = f_floor_protect(_s3),
         s3_5 = _s3_5,
         s4   = _s4_prot,
         s4_5 = _s4_5,
         s5   = _s5)

// --- 2.2 Trend Color Logic (Relationship Analysis) ---
// Determine CPR color based on the shift direction of the Central Pivot
get_final_cpr_color(curr_cp, prev_cp) =>
    float _mt = syminfo.mintick
    if not in_cpr_analysis or na(curr_cp) or na(prev_cp) or math.abs(curr_cp - prev_cp) < _mt
        c_cpr_neu
    else if curr_cp > prev_cp
        c_cpr_bull
    else
        c_cpr_bear

// Same logic, but WITHOUT the "CPR Shift (CPR Relationship)" checkbox check —
// used for the dot next to CP in the dashboard, which must always work,
// regardless of whether the main CPR zone highlighting is enabled on the chart.
// Colors come from the same shared settings in the "CPR Zone & Relationship" group.
f_dash_cpr_dot_color(curr_cp, prev_cp) =>
    float _mt = syminfo.mintick
    // The source c_cpr_bull/bear/neu are set with 90% transparency (for the CPR zone fill on the chart) —
    // for the text in the table we make them opaque via color.new(..., 0), otherwise the dot isn't visible.
    if na(curr_cp) or na(prev_cp) or math.abs(curr_cp - prev_cp) < _mt
        color.new(c_cpr_neu, 0)
    else if curr_cp > prev_cp
        color.new(c_cpr_bull, 0)
    else
        color.new(c_cpr_bear, 0)

// --- 2.3 Helper Functions for Label Formatting ---
// Readable timeframe name for alert texts
var string alert_tf_label = switch in_tf
    'D' => 'Daily'
    'W' => 'Weekly'
    'M' => 'Monthly'
    => in_tf

// Format large numbers (K, M, B, T) for readability
f_format_large_num(float val) =>
    if na(val)
        ''
    else
        float abs_val = math.abs(val)
        if abs_val >= 1e12
            str.tostring(val / 1e12, '#.##') + 'T'
        else if abs_val >= 1e9
            str.tostring(val / 1e9, '#.##') + 'B'
        else if abs_val >= 1e6
            str.tostring(val / 1e6, '#.##') + 'M'
        else if abs_val >= 1e5
            str.tostring(val / 1e3, '#.##') + 'K'
        else
            str.tostring(math.round_to_mintick(val))

// f_str  — adaptive number: K/M/B/T for large values
// f_txt  — single value: «name (val)»
// f_txt2 — range:      «name (v1 - v2)»
f_str(val)                   => na(val) ? '' : f_format_large_num(val)
f_txt(name, v1)              => na(v1) ? '' : name + ' (' + f_str(v1) + ')'
f_txt2(name, v1, v2)         => (na(v1) or na(v2)) ? '' : name + ' (' + f_str(v1) + ' - ' + f_str(v2) + ')'

// Trend Dashboard
// Flat zone threshold: if |price - VWAP| < FLAT_ATR_MULT × ATR(14, D) — consider it flat
// (see get_trend_state/get_trend_state_y below). Declared here instead of next to the
// ATR fetch (which is physically lower in the code) because Pine requires identifiers
// to be declared before they are used, and it's needed inside get_trend_state.
FLAT_ATR_MULT = 0.15

// 5 trend states. Direction is set by Anchored VWAP, CPR zone acts as an impulse/pullback filter:
//   2  — Strong Long   : price above VWAP AND above CPR zone (impulse)
//   1  — Long Pullback : price above VWAP, but inside/below CPR zone (pullback)
//   0  — Flat          : no VWAP data, OR price deviation from VWAP is less than typical
//                        move (< FLAT_ATR_MULT×ATR) — price is hovering at VWAP, no actual trend
//  -1  — Short Pullback: price below VWAP, but inside/above CPR zone (pullback)
//  -2  — Strong Short  : price below VWAP AND below CPR zone (impulse)
// Temporary breakout of CPR doesn't change global VWAP direction, but downgrades status to "pullback".
// Flat via ATR: Added atr_ref parameter ("typical price move") and a true deadband: 
// |price - vwap_val| < FLAT_ATR_MULT × atr_ref → Flat, even if price is slightly above/below VWAP. 
// If atr_ref is unavailable (na), behavior defaults to the old state (pure sign comparison), no ATR flat.
get_trend_state(tc_val, bc_val, price, vwap_val, atr_ref) =>
    int _state = 0
    if not na(vwap_val) and not na(tc_val) and not na(bc_val)
        float _top = math.max(tc_val, bc_val)
        float _bot = math.min(tc_val, bc_val)
        float _dev = price - vwap_val
        bool _has_atr = not na(atr_ref) and atr_ref > 0
        bool _is_flat = _has_atr and math.abs(_dev) < FLAT_ATR_MULT * atr_ref
        if not _is_flat
            // Direction set by VWAP (exact match is a rare case treated as flat)
            int _vwap_dir = _dev > 0 ? 1 : _dev < 0 ? -1 : 0
            if _vwap_dir == 1
                _state := price > _top ? 2 : 1
            else if _vwap_dir == -1
                _state := price < _bot ? -2 : -1
        // _is_flat or _vwap_dir == 0 → _state remains 0 (Flat)
    _state

// Global New Year detector (calculated once per bar, in the CHART context).
// Used only for visual and event triggers: resetting polyline points (block 7)
// and gating alerts (block 5). Does not affect internal VWAP accumulators.
bool global_is_new_year = timeframe.change('12M')


// ===========================================================================================================
// BLOCK 3: DATA REQUEST AND PREPARATION FROM OTHER TIMEFRAMES (MTF)
// ===========================================================================================================

// --- 3.1 Parameter Preparation for request.security ---
// Construct the ticker accounting for continuous futures ('1!')
var fetch_sym = (syminfo.type == 'futures' and in_continuous) ? syminfo.prefix + ':' + syminfo.root + '1!' : syminfo.tickerid
// Use '1440' instead of 'D' to fetch LTP instead of Settlement Price
var calc_tf   = in_last_trd and in_tf == 'D' ? '1440' : in_tf
var roll_tf   = in_last_trd ? '1440' : 'D'
// Pivot timeframe marker, used as a prefix in level names (e.g. «Ⓓ R5»)
var string tf_marker = in_tf == 'D' ? 'Ⓓ' : in_tf == 'W' ? 'Ⓦ' : 'Ⓜ'

// --- 3.2 Price Request (Current period / base: previous MTF bar) ---
[p_high, p_low, t_start, t_end] = request.security(fetch_sym, calc_tf, [high[1], low[1], time_close[1], time_close[0]], barmerge.gaps_off, barmerge.lookahead_on)
p_close = request.security(fetch_sym, in_rolling ? roll_tf : calc_tf, close[1], barmerge.gaps_off, barmerge.lookahead_on)

// Pivot period change flag (similar to global_is_new_year, but for periodic D/W/M VWAP):
// on the bar where the anchor changes, _vwap_src abruptly recalculates for the new period,
// so a Close breakout on this bar is an anchor reset artifact, not real price movement.
// Declared here rather than next to global_is_new_year since t_start doesn't exist until now.
bool _is_new_vwap_period = ta.change(t_start) != 0

// --- 3.3 Price Request (Projection / base: current MTF bar) ---
// Request projection without looking into the future (lookahead_off)
[n_high, n_low] = request.security(fetch_sym, calc_tf, [high, low], barmerge.gaps_off, barmerge.lookahead_off)
n_close   = request.security(fetch_sym, in_rolling ? roll_tf : calc_tf, close, barmerge.gaps_off, barmerge.lookahead_off)
n_t_start = t_end
// Approximate right boundary of the projection (mirrors current period)
n_t_end   = t_end + (t_end - t_start)

// --- 3.4 Price Request (Previous period / base: two bars ago on MTF) ---
// Request historical data (single request.security call to bypass limits)
[pp_high, pp_low, pp_close, p_t_start, p_t_end, pp_t_start, _raw_old_cp] = request.security(fetch_sym, calc_tf,
    [high[2], low[2], close[2], time_close[2], time_close[1], time_close[3], (high[3] + low[3] + close[3]) / 3], barmerge.gaps_off, barmerge.lookahead_on)

// --- 3.5 Trend Analysis Data (CPR) ---
// Initialize old_cp with protection against missing history at the chart start
old_cp = in_cpr_analysis and in_period == 'Previous' and not na(_raw_old_cp) ? _raw_old_cp : na

// --- 3.5.1 Single HLC Request for Confluence and Dashboard ---
// MTF Offset. OFFSET_MTF = 1 guarantees usage of a closed bar
var int OFFSET_MTF = 1

// Confluence activity flag (blocked outside "Current" mode, during Rolling, and on 1M+ TF).
var is_conf_active = in_mtf_conf and in_period == 'Current' and not in_rolling and not is_chart_monthly_or_higher and not in_pivots_off

// Single HLC request function — called once per TF
// Data is used for both confluence and the trend dashboard
// Besides the HLC of the current (closed) period, we also request the previous
// period's HLC (offset+1) in the same request.security call — needed for the
// previous period's CP (CP dot coloring in the dashboard, see block 6.2).
f_fetch_mtf_hlc(tf) =>
    _calc_tf = (in_last_trd and tf == 'D') ? '1440' : tf
    request.security(fetch_sym, _calc_tf,
      [high[OFFSET_MTF], low[OFFSET_MTF], close[OFFSET_MTF],
       high[OFFSET_MTF + 1], low[OFFSET_MTF + 1], close[OFFSET_MTF + 1]], barmerge.gaps_off, barmerge.lookahead_on)

// Fetch data for all three TFs (3 calls instead of 6)
[h_d_raw, l_d_raw, c_d_raw, h_d_prev_raw, l_d_prev_raw, c_d_prev_raw] = f_fetch_mtf_hlc('D')
[h_w_raw, l_w_raw, c_w_raw, h_w_prev_raw, l_w_prev_raw, c_w_prev_raw] = f_fetch_mtf_hlc('W')
[h_m_raw, l_m_raw, c_m_raw, h_m_prev_raw, l_m_prev_raw, c_m_prev_raw] = f_fetch_mtf_hlc('M')

// Dashboard pivots — always calculated (no protective logic)
lvl_d = calc_pivots(h_d_raw, l_d_raw, c_d_raw)
lvl_w = calc_pivots(h_w_raw, l_w_raw, c_w_raw)
lvl_m = calc_pivots(h_m_raw, l_m_raw, c_m_raw)

// Previous period's CP for each dashboard TF (used only for the CP dot color)
cp_d_prev = na(h_d_prev_raw) or na(l_d_prev_raw) or na(c_d_prev_raw) ? na : (h_d_prev_raw + l_d_prev_raw + c_d_prev_raw) / 3
cp_w_prev = na(h_w_prev_raw) or na(l_w_prev_raw) or na(c_w_prev_raw) ? na : (h_w_prev_raw + l_w_prev_raw + c_w_prev_raw) / 3
cp_m_prev = na(h_m_prev_raw) or na(l_m_prev_raw) or na(c_m_prev_raw) ? na : (h_m_prev_raw + l_m_prev_raw + c_m_prev_raw) / 3

// Auto-calibration of the "narrow CPR" threshold via percentile (Daily only)
// We compare today's CPR width against the distribution of CPR width for THIS SAME instrument
// over the last NARROW_CPR_LOOKBACK_D completed daily bars. "Narrow" = narrower than it was in
// (100 - NARROW_CPR_PERCENTILE_D)% of cases over the window — the threshold adapts itself to the
// specific ticker and its current volatility regime. CPR width is taken as a RATIO OF PRICE (_w / _c), not in absolute points
// otherwise, over a long window (200 days), the percentile would be distorted by the instrument's natural price growth/decline.
var int NARROW_CPR_LOOKBACK_D   = 200  // history window (completed daily bars) for the percentile
var int NARROW_CPR_PERCENTILE_D = 20   // the bottom 20% by CPR width over the window is considered "narrow"

// CPR width percentile calculation in the daily context (via OFFSET_MTF).
// ta.percentile_nearest_rank is called unconditionally on every bar so its
// internal rolling window works correctly.
f_narrow_cpr_pctl_d(len, pct) =>
    _h  = high[OFFSET_MTF]
    _l  = low[OFFSET_MTF]
    _c  = close[OFFSET_MTF]
    _cp = (_h + _l + _c) / 3
    _bc = (_h + _l) / 2
    _tc = 2 * _cp - _bc
    _w_ratio = _c != 0 ? math.abs(_tc - _bc) / _c : na

    float raw_pctl = ta.percentile_nearest_rank(_w_ratio, len, pct)
    float _pctl = not na(_w_ratio) ? raw_pctl : na

    [_w_ratio, _pctl]

[cpr_width_ratio_d, cpr_narrow_thresh_ratio_d] = request.security(fetch_sym, 'D', f_narrow_cpr_pctl_d(NARROW_CPR_LOOKBACK_D, NARROW_CPR_PERCENTILE_D), barmerge.gaps_off, barmerge.lookahead_on)

// Confluence pivots — with protective logic (returns na if confluences are inactive)
float h_d_conf = is_conf_active ? h_d_raw : na
float l_d_conf = is_conf_active ? l_d_raw : na
float c_d_conf = is_conf_active ? c_d_raw : na

float h_w_conf = is_conf_active ? h_w_raw : na
float l_w_conf = is_conf_active ? l_w_raw : na
float c_w_conf = is_conf_active ? c_w_raw : na

float h_m_conf = is_conf_active ? h_m_raw : na
float l_m_conf = is_conf_active ? l_m_raw : na
float c_m_conf = is_conf_active ? c_m_raw : na

lvl_d_conf = calc_pivots(h_d_conf, l_d_conf, c_d_conf)
lvl_w_conf = calc_pivots(h_w_conf, l_w_conf, c_w_conf)
lvl_m_conf = calc_pivots(h_m_conf, l_m_conf, c_m_conf)

// Global array to store all current candidate levels (for exclusive Nearest Neighbor capture)
var array<float> conf_candidates = array.new<float>()

// Fixed positions of named levels in conf_candidates — must 1-to-1 match
// the order of array.push() in block 3.7.1 below. Passed explicitly as "own_idx" to
// f_is_exclusive_match INSTEAD of array.indexof(conf_candidates, val): indexof looks for
// the FIRST match by value, not by call position, and messes up the index if two different
// named levels randomly overlap numerically (e.g., R3 == CP on a degenerate bar where h≈l).
// An explicit index removes this ambiguity.
var int IDX_R5   = 0
var int IDX_R4_5 = 1
var int IDX_R4   = 2
var int IDX_R3   = 3
var int IDX_CP   = 4
var int IDX_S3   = 5
var int IDX_S4   = 6
var int IDX_S4_5 = 7
var int IDX_S5   = 8

// Basic check: does the price fall within the tolerance zone (in percentage)
f_is_in_range(val, tgt, tol) =>
    not na(val) and not na(tgt) and tgt != 0 and (math.abs(val - tgt) / math.abs(tgt) <= (tol / 100))

// Exclusive search (Nearest Neighbor)
// The candidate must be within tolerance and be closer than the others. In case of equal distance,
// a tie-breaker triggers: the level with a smaller index in conf_candidates wins 
// (strict priority R5 -> S5). Self-comparison is excluded (i != own_idx).
// own_idx — fixed position of the calling level (see IDX_* constants above),
// passed EXPLICITLY by the caller instead of being recovered via array.indexof —
// see the comment for IDX_* constants regarding the reasoning for this.
f_is_exclusive_match(val, tgt, tol, int own_idx) =>
    bool is_match = false
    if f_is_in_range(val, tgt, tol)
        float dist = math.abs(val - tgt)
        bool is_closest = true
        for i = 0 to array.size(conf_candidates) - 1
            if i != own_idx
                float cand = array.get(conf_candidates, i)
                if not na(cand)
                    float cand_dist = math.abs(cand - tgt)
                    // Strictly closer — always lose. In case of an exact distance match
                    // (within float micro-errors) — only lose if the competitor
                    // has a lower index (it is "earlier" in the fixed order).
                    bool cand_wins = cand_dist < dist - 1e-6 or (math.abs(cand_dist - dist) <= 1e-6 and i < own_idx)
                    if cand_wins
                        is_closest := false
                        break
        is_match := is_closest
    is_match

// Price verification against key higher TF levels (exclusive Nearest Neighbor capture).
// Global nearest neighbor: if several higher-TF levels fall within tolerance,
// the numerically closest one wins — no hierarchy by level type.
// include_pivots: false — only compares against this TF's own High/Low (not its
// calculated pivots). Used when target_lvl was computed on the SAME TF as the
// current levels (own_idx) — comparing a calculated level to itself would be a
// tautology, but that same TF's High/Low is independent raw data, not a tautology
// (see block 3.7.1, self-match protection).
f_check_conf_name(val, target_lvl, tgt_h, tgt_l, tol, int own_idx, bool include_pivots = true) =>
    string res = ""
    float min_dist = na

    // Arrays of values and their text labels
    array<float>  tgt_vals  = include_pivots ? array.from(tgt_h, tgt_l, target_lvl.cp, target_lvl.r3, target_lvl.s3, target_lvl.r4, target_lvl.s4, target_lvl.r4_5, target_lvl.s4_5, target_lvl.r5, target_lvl.s5) : array.from(tgt_h, tgt_l)
    array<string> tgt_names = include_pivots ? array.from("ᴴᴵᴳᴴ", "ᴸᴼᵂ", "CP", "R3", "S3", "R4", "S4", "R4.5", "S4.5", "R5", "S5") : array.from("ᴴᴵᴳᴴ", "ᴸᴼᵂ")

    // Check all targets without early exit
    for i = 0 to array.size(tgt_vals) - 1
        float tgt_val = array.get(tgt_vals, i)
        string tgt_name = array.get(tgt_names, i)

        // If the higher-TF level passes the exclusivity check (no other current level is closer to it)
        if f_is_exclusive_match(val, tgt_val, tol, own_idx)
            float current_dist = math.abs(val - tgt_val)
            // Look for the minimum distance among all matching higher-TF levels
            if na(min_dist) or current_dist < min_dist
                min_dist := current_dist
                res := tgt_name

    res

// --- 3.5.2 Anchored VWAP Calculation Flags ---
// need_vwap_base handles only the breakout alert (strictly tied to the pivot TF in_tf).
// Drawing flags (in_vwap_show_*) are independent: they enable calculation purely
// for visualization, without affecting MTF confluence and alert logic.
var bool need_vwap_base = in_alert_vwap

// Calculation activity flags for VWAP and σ.
// Accounts for Dashboard requirements (in_mtf_dash) to calculate trend direction and the "Σ" column.
var bool need_vwap_d       = in_mtf_conf_vwap or (need_vwap_base and in_tf == 'D') or in_vwap_show_d or in_mtf_dash
var bool need_vwap_w       = in_mtf_conf_vwap or (need_vwap_base and in_tf == 'W') or in_vwap_show_w or in_mtf_dash
var bool need_vwap_m       = in_mtf_conf_vwap or (need_vwap_base and in_tf == 'M') or in_vwap_show_m or in_mtf_dash
var bool need_vwap_y       = in_vwap_show_y or in_alert_vwap or in_mtf_conf_vwap or in_vwap_y_bands_draw or in_alert_vwap_bands or in_mtf_dash
var bool need_vwap_y_bands = in_vwap_y_bands and in_mtf_conf_vwap
var bool need_vwap_y_sigma = need_vwap_y_bands or in_vwap_y_bands_draw or in_alert_vwap_bands or in_mtf_dash

// Missing Volume Detector (Forex/CFD)
// Using syminfo.volumetype == 'n/a' classifies the whole instrument, allowing to distinguish
// systemic volume absence from legitimate zero bars (gaps/pauses) on normal tickers.
// Local volume == 0 check inside VWAP functions acts as a fallback for specific brokers
// where volumetype is not 'n/a', but real volume is still 0.
var bool no_vol_data = syminfo.volumetype == 'n/a'

// VWAP: Fixed Calculation Base
// Accumulator is called via request.security with an independent fixed base.
// This ensures absolute value stability (protects against jumps on TF change),
// deep history, and optimization of the Pine Script engine load.
var string VWAP_BASE_DWM = "15"  // Single base for D/W/M anchors
var string VWAP_BASE_Y   = "60"  // Base for the Yearly anchor (Y) and its σ-bands

// Comparing anchors (Anchor Time Dedup) operates via time, not bar_index,
// because different anchors might use different calculation bases.
f_anchored_vwap(tf, is_active) =>
    var float sum_vol  = 0.0
    var float sum_src  = 0.0
    var int   anchor_time = na  // bar time of the last accumulator reset (for Anchor Time Dedup)

    // Unconditional timeframe.change call for history stability
    bool chg = timeframe.change(tf)

    // VWAP calculation if the flag is active
    if is_active
        // Accumulator reset on a new period or the first history bar
        bool is_new  = chg or barstate.isfirst
        // "Dead" volume protection: for instruments/brokers (e.g., CFD)
        // where volume physically equals 0 on every bar, assign a weight of 1.0 (SMA calculation).
        float v      = no_vol_data or volume == 0 ? 1.0 : nz(volume, 1)
        float src_v  = nz(hlc3 * v)
        sum_vol   := is_new ? v      : sum_vol + v
        sum_src   := is_new ? src_v  : sum_src + src_v
        if is_new
            anchor_time := time

    float vwap_val = is_active and sum_vol > 0 ? sum_src / sum_vol : float(na)
    [vwap_val, anchor_time]

// Request VWAP via request.security with a fixed base
[vwap_d, anchor_time_d] = request.security(fetch_sym, VWAP_BASE_DWM, f_anchored_vwap('D', need_vwap_d), barmerge.gaps_off, barmerge.lookahead_off)
[vwap_w, anchor_time_w] = request.security(fetch_sym, VWAP_BASE_DWM, f_anchored_vwap('W', need_vwap_w), barmerge.gaps_off, barmerge.lookahead_off)
[vwap_m, anchor_time_m] = request.security(fetch_sym, VWAP_BASE_DWM, f_anchored_vwap('M', need_vwap_m), barmerge.gaps_off, barmerge.lookahead_off)

// Dashboard: ATR Flat Zone
// Flat threshold is hardcoded (not moved to settings, see FLAT_ATR_MULT constant).
// ATR is INDEPENDENT of the "ATR Exhaustion Filter" toggle (in_atr_filter, block 4.4,
// OFF by default) — otherwise, the dashboard flat would only work when a separate,
// conceptually unrelated feature is turned on. A single Daily ATR(14) is used as a
// "typical price move" for ALL 4 dashboard rows (D/W/M/Y) — a compromise: technically,
// it'd be more accurate to have a separate ATR for each TF (weekly for 1W, monthly for 1M),
// but that means extra request.security calls and settings for a barely noticeable dashboard precision.
// (The FLAT_ATR_MULT constant is declared earlier, before get_trend_state — see its comments)
dash_atr_val = request.security(fetch_sym, 'D', ta.atr(14)[1], barmerge.gaps_off, barmerge.lookahead_on)

// Determine the trend state for each TF (Dashboard, block 6).
state_d = not is_chart_monthly_or_higher ? get_trend_state(lvl_d.tc, lvl_d.bc, close, vwap_d, dash_atr_val) : 0
state_w = not is_chart_monthly_or_higher ? get_trend_state(lvl_w.tc, lvl_w.bc, close, vwap_w, dash_atr_val) : 0
state_m = not is_chart_monthly_or_higher ? get_trend_state(lvl_m.tc, lvl_m.bc, close, vwap_m, dash_atr_val) : 0

// VWAP Anchor Deduplication (Anchor Time Dedup)
// Identical anchors make D/W/M mathematically identical. For Synergy,
// only the higher TF (M > W > D) is counted, preventing score manipulation.
// Comparison is strictly pairwise (D-W, D-M, W-M), since matches are not transitive
// (e.g., the start of a month on Wednesday matches D but skips the Monday W).

// Anchor comparison via time (anchor_time)
bool dup_dw = not na(anchor_time_d) and not na(anchor_time_w) and anchor_time_d == anchor_time_w
bool dup_dm = not na(anchor_time_d) and not na(anchor_time_m) and anchor_time_d == anchor_time_m
bool dup_wm = not na(anchor_time_w) and not na(anchor_time_m) and anchor_time_w == anchor_time_m

// Yearly VWAP and Variance (Welford-West algorithm)
// Incremental calculation prevents catastrophic loss of float precision,
// typical in the naive formula E[x²] − E[x]² when accumulating massive data over a year.
// Variance (M2) accumulates safely via deviations from the running mean.
f_annual_vwap(is_active, calc_sigma) =>
    var float _wsum = 0.0  // accumulated weight (Σv equivalent)
    var float _mean = 0.0  // weighted mean = VWAP, updated incrementally
    var float _m2   = 0.0  // accumulated weighted sum of squared deviations (variance numerator)

    // Local New Year detector for proper accumulator reset 
    // within the fixed VWAP_BASE_Y context.
    bool _is_new_ctx = timeframe.change('12M') or barstate.isfirst

    if is_active
        bool _is_new = _is_new_ctx
        // "Dead" volume protection (analogous to f_anchored_vwap)
        float _v = no_vol_data or volume == 0 ? 1.0 : nz(volume, 1)
        float _x = nz(hlc3)
        if _is_new
            // Reset on a new year: single point — variance of a single point is 0
            _wsum := _v
            _mean := _x
            _m2   := 0.0
        else
            _wsum += _v
            float _mean_old = _mean
            _mean += (_v / _wsum) * (_x - _mean_old)
            // Accumulate M2 only if bands calculation is required (saves resources)
            if calc_sigma
                _m2 += _v * (_x - _mean_old) * (_x - _mean)

    float _vwap  = is_active and _wsum > 0 ? _mean : float(na)
    // σ = sqrt(M2 / Σv) — identical volume-weighted variance, but without subtracting
    // two large numbers: M2 is already accumulated at the variance scale
    float _sigma = na
    if calc_sigma and is_active and _wsum > 0
        float _variance = _m2 / _wsum
        _sigma := math.sqrt(math.max(_variance, 0.0))

    [_vwap, _sigma]

// Request Yearly VWAP and variance via request.security (VWAP_BASE_Y base)
[vwap_y, vwap_y_sigma] = request.security(fetch_sym, VWAP_BASE_Y, f_annual_vwap(need_vwap_y and not is_chart_monthly_or_higher, need_vwap_y_sigma), barmerge.gaps_off, barmerge.lookahead_off)

// Trend state for the "Y" row (5-level scale). 
// The ±1σ bands of the Yearly VWAP act as an impulse/pullback filter:
//   2  — Strong Long   : price above VWAP AND above +1σ band (impulse)
//   1  — Long Pullback : price above VWAP, but inside ±1σ bands (calm pullback)
//   0  — Flat          : no VWAP/σ data, OR price deviation from VWAP < FLAT_ATR_MULT×ATR
//  -1  — Short Pullback: price below VWAP, but inside ±1σ bands
//  -2  — Strong Short  : price below VWAP AND below -1σ band (impulse)
// ATR Flat: same deadband as get_trend_state — see detailed comments there.
get_trend_state_y(price, vwap_val, sigma_val, atr_ref) =>
    int _state = 0
    if not na(vwap_val) and not na(sigma_val) and sigma_val > 0
        float _dev = price - vwap_val
        bool _has_atr = not na(atr_ref) and atr_ref > 0
        bool _is_flat = _has_atr and math.abs(_dev) < FLAT_ATR_MULT * atr_ref
        if not _is_flat
            int _dir = _dev > 0 ? 1 : _dev < 0 ? -1 : 0
            if _dir == 1
                _state := price > vwap_val + sigma_val ? 2 : 1
            else if _dir == -1
                _state := price < vwap_val - sigma_val ? -2 : -1
    _state

state_y = not is_chart_monthly_or_higher ? get_trend_state_y(close, vwap_y, vwap_y_sigma, dash_atr_val) : 0

// Price distance from Yearly VWAP in σ units — an overheating metric for mean reversion.
// Used in the "Y" row (for close) and the "Σ" column (for CP of each TF).
f_sigma_dist(price, vwap_val, sigma_val) =>
    not na(price) and not na(vwap_val) and not na(sigma_val) and sigma_val > 0 ? (price - vwap_val) / sigma_val : float(na)

// "Σ" column text: sign + one decimal + "σ". "-" if no data.
f_sigma_str(sd) =>
    na(sd) ? "-" : (sd >= 0 ? "+" : "") + str.tostring(sd, "#.#") + "σ"

// "Σ" value color: normal (|σ|<1) — neutral, approaching (1–2σ) — orange,
// overheating (>=2σ) — red. Rounding to 1 decimal syncs color with the displayed text.
f_sigma_color(sd) =>
    float _abs_sd = math.abs(math.round(sd, 1))
    na(sd) ? color.gray : _abs_sd >= 2 ? color.new(#ff5252, 0) : _abs_sd >= 1 ? color.new(#be8a3d, 0) : color.white

// Prices for Yearly VWAP Bands: ±1σ, ±2σ, ±3σ
// Array indices: 0=+1σ, 1=+2σ, 2=+3σ, 3=-1σ, 4=-2σ, 5=-3σ
var int[]   band_y_mult  = array.from(1, 2, 3, -1, -2, -3)
var float[] band_y_price = array.new<float>(6, na)

// Calculate band prices if needed by confluence OR drawing
if need_vwap_y_sigma and not na(vwap_y) and not na(vwap_y_sigma)
    for i = 0 to 5
        array.set(band_y_price, i, vwap_y + array.get(band_y_mult, i) * vwap_y_sigma)
else
    array.fill(band_y_price, na)

// Convert band number into a signed superscript (⁺¹σ — above VWAP, ⁻¹σ — below VWAP)
// signed_n: sign indicates the band's position relative to the main Yearly VWAP line (+nσ / -nσ), not relative to the level
f_sigma_sup(int signed_n) =>
    string _sign = signed_n > 0 ? '⁺' : '⁻'
    int    _abs  = math.abs(signed_n)
    string _num  = switch _abs
        1 => '¹'
        2 => '²'
        3 => '³'
        => str.tostring(_abs)
    _sign + _num

// Text label for band alerts (regular format "+1σ" / "-2σ", no superscripts for readability)
f_sigma_label(int signed_n) => (signed_n > 0 ? '+' : '-') + str.tostring(math.abs(signed_n)) + 'σ'

// VWAP Source for current pivot TF
// Calculated here (block 3) to be available for both alerts (block 5) and drawing (block 7)
// Used ONLY for the «VWAP Breakout» alert — tied to the pivot TF (in_tf), just like before.
_vwap_src = switch in_tf
    'D' => vwap_d
    'W' => vwap_w
    'M' => vwap_m
    => vwap_d

// VWAP Source for DRAWING — independent dropdown choice in «Anchored VWAP» (block 1.9),
// not linked to the pivot TF. Used only in block 7, does not affect _vwap_src/alerts above.
_vwap_view_src = switch
    in_vwap_show_d => vwap_d
    in_vwap_show_w => vwap_w
    in_vwap_show_m => vwap_m
    => float(na)

// Check geometrical inclusion of a value within a range (zone)
f_in_zone(float v, float a, float b) =>
    not na(v) and not na(a) and not na(b) and v >= math.min(a, b) and v <= math.max(a, b)

// Geometry priority: the function evaluates all higher TF levels and zones (CPR, R3, S3).
// If a level falls inside its zone OR fits the tolerance (tol), it is marked eligible.
// From all eligible options, the one with the minimal distance to VWAP is chosen.
f_get_vwap_owner_zoned(float vwap_val, array<float> candidates, float tol, float r3, float r3_5, float s3, float s3_5, float bc, float tc, float cp) =>
    float owner = na
    float min_dist = na
    float _mt = syminfo.mintick
    if not na(vwap_val)
        // 1. Physical presence checks in zones
        bool zone_in_cpr = f_in_zone(vwap_val, bc, tc)
        bool zone_in_r3  = f_in_zone(vwap_val, r3, r3_5)
        bool zone_in_s3  = f_in_zone(vwap_val, s3, s3_5)

        float med_r3 = (r3 + r3_5) / 2.0
        float med_s3 = (s3 + s3_5) / 2.0
        for lvl in candidates
            if not na(lvl)
                bool is_eligible = false

                // 2. Distribute tolerances: VWAP inside a zone? That zone's levels participate.
                if zone_in_cpr and math.abs(lvl - cp) < _mt
                    is_eligible := true
                else if zone_in_r3 and (math.abs(lvl - r3) < _mt or math.abs(lvl - r3_5) < _mt or math.abs(lvl - med_r3) < _mt)
                    is_eligible := true
                else if zone_in_s3 and (math.abs(lvl - s3) < _mt or math.abs(lvl - s3_5) < _mt or math.abs(lvl - med_s3) < _mt)
                    is_eligible := true

                // 3. Distribute tolerances: VWAP fits the % deviation? Any level can participate.
                else if f_is_in_range(vwap_val, lvl, tol)
                    is_eligible := true

                // 4. Finale: from all eligible levels, the one geometrically closest to VWAP grabs the marker.
                if is_eligible
                    float dist = math.abs(vwap_val - lvl)
                    if na(min_dist) or dist < min_dist
                        min_dist := dist
                        owner := lvl
    owner

// Global variables to store VWAP "owners"
var float owner_vwap_d = na
var float owner_vwap_w = na
var float owner_vwap_m = na
var float owner_vwap_y = na
// "Owners" of the Yearly VWAP bands (±1σ/2σ/3σ), indexing mirrors band_y_price
var float[] owner_vwap_y_bands = array.new<float>(6, na)

// VWAP Confluence Marker. Format: «Ⓓ ↓ ⱽᵂᴬᴾ» / «Ⓓ ↑ ⱽᵂᴬᴾ» / «Ⓓ ⱽᵂᴬᴾ»
// For a zone, ref = median (neutral comparison point)
f_get_vwap_marker(float val, float val2 = na) =>
    string _c = ""
    if in_mtf_conf_vwap and in_period == 'Current' and not is_chart_monthly_or_higher
        float median_val = not na(val2) ? (val + val2) / 2 : val
        float _mt        = syminfo.mintick
        // ref — comparison point for the direction arrow
        float ref        = median_val

        // Check if owner matches val, val2, or the zone's median
        _m_d = not na(owner_vwap_d) and (math.abs(val - owner_vwap_d) < _mt or
                (not na(val2) and (math.abs(val2 - owner_vwap_d) < _mt or math.abs(median_val - owner_vwap_d) < _mt)))
        _m_w = not na(owner_vwap_w) and (math.abs(val - owner_vwap_w) < _mt or
                (not na(val2) and (math.abs(val2 - owner_vwap_w) < _mt or math.abs(median_val - owner_vwap_w) < _mt)))
        _m_m = not na(owner_vwap_m) and (math.abs(val - owner_vwap_m) < _mt or
                (not na(val2) and (math.abs(val2 - owner_vwap_m) < _mt or math.abs(median_val - owner_vwap_m) < _mt)))

        // Direction arrow: where the VWAP line stands relative to the level
        _dir_d = not na(vwap_d) ? (vwap_d < ref - _mt ? '↓' : vwap_d > ref + _mt ? '↑' : '') : ''
        _dir_w = not na(vwap_w) ? (vwap_w < ref - _mt ? '↓' : vwap_w > ref + _mt ? '↑' : '') : ''
        _dir_m = not na(vwap_m) ? (vwap_m < ref - _mt ? '↓' : vwap_m > ref + _mt ? '↑' : '') : ''

        if _m_d
            _c += ' Ⓓ' + _dir_d + ' ⱽᵂᴬᴾ'
        if _m_w
            _c += ' Ⓦ' + _dir_w + ' ⱽᵂᴬᴾ'
        if _m_m
            _c += ' Ⓜ' + _dir_m + ' ⱽᵂᴬᴾ'

        // Yearly VWAP (Ⓨ)
        if not na(owner_vwap_y)
            _m_y = math.abs(val - owner_vwap_y) < _mt or
                   (not na(val2) and (math.abs(val2 - owner_vwap_y) < _mt or math.abs(median_val - owner_vwap_y) < _mt))
            if _m_y
                _dir_y = not na(vwap_y) ? (vwap_y < ref - _mt ? '↓' : vwap_y > ref + _mt ? '↑' : '') : ''
                _c += ' Ⓨ' + _dir_y + ' ⱽᵂᴬᴾ'

        // Yearly VWAP Bands (Ⓨ ↓/↑ ⱽᵂᴬᴾ⁺ⁿσ/⁻ⁿσ): compare level with ±1σ/2σ/3σ
        // Sign in f_sigma_sup() — band position relative to the VWAP line (+ above / − below), arrow — band position relative to the level
        if need_vwap_y_bands
            for i = 0 to 5
                float _owner_band = array.get(owner_vwap_y_bands, i)
                if not na(_owner_band)
                    bool _m_yb = math.abs(val - _owner_band) < _mt or
                       (not na(val2) and (math.abs(val2 - _owner_band) < _mt or math.abs(median_val - _owner_band) < _mt))
                    if _m_yb
                        float _band_price = array.get(band_y_price, i)
                        int   _band_n     = array.get(band_y_mult, i)
                        string _dir_yb    = not na(_band_price) ? (_band_price < ref - _mt ? '↓' : _band_price > ref + _mt ? '↑' : '') : ''
                        _c += ' Ⓨ' + _dir_yb + ' ⱽᵂᴬᴾ' + f_sigma_sup(_band_n) + 'σ'
    _c

// --- 3.5.3 Synergy Score ---
// Multi-layered confidence evaluation system for a level.
// WEIGHTS
//   Pivots: D=1.0, W=2.0, M=3.5
//   VWAP:   D=0.5, W=1.5, M=2.5
//           Y (main line)=3.5, Y ±1σ=3.0, Y ±2σ=3.7, Y ±3σ=4.2
//           (Bands are weighted separately from the main line — see W_VWAP_Y_S1/S2/S3 below)
// MODIFIERS
//   • Key level: ×1.3 (applies only to structure, not VWAP).
//     Key levels include: CP/R3/S3/R4/S4 (structural reversals), and targets
//     R4.5/R5/S4.5/S5 — see is_key=true in f_lbl_text() calls below.
//     This is intentional: target levels also participate in MTF pivot confluence
//     and receive the same "key" status bonus as classic reversals.
//   • Diversity (3+ TFs): ×1.25
// VWAP QUALITY (FACTOR-BY-FACTOR — not a single aggregate for the whole VWAP pool)
//   A separate quality multiplier is calculated for each VWAP factor (D/W/M/Y) individually
//   and immediately applied to its own weight, so a strong higher-TF signal is no longer
//   diluted by a weak/contradictory lower-TF signal (and vice versa):
//   • Exact match: ×1.5 (strongest signal)
//   • Confirming arrow: ×1.0 (strong signal)
//   • Contradictory arrow: ×0.0 (nullifies ONLY the contribution of that exact factor)
//   • For neutral levels (CP): ×1.0 (arrows are considered equal)
// CALCULATION STAGES
//   1. ATR Gatekeeper: eliminates levels with <30% of a daily move
//   2. Calculate quality individually for each VWAP factor (D/W/M/Y)
//   3. Structure base: score_pivot = p_d×1.0 + p_w×2.0 + p_m×3.5
//   4. VWAP base: score_vwap = v_d×0.5×q_d + v_w×1.5×q_w + v_m×2.5×q_m + v_y×W_y(σ)×q_y,
//      where W_y(σ) is the Y-factor weight depending on whether it's the main line
//      or a ±1σ/2σ/3σ band (see f_vwap_y_weight)
//   5. MUST-HAVE: Requires at least one higher EFFECTIVE factor (quality > 0)
//      by TF category — W (p_w OR eff_v_w), M (p_m OR eff_v_m), Y (eff_v_y).
//      A contradictory (nullified) VWAP factor no longer passes the gate.
//   6. ATR Catalyst: 50-99% move → ×1.0 (base strength), ≥100% → ×1.25 (exhaustion)
//   7. Diversity bonus: 3+ EFFECTIVE TFs → ×1.25 (nullified contra-factors
//      are not counted towards diversity)
//   8. MIN_ACTIVE_SOURCES: Along with MUST-HAVE, at least 2 effective
//      sources are required (any combination of D/W/M/Y). This prevents a single
//      powerful factor (e.g., one exact Yearly VWAP touch) from single-handedly
//      forming "Synergy" — the name implies the merging of SEVERAL independent
//      confirmations, not just the sheer strength of one.

// --- Weight Coefficients (Constants) ---
var float W_PIVOT_D      = 1.0
var float W_PIVOT_W      = 2.0
var float W_PIVOT_M      = 3.5
var float W_VWAP_D       = 0.5
var float W_VWAP_W       = 1.5
var float W_VWAP_M       = 2.5
var float W_VWAP_Y       = 3.5  // Base weight for the Yearly VWAP (main line)
// Yearly VWAP bands (±1σ/2σ/3σ) are weighted separately from the main line:
// ±1σ — frequent typical deviation, weight slightly lower than base;
// ±2σ/±3σ — rarer extreme zones, weight higher than base.
var float W_VWAP_Y_S1    = 3.0
var float W_VWAP_Y_S2    = 3.7
var float W_VWAP_Y_S3    = 4.2
var float W_KEY_MUL      = 1.3
var float W_DIV_BONUS    = 1.25
var int   MIN_ACTIVE_SOURCES = 2  // Minimum effective sources required for assigning a score (see pt.8)

// Step-based ATR filter thresholds (% of a daily move), see calc_synergy_score
var float ATR_GATE_MIN     = 30.0   // below this — level gets discarded by the gate (pt.1)
var float ATR_WORKING_MOVE = 50.0   // working move: no penalties or bonuses (pt.6)
var float ATR_EXTREME_MOVE = 100.0  // extreme exhaustion: ×1.25 to the final score (pt.6)

// Y-factor weight depending on whether it's the main VWAP line or one of the σ-bands
f_vwap_y_weight(int sigma_y) =>
    float w = W_VWAP_Y
    if sigma_y == 1
        w := W_VWAP_Y_S1
    else if sigma_y == 2
        w := W_VWAP_Y_S2
    else if sigma_y == 3
        w := W_VWAP_Y_S3
    w

// Quality of ONE VWAP factor based on its direction code.
// dir: 0=no match, 1=exact, 2=VWAP below level, 3=VWAP above level
// For neutral levels (CP), any match weighs x1.0 (no exact bonus,
// no direction penalty — arrows for CP are equal).
f_vwap_factor_quality(int dir, bool is_resistance, bool is_neutral) =>
    float q = 0.0
    if dir != 0
        if is_neutral
            q := 1.0
        else if dir == 1
            q := 1.5  // exact match — strongest signal
        else
            // Confirmation: resistance — VWAP from below (dir==2); support — VWAP from above (dir==3)
            bool is_confirm = is_resistance ? dir == 2 : dir == 3
            q := is_confirm ? 1.0 : 0.0  // contradiction completely nullifies ONLY this factor
    q

// --- Synergy Score Calculation Function ---
calc_synergy_score(SynergyFactors sf, float atr_pct, bool is_key, bool is_resistance, bool is_neutral = false) =>
    
    // 1. Strict ATR Filter (Gatekeeper)
    // Reversal levels are discarded if less than 30% of a daily move has passed.
    // The atr_pct > 0.0 condition protects the logic if ATR is disabled in settings.
    if not is_neutral and atr_pct > 0.0 and atr_pct < ATR_GATE_MIN
        float(na)
    else
        // 2. Quality of EACH VWAP factor individually (not a single aggregate for the pool)
        // Anchor Time Dedup: if anchor D matches anchor W OR anchor M — it is the same
        // VWAP accumulator shown twice — D gets nullified in favor of the higher one.
        // If anchor W matches M — W gets nullified in favor of M.
        // (see dup_dw/dup_dm/dup_wm above, block 3.5.2). Comparison is pairwise, not just
        // a D->W->M chain: the 1st day of a month could be a Wednesday — anchor D matches
        // anchor M directly, skipping the weekly one (which anchored on Monday).
        float q_d = (dup_dw or dup_dm) ? 0.0 : f_vwap_factor_quality(sf.dir_d, is_resistance, is_neutral)
        float q_w = dup_wm ? 0.0 : f_vwap_factor_quality(sf.dir_w, is_resistance, is_neutral)
        float q_m = f_vwap_factor_quality(sf.dir_m, is_resistance, is_neutral)
        float q_y = f_vwap_factor_quality(sf.dir_y, is_resistance, is_neutral)

        // "Effective" factor — counted only if it actually provided a non-zero contribution
        // (a nullified contradictory VWAP factor does not count towards gates and diversity)
        bool eff_v_d = sf.v_d > 0 and q_d > 0
        bool eff_v_w = sf.v_w > 0 and q_w > 0
        bool eff_v_m = sf.v_m > 0 and q_m > 0
        bool eff_v_y = sf.v_y > 0 and q_y > 0

        // 3. Structure points base (Price Action)
        float score_pivot = (sf.p_d * W_PIVOT_D) + (sf.p_w * W_PIVOT_W) + (sf.p_m * W_PIVOT_M)
        
        // Key level bonus applies ONLY to structure (eliminates inflation)
        if is_key
            score_pivot *= W_KEY_MUL

        // 4. Volume points base (VWAP + Bands) — quality and weight applied individually to each factor;
        //    for Y-factor, the weight depends on whether it's the main line or a ±1σ/2σ/3σ band (see f_vwap_y_weight)
        float score_vwap = (sf.v_d * W_VWAP_D * q_d) + (sf.v_w * W_VWAP_W * q_w) + (sf.v_m * W_VWAP_M * q_m) + (sf.v_y * f_vwap_y_weight(sf.sigma_y) * q_y)

        // 5. MUST-HAVE: Requires presence of a higher EFFECTIVE factor (W, M or Y)
        bool has_w_factor = sf.p_w > 0 or eff_v_w
        bool has_m_factor = sf.p_m > 0 or eff_v_m
        bool has_y_factor = eff_v_y
        bool has_senior   = has_w_factor or has_m_factor or has_y_factor

        // Count of effective sources (D/W/M/Y) — counted BEFORE the gate, since it is now
        // used both as a mandatory condition (pt.8) and a bonus condition (pt.7)
        int active_tf = ((sf.p_d > 0 or eff_v_d ? 1 : 0) + (sf.p_w > 0 or eff_v_w ? 1 : 0) + (sf.p_m > 0 or eff_v_m ? 1 : 0) + (eff_v_y ? 1 : 0))

        // pt.5 + pt.8: Require NOT ONLY a higher factor (MUST-HAVE), but also at least MIN_ACTIVE_SOURCES
        // independent sources — a single (even if powerful) factor can no longer
        // single-handedly form "Synergy"
        if not has_senior or (score_pivot + score_vwap == 0) or active_tf < MIN_ACTIVE_SOURCES
            float(na)
        else
            float base_total = score_pivot + score_vwap

            // 6. Step-based ATR Catalyst
            float atr_mult = 1.0
            if atr_pct >= ATR_EXTREME_MOVE
                atr_mult := 1.25 // Extreme exhaustion (+25% to overall strength)
            else if atr_pct >= ATR_WORKING_MOVE
                atr_mult := 1.00 // Working move 50-99% (base strength, no penalties or bonuses)

            float total = base_total * atr_mult

            // 7. Timeframe Diversity Bonus (>= 3 EFFECTIVE sources)
            if active_tf >= 3
                total *= W_DIV_BONUS

            total

// --- Synergy Determination Function ---
f_is_synergy(float score) =>
    in_synergy_en and not na(score) and score >= in_synergy_thr

// Factor Collection Function
f_collect_factors(float val, bool is_key, bool is_vwap_eligible, float val2 = na, int own_idx = -1) =>
    SynergyFactors sf = SynergyFactors.new(0,0,0, 0,0,0,0, 0,0,0,0, 0)

    if is_conf_active and is_key
        if f_check_conf_name(val, lvl_d_conf, h_d_conf, l_d_conf, calc_conf_tol, own_idx, in_tf != 'D') != ""
            sf.p_d := 1
        if f_check_conf_name(val, lvl_w_conf, h_w_conf, l_w_conf, calc_conf_tol, own_idx, in_tf != 'W') != ""
            sf.p_w := 1
        if f_check_conf_name(val, lvl_m_conf, h_m_conf, l_m_conf, calc_conf_tol, own_idx, in_tf != 'M') != ""
            sf.p_m := 1

    if is_vwap_eligible and in_mtf_conf_vwap and in_period == 'Current' and not is_chart_monthly_or_higher
        float med_val = not na(val2) ? (val + val2) / 2.0 : val
        float _mt     = syminfo.mintick

        // D-VWAP: direction is recorded individually (1=exact, 2=VWAP below, 3=VWAP above)
        if not na(owner_vwap_d) and (math.abs(val - owner_vwap_d) < _mt or (not na(val2) and (math.abs(val2 - owner_vwap_d) < _mt or math.abs(med_val - owner_vwap_d) < _mt)))
            sf.v_d := 1
            if not na(vwap_d)
                if vwap_d < med_val - _mt
                    sf.dir_d := 2
                else if vwap_d > med_val + _mt
                    sf.dir_d := 3
                else
                    sf.dir_d := 1

        // W-VWAP
        if not na(owner_vwap_w) and (math.abs(val - owner_vwap_w) < _mt or (not na(val2) and (math.abs(val2 - owner_vwap_w) < _mt or math.abs(med_val - owner_vwap_w) < _mt)))
            sf.v_w := 1
            if not na(vwap_w)
                if vwap_w < med_val - _mt
                    sf.dir_w := 2
                else if vwap_w > med_val + _mt
                    sf.dir_w := 3
                else
                    sf.dir_w := 1

        // M-VWAP
        if not na(owner_vwap_m) and (math.abs(val - owner_vwap_m) < _mt or (not na(val2) and (math.abs(val2 - owner_vwap_m) < _mt or math.abs(med_val - owner_vwap_m) < _mt)))
            sf.v_m := 1
            if not na(vwap_m)
                if vwap_m < med_val - _mt
                    sf.dir_m := 2
                else if vwap_m > med_val + _mt
                    sf.dir_m := 3
                else
                    sf.dir_m := 1

        // Y-VWAP (main) OR its bands (±1σ/2σ/3σ)
        bool y_match = false
        float y_ref_price = na  // Price for determining the arrow (VWAP or a specific band)
        int   y_sigma_lvl = 0   // 0 = main line, 1/2/3 = matched σ-band
        
        // 1. Check main Yearly VWAP (priority)
        if not na(owner_vwap_y) and (math.abs(val - owner_vwap_y) < _mt or (not na(val2) and (math.abs(val2 - owner_vwap_y) < _mt or math.abs(med_val - owner_vwap_y) < _mt)))
            y_match := true
            y_ref_price := vwap_y
            y_sigma_lvl := 0
            
        // 2. If no match with the main line, check bands (±1σ/2σ/3σ)
        if need_vwap_y_bands and not y_match
            for i = 0 to 5
                float _owner_band = array.get(owner_vwap_y_bands, i)
                if not na(_owner_band)
                    if math.abs(val - _owner_band) < _mt or (not na(val2) and (math.abs(val2 - _owner_band) < _mt or math.abs(med_val - _owner_band) < _mt))
                        y_match := true
                        y_ref_price := array.get(band_y_price, i)  // Base arrow on the band price
                        y_sigma_lvl := math.abs(array.get(band_y_mult, i))  // 1/2/3 — which specific band
                        break
                        
        // 3. Award points if anything matched (main VWAP or band)
        if y_match
            sf.v_y     := 1
            sf.sigma_y := y_sigma_lvl
            if not na(y_ref_price)
                if y_ref_price < med_val - _mt
                    sf.dir_y := 2
                else if y_ref_price > med_val + _mt
                    sf.dir_y := 3
                else
                    sf.dir_y := 1
    sf

// --- 3.6 ATR Exhaustion Filter Data ---
// TF Selection for ATR Calculation
// We use calc_tf/roll_tf (same as pivots, block 3.1), instead of raw 'D'/in_tf —
// otherwise with in_last_trd (LTP) enabled, pivots calculate from the '1440' session,
// but ATR (and pivot_open) calculate from the 'D' session. On CME futures, these sessions
// start at different times, desyncing HLC pivot lines and exhaustion markers by several hours.
var atr_tf = in_atr_tf_mode == 'Pivot TF' ? calc_tf : roll_tf  // session constant

// Disable ATR if chart TF is higher than the ATR TF
var bool is_atr_tf_valid = timeframe.in_seconds(atr_tf) >= timeframe.in_seconds()

// Fetch ATR base (Open, ATR[1], Time) via a single call for optimization and synchronization
[_raw_pivot_open, _raw_atr_val, _raw_atr_time] = request.security(fetch_sym, atr_tf, [open, ta.atr(in_atr_period)[1], time], barmerge.gaps_off, barmerge.lookahead_on)

// ATR for Synergy Score (independent of UI settings)
// • Base (open) = Pivot TF (calc_tf): protects against false resets mid-period.
// • ATR Value = fixed 1D ('D'): keeps thresholds (30/50/100%) attainable 
//   on higher TFs (measures distance from period start in "daily moves").
_syn_pivot_open = request.security(fetch_sym, calc_tf, open, barmerge.gaps_off, barmerge.lookahead_on)
_syn_atr_val    = request.security(fetch_sym, 'D', ta.atr(in_atr_period)[1], barmerge.gaps_off, barmerge.lookahead_on)
var bool is_syn_atr_valid = timeframe.in_seconds('D') >= timeframe.in_seconds()

// --- 3.6.1 ATR Exhaustion: Active Exhaustion Levels ---
_is_atr_active  = in_atr_filter and is_atr_tf_valid and not is_chart_monthly_or_higher and not in_pivots_off
pivot_open      = _is_atr_active ? _raw_pivot_open : na
atr_val         = _is_atr_active ? _raw_atr_val    : na
atr_time        = _is_atr_active ? _raw_atr_time   : na

// Global variables for memory of current period extremes
var float atr_period_high = na
var float atr_period_low  = na

// Track absolute extremes for the ATR filter
// na(_atr_ch) excluded from reset condition to protect against false wipes during data micro-failures.
// Initial and repeat activations are safely covered by the na(atr_period_high) check, 
// as the variable is forcefully cleared in the else branch when the filter turns off.
_atr_ch = ta.change(atr_time)
if _is_atr_active
    if na(atr_period_high) or (not na(_atr_ch) and _atr_ch != 0)
        atr_period_high := high
        atr_period_low  := low
    else
        atr_period_high := math.max(atr_period_high, high)
        atr_period_low  := math.min(atr_period_low, low)
else
    atr_period_high := na
    atr_period_low  := na

// Base ATR condition: evaluated once at a global level for optimization
bool _atr_base_cond = in_atr_filter and is_atr_tf_valid and in_period == 'Current' and not na(atr_val) and not na(pivot_open)

// Level exhausted: price moved beyond ATR × multiplier from period open
f_is_exhausted(lvl_price) =>
    _atr_base_cond and not na(lvl_price) and math.abs(lvl_price - pivot_open) >= atr_val * in_atr_mult

// Find the closest resistance to place the marker (excluding intermediate R3.5/S3.5)
f_next_resistance(lvl, show_targets) =>
    float _res = na
    if f_is_exhausted(lvl.r3) and atr_period_high < lvl.r3
        _res := lvl.r3
    else if f_is_exhausted(lvl.r4) and atr_period_high < lvl.r4
        _res := lvl.r4
    else if show_targets and f_is_exhausted(lvl.r4_5) and atr_period_high < lvl.r4_5
        _res := lvl.r4_5
    else if show_targets and f_is_exhausted(lvl.r5) and atr_period_high < lvl.r5
        _res := lvl.r5
    _res

// Check levels against the absolute minimum (atr_period_low), not the candle
f_next_support(lvl, show_targets) =>
    float _sup = na
    if f_is_exhausted(lvl.s3) and atr_period_low > lvl.s3
        _sup := lvl.s3
    else if f_is_exhausted(lvl.s4) and atr_period_low > lvl.s4
        _sup := lvl.s4
    else if show_targets and f_is_exhausted(lvl.s4_5) and atr_period_low > lvl.s4_5
        _sup := lvl.s4_5
    else if show_targets and f_is_exhausted(lvl.s5) and atr_period_low > lvl.s5
        _sup := lvl.s5
    _sup

// Exhaustion Marker: ▾/▴ — active zone, ▿/▵ — exhausted, with % of ATR
f_exh_marker(level_price, is_resistance, active_resistance, active_support) =>
    bool hit_res = f_is_exhausted(level_price) and not na(atr_period_high) and atr_period_high >= level_price
    bool hit_sup = f_is_exhausted(level_price) and not na(atr_period_low)  and atr_period_low  <= level_price
    bool is_hit  = is_resistance ? hit_res : hit_sup

    string result = ""
    if is_resistance
        if not na(active_resistance) and math.abs(level_price - active_resistance) < syminfo.mintick
            result := " ▾"
        else if is_hit
            result := " ▿"
    else
        if not na(active_support) and math.abs(level_price - active_support) < syminfo.mintick
            result := " ▴"
        else if is_hit
            result := " ▵"

    // Add exhaustion percentage with superscript ATR and calculation mode label
    if result != "" and not na(atr_val) and atr_val > 0 and not na(pivot_open)
        float dist = math.abs(level_price - pivot_open)
        float pct  = (dist / atr_val) * 100
        // Determine the calculation mode suffix: D (Daily) or P (Pivot-based)
        string atr_mode = in_atr_tf_mode == 'Daily' ? ' ᴰ' : ' ᴾ'
        result := str.format("{0}{1, number, #.#}% ᴬᵀᴿ{2}", result, pct, atr_mode)
    result

// Confluence Marker: «Ⓓ R3» / «Ⓦ High» / «Ⓜ CP» etc.
f_get_conf_marker(val, is_key, int own_idx = -1) =>
    string _c = ""

    if is_conf_active and is_key
        string match_d = f_check_conf_name(val, lvl_d_conf, h_d_conf, l_d_conf, calc_conf_tol, own_idx, in_tf != 'D')
        if match_d != ""
            _c += ' Ⓓ ' + match_d

        string match_w = f_check_conf_name(val, lvl_w_conf, h_w_conf, l_w_conf, calc_conf_tol, own_idx, in_tf != 'W')
        if match_w != ""
            _c += ' Ⓦ ' + match_w

        string match_m = f_check_conf_name(val, lvl_m_conf, h_m_conf, l_m_conf, calc_conf_tol, own_idx, in_tf != 'M')
        if match_m != ""
            _c += ' Ⓜ ' + match_m
    _c

// Remove leading space from marker string
f_trim_lead(s) =>
    str.length(s) > 0 and str.substring(s, 0, 1) == ' ' ? str.substring(s, 1, str.length(s)) : s

// Converts standard digits to superscript
f_to_superscript(string s) =>
    string res = s
    res := str.replace_all(res, "0", "⁰")
    res := str.replace_all(res, "1", "¹")
    res := str.replace_all(res, "2", "²")
    res := str.replace_all(res, "3", "³")
    res := str.replace_all(res, "4", "⁴")
    res := str.replace_all(res, "5", "⁵")
    res := str.replace_all(res, "6", "⁶")
    res := str.replace_all(res, "7", "⁷")
    res := str.replace_all(res, "8", "⁸")
    res := str.replace_all(res, "9", "⁹")
    res := str.replace_all(res, ".", "·")
    res

// Final Synergy Badge Generator
f_get_synergy_badge(float val, bool is_key, bool is_vwap_eligible, bool is_res, bool is_neutral = false, float val2 = na, int own_idx = -1) =>
    string badge = ""
    // Synergy lock on TFs higher than daily: ATR gate uses daily ATR,
    // which does not work on Weekly+ charts (timeframe.in_seconds('D') < timeframe.in_seconds())
    if in_synergy_en and not na(val) and is_syn_atr_valid
        SynergyFactors sf = f_collect_factors(val, is_key, is_vwap_eligible, val2, own_idx)
        float atr_pct = 0.0
        if is_syn_atr_valid and not na(_syn_atr_val) and _syn_atr_val > 0 and not na(_syn_pivot_open)
            atr_pct := (math.abs(val - _syn_pivot_open) / _syn_atr_val) * 100.0
            
        float score = calc_synergy_score(sf, atr_pct, is_key, is_res, is_neutral)
        if f_is_synergy(score)
            // If toggle is enabled, append the numbers, otherwise leave a clean icon
            string _score_str = in_syn_score_show ? f_to_superscript(str.tostring(score, "#.##")) : ""
            badge := " ⋈" + _score_str
    badge

f_build_symbols(val, is_res, act_res, act_sup, is_key, is_vwap_eligible, is_neutral = false, int own_idx = -1) =>
    string _m   = f_exh_marker(val, is_res, act_res, act_sup)
    string _c   = f_get_conf_marker(val, is_key, own_idx)
    string _v   = is_vwap_eligible ? f_get_vwap_marker(val) : ""
    string _syn = f_get_synergy_badge(val, is_key, is_vwap_eligible, is_res, is_neutral, na, own_idx)
    
    string _prefix  = _syn + _c + _v
    string _all_sym = _m != "" ? (_prefix != "" ? _prefix + _m : _m) : _prefix
    _all_sym

f_lbl_text(show_lbl, name, val, is_res, act_res, act_sup, is_key, is_vwap_eligible, is_neutral = false, int own_idx = -1) =>
    string symbols = f_build_symbols(val, is_res, act_res, act_sup, is_key, is_vwap_eligible, is_neutral, own_idx)
    show_lbl ? f_txt(name, val) + symbols : f_trim_lead(symbols)

f_lbl_text2(show_lbl, name, v1, v2, exh_ref, is_res, act_res, act_sup, is_key, is_vwap_eligible, string vwap_str = "", is_neutral = false, int own_idx = -1) =>
    string _c   = f_get_conf_marker(exh_ref, is_key, own_idx)
    string _v   = vwap_str != "" ? vwap_str : (is_vwap_eligible ? f_get_vwap_marker(exh_ref) : "")
    bool effective_vwap_elig = is_vwap_eligible or (vwap_str != "")
    string _syn = f_get_synergy_badge(exh_ref, is_key, effective_vwap_elig, is_res, is_neutral, v1 == exh_ref ? v2 : v1, own_idx)
    string _m   = f_exh_marker(exh_ref, is_res, act_res, act_sup)
    
    string _prefix   = _syn + _c + _v
    string final_sym = _m != "" ? (_prefix != "" ? _prefix + _m : _m) : _prefix
    show_lbl ? f_txt2(name, v1, v2) + final_sym : f_trim_lead(final_sym)

f_lbl_text_simple(show_lbl, name, val, is_key, is_vwap_eligible, is_resistance, is_neutral = false, int own_idx = -1) =>
    string _c   = f_get_conf_marker(val, is_key, own_idx)
    string _v   = is_vwap_eligible ? f_get_vwap_marker(val) : ""
    string _syn = f_get_synergy_badge(val, is_key, is_vwap_eligible, is_resistance, is_neutral, na, own_idx)
    
    // Order: Synergy -> Confluence -> VWAP
    string final_sym = _syn + _c + _v
    if show_lbl
        final_sym != "" ? f_txt(name, val) + final_sym : f_txt(name, val)
    else
        f_trim_lead(final_sym)

// HLC Labels Formatter Function
f_lbl_hlc(show_lbl, name, val) =>
    show_lbl ? f_txt(name, val) : ""

// --- 3.7 Generate Level Objects ---
PivotLevels curr_lvl = calc_pivots(p_high,   p_low,   p_close)
PivotLevels next_lvl = calc_pivots(n_high,   n_low,   n_close)
PivotLevels prev_lvl = calc_pivots(pp_high,  pp_low,  pp_close)

// --- 3.7.1 Populate candidate array for exclusive MTF confluence search ---
if barstate.islast and is_conf_active
    array.clear(conf_candidates)
    // Add only those levels that visually display confluence markers
    array.push(conf_candidates, curr_lvl.r5)
    array.push(conf_candidates, curr_lvl.r4_5)
    array.push(conf_candidates, curr_lvl.r4)
    array.push(conf_candidates, curr_lvl.r3)
    array.push(conf_candidates, curr_lvl.cp)
    array.push(conf_candidates, curr_lvl.s3)
    array.push(conf_candidates, curr_lvl.s4)
    array.push(conf_candidates, curr_lvl.s4_5)
    array.push(conf_candidates, curr_lvl.s5)

// --- 3.7.2 Assign "owners" to VWAP markers ---
var array<float> vwap_targets = array.new<float>()

if barstate.islast and in_mtf_conf_vwap and in_period == 'Current' and not is_chart_monthly_or_higher and not in_pivots_off
    array.clear(vwap_targets)
    array.push(vwap_targets, curr_lvl.cp)
    // Adding R3-R3.5 zone boundaries and median to candidates array
    array.push(vwap_targets, curr_lvl.r3)                          // lower bound of R zone
    array.push(vwap_targets, (curr_lvl.r3 + curr_lvl.r3_5) / 2)    // median of R zone
    array.push(vwap_targets, curr_lvl.r3_5)                        // upper bound of R zone
    // S3–S3.5 zone: identically (S3.5 < S3 by price, so lower bound = S3.5)
    array.push(vwap_targets, curr_lvl.s3_5)                        // lower bound of S zone
    array.push(vwap_targets, (curr_lvl.s3 + curr_lvl.s3_5) / 2)    // median of S zone
    array.push(vwap_targets, curr_lvl.s3)                          // upper bound of S zone
    array.push(vwap_targets, curr_lvl.r4)
    array.push(vwap_targets, curr_lvl.s4)
    array.push(vwap_targets, curr_lvl.r4_5)
    array.push(vwap_targets, curr_lvl.s4_5)
    array.push(vwap_targets, curr_lvl.r5)
    array.push(vwap_targets, curr_lvl.s5)

    // Find nearest level to VWAP via f_get_vwap_owner_zoned:
    // Priority — falls into R3-R3.5/S3-S3.5/CPR zones without tolerance checks.
    // In case zones overlap, select the one whose center is closest to VWAP.
    owner_vwap_d := f_get_vwap_owner_zoned(vwap_d, vwap_targets, calc_conf_vwap_tol, curr_lvl.r3, curr_lvl.r3_5, curr_lvl.s3, curr_lvl.s3_5, curr_lvl.bc, curr_lvl.tc, curr_lvl.cp)
    owner_vwap_w := f_get_vwap_owner_zoned(vwap_w, vwap_targets, calc_conf_vwap_tol, curr_lvl.r3, curr_lvl.r3_5, curr_lvl.s3, curr_lvl.s3_5, curr_lvl.bc, curr_lvl.tc, curr_lvl.cp)
    owner_vwap_m := f_get_vwap_owner_zoned(vwap_m, vwap_targets, calc_conf_vwap_tol, curr_lvl.r3, curr_lvl.r3_5, curr_lvl.s3, curr_lvl.s3_5, curr_lvl.bc, curr_lvl.tc, curr_lvl.cp)
    owner_vwap_y := f_get_vwap_owner_zoned(vwap_y, vwap_targets, calc_conf_vwap_tol, curr_lvl.r3, curr_lvl.r3_5, curr_lvl.s3, curr_lvl.s3_5, curr_lvl.bc, curr_lvl.tc, curr_lvl.cp)

    // Assign "owners" for every Yearly VWAP band (±1σ/2σ/3σ), prioritizing R3-R3.5/S3-S3.5/CPR zones
    if need_vwap_y_bands
        for i = 0 to 5
            array.set(owner_vwap_y_bands, i, f_get_vwap_owner_zoned(array.get(band_y_price, i), vwap_targets, calc_conf_vwap_tol, curr_lvl.r3, curr_lvl.r3_5, curr_lvl.s3, curr_lvl.s3_5, curr_lvl.bc, curr_lvl.tc, curr_lvl.cp))
    else
        array.fill(owner_vwap_y_bands, na)
else if barstate.islast
    // Clear owners upon VWAP toggle-off
    owner_vwap_d := na
    owner_vwap_w := na
    owner_vwap_m := na
    owner_vwap_y := na
    array.fill(owner_vwap_y_bands, na)  // Clear band owners

// --- 3.8 Build HlcData Objects for Each Displayed Period ---
// Current: HLC lines extend from previous period, visualizing the base for current pivots
hlc_curr = HlcData.new(h=p_high,  l=p_low,  c=p_close,  x_start=p_t_start,  x_end=t_end)
// Previous: HLC lines from two periods ago, extended to the end of the current period
hlc_prev = HlcData.new(h=pp_high, l=pp_low, c=pp_close, x_start=pp_t_start, x_end=t_end)
// Projection: HLC lines from start of current period, visualizing the base for a forecast
hlc_next = HlcData.new(h=n_high,  l=n_low,  c=n_close,  x_start=t_start,    x_end=n_t_end)

// --- 3.9 Timeframe Error Protection ---
// Validate Chart TF
var is_vis = switch
    timeframe.isseconds  => true
    timeframe.isintraday => true
    timeframe.isdaily    => in_tf == 'W' or in_tf == 'M'
    timeframe.isweekly   => in_tf == 'M'
    timeframe.ismonthly  => false  // kill switch: monthly and higher always blocked
    => false

// Global "Period Boundary" flag
// Triggers if real-time has surpassed the scheduled closing time
// of the CURRENT pivot period (t_end, block 3.1), but feed still returns old period —
// meaning data is objectively outdated (feed/provider delay).
// Evaluated every bar (not just islast), so it's accessible everywhere.
bool is_boundary_blocked = false
if is_vis
    is_boundary_blocked := not na(t_end) and timenow > t_end

// Deletes the warning table if it exists, and returns a na-pointer.
// Used for uniformly cleaning all warning tables (see below).
f_clear_table(table t) =>
    if not na(t)
        table.delete(t)
    table(na)

// Initialize empty pointers
var table _warn_tbl          = na 
var table _atr_warn_tbl      = na 
var table _syn_warn_tbl      = na 
var table _no_data_tbl       = na 
var table _monthly_warn_tbl  = na 
var table _boundary_warn_tbl = na

if barstate.islast
    // Kill Switch (Monthly+ TF)
    if is_chart_monthly_or_higher
        if na(_monthly_warn_tbl)
            _monthly_warn_tbl := table.new(position.top_center, 1, 1, bgcolor=color.new(color.red, 30), border_color=color.new(color.red, 20), border_width=1, frame_color=color.new(color.red, 20), frame_width=1)
        table.cell(_monthly_warn_tbl, 0, 0, '⚠ MTF Pivots+\nMonthly TF and higher are not supported.\nSwitch to a weekly or lower TF.', text_color=color.white, text_size=size.normal)
        
        // Forceful cleanup of all other warnings
        _warn_tbl           := f_clear_table(_warn_tbl)
        _atr_warn_tbl       := f_clear_table(_atr_warn_tbl)
        _syn_warn_tbl       := f_clear_table(_syn_warn_tbl)
        _no_data_tbl        := f_clear_table(_no_data_tbl)
        _boundary_warn_tbl  := f_clear_table(_boundary_warn_tbl)

    // Boundary Blocked (period change in real-time)
    else if is_boundary_blocked
        if na(_boundary_warn_tbl)
            _boundary_warn_tbl := table.new(position.top_center, 1, 1, bgcolor=color.new(color.red, 30), border_color=color.new(color.red, 20), border_width=1, frame_color=color.new(color.red, 20), frame_width=1)
        
        table.cell(_boundary_warn_tbl, 0, 0, '⚠ Awaiting Data\nThe current period time has expired.\n' + (in_pivots_off ? 'New data will appear automatically\nonce the market opens.' : 'New pivots will appear automatically\nonce the market opens.'), text_color=color.white, text_size=size.normal)
        
        // Forceful cleanup of all other warnings
        _warn_tbl           := f_clear_table(_warn_tbl)
        _atr_warn_tbl       := f_clear_table(_atr_warn_tbl)
        _syn_warn_tbl       := f_clear_table(_syn_warn_tbl)
        _no_data_tbl        := f_clear_table(_no_data_tbl)
        _monthly_warn_tbl   := f_clear_table(_monthly_warn_tbl)

    else
        // All blockages lifted — standard checks
        _monthly_warn_tbl  := f_clear_table(_monthly_warn_tbl)
        _boundary_warn_tbl := f_clear_table(_boundary_warn_tbl)
        
        // 1. Incompatible Pivot TF (meaningless once pivots are turned off)
        if not in_pivots_off and not is_vis
            if na(_warn_tbl)
                _warn_tbl := table.new(position.bottom_right, 1, 1, bgcolor=color.new(color.orange, 20), border_color=color.orange, border_width=1, frame_color=color.orange, frame_width=1)
            table.cell(_warn_tbl, 0, 0, '⚠ MTF Pivots+\nPivot TF is lower than the chart TF!\nDecrease the chart TF or increase the pivot TF.', text_color=color.white, text_size=size.normal)
        else
            _warn_tbl := f_clear_table(_warn_tbl)

        // 2. ATR Desync (ATR Exhaustion has nothing to mark once pivots are off)
        if not in_pivots_off and in_atr_filter and not is_atr_tf_valid
            if na(_atr_warn_tbl)
                _atr_warn_tbl := table.new(position.bottom_left, 1, 1, bgcolor=color.new(color.orange, 20), border_color=color.orange, border_width=1, frame_color=color.orange, frame_width=1)
            table.cell(_atr_warn_tbl, 0, 0, '⚠ ATR Exhaustion\nExhaustion markers disabled.\nSelect "Pivot TF" or decrease the chart TF.', text_color=color.white, text_size=size.normal)
        else
            _atr_warn_tbl := f_clear_table(_atr_warn_tbl)

        // 3. Synergy Warnings (consolidated to center position) — Synergy has nothing to badge
        // once pivots are off, so both variants are suppressed together
        bool syn_can_work = in_mtf_conf or in_mtf_conf_vwap
        
        if in_pivots_off
            _syn_warn_tbl := f_clear_table(_syn_warn_tbl)
        else if in_synergy_en and not is_syn_atr_valid
            // Priority 1: Fundamental lock due to TF
            if na(_syn_warn_tbl)
                _syn_warn_tbl := table.new(position.middle_center, 1, 1, bgcolor=color.new(color.orange, 20), border_color=color.orange, border_width=1, frame_color=color.orange, frame_width=1)
            table.cell(_syn_warn_tbl, 0, 0, '⚠ Synergy (⋈)\nDisabled on current TF.\nATR gate uses daily ATR,\nswitch to a TF lower than 1D.', text_color=color.white, text_size=size.normal)
            
        else if in_synergy_en and not syn_can_work
            // Priority 2: Inactive sources (TF works, but confluence features are turned off)
            if na(_syn_warn_tbl)
                _syn_warn_tbl := table.new(position.middle_center, 1, 1, bgcolor=color.new(color.orange, 20), border_color=color.orange, border_width=1, frame_color=color.orange, frame_width=1)
            table.cell(_syn_warn_tbl, 0, 0, '⚠ Synergy (⋈)\nFactor sources are inactive!\nEnable "MTF Pivot Confluence"\nor "VWAP in Confluence".', text_color=color.white, text_size=size.normal)
            
        else
            // If all good, clear table
            _syn_warn_tbl := f_clear_table(_syn_warn_tbl)

        // 4. Missing Data
        bool _show_no_data = is_vis and (in_period != 'Projection' or barstate.isrealtime) and na(p_high)
        if _show_no_data
            if na(_no_data_tbl)
                _no_data_tbl := table.new(position.bottom_center, 1, 1, bgcolor=color.new(color.orange, 20), border_color=color.orange, border_width=1, frame_color=color.orange, frame_width=1)
            table.cell(_no_data_tbl, 0, 0, '⚠ MTF Pivots+\nNo data for: ' + fetch_sym + '\nDisable "Continuous contract" in settings\nor check the ticker.', text_color=color.white, text_size=size.normal)
        else
            _no_data_tbl := f_clear_table(_no_data_tbl)


// ===========================================================================================================
// BLOCK 4: DRAWING ENGINE
// ===========================================================================================================

// --- 4.1 Base Object Render Functions ---
// Render functions use 'var': objects are created once, and then simply updated
// Different call sites operate on independent objects

// Box border width: module constant, detached from render_box for a single place of modification
// Declared here (not inside the function) to avoid creating a var copy per call site
var int BOX_BORDER_WIDTH = 1

render_line(x1, y1, x2, y2, clr, ln_style) =>
    // Line width from in_line_width
    var line ln = line.new(na, na, na, na, xloc.bar_time, extend.none, clr, ln_style, in_line_width)
    bool _is_valid = not na(x1) and not na(x2) and not na(y1) and not na(y2)
    line.set_x1(ln, _is_valid ? x1 : na)
    line.set_y1(ln, _is_valid ? y1 : na)
    line.set_x2(ln, _is_valid ? x2 : na)
    line.set_y2(ln, _is_valid ? y2 : na)
    // Color and style initialized on creation (var line) as session constants (inputs)

render_box(x1, y_top, x2, y_bot, border_clr, bg_clr, brd_style) =>
    // BOX_BORDER_WIDTH — single constant for all boxes
    var box bx = box.new(na, na, na, na, border_clr, BOX_BORDER_WIDTH, brd_style, extend.none, xloc.bar_time, bg_clr)
    bool _is_valid = not na(x1) and not na(x2) and not na(y_top) and not na(y_bot)
    // Draw zone (box) with automatic coordinate correction (y_top > y_bot)
    _top = _is_valid ? math.max(y_top, y_bot) : na
    _bot = _is_valid ? math.min(y_top, y_bot) : na
    box.set_lefttop(bx, _is_valid ? x1 : na, _top)
    box.set_rightbottom(bx, _is_valid ? x2 : na, _bot)
    // set_bgcolor — dynamic color update
    box.set_bgcolor(bx, bg_clr)

render_lbl(x, y, txt, clr, lb_size) =>
    // Label "points" left from point x, displays to the right of it
    // In "Projection" mode it may go past the right edge — expected behavior
    var label lb = label.new(na, na, "", xloc.bar_time, yloc.price, color.new(color.white, 100), label.style_label_left, clr, lb_size, text.align_left)
    // Empty text (show_lbl=false + no ATR marker + no confluence) → hide label at (na, na)
    // so the object does not "hang" in its last position during real-time updates
    if txt != "" and not na(x) and not na(y)
        label.set_xy(lb, x, y)
        label.set_text(lb, txt)
        label.set_textcolor(lb, clr)
        label.set_size(lb, lb_size)
    else
        label.set_xy(lb, na, na)
        label.set_text(lb, "")

// --- 4.2 Main Function to Draw All Chart Elements ---
// All flags, styles, and colors are passed via DrawConfig (cfg) — full encapsulation
draw_elements(lvl, x_start, x_end, hlc, bg_cpr_color, cfg) =>
    // ATR markers strictly for major levels in "Current" mode
    bool _need_atr    = in_atr_filter and not cfg.show_hlc and in_period == 'Current'
    active_resistance = _need_atr ? f_next_resistance(lvl, cfg.show_targets) : na
    active_support    = _need_atr ? f_next_support(lvl, cfg.show_targets)    : na

    _ls = cfg.lbl_size
    _sl = cfg.show_lbl
    _ar = active_resistance
    _as = active_support

    if not cfg.show_hlc
        // Target levels R4.5–R5 (shown by flag) and extreme R4 (always)
        if cfg.show_targets
            render_line(x_start, lvl.r5, x_end, lvl.r5, cfg.col_r5, cfg.line_style)
            render_line(x_start, lvl.r4_5, x_end, lvl.r4_5, cfg.col_r4_5, cfg.line_style)
        render_line(x_start, lvl.r4, x_end, lvl.r4, cfg.col_r4, cfg.line_style)

        // Support and Resistance Zones R3–R3.5 and S3–S3.5 (lines + fill)
        render_line(x_start, lvl.r3,   x_end, lvl.r3,   cfg.col_r3_5, cfg.line_style)
        render_line(x_start, lvl.r3_5, x_end, lvl.r3_5, cfg.col_r3_5, cfg.line_style)
        // Invisible box border
        render_box(x_start, lvl.r3_5, x_end, lvl.r3, color.new(cfg.col_r3_5, 100), color.new(cfg.col_r3_5, 90), cfg.line_style)

        render_line(x_start, lvl.s3,   x_end, lvl.s3,   cfg.col_s3_5, cfg.line_style)
        render_line(x_start, lvl.s3_5, x_end, lvl.s3_5, cfg.col_s3_5, cfg.line_style)
        render_box(x_start, lvl.s3, x_end, lvl.s3_5, color.new(cfg.col_s3_5, 100), color.new(cfg.col_s3_5, 90), cfg.line_style)

        // Extreme S4 (always) and target levels S4.5–S5 (shown by flag)
        render_line(x_start, lvl.s4, x_end, lvl.s4, cfg.col_s4, cfg.line_style)
        if cfg.show_targets
            render_line(x_start, lvl.s4_5, x_end, lvl.s4_5, cfg.col_s4_5, cfg.line_style)
            render_line(x_start, lvl.s5, x_end, lvl.s5, cfg.col_s5, cfg.line_style)

        // R1-R2 / S1-S2 Levels
        if cfg.show_cams
            render_line(x_start, lvl.r1, x_end, lvl.r1, cfg.col_r1, cfg.line_style)
            render_line(x_start, lvl.r2, x_end, lvl.r2, cfg.col_r2, cfg.line_style)
            render_line(x_start, lvl.s1, x_end, lvl.s1, cfg.col_s1, cfg.line_style)
            render_line(x_start, lvl.s2, x_end, lvl.s2, cfg.col_s2, cfg.line_style)

        // CPR Zone: box fill (no visible borders) + three separate lines CP/BC/TC
        if cfg.show_cpr
            render_box(x_start, lvl.tc, x_end, lvl.bc, color.new(cfg.col_cp, 100), bg_cpr_color, cfg.line_style)
            render_line(x_start, lvl.cp, x_end, lvl.cp, cfg.col_cp, cfg.line_style)
            render_line(x_start, lvl.bc, x_end, lvl.bc, cfg.col_cp, cfg.line_style)
            render_line(x_start, lvl.tc, x_end, lvl.tc, cfg.col_cp, cfg.line_style)

    // HLC lines: begin from candle of extreme formation (hlc.x_start),
    // end up to right boundary of period (hlc.x_end)
    if cfg.show_hlc
        render_line(hlc.x_start, hlc.c, hlc.x_end, hlc.c, cfg.col_close, cfg.line_style)
        render_line(hlc.x_start, hlc.h, hlc.x_end, hlc.h, cfg.col_high,  cfg.line_style)
        render_line(hlc.x_start, hlc.l, hlc.x_end, hlc.l, cfg.col_low,   cfg.line_style)

    if not cfg.show_hlc
        if cfg.show_targets
            // Targets R4.5/R5: is_key=true — intentional (see Synergy Score comments above)
            render_lbl(x_end, lvl.r5, f_lbl_text(_sl, tf_marker + ' R5', lvl.r5, true, _ar, _as, true, true, own_idx=IDX_R5), color.new(cfg.col_r5, cfg.lbl_transp), _ls)
            render_lbl(x_end, lvl.r4_5, f_lbl_text(_sl, tf_marker + ' R4.5', lvl.r4_5, true, _ar, _as, true, true, own_idx=IDX_R4_5), color.new(cfg.col_r4_5, cfg.lbl_transp), _ls)

        render_lbl(x_end, lvl.r4, f_lbl_text(_sl, tf_marker + ' R4', lvl.r4, true, _ar, _as, true, true, own_idx=IDX_R4), color.new(cfg.col_r4, cfg.lbl_transp), _ls)

        // Zone label in center Y, markers on R3/S3
        render_lbl(x_end, (lvl.r3 + lvl.r3_5) / 2, f_lbl_text2(_sl, tf_marker + ' R3-R3.5', lvl.r3_5, lvl.r3, lvl.r3, true, _ar, _as, true, false, f_get_vwap_marker(lvl.r3_5, lvl.r3), own_idx=IDX_R3), color.new(cfg.col_r3_5, cfg.lbl_transp), _ls)
        render_lbl(x_end, (lvl.s3 + lvl.s3_5) / 2, f_lbl_text2(_sl, tf_marker + ' S3-S3.5', lvl.s3, lvl.s3_5, lvl.s3, false, _ar, _as, true, false, f_get_vwap_marker(lvl.s3, lvl.s3_5), own_idx=IDX_S3), color.new(cfg.col_s3_5, cfg.lbl_transp), _ls)

        render_lbl(x_end, lvl.s4, f_lbl_text(_sl, tf_marker + ' S4', lvl.s4, false, _ar, _as, true, true, own_idx=IDX_S4), color.new(cfg.col_s4, cfg.lbl_transp), _ls)

        if cfg.show_targets
            // Targets S4.5/S5: is_key=true — intentional (see Synergy Score comments above)
            render_lbl(x_end, lvl.s4_5, f_lbl_text(_sl, tf_marker + ' S4.5', lvl.s4_5, false, _ar, _as, true, true, own_idx=IDX_S4_5), color.new(cfg.col_s4_5, cfg.lbl_transp), _ls)
            render_lbl(x_end, lvl.s5, f_lbl_text(_sl, tf_marker + ' S5', lvl.s5, false, _ar, _as, true, true, own_idx=IDX_S5), color.new(cfg.col_s5, cfg.lbl_transp), _ls)

        if cfg.show_cams
            // R1-R2/S1-S2: inner levels, no confluence
            render_lbl(x_end, lvl.r1, f_lbl_text_simple(_sl, tf_marker + ' R1', lvl.r1, false, false, true), color.new(cfg.col_r1, cfg.lbl_transp), _ls)
            render_lbl(x_end, lvl.r2, f_lbl_text_simple(_sl, tf_marker + ' R2', lvl.r2, false, false, true), color.new(cfg.col_r2, cfg.lbl_transp), _ls)
            render_lbl(x_end, lvl.s1, f_lbl_text_simple(_sl, tf_marker + ' S1', lvl.s1, false, false, false), color.new(cfg.col_s1, cfg.lbl_transp), _ls)
            render_lbl(x_end, lvl.s2, f_lbl_text_simple(_sl, tf_marker + ' S2', lvl.s2, false, false, false), color.new(cfg.col_s2, cfg.lbl_transp), _ls)

        if cfg.show_cpr
            // TC/BC: text labels are not rendered (lines remain) — secondary levels,
            // visually already distinct by CPR zone and CP line
            // CP: key neutral level (VWAP arrows are equal)
            render_lbl(x_end, lvl.cp, f_lbl_text_simple(_sl, tf_marker + ' CP', lvl.cp, true, true, true, true, own_idx=IDX_CP),  color.new(cfg.col_cp, cfg.lbl_transp), _ls)

    // HLC Labels with no markers
    if cfg.show_hlc
        render_lbl(hlc.x_end, hlc.c, f_lbl_hlc(_sl, tf_marker + ' Close', hlc.c), color.new(cfg.col_close, cfg.lbl_transp), _ls)
        render_lbl(hlc.x_end, hlc.h, f_lbl_hlc(_sl, tf_marker + ' High', hlc.h), color.new(cfg.col_high,  cfg.lbl_transp), _ls)
        render_lbl(hlc.x_end, hlc.l, f_lbl_hlc(_sl, tf_marker + ' Low',  hlc.l), color.new(cfg.col_low,   cfg.lbl_transp), _ls)


// ===========================================================================================================
// BLOCK 5: EXECUTION AND ALERTS SYSTEM
// ===========================================================================================================

// --- 5.1 Render Elements on Chart ---
// Select period, build configuration and draw levels
// Projection draws only in real-time
bool _proj_ready = in_period != 'Projection' or barstate.isrealtime

// Clear drawings (protection against "hanging" objects)
// The draw_elements function is called at all times (on last bar).
// For invalid TF (!is_vis) or active Kill Switch, coordinates are forcibly 
// replaced with na. Internal render_* functions automatically hide 
// var objects upon receiving na, clearing screen from old levels.
if barstate.islast and _proj_ready
    draw_cfg = DrawConfig.new(
        show_lbl     = in_show_lbl,
        show_cpr     = in_cpr,
        show_cams    = in_cams,
        show_hlc     = in_hlc,
        show_targets = in_targets,
        line_style   = style_line,
        lbl_size     = style_lbl_size,
        lbl_transp   = in_lbl_transp,
        col_cp       = c_cp,
        col_r1       = c_r1,
        col_r2       = c_r2,
        col_r3_5     = c_r3_5,
        col_r4       = c_r4,
        col_r4_5     = c_r4_5,
        col_r5       = c_r5,
        col_s1       = c_s1,
        col_s2       = c_s2,
        col_s3_5     = c_s3_5,
        col_s4       = c_s4,
        col_s4_5     = c_s4_5,
        col_s5       = c_s5,
        col_high     = c_high,
        col_low      = c_low,
        col_close    = c_close)

    [active_lvl, active_x_start, active_x_end, active_hlc, active_cpr_col] = switch in_period
        'Previous'   => [prev_lvl, p_t_start, p_t_end, hlc_prev, get_final_cpr_color(prev_lvl.cp, old_cp)]
        'Projection' => [next_lvl, n_t_start, n_t_end, hlc_next, get_final_cpr_color(next_lvl.cp, curr_lvl.cp)]
        =>              [curr_lvl, t_start,   t_end,   hlc_curr, get_final_cpr_color(curr_lvl.cp, prev_lvl.cp)]

    // Force 'na' down the drawing pipeline to erase chart lines —
    // happens when data is outdated (boundary), incompatible pivot TF (is_vis),
    // triggered kill switch (is_chart_monthly_or_higher), or pivots explicitly turned off
    // (in_pivots_off). This single gate also hides everything embedded in the labels —
    // Confluence badges, ATR markers, and the Synergy (⋈) badge — since they're all
    // rendered as text inside these same labels.
    if is_boundary_blocked or not is_vis or is_chart_monthly_or_higher or in_pivots_off
        active_x_start := na
        active_x_end   := na
        active_hlc     := HlcData.new(na, na, na, na, na)

    draw_elements(active_lvl, active_x_start, active_x_end, active_hlc, active_cpr_col, draw_cfg)

// --- 5.2 Dynamic Alerts + Spam Protection ---
// Touch states (varip keeps state between ticks within the same bar)
varip bool was_touching_s3   = false
varip bool was_touching_r3   = false
varip bool was_touching_s4   = false
varip bool was_touching_r4   = false
varip bool was_touching_high = false
varip bool was_touching_low  = false
varip bool was_touching_s4_5 = false
varip bool was_touching_r4_5 = false
varip bool was_touching_s5   = false
varip bool was_touching_r5   = false

// Cooldowns for all alerts (in bars)
varip int last_bar_s3        = -100
varip int last_bar_r3        = -100
varip int last_bar_s4        = -100
varip int last_bar_r4        = -100
varip int last_bar_s4_5      = -100
varip int last_bar_r4_5      = -100
varip int last_bar_s5        = -100
varip int last_bar_r5        = -100
varip int last_bar_high      = -100
varip int last_bar_low       = -100

varip int last_bar_cp_up     = -100
varip int last_bar_cp_dn     = -100
varip int last_bar_vwap_up   = -100
varip int last_bar_vwap_dn   = -100
varip int last_bar_vwap_y_up = -100
varip int last_bar_vwap_y_dn = -100
varip int[] last_bar_band_up = array.new<int>(6, -100)
varip int[] last_bar_band_dn = array.new<int>(6, -100)

// Base alert validity — shared by ALL alert types (pivot-based and VWAP alike):
// kill-switch protection (Monthly+ TF), stale period-data protection (boundary), and "Current" mode only.
bool _base_alert_valid  = not is_chart_monthly_or_higher and not is_boundary_blocked and in_period == 'Current'
// Extra condition for PIVOT-LEVEL alerts (S3/R3/S4/R4/High/Low/CP): also requires a compatible
// pivot TF (is_vis), real period data (p_high), and pivot calculation being enabled.
// VWAP alerts (below) are NOT tied to this — they keep working even with "Pivot Calculation Period" = Off.
bool _pivot_alert_valid = _base_alert_valid and is_vis and not na(p_high) and not in_pivots_off

if _pivot_alert_valid
    // GROUP 1: Touching Levels (High/Low) — one signal per touch + cooldown
    // Logic: alert triggers on touch front (false -> true),
    // but at least in_cooldown bars must pass between two triggers
    bool is_touching_s3   = not na(curr_lvl.s3) and low <= curr_lvl.s3
    bool is_touching_r3   = not na(curr_lvl.r3) and high >= curr_lvl.r3
    bool is_touching_s4   = not na(curr_lvl.s4) and low <= curr_lvl.s4
    bool is_touching_r4   = not na(curr_lvl.r4) and high >= curr_lvl.r4
    bool is_touching_s4_5 = not na(curr_lvl.s4_5) and low <= curr_lvl.s4_5
    bool is_touching_r4_5 = not na(curr_lvl.r4_5) and high >= curr_lvl.r4_5
    bool is_touching_s5   = not na(curr_lvl.s5) and low <= curr_lvl.s5
    bool is_touching_r5   = not na(curr_lvl.r5) and high >= curr_lvl.r5
    bool is_touching_high = not na(p_high) and high >= p_high
    bool is_touching_low  = not na(p_low) and low <= p_low

    // Touch fronts (false -> true) + cooldown check
    bool s3_front   = is_touching_s3 and not was_touching_s3 and (bar_index - last_bar_s3 >= in_cooldown)
    bool r3_front   = is_touching_r3 and not was_touching_r3 and (bar_index - last_bar_r3 >= in_cooldown)
    bool s4_front   = is_touching_s4 and not was_touching_s4 and (bar_index - last_bar_s4 >= in_cooldown)
    bool r4_front   = is_touching_r4 and not was_touching_r4 and (bar_index - last_bar_r4 >= in_cooldown)
    bool s4_5_front = is_touching_s4_5 and not was_touching_s4_5 and (bar_index - last_bar_s4_5 >= in_cooldown)
    bool r4_5_front = is_touching_r4_5 and not was_touching_r4_5 and (bar_index - last_bar_r4_5 >= in_cooldown)
    bool s5_front   = is_touching_s5 and not was_touching_s5 and (bar_index - last_bar_s5 >= in_cooldown)
    bool r5_front   = is_touching_r5 and not was_touching_r5 and (bar_index - last_bar_r5 >= in_cooldown)
    bool high_front = is_touching_high and not was_touching_high and (bar_index - last_bar_high >= in_cooldown)
    bool low_front  = is_touching_low and not was_touching_low and (bar_index - last_bar_low >= in_cooldown)

    if in_alert_rev and s3_front
        alert('Price reached the support zone level (S3). Level (' + alert_tf_label + '): ' + f_format_large_num(curr_lvl.s3) + '.', alert.freq_once_per_bar)
        last_bar_s3 := bar_index
    
    if in_alert_rev and r3_front
        alert('Price reached the resistance zone level (R3). Level (' + alert_tf_label + '): ' + f_format_large_num(curr_lvl.r3) + '.', alert.freq_once_per_bar)
        last_bar_r3 := bar_index
    
    if in_alert_last and s4_front
        alert('Price reached the extreme support level (S4). Level (' + alert_tf_label + '): ' + f_format_large_num(curr_lvl.s4) + '.', alert.freq_once_per_bar)
        last_bar_s4 := bar_index
    
    if in_alert_last and r4_front
        alert('Price reached the extreme resistance level (R4). Level (' + alert_tf_label + '): ' + f_format_large_num(curr_lvl.r4) + '.', alert.freq_once_per_bar)
        last_bar_r4 := bar_index

    if in_alert_ext and s4_5_front
        alert('Price reached the extended support level (S4.5). Level (' + alert_tf_label + '): ' + f_format_large_num(curr_lvl.s4_5) + '.', alert.freq_once_per_bar)
        last_bar_s4_5 := bar_index

    if in_alert_ext and r4_5_front
        alert('Price reached the extended resistance level (R4.5). Level (' + alert_tf_label + '): ' + f_format_large_num(curr_lvl.r4_5) + '.', alert.freq_once_per_bar)
        last_bar_r4_5 := bar_index

    if in_alert_max and s5_front
        alert('Price reached the outermost support level (S5). Level (' + alert_tf_label + '): ' + f_format_large_num(curr_lvl.s5) + '.', alert.freq_once_per_bar)
        last_bar_s5 := bar_index

    if in_alert_max and r5_front
        alert('Price reached the outermost resistance level (R5). Level (' + alert_tf_label + '): ' + f_format_large_num(curr_lvl.r5) + '.', alert.freq_once_per_bar)
        last_bar_r5 := bar_index
    
    if in_alert_hl and high_front
        alert('Price broke the previous period\'s High. Level (' + alert_tf_label + '): ' + f_format_large_num(p_high) + '.', alert.freq_once_per_bar)
        last_bar_high := bar_index
    
    if in_alert_hl and low_front
        alert('Price broke the previous period\'s Low. Level (' + alert_tf_label + '): ' + f_format_large_num(p_low) + '.', alert.freq_once_per_bar)
        last_bar_low := bar_index

    // Update touch states (reset when price moves away from the level)
    was_touching_s3   := is_touching_s3
    was_touching_r3   := is_touching_r3
    was_touching_s4   := is_touching_s4
    was_touching_r4   := is_touching_r4
    was_touching_s4_5 := is_touching_s4_5
    was_touching_r4_5 := is_touching_r4_5
    was_touching_s5   := is_touching_s5
    was_touching_r5   := is_touching_r5
    was_touching_high := is_touching_high
    was_touching_low  := is_touching_low

// GROUP 2: Breakout by Close — with cooldown in bars
if barstate.isconfirmed
    // 2a. CP breakout — only when pivots are enabled and valid
    if _pivot_alert_valid
        bool _cp_cross_up   = close > curr_lvl.cp and close[1] <= curr_lvl.cp
        bool _cp_cross_dn   = close < curr_lvl.cp and close[1] >= curr_lvl.cp

        if in_alert_cpr and _cp_cross_up and (bar_index - last_bar_cp_up >= in_cooldown)
            alert('Price crossed the central pivot (CP) level from below. Level (' + alert_tf_label + '): ' + f_format_large_num(curr_lvl.cp) + '.', alert.freq_once_per_bar)
            last_bar_cp_up := bar_index

        if in_alert_cpr and _cp_cross_dn and (bar_index - last_bar_cp_dn >= in_cooldown)
            alert('Price crossed the central pivot (CP) level from above. Level (' + alert_tf_label + '): ' + f_format_large_num(curr_lvl.cp) + '.', alert.freq_once_per_bar)
            last_bar_cp_dn := bar_index

    // 2b. VWAP alerts (Breakout, Yearly VWAP, Yearly bands) — independent of pivot state
    if _base_alert_valid
        bool _vwap_cross_up   = in_alert_vwap and close > _vwap_src and close[1] <= _vwap_src
        bool _vwap_cross_dn   = in_alert_vwap and close < _vwap_src and close[1] >= _vwap_src
        bool _vwap_y_cross_up = in_alert_vwap and close > vwap_y    and close[1] <= vwap_y
        bool _vwap_y_cross_dn = in_alert_vwap and close < vwap_y    and close[1] >= vwap_y

        if _vwap_cross_up and not _is_new_vwap_period and (bar_index - last_bar_vwap_up >= in_cooldown)
            _vwap_src_str = not na(_vwap_src) ? f_format_large_num(_vwap_src) : 'N/A'
            alert('Price crossed the Anchored VWAP line from below. Level (' + alert_tf_label + '): ' + _vwap_src_str + '.', alert.freq_once_per_bar)
            last_bar_vwap_up := bar_index

        if _vwap_cross_dn and not _is_new_vwap_period and (bar_index - last_bar_vwap_dn >= in_cooldown)
            _vwap_src_str = not na(_vwap_src) ? f_format_large_num(_vwap_src) : 'N/A'
            alert('Price crossed the Anchored VWAP line from above. Level (' + alert_tf_label + '): ' + _vwap_src_str + '.', alert.freq_once_per_bar)
            last_bar_vwap_dn := bar_index

        if _vwap_y_cross_up and not global_is_new_year and (bar_index - last_bar_vwap_y_up >= in_cooldown)
            _vwap_y_str = not na(vwap_y) ? f_format_large_num(vwap_y) : 'N/A'
            alert('Price crossed the Yearly Anchored VWAP line from below. Level: ' + _vwap_y_str + '.', alert.freq_once_per_bar)
            last_bar_vwap_y_up := bar_index

        if _vwap_y_cross_dn and not global_is_new_year and (bar_index - last_bar_vwap_y_dn >= in_cooldown)
            _vwap_y_str = not na(vwap_y) ? f_format_large_num(vwap_y) : 'N/A'
            alert('Price crossed the Yearly Anchored VWAP line from above. Level: ' + _vwap_y_str + '.', alert.freq_once_per_bar)
            last_bar_vwap_y_dn := bar_index

        if in_alert_vwap_bands and not global_is_new_year
            for i = 0 to 5
                float _band_price = array.get(band_y_price, i)
                if not na(_band_price)
                    bool _band_cross_up = close > _band_price and close[1] <= _band_price
                    bool _band_cross_dn = close < _band_price and close[1] >= _band_price
                    string _lbl = f_sigma_label(array.get(band_y_mult, i))

                    if _band_cross_up and (bar_index - array.get(last_bar_band_up, i) >= in_cooldown)
                        alert('Price crossed the Yearly VWAP band (' + _lbl + ') from below. Level: ' + f_format_large_num(_band_price) + '.', alert.freq_once_per_bar)
                        array.set(last_bar_band_up, i, bar_index)

                    if _band_cross_dn and (bar_index - array.get(last_bar_band_dn, i) >= in_cooldown)
                        alert('Price crossed the Yearly VWAP band (' + _lbl + ') from above. Level: ' + f_format_large_num(_band_price) + '.', alert.freq_once_per_bar)
                        array.set(last_bar_band_dn, i, bar_index)


// ===========================================================================================================
// BLOCK 6: MTF ALIGNMENT DASHBOARD
// ===========================================================================================================

// --- 6.1 Dashboard Visual Settings ---
// MTF Dashboard Colors
// 5 states: Impulse (±2) — saturated; Pullback (±1) — muted; Flat (0) — gray.
var c_dash_bg             = color.new(#000000, 0)
var c_dash_strong_bull    = color.new(#0a7a5c, 20)
var c_dash_pullback_long  = color.new(#6b8c7e, 35)
var c_dash_pullback_short = color.new(#9a6b6b, 35)
var c_dash_strong_bear    = color.new(#b22833, 20)
var c_dash_flat           = color.new(#3e3f47, 20) 
var c_dash_header_bg      = color.new(#000000, 0)

// "Trend" cell background by state
f_bg(state) =>
    switch state
        2      => c_dash_strong_bull
        1      => c_dash_pullback_long
        -1     => c_dash_pullback_short
        -2     => c_dash_strong_bear
        =>        c_dash_flat

// "Trend" cell text: ↗/↘ — impulse, ⤴/⤵ — pullback, ⇅ — flat
f_dash_txt(state) =>
    switch state
        2      => "Long ↗"
        1      => "Long ⤴"
        -1     => "Short ⤵"
        -2     => "Short ↘"
        =>        "Flat ⇅"

var int  chart_sec  = timeframe.in_seconds()
// Static part (Chart TF doesn't change while script runs — var is safe)
var bool tf_ok_d    = chart_sec <= timeframe.in_seconds('1D')
var bool tf_ok_w    = chart_sec <= timeframe.in_seconds('1W')
var bool tf_ok_m    = chart_sec <= timeframe.in_seconds('1M')

// Dynamic VWAP Validation
// Unlike stat. TF, VWAP status changes dynamically. 
// Removed "var" so na-status refreshes each bar, 
// preventing false "Flat" during temporary data loss.
bool valid_d = tf_ok_d and not na(vwap_d)
bool valid_w = tf_ok_w and not na(vwap_w)
bool valid_m = tf_ok_m and not na(vwap_m)
bool valid_y = not na(vwap_y) and not na(vwap_y_sigma) and vwap_y_sigma > 0

var table mtf_tbl = na

// CP dot color in the dashboard: shift of the current period's CP relative to
// the previous period of the same TF. Always active (independent of the
// "CPR Shift (CPR Relationship)" checkbox), colors come from the same shared
// settings in the "CPR Zone & Relationship" group (c_cpr_bull / c_cpr_bear / c_cpr_neu),
// including the rule "difference below mintick or data unavailable → gray".
color dash_cp_dot_d = valid_d ? f_dash_cpr_dot_color(lvl_d.cp, cp_d_prev) : color.new(c_cpr_neu, 0)
color dash_cp_dot_w = valid_w ? f_dash_cpr_dot_color(lvl_w.cp, cp_w_prev) : color.new(c_cpr_neu, 0)
color dash_cp_dot_m = valid_m ? f_dash_cpr_dot_color(lvl_m.cp, cp_m_prev) : color.new(c_cpr_neu, 0)

// --- 6.2 Dashboard ---
// Structure: 5 columns (TF, TREND, CP, RS, Σ) x 5 rows (Y, Headers, 1D, 1W, 1M).
// RS ("Relationship Shift") — a dot "●" whose color reflects the shift of the current
// period's CPR relative to the previous one (see f_dash_cpr_dot_color / "CPR Zone & Relationship" settings).
// The "Y" row displays global context (direction and overheating relative to Yearly VWAP).
// For 1W/1M: if CP goes beyond ±2σ of Yearly VWAP, alert marker ⚠ is added.
if barstate.islast
    bool _show_dash = in_mtf_dash and is_vis and not is_boundary_blocked and not is_chart_monthly_or_higher

    if _show_dash
        if na(mtf_tbl)
            mtf_tbl := table.new(position.top_right, 5, 6, border_color=color.new(color.gray, 70), border_width=1, frame_color=color.new(color.gray, 70), frame_width=1, bgcolor=c_dash_bg)

        // Row 0: "Y" — global yearly context
        table.cell(mtf_tbl, 0, 0, "GLOBAL TREND (VWAP)", text_color=color.white, bgcolor=c_dash_header_bg, text_size=style_dash_size, text_halign=text.align_center, text_valign=text.align_center)
        table.cell(mtf_tbl, 1, 0, "", bgcolor=c_dash_header_bg)
        table.cell(mtf_tbl, 2, 0, "", bgcolor=c_dash_header_bg)
        table.cell(mtf_tbl, 3, 0, "", bgcolor=c_dash_header_bg)
        table.cell(mtf_tbl, 4, 0, "", bgcolor=c_dash_header_bg)
        table.merge_cells(mtf_tbl, 0, 0, 4, 0)

        table.cell(mtf_tbl, 0, 1, "Ⓨ", text_color=color.white, text_size=style_dash_size)
        if valid_y
            float _sd_y = f_sigma_dist(close, vwap_y, vwap_y_sigma)
            bool  _hot_y  = not na(_sd_y) and math.abs(math.round(_sd_y, 1)) >= 2
            string _sd_y_str = f_sigma_str(_sd_y) + (_hot_y ? " ⚠" : "")
            
            table.cell(mtf_tbl, 1, 1, f_dash_txt(state_y), text_color=color.white, bgcolor=f_bg(state_y), text_size=style_dash_size)
            table.cell(mtf_tbl, 2, 1, f_format_large_num(vwap_y), text_color=color.white, text_size=style_dash_size)
            table.cell(mtf_tbl, 3, 1, "")
            table.cell(mtf_tbl, 4, 1, _sd_y_str, text_color=f_sigma_color(_sd_y), text_size=style_dash_size)
        else
            table.cell(mtf_tbl, 1, 1, "N/A", text_color=color.gray, bgcolor=c_dash_bg, text_size=style_dash_size)
            table.cell(mtf_tbl, 2, 1, "-",   text_color=color.gray, text_size=style_dash_size)
            table.cell(mtf_tbl, 3, 1, "")
            table.cell(mtf_tbl, 4, 1, "-",   text_color=color.gray, text_size=style_dash_size)
        table.merge_cells(mtf_tbl, 2, 1, 3, 1)

        // Row 1: Column Headers
        table.cell(mtf_tbl, 0, 2, "TF",    text_color=color.white, bgcolor=c_dash_header_bg, text_size=style_dash_size)
        table.cell(mtf_tbl, 1, 2, "TREND", text_color=color.white, bgcolor=c_dash_header_bg, text_size=style_dash_size)
        table.cell(mtf_tbl, 2, 2, "CP",    text_color=color.white, bgcolor=c_dash_header_bg, text_size=style_dash_size)
        table.cell(mtf_tbl, 3, 2, "RS",    text_color=color.white, bgcolor=c_dash_header_bg, text_size=style_dash_size)
        table.cell(mtf_tbl, 4, 2, "Σ",     text_color=color.white, bgcolor=c_dash_header_bg, text_size=style_dash_size)

        // Narrow CPR calculation for daily pivots (percentile)
        // cpr_width_ratio_d and cpr_narrow_thresh_ratio_d are already computed above (block 3.5.1,
        // f_narrow_cpr_pctl_d) — only the comparison happens here. There is no longer an explicit
        // minimum-history gate: ta.percentile_nearest_rank uses whatever bars are available in its
        // window (even fewer than NARROW_CPR_LOOKBACK_D), so the threshold may be less statistically
        // representative on the instrument's earliest bars, but it won't be na.
        bool is_narrow_cpr_d = not na(cpr_width_ratio_d) and not na(cpr_narrow_thresh_ratio_d) and cpr_width_ratio_d < cpr_narrow_thresh_ratio_d
        string rs_text_d = is_narrow_cpr_d ? "⧗" : "●"

        table.cell(mtf_tbl, 0, 3, "Ⓓ", text_color=color.white, text_size=style_dash_size)
        if valid_d
            float _sd_d = f_sigma_dist(lvl_d.cp, vwap_y, vwap_y_sigma)
            bool  _hot_d  = not na(_sd_d) and math.abs(math.round(_sd_d, 1)) >= 2
            string _sd_d_str = f_sigma_str(_sd_d) + (_hot_d ? " ⚠" : "")
            table.cell(mtf_tbl, 1, 3, f_dash_txt(state_d), text_color=color.white, bgcolor=f_bg(state_d), text_size=style_dash_size)
            table.cell(mtf_tbl, 2, 3, f_format_large_num(lvl_d.cp), text_color=color.white, text_size=style_dash_size)
            table.cell(mtf_tbl, 3, 3, rs_text_d, text_color=dash_cp_dot_d, text_size=style_dash_size)
            table.cell(mtf_tbl, 4, 3, _sd_d_str, text_color=f_sigma_color(_sd_d), text_size=style_dash_size)
        else
            table.cell(mtf_tbl, 1, 3, "N/A", text_color=color.gray, bgcolor=c_dash_bg, text_size=style_dash_size)
            table.cell(mtf_tbl, 2, 3, "-",   text_color=color.gray, text_size=style_dash_size)
            table.cell(mtf_tbl, 3, 3, "●",   text_color=color.new(c_cpr_neu, 0), text_size=style_dash_size)
            table.cell(mtf_tbl, 4, 3, "-",   text_color=color.gray, text_size=style_dash_size)

        table.cell(mtf_tbl, 0, 4, "Ⓦ", text_color=color.white, text_size=style_dash_size)
        if valid_w
            float _sd_w   = f_sigma_dist(lvl_w.cp, vwap_y, vwap_y_sigma)
            bool  _hot_w  = not na(_sd_w) and math.abs(math.round(_sd_w, 1)) >= 2
            string _sd_w_str = f_sigma_str(_sd_w) + (_hot_w ? " ⚠" : "")
            table.cell(mtf_tbl, 1, 4, f_dash_txt(state_w), text_color=color.white, bgcolor=f_bg(state_w), text_size=style_dash_size)
            table.cell(mtf_tbl, 2, 4, f_format_large_num(lvl_w.cp), text_color=color.white, text_size=style_dash_size)
            table.cell(mtf_tbl, 3, 4, "●", text_color=dash_cp_dot_w, text_size=style_dash_size)
            table.cell(mtf_tbl, 4, 4, _sd_w_str, text_color=f_sigma_color(_sd_w), text_size=style_dash_size)
        else
            table.cell(mtf_tbl, 1, 4, "N/A", text_color=color.gray, bgcolor=c_dash_bg, text_size=style_dash_size)
            table.cell(mtf_tbl, 2, 4, "-",   text_color=color.gray, text_size=style_dash_size)
            table.cell(mtf_tbl, 3, 4, "●",   text_color=color.new(c_cpr_neu, 0), text_size=style_dash_size)
            table.cell(mtf_tbl, 4, 4, "-",   text_color=color.gray, text_size=style_dash_size)

        table.cell(mtf_tbl, 0, 5, "Ⓜ", text_color=color.white, text_size=style_dash_size)
        if valid_m
            float _sd_m   = f_sigma_dist(lvl_m.cp, vwap_y, vwap_y_sigma)
            bool  _hot_m  = not na(_sd_m) and math.abs(math.round(_sd_m, 1)) >= 2
            string _sd_m_str = f_sigma_str(_sd_m) + (_hot_m ? " ⚠" : "")
            table.cell(mtf_tbl, 1, 5, f_dash_txt(state_m), text_color=color.white, bgcolor=f_bg(state_m), text_size=style_dash_size)
            table.cell(mtf_tbl, 2, 5, f_format_large_num(lvl_m.cp), text_color=color.white, text_size=style_dash_size)
            table.cell(mtf_tbl, 3, 5, "●", text_color=dash_cp_dot_m, text_size=style_dash_size)
            table.cell(mtf_tbl, 4, 5, _sd_m_str, text_color=f_sigma_color(_sd_m), text_size=style_dash_size)
        else
            table.cell(mtf_tbl, 1, 5, "N/A", text_color=color.gray, bgcolor=c_dash_bg, text_size=style_dash_size)
            table.cell(mtf_tbl, 2, 5, "-",   text_color=color.gray, text_size=style_dash_size)
            table.cell(mtf_tbl, 3, 5, "●",   text_color=color.new(c_cpr_neu, 0), text_size=style_dash_size)
            table.cell(mtf_tbl, 4, 5, "-",   text_color=color.gray, text_size=style_dash_size)
    else
        // Dashboard turned off or boundary blocked — delete table
        if not na(mtf_tbl)
            table.delete(mtf_tbl)
            mtf_tbl := na


// ===========================================================================================================
// BLOCK 7: VWAP (tied to pivot TF)
// ===========================================================================================================

// Downsampling: keeps even points in place (without creating a new array)
f_vwap_downsample(array<chart.point> _pts) =>
    int _sz = array.size(_pts)
    if _sz == 0
        na
    else
        int _write = 0
        for _read = 0 to _sz - 1
            if _read % 2 == 0
                array.set(_pts, _write, array.get(_pts, _read))
                _write += 1
        while array.size(_pts) > _write
            array.pop(_pts)

// --- 7.1 Periodic VWAP (tied to day / week / month) ---
// Polyline limit — 10000 points, take some headroom (9500)
var int MAX_VWAP_PTS = 9500

var chart.point[] _vwap_pts  = array.new<chart.point>()
var polyline       _vwap_poly = na

bool _vwap_enabled = (in_vwap_show_d or in_vwap_show_w or in_vwap_show_m) and is_vis and not is_chart_monthly_or_higher

// TF of the actually displayed line (might differ from pivot TF in_tf if user
// picked another period in the dropdown) — point reset must follow this, not in_tf.
var string _vwap_view_tf  = in_vwap_show_d ? 'D' : in_vwap_show_w ? 'W' : in_vwap_show_m ? 'M' : 'D'
bool _vwap_period_change = timeframe.change(_vwap_view_tf)

// Accumulate points, reset on period change
if _vwap_enabled
    if _vwap_period_change or barstate.isfirst
        array.clear(_vwap_pts)

    if not na(_vwap_view_src)
        if array.size(_vwap_pts) >= MAX_VWAP_PTS
            f_vwap_downsample(_vwap_pts)

        // Deduplication by VALUE: prevents array overflow on lower TFs.
        // If VWAP value hasn't changed, shift the last point forward in time (pop+push).
        if array.size(_vwap_pts) > 0 and array.last(_vwap_pts).price == _vwap_view_src
            array.pop(_vwap_pts)

        array.push(_vwap_pts, chart.point.from_time(time, _vwap_view_src))
else
    // VWAP disabled — clear points
    array.clear(_vwap_pts)

if barstate.islast
    if not na(_vwap_poly)
        polyline.delete(_vwap_poly)
        _vwap_poly := na
    if _vwap_enabled and not is_boundary_blocked and array.size(_vwap_pts) >= 2
        _vwap_poly := polyline.new(_vwap_pts, closed=false, curved=false, xloc=xloc.bar_time, line_color=c_vwap, line_style=line.style_solid, line_width=in_vwap_width)

// --- 7.2 Yearly VWAP ---
var chart.point[] _vwap_y_pts  = array.new<chart.point>()
var polyline       _vwap_y_poly = na

bool _vwap_y_enabled = in_vwap_show_y and is_vis and not is_chart_monthly_or_higher

if _vwap_y_enabled
    if global_is_new_year or barstate.isfirst
        array.clear(_vwap_y_pts)

    if not na(vwap_y)
        if array.size(_vwap_y_pts) >= MAX_VWAP_PTS
            f_vwap_downsample(_vwap_y_pts)

        // Yearly VWAP deduplication by value (reduces array load)
        if array.size(_vwap_y_pts) > 0 and array.last(_vwap_y_pts).price == vwap_y
            array.pop(_vwap_y_pts)

        array.push(_vwap_y_pts, chart.point.from_time(time, vwap_y))
else
    array.clear(_vwap_y_pts)

if barstate.islast
    if not na(_vwap_y_poly)
        polyline.delete(_vwap_y_poly)
        _vwap_y_poly := na
    if _vwap_y_enabled and not is_boundary_blocked and array.size(_vwap_y_pts) >= 2
        // Yearly VWAP — solid, standard width
        _vwap_y_poly := polyline.new(_vwap_y_pts, closed=false, curved=false, xloc=xloc.bar_time, line_color=c_vwap, line_style=line.style_solid, line_width=in_vwap_width)

// --- 7.3 Yearly VWAP Bands (±1σ/2σ/3σ) ---
// Point accumulation and (re)drawing polylines for 6 bands: +1σ, +2σ, +3σ, -1σ, -2σ, -3σ
// Each band is stored in separate pts/poly variables — similarly to 7.1/7.2

bool _vwap_y_bands_draw_enabled = in_vwap_show_y and in_vwap_y_bands_draw and is_vis and not is_chart_monthly_or_higher

// Point accumulation for a single band (reuses f_vwap_downsample and general MAX_VWAP_PTS limit)
f_vwap_band_accum(chart.point[] pts, float price, bool reset_now) =>
    if reset_now
        array.clear(pts)
    if not na(price)
        if array.size(pts) >= MAX_VWAP_PTS
            f_vwap_downsample(pts)
        // VWAP Bands deduplication by value
        if array.size(pts) > 0 and array.last(pts).price == price
            array.pop(pts)
        array.push(pts, chart.point.from_time(time, price))

// Points and polylines for each band (band_y_price indexing: 0=+1σ,1=+2σ,2=+3σ,3=-1σ,4=-2σ,5=-3σ)
var chart.point[] _vwap_y_b1p_pts = array.new<chart.point>()
var chart.point[] _vwap_y_b2p_pts = array.new<chart.point>()
var chart.point[] _vwap_y_b3p_pts = array.new<chart.point>()
var chart.point[] _vwap_y_b1n_pts = array.new<chart.point>()
var chart.point[] _vwap_y_b2n_pts = array.new<chart.point>()
var chart.point[] _vwap_y_b3n_pts = array.new<chart.point>()

var polyline _vwap_y_b1p_poly = na
var polyline _vwap_y_b2p_poly = na
var polyline _vwap_y_b3p_poly = na
var polyline _vwap_y_b1n_poly = na
var polyline _vwap_y_b2n_poly = na
var polyline _vwap_y_b3n_poly = na
var polyline _vwap_y_fill_poly = na  // Fill zone between +1σ and -1σ bands

if _vwap_y_bands_draw_enabled
    bool _reset_y_bands = global_is_new_year or barstate.isfirst
    f_vwap_band_accum(_vwap_y_b1p_pts, array.get(band_y_price, 0), _reset_y_bands)
    f_vwap_band_accum(_vwap_y_b2p_pts, array.get(band_y_price, 1), _reset_y_bands)
    f_vwap_band_accum(_vwap_y_b3p_pts, array.get(band_y_price, 2), _reset_y_bands)
    f_vwap_band_accum(_vwap_y_b1n_pts, array.get(band_y_price, 3), _reset_y_bands)
    f_vwap_band_accum(_vwap_y_b2n_pts, array.get(band_y_price, 4), _reset_y_bands)
    f_vwap_band_accum(_vwap_y_b3n_pts, array.get(band_y_price, 5), _reset_y_bands)
else
    array.clear(_vwap_y_b1p_pts)
    array.clear(_vwap_y_b2p_pts)
    array.clear(_vwap_y_b3p_pts)
    array.clear(_vwap_y_b1n_pts)
    array.clear(_vwap_y_b2n_pts)
    array.clear(_vwap_y_b3n_pts)

// Transparency decreases from 1σ to 3σ: the further the deviation, the more visible the band (3σ — extreme)
f_band_draw_color(int k) =>
    float _base_t  = color.t(c_vwap_y_bands)
    float _extra_t = (3 - k) * 15.0
    color.new(c_vwap_y_bands, int(math.min(95.0, _base_t + _extra_t)))

if barstate.islast
    if not na(_vwap_y_b1p_poly)
        polyline.delete(_vwap_y_b1p_poly)
        _vwap_y_b1p_poly := na
    if not na(_vwap_y_b2p_poly)
        polyline.delete(_vwap_y_b2p_poly)
        _vwap_y_b2p_poly := na
    if not na(_vwap_y_b3p_poly)
        polyline.delete(_vwap_y_b3p_poly)
        _vwap_y_b3p_poly := na
    if not na(_vwap_y_b1n_poly)
        polyline.delete(_vwap_y_b1n_poly)
        _vwap_y_b1n_poly := na
    if not na(_vwap_y_b2n_poly)
        polyline.delete(_vwap_y_b2n_poly)
        _vwap_y_b2n_poly := na
    if not na(_vwap_y_b3n_poly)
        polyline.delete(_vwap_y_b3n_poly)
        _vwap_y_b3n_poly := na
    if not na(_vwap_y_fill_poly)
        polyline.delete(_vwap_y_fill_poly)
        _vwap_y_fill_poly := na

    if _vwap_y_bands_draw_enabled and not is_boundary_blocked
        color _col_1 = f_band_draw_color(1)
        color _col_2 = f_band_draw_color(2)
        color _col_3 = f_band_draw_color(3)

        // Semi-transparent fill of the zone between +1σ and -1σ bands.
        // Polygon is constructed as a path "forward" along +1σ and "backward" along -1σ (closed loop),
        // drawn first so the dashed band lines stay on top of the fill.
        if array.size(_vwap_y_b1p_pts) >= 2 and array.size(_vwap_y_b1n_pts) >= 2
            chart.point[] _fill_pts = array.new<chart.point>()
            for i = 0 to array.size(_vwap_y_b1p_pts) - 1
                array.push(_fill_pts, array.get(_vwap_y_b1p_pts, i))
            for i = array.size(_vwap_y_b1n_pts) - 1 to 0
                array.push(_fill_pts, array.get(_vwap_y_b1n_pts, i))
            // The polygon merges TWO paths (+1σ and -1σ), so its size might almost
            // double MAX_VWAP_PTS and hit the polyline limit (10000 points).
            // We additionally compress it manually if needed.
            while array.size(_fill_pts) > 9800
                f_vwap_downsample(_fill_pts)
            _vwap_y_fill_poly := polyline.new(_fill_pts, closed=true, curved=false, xloc=xloc.bar_time, line_color=na, fill_color=color.new(c_vwap_y_bands, 90), line_width=1)

        // Bands are drawn dashed to visually distinguish from the solid Yearly VWAP line
        if array.size(_vwap_y_b1p_pts) >= 2
            _vwap_y_b1p_poly := polyline.new(_vwap_y_b1p_pts, closed=false, curved=false, xloc=xloc.bar_time, line_color=_col_1, line_style=line.style_dashed, line_width=in_vwap_width)
        if array.size(_vwap_y_b2p_pts) >= 2
            _vwap_y_b2p_poly := polyline.new(_vwap_y_b2p_pts, closed=false, curved=false, xloc=xloc.bar_time, line_color=_col_2, line_style=line.style_dashed, line_width=in_vwap_width)
        if array.size(_vwap_y_b3p_pts) >= 2
            _vwap_y_b3p_poly := polyline.new(_vwap_y_b3p_pts, closed=false, curved=false, xloc=xloc.bar_time, line_color=_col_3, line_style=line.style_dashed, line_width=in_vwap_width)
        if array.size(_vwap_y_b1n_pts) >= 2
            _vwap_y_b1n_poly := polyline.new(_vwap_y_b1n_pts, closed=false, curved=false, xloc=xloc.bar_time, line_color=_col_1, line_style=line.style_dashed, line_width=in_vwap_width)
        if array.size(_vwap_y_b2n_pts) >= 2
            _vwap_y_b2n_poly := polyline.new(_vwap_y_b2n_pts, closed=false, curved=false, xloc=xloc.bar_time, line_color=_col_2, line_style=line.style_dashed, line_width=in_vwap_width)
        if array.size(_vwap_y_b3n_pts) >= 2
            _vwap_y_b3n_poly := polyline.new(_vwap_y_b3n_pts, closed=false, curved=false, xloc=xloc.bar_time, line_color=_col_3, line_style=line.style_dashed, line_width=in_vwap_width)
````
