<!-- tradingview-pine-id: PUB;bcb369e1d6594f15906684f8fce92be9 -->
<!-- tradingviewscripts-format: 1 -->
# Dynamic ICT 2022 Model & Adaptive Structure PRO

Source: https://www.tradingview.com/script/BbCwj34M-Dynamic-ICT-2022-Model-Adaptive-Structure-PRO/

## Description

Dynamic ICT 2022 Model & Adaptive Structure PRO

Dynamic ICT 2022 Model & Adaptive Structure PRO is an institutional grade technical analysis tool engineered specifically for traders following Smart Money Concepts and ICT 2022 mentorship models. It automatically identifies major macro structural turning points, maps order flow shifts, and plots visual execution position setups optimized for both dark and light chart themes.

Key Features Overview

1. Major Intermediate Term High and Low Badges
Automatically filters market noise to detect major macro swing extremes. Displays clean red Intermediate Term High badges above macro tops and green Intermediate Term Low badges below macro bottoms.

2. Clean Visual Position Execution Tools
Projects sleek, clutter free Long and Short position tools directly at major ITH and ITL setups. The tool automatically maps out entry levels, invalidation stop zones, and dynamic 1:3 risk to reward target areas without messy text labels.

3. Adaptive Structure Shifts
Tracks real time market structure dynamics across all timeframes. Displays precise dashed Break of Structure lines and solid Change of Character signals as price expands.

4. High Contrast Dynamic Trend Wave
Features a smooth, multi layered trend wave that clearly defines overall market direction and dynamic order flow bias, fully optimized for white and light background charts.

How to Use

Step 1: Determine Macro Bias
Follow the direction of the High Contrast Dynamic Trend Wave to identify whether institutional order flow is currently expanding bullish or bearish.

Step 2: Spot Structural Pivots
Identify major highs marked with solid red ITH badges and major lows marked with solid green ITL badges.

Step 3: Analyze Visual Setup Zones
Utilize the built in visual position tools to observe invalidation boundaries and dynamic 1:3 risk to reward target zones following Market Structure Shifts.

Settings Overview

ICT 2022 Settings
- Show Major ITH / ITL & Position Tools: Toggle visibility of pivot badges and position tool boxes.
- Major Pivot Lookback Sensitivity: Adjust pivot lookback sensitivity to isolate macro highs and lows (default set to 20).
- Target Risk to Reward: Customize reward multiplier from 1:1 up to 1:10.

Trend Wave Settings
- Show Trend Wave: Toggle visibility of the dynamic trend wave.
- Wave Period Length: Adjust wave period length to match your trading timeframe.

Market Structure Settings
- Show BOS & CHoCH Lines: Toggle structural lines and text signals.
- Structure Sensitivity: Customize structural pivot lookback length.

Disclaimer
This indicator is created strictly for educational, analytical, and charting enhancement purposes. It does not provide financial advice, trade recommendations, or guaranteed results. Always apply proper risk management principles.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ACE_Chart_Logic

//@version=6
// ==============================================================================================
//  D Y N A M I C   I C T   2 0 2 2   M O D E L   &   A D A P T I V E   S T R U C T U R E   P R O
// ==============================================================================================

indicator("Dynamic ICT 2022 Model & Adaptive Structure PRO", "ICT 2022 PRO", overlay = true, max_lines_count = 500, max_boxes_count = 100, max_labels_count = 500)

// 1. INPUTS & CONFIGURATION (WHITE BACKGROUND OPTIMIZED)
g_ict        = "===== ICT 2022 MAJOR ITH / ITL & POSITIONS ====="
show_ith_itl = input.bool(true, "Show Major ITH / ITL & Position Tools", group=g_ict)
pivot_sens   = input.int(20, "Major Pivot Lookback Sensitivity", minval=10, maxval=50, group=g_ict)
rr_ratio     = input.float(3.0, "Target Risk-to-Reward (1:3)", minval=1.0, maxval=10.0, step=0.5, group=g_ict)

// Colors tuned specifically for White/Light Backgrounds
c_ith_lbl    = input.color(#d50000, "ITH Label Color (Deep Red)", group=g_ict)
c_itl_lbl    = input.color(#00c853, "ITL Label Color (Deep Green)", group=g_ict)

c_short_zone = input.color(#ff1744, "Short Position Zone Fill", group=g_ict)
c_long_zone  = input.color(#00e676, "Long Position Zone Fill", group=g_ict)

g_wave       = "===== HIGH-CONTRAST GLOWING WAVE ====="
show_wave    = input.bool(true, "Show Trend Wave", group=g_wave)
wave_len     = input.int(21, "Wave Period Length", minval=5, maxval=100, group=g_wave)
c_wave_up    = input.color(#0091ea, "Bullish Trend Wave (Deep Cyan)", group=g_wave)
c_wave_dn    = input.color(#d50000, "Bearish Trend Wave (Deep Red)", group=g_wave)

g_struct     = "===== MARKET STRUCTURE (BOS / CHoCH) ====="
show_struct  = input.bool(true, "Show BOS & CHoCH Lines", group=g_struct)
struct_len   = input.int(12, "Structure Sensitivity", minval=5, maxval=30, group=g_struct)
c_bos        = input.color(#00b0ff, "BOS Line Color", group=g_struct)
c_choch      = input.color(#ff6d00, "CHoCH Line Color", group=g_struct)

atrVal = ta.atr(14)

// 2. HIGH-CONTRAST DYNAMIC TREND WAVE
float wave = ta.ema(close, wave_len)
bool wave_up = wave > wave[1]
color wave_col = wave_up ? c_wave_up : c_wave_dn

plot(show_wave ? wave : na, "Trend Wave Core", color=wave_col, linewidth=3)
plot(show_wave ? wave : na, "Trend Wave Halo", color=color.new(wave_col, 75), linewidth=7)

// 3. MARKET STRUCTURE (BOS & CHoCH)
ph = ta.pivothigh(high, struct_len, struct_len)
pl = ta.pivotlow(low, struct_len, struct_len)

var float last_ph = na
var float last_pl = na

if not na(ph)
    last_ph := ph
if not na(pl)
    last_pl := pl

if show_struct and not na(last_ph) and ta.crossover(close, last_ph)
    line.new(bar_index - struct_len, last_ph, bar_index, last_ph, color=c_bos, style=line.style_dashed, width=1)
    label.new(bar_index, last_ph, "BOS", color=color.new(#000000, 100), textcolor=c_bos, style=label.style_label_left, size=size.tiny)
    last_ph := na

if show_struct and not na(last_pl) and ta.crossunder(close, last_pl)
    line.new(bar_index - struct_len, last_pl, bar_index, last_pl, color=c_choch, style=line.style_solid, width=1)
    label.new(bar_index, last_pl, "CHoCH", color=color.new(#000000, 100), textcolor=c_choch, style=label.style_label_left, size=size.tiny)
    last_pl := na

// 4. STRICT MAJOR ITH / ITL & CLEAN POSITION TOOL
major_ith = ta.pivothigh(high, pivot_sens, pivot_sens)
major_itl = ta.pivotlow(low, pivot_sens, pivot_sens)

if show_ith_itl and not na(major_ith)
    int idx = bar_index - pivot_sens
    float ith_price = high[pivot_sens]
    
    // Clean Solid ITH Badge Label
    label.new(idx, ith_price + (atrVal * 0.3), "ITH", color=c_ith_lbl, textcolor=color.white, style=label.style_label_down, size=size.small)
    
    // Short Position Tool (Clean 1:3 TP Target Zone)
    float entry_p = open[pivot_sens - 1]
    float sl_p    = ith_price + (atrVal * 0.15)
    float risk    = sl_p - entry_p
    float tp_p    = entry_p - (risk * rr_ratio)
    
    // Stop Loss Zone (Red Box)
    box.new(left=idx + 1, top=sl_p, right=idx + 22, bottom=entry_p, bgcolor=color.new(c_short_zone, 82), border_color=c_short_zone)
    // Target Zone (Green Box - 1:3 Hit)
    box.new(left=idx + 1, top=entry_p, right=idx + 22, bottom=tp_p, bgcolor=color.new(c_long_zone, 85), border_color=c_long_zone)
    
    // Entry & TP Lines
    line.new(idx + 1, entry_p, idx + 22, entry_p, color=color.gray, style=line.style_dashed, width=1)
    line.new(idx + 1, tp_p, idx + 22, tp_p, color=c_long_zone, style=line.style_solid, width=2)

if show_ith_itl and not na(major_itl)
    int idx = bar_index - pivot_sens
    float itl_price = low[pivot_sens]
    
    // Clean Solid ITL Badge Label
    label.new(idx, itl_price - (atrVal * 0.3), "ITL", color=c_itl_lbl, textcolor=color.white, style=label.style_label_up, size=size.small)
    
    // Long Position Tool (Clean 1:3 TP Target Zone)
    float entry_p = open[pivot_sens - 1]
    float sl_p    = itl_price - (atrVal * 0.15)
    float risk    = entry_p - sl_p
    float tp_p    = entry_p + (risk * rr_ratio)
    
    // Stop Loss Zone (Red Box)
    box.new(left=idx + 1, top=entry_p, right=idx + 22, bottom=sl_p, bgcolor=color.new(c_short_zone, 82), border_color=c_short_zone)
    // Target Zone (Green Box - 1:3 Hit)
    box.new(left=idx + 1, top=tp_p, right=idx + 22, bottom=entry_p, bgcolor=color.new(c_long_zone, 85), border_color=c_long_zone)
    
    // Entry & TP Lines
    line.new(idx + 1, entry_p, idx + 22, entry_p, color=color.gray, style=line.style_dashed, width=1)
    line.new(idx + 1, tp_p, idx + 22, tp_p, color=c_long_zone, style=line.style_solid, width=2)
````
