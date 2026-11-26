# Hazel nut BB Strategy, volume base- lite version

- url: https://www.tradingview.com/script/c0rLsU20-Hazel-nut-BB-Strategy-volume-base-lite-version/
- type: strategy
- pine_id: PUB;1d62320335444c0fa16306c85c2e61a9
- version: 3.0

## Description

[b]Hazel nut BB Strategy, volume base — lite version[/b]

Having knowledge and information in financial markets is only useful when a trader operates with a well-defined trading strategy. Trading strategies assist in capital management, profit-taking, and reducing potential losses.

This strategy is built upon the core principle of supply and demand dynamics. Alongside this foundation, one of the widely used technical tools — the Bollinger Bands — is employed to structure a framework for profit management and risk control.

In this strategy, the interaction of these tools is explained in detail. A key point to note is that for calculating buy and sell volumes, a lower timeframe function is used. When applied with a tick-level resolution, this provides the most precise measurement of buyer/seller flows. However, this comes with a limitation of reduced historical depth. [b]Users should be aware of this[/b] trade-off: [b]if precise tick-level data is required, shorter timeframes should be considered to extend historical coverage[/b].

The strategy offers multiple configuration options. Nevertheless,[b] it should be treated strictly as a supportive tool rather than a standalone trading system.[/b] Decisions must integrate personal analysis and other instruments. For example, in highly volatile assets with narrow ranges, it is recommended to adjust profit-taking and stop-loss percentages to smaller values.

[b]◉ Volume Settings[/b]
•	Buyer and seller volume (up/down volume) are requested from a lower timeframe, with an option to override the automatic resolution.
•	A global lookback period is applied to calculate moving averages and cumulative sums of buy/sell/delta volumes.
•	Ratios of buyers/sellers to total volume are derived both on the current bar and across the lookback window.

[image]https://www.tradingview.com/x/IdFjam48/[/image]

[b]◉ Bollinger Band[/b]
•	Bands are computed using configurable moving averages (SMA, EMA, RMA, WMA, VWMA).
•	Inputs allow control of length, standard deviation multiplier, and offset.
•	The basis, upper, and lower bands are plotted, with a shaded background between them.

[image]https://www.tradingview.com/x/KUpkuMEd/[/image]

[b]◉ Progress & Proximity[/b]
•	Relative position of the price to the Bollinger basis is expressed as percentages (qPlus/qMinus).
•	“Near band” conditions are triggered when price progress toward the upper or lower band exceeds a user-defined threshold (%).
•	A signed score (sScore) represents how far the close has moved above or below the basis relative to band width.

[b]◉ Info Table[/b]
•	Optional compact table summarizing:
•	- Upper/lower band margins
•	- Buyer/seller volumes with moving averages
•	- Delta and cumulative delta
•	- Buyer/seller ratios per bar and across the window
•	- Money flow values (buy/sell/delta × price) for bar-level and summed periods
•	The table is neutral-colored and resizable for different chart layouts.

[image]https://www.tradingview.com/x/KeIQmeYd/[/image]

[b]◉ Zone Event Gate[/b]
•	Tracks entry into and exit from “near band” zones.
•	Arming logic: a side is armed when price enters a band proximity zone.
•	Trigger logic: on exit, a trade event is generated if cumulative buyer or seller volume dominates over a configurable window.

[b]◉ Trading Logic[/b]
•	Orders are placed only on zone-exit events, conditional on volume dominance.
•	Position sizing is defined as a fixed percentage of strategy equity.
•	Long entries occur when leaving the lower zone with buyer dominance; short entries occur when leaving the upper zone with seller dominance.

[b]◉ Exit Rules[/b]
•	Open positions are managed by a strict priority sequence:
•	1. Stop-loss (% of entry price)
•	2. Take-profit (% of entry price)
•	3. Opposite-side event (zone exit with dominance in the other direction)
•	Stop-loss and take-profit levels are configurable

[image]https://www.tradingview.com/x/yjze4dTd/[/image]

[b]◉ Notes[/b]
•	This lite version is intended to demonstrate the interaction of Bollinger Bands and volume-based dominance logic.
•	It provides a framework to observe how price reacts at band boundaries under varying buy/sell pressure, and how zone exits can be systematically converted into entry/exit signals.

[b][i]When configuring this strategy, it is essential to carefully review the settings within the Strategy Tester. Ensure that the chosen parameters and historical data options are correctly aligned with the intended use. Accurate back testing depends on applying proper configurations for historical reference. The figure below illustrates sample result and configuration type.[/i][/b]


[image]https://www.tradingview.com/x/Pvgt1hxq/[/image]

## Source Code

````pine
// @version= 6
strategy(
      title                  = "BB Volume Apex Strategy [BB & Volume Flow] - REDEFINED",
      shorttitle             = "BBVol",
      overlay                = true,
      initial_capital        = 100000,
      commission_type        = strategy.commission.percent,
      commission_value       = 0.05,
      slippage               = 0,
      calc_on_every_tick     = true, // Recommended for precision when using Intrabar volume
      pyramiding             = 3,
      max_labels_count       = 500,
      max_lines_count        = 500)
//  ══════════════════════════════════════════════════════════════════════════════
// 1. IMPORTS & CONFIGURATION (DSRTL Inspired Structure)
//  ══════════════════════════════════════════════════════════════════════════════
import TradingView/ta/10 as tvta
 
// --- Groups
string  GRP_VOL        = "1. Volume Engine Configuration"
string  GRP_BB         = "2. Bollinger Bands & Squeeze"
string   GRP_STRAT     = "3. Strategy Parameters (VCS & AD@B)"
string   GRP_RISK      = "4. Risk Management"
// GRP_TREND  
string   GRP_EXIT      = "4.1. Exit Strategy (Hybrid)"
string   GRP_DASH      = "5. Dashboard & Visuals"
// --- Volume Configuration
string  calc_method = input.string("Geometric (Approx)", "Volume Calculation Method", options = ["Geometric (Approx)", "Intrabar (Precise)"], group=GRP_VOL)
string  ltf_input   = input.timeframe("15S", "Intrabar Resolution (If Precise)", group=GRP_VOL)
int      cvd_len     = input.int(50, "CVD Smoothing Length", minval=10, group=GRP_VOL, tooltip="Length for smoothing Cumulative Volume Delta (used in Pressure Matrix).")
// --- Bollinger Bands Configuration
string  bb_basis_type = input.string("SMA", "Basis Type", options=["VWMA", "SMA", "EMA"], group=GRP_BB, tooltip="VWMA integrates volume directly into the bands.")
int      bb_len        = input.int(20, "Period", minval=1, group=GRP_BB)
float    bb_mult       = input.float(2.0, "StdDev Multiplier", minval=0.5, group=GRP_BB)
// Squeeze Parameters
int      squeeze_lookback = input.int(50, "Squeeze Lookback", group=GRP_BB)
float    squeeze_threshold= input.float(0.2, "Squeeze Threshold (0-1)", group=GRP_BB, tooltip="Normalized bandwidth must be below this (e.g., 0.2 = lowest 20%) to qualify as a squeeze.")
// --- Strategy Parameters
float    vcs_volume_spike_mult= input.float(2.0, "VCS Volume Spike Multiplier", group=GRP_STRAT)
float    vcs_cvd_threshold = input.float(0.5, "VCS CVD Pressure Threshold", group=GRP_STRAT, tooltip="Minimum normalized CVD pressure required to confirm a breakout.")
float    ad_volume_threshold = input.float(1.5, "AD@B Volume Threshold Multiplier", group=GRP_STRAT)
float     ad_effort_ratio = input.float(0.3, "AD@B Effort/Result Ratio (Max)", group=GRP_STRAT, tooltip="Max Body/Range ratio to qualify as Effort without Result.")
float     ad_cvd_confirm_thresh = input.float(0.2, "AD@B CVD Confirmation Threshold", group=GRP_STRAT, tooltip="CVD Pressure must be below this (weak buying) for Sell signal, and above negative this (weak selling) for Buy signal.")
// --- Risk Management
float    order_pct       = input.float(10.0, "Order Size (% of Equity)", minval=0.1, group=GRP_RISK)
float    sl_atr_mult     = input.float(1.5, "Initial Stop Loss ATR Multiplier", minval=0.5, group=GRP_RISK)

// --- Exit Strategy (Hybrid)
float    vcs_tsl_atr_mult = input.float(2.5, "VCS Trailing Stop ATR Multiplier", minval=1.0, group=GRP_EXIT, tooltip="Multiplier for Dynamic Trailing Stop Loss for VCS (Breakout) setups.")
string   ad_tp_target = input.string("Basis Line", "AD@B Dynamic TP Target", options=["Basis Line", "Opposite Band"], group=GRP_EXIT, tooltip="Dynamic Take Profit target for AD@B (Reversal) setups.")
// --- Dashboard & Visuals
bool     show_dash     = input.bool(true, "Show Dashboard", group=GRP_DASH)
string  dash_pos = input.string(position.bottom_right, "Table Position", options=[position.top_right, position.top_left, position.bottom_right, position.bottom_left, position.middle_right, position.middle_left], group=GRP_DASH)
string  ui_theme = input.string("Dark", "Color Theme", options=["Dark", "Light"], group=GRP_DASH)
string  tbl_size = input.string("small", "Dashboard Text Size", options=["tiny", "small", "normal", "large"], group=GRP_DASH)
color   c_absorb = input.color(#00BCD4, "Absorption Color (Buy)", group=GRP_DASH)
color   c_distrib = input.color(#FF9800, "Distribution Color (Sell)", group=GRP_DASH)
//  ══════════════════════════════════════════════════════════════════════════════
// 2. UTILITIES, TYPES, AND PALETTE
//  ══════════════════════════════════════════════════════════════════════════════
// --- Types
type VolData
    float buy_vol
    float sell_vol
    float total_vol
    float delta
    bool  is_valid
// --- Global Variables
float    global_atr = ta.atr(14)
var     int     ltf_cov_bars = 0
// Trade State Management Variables (for Hybrid Exits)
var     int     active_trade_type = 0 // 0=None, 1=VCS (TSL), 2=AD@B (Dynamic TP)
var     float   trailing_sl = na
var     float   entry_sl = na

// --- Color Palette (Dynamic High Contrast)
var color C_BG_TBL = na
var color C_TXT = na
var color C_LN = na
var color C_BULL_STRONG = na
var color C_BULL_WEAK = na
var color C_BEAR_STRONG = na
var color C_BEAR_WEAK = na
var color C_NEUTRAL = na
var color C_CONFLICT = na

if ui_theme == "Dark"
    // Dark Theme: Use Bright/Neon colors for visibility against black
    C_BG_TBL      := color.new(color.black, 70) // Less transparent for better readability
    C_TXT         := #eeeeee
    C_LN          := color.new(#eeeeee, 85)
    C_BULL_STRONG := #00E676 // Neon Green
    C_BULL_WEAK   := #69F0AE // Light Green
    C_BEAR_STRONG := #FF1744 // Neon Red
    C_BEAR_WEAK   := #FF8A80 // Light Red
    C_NEUTRAL     := #B0BEC5 // Blue Grey
    C_CONFLICT    := #FFD600 // Amber
else
    // Light Theme: Use Deep/Dark colors for visibility against white
    C_BG_TBL      := color.new(color.white, 70) // Less transparent
    C_TXT         := #000000
    C_LN          := color.new(#000000, 85)
    C_BULL_STRONG := #00695C // Deep Teal/Green
    C_BULL_WEAK   := #4CAF50 // Standard Green
    C_BEAR_STRONG := #C62828 // Deep Red
    C_BEAR_WEAK   := #E57373 // Standard Red
    C_NEUTRAL     := #455A64 // Dark Slate
    C_CONFLICT    := #FBC02D // Darker Yellow
// --- Helper Functions
f_fmt(float v) =>
    string _res = "N/A"
    if not na(v)
        float a = math.abs(v)
        _res := a >= 1e9 ? str.tostring(v / 1e9, "#.##") + "B" :
                 a >= 1e6 ? str.tostring(v / 1e6, "#.##") + "M" :
                 a >= 1e3 ? str.tostring(v / 1e3, "#.##") + "K" :
                 str.tostring(v, format.mintick)
    _res
//  ══════════════════════════════════════════════════════════════════════════════
// 3. VOLUME CALCULATION ENGINE (DUAL METHOD)
//  ══════════════════════════════════════════════════════════════════════════════
// Method 1: Geometric Approximation
f_get_geo_volume() =>
    float range_i = high - low
    float v_b = 0.0
    float v_s = 0.0
    if range_i == 0
        v_b := volume * 0.5
        v_s := volume * 0.5
    else
        v_b := volume * ((close - low) / range_i)
        v_s := volume * ((high - close) / range_i)
    VolData.new(v_b, v_s, volume, v_b - v_s, true)
// Method 2: Intrabar (Precise LTF)
f_get_ltf_volume(string _ltf) =>
    [u, d, dl] = tvta.requestUpAndDownVolume(_ltf)
    float v_b = math.abs(u)
    float v_s = math.abs(d)
    VolData.new(v_b, v_s, v_b + v_s, dl, not na(dl))
// Main Volume Processing
current_vol = VolData.new(0.0, 0.0, 0.0, 0.0, false)
if calc_method == "Intrabar (Precise)"
    current_vol := f_get_ltf_volume(ltf_input)
else
    current_vol := f_get_geo_volume()
// LTF Coverage Tracking
if (calc_method == "Intrabar (Precise)" and current_vol.is_valid) or (calc_method == "Geometric (Approx)")
    ltf_cov_bars += 1
// Derived Volume Metrics
float   delta_volume = current_vol.delta
// Cumulative Volume Delta (CVD) Analysis
float   cvd = ta.cum(delta_volume)
float   cvd_smoothed = ta.ema(cvd, cvd_len)
// CVD Pressure: Normalized Rate of Change (Slope) of CVD.
float   cvd_roc = ta.change(cvd_smoothed)
// Normalize CVD ROC by ATR to make it comparable across volatility regimes
float   cvd_pressure = na(global_atr) or global_atr == 0 ? 0 : cvd_roc / global_atr
// Average Volume
float    avg_volume = ta.sma(current_vol.total_vol, bb_len)

//  ══════════════════════════════════════════════════════════════════════════════
// 4. BOLLINGER BANDS ENGINE & ADAPTIVE SQUEEZE
//  ══════════════════════════════════════════════════════════════════════════════
f_calculate_basis(string type, int len) =>
    float v_vwma = ta.vwma(close, len)
    float v_sma  = ta.sma(close, len)
    float v_ema  = ta.ema(close, len)

    switch type
        "VWMA" => v_vwma
        "SMA"  => v_sma
        "EMA"  => v_ema
float   basis = f_calculate_basis(bb_basis_type, bb_len)
float   dev = bb_mult * ta.stdev(close, bb_len)
float   upper = basis + dev
float   lower = basis - dev
// Bandwidth (Normalized by basis)
float   bandwidth = (upper - lower) / basis
// %B (Position within the bands)
float   percent_b = (upper - lower) > 0 ? (close - lower) / (upper - lower) : 0.5
// Adaptive Squeeze Detection (Normalized Bandwidth)
float   lowest_bw = ta.lowest(bandwidth, squeeze_lookback)
float   highest_bw = ta.highest(bandwidth, squeeze_lookback)
// Normalize BW (0 = narrowest in lookback, 1 = widest)
float   normalized_bw = (highest_bw - lowest_bw) > 0 ? (bandwidth - lowest_bw) / (highest_bw - lowest_bw) : 0
bool    is_squeezing = normalized_bw <= squeeze_threshold
// Visuals (High Visibility Update)
// Determine basis color based on UI theme: White for Dark mode, Black for Light mode to ensure contrast
color c_basis_vis = ui_theme == "Dark" ? #ffffff : #000000

// Plot Basis line with increased thickness (2) and high contrast color
plot(basis, "Basis", color=c_basis_vis, linewidth=2)

// Plot Upper and Lower bands with 0 transparency (Solid) for maximum visibility
var p1 = plot(upper, "Upper", color=color.new(C_BEAR_STRONG, 0), linewidth=1)
var p2 = plot(lower, "Lower", color=color.new(C_BULL_STRONG, 0), linewidth=1)

// Fill background: Distinct color during volatility squeeze, subtle gray otherwise
color fill_color = is_squeezing ? color.new(C_CONFLICT, 85) : color.new(color.gray, 92)
fill(p1, p2, title="Background", color=fill_color)
//  ══════════════════════════════════════════════════════════════════════════════
// 5. STRATEGY LOGIC & SIGNAL GENERATION (REFINED - PURE BB & VOLUME)
//  ══════════════════════════════════════════════════════════════════════════════
// Initialize signals globally
bool     long_signal_vcs = false
bool     short_signal_vcs = false
bool     long_signal_ad = false
bool     short_signal_ad = false
// Safety Check
// Updated lookback calculation
int max_lookback = math.max(bb_len, squeeze_lookback)

// Main logic runs only when enough data is present
if ltf_cov_bars > max_lookback
    // --- Setup 1: Volume Confirmed Squeeze (VCS) - BREAKOUT ---
    // Logic: Relaxed to allow breakouts if we are in a squeeze or just exited one (3-bar window).

    // 1. Context: Are we in a squeeze OR did we just leave one recently?
    bool squeeze_context = is_squeezing or is_squeezing[1] or is_squeezing[2] or is_squeezing[3]

    // 2. Volume Spike
    volume_spike = current_vol.total_vol > avg_volume * vcs_volume_spike_mult

    // 3. Long Breakout
    if close > upper[1] and volume_spike and squeeze_context
        // Confirmation: Strong delta, CVD pressure threshold.
        if delta_volume > 0 and cvd_pressure > vcs_cvd_threshold
            long_signal_vcs := true

    // 4. Short Breakout
    if close < lower[1] and volume_spike and squeeze_context
        // Confirmation: Strong delta...
        if delta_volume < 0 and cvd_pressure < -vcs_cvd_threshold
            short_signal_vcs := true

    // --- Setup 2: Absorption/Distribution at the Bands (AD@B) - REVERSAL/VSA ---
    // Logic: Identifying high activity near the bands where the volume flow contradicts the price direction, signaling potential exhaustion (Effort vs Result).

    // Calculations in local scope
    high_volume_bar = current_vol.total_vol > avg_volume * ad_volume_threshold
    // VSA Concept: Effort vs Result (Small body relative to total range on high volume)
    body_range = math.abs(close - open)
    total_range = high - low
    effort_no_result = total_range > 0 and (body_range / total_range) < ad_effort_ratio

    // Distribution (Sell Signal)
    if percent_b > 0.95 and high_volume_bar // Condition: Near/above upper band + High Volume
        // Volume Contradiction: Negative delta despite high price (Sellers overcoming buyers)
        volume_contradiction = delta_volume < 0

        // CVD Confirmation (Pressure is weakening/low - Buyers are losing momentum)
        cvd_confirms = cvd_pressure < ad_cvd_confirm_thresh

        // (Trend Filter dependency  )

        if (effort_no_result or volume_contradiction) and cvd_confirms
            short_signal_ad := true

    // Absorption (Buy Signal)
    if percent_b < 0.05 and high_volume_bar // Condition: Near/below lower band + High Volume
        // Volume Contradiction: Positive delta despite low price (Buyers absorbing the selling)
        volume_contradiction = delta_volume > 0
        // CVD Confirmation (Pressure is strengthening/high - Sellers are losing momentum)
        cvd_confirms = cvd_pressure > -ad_cvd_confirm_thresh

        // (Trend Filter dependency  )

        if (effort_no_result or volume_contradiction) and cvd_confirms
            long_signal_ad := true

// ══════════════════════════════════════════════════════════════════════════════
// 6. SMART VISUALS CONFIGURATION
// ══════════════════════════════════════════════════════════════════════════════
// Visual settings
var int lbl_transp = 20
var string txt_size = size.small

// State variables for label stacking (Anti-Overlap)
var int last_long_x = -999
var float last_long_y = 0.0
var int last_short_x = -999
var float last_short_y = 999999.0

//  ══════════════════════════════════════════════════════════════════════════════
// 7. TRADE EXECUTION AND HYBRID RISK MANAGEMENT
//  ══════════════════════════════════════════════════════════════════════════════
float    pos_qty = (strategy.equity * order_pct * 0.01) / close
// Initial Stop Loss Calculation (ATR based)
float    sl_long = close - global_atr * sl_atr_mult
float    sl_short = close + global_atr * sl_atr_mult

// --- Entries (Pyramiding is controlled by strategy settings) ---
bool enter_long = long_signal_vcs or long_signal_ad
bool enter_short = short_signal_vcs or short_signal_ad

if enter_long
    // Determine type. Prioritize VCS (Type 1)
    int entry_type = long_signal_vcs ? 1 : 2
    string comment = entry_type == 1 ? "VCS-L" : "AD-L"
    strategy.entry("L", strategy.long, qty=pos_qty, comment=comment)

    // --- Smart Visuals (Long) ---
    string v_txt = entry_type == 1 ? "VCS Break" : "Absorption"
    color v_col = entry_type == 1 ? C_BULL_STRONG : c_absorb
    
    // Calculate Spacing based on Volatility
    float spacer = global_atr * 0.5
    float gap = global_atr * 0.1
    float base_y = low - gap
    float target_y = base_y - spacer

    // Anti-Overlap Logic: Stack Downwards if crowded
    if (bar_index - last_long_x) < 6
        if target_y > (last_long_y - spacer/2)
            target_y := math.min(target_y, last_long_y - spacer)

    // Draw Visuals
    label.new(bar_index, target_y, v_txt, xloc.bar_index, yloc.price, color.new(v_col, lbl_transp), style=label.style_label_up, textcolor=color.white, size=txt_size)
    line.new(bar_index, target_y, bar_index, base_y, xloc.bar_index, extend.none, color.new(v_col, 50), line.style_dashed, 1)

    // Update State
    last_long_x := bar_index
    last_long_y := target_y

    // Store trade state
    active_trade_type := entry_type
    entry_sl := sl_long
    if entry_type == 1
        trailing_sl := sl_long

else if enter_short
    int entry_type = short_signal_vcs ? 1 : 2
    string comment = entry_type == 1 ? "VCS-S" : "AD-S"
    strategy.entry("S", strategy.short, qty=pos_qty, comment=comment)

    // --- Smart Visuals (Short) ---
    string v_txt = entry_type == 1 ? "VCS Break" : "Distribution"
    color v_col = entry_type == 1 ? C_BEAR_STRONG : c_distrib
    
    // Calculate Spacing based on Volatility
    float spacer = global_atr * 0.5
    float gap = global_atr * 0.1
    float base_y = high + gap
    float target_y = base_y + spacer

    // Anti-Overlap Logic: Stack Upwards if crowded
    if (bar_index - last_short_x) < 6
        if target_y < (last_short_y + spacer/2)
            target_y := math.max(target_y, last_short_y + spacer)

    // Draw Visuals
    label.new(bar_index, target_y, v_txt, xloc.bar_index, yloc.price, color.new(v_col, lbl_transp), style=label.style_label_down, textcolor=color.white, size=txt_size)
    line.new(bar_index, target_y, bar_index, base_y, xloc.bar_index, extend.none, color.new(v_col, 50), line.style_dashed, 1)

    // Update State
    last_short_x := bar_index
    last_short_y := target_y

    active_trade_type := entry_type
    entry_sl := sl_short
    if entry_type == 1
        trailing_sl := sl_short

// --- Hybrid Exit Management ---
// This section runs on every tick/bar close to manage dynamic exits.
if strategy.position_size > 0 // In a Long position
    if active_trade_type == 1 // VCS Setup -> Dynamic TSL
        // Calculate potential new TSL based on current price and VCS TSL Multiplier
        float new_tsl = close - global_atr * vcs_tsl_atr_mult
        // Update TSL only if the new level is higher (trailing upwards)
        trailing_sl := math.max(trailing_sl, new_tsl)
        // Apply the TSL
        strategy.exit("TSL-L", "L", stop=trailing_sl)

    else if active_trade_type == 2 // AD@B Setup -> Dynamic TP & Fixed SL
        // Calculate Dynamic TP (it updates as the basis/band moves)
        float dynamic_tp = ad_tp_target == "Basis Line" ? basis : upper
        // Safety check: ensure TP is above entry price.
        // Note: Using strategy.opentrades - 1 gets the latest trade entry price
        if dynamic_tp > strategy.opentrades.entry_price(strategy.opentrades - 1)
            strategy.exit("TP/SL-L", "L", stop=entry_sl, limit=dynamic_tp)
        else
            // If TP is invalid (e.g. Basis moved below entry), rely only on SL.
            strategy.exit("SL-L", "L", stop=entry_sl)

else if strategy.position_size < 0 // In a Short position
    if active_trade_type == 1 // VCS Setup -> Dynamic TSL
        float new_tsl = close + global_atr * vcs_tsl_atr_mult
        // Update TSL only if the new level is lower (trailing downwards)
        trailing_sl := math.min(trailing_sl, new_tsl)
        // Apply the TSL
        strategy.exit("TSL-S", "S", stop=trailing_sl)

    else if active_trade_type == 2 // AD@B Setup -> Dynamic TP & Fixed SL
        float dynamic_tp = ad_tp_target == "Basis Line" ? basis : lower
        // Safety check: ensure TP is below entry price.
        if dynamic_tp < strategy.opentrades.entry_price(strategy.opentrades - 1)
            strategy.exit("TP/SL-S", "S", stop=entry_sl, limit=dynamic_tp)
        else
            strategy.exit("SL-S", "S", stop=entry_sl)

else // Flat (position_size == 0)
    // Reset management variables when flat
    active_trade_type := 0
    trailing_sl := na
    entry_sl := na


//  ══════════════════════════════════════════════════════════════════════════════
// 8. DASHBOARD (VOLUME PRESSURE MATRIX - DSRTL STYLE) - NO CHANGES AS REQUESTED
//  ══════════════════════════════════════════════════════════════════════════════
// --- State Detection Functions ---
// S-State (Static): Bollinger Position (%B based)
// 1=Above Upper, 2=Near Upper, 3=Mid Zone, 4=Near Lower, 5=Below Lower
f_get_s_state(float pb) =>
    int _res = 3
    if pb > 1.0
        _res := 1
    else if pb >= 0.8
        _res := 2
    else if pb <= 0.0
        _res := 5
    else if pb <= 0.2
        _res := 4
    _res
// D-State (Dynamic): Volume Pressure (CVD Pressure based)
// 1=Extreme Buy, 2=Mod Buy, 3=Neutral, 4=Mod Sell, 5=Extreme Sell
f_get_d_state(float pressure) =>
    int _res = 3
    if pressure > 1.5
        _res := 1
    else if pressure > 0.5
        _res := 2
    else if pressure < -1.5
        _res := 5
    else if pressure < -0.5
        _res := 4
    _res
// --- Matrix Interpretation Engine ---
type MatrixInterpretation
    string title
    string bias
    string signal
    color  m_col
    color  bias_col

f_interpret_matrix(int s_state, int d_state) =>
    string m_title = "ANALYZING..."
    string m_bias = "N/A"
    string m_signal = "N/A"
    color m_col = C_NEUTRAL
    color bias_col = C_NEUTRAL

    // Interpretation Logic tailored for Hazel-Apex (Volume Flow + BB Position)
    if s_state == 1 // S1: Above Upper Band
        if d_state == 1
            m_title := "VOLUME BREAKOUT (UP)", m_col := C_BULL_STRONG, m_bias := "Strong Bullish", bias_col := C_BULL_STRONG, m_signal := "Extreme buying pressure confirming breakout. VCS potential."
        else if d_state >= 4
            m_title := "DISTRIBUTION (VSA)", m_col := C_BEAR_STRONG, m_bias := "Reversal Risk (High)", bias_col := C_CONFLICT, m_signal := "High price + Selling Pressure. Potential AD@B signal."
        else
            m_title := "OVERBOUGHT (Caution)", m_col := C_BULL_WEAK, m_bias := "Bullish/Neutral", bias_col := C_BULL_WEAK, m_signal := "Price extended. Monitor CVD for continuation."
    else if s_state == 2 // S2: Near Upper Band
        if d_state <= 2
            m_title := "UPTREND PRESSURE", m_col := C_BULL_WEAK, m_bias := "Bullish", bias_col := C_BULL_WEAK, m_signal := "Testing upper band with volume support."
        else if d_state >= 4
            m_title := "REJECTION RISK", m_col := C_BEAR_WEAK, m_bias := "Bearish/Neutral", bias_col := C_BEAR_WEAK, m_signal := "Selling pressure emerging near resistance."
        else
            m_title := "CONSOLIDATION (High)", m_col := C_NEUTRAL, m_bias := "Neutral", bias_col := C_NEUTRAL, m_signal := "Indecision near upper band."
    else if s_state == 3 // S3: Mid Zone
        if d_state == 1
            m_title := "STRONG BUYING (Mid)", m_col := C_BULL_STRONG, m_bias := "Bullish Trend Start?", bias_col := C_BULL_STRONG, m_signal := "Strong volume trend developing from center."
        else if d_state == 5
            m_title := "STRONG SELLING (Mid)", m_col := C_BEAR_STRONG, m_bias := "Bearish Trend Start?", bias_col := C_BEAR_STRONG, m_signal := "Strong volume trend developing from center."
        else
            m_title := "NO MAN'S LAND (Chop)", m_col := C_NEUTRAL, m_bias := "Neutral", bias_col := C_NEUTRAL, m_signal := "Dead Center. Low conviction. Avoid."
    else if s_state == 4 // S4: Near Lower Band
        if d_state <= 2
            m_title := "BOUNCE RISK", m_col := C_BULL_WEAK, m_bias := "Bullish/Neutral", bias_col := C_BULL_WEAK, m_signal := "Buying pressure emerging near support."
        else if d_state >= 4
            m_title := "DOWNTREND PRESSURE", m_col := C_BEAR_WEAK, m_bias := "Bearish", bias_col := C_BEAR_WEAK, m_signal := "Testing lower band with volume support."
        else
            m_title := "CONSOLIDATION (Low)", m_col := C_NEUTRAL, m_bias := "Neutral", bias_col := C_NEUTRAL, m_signal := "Indecision near lower band."
    else if s_state == 5 // S5: Below Lower Band
        if d_state == 5
            m_title := "VOLUME BREAKDOWN (DN)", m_col := C_BEAR_STRONG, m_bias := "Strong Bearish", bias_col := C_BEAR_STRONG, m_signal := "Extreme selling pressure confirming breakdown. VCS potential."
        else if d_state <= 2
            m_title := "ABSORPTION (VSA)", m_col := C_BULL_STRONG, m_bias := "Reversal Risk (High)", bias_col := C_CONFLICT, m_signal := "Low price + Buying Pressure. Potential AD@B signal."
        else
            m_title := "OVERSOLD (Caution)", m_col := C_BEAR_WEAK, m_bias := "Bearish/Neutral", bias_col := C_BEAR_WEAK, m_signal := "Price extended. Monitor CVD for continuation."
    
    MatrixInterpretation.new(m_title, m_bias, m_signal, m_col, bias_col)

// --- Dashboard Render ---
var     table   dash_tbl = table.new(dash_pos, 6, 16, border_width=1, frame_color=C_LN, bgcolor=C_BG_TBL)
// Helper for spanned cells with dynamic size
f_cell_span(table _tbl, int _row, string _text, color _txt_color, color _bg_color, string _sz) =>
    table.cell(_tbl, 0, _row, _text, text_color=_txt_color, bgcolor=_bg_color, text_size=_sz, text_halign=text.align_center)
    table.merge_cells(_tbl, 0, _row, 5, _row)
if barstate.islast and show_dash
    // 1. Calculate States & Interpret
    s_state = f_get_s_state(percent_b)
    d_state = f_get_d_state(cvd_pressure)
    interpretation = f_interpret_matrix(s_state, d_state)

    row_cursor = 0
    // 2. Draw Main Dashboard

    // Main Title (Tactical Description)
    // If Squeeze is active, display it prominently
    display_title = is_squeezing ? "SQUEEZE ACTIVE (Volatility Compression)" : interpretation.title
    display_color = is_squeezing ? C_CONFLICT : interpretation.m_col

    f_cell_span(dash_tbl, row_cursor, display_title, color.white, color.new(display_color, 20), tbl_size)
    row_cursor += 1
    // Bias & Signal
    f_cell_span(dash_tbl, row_cursor, "Bias: " + interpretation.bias, interpretation.bias_col, C_BG_TBL, tbl_size)
    row_cursor += 1
    f_cell_span(dash_tbl, row_cursor, interpretation.signal, C_TXT, C_BG_TBL, tbl_size)
    row_cursor += 1
    // Key Metrics (Engineering Format for Pressure)
    p_fmt = math.abs(cvd_pressure) < 0.01 and cvd_pressure != 0 ? "#.######" : "#.##"
    metrics_txt = "Norm BW: " + str.tostring(normalized_bw, "#.2f") + " | %B: " + str.tostring(percent_b, "#.2f") + " | CVD Press: " + str.tostring(cvd_pressure, p_fmt)
    f_cell_span(dash_tbl, row_cursor, metrics_txt, C_TXT, C_BG_TBL, tbl_size)

    map_start_row = row_cursor
    // Headers (S = Static/Position, D = Dynamic/CVD Pressure)
    table.cell(dash_tbl, 0, map_start_row+0, "S\\D", bgcolor=C_BG_TBL, text_color=C_TXT, text_size=tbl_size)
    table.cell(dash_tbl, 1, map_start_row+0, "D1  ↑↑ (Buy)", bgcolor=C_BG_TBL, text_color=C_BULL_STRONG, text_size=tbl_size)
    table.cell(dash_tbl, 2, map_start_row+0, "D2  ↑ ", bgcolor=C_BG_TBL, text_color=C_BULL_WEAK, text_size=tbl_size)
    table.cell(dash_tbl, 3, map_start_row+0, "D3", bgcolor=C_BG_TBL, text_color=C_NEUTRAL, text_size=tbl_size)
    table.cell(dash_tbl, 4, map_start_row+0, "D4  ↓ ", bgcolor=C_BG_TBL, text_color=C_BEAR_WEAK, text_size=tbl_size)
    table.cell(dash_tbl, 5, map_start_row+0, "D5  ↓↓ (Sell)", bgcolor=C_BG_TBL, text_color=C_BEAR_STRONG, text_size=tbl_size)
    table.cell(dash_tbl, 0, map_start_row+1, "S1 (Above)", bgcolor=C_BG_TBL, text_color=C_TXT, text_size=tbl_size)
    table.cell(dash_tbl, 0, map_start_row+2, "S2 (Near U)", bgcolor=C_BG_TBL, text_color=C_TXT, text_size=tbl_size)
    table.cell(dash_tbl, 0, map_start_row+3, "S3 (Mid)", bgcolor=C_BG_TBL, text_color=C_TXT, text_size=tbl_size)
    table.cell(dash_tbl, 0, map_start_row+4, "S4 (Near L)", bgcolor=C_BG_TBL, text_color=C_TXT, text_size=tbl_size)
    table.cell(dash_tbl, 0, map_start_row+5, "S5 (Below)", bgcolor=C_BG_TBL, text_color=C_TXT, text_size=tbl_size)

    // Populate the matrix map
    for i = 1 to 5 // S-State (Rows)
        for j = 1 to 5 // D-State (Cols)
            cell_data = f_interpret_matrix(i, j)
            bg_color = cell_data.bias_col
            txt = ""
            transp = 92 // High transparency for background cells
            // Highlight the active cell
            if i == s_state and j == d_state
                transp := 60 // Less transparent for active cell
                txt := " ⬤ "

            table.cell(dash_tbl, j, map_start_row+i, txt, bgcolor=color.new(bg_color, transp), text_color=color.white, text_size=size.small, text_halign=text.align_center, text_valign=text.align_center)
    
    row_cursor += 6
    // 4. System Info & Volume Details
    f_cell_span(dash_tbl, row_cursor, " ═══════  SYSTEM & VOLUME FLOW  ═══════ ", C_LN, C_BG_TBL, tbl_size)
    row_cursor += 1
    method_str = calc_method == "Intrabar (Precise)" ? "Mode: Precise (" + ltf_input + ")" : "Mode: Geometric"
    f_cell_span(dash_tbl, row_cursor, method_str + " | Basis: " + bb_basis_type + " | #" + syminfo.ticker, color.new(C_TXT, 50), C_BG_TBL, tbl_size)
    row_cursor += 1

    // Volume Details with Money Flow (using dynamic currency)
    d_sign = current_vol.delta > 0 ? "(+)" : (current_vol.delta < 0 ? "(-)" : "")
    // Calculate Money Flow (Volume * Price)
    buy_mf = current_vol.buy_vol * close
    sell_mf = current_vol.sell_vol * close
    delta_mf = math.abs(buy_mf - sell_mf)

    vol_row = " ▲  Buy Flow: " + syminfo.currency + " " + f_fmt(buy_mf) + "\n ▼  Sell Flow: " + syminfo.currency + " " + f_fmt(sell_mf) + "\nΔ Delta Flow: " + syminfo.currency + " " + f_fmt(delta_mf) + d_sign
    f_cell_span(dash_tbl, row_cursor, vol_row, C_TXT, C_BG_TBL, tbl_size)
````
