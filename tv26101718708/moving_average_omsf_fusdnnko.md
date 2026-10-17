# Moving Average OMSF

- url: https://www.tradingview.com/script/FUsdnNKO/
- type: indicator
- pine_id: PUB;44d8bc25d1b94777bf6da5dad71400f5
- version: 2.0

## Description

📘 [b]Moving Average OMSF[/b] – Educational Implementation

[b]Overview[/b]
This indicator serves as an official educational template for the [b]Objective Market Structure Framework (OMSF)[/b]. While the underlying library is a powerful engine for developers, this script is designed to help traders visualize how the framework "feels" in real-time market conditions.
https://de.tradingview.com/script/g1122Yj2/
The goal is to bridge the gap between raw price action and systematic structural analysis. By using this tool, you can observe how the OMSF identifies structural balance points without the lag or noise of traditional moving averages.

[b]Why this is different[/b]
Most Moving Averages (EMA, SMA) only process closing prices. The OMSF MA processes structural lifecycle (Running Peaks → Confirmed Levels). [b]Context over Price:[/b] It focuses on the [b]"Midpoint of Structure."[/b]

[b]Parameters & Inputs[/b]
[b]Timeframe[/b]. Sets the structural context. Use it to map HTF structures (e.g., 1H) directly onto your trading timeframe (e.g., 5m).
[b]Structural Period[/b]. Defines the "depth" of the analysis. Higher values focus on major swings; lower values capture local intraday moves.
[b]OMSF MA Color[/b]. The central baseline, representing the "Fair Value" (Midpoint) of the current structural lifecycle.
[b]Upper/Lower Bands[/b]. Smoothed structural boundaries acting as dynamic S/R zones derived from finalized omsf.High/Low levels.
[b]Show Baseline EMA[/b]. Toggle to compare the structural OMSF logic against a standard price-based EMA.


[b]How to use this for Education[/b]
How to use this for Education
    • Structural Feel: Watch how the bands expand during trending phases and contract during compressions.
    • MTF Dynamics: Set the indicator to a higher timeframe (HTF). Observe how LTF price action reacts with high precision to the structural boundaries of the higher-level flow.
    • Comparison: Use the EMA toggle. Notice how the OMSF MA remains "stable" during choppy sideways moves where standard EMAs often produce false signals.
    • Template for Devs: Check the source code to see how to import the OMSF Library and handle the 19-variable output tuple.

[b]Structural Flow vs. Filtered Signal[/b]
The OMSF Moving Average offers a unique perspective by balancing raw data and filtered logic:
[list]
[*]Holistic Structure: While the core StrHigh/Low levels act as strict filters to identify only high-conviction structural extremes, the omsf.ma integrates the OMSF Raw Structure (omsfHigh/Low).
[*]The Benefit: It ignores minor price noise (fluctuations without structural meaning) while remaining sensitive to the actual development of the move.
[/list]

[b]Disclaimer [/b] This is an analytical framework designed for professional traders. It provides the structure; you provide the strategy. [b]This is not financial advice.[/b]
[i]I release my frameworks to the community to validate the OMSF logic against real-world volatility. This live feedback loop is essential for refining the code and ensuring the framework remains resilient and reliable across all market conditions.[/i]
Made in Germany 🇩🇪 with a focus on logic and precision.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © arnipoer | Made in Germany 🇩🇪 ☺


// ----------------------------------------------------------------------------------------- //
// EDUCATIONAL EXAMPLE: Implementing the OMSF Framework                                      //
// This script demonstrates how to utilize the 19 structural output variables from the       //
// OMSF Library to create a professional Moving Average environment.                         //
// Use this as a template to understand the synergy between:                                 //
// - Market Phases (Expansion vs. Correction)                                                //
// - Structural Ranges (Compression vs. Wide Ranges)                                         //
// - Comparison with standard indicators (OMSF vs. EMA)                                      //
// ----------------------------------------------------------------------------------------- //

//@version=6
indicator("Moving Average OMSF", shorttitle = "OMSF MA", timeframe = "120", timeframe_gaps = true, behind_chart = true, overlay = true)

// Import the core library
//@link https://www.tradingview.com/script/g1122Yj2/

// OMSF Learning Space: Tutorial to understand Method of OMSF-Structure
//@link https://www.tradingview.com/script/KYJoMqb1-OMSF-Learning-Space/

import arnipoer/PriceActionStructure/4 as omsf
import arnipoer/VisualStructureTools/4 as vst

[bull_candle_color, bear_candle_color, deep_space_blue, midnight_charcoal, silk_pearl, omsf_color, omsf_bulls_color, omsf_bears_color, hyper_green_hex, laser_crimson_hex, cream, 
     mint_cyan, ice_blue, soft_coral, bears_dusk, bulls_fading, bulls_exhaustion, bulls_dawn] = vst.colorsuite()


// --- Inputs ---
gp_funct_ma    = 'Moving Average Settings'
source         = input.string('OMSF High/ Low', 'OMSF Source', options = ['Filtered OMSF High/ Low', 'OMSF High/ Low', 'Peak High/ Low'], group = gp_funct_ma)
ma_length      = input.int(50, 'MA Length', minval = 1, group = gp_funct_ma, tooltip = "The lookback period for the OMSF framework. All swing sizes and the MA are calculated relative to this value.")
show_ema       = input.bool(false, "Show Baseline EMA for comparison?", group = gp_funct_ma)

gp_omsf_para   = 'OMSF Parameters'
period         = input.int(14, 'ATR Period', step = 1, group = gp_omsf_para, inline = '1', active = source == 'Filtered OMSF High/ Low', tooltip = "The lookback period for ATR. Volatility measurements and swing thresholds are relative to this period.")
comp_tresh     = input.float(1.5, 'Compression Threshold', group = gp_omsf_para, step = 0.05, inline = '2', active = source == 'Filtered OMSF High/ Low', tooltip = "Swings smaller than this multiplier * ATR are labeled as 'Compression' (low volatility).")
hrg_tresh      = input.float(4.0, 'Huge Threshold', group = gp_omsf_para, step = 0.05, minval = 0.05, inline = '3', active = source == 'Filtered OMSF High/ Low', tooltip = "Swings larger than this multiplier * ATR are labeled as 'Expansion' (high volatility).")
expans_tresh   = input.float(1.2, 'Expansion Factor', group = gp_omsf_para, step = 0.05, minval = 1.05, inline = '4', active = source == 'Filtered OMSF High/ Low', tooltip = "Defines the breakout zone. Price must move this factor beyond the previous range to trigger an expansion phase.")
use_mom_filter = input.bool(true, "Use Momentum Filter", group = gp_omsf_para, inline = '5', active = source == 'Filtered OMSF High/ Low', tooltip = "If enabled, compression zones are only updated if the candle body exceeds the Momentum Threshold.")
mom_tresh      = input.float(1, 'Momentum Threshold', step = 0.05, minval = 0, group = gp_omsf_para, active = source == 'Filtered OMSF High/ Low', inline = '5', tooltip = "Minimum candle body size relative to ATR to pass the momentum filter.")

gp_style       = 'Visual Settings'
color_theme    = input.string('omsf_scheme', 'Color Scheme', options = ['omsf_scheme', 'omsf_light', 'custom'], display = display.none)
ma_color       = input.color(color.silver, "OMSF MA Color", group = gp_style, inline = "1", active = color_theme == 'custom')
upper_color    = input.color(color.red, "Upper Band", group = gp_style, inline = "2", active = color_theme == 'custom')
lower_color    = input.color(color.green, "Lower Band", group = gp_style, inline = "2", active = color_theme == 'custom')


// --- Logic ---
// Fetching the 19 variables
[omsf_strHigh, omsf_strHigh_time, omsf_strLow, omsf_strLow_time, peakHigh, peakLow, upMove, downMove, omsfHigh, omsfHigh_time, omsfLow, omsfLow_time, 
     compressed, standardRange, extended, expansLong, expansShort, longCorr, shortCorr] = omsf.get_omsf_structure(use_mom_filter, mom_tresh, close, period, expans_tresh, comp_tresh, hrg_tresh)

// Calculate the structural Moving Average & Bands using the library function
[omsf_ma, upper, lower] = omsf.ma(ma_length, source == 'OMSF High/ Low' ? omsfHigh : source == 'Filtered OMSF High/ Low' ? omsf_strHigh : peakHigh, source == 'OMSF High/ Low' ? omsfLow : source == 'Filtered OMSF High/ Low' ? omsf_strLow : peakLow)

// --- Visualization ---
plot(omsf_ma, "OMSF Structural MA", color = color_theme == 'omsf_scheme' ? omsf_color : color_theme == 'omsf_light' ? cream : ma_color, linewidth = 2)
plot(upper,   "Upper OMSF Band",    color = color_theme == 'omsf_scheme' ? omsf_bulls_color : color_theme == 'omsf_light' ? mint_cyan : upper_color, linewidth = 2)
plot(lower,   "Lower OMSF Band",    color = color_theme == 'omsf_scheme' ? omsf_bears_color : color_theme == 'omsf_light' ? soft_coral : lower_color, linewidth = 2)

// Comparison EMA
plot(show_ema ? ta.ema(close, ma_length) : na, "Standard EMA (Comparison)", color = color.blue, linewidth = 2)
````
