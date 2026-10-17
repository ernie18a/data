# Reversal & Continuation Index

- url: https://www.tradingview.com/script/Q5G2PHoy-Reversal-Continuation-Index/
- type: indicator
- pine_id: PUB;cdc5375d0bb146dea29fa6812b290f2a
- version: 2.0

## Description

$$I. OVERVIEW AND OBJECTIVE$$

The Reversal & Continuation Index (RCI) is a dual-engine Digital Signal Processing (DSP) tool designed to simultaneously measure two conflicting market forces: macro-level directional persistence and micro-level kinematic snapbacks.

Traditional oscillators often blend short-term momentum and long-term trend into a single output, resulting in a loss of nuance. The RCI architecture separates these elements, providing a clear structural wave (Continuation) overlaid with a highly responsive signal blade (Reversion) to identify high-probability turning points.


The Mechanism: The CI acts as the foundational structural anchor of the indicator. It measures the long-range efficiency of the market.

The Math: It calculates the net price displacement over a macro lookback period (default 34 bars) and divides it by the total absolute path distance traveled in that same period. This efficiency ratio is then smoothed via a Weighted Moving Average (default 5 bars) to eliminate micro-structural noise.

Interpretation:

Onset (Accelerating): When the absolute value of the CI is expanding, directional persistence is increasing. The trend is structurally sound and accelerating (visualized by bright green or bright red fills).

Exhaustion (Decelerating): When the absolute value of the CI is contracting, the trend's directional efficiency is mathematically decaying, even if the price is still slowly grinding in the trend's direction. This is an early warning of structural weakness (visualized by darker, muted colors).



The Mechanism: The RI acts as the fast, piercing kinematic blade. It operates on the same mathematical foundation as the CI but measures acute bar-to-bar snapbacks over a much tighter window (default 9 bars) without any artificial smoothing.

The Math: It normalizes the short-term sum of price differences by the absolute sum of those differences, bounding the result strictly between -100 and +100.

Interpretation: The RI identifies overextended, short-term kinematic momentum. It whips rapidly between extremes, highlighting the exact moments when acute price momentum is overbought or oversold.



The true power of the RCI lies in the convergence of its two independent indices. The indicator does not generate signals based purely on overbought/oversold levels, but rather on the interaction between macro exhaustion and micro reversion.

Bullish Convergence Reversal:
Occurs when the macro Bearish Trend enters a state of Exhaustion (the negative CI wave begins contracting toward zero), AND the fast Reversion Index simultaneously crosses above the zero line. This indicates that the long-term selling pressure is mathematically exhausted just as short-term momentum shifts bullish.

Bearish Convergence Reversal:
Occurs when the macro Bullish Trend enters a state of Exhaustion (the positive CI wave begins contracting toward zero), AND the fast Reversion Index simultaneously crosses below the zero line. This indicates that the long-term buying pressure is mathematically exhausted just as short-term momentum shifts bearish.

$$V. CONCLUSION$$

The Reversal & Continuation Index moves beyond basic momentum tracking. By explicitly tokenizing when a macro trend loses its directional persistence and timing the entry with a short-term kinematic fracture, the RCI provides a rigorous framework for identifying institutional phase shifts.

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// Extracted and Architected by THE ALPHA COUNCIL
//@version=6
indicator("Reversal & Continuation Index [Alpha Council]", "RCI DSP", overlay = false)

//---------------------------------------------------------------------------------------------------------------------}
// Constants & Topography
//---------------------------------------------------------------------------------------------------------------------{
color COLOR_BULL_ON  = #00FF00 // Trend Onset (Accelerating Persistence)
color COLOR_BULL_EX  = #089981 // Trend Exhaustion (Decelerating Persistence)
color COLOR_BEAR_ON  = #FF0000 // Bear Onset (Accelerating Negative Persistence)
color COLOR_BEAR_EX  = #f23645 // Bear Exhaustion (Decelerating Negative Persistence)
color COLOR_NEUTRAL  = color.gray

//---------------------------------------------------------------------------------------------------------------------}
// Inputs & Optimal Defaults
//---------------------------------------------------------------------------------------------------------------------{
int   riLengthInput  = input.int(9,  "Reversion Index Length (Short-Term)", minval=2, group="Kinematic Parameters", tooltip="Optimal Default: 9. Measures acute bar-to-bar snapbacks for short-term reversal timing.")
int   ciLengthInput  = input.int(34, "Continuation Index Length (Macro)", minval=10, group="Structural Parameters", tooltip="Optimal Default: 34. Measures broad directional persistence to track onset and exhaustion.")
int   ciSmoothInput  = input.int(5,  "Continuation Smoothing", minval=1, group="Structural Parameters", tooltip="Optimal Default: 5. Applies a Weighted Moving Average to smooth out microstructure noise in the macro index.")

float extLevelInput  = input.float(40.0, "Reversal Extension Threshold (CI)", group="Signal Filters", tooltip="CI must exceed this absolute value for a REV signal to trigger. Filters out chop.")
float divLevelInput  = input.float(40.0, "Divergence Extreme Threshold (RI)", group="Signal Filters", tooltip="RI must exceed this absolute value on the previous pivot to register a DIV.")
int   debounceInput  = input.int(8,      "Signal Debounce (Bars)", minval=1, group="Signal Filters", tooltip="Prevents consecutive onset triangles from clustering too closely.")

//---------------------------------------------------------------------------------------------------------------------}
// BASE KINEMATICS: 1st Derivative (Bar-to-Bar Delta)
//---------------------------------------------------------------------------------------------------------------------{
float diff = close - nz(close[1], close)
float abs_diff = math.abs(diff)

//---------------------------------------------------------------------------------------------------------------------}
// REVERSION INDEX (RI): The Fast Kinematic Blade
//---------------------------------------------------------------------------------------------------------------------{
// Normalizes the short-term sum of differences by the total path distance (Absolute sum)
float ri_net_move = math.sum(diff, riLengthInput)
float ri_tot_move = math.sum(abs_diff, riLengthInput)

// Bounds to [-100, 100]
float ri = ri_tot_move == 0 ? 0.0 : (ri_net_move / ri_tot_move) * 100.0

//---------------------------------------------------------------------------------------------------------------------}
// CONTINUATION INDEX (CI): Macro Directional Persistence
//---------------------------------------------------------------------------------------------------------------------{
// Measures long-range efficiency and directional persistence
float ci_net_move = close - nz(close[ciLengthInput], close)
float ci_tot_move = math.sum(abs_diff, ciLengthInput)
float raw_ci = ci_tot_move == 0 ? 0.0 : (ci_net_move / ci_tot_move) * 100.0

// Smooth the macro persistence to isolate the true structural wave
float ci = ta.wma(raw_ci, ciSmoothInput)

//---------------------------------------------------------------------------------------------------------------------}
// Topological State Routing (Onset vs Exhaustion)
//---------------------------------------------------------------------------------------------------------------------{
// Is the persistence expanding or contracting?
bool is_bullish = ci > 0
bool is_bearish = ci < 0
bool is_expanding = math.abs(ci) > math.abs(nz(ci[1]))

// Tokenize the structural phase
color ci_color = COLOR_NEUTRAL
color ci_fill  = color.new(COLOR_NEUTRAL, 80)

if is_bullish and is_expanding
    ci_color := COLOR_BULL_ON
    ci_fill  := color.new(COLOR_BULL_ON, 70)
else if is_bullish and not is_expanding
    ci_color := COLOR_BULL_EX
    ci_fill  := color.new(COLOR_BULL_EX, 50)
else if is_bearish and is_expanding
    ci_color := COLOR_BEAR_ON
    ci_fill  := color.new(COLOR_BEAR_ON, 70)
else if is_bearish and not is_expanding
    ci_color := COLOR_BEAR_EX
    ci_fill  := color.new(COLOR_BEAR_EX, 50)

//---------------------------------------------------------------------------------------------------------------------}
// Visuals & Rendering Matrix
//---------------------------------------------------------------------------------------------------------------------{
// Plot Structural CI Wave
plot_ci = plot(ci, title="Continuation Index (Macro Persistence)", color=ci_color, linewidth=2, style=plot.style_line)
plot_zero = plot(0, display=display.none)
fill(plot_ci, plot_zero, color=ci_fill, title="CI Topological Fill")

// Plot Fast RI Blade
color ri_color = ri >= 0 ? color.new(COLOR_BULL_ON, 0) : color.new(COLOR_BEAR_ON, 0)
plot(ri, title="Reversion Index (Short-Term Reversal)", color=color.new(color.white, 30), linewidth=1, style=plot.style_line)

// Extremity Boundary Lines
hline( 70, "Over-Persistent (Bullish)", color=color.new(COLOR_BULL_EX, 50), linestyle=hline.style_dashed)
hline(-70, "Over-Persistent (Bearish)", color=color.new(COLOR_BEAR_EX, 50), linestyle=hline.style_dashed)
hline(  0, "Zero Line",                 color=color.new(COLOR_NEUTRAL, 50), linestyle=hline.style_dotted)

//---------------------------------------------------------------------------------------------------------------------}
// Divergence & Kinematic Interaction Engine (FILTERED & DEBOUNCED)
//---------------------------------------------------------------------------------------------------------------------{
// 1. Continuation Confirmation (Onset / Momentum Push)
bool raw_bull_push = ta.crossover(ri, ci) and ci > 0 and is_expanding
bool raw_bear_push = ta.crossunder(ri, ci) and ci < 0 and is_expanding

// Temporal Debouncing to prevent triangle clustering
var int last_bull_push = 0
var int last_bear_push = 0

bool bull_onset_push = raw_bull_push and (bar_index - last_bull_push > debounceInput)
bool bear_onset_push = raw_bear_push and (bar_index - last_bear_push > debounceInput)

if bull_onset_push
    last_bull_push := bar_index
if bear_onset_push
    last_bear_push := bar_index

// 2. Structural Divergence Detection (Price vs Reversion Index)
int lb = 5
int rb = 5
float ph = ta.pivothigh(high, lb, rb)
float pl = ta.pivotlow(low, lb, rb)

var float prev_ph_price = na
var float prev_ph_ri    = na
var float prev_pl_price = na
var float prev_pl_ri    = na

bool bear_div = false
bool bull_div = false

if not na(ph)
    // Amplitude Gate: Only valid if the previous momentum push was actually overbought
    if ph > prev_ph_price and ri[rb] < prev_ph_ri and prev_ph_ri > divLevelInput
        bear_div := true
    prev_ph_price := ph
    prev_ph_ri    := ri[rb]

if not na(pl)
    // Amplitude Gate: Only valid if the previous momentum push was actually oversold
    if pl < prev_pl_price and ri[rb] > prev_pl_ri and prev_pl_ri < -divLevelInput
        bull_div := true
    prev_pl_price := pl
    prev_pl_ri    := ri[rb]

//---------------------------------------------------------------------------------------------------------------------}
// Main Chart Overlay Signals (Projected from Sub-pane via force_overlay)
//---------------------------------------------------------------------------------------------------------------------{
// A true reversal occurs when the macro trend exhausts (from an extreme state), and the fast RI crosses zero against it.
bool bearish_reversal = (ci > extLevelInput and not is_expanding) and ta.crossunder(ri, 0)
bool bullish_reversal = (ci < -extLevelInput and not is_expanding) and ta.crossover(ri, 0)

plotshape(bullish_reversal, title="Bullish Convergence", text="REV", style=shape.labelup,   location=location.belowbar, color=COLOR_BULL_ON, textcolor=color.white, size=size.small, force_overlay=true)
plotshape(bearish_reversal, title="Bearish Convergence", text="REV", style=shape.labeldown, location=location.abovebar, color=COLOR_BEAR_ON, textcolor=color.white, size=size.small, force_overlay=true)

plotshape(bull_onset_push, title="Bullish Onset Push", style=shape.triangleup, location=location.belowbar, color=COLOR_BULL_EX, size=size.small, force_overlay=true)
plotshape(bear_onset_push, title="Bearish Onset Push", style=shape.triangledown, location=location.abovebar, color=COLOR_BEAR_EX, size=size.small, force_overlay=true)

// Offset by -rb so the divergence shape mathematically aligns over the true pivot on the main chart
plotshape(bull_div, title="Bullish Divergence", text="DIV", style=shape.labelup, location=location.belowbar, color=color.new(COLOR_BULL_ON, 30), textcolor=color.white, size=size.small, offset=-rb, force_overlay=true)
plotshape(bear_div, title="Bearish Divergence", text="DIV", style=shape.labeldown, location=location.abovebar, color=color.new(COLOR_BEAR_ON, 30), textcolor=color.white, size=size.small, offset=-rb, force_overlay=true)

//---------------------------------------------------------------------------------------------------------------------}
// Algorithmic Alert Conditions (Convergent Exhaustion Events)
//---------------------------------------------------------------------------------------------------------------------{
alertcondition(bullish_reversal, title="Bullish Convergence Reversal", message="Macro Bearish Trend is exhausting. Short-term Reversion Index has flipped positive.")
alertcondition(bearish_reversal, title="Bearish Convergence Reversal", message="Macro Bullish Trend is exhausting. Short-term Reversion Index has flipped negative.")

alertcondition(bull_div, title="Bullish Divergence", message="Price made a lower low, but the Reversion Index made a higher low.")
alertcondition(bear_div, title="Bearish Divergence", message="Price made a higher high, but the Reversion Index made a lower high.")
//---------------------------------------------------------------------------------------------------------------------}
````
