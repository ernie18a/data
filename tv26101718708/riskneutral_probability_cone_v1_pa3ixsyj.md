# Risk-Neutral Probability Cone [v1]

- url: https://www.tradingview.com/script/PA3IxSYJ-Risk-Neutral-Probability-Cone-v1/
- type: indicator
- pine_id: PUB;3d71fa1d5e674cd8adf0eff5d9035a27
- version: 1.0

## Description

The Risk-Neutral Probability Cone is a forward-looking volatility projection tool designed to help traders estimate probable future price ranges over a selected number of bars.

The indicator projects a probability cone from the current anchor price using a lognormal price-process framework. It plots expected path, ±1σ, ±2σ, and ±3σ forward price bands based on the selected volatility model, drift model, and projection horizon.

This is not a buy or sell signal indicator.

It is a scenario-planning, risk-management, and probability-mapping tool.

The goal is to help traders answer:

“How far could price reasonably move over my selected horizon?”

and

“Is my price target inside or outside the expected probability range?”

The indicator can be used across FX, crypto, equities, indices, commodities, futures, and other liquid markets.

WHAT THE INDICATOR DOES
━━━━━━━━━━━━━━━━━━━━━━

The indicator starts from an anchor price and projects a forward probability cone.

The cone is based on:

• Anchor price
• Selected volatility model
• Selected drift model
• Projection horizon
• Bars per year
• Lognormal price dynamics
• Standard deviation bands

The main output is a forward cone showing possible future price ranges.

The cone expands over time because uncertainty increases as the projection horizon becomes longer.

A short projection horizon will produce a narrower cone.

A long projection horizon will produce a wider cone.

CORE IDEA
━━━━━━━━━━━━━━━━━━━━━━

The indicator assumes that future price movement can be approximated using a lognormal distribution.

This is similar to the framework used in many derivatives and option-pricing models.

The projected price level is calculated using:

Expected price movement over time

plus

Volatility-adjusted standard deviation bands

The indicator then plots the following paths:

• Expected path
• +1σ and -1σ bands
• +2σ and -2σ bands
• +3σ and -3σ bands

These bands help traders visualize a probability-based forward range.

WHAT THE CONE LEVELS MEAN
━━━━━━━━━━━━━━━━━━━━━━

Expected Path

The expected path is the central projection line.

It reflects the selected drift model and the volatility adjustment used in the lognormal framework.

It should not be treated as a forecast.

It is a model-based expected reference path.

1σ Cone

The ±1σ cone shows the normal expected range around the projected path.

This is the most practical zone for ordinary price movement.

If price remains inside the 1σ cone, it is generally moving within a normal volatility-adjusted range.

2σ Cone

The ±2σ cone shows a more extended move.

Price moving toward or beyond the 2σ cone suggests a larger-than-normal move relative to the selected volatility model.

This may indicate:

• Momentum expansion
• Event-driven repricing
• Trend acceleration
• Liquidity shock
• Mispriced volatility assumption

3σ Cone

The ±3σ cone shows an extreme move zone.

This is useful for stress testing, event-risk planning, and identifying unusually large price moves.

A move toward the 3σ cone should not automatically be treated as a reversal signal.

Strong markets can remain outside expected ranges when volatility expands or when the original volatility input becomes stale.

MAIN COMPONENTS
━━━━━━━━━━━━━━━━━━━━━━

1. Anchor Price

The anchor price is the starting point of the probability cone.

The script supports four anchor modes:

• Close
• Manual
• EMA
• VWAP

Close uses the latest closing price.

Manual allows the trader to enter a specific price level.

EMA uses a moving average as the anchor.

VWAP uses volume-weighted average price as the anchor.

For live projection, Close is usually the easiest setting.

For scenario planning, Manual is useful because it allows the trader to anchor the cone from a specific entry price, event level, or key market level.

2. Projection Horizon

The projection horizon determines how far into the future the cone extends.

It is measured in bars.

For example:

• On a 1-hour chart, 24 bars means approximately 24 trading hours
• On a daily chart, 20 bars means approximately 20 trading days
• On a 5-minute chart, 48 bars means approximately 4 trading hours

The longer the horizon, the wider the cone becomes.

3. Cone Drawing Step

Cone Drawing Step controls how frequently the cone lines are drawn.

A smaller step makes the cone smoother.

A larger step makes the cone lighter and less visually crowded.

For shorter horizons, a smaller step can be used.

For longer horizons, a larger step can help keep the chart clean.

4. Volatility Model

The indicator includes three volatility model options:

• Realized Volatility
• ATR Proxy
• Composite

Realized Volatility uses log returns and rolling standard deviation.

ATR Proxy uses average true range as a percentage of price.

Composite blends realized volatility and ATR volatility.

Realized Volatility is more statistically direct.

ATR Proxy is more sensitive to intrabar range.

Composite is often the most practical default because it captures both close-to-close movement and range-based movement.

5. Drift Model

The indicator includes three drift models:

• Risk-Neutral
• Zero Drift
• Historical Drift

Risk-Neutral uses risk-free rate minus carry or dividend yield.

Zero Drift assumes no directional drift.

Historical Drift estimates drift from past log returns.

For short-term trading, Zero Drift or Risk-Neutral usually provides cleaner projections.

Historical Drift can be unstable and may overfit recent trends.

6. Risk-Free Rate and Carry / Dividend Yield

These inputs are used when the Drift Model is set to Risk-Neutral.

For equities, carry or dividend yield can represent dividend assumptions.

For FX, the difference between domestic and foreign rates may be relevant.

For crypto, users may prefer Zero Drift unless they have a clear carry assumption.

7. Probability to Target

The script includes an optional probability-to-target feature.

When enabled, the user can enter a target price.

The indicator estimates the model-based probability that price will finish above that target by the end of the projection horizon.

This is useful for scenario planning and target evaluation.

It should not be treated as a guaranteed forecast.

HOW TO READ THE INDICATOR
━━━━━━━━━━━━━━━━━━━━━━

The indicator plots a forward cone on the price chart.

General visual guide:

• White path = expected path
• Green cone = ±1σ range
• Orange cone = ±2σ range
• Red cone = ±3σ range

The dashboard shows:

• Anchor price
• Volatility model
• Annualized volatility
• Drift model
• Annual drift
• Horizon bars
• Expected terminal price
• +1σ and -1σ terminal levels
• +2σ and -2σ terminal levels
• +3σ and -3σ terminal levels
• Probability above target if enabled

The cone should be read as a forward probability range, not as support and resistance.

HOW TO USE THE INDICATOR
━━━━━━━━━━━━━━━━━━━━━━

Use the Risk-Neutral Probability Cone as a forward scenario tool.

The main workflow is:

1. Choose the market and timeframe.

The indicator can be used on intraday or daily charts.

The timeframe should match the trader’s holding period.

2. Choose the anchor mode.

Use Close for live projection.

Use Manual for trade planning.

Use EMA for smoother trend-based projections.

Use VWAP for intraday execution context.

3. Select the projection horizon.

Match the horizon to the trade idea.

A scalp should use fewer bars.

A swing trade should use more bars.

4. Select the volatility model.

Use Realized Volatility for a cleaner statistical model.

Use ATR Proxy for a more range-sensitive model.

Use Composite for a balanced approach.

5. Select the drift model.

Use Risk-Neutral for derivatives-style scenario mapping.

Use Zero Drift for clean short-term projections.

Use Historical Drift only when you intentionally want recent trend behaviour included.

6. Read the cone.

If price is inside the 1σ cone, the move is relatively normal.

If price approaches the 2σ cone, the move is becoming extended.

If price approaches the 3σ cone, the move is extreme relative to the selected assumptions.

7. Compare price targets to the cone.

Targets inside the 1σ cone are more conservative.

Targets near the 2σ cone are more aggressive.

Targets near or beyond the 3σ cone require a much stronger volatility or trend justification.

PRACTICAL TRADING USE CASES
━━━━━━━━━━━━━━━━━━━━━━

1. Trade Target Planning

The cone helps traders assess whether a target is realistic for the selected holding period.

If a target is far beyond the 2σ or 3σ cone, the trader should question whether the target is realistic without a major catalyst.

2. Stop-Loss Planning

The cone can help traders understand normal adverse movement.

A stop placed too close inside the normal 1σ range may be vulnerable to ordinary volatility.

A stop placed outside the expected range may require smaller position size.

3. Event-Risk Planning

The cone can be used before major events such as:

• CPI
• NFP
• FOMC
• ECB decisions
• Earnings
• Crypto unlocks
• Geopolitical events
• Major macro data

The trader can compare expected event movement against the cone.

If price moves outside the 2σ or 3σ cone after the event, it may indicate that the market is repricing beyond normal volatility assumptions.

4. Breakout Assessment

If price breaks above the 1σ cone and volatility is also expanding, the breakout may have more momentum support.

If price breaks the 1σ cone but immediately returns inside the cone, the breakout may be weaker.

5. Mean-Reversion Monitoring

Price near the 2σ or 3σ cone may be extended.

However, the cone should not be used to fade price blindly.

A better mean-reversion setup requires confirmation such as:

• Failed continuation
• Re-entry inside the cone
• Break of short-term structure
• Volatility cooling
• Reclaim of a key moving average
• Liquidity sweep and rejection

6. Scenario Analysis

The cone can be used to frame bull, base, and bear scenarios.

The upper cone levels represent upside scenarios.

The lower cone levels represent downside scenarios.

The expected path represents the model’s central scenario.

SUGGESTED SETTINGS
━━━━━━━━━━━━━━━━━━━━━━

FX 1-Hour

• Anchor Mode: Close or Manual
• Volatility Model: Realized Volatility or Composite
• Realized Volatility Lookback: 30 to 50
• ATR Lookback: 14
• Horizon Bars: 24 to 72
• Cone Drawing Step: 4 to 8
• Bars Per Year: 6240
• Drift Model: Risk-Neutral or Zero Drift

Crypto 1-Hour

• Anchor Mode: Close or Manual
• Volatility Model: Composite
• Realized Volatility Lookback: 50
• ATR Lookback: 14 to 21
• Horizon Bars: 24 to 168
• Cone Drawing Step: 6 to 12
• Bars Per Year: 8760
• Drift Model: Zero Drift or Risk-Neutral

Daily Equities / Indices

• Anchor Mode: Close or EMA
• Volatility Model: Composite
• Realized Volatility Lookback: 20 to 30
• ATR Lookback: 14
• Horizon Bars: 10 to 30
• Cone Drawing Step: 2 to 5
• Bars Per Year: 252
• Drift Model: Risk-Neutral

Intraday Indices

• Anchor Mode: Close, Manual, or VWAP
• Volatility Model: Composite
• Realized Volatility Lookback: 30 to 50
• ATR Lookback: 14
• Horizon Bars: 24 to 96
• Cone Drawing Step: 4 to 8
• Bars Per Year: adjust to the timeframe
• Drift Model: Zero Drift or Risk-Neutral

DRIFT MODEL GUIDE
━━━━━━━━━━━━━━━━━━━━━━

Risk-Neutral Drift

Risk-Neutral drift uses:

Risk-Free Rate minus Carry / Dividend Yield

This is useful for a derivatives-style probability framework.

For FX, this may approximate the interest rate differential.

For equities, the carry input may represent dividend yield.

For crypto, this is often less relevant unless there is a specific funding or carry assumption.

Zero Drift

Zero Drift assumes no expected directional drift.

This is often useful for short-term trading because drift is usually small relative to volatility over short horizons.

Zero Drift is a clean default for intraday analysis.

Historical Drift

Historical Drift estimates drift from recent average log returns.

This can make the cone follow recent trend behaviour, but it is also more prone to overfitting.

Historical Drift should be used carefully.

VOLATILITY MODEL GUIDE
━━━━━━━━━━━━━━━━━━━━━━

Realized Volatility

Realized Volatility uses close-to-close log returns.

This is statistically clean and works well for probability-based modelling.

ATR Proxy

ATR Proxy uses range-based volatility.

It is more sensitive to intrabar movement and can be useful for instruments with large wicks or wide trading ranges.

Composite

Composite blends realized volatility and ATR volatility.

This is often the best practical default because it captures both return-based and range-based volatility.

PROBABILITY TO TARGET
━━━━━━━━━━━━━━━━━━━━━━

The probability-to-target feature estimates the probability that price will finish above the selected target price by the end of the projection horizon.

This can be useful for:

• Checking whether a target is realistic
• Comparing upside and downside scenarios
• Evaluating trade targets before entry
• Stress testing expectations
• Avoiding overly ambitious targets

Important note:

The probability is model-based.

It depends heavily on the selected volatility, drift, anchor, and horizon inputs.

It should not be treated as a guaranteed probability.

HOW TO COMBINE WITH OTHER INDICATORS
━━━━━━━━━━━━━━━━━━━━━━

This indicator works best as part of a broader volatility and market-structure framework.

Useful combinations:

• Expected Move Bands
• Realized Volatility Regime Indicator
• Implied Volatility Proxy
• Delta-Hedging Pressure Proxy
• Dynamic Stop-Loss Using Expected Move
• VWAP
• Moving averages
• Support and resistance
• Liquidity zones
• Market structure breaks
• Macro and event calendars

Suggested framework:

Expected Move Bands show near-term projected levels.

Realized Volatility Regime shows whether volatility is low, normal, high, or extreme.

IV Proxy shows whether broader uncertainty is rising or cooling.

Delta-Hedging Pressure Proxy shows whether directional pressure is positive or negative.

Dynamic Stop-Loss Using Expected Move converts volatility into stop and target levels.

Risk-Neutral Probability Cone maps a full forward probability range.

Together, these tools help answer:

• How far can price move?
• What is the probable forward range?
• Is the target realistic?
• Is volatility expanding or cooling?
• Is directional pressure aligned?
• Where should stops and targets be placed?
• Should position size be reduced?

TRADING EXAMPLES
━━━━━━━━━━━━━━━━━━━━━━

Example 1: Target Planning

A trader is long EUR/USD on the 1-hour chart.

The trader sets the cone horizon to 24 bars.

The upside target is close to the +1σ terminal level.

This suggests the target is within a normal expected range.

If the target is above +2σ, the trader may need stronger confirmation from trend, momentum, or event risk.

Example 2: Breakout Confirmation

Price breaks above a key resistance level and moves outside the +1σ cone.

If volatility is expanding and the IV Proxy is rising, the breakout may have stronger continuation potential.

If price quickly returns inside the cone, the breakout may be weaker.

Example 3: Event Risk

Before a central bank decision, a trader anchors the cone from the pre-event price.

After the event, price moves beyond the 2σ cone.

This suggests the event caused a larger-than-normal repricing relative to the volatility assumptions used before the event.

Example 4: Mean-Reversion Watch

Price trades near the +3σ cone.

This is an extreme move relative to the model.

However, the trader should not automatically short.

A better setup would require failed continuation, volatility cooling, and price re-entry inside the cone.

Example 5: Stop Placement Context

A trader wants to place a stop inside the 1σ cone.

The cone suggests that ordinary volatility could reach that level.

The trader may choose to reduce size and place the stop beyond a more meaningful structure level, or avoid the trade if reward-to-risk is poor.

RISK MANAGEMENT NOTES
━━━━━━━━━━━━━━━━━━━━━━

The cone is most useful when combined with position sizing and trade invalidation logic.

Practical risk rules:

• Do not treat cone levels as guaranteed support or resistance
• Do not fade 2σ or 3σ moves without confirmation
• Reduce size when volatility is high and the cone is wide
• Avoid unrealistic targets far outside the cone without a catalyst
• Use the cone to judge whether stops and targets are reasonable
• Re-anchor the cone after major events or regime shifts
• Treat the cone as a scenario map, not a forecast

A wider cone means uncertainty is higher.

Higher uncertainty should generally mean smaller position size.

WHAT THIS INDICATOR IS BEST FOR
━━━━━━━━━━━━━━━━━━━━━━

This indicator is best used for:

• Forward probability mapping
• Scenario analysis
• Target evaluation
• Event-risk planning
• Stop and target context
• Volatility-adjusted range projection
• Identifying normal versus extreme price movement
• Trade planning
• Risk management

It is useful for traders who want to frame markets probabilistically instead of relying only on static support and resistance.

WHAT THIS INDICATOR IS NOT
━━━━━━━━━━━━━━━━━━━━━━

This indicator is not:

• A buy or sell signal generator
• A standalone trading strategy
• A guarantee that price will stay inside the cone
• A Monte Carlo simulation
• A true options-implied probability model
• A replacement for risk management
• A replacement for market structure
• A complete trading system

The cone describes a model-based forward distribution.

It does not predict the future with certainty.

IMPORTANT LIMITATIONS
━━━━━━━━━━━━━━━━━━━━━━

The indicator depends on model assumptions.

Key assumptions include:

• Volatility estimate is relevant for the future horizon
• Price movement can be approximated by a lognormal process
• Drift input is reasonable
• Market conditions remain broadly comparable
• No sudden structural break occurs

These assumptions can fail.

The cone may become inaccurate during:

• Economic data shocks
• Central bank decisions
• Earnings surprises
• Geopolitical events
• Liquidity gaps
• Crypto liquidation cascades
• Market opens and closes
• Sudden volatility regime shifts

The indicator does not include:

• Options implied volatility
• Options skew
• Volatility term structure
• Dealer positioning
• Order flow
• Market depth
• News sentiment
• Fundamental data
• Liquidity conditions

The cone should be used as a decision-support tool, not as a standalone trading system.

FINAL NOTES
━━━━━━━━━━━━━━━━━━━━━━

The Risk-Neutral Probability Cone helps traders convert volatility, drift, and time into a forward probability map.

Instead of asking only whether price is bullish or bearish, this tool helps answer:

• What is the probable forward range?
• Is the current move normal or extended?
• Is my target realistic?
• Is my stop too close?
• Is the market moving beyond expected assumptions?
• Should I reduce size because uncertainty is high?
• Has the market repriced beyond the cone after an event?

The indicator is designed to improve scenario planning, risk discipline, and volatility-aware decision making.

## Source Code

````pine
//@version=6
indicator("Risk-Neutral Probability Cone [v1]", "RN Cone", overlay=true, max_lines_count=500, max_labels_count=100)

// ======================================================
// 1. USER INPUTS
// ======================================================

// Anchor settings
anchorMode = input.string("Close", "Anchor Mode", options=["Close", "Manual", "EMA", "VWAP"])

manualAnchor = input.float(100.0, "Manual Anchor Price", minval=0.0000001)

emaLength = input.int(20, "EMA Anchor Length", minval=1, maxval=500)

// Cone horizon settings
horizonBars = input.int(50, "Projection Horizon in Bars", minval=1, maxval=500)

coneStep = input.int(5, "Cone Drawing Step", minval=1, maxval=50)

// Volatility settings
volatilityMode = input.string("Realized Volatility", "Volatility Model", options=["Realized Volatility", "ATR Proxy", "Composite"])

rvLookback = input.int(30, "Realized Volatility Lookback", minval=5, maxval=500)

atrLookback = input.int(14, "ATR Lookback", minval=2, maxval=500)

barsPerYear = input.int(252, "Bars Per Year", minval=1)

// Drift settings
driftMode = input.string("Risk-Neutral", "Drift Model", options=["Risk-Neutral", "Zero Drift", "Historical Drift"])

riskFreeRate = input.float(0.00, "Risk-Free Rate", step=0.001)

carryYield = input.float(0.00, "Carry / Dividend Yield", step=0.001)

historicalDriftLookback = input.int(100, "Historical Drift Lookback", minval=10, maxval=1000)

// Display settings
showOneSigma = input.bool(true, "Show 1σ Cone")

showTwoSigma = input.bool(true, "Show 2σ Cone")

showThreeSigma = input.bool(true, "Show 3σ Cone")

showExpectedPath = input.bool(true, "Show Expected Path")

showTerminalLabels = input.bool(true, "Show Terminal Labels")

showDashboard = input.bool(true, "Show Dashboard")

showProbabilityTarget = input.bool(false, "Show Probability to Target")

targetPrice = input.float(100.0, "Target Price", minval=0.0000001)

// Style settings
coneLineWidth = input.int(2, "Cone Line Width", minval=1, maxval=5)

expectedPathWidth = input.int(2, "Expected Path Width", minval=1, maxval=5)


// ======================================================
// 2. HELPER FUNCTIONS
// ======================================================

f_norm_pdf(x) =>
    0.3989422804014327 * math.exp(-0.5 * x * x)

f_norm_cdf(x) =>
    float absX = math.abs(x)
    float t = 1.0 / (1.0 + 0.2316419 * absX)
    float d = f_norm_pdf(absX)

    float prob = d * t * (
         0.319381530 +
         t * (
             -0.356563782 +
             t * (
                 1.781477937 +
                 t * (
                     -1.821255978 +
                     t * 1.330274429
                 )
             )
         )
    )

    x >= 0.0 ? 1.0 - prob : prob

f_lognormal_level(anchorPrice, drift, sigma, timeInYears, zScore) =>
    anchorPrice * math.exp((drift - 0.5 * sigma * sigma) * timeInYears + zScore * sigma * math.sqrt(timeInYears))

f_delete_lines(lineArray) =>
    int lineCount = array.size(lineArray)

    if lineCount > 0
        for i = 0 to lineCount - 1
            line currentLine = array.get(lineArray, i)

            if not na(currentLine)
                line.delete(currentLine)

        array.clear(lineArray)

f_delete_labels(labelArray) =>
    int labelCount = array.size(labelArray)

    if labelCount > 0
        for i = 0 to labelCount - 1
            label currentLabel = array.get(labelArray, i)

            if not na(currentLabel)
                label.delete(currentLabel)

        array.clear(labelArray)


// ======================================================
// 3. ANCHOR PRICE
// ======================================================

float anchorPrice = close

if anchorMode == "Manual"
    anchorPrice := manualAnchor
else if anchorMode == "EMA"
    anchorPrice := ta.ema(close, emaLength)
else if anchorMode == "VWAP"
    anchorPrice := ta.vwap(hlc3)
else
    anchorPrice := close


// ======================================================
// 4. VOLATILITY MODEL
// ======================================================

float logReturn = na

if close[1] > 0.0
    logReturn := math.log(close / close[1])

float rvPerBar = ta.stdev(logReturn, rvLookback)
float rvAnnualized = rvPerBar * math.sqrt(barsPerYear)

float atrValue = ta.atr(atrLookback)
float atrPct = close != 0.0 ? atrValue / close : na
float atrAnnualized = atrPct * math.sqrt(barsPerYear)

float compositeAnnualizedVol = (rvAnnualized * 0.60) + (atrAnnualized * 0.40)

float selectedVol = rvAnnualized

if volatilityMode == "ATR Proxy"
    selectedVol := atrAnnualized
else if volatilityMode == "Composite"
    selectedVol := compositeAnnualizedVol
else
    selectedVol := rvAnnualized

float sigma = math.max(selectedVol, 0.000001)


// ======================================================
// 5. DRIFT MODEL
// ======================================================

float averageLogReturn = ta.sma(logReturn, historicalDriftLookback)
float historicalDrift = averageLogReturn * barsPerYear

float riskNeutralDrift = riskFreeRate - carryYield

float selectedDrift = riskNeutralDrift

if driftMode == "Zero Drift"
    selectedDrift := 0.0
else if driftMode == "Historical Drift"
    selectedDrift := historicalDrift
else
    selectedDrift := riskNeutralDrift


// ======================================================
// 6. TERMINAL CONE LEVELS
// ======================================================

float horizonYears = horizonBars / barsPerYear

float expectedTerminal = f_lognormal_level(anchorPrice, selectedDrift, sigma, horizonYears, 0.0)

float upper1Terminal = f_lognormal_level(anchorPrice, selectedDrift, sigma, horizonYears, 1.0)
float lower1Terminal = f_lognormal_level(anchorPrice, selectedDrift, sigma, horizonYears, -1.0)

float upper2Terminal = f_lognormal_level(anchorPrice, selectedDrift, sigma, horizonYears, 2.0)
float lower2Terminal = f_lognormal_level(anchorPrice, selectedDrift, sigma, horizonYears, -2.0)

float upper3Terminal = f_lognormal_level(anchorPrice, selectedDrift, sigma, horizonYears, 3.0)
float lower3Terminal = f_lognormal_level(anchorPrice, selectedDrift, sigma, horizonYears, -3.0)


// ======================================================
// 7. TARGET PROBABILITY
// ======================================================

float targetProbabilityAbove = na
float targetProbabilityBelow = na

if showProbabilityTarget and targetPrice > 0.0 and anchorPrice > 0.0 and horizonYears > 0.0 and sigma > 0.0
    float zTarget = (math.log(targetPrice / anchorPrice) - (selectedDrift - 0.5 * sigma * sigma) * horizonYears) / (sigma * math.sqrt(horizonYears))
    targetProbabilityAbove := 1.0 - f_norm_cdf(zTarget)
    targetProbabilityBelow := f_norm_cdf(zTarget)


// ======================================================
// 8. DRAW PROBABILITY CONE
// ======================================================

var line[] coneLines = array.new_line()
var label[] coneLabels = array.new_label()

if barstate.islast
    f_delete_lines(coneLines)
    f_delete_labels(coneLabels)

    int maxStep = math.min(horizonBars, 500)
    int previousOffset = 0

    float prevExpected = anchorPrice
    float prevUpper1 = anchorPrice
    float prevLower1 = anchorPrice
    float prevUpper2 = anchorPrice
    float prevLower2 = anchorPrice
    float prevUpper3 = anchorPrice
    float prevLower3 = anchorPrice

    for currentOffset = coneStep to maxStep by coneStep
        float tYears = currentOffset / barsPerYear

        float currentExpected = f_lognormal_level(anchorPrice, selectedDrift, sigma, tYears, 0.0)

        float currentUpper1 = f_lognormal_level(anchorPrice, selectedDrift, sigma, tYears, 1.0)
        float currentLower1 = f_lognormal_level(anchorPrice, selectedDrift, sigma, tYears, -1.0)

        float currentUpper2 = f_lognormal_level(anchorPrice, selectedDrift, sigma, tYears, 2.0)
        float currentLower2 = f_lognormal_level(anchorPrice, selectedDrift, sigma, tYears, -2.0)

        float currentUpper3 = f_lognormal_level(anchorPrice, selectedDrift, sigma, tYears, 3.0)
        float currentLower3 = f_lognormal_level(anchorPrice, selectedDrift, sigma, tYears, -3.0)

        int x1 = bar_index + previousOffset
        int x2 = bar_index + currentOffset

        if showExpectedPath
            line expectedLine = line.new(x1, prevExpected, x2, currentExpected, color=color.new(color.white, 0), width=expectedPathWidth)
            array.push(coneLines, expectedLine)

        if showOneSigma
            line upper1Line = line.new(x1, prevUpper1, x2, currentUpper1, color=color.new(color.green, 0), width=coneLineWidth)
            line lower1Line = line.new(x1, prevLower1, x2, currentLower1, color=color.new(color.green, 0), width=coneLineWidth)

            array.push(coneLines, upper1Line)
            array.push(coneLines, lower1Line)

        if showTwoSigma
            line upper2Line = line.new(x1, prevUpper2, x2, currentUpper2, color=color.new(color.orange, 0), width=coneLineWidth)
            line lower2Line = line.new(x1, prevLower2, x2, currentLower2, color=color.new(color.orange, 0), width=coneLineWidth)

            array.push(coneLines, upper2Line)
            array.push(coneLines, lower2Line)

        if showThreeSigma
            line upper3Line = line.new(x1, prevUpper3, x2, currentUpper3, color=color.new(color.red, 0), width=1)
            line lower3Line = line.new(x1, prevLower3, x2, currentLower3, color=color.new(color.red, 0), width=1)

            array.push(coneLines, upper3Line)
            array.push(coneLines, lower3Line)

        previousOffset := currentOffset

        prevExpected := currentExpected
        prevUpper1 := currentUpper1
        prevLower1 := currentLower1
        prevUpper2 := currentUpper2
        prevLower2 := currentLower2
        prevUpper3 := currentUpper3
        prevLower3 := currentLower3

    if previousOffset < maxStep
        float finalYears = maxStep / barsPerYear

        float finalExpected = f_lognormal_level(anchorPrice, selectedDrift, sigma, finalYears, 0.0)

        float finalUpper1 = f_lognormal_level(anchorPrice, selectedDrift, sigma, finalYears, 1.0)
        float finalLower1 = f_lognormal_level(anchorPrice, selectedDrift, sigma, finalYears, -1.0)

        float finalUpper2 = f_lognormal_level(anchorPrice, selectedDrift, sigma, finalYears, 2.0)
        float finalLower2 = f_lognormal_level(anchorPrice, selectedDrift, sigma, finalYears, -2.0)

        float finalUpper3 = f_lognormal_level(anchorPrice, selectedDrift, sigma, finalYears, 3.0)
        float finalLower3 = f_lognormal_level(anchorPrice, selectedDrift, sigma, finalYears, -3.0)

        int finalX1 = bar_index + previousOffset
        int finalX2 = bar_index + maxStep

        if showExpectedPath
            line finalExpectedLine = line.new(finalX1, prevExpected, finalX2, finalExpected, color=color.new(color.white, 0), width=expectedPathWidth)
            array.push(coneLines, finalExpectedLine)

        if showOneSigma
            line finalUpper1Line = line.new(finalX1, prevUpper1, finalX2, finalUpper1, color=color.new(color.green, 0), width=coneLineWidth)
            line finalLower1Line = line.new(finalX1, prevLower1, finalX2, finalLower1, color=color.new(color.green, 0), width=coneLineWidth)

            array.push(coneLines, finalUpper1Line)
            array.push(coneLines, finalLower1Line)

        if showTwoSigma
            line finalUpper2Line = line.new(finalX1, prevUpper2, finalX2, finalUpper2, color=color.new(color.orange, 0), width=coneLineWidth)
            line finalLower2Line = line.new(finalX1, prevLower2, finalX2, finalLower2, color=color.new(color.orange, 0), width=coneLineWidth)

            array.push(coneLines, finalUpper2Line)
            array.push(coneLines, finalLower2Line)

        if showThreeSigma
            line finalUpper3Line = line.new(finalX1, prevUpper3, finalX2, finalUpper3, color=color.new(color.red, 0), width=1)
            line finalLower3Line = line.new(finalX1, prevLower3, finalX2, finalLower3, color=color.new(color.red, 0), width=1)

            array.push(coneLines, finalUpper3Line)
            array.push(coneLines, finalLower3Line)

    if showTerminalLabels
        int labelX = bar_index + maxStep

        label anchorLabel = label.new(bar_index, anchorPrice, "Anchor: " + str.tostring(anchorPrice, format.mintick), style=label.style_label_left, textcolor=color.white, color=color.new(color.gray, 0))
        array.push(coneLabels, anchorLabel)

        if showExpectedPath
            label expectedLabel = label.new(labelX, expectedTerminal, "Expected: " + str.tostring(expectedTerminal, format.mintick), style=label.style_label_left, textcolor=color.white, color=color.new(color.gray, 0))
            array.push(coneLabels, expectedLabel)

        if showOneSigma
            label upper1Label = label.new(labelX, upper1Terminal, "+1σ: " + str.tostring(upper1Terminal, format.mintick), style=label.style_label_left, textcolor=color.white, color=color.new(color.green, 0))
            label lower1Label = label.new(labelX, lower1Terminal, "-1σ: " + str.tostring(lower1Terminal, format.mintick), style=label.style_label_left, textcolor=color.white, color=color.new(color.green, 0))

            array.push(coneLabels, upper1Label)
            array.push(coneLabels, lower1Label)

        if showTwoSigma
            label upper2Label = label.new(labelX, upper2Terminal, "+2σ: " + str.tostring(upper2Terminal, format.mintick), style=label.style_label_left, textcolor=color.white, color=color.new(color.orange, 0))
            label lower2Label = label.new(labelX, lower2Terminal, "-2σ: " + str.tostring(lower2Terminal, format.mintick), style=label.style_label_left, textcolor=color.white, color=color.new(color.orange, 0))

            array.push(coneLabels, upper2Label)
            array.push(coneLabels, lower2Label)

        if showThreeSigma
            label upper3Label = label.new(labelX, upper3Terminal, "+3σ: " + str.tostring(upper3Terminal, format.mintick), style=label.style_label_left, textcolor=color.white, color=color.new(color.red, 0))
            label lower3Label = label.new(labelX, lower3Terminal, "-3σ: " + str.tostring(lower3Terminal, format.mintick), style=label.style_label_left, textcolor=color.white, color=color.new(color.red, 0))

            array.push(coneLabels, upper3Label)
            array.push(coneLabels, lower3Label)

        if showProbabilityTarget and not na(targetProbabilityAbove)
            label targetProbLabel = label.new(labelX, targetPrice, "P(Above Target): " + str.tostring(targetProbabilityAbove * 100.0, "#.##") + "%", style=label.style_label_left, textcolor=color.white, color=color.new(color.blue, 0))
            array.push(coneLabels, targetProbLabel)


// ======================================================
// 9. DASHBOARD
// ======================================================

var table dash = table.new(position.top_right, columns=2, rows=12, border_width=1)

if barstate.islast
    if showDashboard
        table.cell(dash, 0, 0, "Metric", text_color=color.white, bgcolor=color.new(color.black, 0))
        table.cell(dash, 1, 0, "Value", text_color=color.white, bgcolor=color.new(color.black, 0))

        table.cell(dash, 0, 1, "Anchor", text_color=color.white, bgcolor=color.new(color.black, 20))
        table.cell(dash, 1, 1, str.tostring(anchorPrice, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 20))

        table.cell(dash, 0, 2, "Vol Model", text_color=color.white, bgcolor=color.new(color.black, 20))
        table.cell(dash, 1, 2, volatilityMode, text_color=color.white, bgcolor=color.new(color.black, 20))

        table.cell(dash, 0, 3, "Annualized Vol", text_color=color.white, bgcolor=color.new(color.black, 20))
        table.cell(dash, 1, 3, str.tostring(sigma * 100.0, "#.##") + "%", text_color=color.white, bgcolor=color.new(color.black, 20))

        table.cell(dash, 0, 4, "Drift Model", text_color=color.white, bgcolor=color.new(color.black, 20))
        table.cell(dash, 1, 4, driftMode, text_color=color.white, bgcolor=color.new(color.black, 20))

        table.cell(dash, 0, 5, "Annual Drift", text_color=color.white, bgcolor=color.new(color.black, 20))
        table.cell(dash, 1, 5, str.tostring(selectedDrift * 100.0, "#.##") + "%", text_color=color.white, bgcolor=color.new(color.black, 20))

        table.cell(dash, 0, 6, "Horizon Bars", text_color=color.white, bgcolor=color.new(color.black, 20))
        table.cell(dash, 1, 6, str.tostring(horizonBars), text_color=color.white, bgcolor=color.new(color.black, 20))

        table.cell(dash, 0, 7, "Expected Terminal", text_color=color.white, bgcolor=color.new(color.black, 20))
        table.cell(dash, 1, 7, str.tostring(expectedTerminal, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 20))

        table.cell(dash, 0, 8, "+1σ / -1σ", text_color=color.white, bgcolor=color.new(color.black, 20))
        table.cell(dash, 1, 8, str.tostring(upper1Terminal, format.mintick) + " / " + str.tostring(lower1Terminal, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 20))

        table.cell(dash, 0, 9, "+2σ / -2σ", text_color=color.white, bgcolor=color.new(color.black, 20))
        table.cell(dash, 1, 9, str.tostring(upper2Terminal, format.mintick) + " / " + str.tostring(lower2Terminal, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 20))

        table.cell(dash, 0, 10, "+3σ / -3σ", text_color=color.white, bgcolor=color.new(color.black, 20))
        table.cell(dash, 1, 10, str.tostring(upper3Terminal, format.mintick) + " / " + str.tostring(lower3Terminal, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 20))

        table.cell(dash, 0, 11, "P Above Target", text_color=color.white, bgcolor=color.new(color.black, 20))
        table.cell(dash, 1, 11, showProbabilityTarget and not na(targetProbabilityAbove) ? str.tostring(targetProbabilityAbove * 100.0, "#.##") + "%" : "Hidden", text_color=color.white, bgcolor=color.new(color.black, 20))
    else
        table.clear(dash, 0, 0, 1, 11)


// ======================================================
// 10. ALERT CONDITIONS
// ======================================================

alertcondition(showProbabilityTarget and not na(targetProbabilityAbove) and targetProbabilityAbove >= 0.70, title="High Probability Above Target", message="Risk-Neutral Probability Cone estimates probability above target is 70% or higher.")

alertcondition(showProbabilityTarget and not na(targetProbabilityAbove) and targetProbabilityAbove <= 0.30, title="Low Probability Above Target", message="Risk-Neutral Probability Cone estimates probability above target is 30% or lower.")

alertcondition(close > upper1Terminal, title="Price Above Terminal +1σ", message="Price is above the current terminal +1σ cone level.")

alertcondition(close < lower1Terminal, title="Price Below Terminal -1σ", message="Price is below the current terminal -1σ cone level.")

alertcondition(close > upper2Terminal, title="Price Above Terminal +2σ", message="Price is above the current terminal +2σ cone level.")

alertcondition(close < lower2Terminal, title="Price Below Terminal -2σ", message="Price is below the current terminal -2σ cone level.")
````
