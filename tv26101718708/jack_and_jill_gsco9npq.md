# Jack and Jill 

- url: https://www.tradingview.com/script/GscO9nPq-Jack-and-Jill/
- type: indicator
- pine_id: PUB;ec81320cbcb04581a0190dc0f1fe22a3
- version: 1.0

## Description

I. LIMITATIONS OF TRADITIONAL MOVING AVERAGES

Traditional moving averages (SMA, EMA, WMA) serve as foundational market tools, but they exhibit specific mathematical constraints when applied to highly volatile data:

Lag: By inherently averaging historical data, they naturally trail the current market state.

Aliasing (Cyclic Contamination): They often struggle to distinguish between underlying macro trends and temporary cyclical market waves, which can result in whipsaws and delayed signals.

To address these challenges and more accurately model continuous-time price movement, advanced Digital Signal Processing (DSP) can be deployed as an alternative framework.

II. THE DUAL-STATE SOLUTION

John Ehlers' "Jack and Jill" concept separates the market data into two distinct components. Instead of blending short-term fluctuations and long-term trends into a single average, they are isolated using specialized mathematical models:
► JACK: A fast, low-lag price tracker.
► JILL: A slower trend line, filtered to remove cyclical noise.
III. JACK: THE FAST PRICE TRACKER

The Mechanism: A 2nd-Order Infinite Impulse Response (IIR) SuperSmoother.

The Execution: Jack tracks short-term price movements. By applying a 2nd-order SuperSmoother, Jack efficiently filters out high-frequency noise and erratic intraday price spikes. It follows the price closely with minimal lag, providing a clearer view of the immediate trend direction.

IV. JILL: THE TREND DECYCLER$$

The Mechanism: A 2-Pole High-Pass Decycler coupled with smoothing.

The Execution: Instead of standard averaging, Jill uses a 2-Pole High-Pass filter to identify the market's dominant cycle and subtracts that cyclic data from the price to isolate the broader macroeconomic trend. A half-length SuperSmoother is then applied to stabilize the output, resulting in a smooth baseline that minimizes temporary cyclical fluctuations.

V. THE PHASE CONVERGENCE OSCILLATOR (PCO)
The Mechanism: Momentum Divergence.

The Execution: While Jack and Jill map the spatial topology on the primary chart, the Phase Convergence Oscillator (PCO) operates in a decoupled, isolated matrix. It measures the exact delta (Jack - Jill) and tracks its momentum.

Expanding Delta: The trend is structurally intact and accelerating.

Contracting Delta: Trend momentum is decelerating, which may serve as an early indication of exhaustion before Jack actually crosses Jill.

VI. TOPOLOGICAL GRADIENT RENDERING

The space between Jack and Jill represents the maturity of the trend. The visual matrix applies a 6-stage continuous opacity gradient—highly transparent at the edge of Jack (where price is volatile and untested) and reaching maximum density as it anchors onto Jill (the established structural core).

VII. CONCLUSION
The Jack and Jill indicator is designed as a continuous-time convergence engine rather than a conventional crossover tool. When the PCO accelerates and Jack crosses the structural decycler, a potential phase shift is identified.

This framework represents a rigorous application of signal processing techniques to financial trend analysis.

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// Extracted and Architected by THE ALPHA COUNCIL
//@version=6
indicator("Jack and Jill Structural Trend & PCO [Alpha Council]", "Jack & Jill DSP", overlay = false)

//---------------------------------------------------------------------------------------------------------------------}
// Inputs & Optimal Defaults
//---------------------------------------------------------------------------------------------------------------------{
float src                = input.source(close, "Data Source", group="Global Parameters")

// Overlay Parameters
int   jackLengthInput    = input.int(10, "Overlay: Jack Length (Fast Tracker)", minval=2, group="Overlay DSP Parameters", tooltip="Optimal Default: 10. Controls how tightly Jack hugs the price action on the main chart.")
int   jillLengthInput    = input.int(40, "Overlay: Jill Length (Cyclic Cutoff)", minval=10, group="Overlay DSP Parameters", tooltip="Optimal Default: 40. Controls the dominant cycle cutoff for the main chart overlay.")

// PCO Parameters
int   pcoJackLengthInput = input.int(10, "PCO: Jack Length (Oscillator)", minval=2, group="Oscillator DSP Parameters", tooltip="Decoupled fast length for the Phase Convergence Oscillator in the sub-pane.")
int   pcoJillLengthInput = input.int(40, "PCO: Jill Length (Oscillator)", minval=10, group="Oscillator DSP Parameters", tooltip="Decoupled slow length for the Phase Convergence Oscillator in the sub-pane.")

// Visual & Topological Color Parameters
color COLOR_JACK_BULL    = input.color(#00FF00, "Jack Bullish Color", group="Visual Parameters", inline="Jack")
color COLOR_JACK_BEAR    = input.color(#FF0000, "Jack Bearish Color", group="Visual Parameters", inline="Jack")
color COLOR_JILL         = input.color(color.new(color.gray, 10), "Jill Line Color", group="Visual Parameters")
color COLOR_BASE_BULL    = input.color(#089981, "Gradient Base Bullish", group="Visual Parameters", inline="Base")
color COLOR_BASE_BEAR    = input.color(#f23645, "Gradient Base Bearish", group="Visual Parameters", inline="Base")
string signalSizeInput   = input.string(size.small, "Signal Size", options=[size.tiny, size.small, size.normal, size.large, size.huge, size.auto], group="Visual Parameters")

//---------------------------------------------------------------------------------------------------------------------}
// OVERLAY JACK: The Fast Kinematic Tracker (2nd Order SuperSmoother)
//---------------------------------------------------------------------------------------------------------------------{
float a1_jack = math.exp(-1.414 * math.pi / jackLengthInput)
float b1_jack = 2.0 * a1_jack * math.cos(1.414 * math.pi / jackLengthInput)
float c2_jack = b1_jack
float c3_jack = -a1_jack * a1_jack
float c1_jack = 1.0 - c2_jack - c3_jack

var float jack = na
jack := c1_jack * src + c2_jack * nz(jack[1], src) + c3_jack * nz(jack[2], src)

//---------------------------------------------------------------------------------------------------------------------}
// OVERLAY JILL: The Structural Trend (2-Pole Ehlers Decycler + SuperSmoother)
//---------------------------------------------------------------------------------------------------------------------{
float alpha_hp = (math.cos(0.707 * 2.0 * math.pi / jillLengthInput) + math.sin(0.707 * 2.0 * math.pi / jillLengthInput) - 1.0) / math.cos(0.707 * 2.0 * math.pi / jillLengthInput)

var float hp = na
hp := math.pow(1.0 - alpha_hp / 2.0, 2) * (src - 2.0 * nz(src[1], src) + nz(src[2], src)) + 2.0 * (1.0 - alpha_hp) * nz(hp[1], 0.0) - math.pow(1.0 - alpha_hp, 2) * nz(hp[2], 0.0)

float decycled_price = src - hp

float a1_jill = math.exp(-1.414 * math.pi / (jillLengthInput / 2.0))
float b1_jill = 2.0 * a1_jill * math.cos(1.414 * math.pi / (jillLengthInput / 2.0))
float c2_jill = b1_jill
float c3_jill = -a1_jill * a1_jill
float c1_jill = 1.0 - c2_jill - c3_jill

var float jill = na
jill := c1_jill * decycled_price + c2_jill * nz(jill[1], decycled_price) + c3_jill * nz(jill[2], decycled_price)

//---------------------------------------------------------------------------------------------------------------------}
// PCO DECOUPLED MATRIX: Independent Oscillator Calculations
//---------------------------------------------------------------------------------------------------------------------{
// PCO Jack
float a1_pco_jack = math.exp(-1.414 * math.pi / pcoJackLengthInput)
float b1_pco_jack = 2.0 * a1_pco_jack * math.cos(1.414 * math.pi / pcoJackLengthInput)
float c2_pco_jack = b1_pco_jack
float c3_pco_jack = -a1_pco_jack * a1_pco_jack
float c1_pco_jack = 1.0 - c2_pco_jack - c3_pco_jack

var float pco_jack = na
pco_jack := c1_pco_jack * src + c2_pco_jack * nz(pco_jack[1], src) + c3_pco_jack * nz(pco_jack[2], src)

// PCO Jill
float alpha_hp_pco = (math.cos(0.707 * 2.0 * math.pi / pcoJillLengthInput) + math.sin(0.707 * 2.0 * math.pi / pcoJillLengthInput) - 1.0) / math.cos(0.707 * 2.0 * math.pi / pcoJillLengthInput)

var float hp_pco = na
hp_pco := math.pow(1.0 - alpha_hp_pco / 2.0, 2) * (src - 2.0 * nz(src[1], src) + nz(src[2], src)) + 2.0 * (1.0 - alpha_hp_pco) * nz(hp_pco[1], 0.0) - math.pow(1.0 - alpha_hp_pco, 2) * nz(hp_pco[2], 0.0)

float decycled_price_pco = src - hp_pco

float a1_pco_jill = math.exp(-1.414 * math.pi / (pcoJillLengthInput / 2.0))
float b1_pco_jill = 2.0 * a1_pco_jill * math.cos(1.414 * math.pi / (pcoJillLengthInput / 2.0))
float c2_pco_jill = b1_pco_jill
float c3_pco_jill = -a1_pco_jill * a1_pco_jill
float c1_pco_jill = 1.0 - c2_pco_jill - c3_pco_jill

var float pco_jill = na
pco_jill := c1_pco_jill * decycled_price_pco + c2_pco_jill * nz(pco_jill[1], decycled_price_pco) + c3_pco_jill * nz(pco_jill[2], decycled_price_pco)

//---------------------------------------------------------------------------------------------------------------------}
// Kinematic Tokenization & Structural Logic (Overlay)
//---------------------------------------------------------------------------------------------------------------------{
bool is_jack_bullish = jack > jill
color current_jack_color = is_jack_bullish ? COLOR_JACK_BULL : COLOR_JACK_BEAR
color current_base_color = is_jack_bullish ? COLOR_BASE_BULL : COLOR_BASE_BEAR

bool jack_climbs  = ta.crossover(jack, jill)
bool jack_tumbles = ta.crossunder(jack, jill)

//---------------------------------------------------------------------------------------------------------------------}
// Visuals & Gradient Rendering Matrix (Projected to Main Chart via force_overlay)
//---------------------------------------------------------------------------------------------------------------------{
plot_jack = plot(jack, title="Jack (Kinematic Tracker)", color=current_jack_color, linewidth=2, force_overlay=true)
plot_jill = plot(jill, title="Jill (Structural Decycler)", color=COLOR_JILL, linewidth=3, force_overlay=true)

// Intermediate hidden plots to forge a continuous structural gradient
float diff = jill - jack
plot_s1 = plot(jack + diff * 0.166, display=display.none, editable=false, force_overlay=true)
plot_s2 = plot(jack + diff * 0.333, display=display.none, editable=false, force_overlay=true)
plot_s3 = plot(jack + diff * 0.500, display=display.none, editable=false, force_overlay=true)
plot_s4 = plot(jack + diff * 0.666, display=display.none, editable=false, force_overlay=true)
plot_s5 = plot(jack + diff * 0.833, display=display.none, editable=false, force_overlay=true)

// 6-Stage Deep Opacity Fill: Nearing invisibility by Jack (price), hardening towards Jill
fill(plot_jack, plot_s1, color=color.new(current_base_color, 96), title="Gradient Stage 1")
fill(plot_s1,   plot_s2, color=color.new(current_base_color, 91), title="Gradient Stage 2")
fill(plot_s2,   plot_s3, color=color.new(current_base_color, 85), title="Gradient Stage 3")
fill(plot_s3,   plot_s4, color=color.new(current_base_color, 78), title="Gradient Stage 4")
fill(plot_s4,   plot_s5, color=color.new(current_base_color, 70), title="Gradient Stage 5")
fill(plot_s5,   plot_jill, color=color.new(current_base_color, 60), title="Gradient Stage 6")

// Visual Signals on the Main Chart - Dynamically routed via Conditional Series to bypass constant string constraints
plotshape(signalSizeInput == size.tiny   and jack_climbs, title="Jack Climbs [Tiny]",   style=shape.triangleup,   location=location.belowbar, color=COLOR_JACK_BULL, size=size.tiny,   editable=false, force_overlay=true)
plotshape(signalSizeInput == size.small  and jack_climbs, title="Jack Climbs [Small]",  style=shape.triangleup,   location=location.belowbar, color=COLOR_JACK_BULL, size=size.small,  editable=false, force_overlay=true)
plotshape(signalSizeInput == size.normal and jack_climbs, title="Jack Climbs [Normal]", style=shape.triangleup,   location=location.belowbar, color=COLOR_JACK_BULL, size=size.normal, editable=false, force_overlay=true)
plotshape(signalSizeInput == size.large  and jack_climbs, title="Jack Climbs [Large]",  style=shape.triangleup,   location=location.belowbar, color=COLOR_JACK_BULL, size=size.large,  editable=false, force_overlay=true)
plotshape(signalSizeInput == size.huge   and jack_climbs, title="Jack Climbs [Huge]",   style=shape.triangleup,   location=location.belowbar, color=COLOR_JACK_BULL, size=size.huge,   editable=false, force_overlay=true)
plotshape(signalSizeInput == size.auto   and jack_climbs, title="Jack Climbs [Auto]",   style=shape.triangleup,   location=location.belowbar, color=COLOR_JACK_BULL, size=size.auto,   editable=false, force_overlay=true)

plotshape(signalSizeInput == size.tiny   and jack_tumbles, title="Jack Tumbles [Tiny]",   style=shape.triangledown, location=location.abovebar, color=COLOR_JACK_BEAR, size=size.tiny,   editable=false, force_overlay=true)
plotshape(signalSizeInput == size.small  and jack_tumbles, title="Jack Tumbles [Small]",  style=shape.triangledown, location=location.abovebar, color=COLOR_JACK_BEAR, size=size.small,  editable=false, force_overlay=true)
plotshape(signalSizeInput == size.normal and jack_tumbles, title="Jack Tumbles [Normal]", style=shape.triangledown, location=location.abovebar, color=COLOR_JACK_BEAR, size=size.normal, editable=false, force_overlay=true)
plotshape(signalSizeInput == size.large  and jack_tumbles, title="Jack Tumbles [Large]",  style=shape.triangledown, location=location.abovebar, color=COLOR_JACK_BEAR, size=size.large,  editable=false, force_overlay=true)
plotshape(signalSizeInput == size.huge   and jack_tumbles, title="Jack Tumbles [Huge]",   style=shape.triangledown, location=location.abovebar, color=COLOR_JACK_BEAR, size=size.huge,   editable=false, force_overlay=true)
plotshape(signalSizeInput == size.auto   and jack_tumbles, title="Jack Tumbles [Auto]",   style=shape.triangledown, location=location.abovebar, color=COLOR_JACK_BEAR, size=size.auto,   editable=false, force_overlay=true)

//---------------------------------------------------------------------------------------------------------------------}
// Phase Convergence Oscillator (PCO) (Rendered Natively in Dedicated Pane)
//---------------------------------------------------------------------------------------------------------------------{
// Measures the decoupled 1st-derivative momentum of the distance between the PCO Jack and Jill
float pco_delta = pco_jack - pco_jill
color pco_color = pco_delta >= 0 ? (pco_delta > nz(pco_delta[1]) ? COLOR_JACK_BULL : color.new(COLOR_JACK_BULL, 60)) : (pco_delta < nz(pco_delta[1]) ? COLOR_JACK_BEAR : color.new(COLOR_JACK_BEAR, 60))

plot(pco_delta, title="PCO Delta", style=plot.style_columns, color=pco_color, linewidth=3)
hline(0, "Zero Line", color=color.new(color.gray, 50), linestyle=hline.style_dotted)

//---------------------------------------------------------------------------------------------------------------------}
// Alert Engine Registration
//---------------------------------------------------------------------------------------------------------------------{
alertcondition(jack_climbs,  title="Jack Climbs (Bullish)",  message="Jack has climbed above Jill. A bullish structural phase shift has been detected.")
alertcondition(jack_tumbles, title="Jack Tumbles (Bearish)", message="Jack has tumbled below Jill. A bearish structural phase shift has been detected.")
//---------------------------------------------------------------------------------------------------------------------}
````
