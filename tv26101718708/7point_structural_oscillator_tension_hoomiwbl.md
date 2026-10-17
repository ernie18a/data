# 7-Point Structural Oscillator [Tension]

- url: https://www.tradingview.com/script/HoOmIwBl-7-Point-Structural-Oscillator-Tension/
- type: indicator
- pine_id: PUB;b241537393264229a8bfc33a474c4b97
- version: 1.0

## Description

[b]Technical Description[/b]
The 7-Point Structural Oscillator is a market geometry indicator that quantifies price deviation from established structural lattice points. It measures structural tension—the net displacement of current price relative to seven critical coordinate pairs in the price-time manifold.

[b]Mathematical Foundation[/b]
The oscillator constructs a 7-dimensional reference frame from swing mechanics:
1. PSH (Previous Swing High): Price and temporal coordinates of the last confirmed pivot peak
2. CSH (Current Swing High): Most recent pivot peak
3. PSL (Previous Swing Low): Last confirmed pivot trough
4. CSL (Current Swing Low): Most recent pivot trough
5. PT5 (Inter-Low Maximum): Highest price point between CSL and PSL (local resistance within the swing range)
6. PT6 (Inter-High Minimum): Lowest price point between CSH and PSH (local support within the swing range)
7. PT7 (Structural Midpoint): Arithmetic mean of PT5 and PT6, representing the equilibrium plane between local extremes

[b]Tension Calculation[/b]
Where ￼ is current price (close) and ￼ represents the seven structural coordinates.
Positive tension indicates price trading above the structural centroid (bullish structural dominance); negative tension indicates trading below (bearish structural dominance). The magnitude represents the strength of deviation from equilibrium.

￼
[b]User Guide[/b]
[i][b]Inputs[/b][/i]
 • Swing Length (default: 10): The lookback period for pivot detection. Higher values capture major structural points (higher timeframes); lower values capture microstructure (lower timeframes).
 • Show Data Table: Toggle visibility of coordinate reference table (if implemented in future versions).
Interpretation
Zero Line Crossings
 • Bullish signal: Tension crosses above zero (price breaks through structural equilibrium to the upside)
 • Bearish signal: Tension crosses below zero (price breaks through structural equilibrium to the downside)
Extreme Readings
 • High positive values (> historical 90th percentile): Price extended far above structure, potential mean-reversion or resistance confluence
 • High negative values (< historical 10th percentile): Price extended far below structure, potential oversold or support confluence
Divergence Analysis
 • Price makes higher high + Tension makes lower high = Structural weakness (potential reversal)
 • Price makes lower low + Tension makes higher low = Structural accumulation (potential bounce)

[b]Best Practices[/b]
1. Multi-Timeframe Confirmation: Use swing length 10 on higher timeframe to establish major structure, swing length 5 on current timeframe for entry timing.
2. Confluence with Price Action: When tension approaches zero, watch for doji/pin bar formations at PT5/PT6 levels—this indicates market indecision at calculated structural boundaries.
3. Trend Strength: Sustained positive tension with increasing magnitude suggests strong trending environment; oscillation around zero suggests ranging/choppy conditions.
4. Volume Context: (If combining with volume tools) High volume breaking through PT5 or PT6 validates structural breaks; low volume suggests false breaks.
Limitations
 • Pivot-based systems inherently lag by swing_len bars
 • Point 5 and 6 calculations use highest/lowest functions within inter-swing windows; in volatile conditions with multiple intermediate pivots, these represent the extremes, not necessarily the first touch point
 • Designed for markets with clear swing structure (equities, forex, crypto); less effective in parabolic or illiquid conditions

## Source Code

````pine
//@version=5
indicator("7-Point Structural Oscillator [Tension]", overlay=false)

// --- INPUTS ---
swing_len = input.int(7, "Swing Length", minval=3)
show_table = input.bool(true, "Show Data Table")

// --- 1. IDENTIFY SWING POINTS ---
// We use pivot highs and lows to determine structure
ph = ta.pivothigh(high, swing_len, 1)
pl = ta.pivotlow(low, swing_len, 1)

// --- 2. STORAGE VARIABLES (State Management) ---
// We need to store historical coordinates (Price and Bar Index)
var float csh_price = na, var int csh_idx = na // Current Swing High
var float psh_price = na, var int psh_idx = na // Previous Swing High
var float csl_price = na, var int csl_idx = na // Current Swing Low
var float psl_price = na, var int psl_idx = na // Previous Swing Low

// Update Logic for Highs
if not na(ph)
    psh_price := csh_price
    psh_idx := csh_idx
    csh_price := high[swing_len]
    csh_idx := bar_index[swing_len]

// Update Logic for Lows
if not na(pl)
    psl_price := csl_price
    psl_idx := csl_idx
    csl_price := low[swing_len]
    csl_idx := bar_index[swing_len]

// --- 3. CALCULATE INTERMEDIATE POINTS ---
// Point 5: Highest point between Current and Previous Swing Low
// We look at the range between psl_idx and csl_idx
// If the indices are valid, we scan that window.
get_high_between(start_idx, end_idx) =>
    float highest_val = -1.0e10
    if not na(start_idx) and not na(end_idx) and end_idx > start_idx
        len = end_idx - start_idx
        // Use highest from the offset of the current bar back to the end_idx
        // This is tricky in real-time, simpler to approx using known CSH logic or scan
        // Since we are usually at live price, we look back.
        // Simplified: The Highest point between two lows is usually the Swing High in between.
        // However, to be precise to your request, we calculate it dynamically:
        highest_val := high
        for i = 0 to (bar_index - start_idx)
            if bar_index[i] <= end_idx and bar_index[i] >= start_idx
                if high[i] > highest_val
                    highest_val := high[i]
    highest_val

// Point 6: Lowest point between Current and Previous Swing High
get_low_between(start_idx, end_idx) =>
    float lowest_val = 1.0e10
    if not na(start_idx) and not na(end_idx) and end_idx > start_idx
        for i = 0 to (bar_index - start_idx)
            if bar_index[i] <= end_idx and bar_index[i] >= start_idx
                if low[i] < lowest_val
                    lowest_val := low[i]
    lowest_val

// To save performance, we only scan when structure exists
// Note: Determining the "Between" points precisely requires iteration or assuming the intermediate swing is the extreme.
// For strict adherence to "Between Current and Previous":
float pt5_price = na // Highest between Lows
float pt6_price = na // Lowest between Highs

// We approximate the range by looking back from current bar to the Previous Swing Index
// This is heavy calculation, so we limit lookback or assume the stored CSH/CSL acts as the proxy often.
// However, let's implement the specific logic:
if not na(psl_idx) and not na(csl_idx)
    pt5_price := 0.0
    // The range is between the two pivot occurrences
    dist = csl_idx - psl_idx
    if dist > 0
        // The high occurred 'dist' bars ago relative to the CSL
        // We need the offset from current bar: (bar_index - csl_idx)
        current_offset = bar_index - csl_idx
        // Look back from CSL to PSL
        pt5_price := ta.highest(high, dist)[current_offset]

if not na(psh_idx) and not na(csh_idx)
    pt6_price := 1000000.0
    dist = csh_idx - psh_idx
    if dist > 0
        current_offset = bar_index - csh_idx
        pt6_price := ta.lowest(low, dist)[current_offset]

// Point 7: Midpoint of 5 and 6
pt7_price = (pt5_price + pt6_price) / 2

// --- 4. CALCULATE DISTANCE & TIME ---
// Current Price
cp = close
curr_bar = bar_index

// Helper to calc distance
calc_diff(target) => na(target) ? 0 : cp - target
calc_time(target_idx) => na(target_idx) ? 0 : curr_bar - target_idx

// Prices
d1 = calc_diff(psh_price)
d2 = calc_diff(csh_price)
d3 = calc_diff(psl_price)
d4 = calc_diff(csl_price)
d5 = calc_diff(pt5_price)
d6 = calc_diff(pt6_price)
d7 = calc_diff(pt7_price)

// --- 5. THE OSCILLATOR (Structural Tension) ---
// We average the price distances to see if we are net far or net close to structure
tension = (d1 + d2 + d3 + d4 + d5 + d6 + d7) / 7

plot(tension, color=tension > 0 ? color.teal : color.red, style=plot.style_columns, title="Structural Tension")
hline(0, "Equilibrium", color.gray)
````
