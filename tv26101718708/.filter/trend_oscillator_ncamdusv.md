# Trend Oscillator

- url: https://www.tradingview.com/script/NcamDuSV-Trend-Oscillator/
- type: indicator
- pine_id: PUB;4c0534bdd2624a4e8ee467e709c9af9d
- version: 3.0

## Description

]Modified DZIV's 'Trend Indicator B' and added a rate-of-change oscillator to better model the buy/sell momentum of each 'push' or leg in the current trend. It may assist in visualizing when 'dips' may be occurring in a current trend for a continuation play and/or when exhaustion may be occurring for a reversal play.  Personally, I like to pair with a high and a low BB for even more accurate entries/exits. As always, should be used with context and higher timeframe trend analysis. View Github Repo for how-to use case images.

https://github.com/DLocarno/Trend-Oscillator/blob/48b3ed068afae2200bf4f7e0ca14c9bcb574eefe/ContinuationExample.png

https://github.com/DLocarno/Trend-Oscillator/blob/48b3ed068afae2200bf4f7e0ca14c9bcb574eefe/ReversalExample.png

https://github.com/DLocarno/Trend-Oscillator/blob/48b3ed068afae2200bf4f7e0ca14c9bcb574eefe/ReversalExample2.png

https://github.com/DLocarno/Trend-Oscillator/blob/48b3ed068afae2200bf4f7e0ca14c9bcb574eefe/EntriesExitsExample.png

## Source Code

````pine
//@version=5
//
//╔════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
//║ Original Author: Trend Indicator B by DZIV (dzi_v_) // Slope & Exhaustion extension by Dave L
//║ Licence | CC BY-NC-SA 4.0 : https://creativecommons.org/licenses/by-nc-sa/4.0/
//╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
//║ Changelog :
//║ 2021.04.15 > B-V1.0 -First publish
//║ 2021.05.05 > B-V2.0 -Added high and low calculation and display
//║ 					-Minor script optimisation
//║ 2021.05.06 > B-V2.1 -Added resolution customisation in the study
//║ 2021.10.18 > B-V2.2 -Added "MA Type" customisation possibility
//║ 					-Replaced the "colour schemes" feature by a "base color inputs" feature (user friendly)
//║ 					-Switched the title names to English for a better understanding
//║ 					-Minor script optimisation
//║ 2024.04.21 > B-V2.3 -Switched to PineScript version 5
//║ 					-Major script rethinking and optimisation
//║ 					-Removed double smoothing for less lag
//║ 					-Added ALMA, HMA and ZLEMA to the "MA Type" input string
//║ 					-Added highlights to indicate potential trend reversals
//║ 2025.04.18 > B-V2.4 -Added Slope / Rate-of-Change model
//║ 2025.04.18 > B-V2.5 -Added 3-state slope: Rising / Flat / Falling with adjustable neutral deadband zone
//║ 2025.04.18 > B-V2.6 -Peak tracking state machine: stores slope peak + close price per cycle
//║ 2025.04.18 > B-V2.7 -Fixed: cross-invalidation + trend-direction guard on labels
//║ 2025.04.18 > B-V2.8 -Fixed: momentum threshold now only gates P1, not P2
//║ 2025.04.18 > B-V2.9 -Fixed: cycle reset now triggered by trend crossing zero, not slope
//║ 2025.04.18 > B-V3.0 -Fixed: P1 now only advances when the next peak is also strong
//║ 2025.04.18 > B-V3.1 -Adaptive slope via Efficiency Ratio (ER) blending
//║ 					 Single slope_period replaced with slope_period_fast + slope_period_slow
//║ 					 ER (0=choppy → 1=trending) blends continuously between them:
//║ 					 trending markets lean fast (responsive), choppy markets lean slow
//║ 					 (smoothed), suppressing noisy micro-peaks without a fixed cutoff.
//║                      e.g. attempts to apply a kaufman style adaptive filter to the slope line, making more meaningful
//║                      moves appear prominent and suppressing noise, depending on current volatility/chop levels.
//║                      Can keep the fast and slow slope parameters the same to keep original functionality.
//║ 2025.04.20 > B-V3.2 -Slope now computed on raw HA body (pre-normalization) to avoid derivative compression
//║                      at trend extremes where the bounded ±100 oscillator masks sustained momentum.
//║                      Raw slope is then normalized to ±100 via rolling max before visual scale is applied.
//║                      momentum_threshold now operates on the ±100 normalized scale (instrument-independent).
//║                      Added Slope Norm. Lookback input to control the rolling normalization window.
//║                      This should result in a more accurate slope magnitude depiction during extreme trends.
//╚════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
//
//╔════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
//║ Settings :
indicator('Trend Indicator B (v3.2) [DZIV] With Rate-of-Change', 'Trend Oscillator', false, max_labels_count = 500, max_lines_count = 500)
 
ma_type   = input.string('VWMA', 'MA Type', ['ALMA','HMA','SMA','SWMA','VWMA','WMA','ZLEMA','EMA'], group = 'Setup')
ma_period = input.int(30, 'MA Period (Length)', 1, group = 'Setup')
 
alma_offset = input.float(0.85, 'ALMA Shift',    0, 1, 0.05, group = 'Setup (ALMA)') // for ALMA type only
alma_sigma  = input.int(6,     'ALMA Deviation', 1, step = 1, group = 'Setup (ALMA)') // for ALMA type only
 
// ── Slope settings ────────────────────────────────────────────────────────────
slope_method      = input.string('Momentum', 'Slope Method',
     ['Smoothed Derivative', 'Linear Regression', 'Momentum'],
     tooltip = 'Smoothed Derivative: MA of bar-by-bar changes.\nLinear Regression: least-squares slope over the window.\nMomentum: raw n-bar difference per bar.',
     group = 'Slope Settings')
slope_period_fast = input.int(4,  'Slope Period — Fast', minval = 2,
     tooltip = 'Used when market is trending (Efficiency Ratio near 1). More responsive to volatility, less smoothing.',
     group = 'Slope Settings')
slope_period_slow = input.int(9,  'Slope Period — Slow', minval = 2,
     tooltip = 'Used when market is choppy (Efficiency Ratio near 0). More smoothing, better suppressing slope noise.',
     group = 'Slope Settings')
er_period         = input.int(9,  'ER Period',           minval = 2,
     tooltip = 'Lookback for the Efficiency Ratio.\nMeasures directional efficiency of price movement and weights the rate-of-change line between slow and fast periods\nER = net price move / sum of bar-by-bar moves. Higher = slower transition time.',
     group = 'Slope Settings')
slope_scale       = input.float(50, 'Slope Scale',        minval = 1, step = 1,
     tooltip = 'Visual multiplier applied after normalization. Controls the display amplitude of the slope line relative to the oscillator.',
     group = 'Slope Settings')
slope_norm_period = input.int(200, 'Slope Norm. Lookback', minval = 20,
     tooltip = 'Rolling window used to normalize the raw body slope to a ±100 scale before visual scale is applied.\nLarger = more stable baseline; smaller = more adaptive to recent momentum range.',
     group = 'Slope Settings')
slope_deadband    = input.float(0.25, 'Deadband (Flat Zone ±)', minval = 0.0, step = 0.25,
     tooltip = 'Slope values within ±this threshold are treated as Flat/Plateauing.',
     group = 'Slope Settings')
 
// ── Divergence Lines (Beta) ─────────────────────────────────────────────────────────
show_div_lines     = input.bool(true,  'Show divergence lines',   group = 'Divergence Lines')
momentum_threshold = input.float(20.0, 'Momentum Threshold',     minval = 0.1, step = 0.5,
     tooltip = 'Operates on the normalized ±100 slope scale (instrument-independent).\n' +
               'A phase is only established when a slope peak exceeds this magnitude.\n' +
               'P1 is set on the first strong peak, and only advances to a later strong peak.\n' +
               'Weak P2s (below threshold) can trigger a line but never become the new P1.\n' +
               'The cycle resets when the trend line crosses zero.',
     group = 'Divergence Lines')
 
// ── On/Off ────────────────────────────────────────────────────────────────────
show_line(x)      => input.bool(true, 'Show trend line',          group = 'On/Off') ? x : na
show_fill(x)      => input.bool(true, 'Show fill',                group = 'On/Off') ? x : na
show_highlight(x) => input.bool(true, 'Show highlight',           group = 'On/Off') ? x : na
show_slope(x)     => input.bool(true, 'Show slope line',          group = 'On/Off') ? x : na
show_deadband(x)  => input.bool(true, 'Show deadband zone',       group = 'On/Off') ? x : na
show_markers(x)   => input.bool(true, 'Show slope state markers', group = 'On/Off') ? x : na
//╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
//║ Calculations :
f(x) =>
    switch ma_type
        'ALMA'  => ta.alma(x, ma_period, alma_offset, alma_sigma)
        'HMA'   => ta.hma(x, ma_period)
        'SMA'   => ta.sma(x, ma_period)
        'SWMA'  => ta.swma(x)
        'VWMA'  => ta.vwma(x, ma_period)
        'WMA'   => ta.wma(x, ma_period)
        'ZLEMA' => ta.ema(x + x - x[math.floor((ma_period - 1) / 2)], ma_period)
        =>         ta.ema(x, ma_period)
 
ma_heikinashi_open  = f(request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, open))
ma_heikinashi_close = f(request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, close))
ma_heikinashi_high  = f(request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, high))
ma_heikinashi_low   = f(request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, low))
 
trend = 100 * (ma_heikinashi_close - ma_heikinashi_open) / (ma_heikinashi_high - ma_heikinashi_low)
 
// Raw HA body — unnormalized slope source.
// Computing slope on the bounded `trend` ratio creates derivative compression at ±100 extremes
// (the oscillator pins while underlying momentum may still be building). Using the raw body
// before range-division captures true momentum changes regardless of how "trendy" the candle is.
ma_heikinashi_raw_body = ma_heikinashi_close - ma_heikinashi_open
 
// ── Efficiency Ratio ──────────────────────────────────────────────────────────
// ER = directional move / total path length over er_period bars
// Ranges 0 (pure chop) → 1 (perfectly trending)
// Used to blend continuously between fast and slow slope calculations
er_net_move = math.abs(close - close[er_period])
er_path     = math.sum(math.abs(close - close[1]), er_period)
er          = er_path > 0 ? er_net_move / er_path : 0
 
// ── Slope / Rate-of-Change on raw HA body (ER-blended fast + slow) ────────────
raw_slope_fast = switch slope_method
    'Linear Regression' => ta.linreg(ma_heikinashi_raw_body, slope_period_fast, 0) - ta.linreg(ma_heikinashi_raw_body, slope_period_fast, 1)
    'Momentum'          => (ma_heikinashi_raw_body - ma_heikinashi_raw_body[slope_period_fast]) / slope_period_fast
    =>                     ta.sma(ma_heikinashi_raw_body - ma_heikinashi_raw_body[1], slope_period_fast)
 
raw_slope_slow = switch slope_method
    'Linear Regression' => ta.linreg(ma_heikinashi_raw_body, slope_period_slow, 0) - ta.linreg(ma_heikinashi_raw_body, slope_period_slow, 1)
    'Momentum'          => (ma_heikinashi_raw_body - ma_heikinashi_raw_body[slope_period_slow]) / slope_period_slow
    =>                     ta.sma(ma_heikinashi_raw_body - ma_heikinashi_raw_body[1], slope_period_slow)
 
// Blend: trending market (ER→1) favours fast; choppy market (ER→0) favours slow
raw_slope_blended = er * raw_slope_fast + (1 - er) * raw_slope_slow
 
// Normalize blended slope to ±100 using rolling absolute maximum, then apply visual scale.
// trend_slope_norm : stable ±100 scale — used for threshold logic (instrument-independent)
// trend_slope      : display-scaled version — used for plotting and line coordinates
slope_abs_max    = ta.highest(math.abs(raw_slope_blended), slope_norm_period)
trend_slope_norm = slope_abs_max > 0 ? (raw_slope_blended / slope_abs_max) * 100 : 0
trend_slope      = trend_slope_norm * slope_scale / 100
 
// ── 3-State classification using deadband ─────────────────────────────────────
slope_state      = trend_slope >  slope_deadband ? 1 : trend_slope < -slope_deadband ? -1 : 0
entering_rising  = slope_state ==  1 and slope_state[1] != 1
entering_flat    = slope_state ==  0 and slope_state[1] != 0
entering_falling = slope_state == -1 and slope_state[1] != -1
//╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
//║ Colors :
color_positive   = input.color(color.new(#26A69A, 0), 'Positive color (Bullish)',  group = 'Colors')
color_negative   = input.color(color.new(#EF5350, 0), 'Negative color (Bearish)',  group = 'Colors')
color_s_positive = input.color(color.new(#038197, 0), 'Slope positive color',      group = 'Colors')
color_s_negative = input.color(color.new(#e74b7f, 0), 'Slope negative color',      group = 'Colors')
color_neutral    = input.color(color.new(#808080, 0), 'Neutral color',             group = 'Colors')
color_flat       = input.color(color.new(#B0BEC5, 0), 'Flat/Plateau color',        group = 'Colors')
 
color_trend = trend > 0 ? color_positive : color_negative
 
color_slope =
     slope_state == 0 ? color_flat :
     trend > 0
         ? (slope_state ==  1 ? color.new(color_s_positive, 0) : color.new(color_s_negative, 0))
         : (slope_state == -1 ? color.new(color_s_negative, 0) : color.new(color_s_positive, 0))
//╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
//║ Divergence / Exhaustion Detection :
//
// Phase lifecycle:
//   INACTIVE  → waiting for a strong peak (≥ momentum_threshold) to open a cycle
//   ACTIVE    → tracking; P1 is fixed at the last strong peak
//   RESET     → trend crossed zero; back to INACTIVE until next strong peak
//
// P1 advancement rule:
//   P1 only moves forward when a subsequent peak is ALSO strong (≥ threshold).
//   A weak P2 (< threshold) fires a divergence line if conditions are met, but
//   the P1 anchor stays fixed.
//
// Guard conditions for a divergence line:
//   1. An active phase exists (P1 set by a strong peak, trend not yet crossed zero)
//   2. P2 slope < P1 slope (momentum lower high / higher low)
//   3. Price at P2 diverges from price at P1 (higher close for bull, lower for bear)
//   4. trend[1] > 0 for bull / trend[1] < 0 for bear
 
// ── Peak shape (no threshold) ─────────────────────────────────────────────────
bull_any_peak = trend_slope[1] >  trend_slope[0] and trend_slope[1] >= trend_slope[2] and trend_slope[1] >  0
bear_any_peak = trend_slope[1] <  trend_slope[0] and trend_slope[1] <= trend_slope[2] and trend_slope[1] <  0
 
// ── Strong peaks — threshold applied to normalized ±100 scale ─────────────────
bull_strong_peak = bull_any_peak and trend_slope_norm[1] >  momentum_threshold
bear_strong_peak = bear_any_peak and trend_slope_norm[1] < -momentum_threshold
 
// ── Persistent state — bull cycle ─────────────────────────────────────────────
var float bull_p1_slope = na
var float bull_p1_close = na
var int   bull_p1_bar   = na
var bool  bull_crossed  = false
 
// ── Persistent state — bear cycle ─────────────────────────────────────────────
var float bear_p1_slope = na
var float bear_p1_close = na
var int   bear_p1_bar   = na
var bool  bear_crossed  = false
 
// ── Trend zero-cross reset ─────────────────────────────────────────────────────
if not na(bull_p1_slope) and trend <= 0
    bull_crossed := true
if not na(bear_p1_slope) and trend >= 0
    bear_crossed := true
 
// ── Bullish peak processing ───────────────────────────────────────────────────
if bull_any_peak
    if na(bull_p1_slope) or bull_crossed
        if bull_strong_peak
            bull_p1_slope := trend_slope[1]
            bull_p1_close := close[1]
            bull_p1_bar   := bar_index[1]
            bull_crossed  := false
    else
        if trend_slope[1] < bull_p1_slope and close[1] > bull_p1_close and trend[1] > 0
            if show_div_lines
                line.new(bull_p1_bar, bull_p1_slope, bar_index[1], trend_slope[1],
                     color = color.new(color_s_negative, 40),
                     width = 1, style = line.style_dashed)
        if bull_strong_peak
            bull_p1_slope := trend_slope[1]
            bull_p1_close := close[1]
            bull_p1_bar   := bar_index[1]
 
// ── Bearish trough processing ─────────────────────────────────────────────────
if bear_any_peak
    if na(bear_p1_slope) or bear_crossed
        if bear_strong_peak
            bear_p1_slope := trend_slope[1]
            bear_p1_close := close[1]
            bear_p1_bar   := bar_index[1]
            bear_crossed  := false
    else
        if trend_slope[1] > bear_p1_slope and close[1] < bear_p1_close and trend[1] < 0
            if show_div_lines
                line.new(bear_p1_bar, bear_p1_slope, bar_index[1], trend_slope[1],
                     color = color.new(color_s_positive, 40),
                     width = 1, style = line.style_dashed)
        if bear_strong_peak
            bear_p1_slope := trend_slope[1]
            bear_p1_close := close[1]
            bear_p1_bar   := bar_index[1]
//╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
//║ Plot :
plot_trend = plot(trend,       'Trend (Heikin Ashi)', show_line(color_trend),  1)
plot_null  = plot(0,           'Null (Doji)',          color_neutral,           1, plot.style_cross)
plot_slope = plot(trend_slope, 'Trend Slope',          show_slope(color_slope), 2)
 
plot_db_upper = plot( slope_deadband, 'Deadband Upper', show_deadband(color.new(color_flat, 75)), 1, plot.style_line)
plot_db_lower = plot(-slope_deadband, 'Deadband Lower', show_deadband(color.new(color_flat, 75)), 1, plot.style_line)
fill(plot_db_upper, plot_db_lower, show_deadband(color.new(color_flat, 88)), 'Deadband Zone')
//╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
//║ State-transition markers :
plotshape(show_markers(entering_rising  ? trend_slope : na),
     'Slope → Rising',  shape.triangleup,   location.absolute, color.new(color_s_positive, 10), size = size.tiny)
plotshape(show_markers(entering_falling ? trend_slope : na),
     'Slope → Falling', shape.triangledown, location.absolute, color.new(color_s_negative, 10), size = size.tiny)
plotshape(show_markers(entering_flat    ? trend_slope : na),
     'Slope → Flat',    shape.circle,       location.absolute, color.new(color_flat, 10),        size = size.tiny, display = display.none)
//╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
//║ Hline :
hline( 100, 'Maxval',      color_positive, hline.style_solid,   2)
hline(  50, 'Pivot line',  color_neutral,  hline.style_solid)
hline(  25, 'Pivot line',  color_neutral,  hline.style_dotted)
hline(   0, 'Null (Doji)', color_neutral,  hline.style_solid)
hline( -25, 'Pivot line',  color_neutral,  hline.style_dotted)
hline( -50, 'Pivot line',  color_neutral,  hline.style_solid)
hline(-100, 'Minval',      color_negative, hline.style_solid,   2)
//╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
//║ Fill :
fill(plot_trend, plot_null, 0, trend < 0 ? -25 : 25, na, show_fill(color.new(color_trend, 50)), 'Color Fill')
//╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
//║ Bgcolor :
bgcolor(math.abs(trend) > 25 ? show_highlight(color.new(color_trend, 87.5)) : na, title = 'Pivot Highlight (Weak)')
bgcolor(math.abs(trend) > 50 ? show_highlight(color.new(color_trend, 87.5)) : na, title = 'Pivot Highlight (Strong)')
//╚════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
````
