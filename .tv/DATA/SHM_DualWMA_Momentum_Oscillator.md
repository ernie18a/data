<!-- tradingview-pine-id: PUB;e4e54c05a6494ccfaaeeda8760b217ee -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# SHM Dual-WMA Momentum Oscillator

Source: https://www.tradingview.com/script/2dfGFrVX-SHM-Dual-WMA-Momentum-Oscillator/

## Description

SHM - Dual-WMA Momentum Oscillator [DWO]

Overview-
The SHM Dual-WMA Momentum Oscillator (DWO) is an institutional-grade momentum indicator engineered to isolate structural trend direction, momentum acceleration, and high-probability market cycles across custom timeframes.
By calculating the percentage distance between a Fast WMA and a Slow WMA, the DWO filters out transient market noise and locks calculation logic to a customizable higher timeframe wave—allowing you to project and track macro momentum seamlessly across every chart resolution.

Key Features & Architecture- 
* Flexible Multi-Timeframe (MTF) Engine: Complete control over your anchor timeframe (Anchor Momentum Timeframe). Choose your preferred momentum wave (e.g., 4H, Daily/24H, 3D, Weekly) and lock it to display consistently across all timeframes without repainting or distortion.

* Universal Timeframe Visibility: Lock your preferred anchor to the 4-Hour wave, and that 4H momentum wave stays strictly visible whether you zoom down to a 15-minute execution chart or step up to inspect the Daily or Weekly macro chart.

* Structural Trend Isolation: Eliminates short-term volatility, revealing where higher-timeframe capital flow is actually moving.

* Triple Equilibrium Baselines: Features customizable numeric anchor points (+33, 0, -33) paired with dynamic 4-color momentum acceleration histograms to easily spot expansion, exhaustion, and mean-reversion zones.

* Signal Tracking Line: Integrates an EMA-smoothed signal tracking line to highlight momentum crossovers and zero-line baseline retests cleanly.

How to Use for Analysis-
1. Selecting Your Anchor Timeframe:
    * Set the Anchor Momentum Timeframe in the settings input to your preferred cycle (e.g., 240 for 4H execution, 1440 for Daily macro, or 1W for high-timeframe positioning).
2. Determining Trend Bias:
    * DWO Line Above Zero Baseline: The selected anchor wave is structurally bullish. Intraday pullbacks act as buying liquidity within the broader trend.
    * DWO Line Below Zero Baseline: The selected anchor wave is structurally bearish. Intraday bounces act as counter-trend rallies.
3. Equilibrium Acceleration Histograms:
    * Green / Teal Histograms: Positive momentum acceleration relative to your selected anchor timeframe.
    * Red / Dark Red Histograms: Negative momentum acceleration relative to your selected anchor timeframe.

Inputs & Settings-
* Anchor Momentum Timeframe (Default: 24H / 1440): Selects the timeframe wave to project across all charts (supports 1m up to 1W).

* Fast WMA Lookback (Default: 65): Controls the sensitivity of the primary signal curve.

* Slow WMA Lookback (Default: 480): Establishes the baseline filter for long-term trend isolation.

* Signal Smoothing Line (Default: 63): Adjusts the sensitivity of the EMA signal tracking curve.

* Triple Baseline Configuration: Sets the Y-axis levels for upper (+33), zero (0), and lower (-33) histograms.

Disclaimer
This script is designed for educational, informational, and analytical charting purposes only. It does not constitute financial or trading advice. Always perform independent analysis and practice strict risk management.

---

## Source Code

````pine
//@version=6
indicator("SHM Dual-WMA Momentum Oscillator", overlay=false, precision=2, shorttitle="DWO")

// ==========================================
// 1. INPUTS & CONFIGURATION
// ==========================================
// Dynamic MTF Framework Engine
htf_timeframe  = input.timeframe("1440", title="Anchor Momentum Timeframe", tooltip="Choose the timeframe wave to project across all charts (e.g., 240 for 4H, 1440 for Daily, 3D, W).", group="1. MULTI-TIMEFRAME ENGINE")

fast_len       = input.int(63, title="Fast WMA Lookback", group="Core WMA Engine")
slow_len       = input.int(480, title="Slow WMA Lookback", group="Core WMA Engine")
signal_len     = input.int(63, title="Signal Smoothing Line", group="Momentum Smoothing")
visual_offset  = input.int(1, title="Visual Plot Offset", group="Core Framework")
price_source   = input.source(ohlc4, title="Price Source Data", group="Core Framework")

// Triple Baseline Shift Configuration
upper_eq_midline = input.float(33.0,  title="Upper Baseline (+33)", group="Visualization Settings")
zero_eq_midline  = input.float(0.0,   title="Zero Baseline (0)", group="Visualization Settings")
lower_eq_midline = input.float(-33.0, title="Lower Baseline (-33)", group="Visualization Settings")

// ==========================================
// 2. MATHEMATICAL DISTANCE ENGINE (DYNAMIC MTF)
// ==========================================
f_htf_calc(src, f_len, s_len, sig_len) =>
    f_wma = ta.wma(src, f_len)
    s_wma = ta.wma(src, s_len)
    dwo   = ((f_wma - s_wma) / s_wma) * 100
    sig   = ta.ema(dwo, sig_len)
    hist  = dwo - sig
    [dwo, sig, hist]

// Fetch selected anchor momentum timeframe mapped across higher/lower charts
[dwo_line, signal_line, histogram] = request.security(
     syminfo.tickerid, 
     htf_timeframe, 
     f_htf_calc(price_source, fast_len, slow_len, signal_len), 
     barmerge.gaps_off, 
     barmerge.lookahead_off
 )

// Dynamic Histogram Color Palettes
color hist_color_primary = histogram >= 0 ? (histogram > histogram[1] ? color.rgb(23, 205, 166, 40) : color.rgb(20, 200, 161, 40)) : (histogram < histogram[1] ? color.rgb(177, 28, 28, 20) : color.new(#db1616, 40))
color hist_color_zero    = histogram >= 0 ? (histogram > histogram[1] ? color.new(#29b496, 50) : color.new(#0d9076, 67)) : (histogram < histogram[1] ? color.new(#971919, 57) : color.new(#c52424, 40))

// Shifted Histograms
shifted_hist_upper = upper_eq_midline + histogram
shifted_hist_zero  = zero_eq_midline  + histogram
shifted_hist_lower = lower_eq_midline + histogram

// ==========================================
// 3. VISUALIZATION LAYER
// ==========================================
hline(upper_eq_midline, "Upper Baseline (+33)", color=#505268b3, linestyle=hline.style_solid)
hline(zero_eq_midline,  "Zero Baseline (0)",    color=color.new(color.gray, 50), linestyle=hline.style_dashed)
hline(lower_eq_midline, "Lower Baseline (-33)", color=#505268b3, linestyle=hline.style_solid)

plot(shifted_hist_lower, title="Lower (-33) Histogram", color=hist_color_primary, style=plot.style_histogram, histbase=lower_eq_midline, linewidth=2, offset=visual_offset, display=display.none)
plot(shifted_hist_zero,  title="Zero (0) Histogram",    color=hist_color_zero,    style=plot.style_histogram, histbase=zero_eq_midline,  linewidth=2, offset=visual_offset)
plot(shifted_hist_upper, title="Upper (+33) Histogram", color=hist_color_primary, style=plot.style_histogram, histbase=upper_eq_midline, linewidth=3, offset=visual_offset, display=display.none)

plot(dwo_line, title="DWO Primary Line", color=color.rgb(236, 225, 211, 40), linewidth=1, offset=visual_offset)
plot(signal_line, title="Signal Tracking Line", color=color.new(#ab0000, 60), linewidth=1, offset=visual_offset)
````
