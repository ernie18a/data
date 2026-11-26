# Volatility Squeeze Oscillator [JOAT]

- url: https://www.tradingview.com/script/3iC1QrdU-Volatility-Squeeze-Oscillator-JOAT/
- type: indicator
- pine_id: PUB;0fee9c0881804e21a896c524cb4aa085
- version: 1.0

## Description

[b]Volatility Squeeze Oscillator [JOAT][/b]

[b]Introduction[/b]

Volatility does not move randomly. It compresses, coils, and then releases — and the magnitude of the release is frequently proportional to the depth and duration of the compression. This relationship between volatility contraction and subsequent expansion is one of the most durable patterns in market behavior across all asset classes and timeframes. The Volatility Squeeze Oscillator [JOAT] is built to quantify this relationship with precision, using a multi-layered analysis framework that goes well beyond standard squeeze detection.

At its core, the indicator uses an ATR compression ratio engine to measure the difference between a short-term and long-term ATR. When the short-term ATR is smaller than the long-term ATR, volatility is contracting — the market is coiling. When the short-term ATR expands beyond the long-term reference, the coil is releasing. This compression differential is normalized against the high-low range, making the oscillator comparable across different instruments and volatility regimes.

Three additional analytical layers are stacked on top of the compression engine. A cumulative delta proxy estimates buying versus selling pressure within each bar using range-based calculations — no Level 2 or order flow data required. A volume RSI module measures whether the current volume is elevated relative to its own history, providing a confluence filter that separates high-conviction from low-conviction squeeze releases. And a statistical deviation band system built on a 200-bar lookback marks the historically significant boundaries of the squeeze oscillator's own distribution, so traders can identify not just whether a squeeze is forming, but how extreme it is relative to its own history.

[image]https://www.tradingview.com/x/PLGfsNAY/[/image]

[b]Core Concepts[/b]

[b]1. ATR Compression Ratio Engine[/b]

The compression ratio is derived from two ATR calculations at different smoothing periods. Both use EMA smoothing rather than RMA (Wilder's method) to produce a more responsive and visually cleaner oscillator. The short-term ATR reflects current volatility conditions. The long-term ATR (calculated at double the base period) establishes the reference level representing the recent historical norm. The difference between these two — long minus short — is the squeeze value: positive when the market is contracting (short ATR below long-term baseline), negative when expanding.

[pine]
trueRange = ta.tr(true)
atrShort = ta.ema(trueRange, len)
atrLong = ta.ema(atrShort, len * 2)
sqzRaw = atrLong - atrShort
hlRange = ta.highest(high, len) - ta.lowest(low, len)
sqzVal = hlRange > 0 ? sqzRaw / hlRange : 0
[/pine]

Normalizing by the HL range makes the oscillator dimensionless — a squeeze value of 0.3 carries the same meaning whether you are analyzing a $1 stock or a $50,000 Bitcoin contract. The signal line is an EMA of the squeeze value, used to detect the inflection point where the squeeze begins to build (sqzVal crossing above sqzSig) or release (sqzVal crossing below sqzSig).

[b]2. Hyper-Squeeze Detection[/b]

A hyper-squeeze occurs when the squeeze value is not merely positive (compressing) but is actively rising for N consecutive bars — indicating an accelerating contraction rather than a stable one. Accelerating compression is particularly significant because it suggests market participants are increasingly reducing their activity, creating a coiled spring effect where the eventual release may be more forceful.

[pine]
hyperSqz = sqzVal > 0 and ta.rising(sqzVal, hyperLen)
[/pine]

When a hyper-squeeze is active, a violet tint is overlaid on the oscillator background in addition to the regular delta-driven background color. The dashboard updates the hyper squeeze row to ACTIVE status. This dual visual layer makes extended compression phases immediately distinguishable from ordinary positive squeeze readings.

[b]3. Cumulative Delta Proxy[/b]

Order flow analysis — understanding whether buyers or sellers are dominant within a given period — typically requires tick-level data or exchange-provided volume breakdown. This indicator constructs a proxy for cumulative delta using bar-level range analysis, making the information accessible without any data feed requirements.

[pine]
barRange = high - low
bullPress = barRange > 0 ? (close - low) / barRange : 0.5
bearPress = barRange > 0 ? (high - close) / barRange : 0.5
deltaBar = bullPress - bearPress
deltaSma = ta.sma(deltaBar, deltaLen)
deltaPos = deltaSma > 0
[/pine]

A close near the high of the bar implies buyers dominated (bull pressure near 1.0). A close near the low implies sellers dominated (bear pressure near 1.0). The difference, smoothed over a configurable window, produces a normalized delta reading. When delta is positive during a squeeze, the compressed volatility is accumulating with a bullish lean. When negative, with a bearish lean. This directional information is used both in the histogram coloring (alpha derived from delta conviction) and in dashboard output.

[b]4. Volume RSI Confluence[/b]

Volume RSI applies the standard RSI momentum formula to the volume series rather than price. This produces a normalized [0,100] reading of whether current volume is elevated or depressed relative to its recent distribution. A high volume RSI (default threshold: 65) during a squeeze release indicates that the expansion is occurring on above-average participation — a meaningful distinction from low-volume releases that can quickly reverse.

[pine]
volRsi = ta.rsi(volume, 14)
highVol = volRsi > volThresh
[/pine]

The volume RSI value and status are displayed in the dashboard. Alert conditions include a "high-volume release" alert specifically when both a squeeze release signal and elevated volume RSI occur simultaneously, providing a higher-conviction composite signal.

[b]5. Statistical Deviation Bands[/b]

Rather than using fixed threshold lines at arbitrary values, the oscillator's own distribution is analyzed statistically using a 200-bar lookback. The mean and one and two standard deviation levels of the squeeze value over this window establish dynamically updating bands. These bands are filled with a gradient and rendered at adaptive transparency based on the current Z-score — as the oscillator approaches the 2σ band, the fill becomes more opaque, visually emphasizing extreme readings.

[pine]
sqzMean = ta.sma(sqzVal, statLen)
sqzStd = ta.stdev(sqzVal, statLen)
band1Up = sqzMean + sqzStd
band2Up = sqzMean + 2 * sqzStd
band1Dn = sqzMean - sqzStd
band2Dn = sqzMean - 2 * sqzStd
zScore = sqzStd > 0 ? (sqzVal - sqzMean) / sqzStd : 0
[/pine]

A squeeze reading above the 2σ upper band is historically anomalous compression — significantly above what has been typical over the prior 200 bars. Such readings often precede the most explosive release moves.

[b]6. Histogram Coloring and Background Rendering[/b]

The histogram bar colors encode two simultaneous dimensions. The base color is red when the squeeze is building (sqzVal above sqzSig) and teal when releasing (sqzVal below sqzSig). The alpha channel of each bar is modulated by the absolute value of the delta conviction — high delta conviction produces more saturated colors, while low-conviction delta (price closing near the bar midpoint) produces more transparent bars. The background color is a 93% alpha gradient driven entirely by delta: teal for bullish delta, red for bearish delta, with the hyper-squeeze violet tint layered on top when active.

[b]Features[/b]

[list]
[*][b]ATR Compression Ratio Engine:[/b] Measures the difference between short-term and long-term EMA-smoothed ATR, normalized by HL range for cross-instrument comparability.
[*][b]Signal Line:[/b] EMA of the squeeze value provides the crossover reference for detecting compression buildup and release initiation.
[*][b]Hyper-Squeeze Detection:[/b] Identifies accelerating compression phases where the squeeze is rising for N consecutive bars simultaneously.
[*][b]Cumulative Delta Proxy:[/b] Bar-range-based buying and selling pressure estimate, smoothed and normalized, requiring no Level 2 data.
[*][b]Volume RSI Confluence:[/b] RSI applied to volume series identifies above-average participation, separating high-conviction releases from low-volume ones.
[*][b]Statistical Deviation Bands:[/b] 200-bar mean and sigma levels with gradient fill and adaptive transparency based on Z-score position.
[*][b]Delta-Driven Alpha Histogram:[/b] Histogram color and opacity encode both squeeze direction and delta conviction simultaneously.
[*][b]Layered Background Coloring:[/b] Delta-based background with hyper-squeeze overlay provides immediate pane-level context without requiring close inspection.
[*][b]Signal Markers:[/b] Circle markers at oscillator bottom on squeeze cross and release cross events.
[*][b]Seven-Row Dashboard:[/b] Real-time status covering state, hyper squeeze, volume RSI, delta bias, Z-score, and squeeze value.
[*][b]Four Alert Conditions:[/b] Squeeze building, release detected, hyper squeeze active, and high-volume release composite signal.
[/list]

[b]Input Parameters[/b]

[b]ATR Settings:[/b]
[list]
[*]Base Length: Period for short-term ATR EMA and HL range lookback (default: 20)
[/list]

[b]Hyper-Squeeze Settings:[/b]
[list]
[*]Hyper Squeeze Consecutive Bars: Number of consecutive rising bars required for hyper-squeeze (default: 3)
[/list]

[b]Delta Settings:[/b]
[list]
[*]Delta Smoothing Window: SMA period for the delta bar average (default: 10)
[/list]

[b]Volume RSI Settings:[/b]
[list]
[*]Volume RSI Period: RSI lookback applied to volume series (default: 14)
[*]Volume RSI Threshold: Level above which volume is considered elevated (default: 65)
[/list]

[b]Statistical Bands Settings:[/b]
[list]
[*]Statistical Lookback: Bar count for mean and standard deviation computation (default: 200)
[*]Show Bands: Toggle deviation band fills (default: true)
[/list]

[b]Display Settings:[/b]
[list]
[*]Show Background: Toggle delta and hyper-squeeze background coloring (default: true)
[*]Show Signal Markers: Toggle circle markers at squeeze and release crosses (default: true)
[*]Show Dashboard: Toggle the seven-row information table (default: true)
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Monitor the Squeeze State[/b]

The primary read from this oscillator is the current state displayed in the dashboard: SQUEEZING, RELAXING, or EXPANDING. Squeezing means the compression ratio is positive and rising — the market is actively coiling. Relaxing means the compression is positive but flattening or declining — the coil is beginning to unwind. Expanding means the oscillator has gone negative — volatility is actively expanding beyond the historical baseline. The transition from SQUEEZING to RELAXING is the early warning signal; the transition to EXPANDING is confirmation that the release has begun.

[b]Step 2: Watch for Hyper-Squeeze Conditions[/b]

When the dashboard shows HYPER SQUEEZE: ACTIVE and the chart shows the violet tint overlay, the compression is accelerating — each bar the market is coiling tighter. These conditions historically precede more forceful releases. In hyper-squeeze conditions, position sizing on the anticipated breakout can be considered carefully, as the magnitude of the release may be larger than during ordinary squeeze exits.

[b]Step 3: Check Delta Bias for Directional Lean[/b]

Before committing to a directional bias, check the delta row in the dashboard. Positive delta (bullish) during a squeeze indicates that even during compression, buyers have been closing bars near the upper portion of their range — a bullish accumulation signature. Negative delta (bearish) suggests the opposite. Delta bias does not guarantee direction, but it provides a useful lean when combined with the squeeze release signal.

[b]Step 4: Require Volume RSI Confluence on Release[/b]

Not all squeeze releases produce sustained moves. Low-volume releases frequently reverse within a few bars. The "High-Volume Release" alert fires only when both a release cross and elevated volume RSI (above threshold) occur simultaneously. Waiting for this composite signal before acting on a release — rather than responding to the release cross alone — filters out a meaningful number of false expansion signals in low-participation environments.

[image]https://www.tradingview.com/x/cbfK4LrO/[/image]

[b]Indicator Limitations[/b]

[list]
[*]The ATR compression ratio measures relative volatility contraction but cannot determine the direction of the eventual breakout. This indicator identifies when a release is likely, not which way price will move. Directional analysis must come from structure, trend, or other contextual tools.
[*]The delta proxy is a bar-level approximation of order flow. It does not access actual tick data, order book data, or trade-level information. In markets with high-frequency activity, the close-to-high/low ratio can systematically misrepresent actual buying and selling pressure.
[*]The statistical deviation bands require 200 bars to be fully seeded. On instruments or timeframes with limited history, or immediately after loading a new chart, the bands may produce unreliable readings until sufficient data is available.
[*]Volume RSI confluence is not applicable to instruments where volume data is unreliable, unavailable, or represents synthetic aggregation (some forex pairs, certain CFDs). In these cases, the volume RSI row should be treated as informational only.
[*]The hyper-squeeze condition measures consecutive rising bars in the squeeze value. This makes it sensitive to the base period setting — shorter periods produce more variable squeeze values, leading to more frequent interruptions of the consecutive count.
[*]This indicator operates entirely on the chart's native timeframe. It does not incorporate multi-timeframe squeeze data — a squeeze on a 15-minute chart may be occurring within the context of a much larger timeframe expansion that this indicator would not reflect.
[/list]

[b]Originality Statement[/b]

The Volatility Squeeze Oscillator is a purpose-built analytical instrument that combines techniques not previously assembled in this specific architecture.

[list]
[*]The ATR compression ratio engine — using EMA-smoothed ATR at the base period versus double the base period, normalized by the HL range — is an original squeeze quantification method. It differs from the widely used Lazybear TTM Squeeze (which measures Bollinger Band width versus Keltner Channel width) by operating entirely within the ATR framework with range normalization.
[*]The hyper-squeeze detection via ta.rising() on the already-positive squeeze value identifies accelerating compression as a distinct state separate from ordinary compression, a categorization not found in standard squeeze implementations.
[*]The cumulative delta proxy using bar-range ratios (close minus low divided by range for bull pressure; high minus close divided by range for bear pressure), smoothed and normalized, provides order-flow-inspired information without any data dependency beyond OHLC — an original application of range analysis.
[*]The integration of volume RSI as a confluence gate within the squeeze oscillator framework — not as a separate indicator but as an internal filter with dedicated dashboard output and composite alert conditions — is an original design choice.
[*]The statistical deviation band system applied to the squeeze oscillator's own values (using a 200-bar SMA and StDev of the squeeze value itself) to create adaptive significance thresholds is an original meta-statistical layer not found in comparable oscillators.
[/list]

[b]Disclaimer[/b]

The Volatility Squeeze Oscillator [JOAT] is provided for educational and informational purposes only. It is a technical analysis tool and does not constitute financial advice. Identifying squeeze conditions does not predict the direction or magnitude of subsequent price moves with any certainty. All trading involves risk of loss. Users are solely responsible for their own trading decisions. Please consider your individual risk tolerance and consult a licensed financial professional before engaging in any trading activity.

-Made with passion by officialjackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Volatility Squeeze Oscillator [JOAT]", shorttitle="VSO [JOAT]", overlay=false)

// ══════════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════════
grpSQ   = "Squeeze Engine"
sqLen   = input.int(14, "ATR Period",            group=grpSQ, minval=3)
smLen   = input.int(7,  "Smoothing Length",       group=grpSQ, minval=1)
sigLen  = input.int(14, "Signal EMA Length",      group=grpSQ, minval=3)
hSqLen  = input.int(5,  "Hyper-Squeeze Lookback", group=grpSQ, minval=2,
          tooltip="Consecutive rising bars for hyper-squeeze detection")

grpDelta = "Delta Proxy"
showDelta = input.bool(true, "Show Cumulative Delta", group=grpDelta)
deltaLen  = input.int(20, "Delta Lookback",       group=grpDelta, minval=5)

grpVol  = "Volume Confluence"
volRsiLen = input.int(14, "Volume RSI Period",    group=grpVol, minval=3)
volThresh = input.float(65.0, "Vol RSI Threshold", group=grpVol, minval=30, maxval=90)

grpBands = "Statistical Bands"
showBands = input.bool(true, "Show Deviation Bands", group=grpBands)
bandLen   = input.int(200, "Band Lookback", group=grpBands, minval=50, maxval=4999)

grpVis  = "Appearance"
sqzCol  = input.color(#ff3366, "Squeeze Color",  group=grpVis)
relCol  = input.color(#00e5aa, "Release Color",  group=grpVis)
neutCol = input.color(#8888cc, "Neutral Color",  group=grpVis)
showDash = input.bool(true, "Show Dashboard",    group=grpVis)

// ══════════════════════════════════════════════════════════════════
// CORE SQUEEZE ENGINE
// ATR compression ratio: measures how tight current ATR is vs longer EMA of ATR
// Positive = contracting (squeeze), Negative = expanding (release)
// ══════════════════════════════════════════════════════════════════
atr        = ta.ema(ta.tr(true), sqLen)
atrLong    = ta.ema(atr, sqLen * 2)
compression = atrLong - atr   // Positive = squeeze, negative = expansion

hlRange     = ta.ema(high - low, sqLen * 2)
sqzRaw      = compression / math.max(hlRange, 1e-10) * 100   // Dimensionless ratio
sqzVal      = ta.ema(sqzRaw, smLen)                           // Smoothed squeeze value
sqzSig      = ta.ema(sqzVal, sigLen)                          // Signal line

// ══════════════════════════════════════════════════════════════════
// CUMULATIVE DELTA PROXY (order flow approximation without Level 2)
// Uses close position within bar as a proxy for buying/selling pressure
// ══════════════════════════════════════════════════════════════════
barRange   = math.max(high - low, 1e-10)
bullPress  = (close - low)  / barRange   // 1.0 = pure bull candle
bearPress  = (high - close) / barRange   // 1.0 = pure bear candle
deltaBar   = bullPress - bearPress        // Net delta per bar [-1, 1]

// Normalized cumulative delta
cumDelta    = ta.sma(deltaBar, deltaLen)
cdNorm      = (cumDelta - ta.lowest(cumDelta, 60)) /
              math.max(ta.highest(cumDelta, 60) - ta.lowest(cumDelta, 60), 1e-10)
// cdNorm in [0,1] — above 0.5 = bull pressure, below 0.5 = bear

// ══════════════════════════════════════════════════════════════════
// VOLUME RSI CONFLUENCE
// ══════════════════════════════════════════════════════════════════
volRsi     = ta.rsi(volume, volRsiLen)
highVol    = volRsi > volThresh

// ══════════════════════════════════════════════════════════════════
// STATISTICAL DEVIATION BANDS
// Uses near-full-history stats to contextualize current squeeze level
// ══════════════════════════════════════════════════════════════════
cumMean    = ta.sma(sqzVal, bandLen)
cumStd     = ta.stdev(sqzVal, bandLen)

upper2     = cumMean + 2 * cumStd
upper1     = cumMean + 1 * cumStd
lower1     = cumMean - 1 * cumStd
lower2     = cumMean - 2 * cumStd

// Adaptive transparency for bands
zScore     = (sqzVal - cumMean) / math.max(cumStd, 1e-10)
bandTrans  = math.max(70, math.min(95, 95 - math.abs(zScore) * 5))

// ══════════════════════════════════════════════════════════════════
// SIGNAL DETECTION
// ══════════════════════════════════════════════════════════════════
sqzCross   = ta.crossover(sqzVal, sqzSig)    // Squeeze building
relCross   = ta.crossunder(sqzVal, sqzSig)   // Release/expansion

// Hyper-squeeze: consecutive bars of rising positive squeeze
hyperSqz   = sqzVal > 0 and ta.rising(sqzVal, hSqLen)

// Confirmed signals only
sqzSignal  = sqzCross and barstate.isconfirmed
relSignal  = relCross and barstate.isconfirmed
hyperSignal = hyperSqz and barstate.isconfirmed

// ══════════════════════════════════════════════════════════════════
// HISTOGRAM COLOR LOGIC
// Above signal = squeeze (red), below signal = release (teal)
// Opacity based on cumulative delta (brighter = more conviction)
// ══════════════════════════════════════════════════════════════════
histAlpha  = math.round((1.0 - math.abs(cdNorm - 0.5) * 2) * 50)
histCol    = sqzVal > sqzSig ? color.new(sqzCol, histAlpha) :
             color.new(relCol, histAlpha)

// ══════════════════════════════════════════════════════════════════
// PLOTS
// ══════════════════════════════════════════════════════════════════
sigPlot  = plot(sqzSig, "Signal",        color=color.new(color.white, 60), linewidth=1)
valPlot  = plot(sqzVal, "Squeeze Value", color=sqzVal > sqzSig ? color.new(sqzCol,0) : color.new(relCol,0), linewidth=2)

fill(sigPlot, valPlot,
     sqzVal, sqzSig,
     sqzVal > sqzSig ? color.new(sqzCol, 60) : color.new(color.white, 100),
     sqzVal > sqzSig ? color.new(color.white, 100) : color.new(relCol, 60),
     title="Squeeze Fill")

// Zero line reference
hline(0, "Zero", color=color.new(color.white, 80), linestyle=hline.style_dotted)

// Statistical deviation bands
pU2 = plot(showBands ? upper2 : na, "Upper 2σ", color=color.new(sqzCol, 80), linewidth=1, style=plot.style_circles)
pU1 = plot(showBands ? upper1 : na, "Upper 1σ", color=color.new(sqzCol, 90))
pL1 = plot(showBands ? lower1 : na, "Lower 1σ", color=color.new(relCol, 90))
pL2 = plot(showBands ? lower2 : na, "Lower 2σ", color=color.new(relCol, 80), linewidth=1, style=plot.style_circles)

fill(pU1, pU2, showBands ? color.from_gradient(sqzVal, -20, 20, color.new(sqzCol, math.round(bandTrans)), color.new(relCol, math.round(bandTrans))) : na, title="Upper Band")
fill(pL2, pL1, showBands ? color.from_gradient(sqzVal, -20, 20, color.new(sqzCol, math.round(bandTrans)), color.new(relCol, math.round(bandTrans))) : na, title="Lower Band")

// Cumulative delta as a subtle background fill
deltaColor = color.from_gradient(cdNorm, 0, 1, color.new(sqzCol, 93), color.new(relCol, 93))
bgcolor(showDelta ? deltaColor : na, title="Delta Background")

// Hyper-squeeze highlights
bgcolor(hyperSignal ? color.new(sqzCol, 88) : na, title="Hyper Squeeze")

// Signal markers
plotshape(sqzSignal,  "Squeeze",       shape.circle, location.bottom, color.new(sqzCol, 30), size=size.tiny)
plotshape(relSignal,  "Release",       shape.circle, location.bottom, color.new(relCol, 30), size=size.tiny)

// ══════════════════════════════════════════════════════════════════
// DASHBOARD
// ══════════════════════════════════════════════════════════════════
if barstate.islast and showDash
    var table dash = table.new(position.top_right, 2, 7,
                               bgcolor=color.new(#0a0a1e, 5),
                               border_width=1, border_color=color.new(color.white,80),
                               frame_color=color.new(color.white,70), frame_width=1)

    sqzState   = sqzVal > 0 ? (sqzVal > sqzSig ? "SQUEEZING" : "RELAXING") : "EXPANDING"
    sqzStateC  = sqzVal > 0 ? (sqzVal > sqzSig ? sqzCol : color.new(color.orange,0)) : relCol
    volState   = highVol ? "ELEVATED" : "NORMAL"
    volStateC  = highVol ? color.new(color.orange,0) : color.new(color.white,50)
    deltaState = cdNorm > 0.6 ? "BULLISH" : cdNorm < 0.4 ? "BEARISH" : "NEUTRAL"
    deltaC     = cdNorm > 0.6 ? relCol : cdNorm < 0.4 ? sqzCol : color.new(color.white,50)
    zTxt       = str.tostring(math.round(zScore, 2)) + "σ"
    zClr       = math.abs(zScore) > 2 ? color.new(color.orange,0) : color.new(color.white,50)

    table.cell(dash, 0, 0, "VSO · [JOAT]",    text_color=color.new(color.white,30), text_size=size.small, text_halign=text.align_center, bgcolor=color.new(#0d0d2a,0))
    table.cell(dash, 1, 0, "v1.0",           text_color=color.new(color.white,60), text_size=size.tiny,  text_halign=text.align_center, bgcolor=color.new(#0d0d2a,0))
    table.cell(dash, 0, 1, "State",          text_color=color.new(color.white,40), text_size=size.tiny)
    table.cell(dash, 1, 1, sqzState,         text_color=sqzStateC, text_size=size.tiny, text_halign=text.align_center)
    table.cell(dash, 0, 2, "Hyper Squeeze",  text_color=color.new(color.white,40), text_size=size.tiny)
    table.cell(dash, 1, 2, hyperSqz ? "ACTIVE" : "—", text_color=hyperSqz ? sqzCol : color.new(color.white,60), text_size=size.tiny, text_halign=text.align_center)
    table.cell(dash, 0, 3, "Volume RSI",     text_color=color.new(color.white,40), text_size=size.tiny)
    table.cell(dash, 1, 3, volState,         text_color=volStateC, text_size=size.tiny, text_halign=text.align_center)
    table.cell(dash, 0, 4, "Delta Bias",     text_color=color.new(color.white,40), text_size=size.tiny)
    table.cell(dash, 1, 4, deltaState,       text_color=deltaC, text_size=size.tiny, text_halign=text.align_center)
    table.cell(dash, 0, 5, "Z-Score",        text_color=color.new(color.white,40), text_size=size.tiny)
    table.cell(dash, 1, 5, zTxt,             text_color=zClr, text_size=size.tiny, text_halign=text.align_center)
    table.cell(dash, 0, 6, "Sqz Value",      text_color=color.new(color.white,40), text_size=size.tiny)
    table.cell(dash, 1, 6, str.tostring(math.round(sqzVal, 3)), text_color=sqzVal > 0 ? sqzCol : relCol, text_size=size.tiny, text_halign=text.align_center)

// ══════════════════════════════════════════════════════════════════
// ALERTS
// ══════════════════════════════════════════════════════════════════
alertcondition(sqzSignal,   "Squeeze Building", "JOAT VSO: Volatility Squeeze Building")
alertcondition(relSignal,   "Release Detected", "JOAT VSO: Volatility Release Detected")
alertcondition(hyperSignal, "Hyper Squeeze",    "JOAT VSO: Hyper Squeeze Alert")
alertcondition(highVol and relSignal, "Volume Release", "JOAT VSO: High-Volume Release Event")
````
