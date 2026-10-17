# Z-Score Source Monitor

- url: https://www.tradingview.com/script/UU6ehtlt-Z-Score-Source-Monitor/
- type: indicator
- pine_id: PUB;fdf7ec77c3d54fa89a1e7508faeac362
- version: 1.0

## Description

[b]Z-Score Source Monitor[/b]

[i]What this script does:[/i]
Z-Score Source Monitor calculates a rolling Z-Score on any external indicator line connected via the source input. It answers one question: how statistically extreme is the current reading of any oscillating indicator relative to its recent history?
A Z-Score of 0 means the source is exactly at its rolling mean. A reading of ±1 is within normal range. A reading beyond ±2 occurs roughly 5% of the time statistically, and beyond ±3 less than 1% of the time. These are the levels where statistical exhaustion tends to occur.

[i]What makes this script original:[/i]
Most Z-Score indicators on TradingView calculate the Z-Score on price. This script is built around a generic input.source — meaning it can calculate the Z-Score on any indicator plot, not just price. This makes it a universal statistical layer that can be placed on top of momentum oscillators, volume indicators, custom signals, or any other plotted line.
The volatility calculation uses EWMA (Exponentially Weighted Moving Average) variance rather than a fixed rolling standard deviation. This means the script adapts faster to changes in the statistical behavior of the source, without waiting for the full lookback window to shift. In fast-moving or regime-changing markets this produces a more responsive and accurate measure of statistical extension.

[i]How to use it:[/i]
Connect any external indicator plot to the Source input. The script will calculate and display:

Smoothed Z-Score as histogram and line, color-coded by zone
Raw Z-Score as a reference behind the smoothed line
Reference lines at ±1σ, ±2σ and ±3σ
Dashboard showing current Z-Score, zone classification, direction and raw Z value

The example chart uses the Fast Line from Bjorgum's TSI indicator as the source input, demonstrating how the Z-Score identifies statistical extremes on a momentum oscillator.
Settings

Source: connect any external indicator plot
Lookback: number of bars for the rolling mean (default 20)
EWMA Half-Life: controls how quickly the volatility measure adapts to recent behavior (default 15)
Z-Score Smoothing: EMA smoothing applied to the raw Z-Score to reduce noise (default 3)

[i]How to read the zones[/i]:

Gray: neutral, source near its mean
Light blue / light orange: mild extension beyond ±1σ
Blue / red: statistically extended beyond ±2σ — observe closely
Dark blue / dark red: rare extreme beyond ±3σ

[i]Important note:[/i]
This script is an observation tool. It identifies statistical extremes but does not generate buy or sell signals. Always use it as additional context alongside your own analysis. Past statistical extremes do not guarantee future reversals.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Nun_Donna
//
// Z-Score Source Monitor
//
// Calculates a rolling Z-Score on any external indicator line
// connected via the source input. Uses EWMA volatility for
// faster adaptation to changing market conditions compared to
// a fixed rolling standard deviation.
//
// Connect any indicator plot as the source input.
// Observe the distribution over several weeks before
// choosing thresholds for your own trading decisions.

//@version=6
indicator("Z-Score Source Monitor", overlay=false, max_bars_back=500)

// ═══════════════════════════════════════════════════════
// SOURCE
// ═══════════════════════════════════════════════════════
float src = input.source(close, "Source",
     tooltip="Connect any external indicator plot as the source for the Z-Score calculation.")

// ═══════════════════════════════════════════════════════
// SETTINGS
// ═══════════════════════════════════════════════════════
int   z_len = input.int(20,  "Lookback (bars)", minval=5, maxval=100,
     tooltip="Number of bars used to calculate the rolling mean. Lower values react faster. Higher values provide more stable readings.")
int   z_hl  = input.int(15,  "EWMA Half-Life (bars)", minval=3, maxval=50,
     tooltip="Half-life for EWMA volatility. Shorter = faster response to recent volatility changes. Longer = smoother but slower.")
int   z_sm  = input.int(3,   "Z-Score Smoothing (bars)", minval=1, maxval=10,
     tooltip="EMA smoothing applied to the raw Z-Score. Higher values reduce noise but add lag.")

// ═══════════════════════════════════════════════════════
// CALCULATION
// ═══════════════════════════════════════════════════════

// Rolling mean of the source
float src_mean = ta.ema(src, z_len)

// EWMA volatility — weights recent bars more heavily
// than a fixed rolling standard deviation
float src_alpha = 1.0 - math.exp(-math.log(2) / z_hl)
var float src_ewma_var = na
float src_dev = src - src_mean
src_ewma_var := na(src_ewma_var) ? src_dev * src_dev : (1.0 - src_alpha) * src_ewma_var + src_alpha * src_dev * src_dev
float src_std = math.sqrt(math.max(src_ewma_var, 1e-16))

// Raw Z-Score
float z_raw = src_std > 0 ? (src - src_mean) / src_std : 0.0

// Smoothed Z-Score
float z = ta.ema(z_raw, z_sm)

// ═══════════════════════════════════════════════════════
// COLOR BY ZONE
// ═══════════════════════════════════════════════════════
color col_z = z <= -3 ? color.rgb(0, 80, 255) : z <= -2 ? color.rgb(0, 160, 255) : z <= -1 ? color.rgb(100, 200, 255) : z >= 3 ? color.rgb(255, 40, 40) : z >= 2 ? color.rgb(255, 120, 80) : z >= 1 ? color.rgb(255, 200, 150) : color.new(color.gray, 40)

// ═══════════════════════════════════════════════════════
// PLOTS
// ═══════════════════════════════════════════════════════

// Z-Score as histogram for easy distribution reading
plot(z, "Z-Score", style=plot.style_histogram, color=col_z, linewidth=2)

// Z-Score as line on top
plot(z, "Z-Score Line", color=color.white, linewidth=1)

// Reference lines
hline( 0,  "0σ",   color=color.new(color.gray,   50), linestyle=hline.style_solid)
hline( 1,  "+1σ",  color=color.new(color.orange,  60), linestyle=hline.style_dashed)
hline(-1,  "−1σ",  color=color.new(color.teal,    60), linestyle=hline.style_dashed)
hline( 2,  "+2σ",  color=color.new(color.red,     50), linestyle=hline.style_dashed)
hline(-2,  "−2σ",  color=color.new(color.blue,    50), linestyle=hline.style_dashed)
hline( 3,  "+3σ",  color=color.new(color.red,     30), linestyle=hline.style_dotted)
hline(-3,  "−3σ",  color=color.new(color.blue,    30), linestyle=hline.style_dotted)

// ═══════════════════════════════════════════════════════
// DASHBOARD
// ═══════════════════════════════════════════════════════
if barstate.isconfirmed
    var table dash = table.new(position.top_right, 2, 6,
         frame_color=color.gray, frame_width=1,
         border_width=1, border_color=color.gray)

    color c_txt  = color.white
    color c_head = color.new(color.gray, 50)
    color c_bull = color.new(color.teal,  40)
    color c_bear = color.new(color.red,   40)
    color c_neut = color.new(color.gray,  60)

    // Header
    table.cell(dash, 0, 0, "Z-Score Monitor", text_color=c_txt, bgcolor=c_head, text_size=size.small)
    table.cell(dash, 1, 0, "",                text_color=c_txt, bgcolor=c_head, text_size=size.small)

    // Z-Score value
    color z_col = z < -2 ? c_bull : z > 2 ? c_bear : c_neut
    table.cell(dash, 0, 1, "Z-Score",  text_color=c_txt, bgcolor=c_neut, text_size=size.small)
    table.cell(dash, 1, 1, str.tostring(z, "#.##"), text_color=c_txt, bgcolor=z_col, text_size=size.small)

    // Zone label
    string zone_str = z <= -3 ? "Extreme OS (<−3)" : z <= -2 ? "Oversold (<−2)" : z <= -1 ? "Mild OS (<−1)" : z >= 3 ? "Extreme OB (>3)" : z >= 2 ? "Overbought (>2)" : z >= 1 ? "Mild OB (>1)" : "Neutral"
    color zone_col = z <= -2 ? c_bull : z >= 2 ? c_bear : c_neut
    table.cell(dash, 0, 2, "Zone",     text_color=c_txt, bgcolor=c_neut,   text_size=size.small)
    table.cell(dash, 1, 2, zone_str,   text_color=c_txt, bgcolor=zone_col,  text_size=size.small)

    // Direction
    string dir_str = z > z[1] ? "Rising ▲" : z < z[1] ? "Falling ▼" : "Flat"
    color  dir_col = z > z[1] ? c_bull : z < z[1] ? c_bear : c_neut
    table.cell(dash, 0, 3, "Direction", text_color=c_txt, bgcolor=c_neut,  text_size=size.small)
    table.cell(dash, 1, 3, dir_str,     text_color=c_txt, bgcolor=dir_col,  text_size=size.small)

    // Raw Z for reference
    color zr_col = z_raw < -2 ? c_bull : z_raw > 2 ? c_bear : c_neut
    table.cell(dash, 0, 4, "Raw Z",    text_color=c_txt, bgcolor=c_neut,  text_size=size.small)
    table.cell(dash, 1, 4, str.tostring(z_raw, "#.##"), text_color=c_txt, bgcolor=zr_col, text_size=size.small)

    // Source value
    table.cell(dash, 0, 5, "Source",   text_color=c_txt, bgcolor=c_neut, text_size=size.small)
    table.cell(dash, 1, 5, str.tostring(src, "#.#####"), text_color=c_txt, bgcolor=c_neut, text_size=size.small)
````
