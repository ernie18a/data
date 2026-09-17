<!-- tradingview-pine-id: PUB;53321305baab4b4f9e1bff67055402be -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# IQR Risk-to-Reward & Dynamic Targets [MantisAlgo]

Source: https://www.tradingview.com/script/hqBRfxAn-IQR-Risk-to-Reward-Dynamic-Targets-MantisAlgo/

## Description

IQR Risk-to-Reward & Dynamic Targets combines empirical quartile statistics with structural liquidity analysis to identify setups with favorable market-derived risk-to-reward. Instead of assigning arbitrary profit targets such as fixed 2× risk multiples, the indicator divides recent price action into Q1 (25th percentile), Q2 (Median), and Q3 (75th percentile), together with 1.5×IQR statistical outlier boundaries.

These statistical value zones are combined with opposing swing liquidity to calculate the available True Risk-to-Reward Ratio before a setup is displayed. Each qualified setup automatically projects Entry, Structural Stop Loss, Take Profit 1, Take Profit 2, and the resulting True R:R directly on the chart.

[image]https://www.tradingview.com/x/PUavRNyI/[/image]

🟢 IQR FAIR VALUE STRUCTURE

The Interquartile Range represents the middle 50% of the recent price distribution:

IQR = Q3 − Q1
Q1 = 25th Percentile  
Q2 = 50th Percentile (Median)  
Q3 = 75th Percentile

When price remains primarily between Q1 and Q3, the market is trading inside its recent statistical value region and tends to rotate around the Median. When price extends beyond an outer quartile or IQR outlier region and subsequently reclaims the Median Wave, the indicator evaluates whether sufficient structural space exists for a move toward opposing liquidity.

This creates two broad market conditions:
• Equilibrium / Mean-Reversion — Price remains within the Q1–Q3 value region and rotates around the Median.  
• Expansion / Reclaim — Price extends outside statistical value, then reclaims the Median with sufficient space toward opposing liquidity.

🟢 SIGNALS & TRUE R:R GATE

The core trigger follows a simple sweep-and-reclaim sequence.
For a Long setup, price must first sweep or touch the Lower IQR Band within the recent bars. The signal is then evaluated when price crosses back above the Median Wave and the reclaim candle closes above it.
For a Short setup, price must first sweep or touch the Upper IQR Band. The signal is evaluated when price subsequently crosses back below the Median Wave and the reclaim candle closes below it.

Long: Lower Band Sweep → Median Reclaim → Confirmed Close  
Short: Upper Band Sweep → Median Reclaim → Confirmed Close

The reclaim candle becomes the Entry only when volume is sufficiently active, the signal cooldown has been satisfied, and the available True R:R meets or exceeds the selected minimum threshold.
True R:R = Target Distance / Invalidation Distance
Target Distance = |TP2 − Entry|  
Invalidation Distance = |Entry − SL|
If True R:R is below the selected threshold, the setup is suppressed. If it meets or exceeds the threshold, the trigger triangle and complete Entry / SL / TP1 / TP2 structure are displayed.

🟢 DYNAMIC TARGET STRUCTURE

Each qualified setup contains four objective levels:
Entry — The exact closing price of the confirmed trigger candle.
Stop Loss — The structural extreme associated with the preceding sweep. For Long setups, the relevant sweep low is used; for Short setups, the relevant sweep high is used. A break beyond this level invalidates the setup structure.
Take Profit 1 — TP1 is based on the opposing quartile boundary: Q3 for Long setups and Q1 for Short setups. It represents the first statistical mean-reversion objective.
Take Profit 2 — TP2 is based on opposing structural liquidity: swing-high liquidity for Long setups and swing-low liquidity for Short setups. Because TP2 is derived from actual chart structure rather than a predetermined fixed multiple, the resulting True R:R changes naturally from setup to setup.

[image]https://www.tradingview.com/x/mhdBKc7c/[/image]

🟢 IQR OUTLIER FENCES

The indicator also calculates traditional Box Plot outlier boundaries:

Lower Fence = Q1 − (1.5 × IQR)  
Upper Fence = Q3 + (1.5 × IQR)

These boundaries identify price observations that are unusually extended relative to the recent rolling distribution and provide additional context for statistical sweeps.

🟢 DYNAMIC MEDIAN WAVE

The central Median Wave is based on Q2 and smoothed using a two-pole SuperSmoother-style digital filter. Its purpose is to reduce short-term noise while remaining responsive to directional changes. The wave changes visual state according to its directional slope and acts as the primary reclaim reference for potential setups.

🟢 STATISTICAL BOX-PLOT PIVOTS

Confirmed structural swing pivots can display compact Box Plot brackets directly on the chart. Each bracket visualizes the local Q1 Lower Quartile, Q2 Median, Q3 Upper Quartile, and IQR outlier boundaries, making it easier to compare structural turning points with the surrounding statistical distribution.

🟢 STATISTICAL HUD

The optional top-right HUD provides a compact summary of the current statistical and structural state, allowing users to review the active distribution, directional context, and setup information without manually inspecting every plotted level.

🟢 SETTINGS

Quartile Sample Window — 34: Controls the rolling observation window used to calculate Q1, Q2, and Q3.
Outlier Whisker Multiplier — 1.5: Controls the IQR multiplier used to define the statistical outlier fences.
Structural Liquidity Lookback — 20: Controls the search window used to identify opposing swing liquidity for TP2.
Minimum True R:R Ratio — 2.0: Defines the minimum required target distance relative to structural risk. Higher values produce fewer but more selective setups.
Signal Cooldown — 6: Controls the minimum separation between consecutive signals.
Visual Settings: Show IQR Fair Value Cloud, Show Statistical Box-Plot Pins, Show Signal Trigger Triangles, Show Target Projection Rays, Max Historical Setups to Display, and Show Statistical HUD Dashboard.

🟢 INTERPRETATION

The indicator combines three elements: Statistical Location, Structural Invalidation, and Available Target Space. It does not assume that every statistical extreme will reverse or that every liquidity target will be reached.
Instead, it evaluates whether a confirmed statistical reclaim has enough remaining structural space relative to its invalidation risk to satisfy the selected True R:R requirement. The goal is to make signal timing, structural risk, and available market space directly visible on the chart rather than attaching arbitrary target multiples after a signal appears.

🟢 DISCLAIMER

This indicator is designed for technical analysis, quantitative research, and educational purposes only. It does not constitute financial advice. Historical statistical relationships do not guarantee future outcomes. Always apply appropriate risk management and position sizing.

---

## Source Code

````pine
// © 2026 MantisAlgo
// All rights reserved.
//@version=6
// Title: IQR Risk-to-Reward & Dynamic Targets [MantisAlgo]
// Kind: indicator
// Surface: overlay
// Signal: directional
// Universe: chart
// Repaint: bar_close
// Horizon: intraday
// Data: ohlcv
// Tags: Price_Action, Liquidity, Support_Resistance, Volatility, Signals, Alerts

indicator("IQR Risk-to-Reward & Dynamic Targets [MantisAlgo]", shorttitle="IQR R:R Targets", overlay=true, max_lines_count=500, max_labels_count=500)

// -----------------------------------------------------------------------------
// IQR Risk-to-Reward & Dynamic Targets [MantisAlgo]
// First-principles quantitative indicator grounding every price target and stop
// loss in descriptive statistics and structural liquidity pools:
// - Entry: Confirmed reclaim of Median (Q2) following a sweep into Discount (Q1)
// - Stop Loss: Anchored to the structural sweep low or 1.5*IQR Outlier Whisker
// - Targets: Anchored to opposing Premium boundary (Q3) and Swing Liquidity Highs
// - Risk-to-Reward Gate: Strictly calculates (Real Target - Entry) / (Entry - SL).
//   Only qualifies and displays setups with genuine mathematical edge (R:R >= minRR).
// -----------------------------------------------------------------------------

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 01 — Inputs
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grp_stat    = "Quartile Distribution & Structure"
sampleLen   = input.int(34, "Quartile Sample Window", minval=10, maxval=150, group=grp_stat, tooltip="Lookback window used to calculate empirical percentiles (Q1 25th, Q2 50th Median, Q3 75th)")
whiskerMult = input.float(1.5, "Outlier Whisker Multiplier", minval=1.0, maxval=3.0, step=0.1, group=grp_stat, tooltip="IQR multiplier for statistical outlier fences that define the structural invalidation boundary (default 1.5)")
liqLen      = input.int(20, "Structural Liquidity Lookback", minval=5, maxval=60, group=grp_stat, tooltip="Lookback window for locating opposing swing high/low liquidity pools as objective targets")

grp_risk    = "First-Principles Risk-Reward Gate"
minRR       = input.float(2.0, "Minimum True R:R Ratio", minval=1.0, maxval=5.0, step=0.25, group=grp_risk, tooltip="Minimum required ratio between structural target distance and invalidation risk. Setups failing this threshold are filtered out.")
cooldownLen = input.int(6, "Signal Cooldown (Bars)", minval=2, maxval=30, group=grp_risk, tooltip="Minimum bar separation between consecutive signals to avoid clustered executions")

grp_display     = "Visual Elements & Layout"
showCloud       = input.bool(true, "Show IQR Fair Value Cloud", group=grp_display, tooltip="Display the translucent Q1-Q3 fair value equilibrium envelope around the wave")
showSignals     = input.bool(true, "Show Signal Trigger Triangles", group=grp_display, tooltip="Display clean, non-intrusive directional triangles on confirmed trigger bars")
showLines       = input.bool(true, "Show Target Projection Rays", group=grp_display, tooltip="Draw thin, elegant Entry, Stop Loss, and Take Profit projection lines for setups")
maxHistory      = input.int(60, "Max Historical Setups to Display", minval=5, maxval=80, group=grp_display, tooltip="Number of past setups to keep target projection lines and labels on the chart (default 60, up to 80)")
showHud         = input.bool(true, "Show Statistical HUD Dashboard", group=grp_display, tooltip="Render the top-right metrics summary table")

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 02 — Constants and display settings
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bullColor       = color.new(#00E5FF, 0)
bearColor       = color.new(#FF2E63, 0)
bullCloudColor  = color.new(#00E5FF, 93)
bearCloudColor  = color.new(#FF2E63, 93)
neutralColor    = color.new(#787b86, 40)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 03 — Persistent state
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var line[]  historyLines       = array.new<line>()
var label[] historyLabels      = array.new<label>()

var int   lastSignalBarIndex = -100
var float lastExpectedRR     = 0.0
var int   totalSetupsCount   = 0

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 04 — Calculation and state functions
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SuperSmoother 2-Pole digital filter for smooth zero-lag trend trajectory
f_superSmoother(float src, int length) =>
    a1 = math.exp(-1.414 * 3.14159 / length)
    b1 = 2.0 * a1 * math.cos(1.414 * 180.0 / length * 3.14159 / 180.0)
    c2 = b1
    c3 = -a1 * a1
    c1 = 1.0 - c2 - c3
    var float s = na
    s := na(s[1]) ? src : c1 * (src + nz(src[1])) * 0.5 + c2 * nz(s[1]) + c3 * nz(s[2])
    s

// Computes empirical Interquartile Range (IQR) from raw price series
f_rollingIQR(int length) =>
    float[] pArr = array.new_float(0)
    for k = 0 to length - 1
        array.push(pArr, close[k])
    array.sort(pArr, order.ascending)
    q1Val = array.percentile_linear_interpolation(pArr, 25)
    q3Val = array.percentile_linear_interpolation(pArr, 75)
    q3Val - q1Val

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 05 — Runtime orchestration
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
medianWave = f_superSmoother(hlc3, 21)
waveSlope = medianWave - medianWave[1]

iqrRaw = f_rollingIQR(sampleLen)

smoothIQR = f_superSmoother(iqrRaw, 14)
upperBand = medianWave + (smoothIQR * 0.75)
lowerBand = medianWave - (smoothIQR * 0.75)
upperFence = medianWave + (smoothIQR * whiskerMult)
lowerFence = medianWave - (smoothIQR * whiskerMult)

// Opposing Structural Liquidity Pools (Objective Grounding)
swingLiquidityHigh = ta.highest(high, liqLen)
swingLiquidityLow  = ta.lowest(low, liqLen)

avgVol = ta.sma(volume, 20)
isVolActive = volume >= (avgVol * 0.75)

bullSetupConfirmed = false
bearSetupConfirmed = false

float setupEntry = na
float setupSL    = na
float setupTP1   = na
float setupTP2   = na
float setupTrueRR = 0.0

canTrigger = (bar_index - lastSignalBarIndex) >= cooldownLen

// ─────────────────────────────────────────────────────────────────────────────
// Bullish Setup Logic & First-Principles Grounding:
// 1. Why Entry? Price swept discount (below lowerBand/lowerFence) and reclaimed Median wave.
// 2. Why SL? Invalidation anchored to sweep low (ta.lowest(low, 3)). If breached, thesis fails.
// 3. Why TP1? Q3 Fair Value Premium boundary (50% scale-out level).
// 4. Why TP2? Opposing structural high liquidity pool or Upper statistical fence.
// 5. Why Triggered? True Grounded R:R = (TP2 - Entry) / (Entry - SL) >= minRR.
// ─────────────────────────────────────────────────────────────────────────────
bullSweep = (low[1] <= lowerBand[1] or low[2] <= lowerBand[2] or low[3] <= lowerBand[3] or low <= lowerFence)
bullReclaim = (close > medianWave and close[1] <= medianWave[1])

if bullSweep and bullReclaim and isVolActive and canTrigger and barstate.isconfirmed
    // 1. Structural Stop Loss: Local sweep low
    rawSL = ta.lowest(low, 4)
    riskDist = close - rawSL
    
    // 2. Objective Structural Targets
    tp1Price = upperBand
    tp2Price = math.max(upperFence, swingLiquidityHigh[1])
    rewardDist = tp2Price - close
    
    // 3. True Calculated R:R
    if riskDist > 0 and rewardDist > 0
        calcRR = rewardDist / riskDist
        // Strict Grounded Gate: Only pass if natural market structure offers sufficient R:R
        if calcRR >= minRR
            bullSetupConfirmed := true
            setupEntry   := close
            setupSL      := rawSL
            setupTP1     := tp1Price
            setupTP2     := tp2Price
            setupTrueRR  := calcRR

// ─────────────────────────────────────────────────────────────────────────────
// Bearish Setup Logic & First-Principles Grounding:
// 1. Why Entry? Price swept premium (above upperBand/upperFence) and broke below Median wave.
// 2. Why SL? Invalidation anchored to sweep high (ta.highest(high, 3)). If breached, thesis fails.
// 3. Why TP1? Q1 Fair Value Discount boundary (50% scale-out level).
// 4. Why TP2? Opposing structural low liquidity pool or Lower statistical fence.
// 5. Why Triggered? True Grounded R:R = (Entry - TP2) / (SL - Entry) >= minRR.
// ─────────────────────────────────────────────────────────────────────────────
bearSweep = (high[1] >= upperBand[1] or high[2] >= upperBand[2] or high[3] >= upperBand[3] or high >= upperFence)
bearReclaim = (close < medianWave and close[1] >= medianWave[1])

if bearSweep and bearReclaim and isVolActive and canTrigger and barstate.isconfirmed
    // 1. Structural Stop Loss: Local sweep high
    rawSL = ta.highest(high, 4)
    riskDist = rawSL - close
    
    // 2. Objective Structural Targets
    tp1Price = lowerBand
    tp2Price = math.min(lowerFence, swingLiquidityLow[1])
    rewardDist = close - tp2Price
    
    // 3. True Calculated R:R
    if riskDist > 0 and rewardDist > 0
        calcRR = rewardDist / riskDist
        // Strict Grounded Gate: Only pass if natural market structure offers sufficient R:R
        if calcRR >= minRR
            bearSetupConfirmed := true
            setupEntry   := close
            setupSL      := rawSL
            setupTP1     := tp1Price
            setupTP2     := tp2Price
            setupTrueRR  := calcRR

// Update State
if bullSetupConfirmed or bearSetupConfirmed
    lastSignalBarIndex := bar_index
    lastExpectedRR     := setupTrueRR
    totalSetupsCount   := totalSetupsCount + 1

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 06 — Rendering and drawing lifecycle
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 1. Dynamic Median Trend Wave
waveColor = waveSlope > 0 ? bullColor : (waveSlope < 0 ? bearColor : neutralColor)
p_wave = plot(medianWave, "Median Dynamic Wave", color=waveColor, linewidth=2)

// 2. Translucent IQR Fair Value Envelope (Q1 to Q3)
p_upper = plot(showCloud ? upperBand : na, "IQR Value Band (Q3)", color=color.new(bullColor, 60), linewidth=1, style=plot.style_line)
p_lower = plot(showCloud ? lowerBand : na, "IQR Value Band (Q1)", color=color.new(bearColor, 60), linewidth=1, style=plot.style_line)

fill(p_wave, p_upper, color=showCloud ? bullCloudColor : na, title="IQR Upper Fair Value Cloud")
fill(p_wave, p_lower, color=showCloud ? bearCloudColor : na, title="IQR Lower Fair Value Cloud")

// 3. Directional Signal Triangles
plotshape(showSignals and bullSetupConfirmed, title="Bullish Setup Trigger", style=shape.triangleup, location=location.belowbar, color=color.new(#089981, 0), size=size.small, offset=0)
plotshape(showSignals and bearSetupConfirmed, title="Bearish Setup Trigger", style=shape.triangledown, location=location.abovebar, color=color.new(#f23645, 0), size=size.small, offset=0)

// 4. Objective Historical Target Projection Rays with Clear Dual Labels
if (bullSetupConfirmed or bearSetupConfirmed) and showLines
    projLen = 14
    lEntry = line.new(x1=bar_index, y1=setupEntry, x2=bar_index + projLen, y2=setupEntry, color=color.new(color.white, 50), width=1, style=line.style_dotted)
    lSl    = line.new(x1=bar_index, y1=setupSL, x2=bar_index + projLen, y2=setupSL, color=color.new(bearColor, 35), width=1, style=line.style_solid)
    lTp1   = line.new(x1=bar_index, y1=setupTP1, x2=bar_index + projLen, y2=setupTP1, color=color.new(bullColor, 50), width=1, style=line.style_dotted)
    lTp2   = line.new(x1=bar_index, y1=setupTP2, x2=bar_index + projLen, y2=setupTP2, color=color.new(bullColor, 20), width=2, style=line.style_solid)
    
    lblSl  = label.new(x=bar_index + projLen, y=setupSL, text="SL", color=color.new(#000000, 100), textcolor=bearColor, style=label.style_label_left, size=size.small)
    lblTp1 = label.new(x=bar_index + projLen, y=setupTP1, text="TP1 (50%)", color=color.new(#000000, 100), textcolor=color.new(bullColor, 20), style=label.style_label_left, size=size.small)
    lblTp2 = label.new(x=bar_index + projLen, y=setupTP2, text="TP2 [1:" + str.tostring(setupTrueRR, "#.#") + "]", color=color.new(#000000, 100), textcolor=bullColor, style=label.style_label_left, size=size.small)
    
    array.push(historyLines, lEntry)
    array.push(historyLines, lSl)
    array.push(historyLines, lTp1)
    array.push(historyLines, lTp2)
    array.push(historyLabels, lblSl)
    array.push(historyLabels, lblTp1)
    array.push(historyLabels, lblTp2)

// Prune oldest historical drawings beyond user limit
while array.size(historyLines) > (maxHistory * 4)
    line.delete(array.shift(historyLines))
while array.size(historyLabels) > (maxHistory * 3)
    label.delete(array.shift(historyLabels))

// 5. Modern Terminal HUD Table
var table hudTable = table.new(position.top_right, 2, 4, bgcolor=color.new(#131722, 10), border_color=color.new(#363c4e, 30), border_width=1)

if showHud and barstate.islast
    regimeStr = close > upperBand ? "Premium" : (close < lowerBand ? "Discount" : "Equilibrium")
    regimeColor = close > upperBand ? color.new(#00E5FF, 0) : (close < lowerBand ? color.new(#FFA000, 0) : color.new(#2962ff, 0))
    
    table.cell(hudTable, 0, 0, "Regime", bgcolor=color.new(#1e222d, 20), text_color=color.gray, text_size=size.small)
    table.cell(hudTable, 1, 0, regimeStr, bgcolor=color.new(#1e222d, 20), text_color=regimeColor, text_size=size.small)
    
    table.cell(hudTable, 0, 1, "IQR Width", bgcolor=color.new(#1e222d, 20), text_color=color.gray, text_size=size.small)
    table.cell(hudTable, 1, 1, str.tostring(smoothIQR, "#.##"), bgcolor=color.new(#1e222d, 20), text_color=color.white, text_size=size.small)
    
    table.cell(hudTable, 0, 2, "Last True R:R", bgcolor=color.new(#1e222d, 20), text_color=color.gray, text_size=size.small)
    table.cell(hudTable, 1, 2, lastExpectedRR > 0 ? "1:" + str.tostring(lastExpectedRR, "#.#") : "Standby", bgcolor=color.new(#1e222d, 20), text_color=lastExpectedRR >= minRR ? color.green : color.gray, text_size=size.small)
    
    table.cell(hudTable, 0, 3, "Total Setups", bgcolor=color.new(#1e222d, 20), text_color=color.gray, text_size=size.small)
    table.cell(hudTable, 1, 3, str.tostring(totalSetupsCount), bgcolor=color.new(#1e222d, 20), text_color=color.white, text_size=size.small)

// 6. Alerts
alertcondition(bullSetupConfirmed, title="Bullish IQR Setup", message="Bullish IQR Grounded Setup confirmed with favorable Risk:Reward ratio.")
alertcondition(bearSetupConfirmed, title="Bearish IQR Setup", message="Bearish IQR Grounded Setup confirmed with favorable Risk:Reward ratio.")
````
