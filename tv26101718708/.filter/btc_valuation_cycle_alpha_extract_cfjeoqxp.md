# BTC Valuation Cycle [Alpha Extract]

- url: https://www.tradingview.com/script/CfJEoqXP-BTC-Valuation-Cycle-Alpha-Extract/
- type: indicator
- pine_id: PUB;f0a73e004bd34d68bf8a45a84b94fe47
- version: 1.0

## Description

A sophisticated multi-metric Bitcoin valuation framework that synthesizes on-chain analytics including SOPR, MVRV, Price-to-Realized, and Mayer Multiple into a unified 0-100 cycle oscillator with six-tier zone classification for market cycle identification. Utilizing logistic transformation with configurable weighting and z-score normalization, this indicator delivers institutional-grade Bitcoin-specific valuation assessment with pivot-based extreme detection and comprehensive alert system. The system's weighted composite architecture combined with adaptive curve intensity enables precise calibration of cycle sensitivity while maintaining statistical validity across Bitcoin's multi-year market cycles.

🔶 Advanced Multi-Metric Synthesis Engine

Implements sophisticated composite calculation combining four distinct Bitcoin valuation metrics with configurable weighting and normalization framework. The system retrieves SOPR (Spent Output Profit Ratio), MVRV (Market Value to Realized Value), Price-to-Realized ratio, and Mayer Multiple from on-chain sources, applies z-score normalization to each metric over configurable periods, transforms via logistic function for 0-100 scaling, and generates weighted average creating unified cycle score.

[pine]// Component Score Calculation
SOPR_Centered = SOPR - 1.0
SOPR_Z = z_score(SOPR_Centered, Normalization_Length)
SOPR_Score = logistic_100(SOPR_Z, Curve_Intensity)

Price_to_Realized_Z = z_score(Price / Realized_Price, Normalization_Length)
PR_Score = logistic_100(Price_to_Realized_Z, Curve_Intensity)

MVRV_Z = z_score(Market_Cap / Realized_Cap, Normalization_Length)
MVRV_Score = logistic_100(MVRV_Z, Curve_Intensity)

Mayer_Z = z_score(Mayer_Multiple, Normalization_Length)
Mayer_Score = logistic_100(Mayer_Z, Curve_Intensity)

// Weighted Composite
Cycle = (SOPR_Score × W_SOPR + PR_Score × W_PR + MVRV_Score × W_MVRV + Mayer_Score × W_Mayer) / (W_SOPR + W_PR + W_MVRV + W_Mayer)[/pine]

🔶 Understanding Bitcoin Valuation Metrics

SOPR (Spent Output Profit Ratio) measures the degree of profit for coins moved on-chain, calculated as value sold divided by value paid. Values above 1.0 indicate profitable selling (distribution), below 1.0 indicate loss-taking (capitulation). The system centers SOPR around 1.0 for normalization.

MVRV (Market Value to Realized Value) compares current market cap to realized cap (aggregate cost basis). High MVRV signals overvaluation as price exceeds average acquisition cost; low 
MVRV suggests undervaluation. The system offers Ratio mode (raw MVRV), Z-Score mode (statistical deviation), or Blend mode (average of both).

Price-to-Realized Ratio directly compares current BTC price to realized price (realized cap divided by circulating supply), providing cleaner valuation signal than MVRV by removing market cap distortions.

Mayer Multiple measures price relative to 200-day moving average. Values above 2.4 historically mark tops; values near or below 1.0 mark bottoms. The system normalizes this classic technical indicator alongside on-chain metrics.

🔶 Logistic Transformation Framework

Features sophisticated logistic function application converting unbounded z-scores into bounded 0-100 range with configurable curve intensity controlling sensitivity. The system applies formula: 100 / (1 + exp(-z × k)) where z is z-score and k is curve intensity (default 0.90), creates S-curve transformation preserving relative relationships while preventing extreme outliers, and enables smooth gradient visualization across entire cycle range.

🔶 Six-Tier Cycle Zone Classification

Implements comprehensive market cycle framework dividing 0-100 range into six distinct zones with configurable thresholds representing Bitcoin's characteristic bubble and bust patterns. The system defines Bottom Extreme (default <10, accumulation zone), Cold Zone (10-25, early recovery), Lower Mid (25-40, neutral to bullish), Upper Mid (40-60, bullish), Hot Zone (60-75, late bull market), and Top Extreme (>75, euphoria/distribution) with dynamic color coding.

🔶 Pivot-Based Extreme Detection System

Provides intelligent local extreme identification using pivot high/low detection with zone threshold filtering and visual capsule markers. The system detects pivot highs above Hot Zone threshold and pivot lows below Cold Zone threshold using configurable left/right bars, creates horizontal capsule visualizations at exact extreme values with color-coded centers (red for tops, cyan for bottoms), and maintains rolling array limited to maximum capsule count for clean chart presentation.

🔶 MVRV Calculation Mode Selection

Offers three distinct MVRV calculation approaches optimizing for different market conditions and analytical preferences. Ratio mode uses raw Market Cap / Realized Cap for direct valuation comparison, Z-Score mode applies statistical normalization emphasizing deviations from historical mean, and Blend mode (default) averages both approaches balancing absolute valuation with statistical context for robust signal generation.

🔶 Configurable Metric Weighting System

Features flexible weight allocation enabling traders to emphasize preferred metrics or disable unreliable components during specific market regimes. The system accepts 0.0-N weight values for each metric (default 1.0 all equal), automatically handles missing data by excluding NA metrics from composite, recalculates weighted average dynamically, and enables custom cycle calibration based on trader's confidence in different on-chain signals.

🔶 Confirmed HTF Data Integration

Implements rigorous anti-repaint methodology using confirmed higher-timeframe values with [1] offset preventing live bar distortion. The system retrieves all on-chain metrics from daily timeframe with 1-bar offset ensuring only completed daily candle data influences cycle score, applies identical offset to Mayer Multiple calculation, and maintains signal stability across real-time updates preventing false extreme alerts.

🔶 Comprehensive Alert Framework

Provides five distinct alert conditions covering critical cycle events and threshold breaches with descriptive messages. The system triggers Top Extreme alert on crossover above top threshold (default 90), Bottom Extreme alert on crossunder below bottom threshold (default 10), Hot Rejection alert when cycle falls from Hot Zone, Cold Reclaim alert when cycle rises from Cold Zone, and Mayer Threshold breach alert for traditional technical confirmation.

🔶 Gradient Zone Visualization Architecture

Creates intuitive color-coded area plot with six distinct color zones reflecting current cycle position through visual spectrum from cyan (extreme bottom) through purple/orange to red (extreme top). The system applies dynamic zone coloring to both area fill and cycle value display, implements configurable area transparency (default opaque), and maintains consistent color scheme across oscillator pane, table values, and capsule markers.

🔶 Real-Time Diagnostics System

Features comprehensive data availability monitoring with missing metric labels and detailed value table showing all component metrics. The system detects NA values in SOPR, Realized Price, MVRV, or Mayer Multiple, displays warning label listing unavailable metrics, and provides table overlay showing current values for Cycle score, all four components, MVRV-Z, Mayer MA, and threshold with color-coded formatting.

🔶 Performance Optimization Framework

Employs efficient calculation methods with null-safe division functions, optimized array management for capsule storage, and conditional plotting minimizing unnecessary rendering. The system includes streamlined weighted average calculation skipping NA metrics, smart capsule cleanup maintaining maximum limit through oldest-first deletion, and minimal recalculation overhead through var declarations and confirmed bar logic.

This indicator delivers sophisticated Bitcoin-specific valuation analysis through multi-metric on-chain synthesis unavailable in traditional technical indicators. By combining SOPR (profit/loss behavior), MVRV (cost basis valuation), Price-to-Realized (pure valuation), and Mayer Multiple (technical context) into unified cycle framework with statistical normalization, it provides comprehensive market cycle assessment grounded in blockchain fundamentals. The six-tier zone system maps directly to Bitcoin's characteristic 4-year halving cycles with Bottom Extreme zones historically marking generational buying opportunities and Top Extreme zones marking distribution phases. Perfect for long-term Bitcoin investors seeking data-driven cycle timing, position sizing based on valuation extremes (increase allocation in Cold/Bottom zones, reduce in Hot/Top zones), and objective framework for navigating Bitcoin's volatile multi-year cycles with alerts providing advance warning of major cycle transitions requiring portfolio reassessment.

## Source Code

````pine
//@version=6
indicator("BTC Valuation Cycle [Alpha Extract]", overlay = false, max_lines_count = 500, max_labels_count = 500)

const string gData = "Data Sources"
const string gModel = "Model"
const string gZones = "Cycle Zones"
const string gVisual = "Visuals"
const string gDiag = "Diagnostics"
//
tf_onchain = input.timeframe("D", "On-chain Timeframe", group = gData)
price_sym = input.string("INDEX:BTCUSD", "BTC Price Symbol", group = gData)
sopr_sym = input.string("GLASSNODE:BTC_SOPR", "SOPR Symbol", group = gData)
mcap_sym = input.string("BTC_MARKETCAP", "Market Cap Symbol", group = gData)
realized_sym = input.string("BTC_MARKETCAPREAL", "Realized Cap Symbol", group = gData)
supply_sym = input.string("BTC_SUPPLY", "Supply Symbol", group = gData)

mvrv_mode = input.string("Blend", "MVRV Engine", options = ["Ratio", "Z-Score", "Blend"], group = gModel)
norm_len = input.int(365, "Normalization Length", minval = 30, group = gModel)
z_len = input.int(365, "MVRV Z-Score Length", minval = 30, group = gModel)
smooth_len = input.int(8, "Cycle Smoothing", minval = 1, group = gModel)
curve_k = input.float(0.90, "Curve Intensity", minval = 0.10, maxval = 3.0, step = 0.05, group = gModel)
mayer_tf = input.timeframe("D", "Mayer Timeframe", group = gModel)
mayer_psma_len = input.int(200, "Mayer Price SMA Length", minval = 20, group = gModel)
mayer_msma_len = input.int(200, "Mayer Multiple SMA Length", minval = 20, group = gModel)
mayer_threshold = input.float(2.40, "Mayer Threshold", minval = 0.1, step = 0.1, group = gModel)
w_sopr = input.float(1.0, "Weight: SOPR", minval = 0.0, step = 0.25, group = gModel)
w_rp = input.float(1.0, "Weight: Price/Realized", minval = 0.0, step = 0.25, group = gModel)
w_mvrv = input.float(1.0, "Weight: MVRV", minval = 0.0, step = 0.25, group = gModel)
w_mayer = input.float(1.0, "Weight: Mayer Multiple", minval = 0.0, step = 0.25, group = gModel)

zone_top = input.float(90.0, "Top Extreme", minval = 50.0, maxval = 100.0, group = gZones)
zone_hot = input.float(75.0, "Hot Zone", minval = 40.0, maxval = 100.0, group = gZones)
zone_mid_hi = input.float(60.0, "Upper Mid", minval = 20.0, maxval = 90.0, group = gZones)
zone_mid_lo = input.float(40.0, "Lower Mid", minval = 10.0, maxval = 80.0, group = gZones)
zone_cold = input.float(25.0, "Cold Zone", minval = 0.0, maxval = 60.0, group = gZones)
zone_bottom = input.float(10.0, "Bottom Extreme", minval = 0.0, maxval = 50.0, group = gZones)

show_capsules = input.bool(true, "Show Pivot Capsules", group = gVisual)
show_mayer_lines = input.bool(false, "Show Mayer Raw Lines", group = gVisual)
capsule_pivot_left = input.int(3, "Capsule Pivot Left", minval = 1, maxval = 20, group = gVisual)
capsule_pivot_right = input.int(3, "Capsule Pivot Right", minval = 1, maxval = 20, group = gVisual)
capsule_half_len = input.int(3, "Capsule Half Width", minval = 1, maxval = 20, group = gVisual)
max_capsules = input.int(120, "Max Capsules", minval = 10, maxval = 250, group = gVisual)
area_alpha = input.int(0, "Area Transparency", minval = 0, maxval = 100, group = gVisual)
bg_alpha = input.int(0, "Panel Background Transparency", minval = 0, maxval = 100, group = gVisual)

show_data_label = input.bool(true, "Show Missing Data Label", group = gDiag)
show_value_table = input.bool(true, "Show Value Table", group = gDiag)

f_safe_div(float a, float b) =>
    na(a) or na(b) or b == 0 ? na : a / b

f_zscore(float x, int len) =>
    float mean = ta.sma(x, len)
    float stdev = ta.stdev(x, len)
    na(x) or na(mean) or na(stdev) or stdev == 0 ? na : (x - mean) / stdev

f_logistic_100(float z, float k) =>
    na(z) ? na : 100.0 / (1.0 + math.exp(-z * k))

f_clamp100(float x) =>
    math.max(0.0, math.min(100.0, x))

f_zone_color(float x, float zTop, float zHot, float zMidHi, float zMidLo, float zCold, float zBottom, color cTop, color cHot, color cMidHi, color cMidLo, color cCold, color cBottom, color cUnder, color cNa) =>
    na(x) ? cNa :
     x >= zTop ? cTop :
     x >= zHot ? cHot :
     x >= zMidHi ? cMidHi :
     x >= zMidLo ? cMidLo :
     x >= zCold ? cCold :
     x >= zBottom ? cBottom :
     cUnder

f_push_capsule(array<line> line_store, int x, float y, int half_len, color outer_col, color inner_col, int max_caps) =>
    line outer_line = line.new(x - half_len, y, x + half_len, y, xloc = xloc.bar_index, extend = extend.none, color = outer_col, width = 9)
    line inner_line = line.new(x - half_len + 1, y, x + half_len - 1, y, xloc = xloc.bar_index, extend = extend.none, color = inner_col, width = 4)
    array.push(line_store, outer_line)
    array.push(line_store, inner_line)
    while array.size(line_store) > max_caps * 2
        line.delete(array.shift(line_store))

// Use confirmed higher-timeframe values only to avoid live HTF repaint.
float btc_price = str.length(price_sym) > 0 ? request.security(price_sym, tf_onchain, close[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off) : na
float sopr = str.length(sopr_sym) > 0 ? request.security(sopr_sym, tf_onchain, close[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off) : na
float mcap = str.length(mcap_sym) > 0 ? request.security(mcap_sym, tf_onchain, close[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off) : na
float realized_cap = str.length(realized_sym) > 0 ? request.security(realized_sym, tf_onchain, close[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off) : na
float supply = str.length(supply_sym) > 0 ? request.security(supply_sym, tf_onchain, close[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off) : na

float realized_price = f_safe_div(realized_cap, supply)
float price_to_realized = f_safe_div(btc_price, realized_price)
float mvrv = f_safe_div(mcap, realized_cap)
float mvrv_z = f_zscore(mvrv, z_len)
float sopr_centered = na(sopr) ? na : sopr - 1.0
float mayer_multiple = str.length(price_sym) > 0 ? request.security(price_sym, mayer_tf, (close / ta.sma(close, mayer_psma_len))[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off) : na
float mayer_mma = str.length(price_sym) > 0 ? request.security(price_sym, mayer_tf, ta.sma(close / ta.sma(close, mayer_psma_len), mayer_msma_len)[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off) : na

float sopr_score = f_logistic_100(f_zscore(sopr_centered, norm_len), curve_k)
float rp_score = f_logistic_100(f_zscore(price_to_realized, norm_len), curve_k)
float mvrv_ratio_score = f_logistic_100(f_zscore(mvrv, norm_len), curve_k)
float mvrv_z_score = f_logistic_100(mvrv_z, curve_k)
float mayer_score = f_logistic_100(f_zscore(mayer_multiple, norm_len), curve_k)

float mvrv_score = na
if mvrv_mode == "Ratio"
    mvrv_score := mvrv_ratio_score
else if mvrv_mode == "Z-Score"
    mvrv_score := mvrv_z_score
else
    mvrv_score := na(mvrv_ratio_score) or na(mvrv_z_score) ? na : (mvrv_ratio_score + mvrv_z_score) * 0.5

float w_sum = 0.0
float v_sum = 0.0

if not na(sopr_score) and w_sopr > 0
    w_sum += w_sopr
    v_sum += sopr_score * w_sopr

if not na(rp_score) and w_rp > 0
    w_sum += w_rp
    v_sum += rp_score * w_rp

if not na(mvrv_score) and w_mvrv > 0
    w_sum += w_mvrv
    v_sum += mvrv_score * w_mvrv

if not na(mayer_score) and w_mayer > 0
    w_sum += w_mayer
    v_sum += mayer_score * w_mayer

float cycle_raw = w_sum > 0 ? v_sum / w_sum : na
float cycle = f_clamp100(ta.ema(cycle_raw, smooth_len))

color c_panel_bg = #0f050a
color c_zone_top = #FF2D2D
color c_zone_hot = #FF8C00
color c_zone_mid_hi = #7C6BFF
color c_zone_mid_lo = #8B5CF6
color c_zone_cold = #5F0F40
color c_zone_bottom = #7DD3FC
color c_zone_under = #240B36
color c_zone_na = color.new(#7A375D, 80)
color c_comp_sopr = #FF7F50
color c_comp_rp = #F9C80E
color c_comp_mvrv = #D90368
color c_comp_mayer = #5F0F40
color c_thresh = #FF5A36
color c_capsule_outer = #5F0F40
color c_capsule_top = #FF2D2D
color c_capsule_bottom = #7DD3FC

color zone_col = f_zone_color(cycle, zone_top, zone_hot, zone_mid_hi, zone_mid_lo, zone_cold, zone_bottom, c_zone_top, c_zone_hot, c_zone_mid_hi, c_zone_mid_lo, c_zone_cold, c_zone_bottom, c_zone_under, c_zone_na)

bgcolor(color.new(c_panel_bg, bg_alpha), title = "Panel Background")

hline(100, "100", color = color.new(color.white, 100))
hline(0, "0", color = color.new(color.white, 100))
plot(zone_top, "Top Extreme", color = color.new(c_zone_top, 70), linewidth = 1, style = plot.style_line)
plot(zone_hot, "Hot Zone", color = color.new(c_zone_hot, 75), linewidth = 1, style = plot.style_line)
plot(zone_mid_hi, "Upper Mid", color = color.new(c_zone_mid_hi, 85), linewidth = 1, style = plot.style_line)
plot(zone_mid_lo, "Lower Mid", color = color.new(c_zone_mid_lo, 85), linewidth = 1, style = plot.style_line)
plot(zone_cold, "Cold Zone", color = color.new(c_zone_cold, 75), linewidth = 1, style = plot.style_line)
plot(zone_bottom, "Bottom Extreme", color = color.new(c_zone_bottom, 70), linewidth = 1, style = plot.style_line)

cycle_area_top = plot(cycle, "Cycle Area Top", color = color.new(zone_col, 100), display = display.none)
cycle_area_base = plot(0, "Cycle Area Base", color = color.new(color.white, 100), display = display.none)
fill(cycle_area_top, cycle_area_base, color = color.new(zone_col, area_alpha), title = "Cycle Area")

plot(show_mayer_lines ? mayer_multiple : na, "Mayer Multiple", color = c_comp_mayer, linewidth = 2)
plot(show_mayer_lines ? mayer_threshold : na, "Mayer Threshold", color = c_thresh, linewidth = 1, trackprice = true)
plot(show_mayer_lines ? mayer_mma : na, "Mayer Multiple MA", color = c_comp_mvrv, linewidth = 1)

var array<line> capsule_lines = array.new_line()
if not show_capsules and array.size(capsule_lines) > 0
    while array.size(capsule_lines) > 0
        line.delete(array.pop(capsule_lines))
if not show_capsules and array.size(line.all) > 0
    while array.size(line.all) > 0
        line.delete(array.get(line.all, array.size(line.all) - 1))

float ph = ta.pivothigh(cycle, capsule_pivot_left, capsule_pivot_right)
float pl = ta.pivotlow(cycle, capsule_pivot_left, capsule_pivot_right)
bool top_pivot = not na(ph) and ph >= zone_hot
bool bottom_pivot = not na(pl) and pl <= zone_cold

if show_capsules and barstate.isconfirmed and top_pivot
    int x_top = bar_index - capsule_pivot_right
    f_push_capsule(capsule_lines, x_top, ph, capsule_half_len, c_capsule_outer, c_capsule_top, max_capsules)

if show_capsules and barstate.isconfirmed and bottom_pivot
    int x_bottom = bar_index - capsule_pivot_right
    f_push_capsule(capsule_lines, x_bottom, pl, capsule_half_len, c_capsule_outer, c_capsule_bottom, max_capsules)

bool bar_closed = barstate.isconfirmed
bool top_extreme_cross = bar_closed and ta.crossover(cycle, zone_top)
bool bottom_extreme_cross = bar_closed and ta.crossunder(cycle, zone_bottom)
bool hot_reject = bar_closed and cycle[1] >= zone_hot and cycle < zone_hot
bool cold_reclaim = bar_closed and cycle[1] <= zone_cold and cycle > zone_cold
float oversold_marker_y = -2.0

plotshape(top_extreme_cross, title = "Top Extreme Trigger", style = shape.circle, location = location.top, color = color.new(c_capsule_top, 0), size = size.tiny, text = "")
plotshape(bottom_extreme_cross ? oversold_marker_y : na, title = "Bottom Extreme Trigger", style = shape.circle, location = location.absolute, color = color.new(c_capsule_bottom, 0), size = size.tiny, text = "")

alertcondition(top_extreme_cross, "BTC Cycle Top Extreme", "BTC valuation cycle crossed above top extreme.")
alertcondition(bottom_extreme_cross, "BTC Cycle Bottom Extreme", "BTC valuation cycle crossed below bottom extreme.")
alertcondition(hot_reject, "BTC Cycle Hot Rejection", "BTC valuation cycle rejected down from hot zone.")
alertcondition(cold_reclaim, "BTC Cycle Cold Reclaim", "BTC valuation cycle reclaimed up from cold zone.")
alertcondition(bar_closed and ta.crossover(mayer_multiple, mayer_threshold), "Mayer Multiple Above Threshold", "Mayer Multiple crossed above threshold.")

string missing = ""
missing := na(sopr) ? missing + "SOPR, " : missing
missing := na(realized_price) ? missing + "Realized Price, " : missing
missing := na(mvrv) ? missing + "MVRV, " : missing
missing := na(mayer_multiple) ? missing + "Mayer Multiple, " : missing
if str.length(missing) >= 2 and str.substring(missing, str.length(missing) - 2, str.length(missing)) == ", "
    missing := str.substring(missing, 0, str.length(missing) - 2)

var label missing_label = na
if barstate.islast and show_data_label
    label.delete(missing_label)
    if str.length(missing) > 0
        missing_label := label.new(bar_index, 95, "Missing data: " + missing, style = label.style_label_down, color = color.new(#EF4444, 0), textcolor = color.white)

var table t = table.new(position.top_right, 2, 10, border_width = 1)
if barstate.islast and show_value_table
    table.cell(t, 0, 0, "Metric", text_color = color.white, bgcolor = color.new(c_panel_bg, 0))
    table.cell(t, 1, 0, "Value", text_color = color.white, bgcolor = color.new(c_panel_bg, 0))
    table.cell(t, 0, 1, "Cycle", text_color = color.white, bgcolor = color.new(c_panel_bg, 0))
    table.cell(t, 1, 1, str.tostring(cycle, "#.00"), text_color = zone_col, bgcolor = color.new(c_panel_bg, 0))
    table.cell(t, 0, 2, "SOPR", text_color = color.white, bgcolor = color.new(c_panel_bg, 0))
    table.cell(t, 1, 2, str.tostring(sopr, "#.000"), text_color = color.new(c_comp_sopr, 0), bgcolor = color.new(c_panel_bg, 0))
    table.cell(t, 0, 3, "Realized Px", text_color = color.white, bgcolor = color.new(c_panel_bg, 0))
    table.cell(t, 1, 3, str.tostring(realized_price, "#.##"), text_color = color.new(c_comp_rp, 0), bgcolor = color.new(c_panel_bg, 0))
    table.cell(t, 0, 4, "P/RP", text_color = color.white, bgcolor = color.new(c_panel_bg, 0))
    table.cell(t, 1, 4, str.tostring(price_to_realized, "#.000"), text_color = color.new(c_comp_rp, 0), bgcolor = color.new(c_panel_bg, 0))
    table.cell(t, 0, 5, "MVRV", text_color = color.white, bgcolor = color.new(c_panel_bg, 0))
    table.cell(t, 1, 5, str.tostring(mvrv, "#.000"), text_color = color.new(c_comp_mvrv, 0), bgcolor = color.new(c_panel_bg, 0))
    table.cell(t, 0, 6, "MVRV-Z", text_color = color.white, bgcolor = color.new(c_panel_bg, 0))
    table.cell(t, 1, 6, str.tostring(mvrv_z, "#.000"), text_color = color.new(c_comp_mvrv, 0), bgcolor = color.new(c_panel_bg, 0))
    table.cell(t, 0, 7, "Mayer", text_color = color.white, bgcolor = color.new(c_panel_bg, 0))
    table.cell(t, 1, 7, str.tostring(mayer_multiple, "#.000"), text_color = color.new(c_comp_mayer, 0), bgcolor = color.new(c_panel_bg, 0))
    table.cell(t, 0, 8, "Mayer MA", text_color = color.white, bgcolor = color.new(c_panel_bg, 0))
    table.cell(t, 1, 8, str.tostring(mayer_mma, "#.000"), text_color = color.new(c_comp_mvrv, 0), bgcolor = color.new(c_panel_bg, 0))
    table.cell(t, 0, 9, "Mayer Thresh", text_color = color.white, bgcolor = color.new(c_panel_bg, 0))
    table.cell(t, 1, 9, str.tostring(mayer_threshold, "#.000"), text_color = color.new(c_thresh, 0), bgcolor = color.new(c_panel_bg, 0))
````
