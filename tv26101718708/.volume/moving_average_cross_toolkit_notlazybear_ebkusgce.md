# Moving Average Cross Toolkit [NotLazyBear]

- url: https://www.tradingview.com/script/Ebkusgce-Moving-Average-Cross-Toolkit-NotLazyBear/
- type: indicator
- pine_id: PUB;580e28f6a0b3468b9d3d43a657af2ff2
- version: 5.0

## Description

[b]Moving Average Cross Toolkit[/b]
[i]A comprehensive moving average system that lets you mix and match 27 different MA types — from simple built-in averages to advanced scientific and adaptive algorithms — across up to 4 lines on your chart. Includes three different ways to define trend direction, automatic cross detection with signals, and visual fills between lines. Think of it as a Swiss Army knife for moving average analysis, letting you experiment with everything from basic trend following to cutting-edge mathematical smoothing techniques.[/i]
[b]What This Actually Does (In Plain English)[/b]
Most charts let you add one or two moving averages. This toolkit lets you add [b]up to four[/b], and each one can be a completely different type of average. You could have a simple 50-period EMA, a 200-period scientific "Quantum Uncertainty" MA, a 100-period adaptive KAMA, and a 20-period SuperSmoother — all on the same chart, all working together.
The indicator then:
[list]
[*]Plots your chosen MAs with custom colors and thickness
[*]Fills the space between them with color (green when faster is above slower, red when below)
[*]Detects when any two lines cross and plots arrow signals
[*]Determines overall trend direction using one of three methods
[*]Changes the background color to show the current trend state
[/list]
[b]The 27 Moving Average Types[/b]
[list]
[*][b]Built-in Basics (8):[/b] SMA, EMA, WMA, VWMA, HMA, RMA, SWMA, ALMA — standard tools everyone knows.
[*][b]Scientific/Adaptive (19):[/b] Wave Mechanics, Thermodynamic Entropy, Biological Synaptic, Quantum Uncertainty, Fluid Dynamics, Network Cascade, Behavioral Economics, Hybrid Scientific, SuperSmoother, KAMA, Jurik, Hull, Zero-Lag, TEMA, DEMA, FRAMA, Hurst Adaptive, Phase Harmonic, Volatility Adjusted.
[/list]
[b]The Scientific MAs Explained Simply[/b]
[list]
[*][b]Wave Mechanics:[/b] Adds tiny sine-wave oscillations to the price, like ripples on water, then smooths them. Good for catching cyclical patterns.
[*][b]Thermodynamic Entropy:[/b] Measures how "random" price movements are and adjusts smoothing accordingly. More random = more smoothing. Less random = more responsive.
[*][b]Biological Synaptic:[/b] Models price like signals passing through brain cells, with weights that fade exponentially. Recent bars matter most, but older bars still contribute a little.
[*][b]Quantum Uncertainty:[/b] Uses a physics concept — the more precisely you know position, the less you know momentum. Adapts smoothing based on this trade-off between price location and speed.
[*][b]Fluid Dynamics:[/b] Treats price like water flowing through pipes. When flow is smooth (low volatility), it uses gentle smoothing. When turbulent (high volatility), it adapts aggressively.
[*][b]Network Cascade:[/b] Groups nearby prices into "clusters" and averages them. Prices close to each other get full weight; outliers get reduced weight.
[*][b]Behavioral Economics:[/b] Based on Nobel Prize-winning Prospect Theory. Losses hurt more than gains feel good, so this MA weights downward moves differently than upward moves.
[*][b]Hybrid Scientific:[/b] Combines all 6 scientific MAs above and dynamically weights them based on which one has been most accurate recently.
[*][b]SuperSmoother:[/b] A specialized filter that removes high-frequency noise while preserving the underlying trend. Very clean lines.
[*][b]KAMA (Kaufman Adaptive):[/b] Adjusts its speed based on market efficiency. In strong trends, it speeds up. In choppy markets, it slows down to avoid whipsaw.
[*][b]Jurik:[/b] A proprietary-style adaptive MA with error correction. Known for being very smooth while maintaining low lag.
[*][b]Hull:[/b] Uses weighted MAs of half-lengths to reduce lag significantly. Very responsive but can overshoot.
[*][b]Zero-Lag:[/b] Attempts to remove the delay inherent in all MAs by using a de-lagging technique. Snappy but can be noisy.
[*][b]TEMA/DEMA:[/b] Triple/Double Exponential MAs. Apply EMA multiple times to reduce lag further.
[*][b]FRAMA (Fractal Adaptive):[/b] Uses fractal dimension to adapt smoothing. In trending markets (low fractal dimension), it behaves like a fast EMA. In choppy markets (high fractal dimension), it behaves like a slow SMA.
[*][b]Hurst Adaptive:[/b] Uses the Hurst exponent to detect trending vs mean-reverting regimes and adjusts speed accordingly.
[*][b]Phase Harmonic:[/b] A band-pass filter that isolates specific cycle lengths. Like tuning a radio to only hear one station.
[*][b]Volatility Adjusted:[/b] EMA with length automatically scaled by current volatility. High volatility = longer (slower). Low volatility = shorter (faster).
[/list]
[b]All The Settings Explained[/b]
[i]General[/i]
[list]
[*][b]Moving Averages to Display:[/b] 2, 3, or 4. Controls how many MA configuration panels are active.
[*][b]Phase Harmonic Bandwidth:[/b] How "wide" the frequency filter is for the Phase Harmonic MA. Default 0.1. Lower = more selective (only very specific cycles pass). Higher = more permissive. Only affects that one MA type.
[/list]
[i]MA 1–4 Configuration (Identical for Each)[/i]
[list]
[*][b]Enable:[/b] Toggle this MA on/off.
[*][b]Type:[/b] Choose from 27 available types.
[*][b]Length:[/b] Lookback period. Standard is 50 for fast, 200 for slow, but experiment freely.
[*][b]Source:[/b] Which price to use — close, open, high, low, hl2, hlc3, ohlc4.
[*][b]Color:[/b] Line color.
[*][b]Width:[/b] Line thickness (1–4).
[/list]
[i]Trend Identification Logic[/i]
[list]
[*][b]Strict Hierarchy:[/b] (Default) MA1 > MA2 > MA3 > MA4 = bullish. Reverse = bearish. Simple and classic — like a stack of cards.
[*][b]Custom Pairs:[/b] Define up to 3 specific pairs (e.g., MA1 vs MA2, MA2 vs MA3) with custom conditions (Fast > Slow OR Fast < Slow). All enabled pairs must agree for a trend signal. Flexible for complex strategies.
[*][b]Weighted Score:[/b] Each pair gets +1 (bullish) or -1 (bearish). Sum them up. If total ≥ threshold = bullish. If total ≤ -threshold = bearish. Default threshold is 2. This allows "mixed" signals — e.g., 2 pairs bullish and 1 bearish might still be bullish overall.
[/list]
[i]Trend Logic — Pairs (Custom Pairs Mode)[/i]
[list]
[*][b]Pair 1–3:[/b] Enable/disable, choose fast MA (1–4), choose slow MA (1–4), set condition (Fast > Slow or Fast < Slow).
[*][b]Example:[/b] Pair 1: MA1 (50 EMA) > MA2 (200 SMA) = bullish. Pair 2: MA3 (100 KAMA) > MA4 (20 SuperSmoother) = bullish. Both must be true for overall bullish trend.
[/list]
[i]Trend Logic — Weighted[/i]
[list]
[*][b]Weighted Score Threshold:[/b] How many points needed for a directional signal. Default 2. With 3 pairs, scores range from -3 to +3. Threshold 2 means you need 2 bullish pairs (and at most 1 bearish) for bullish signal.
[/list]
[i]Visuals[/i]
[list]
[*][b]Show MA Fills:[/b] Toggle the colored shading between MAs.
[*][b]Show Background Trend:[/b] Toggle the background color (green/red/grey).
[*][b]Show Cross & Trend Signals:[/b] Toggle all arrow and label markers.
[/list]
[b]How To Read The Chart[/b]
[list]
[*][b]MA Lines:[/b] Up to 4 colored lines tracking price. Their behavior depends entirely on which types you chose. A KAMA will hug price tightly in trends. A SuperSmoother will glide smoothly. A Scientific MA might behave oddly during high volatility.
[*][b]Fills Between Lines:[/b] Green shading when the faster MA is above the slower MA. Red shading when below. The intensity of color shows the "health" of the trend — wide, consistent fills = strong trend. Thin, flickering fills = weak or changing trend.
[*][b]Background Color:[/b] Light green = bullish trend confirmed. Light red = bearish trend confirmed. Grey = neutral/mixed.
[*][b]Cross Signals:[/b]
[list]
[*]"1▲2" = MA1 crossed above MA2 (bullish cross)
[*]"1▼2" = MA1 crossed below MA2 (bearish cross)
[*]"2▲3", "2▼3", "3▲4", "3▼4" = Same logic for other pairs
[*]Larger triangles = MA1/MA2 crosses (most important). Smaller = secondary crosses.
[/list]
[*][b]Trend Labels:[/b] "BULL" or "BEAR" appear when the overall trend state changes (based on your chosen mode). These are later than cross signals but confirm the bigger picture.
[/list]
[b]Practical Trading Strategies[/b]
[i]The "Golden Cross on Steroids" Play (Beginner-Friendly)[/i]
[list]
[*]Set MA1 to 50-period EMA (fast) and MA2 to 200-period SMA (slow)
[*]Use Strict Hierarchy mode
[*]Wait for MA1 to cross above MA2 with a "1▲2" signal
[*]Enter long when background turns green
[*]Stay long as long as background stays green
[*]Exit when MA1 crosses below MA2 ("1▼2") or background turns grey/red
[*]This is the classic trend-following approach, enhanced with visual confirmation
[/list]
[i]The "Adaptive Multi-MA" Play[/i]
[list]
[*]Set MA1 to KAMA (50) — adaptive, fast in trends
[*]Set MA2 to FRAMA (100) — adaptive, fractal-based
[*]Set MA3 to SuperSmoother (200) — clean long-term trend
[*]Use Weighted Score mode with threshold 2
[*]When all three agree bullish (green background), the trend is strong and genuine
[*]When they disagree (grey background), the market is confused — reduce size or wait
[*]This filters out many false signals by requiring multi-timeframe consensus
[/list]
[i]The "Scientific Experiment" Play[/i]
[list]
[*]Replace one standard MA with a scientific one (e.g., Quantum Uncertainty or Fluid Dynamics)
[*]Compare its behavior to the standard EMA/SMA on the same chart
[*]Notice when the scientific MA leads or lags — this reveals regime changes
[*]Use the scientific MA as an early warning system and the standard MA for confirmation
[*]Example: When Quantum MA crosses above SMA but price hasn't moved yet, it may predict an upcoming shift
[/list]
[i]The "Custom Pair Strategy" Play (Advanced)[/i]
[list]
[*]Define specific relationships that matter for your strategy
[*]Example: Pair 1 = MA1 (short-term) > MA2 (long-term) for trend direction
[*]Pair 2 = MA3 (volume-weighted) > MA4 (price-only) for volume confirmation
[*]Both must agree for a signal — this adds a volume filter to your trend system
[*]Experiment with unconventional pairings to find edges in your specific market
[/list]
[b]Important Things To Know[/b]
[list]
[*][b]Scientific MAs Are Experimental:[/b] The Wave Mechanics, Quantum Uncertainty, Fluid Dynamics, etc. MAs are mathematical curiosities based on physics and biology analogies. They are NOT proven to outperform standard MAs. Use them for experimentation and learning, not as holy grails. The Hybrid Scientific MA attempts to solve this by dynamically weighting them based on recent accuracy.
[*][b]Lag vs. Noise Trade-Off:[/b] All MAs face this fundamental tension. Responsive MAs (Hull, Zero-Lag, TEMA) catch turns early but generate false signals. Smooth MAs (SuperSmoother, SMA, RMA) avoid false signals but enter trends late. Adaptive MAs (KAMA, FRAMA, Jurik) try to balance this by changing speed based on conditions. There is no perfect MA — only the right MA for the right market condition.
[*][b]Custom Implementations Use Taylor Series:[/b] Some scientific MAs require math functions not in Pine Script's standard library (tanh, atan2). The script includes manual implementations using Taylor series expansions. These are accurate but computationally heavier than built-in functions. On very long charts, initial load may take a moment.
[*][b]Phase Harmonic Requires Bandwidth:[/b] This MA type is unique because it needs the global bandwidth parameter. If you use Phase Harmonic for multiple MAs, they all share the same bandwidth setting. Narrow bandwidth (0.05) = very selective, may produce flat lines. Wide bandwidth (0.3) = more responsive but less "harmonic."
[*][b]VWMA and VWAP Are Different:[/b] VWMA (Volume-Weighted Moving Average) is a standard MA type available here. The Volatility Adjusted MA uses ATR scaling. Don't confuse these — they behave very differently.
[*][b]Weighted Score Mode Allows Nuance:[/b] Unlike Strict Hierarchy (all-or-nothing), Weighted Score lets you have "mostly bullish" or "mostly bearish" states. This is useful when markets are transitioning. A score of +1 (threshold 2) means bullish pairs lead but haven't fully won — early warning.
[*][b]Cross Signals Fire Immediately:[/b] They use ta.crossover/crossunder which triggers on the bar where the cross happens. In choppy markets, you may get rapid back-and-forth crosses. The background trend filter (which requires sustained conditions) helps reduce this noise.
[*][b]No Repainting:[/b] All MAs use historical data only. Cross signals appear at confirmation and do not shift. The only exception would be if you use a very short pivot length with lookahead, but the default settings are safe.
[/list]
[b]Common Mistakes To Avoid[/b]
[list]
[*][b]Using Too Many Scientific MAs at Once:[/b] They're fun to experiment with, but 4 scientific MAs on one chart is overwhelming and likely counterproductive. Start with 1–2 standard MAs and add 1 scientific MA for comparison.
[*][b]Ignoring the Trend Mode Setting:[/b] Strict Hierarchy, Custom Pairs, and Weighted Score produce very different signals. Make sure you understand which mode is active and how it defines "trend." The default Strict Hierarchy is simple and reliable.
[*][b]Chasing Every Cross:[/b] In choppy markets, MAs cross constantly. The fills will flicker green/red rapidly. Don't trade every cross — wait for the background trend to confirm and for multiple MAs to align.
[*][b]Setting Incompatible Lengths:[/b] A 5-period SMA and a 200-period KAMA will cross frequently and produce confusing signals. The classic fast/slow pairing (e.g., 50/200) works because the lengths are meaningfully different. Keep a 2:1 to 4:1 ratio between your fastest and slowest MA.
[*][b]Forgetting Source Matters:[/b] Using high for one MA and low for another creates artificial crosses that don't reflect true price action. Standard practice is close for all, or hl2 for a balanced view. Only mix sources if you have a specific strategy reason.
[*][b]Over-Optimizing Colors and Widths:[/b] It's tempting to make every MA a different neon color with maximum width. This creates visual chaos. Use 2–3 colors maximum, with the most important MA being boldest.
[/list]

## Source Code

````pine
//@version=6
indicator("Moving Average Cross Toolkit [NotLazyBear]", shorttitle="MA Toolkit[NotLazyBear]", overlay=true, max_lines_count=500, max_labels_count=500, max_bars_back=1000)
import TradingView/ta/12

// ============================================================================
//  UNIVERSAL MOVING AVERAGE CROSS TOOLKIT
// ============================================================================

// === GENERAL CONFIGURATION ===
maCount      = input.int(2, "Moving Averages to Display", options=[2, 3, 4], group="General")

// === MA 1 CONFIGURATION ===
ma1Enable = input.bool(true, "Enable MA 1", group="MA 1")
ma1Type   = input.string("EMA", "MA 1 Type", options=["SMA","EMA","WMA","VWMA","HMA","RMA","SWMA","ALMA","Thermodynamic Entropy","Biological Synaptic","Fluid Dynamics","Network Cascade","Behavioral Economics","SuperSmoother","KAMA","Jurik","Hull","Zero-Lag","TEMA","DEMA","FRAMA","Hurst Adaptive","Volatility Adjusted","AMA","T3","ADXVMA","AHRMA","ALXMA","DSEMA","FEMA","IE2","Instantaneous Trendline","ILRS","Laguerre Filter","Leader EMA","LSMA","McGinley Dynamic","McNicholl EMA","NonLagMA","PWMA","RMTA","SDEC","SWMA (Sine)","SLWMA","SMMA","TMA","VEMA","ZLagDEMA","ZLagMA","ZLagTEMA","ThreePole Butterworth","ThreePole SuperSmoother","TwoPole Butterworth","TwoPole SuperSmoother"], group="MA 1")
ma1Len    = input.int(50, "MA 1 Length", minval=1, group="MA 1")
ma1Src    = input.source(close, "MA 1 Source", group="MA 1")
ma1Color  = input.color(color.new(#00E5FF, 0), "MA 1 Color", group="MA 1")
ma1Width  = input.int(2, "MA 1 Width", minval=1, maxval=4, group="MA 1")

// === MA 2 CONFIGURATION ===
ma2Enable = input.bool(true, "Enable MA 2", group="MA 2")
ma2Type   = input.string("SMA", "MA 2 Type", options=["SMA","EMA","WMA","VWMA","HMA","RMA","SWMA","ALMA","Thermodynamic Entropy","Biological Synaptic","Fluid Dynamics","Network Cascade","Behavioral Economics","SuperSmoother","KAMA","Jurik","Hull","Zero-Lag","TEMA","DEMA","Hurst Adaptive","Volatility Adjusted","AMA","T3","ADXVMA","AHRMA","ALXMA","DSEMA","FEMA","IE2","FRAMA","Instantaneous Trendline","ILRS","Laguerre Filter","Leader EMA","LSMA","McGinley Dynamic","McNicholl EMA","NonLagMA","PWMA","RMTA","SDEC","SWMA (Sine)","SLWMA","SMMA","TMA","VEMA","ZLagDEMA","ZLagMA ","ZLagTEMA","ThreePole Butterworth","ThreePole SuperSmoother","TwoPole Butterworth","TwoPole SuperSmoother"], group="MA 2")
ma2Len    = input.int(200, "MA 2 Length", minval=1, group="MA 2")
ma2Src    = input.source(close, "MA 2 Source", group="MA 2")
ma2Color  = input.color(color.new(#FF5252, 0), "MA 2 Color", group="MA 2")
ma2Width  = input.int(2, "MA 2 Width", minval=1, maxval=4, group="MA 2")

// === MA 3 CONFIGURATION ===
ma3Enable = input.bool(false, "Enable MA 3", group="MA 3")
ma3Type   = input.string("WMA", "MA 3 Type", options=["SMA","EMA","WMA","VWMA","HMA","RMA","SWMA","ALMA","Thermodynamic Entropy","Biological Synaptic","Fluid Dynamics","Network Cascade","Behavioral Economics","SuperSmoother","KAMA","Jurik","Hull","Zero-Lag","TEMA","DEMA","Hurst Adaptive","Volatility Adjusted","AMA","T3","ADXVMA","AHRMA","ALXMA","DSEMA","FEMA","IE2","FRAMA","Instantaneous Trendline","ILRS","Laguerre Filter","Leader EMA","LSMA","McGinley Dynamic","McNicholl EMA","NonLagMA","PWMA","RMTA","SDEC","SWMA (Sine)","SLWMA","SMMA","TMA","VEMA","ZLagDEMA","ZLagMA ","ZLagTEMA","ThreePole Butterworth","ThreePole SuperSmoother","TwoPole Butterworth","TwoPole SuperSmoother"], group="MA 3")
ma3Len    = input.int(100, "MA 3 Length", minval=1, group="MA 3")
ma3Src    = input.source(close, "MA 3 Source", group="MA 3")
ma3Color  = input.color(color.new(#69F0AE, 0), "MA 3 Color", group="MA 3")
ma3Width  = input.int(2, "MA 3 Width", minval=1, maxval=4, group="MA 3")

// === MA 4 CONFIGURATION ===
ma4Enable = input.bool(false, "Enable MA 4", group="MA 4")
ma4Type   = input.string("VWMA", "MA 4 Type", options=["SMA","EMA","WMA","VWMA","HMA","RMA","SWMA","ALMA","Thermodynamic Entropy","Biological Synaptic","Fluid Dynamics","Network Cascade","Behavioral Economics","SuperSmoother","KAMA","Jurik","Hull","Zero-Lag","TEMA","DEMA","FRAMA","Hurst Adaptive","Volatility Adjusted","AMA","T3","ADXVMA","AHRMA","ALXMA","DSEMA","FEMA","IE2","FRAMA ","Instantaneous Trendline","ILRS","Laguerre Filter","Leader EMA","LSMA","McGinley Dynamic","McNicholl EMA","NonLagMA","PWMA","RMTA","SDEC","SWMA (Sine)","SLWMA","SMMA","TMA","VEMA","ZLagDEMA","ZLagMA ","ZLagTEMA","ThreePole Butterworth","ThreePole SuperSmoother","TwoPole Butterworth","TwoPole SuperSmoother"], group="MA 4")
ma4Len    = input.int(200, "MA 4 Length", minval=1, group="MA 4")
ma4Src    = input.source(close, "MA 4 Source", group="MA 4")
ma4Color  = input.color(color.new(#E040FB, 0), "MA 4 Color", group="MA 4")
ma4Width  = input.int(2, "MA 4 Width", minval=1, maxval=4, group="MA 4")

// === LIBRARY MA PARAMETERS ===
kamaFastEnd    = input.int(2, "KAMA Fast End", minval=1, group="Library MA Parameters")
kamaSlowEnd    = input.int(30, "KAMA Slow End", minval=1, group="Library MA Parameters")
amaFl          = input.int(2, "AMA Fast Length", minval=1, group="Library MA Parameters")
amaSl          = input.int(30, "AMA Slow Length", minval=1, group="Library MA Parameters")
framaFC        = input.int(1, "FRAMA  Fast Channel", minval=1, group="Library MA Parameters")
framaSC        = input.int(200, "FRAMA  Slow Channel", minval=1, group="Library MA Parameters")
instantAlpha   = input.float(0.07, "Instantaneous Trendline Alpha", minval=0.001, maxval=1.0, step=0.001, group="Library MA Parameters")
laguerreAlpha  = input.float(0.07, "Laguerre Alpha", minval=0.001, maxval=1.0, step=0.001, group="Library MA Parameters")
lsmaOffset     = input.int(0, "LSMA Offset", group="Library MA Parameters")
pwmaPwr        = input.float(2.0, "PWMA Power", minval=0.1, step=0.1, group="Library MA Parameters")

// === TREND IDENTIFICATION LOGIC ===
trendMode = input.string("Strict Hierarchy", "Trend Identification Mode", options=["Strict Hierarchy", "Custom Pairs", "Weighted Score"], group="Trend Logic")

pair1Enable = input.bool(true, "Enable Pair 1", group="Trend Logic — Pairs")
pair1Fast = input.int(1, "Pair 1 Fast MA", minval=1, maxval=4, group="Trend Logic — Pairs")
pair1Slow = input.int(2, "Pair 1 Slow MA", minval=1, maxval=4, group="Trend Logic — Pairs")
pair1Cond = input.string("Fast > Slow", "Pair 1 Condition", options=["Fast > Slow", "Fast < Slow"], group="Trend Logic — Pairs")

pair2Enable = input.bool(false, "Enable Pair 2", group="Trend Logic — Pairs")
pair2Fast = input.int(2, "Pair 2 Fast MA", minval=1, maxval=4, group="Trend Logic — Pairs")
pair2Slow = input.int(3, "Pair 2 Slow MA", minval=1, maxval=4, group="Trend Logic — Pairs")
pair2Cond = input.string("Fast > Slow", "Pair 2 Condition", options=["Fast > Slow", "Fast < Slow"], group="Trend Logic — Pairs")

pair3Enable = input.bool(false, "Enable Pair 3", group="Trend Logic — Pairs")
pair3Fast = input.int(3, "Pair 3 Fast MA", minval=1, maxval=4, group="Trend Logic — Pairs")
pair3Slow = input.int(4, "Pair 3 Slow MA", minval=1, maxval=4, group="Trend Logic — Pairs")
pair3Cond = input.string("Fast > Slow", "Pair 3 Condition", options=["Fast > Slow", "Fast < Slow"], group="Trend Logic — Pairs")

weightThreshold = input.int(1, "Weighted Score Threshold", minval=1, maxval=3, group="Trend Logic — Weighted")

// === SMART CROSS v2 CONFIGURATION ===
smartMode      = input.bool(true, "Enable Smart Cross Filter", group="Smart Cross v2")
smartThreshold = input.float(0.5, "Minimum Quality Score (0.0–1.0)", minval=0.0, maxval=1.0, step=0.1, group="Smart Cross v2")
allowNoHistory = input.bool(true, "Allow First Crosses (No History)", group="Smart Cross v2")

// === VISUAL SETTINGS ===
showFills   = input.bool(true, "Show MA Fills", group="Visuals")
showBg      = input.bool(true, "Show Background Trend", group="Visuals")
showSignals = input.bool(true, "Show Cross & Trend Signals", group="Visuals")

// ============================================================================
//  ORIGINAL CUSTOM MA IMPLEMENTATIONS
// ============================================================================

thermodynamicMA(src, len) =>
    float entropy = 0.0
    float total   = 0.0
    int calcLen   = math.min(len, 100)
    for i = 0 to calcLen - 1
        total += math.abs(nz(src[i]) - nz(src[i+1]))
    for i = 0 to calcLen - 1
        float val = math.abs(nz(src[i]) - nz(src[i+1]))
        float p   = total > 0 ? val / total : 1.0 / calcLen
        entropy := entropy - (p > 0 ? p * math.log(p) / math.log(2.0) : 0.0)
    float maxEntropy  = math.log(calcLen) / math.log(2.0)
    float normEntropy = maxEntropy > 0 ? entropy / maxEntropy : 0.5
    float alpha       = 2.0 / (len * (1.0 + normEntropy) + 1.0)
    var float ema     = na
    ema := nz(alpha * src + (1.0 - alpha) * nz(ema[1]), src)
    ema

synapticMA(src, len) =>
    float signal = 0.0
    float norm   = 0.0
    int synLen   = math.min(len, 50)
    for i = 0 to synLen - 1
        float weight = math.exp(-float(i) / (len * 0.3))
        signal += nz(src[i]) * weight
        norm   += weight
    nz(signal / norm, src)

// Custom Tanh Function
f_tanh(x) =>
    e2x = math.exp(2 * x)
    (e2x - 1) / (e2x + 1)



fluidMA(src, len) =>
    float velocity     = src - nz(src[1])
    float viscosity    = ta.stdev(src, len) * 0.1
    float reynolds     = math.abs(velocity) / (viscosity + 0.0001)
    float smoothFactor = 2.0 / (len * f_tanh(reynolds / 10.0) + 1.0)
    var float fma      = na
    fma := nz(smoothFactor * src + (1.0 - smoothFactor) * nz(fma[1]), src)
    fma

networkMA(src, len) =>
    float threshold = ta.stdev(src, len) * 0.5
    float sumVal    = 0.0
    float sumWeight = 0.0
    int netLen      = math.min(len, 100)
    for i = 0 to netLen - 1
        float dist   = math.abs(src - nz(src[i]))
        float weight = dist < threshold ? 1.0 : 0.2
        sumVal    += nz(src[i]) * weight
        sumWeight += weight
    nz(sumVal / sumWeight, src)

behavioralMA(src, len) =>
    int refIdx     = math.min(int(len / 2), 100)
    float ref      = nz(src[refIdx])
    float sumVal   = 0.0
    float sumWeight= 0.0
    int behLen     = math.min(len, 100)
    for i = 0 to behLen - 1
        float gain   = nz(src[i]) - ref
        float weight = gain >= 0 ? math.sqrt(gain + 1.0) : math.pow(math.abs(gain) + 1.0, 0.8) * 2.0
        sumVal    += nz(src[i]) * weight
        sumWeight += weight
    nz(sumVal / sumWeight, src)

superSmootherMA(src, len) =>
    float a1 = math.exp(-1.414 * math.pi / len)
    float b1 = 2.0 * a1 * math.cos(1.414 * math.pi / len)
    float c2 = b1
    float c3 = -a1 * a1
    float c1 = 1.0 - c2 - c3
    var float ss = na
    ss := c1 * (src + nz(src[1])) / 2.0 + c2 * nz(ss[1]) + c3 * nz(ss[2])
    nz(ss, src)

kamaMA(src, len, fastEnd, slowEnd) =>
    float nsignal = math.abs(src - nz(src[len]))
    float nnoise  = 0.0
    for i = 0 to len - 1
        nnoise += math.abs(nz(src[i]) - nz(src[i+1]))
    float nefratio = nnoise != 0 ? nsignal / nnoise : 0
    float nfastend = 2.0 / (fastEnd + 1)
    float nslowend = 2.0 / (slowEnd + 1)
    float nsmooth  = math.pow(nefratio * (nfastend - nslowend) + nslowend, 2)
    var float nAMA = na
    nAMA := nz(nAMA[1]) + nsmooth * (src - nz(nAMA[1]))
    nAMA

jurikMA(src, len) =>
    float beta  = 0.45 * (len - 1.0) / (0.45 * (len - 1.0) + 2.0)
    float alpha = math.pow(beta, 1.0)
    var float e0 = na
    var float e1 = na
    e0 := (1.0 - alpha) * src + alpha * nz(e0[1], src)
    e1 := (src - e0) * (1.0 - beta) + beta * nz(e1[1], 0.0)
    e0 + e1

hullCustomMA(src, len) =>
    int h1 = math.max(int(len / 2), 1)
    int h2 = math.max(int(math.sqrt(len)), 1)
    float w1 = ta.wma(src, h1)
    float w2 = ta.wma(src, len)
    float raw = 2.0 * w1 - w2
    nz(ta.wma(raw, h2), src)

zeroLagMA(src, len) =>
    float e1 = ta.ema(src, len)
    float e2 = ta.ema(e1, len)
    e1 + (e1 - e2)

temaMA(src, len) =>
    float e1 = ta.ema(src, len)
    float e2 = ta.ema(e1, len)
    float e3 = ta.ema(e2, len)
    3.0 * (e1 - e2) + e3

demaMA(src, len) =>
    float e1 = ta.ema(src, len)
    float e2 = ta.ema(e1, len)
    2.0 * e1 - e2

framaMA(src, len) =>
    int n       = math.max(int(len / 2), 1)
    float hi1   = ta.highest(src, n)
    float lo1   = ta.lowest(src, n)
    float hi2   = ta.highest(nz(src[n], src), n)
    float lo2   = ta.lowest(nz(src[n], src), n)
    float hi    = ta.highest(src, len)
    float lo    = ta.lowest(src, len)
    float n1    = (hi1 - lo1) / n
    float n2    = (hi2 - lo2) / n
    float n3    = (hi - lo) / len
    float d     = (n1 > 0 and n2 > 0 and n3 > 0) ? (math.log(n1 + n2) - math.log(n3)) / math.log(2.0) : 1.0
    float alpha = math.exp(-4.6 * (d - 1.0))
    alpha := math.max(0.01, math.min(1.0, alpha))
    var float frama = na
    frama := alpha * src + (1.0 - alpha) * nz(frama[1], src)
    nz(frama, src)

hurstAdaptiveMA(src, len) =>
    int half    = math.max(int(len / 2), 1)
    float n1    = (ta.highest(src, half) - ta.lowest(src, half)) / half
    float n2    = (ta.highest(nz(src[half], src), half) - ta.lowest(nz(src[half], src), half)) / half
    float n3    = (ta.highest(src, len) - ta.lowest(src, len)) / len
    float d     = (n1 + n2 > 0 and n3 > 0) ? (math.log(n1 + n2) - math.log(n3)) / math.log(2.0) : 1.0
    float h     = 2.0 - d
    float alpha = 2.0 / (len * h + 1.0)
    var float hma = na
    hma := nz(alpha * src + (1.0 - alpha) * nz(hma[1]), src)
    hma

volatilityAdjustedMA(src, len) =>
    float atr     = ta.atr(math.min(len, 100))
    float volNorm = atr / (ta.sma(src, math.min(len, 100)) * 0.01 + 0.0001)
    float adjLen  = len * (1.0 + volNorm)
    adjLen := math.max(2.0, adjLen)
    nz(ta.ema2(src, int(adjLen)), src)

swmaCustom(src, len) =>
    float sum   = 0.0
    float wSum  = 0.0
    int swmaLen = math.min(len, 20)
    for i = 0 to swmaLen - 1
        float w = swmaLen > 1 ? math.min(i + 1, swmaLen - i) : 1.0
        sum  += nz(src[i]) * w
        wSum += w
    nz(sum / wSum, src)


amaMA(src, len, fl, sl) =>
    float flout = 2.0 / (fl + 1)
    float slout = 2.0 / (sl + 1)
    float hh    = ta.highest(high, len + 1)
    float ll    = ta.lowest(low, len + 1)
    float mltp  = hh - ll != 0 ? math.abs(2 * src - ll - hh) / (hh - ll) : 0
    float ssc   = mltp * (flout - slout) + slout
    var float ama = 0.
    ama := nz(ama[1]) + math.pow(ssc, 2) * (src - nz(ama[1]))
    ama

t3MA(src, len) =>
    float xe11 = ta.ema(src, len)
    float xe21 = ta.ema(xe11, len)
    float xe31 = ta.ema(xe21, len)
    float xe41 = ta.ema(xe31, len)
    float xe51 = ta.ema(xe41, len)
    float xe61 = ta.ema(xe51, len)
    float b1   = 0.7
    float c11  = -b1 * b1 * b1
    float c21  = 3 * b1 * b1 + 3 * b1 * b1 * b1
    float c31  = -6 * b1 * b1 - 3 * b1 - 3 * b1 * b1 * b1
    float c41  = 1 + 3 * b1 + b1 * b1 * b1 + 3 * b1 * b1
    c11 * xe61 + c21 * xe51 + c31 * xe41 + c41 * xe31

adxvmaMA(src, len) =>
    var float tpdm = 0.
    var float tmdm = 0.
    var float pdm  = 0.
    var float mdm  = 0.
    var float pdi  = 0.
    var float mdi  = 0.
    var float out  = 0.
    var float val  = 0.
    var float tout = 0.
    var float vi   = 0.
    float diff = src - nz(src[1])
    tpdm := diff > 0 ? diff : tpdm
    tmdm := diff > 0 ? tmdm : -diff
    pdm  := ((len - 1.0) * nz(pdm[1]) + tpdm) / len
    mdm  := ((len - 1.0) * nz(mdm[1]) + tmdm) / len
    float trueRange = pdm + mdm
    float tpdi = trueRange > 0 ? pdm / trueRange : 0
    float tmdi = trueRange > 0 ? mdm / trueRange : 0
    pdi := ((len - 1.0) * nz(pdi[1]) + tpdi) / len
    mdi := ((len - 1.0) * nz(mdi[1]) + tmdi) / len
    tout := (pdi + mdi) > 0 ? math.abs(pdi - mdi) / (pdi + mdi) : tout
    out  := ((len - 1.0) * nz(out[1]) + tout) / len
    float thi = math.max(out, nz(out[1]))
    float tlo = math.min(out, nz(out[1]))
    for j = 2 to len
        thi := math.max(nz(out[j]), thi)
        tlo := math.min(nz(out[j]), tlo)
    vi := (thi - tlo) > 0 ? (out - tlo) / (thi - tlo) : vi
    val := ((len - vi) * nz(val[1]) + vi * src) / len
    val

ahrmaMA(src, len) =>
    var float ahrma = 0.
    float medMA = (nz(ahrma[1]) + nz(ahrma[len])) / 2.0
    ahrma := nz(ahrma[1]) + ((src - medMA) / len)
    ahrma

alxmaMA(src, len) =>
    float sumw = len - 2
    float sum  = sumw * src
    for k = 1 to len
        float weight = len - k - 2
        sumw += weight
        sum  += weight * nz(src[k])
    float out = len < 4 ? src : sum / sumw
    out

dsemaMA(src, len) =>
    float alpha = 2.0 / (1.0 + math.sqrt(len))
    var float ema1 = 0.
    var float ema2 = 0.
    ema1 := nz(ema1[1]) + alpha * (src - nz(ema1[1]))
    ema2 := nz(ema2[1]) + alpha * (ema1 - nz(ema2[1]))
    ema2

femaMA(src, len) =>
    float alpha = 2.0 / (2.0 + (len - 1.0) / 2.0)
    var float out = 0.
    out := nz(out[1]) + alpha * (src - nz(out[1]))
    out

ie2MA(src, len) =>
    float sumx = 0., sumxx = 0., sumxy = 0., sumy = 0.
    for k = 0 to len - 1
        float price = nz(src[k])
        sumx  += k
        sumxx += k * k
        sumxy += k * price
        sumy  += price
    float slope = (len * sumxy - sumx * sumy) / (sumx * sumx - len * sumxx)
    float average = sumy / len
    (((average + slope) + (sumy + slope * sumx) / len) / 2.0)

framaMA(src, len, FC, SC) =>
    int len1 = int(len / 2)
    float w = math.log(2.0 / (SC + 1))
    float H1 = ta.highest(high, len1)
    float L1 = ta.lowest(low, len1)
    float N1 = (H1 - L1) / len1
    float H2 = ta.highest(high, len1)[len1]
    float L2 = ta.lowest(low, len1)[len1]
    float N2 = (H2 - L2) / len1
    float H3 = ta.highest(high, len)
    float L3 = ta.lowest(low, len)
    float N3 = (H3 - L3) / len
    float dimen1 = (math.log(N1 + N2) - math.log(N3)) / math.log(2)
    var float dimen = 1.0
    dimen := N1 > 0 and N2 > 0 and N3 > 0 ? dimen1 : nz(dimen[1])
    float alpha1 = math.exp(w * (dimen - 1))
    float oldalpha = alpha1 > 1 ? 1 : alpha1 < 0.01 ? 0.01 : alpha1
    float oldN = (2 - oldalpha) / oldalpha
    float N = (SC - FC) * (oldN - 1) / (SC - 1) + FC
    float alpha_ = 2.0 / (N + 1)
    float alpha = alpha_ < 2.0 / (SC + 1) ? 2.0 / (SC + 1) : alpha_ > 1 ? 1 : alpha_
    var float out = 0.0
    out := (1 - alpha) * nz(out[1]) + alpha * src
    out

instantMA(src, alpha) =>
    var float itrend = 0.0
    itrend := bar_index < 7 ? (src + 2 * nz(src[1]) + nz(src[2])) / 4 :
         (alpha - math.pow(alpha, 2) / 4) * src + 0.5 * math.pow(alpha, 2) * nz(src[1]) - (alpha - 0.75 * math.pow(alpha, 2)) * nz(src[2]) + 2 * (1 - alpha) * nz(itrend[1]) - math.pow(1 - alpha, 2) * nz(itrend[2])
    2 * itrend - nz(itrend[2])

ilrsMA(src, len) =>
    float sum = len * (len - 1) * 0.5
    float sum2 = (len - 1) * len * (2 * len - 1) / 6.0
    float sum1 = 0., sumy = 0.
    for i = 0 to len - 1
        sum1 += i * nz(src[i])
        sumy += nz(src[i])
    float num1 = len * sum1 - sum * sumy
    float num2 = sum * sum - len * sum2
    float slope = num2 != 0. ? num1 / num2 : 0.
    slope + ta.sma(src, len)

laguerreMA(src, alpha) =>
    var float L0 = 0.0
    var float L1 = 0.0
    var float L2 = 0.0
    var float L3 = 0.0
    L0 := alpha * src + (1 - alpha) * nz(L0[1])
    L1 := -(1 - alpha) * L0 + nz(L0[1]) + (1 - alpha) * nz(L1[1])
    L2 := -(1 - alpha) * L1 + nz(L1[1]) + (1 - alpha) * nz(L2[1])
    L3 := -(1 - alpha) * L2 + nz(L2[1]) + (1 - alpha) * nz(L3[1])
    (L0 + 2 * L1 + 2 * L2 + L3) / 6

leaderMA(src, len) =>
    float alpha = 2.0 / (len + 1.0)
    var float ldr = 0.
    var float ldr2 = 0.
    ldr  := nz(ldr[1]) + alpha * (src - nz(ldr[1]))
    ldr2 := nz(ldr2[1]) + alpha * (src - ldr - nz(ldr2[1]))
    ldr + ldr2

lsmaMA(src, len, offset) =>
    ta.linreg(src, len, offset)

mcginleyMA(src, len) =>
    var float mg = 0.0
    float t = ta.ema(src, len)
    mg := na(mg[1]) ? t : mg[1] + (src - mg[1]) / (len * math.pow(src / mg[1], 4))
    mg

mcNichollMA(src, len) =>
    float alpha = 2.0 / (len + 1)
    float ema1 = ta.ema(src, len)
    float ema2 = ta.ema(ema1, len)
    ((2 - alpha) * ema1 - ema2) / (1 - alpha)

nonlagmaMA(src, len) =>
    float cycle = 4.0
    float coeff = 3.0 * math.pi
    float phase = len - 1.0
    int maxLen = math.min(len, 150)
    int _len = int(maxLen * cycle + phase)
    float weight = 0.
    float out = 0.
    array<float> alphas = array.new_float(_len, 0.0)
    for k = 0 to _len - 1
        float t = k <= phase - 1 ? 1.0 * k / (phase - 1) : 1.0 + (k - phase + 1) * (2.0 * cycle - 1.0) / (cycle * maxLen - 1.0)
        float beta = math.cos(math.pi * t)
        float g = 1.0 / (coeff * t + 1)
        g := t <= 0.5 ? 1 : g
        array.set(alphas, k, g * beta)
        weight += array.get(alphas, k)
    if weight > 0
        float sum = 0.
        for k = 0 to _len - 1
            sum += array.get(alphas, k) * nz(src[k])
        out := sum / weight
    out

pwmaMA(src, len, pwr) =>
    float sum = 0.0
    float weightSum = 0.0
    for i = 0 to len - 1
        float weight = math.pow(float(len - i), pwr)
        sum += nz(src[i]) * weight
        weightSum += weight
    sum / weightSum

rmtaMA(src, len) =>
    float alpha = 2.0 / (len + 1)
    var float b = 0.0
    b := (1 - alpha) * nz(b[1], src) + src
    var float rmta = 0.0
    rmta := (1 - alpha) * nz(rmta[1], src) + alpha * (src + b - nz(b[1]))
    rmta

decyclerMA(src, len) =>
    float alphaArg = 2 * math.pi / (len * math.sqrt(2))
    var float alpha = 0.0
    alpha := math.cos(alphaArg) != 0 ? (math.cos(alphaArg) + math.sin(alphaArg) - 1) / math.cos(alphaArg) : nz(alpha[1])
    var float hp = 0.0
    hp := math.pow(1 - alpha / 2, 2) * (src - 2 * nz(src[1]) + nz(src[2])) + 2 * (1 - alpha) * nz(hp[1]) - math.pow(1 - alpha, 2) * nz(hp[2])
    src - hp

slwmaMA(src, len) =>
    ta.wma(ta.wma(src, len), int(math.floor(math.sqrt(len))))

swmaSineMA(src, len) =>
    float sum = 0.0
    float weightSum = 0.0
    for i = 0 to len - 1
        float weight = math.sin((i + 1) * math.pi / (len + 1))
        sum += nz(src[i]) * weight
        weightSum += weight
    sum / weightSum

tmaMA(src, len) =>
    float filt = 0.0
    float coef = 0.0
    float l2 = len / 2.0
    for i = 1 to len
        float c = i < l2 ? i : i > l2 ? len + 1 - i : l2
        filt += c * nz(src[i - 1])
        coef += c
    filt := coef != 0 ? filt / coef : 0
    filt

vwemaMA(src, len) =>
    float p = ta.ema(volume * src, len)
    float v = ta.ema(volume, len)
    p / v

zlagdemaMA(src, len) =>
    float zdema1 = ta.ema(src, len)
    float zdema2 = ta.ema(zdema1, len)
    float dema1  = 2 * zdema1 - zdema2
    float zdema12 = ta.ema(dema1, len)
    float zdema22 = ta.ema(zdema12, len)
    2 * zdema12 - zdema22

zlagmaMA(src, len) =>
    float alpha = 2.0 / (1.0 + len)
    int per = int(math.ceil((len - 1.0) / 2.0))
    var float zlagma = 0.
    zlagma := nz(zlagma[1]) + alpha * (2.0 * src - nz(zlagma[per]) - nz(zlagma[1]))
    zlagma

zlagtemaMA(src, len) =>
    float ema1 = ta.ema(src, len)
    float ema2 = ta.ema(ema1, len)
    float ema3 = ta.ema(ema2, len)
    float out  = 3 * (ema1 - ema2) + ema3
    float ema1a = ta.ema(out, len)
    float ema2a = ta.ema(ema1a, len)
    float ema3a = ta.ema(ema2a, len)
    3 * (ema1a - ema2a) + ema3a

threepolebuttfiltMA(src, len) =>
    var float bttr = 0.
    var float a1 = 0.
    var float b1 = 0.
    var float c1 = 0.
    a1 := math.exp(-math.pi / len)
    b1 := 2 * a1 * math.cos(1.738 * math.pi / len)
    c1 := a1 * a1
    float coef2 = b1 + c1
    float coef3 = -(c1 + b1 * c1)
    float coef4 = c1 * c1
    float coef1 = (1 - b1 + c1) * (1 - c1) / 8.0
    bttr := coef1 * (src + 3 * nz(src[1]) + 3 * nz(src[2]) + nz(src[3])) + coef2 * nz(bttr[1]) + coef3 * nz(bttr[2]) + coef4 * nz(bttr[3])
    bttr := bar_index < 4 ? src : bttr
    bttr

threepolesssMA(src, len) =>
    var float filt = 0.
    var float a1 = 0.
    var float b1 = 0.
    var float c1 = 0.
    a1 := math.exp(-math.pi / len)
    b1 := 2 * a1 * math.cos(1.738 * math.pi / len)
    c1 := a1 * a1
    float coef2 = b1 + c1
    float coef3 = -(c1 + b1 * c1)
    float coef4 = c1 * c1
    float coef1 = 1 - coef2 - coef3 - coef4
    filt := coef1 * src + coef2 * nz(filt[1]) + coef3 * nz(filt[2]) + coef4 * nz(filt[3])
    filt := bar_index < 4 ? src : filt
    filt

twopolebutterMA(src, len) =>
    var float bttr = 0.
    var float a1 = 0.
    var float b1 = 0.
    a1 := math.exp(-1.414 * math.pi / len)
    b1 := 2 * a1 * math.cos(1.414 * math.pi / len)
    float coef2 = b1
    float coef3 = -a1 * a1
    float coef1 = (1 - b1 + a1 * a1) / 4.0
    bttr := coef1 * (src + 2 * nz(src[1]) + nz(src[2])) + coef2 * nz(bttr[1]) + coef3 * nz(bttr[2])
    bttr := bar_index < 3 ? src : bttr
    bttr

twopolessMA(src, len) =>
    var float filt = 0.
    var float a1 = 0.
    var float b1 = 0.
    a1 := math.exp(-1.414 * math.pi / len)
    b1 := 2 * a1 * math.cos(1.414 * math.pi / len)
    float coef2 = b1
    float coef3 = -a1 * a1
    float coef1 = 1 - coef2 - coef3
    filt := coef1 * src + coef2 * nz(filt[1]) + coef3 * nz(filt[2])
    filt := bar_index < 3 ? src : filt
    filt

// ============================================================================
//  DISPATCH ENGINE
// ============================================================================

getMA(src, len, type, kamaFast, kamaSlow, amaFl, amaSl, framaFC, framaSC, instantAlpha, lsmaOffset, pwmaPwr, laguerreAlpha) =>
    float r = na
    if type == "SMA"
        r := ta.sma(src, len)
    else if type == "EMA"
        r := ta.ema(src, len)
    else if type == "WMA"
        r := ta.wma(src, len)
    else if type == "VWMA"
        r := ta.vwma(src, len)
    else if type == "HMA"
        r := ta.hma(src, len)
    else if type == "RMA"
        r := ta.rma(src, len)
    else if type == "SWMA"
        r := swmaCustom(src, len)
    else if type == "ALMA"
        r := ta.alma(src, len, 0.85, 6.0)
    else if type == "Thermodynamic Entropy"
        r := thermodynamicMA(src, len)
    else if type == "Biological Synaptic"
        r := synapticMA(src, len)
    else if type == "Fluid Dynamics"
        r := fluidMA(src, len)
    else if type == "Network Cascade"
        r := networkMA(src, len)
    else if type == "Behavioral Economics"
        r := behavioralMA(src, len)
    else if type == "SuperSmoother"
        r := superSmootherMA(src, len)
    else if type == "KAMA"
        r := kamaMA(src, len, kamaFast, kamaSlow)
    else if type == "Jurik"
        r := jurikMA(src, len)
    else if type == "Hull"
        r := hullCustomMA(src, len)
    else if type == "Zero-Lag"
        r := zeroLagMA(src, len)
    else if type == "TEMA"
        r := temaMA(src, len)
    else if type == "DEMA"
        r := demaMA(src, len)
    else if type == "FRAMA"
        r := framaMA(src, len)
    else if type == "Hurst Adaptive"
        r := hurstAdaptiveMA(src, len)
    else if type == "Volatility Adjusted"
        r := volatilityAdjustedMA(src, len)
    else if type == "AMA"
        r := amaMA(src, len, amaFl, amaSl)
    else if type == "T3"
        r := t3MA(src, len)
    else if type == "ADXVMA"
        r := adxvmaMA(src, len)
    else if type == "AHRMA"
        r := ahrmaMA(src, len)
    else if type == "ALXMA"
        r := alxmaMA(src, len)
    else if type == "DSEMA"
        r := dsemaMA(src, len)
    else if type == "FEMA"
        r := femaMA(src, len)
    else if type == "IE2"
        r := ie2MA(src, len)
    else if type == "FRAMA "
        r := framaMA(src, len, framaFC, framaSC)
    else if type == "Instantaneous Trendline"
        r := instantMA(src, instantAlpha)
    else if type == "ILRS"
        r := ilrsMA(src, len)
    else if type == "Laguerre Filter"
        r := laguerreMA(src, laguerreAlpha)
    else if type == "Leader EMA"
        r := leaderMA(src, len)
    else if type == "LSMA"
        r := lsmaMA(src, len, lsmaOffset)
    else if type == "McGinley Dynamic"
        r := mcginleyMA(src, len)
    else if type == "McNicholl EMA"
        r := mcNichollMA(src, len)
    else if type == "NonLagMA"
        r := nonlagmaMA(src, len)
    else if type == "PWMA"
        r := pwmaMA(src, len, pwmaPwr)
    else if type == "RMTA"
        r := rmtaMA(src, len)
    else if type == "SDEC"
        r := decyclerMA(src, len)
    else if type == "SWMA (Sine)"
        r := swmaSineMA(src, len)
    else if type == "SLWMA"
        r := slwmaMA(src, len)
    else if type == "SMMA"
        r := ta.rma(src, len)
    else if type == "TMA"
        r := tmaMA(src, len)
    else if type == "VEMA"
        r := vwemaMA(src, len)
    else if type == "ZLagDEMA"
        r := zlagdemaMA(src, len)
    else if type == "ZLagMA "
        r := zlagmaMA(src, len)
    else if type == "ZLagTEMA"
        r := zlagtemaMA(src, len)
    else if type == "ThreePole Butterworth"
        r := threepolebuttfiltMA(src, len)
    else if type == "ThreePole SuperSmoother"
        r := threepolesssMA(src, len)
    else if type == "TwoPole Butterworth"
        r := twopolebutterMA(src, len)
    else if type == "TwoPole SuperSmoother"
        r := twopolessMA(src, len)
    r

// ============================================================================
//  CALCULATE ALL MOVING AVERAGES
// ============================================================================

ma1 = ma1Enable ? getMA(ma1Src, ma1Len, ma1Type, kamaFastEnd, kamaSlowEnd, amaFl, amaSl, framaFC, framaSC, instantAlpha, lsmaOffset, pwmaPwr, laguerreAlpha) : na
ma2 = ma2Enable ? getMA(ma2Src, ma2Len, ma2Type, kamaFastEnd, kamaSlowEnd, amaFl, amaSl, framaFC, framaSC, instantAlpha, lsmaOffset, pwmaPwr, laguerreAlpha) : na
ma3 = ma3Enable and maCount >= 3 ? getMA(ma3Src, ma3Len, ma3Type, kamaFastEnd, kamaSlowEnd, amaFl, amaSl, framaFC, framaSC, instantAlpha, lsmaOffset, pwmaPwr, laguerreAlpha) : na
ma4 = ma4Enable and maCount >= 4 ? getMA(ma4Src, ma4Len, ma4Type, kamaFastEnd, kamaSlowEnd, amaFl, amaSl, framaFC, framaSC, instantAlpha, lsmaOffset, pwmaPwr, laguerreAlpha) : na

// ============================================================================
//  SMART CROSS ALGORITHM v2 — Cross Quality Evaluation Engine
//  Tracks every cross cycle: entry → opposite cross.
//  Measures follow-through vs drawdown to compute a Net Quality score.
//  New signals are gated by the quality history of same-dir & opp-dir cycles.
// ============================================================================

// --- Pair 1-2 Cycle Tracking ---
var float p12_up_entry   = na
var float p12_up_peak    = na
var float p12_up_trough  = na
var float p12_down_entry = na
var float p12_down_peak  = na
var float p12_down_trough= na
var float p12_last_up_net   = na
var float p12_last_down_net = na
var int   p12_track = 0     // 0=none, 1=up, 2=down

// Update active cycle extremes every bar
if p12_track == 1
    p12_up_peak   := math.max(nz(p12_up_peak), high)
    p12_up_trough := math.min(nz(p12_up_trough), low)
else if p12_track == 2
    p12_down_peak   := math.max(nz(p12_down_peak), high)
    p12_down_trough := math.min(nz(p12_down_trough), low)

bool p12_rawUp   = ta.crossover(ma1, ma2)
bool p12_rawDown = ta.crossunder(ma1, ma2)

if p12_rawUp
    if p12_track == 2
        // Finalize the down cycle that just ended
        float d_move = (p12_down_entry - nz(p12_down_trough)) / p12_down_entry
        float d_dd   = (nz(p12_down_peak) - p12_down_entry) / p12_down_entry
        p12_last_down_net := d_move - d_dd * 0.5
    p12_track     := 1
    p12_up_entry  := close
    p12_up_peak   := high
    p12_up_trough := low

if p12_rawDown
    if p12_track == 1
        // Finalize the up cycle that just ended
        float u_move = (nz(p12_up_peak) - p12_up_entry) / p12_up_entry
        float u_dd   = (p12_up_entry - nz(p12_up_trough)) / p12_up_entry
        p12_last_up_net := u_move - u_dd * 0.5
    p12_track       := 2
    p12_down_entry  := close
    p12_down_peak   := high
    p12_down_trough := low

// Score calculation (executed only on cross bars)
float p12_up_score   = na
float p12_down_score = na

if p12_rawUp
    bool hasUp   = not na(p12_last_up_net)
    bool hasDown = not na(p12_last_down_net)
    float sameDir = hasUp   ? (p12_last_up_net > 0.005 ? 1.0 : p12_last_up_net > 0.0 ? 0.5 : 0.0) : (allowNoHistory ? 0.5 : 0.0)
    float oppFail = hasDown ? (p12_last_down_net < -0.005 ? 1.0 : p12_last_down_net < 0.0 ? 0.5 : 0.0) : (allowNoHistory ? 0.5 : 0.0)
    p12_up_score := (sameDir + oppFail) / 2.0

if p12_rawDown
    bool hasUp   = not na(p12_last_up_net)
    bool hasDown = not na(p12_last_down_net)
    float sameDir = hasDown ? (p12_last_down_net > 0.005 ? 1.0 : p12_last_down_net > 0.0 ? 0.5 : 0.0) : (allowNoHistory ? 0.5 : 0.0)
    float oppFail = hasUp   ? (p12_last_up_net < -0.005 ? 1.0 : p12_last_up_net < 0.0 ? 0.5 : 0.0) : (allowNoHistory ? 0.5 : 0.0)
    p12_down_score := (sameDir + oppFail) / 2.0

bool cross1_2_Bull = smartMode ? (p12_rawUp and not na(p12_up_score) and p12_up_score >= smartThreshold) : p12_rawUp
bool cross1_2_Bear = smartMode ? (p12_rawDown and not na(p12_down_score) and p12_down_score >= smartThreshold) : p12_rawDown

// --- Pair 2-3 Cycle Tracking ---
var float p23_up_entry   = na
var float p23_up_peak    = na
var float p23_up_trough  = na
var float p23_down_entry = na
var float p23_down_peak  = na
var float p23_down_trough= na
var float p23_last_up_net   = na
var float p23_last_down_net = na
var int   p23_track = 0

if p23_track == 1
    p23_up_peak   := math.max(nz(p23_up_peak), high)
    p23_up_trough := math.min(nz(p23_up_trough), low)
else if p23_track == 2
    p23_down_peak   := math.max(nz(p23_down_peak), high)
    p23_down_trough := math.min(nz(p23_down_trough), low)

bool p23_rawUp   = not na(ma3) and ta.crossover(ma2, ma3)
bool p23_rawDown = not na(ma3) and ta.crossunder(ma2, ma3)

if p23_rawUp
    if p23_track == 2
        float d_move = (p23_down_entry - nz(p23_down_trough)) / p23_down_entry
        float d_dd   = (nz(p23_down_peak) - p23_down_entry) / p23_down_entry
        p23_last_down_net := d_move - d_dd * 0.5
    p23_track     := 1
    p23_up_entry  := close
    p23_up_peak   := high
    p23_up_trough := low

if p23_rawDown
    if p23_track == 1
        float u_move = (nz(p23_up_peak) - p23_up_entry) / p23_up_entry
        float u_dd   = (p23_up_entry - nz(p23_up_trough)) / p23_up_entry
        p23_last_up_net := u_move - u_dd * 0.5
    p23_track       := 2
    p23_down_entry  := close
    p23_down_peak   := high
    p23_down_trough := low

float p23_up_score   = na
float p23_down_score = na

if p23_rawUp
    bool hasUp   = not na(p23_last_up_net)
    bool hasDown = not na(p23_last_down_net)
    float sameDir = hasUp   ? (p23_last_up_net > 0.005 ? 1.0 : p23_last_up_net > 0.0 ? 0.5 : 0.0) : (allowNoHistory ? 0.5 : 0.0)
    float oppFail = hasDown ? (p23_last_down_net < -0.005 ? 1.0 : p23_last_down_net < 0.0 ? 0.5 : 0.0) : (allowNoHistory ? 0.5 : 0.0)
    p23_up_score := (sameDir + oppFail) / 2.0

if p23_rawDown
    bool hasUp   = not na(p23_last_up_net)
    bool hasDown = not na(p23_last_down_net)
    float sameDir = hasDown ? (p23_last_down_net > 0.005 ? 1.0 : p23_last_down_net > 0.0 ? 0.5 : 0.0) : (allowNoHistory ? 0.5 : 0.0)
    float oppFail = hasUp   ? (p23_last_up_net < -0.005 ? 1.0 : p23_last_up_net < 0.0 ? 0.5 : 0.0) : (allowNoHistory ? 0.5 : 0.0)
    p23_down_score := (sameDir + oppFail) / 2.0

bool cross2_3_Bull = smartMode ? (p23_rawUp and not na(p23_up_score) and p23_up_score >= smartThreshold) : p23_rawUp
bool cross2_3_Bear = smartMode ? (p23_rawDown and not na(p23_down_score) and p23_down_score >= smartThreshold) : p23_rawDown

// --- Pair 3-4 Cycle Tracking ---
var float p34_up_entry   = na
var float p34_up_peak    = na
var float p34_up_trough  = na
var float p34_down_entry = na
var float p34_down_peak  = na
var float p34_down_trough= na
var float p34_last_up_net   = na
var float p34_last_down_net = na
var int   p34_track = 0

if p34_track == 1
    p34_up_peak   := math.max(nz(p34_up_peak), high)
    p34_up_trough := math.min(nz(p34_up_trough), low)
else if p34_track == 2
    p34_down_peak   := math.max(nz(p34_down_peak), high)
    p34_down_trough := math.min(nz(p34_down_trough), low)

bool p34_rawUp   = not na(ma4) and ta.crossover(ma3, ma4)
bool p34_rawDown = not na(ma4) and ta.crossunder(ma3, ma4)

if p34_rawUp
    if p34_track == 2
        float d_move = (p34_down_entry - nz(p34_down_trough)) / p34_down_entry
        float d_dd   = (nz(p34_down_peak) - p34_down_entry) / p34_down_entry
        p34_last_down_net := d_move - d_dd * 0.5
    p34_track     := 1
    p34_up_entry  := close
    p34_up_peak   := high
    p34_up_trough := low

if p34_rawDown
    if p34_track == 1
        float u_move = (nz(p34_up_peak) - p34_up_entry) / p34_up_entry
        float u_dd   = (p34_up_entry - nz(p34_up_trough)) / p34_up_entry
        p34_last_up_net := u_move - u_dd * 0.5
    p34_track       := 2
    p34_down_entry  := close
    p34_down_peak   := high
    p34_down_trough := low

float p34_up_score   = na
float p34_down_score = na

if p34_rawUp
    bool hasUp   = not na(p34_last_up_net)
    bool hasDown = not na(p34_last_down_net)
    float sameDir = hasUp   ? (p34_last_up_net > 0.005 ? 1.0 : p34_last_up_net > 0.0 ? 0.5 : 0.0) : (allowNoHistory ? 0.5 : 0.0)
    float oppFail = hasDown ? (p34_last_down_net < -0.005 ? 1.0 : p34_last_down_net < 0.0 ? 0.5 : 0.0) : (allowNoHistory ? 0.5 : 0.0)
    p34_up_score := (sameDir + oppFail) / 2.0

if p34_rawDown
    bool hasUp   = not na(p34_last_up_net)
    bool hasDown = not na(p34_last_down_net)
    float sameDir = hasDown ? (p34_last_down_net > 0.005 ? 1.0 : p34_last_down_net > 0.0 ? 0.5 : 0.0) : (allowNoHistory ? 0.5 : 0.0)
    float oppFail = hasUp   ? (p34_last_up_net < -0.005 ? 1.0 : p34_last_up_net < 0.0 ? 0.5 : 0.0) : (allowNoHistory ? 0.5 : 0.0)
    p34_down_score := (sameDir + oppFail) / 2.0

bool cross3_4_Bull = smartMode ? (p34_rawUp and not na(p34_up_score) and p34_up_score >= smartThreshold) : p34_rawUp
bool cross3_4_Bear = smartMode ? (p34_rawDown and not na(p34_down_score) and p34_down_score >= smartThreshold) : p34_rawDown

// ============================================================================
//  TREND IDENTIFICATION LOGIC
// ============================================================================

getMAByIndex(idx) =>
    float v = na
    if idx == 1
        v := ma1
    else if idx == 2
        v := ma2
    else if idx == 3
        v := ma3
    else if idx == 4
        v := ma4
    v

// --- Strict Hierarchy Mode ---
isStrictBullish = ma1 > ma2 and (na(ma3) or ma2 > ma3) and (na(ma4) or ma3 > ma4)
isStrictBearish = ma1 < ma2 and (na(ma3) or ma2 < ma3) and (na(ma4) or ma3 < ma4)

// --- Custom Pairs Mode ---
p1f = getMAByIndex(pair1Fast)
p1s = getMAByIndex(pair1Slow)
pair1Bull = pair1Enable and not na(p1f) and not na(p1s) ? (pair1Cond == "Fast > Slow" ? p1f > p1s : p1f < p1s) : true
pair1Bear = pair1Enable and not na(p1f) and not na(p1s) ? (pair1Cond == "Fast > Slow" ? p1f < p1s : p1f > p1s) : true

p2f = getMAByIndex(pair2Fast)
p2s = getMAByIndex(pair2Slow)
pair2Bull = pair2Enable and not na(p2f) and not na(p2s) ? (pair2Cond == "Fast > Slow" ? p2f > p2s : p2f < p2s) : true
pair2Bear = pair2Enable and not na(p2f) and not na(p2s) ? (pair2Cond == "Fast > Slow" ? p2f < p2s : p2f > p2s) : true

p3f = getMAByIndex(pair3Fast)
p3s = getMAByIndex(pair3Slow)
pair3Bull = pair3Enable and not na(p3f) and not na(p3s) ? (pair3Cond == "Fast > Slow" ? p3f > p3s : p3f < p3s) : true
pair3Bear = pair3Enable and not na(p3f) and not na(p3s) ? (pair3Cond == "Fast > Slow" ? p3f < p3s : p3f > p3s) : true

isCustomBullish = pair1Bull and pair2Bull and pair3Bull
isCustomBearish = pair1Bear and pair2Bear and pair3Bear

// --- Weighted Score Mode ---
score1 = pair1Enable and not na(p1f) and not na(p1s) ? (p1f > p1s ? 1 : -1) : 0
score2 = pair2Enable and not na(p2f) and not na(p2s) ? (p2f > p2s ? 1 : -1) : 0
score3 = pair3Enable and not na(p3f) and not na(p3s) ? (p3f > p3s ? 1 : -1) : 0
totalScore = score1 + score2 + score3
isWeightedBullish = totalScore >= weightThreshold
isWeightedBearish = totalScore <= -weightThreshold

// --- Final Trend State ---
trendBullish = trendMode == "Strict Hierarchy" ? isStrictBullish : trendMode == "Custom Pairs" ? isCustomBullish : isWeightedBullish
trendBearish = trendMode == "Strict Hierarchy" ? isStrictBearish : trendMode == "Custom Pairs" ? isCustomBearish : isWeightedBearish
trendNeutral = not trendBullish and not trendBearish

// ============================================================================
//  VISUALIZATION
// ============================================================================

bgColor = showBg ? (trendBullish ? color.new(#00C853, 92) : trendBearish ? color.new(#FF1744, 92) : color.new(#78909C, 92)) : na
bgcolor(bgColor, title="Trend Background")

p1 = plot(ma1, title="MA 1", color=ma1Color, linewidth=ma1Width, style=plot.style_line)
p2 = plot(ma2, title="MA 2", color=ma2Color, linewidth=ma2Width, style=plot.style_line)
p3 = plot(ma3, title="MA 3", color=ma3Color, linewidth=ma3Width, style=plot.style_line)
p4 = plot(ma4, title="MA 4", color=ma4Color, linewidth=ma4Width, style=plot.style_line)

fill(p1, p2, color=showFills and not na(ma1) and not na(ma2) ? (ma1 > ma2 ? color.new(#00E5FF, 85) : color.new(#FF5252, 85)) : na, title="Fill 1-2")
fill(p2, p3, color=showFills and not na(ma2) and not na(ma3) ? (ma2 > ma3 ? color.new(#00E5FF, 90) : color.new(#FF5252, 90)) : na, title="Fill 2-3")
fill(p3, p4, color=showFills and not na(ma3) and not na(ma4) ? (ma3 > ma4 ? color.new(#00E5FF, 90) : color.new(#FF5252, 90)) : na, title="Fill 3-4")

// --- Pair 1-2 Signals (quality-differentiated) ---
plotshape(showSignals and cross1_2_Bull, title="Cross 1>2 Bull", location=location.belowbar, color=color.new(#00E676, 0), style=shape.triangleup, size=size.small, text="1▲2", textcolor=color.white)
plotshape(showSignals and cross1_2_Bear, title="Cross 1<2 Bear", location=location.abovebar, color=color.new(#FF1744, 0), style=shape.triangledown, size=size.small, text="1▼2", textcolor=color.white)

// --- Pair 2-3 Signals ---
plotshape(showSignals and cross2_3_Bull, title="Cross 2>3 Bull", location=location.belowbar, color=color.new(#00E676, 20), style=shape.triangleup, size=size.tiny, text="2▲3", textcolor=color.white)
plotshape(showSignals and cross2_3_Bear, title="Cross 2<3 Bear", location=location.abovebar, color=color.new(#FF1744, 20), style=shape.triangledown, size=size.tiny, text="2▼3", textcolor=color.white)

// --- Pair 3-4 Signals ---
plotshape(showSignals and cross3_4_Bull, title="Cross 3>4 Bull", location=location.belowbar, color=color.new(#00E676, 40), style=shape.triangleup, size=size.tiny, text="3▲4", textcolor=color.white)
plotshape(showSignals and cross3_4_Bear, title="Cross 3<4 Bear", location=location.abovebar, color=color.new(#FF1744, 40), style=shape.triangledown, size=size.tiny, text="3▼4", textcolor=color.white)


// ============================================================================
//  ALERTS
// ============================================================================

alertcondition(cross1_2_Bull, title="🟢 MA1 Crosses Above MA2 (Smart)", message='{"alert":"MA1 Smart Cross Above MA2","score":{{p12_up_score}},"price":{{close}}}')
alertcondition(cross1_2_Bear, title="🔴 MA1 Crosses Below MA2 (Smart)", message='{"alert":"MA1 Smart Cross Below MA2","score":{{p12_down_score}},"price":{{close}}}')
alertcondition(cross2_3_Bull, title="🟢 MA2 Crosses Above MA3 (Smart)", message='{"alert":"MA2 Smart Cross Above MA3","score":{{p23_up_score}},"price":{{close}}}')
alertcondition(cross2_3_Bear, title="🔴 MA2 Crosses Below MA3 (Smart)", message='{"alert":"MA2 Smart Cross Below MA3","score":{{p23_down_score}},"price":{{close}}}')
alertcondition(cross3_4_Bull, title="🟢 MA3 Crosses Above MA4 (Smart)", message='{"alert":"MA3 Smart Cross Above MA4","score":{{p34_up_score}},"price":{{close}}}')
alertcondition(cross3_4_Bear, title="🔴 MA3 Crosses Below MA4 (Smart)", message='{"alert":"MA3 Smart Cross Below MA4","score":{{p34_down_score}},"price":{{close}}}')
alertcondition(trendBullish and not trendBullish[1], title="🟢 Bullish Trend Start", message='{"alert":"Bullish Trend Start","price":{{close}}}')
alertcondition(trendBearish and not trendBearish[1], title="🔴 Bearish Trend Start", message='{"alert":"Bearish Trend Start","price":{{close}}}')
alertcondition(trendNeutral and not trendNeutral[1], title="⚪ Trend Neutral", message='{"alert":"Trend Neutral","price":{{close}}}')
````
