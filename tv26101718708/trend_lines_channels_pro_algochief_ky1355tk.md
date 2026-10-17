# Trend Lines & Channels Pro [AlgoChief]

- url: https://www.tradingview.com/script/Ky1355Tk-Trend-Lines-Channels-Pro-AlgoChief/
- type: indicator
- pine_id: PUB;9bdef36b7f4a4f10a8610d107f5229cd
- version: 1.0

## Description

# Trend Lines & Channels Pro [AlgoChief]

### An Institutional-Grade Trendline, Support/Resistance Channel, and Multi-Period Market Structure Suite Engineered for Modern Price Action Traders

---

### 📌 Overview & Core Philosophy

Drawing trendlines is traditionally one of the most subjective tasks in technical analysis. Ten different traders often draw ten different lines on the exact same chart. When lines are drawn arbitrarily across arbitrary candle wicks, they lead to false breakouts, whipsaws, and execution hesitation.

**Trend Lines & Channels Pro [AlgoChief]** eliminates human subjectivity by applying rigorous geometric and mathematical validation to identify true institutional support and resistance boundaries. 

Instead of relying on single razor-thin lines, this indicator models trendlines as **dynamic structural channels** by evaluating:
1. **Pivot Confirmation**: Identifying true structural pivot points over user-defined lookback periods.
2. **Channel Geometry & Touch Validation**: Scoring each line based on how many pivot points fit within a defined threshold channel band.
3. **Angular Inclination & Velocity**: Calculating true degrees of slope ($0^\circ$ to $90^\circ$) to filter out noisy or horizontal drift while highlighting high-velocity trends.
4. **Market Structure Alignment**: Running real-time linear regression across multiple time frames/lengths to confirm overall directional momentum.

---

### ✨ Key Features Breakdown

#### 1. Multi-Pivot Channel Solver & Strength Scoring
* **Algorithmic Fitting**: The indicator identifies confirmed swing highs and swing lows and solves for lines that encompass the highest concentration of pivot points.
* **Auto-Scored Strength**: Each discovered trendline is scored based on pivot touches and validation density. Lines exceeding the **Minimum Strength** threshold are classified as **Strong** (solid lines), while secondary candidate levels are rendered as **Weak** (subtle dotted lines).

#### 2. Shaded Channels with Equilibrium Midlines (`linefill`)
* Price action rarely reverses at an exact pixel on a screen. By enabling **Trend Channels**, the indicator projects upper, lower, and equilibrium (midline) boundaries.
* Semi-transparent color fills allow you to see at a glance whether price is testing channel equilibrium, bouncing from lower demand, or exhausting into upper supply.

#### 3. True Angular Analysis & Steep Slope Alerts
* **Angle Calculation**: Measures the real geometric inclination of every trendline in degrees ($0^\circ - 90^\circ$).
* **Angle Separation Filter**: Prevents chart clutter by discarding parallel lines that share near-identical slopes.
* **Steep Momentum Highlighting**: Automatically changes trendline color (e.g., to amber/yellow) when a trendline exceeds a user-defined steepness angle (e.g., $> 45^\circ$), warning you of potential overextended climax moves.

#### 4. Broken Trendline Memory & Re-Test Engine
* When an active trendline breaks, the indicator does not simply delete it. It retains the **Last Broken Trendline** on the chart as a dotted reference line for a configurable number of bars.
* Tracks breakout levels and alerts you when price pulls back to perform a **classical Break & Retest** confirmation.

#### 5. Angle Bisector (Compression & Squeeze Projector)
* When an active uptrend line and downtrend line converge, the indicator can dynamically project the **Angle Bisector**.
* This bisector line acts as the central median vector of converging wedges, pennants, and triangles, helping you identify future apex breakout targets.

#### 6. Multi-Period Market Structure HUD Table
* Displays a compact on-chart dashboard evaluating trend direction and slope across **4 distinct historical lengths** (e.g., 50, 100, 150, 200 bars).
* Visual color-coded power bars show real-time momentum strength and warning signs when macro and micro trends conflict.

#### 7. Active Trendlines HUD Matrix
* A clean heads-up table that lists current active support and resistance levels, their strength ratings, angular inclinations, and exact percentage distance from the current market close.

#### 8. External Signal Plot for Automated Trading Bots
* Includes a machine-readable numeric output (`ext_signal`) designed for webhook automations (PineConnector, 3Commas, WunderTrading, Alertatron):
  * `1.0` = Support Broken (Bearish Breakout)
  * `2.0` = Resistance Broken (Bullish Breakout)
  * `3.0` = Inside Support Channel
  * `4.0` = Inside Resistance Channel
  * `5.0` = Bounce Up from Support (Bullish Rejection)
  * `6.0` = Bounce Down from Resistance (Bearish Rejection)
  * `7.0` = Strong Steep Uptrend Detected
  * `8.0` = Strong Steep Downtrend Detected
  * `9.0` = Support Re-Broken
  * `10.0` = Resistance Re-Broken
  * `11.0` = Brand New Uptrend Line Established
  * `12.0` = Brand New Downtrend Line Established
  * `Fractional decimals` = Normalized percentage distance to nearest S/R

#### 9. All-in-One Alert Engine with Dynamic Placeholders
* Single consolidated alert mechanism supporting comprehensive string templates. You can customize webhook JSON payloads using real-time placeholders:
  * `{{ticker}}`, `{{timeframe}}`, `{{close}}`, `{{time}}`
  * `{{CurrentSupport}}`, `{{CurrentResistance}}`
  * `{{CurrentSupportAngle}}`, `{{CurrentResistanceAngle}}`
  * `{{BrokenSupport}}`, `{{BrokenResistance}}`
  * `{{ReBrokenSupport}}`, `{{ReBrokenResistance}}`
  * `{{TriangleDistancePercent}}`, `{{DistanceTosrPercent}}`

---

### 📖 How to Trade with Trend Lines & Channels Pro

#### Strategy 1: The Channel Bounce (Trend Continuation)
* **Setup**: Wait for price to enter a **Strong Uptrend Channel**.
* **Confirmation**: Look for candle wick rejection from the channel lower band, accompanied by the **Bounce Back Up from Support** signal.
* **Execution**: Enter Long with stop loss below the channel lower boundary; target channel midline and upper band.

#### Strategy 2: Breakout & Broken Line Retest
* **Setup**: Price decisively closes outside a major downtrend channel with strong volume.
* **Confirmation**: The script highlights the breakout level and keeps the broken line active. Wait for a re-test of the broken line (which now acts as new support).
* **Execution**: Enter on the re-test confirmation for higher risk-to-reward continuation entries.

#### Strategy 3: Squeeze Compression & S/R Breakout
* **Setup**: Distance between upper and lower trendlines compresses below the **Triangle Squeeze** threshold ($< 2\%$).
* **Execution**: Prepare for an explosive expansion breakout. Trigger alerts on either Support or Resistance breaks to capture the initial surge.

---

### ⚙️ Input Settings Guide

| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| **Pivot Period** | Integer | `4` | Left/Right bar confirmation count for swing high/low pivots. |
| **Source for Pivots** | String | `High/Low` | Use candle wicks (`High/Low`) or candle bodies (`Close`) for pivot calculations. |
| **Threshold Rate** | Float | `4.0` | Determines channel width band around the primary trendline. |
| **Minimum Strength** | Float | `3.0` | Minimum score required for a trendline to be categorized as Strong. |
| **Maximum Loopback** | Integer | `350` | Maximum lookback window for historical pivot detection. |
| **Show Trendlines as** | String | `Trend Channel With Midline` | Display style: single line, standard channel, or channel with 50% midline. |
| **Shaded Channels** | Boolean | `True` | Fills the channel zone with translucent background color. |
| **Minimum Angle Rate** | Float | `15.0°` | Minimum angular difference required before establishing a concurrent trendline. |
| **Angle Threshold** | Float | `45.0°` | Slope threshold above which lines are highlighted with steep momentum color. |
| **Show Last Broken Line** | Boolean | `True` | Keeps the most recently invalidated trendline visible for retest analysis. |
| **Show Angle Bisector** | Boolean | `False` | Computes and projects the median bisector of converging trendlines. |
| **Market Structure Table**| Boolean | `True` | Renders the 4-length linear regression trend and momentum matrix. |
| **Trend Lines Table** | Boolean | `True` | Renders the active S/R levels, strength scores, and distances. |

---

### ⚠️ Risk Disclaimer

This indicator is developed for educational, analytical, and research purposes only. Technical analysis indicators, including automated trendlines and channels, cannot guarantee future price movements. Always apply strict risk management, appropriate position sizing, and combine structural indicators with broader market context before executing real-capital trades.

---

## Source Code

````pine
//@version=6
// ==================================================================================================
// Indicator   : Trend Lines & Channels Pro [AlgoChief]
// Short Title : TLP [AlgoChief]
// Author      : AlgoChief (Proprietary Algorithmic Trading Systems)
// Description : Advanced Automated Trendlines, Channels, Multi-Period Market Structure,
//               Angle Bisectors, Retest Engine, Dynamic HUD Tables, and All-in-One Alerts.
// Architecture: Fully engineered in Pine Script v5 with clean original geometry, zero copyright conflicts.
// ==================================================================================================
indicator(title="Trend Lines & Channels Pro [AlgoChief]", shorttitle="TLP [AlgoChief]", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=100)

// ==================================================================================================
// INPUTS & USER CONFIGURATION
// ==================================================================================================
GRP_GEN = "GENERAL SETTINGS"
utc_offset          = input.float(0.0, "Timezone / UTC Offset (Hours)", minval=-12.0, maxval=14.0, step=0.5, group=GRP_GEN, tooltip="Set according to chart timezone (e.g. -4 for NY, +1 for London, +3 for Moscow, +5.5 for IST). Used for alert timestamps and broken line calculations.", display=display.none)
prd                 = input.int(4, "Pivot Period", minval=1, maxval=50, group=GRP_GEN, tooltip="Number of left and right bars required to confirm a Pivot High or Pivot Low.", display=display.none)
src_mode            = input.string("High/Low", "Source for Pivots", options=["High/Low", "Close"], group=GRP_GEN, tooltip="Use candle wicks (High/Low) or Close prices to identify pivots.", display=display.none)
threshold_rate      = input.float(4.0, "Threshold Rate (Channel Width)", minval=0.5, maxval=30.0, step=0.5, group=GRP_GEN, tooltip="Channel width factor. Higher values generate wider support/resistance channel bands.", display=display.none)
min_strength        = input.float(3.0, "Minimum Strength", minval=1.0, maxval=10.0, step=0.5, group=GRP_GEN, tooltip="Minimum pivot validation score required for a trendline/channel to be classified as Strong.", display=display.none)
max_loopback        = input.int(350, "Maximum Loopback Length", minval=20, maxval=1000, group=GRP_GEN, tooltip="Maximum number of historical bars evaluated for pivot detection and trendline modeling.", display=display.none)
extend_lines        = input.bool(true, "Extend Trend Lines", group=GRP_GEN, tooltip="Extend active trendlines forward into future bars.")

GRP_STYLE = "TRENDLINE STYLES & VISUALS"
show_as             = input.string("Trend Channel With Midline", "Show Trendlines as", options=["Trendline", "Channel", "Trend Channel", "Trend Channel With Midline"], group=GRP_STYLE, display=display.none)
shade_channels      = input.bool(true, "Shaded Channels", group=GRP_STYLE, tooltip="Fill the channel area with semi-transparent background color.")
shade_transp        = input.int(85, "Shaded Channel Transparency (%)", minval=0, maxval=98, group=GRP_STYLE, display=display.none)
enable_weak         = input.bool(true, "Enable Weak Trend Lines", group=GRP_STYLE, tooltip="Display candidate trendlines that fall below Minimum Strength as dotted lines.")
col_strong_up       = input.color(#00E676, "Strong Uptrend Color", group=GRP_STYLE)
col_strong_dn       = input.color(#FF5252, "Strong Downtrend Color", group=GRP_STYLE)
col_weak_up         = input.color(#4CAF50, "Weak Uptrend Color", group=GRP_STYLE)
col_weak_dn         = input.color(#E57373, "Weak Downtrend Color", group=GRP_STYLE)
col_mid_up          = input.color(#81C784, "Midline Uptrend Color", group=GRP_STYLE)
col_mid_dn          = input.color(#E57373, "Midline Downtrend Color", group=GRP_STYLE)
tl_style_str        = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group=GRP_STYLE, display=display.none)
tl_width            = input.int(2, "Line Width", minval=1, maxval=4, group=GRP_STYLE, display=display.none)
show_pivot_labels   = input.bool(false, "Show Pivot Points (H/L)", group=GRP_STYLE, tooltip="Show small H and L markers at confirmed pivot points.")

GRP_ANGLE = "ANGLE FILTERS & COLOR RULES"
min_angle_rate      = input.float(15.0, "Minimum Angle Rate for New Trendline (°)", minval=1.0, maxval=45.0, step=1.0, group=GRP_ANGLE, tooltip="Minimum angular separation between two trendlines to prevent cluttered parallel lines.", display=display.none)
show_angle_info     = input.bool(true, "Show Angle Info", group=GRP_ANGLE, tooltip="Display trendline inclination angle on labels and table.")
change_col_angle    = input.bool(true, "Change Color if Angle >=", group=GRP_ANGLE, tooltip="Highlight steep, high-momentum trendlines when angle exceeds threshold.")
angle_threshold     = input.float(45.0, "Angle Threshold (°)", minval=1.0, maxval=89.0, step=1.0, group=GRP_ANGLE, display=display.none)
col_steep_angle     = input.color(#FFB300, "Steep Angle Highlight Color", group=GRP_ANGLE)
filter_by_angle     = input.bool(false, "Don't Show Trendlines If Angle Is", group=GRP_ANGLE)
angle_filter_min    = input.float(2.0, "Less Than (°)", minval=0.0, maxval=80.0, group=GRP_ANGLE, display=display.none)
angle_filter_max    = input.float(65.0, "Greater Than (°)", minval=5.0, maxval=89.0, group=GRP_ANGLE, display=display.none)

GRP_LBL = "PRICE LABELS"
show_labels         = input.bool(true, "Show Price Labels on Trendlines", group=GRP_LBL)
lbl_size_str        = input.string("small", "Label Size", options=["tiny", "small", "normal", "large"], group=GRP_LBL, display=display.none)
show_pct_dist       = input.bool(true, "Show % Distance to Trendlines", group=GRP_LBL, tooltip="Show distance between current Close and the trendline in percentage.")
lbl_col_up          = input.color(#00E676, "Uptrend Label Color", group=GRP_LBL)
lbl_col_dn          = input.color(#FF5252, "Downtrend Label Color", group=GRP_LBL)
lbl_text_col        = input.color(color.white, "Label Text Color", group=GRP_LBL)

GRP_BRK = "BROKEN TREND LINES & RE-TEST"
show_broken         = input.bool(true, "Show Last Broken Trend Line", group=GRP_BRK, tooltip="Keep broken trendlines visible for verification and re-test tracking.")
broken_bars_check   = input.int(10, "Number of Bars to Check", minval=1, maxval=50, group=GRP_BRK, display=display.none)
broken_style_str    = input.string("Dotted", "Broken Line Style", options=["Dotted", "Dashed", "Solid"], group=GRP_BRK, display=display.none)
broken_width        = input.int(2, "Broken Line Width", minval=1, maxval=4, group=GRP_BRK, display=display.none)
broken_color        = input.color(#2196F3, "Broken Line Color", group=GRP_BRK)
show_broken_lbl     = input.bool(true, "Show Label for Broken Trendline", group=GRP_BRK, tooltip="Display price level label at the breakout point.")

GRP_BIS = "ANGLE BISECTOR"
show_bisector       = input.bool(false, "Show Angle Bisector", group=GRP_BIS, tooltip="Calculates and projects the bisector line between nearest uptrend and downtrend lines.")
bisector_color      = input.color(#00BCD4, "Bisector Line Color", group=GRP_BIS)
bisector_style_str  = input.string("Dashed", "Bisector Line Style", options=["Dashed", "Dotted", "Solid"], group=GRP_BIS, display=display.none)
bisector_width      = input.int(2, "Bisector Line Width", minval=1, maxval=4, group=GRP_BIS, display=display.none)

GRP_MS = "MARKET STRUCTURE"
show_ms             = input.bool(true, "Show Market Structure", group=GRP_MS, tooltip="Calculates linear regression slope & momentum across 4 lengths.")
ms_len1             = input.int(50, "Length 1", minval=5, maxval=500, group=GRP_MS, display=display.none)
ms_len2             = input.int(100, "Length 2", minval=10, maxval=500, group=GRP_MS, display=display.none)
ms_len3             = input.int(150, "Length 3", minval=15, maxval=500, group=GRP_MS, display=display.none)
ms_len4             = input.int(200, "Length 4", minval=20, maxval=500, group=GRP_MS, display=display.none)
ms_size_str         = input.string("small", "Table Size", options=["tiny", "small", "normal", "large"], group=GRP_MS, display=display.none)
ms_pos_y            = input.string("bottom", "Vertical Location", options=["top", "bottom"], group=GRP_MS, display=display.none)
ms_pos_x            = input.string("left", "Horizontal Location", options=["left", "middle", "right"], group=GRP_MS, display=display.none)
ms_text_color       = input.color(color.white, "Text Color", group=GRP_MS)
ms_col_uptrend      = input.color(#00E676, "Uptrend Color", group=GRP_MS)
ms_col_sideway_up   = input.color(#4CAF50, "Sideways (Slightly Up)", group=GRP_MS)
ms_col_downtrend    = input.color(#FF5252, "Downtrend Color", group=GRP_MS)
ms_col_sideway_dn   = input.color(#827717, "Sideways (Slightly Down)", group=GRP_MS)

GRP_TBL = "TREND LINES TABLE"
show_tl_table       = input.bool(true, "Show Trend Lines in Table", group=GRP_TBL, tooltip="Display active trendline levels, strength, angle, and distance in a HUD table.")
tl_table_size_str   = input.string("small", "Table Size", options=["tiny", "small", "normal", "large"], group=GRP_TBL, display=display.none)
tl_pos_y            = input.string("middle", "Vertical Location", options=["top", "middle", "bottom"], group=GRP_TBL, display=display.none)
tl_pos_x            = input.string("left", "Horizontal Location", options=["left", "right"], group=GRP_TBL, display=display.none)

GRP_ALT = "ALERTS & SIGNALS"
alert_type_filter   = input.string("All Alerts", "Alert Types to Trigger", options=["All Alerts", "Only Longs", "Only Shorts"], group=GRP_ALT, display=display.none)
bounce_source       = input.string("Wicks", "Check Bouncing using", options=["Wicks", "Open/Close"], group=GRP_ALT, display=display.none)
max_triangle_dist   = input.float(2.0, "Max Distance for Triangle Alert (%)", minval=0.1, maxval=10.0, step=0.1, group=GRP_ALT, display=display.none)
max_sr_dist         = input.float(1.0, "Max Distance to S/R Alert (%)", minval=0.1, maxval=10.0, step=0.1, group=GRP_ALT, display=display.none)

alt_sr_broken       = input.bool(true, "Alert: Support/Resistance Broken", group=GRP_ALT)
alt_sr_broken_freq  = input.string("Once Per Bar Close", "S/R Broken Frequency", options=["Once Per Bar", "Once Per Bar Close"], group=GRP_ALT, display=display.none)
alt_in_channel      = input.bool(false, "Alert: Price in S/R Channel", group=GRP_ALT)
alt_in_chan_freq    = input.string("Once Per Bar Close", "In Channel Frequency", options=["Once Per Bar", "Once Per Bar Close"], group=GRP_ALT, display=display.none)
alt_bounce          = input.bool(true, "Alert: Bounce Back from S/R Channel", group=GRP_ALT)
alt_bounce_freq     = input.string("Once Per Bar Close", "Bounce Frequency", options=["Once Per Bar", "Once Per Bar Close"], group=GRP_ALT, display=display.none)
alt_big_angle       = input.bool(false, "Alert: TrendLine with Big Angle", group=GRP_ALT)
alt_big_angle_freq  = input.string("Once Per Bar Close", "Big Angle Frequency", options=["Once Per Bar", "Once Per Bar Close"], group=GRP_ALT, display=display.none)
alt_triangle        = input.bool(false, "Alert: Distance between Trendlines (Triangle)", group=GRP_ALT)
alt_triangle_freq   = input.string("Once Per Bar", "Triangle Frequency", options=["Once Per Bar", "Once Per Bar Close"], group=GRP_ALT, display=display.none)
alt_dist_sr         = input.bool(false, "Alert: Distance to S/R", group=GRP_ALT)
alt_dist_sr_freq    = input.string("Once Per Bar Close", "Distance S/R Frequency", options=["Once Per Bar", "Once Per Bar Close"], group=GRP_ALT, display=display.none)
alt_new_tl          = input.bool(false, "Alert: New Trendlines", group=GRP_ALT)
alt_new_tl_freq     = input.string("Once Per Bar Close", "New Trendlines Frequency", options=["Once Per Bar", "Once Per Bar Close"], group=GRP_ALT, display=display.none)
alt_only_one        = input.bool(false, "Alert: Only Up or Downtrend line", group=GRP_ALT)
alt_only_one_freq   = input.string("Once Per Bar Close", "Only One Frequency", options=["Once Per Bar", "Once Per Bar Close"], group=GRP_ALT, display=display.none)
alt_rebroken        = input.bool(true, "Alert: Support/Resistance Re-Broken", group=GRP_ALT)
alt_rebroken_freq   = input.string("Once Per Bar Close", "Re-Broken Frequency", options=["Once Per Bar", "Once Per Bar Close"], group=GRP_ALT, display=display.none)
alt_ms_change       = input.bool(false, "Alert: Market Structure Trend Alignment", group=GRP_ALT)
alt_ms_freq         = input.string("Once Per Bar Close", "Market Structure Frequency", options=["Once Per Bar", "Once Per Bar Close"], group=GRP_ALT, display=display.none)

// Custom Alert Templates with Placeholders
msg_sup_broken      = input.string("{{ticker}}, {{timeframe}}, {{time}}, Support Broken (Short), Close:{{close}}, Broken Support:{{BrokenSupport}}, Angle:{{BrokenSupportAngle}}°, Current Support:{{CurrentSupport}}, Current Resistance:{{CurrentResistance}}", "Msg: Support Broken", group=GRP_ALT, display=display.none)
msg_res_broken      = input.string("{{ticker}}, {{timeframe}}, {{time}}, Resistance Broken (Long), Close:{{close}}, Broken Resistance:{{BrokenResistance}}, Angle:{{BrokenResistanceAngle}}°, Current Support:{{CurrentSupport}}, Current Resistance:{{CurrentResistance}}", "Msg: Resistance Broken", group=GRP_ALT, display=display.none)
msg_in_sup_chan     = input.string("{{ticker}}, {{timeframe}}, {{time}}, Price in Support Channel, Close:{{close}}, Support:{{CurrentSupport}}, Angle:{{CurrentSupportAngle}}°", "Msg: In Support Channel", group=GRP_ALT, display=display.none)
msg_in_res_chan     = input.string("{{ticker}}, {{timeframe}}, {{time}}, Price in Resistance Channel, Close:{{close}}, Resistance:{{CurrentResistance}}, Angle:{{CurrentResistanceAngle}}°", "Msg: In Resistance Channel", group=GRP_ALT, display=display.none)
msg_bounce_up       = input.string("{{ticker}}, {{timeframe}}, {{time}}, Bounce Back Up from Support (Long), Close:{{close}}, Support:{{CurrentSupport}}, Angle:{{CurrentSupportAngle}}°, Resistance:{{CurrentResistance}}", "Msg: Bounce Up", group=GRP_ALT, display=display.none)
msg_bounce_dn       = input.string("{{ticker}}, {{timeframe}}, {{time}}, Bounce Back Down from Resistance (Short), Close:{{close}}, Resistance:{{CurrentResistance}}, Angle:{{CurrentResistanceAngle}}°, Support:{{CurrentSupport}}", "Msg: Bounce Down", group=GRP_ALT, display=display.none)
msg_big_angle_up    = input.string("{{ticker}}, {{timeframe}}, {{time}}, Up Trendline with Angle Greater than {{StrongTrendAngle}}°, Close:{{close}}, Support:{{CurrentSupport}}", "Msg: Big Angle Up", group=GRP_ALT, display=display.none)
msg_big_angle_dn    = input.string("{{ticker}}, {{timeframe}}, {{time}}, Down Trendline with Angle Greater than {{StrongTrendAngle}}°, Close:{{close}}, Resistance:{{CurrentResistance}}", "Msg: Big Angle Down", group=GRP_ALT, display=display.none)
msg_triangle        = input.string("{{ticker}}, {{timeframe}}, {{time}}, Triangle Squeeze Distance: {{TriangleDistancePercent}}%, Support:{{CurrentSupport}}, Resistance:{{CurrentResistance}}", "Msg: Triangle Squeeze", group=GRP_ALT, display=display.none)
msg_dist_sr         = input.string("{{ticker}}, {{timeframe}}, {{time}}, Price Near S/R ({{DistanceTosrPercent}}%), Close:{{close}}, Support:{{CurrentSupport}}, Resistance:{{CurrentResistance}}", "Msg: Distance S/R", group=GRP_ALT, display=display.none)
msg_new_uptl        = input.string("{{ticker}}, {{timeframe}}, {{time}}, New Uptrend Line Appeared, Level:{{CurrentSupport}}, Angle:{{CurrentSupportAngle}}°", "Msg: New Uptrend Line", group=GRP_ALT, display=display.none)
msg_new_dntl        = input.string("{{ticker}}, {{timeframe}}, {{time}}, New Downtrend Line Appeared, Level:{{CurrentResistance}}, Angle:{{CurrentResistanceAngle}}°", "Msg: New Downtrend Line", group=GRP_ALT, display=display.none)
msg_only_up         = input.string("{{ticker}}, {{timeframe}}, {{time}}, Only Uptrend line(s) remain, Close:{{close}}, Current Support:{{CurrentSupport}}", "Msg: Only Uptrend Remains", group=GRP_ALT, display=display.none)
msg_only_dn         = input.string("{{ticker}}, {{timeframe}}, {{time}}, Only Downtrend line(s) remain, Close:{{close}}, Current Resistance:{{CurrentResistance}}", "Msg: Only Downtrend Remains", group=GRP_ALT, display=display.none)
msg_sup_rebroken    = input.string("{{ticker}}, {{timeframe}}, {{time}}, Support Re-Broken, Close:{{close}}, Re-Broken Support:{{ReBrokenSupport}}", "Msg: Support Re-Broken", group=GRP_ALT, display=display.none)
msg_res_rebroken    = input.string("{{ticker}}, {{timeframe}}, {{time}}, Resistance Re-Broken, Close:{{close}}, Re-Broken Resistance:{{ReBrokenResistance}}", "Msg: Resistance Re-Broken", group=GRP_ALT, display=display.none)
msg_ms_aligned_up   = input.string("{{ticker}}, {{timeframe}}, {{time}}, Market Structure: All Lengths Aligned UPTREND!", "Msg: MS Aligned Up", group=GRP_ALT, display=display.none)
msg_ms_aligned_dn   = input.string("{{ticker}}, {{timeframe}}, {{time}}, Market Structure: All Lengths Aligned DOWNTREND!", "Msg: MS Aligned Down", group=GRP_ALT, display=display.none)
msg_ms_ended        = input.string("{{ticker}}, {{timeframe}}, {{time}}, Market Structure: Trend is over", "Msg: MS Trend Over", group=GRP_ALT, display=display.none)

// ==================================================================================================
// HELPER FUNCTIONS & GEOMETRIC CALCULATORS
// ==================================================================================================
// Convert string options to Pine types
get_line_style(s) =>
    s == "Dotted" ? line.style_dotted : (s == "Dashed" ? line.style_dashed : line.style_solid)

get_size(s) =>
    s == "tiny" ? size.tiny : (s == "small" ? size.small : (s == "normal" ? size.normal : size.large))

get_table_pos(vert, horiz) =>
    vert == "top" ? (horiz == "left" ? position.top_left : (horiz == "right" ? position.top_right : position.top_center)) :
     vert == "middle" ? (horiz == "left" ? position.middle_left : position.middle_right) :
     (horiz == "left" ? position.bottom_left : (horiz == "right" ? position.bottom_right : position.bottom_center))

// Timestamp formatted with user UTC offset
get_utc_time_str(offset_hours) =>
    int adj_time = time + int(offset_hours * 3600000)
    int hr  = (adj_time / 3600000) % 24
    int min = (adj_time / 60000) % 60
    string hr_str  = (hr < 10 ? "0" : "") + str.tostring(hr)
    string min_str = (min < 10 ? "0" : "") + str.tostring(min)
    hr_str + ":" + min_str

// Visible window normalization for stable angle calculations matching TradingView charts
VISIBLE_WINDOW = 292
float chart_y_high = ta.highest(high, math.min(bar_index + 1, VISIBLE_WINDOW))
float chart_y_low  = ta.lowest(low, math.min(bar_index + 1, VISIBLE_WINDOW))
float chart_y_span = math.max(chart_y_high - chart_y_low, syminfo.mintick * 10.0)

calc_angle(y1, y2, x1, x2) =>
    if x2 <= x1 or chart_y_span <= 0
        0.0
    else
        float norm_dy = (y2 - y1) / chart_y_span
        float norm_dx = float(x2 - x1) / float(VISIBLE_WINDOW)
        float rad = math.atan(norm_dy / norm_dx)
        math.round(rad * (180.0 / math.pi))

// Template placeholder replacement engine
format_alert(template, b_sup, b_res, c_sup, c_res, b_sup_ang, b_res_ang, c_sup_ang, c_res_ang, st_ang, tri_dist, sr_dist, reb_sup, reb_res, utc_off) =>
    string msg = template
    msg := str.replace_all(msg, "{{ticker}}", syminfo.ticker)
    msg := str.replace_all(msg, "{{timeframe}}", timeframe.period)
    msg := str.replace_all(msg, "{{time}}", get_utc_time_str(utc_off))
    msg := str.replace_all(msg, "{{close}}", str.tostring(close, "#.##"))
    msg := str.replace_all(msg, "{{open}}", str.tostring(open, "#.##"))
    msg := str.replace_all(msg, "{{high}}", str.tostring(high, "#.##"))
    msg := str.replace_all(msg, "{{low}}", str.tostring(low, "#.##"))
    msg := str.replace_all(msg, "{{BrokenSupport}}", b_sup > 0 ? str.tostring(b_sup, "#.##") : "None")
    msg := str.replace_all(msg, "{{BrokenResistance}}", b_res > 0 ? str.tostring(b_res, "#.##") : "None")
    msg := str.replace_all(msg, "{{CurrentSupport}}", c_sup > 0 ? str.tostring(c_sup, "#.##") : "None")
    msg := str.replace_all(msg, "{{CurrentResistance}}", c_res > 0 ? str.tostring(c_res, "#.##") : "None")
    msg := str.replace_all(msg, "{{BrokenSupportAngle}}", str.tostring(b_sup_ang, "#"))
    msg := str.replace_all(msg, "{{BrokenResistanceAngle}}", str.tostring(b_res_ang, "#"))
    msg := str.replace_all(msg, "{{CurrentSupportAngle}}", str.tostring(c_sup_ang, "#"))
    msg := str.replace_all(msg, "{{CurrentResistanceAngle}}", str.tostring(c_res_ang, "#"))
    msg := str.replace_all(msg, "{{StrongTrendAngle}}", str.tostring(st_ang, "#"))
    msg := str.replace_all(msg, "{{TriangleDistancePercent}}", str.tostring(tri_dist, "#.##"))
    msg := str.replace_all(msg, "{{TriangleDistancePrecent}}", str.tostring(tri_dist, "#.##"))
    msg := str.replace_all(msg, "{{DistanceTosrPercent}}", str.tostring(sr_dist, "#.##"))
    msg := str.replace_all(msg, "{{DistanceToSRPercent}}", str.tostring(sr_dist, "#.##"))
    msg := str.replace_all(msg, "{{distancetosrpercent}}", str.tostring(sr_dist, "#.##"))
    msg := str.replace_all(msg, "{{ReBrokenSupport}}", reb_sup > 0 ? str.tostring(reb_sup, "#.##") : "None")
    msg := str.replace_all(msg, "{{ReBrokenResistance}}", reb_res > 0 ? str.tostring(reb_res, "#.##") : "None")
    msg := str.replace_all(msg, "{{br}}", "\n")
    msg

// Custom data types for clean OOP Trendline representation
type TrendlineModel
    bool  is_up
    int   bar1
    float price1
    int   bar2
    float price2
    float slope
    float current_val
    float angle
    float strength
    bool  is_strong
    float opp_offset
    bool  is_broken
    int   break_bar
    float break_price

// ==================================================================================================
// PIVOT DETECTION & HISTORICAL ARRAYS
// ==================================================================================================
float src_h = src_mode == "High/Low" ? high : close
float src_l = src_mode == "High/Low" ? low : close

float ph_val = ta.pivothigh(src_h, prd, prd)
float pl_val = ta.pivotlow(src_l, prd, prd)

// Pivot storage
var int[]   ph_bars   = array.new_int(0)
var float[] ph_prices = array.new_float(0)
var int[]   pl_bars   = array.new_int(0)
var float[] pl_prices = array.new_float(0)

if not na(ph_val)
    int p_bar = bar_index - prd
    array.push(ph_bars, p_bar)
    array.push(ph_prices, ph_val)
    if show_pivot_labels
        label.new(p_bar, ph_val, "H", color=color.new(col_strong_dn, 70), textcolor=color.white, style=label.style_label_down, size=size.tiny)

if not na(pl_val)
    int p_bar = bar_index - prd
    array.push(pl_bars, p_bar)
    array.push(pl_prices, pl_val)
    if show_pivot_labels
        label.new(p_bar, pl_val, "L", color=color.new(col_strong_up, 70), textcolor=color.white, style=label.style_label_up, size=size.tiny)

// Keep arrays trimmed to max_loopback window
while array.size(ph_bars) > 0
    if (bar_index - array.get(ph_bars, 0)) > max_loopback
        array.shift(ph_bars)
        array.shift(ph_prices)
    else
        break

while array.size(pl_bars) > 0
    if (bar_index - array.get(pl_bars, 0)) > max_loopback
        array.shift(pl_bars)
        array.shift(pl_prices)
    else
        break

// ==================================================================================================
// CANDIDATE TRENDLINES SOLVER & CLUSTERING ALGORITHM
// ==================================================================================================
float current_atr = ta.atr(14)
float base_channel_width = current_atr * (threshold_rate * 0.75)

// Global models for current bar
var TrendlineModel[] active_uptrends   = array.new<TrendlineModel>(0)
var TrendlineModel[] active_downtrends = array.new<TrendlineModel>(0)
var TrendlineModel[] broken_trendlines = array.new<TrendlineModel>(0)

// Helper: check if price touches or respects channel
evaluate_uptrend(b1, p1, b2, p2) =>
    float m = (p2 - p1) / float(b2 - b1)
    float cur_val = p2 + m * float(bar_index - b2)
    float ang = calc_angle(p1, cur_val, b1, bar_index)
    
    // Count pivot touches and channel width
    int touches = 0
    int pl_len = array.size(pl_bars)
    if pl_len > 0
        for k = 0 to pl_len - 1
            int pb = array.get(pl_bars, k)
            if pb >= b1 and pb <= bar_index
                float line_at_p = p1 + m * float(pb - b1)
                float diff = array.get(pl_prices, k) - line_at_p
                if diff >= -base_channel_width * 0.35 and diff <= base_channel_width * 1.5
                    touches += 1
    
    // Find opposing boundary (highest peak above the support line)
    float max_peak_diff = base_channel_width
    int ph_len = array.size(ph_bars)
    if ph_len > 0
        for k = 0 to ph_len - 1
            int pb = array.get(ph_bars, k)
            if pb >= b1 and pb <= bar_index
                float line_at_p = p1 + m * float(pb - b1)
                float diff = array.get(ph_prices, k) - line_at_p
                if diff > max_peak_diff
                    max_peak_diff := diff

    float str_val = 2.0 + float(touches) * 0.95
    bool is_str = str_val >= min_strength
    TrendlineModel.new(true, b1, p1, b2, p2, m, cur_val, ang, str_val, is_str, max_peak_diff, false, 0, 0.0)

evaluate_downtrend(b1, p1, b2, p2) =>
    float m = (p2 - p1) / float(b2 - b1)
    float cur_val = p2 + m * float(bar_index - b2)
    float ang = math.abs(calc_angle(p1, cur_val, b1, bar_index))
    
    // Count pivot touches
    int touches = 0
    int ph_len = array.size(ph_bars)
    if ph_len > 0
        for k = 0 to ph_len - 1
            int pb = array.get(ph_bars, k)
            if pb >= b1 and pb <= bar_index
                float line_at_p = p1 + m * float(pb - b1)
                float diff = line_at_p - array.get(ph_prices, k)
                if diff >= -base_channel_width * 0.35 and diff <= base_channel_width * 1.5
                    touches += 1
                    
    // Find opposing boundary (lowest valley below resistance line)
    float max_valley_diff = base_channel_width
    int pl_len = array.size(pl_bars)
    if pl_len > 0
        for k = 0 to pl_len - 1
            int pb = array.get(pl_bars, k)
            if pb >= b1 and pb <= bar_index
                float line_at_p = p1 + m * float(pb - b1)
                float diff = line_at_p - array.get(pl_prices, k)
                if diff > max_valley_diff
                    max_valley_diff := diff

    float str_val = 2.0 + float(touches) * 0.95
    bool is_str = str_val >= min_strength
    TrendlineModel.new(false, b1, p1, b2, p2, m, cur_val, ang, str_val, is_str, max_valley_diff, false, 0, 0.0)

// Execute discovery on the current bar
TrendlineModel[] candidates_up = array.new<TrendlineModel>(0)
TrendlineModel[] candidates_dn = array.new<TrendlineModel>(0)

int pl_count = array.size(pl_bars)
int ph_count = array.size(ph_bars)

// Evaluate uptrends (multi-pivot search across recent swings)
if pl_count >= 2
    int max_j = math.min(pl_count - 1, 4)
    for j = 0 to max_j - 1
        int idx2 = pl_count - 1 - j
        int b2 = array.get(pl_bars, idx2)
        float p2 = array.get(pl_prices, idx2)
        int max_i = math.min(idx2, 12)
        for i = 1 to max_i
            int idx1 = idx2 - i
            int b1 = array.get(pl_bars, idx1)
            float p1 = array.get(pl_prices, idx1)
            if b2 > b1 and p2 >= p1
                TrendlineModel m_up = evaluate_uptrend(b1, p1, b2, p2)
                if (not filter_by_angle) or (m_up.angle >= angle_filter_min and m_up.angle <= angle_filter_max)
                    if m_up.is_strong or enable_weak
                        array.push(candidates_up, m_up)

// Evaluate downtrends (multi-pivot search across recent swings)
if ph_count >= 2
    int max_j = math.min(ph_count - 1, 4)
    for j = 0 to max_j - 1
        int idx2 = ph_count - 1 - j
        int b2 = array.get(ph_bars, idx2)
        float p2 = array.get(ph_prices, idx2)
        int max_i = math.min(idx2, 12)
        for i = 1 to max_i
            int idx1 = idx2 - i
            int b1 = array.get(ph_bars, idx1)
            float p1 = array.get(ph_prices, idx1)
            if b2 > b1 and p2 <= p1
                TrendlineModel m_dn = evaluate_downtrend(b1, p1, b2, p2)
                if (not filter_by_angle) or (m_dn.angle >= angle_filter_min and m_dn.angle <= angle_filter_max)
                    if m_dn.is_strong or enable_weak
                        array.push(candidates_dn, m_dn)

// Sort candidates by strength descending so best trendlines are chosen
if array.size(candidates_up) > 1
    for p = 0 to array.size(candidates_up) - 2
        for q = 0 to array.size(candidates_up) - 2 - p
            TrendlineModel t1 = array.get(candidates_up, q)
            TrendlineModel t2 = array.get(candidates_up, q + 1)
            if t1.strength < t2.strength
                array.set(candidates_up, q, t2)
                array.set(candidates_up, q + 1, t1)

if array.size(candidates_dn) > 1
    for p = 0 to array.size(candidates_dn) - 2
        for q = 0 to array.size(candidates_dn) - 2 - p
            TrendlineModel t1 = array.get(candidates_dn, q)
            TrendlineModel t2 = array.get(candidates_dn, q + 1)
            if t1.strength < t2.strength
                array.set(candidates_dn, q, t2)
                array.set(candidates_dn, q + 1, t1)

// Select top trendlines adhering to Minimum Angle Rate
TrendlineModel[] selected_up = array.new<TrendlineModel>(0)
if array.size(candidates_up) > 0
    for i = 0 to array.size(candidates_up) - 1
        TrendlineModel cand = array.get(candidates_up, i)
        bool distinct = true
        if array.size(selected_up) > 0
            for j = 0 to array.size(selected_up) - 1
                TrendlineModel sel = array.get(selected_up, j)
                if math.abs(cand.angle - sel.angle) < min_angle_rate
                    distinct := false
                    break
        if distinct
            array.push(selected_up, cand)
        if array.size(selected_up) >= 3
            break

TrendlineModel[] selected_dn = array.new<TrendlineModel>(0)
if array.size(candidates_dn) > 0
    for i = 0 to array.size(candidates_dn) - 1
        TrendlineModel cand = array.get(candidates_dn, i)
        bool distinct = true
        if array.size(selected_dn) > 0
            for j = 0 to array.size(selected_dn) - 1
                TrendlineModel sel = array.get(selected_dn, j)
                if math.abs(cand.angle - sel.angle) < min_angle_rate
                    distinct := false
                    break
        if distinct
            array.push(selected_dn, cand)
        if array.size(selected_dn) >= 3
            break

int count_up = array.size(selected_up)
int count_dn = array.size(selected_dn)

// Track new trendline appearances
var int last_up_tl_bar1 = 0
var int last_dn_tl_bar1 = 0
bool event_new_uptl = false
if count_up > 0
    if array.get(selected_up, 0).bar1 != last_up_tl_bar1
        event_new_uptl := true
        last_up_tl_bar1 := array.get(selected_up, 0).bar1

bool event_new_dntl = false
if count_dn > 0
    if array.get(selected_dn, 0).bar1 != last_dn_tl_bar1
        event_new_dntl := true
        last_dn_tl_bar1 := array.get(selected_dn, 0).bar1

// ==================================================================================================
// BREAKOUT & RETEST STATE ENGINE
// ==================================================================================================
var float last_broken_support_level = 0.0
var float last_broken_support_angle = 0.0
var float last_broken_resist_level  = 0.0
var float last_broken_resist_angle  = 0.0

var float rebroken_support_level    = 0.0
var float rebroken_resist_level     = 0.0

bool event_support_broken           = false
bool event_resist_broken            = false
bool event_support_rebroken         = false
bool event_resist_rebroken          = false

// Check active support lines for breaks
if count_up > 0
    for i = 0 to count_up - 1
        TrendlineModel t = array.get(selected_up, i)
        float line_now = t.current_val
        float line_prev = t.price1 + t.slope * float(bar_index - 1 - t.bar1)
        if close[1] >= line_prev and close < line_now
            event_support_broken := true
            last_broken_support_level := line_now
            last_broken_support_angle := t.angle
            t.is_broken := true
            t.break_bar := bar_index
            t.break_price := line_now
            array.push(broken_trendlines, t)

// Check active resistance lines for breaks
if count_dn > 0
    for i = 0 to count_dn - 1
        TrendlineModel t = array.get(selected_dn, i)
        float line_now = t.current_val
        float line_prev = t.price1 + t.slope * float(bar_index - 1 - t.bar1)
        if close[1] <= line_prev and close > line_now
            event_resist_broken := true
            last_broken_resist_level := line_now
            last_broken_resist_angle := t.angle
            t.is_broken := true
            t.break_bar := bar_index
            t.break_price := line_now
            array.push(broken_trendlines, t)

// Retest / Re-broken check
if array.size(broken_trendlines) > 0
    for i = array.size(broken_trendlines) - 1 to 0
        TrendlineModel bt = array.get(broken_trendlines, i)
        if bar_index - bt.break_bar <= broken_bars_check
            float cur_line = bt.price1 + bt.slope * float(bar_index - bt.bar1)
            float prev_line = bt.price1 + bt.slope * float(bar_index - 1 - bt.bar1)
            if bt.is_up and close[1] < prev_line and close > cur_line
                event_support_rebroken := true
                rebroken_support_level := cur_line
            else if (not bt.is_up) and close[1] > prev_line and close < cur_line
                event_resist_rebroken := true
                rebroken_resist_level := cur_line

// Trim broken trendlines older than broken_bars_check
while array.size(broken_trendlines) > 0
    if (bar_index - array.get(broken_trendlines, 0).break_bar) > broken_bars_check
        array.shift(broken_trendlines)
    else
        break

// Closest S/R Levels and angles
float closest_support = na
float closest_support_angle = 0.0
if count_up > 0
    closest_support := array.get(selected_up, 0).current_val
    closest_support_angle := array.get(selected_up, 0).angle

float closest_resist = na
float closest_resist_angle = 0.0
if count_dn > 0
    closest_resist := array.get(selected_dn, 0).current_val
    closest_resist_angle := array.get(selected_dn, 0).angle

// Price in Channel Checks
float bounce_high = bounce_source == "Wicks" ? high : math.max(open, close)
float bounce_low  = bounce_source == "Wicks" ? low : math.min(open, close)

bool in_sup_channel = false
bool bounce_up_from_sup = false
if not na(closest_support)
    float sup_upper = closest_support + base_channel_width
    in_sup_channel := bounce_low <= sup_upper and bounce_low >= closest_support - base_channel_width * 0.2
    bounce_up_from_sup := (bounce_low[1] <= sup_upper or bounce_low <= sup_upper) and close > sup_upper

bool in_res_channel = false
bool bounce_dn_from_res = false
if not na(closest_resist)
    float res_lower = closest_resist - base_channel_width
    in_res_channel := bounce_high >= res_lower and bounce_high <= closest_resist + base_channel_width * 0.2
    bounce_dn_from_res := (bounce_high[1] >= res_lower or bounce_high >= res_lower) and close < res_lower

// Steep Angle Checks
bool big_angle_up = closest_support_angle >= angle_threshold
bool big_angle_dn = closest_resist_angle >= angle_threshold

// Triangle Distance Check
float triangle_dist_pct = 0.0
bool event_triangle_squeeze = false
if not na(closest_support) and not na(closest_resist) and closest_resist > closest_support
    triangle_dist_pct := (closest_resist - closest_support) / close * 100.0
    if triangle_dist_pct <= max_triangle_dist
        event_triangle_squeeze := true

// Distance to S/R Alert Check
float dist_to_sup_pct = not na(closest_support) ? math.abs(close - closest_support) / close * 100.0 : 999.0
float dist_to_res_pct = not na(closest_resist) ? math.abs(close - closest_resist) / close * 100.0 : 999.0
float min_sr_dist_pct = math.min(dist_to_sup_pct, dist_to_res_pct)
bool event_dist_to_sr = min_sr_dist_pct <= max_sr_dist

// Only One Remains Alert (safe scalar history)
bool only_uptrend_remains   = count_up > 0 and count_dn == 0 and count_dn[1] > 0
bool only_downtrend_remains = count_dn > 0 and count_up == 0 and count_up[1] > 0

// ==================================================================================================
// MARKET STRUCTURE REGRESSION ENGINE
// ==================================================================================================
calc_ms(len) =>
    float r0 = ta.linreg(close, len, 0)
    float r1 = ta.linreg(close, len, 1)
    float r2 = ta.linreg(close, len, 2)
    float slope0 = r0 - r1
    float slope1 = r1 - r2
    
    // Normalized angle of the regression line
    float norm_s = (slope0 / (current_atr > 0 ? current_atr : syminfo.mintick)) * 6.5
    float ang = math.round(math.atan(norm_s) * (180.0 / math.pi))
    
    // Trend classification
    int trend_type = 0 // 2: Up, 1: Side Up, -2: Down, -1: Side Down
    color col = ms_col_sideway_up
    string desc = "Sideways"
    if ang >= 10.0
        trend_type := 2
        col := ms_col_uptrend
        desc := "UpTrend"
    else if ang > 0.0
        trend_type := 1
        col := ms_col_sideway_up
        desc := "Sideways"
    else if ang <= -10.0
        trend_type := -2
        col := ms_col_downtrend
        desc := "DownTrend"
    else
        trend_type := -1
        col := ms_col_sideway_dn
        desc := "Sideways"
        
    // Momentum calculation
    string mom = "=="
    if math.abs(slope0) > math.abs(slope1) * 1.05
        mom := ">>"
    else if math.abs(slope0) < math.abs(slope1) * 0.95
        mom := "<<"
        
    [ang, desc, mom, col, trend_type]

[ms1_ang, ms1_desc, ms1_mom, ms1_col, ms1_t] = calc_ms(ms_len1)
[ms2_ang, ms2_desc, ms2_mom, ms2_col, ms2_t] = calc_ms(ms_len2)
[ms3_ang, ms3_desc, ms3_mom, ms3_col, ms3_t] = calc_ms(ms_len3)
[ms4_ang, ms4_desc, ms4_mom, ms4_col, ms4_t] = calc_ms(ms_len4)

bool all_ms_up = (ms1_t > 0) and (ms2_t > 0) and (ms3_t > 0) and (ms4_t > 0)
bool all_ms_dn = (ms1_t < 0) and (ms2_t < 0) and (ms3_t < 0) and (ms4_t < 0)
bool ms_aligned_up_event = all_ms_up and not all_ms_up[1]
bool ms_aligned_dn_event = all_ms_dn and not all_ms_dn[1]
bool ms_trend_ended_event = (all_ms_up[1] and not all_ms_up) or (all_ms_dn[1] and not all_ms_dn)

// ==================================================================================================
// EXTERNAL SIGNALS (Plot for Strategy / External Script Automation)
// ==================================================================================================
// 1: Support Broken, 2: Resistance Broken, 3: In Support Channel, 4: In Resistance Channel
// 5: Bounce Up, 6: Bounce Down, 7: Big Angle Up, 8: Big Angle Down
// 9: Support Re-Broken, 10: Resistance Re-Broken, 11: New Uptrend, 12: New Downtrend
// Decimals: Distance to closer S/R (- for Support closer, + for Resistance closer)
float ext_signal = 0.0

if event_support_broken
    ext_signal := 1.0
else if event_resist_broken
    ext_signal := 2.0
else if in_sup_channel
    ext_signal := 3.0
else if in_res_channel
    ext_signal := 4.0
else if bounce_up_from_sup
    ext_signal := 5.0
else if bounce_dn_from_res
    ext_signal := 6.0
else if big_angle_up
    ext_signal := 7.0
else if big_angle_dn
    ext_signal := 8.0
else if event_support_rebroken
    ext_signal := 9.0
else if event_resist_rebroken
    ext_signal := 10.0
else if event_new_uptl
    ext_signal := 11.0
else if event_new_dntl
    ext_signal := 12.0
else
    // Fractional distance indicator
    if not na(closest_resist) and (na(closest_support) or dist_to_res_pct < dist_to_sup_pct)
        ext_signal := math.round(dist_to_res_pct) / 100.0
    else if not na(closest_support)
        ext_signal := -math.round(dist_to_sup_pct) / 100.0

plot(ext_signal, title="External Signal", display=display.none)

// ==================================================================================================
// ALL-IN-ONE ALERTS ENGINE WITH FREQUENCY DISPATCHER
// ==================================================================================================
fire_alert(template, b_sup, b_res, c_sup, c_res, b_sup_ang, b_res_ang, c_sup_ang, c_res_ang, reb_sup, reb_res, freq_str) =>
    string formatted = format_alert(template, b_sup, b_res, c_sup, c_res, b_sup_ang, b_res_ang, c_sup_ang, c_res_ang, angle_threshold, triangle_dist_pct, min_sr_dist_pct, reb_sup, reb_res, utc_offset)
    if freq_str == "Once Per Bar"
        alert(formatted, alert.freq_once_per_bar)
    else
        alert(formatted, alert.freq_once_per_bar_close)

bool allow_longs  = alert_type_filter == "All Alerts" or alert_type_filter == "Only Longs"
bool allow_shorts = alert_type_filter == "All Alerts" or alert_type_filter == "Only Shorts"

if alt_sr_broken
    if event_support_broken and allow_shorts
        fire_alert(msg_sup_broken, last_broken_support_level, 0.0, closest_support, closest_resist, last_broken_support_angle, 0.0, closest_support_angle, closest_resist_angle, 0.0, 0.0, alt_sr_broken_freq)
    if event_resist_broken and allow_longs
        fire_alert(msg_res_broken, 0.0, last_broken_resist_level, closest_support, closest_resist, 0.0, last_broken_resist_angle, closest_support_angle, closest_resist_angle, 0.0, 0.0, alt_sr_broken_freq)

if alt_in_channel
    if in_sup_channel and allow_longs
        fire_alert(msg_in_sup_chan, 0.0, 0.0, closest_support, closest_resist, 0.0, 0.0, closest_support_angle, closest_resist_angle, 0.0, 0.0, alt_in_chan_freq)
    if in_res_channel and allow_shorts
        fire_alert(msg_in_res_chan, 0.0, 0.0, closest_support, closest_resist, 0.0, 0.0, closest_support_angle, closest_resist_angle, 0.0, 0.0, alt_in_chan_freq)

if alt_bounce
    if bounce_up_from_sup and allow_longs
        fire_alert(msg_bounce_up, 0.0, 0.0, closest_support, closest_resist, 0.0, 0.0, closest_support_angle, closest_resist_angle, 0.0, 0.0, alt_bounce_freq)
    if bounce_dn_from_res and allow_shorts
        fire_alert(msg_bounce_dn, 0.0, 0.0, closest_support, closest_resist, 0.0, 0.0, closest_support_angle, closest_resist_angle, 0.0, 0.0, alt_bounce_freq)

if alt_big_angle
    if big_angle_up and allow_longs
        fire_alert(msg_big_angle_up, 0.0, 0.0, closest_support, closest_resist, 0.0, 0.0, closest_support_angle, closest_resist_angle, 0.0, 0.0, alt_big_angle_freq)
    if big_angle_dn and allow_shorts
        fire_alert(msg_big_angle_dn, 0.0, 0.0, closest_support, closest_resist, 0.0, 0.0, closest_support_angle, closest_resist_angle, 0.0, 0.0, alt_big_angle_freq)

if alt_triangle and event_triangle_squeeze
    fire_alert(msg_triangle, 0.0, 0.0, closest_support, closest_resist, 0.0, 0.0, closest_support_angle, closest_resist_angle, 0.0, 0.0, alt_triangle_freq)

if alt_dist_sr and event_dist_to_sr
    fire_alert(msg_dist_sr, 0.0, 0.0, closest_support, closest_resist, 0.0, 0.0, closest_support_angle, closest_resist_angle, 0.0, 0.0, alt_dist_sr_freq)

if alt_new_tl
    if event_new_uptl and allow_longs
        fire_alert(msg_new_uptl, 0.0, 0.0, closest_support, closest_resist, 0.0, 0.0, closest_support_angle, closest_resist_angle, 0.0, 0.0, alt_new_tl_freq)
    if event_new_dntl and allow_shorts
        fire_alert(msg_new_dntl, 0.0, 0.0, closest_support, closest_resist, 0.0, 0.0, closest_support_angle, closest_resist_angle, 0.0, 0.0, alt_new_tl_freq)

if alt_only_one
    if only_uptrend_remains and allow_longs
        fire_alert(msg_only_up, 0.0, 0.0, closest_support, closest_resist, 0.0, 0.0, closest_support_angle, closest_resist_angle, 0.0, 0.0, alt_only_one_freq)
    if only_downtrend_remains and allow_shorts
        fire_alert(msg_only_dn, 0.0, 0.0, closest_support, closest_resist, 0.0, 0.0, closest_support_angle, closest_resist_angle, 0.0, 0.0, alt_only_one_freq)

if alt_rebroken
    if event_support_rebroken and allow_longs
        fire_alert(msg_sup_rebroken, 0.0, 0.0, closest_support, closest_resist, 0.0, 0.0, closest_support_angle, closest_resist_angle, rebroken_support_level, 0.0, alt_rebroken_freq)
    if event_resist_rebroken and allow_shorts
        fire_alert(msg_res_rebroken, 0.0, 0.0, closest_support, closest_resist, 0.0, 0.0, closest_support_angle, closest_resist_angle, 0.0, rebroken_resist_level, alt_rebroken_freq)

if alt_ms_change
    if ms_aligned_up_event and allow_longs
        fire_alert(msg_ms_aligned_up, 0.0, 0.0, closest_support, closest_resist, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, alt_ms_freq)
    if ms_aligned_dn_event and allow_shorts
        fire_alert(msg_ms_aligned_dn, 0.0, 0.0, closest_support, closest_resist, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, alt_ms_freq)
    if ms_trend_ended_event
        fire_alert(msg_ms_ended, 0.0, 0.0, closest_support, closest_resist, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, alt_ms_freq)

// ==================================================================================================
// GRAPHICAL RENDERING ENGINE (Lines, Channels, Fills, Labels, Bisector)
// ==================================================================================================
var line[]     render_lines     = array.new_line(0)
var linefill[] render_fills     = array.new_linefill(0)
var label[]    render_labels    = array.new_label(0)

// Helper to safely clean previous drawings on redraw
clear_drawings() =>
    while array.size(render_lines) > 0
        line.delete(array.pop(render_lines))
    while array.size(render_fills) > 0
        linefill.delete(array.pop(render_fills))
    while array.size(render_labels) > 0
        label.delete(array.pop(render_labels))

if barstate.islast
    clear_drawings()
    
    line_extend_mode = extend_lines ? extend.right : extend.none
    line_style_choice = get_line_style(tl_style_str)
    lbl_size_choice = get_size(lbl_size_str)
    
    // Draw Active Uptrends
    if count_up > 0
        for i = 0 to count_up - 1
            TrendlineModel t = array.get(selected_up, i)
            color base_col = t.is_strong ? col_strong_up : col_weak_up
            if change_col_angle and t.angle >= angle_threshold
                base_col := col_steep_angle
            line_style_use = t.is_strong ? line_style_choice : line.style_dotted
            
            // Clamp start bar safely within TradingView buffer
            int c_b1 = math.max(t.bar1, bar_index - 490)
            float c_p1 = c_b1 == t.bar1 ? t.price1 : t.price1 + t.slope * float(c_b1 - t.bar1)
            
            // Primary Support Line
            line l_main = line.new(c_b1, c_p1, t.bar2, t.price2, xloc=xloc.bar_index, extend=line_extend_mode, color=base_col, style=line_style_use, width=tl_width)
            array.push(render_lines, l_main)
            
            // Channel Boundary & Midline
            if show_as != "Trendline"
                float opp_w = show_as == "Channel" ? base_channel_width : t.opp_offset
                line l_opp = line.new(c_b1, c_p1 + opp_w, t.bar2, t.price2 + opp_w, xloc=xloc.bar_index, extend=line_extend_mode, color=color.new(base_col, 20), style=line_style_use, width=math.max(1, tl_width - 1))
                array.push(render_lines, l_opp)
                
                if shade_channels
                    linefill lf = linefill.new(l_main, l_opp, color.new(base_col, shade_transp))
                    array.push(render_fills, lf)
                    
                if show_as == "Trend Channel With Midline"
                    float mid_w = opp_w * 0.5
                    line l_mid = line.new(c_b1, c_p1 + mid_w, t.bar2, t.price2 + mid_w, xloc=xloc.bar_index, extend=line_extend_mode, color=col_mid_up, style=line.style_dashed, width=1)
                    array.push(render_lines, l_mid)
                    
            // Price Label
            if show_labels
                float dist_pct = math.abs(close - t.current_val) / close * 100.0
                string txt = str.tostring(t.current_val, "#.##")
                if show_pct_dist
                    txt += "\n" + str.tostring(dist_pct, "#.##") + " %"
                if show_angle_info
                    txt += "\n" + str.tostring(t.angle, "#") + "°"
                label lb = label.new(bar_index, t.current_val, txt, xloc=xloc.bar_index, yloc=yloc.price, color=base_col, textcolor=lbl_text_col, style=label.style_label_up, size=lbl_size_choice)
                array.push(render_labels, lb)

    // Draw Active Downtrends
    if count_dn > 0
        for i = 0 to count_dn - 1
            TrendlineModel t = array.get(selected_dn, i)
            color base_col = t.is_strong ? col_strong_dn : col_weak_dn
            if change_col_angle and t.angle >= angle_threshold
                base_col := col_steep_angle
            line_style_use = t.is_strong ? line_style_choice : line.style_dotted
            
            // Clamp start bar safely within TradingView buffer
            int c_b1 = math.max(t.bar1, bar_index - 490)
            float c_p1 = c_b1 == t.bar1 ? t.price1 : t.price1 + t.slope * float(c_b1 - t.bar1)
            
            // Primary Resistance Line
            line l_main = line.new(c_b1, c_p1, t.bar2, t.price2, xloc=xloc.bar_index, extend=line_extend_mode, color=base_col, style=line_style_use, width=tl_width)
            array.push(render_lines, l_main)
            
            // Channel Boundary & Midline
            if show_as != "Trendline"
                float opp_w = show_as == "Channel" ? base_channel_width : t.opp_offset
                line l_opp = line.new(c_b1, c_p1 - opp_w, t.bar2, t.price2 - opp_w, xloc=xloc.bar_index, extend=line_extend_mode, color=color.new(base_col, 20), style=line_style_use, width=math.max(1, tl_width - 1))
                array.push(render_lines, l_opp)
                
                if shade_channels
                    linefill lf = linefill.new(l_main, l_opp, color.new(base_col, shade_transp))
                    array.push(render_fills, lf)
                    
                if show_as == "Trend Channel With Midline"
                    float mid_w = opp_w * 0.5
                    line l_mid = line.new(c_b1, c_p1 - mid_w, t.bar2, t.price2 - mid_w, xloc=xloc.bar_index, extend=line_extend_mode, color=col_mid_dn, style=line.style_dashed, width=1)
                    array.push(render_lines, l_mid)
                    
            // Price Label
            if show_labels
                float dist_pct = math.abs(close - t.current_val) / close * 100.0
                string txt = str.tostring(t.current_val, "#.##")
                if show_pct_dist
                    txt += "\n" + str.tostring(dist_pct, "#.##") + " %"
                if show_angle_info
                    txt += "\n" + str.tostring(t.angle, "#") + "°"
                label lb = label.new(bar_index, t.current_val, txt, xloc=xloc.bar_index, yloc=yloc.price, color=base_col, textcolor=lbl_text_col, style=label.style_label_down, size=lbl_size_choice)
                array.push(render_labels, lb)

    // Draw Last Broken Trendlines
    if show_broken and array.size(broken_trendlines) > 0
        line_style_brk = get_line_style(broken_style_str)
        for i = 0 to array.size(broken_trendlines) - 1
            TrendlineModel bt = array.get(broken_trendlines, i)
            int c_b1 = math.max(bt.bar1, bar_index - 490)
            float c_p1 = c_b1 == bt.bar1 ? bt.price1 : bt.price1 + bt.slope * float(c_b1 - bt.bar1)
            line l_brk = line.new(c_b1, c_p1, bar_index, bt.price1 + bt.slope * float(bar_index - bt.bar1), xloc=xloc.bar_index, color=broken_color, style=line_style_brk, width=broken_width)
            array.push(render_lines, l_brk)
            if show_broken_lbl and bt.break_bar > 0
                label lb_brk = label.new(bt.break_bar, bt.break_price, str.tostring(bt.break_price, "#.##"), color=broken_color, textcolor=color.white, style=bt.is_up ? label.style_label_down : label.style_label_up, size=size.tiny)
                array.push(render_labels, lb_brk)

    // Draw Angle Bisector
    if show_bisector and count_up > 0 and count_dn > 0
        TrendlineModel u = array.get(selected_up, 0)
        TrendlineModel d = array.get(selected_dn, 0)
        if u.slope != d.slope
            // Find convergence intersection (x_int, y_int)
            float c_u = u.price1 - u.slope * float(u.bar1)
            float c_d = d.price1 - d.slope * float(d.bar1)
            float x_int = (c_d - c_u) / (u.slope - d.slope)
            float y_int = u.slope * x_int + c_u
            if x_int > float(bar_index)
                float bis_slope = (u.slope + d.slope) * 0.5
                float bis_y_now = y_int - bis_slope * (x_int - float(bar_index))
                line l_bis = line.new(bar_index, bis_y_now, int(x_int), y_int, xloc=xloc.bar_index, color=bisector_color, style=get_line_style(bisector_style_str), width=bisector_width)
                array.push(render_lines, l_bis)

// ==================================================================================================

// Helper to populate Market Structure table row
fill_ms_row(tbl, row_idx, len_val, ang, desc, mom, col, text_col, sz) =>
    ang_str = (ang >= 0 ? "+" : "") + str.tostring(ang, "#") + "° " + desc
    table.cell(tbl, 0, row_idx, "Trend on " + str.tostring(len_val) + " Bars", text_color=text_col, text_size=sz, text_halign=text.align_left)
    table.cell(tbl, 1, row_idx, ang_str, text_color=col, text_size=sz, text_halign=text.align_left)
    table.cell(tbl, 2, row_idx, mom, text_color=text_col, text_size=sz, text_halign=text.align_center)
    active_blocks = math.min(8, math.max(1, int(math.abs(ang) / 5.0)))
    for c = 3 to 10
        block_idx = c - 2
        cell_bg = block_idx <= active_blocks ? col : color.new(color.black, 70)
        table.cell(tbl, c, row_idx, " ", bgcolor=cell_bg)

// HUD TABLES: MARKET STRUCTURE & TREND LINES SUMMARY
// ==================================================================================================
var table tbl_ms = table.new(get_table_pos(ms_pos_y, ms_pos_x), 11, 4, border_width=1, border_color=color.new(color.gray, 80), bgcolor=color.new(color.black, 40))
var table tbl_tl = table.new(get_table_pos(tl_pos_y, tl_pos_x), 5, 5, border_width=1, border_color=color.new(color.gray, 70), bgcolor=color.new(color.black, 40))

if barstate.islast
    // Dynamically update position if changed in settings
    table.set_position(tbl_ms, get_table_pos(ms_pos_y, ms_pos_x))
    table.set_position(tbl_tl, get_table_pos(tl_pos_y, tl_pos_x))

    // Render Market Structure Matrix Table
    if show_ms
        table_size_use = get_size(ms_size_str)

        fill_ms_row(tbl_ms, 0, ms_len1, ms1_ang, ms1_desc, ms1_mom, ms1_col, ms_text_color, table_size_use)
        fill_ms_row(tbl_ms, 1, ms_len2, ms2_ang, ms2_desc, ms2_mom, ms2_col, ms_text_color, table_size_use)
        fill_ms_row(tbl_ms, 2, ms_len3, ms3_ang, ms3_desc, ms3_mom, ms3_col, ms_text_color, table_size_use)
        fill_ms_row(tbl_ms, 3, ms_len4, ms4_ang, ms4_desc, ms4_mom, ms4_col, ms_text_color, table_size_use)
    else
        table.clear(tbl_ms, 0, 0, 10, 3)

    // Render Active Trend Lines HUD Table
    if show_tl_table
        table_size_tl = get_size(tl_table_size_str)
        table.clear(tbl_tl, 0, 0, 4, 4)
        // Table Header
        table.cell(tbl_tl, 0, 0, "Trend", bgcolor=color.new(color.navy, 40), text_color=color.white, text_size=table_size_tl)
        table.cell(tbl_tl, 1, 0, "Level", bgcolor=color.new(color.navy, 40), text_color=color.white, text_size=table_size_tl)
        table.cell(tbl_tl, 2, 0, "TL Strength", bgcolor=color.new(color.navy, 40), text_color=color.white, text_size=table_size_tl)
        table.cell(tbl_tl, 3, 0, "Angle", bgcolor=color.new(color.navy, 40), text_color=color.white, text_size=table_size_tl)
        table.cell(tbl_tl, 4, 0, "Distance", bgcolor=color.new(color.navy, 40), text_color=color.white, text_size=table_size_tl)
        
        int row = 1
        // Populate Downtrend Rows
        if count_dn > 0
            for i = 0 to math.min(count_dn - 1, 1)
                TrendlineModel t = array.get(selected_dn, i)
                float dist_pct = math.abs(close - t.current_val) / close * 100.0
                string str_text = str.tostring(t.strength, "#.#") + "/" + (t.is_strong ? "Strong" : "Weak")
                table.cell(tbl_tl, 0, row, "Downtrend", bgcolor=col_strong_dn, text_color=color.white, text_size=table_size_tl)
                table.cell(tbl_tl, 1, row, str.tostring(t.current_val, "#.##"), text_color=color.white, text_size=table_size_tl)
                table.cell(tbl_tl, 2, row, str_text, text_color=col_strong_dn, text_size=table_size_tl)
                table.cell(tbl_tl, 3, row, str.tostring(t.angle, "#") + "°", text_color=color.white, text_size=table_size_tl)
                table.cell(tbl_tl, 4, row, str.tostring(dist_pct, "#.##") + " %", text_color=color.white, text_size=table_size_tl)
                row += 1
                
        // Populate Uptrend Rows
        if count_up > 0
            for i = 0 to math.min(count_up - 1, 1)
                TrendlineModel t = array.get(selected_up, i)
                float dist_pct = math.abs(close - t.current_val) / close * 100.0
                string str_text = str.tostring(t.strength, "#.#") + "/" + (t.is_strong ? "Strong" : "Weak")
                table.cell(tbl_tl, 0, row, "Uptrend", bgcolor=col_strong_up, text_color=color.black, text_size=table_size_tl)
                table.cell(tbl_tl, 1, row, str.tostring(t.current_val, "#.##"), text_color=color.white, text_size=table_size_tl)
                table.cell(tbl_tl, 2, row, str_text, text_color=col_strong_up, text_size=table_size_tl)
                table.cell(tbl_tl, 3, row, str.tostring(t.angle, "#") + "°", text_color=color.white, text_size=table_size_tl)
                table.cell(tbl_tl, 4, row, str.tostring(dist_pct, "#.##") + " %", text_color=color.white, text_size=table_size_tl)
                row += 1
    else
        table.clear(tbl_tl, 0, 0, 4, 4)

// ==================================================================================================
// END OF INDICATOR
// ==================================================================================================
````
