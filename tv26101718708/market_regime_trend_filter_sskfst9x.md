# Market Regime & Trend Filter

- url: https://www.tradingview.com/script/sSKfST9X/
- type: indicator
- pine_id: PUB;22aea3bbb6a94a6791d8b624c00e138b
- version: 2.0

## Description

🚀 MARKET REGIME & TREND FILTER PRO [MRTF]

The Market Regime & Trend Filter Pro (MRTF), engineered by gunebak4n, is an institutional-grade multi-dimensional trend classification and market structure isolation framework. It is designed to visually map macro price regimes, isolate structural expansions, and filter out low-liquidity market noise without a single pixel of signal repainting.

MRTF operates on the core principle that directional price movement cannot be evaluated in a vacuum. True, sustainable trends are defined by the mathematical convergence of statistical linear regression velocity and validated swing market structures (Higher Highs / Lower Lows). By unifying an asset-agnostic, normalized slope calculation with a lag-free swing matrix, MRTF projects multi-state market environments directly onto the user's chart.

Unlike traditional moving averages or standard trend-following tools that suffer from severe lag or generate devastating false signals during prolonged sideways consolidations, MRTF dynamically shifts across five distinct market regimes—instantly distinguishing a high-conviction breakout from a dangerous, low-velocity trap.

💡 CORE DESIGN PRINCIPLES

🧭 Normalized Statistical Velocity Engine

Standard linear regression slopes fail when comparing different assets or volatile timeframes because their raw values depend entirely on the asset's nominal price. MRTF solves this by processing the raw slope (Beta Coefficient) through a dynamic ATR (Average True Range) normalization matrix. This transforms ordinary regression into a universal, percentage-based momentum tracker that remains stable across Bitcoin, Apple, or Gold.

🧬 Non-Repainting Multi-Layer Validation

The framework continuously evaluates two distinct algorithmic layers:

Statistical Trend Component: A localized rolling covariance engine that measures the geometric slope of the price index over a user-defined lookback window.

Structural Swing Component: A strict, non-repainting pivot tracking system that marks qualified market structures based on strict historical confirmations.

The structural intersection of these layers determines the definitive macro market regime.

💡 KEY FEATURES

📊 Five-State Market Regime Matrix

Instead of a binary "bull or bear" output, MRTF classifies the market into 5 actionable phases to optimize strategy execution:

Strong Bullish: Market structure is breaking higher (HH/HL) and the normalized channel slope is expanding aggressively upward.

Weak Bullish: Structural trend is upward but momentum is flattening, OR macro momentum is extremely bullish despite temporary structural breaks.

Ranging / Choppy: The absolute trend slope is compressed inside the dead-zone threshold. Capital preservation mode.

Weak Bearish: Structural trend is downward but selling momentum is stalling, OR macro momentum is sharply negative despite minor upward structural retracements.

Strong Bearish: Market structure is breaking lower (LH/LL) and the normalized channel slope is accelerating aggressively downward.

🧪 Advanced Chart-Scale Alignment (Log/Linear)

A critical feature engineered into MRTF is its manual Price Scale Mode switch. Because Pine Script cannot natively detect whether a user's visual chart layout is set to Logarithmic or Linear, MRTF provides an input enum to match your chart. This prevents the mathematical distortion of regression slopes on long-term logarithmic charts, ensuring accurate momentum readings.

🛡️ Non-Repainting Historical Swing Mapping

The indicator utilizes advanced pivot logic to identify valid structural peaks and troughs. By utilizing a fixed right-bar confirmation offset, the system completely eliminates the risk of signal repainting. Shapes are placed historically precisely where the structural pivot occurred, offering an uncorrupted look back at structural market transitions.

🔬 MATHEMATICAL ARCHITECTURE

[STEP 1: Chart Scale Selection & Log Transformation]
If Scale Mode is Logarithmic:
   Y_val = ln(Close)
If Scale Mode is Linear:
   Y_val = Close

[STEP 2: Rolling Window Covariance & Slope Engine]
• Mean_X     = SMA(bar_index, Length)
• Mean_Y     = SMA(Y_val, Length)
• Mean_XY    = SMA(bar_index * Y_val, Length)
• Cov_XY     = Mean_XY - (Mean_X * Mean_Y)
• Variance_X = Variance(bar_index, Length)
• Raw_Slope  = Cov_XY / Variance_X

[STEP 3: Average True Range Normalization Matrix]
• ATR_Val    = ATR(Length)

If Scale Mode is Logarithmic:
   Normalized_Slope = Raw_Slope * 100
If Scale Mode is Linear:
   Normalized_Slope = (Raw_Slope / ATR_Val) * 100

🛠️ USAGE FRAMEWORK

1. Candlestick Regime Coloring
Monitor the color shifts of the live candlesticks to instantly identify the dominant institutional phase:

Bright Lime Candles: Strong Bullish Expansion. (Ideal for riding strong macro trend extensions).

Muted Green Candles: Weak Bullish Phase / Potential Exhaustion or Minor Retracement.

Gray Candles: Ranging / Choppy Environment. Tighten stop-losses, avoid breakout chasing, and look for mean-reversion setups.

Muted Maroon Candles: Weak Bearish Phase / Defensive Posture.

Bright Red Candles: Strong Bearish Expansion. (Ideal for capital preservation or short-side exposure).

2. Analytical Control Dashboard
The real-time HUD (Heads-Up Display) in the corner of your chart provides a synchronized summary of market health:

Scale Mode: Confirms whether your mathematical engine is aligned with your visual chart scale.

Norm Slope: Displays the exact normalized statistical momentum score. Values crossing outside your threshold indicate volatility expansions.

Market Structure: Shows the structural orientation based on valid pivot series (Bullish, Bearish, or Undetermined).

3. Structural Pivot Turning Points
The small red and lime triangles plotted on the chart mark confirmed structural swing points. Because they are fully non-repainting, they represent concrete psychological levels where institutional order flow shifted, making them excellent levels for placing structural stop-losses or identifying major support/resistance zones.

⚙️ SYSTEM CHARACTERISTICS

Zero Repainting: All background calculations, candlestick color shifts, and swing markers are mathematically locked upon bar close.

Fully Parameterized Controls: Seamlessly adjust regression lengths, swing confirmations, and slope thresholds to adapt the script to Scalping, Day Trading, or Macro Swing Trading.

Asset-Agnostic Engine: Works flawlessly across Equities, Forex, Crypto, Indices, and Commodities by converting absolute price tracking into standardized volatility metrics.

Custom Visual Themes: Every single regime color and dashboard location parameter can be customized within the user settings panel to fit clean dark or light chart aesthetics.

📌 CREDIT

The Market Regime & Trend Filter Pro (MRTF) is officially engineered and published by gunebak4n on TradingView.

This script is built for professional traders who prioritize statistical clarity and structural confirmation over erratic, lagging indicators or noise-heavy lagging moving averages.

⚠️ DISCLAIMER

MRTF is a probabilistic statistical mapping model designed for data visualization. It does not issue absolute trading recommendations, financial advice, or automated profit guarantees. Always backtest your parameters and manage your risk exposure strictly according to your personal trading plan.

## Source Code

````pine
//@version=6
// @author gunebak4n
indicator("Market Regime & Trend Filter", shorttitle="Regime+Slope", overlay=true)

// ============================================================================
// 1. ENUMS & CONSTANTS
// ============================================================================
enum ScaleMode
    linear = "Linear"
    log = "Logarithmic"

enum DisplayMode
    realtime = "Real-time Confirmation (No Visual Delay)"
    historical = "Historical Pivot Location (Offset Backwards)"

// ============================================================================
// 2. USER INPUTS
// ============================================================================
// Group 1: Statistical Engine Settings
grp_reg         = "1. Regression & Slope Settings"
in_scaleMode    = input.enum(ScaleMode.linear, title="Price Scale Mode", group=grp_reg, tooltip="MATCH WITH YOUR CHART SCALE: Pine Script cannot automatically detect if your chart is log or linear.")
in_regLen       = input.int(50, title="Regression Lookback Period", minval=10, maxval=300, group=grp_reg, tooltip="The number of bars used to calculate the linear regression slope.")
in_slopeThresh  = input.float(1.0, title="Slope Threshold (Normalized)", minval=0.1, step=0.1, group=grp_reg, tooltip="The baseline sensitivity for trend detection.")

// Group 2: Market Structure Settings
grp_struct      = "2. Market Structure (Swing) Settings"
in_displayMode  = input.enum(DisplayMode.realtime, title="Signal Display Mode", group=grp_struct, tooltip="Real-time: Displays the shape instantly on the confirmation bar (no repaint perception).\nHistorical: Offsets the shape back to the exact swing peak bar.")
in_swingLeft    = input.int(5, title="Swing Left Bars", minval=2, group=grp_struct, tooltip="Number of bars required to the left of a peak/trough.")
in_swingRight   = input.int(5, title="Swing Right Bars", minval=2, group=grp_struct, tooltip="Number of bars required to the right to confirm the pivot.")

// Group 3: Visual Theme Customization
grp_vis         = "3. Color Theme Customization"
c_strong_bull   = input.color(color.lime, title="Strong Bullish Color", group=grp_vis)
c_weak_bull     = input.color(color.new(color.green, 40), title="Weak Bullish Color", group=grp_vis)
c_choppy        = input.color(color.new(color.gray, 60), title="Ranging / Choppy Color", group=grp_vis)
c_weak_bear     = input.color(color.new(color.maroon, 40), title="Weak Bearish Color", group=grp_vis)
c_strong_bear   = input.color(color.red, title="Strong Bearish Color", group=grp_vis)

// Group 4: Dashboard Configuration
grp_dash        = "4. Analytical Dashboard Settings"
in_showDash     = input.bool(true, title="Show Dashboard", group=grp_dash)
in_dashPos      = input.string("Bottom Right", title="Dashboard Position", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group=grp_dash)

// ============================================================================
// 3. STATISTICAL REGRESSION ENGINE
// ============================================================================
var float var_x = ta.variance(bar_index, in_regLen)
float y_val = in_scaleMode == ScaleMode.log ? math.log(close) : close

float mean_x  = ta.sma(bar_index, in_regLen)
float mean_y  = ta.sma(y_val, in_regLen)
float mean_xy = ta.sma(bar_index * y_val, in_regLen)
float cov_xy  = mean_xy - (mean_x * mean_y)

float raw_slope = cov_xy / var_x
float atr_val = ta.atr(in_regLen)
float norm_slope = in_scaleMode == ScaleMode.log ? (raw_slope * 100) : (raw_slope / atr_val * 100)

// ============================================================================
// 4. MARKET STRUCTURE ENGINE
// ============================================================================
float ph = ta.pivothigh(high, in_swingLeft, in_swingRight)
float pl = ta.pivotlow(low, in_swingLeft, in_swingRight)

var float last_hh = na
var float prev_hh = na
var float last_ll = na
var float prev_ll = na

if not na(ph)
    prev_hh := last_hh
    last_hh := ph
if not na(pl)
    prev_ll := last_ll
    last_ll := pl

var int struct_dir = 0 
bool is_hh = last_hh > prev_hh
bool is_hl = last_ll > prev_ll
bool is_lh = last_hh < prev_hh
bool is_ll = last_ll < prev_ll

if is_hh and is_hl
    struct_dir := 1
else if is_lh and is_ll
    struct_dir := -1

// ============================================================================
// 5. REGIME CLASSIFICATION MATRICES
// ============================================================================
bool is_slope_bull = norm_slope > in_slopeThresh
bool is_slope_bear = norm_slope < -in_slopeThresh
bool is_slope_flat = math.abs(norm_slope) <= in_slopeThresh

int regime = 0 

if struct_dir == 1 and is_slope_bull
    regime := 2
else if (struct_dir == 1 and is_slope_flat) or (struct_dir != 1 and is_slope_bull)
    regime := 1
else if struct_dir == -1 and is_slope_bear
    regime := -2
else if (struct_dir == -1 and is_slope_flat) or (struct_dir != -1 and is_slope_bear)
    regime := -1
else
    regime := 0

// ============================================================================
// 6. VISUALIZATION & RENDERING
// ============================================================================
color c_regime = switch regime
    2  => c_strong_bull
    1  => c_weak_bull
    0  => c_choppy
    -1 => c_weak_bear
    -2 => c_strong_bear
    => c_choppy

barcolor(c_regime, title="Market Regime Bar Color")

// Dynamically handle visual offset based on user selection
int shape_offset = in_displayMode == DisplayMode.historical ? -in_swingRight : 0

plotshape(not na(ph) ? (in_displayMode == DisplayMode.historical ? ph : high) : na, 
          style=shape.triangledown, 
          location=in_displayMode == DisplayMode.historical ? location.absolute : location.abovebar, 
          color=color.red, 
          size=size.tiny, 
          offset=shape_offset, 
          title="Confirmed Swing High")

plotshape(not na(pl) ? (in_displayMode == DisplayMode.historical ? pl : low) : na, 
          style=shape.triangleup, 
          location=in_displayMode == DisplayMode.historical ? location.absolute : location.belowbar, 
          color=color.lime, 
          size=size.tiny, 
          offset=shape_offset, 
          title="Confirmed Swing Low")

// Analytical Dashboard Generation
table_pos = switch in_dashPos
    "Top Right"    => position.top_right
    "Bottom Right" => position.bottom_right
    "Top Left"     => position.top_left
    "Bottom Left"  => position.bottom_left
    => position.bottom_right

var table info_table = table.new(table_pos, 2, 4, border_width=1, border_color=color.gray)

if barstate.islast and in_showDash
    table.cell(info_table, 0, 0, "Scale Mode", text_color=color.white, bgcolor=color.black)
    table.cell(info_table, 1, 0, in_scaleMode == ScaleMode.log ? "Logarithmic" : "Linear", text_color=color.yellow, bgcolor=color.black)
    
    table.cell(info_table, 0, 1, "Norm Slope", text_color=color.white, bgcolor=color.black)
    table.cell(info_table, 1, 1, str.tostring(norm_slope, "#.##"), text_color=color.white, bgcolor=c_regime)
    
    table.cell(info_table, 0, 2, "Market Structure", text_color=color.white, bgcolor=color.black)
    table.cell(info_table, 1, 2, struct_dir == 1 ? "Bullish (HH/HL)" : struct_dir == -1 ? "Bearish (LH/LL)" : "Undetermined", text_color=color.white, bgcolor=color.black)
    
    table.cell(info_table, 0, 3, "Market Regime", text_color=color.white, bgcolor=color.black)
    string reg_txt = switch regime
        2  => "Strong Bullish"
        1  => "Weak Bullish"
        0  => "Ranging / Choppy"
        -1 => "Weak Bearish"
        -2 => "Strong Bearish"
    table.cell(info_table, 1, 3, reg_txt, text_color=color.white, bgcolor=c_regime)
````
