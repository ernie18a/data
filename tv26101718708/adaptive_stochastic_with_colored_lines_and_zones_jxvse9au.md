# Adaptive Stochastic with Colored Lines and Zones

- url: https://www.tradingview.com/script/jxVSE9AU/
- type: indicator
- pine_id: PUB;423e515ed1a44e3fa830a4dc89153f5a
- version: 1.0

## Description

Adaptive Stochastic with Colored Lines and Zones

"Adaptive Stochastic with Colored Lines and Zones" is an enhanced Stochastic Oscillator designed to improve trend visualization and market momentum analysis through dynamic color changes and clearly defined overbought/oversold zones.

The indicator automatically adjusts the color of the main Stochastic line according to prevailing market conditions:

**Blue** indicates bullish momentum and strengthening upward pressure.

**Red** indicates bearish momentum and increasing downward pressure.

This visual feedback helps traders quickly assess market direction without adding additional trend-following tools to the chart.

 Overbought and Oversold Zones

The indicator highlights key momentum extremes:

* **Above 80** – Strong Overbought Zone
* **Below 20** – Strong Oversold Zone

These areas can help identify periods of extended market movement, potential pullbacks, or possible reversal conditions when combined with price action and other forms of technical analysis.

Applications

* Trend identification
* Momentum analysis
* Confirmation of market direction
* Detection of overbought and oversold conditions
* Support for entry and exit timing

Suitable Markets

The indicator can be used across multiple asset classes, including Forex, Cryptocurrencies, Stocks, Indices, and Futures, and is compatible with various trading styles ranging from intraday trading to longer-term trend analysis.

[image]https://www.tradingview.com/x/NuvC64yu/[/image]Notes

As with any technical indicator, Adaptive Stochastic with Colored Lines and Zones should be used as part of a broader trading strategy and not as a standalone signal generator. Combining momentum readings with market structure, support and resistance levels, and risk management techniques may improve decision-making.

## Source Code

````pine
//@version=6
indicator("Adaptive Stochastic with Colored Lines and Zones", shorttitle="Adaptive Stoch", overlay=false)

// ==========================================
// 1. INPUTS - STOCHASTIC PARAMETERS
// ==========================================
grp_stoch = "Stochastic Parameters"
periodK   = input.int(14, title="%K Period", minval=1, group=grp_stoch)
periodD   = input.int(3, title="%D Period (Smoothing)", minval=1, group=grp_stoch)
smoothK   = input.int(3, title="%K Period (Smoothing)", minval=1, group=grp_stoch)

// ==========================================
// 2. INPUTS - LEVELS, BANDS AND TRIGGERS
// ==========================================
grp_levels = "Levels, Bands & Triggers"
ob_high    = input.int(100, title="Overbought - High", group=grp_levels)
ob_low     = input.int(80, title="Overbought - Low (Band)", group=grp_levels)
mid_line   = input.int(50, title="Middle Line", group=grp_levels)
os_high    = input.int(20, title="Oversold - High (Band)", group=grp_levels)
os_low     = input.int(0, title="Oversold - Low", group=grp_levels)

// Background color activation triggers
trigger_ob = input.int(80, title="Overbought Activation Trigger", group=grp_levels)
trigger_os = input.int(20, title="Oversold Activation Trigger", group=grp_levels)

// ==========================================
// 3. INPUTS - COLORS AND TRANSPARENCY
// ==========================================
grp_colors  = "Coloring"
color_up    = input.color(color.blue, title="%K Color - Up (Blue)", group=grp_colors)
color_down  = input.color(color.red, title="%K Color - Down (Red)", group=grp_colors)
color_lineD = input.color(color.gray, title="%D Line Color", group=grp_colors)

// Band background colors with transparency slider
trans_ob    = input.int(75, title="Overbought Transparency (0-100)", minval=0, maxval=100, group=grp_colors)
trans_os    = input.int(75, title="Oversold Transparency (0-100)", minval=0, maxval=100, group=grp_colors)
bg_ob_color = input.color(color.red, title="Overbought Background", group=grp_colors)
bg_os_color = input.color(color.blue, title="Oversold Background", group=grp_colors)

// ==========================================
// 4. STOCHASTIC CALCULATIONS
// ==========================================
stoch_raw = ta.stoch(close, high, low, periodK)
k = ta.sma(stoch_raw, smoothK)
d = ta.sma(k, periodD)

// Dynamic main %K line coloring based on direction
// If k rises compared to the previous bar -> blue, if it falls -> red
k_color = ta.rising(k, 1) ? color_up : (ta.falling(k, 1) ? color_down : color_down)

// ==========================================
// 5. DYNAMIC BACKGROUND FILL CONDITIONS
// ==========================================
// Upper background (80-100) lights up only when exceeding the trigger (default 85)
current_ob_color = (k >= trigger_ob) ? color.new(bg_ob_color, trans_ob) : color.new(bg_ob_color, 100)

// Lower background (0-20) lights up only when dropping below the trigger (default 15)
current_os_color = (k <= trigger_os) ? color.new(bg_os_color, trans_os) : color.new(bg_os_color, 100)

// ==========================================
// 6. DRAWING LINES AND BACKGROUND
// ==========================================
// Grid lines based on hline to preserve dashed style without compilation errors
h_ob_high = hline(ob_high, title="Overbought Max", color=color.new(color.gray, 100))
h_ob_low  = hline(ob_low, title="Overbought Band", color=color.gray, linestyle=hline.style_dotted)

hline(mid_line, title="Line 50", color=color.new(color.gray, 30), linestyle=hline.style_solid, linewidth=1)

h_os_high = hline(os_high, title="Oversold Band", color=color.gray, linestyle=hline.style_dotted)
h_os_low  = hline(os_low, title="Oversold Min", color=color.new(color.gray, 100))

// Dynamic zone space filling
fill(h_ob_high, h_ob_low, color=current_ob_color, title="Overbought Filling")
fill(h_os_high, h_os_low, color=current_os_color, title="Oversold Filling")

// Drawing the main dynamic Stochastic lines on top
plot(k, title="Main %K Line (Dynamic Color)", color=k_color, linewidth=2)
plot(d, title="%D Line", color=color_lineD, linewidth=1)
````
