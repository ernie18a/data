# Stable Yield Curve Regime

- url: https://www.tradingview.com/script/A0tC4OXc-Stable-Yield-Curve-Regime/
- type: indicator
- pine_id: PUB;b6579d8302324fea96d488f2d4f4ed85
- version: 2.0

## Description

[b]Overview[/b]

The Stable Yield Curve Regime Indicator identifies the dominant Treasury yield-curve regime while filtering out the noise produced by daily regime classifiers.

Instead of changing regimes after every small yield movement, it uses:

[list]
[*]Smoothed yields
[*]Multi-period yield changes
[*]Minimum movement thresholds
[*]Rolling regime voting
[*]Optional magnitude weighting
[*]Dominance and confirmation filters
[/list]

The default curve compares the US 2-year and 10-year Treasury yields, but both symbols are customizable.

[b]Regime Definitions[/b]

[b]Bull Steepener[/b]

Yields are generally falling while the long-minus-short spread is widening. This commonly occurs when short-term yields fall faster than long-term yields.

[b]Bull Flattener[/b]

Yields are generally falling while the long-minus-short spread is narrowing. This commonly occurs when long-term yields fall faster than short-term yields.

[b]Bear Steepener[/b]

Yields are generally rising while the long-minus-short spread is widening. This commonly occurs when long-term yields rise faster than short-term yields.

[b]Bear Flattener[/b]

Yields are generally rising while the long-minus-short spread is narrowing. This commonly occurs when short-term yields rise faster than long-term yields.

“Bull” and “bear” refer to bond prices, not necessarily equities.

[b]Calculation Method[/b]

The indicator smooths the selected short-end and long-end yields, then measures their changes over the selected observation horizon.

[b]Level Move[/b] = (change in short yield + change in long yield) / 2

[list]
[*]Negative Level Move: yields are generally falling
[*]Positive Level Move: yields are generally rising
[/list]

[b]Curve Move[/b] = change in long yield − change in short yield

[list]
[*]Positive Curve Move: steepening
[*]Negative Curve Move: flattening
[/list]

Bull versus bear is determined by the average movement of both yields. Therefore, an observation can still be classified when the two yields move in opposite directions, provided their average movement passes the selected threshold.

Each analysis bar creates one regime observation. When the observation horizon is greater than one, consecutive observations overlap.

[b]Stability Filters[/b]

[b]Minimum Movement Thresholds[/b]

An observation is treated as neutral when either the Level Move or Curve Move is smaller than its selected basis-point threshold.

[b]Rolling Dominance[/b]

The indicator evaluates regime observations over a configurable rolling window. The regime with the highest score becomes the current leader.

[b]Observation Weighting[/b]

Equal voting gives every valid observation one vote.

Magnitude weighting gives larger combined yield-level and curve movements more influence.

[b]Minimum Coverage[/b]

A minimum percentage of the rolling window must contain valid, non-neutral observations.

[b]Minimum Dominance[/b]

The leading regime must control a minimum share of the classified vote weight.

[b]Minimum Lead[/b]

The leading regime must exceed the runner-up by the selected percentage-point margin.

[b]Confirmation Bars[/b]

A new regime must remain qualified for several consecutive analysis bars before replacing the stable regime.

[b]Main Settings[/b]

[list]
[*]Short-end yield: Default is [symbol="TVC:US02Y"]TVC:US02Y[/symbol]
[*]Long-end yield: Default is [symbol="TVC:US10Y"]TVC:US10Y[/symbol]
[*]Analysis timeframe: Timeframe used for all calculations
[*]Yield smoothing: Smooths each yield before measuring changes
[*]Observation horizon: Period over which yield changes are measured
[*]Dominance window: Number of regime observations evaluated
[*]Minimum yield move: Filters small general yield movements
[*]Minimum curve move: Filters small steepening or flattening movements
[*]Observation weighting: Equal votes or magnitude weighted
[*]Minimum coverage: Required proportion of valid observations
[*]Minimum dominant share: Required share held by the leading regime
[*]Minimum lead: Required advantage over the runner-up
[*]Confirmation bars: Consecutive bars required before switching
[*]Hold previous regime when unclear: Retains the last stable regime until another qualifies
[/list]

[b]Default Configuration[/b]

[list]
[*]Analysis timeframe: Daily
[*]Yield smoothing: 3 bars
[*]Observation horizon: 5 bars
[*]Dominance window: 30 bars
[*]Minimum yield move: 1 basis point
[*]Minimum curve move: 1 basis point
[*]Weighting: Magnitude weighted
[*]Minimum coverage: 50%
[*]Minimum dominant share: 45%
[*]Minimum lead: 10 percentage points
[*]Confirmation: 3 bars
[/list]

With daily analysis, the default dominance window represents 30 daily regime observations, with each observation measuring a five-day yield movement.

[b]Indicator Outputs[/b]

The panel displays:

[list]
[*]Dominant regime share
[*]Classified coverage
[*]Optional individual regime shares
[*]Background color representing the stable regime
[*]Labels when the stable regime changes
[*]A dashboard showing the leader, stable regime, confidence, curve spread and pending switches
[/list]

Default colors:

[list]
[*]Green: Bull steepener
[*]Blue: Bull flattener
[*]Orange: Bear steepener
[*]Red: Bear flattener
[*]Gray: Unclear
[/list]

[b]Non-Repainting Behavior[/b]

The script uses the previous completed analysis-timeframe bar. This prevents unfinished higher-timeframe data from changing historical results but introduces a one-analysis-bar delay.

The chart timeframe must be equal to or lower than the selected analysis timeframe for the intended calculation to operate correctly.

For example:

[list]
[*]1-hour chart with daily analysis: Supported
[*]Daily chart with daily analysis: Supported
[*]Daily chart with weekly analysis: Supported
[*]Weekly chart with daily analysis: Not supported reliably
[/list]

[b]Interpretation Notes[/b]

The indicator measures changes in the curve, not only its current shape.

A curve can steepen while remaining inverted. For example, a move from −100 basis points to −70 basis points is a steepening even though the spread remains negative.

The dashboard’s curve-spread reading should therefore be considered alongside the regime.

The indicator is descriptive rather than predictive. It does not independently forecast recessions, inflation, central-bank decisions or asset prices.

[b]Suggested Uses[/b]

[list]
[*]Treasury and bond-futures analysis
[*]Equity-index macro analysis
[*]Sector-rotation analysis
[*]Duration positioning
[*]Monetary-policy expectations
[*]Cross-asset regime analysis
[/list]

It should not be treated as a standalone entry or exit signal.

[b]Alerts[/b]

Alerts are available for confirmed changes into:

[list]
[*]Bull steepener
[*]Bull flattener
[*]Bear steepener
[*]Bear flattener
[/list]

Alerts trigger only after the new stable regime passes all filters and confirmation requirements.

[b]Disclaimer[/b]

This indicator is provided for informational and educational purposes only. It does not constitute investment advice or a recommendation to buy or sell any financial instrument.

Yield-curve regimes describe historical market behavior and do not guarantee future economic or investment outcomes.

## Source Code

````pine
//@version=6
indicator(
     "Yield Curve Regime",
     shorttitle = "YC Regime",
     overlay = false,
     max_bars_back = 2000
)

//=============================================================================
// INPUTS
//=============================================================================

string GROUP_DATA     = "1. Yield Curve Data"
string GROUP_SIGNAL   = "2. Regime Calculation"
string GROUP_FILTER   = "3. Stability Filters"
string GROUP_DISPLAY  = "4. Display"

string shortSymbol = input.symbol(
     "TVC:US02Y",
     "Short-end yield",
     group = GROUP_DATA,
     tooltip = "Default: US 2-year Treasury yield."
)

string longSymbol = input.symbol(
     "TVC:US10Y",
     "Long-end yield",
     group = GROUP_DATA,
     tooltip = "Default: US 10-year Treasury yield. Change this to US30Y if you prefer a 2s30s curve."
)

string analysisTf = input.timeframe(
     "1D",
     "Analysis timeframe",
     group = GROUP_DATA,
     tooltip = "The rolling window and all lookbacks are measured in bars of this timeframe. Use 1D for daily macro regimes."
)

int smoothingLength = input.int(
     3,
     "Yield smoothing length",
     minval = 1,
     maxval = 50,
     group = GROUP_SIGNAL,
     tooltip = "Smooths each yield before calculating its change. Higher values reduce noise but add lag."
)

int observationHorizon = input.int(
     5,
     "Regime observation horizon",
     minval = 1,
     maxval = 100,
     group = GROUP_SIGNAL,
     tooltip = "Measures the change in smoothed yields over this many analysis bars. Five means each observation represents a five-day move on a daily timeframe."
)

int dominanceWindow = input.int(
     30,
     "Dominance window",
     minval = 5,
     maxval = 250,
     group = GROUP_SIGNAL,
     tooltip = "Number of classified observations used to determine the dominant regime."
)

float minLevelMoveBp = input.float(
     1.0,
     "Minimum average yield move",
     minval = 0.0,
     maxval = 50.0,
     step = 0.25,
     group = GROUP_FILTER,
     tooltip = "Minimum absolute movement, in basis points, of the average of the short and long yield changes."
)

float minCurveMoveBp = input.float(
     1.0,
     "Minimum curve move",
     minval = 0.0,
     maxval = 50.0,
     step = 0.25,
     group = GROUP_FILTER,
     tooltip = "Minimum absolute change, in basis points, of the long-minus-short yield spread."
)

string voteWeighting = input.string(
     "Magnitude weighted",
     "Observation weighting",
     options = ["Equal votes", "Magnitude weighted"],
     group = GROUP_FILTER,
     tooltip = "Magnitude weighting gives larger yield and curve movements more influence than marginal movements."
)

float minCoveragePct = input.float(
     50.0,
     "Minimum classified coverage",
     minval = 0.0,
     maxval = 100.0,
     step = 5.0,
     group = GROUP_FILTER,
     tooltip = "Minimum percentage of the rolling window that must contain a valid, non-neutral regime."
)

float minDominancePct = input.float(
     45.0,
     "Minimum dominant share",
     minval = 25.0,
     maxval = 100.0,
     step = 1.0,
     group = GROUP_FILTER,
     tooltip = "The leading regime must have at least this percentage of classified vote weight."
)

float minLeadPct = input.float(
     10.0,
     "Minimum lead over runner-up",
     minval = 0.0,
     maxval = 50.0,
     step = 1.0,
     group = GROUP_FILTER,
     tooltip = "The leading regime must exceed the second-place regime by at least this amount."
)

int confirmationBars = input.int(
     3,
     "Bars required before switching",
     minval = 1,
     maxval = 20,
     group = GROUP_FILTER,
     tooltip = "A new qualified regime must remain dominant for this many analysis bars before the displayed regime changes."
)

bool requireFullWindow = input.bool(
     true,
     "Require complete dominance window",
     group = GROUP_FILTER,
     tooltip = "Prevents signals from appearing until the full rolling window has been populated."
)

bool holdPreviousWhenUnclear = input.bool(
     true,
     "Hold previous regime when unclear",
     group = GROUP_FILTER,
     tooltip = "When no regime meets the filters, retain the previous stable regime rather than switching to neutral."
)

bool showComponentShares = input.bool(
     false,
     "Show individual regime shares",
     group = GROUP_DISPLAY
)

bool showDashboard = input.bool(
     true,
     "Show dashboard",
     group = GROUP_DISPLAY
)

//=============================================================================
// FUNCTIONS
//=============================================================================

// Returns the last confirmed smoothed yield and its confirmed change.
//
// The [1] history reference combined with lookahead_on prevents the script from
// using an unfinished analysis-timeframe bar. This intentionally adds one
// analysis-bar delay in exchange for non-repainting behavior.
f_confirmedYieldData(int smoothLen, int horizon) =>
    float smoothedYield = ta.sma(close, smoothLen)
    float yieldChange   = smoothedYield - smoothedYield[horizon]
    [smoothedYield[1], yieldChange[1]]

f_regimeName(int regime) =>
    switch regime
        1 => "Bull Steepener"
        2 => "Bull Flattener"
        3 => "Bear Steepener"
        4 => "Bear Flattener"
        => "Unclear"

f_regimeColor(int regime) =>
    switch regime
        1 => color.rgb(0, 170, 110)
        2 => color.rgb(30, 125, 210)
        3 => color.rgb(230, 145, 25)
        4 => color.rgb(210, 55, 55)
        => color.gray

f_formatBp(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.0") + " bp"

f_formatPct(float value) =>
    na(value) ? "n/a" : str.tostring(value * 100.0, "#.0") + "%"

//=============================================================================
// REQUEST CONFIRMED YIELD DATA
//=============================================================================

[shortYield, shortYieldChange] = request.security(
     shortSymbol,
     analysisTf,
     f_confirmedYieldData(smoothingLength, observationHorizon),
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on
)

[longYield, longYieldChange] = request.security(
     longSymbol,
     analysisTf,
     f_confirmedYieldData(smoothingLength, observationHorizon),
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on
)

// TradingView yield symbols are expressed in percentage points.
// Multiplying their changes by 100 converts them to basis points.
float shortMoveBp = shortYieldChange * 100.0
float longMoveBp  = longYieldChange  * 100.0

// Average movement determines bull versus bear.
// Falling yields = bullish bonds. Rising yields = bearish bonds.
float levelMoveBp = (shortMoveBp + longMoveBp) / 2.0

// Change in long-minus-short spread determines steepening versus flattening.
float curveMoveBp = longMoveBp - shortMoveBp

// Current smoothed long-minus-short spread.
float curveSpreadBp = (longYield - shortYield) * 100.0

bool dataReady =
     not na(shortYield) and
     not na(longYield) and
     not na(levelMoveBp) and
     not na(curveMoveBp)

//=============================================================================
// RAW REGIME CLASSIFICATION
//=============================================================================

// Regime mapping:
//
// 1: Bull steepener  = yields falling, curve widening
// 2: Bull flattener  = yields falling, curve narrowing
// 3: Bear steepener  = yields rising,  curve widening
// 4: Bear flattener  = yields rising,  curve narrowing
// 0: Neutral/unclear

int rawRegime = 0

bool meaningfulLevelMove =
     dataReady and
     math.abs(levelMoveBp) >= minLevelMoveBp and
     levelMoveBp != 0.0

bool meaningfulCurveMove =
     dataReady and
     math.abs(curveMoveBp) >= minCurveMoveBp and
     curveMoveBp != 0.0

if meaningfulLevelMove and meaningfulCurveMove
    if levelMoveBp < 0.0 and curveMoveBp > 0.0
        rawRegime := 1
    else if levelMoveBp < 0.0 and curveMoveBp < 0.0
        rawRegime := 2
    else if levelMoveBp > 0.0 and curveMoveBp > 0.0
        rawRegime := 3
    else if levelMoveBp > 0.0 and curveMoveBp < 0.0
        rawRegime := 4

float rawWeight = 0.0

if rawRegime != 0
    rawWeight := voteWeighting == "Magnitude weighted" ?
         math.sqrt(math.abs(levelMoveBp) * math.abs(curveMoveBp)) :
         1.0

//=============================================================================
// ROLLING DOMINANCE ENGINE
//=============================================================================

// Arrays are updated once per analysis-timeframe period. This prevents a
// daily observation from being counted repeatedly on intraday charts.
var array<int> regimeHistory   = array.new<int>()
var array<float> weightHistory = array.new<float>()

var int stableRegime     = 0
var int leaderRegime     = 0
var int qualifiedRegime  = 0
var int pendingRegime    = 0
var int pendingCount     = 0
var int sampleCount      = 0

var float dominantShareNow = na
var float coverageShareNow = na

var float bullSteepShareNow = na
var float bullFlatShareNow  = na
var float bearSteepShareNow = na
var float bearFlatShareNow  = na

bool newAnalysisBar = timeframe.change(analysisTf) or barstate.isfirst

if newAnalysisBar and dataReady
    array.push(regimeHistory, rawRegime)
    array.push(weightHistory, rawWeight)

    if array.size(regimeHistory) > dominanceWindow
        array.shift(regimeHistory)
        array.shift(weightHistory)

    sampleCount := array.size(regimeHistory)

    float bullSteepScore = 0.0
    float bullFlatScore  = 0.0
    float bearSteepScore = 0.0
    float bearFlatScore  = 0.0

    int classifiedCount = 0

    for i = 0 to sampleCount - 1
        int historicalRegime = array.get(regimeHistory, i)
        float historicalWeight = array.get(weightHistory, i)

        if historicalRegime != 0
            classifiedCount += 1

        if historicalRegime == 1
            bullSteepScore += historicalWeight
        else if historicalRegime == 2
            bullFlatScore += historicalWeight
        else if historicalRegime == 3
            bearSteepScore += historicalWeight
        else if historicalRegime == 4
            bearFlatScore += historicalWeight

    float totalScore =
         bullSteepScore +
         bullFlatScore +
         bearSteepScore +
         bearFlatScore

    float bullSteepShare = totalScore > 0.0 ? bullSteepScore / totalScore : 0.0
    float bullFlatShare  = totalScore > 0.0 ? bullFlatScore  / totalScore : 0.0
    float bearSteepShare = totalScore > 0.0 ? bearSteepScore / totalScore : 0.0
    float bearFlatShare  = totalScore > 0.0 ? bearFlatScore  / totalScore : 0.0

    float coverageShare = sampleCount > 0 ?
         float(classifiedCount) / float(sampleCount) :
         0.0

    int candidate = 0
    float candidateShare = 0.0

    if totalScore > 0.0
        candidate := 1
        candidateShare := bullSteepShare

        if bullFlatShare > candidateShare
            candidate := 2
            candidateShare := bullFlatShare

        if bearSteepShare > candidateShare
            candidate := 3
            candidateShare := bearSteepShare

        if bearFlatShare > candidateShare
            candidate := 4
            candidateShare := bearFlatShare

    float runnerUpShare = 0.0

    if candidate == 1
        runnerUpShare := math.max(
             bullFlatShare,
             math.max(bearSteepShare, bearFlatShare)
        )
    else if candidate == 2
        runnerUpShare := math.max(
             bullSteepShare,
             math.max(bearSteepShare, bearFlatShare)
        )
    else if candidate == 3
        runnerUpShare := math.max(
             bullSteepShare,
             math.max(bullFlatShare, bearFlatShare)
        )
    else if candidate == 4
        runnerUpShare := math.max(
             bullSteepShare,
             math.max(bullFlatShare, bearSteepShare)
        )

    bool enoughHistory =
         not requireFullWindow or
         sampleCount >= dominanceWindow

    bool enoughCoverage =
         coverageShare >= minCoveragePct / 100.0

    bool enoughDominance =
         candidateShare >= minDominancePct / 100.0

    bool enoughLead =
         candidateShare - runnerUpShare >= minLeadPct / 100.0

    bool candidateQualifies =
         candidate != 0 and
         enoughHistory and
         enoughCoverage and
         enoughDominance and
         enoughLead

    leaderRegime := candidate
    qualifiedRegime := candidateQualifies ? candidate : 0

    dominantShareNow := candidateShare
    coverageShareNow := coverageShare

    bullSteepShareNow := bullSteepShare
    bullFlatShareNow  := bullFlatShare
    bearSteepShareNow := bearSteepShare
    bearFlatShareNow  := bearFlatShare

    // Hysteresis and persistence logic.
    if qualifiedRegime == stableRegime
        pendingRegime := 0
        pendingCount := 0

    else if qualifiedRegime == 0
        pendingRegime := 0
        pendingCount := 0

        if not holdPreviousWhenUnclear
            stableRegime := 0

    else
        if pendingRegime == qualifiedRegime
            pendingCount += 1
        else
            pendingRegime := qualifiedRegime
            pendingCount := 1

        if pendingCount >= confirmationBars
            stableRegime := qualifiedRegime
            pendingRegime := 0
            pendingCount := 0

//=============================================================================
// DISPLAY
//=============================================================================

color stableColor = f_regimeColor(stableRegime)

bgcolor(
     color.new(stableColor, stableRegime == 0 ? 94 : 87),
     title = "Stable regime background"
)

plot(
     dominantShareNow * 100.0,
     "Dominant regime share",
     color = stableColor,
     linewidth = 3,
     style = plot.style_stepline
)

plot(
     coverageShareNow * 100.0,
     "Classified coverage",
     color = color.new(color.silver, 35),
     linewidth = 1
)

plot(
     showComponentShares ? bullSteepShareNow * 100.0 : na,
     "Bull steepener share",
     color = color.rgb(0, 170, 110),
     linewidth = 1
)

plot(
     showComponentShares ? bullFlatShareNow * 100.0 : na,
     "Bull flattener share",
     color = color.rgb(30, 125, 210),
     linewidth = 1
)

plot(
     showComponentShares ? bearSteepShareNow * 100.0 : na,
     "Bear steepener share",
     color = color.rgb(230, 145, 25),
     linewidth = 1
)

plot(
     showComponentShares ? bearFlatShareNow * 100.0 : na,
     "Bear flattener share",
     color = color.rgb(210, 55, 55),
     linewidth = 1
)

hline(
     minDominancePct,
     "Minimum dominance",
     color = color.new(color.gray, 45),
     linestyle = hline.style_dashed
)

hline(0.0, "0%", color = color.new(color.gray, 80))
hline(100.0, "100%", color = color.new(color.gray, 80))

bool regimeChanged =
     stableRegime != nz(stableRegime[1], 0) and
     stableRegime != 0

plotshape(
     regimeChanged and stableRegime == 1,
     title = "Bull steepener switch",
     style = shape.labelup,
     location = location.bottom,
     color = color.rgb(0, 170, 110),
     text = "Bull\nSteepener",
     textcolor = color.white,
     size = size.tiny
)

plotshape(
     regimeChanged and stableRegime == 2,
     title = "Bull flattener switch",
     style = shape.labelup,
     location = location.bottom,
     color = color.rgb(30, 125, 210),
     text = "Bull\nFlattener",
     textcolor = color.white,
     size = size.tiny
)

plotshape(
     regimeChanged and stableRegime == 3,
     title = "Bear steepener switch",
     style = shape.labelup,
     location = location.bottom,
     color = color.rgb(230, 145, 25),
     text = "Bear\nSteepener",
     textcolor = color.white,
     size = size.tiny
)

plotshape(
     regimeChanged and stableRegime == 4,
     title = "Bear flattener switch",
     style = shape.labelup,
     location = location.bottom,
     color = color.rgb(210, 55, 55),
     text = "Bear\nFlattener",
     textcolor = color.white,
     size = size.tiny
)

//=============================================================================
// DASHBOARD
//=============================================================================

float chartSeconds = timeframe.in_seconds()
float analysisSeconds = timeframe.in_seconds(analysisTf)

bool chartTfTooHigh =
     not na(chartSeconds) and
     not na(analysisSeconds) and
     chartSeconds > analysisSeconds

string statusText = "Stable"

if chartTfTooHigh
    statusText := "Use chart TF ≤ analysis TF"
else if requireFullWindow and sampleCount < dominanceWindow
    statusText := "Warming up: " +
         str.tostring(sampleCount) + "/" +
         str.tostring(dominanceWindow)
else if qualifiedRegime == 0
    statusText := "No regime passes filters"
else if pendingRegime != 0
    statusText := "Confirming " +
         str.tostring(pendingCount) + "/" +
         str.tostring(confirmationBars)

string pendingText = pendingRegime == 0 ?
     "None" :
     f_regimeName(pendingRegime) +
     " " +
     str.tostring(pendingCount) +
     "/" +
     str.tostring(confirmationBars)

var table dashboard = table.new(
     position.top_right,
     2,
     9,
     border_width = 1
)

if barstate.islast and showDashboard
    table.cell(
         dashboard, 0, 0, "Stable regime",
         bgcolor = color.new(stableColor, 15),
         text_color = color.white
    )
    table.cell(
         dashboard, 1, 0, f_regimeName(stableRegime),
         bgcolor = color.new(stableColor, 15),
         text_color = color.white
    )

    table.cell(dashboard, 0, 1, "Current leader")
    table.cell(dashboard, 1, 1, f_regimeName(leaderRegime))

    table.cell(dashboard, 0, 2, "Qualified leader")
    table.cell(
         dashboard,
         1,
         2,
         qualifiedRegime == 0 ? "None" : f_regimeName(qualifiedRegime)
    )

    table.cell(dashboard, 0, 3, "Pending switch")
    table.cell(dashboard, 1, 3, pendingText)

    table.cell(dashboard, 0, 4, "Dominant share")
    table.cell(dashboard, 1, 4, f_formatPct(dominantShareNow))

    table.cell(dashboard, 0, 5, "Classified coverage")
    table.cell(dashboard, 1, 5, f_formatPct(coverageShareNow))

    table.cell(dashboard, 0, 6, "Curve spread")
    table.cell(dashboard, 1, 6, f_formatBp(curveSpreadBp))

    table.cell(dashboard, 0, 7, "Level / curve move")
    table.cell(
         dashboard,
         1,
         7,
         f_formatBp(levelMoveBp) +
         " / " +
         f_formatBp(curveMoveBp)
    )

    table.cell(
         dashboard,
         0,
         8,
         "Status",
         bgcolor = chartTfTooHigh ?
              color.new(color.red, 25) :
              color.new(color.gray, 80)
    )
    table.cell(
         dashboard,
         1,
         8,
         statusText,
         bgcolor = chartTfTooHigh ?
              color.new(color.red, 25) :
              color.new(color.gray, 80)
    )

//=============================================================================
// ALERTS
//=============================================================================

alertcondition(
     regimeChanged and stableRegime == 1,
     "Stable Bull Steepener",
     "Stable yield-curve regime changed to Bull Steepener."
)

alertcondition(
     regimeChanged and stableRegime == 2,
     "Stable Bull Flattener",
     "Stable yield-curve regime changed to Bull Flattener."
)

alertcondition(
     regimeChanged and stableRegime == 3,
     "Stable Bear Steepener",
     "Stable yield-curve regime changed to Bear Steepener."
)

alertcondition(
     regimeChanged and stableRegime == 4,
     "Stable Bear Flattener",
     "Stable yield-curve regime changed to Bear Flattener."
)
````
