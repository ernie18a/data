# Smart Money Structure & Dynamic Equilibrium Suite [ICT Pro]

- url: https://www.tradingview.com/script/VTnzbHoC-Smart-Money-Structure-Dynamic-Equilibrium-Suite-ICT-Pro/
- type: indicator
- pine_id: PUB;74dbdc5b14ab4888b9535d17f60256fe
- version: 1.0

## Description

Smart Money Structure & Dynamic Equilibrium Suite [ICT Pro]

Overview & Purpose
Smart Money Structure & Dynamic Equilibrium Suite [ICT Pro] is an advanced, high-precision technical analysis visual tool engineered for Pine Script v6. Designed specifically for modern Price Action, Smart Money Concepts (SMC), and Inner Circle Trader (ICT) analysts, this script provides clean visual overlays for key liquidity boundaries, trend momentum, and range midpoints without cluttering chart aesthetics.

Instead of displaying unnecessary lines or repainting historical indicators, this suite focuses purely on real-time structural clarity, dynamic range evaluation, and institutional volume tracking.


Key Features & Technical Components

1. Auto-Swept Previous Day High & Low (PDH / PDL)
- Institutional Liquidity Levels: Automatically tracks and plots the Previous Day High (PDH) and Previous Day Low (PDL) as horizontal daily boundaries.
- Dynamic Disappear / Swept Logic: Once price crosses or sweeps a daily liquidity level during an active trading session, the swept level automatically vanishes from the chart. This ensures your view remains clean and focused only on active, unmitigated daily liquidity targets.
- Full Visual Customization: Adjust line colors, text colors, line thickness, and stroke style (Solid, Dashed, or Dotted) directly from the inputs menu.

2. Connected Dynamic Equilibrium Range
- 50% Midpoint Calculation: Continuously calculates the real-time 50% Equilibrium price zone based on customizable local swing lookback periods.
- Connected Line Extension: Features an extended horizontal line that connects seamlessly to the "EQUILIBRIUM" text label on the right margin, eliminating visual gaps or confusion about range boundaries.

3. Smart Volume Spike & Trend Candle Glow Engine
- Directional Candle Glow: Color-codes chart candles based on dual Moving Average alignments—Neon Green during bullish momentum and Neon Red during bearish momentum.
- Golden Volume Spike Highlighting: Dynamically overlays high-volume institutional candles in a distinct Glowing Gold color whenever current bar volume exceeds customizable moving average multipliers. This makes it effortless to spot institutional expansion bars.

4. Major Intermediate Term Swing Badges (ITH / ITL)
- Structural Pivot Badges: Automatically flags confirmed major high and low points using clear ITH (Intermediate Term High) and ITL (Intermediate Term Low) badges.
- Customizable Sensitivity: Adjust the pivot lookback sensitivity to tailor the detector for scalp, intraday, or higher-timeframe swing trading.


Full Inputs & Parameter Configuration Guide

1. Moving Average & Ribbon Controls
- Show MAs: Enables or disables the visibility of the two core Moving Averages on the chart.
- MA Type: Choose between EMA (Exponential), SMA (Simple), or WMA (Weighted) calculation methods.
- Fast MA Length: Defines the lookback period for the fast directional moving average (Default: 9).
- Slow MA Length: Defines the lookback period for the baseline moving average (Default: 21).
- MA Line Thickness: Adjusts stroke width for both moving averages (1 to 4 pixels).
- Show MA Ribbon Glow: Toggles the background color fill between the Fast and Slow MAs on or off.

2. Smart Candle Glow Settings
- Enable Trend Candle Coloring: Toggles custom candle coloring based on MA trend direction.
- Highlight Volume Spikes: Turns on or off the special Golden Candle overlay for high-volume bars.
- Volume Spike Threshold: Set the volume multiplier relative to the 20-period volume average (Default: 1.8x).

3. Equilibrium Settings
- Show Equilibrium Level: Turns the 50% range midpoint line on or off.
- Equilibrium Lookback Period: Sets the number of historical bars evaluated to compute the local range midpoint.
- Line Style & Thickness: Customize whether the line appears Solid, Dashed, or Dotted, as well as its thickness and color.

4. Daily Liquidity Settings (PDH / PDL)
- Show PDH & PDL: Toggles display of Previous Day High and Low levels.
- PDH/PDL Line Style & Thickness: Select custom visual preferences for daily boundaries.
- Color Pickers: Separate line and text color options for both High and Low daily levels.


Step-by-Step Guide: How to Use This Tool Effectively

Step 1: Determine Structural Bias
Use the Trend Ribbon Cloud and candle coloring to establish current market bias. Green candles and ribbons indicate bullish control, while Red candles signify bearish dominance.

Step 2: Monitor Daily Liquidity Targets
Observe active PDH and PDL lines as primary liquidity pools. When a line disappears from your chart, it confirms that liquidity at that level has been swept by price.

Step 3: Evaluate Value Zones
Refer to the Equilibrium step-line to determine whether current price trades above 50% (Premium territory) or below 50% (Discount territory) relative to recent market swings.

Step 4: Identify Institutional Volume Expansion
Pay close attention to Glowing Gold candles. Volume spikes often coincide with smart money entries, order block mitigations, or explosive range breakouts.


Trading Disclaimer & Risk Warning (House Rules Compliance)

Educational Disclaimer:
This script is strictly a visual analysis and charting utility designed for technical educational purposes. It does NOT offer financial advice, trade signals, investment recommendations, or automated buy/sell algorithms. 

Risk Acknowledgment:
Financial trading carries inherent risk, and historical market behavior depicted by visual indicators does not guarantee future results. Users are fully responsible for their own trading decisions and risk management strategies.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NOVA_STRATIGY

//@version=6
indicator("Smart Money Structure & Dynamic Equilibrium Suite [ICT Pro]", "SMC Structure & EQ Suite Pro", overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 200)

// ----------------------------------------------------------------------------------------------
// 1. INPUTS & CONFIGURATION PANEL
// ----------------------------------------------------------------------------------------------

// A. Glowing Moving Averages Settings
g_ma         = "===== GLOWING MOVING AVERAGES ====="
show_ma      = input.bool(true, "Show MAs", group=g_ma)
ma_type      = input.string("EMA", "MA Type", options=["EMA", "SMA", "WMA"], group=g_ma)
fast_len     = input.int(9, "Fast MA Length", minval=1, group=g_ma)
slow_len     = input.int(21, "Slow MA Length", minval=1, group=g_ma)
ma_width     = input.int(2, "MA Line Thickness", minval=1, maxval=4, group=g_ma)
show_ribbon  = input.bool(true, "Show MA Background Ribbon Glow", group=g_ma)
c_ma_fast    = input.color(#00e676, "Fast MA Color (Bullish)", group=g_ma)
c_ma_slow    = input.color(#ff1744, "Slow MA Color (Bearish)", group=g_ma)

// B. Smart Volume & Trend Candle Glow
g_glow       = "===== SMART CANDLE GLOW ENGINE ====="
enable_glow  = input.bool(true, "Enable Trend Candle Coloring", group=g_glow)
vol_spike_en = input.bool(true, "Highlight High Volume Spikes", group=g_glow)
vol_mult     = input.float(1.8, "Volume Spike Threshold (x MA Volume)", minval=1.0, step=0.1, group=g_glow)
c_gold_glow  = input.color(#ffd700, "Volume Spike Candle Color (Gold)", group=g_glow)

// C. Dynamic Equilibrium Settings
g_eq         = "===== DYNAMIC EQUILIBRIUM LEVEL ====="
show_eq      = input.bool(true, "Show Equilibrium Level", group=g_eq)
eq_sens      = input.int(10, "Equilibrium Lookback Period", minval=2, maxval=50, group=g_eq)
eq_width     = input.int(2, "Line Thickness", minval=1, maxval=4, group=g_eq)
eq_style     = input.string("Dashed", "Line Style", options=["Solid", "Dashed", "Dotted"], group=g_eq)
c_eq         = input.color(#0288d1, "Equilibrium Color", group=g_eq)

// D. PDH & PDL (With Auto Disappear On Swept Logic)
g_pd         = "===== PREVIOUS DAY HIGH / LOW (PDH / PDL) ====="
show_pd      = input.bool(true, "Show PDH & PDL", group=g_pd)
pd_width     = input.int(2, "PDH/PDL Line Thickness", minval=1, maxval=4, group=g_pd)
pd_style     = input.string("Dashed", "PDH/PDL Line Style", options=["Solid", "Dashed", "Dotted"], group=g_pd)
c_pdh_line   = input.color(#ff1744, "PDH Line Color", group=g_pd)
c_pdh_txt    = input.color(#ff1744, "PDH Text Color", group=g_pd)
c_pdl_line   = input.color(#00e676, "PDL Line Color", group=g_pd)
c_pdl_txt    = input.color(#00e676, "PDL Text Color", group=g_pd)

// E. ITH & ITL Badges
g_ith        = "===== ITH & ITL MAJOR SWINGS ====="
show_ith     = input.bool(true, "Show ITH / ITL Badges", group=g_ith)
ith_sens     = input.int(5, "Sensitivity Lookback", minval=2, maxval=30, group=g_ith)
ith_size     = input.string("Normal", "Badge Size", options=["Small", "Normal", "Large"], group=g_ith)

// Helper Function for Line Style Choice
f_line_style(style_str) =>
    style_str == "Dashed" ? line.style_dashed : style_str == "Dotted" ? line.style_dotted : line.style_solid

// ----------------------------------------------------------------------------------------------
// 2. GLOWING CANDLE & MOVING AVERAGE LOGIC
// ----------------------------------------------------------------------------------------------
f_ma_calc(src, len, type) =>
    type == "EMA" ? ta.ema(src, len) : type == "SMA" ? ta.sma(src, len) : ta.wma(src, len)

ma_f = f_ma_calc(close, fast_len, ma_type)
ma_s = f_ma_calc(close, slow_len, ma_type)

bool is_bull = ma_f > ma_s
float vol_ma = ta.sma(volume, 20)
bool is_vol_spike = vol_spike_en and (volume > vol_ma * vol_mult)

color candle_col = is_vol_spike ? c_gold_glow : (is_bull ? c_ma_fast : c_ma_slow)

plotcandle(open, high, low, close, "Glowing Candles",
     color = enable_glow ? candle_col : na,
     wickcolor = enable_glow ? candle_col : na,
     bordercolor = enable_glow ? candle_col : na)

p_f = plot(show_ma ? ma_f : na, "Fast MA", color=c_ma_fast, linewidth=ma_width)
p_s = plot(show_ma ? ma_s : na, "Slow MA", color=c_ma_slow, linewidth=ma_width)

fill(p_f, p_s, color=(show_ma and show_ribbon) ? color.new(is_bull ? c_ma_fast : c_ma_slow, 85) : na, title="MA Ribbon Fill")

// ----------------------------------------------------------------------------------------------
// 3. ITH & ITL BADGES
// ----------------------------------------------------------------------------------------------
ph = ta.pivothigh(high, ith_sens, ith_sens)
pl = ta.pivotlow(low, ith_sens, ith_sens)

string sz = ith_size == "Small" ? size.small : ith_size == "Large" ? size.large : size.normal

if show_ith and not na(ph)
    label.new(bar_index - ith_sens, high[ith_sens] + ta.atr(14)*0.3, "ITH", color=#ff1744, textcolor=#ffffff, style=label.style_label_down, size=sz)

if show_ith and not na(pl)
    label.new(bar_index - ith_sens, low[ith_sens] - ta.atr(14)*0.3, "ITL", color=#00e676, textcolor=#ffffff, style=label.style_label_up, size=sz)

// ----------------------------------------------------------------------------------------------
// 4. EQUILIBRIUM LEVEL WITH EXTENDED LINE TO TEXT
// ----------------------------------------------------------------------------------------------
float eq_h = ta.highest(high, eq_sens)
float eq_l = ta.lowest(low, eq_sens)
float eq_val = (eq_h + eq_l) / 2.0

var line l_eq = na
var label lbl_eq = na

if show_eq and barstate.islast
    line.delete(l_eq)
    label.delete(lbl_eq)
    
    int end_x = bar_index + 12
    l_eq := line.new(bar_index - eq_sens, eq_val, end_x, eq_val, color=c_eq, width=eq_width, style=f_line_style(eq_style))
    lbl_eq := label.new(end_x, eq_val, "EQUILIBRIUM", color=color.new(#ffffff, 100), textcolor=c_eq, style=label.style_label_left, size=size.small)

// ----------------------------------------------------------------------------------------------
// 5. PREVIOUS DAY HIGH / LOW (WITH BREAK / SWEPT DISAPPEAR LOGIC)
// ----------------------------------------------------------------------------------------------
[pdh, pdl] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead=barmerge.lookahead_on)

var bool pdh_broken = false
var bool pdl_broken = false

if ta.change(time("D")) != 0
    pdh_broken := false
    pdl_broken := false

if high > pdh
    pdh_broken := true
if low < pdl
    pdl_broken := true

var line l_pdh = na
var line l_pdl = na
var label lbl_pdh = na
var label lbl_pdl = na

if show_pd and barstate.islast
    line.delete(l_pdh)
    line.delete(l_pdl)
    label.delete(lbl_pdh)
    label.delete(lbl_pdl)
    
    int right_x = bar_index + 10
    
    if not pdh_broken
        l_pdh := line.new(bar_index - 40, pdh, right_x, pdh, color=c_pdh_line, width=pd_width, style=f_line_style(pd_style))
        lbl_pdh := label.new(right_x, pdh, "PDH", color=color.new(#ffffff, 100), textcolor=c_pdh_txt, style=label.style_label_left, size=size.small)

    if not pdl_broken
        l_pdl := line.new(bar_index - 40, pdl, right_x, pdl, color=c_pdl_line, width=pd_width, style=f_line_style(pd_style))
        lbl_pdl := label.new(right_x, pdl, "PDL", color=color.new(#ffffff, 100), textcolor=c_pdl_txt, style=label.style_label_left, size=size.small)
````
