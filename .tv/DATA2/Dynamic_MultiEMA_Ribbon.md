<!-- tradingview-pine-id: PUB;0af5e1ca0b664b50aab27b2e8f43d64c -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Dynamic Multi-EMA Ribbon

Source: https://www.tradingview.com/script/R9bTGjIT-Dynamic-Multi-EMA-Ribbon-MTF-Auto-Intensity/

## Description

Description:

The Dynamic Multi-EMA Ribbon is a powerful, highly visual trend-following tool designed to help traders instantly identify market direction, momentum strength, and potential dynamic support/resistance zones.

Instead of cluttering your chart with confusing lines, this indicator intelligently uses a gradient color scheme and dynamically adjusting ribbon fills to give you a clear, immediate read on the market's pulse.

Key Features
Strategic 6-EMA Array: Plots six critical Exponential Moving Averages (50, 100, 150, 250, 500, and 750). To keep the chart clean, the lines are shaded in a smooth visual gradient—the fastest EMA (50) is the darkest, while the slowest (750) is the lightest.

Dynamic Ribbon Intensity: This is the standout feature. The area between the EMAs is filled with a colored ribbon (Green for Bullish, Red for Bearish). As the EMAs diverge (momentum increases), the color becomes richer and more intense. As the EMAs converge (momentum slows down or consolidates), the colors fade, warning you of a potential trend pause or reversal.

Multi-Timeframe (MTF) Capability: Want to see 1-Hour EMAs on a 5-Minute chart? No problem. The indicator includes a built-in MTF setting, allowing you to track higher timeframe trends without switching your current chart view.

Highly Customizable: You have full control over your chart's aesthetics. Toggle the ribbon fills on or off for specific EMA pairs, change the bullish/bearish colors, and adjust the maximum transparency limits to suit your dark or light chart theme. By default, the ribbon fills the space between the 50, 100, and 150 EMAs to prevent visual overload.

How to Use This Indicator
Trend Direction (Color & Order):

Bullish: When faster EMAs are above slower EMAs, the ribbon paints Green.

Bearish: When faster EMAs fall below slower EMAs, the ribbon paints Red.

Momentum Strength (Color Intensity):

Strong Trend: Bright, bold ribbons mean the moving averages are fanning out and momentum is accelerating.

Weakening Trend / Consolidation: Faint, transparent ribbons mean the moving averages are squeezing together. This often precedes a breakout or a trend reversal.

Dynamic Support and Resistance: The various EMA lines, particularly the 200+ period EMAs, frequently act as strong dynamic support in an uptrend or resistance in a downtrend. Look for price reactions when the chart pulls back into the ribbon zones.

Settings Guide
Indicator Timeframe: Leave blank to use the current chart's timeframe, or select a higher timeframe (e.g., 15m, 1H, 1D) for macro trend analysis.

Line Width & Colors: Adjust the thickness of the EMAs and override the default black/gray gradient if desired.

Area Fill Settings: Use the checkboxes to decide exactly where you want the color ribbons applied.

Max Intensity Transparency: Adjust this percentage to make the ribbons brighter or softer at their maximum momentum peaks.

Disclaimer: This script is for educational and informational purposes only. It does not constitute financial advice. Always combine indicators with proper risk management and your own market analysis.

---

## Source Code

````pine
//@version=6
indicator("Dynamic Multi-EMA Ribbon", overlay=true)

// ==============================================================================
// 1. TIMEFRAME SETTINGS 
// ==============================================================================
grp_tf = "Timeframe Settings"
mtf = input.timeframe("", title="Indicator Timeframe", group=grp_tf, tooltip="Leave empty for Chart Timeframe")

// ==============================================================================
// 2. EMA LINE SETTINGS (Updated for better visibility)
// ==============================================================================
grp_ema = "EMA Line Colors & Thickness"
// 6 EMAs in progressively lighter shades of black (adjusted for visibility)
c_ema50  = input.color(color.rgb(0, 0, 0),       title="EMA 50 Color",  group=grp_ema) // Darkest (Black)
c_ema100 = input.color(color.rgb(25, 25, 25),    title="EMA 100 Color", group=grp_ema)
c_ema150 = input.color(color.rgb(50, 50, 50),    title="EMA 150 Color", group=grp_ema)
c_ema250 = input.color(color.rgb(75, 75, 75),    title="EMA 250 Color", group=grp_ema)
c_ema500 = input.color(color.rgb(100, 100, 100), title="EMA 500 Color", group=grp_ema)
c_ema750 = input.color(color.rgb(125, 125, 125), title="EMA 750 Color", group=grp_ema) // Lightest, but still visible

line_thick = input.int(2, title="Line Width", minval=1, maxval=4, group=grp_ema, tooltip="Pine script only accepts whole numbers. Set to 1 or 2 (closest to 1.5)")

// ==============================================================================
// 3. FILL / AREA SETTINGS 
// ==============================================================================
grp_fill = "Area Fill Settings"
fill_50_100  = input.bool(true,  title="Fill Area: 50 & 100",   group=grp_fill)
fill_100_150 = input.bool(true,  title="Fill Area: 100 & 150",  group=grp_fill)
fill_150_250 = input.bool(false, title="Fill Area: 150 & 250",  group=grp_fill)
fill_250_500 = input.bool(false, title="Fill Area: 250 & 500",  group=grp_fill)
fill_500_750 = input.bool(false, title="Fill Area: 500 & 750",  group=grp_fill)

grp_col = "Area Colors & Transparency"
col_bull = input.color(color.green, title="Bullish Area Color (Lower > Higher)", group=grp_col)
col_bear = input.color(color.red,   title="Bearish Area Color (Higher > Lower)", group=grp_col)
base_transp = input.int(50, title="Max Intensity Transparency (%)", minval=0, maxval=100, group=grp_col)

// ==============================================================================
// 4. CALCULATIONS & MULTI-TIMEFRAME DATA
// ==============================================================================
// Function to fetch EMA on the selected timeframe
get_ema(len) =>
    request.security(syminfo.tickerid, mtf, ta.ema(close, len))

ema50  = get_ema(50)
ema100 = get_ema(100)
ema150 = get_ema(150)
ema250 = get_ema(250)
ema500 = get_ema(500)
ema750 = get_ema(750)

// ==============================================================================
// 5. PLOTTING THE EMAS
// ==============================================================================
p50  = plot(ema50,  title="EMA 50",  color=c_ema50,  linewidth=line_thick)
p100 = plot(ema100, title="EMA 100", color=c_ema100, linewidth=line_thick)
p150 = plot(ema150, title="EMA 150", color=c_ema150, linewidth=line_thick)
p250 = plot(ema250, title="EMA 250", color=c_ema250, linewidth=line_thick)
p500 = plot(ema500, title="EMA 500", color=c_ema500, linewidth=line_thick)
p750 = plot(ema750, title="EMA 750", color=c_ema750, linewidth=line_thick)

// ==============================================================================
// 6. DYNAMIC INTENSITY COLOR CALCULATION
// ==============================================================================
// Function to calculate color intensity based on line divergence/convergence
get_dynamic_color(fast_ema, slow_ema, bull_c, bear_c, min_transp) =>
    // Calculate distance between the two lines
    diff = math.abs(fast_ema - slow_ema)
    
    // Find the highest difference over a lookback window to normalize the distance
    max_diff = ta.highest(diff, 200)
    max_diff := max_diff == 0 ? 1 : max_diff // Prevent division by zero
    
    // Normalized distance (0.0 to 1.0)
    // 1.0 = highly diverging (widest gap). 0.0 = highly converging (touching).
    ratio = diff / max_diff
    
    // Calculate transparency: When lines are close (ratio ~0), transparency approaches 95% (faint)
    // When lines diverge widely (ratio ~1), transparency approaches the user's base limit (50%)
    dynamic_transp = 95 - (ratio * (95 - min_transp))
    
    // Determine if Bullish or Bearish
    is_bull = fast_ema > slow_ema
    
    // Return final dynamically-adjusted color
    color.new(is_bull ? bull_c : bear_c, int(dynamic_transp))

// Generate colors (only computes if the user toggled the fill on)
color_50_100  = fill_50_100  ? get_dynamic_color(ema50,  ema100, col_bull, col_bear, base_transp) : na
color_100_150 = fill_100_150 ? get_dynamic_color(ema100, ema150, col_bull, col_bear, base_transp) : na
color_150_250 = fill_150_250 ? get_dynamic_color(ema150, ema250, col_bull, col_bear, base_transp) : na
color_250_500 = fill_250_500 ? get_dynamic_color(ema250, ema500, col_bull, col_bear, base_transp) : na
color_500_750 = fill_500_750 ? get_dynamic_color(ema500, ema750, col_bull, col_bear, base_transp) : na

// ==============================================================================
// 7. AREA FILLING
// ==============================================================================
fill(p50,  p100, color=color_50_100,  title="Fill 50-100")
fill(p100, p150, color=color_100_150, title="Fill 100-150")
fill(p150, p250, color=color_150_250, title="Fill 150-250")
fill(p250, p500, color=color_250_500, title="Fill 250-500")
fill(p500, p750, color=color_500_750, title="Fill 500-750")
````
