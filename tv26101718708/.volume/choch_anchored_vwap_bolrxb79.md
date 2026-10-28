# CHoCH Anchored VWAP

- url: https://www.tradingview.com/script/boLrXB79-CHoCH-Anchored-VWAP/
- type: indicator
- pine_id: PUB;2bd0b3f475e44e52b28838e0618600d0
- version: 1.0

## Description

█ OVERVIEW
The CHoCH Anchored VWAP indicator automatically detects changes in market character (CHoCH) across six different pivot lengths simultaneously and uses them as anchoring points for VWAP.
After each detected CHoCH, VWAP is reset and calculated from the moment of confirmed market structure break. Standard deviation bands (SD 1–3) are plotted around it with gradient fills.
This allows the indicator to reflect the current “fair value” and deviation range within a new market regime, instead of relying on arbitrary or delayed anchor points.

█ CONCEPTS
This indicator is designed for traders using Smart Money Concepts (SMC) and ICT methodologies. Its main goal is to solve a common issue with traditional VWAPs — arbitrary or delayed anchoring.

Standard VWAPs are calculated from the start of a session, a manually selected point, or a pivot. Each approach has limitations:
* the starting point is not directly tied to current market structure
* pivot-based VWAP introduces delay, as pivots are confirmed only after several candles and then plotted retroactively

In this indicator, the anchor point is derived directly from price action and real structural changes.

CHoCH (Change of Character)
CHoCH represents a break in the current market structure where control shifts from one side of the market to the other.
The indicator detects these events across six different pivot lengths, allowing it to capture:
* short-term structural shifts
* more significant higher-timeframe reversals

A CHoCH is only generated when a structural break occurs in the opposite direction of the previous market bias.

Anchored VWAP reset on CHoCH
Instead of anchoring VWAP at arbitrary or delayed points, the indicator starts its calculation exactly at the moment of a confirmed structural break.
The anchor:
* appears on the current candle (no backplotting)
* does not use future data
* reflects the actual moment of control shift

As a result, VWAP represents the average price of participants operating within the new market structure, rather than a mix of old and new conditions.

SD Bands (1–3)
Standard deviation bands are calculated relative to the VWAP anchored in the new market regime.
They show:
* the normal range of price movement
* equilibrium levels (around VWAP)
* potential extremes (SD 2–3)

This makes it easier to identify both mean reversion opportunities and trend continuation after pullbacks.

█ FEATURES
1. CHoCH
* Pivot Length 1–6 – six independent pivot lengths (default: 10, 10, 15, 20, 30, 50)
* Show CHoCH Labels – optional labels displaying the pivot length that triggered CHoCH
* CHoCH Up / Down colors

2. VWAP & SD Bands
* Show Anchored VWAP – toggle VWAP line visibility
* Show SD Bands – toggle SD bands (1–3)
* 1 / 2 / 3 SD Multiplier – standard deviation multipliers
* Use candle range instead of volume – mode for markets without volume

3. Colors & Transparency
* Separate base colors for upper and lower SD bands
* Independent transparency for each SD level (1–3)
* Gradient fills between VWAP and SD bands (3 intensity levels)

4. Visualization
* Gradient fills between VWAP and SD bands
* Automatic CHoCH labels on each reset (with pivot length)
* Clear color coding for CHoCH Up (green) and CHoCH Down (red)

5. Alerts
* Alertcondition for CHoCH Up and CHoCH Down
* Real-time alert support

█ APPLICATIONS
The indicator is particularly useful in the following scenarios:

1. Trading in the direction of the new structure
In an uptrend: CHoCH Up + price above VWAP creates a bullish context.
In a downtrend: CHoCH Down + price below VWAP works analogously.

VWAP acts as a dynamic average price for the new market structure and can be used as a reference point when looking for entries in the direction of the trend.

2. Identifying fair value and deviations
SD bands show how far price deviates from the new volume-weighted average.
This helps to:
* identify equilibrium zones (around VWAP)
* assess whether price is within a normal range or at an extreme

For example: if price reaches higher deviations (e.g., SD2–SD3) and a reaction appears, a move back toward VWAP can be considered.

3. Confluence with other tools
The indicator works well as part of a confluence-based approach with other technical tools.
For example:
* in an uptrend, price tests VWAP and reacts upward
* at the same time, a momentum indicator shows bullish strength
→ this may provide a basis for considering a long position

4. Position management
After a CHoCH appears, the indicator provides volatility context through SD bands.
Possible use cases:
* using SD levels as reference Take Profit targets
* using VWAP or structure as a reference for Stop Loss

This allows position management decisions to be based on current market structure rather than fixed levels.

█ NOTES
* Smaller Pivot Length → more signals (higher sensitivity)
* Larger Pivot Length → fewer but stronger structural shifts
* On markets without volume, the “Use candle range” option replaces volume with candle range

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Uncle_the_shooter

//@version=6
indicator('CHoCH Anchored VWAP', overlay = true)

// CHoCH INPUTS
p1 = input.int(10, 'Pivot Length 1', minval = 1, group = 'CHoCH')
p2 = input.int(10, 'Pivot Length 2', minval = 1, group = 'CHoCH')
p3 = input.int(15, 'Pivot Length 3', minval = 1, group = 'CHoCH')
p4 = input.int(20, 'Pivot Length 4', minval = 1, group = 'CHoCH')
p5 = input.int(30, 'Pivot Length 5', minval = 1, group = 'CHoCH')
p6 = input.int(50, 'Pivot Length 6', minval = 1, group = 'CHoCH')
show_choch_label = input.bool(false, 'Show CHoCH Labels', group = 'CHoCH')
choch_up_color = input.color(#26a69a, 'CHoCH Up Color', group = 'CHoCH')
choch_dn_color = input.color(#ef5350, 'CHoCH Down Color', group = 'CHoCH')

// VWAP + SD BANDS INPUTS
group_vwap = 'VWAP & SD Bands'

show_vwap = input.bool(true, 'Show Anchored VWAP', group = group_vwap)
vwap_color = input.color(color.rgb(145, 145, 145), 'VWAP Color', group = group_vwap)
show_bands = input.bool(true, 'Show SD Bands', group = group_vwap)

sd1_mult = input.float(1.0, '1 SD Multiplier', step = 0.1, group = group_vwap)
sd2_mult = input.float(2.0, '2 SD Multiplier', step = 0.1, group = group_vwap)
sd3_mult = input.float(3.0, '3 SD Multiplier', step = 0.1, group = group_vwap)

use_candle_range = input.bool(false, 'Use candle range (high-low) instead of volume', group = group_vwap, 
     tooltip = 'On markets without volume data, this option allows the indicator to function correctly by replacing volume with the candle range (high-low).')

// SD BANDS – COLORS & TRANSPARENCY
group_bands_style = 'SD Bands - Gradient & Colors'

// Base colors for SD lines
band1_color_up = input.color(#26a69a, '1 SD Upper – Base Color', group = group_bands_style)
band1_color_dn = input.color(#ef5350, '1 SD Lower – Base Color', group = group_bands_style)

band2_color_up = input.color(#26a69a, '2 SD Upper – Base Color', group = group_bands_style)
band2_color_dn = input.color(#ef5350, '2 SD Lower – Base Color', group = group_bands_style)

band3_color_up = input.color(#26a69a, '3 SD Upper – Base Color', group = group_bands_style)
band3_color_dn = input.color(#ef5350, '3 SD Lower – Base Color', group = group_bands_style)

// Transparency of SD lines
sd1_trans = input.int(90, '1 SD Line Transparency', minval = 0, maxval = 100, group = group_bands_style)
sd2_trans = input.int(75, '2 SD Line Transparency', minval = 0, maxval = 100, group = group_bands_style)
sd3_trans = input.int(60, '3 SD Line Transparency', minval = 0, maxval = 100, group = group_bands_style)

// GRADIENT FILLS between SD lines
show_gradient_fill = input.bool(true, 'Show gradient fill between SD lines', group = group_bands_style)

fill_trans_vwap_1 = input.int(90, 'Gradient VWAP → 1 SD (strongest)', minval = 0, maxval = 100, group = group_bands_style)
fill_trans_1_2   = input.int(75, 'Gradient 1 SD → 2 SD', minval = 0, maxval = 100, group = group_bands_style)
fill_trans_2_3   = input.int(60, 'Gradient 2 SD → 3 SD (lightest)', minval = 0, maxval = 100, group = group_bands_style)

// BROKEN LEVELS + DIRECTIONS
var array<float> broken_highs1 = array.new_float()
var array<float> broken_lows1 = array.new_float()
var array<float> broken_highs2 = array.new_float()
var array<float> broken_lows2 = array.new_float()
var array<float> broken_highs3 = array.new_float()
var array<float> broken_lows3 = array.new_float()
var array<float> broken_highs4 = array.new_float()
var array<float> broken_lows4 = array.new_float()
var array<float> broken_highs5 = array.new_float()
var array<float> broken_lows5 = array.new_float()
var array<float> broken_highs6 = array.new_float()
var array<float> broken_lows6 = array.new_float()

var int last_dir1 = 0
var int last_dir2 = 0
var int last_dir3 = 0
var int last_dir4 = 0
var int last_dir5 = 0
var int last_dir6 = 0

// FUNCTION – CHoCH detection
f_choch(length, b_highs, b_lows, last_dir) =>
    p_high = ta.pivothigh(high, length, length)
    p_low  = ta.pivotlow (low,  length, length)
   
    var float last_high = na
    var float last_low  = na
   
    if not na(p_high)
        last_high := p_high
    if not na(p_low)
        last_low  := p_low
   
    bool raw_cross_up   = ta.crossover(close, nz(last_high))
    bool raw_cross_down = ta.crossunder(close, nz(last_low))
   
    bool cross_up   = not na(last_high) and raw_cross_up
    bool cross_down = not na(last_low)  and raw_cross_down
   
    bool bos_up   = cross_up   and not array.includes(b_highs, last_high)
    bool bos_down = cross_down and not array.includes(b_lows,  last_low)
   
    bool choch_up   = bos_up   and last_dir == -1
    bool choch_down = bos_down and last_dir == 1
   
    int new_dir = last_dir
    if bos_up
        array.push(b_highs, last_high)
        new_dir := 1
    if bos_down
        array.push(b_lows, last_low)
        new_dir := -1
   
    [choch_up, choch_down, new_dir]

// Multi CHoCH detection
[cu1, cd1, nd1] = f_choch(p1, broken_highs1, broken_lows1, last_dir1)
[cu2, cd2, nd2] = f_choch(p2, broken_highs2, broken_lows2, last_dir2)
[cu3, cd3, nd3] = f_choch(p3, broken_highs3, broken_lows3, last_dir3)
[cu4, cd4, nd4] = f_choch(p4, broken_highs4, broken_lows4, last_dir4)
[cu5, cd5, nd5] = f_choch(p5, broken_highs5, broken_lows5, last_dir5)
[cu6, cd6, nd6] = f_choch(p6, broken_highs6, broken_lows6, last_dir6)

last_dir1 := nd1
last_dir2 := nd2
last_dir3 := nd3
last_dir4 := nd4
last_dir5 := nd5
last_dir6 := nd6

choch_up   = cu1 or cu2 or cu3 or cu4 or cu5 or cu6
choch_down = cd1 or cd2 or cd3 or cd4 or cd5 or cd6

// DETERMINING WHICH PIVOT TRIGGERED THE CHoCH (for labels)
int   choch_pivot_len = na
string choch_label_txt = na

if cu1 or cd1
    choch_pivot_len := p1
else if cu2 or cd2
    choch_pivot_len := p2
else if cu3 or cd3
    choch_pivot_len := p3
else if cu4 or cd4
    choch_pivot_len := p4
else if cu5 or cd5
    choch_pivot_len := p5
else if cu6 or cd6
    choch_pivot_len := p6

if not na(choch_pivot_len)
    choch_label_txt := "CHoCH " + str.tostring(choch_pivot_len)

// ANCHORED VWAP + SD BANDS (reset on every CHoCH)
float weight = use_candle_range ? math.max(high - low, syminfo.mintick) : volume
var int   anchor_bar   = na
var float sum_tp_vol   = 0.0
var float sum_vol      = 0.0
var float sum_p2_vol   = 0.0

if choch_up or choch_down
    anchor_bar   := bar_index
    sum_tp_vol   := hlc3 * weight
    sum_vol      := weight
    sum_p2_vol   := math.pow(hlc3, 2) * weight
   
    // Label with pivot length
    if show_choch_label and not na(choch_label_txt)
        label.new(bar_index, choch_up ? low : high, choch_label_txt,
                  style = choch_up ? label.style_label_up : label.style_label_down,
                  color = color.new(choch_up ? choch_up_color : choch_dn_color, 20),
                  textcolor = color.white, size = size.small)
else if not na(anchor_bar)
    sum_tp_vol += hlc3 * weight
    sum_vol    += weight
    sum_p2_vol += math.pow(hlc3, 2) * weight

anchored_vwap = not na(anchor_bar) ? sum_tp_vol / sum_vol : na
variance      = not na(anchor_bar) ? (sum_p2_vol / sum_vol) - math.pow(anchored_vwap, 2) : na
stdev         = not na(anchor_bar) ? math.sqrt(variance) : na

band1_up = anchored_vwap + stdev * sd1_mult
band1_dn = anchored_vwap - stdev * sd1_mult
band2_up = anchored_vwap + stdev * sd2_mult
band2_dn = anchored_vwap - stdev * sd2_mult
band3_up = anchored_vwap + stdev * sd3_mult
band3_dn = anchored_vwap - stdev * sd3_mult

// PLOTTING
p_vwap     = plot(show_vwap ? anchored_vwap : na, title = "CHoCH Anchored VWAP",     color = vwap_color, linewidth = 2)

p_vwap_fill = plot(anchored_vwap, title = "Hidden VWAP for fills", color = na, display = display.none)

p_band1_up = plot(show_bands ? band1_up : na, title = "+1 SD", color = color.new(band1_color_up, sd1_trans), linewidth = 1)
p_band1_dn = plot(show_bands ? band1_dn : na, title = "-1 SD", color = color.new(band1_color_dn, sd1_trans), linewidth = 1)
p_band2_up = plot(show_bands ? band2_up : na, title = "+2 SD", color = color.new(band2_color_up, sd2_trans), linewidth = 1)
p_band2_dn = plot(show_bands ? band2_dn : na, title = "-2 SD", color = color.new(band2_color_dn, sd2_trans), linewidth = 1)
p_band3_up = plot(show_bands ? band3_up : na, title = "+3 SD", color = color.new(band3_color_up, sd3_trans), linewidth = 1)
p_band3_dn = plot(show_bands ? band3_dn : na, title = "-3 SD", color = color.new(band3_color_dn, sd3_trans), linewidth = 1)

// GRADIENT FILLS
fill(p_vwap_fill, p_band1_up, color = (show_bands and show_gradient_fill) ? color.new(band1_color_up, fill_trans_vwap_1) : na, title = "Gradient VWAP-1SD Up")
fill(p_band1_up, p_band2_up, color = (show_bands and show_gradient_fill) ? color.new(band2_color_up, fill_trans_1_2)   : na, title = "Gradient 1-2SD Up")
fill(p_band2_up, p_band3_up, color = (show_bands and show_gradient_fill) ? color.new(band3_color_up, fill_trans_2_3)   : na, title = "Gradient 2-3SD Up")

fill(p_vwap_fill, p_band1_dn, color = (show_bands and show_gradient_fill) ? color.new(band1_color_dn, fill_trans_vwap_1) : na, title = "Gradient VWAP-1SD Dn")
fill(p_band1_dn, p_band2_dn, color = (show_bands and show_gradient_fill) ? color.new(band2_color_dn, fill_trans_1_2)   : na, title = "Gradient 1-2SD Dn")
fill(p_band2_dn, p_band3_dn, color = (show_bands and show_gradient_fill) ? color.new(band3_color_dn, fill_trans_2_3)   : na, title = "Gradient 2-3SD Dn")

// ALERTS
alertcondition(choch_up,   title = "CHoCH ↑",   message = "CHoCH Up - Bullish structure broken")
alertcondition(choch_down, title = "CHoCH ↓",   message = "CHoCH Down - Bearish structure broken")
````
