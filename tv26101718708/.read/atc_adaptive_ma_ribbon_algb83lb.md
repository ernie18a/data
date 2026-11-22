# ATC Adaptive MA Ribbon

- url: https://www.tradingview.com/script/aLgB83lB-ATC-Adaptive-MA-Ribbon/
- type: indicator
- pine_id: PUB;4108fb4a9a364552b966722d817f5158
- version: 1.0

## Description

What It Is

The ATC Ribbon is a four-line moving average ribbon that automatically adjusts its sensitivity to match current market conditions. Unlike standard moving average ribbons that use fixed settings regardless of what the market is doing, the ATC Ribbon detects whether the market is trending, ranging, or transitioning — and tightens or widens the ribbon accordingly. The result is a cleaner, more responsive trend tool that reduces whipsaw in choppy conditions and stays tight to price during directional moves.

This is not a signal generator. It is a visual context engine — designed to answer one question at a glance: what is the market doing right now, and how strong is it doing it?

________________________________________

Who It's Built For

The ATC Ribbon is built for active traders working intraday to swing timeframes on futures, equities, and forex. It serves traders who use moving averages as part of their directional bias toolkit but are frustrated by the classic tradeoff: fast MAs that whipsaw in ranges, or slow MAs that lag behind trends.

If you've ever wished your moving average ribbon would behave differently in a trending market than a choppy one — without you having to manually change settings — this is what that looks like.

________________________________________

Core Concept

At its foundation, the ATC Ribbon plots four moving averages: one Hull Moving Average (HMA) as the fast lead line, and three Exponential Moving Averages (EMAs) at medium, slow, and anchor lengths. This fixed architecture — HMA + EMA + EMA + EMA — never changes. The MA types stay consistent so you always know what you're reading.

What adapts is the length configuration. The indicator runs a manual ADX calculation in the background to classify the current environment into one of three regimes:

Trend — ADX is elevated, confirming strong directional movement. The ribbon tightens by applying a multiplier below 1.0 to all lengths, making the MAs more responsive and keeping them close to price during runs.

Range — ADX is low, confirming a lack of directional conviction. The ribbon widens by applying a multiplier above 1.0, smoothing out noise and reducing false crossover signals during chop.

Transition — ADX sits between the two thresholds. The ribbon uses its base (default) lengths, representing a neutral stance while the market decides its next move.

All three ribbon configurations are precomputed on every bar. The indicator doesn't recalculate on the fly — it simply selects the appropriate pre-built set based on the current regime. This eliminates the instability and repainting issues that plague most "adaptive" moving average tools.

________________________________________

ATC Ribbon Upgrades Over Standard MA Ribbons

HMA Lead Line — The fast MA uses a Hull Moving Average instead of a standard EMA or SMA. HMA delivers significantly less lag at equivalent smoothing depth, giving you an earlier read on momentum shifts without adding noise.

Regime-Adaptive Lengths — Instead of one static ribbon that traders manually adjust for different conditions, the ATC Ribbon precomputes three discrete configurations and transitions between them using hysteresis-gated ADX classification. You get one ribbon that acts like three, without ever needing to touch your settings.

Hysteresis on Everything — Both the regime state and the alignment bias label are protected by hysteresis buffers. This means the indicator won't flicker back and forth at boundary values. A regime must clear its threshold by a user-defined margin before the indicator acknowledges the transition. The same logic applies to the bullish/bearish alignment label — it must hold its new state for a configurable number of bars before the HUD updates. This is the difference between a tool you can trust and one that makes you second-guess it.

Alignment Scoring — The ribbon doesn't just show four lines. It calculates a composite alignment score (0–100) based on two components: stack order (are the MAs properly sequenced from fast to slow?) and slope agreement (are all four MAs rising or falling together?). This score drives the ribbon color intensity and gives you a single number that quantifies how clean the current trend structure is.

________________________________________
Chart Visuals — What You'll See

The Four MA Lines — The fast HMA leads in a slightly thicker line. The medium and slow EMAs follow in thinner lines. The anchor EMA plots in a distinct darker blue, thicker line — it acts as your structural reference, similar to a 200 EMA.

Gradient Ribbon Fill — Between each adjacent pair of MAs, a semi-transparent fill creates a layered gradient effect. The fill between the fast and medium MA is the most opaque; the fill between the slow and anchor MA is the most transparent. This produces a ribbon that visually "fades" from the leading edge to the structural anchor, giving you an intuitive sense of ribbon width and separation at a glance.

Color — The entire ribbon shifts color based on the current alignment bias. Green when the stack and slope structure favors bullish. Red when it favors bearish. Blue when the alignment is neutral or transitional. The color intensity scales with the alignment score — a strong, well-ordered trend produces rich, saturated color; a weak or mixed alignment produces a muted, faded ribbon.

Regime Background Wash — A subtle background tint appears during confirmed Trend and Range regimes. In Trend, the background takes on the current ribbon color at very low opacity. In Range, it shifts to a neutral blue tint. This ambient visual cue lets you see the regime classification without looking at the HUD.

Regime Change Pulse — When the market transitions from one regime to another, a single-bar accent-colored background pulse fires. This is your visual alert that the ribbon just switched configurations.

________________________________________

The HUD — Your Dashboard at a Glance

The HUD is a compact table displayed in your chosen chart corner (default: top right) that reports five real-time data points:

Regime — Displays the current regime label (Trend, Range, or Transition) alongside the live ADX value. This tells you both what the indicator thinks the market is doing and why it thinks that.

Alignment — Shows the current directional bias: Bullish, Bearish, or Neutral. Color-coded to match the ribbon.

Score — The composite alignment score expressed as a value out of 100. A +87/100 in bullish alignment means 87% of the stack order and slope criteria favor upside. This number lets you gauge trend quality, not just trend direction.

Config — Displays the active regime multiplier and the four MA lengths currently in use (e.g., 0.70x | 6/15/35/140). This makes the adaptive behavior completely transparent — you always know exactly what settings the ribbon is running.

Price — Reports whether the current close is Above Anchor, Below Anchor, or Neutral relative to the anchor EMA. This is a fast structural reference — above anchor generally favors longs, below anchor generally favors shorts.

________________________________________

Logic Layers — How the Indicator Thinks

Layer 1: ADX Regime Detection — The indicator runs a full manual ADX calculation (not a black-box wrapper) and classifies the result against two user-defined thresholds. Below the Range threshold, the market is classified as ranging. Above the Trend threshold, it's classified as trending. Between the two, it's in Transition. A hysteresis buffer prevents the regime from flickering at the boundary.

Layer 2: Precomputed Ribbon Selection — All three ribbon configurations (Trend, Transition, Range) are computed on every bar. When the regime state changes, the indicator simply swaps which set of MA values it displays. There is no recalculation lag, no repainting, and no series-length instability.

Layer 3: Alignment Scoring — Eight binary criteria are evaluated: four for stack order (is fast above medium? medium above slow? slow above anchor? fast above anchor?) and four for slope (is each MA rising or falling compared to its prior bar?). Bullish criteria accumulate into a bull score, bearish criteria into a bear score. The higher score determines the bias, and the magnitude drives color intensity.

Layer 4: Hysteresis Gating — Both the regime label and the alignment bias label pass through hysteresis filters before updating. The regime requires ADX to clear its threshold by a configurable buffer before flipping. The alignment bias requires the new state to persist for a configurable number of bars before the HUD acknowledges it. This ensures that everything you see on the chart represents a confirmed state, not a marginal one.

________________________________________

Alerts

The ATC Ribbon includes seven configurable alert conditions:

•	Entered Trend Regime — Fires when the market transitions into a confirmed Trend state.

•	Entered Range Regime — Fires when the market transitions into a confirmed Range state.


•	Entered Transition Regime — Fires when the market moves into the neutral Transition zone.

•	Bullish Alignment — Fires when the ribbon alignment flips to Bullish after hysteresis confirmation.


•	Bearish Alignment — Fires when the ribbon alignment flips to Bearish after hysteresis confirmation.

•	Price Crossed Above Anchor — Fires when the close crosses above the anchor EMA.


•	Price Crossed Below Anchor — Fires when the close crosses below the anchor EMA.

All alerts are one-per-event — they fire on the bar where the state change is confirmed, not on every bar where the condition is true.

________________________________________

How to Trade with the ATC Ribbon

Step 1 — Read the Regime. Before anything else, check the HUD or the background wash. If the market is in Trend regime, you're looking for continuation setups. If it's in Range regime, you're looking for mean-reversion or waiting for a breakout. If it's in Transition, stay patient — the market hasn't committed yet.

Step 2 — Check the Alignment. A Bullish alignment with a high score (above 70) tells you the ribbon is well-ordered and all four MAs are rising together. That's a clean trend structure. A Bearish alignment with a high score tells you the same thing to the downside. Neutral or low-score readings mean the trend structure is messy — be selective or wait.

Step 3 — Use the Anchor EMA as Your Structural Line. The anchor EMA (default 200-period, adjusted by regime) serves as your macro bias filter. Price above the anchor favors long setups. Price below favors shorts. This is not a signal — it's a filter that keeps you on the right side of the larger structure.

Step 4 — Look for Pullbacks into the Ribbon. In a confirmed Trend regime with strong alignment, the highest-probability entries come when price pulls back into the ribbon (toward the medium or slow EMA) and then resumes in the direction of the alignment. The ribbon acts as a dynamic support/resistance zone during trends.

Step 5 — Respect Range Regime Behavior. When the ribbon is in Range mode, it automatically widens to filter out noise. During these periods, the ribbon is telling you that directional conviction is low. Use this as a signal to reduce position sizing, tighten stops, or wait for a regime change. Forcing trend trades during a confirmed Range regime is fighting the indicator.

Step 6 — Watch for Regime Change Pulses. The single-bar background pulse that fires on regime transitions is one of the most actionable features. A shift from Range to Trend, confirmed by rising alignment score, is often the early signal that a new directional move is underway. These transitions are where the best risk/reward setups tend to form.

Step 7 — Combine with Your Edge. The ATC Ribbon is a context and bias tool, not a standalone entry signal. It's designed to be layered with your existing strategy — whether that's price action, volume analysis, key levels, or other indicators. Let the ribbon tell you what kind of market you're in and which direction it favors, then use your primary method to time the entry.

________________________________________

Settings Reference

Source — The price series used for all four MAs. Default: Close.

Base Lengths (Transition Regime) — The default MA lengths used during the Transition regime. Fast HMA: 9. Medium EMA: 21. Slow EMA: 50. Anchor EMA: 200. These are the "home base" settings that the Trend and Range multipliers adjust from.

ADX Length — The smoothing period for the ADX calculation. Default: 14. Higher values produce a slower, smoother regime classification.

Range Threshold — ADX below this value classifies the market as Range. Default: 15.0.

Trend Threshold — ADX above this value classifies the market as Trend. Default: 25.0.

ADX Hysteresis Buffer — The additional ADX distance required to exit a confirmed regime. Default: 2.0. Higher values make regime states stickier and reduce flicker.

Trend Regime Multiplier — Applied to all base lengths during Trend regime. Default: 0.70 (tightens the ribbon by 30%).

Range Regime Multiplier — Applied to all base lengths during Range regime. Default: 1.30 (widens the ribbon by 30%).

Alignment Hysteresis — Number of bars a new alignment bias must persist before the HUD and color update. Default: 2. Set to 0 for immediate updates.

Visual Toggles — Show/hide ribbon fill, MA lines, and regime background independently. All default to on.

________________________________________

Recommended Instruments and Timeframes

The ATC Ribbon is built and tested for: ES, NQ, YM, CL, GC, SPY, QQQ, major FX pairs, and large-cap stocks.

Recommended timeframes: 15-minute, 1-hour, 4-hour, and Daily. The regime detection and alignment scoring are calibrated for these intervals. Lower timeframes (1m, 5m) will produce more frequent regime changes and may require adjusted ADX thresholds. Higher timeframes (Weekly, Monthly) will work but regime transitions will be infrequent.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ATConcepts

//@version=6
// ========================================================================== 
indicator("ATC Adaptive MA Ribbon", shorttitle="ATC Ribbon", overlay=true, max_bars_back=500, max_labels_count=50)

// ========================================================================== 
// Section B — User Inputs
// ========================================================================== 
grpATC = "ATC Ribbon"
showHUD = input.bool(true, "Show HUD", group=grpATC, tooltip="Shows or hides the status HUD in the selected chart corner.")
hudPos = input.string("Top Right", "HUD Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpATC, tooltip="Selects the chart corner used by the HUD.")
hudTheme = input.string("Dark", "HUD Theme", options=["Dark", "Light"], group=grpATC, tooltip="Selects the HUD background and text theme.")

grpCalc = "Calculation Session"
calcSessionMode = input.string("Extended Session", "Calculation Data", options=["Extended Session", "Regular Session", "Chart Session"], group=grpCalc, tooltip="Controls the internal data stream used for MA, ADX, regime, and alignment calculations. Extended Session keeps calculations consistent when the chart's Extended Hours display is turned on or off.")
regularSession = input.session("0930-1600", "Regular Session", group=grpCalc, tooltip="Regular-session window used for optional display filtering and session awareness.")
sessionTZ = input.string("America/New_York", "Session Timezone", group=grpCalc, tooltip="Timezone used to evaluate the regular-session window.")
hideOutsideRegular = input.bool(false, "Hide Visuals Outside Regular Session", group=grpCalc, tooltip="When enabled, hides ribbon visuals outside the regular session while keeping the selected calculation data stream unchanged.")

grpSrc = "Source"
srcInput = input.source(close, "Source", group=grpSrc, tooltip="Source series used for all four ribbon moving averages.")

grpBase = "Base Lengths — Transition Regime"
fastLenBase = input.int(9, "Fast HMA Length", minval=3, maxval=100, group=grpBase, tooltip="Base length for the fast HMA in the Transition regime.")
mediumLenBase = input.int(21, "Medium EMA Length", minval=5, maxval=200, group=grpBase, tooltip="Base length for the medium EMA in the Transition regime.")
slowLenBase = input.int(50, "Slow EMA Length", minval=10, maxval=300, group=grpBase, tooltip="Base length for the slow EMA in the Transition regime.")
anchorLenBase = input.int(200, "Anchor EMA Length", minval=50, maxval=500, group=grpBase, tooltip="Base length for the anchor EMA in the Transition regime.")

grpRegime = "ADX Regime Detection"
adxLen = input.int(14, "ADX Length", minval=5, maxval=50, group=grpRegime, tooltip="Smoothing period used by the manual ADX calculation.")
adxLowInput = input.float(15.0, "Range Threshold", minval=5.0, maxval=40.0, step=0.5, group=grpRegime, tooltip="ADX below this value classifies the environment as Range when hysteresis allows the transition.")
adxHighInput = input.float(25.0, "Trend Threshold", minval=15.0, maxval=50.0, step=0.5, group=grpRegime, tooltip="ADX above this value classifies the environment as Trend when hysteresis allows the transition.")
adxHysteresis = input.float(2.0, "ADX Hysteresis Buffer", minval=0.0, maxval=10.0, step=0.5, group=grpRegime, tooltip="Extra ADX distance required to leave Range or Trend states. Higher values reduce regime flicker.")

grpMult = "Regime Length Multipliers"
trendMult = input.float(0.70, "Trend Regime Multiplier", minval=0.30, maxval=1.50, step=0.05, group=grpMult, tooltip="Multiplier applied to base lengths for the precomputed Trend ribbon. Values below 1 tighten the ribbon.")
rangeMult = input.float(1.30, "Range Regime Multiplier", minval=0.80, maxval=2.50, step=0.05, group=grpMult, tooltip="Multiplier applied to base lengths for the precomputed Range ribbon. Values above 1 widen the ribbon.")

grpAlign = "Alignment Scoring"
alignHysteresis = input.int(2, "Alignment Hysteresis", minval=0, maxval=10, group=grpAlign, tooltip="Number of bars a new alignment bias must persist before the HUD and ribbon color update. Zero updates immediately.")

grpVis = "Visuals"
showRibbon = input.bool(true, "Show Ribbon Fill", group=grpVis, tooltip="Shows or hides the gradient-style fill between adjacent ribbon averages.")
showMAs = input.bool(true, "Show MA Lines", group=grpVis, tooltip="Shows or hides the four ribbon moving-average lines.")
showRegimeBG = input.bool(true, "Show Regime Background", group=grpVis, tooltip="Shows or hides the subtle background tint for Trend and Range regimes.")
bullCol = input.color(#3D9970, "Bullish Color", group=grpVis, tooltip="Color used for bullish alignment, bullish HUD text, and bullish ribbon states.")
bearCol = input.color(#D64545, "Bearish Color", group=grpVis, tooltip="Color used for bearish alignment, bearish HUD text, and bearish ribbon states.")
neutCol = input.color(#2E75B6, "Neutral Color", group=grpVis, tooltip="Color used when ribbon alignment is neutral or transitional.")
accCol = input.color(#2E75B6, "Accent Color", group=grpVis, tooltip="Accent color used for HUD accents and regime-change pulses.")
anchorCol = input.color(#1F4E79, "Anchor MA Color", group=grpVis, tooltip="Color used for the anchor EMA line.")

// ========================================================================== 
// Section C — Core Calculations
// ========================================================================== 
float adxLow = adxLowInput
float adxHigh = adxHighInput
if adxHigh <= adxLow
    adxHigh := adxLow + 0.5

fastLenTrend = math.max(3, int(math.round(fastLenBase * trendMult)))
mediumLenTrend = math.max(5, int(math.round(mediumLenBase * trendMult)))
slowLenTrend = math.max(10, int(math.round(slowLenBase * trendMult)))
anchorLenTrend = math.max(50, int(math.round(anchorLenBase * trendMult)))

fastLenRange = math.max(3, int(math.round(fastLenBase * rangeMult)))
mediumLenRange = math.max(5, int(math.round(mediumLenBase * rangeMult)))
slowLenRange = math.max(10, int(math.round(slowLenBase * rangeMult)))
anchorLenRange = math.max(50, int(math.round(anchorLenBase * rangeMult)))

fastLenTransition = fastLenBase
mediumLenTransition = mediumLenBase
slowLenTransition = slowLenBase
anchorLenTransition = anchorLenBase

calcTicker = switch calcSessionMode
    "Extended Session" => ticker.modify(syminfo.tickerid, session.extended)
    "Regular Session" => ticker.modify(syminfo.tickerid, session.regular)
    => syminfo.tickerid

inRegularSession = not na(time(timeframe.period, regularSession, sessionTZ))
displayAllowed = not hideOutsideRegular or inRegularSession

f_core() =>
    _src = not na(srcInput) ? srcInput : close
    _hasPrevBar = bar_index > 0
    _prevHigh = _hasPrevBar ? high[1] : high
    _prevLow = _hasPrevBar ? low[1] : low

    _upMove = high - _prevHigh
    _downMove = _prevLow - low

    _plusDM = 0.0
    if _upMove > _downMove and _upMove > 0.0
        _plusDM := _upMove

    _minusDM = 0.0
    if _downMove > _upMove and _downMove > 0.0
        _minusDM := _downMove

    _trueRange = ta.tr(true)
    _plusDMs = ta.rma(_plusDM, adxLen)
    _minusDMs = ta.rma(_minusDM, adxLen)
    _trSmoothed = ta.rma(_trueRange, adxLen)

    _plusDI = 0.0
    if _trSmoothed != 0.0
        _plusDI := 100.0 * _plusDMs / _trSmoothed

    _minusDI = 0.0
    if _trSmoothed != 0.0
        _minusDI := 100.0 * _minusDMs / _trSmoothed

    _dxSum = _plusDI + _minusDI
    _dx = 0.0
    if _dxSum != 0.0
        _dx := 100.0 * math.abs(_plusDI - _minusDI) / _dxSum

    _adxVal = ta.rma(_dx, adxLen)
    _validAdx = not na(_adxVal)

    var int _regimeCode = 0
    int _rawRegimeCode = 0
    if _validAdx
        if _adxVal < adxLow
            _rawRegimeCode := -1
        else if _adxVal > adxHigh
            _rawRegimeCode := 1

    if _validAdx
        if _regimeCode == -1
            if _adxVal > adxLow + adxHysteresis
                _regimeCode := _rawRegimeCode
        else if _regimeCode == 1
            if _adxVal < adxHigh - adxHysteresis
                _regimeCode := _rawRegimeCode
        else
            _regimeCode := _rawRegimeCode

    _regimeChanged = _hasPrevBar and _regimeCode != _regimeCode[1]

    _ma1Trend = ta.hma(_src, fastLenTrend)
    _ma2Trend = ta.ema(_src, mediumLenTrend)
    _ma3Trend = ta.ema(_src, slowLenTrend)
    _ma4Trend = ta.ema(_src, anchorLenTrend)

    _ma1Range = ta.hma(_src, fastLenRange)
    _ma2Range = ta.ema(_src, mediumLenRange)
    _ma3Range = ta.ema(_src, slowLenRange)
    _ma4Range = ta.ema(_src, anchorLenRange)

    _ma1Transition = ta.hma(_src, fastLenTransition)
    _ma2Transition = ta.ema(_src, mediumLenTransition)
    _ma3Transition = ta.ema(_src, slowLenTransition)
    _ma4Transition = ta.ema(_src, anchorLenTransition)

    int _activeFastLen = fastLenTransition
    int _activeMediumLen = mediumLenTransition
    int _activeSlowLen = slowLenTransition
    int _activeAnchorLen = anchorLenTransition

    float _ma1 = _ma1Transition
    float _ma2 = _ma2Transition
    float _ma3 = _ma3Transition
    float _ma4 = _ma4Transition

    if _regimeCode == 1
        _activeFastLen := fastLenTrend
        _activeMediumLen := mediumLenTrend
        _activeSlowLen := slowLenTrend
        _activeAnchorLen := anchorLenTrend
        _ma1 := _ma1Trend
        _ma2 := _ma2Trend
        _ma3 := _ma3Trend
        _ma4 := _ma4Trend
    else if _regimeCode == -1
        _activeFastLen := fastLenRange
        _activeMediumLen := mediumLenRange
        _activeSlowLen := slowLenRange
        _activeAnchorLen := anchorLenRange
        _ma1 := _ma1Range
        _ma2 := _ma2Range
        _ma3 := _ma3Range
        _ma4 := _ma4Range

    _maStackValid = not na(_ma1) and not na(_ma2) and not na(_ma3) and not na(_ma4)
    _maHistoryValid = _hasPrevBar and _maStackValid and not na(_ma1[1]) and not na(_ma2[1]) and not na(_ma3[1]) and not na(_ma4[1])

    _rising1 = _maHistoryValid and _ma1 > _ma1[1]
    _rising2 = _maHistoryValid and _ma2 > _ma2[1]
    _rising3 = _maHistoryValid and _ma3 > _ma3[1]
    _rising4 = _maHistoryValid and _ma4 > _ma4[1]

    _bullOrder = 0
    _bearOrder = 0
    if _maStackValid
        if _ma1 > _ma2
            _bullOrder += 1
        if _ma2 > _ma3
            _bullOrder += 1
        if _ma3 > _ma4
            _bullOrder += 1
        if _ma1 > _ma4
            _bullOrder += 1
        if _ma1 < _ma2
            _bearOrder += 1
        if _ma2 < _ma3
            _bearOrder += 1
        if _ma3 < _ma4
            _bearOrder += 1
        if _ma1 < _ma4
            _bearOrder += 1

    _bullSlope = 0
    _bearSlope = 0
    if _maHistoryValid
        if _rising1
            _bullSlope += 1
        else
            _bearSlope += 1
        if _rising2
            _bullSlope += 1
        else
            _bearSlope += 1
        if _rising3
            _bullSlope += 1
        else
            _bearSlope += 1
        if _rising4
            _bullSlope += 1
        else
            _bearSlope += 1

    _bullScore = 0.0
    _bearScore = 0.0
    if _maStackValid
        _bullScore := (_bullOrder + _bullSlope) * 100.0 / 8.0
        _bearScore := (_bearOrder + _bearSlope) * 100.0 / 8.0

    _alignmentMag = math.max(_bullScore, _bearScore)

    int _alignmentBiasCode = 0
    if _bullScore > _bearScore
        _alignmentBiasCode := 1
    else if _bearScore > _bullScore
        _alignmentBiasCode := -1

    var int _stableBiasCode = 0
    var int _biasCandidateBars = 0
    var int _biasCandidateCode = 0

    if alignHysteresis == 0
        _stableBiasCode := _alignmentBiasCode
        _biasCandidateCode := _alignmentBiasCode
        _biasCandidateBars := 0
    else if _alignmentBiasCode == _stableBiasCode
        _biasCandidateBars := 0
        _biasCandidateCode := _alignmentBiasCode
    else
        if _alignmentBiasCode == _biasCandidateCode
            _biasCandidateBars += 1
        else
            _biasCandidateCode := _alignmentBiasCode
            _biasCandidateBars := 1
        if _biasCandidateBars >= alignHysteresis
            _stableBiasCode := _alignmentBiasCode
            _biasCandidateBars := 0

    _regimeLenMult = 1.0
    if _regimeCode == 1
        _regimeLenMult := trendMult
    else if _regimeCode == -1
        _regimeLenMult := rangeMult

    _priceCrossAboveAnchor = ta.crossover(close, _ma4)
    _priceCrossBelowAnchor = ta.crossunder(close, _ma4)
    _bullishAlignmentFlip = _stableBiasCode == 1 and _stableBiasCode[1] != 1
    _bearishAlignmentFlip = _stableBiasCode == -1 and _stableBiasCode[1] != -1

    [_ma1, _ma2, _ma3, _ma4, _adxVal, _regimeCode, _regimeChanged, _bullScore, _bearScore, _alignmentMag, _stableBiasCode, _activeFastLen, _activeMediumLen, _activeSlowLen, _activeAnchorLen, _regimeLenMult, _priceCrossAboveAnchor, _priceCrossBelowAnchor, _bullishAlignmentFlip, _bearishAlignmentFlip]

[ma1Raw, ma2Raw, ma3Raw, ma4Raw, adxVal, regimeCode, regimeChanged, bullScore, bearScore, alignmentMag, stableBiasCode, activeFastLen, activeMediumLen, activeSlowLen, activeAnchorLen, regimeLenMult, priceCrossAboveAnchor, priceCrossBelowAnchor, bullishAlignmentFlip, bearishAlignmentFlip] = request.security(calcTicker, timeframe.period, f_core(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

maStackValid = not na(ma1Raw) and not na(ma2Raw) and not na(ma3Raw) and not na(ma4Raw)

// ========================================================================== 
// Section D — Enhancement Layer
// ========================================================================== 
string regime = "Transition"
if regimeCode == 1
    regime := "Trend"
else if regimeCode == -1
    regime := "Range"

string stableBias = "Neutral"
if stableBiasCode == 1
    stableBias := "Bullish"
else if stableBiasCode == -1
    stableBias := "Bearish"

color ribbonCol = neutCol
if stableBiasCode == 1
    ribbonCol := bullCol
else if stableBiasCode == -1
    ribbonCol := bearCol

int rawFade = 100 - int(math.round(alignmentMag * 0.6))
int intensityFade = math.max(40, math.min(100, rawFade))

ma1 = displayAllowed ? ma1Raw : na
ma2 = displayAllowed ? ma2Raw : na
ma3 = displayAllowed ? ma3Raw : na
ma4 = displayAllowed ? ma4Raw : na

// ========================================================================== 
// Section E — Plotting & Visual Rendering
// ========================================================================== 
ma1Plot = plot(showMAs ? ma1 : na, "Fast HMA", color=color.new(ribbonCol, 10), linewidth=2)
ma2Plot = plot(showMAs ? ma2 : na, "Medium EMA", color=color.new(ribbonCol, 30), linewidth=1)
ma3Plot = plot(showMAs ? ma3 : na, "Slow EMA", color=color.new(ribbonCol, 50), linewidth=1)
ma4Plot = plot(showMAs ? ma4 : na, "Anchor EMA", color=color.new(anchorCol, 10), linewidth=2)

color fillFastMedium = na
color fillMediumSlow = na
color fillSlowAnchor = na
if showRibbon and displayAllowed
    fillFastMedium := color.new(ribbonCol, math.min(85, intensityFade + 10))
    fillMediumSlow := color.new(ribbonCol, math.min(88, intensityFade + 20))
    fillSlowAnchor := color.new(ribbonCol, math.min(92, intensityFade + 35))

fill(ma1Plot, ma2Plot, color=fillFastMedium, title="Fast–Medium Fill")
fill(ma2Plot, ma3Plot, color=fillMediumSlow, title="Medium–Slow Fill")
fill(ma3Plot, ma4Plot, color=fillSlowAnchor, title="Slow–Anchor Fill")

color regimeBgCol = na
if regimeCode == 1
    regimeBgCol := color.new(ribbonCol, 94)
else if regimeCode == -1
    regimeBgCol := color.new(neutCol, 96)

bgcolor(showRegimeBG and displayAllowed ? regimeBgCol : na, title="Regime Background")
bgcolor(regimeChanged and displayAllowed ? color.new(accCol, 75) : na, title="Regime Change Pulse")

// ========================================================================== 
// Section F — HUD
// ========================================================================== 
var table hud = na

if barstate.islast
    if showHUD
        if not na(hud)
            table.delete(hud)

        hudPosition = position.top_right
        if hudPos == "Top Left"
            hudPosition := position.top_left
        else if hudPos == "Bottom Right"
            hudPosition := position.bottom_right
        else if hudPos == "Bottom Left"
            hudPosition := position.bottom_left

        bgColor = #1E1E1E
        txColor = color.white
        dimColor = color.new(color.white, 40)
        if hudTheme == "Light"
            bgColor := #FAFAFA
            txColor := #222222
            dimColor := color.new(#222222, 40)

        regimeCol = accCol
        if regimeCode == 1
            regimeCol := ribbonCol
        else if regimeCode == -1
            regimeCol := dimColor

        biasCol = dimColor
        if stableBiasCode == 1
            biasCol := bullCol
        else if stableBiasCode == -1
            biasCol := bearCol

        scoreText = "0"
        if stableBiasCode == 1
            scoreText := "+" + str.tostring(math.round(bullScore))
        else if stableBiasCode == -1
            scoreText := "-" + str.tostring(math.round(bearScore))

        calcModeShort = switch calcSessionMode
            "Extended Session" => "EXT"
            "Regular Session" => "RTH"
            => "CHART"

        regimeText = regime + " | ADX " + str.tostring(adxVal, "#.0")
        configText = calcModeShort + " | " + str.tostring(regimeLenMult, "#.00") + "x | " + str.tostring(activeFastLen) + "/" + str.tostring(activeMediumLen) + "/" + str.tostring(activeSlowLen) + "/" + str.tostring(activeAnchorLen)
        anchorText = "Neutral"
        anchorTextColor = dimColor
        if maStackValid
            if close > ma4Raw
                anchorText := "Above Anchor"
                anchorTextColor := bullCol
            else if close < ma4Raw
                anchorText := "Below Anchor"
                anchorTextColor := bearCol

        hud := table.new(hudPosition, 2, 6, bgcolor=bgColor, border_width=1, border_color=color.new(ribbonCol, 55))
        table.cell(hud, 0, 0, "ATC Ribbon", text_color=ribbonCol, bgcolor=bgColor, text_size=size.small)
        table.cell(hud, 1, 0, "v1.2", text_color=ribbonCol, bgcolor=bgColor, text_size=size.small)
        table.cell(hud, 0, 1, "Regime", text_color=dimColor, bgcolor=bgColor, text_size=size.small)
        table.cell(hud, 1, 1, regimeText, text_color=regimeCol, bgcolor=bgColor, text_size=size.small)
        table.cell(hud, 0, 2, "Alignment", text_color=dimColor, bgcolor=bgColor, text_size=size.small)
        table.cell(hud, 1, 2, stableBias, text_color=biasCol, bgcolor=bgColor, text_size=size.small)
        table.cell(hud, 0, 3, "Score", text_color=dimColor, bgcolor=bgColor, text_size=size.small)
        table.cell(hud, 1, 3, scoreText + " / 100", text_color=biasCol, bgcolor=bgColor, text_size=size.small)
        table.cell(hud, 0, 4, "Config", text_color=dimColor, bgcolor=bgColor, text_size=size.small)
        table.cell(hud, 1, 4, configText, text_color=txColor, bgcolor=bgColor, text_size=size.small)
        table.cell(hud, 0, 5, "Price", text_color=dimColor, bgcolor=bgColor, text_size=size.small)
        table.cell(hud, 1, 5, anchorText, text_color=anchorTextColor, bgcolor=bgColor, text_size=size.small)
    else
        if not na(hud)
            table.delete(hud)
            hud := na

// ========================================================================== 
// Section G — Alerts
// ========================================================================== 
alertcondition(regimeChanged and regimeCode == 1, "Entered Trend Regime", "ATC Ribbon: Market entered Trend regime.")
alertcondition(regimeChanged and regimeCode == -1, "Entered Range Regime", "ATC Ribbon: Market entered Range regime.")
alertcondition(regimeChanged and regimeCode == 0, "Entered Transition Regime", "ATC Ribbon: Market entered Transition regime.")
alertcondition(bullishAlignmentFlip, "Bullish Alignment", "ATC Ribbon: Ribbon flipped to Bullish alignment.")
alertcondition(bearishAlignmentFlip, "Bearish Alignment", "ATC Ribbon: Ribbon flipped to Bearish alignment.")
alertcondition(priceCrossAboveAnchor, "Price Crossed Above Anchor", "ATC Ribbon: Price crossed above the Anchor EMA.")
alertcondition(priceCrossBelowAnchor, "Price Crossed Below Anchor", "ATC Ribbon: Price crossed below the Anchor EMA.")
````
