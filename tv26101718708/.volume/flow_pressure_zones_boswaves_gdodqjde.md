# Flow Pressure Zones [BOSWaves]

- url: https://www.tradingview.com/script/GDODqJde-Flow-Pressure-Zones-BOSWaves/
- type: indicator
- pine_id: PUB;b0bc5077f856444fa0f1faef48dac317
- version: 1.0

## Description

[b]Volume Flow Zones [BOSWaves] - Body-Ratio Volume Flow Scoring with Baseline Fuel Visualization and Counter-Trend Reversal Zone Detection[/b]

[b]Overview[/b]

Volume Flow Zones [BOSWaves] is a volume-weighted flow intensity system that scores each bar by the combined strength of its body-to-range ratio and volume participation relative to its rolling average, where baseline fuel candle height, price candle gradient intensity, and reversal zone placement are all driven by this normalized flow score rather than fixed thresholds or arbitrary indicator crossovers.

[image]https://www.tradingview.com/x/9ya4GWMu/[/image]

Instead of relying on raw volume or price direction alone, the flow score combines how convincingly price moved within the bar's range with how significant the bar's volume was relative to recent history, producing a single normalized conviction reading that reflects both the directional commitment and the participation weight behind each bar. This score then drives every visual layer of the indicator simultaneously, from the height of the fuel candles on the baseline to the brightness of the price candle coloring to the conditions required for a reversal zone to be planted.

This creates a flow monitoring framework that communicates momentum quality continuously rather than at discrete signal events. The baseline fuel candles grow and shrink with the flow score on every bar, the glow around the WMA baseline intensifies during high-flow periods, price candles brighten toward full trend color during strong participation and dim toward neutral during weak flow, and yellow reversal candles fire when meaningful counter-trend flow appears against the prevailing trend direction, at which point a forward-projecting reversal zone is planted at the bar's extreme.

Price is therefore evaluated not just for direction relative to the baseline but for the quality and intensity of the flow supporting that direction on every bar.

[b]Conceptual Framework[/b]

Volume Flow Zones is founded on the principle that directional price movement carries meaningfully different conviction depending on how decisively price closed within the bar's range and how significantly volume participated relative to recent norms, and that these two dimensions together produce a more reliable flow quality reading than either dimension alone.

Traditional momentum tools measure direction through crossovers or oscillator levels that treat all bars equally regardless of whether a move was driven by decisive high-volume conviction or by drifting low-volume noise. This framework replaces uniform direction measurement with a per-bar flow quality score that distinguishes between genuine momentum and low-conviction price movement, encoding that distinction across every visual element so that chart reading reflects real participation dynamics rather than mechanical indicator states.

Three core principles guide the design:
[list=1]
[*]Flow quality should be measured by combining body dominance within the bar range with volume significance relative to the rolling average, producing a score that captures both directional decisiveness and participation weight simultaneously.
[*]The flow score should drive all visual outputs proportionally and continuously, with fuel candle height, price candle brightness, and baseline glow all scaling in real time to the current flow reading rather than switching between fixed states.
[*]Counter-trend flow events meeting minimum quality thresholds should generate forward-projecting reversal zones anchored to the bar extreme where the opposing flow appeared, marking structural reference levels for potential trend exhaustion and reversal.
[/list]
This shifts trend analysis from binary directional state monitoring into continuous flow quality measurement where visual intensity across every chart layer communicates conviction strength in real time.

[b]Theoretical Foundation[/b]

The indicator combines WMA-based trend direction, body-to-range ratio measurement, volume SMA normalization, flow score derivation with rolling normalization, reversal detection through close position and volume threshold testing, and an ATR-scaled fuel candle system that projects flow intensity visually from the baseline.

The WMA baseline provides a weighted directional reference that gives greater importance to recent price activity, establishing the trend context that determines fuel candle positioning and reversal direction qualification. The body ratio measures what fraction of the bar's total range the body occupies, with higher ratios indicating more decisive directional commitment. Volume normalization divides each bar's volume by its SMA baseline and caps the result at three, preventing extreme volume spikes from overwhelming the score. The raw flow score multiplies body ratio by normalized volume, and a rolling highest-lowest normalization converts the raw score to a 0-1 range that adapts to the instrument's typical flow distribution. Reversal detection tests close position within the range, bar direction, and volume normalization simultaneously, requiring all three conditions to be met before a reversal event qualifies.

Four internal systems operate in tandem:
[list]
[*][i]Flow Score Engine[/i]: Calculates body ratio from open-close range divided by high-low range, normalizes volume against its SMA baseline, multiplies the two to produce raw flow, then normalizes the raw flow against its rolling highest and lowest values to produce the final 0-1 score that drives all downstream visual systems.
[*][i]Baseline Fuel Candle System[/i]: Positions ATR-scaled candles above the baseline for bearish trends and below for bullish trends, scaling their height proportionally to the current flow score so that fuel candle length grows and shrinks with each bar's flow intensity and coloring intensifies with a power-transformed opacity gradient.
[*][i]Price Candle Gradient System[/i]: Colors chart candles from a dimmed version of the trend color at low flow scores to full saturation at high flow scores using a power-transformed gradient, with yellow override on any bar where counter-trend reversal conditions are met regardless of trend state.
[*][i]Flow Reversal Zone Engine[/i]: Monitors for qualifying counter-trend flow events meeting close position, direction, and volume thresholds above the minimum flow score, plants ATR-scaled zones with dashed midlines at the bar extreme on confirmed qualifying bars subject to cooldown enforcement, extends zones forward until price closes through them on two consecutive bars.
[/list]
This design allows every chart element to reflect the current flow score simultaneously while the reversal zone system independently tracks and maps the structural locations where meaningful counter-trend flow appeared.

[b]How It Works[/b]

Volume Flow Zones evaluates price through a sequence of flow-aware scoring and visualization processes:
[list=1]
[*][i]WMA Baseline Calculation[/i]: The Weighted Moving Average is calculated over the configured length, with trend direction determined by whether close is above or below the baseline on each bar.
[*][i]Body Ratio Measurement[/i]: The absolute difference between close and open is divided by the high-low range to produce a 0-1 body ratio, with higher values indicating bars where price moved decisively in one direction relative to its total range.
[*][i]Volume Normalization[/i]: Raw volume is divided by the Volume SMA baseline and capped at 3.0, producing a score that reflects whether the bar's participation was below average, average, or significantly above average relative to recent history.
[*][i]Raw Flow Calculation[/i]: Body ratio is multiplied by normalized volume to combine directional decisiveness with participation weight into a single raw flow reading.
[*][i]Rolling Normalization[/i]: The raw flow is normalized against its highest and lowest values over the configured lookback window, producing a 0-1 score that adapts to the instrument's typical flow range and maintains consistent visual scaling across different volatility regimes.
[*][i]Reversal Condition Testing[/i]: Counter-trend pressure is identified when close position within the bar range is below 0.35 on a down-close bar with volume above 1.2 times SMA for bearish pressure, or above 0.65 on an up-close bar with the same volume threshold for bullish pressure. These conditions combined with the flow score threshold and trend direction determine whether a reversal event qualifies.
[*][i]Price Candle Coloring[/i]: The normalized flow score is power-transformed and mapped to a gradient between a dimmed and full-saturation version of the trend color. Reversal bars override this coloring with full yellow regardless of score or trend direction.
[*][i]Fuel Candle Rendering[/i]: ATR-scaled open and close prices are calculated from the WMA with the configured offset, with candle height proportional to the flow score. Fuel candles render below the baseline during uptrends and above during downtrends, with opacity power-transformed from the flow score and yellow coloring applied on reversal bars.
[*][i]Baseline Glow Rendering[/i]: A wide low-opacity version of the WMA line and a thinner core line are plotted with transparency inversely proportional to a smoothed flow average, producing a glow effect that intensifies during sustained high-flow periods.
[*][i]Reversal Zone Planting[/i]: On confirmed reversal bars satisfying the cooldown requirement, an ATR-scaled zone is planted centered on the bar's low for bullish reversals and high for bearish reversals, with a dashed midline and forward extension. Overlapping same-direction zones are removed before the new zone is added.
[*][i]Zone Lifecycle Management[/i]: All active zones extend rightward on each bar. When close has been below the zone bottom for two consecutive bars for bullish zones or above the zone top for two consecutive bars for bearish zones, the zone is deleted.
[/list]
Together, these elements form a continuously updating flow monitoring system where baseline fuel candles, price candle gradients, and reversal zones all derive from the same underlying flow score, producing a visually unified conviction map across every chart element.

[b]Interpretation[/b]

Volume Flow Zones should be interpreted as a flow quality visualization system with structural counter-trend zone mapping:
[list]
[*][i]WMA Baseline[/i]: The Weighted Moving Average provides the primary trend reference with a glow that brightens during sustained high-flow periods, providing an immediate visual indicator of whether the current trend is being supported by strong or weak participation.
[*][i]Bullish Trend State (Green)[/i]: Active when close is above the WMA, with fuel candles projecting below the baseline and price candles coloring green with intensity scaling from the flow score.
[*][i]Bearish Trend State (Red)[/i]: Active when close is below the WMA, with fuel candles projecting above the baseline and price candles coloring red with intensity scaling from the flow score.
[*][i]Fuel Candle Height[/i]: The primary flow intensity indicator, growing with each bar's flow score and shrinking during low-conviction periods. Tall fuel candles indicate strong directional participation. Short or barely visible fuel candles indicate weak flow with low conviction behind the current price movement.
[*][i]Fuel Candle Opacity[/i]: The transparency of each fuel candle further encodes flow strength, with near-opaque candles representing peak-intensity flow events and highly transparent candles representing low-intensity bars.
[*][i]Price Candle Gradient[/i]: Price candles brighten toward full trend color saturation at high flow scores and dim toward a muted version of the trend color at low flow scores, providing an immediate bar-level conviction reading directly on the candlestick.
[*][i]Yellow Candles[/i]: Both the price candle and fuel candle flash yellow on bars where qualifying counter-trend flow is detected, immediately identifying potential exhaustion or reversal events within the current trend.
[*][i]Flow Reversal Zones[/i]: Horizontal zones with dashed midlines planted at bar extremes where qualifying counter-trend flow appeared, projecting forward as structural reference levels for the price level where opposing flow was significant enough to register. Bullish reversal zones are colored green, bearish reversal zones red.
[/list]
Fuel candle height dynamics, price candle brightness, yellow reversal identification, and zone proximity collectively provide more flow intelligence than any element in isolation.

[b]Signal Logic & Visual Cues[/b]

Volume Flow Zones presents two primary reversal signal types alongside continuous flow intensity monitoring:
[list=1]
[*][i]Bullish Reversal (Yellow)[/i]: Triggered when price closes in the upper portion of the bar's range on an up-close bar with above-average volume during a downtrend, with flow score exceeding the minimum threshold. Plants a bullish reversal zone below the bar and flashes both price and fuel candles yellow.
[*][i]Bearish Reversal (Yellow)[/i]: Triggered when price closes in the lower portion of the bar's range on a down-close bar with above-average volume during an uptrend, with flow score exceeding the minimum threshold. Plants a bearish reversal zone above the bar and flashes both price and fuel candles yellow.
[/list]
Zone cooldown enforcement prevents multiple zones from planting in rapid succession, spacing reversal references to only the most significant qualifying events within each cooldown window.

Alert generation covers bullish and bearish reversal flow events and WMA bullish and bearish flips for systematic trend monitoring workflows.

[b]Strategy Integration[/b]

Volume Flow Zones fits within flow-informed trend-following and counter-trend monitoring approaches:
[list]
[*][i]Fuel Candle Conviction Reading[/i]: Use fuel candle height as a continuous trend health gauge. Consistently tall fuel candles during a trend indicate sustained directional commitment. Progressively shrinking fuel candles within an established trend suggest flow is weakening before any price indicator or crossover confirms the deterioration.
[*][i]Yellow Candle Context[/i]: Use yellow reversal candles as early warning signals within trends rather than as standalone entry triggers. A single yellow candle mid-trend may indicate temporary absorption. Multiple yellow candles within a short window suggest building counter-trend pressure warranting reduced confidence in continuation.
[*][i]Reversal Zone Reference Trading[/i]: Use planted reversal zones as structural reference levels where meaningful opposing flow previously appeared. Price returning to these zones encounters the price level where prior counter-trend activity was significant enough to meet the reversal detection criteria.
[*][i]WMA Flip Entries[/i]: Use WMA direction changes combined with high fuel candle readings immediately following the flip as trend initiation entries, favoring flips that coincide with strong flow scores over flips that occur during low-conviction flow conditions.
[*][i]Flow Divergence Detection[/i]: Monitor for situations where price is making new highs or lows but fuel candle height is diminishing, indicating that price extension is occurring on weakening flow and increasing the probability of reversal or consolidation.
[*][i]Multi-Timeframe Flow Alignment[/i]: Apply higher-timeframe WMA direction and fuel candle intensity as directional context filters, engaging with lower-timeframe reversal zones and yellow candle signals only when they align with the broader flow state established on the higher timeframe.
[/list]
[b]Technical Implementation Details[/b]
[list]
[*][i]Baseline Engine[/i]: Weighted Moving Average with configurable length for trend direction and fuel candle anchoring
[*][i]Flow Score[/i]: Body-to-range ratio multiplied by volume SMA normalization with rolling highest-lowest normalization over configurable lookback
[*][i]Reversal Detection[/i]: Close position threshold, bar direction, and volume normalization minimum combined with flow score floor and trend direction gating
[*][i]Fuel Candles[/i]: ATR-scaled height with configurable multiplier and baseline offset, power-transformed opacity gradient, yellow override on reversal bars
[*][i]Price Candles[/i]: Power-transformed flow gradient from dimmed to saturated trend color with full yellow override on reversal bars
[*][i]Baseline Glow[/i]: Dual-line wide and narrow WMA plots with transparency inversely proportional to smoothed flow average
[*][i]Zone System[/i]: Array-managed ATR-scaled zone boxes with dashed midlines, cooldown enforcement, overlap removal, forward extension, and two-bar consecutive close breach invalidation
[*][i]Performance Profile[/i]: Optimized for real-time execution with configurable zone count cap and array-based lifecycle management
[/list]
[b]Optimal Application Parameters[/b]

Timeframe Guidance:
[list]
[*][i]1 - 5 min[/i]: Intraday flow monitoring for scalping with shorter WMA and normalization lengths for faster flow score adaptation to intraday momentum shifts
[*][i]15 - 60 min[/i]: Session-level trend flow tracking with balanced WMA length and moderate zone cooldown for meaningful reversal zone spacing across typical session moves
[*][i]4H - Daily[/i]: Swing-level flow quality monitoring with longer WMA and normalization lookback for sustained flow readings across multi-session directional moves
[/list]
Suggested Baseline Configuration:
[list]
[*][i]WMA Length[/i]: 80
[*][i]Volume SMA[/i]: 20
[*][i]Normalization Lookback[/i]: 80
[*][i]Offset (ATR%)[/i]: 0.4
[*][i]Candle Height[/i]: 2.0
[*][i]Show Reversal Zones[/i]: Enabled
[*][i]Zone Cooldown[/i]: 31
[*][i]Max Zones[/i]: 3
[*][i]Show Fuel Candles[/i]: Enabled
[*][i]Show Baseline[/i]: Enabled
[*][i]Show Baseline Glow[/i]: Enabled
[*][i]Color Price Candles[/i]: Enabled (requires disabling original chart candles in chart settings)
[/list]
These suggested parameters should be used as a baseline; their effectiveness depends on the instrument's volatility characteristics, volume behavior, and preferred signal density, so fine-tuning is expected for optimal performance.

[b]Parameter Calibration Notes[/b]

Use the following adjustments to refine behavior without altering the core logic:
[list]
[*][i]Fuel candles too tall or too short[/i]: Adjust Candle Height to scale the maximum fuel candle height relative to ATR. Lower values produce more subtle fuel visualization, higher values produce more prominent height differences between high and low flow bars.
[*][i]Fuel candles too close or far from price[/i]: Adjust Offset (ATR%) to control the gap between the WMA baseline and the near edge of the fuel candles, adapting visual separation to the instrument's typical ATR range.
[*][i]Flow score too reactive[/i]: Increase Normalization Lookback to smooth the normalization window, requiring more bars to recalibrate the flow range and reducing sensitivity to short-term volume spikes.
[*][i]Flow score too slow to adapt[/i]: Decrease Normalization Lookback for faster recalibration of the flow score range, allowing the system to adapt more quickly to changing volatility and volume conditions.
[*][i]Too many reversal zones forming[/i]: Increase Zone Cooldown to enforce greater bar separation between consecutive zone plants, or reduce Max Zones to limit the total number of active reference levels on the chart.
[*][i]Reversal zones too narrow or wide[/i]: Adjust Zone Height (ATR×) to scale the vertical size of each reversal zone relative to ATR, calibrating zone thickness to the instrument's typical noise range at the target timeframe.
[*][i]WMA too reactive to price[/i]: Increase WMA Length for a smoother baseline that filters minor oscillations and reduces frequency of trend direction changes, producing more stable fuel candle positioning and cleaner reversal zone direction assignments.
[/list]
Adjustments should be incremental and evaluated across multiple session types rather than isolated market conditions.

[b]Performance Characteristics[/b]

High Effectiveness:
[list]
[*]Trending markets with clear directional momentum where fuel candle height builds during impulse phases and provides early warning of conviction decay before price reverses
[*]Instruments with consistent volume participation where SMA normalization accurately identifies above-average bars and the flow score reliably differentiates high and low conviction moves
[*]Flow divergence strategies where declining fuel candle height during price extension provides early deterioration signals before conventional indicators confirm reversal
[*]Counter-trend monitoring approaches where reversal zones mark the precise price levels where meaningful opposing flow appeared for use as structural reference in subsequent analysis
[/list]
Reduced Effectiveness:
[list]
[*]Choppy, low-volume markets where body ratios are consistently low and volume normalization produces undifferentiated scores, reducing fuel candle height variation and generating frequent yellow candles without meaningful reversal context
[*]Instruments with highly irregular volume distribution where the SMA normalization baseline is distorted by outlier sessions, producing unreliable flow score rankings across typical bars
[*]Extremely fast-moving markets where large body ratios are consistently present on almost every bar, compressing the flow score range and reducing the visual differentiation between high and low conviction periods
[*]Low-ATR instruments where the fuel candle geometry produces visually imperceptible height differences, requiring manual candle height and offset adjustment to produce meaningful visual scaling
[*]Consolidation and sideways conditions where volume participation is mixed and body ratios are low, producing uniformly short fuel candles and frequent yellow candles without the trend context that makes reversal detection structurally meaningful
[/list]
[b]Integration Guidelines[/b]
[list]
[*][i]Confluence[/i]: Combine with BOSWaves structural tools, order block analysis, or momentum oscillators to validate reversal zone interactions and yellow candle events with broader analytical context
[*][i]Fuel Candle Trend Health[/i]: Monitor fuel candle height evolution throughout established trends as a continuous conviction health indicator. Progressively shrinking fuel candles during a sustained trend suggest flow deterioration that may precede reversal before price structure confirms the change.
[*][i]Yellow Candle Clustering[/i]: Single isolated yellow candles within a trend carry less weight than clusters of two or more within a short window. Clusters suggest building counter-trend participation that is approaching the threshold required to challenge the prevailing flow direction.
[*][i]Zone Freshness[/i]: Prioritize recently planted reversal zones over older ones. Fresh zones reflect current session flow dynamics while older zones may have formed under different volume and volatility conditions that are no longer representative.
[*][i]State Discipline[/i]: Maintain directional bias aligned with the current WMA trend state until a confirmed WMA direction change occurs. Yellow candles and reversal zones within an established trend are monitoring signals rather than automatic exit triggers and should be interpreted as context rather than directional commands.
[/list]
[b]Disclaimer[/b]

Volume Flow Zones [BOSWaves] is a professional-grade flow quality analysis and counter-trend monitoring tool. It uses body-ratio volume flow scoring with rolling normalization and reversal zone detection but does not predict future price movements. Results depend on market conditions, instrument volume characteristics, parameter selection, and disciplined execution. BOSWaves recommends deploying this indicator within a broader analytical framework that incorporates price structure, order flow context, and comprehensive risk management.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BOSWaves

//@version=6
indicator("Flow Pressure Zones [BOSWaves]", overlay = true, max_lines_count = 500, max_bars_back = 500, max_boxes_count = 500)

// ┌────────────────────────────── BOSWaves ─ Inputs ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
const string gCore = "Flow Engine"
const string gFuel = "Fuel Candles"
const string gLevs = "Flow Reversal Zones"
const string gVis  = "Display"

int    wmaLen      = input.int(80, "WMA Length", minval = 5, group = gCore,
     tooltip = "Weighted MA baseline. Lower = faster trend response.")
int    volLen      = input.int(20, "Volume SMA", minval = 5, group = gCore)
int    normLen     = input.int(80, "Normalization Lookback", minval = 10, group = gCore)

float  candleOff   = input.float(0.4, "Offset (ATR %)", minval = 0.0, step = 0.1, group = gFuel)
float  heightMult  = input.float(2.0, "Candle Height", minval = 0.5, maxval = 5.0, step = 0.5, group = gFuel)

bool   showZones   = input.bool(true, "Show Reversal Zones", group = gLevs,
     tooltip = "Zones planted where strong counter-trend flow appeared.")
int    zoneCD      = input.int(31, "Zone Cooldown", minval = 2, maxval = 50, group = gLevs)
int    maxZones    = input.int(3, "Max Zones", minval = 2, maxval = 15, group = gLevs)
float  zoneATR     = input.float(0.1, "Zone Height (ATR×)", minval = 0.1, maxval = 1.0, step = 0.05, group = gLevs)

bool   showFuel    = input.bool(true, "Show Fuel Candles", group = gVis)
bool   showBase    = input.bool(true, "Show Baseline", group = gVis)
bool   showGlow    = input.bool(true, "Show Baseline Glow", group = gVis)
bool   paintBars   = input.bool(true, "Color Price Candles", group = gVis,
     tooltip = "Colors the actual chart candles by trend direction with flow-based gradient.")

color  bullCol     = input.color(#00ff00, "Bullish", inline = "c", group = gVis)
color  bearCol     = input.color(#ff0000, "Bearish", inline = "c", group = gVis)
color  revCol      = input.color(#ffff00, "Reversal", inline = "c2", group = gVis)

// ┌────────────────────────────── BOSWaves ─ WMA Baseline ───────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
float wma     = ta.wma(close, wmaLen)
bool  trendUp = close > wma

// ┌────────────────────────────── BOSWaves ─ Flow Score ──────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
float barRange  = math.max(high - low, syminfo.mintick)
float bodySize  = math.abs(close - open)
float bodyRatio = bodySize / barRange
float closePos  = (close - low) / barRange

float volSma    = ta.sma(volume, volLen)
float volNorm   = volSma > 0 ? math.min(volume / volSma, 3.0) : 1.0

float rawFlow   = bodyRatio * volNorm

float flowMax   = ta.highest(rawFlow, normLen)
float flowMin   = ta.lowest(rawFlow, normLen)
float flowNorm  = (flowMax > flowMin) ? (rawFlow - flowMin) / (flowMax - flowMin) : 0.0

// ┌────────────────────────────── BOSWaves ─ Reversal Detection ─────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
bool sellPressure = closePos < 0.35 and close < open and volNorm > 1.2
bool buyPressure  = closePos > 0.65 and close > open and volNorm > 1.2

bool bullReversal = not trendUp and buyPressure and flowNorm > 0.5
bool bearReversal = trendUp and sellPressure and flowNorm > 0.5
bool anyReversal  = bullReversal or bearReversal

// ┌────────────────────────────── BOSWaves ─ Price Candle Coloring ──────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
color trendCol = trendUp ? bullCol : bearCol

// Flow gradient — weak = dim trend color, strong = vivid trend color
float priceScore = math.pow(flowNorm, 0.7)
color bodyCol    = paintBars ? color.from_gradient(priceScore, 0, 1, color.new(trendCol, 70), trendCol) : na
color wickCol    = paintBars ? color.from_gradient(priceScore, 0, 1, color.new(trendCol, 60), color.new(trendCol, 5)) : na
color bordCol    = paintBars ? color.from_gradient(priceScore, 0, 1, color.new(trendCol, 55), color.new(trendCol, 0)) : na

// Override on reversal bars — flash yellow
if paintBars and anyReversal
    bodyCol := revCol
    wickCol := revCol
    bordCol := revCol

plotcandle(open, high, low, close, "Price Candles",
     color = bodyCol, wickcolor = wickCol, bordercolor = bordCol,
     display = paintBars ? display.all : display.none)

// ┌────────────────────────────── BOSWaves ─ Fuel Candle Color ──────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
color fuelBaseCol = anyReversal ? revCol : trendCol

float fuelPower = math.pow(flowNorm, 1.5)
int   fuelTrans = int(math.max(0, 80 - fuelPower * 80))
color fuelCol   = color.new(fuelBaseCol, fuelTrans)

// ┌────────────────────────────── BOSWaves ─ Fuel Candle Geometry ───────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
float atr       = ta.atr(200)
float gap       = atr * candleOff
float scaledH   = flowNorm * atr * heightMult

float bullOpen  = wma - gap
float bullClose = bullOpen - scaledH

float bearOpen  = wma + gap
float bearClose = bearOpen + scaledH

// ┌────────────────────────────── BOSWaves ─ Baseline Glow ──────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
float flowSma    = ta.sma(flowNorm, 8)
int   glowTransp = int(math.max(30, 80 - flowSma * 50))

plot(showBase and showGlow ? wma : na, "Glow", color.new(trendCol, glowTransp + 15), 6)
plot(showBase ? wma : na, "WMA Core", color.new(trendCol, glowTransp), 2)

// ┌────────────────────────────── BOSWaves ─ Fuel Candles ───────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
plotcandle(
     showFuel and trendUp ? bullOpen : na,
     bullOpen, bullClose, bullClose,
     title = "Bull Fuel", color = fuelCol, wickcolor = fuelCol, bordercolor = fuelCol)

plotcandle(
     showFuel and not trendUp ? bearOpen : na,
     bearOpen, bearClose, bearClose,
     title = "Bear Fuel", color = fuelCol, wickcolor = fuelCol, bordercolor = fuelCol)

// ┌────────────────────────────── BOSWaves ─ Flow Reversal Zones ────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
type FlowZone
    float top
    float bot
    float mid
    int   originBar
    bool  isBull
    box   zoneBox
    line  midLine

var FlowZone[] zones = array.new<FlowZone>()
var int lastZoneBar  = 0

if showZones and anyReversal and barstate.isconfirmed and bar_index - lastZoneBar >= zoneCD
    lastZoneBar := bar_index

    float halfH  = atr * zoneATR / 2.
    float anchor = bullReversal ? low : high
    float zTop   = anchor + halfH
    float zBot   = anchor - halfH
    float zMid   = anchor

    color zCol = bullReversal ? bullCol : bearCol

    if zones.size() > 0
        for i = zones.size() - 1 to 0
            FlowZone fz = zones.get(i)
            if fz.isBull == bullReversal and zBot < fz.top and zTop > fz.bot
                fz.zoneBox.delete()
                fz.midLine.delete()
                zones.remove(i)

    while zones.size() >= maxZones
        FlowZone old = zones.shift()
        old.zoneBox.delete()
        old.midLine.delete()

    box zb = box.new(bar_index, zTop, bar_index + 20, zBot,
         bgcolor = color.new(zCol, 85),
         border_color = color.new(zCol, 50),
         border_width = 1)

    line ml = line.new(bar_index, zMid, bar_index + 20, zMid,
         color = color.new(zCol, 35),
         width = 1,
         style = line.style_dashed)

    zones.push(FlowZone.new(zTop, zBot, zMid, bar_index, bullReversal, zb, ml))

if zones.size() > 0
    for i = zones.size() - 1 to 0
        FlowZone fz = zones.get(i)

        bool broken = false
        if fz.isBull
            broken := close < fz.bot and close[1] < fz.bot
        else
            broken := close > fz.top and close[1] > fz.top

        if broken
            fz.zoneBox.delete()
            fz.midLine.delete()
            zones.remove(i)
            continue

        fz.zoneBox.set_right(bar_index + 20)
        fz.midLine.set_x2(bar_index + 20)

// ┌────────────────────────────── BOSWaves ─ Alerts ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
alertcondition(bullReversal, "Bull Reversal Flow", "Buy pressure against downtrend on {{ticker}}")
alertcondition(bearReversal, "Bear Reversal Flow", "Sell pressure against uptrend on {{ticker}}")
alertcondition(trendUp and not trendUp[1], "WMA Bullish", "WMA flipped bullish on {{ticker}}")
alertcondition(not trendUp and trendUp[1], "WMA Bearish", "WMA flipped bearish on {{ticker}}")
````
