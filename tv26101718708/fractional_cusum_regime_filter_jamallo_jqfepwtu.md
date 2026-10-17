# Fractional CUSUM Regime Filter [Jamallo]

- url: https://www.tradingview.com/script/JqFEpwTU-Fractional-CUSUM-Regime-Filter-Jamallo/
- type: indicator
- pine_id: PUB;d76fa4ee4f76417c9447f82a771e2995
- version: 1.0

## Description

🔹[b]Intro[/b]

The Fractional CUSUM Regime Filter is a quantitative trend and volatility channel indicator designed to identify structural market regimes with high stability. Unlike traditional filters that suffer from lag or whipsaw signals, this indicator applies a dual-layered preprocessor combining Lopez de Prado’s Fixed-Window Fractional Differentiation (FFD) with a classic Cumulative Sum (CUSUM) statistical trigger.

🔹[b]Break down[/b]

[list]
[*][b]Fractional Differentiation (FFD)[/b]: Stationarizes pricing input while retaining long-term historical memory (controlled by the "d" parameter). 

[*][b]Classic CUSUM Filter[/b]: Accumulates deviations from a rolling baseline relative to current volatility. When cumulative deviation exceeds the threshold multiplier (h), a new regime change is triggered, and the baseline steps dynamically to the new price level.

[*][b]Vol-Adjusted Percentile Bands[/b]: Linear interpolation percentiles of price deviation relative to the stepped baseline. The distances are "locked" and only update on CUSUM regime triggers to prevent wobbly bands.
[/list]

🔹[b]Visual Guide: Indicator Anatomy[/b]

Here we have the structure of the indicator, including the CUSUM baseline, the 68% inner percentile band, and the 95% outer percentile band.

[image]https://www.tradingview.com/x/ZLdV2auH/[/image]

[b]How to use: Mean Reversion (Pullbacks to the Mean)[/b]

The channel boundaries represent statistical extremes. When the price is pushed outside the bands, it is mathematically overextended and highly likely to revert back to the CUSUM baseline.

Long Setup (Pullbacks in Bullish Trend): During a green CUSUM uptrend, watch for price to pull back to the lower bands ("micro pullback") and enter as it heads back up to the baseline mean.

https://www.tradingview.com/x/X0vhVxPS/

Short Setup (Pullbacks in Bearish Trend): During a red CUSUM downtrend, watch for price to rally into the upper bands ("micro pullback") and enter as it reverts down to the baseline mean.

https://www.tradingview.com/x/MyZPE0NV/

🔹[b]How to use: Trend Following & Risk Management[/b]

The indicator is designed to capture sustained macro trends while providing clear risk parameters.

[list]
[*][b]Entering on Breakthroughs[/b]: Enter when the BUY/SELL signal flags appear (indicating a new CUSUM regime shift). 

[*][b]Stop Loss Placement[/b]: Place stop loss orders just below the opposite outer band or below the stepped baseline. 

[*][b]Letting Winners Run[/b]: Ride the trend as long as the CUSUM baseline maintains its colored regime state (Green for Long, Red for Short).
[/list]

https://www.tradingview.com/x/HKpVrxXO/
https://www.tradingview.com/x/LsrZ9MZ2/

🔹[b]Settings Parameters [/b]

[list]
[*][b]d (0.01 - 0.99)[/b]: Differentiation order. Lower values retain more historical memory; higher values approach first-difference.

[*][b]CUSUM Drift & Threshold[/b]: Controls baseline sensitivity to regime changes. 

[*][b]Percentile Lookback & Targets[/b]: Set the statistical width of the inner and outer boundaries.
[/list]

## Source Code

````pine
//@version=6
indicator("Fractional CUSUM Regime Filter [Jamallo]", 
     overlay = true,
     max_bars_back = 500)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════════════════════

ffdD = input.float(0.5, "Fractional Differentiation Degree (d)", minval=0.01, maxval=0.99, step=0.01, group="Fractional Differentiation", tooltip="Real-valued differentiation order. Lower values retain more historical memory; higher values approach first-difference.")
ffdLength = input.int(30, "Fractional Differentiation Window Length", minval=5, maxval=200, group="Fractional Differentiation", tooltip="Number of historical bars to accumulate memory weights.")

cusumPeriod = input.int(20, "CUSUM Volatility Period", minval=2, group="CUSUM Baseline", tooltip="Lookback period to estimate rolling volatility of the smoothed series.")
cusumDrift = input.float(0.5, "CUSUM Drift Multiplier", minval=0.0, maxval=5.0, step=0.1, group="CUSUM Baseline", tooltip="Drift parameter (k) to filter out noise. High values require stronger movement to trigger a baseline shift.")
cusumThreshold = input.float(5.0, "CUSUM Threshold Multiplier", minval=0.1, maxval=10.0, step=0.1, group="CUSUM Baseline", tooltip="Threshold parameter (h) in standard deviations. When cumulative deviation exceeds this, baseline shifts.")

percentileLookback = input.int(100, "Percentile Lookback Period", minval=20, maxval=500, group="Percentile Bands")
innerPercentile = input.float(68.0, "Inner Percentile", minval=50.0, maxval=99.0, step=1.0, group="Percentile Bands")
outerPercentile = input.float(95.0, "Outer Percentile", minval=50.0, maxval=99.9, step=1.0, group="Percentile Bands")

showInnerBands = input.bool(true, "Show Inner Percentile Bands", group="Display")
showOuterBands = input.bool(true, "Show Outer Percentile Bands", group="Display")
colorCodeBaseline = input.bool(true, "Color Code Baseline", group="Display")
showSignals = input.bool(true, "Show Signals", group="Display")
bullColor = input.color(color.teal, "Bullish Color", inline="colors", group="Display")
bearColor = input.color(color.maroon, "Bearish Color", inline="colors", group="Display")
neutralColor = input.color(color.gray, "Neutral Color", inline="colors", group="Display")

// ══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════════════════════════════════════════════════════════
// FRACTIONAL DIFFERENTIATION WEIGHTS CALCULATION
// ══════════════════════════════════════════════════════════════════════════════

var float ffd_weights_sum = 0.0
var float[] ffd_weights = na
if na(ffd_weights)
    ffd_weights := array.new<float>(ffdLength)
    array.set(ffd_weights, 0, 1.0)
    ffd_weights_sum := 1.0
    for k = 1 to ffdLength - 1
        w_prev = array.get(ffd_weights, k - 1)
        coeff = -w_prev * (ffdD - k + 1) / k
        array.set(ffd_weights, k, coeff)
        ffd_weights_sum := ffd_weights_sum + coeff

f_ffd_apply(float src, float[] weights, int length) =>
    float ffd_val = 0.0
    for i = 0 to length - 1
        ffd_val := ffd_val + array.get(weights, i) * nz(src[i], src)
    ffd_val

// ══════════════════════════════════════════════════════════════════════════════
// HYBRID FRACTIONAL DIFFERENTIATION & CLASSIC CUSUM PREPROCESSOR
// ══════════════════════════════════════════════════════════════════════════════

f_calculate_ffd_cusum_filter() =>
    // Step 1: Stationarize close pricing input using Fixed-Window Fractional Differentiation (FFD)
    ffd_val = f_ffd_apply(close, ffd_weights, ffdLength)
    
    vol = ta.stdev(ffd_val - ffd_val[1], cusumPeriod)
    vol_adjusted = na(vol) or vol == 0.0 ? 1e-8 : vol
    
    var float s_pos = 0.0
    var float s_neg = 0.0
    var float baseline = na
    bool triggered = false
    var int trend = 0
    
    if na(baseline)
        baseline := close
        triggered := true
        
    // Step 2: Calculate Classic CUSUM deviations of FFD input relative to FFD baseline representation
    baseline_ffd = baseline * ffd_weights_sum
    dev_up = ffd_val - baseline_ffd
    dev_down = baseline_ffd - ffd_val
    
    z_up = dev_up / vol_adjusted
    z_down = dev_down / vol_adjusted
    
    if not na(vol)
        s_pos := math.max(0.0, nz(s_pos[1]) + z_up - cusumDrift)
        s_neg := math.max(0.0, nz(s_neg[1]) + z_down - cusumDrift)
        
        if s_pos > cusumThreshold
            baseline := close
            s_pos := 0.0
            s_neg := 0.0
            triggered := true
            trend := 1
        else if s_neg > cusumThreshold
            baseline := close
            s_pos := 0.0
            s_neg := 0.0
            triggered := true
            trend := -1
            
    [baseline, triggered, trend]

// ══════════════════════════════════════════════════════════════════════════════
// CALCULATE INDICATORS
// ══════════════════════════════════════════════════════════════════════════════

[range_filter, triggered, trendState] = f_calculate_ffd_cusum_filter()

// ══════════════════════════════════════════════════════════════════════════════
// PERCENTILE BANDS
// ══════════════════════════════════════════════════════════════════════════════

price_deviation = math.abs(close - range_filter)
inner_distance = ta.percentile_linear_interpolation(price_deviation, percentileLookback, innerPercentile)
outer_distance = ta.percentile_linear_interpolation(price_deviation, percentileLookback, outerPercentile)

var float active_inner_dist = na
var float active_outer_dist = na

if triggered or na(active_inner_dist)
    active_inner_dist := inner_distance
    active_outer_dist := outer_distance

upper_inner = range_filter + active_inner_dist
lower_inner = range_filter - active_inner_dist
upper_outer = range_filter + active_outer_dist
lower_outer = range_filter - active_outer_dist

color baselineColor = colorCodeBaseline ? 
     (trendState == 1 ? bullColor : trendState == -1 ? bearColor : neutralColor) : 
     color.white

// ══════════════════════════════════════════════════════════════════════════════
// PLOTTING
// ══════════════════════════════════════════════════════════════════════════════

baseline_plot = plot(range_filter, "CUSUM Baseline", color=baselineColor, linewidth=1)

upper_band1_color = trendState == 1 ? color.new(bullColor, 80) : trendState == -1 ? color.new(bearColor, 80) : color.new(neutralColor, 80)
upper_band2_color = trendState == 1 ? color.new(bullColor, 70) : trendState == -1 ? color.new(bearColor, 70) : color.new(neutralColor, 70)

lower_band1_color = trendState == 1 ? color.new(bullColor, 80) : trendState == -1 ? color.new(bearColor, 80) : color.new(neutralColor, 80)
lower_band2_color = trendState == 1 ? color.new(bullColor, 70) : trendState == -1 ? color.new(bearColor, 70) : color.new(neutralColor, 70)

upper_inner_plot = plot(showInnerBands ? upper_inner : na, "Upper Inner Band", color=upper_band1_color, linewidth=1)
upper_outer_plot = plot(showOuterBands ? upper_outer : na, "Upper Outer Band", color=upper_band2_color, linewidth=1)

lower_inner_plot = plot(showInnerBands ? lower_inner : na, "Lower Inner Band", color=lower_band1_color, linewidth=1)
lower_outer_plot = plot(showOuterBands ? lower_outer : na, "Lower Outer Band", color=lower_band2_color, linewidth=1)

// Gradient fills for Band 1
fill(upper_inner_plot, baseline_plot, range_filter, upper_inner, color.new(bullColor, 95), color.new(bullColor, 97), title="Upper Band 1 Gradient")
fill(baseline_plot, lower_inner_plot, lower_inner, range_filter, color.new(bearColor, 97), color.new(bearColor, 95), title="Lower Band 1 Gradient")

// Gradient fills for Band 2
fill(upper_outer_plot, upper_inner_plot, upper_inner, upper_outer, color.new(bullColor, 97), color.new(bullColor, 80), title="Upper Band 2 Gradient")
fill(lower_inner_plot, lower_outer_plot, lower_outer, lower_inner, color.new(bearColor, 80), color.new(bearColor, 97), title="Lower Band 2 Gradient")

// ══════════════════════════════════════════════════════════════════════════════
// ALERTS & SIGNALS
// ══════════════════════════════════════════════════════════════════════════════

bool trendUp = trendState == 1 and trendState[1] != 1
bool trendDown = trendState == -1 and trendState[1] != -1

// Buy/Sell Signals
plotshape(showSignals and trendUp, title="Bullish Signal (Buy)", style=shape.labelup, location=location.belowbar, color=bullColor, text="BUY", textcolor=color.white, size=size.small)
plotshape(showSignals and trendDown, title="Bearish Signal (Sell)", style=shape.labeldown, location=location.abovebar, color=bearColor, text="SELL", textcolor=color.white, size=size.small)

alertcondition(trendUp, "Trend Up", "Range Matrix: Bullish regime detected")
alertcondition(trendDown, "Trend Down", "Range Matrix: Bearish regime detected")
````
