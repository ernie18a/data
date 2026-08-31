<!-- tradingview-pine-id: PUB;5642f1de35a244fb895dbc57867d70b0 -->
<!-- tradingviewscripts-format: 1 -->
# RibbonFlux MA - Adaptive Flow [AFD]

Source: https://www.tradingview.com/script/3h7sQkFU-RibbonFlux-MA-Adaptive-Flow-AFD/

## Description

[image]https://www.tradingview.com/x/KS2F5uVs/[/image]

Your averages are stacked and pointing the same way - but is that move widening, just holding, or already compressing?

Every MA ribbon on the shelf draws the same two or three lines and floods the gap with one colour at one opacity. So a ribbon that has pulled four ATR apart and is still separating looks exactly like a ribbon that has collapsed onto itself. The fill never tells you anything the lines didn't, which is why most people end up reading the lines and ignoring the shading entirely.

RibbonFlux makes the space between the lines carry the information.The gap is measured against ATR, ranked against its own recent history, and the shading answers to that: it deepens while the legs separate in agreement, and drains to a restrained neutral the moment they compress or lose their order. Same averages you already read - the space between them now states which of four conditions it is in.

WHY IT MATTERS
Separation and compression are the two things an MA ribbon actually knows, and the standard ribbon throws both away by drawing them identically. RibbonFlux spends its whole visual budget on that one distinction. It describes geometry already on your chart - never a prediction of what comes next, and never an instruction to act.

AT A GLANCE
[image]https://www.tradingview.com/x/0fXJLwM7/[/image]

[*]Three independent averages - Lead, Base, and an optional Third. Each picks its own method, length (2-250) and price source, and a single enabled average still draws on its own.
[*]Eight methods per slot - EMA, SMA, WMA, VWMA, HMA, RMA (Wilder), McGinley Dynamic, Fibonacci EMA Composite. Mixed freely: an HMA Lead over an EMA Base over an RMA Third is a valid setup.
[*]Seven price sources per slot - Open, High, Low, Close, HL2, HLC3, OHLC4. Set per average rather than globally, and always on the chart timeframe.
[*]The Flow Phase Engine - four conditions drive the fill's colour and depth: coherent expansion, stable flow, compression, mixed structure. Display only, and they never touch the MA values.
[*]Each leg measured separately - Lead/Base and Base/Third are scored independently, so one fill can be compressing while the other expands. A single-opacity ribbon cannot show that.
[*]Twelve palettes - Ocean, Indigo, Ember, Mono, Forest, Gold, Violet, Orderflow, Midnight, Copper, Arctic, Carbon. Or set Line color mode to Custom for a fixed colour per average, independent of the flow.
[*]Line width and line style - 1 to 4 pixels, and Solid, Stepped, Dotted or Crosses. Applied to every core line and both halo tiers together, so the whole system thins or thickens as one.
[*]Optional flow candles - bodies, wicks and borders take the relationship colour. Off by default, and under Adaptive dynamics they turn neutral during compression along with the ribbon.
[*]Deliberately quiet - seven plots, two fills, one optional candle overlay. No alerts, no arrows, no dashboard, no labels, no boxes, no trendlines, nothing else drawn.

THE FOUR FLOW PHASES
Each leg of the ribbon is classified on every bar, and its own fill responds. Nothing here produces an event, and no phase ranks, scores or grades the market.

[*]Coherent expansion - the enabled averages are in order, sloping the same way, and that leg is widening. Deepest shading: the phase factor is 1.00.
[*]Stable flow - in order and sloping together, but the leg is not widening. Held back at 0.75.
[*]Compression - the leg's ATR-normalized spacing sits in the bottom fifth of its own last 100 bars. Restrained neutral colour, and a phase factor of 0.00, which leaves depth at its 0.35 floor.
[*]Mixed structure - the ordering or the slope agreement has broken. Restrained neutral colour, minimal shading at 0.25.

Compression uses a deadband, not a single threshold: a leg enters compression at a percent rank of 20 or below and only leaves it at 30 or above, so a leg hovering near one number does not flicker between two appearances. Before 100 bars of history exist, no leg is classified as compressed.

THE MECHANICS, STATED PLAINLY
ATR spacing = abs(faster average - slower average) / max(ATR(14), one tick)

leg depth = 0.35 + 0.65 x clamp(ATR spacing, 0, 1) x phase factor, then EMA-smoothed over the Flow response length

compression: enter at percent rank <= 20 over 100 bars, leave at >= 30

ordered: Lead > Base (> Third), or Lead < Base (< Third)

Flow response sets one number used three ways - the slope lookback, the expansion lookback, and the smoothing length: Quick is 2 bars, Balanced 3, Smooth 5. Setting Ribbon dynamics to Fixed bypasses the engine and holds each fill at the opacity you selected.

HOW IT DIFFERS FROM A STANDARD MA RIBBON
[image]https://www.tradingview.com/x/iWYqEQR7/[/image]

[*]The fill is measured, not decorative - opacity is a function of ATR-normalized spacing and phase, recomputed every bar. A conventional ribbon fills the gap at a constant tone however wide or narrow it is.
[*]Both legs are scored on their own terms - the Lead/Base fill and the Base/Third fill can disagree, so compression in the inner leg does not mute the outer one, or the reverse.
[*]Compression is relative to the instrument, and sticky - a percent rank of its own history with a 20/30 deadband, not a fixed price or tick distance. It travels across symbols and timeframes without retuning.
[*]Two methods a ribbon rarely offers - McGinley Dynamic and a Fibonacci EMA Composite. The composite is the equal-weight mean of five EMAs at Fibonacci-scaled periods; McGinley scales its own step by the fourth power of the price ratio.
[*]The arithmetic ships with an independent open-source reference implementation - every documented formula is reproducible rather than asserted. A trust signal, not the pitch: what you are here for is the ribbon, not the tests.

THE VISUALS

[*]Lead and Base - a crisp core line plus two restrained halo tiers each. At the default width of 2 the Lead halos are 6 and 4 pixels and the Base halos 5 and 3; Line width scales all of it together.
[*]Glow - Off, Soft, Balanced, Rich, with opacity following Lead/Base spacing independently of the ribbon. So the lines themselves brighten as the pair separates, with a floor so they never vanish.
[*]Ribbon shading - Off, Soft, Balanced, Rich sets the maximum depth the Flow Phases then modulate. Off removes both fills and leaves the lines.
[*]A valid Third MA - one crisp line plus its own Base-to-Third shade. It also joins the ordering and slope tests, so enabling it makes coherence a three-line condition.
[*]Line style - Stepped holds each value until the next bar. Dotted and Crosses place one mark per bar, so spacing follows bar width and opens up as you zoom in. Pine's plot() has no stroked dotted or dashed line, and this script uses no drawing objects to fake one.
[*]Layering - the lines and fills draw in front of the candles, not behind them. Deliberate, so the optional flow candles can colour wicks and borders as well as bodies; if it reads heavy, Line width 1 or Glow Soft thins it.

HOW TO USE IT

[*]Start with the defaults - Close EMA 9 over Close EMA 21, Ocean, Balanced glow and shading, Adaptive dynamics. Chosen for readability, not tuned as trading parameters.
[*]Enable the Third MA for slower context - it defaults to Close EMA 50. Ordering then requires all three in sequence, a stricter condition than two.
[*]Reach for Flow response first - Quick if the shading feels sluggish, Smooth if it feels twitchy. It is the one control that changes how fast the appearance reacts.
[*]Set Ribbon dynamics to Fixed to switch the engine off - a plain constant-opacity ribbon, for comparing against what you ran before. Everything else, from palette to custom colours to width, style, glow and candle colouring, is taste: set it once and leave it.

WHAT IT DELIBERATELY DOES NOT DO
It issues no alerts and has no alert conditions at all. It draws no arrows, entries, retests, setup zones, targets or labels, keeps no dashboard or readout, and ranks, scores and grades nothing. It makes no accuracy, reliability, profitability, probability or future-result claim of any kind. Moving averages are lagging transformations of price that has already printed: visible separation, alignment or colour establishes neither future direction nor the quality of any trade. Educational chart context only - not financial advice.

DATA, TIMEFRAMES, AND WHAT TO CHECK YOURSELF

[*]Everything is computed on your chart's own timeframe and data - there are no higher-timeframe requests anywhere in the source, so there is no lookahead argument to disclose and no second feed to reconcile against your chart.
[*]Any MA moves while its bar is still forming, and two parts of this script also carry state from bar to bar: the McGinley recursion and the compression deadband. That describes the mechanism. Confirm it with the bar-replay tool on your own symbol and timeframe before relying on it - a description of mechanism is not that check, and nothing here claims to be.
[*]The averages read chart OHLC - on Heikin Ashi, Renko, Range or similar they average those synthetic values, not traded prices. Use standard time-based candles if you want the averages to describe real prices.
[*]VWMA needs usable volume, and the Fibonacci EMA Composite needs a length of 8 or more - each is simply unavailable otherwise. A selected calculation that cannot be produced stays unavailable: the script never silently substitutes another method.
[*]McGinley seeds from an SMA of its own length, then advances by previous + (source - previous) / (0.6 x length x ratio^4). If its source or recurrence goes invalid the line goes unavailable and reseeds only after the next contiguous valid window.
[*]Identical Lead and Base settings leave nothing to read - both lines still draw, but the ribbon and flow candles switch off and the lines fall back to neutral. A Third duplicating Lead or Base likewise draws its line while taking no shade and no phase depth.

ORIGINALITY AND CREDIT
Ribbon indicators are old ground; what is new here is that the fill is a measurement rather than a decoration - ATR-normalized leg spacing, a relative compression rank with hysteresis, and per-leg depth, all resolved into colour and opacity and nothing else. The engine is deliberately confined to display, and the surface is deliberately small.

Open source under the Mozilla Public License 2.0. (c) Auction Foundry LLC.

This indicator describes the geometry of averages computed from your chart's own price history. It is not a forecast, not a signal, and not financial advice.

---

## Source Code

````pine
// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.
// © Auction Foundry LLC

//@version=6
indicator("RibbonFlux MA - Adaptive Flow [AFD]", "RFLX [AFD]", overlay = true, behind_chart = false)

const string GROUP_AVERAGES = "Averages"
const string GROUP_APPEARANCE = "Appearance"

const string METHOD_EMA = "EMA"
const string METHOD_SMA = "SMA"
const string METHOD_WMA = "WMA"
const string METHOD_VWMA = "VWMA"
const string METHOD_HMA = "HMA"
const string METHOD_RMA = "RMA (Wilder)"
const string METHOD_MCGINLEY = "McGinley Dynamic"
const string METHOD_FIBONACCI = "Fibonacci EMA Composite"

const string PALETTE_OCEAN = "Ocean"
const string PALETTE_INDIGO = "Indigo"
const string PALETTE_EMBER = "Ember"
const string PALETTE_MONO = "Mono"
const string PALETTE_FOREST = "Forest"
const string PALETTE_GOLD = "Gold"
const string PALETTE_VIOLET = "Violet"
const string PALETTE_ORDERFLOW = "Orderflow"
const string PALETTE_MIDNIGHT = "Midnight"
const string PALETTE_COPPER = "Copper"
const string PALETTE_ARCTIC = "Arctic"
const string PALETTE_CARBON = "Carbon"

const string LINE_COLORS_FLOW = "Flow colors"
const string LINE_COLORS_CUSTOM = "Custom"

const string GLOW_OFF = "Off"
const string GLOW_SOFT = "Soft"
const string GLOW_BALANCED = "Balanced"
const string GLOW_RICH = "Rich"

const string RIBBON_OFF = "Off"
const string RIBBON_SOFT = "Soft"
const string RIBBON_BALANCED = "Balanced"
const string RIBBON_RICH = "Rich"

const string DYNAMICS_FIXED = "Fixed"
const string DYNAMICS_ADAPTIVE = "Adaptive"

const string RESPONSE_QUICK = "Quick"
const string RESPONSE_BALANCED = "Balanced"
const string RESPONSE_SMOOTH = "Smooth"

const string LINESTYLE_SOLID = "Solid"
const string LINESTYLE_STEPPED = "Stepped"
const string LINESTYLE_DOTTED = "Dotted"
const string LINESTYLE_CROSSES = "Crosses"

const string SOURCE_OPEN = "Open"
const string SOURCE_HIGH = "High"
const string SOURCE_LOW = "Low"
const string SOURCE_CLOSE = "Close"
const string SOURCE_HL2 = "HL2"
const string SOURCE_HLC3 = "HLC3"
const string SOURCE_OHLC4 = "OHLC4"

const int FLOW_ATR_LENGTH = 14
const int FLOW_PERCENT_RANK_LENGTH = 100
const float FLOW_COMPRESSION_ENTER = 20.0
const float FLOW_COMPRESSION_RELEASE = 30.0
const float GLOW_INTENSITY_FLOOR = 0.35
const float FLOW_DEPTH_FLOOR = 0.35

bool showLeadAverage = input.bool(true, "Enable Lead MA", tooltip = "• Shows the Lead MA.\n• Lead and Base together form the flow ribbon.", group = GROUP_AVERAGES, display = display.none)
string leadSourceChoice = input.string(SOURCE_CLOSE, "Lead source", options = [SOURCE_OPEN, SOURCE_HIGH, SOURCE_LOW, SOURCE_CLOSE, SOURCE_HL2, SOURCE_HLC3, SOURCE_OHLC4], tooltip = "• Price field used by the Lead MA.\n• Uses the chart timeframe.", group = GROUP_AVERAGES, display = display.none, active = showLeadAverage)
string leadMethod = input.string(METHOD_EMA, "Lead MA type", options = [METHOD_EMA, METHOD_SMA, METHOD_WMA, METHOD_VWMA, METHOD_HMA, METHOD_RMA, METHOD_MCGINLEY, METHOD_FIBONACCI], tooltip = "• Selects the Lead MA calculation.\n• RMA (Wilder) smooths price; it is not RSI.", group = GROUP_AVERAGES, display = display.none, active = showLeadAverage)
int leadLength = input.int(9, "Lead length", minval = 2, maxval = 250, tooltip = "• Bars used by the Lead MA.\n• Lower = faster and more reactive.\n• Higher = smoother and slower.\n• Fibonacci EMA Composite requires 8 or more.", group = GROUP_AVERAGES, display = display.none, active = showLeadAverage)
bool showBaseAverage = input.bool(true, "Enable Base MA", tooltip = "• Shows the Base MA.\n• Lead and Base together form the flow ribbon.", group = GROUP_AVERAGES, display = display.none)
string baseSourceChoice = input.string(SOURCE_CLOSE, "Base source", options = [SOURCE_OPEN, SOURCE_HIGH, SOURCE_LOW, SOURCE_CLOSE, SOURCE_HL2, SOURCE_HLC3, SOURCE_OHLC4], tooltip = "• Price field used by the Base MA.\n• Uses the chart timeframe.", group = GROUP_AVERAGES, display = display.none, active = showBaseAverage)
string baseMethod = input.string(METHOD_EMA, "Base MA type", options = [METHOD_EMA, METHOD_SMA, METHOD_WMA, METHOD_VWMA, METHOD_HMA, METHOD_RMA, METHOD_MCGINLEY, METHOD_FIBONACCI], tooltip = "• Selects the Base MA calculation.\n• RMA (Wilder) smooths price; it is not RSI.", group = GROUP_AVERAGES, display = display.none, active = showBaseAverage)
int baseLength = input.int(21, "Base length", minval = 2, maxval = 250, tooltip = "• Bars used by the Base MA.\n• Lower = faster and more reactive.\n• Higher = smoother and slower.\n• Fibonacci EMA Composite requires 8 or more.", group = GROUP_AVERAGES, display = display.none, active = showBaseAverage)
bool showThirdAverage = input.bool(false, "Enable Third MA", tooltip = "• Shows the Third MA.\n• When valid and distinct, it adds a shade and participates in Flow Phases.", group = GROUP_AVERAGES, display = display.none)
string thirdSourceChoice = input.string(SOURCE_CLOSE, "Third source", options = [SOURCE_OPEN, SOURCE_HIGH, SOURCE_LOW, SOURCE_CLOSE, SOURCE_HL2, SOURCE_HLC3, SOURCE_OHLC4], tooltip = "• Price field used by the Third MA.\n• Uses the chart timeframe.", group = GROUP_AVERAGES, display = display.none, active = showThirdAverage)
string thirdMethod = input.string(METHOD_EMA, "Third MA type", options = [METHOD_EMA, METHOD_SMA, METHOD_WMA, METHOD_VWMA, METHOD_HMA, METHOD_RMA, METHOD_MCGINLEY, METHOD_FIBONACCI], tooltip = "• Selects the Third MA calculation.\n• RMA (Wilder) smooths price; it is not RSI.", group = GROUP_AVERAGES, display = display.none, active = showThirdAverage)
int thirdLength = input.int(50, "Third length", minval = 2, maxval = 250, tooltip = "• Bars used by the Third MA.\n• Lower = faster and more reactive.\n• Higher = smoother and slower.\n• Fibonacci EMA Composite requires 8 or more.", group = GROUP_AVERAGES, display = display.none, active = showThirdAverage)

bool primaryAveragesEnabled = showLeadAverage and showBaseAverage
bool anyAverageEnabled = showLeadAverage or showBaseAverage or showThirdAverage

string palette = input.string(PALETTE_OCEAN, "Palette", options = [PALETTE_OCEAN, PALETTE_INDIGO, PALETTE_EMBER, PALETTE_MONO, PALETTE_FOREST, PALETTE_GOLD, PALETTE_VIOLET, PALETTE_ORDERFLOW, PALETTE_MIDNIGHT, PALETTE_COPPER, PALETTE_ARCTIC, PALETTE_CARBON], tooltip = "• Sets flow, ribbon, default Third MA, and optional candle colors.\n• Visual only.", group = GROUP_APPEARANCE, display = display.none, active = anyAverageEnabled)
string lineColorMode = input.string(LINE_COLORS_FLOW, "Line color mode", options = [LINE_COLORS_FLOW, LINE_COLORS_CUSTOM], tooltip = "• Flow colors follow the Lead/Base relationship.\n• Custom uses a fixed color for each enabled MA line.", group = GROUP_APPEARANCE, display = display.none, active = anyAverageEnabled)
color customLeadLineColor = input.color(color.rgb(40, 218, 210), "Custom Lead line", tooltip = "• Fixed Lead MA line and halo color in Custom mode.", group = GROUP_APPEARANCE, display = display.none, active = showLeadAverage and lineColorMode == LINE_COLORS_CUSTOM)
color customBaseLineColor = input.color(color.rgb(255, 82, 145), "Custom Base line", tooltip = "• Fixed Base MA line and halo color in Custom mode.", group = GROUP_APPEARANCE, display = display.none, active = showBaseAverage and lineColorMode == LINE_COLORS_CUSTOM)
color customThirdLineColor = input.color(color.rgb(255, 196, 80), "Custom Third line", tooltip = "• Fixed Third MA line and Base/Third shade color in Custom mode.", group = GROUP_APPEARANCE, display = display.none, active = showThirdAverage and lineColorMode == LINE_COLORS_CUSTOM)
int lineWidth = input.int(2, "Line width", minval = 1, maxval = 4, tooltip = "• Thickness of the MA core lines in pixels.\n• Halo widths scale with it.\n• Lower = more of the candle stays visible.\n• Higher = heavier lines.", group = GROUP_APPEARANCE, display = display.none, active = anyAverageEnabled)
string lineStyleChoice = input.string(LINESTYLE_SOLID, "Line style", options = [LINESTYLE_SOLID, LINESTYLE_STEPPED, LINESTYLE_DOTTED, LINESTYLE_CROSSES], tooltip = "• Applies to every MA line and its halos.\n• Solid draws a continuous line.\n• Stepped holds each value until the next bar.\n• Dotted and Crosses mark one point per bar, so their spacing follows bar width and they open up as you zoom in.", group = GROUP_APPEARANCE, display = display.none, active = anyAverageEnabled)
string glow = input.string(GLOW_BALANCED, "Glow", options = [GLOW_OFF, GLOW_SOFT, GLOW_BALANCED, GLOW_RICH], tooltip = "• Off removes line halos.\n• Soft, Balanced, and Rich increase maximum opacity.\n• Valid Lead/Base spacing scales opacity relative to ATR(14).\n• Standalone lines use the full preset; visual only.", group = GROUP_APPEARANCE, display = display.none, active = showLeadAverage or showBaseAverage)
bool showRibbon = input.bool(true, "Show flow ribbon", tooltip = "• Shows the Lead/Base fill.\n• Also shades Base/Third when Third is enabled and valid.", group = GROUP_APPEARANCE, display = display.none, active = primaryAveragesEnabled)
string ribbonShading = input.string(RIBBON_BALANCED, "Ribbon shading", options = [RIBBON_OFF, RIBBON_SOFT, RIBBON_BALANCED, RIBBON_RICH], tooltip = "• Off removes both fills.\n• Soft is lightest; Rich is darkest.\n• Visual only.", group = GROUP_APPEARANCE, display = display.none, active = primaryAveragesEnabled and showRibbon)
string ribbonDynamics = input.string(DYNAMICS_ADAPTIVE, "Ribbon dynamics", options = [DYNAMICS_FIXED, DYNAMICS_ADAPTIVE], tooltip = "• Fixed keeps each fill at the selected opacity.\n• Adaptive shows coherent expansion, stable flow, compression, and mixed structure.\n• Uses ATR(14) and recent relative spacing; visual only.", group = GROUP_APPEARANCE, display = display.none, active = primaryAveragesEnabled and showRibbon and ribbonShading != RIBBON_OFF)
string flowResponse = input.string(RESPONSE_BALANCED, "Flow response", options = [RESPONSE_QUICK, RESPONSE_BALANCED, RESPONSE_SMOOTH], tooltip = "• Quick reacts over 2 bars.\n• Balanced uses 3 bars.\n• Smooth uses 5 bars and changes most gradually.\n• Affects Adaptive display only.", group = GROUP_APPEARANCE, display = display.none, active = primaryAveragesEnabled and showRibbon and ribbonShading != RIBBON_OFF and ribbonDynamics == DYNAMICS_ADAPTIVE)
bool colorBars = input.bool(false, "Color bars by flow", tooltip = "• Colors candle bodies, wicks, and borders with the Lead/Base relationship.\n• Adaptive compression uses the neutral palette color.\n• Uses fully opaque colors; visual only.", group = GROUP_APPEARANCE, display = display.none, active = primaryAveragesEnabled)

f_priceSource(simple string choice) =>
    switch choice
        SOURCE_OPEN => open
        SOURCE_HIGH => high
        SOURCE_LOW => low
        SOURCE_CLOSE => close
        SOURCE_HL2 => hl2
        SOURCE_HLC3 => hlc3
        SOURCE_OHLC4 => ohlc4
        => na

float leadSource = f_priceSource(leadSourceChoice)
float baseSource = f_priceSource(baseSourceChoice)
float thirdSource = f_priceSource(thirdSourceChoice)

f_fibonacciComposite(float source, simple int length) =>
    int period1 = math.max(1, int(math.round(length * 5.0 / 34.0)))
    int period2 = math.max(1, int(math.round(length * 8.0 / 34.0)))
    int period3 = math.max(1, int(math.round(length * 13.0 / 34.0)))
    int period4 = math.max(1, int(math.round(length * 21.0 / 34.0)))
    int period5 = math.max(1, int(math.round(length * 34.0 / 34.0)))
    float ema1 = ta.ema(source, period1)
    float ema2 = ta.ema(source, period2)
    float ema3 = ta.ema(source, period3)
    float ema4 = ta.ema(source, period4)
    float ema5 = ta.ema(source, period5)
    bool componentsValid = not na(ema1) and not na(ema2) and not na(ema3) and not na(ema4) and not na(ema5)
    length >= 8 and componentsValid ? (ema1 + ema2 + ema3 + ema4 + ema5) / 5.0 : na

f_mcginley(float source, simple int length) =>
    float seed = ta.sma(source, length)
    float priceGuard = math.max(syminfo.mintick * 0.000001, 0.000000000001)
    float denominatorGuard = 0.000000000001
    var float value = na
    var bool seeded = false
    var int validBars = 0
    bool sourceValid = not na(source) and math.abs(source) > priceGuard
    validBars := sourceValid ? math.min(validBars + 1, length) : 0
    if not sourceValid
        value := na
        seeded := false
    else if not seeded
        value := na
        if validBars >= length and not na(seed) and math.abs(seed) > priceGuard
            value := seed
            seeded := true
    else
        float previous = value[1]
        if na(previous) or math.abs(previous) <= priceGuard
            value := na
            seeded := false
            validBars := 1
        else
            float ratio = source / previous
            float denominator = 0.6 * length * math.pow(ratio, 4.0)
            if na(denominator) or math.abs(denominator) <= denominatorGuard
                value := na
                seeded := false
                validBars := 1
            else
                float candidate = previous + (source - previous) / denominator
                if na(candidate)
                    value := na
                    seeded := false
                    validBars := 1
                else
                    value := candidate
    value

f_scaledTransparency(int configuredTransparency, float intensity) =>
    float configuredOpacity = 100.0 - configuredTransparency
    math.max(0.0, math.min(100.0, 100.0 - configuredOpacity * intensity))

f_flowDepth(float normalizedSpacing, bool compressed, bool coherent, bool expanding) =>
    float boundedSpacing = na(normalizedSpacing) ? 0.0 : math.max(0.0, math.min(1.0, normalizedSpacing))
    float phaseFactor = compressed ? 0.0 : coherent ? (expanding ? 1.0 : 0.75) : 0.25
    FLOW_DEPTH_FLOOR + (1.0 - FLOW_DEPTH_FLOOR) * boundedSpacing * phaseFactor

float leadEma = ta.ema(leadSource, leadLength)
float leadSma = ta.sma(leadSource, leadLength)
float leadWma = ta.wma(leadSource, leadLength)
float leadVwma = ta.vwma(leadSource, leadLength)
float leadHma = ta.hma(leadSource, leadLength)
float leadRma = ta.rma(leadSource, leadLength)
float leadFibonacci = f_fibonacciComposite(leadSource, leadLength)
float leadMcGinley = f_mcginley(leadSource, leadLength)

float baseEma = ta.ema(baseSource, baseLength)
float baseSma = ta.sma(baseSource, baseLength)
float baseWma = ta.wma(baseSource, baseLength)
float baseVwma = ta.vwma(baseSource, baseLength)
float baseHma = ta.hma(baseSource, baseLength)
float baseRma = ta.rma(baseSource, baseLength)
float baseFibonacci = f_fibonacciComposite(baseSource, baseLength)
float baseMcGinley = f_mcginley(baseSource, baseLength)

float thirdEma = ta.ema(thirdSource, thirdLength)
float thirdSma = ta.sma(thirdSource, thirdLength)
float thirdWma = ta.wma(thirdSource, thirdLength)
float thirdVwma = ta.vwma(thirdSource, thirdLength)
float thirdHma = ta.hma(thirdSource, thirdLength)
float thirdRma = ta.rma(thirdSource, thirdLength)
float thirdFibonacci = f_fibonacciComposite(thirdSource, thirdLength)
float thirdMcGinley = f_mcginley(thirdSource, thirdLength)

float leadAverage = switch leadMethod
    METHOD_EMA => leadEma
    METHOD_SMA => leadSma
    METHOD_WMA => leadWma
    METHOD_VWMA => leadVwma
    METHOD_HMA => leadHma
    METHOD_RMA => leadRma
    METHOD_MCGINLEY => leadMcGinley
    METHOD_FIBONACCI => leadFibonacci
    => na

float baseAverage = switch baseMethod
    METHOD_EMA => baseEma
    METHOD_SMA => baseSma
    METHOD_WMA => baseWma
    METHOD_VWMA => baseVwma
    METHOD_HMA => baseHma
    METHOD_RMA => baseRma
    METHOD_MCGINLEY => baseMcGinley
    METHOD_FIBONACCI => baseFibonacci
    => na

float thirdAverage = switch thirdMethod
    METHOD_EMA => thirdEma
    METHOD_SMA => thirdSma
    METHOD_WMA => thirdWma
    METHOD_VWMA => thirdVwma
    METHOD_HMA => thirdHma
    METHOD_RMA => thirdRma
    METHOD_MCGINLEY => thirdMcGinley
    METHOD_FIBONACCI => thirdFibonacci
    => na

bool identicalConfiguration = primaryAveragesEnabled and leadMethod == baseMethod and leadLength == baseLength and leadSourceChoice == baseSourceChoice
bool averagesValid = primaryAveragesEnabled and not identicalConfiguration and not na(leadAverage) and not na(baseAverage)
bool thirdAverageValid = not na(thirdAverage)
bool thirdDuplicatesLead = primaryAveragesEnabled and showThirdAverage and thirdMethod == leadMethod and thirdLength == leadLength and thirdSourceChoice == leadSourceChoice
bool thirdDuplicatesBase = primaryAveragesEnabled and showThirdAverage and thirdMethod == baseMethod and thirdLength == baseLength and thirdSourceChoice == baseSourceChoice
bool thirdDuplicatesPrimary = thirdDuplicatesLead or thirdDuplicatesBase
bool thirdFlowValid = not showThirdAverage or (not thirdDuplicatesPrimary and thirdAverageValid)
bool thirdDepthEnabled = showThirdAverage and thirdFlowValid and averagesValid
int rawRelationship = not averagesValid ? 0 : leadAverage > baseAverage ? 1 : leadAverage < baseAverage ? -1 : 0

int flowResponseLength = switch flowResponse
    RESPONSE_QUICK => 2
    RESPONSE_SMOOTH => 5
    => 3

float flowAtr = ta.atr(FLOW_ATR_LENGTH)
bool separationAvailable = averagesValid and not na(flowAtr)
float leadBaseAtrSpacing = separationAvailable ? math.abs(leadAverage - baseAverage) / math.max(flowAtr, syminfo.mintick) : na
float baseThirdAtrSpacing = separationAvailable and thirdDepthEnabled ? math.abs(baseAverage - thirdAverage) / math.max(flowAtr, syminfo.mintick) : na
float normalizedLeadBaseSpacing = not na(leadBaseAtrSpacing) ? math.min(1.0, leadBaseAtrSpacing) : na
float normalizedBaseThirdSpacing = not na(baseThirdAtrSpacing) ? math.min(1.0, baseThirdAtrSpacing) : na
float leadBasePercentRank = ta.percentrank(leadBaseAtrSpacing, FLOW_PERCENT_RANK_LENGTH)
float baseThirdPercentRank = ta.percentrank(baseThirdAtrSpacing, FLOW_PERCENT_RANK_LENGTH)

var bool leadBaseCompressed = false
if not averagesValid or na(leadBasePercentRank)
    leadBaseCompressed := false
else
    leadBaseCompressed := leadBaseCompressed ? leadBasePercentRank < FLOW_COMPRESSION_RELEASE : leadBasePercentRank <= FLOW_COMPRESSION_ENTER

var bool baseThirdCompressed = false
if not thirdDepthEnabled or na(baseThirdPercentRank)
    baseThirdCompressed := false
else
    baseThirdCompressed := baseThirdCompressed ? baseThirdPercentRank < FLOW_COMPRESSION_RELEASE : baseThirdPercentRank <= FLOW_COMPRESSION_ENTER

bool orderedUp = averagesValid and (thirdDepthEnabled ? leadAverage > baseAverage and baseAverage > thirdAverage : leadAverage > baseAverage)
bool orderedDown = averagesValid and (thirdDepthEnabled ? leadAverage < baseAverage and baseAverage < thirdAverage : leadAverage < baseAverage)
int orderedDirection = orderedUp ? 1 : orderedDown ? -1 : 0
bool slopeDataAvailable = averagesValid and not na(leadAverage[flowResponseLength]) and not na(baseAverage[flowResponseLength]) and (not thirdDepthEnabled or not na(thirdAverage[flowResponseLength]))
bool risingTogether = slopeDataAvailable and leadAverage > leadAverage[flowResponseLength] and baseAverage > baseAverage[flowResponseLength] and (not thirdDepthEnabled or thirdAverage > thirdAverage[flowResponseLength])
bool fallingTogether = slopeDataAvailable and leadAverage < leadAverage[flowResponseLength] and baseAverage < baseAverage[flowResponseLength] and (not thirdDepthEnabled or thirdAverage < thirdAverage[flowResponseLength])
bool slopesAligned = orderedDirection == 1 ? risingTogether : orderedDirection == -1 ? fallingTogether : false
bool flowCoherent = orderedDirection != 0 and slopesAligned
bool leadBaseExpanding = not na(leadBaseAtrSpacing) and not na(leadBaseAtrSpacing[flowResponseLength]) and leadBaseAtrSpacing > leadBaseAtrSpacing[flowResponseLength]
bool baseThirdExpanding = thirdDepthEnabled and not na(baseThirdAtrSpacing) and not na(baseThirdAtrSpacing[flowResponseLength]) and baseThirdAtrSpacing > baseThirdAtrSpacing[flowResponseLength]
float rawLeadBaseDepth = f_flowDepth(normalizedLeadBaseSpacing, leadBaseCompressed, flowCoherent, leadBaseExpanding)
float rawBaseThirdDepth = f_flowDepth(normalizedBaseThirdSpacing, baseThirdCompressed, flowCoherent, baseThirdExpanding)
float smoothedLeadBaseDepth = ta.ema(rawLeadBaseDepth, flowResponseLength)
float smoothedBaseThirdDepth = ta.ema(rawBaseThirdDepth, flowResponseLength)
int relationship = ribbonDynamics == DYNAMICS_ADAPTIVE and leadBaseCompressed ? 0 : rawRelationship

color bullishColor = switch palette
    PALETTE_OCEAN => color.rgb(40, 218, 210)
    PALETTE_INDIGO => color.rgb(95, 168, 255)
    PALETTE_EMBER => color.rgb(255, 178, 72)
    PALETTE_FOREST => color.rgb(48, 204, 126)
    PALETTE_GOLD => color.rgb(245, 188, 66)
    PALETTE_VIOLET => color.rgb(153, 112, 255)
    PALETTE_ORDERFLOW => color.rgb(0, 114, 178)
    PALETTE_MIDNIGHT => color.rgb(59, 120, 165)
    PALETTE_COPPER => color.rgb(161, 92, 34)
    PALETTE_ARCTIC => color.rgb(31, 122, 140)
    PALETTE_CARBON => color.rgb(63, 119, 130)
    => color.rgb(222, 226, 232)

color bearishColor = switch palette
    PALETTE_OCEAN => color.rgb(255, 82, 145)
    PALETTE_INDIGO => color.rgb(186, 104, 255)
    PALETTE_EMBER => color.rgb(255, 92, 72)
    PALETTE_FOREST => color.rgb(239, 92, 104)
    PALETTE_GOLD => color.rgb(105, 92, 222)
    PALETTE_VIOLET => color.rgb(255, 92, 176)
    PALETTE_ORDERFLOW => color.rgb(213, 94, 0)
    PALETTE_MIDNIGHT => color.rgb(166, 92, 158)
    PALETTE_COPPER => color.rgb(161, 79, 106)
    PALETTE_ARCTIC => color.rgb(177, 76, 99)
    PALETTE_CARBON => color.rgb(150, 84, 107)
    => color.rgb(112, 118, 128)

color transitionColor = switch palette
    PALETTE_MONO => color.rgb(160, 164, 172)
    PALETTE_ORDERFLOW => color.rgb(107, 114, 128)
    PALETTE_MIDNIGHT => color.rgb(115, 123, 140)
    PALETTE_COPPER => color.rgb(120, 110, 102)
    PALETTE_ARCTIC => color.rgb(106, 118, 135)
    PALETTE_CARBON => color.rgb(105, 113, 123)
    => color.rgb(118, 132, 151)
color flowColor = relationship == 1 ? bullishColor : relationship == -1 ? bearishColor : transitionColor
color thirdDefaultColor = switch palette
    PALETTE_OCEAN => color.rgb(255, 196, 80)
    PALETTE_INDIGO => color.rgb(72, 214, 202)
    PALETTE_EMBER => color.rgb(255, 214, 92)
    PALETTE_FOREST => color.rgb(246, 180, 76)
    PALETTE_GOLD => color.rgb(52, 194, 210)
    PALETTE_VIOLET => color.rgb(78, 214, 164)
    PALETTE_ORDERFLOW => color.rgb(10, 128, 100)
    PALETTE_MIDNIGHT => color.rgb(163, 111, 14)
    PALETTE_COPPER => color.rgb(47, 127, 120)
    PALETTE_ARCTIC => color.rgb(86, 124, 58)
    PALETTE_CARBON => color.rgb(133, 118, 46)
    => color.rgb(188, 192, 200)

color leadLineBaseColor = lineColorMode == LINE_COLORS_CUSTOM ? customLeadLineColor : flowColor
color baseLineBaseColor = lineColorMode == LINE_COLORS_CUSTOM ? customBaseLineColor : flowColor
color thirdLineBaseColor = lineColorMode == LINE_COLORS_CUSTOM ? customThirdLineColor : thirdDefaultColor

int outerTransparency = switch glow
    GLOW_SOFT => 94
    GLOW_BALANCED => 90
    GLOW_RICH => 84
    => 100

int middleTransparency = switch glow
    GLOW_SOFT => 88
    GLOW_BALANCED => 80
    GLOW_RICH => 70
    => 100

float normalizedSeparation = separationAvailable ? normalizedLeadBaseSpacing : 1.0
float haloIntensity = separationAvailable ? GLOW_INTENSITY_FLOOR + (1.0 - GLOW_INTENSITY_FLOOR) * normalizedSeparation : 1.0
float leadOuterTransparency = f_scaledTransparency(outerTransparency, haloIntensity)
float leadMiddleTransparency = f_scaledTransparency(middleTransparency, haloIntensity)
float baseOuterTransparency = f_scaledTransparency(math.min(100, outerTransparency + 3), haloIntensity)
float baseMiddleTransparency = f_scaledTransparency(math.min(100, middleTransparency + 5), haloIntensity)

color leadOuterColor = glow == GLOW_OFF ? na : color.new(leadLineBaseColor, leadOuterTransparency)
color leadMiddleColor = glow == GLOW_OFF ? na : color.new(leadLineBaseColor, leadMiddleTransparency)
color baseOuterColor = glow == GLOW_OFF ? na : color.new(baseLineBaseColor, baseOuterTransparency)
color baseMiddleColor = glow == GLOW_OFF ? na : color.new(baseLineBaseColor, baseMiddleTransparency)
color leadCoreColor = color.new(leadLineBaseColor, 0)
color baseCoreColor = color.new(baseLineBaseColor, 18)

int ribbonBaseTransparency = switch ribbonShading
    RIBBON_OFF => 100
    RIBBON_SOFT => 92
    RIBBON_BALANCED => 86
    => 78

bool ribbonVisible = showRibbon and ribbonShading != RIBBON_OFF
bool adaptiveDynamics = ribbonDynamics == DYNAMICS_ADAPTIVE
bool mixedFlowPhase = adaptiveDynamics and averagesValid and not flowCoherent and not leadBaseCompressed
float leadBaseTransparency = adaptiveDynamics ? f_scaledTransparency(ribbonBaseTransparency, smoothedLeadBaseDepth) : ribbonBaseTransparency
float baseThirdTransparency = adaptiveDynamics ? f_scaledTransparency(ribbonBaseTransparency, smoothedBaseThirdDepth) : ribbonBaseTransparency
color leadBaseFillColor = adaptiveDynamics and (leadBaseCompressed or mixedFlowPhase) ? transitionColor : flowColor
color baseThirdFillColor = adaptiveDynamics and (baseThirdCompressed or mixedFlowPhase) ? transitionColor : thirdLineBaseColor
color ribbonColor = ribbonVisible and averagesValid ? color.new(leadBaseFillColor, leadBaseTransparency) : na
color thirdRibbonColor = ribbonVisible and thirdDepthEnabled ? color.new(baseThirdFillColor, baseThirdTransparency) : na
bool showFlowCandles = colorBars and averagesValid
color flowCandleColor = showFlowCandles ? color.new(flowColor, 0) : na

lineStyle = switch lineStyleChoice
    LINESTYLE_STEPPED => plot.style_stepline
    LINESTYLE_DOTTED => plot.style_circles
    LINESTYLE_CROSSES => plot.style_cross
    => plot.style_line

plotcandle(showFlowCandles ? open : na, showFlowCandles ? high : na, showFlowCandles ? low : na, showFlowCandles ? close : na, "Flow candles", color = flowCandleColor, wickcolor = flowCandleColor, editable = false, bordercolor = flowCandleColor, display = display.pane)
plot(showLeadAverage ? leadAverage : na, "Lead MA outer halo", color = leadOuterColor, linewidth = lineWidth + 4, style = lineStyle, editable = false, display = display.pane)
plot(showLeadAverage ? leadAverage : na, "Lead MA middle halo", color = leadMiddleColor, linewidth = lineWidth + 2, style = lineStyle, editable = false, display = display.pane)
leadCorePlot = plot(showLeadAverage ? leadAverage : na, "Lead MA", color = leadCoreColor, linewidth = lineWidth, style = lineStyle, editable = false)
plot(showBaseAverage ? baseAverage : na, "Base MA outer halo", color = baseOuterColor, linewidth = lineWidth + 3, style = lineStyle, editable = false, display = display.pane)
plot(showBaseAverage ? baseAverage : na, "Base MA middle halo", color = baseMiddleColor, linewidth = lineWidth + 1, style = lineStyle, editable = false, display = display.pane)
baseCorePlot = plot(showBaseAverage ? baseAverage : na, "Base MA", color = baseCoreColor, linewidth = lineWidth, style = lineStyle, editable = false)
thirdCorePlot = plot(showThirdAverage and thirdAverageValid ? thirdAverage : na, "Third MA", color = color.new(thirdLineBaseColor, 0), linewidth = lineWidth, style = lineStyle, editable = false)
fill(baseCorePlot, thirdCorePlot, color = thirdRibbonColor, title = "Third MA shade", editable = false, fillgaps = false)
fill(leadCorePlot, baseCorePlot, color = ribbonColor, title = "Flow ribbon", editable = false, fillgaps = false)
````
