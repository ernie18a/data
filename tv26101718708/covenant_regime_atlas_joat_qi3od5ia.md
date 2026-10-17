# Covenant Regime Atlas [JOAT]

- url: https://www.tradingview.com/script/qi3Od5iA-Covenant-Regime-Atlas-JOAT/
- type: indicator
- pine_id: PUB;bd7e52a7a93b496db64dbe81ce7e085d
- version: 1.0

## Description

[b]Covenant Regime Atlas [JOAT][/b]

[b]Introduction[/b]

Covenant Regime Atlas is an open-source Pine Script v6 market-regime indicator built to classify directional state through trend, expansion, persistence, and retest quality. Its purpose is not to predict the next trade by itself, but to create a durable bias layer that tells the trader whether the market is developing a bullish regime, a bearish regime, or a maturing directional environment worth respecting.

The problem this script solves is context instability. Many traders can spot a moving-average crossover or a burst in ATR, but that alone does not answer whether the regime is actually mature, whether momentum has real separation, or whether recent retests are behaving consistently with the dominant trend. Covenant Regime Atlas addresses this by blending multiple regime components into one overlay and dashboard.

The script uses a dual-mid framework derived from EMA and HMA references, ATR-scaled cloud and envelope bands, persistence measurement, heat normalization, slope impulse, and retest memory. This lets it move beyond a simple bullish-versus-bearish cross and instead describe whether the regime is developing, mature, expanding efficiently, or internally cooling.

The result is an indicator for traders who want a cleaner read of bias before interpreting any trigger tool. It is especially useful as a regime filter for execution indicators and strategies that should behave differently in mature directional flow versus unstable transition periods.

[image]https://www.tradingview.com/x/bsi7Zo1H/[/image]

[b]Core Concepts[/b]

[b]1. Directional Mid Versus Structural Mid[/b]

The script creates a fast directional midpoint and a slower structural midpoint using blended EMA and HMA references. The spread between those two curves forms the backbone of regime direction.

[pine]
float directionalMid = math.avg(emaFast, hmaFast)
float structuralMid = math.avg(emaSlow, hmaSlow)
bool trendBull = directionalMid > structuralMid
[/pine]

This gives the regime engine more shape than a single moving average crossover. The directional mid measures active flow. The structural mid measures slower context.

[b]2. Regime Strength Through Separation And Heat[/b]

Regime strength is calculated from ATR-normalized spread plus the distance of normalized heat from its midpoint. In other words, the regime is strongest when the fast and slow structures are well separated and price is also positioned decisively within its recent range.

This helps avoid overvaluing tiny directional crosses that occur with little actual separation or energy.

[b]3. Persistence And Maturity[/b]

Every regime needs time to prove itself. The script counts how long the current directional condition has been intact and compares that against a user-defined persistence floor. Once the threshold is met, the regime is treated as mature rather than merely developing.

This matters because a fresh directional flip is different from a directional condition that has held for many bars and survived multiple retest opportunities.

[b]4. Retest Memory[/b]

After a mature regime forms, the indicator watches for controlled retests of the directional midpoint. Bull retests occur when price revisits the midline from above and closes back above it. Bear retests use the opposite condition. The last retest is stored as a dotted line and extended forward until it becomes irrelevant.

This gives the trader a simple memory of where the market most recently confirmed trend participation.

[b]5. Pulse, Expansion, And Efficiency[/b]

The script also measures volatility expansion, slope impulse, heat drift, trend separation percentage, and directional travel efficiency. These metrics allow the dashboard to distinguish between a mature regime that is expanding forcefully and one that is mature but internally cooling or grinding.

[image]https://www.tradingview.com/x/A6Cb3GYs/[/image]

[b]Features[/b]

[list]
[*][b]Bull and bear regime classification:[/b] Uses fast-versus-slow blended midpoints to define directional control
[*][b]Maturity logic:[/b] Distinguishes developing regimes from mature ones using persistence counting
[*][b]ATR-scaled cloud and envelope:[/b] Frames the current directional corridor directly on the chart
[*][b]Retest memory engine:[/b] Stores the latest mature-regime retest level for forward reference
[*][b]Initiation band:[/b] Preserves the regime start envelope so traders can judge distance from the original launch zone
[*][b]Pulse ribbon:[/b] Adds a compact visual band around price to reflect internal heat conditions
[*][b]Regime backdrop shading:[/b] Tints the chart according to the active directional state
[*][b]Detailed dashboard:[/b] Displays strength, heat, persistence, expansion, slope pulse, retest distance, maturity, efficiency, and more
[*][b]Confirmed-bar alerts:[/b] Includes mature bias, retest, expansion, continuation, efficient trend, and heat-reset conditions
[*][b]Data-window outputs:[/b] Exposes regime internals for systematic reading or comparison
[/list]

[b]Visual Elements[/b]

[list]
[*][b]Directional cloud:[/b] The gap between the fast and slow regime mids shows whether the market is operating with clean separation
[*][b]Envelope bands:[/b] ATR-based boundaries help frame the active directional corridor around price
[*][b]Initiation band:[/b] The regime launch area stays visible so users can measure how far the trend has traveled from origin
[*][b]Retest line memory:[/b] The latest confirmed retest is preserved as a direct chart reference
[*][b]Backdrop and pulse ribbon:[/b] Context shading and the pulse band make regime character readable without overloading the chart
[/list]

[b]Best Practices[/b]

[list]
[*]Treat mature regimes differently from developing ones because the same trigger can behave very differently in each state
[*]Watch heat drift when a regime remains mature but starts losing internal energy
[*]Use retest memory to frame participation zones rather than chasing every extension away from the midline
[*]Give more weight to regimes that show both persistence and expansion instead of one without the other
[*]Use the atlas as a context engine first and an alert source second
[/list]

[b]Input Parameters[/b]

[b]Trend Engine:[/b]
[list]
[*]Fast Length: Sets the faster directional reference
[*]Slow Length: Sets the slower structural reference
[*]Heat Window: Defines the range-normalization window for heat calculations
[*]ATR Length: Controls volatility normalization
[*]Cloud Width Factor: Sets the width of the directional cloud and envelope
[/list]

[b]Retest Engine:[/b]
[list]
[*]Show Retest Memory: Toggles retest storage and line rendering
[*]Retest Cooldown Bars: Prevents retests from firing too frequently
[*]Persistence Floor: Sets how many bars are required before a regime is considered mature
[*]Show Initiation Band: Displays the preserved start range of the current regime
[*]Maturity Window: Controls maturity scaling and travel-efficiency measurements
[/list]

[b]Display:[/b]
[list]
[*]Show Dashboard toggle
[*]Show Regime Backdrop toggle
[*]Show Pulse Ribbon toggle
[*]Independent bull, bear, neutral, and panel colors
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read Regime Tag And Strength[/b]
Begin with the dashboard’s regime tag. It tells you whether the market is bullish or bearish and whether that state is still developing or already mature. Pair that with the strength reading to avoid confusing a weak directional bias with a strong one.

[b]Step 2: Check Persistence And Expansion[/b]
Persistence tells you how long the regime has survived. Expansion tells you whether volatility is supporting the move. A mature regime with positive expansion usually deserves more respect than a new regime with weak expansion.

[b]Step 3: Use Retest Memory As A Structural Anchor[/b]
When the retest line is present, it marks the last meaningful participation check inside the trend. That line can help frame whether the current move is still building from a healthy base or drifting too far away from supportive structure.

[b]Step 4: Watch Heat Drift And Efficiency[/b]
Heat drift helps show whether the regime is internally warming or cooling. Efficiency tells you whether directional travel has been orderly. These readings are helpful when deciding whether the trend still looks clean or is becoming unstable.

[b]Step 5: Use It As The Bias Layer For Other Tools[/b]
Covenant Regime Atlas is best used as a bias filter. It helps define whether you should be thinking continuation, pullback participation, or caution. Pair it with your own trigger logic rather than using the regime alone as a full trading plan.

[b]Indicator Limitations[/b]

[list]
[*]A developing regime can fail before reaching maturity, especially in choppy markets
[*]Retest memory is useful for context, but the stored retest level is not guaranteed to hold on future tests
[*]Efficiency and heat drift are descriptive metrics, not predictive guarantees of continuation
[*]The indicator can still classify a directional state during periods where execution conditions are poor for actual trading
[/list]

[b]Originality Statement[/b]

Covenant Regime Atlas is original in the way it blends trend separation, maturity, retest memory, expansion, and efficiency into a unified regime overlay. It is not just a moving-average cloud with added cosmetics:

[list]
[*]It separates directional identity from maturity, allowing the user to distinguish developing and established regimes
[*]It stores retest memory as a living structural feature instead of relying only on static crossover logic
[*]It combines heat, slope, expansion, and efficiency into one dashboard so regime quality can be judged from multiple dimensions
[*]It preserves the initiation band of the current regime, which gives context that typical trend overlays do not maintain
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice or a recommendation to buy or sell any financial instrument. Regime readings describe current market structure and internal state based on historical prices. They do not guarantee future movement or profitable trading decisions. Always use independent judgment and proper risk management.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Covenant Regime Atlas [JOAT]", shorttitle = "ARC [JOAT]", overlay = true, max_lines_count = 500, max_labels_count = 200, max_boxes_count = 200)

//--------------------------------------------------------------------------------------------------
// JOAT Covenant Regime Atlas
//--------------------------------------------------------------------------------------------------
// Purpose:
// - Classify market regime through direction, expansion, persistence, and retest quality.
// - Fuse trend-cloud logic, envelope logic, and normalized heat state into one institutional overlay.
// - Provide a stable bias layer for discretionary use and strategy integration.
//--------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------
// Inputs
//--------------------------------------------------------------------------------------------------
string groupTrend = "Trend Engine"
int fastLength = input.int(34, "Fast Length", minval = 10, maxval = 120, group = groupTrend)
int slowLength = input.int(89, "Slow Length", minval = 20, maxval = 250, group = groupTrend)
int heatLength = input.int(70, "Heat Window", minval = 20, maxval = 200, group = groupTrend)
int atrLength = input.int(100, "ATR Length", minval = 20, maxval = 250, group = groupTrend)
float cloudWidth = input.float(0.75, "Cloud Width Factor", minval = 0.20, maxval = 2.00, step = 0.05, group = groupTrend)

string groupRetest = "Retest Engine"
bool showRetests = input.bool(true, "Show Retest Memory", group = groupRetest)
int retestCooldown = input.int(8, "Retest Cooldown Bars", minval = 3, maxval = 30, group = groupRetest)
int persistenceFloor = input.int(14, "Persistence Floor", minval = 5, maxval = 50, group = groupRetest)
bool showInitiationBand = input.bool(true, "Show Initiation Band", group = groupRetest)
int maturityWindow = input.int(34, "Maturity Window", minval = 10, maxval = 120, group = groupRetest)

string groupStyle = "Visual Language"
color upCore = input.color(color.rgb(25, 206, 156), "Bull Core", group = groupStyle, inline = "a")
color downCore = input.color(color.rgb(209, 72, 178), "Bear Core", group = groupStyle, inline = "a")
color upAccent = input.color(color.rgb(33, 124, 198), "Bull Accent", group = groupStyle, inline = "b")
color downAccent = input.color(color.rgb(255, 131, 72), "Bear Accent", group = groupStyle, inline = "b")
color neutralCore = input.color(color.rgb(137, 146, 160), "Neutral", group = groupStyle)
color panelBg = input.color(color.rgb(14, 20, 30), "Panel Background", group = groupStyle)
bool showDashboard = input.bool(true, "Show Dashboard", group = groupStyle)
bool showBackdrop = input.bool(true, "Show Regime Backdrop", group = groupStyle)
bool showPulseRibbon = input.bool(true, "Show Pulse Ribbon", group = groupStyle)

//--------------------------------------------------------------------------------------------------
// Persistent state
//--------------------------------------------------------------------------------------------------
var int lastRetestBar = na
var float regimeStart = na
var float regimeUpper = na
var float regimeLower = na
var bool bullRegime = false
var line retestLine = na
var table dashboard = table.new(position.top_right, 2, 17, frame_color = color.new(color.white, 85), frame_width = 1)

//--------------------------------------------------------------------------------------------------
// Helpers
//--------------------------------------------------------------------------------------------------
safeDiv(float numerator, float denominator) =>
    denominator == 0.0 ? 0.0 : numerator / denominator

clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

formatPct(float value) =>
    str.tostring(value, "#.0") + "%"

stateColor(bool bull, float intensity) =>
    color primary = bull ? upCore : downCore
    color secondary = bull ? upAccent : downAccent
    color.from_gradient(intensity, 0, 100, color.new(secondary, 75), color.new(primary, 0))

fillColor(bool bull, float intensity) =>
    color primary = bull ? upCore : downCore
    color secondary = bull ? upAccent : downAccent
    color.from_gradient(intensity, 0, 100, color.new(secondary, 94), color.new(primary, 84))

dashboardCell(int column, int row, string cellText, color bg, color fg) =>
    table.cell(dashboard, column, row, cellText, bgcolor = bg, text_color = fg, text_size = size.small)

//--------------------------------------------------------------------------------------------------
// Core regime metrics
//--------------------------------------------------------------------------------------------------
float atrValue = ta.atr(atrLength)
float emaFast = ta.ema(close, fastLength)
float emaSlow = ta.ema(close, slowLength)
float hmaFast = ta.hma(close, math.max(10, fastLength - 8))
float hmaSlow = ta.hma(close, math.max(20, slowLength - 13))

float directionalMid = math.avg(emaFast, hmaFast)
float structuralMid = math.avg(emaSlow, hmaSlow)
float spread = directionalMid - structuralMid
float spreadAbs = math.abs(spread)
float spreadNorm = safeDiv(spreadAbs, atrValue) * 100.0

float rangeHigh = ta.highest(high, heatLength)
float rangeLow = ta.lowest(low, heatLength)
float heatNorm = safeDiv(close - rangeLow, math.max(rangeHigh - rangeLow, syminfo.mintick)) * 100.0

bool trendBull = directionalMid > structuralMid
bool trendFlip = trendBull != trendBull[1]

float cloudTop = trendBull ? directionalMid : directionalMid + atrValue * cloudWidth
float cloudBottom = trendBull ? directionalMid - atrValue * cloudWidth : directionalMid
float envelopeTop = math.avg(emaFast + atrValue * cloudWidth, hmaFast + atrValue * cloudWidth)
float envelopeBottom = math.avg(emaFast - atrValue * cloudWidth, hmaFast - atrValue * cloudWidth)

float regimeStrength = clamp(spreadNorm * 0.60 + math.abs(heatNorm - 50.0) * 0.80, 0, 100)
float volatilityExpansion = safeDiv(ta.atr(20), ta.atr(100)) * 100.0
float directionalSlope = ta.linreg(directionalMid, 12, 0) - ta.linreg(directionalMid, 12, 1)
float structuralSlope = ta.linreg(structuralMid, 12, 0) - ta.linreg(structuralMid, 12, 1)
float slopeImpulse = clamp(safeDiv(directionalSlope - structuralSlope, syminfo.mintick * 50) * 100.0, -100, 100)
float retestDistanceAtr = not na(retestLine) ? safeDiv(close - retestLine.get_y1(), atrValue) : na
float trendSeparationPct = safeDiv(spreadAbs, math.max(close, syminfo.mintick)) * 100.0
float heatDrift = ta.sma(heatNorm, 5) - ta.sma(heatNorm, 13)
int effectiveMaturityWindow = math.min(maturityWindow, bar_index)
float directionalTravel = effectiveMaturityWindow > 0 ? math.sum(math.abs(ta.change(directionalMid)), effectiveMaturityWindow) : 0.0
float regimeEfficiency = effectiveMaturityWindow > 0 ? safeDiv(math.abs(directionalMid - directionalMid[effectiveMaturityWindow]), math.max(directionalTravel, syminfo.mintick)) * 100.0 : 0.0

var int persistence = 0
persistence := trendBull == trendBull[1] ? nz(persistence[1]) + 1 : 0
bool matureRegime = persistence >= persistenceFloor
float maturityScore = clamp(safeDiv(persistence, maturityWindow) * 100.0, 0, 100)
int memoryAge = not na(regimeStart) ? persistence : 0

//--------------------------------------------------------------------------------------------------
// Regime initiation memory
//--------------------------------------------------------------------------------------------------
if barstate.isconfirmed and trendFlip
    bullRegime := trendBull
    regimeStart := trendBull ? low : high
    regimeUpper := high
    regimeLower := low
    line.delete(retestLine)
    retestLine := na

if not na(regimeUpper)
    regimeUpper := trendFlip ? high : math.max(regimeUpper, high)
    regimeLower := trendFlip ? low : math.min(regimeLower, low)

//--------------------------------------------------------------------------------------------------
// Retest engine
//--------------------------------------------------------------------------------------------------
bool cooldownReady = na(lastRetestBar) or bar_index - lastRetestBar > retestCooldown
bool bullRetest = barstate.isconfirmed and showRetests and matureRegime and trendBull and cooldownReady and low <= directionalMid and close >= directionalMid
bool bearRetest = barstate.isconfirmed and showRetests and matureRegime and not trendBull and cooldownReady and high >= directionalMid and close <= directionalMid

if bullRetest or bearRetest
    lastRetestBar := bar_index
    line.delete(retestLine)
    float retestPrice = bullRetest ? low : high
    color retestColor = bullRetest ? stateColor(true, regimeStrength) : stateColor(false, regimeStrength)
    retestLine := line.new(bar_index - 1, retestPrice, bar_index + 10, retestPrice, color = retestColor, style = line.style_dotted, width = 2)

if not na(retestLine)
    retestLine.set_x2(bar_index + 10)
    if high > retestLine.get_y1() and low < retestLine.get_y1() and bar_index - retestLine.get_x1() > 2
        line.delete(retestLine)
        retestLine := na

//--------------------------------------------------------------------------------------------------
// Visual framework
//--------------------------------------------------------------------------------------------------
color trendEdge = trendBull ? stateColor(true, regimeStrength) : stateColor(false, regimeStrength)
color trendFill = trendBull ? fillColor(true, regimeStrength) : fillColor(false, regimeStrength)
color heatColor =
     heatNorm >= 50
     ? color.from_gradient(heatNorm, 50, 100, color.new(upAccent, 75), color.new(upCore, 0))
     : color.from_gradient(heatNorm, 0, 50, color.new(downCore, 0), color.new(downAccent, 75))

plotDirectional = plot(trendFlip ? na : directionalMid, "Directional Mid", color = trendEdge, linewidth = 2)
plotStructural = plot(trendFlip ? na : structuralMid, "Structural Mid", color = color.new(neutralCore, 20), linewidth = 1)
fill(plotDirectional, plotStructural, color = trendFill)

topPlot = plot(envelopeTop, "Envelope Top", color = color.new(trendEdge, 55), linewidth = 1)
botPlot = plot(envelopeBottom, "Envelope Bottom", color = color.new(trendEdge, 55), linewidth = 1)
fill(topPlot, botPlot, color = color.new(trendEdge, 92))

float initiationMid = not na(regimeUpper) and not na(regimeLower) ? math.avg(regimeUpper, regimeLower) : na
upperBand = plot(showInitiationBand and not trendFlip ? regimeUpper : na, "Initiation Upper", color = color.new(trendEdge, 75), style = plot.style_linebr)
lowerBand = plot(showInitiationBand and not trendFlip ? regimeLower : na, "Initiation Lower", color = color.new(trendEdge, 75), style = plot.style_linebr)
fill(upperBand, lowerBand, color = color.new(trendEdge, 94))
plot(showInitiationBand and not trendFlip ? initiationMid : na, "Initiation Mid", color = color.new(neutralCore, 25), style = plot.style_linebr)

float pulseRibbonUpper = directionalMid + atrValue * 0.18
float pulseRibbonLower = directionalMid - atrValue * 0.18
pulseTop = plot(showPulseRibbon ? pulseRibbonUpper : na, "Pulse Ribbon Upper", color = color.new(heatColor, 75))
pulseBot = plot(showPulseRibbon ? pulseRibbonLower : na, "Pulse Ribbon Lower", color = color.new(heatColor, 75))
fill(pulseTop, pulseBot, color = color.new(heatColor, 92))

color regimeCandle =
     trendBull
     ? color.from_gradient(regimeStrength, 0, 100, color.new(upCore, 65), color.new(upCore, 0))
     : color.from_gradient(regimeStrength, 0, 100, color.new(downCore, 65), color.new(downCore, 0))

color blendedCandle = color.from_gradient(math.abs(heatNorm - 50), 0, 50, regimeCandle, heatColor)
bgcolor(showBackdrop ? color.new(trendEdge, matureRegime ? 95 : 97) : na)
barcolor(blendedCandle)
plotcandle(open, high, low, close, color = blendedCandle, wickcolor = blendedCandle, bordercolor = blendedCandle, force_overlay = true, title = "Regime Candles")

//--------------------------------------------------------------------------------------------------
// Dashboard
//--------------------------------------------------------------------------------------------------
if showDashboard and barstate.islast
    color panelTop = color.new(trendEdge, 84)
    float envelopeWidthAtr = safeDiv(envelopeTop - envelopeBottom, atrValue)
    float initiationDistanceAtr = not na(initiationMid) ? safeDiv(close - initiationMid, atrValue) : na
    string regimeTag =
         trendBull and matureRegime ? "Bull Mature" :
         trendBull and not matureRegime ? "Bull Developing" :
         not trendBull and matureRegime ? "Bear Mature" :
         "Bear Developing"

    dashboardCell(0, 0, "Covenant Atlas", panelTop, color.white)
    dashboardCell(1, 0, regimeTag, panelTop, color.white)

    dashboardCell(0, 1, "Strength", panelBg, color.new(color.white, 10))
    dashboardCell(1, 1, formatPct(regimeStrength), panelBg, trendEdge)

    dashboardCell(0, 2, "Heat", panelBg, color.new(color.white, 10))
    dashboardCell(1, 2, formatPct(heatNorm), panelBg, heatColor)

    dashboardCell(0, 3, "Persistence", panelBg, color.new(color.white, 10))
    dashboardCell(1, 3, str.tostring(persistence), panelBg, color.white)

    dashboardCell(0, 4, "Spread ATR", panelBg, color.new(color.white, 10))
    dashboardCell(1, 4, str.tostring(safeDiv(spreadAbs, atrValue), "#.00"), panelBg, trendEdge)

    dashboardCell(0, 5, "Expansion", panelBg, color.new(color.white, 10))
    dashboardCell(1, 5, formatPct(volatilityExpansion), panelBg, trendEdge)

    dashboardCell(0, 6, "Start", panelBg, color.new(color.white, 10))
    dashboardCell(1, 6, not na(regimeStart) ? str.tostring(regimeStart, format.mintick) : "na", panelBg, color.white)

    dashboardCell(0, 7, "Retest", panelBg, color.new(color.white, 10))
    dashboardCell(1, 7, bullRetest ? "Bull" : bearRetest ? "Bear" : "Idle", panelBg, trendEdge)

    dashboardCell(0, 8, "Env Width ATR", panelBg, color.new(color.white, 10))
    dashboardCell(1, 8, str.tostring(envelopeWidthAtr, "#.00"), panelBg, trendEdge)

    dashboardCell(0, 9, "Init Dist ATR", panelBg, color.new(color.white, 10))
    dashboardCell(1, 9, na(initiationDistanceAtr) ? "na" : str.tostring(initiationDistanceAtr, "#.00"), panelBg, trendEdge)

    dashboardCell(0, 10, "Slope Pulse", panelBg, color.new(color.white, 10))
    dashboardCell(1, 10, str.tostring(slopeImpulse, "#.0"), panelBg, slopeImpulse >= 0 ? upCore : downCore)

    dashboardCell(0, 11, "Retest Dist", panelBg, color.new(color.white, 10))
    dashboardCell(1, 11, na(retestDistanceAtr) ? "na" : str.tostring(retestDistanceAtr, "#.00"), panelBg, na(retestDistanceAtr) ? color.white : retestDistanceAtr >= 0 ? upCore : downCore)

    dashboardCell(0, 12, "Trend State", panelBg, color.new(color.white, 10))
    dashboardCell(1, 12, bullRegime ? "Bull Memory" : "Bear Memory", panelBg, bullRegime ? upCore : downCore)

    dashboardCell(0, 13, "Maturity", panelBg, color.new(color.white, 10))
    dashboardCell(1, 13, str.tostring(maturityScore, "#.0") + "%", panelBg, maturityScore >= 50 ? trendEdge : neutralCore)

    dashboardCell(0, 14, "Heat Drift", panelBg, color.new(color.white, 10))
    dashboardCell(1, 14, str.tostring(heatDrift, "#.0"), panelBg, heatDrift >= 0 ? upCore : downCore)

    dashboardCell(0, 15, "Sep %", panelBg, color.new(color.white, 10))
    dashboardCell(1, 15, str.tostring(trendSeparationPct, "#.00"), panelBg, trendEdge)

    dashboardCell(0, 16, "Efficiency", panelBg, color.new(color.white, 10))
    dashboardCell(1, 16, str.tostring(regimeEfficiency, "#.0") + "%", panelBg, regimeEfficiency >= 50 ? trendEdge : neutralCore)

//--------------------------------------------------------------------------------------------------
// Alerts
//--------------------------------------------------------------------------------------------------
bool confirmedBullBias = barstate.isconfirmed and trendBull and matureRegime and regimeStrength >= 45
bool confirmedBearBias = barstate.isconfirmed and not trendBull and matureRegime and regimeStrength >= 45
bool confirmedBullRetest = bullRetest
bool confirmedBearRetest = bearRetest
bool confirmedBullExpansion = barstate.isconfirmed and trendBull and volatilityExpansion >= 100 and slopeImpulse > 0
bool confirmedBearExpansion = barstate.isconfirmed and not trendBull and volatilityExpansion >= 100 and slopeImpulse < 0
bool confirmedBullContinuation = barstate.isconfirmed and trendBull and matureRegime and heatDrift > 0 and maturityScore >= 50
bool confirmedBearContinuation = barstate.isconfirmed and not trendBull and matureRegime and heatDrift < 0 and maturityScore >= 50
bool confirmedEfficientTrend = barstate.isconfirmed and matureRegime and regimeEfficiency >= 50 and math.abs(slopeImpulse) >= 5
bool confirmedHeatReset = barstate.isconfirmed and matureRegime and math.abs(heatNorm - 50.0) <= 8 and math.abs(heatDrift) < 4

alertcondition(confirmedBullBias, "JOAT Covenant Bull Bias", "Covenant Regime Atlas confirms a mature bullish regime.")
alertcondition(confirmedBearBias, "JOAT Covenant Bear Bias", "Covenant Regime Atlas confirms a mature bearish regime.")
alertcondition(confirmedBullRetest, "JOAT Covenant Bull Retest", "Covenant Regime Atlas confirms a bullish retest.")
alertcondition(confirmedBearRetest, "JOAT Covenant Bear Retest", "Covenant Regime Atlas confirms a bearish retest.")
alertcondition(confirmedBullExpansion, "JOAT Covenant Bull Expansion", "Covenant Regime Atlas confirms bullish expansion with positive slope impulse.")
alertcondition(confirmedBearExpansion, "JOAT Covenant Bear Expansion", "Covenant Regime Atlas confirms bearish expansion with negative slope impulse.")
alertcondition(confirmedBullContinuation, "JOAT Covenant Bull Continuation", "Covenant Regime Atlas confirms bullish continuation pressure.")
alertcondition(confirmedBearContinuation, "JOAT Covenant Bear Continuation", "Covenant Regime Atlas confirms bearish continuation pressure.")
alertcondition(confirmedEfficientTrend, "JOAT Covenant Efficient Trend", "Covenant Regime Atlas confirms an efficient mature regime.")
alertcondition(confirmedHeatReset, "JOAT Covenant Heat Reset", "Covenant Regime Atlas confirms a mature regime heat reset.")

plot(regimeStrength, "Regime Strength (Data Window)", color = trendEdge, display = display.data_window)
plot(heatNorm, "Heat Norm (Data Window)", color = heatColor, display = display.data_window)
plot(volatilityExpansion, "Expansion (Data Window)", color = trendEdge, display = display.data_window)
plot(retestDistanceAtr, "Retest Distance ATR (Data Window)", color = na(retestDistanceAtr) ? neutralCore : retestDistanceAtr >= 0 ? upCore : downCore, display = display.data_window)
plot(maturityScore, "Maturity Score (Data Window)", color = maturityScore >= 50 ? trendEdge : neutralCore, display = display.data_window)
plot(regimeEfficiency, "Regime Efficiency % (Data Window)", color = regimeEfficiency >= 50 ? trendEdge : neutralCore, display = display.data_window)
````
