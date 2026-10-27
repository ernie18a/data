# Barrier Option-Style Breakout Indicator [v1]

- url: https://www.tradingview.com/script/5BBMS3LW-Barrier-Option-Style-Breakout-Indicator-v1/
- type: indicator
- pine_id: PUB;eba99854c28c4be8b1a0d51e71a7d098
- version: 1.0

## Description

The Barrier Option-Style Breakout Indicator is a path-dependent breakout tool inspired by barrier option logic.

In barrier options, the path of price matters. It is not enough to know where price ends. What matters is whether price touched, breached, activated, retested, or failed around a specific barrier level.

This indicator applies that same idea to breakout trading.

Instead of only asking whether price is above resistance or below support, the indicator asks:

• Has price reached the barrier?
• Has the barrier been confirmed?
• Did the breakout pass volatility and volume quality filters?
• Did price retest the barrier and hold?
• Did price fail back inside the range?
• Is the breakout active, weak, confirmed, or failed?

This is not a simple buy or sell signal indicator.

It is a breakout-quality and path-dependency framework designed to help traders evaluate whether a breakout has enough structure, confirmation, and follow-through.

The indicator can be used across FX, crypto, indices, commodities, futures, and liquid stocks.

WHAT THE INDICATOR DOES
━━━━━━━━━━━━━━━━━━━━━━

The indicator creates upper and lower barrier levels.

These barriers can be based on:

• Recent range high and range low
• Manual user-defined levels
• Expected-move levels

Once a barrier is touched or breached, the script tracks what happens next.

It classifies the market into states such as:

• Neutral
• Weak upper breach
• Weak lower breach
• Bullish knock-in
• Bearish knock-in
• Bullish retest confirmed
• Bearish retest confirmed
• Bullish barrier failed
• Bearish barrier failed

The key advantage is that the indicator remembers the active barrier and monitors the post-breakout path.

This makes it more useful than a simple horizontal breakout line.

CORE IDEA
━━━━━━━━━━━━━━━━━━━━━━

A normal breakout indicator usually checks whether price has crossed a level.

This indicator goes further.

It treats the breakout level as a barrier.

Once price activates the barrier, the indicator tracks whether the breakout becomes more credible or fails.

The logic is:

1. Define the upper and lower barriers.
2. Watch for price to touch or close beyond a barrier.
3. Apply breakout confirmation rules.
4. Check volatility and volume quality filters.
5. Track the active barrier after breakout.
6. Watch for a retest.
7. Watch for a failure back inside the barrier.
8. Classify the current market state.

This gives the trader a more complete breakout map.

MAIN COMPONENTS
━━━━━━━━━━━━━━━━━━━━━━

1. Barrier Mode

The script includes three barrier modes:

• Range High/Low
• Manual
• Expected Move

Range High/Low uses the recent highest high and lowest low over the selected lookback period.

Manual allows the trader to enter custom upper and lower barrier levels.

Expected Move creates dynamic barriers using volatility and expected-move logic.

Range High/Low is usually best for technical breakout trading.

Manual is useful for major levels, event levels, round numbers, or externally defined support and resistance.

Expected Move is useful for volatility-adjusted breakout analysis.

2. Range Lookback

When using Range High/Low mode, the range lookback determines how many bars are used to calculate the upper and lower barriers.

A shorter lookback creates more reactive barriers.

A longer lookback creates more important, but slower-moving barriers.

For intraday trading, 30 to 80 bars can be useful.

For swing trading, 50 to 200 bars may be more appropriate.

3. Manual Barriers

Manual mode allows the trader to input a specific upper and lower barrier.

This is useful when the trader already knows the key levels.

Examples include:

• Previous day high
• Previous day low
• Weekly high
• Weekly low
• Major support
• Major resistance
• Round number
• Event anchor level
• Liquidity zone

4. Expected Move Barriers

Expected Move mode calculates barriers using volatility.

The indicator estimates expected movement over a selected horizon and places the upper and lower barriers around the anchor price.

This mode is useful when the trader wants breakout levels to adapt to current volatility.

If volatility is high, the expected-move barriers widen.

If volatility is low, the expected-move barriers narrow.

5. Breakout Confirmation

The script includes three confirmation modes:

• Touch Barrier
• Close Beyond Barrier
• Close + Buffer

Touch Barrier is the most sensitive.

Close Beyond Barrier requires the candle to close beyond the barrier.

Close + Buffer requires price to close beyond the barrier by an additional buffer.

Close + Buffer is the strictest and usually the best setting for reducing false breakouts.

6. Breakout Buffer

The breakout buffer helps reduce false signals.

The buffer can be based on:

• ATR
• Percent
• Ticks

ATR buffer is generally the most adaptive because it scales with current market volatility.

For example, a 0.25 ATR buffer means price must close beyond the barrier by 25% of the current ATR.

7. Retest Logic

After a breakout, price often returns to test the breakout level.

The indicator can monitor whether price retests the active barrier and holds.

A bullish retest is confirmed when price breaks above the upper barrier, returns toward that barrier, and holds above it.

A bearish retest is confirmed when price breaks below the lower barrier, returns toward that barrier, and holds below it.

This is useful because many traders prefer to enter after a breakout retest rather than on the initial breakout candle.

8. Retest Window

The retest window controls how many bars after the breakout the indicator will monitor for a valid retest.

A short window is stricter.

A longer window gives price more time to return to the barrier.

For intraday trading, 8 to 24 bars can be useful.

For swing trading, 20 to 50 bars may be more appropriate.

9. Retest Tolerance

The retest tolerance controls how close price must come to the active barrier to qualify as a retest.

The tolerance can be based on:

• ATR
• Percent
• Ticks

ATR tolerance is usually the best default because it adapts to volatility.

10. Failure Logic

A failed breakout occurs when price breaks the barrier but then returns back inside the prior range.

For a bullish breakout, failure occurs when price breaks above the upper barrier but then closes back below the active barrier.

For a bearish breakout, failure occurs when price breaks below the lower barrier but then closes back above the active barrier.

Failure detection is important because failed breakouts can produce strong reversal moves.

11. Quality Filters

The script includes volatility and volume quality filters.

The volatility filter checks whether volatility percentile is high enough to support a quality breakout.

The volume filter checks whether current volume is elevated relative to average volume.

A breakout that passes both filters is treated as stronger.

A breakout that breaches the barrier but fails the quality filters is marked as a weak breach.

12. Barrier Hit Probability Proxy

The indicator includes a simple barrier hit probability estimate.

This is not a full barrier option first-passage model.

It is a simplified approximation based on:

• Distance to the barrier
• Expected move
• Selected barrier sigma

It gives a rough sense of how close price is to the upper or lower barrier in volatility-adjusted terms.

HOW TO READ THE INDICATOR
━━━━━━━━━━━━━━━━━━━━━━

The indicator plots barrier levels on the price chart.

Visual guide:

• Green line = Upper Barrier
• Red line = Lower Barrier
• Faded green line = Upper confirmation level when buffer is enabled
• Faded red line = Lower confirmation level when buffer is enabled
• White line = Active Barrier after breakout activation

Signal labels show:

• Knock-In
• Weak
• Retest
• Fail

A Knock-In signal means the barrier breakout has been activated.

A Weak signal means the barrier was breached, but quality filters failed.

A Retest signal means price returned to the active barrier and held.

A Fail signal means price broke the barrier but failed back inside.

The dashboard shows:

• Market State
• Barrier Mode
• Upper Barrier
• Lower Barrier
• Active Barrier
• Bars Since Breakout
• Volatility Percentile
• Volume Ratio
• Quality Filter
• Probability Hit Upper
• Probability Hit Lower

MARKET STATE DEFINITIONS
━━━━━━━━━━━━━━━━━━━━━━

Neutral

Neutral means no active confirmed breakout state is present.

Price may be trading inside the range or near a barrier without confirmation.

Weak Upper Breach

A weak upper breach occurs when price breaches the upper barrier, but the quality filters do not pass.

This suggests the upside breakout may lack volatility or volume support.

Weak Lower Breach

A weak lower breach occurs when price breaches the lower barrier, but the quality filters do not pass.

This suggests the downside breakout may lack volatility or volume support.

Bullish Knock-In

Bullish Knock-In means the upper barrier has been activated by a confirmed bullish breakout.

This suggests upside breakout conditions are active.

Bearish Knock-In

Bearish Knock-In means the lower barrier has been activated by a confirmed bearish breakout.

This suggests downside breakout conditions are active.

Bullish Retest Confirmed

Bullish Retest Confirmed means price broke above the upper barrier, returned to retest it, and held above it.

This is often a higher-quality bullish continuation condition than the initial breakout candle alone.

Bearish Retest Confirmed

Bearish Retest Confirmed means price broke below the lower barrier, returned to retest it, and held below it.

This is often a higher-quality bearish continuation condition than the initial breakdown candle alone.

Bullish Barrier Failed

Bullish Barrier Failed means price broke above the upper barrier but then failed back below the active barrier.

This may indicate a failed breakout, bull trap, liquidity sweep, or exhaustion move.

Bearish Barrier Failed

Bearish Barrier Failed means price broke below the lower barrier but then failed back above the active barrier.

This may indicate a failed breakdown, bear trap, liquidity sweep, or exhaustion move.

HOW TO USE THE INDICATOR
━━━━━━━━━━━━━━━━━━━━━━

Use this indicator as a breakout-quality framework.

The script is designed to help answer:

• Where are the active breakout barriers?
• Has price breached the barrier?
• Did the breach pass quality filters?
• Has the breakout retested and held?
• Has the breakout failed back inside?
• Is the breakout worth following or should it be avoided?

The indicator should not be used alone for trade entries.

Use it with market structure, trend, liquidity, volatility regime, expected-move levels, and risk management.

PRACTICAL TRADING WORKFLOW
━━━━━━━━━━━━━━━━━━━━━━

1. Choose the barrier mode.

Use Range High/Low for normal breakout trading.

Use Manual for known levels.

Use Expected Move for volatility-adjusted breakout zones.

2. Choose confirmation mode.

Use Close Beyond Barrier for balanced confirmation.

Use Close + Buffer for stricter breakout confirmation.

Use Touch Barrier only for aggressive or early-warning use.

3. Check quality filters.

A breakout is stronger when volatility and volume filters pass.

A weak breach should be treated with caution.

4. Watch the active barrier.

After a breakout, the active barrier becomes the key reference level.

For bullish breakouts, the upper barrier becomes the key support test.

For bearish breakouts, the lower barrier becomes the key resistance test.

5. Wait for retest if needed.

Conservative traders may wait for Retest Confirmed before entering.

This can reduce chasing risk after the initial breakout candle.

6. Watch for failure.

If price returns back inside the barrier within the failure window, the breakout has failed.

Failed breakouts can become reversal opportunities, but they still require confirmation.

7. Manage risk.

Breakouts can be volatile.

Do not use the signal without stop-loss planning, position sizing, and reward-to-risk evaluation.

BREAKOUT INTERPRETATION
━━━━━━━━━━━━━━━━━━━━━━

Bullish Breakout Setup

A higher-quality bullish breakout may include:

• Price breaks above the upper barrier
• Confirmation mode is satisfied
• Volatility filter passes
• Volume filter passes
• Price holds above the active barrier
• Retest is confirmed
• Higher-timeframe structure supports upside

Bearish Breakout Setup

A higher-quality bearish breakout may include:

• Price breaks below the lower barrier
• Confirmation mode is satisfied
• Volatility filter passes
• Volume filter passes
• Price holds below the active barrier
• Retest is confirmed
• Higher-timeframe structure supports downside

Weak Breakout

A weak breakout may occur when:

• Price breaches the barrier but volume is low
• Volatility percentile is too low
• Price fails to close beyond the buffer
• Price immediately returns inside the range
• Breakout occurs into major opposing structure

Failed Breakout

A failed breakout may occur when:

• Price breaks the barrier
• Traders chase the breakout
• Price reverses back inside the barrier
• The active barrier fails to hold
• The market traps breakout traders

Failed breakouts should not be ignored. They often contain useful information about liquidity and positioning.

SUGGESTED SETTINGS
━━━━━━━━━━━━━━━━━━━━━━

FX 1-Hour

• Barrier Mode: Range High/Low
• Range Lookback Bars: 50
• Breakout Confirmation: Close + Buffer
• Buffer Mode: ATR
• ATR Buffer Multiplier: 0.20 to 0.35
• Retest Window Bars: 12 to 24
• Failure Window Bars: 12 to 24
• Volatility Filter: True
• Minimum Vol Percentile: 50
• Volume Filter: False or True depending on broker volume quality
• Bars Per Year: 6240

Crypto 1-Hour

• Barrier Mode: Range High/Low
• Range Lookback Bars: 50 to 100
• Breakout Confirmation: Close + Buffer
• ATR Buffer Multiplier: 0.25 to 0.50
• Retest Window Bars: 24
• Failure Window Bars: 24
• Volatility Filter: True
• Volume Filter: True
• Minimum Volume Ratio: 1.20
• Bars Per Year: 8760

Indices 15-Minute or 1-Hour

• Barrier Mode: Range High/Low
• Range Lookback Bars: 30 to 80
• Breakout Confirmation: Close + Buffer
• ATR Buffer Multiplier: 0.20 to 0.40
• Retest Window Bars: 8 to 20
• Failure Window Bars: 8 to 20
• Volatility Filter: True
• Volume Filter: True

Daily Equities

• Barrier Mode: Range High/Low or Manual
• Range Lookback Bars: 50 to 100
• Breakout Confirmation: Close Beyond Barrier or Close + Buffer
• ATR Buffer Multiplier: 0.20 to 0.50
• Retest Window Bars: 5 to 20
• Failure Window Bars: 5 to 20
• Volatility Filter: True
• Volume Filter: True
• Bars Per Year: 252

BARRIER MODE GUIDE
━━━━━━━━━━━━━━━━━━━━━━

Range High/Low

This mode calculates the upper and lower barriers from the recent price range.

Best for:

• Breakout trading
• Range expansion setups
• Support and resistance breaks
• Consolidation breakouts

Manual

Manual mode allows the trader to define the upper and lower barriers.

Best for:

• Key technical levels
• Previous day high/low
• Weekly high/low
• Round numbers
• Event levels
• Liquidity zones

Expected Move

Expected Move mode creates volatility-adjusted barriers.

Best for:

• Volatility-based breakout analysis
• Event-risk planning
• Comparing price movement to expected range
• Adaptive barrier levels

CONFIRMATION MODE GUIDE
━━━━━━━━━━━━━━━━━━━━━━

Touch Barrier

This mode triggers as soon as price touches the barrier.

It is the most sensitive setting.

Best for early warning, but it will produce more false signals.

Close Beyond Barrier

This mode requires the candle to close beyond the barrier.

It is more reliable than simple touch logic.

This is a balanced setting.

Close + Buffer

This mode requires price to close beyond the barrier by an additional buffer.

It is the strictest setting.

Best for reducing false breakouts.

RETEST LOGIC GUIDE
━━━━━━━━━━━━━━━━━━━━━━

A retest occurs when price breaks the barrier and then returns to test it.

For bullish breakouts, the upper barrier should ideally act as support.

For bearish breakouts, the lower barrier should ideally act as resistance.

Retest confirmation can help traders avoid chasing the initial breakout candle.

However, not all strong breakouts retest.

A very strong breakout may continue without giving a clean retest.

FAILURE LOGIC GUIDE
━━━━━━━━━━━━━━━━━━━━━━

A breakout failure occurs when price breaks the barrier but then returns back inside the active barrier.

This can be important because failed breakouts often indicate trapped positioning.

A bullish breakout failure can suggest:

• Bull trap
• Liquidity sweep above resistance
• Failed upside continuation
• Potential reversal risk

A bearish breakout failure can suggest:

• Bear trap
• Liquidity sweep below support
• Failed downside continuation
• Potential reversal risk

Failure signals should still be confirmed with price structure and risk management.

HOW TO COMBINE WITH OTHER INDICATORS
━━━━━━━━━━━━━━━━━━━━━━

This indicator works best as part of a broader volatility and market-structure framework.

Useful combinations:

• Expected Move Bands
• Realized Volatility Regime Indicator
• Implied Volatility Proxy
• Delta-Hedging Pressure Proxy
• Dynamic Stop-Loss Using Expected Move
• Risk-Neutral Probability Cone
• VWAP
• Moving averages
• Support and resistance
• Liquidity zones
• Market structure breaks
• Macro and event calendars

Suggested framework:

Expected Move Bands show near-term volatility-adjusted levels.

Realized Volatility Regime shows whether volatility is low, normal, high, or extreme.

IV Proxy shows whether broader uncertainty is rising or cooling.

Delta-Hedging Pressure Proxy shows whether directional pressure is positive or negative.

Dynamic Stop-Loss converts volatility into risk levels.

Risk-Neutral Probability Cone maps forward probability ranges.

Barrier Option-Style Breakout Indicator tracks whether price has activated, confirmed, retested, or failed a breakout barrier.

Together, these tools help answer:

• Where are the breakout levels?
• Has price activated the barrier?
• Is the breakout high quality or weak?
• Has the breakout retested and held?
• Has the breakout failed?
• How far can price reasonably move?
• Where should stops and targets be placed?
• Should position size be reduced?

TRADING EXAMPLES
━━━━━━━━━━━━━━━━━━━━━━

Example 1: Bullish Knock-In

Price breaks above the upper barrier.

The dashboard shows:

• Market State: Bullish Knock-In
• Quality Filter: Pass
• Volatility Percentile: above threshold
• Volume Ratio: above threshold

This suggests that the upside breakout has been activated and supported by quality conditions.

A trader may look for continuation, but should still manage risk carefully.

Example 2: Bullish Retest Confirmed

Price breaks above the upper barrier, then returns to retest the barrier and holds above it.

The dashboard shows:

• Market State: Bullish Retest Confirmed

This is often a stronger continuation setup than the initial breakout candle.

A trader may use the active barrier as a key invalidation reference.

Example 3: Weak Upper Breach

Price moves above the upper barrier, but the quality filter fails.

The dashboard shows:

• Market State: Weak Upper Breach
• Quality Filter: Fail

This suggests caution.

The breakout may not have enough volatility or volume support.

Example 4: Bullish Barrier Failed

Price breaks above the upper barrier but then closes back below the active barrier.

The dashboard shows:

• Market State: Bullish Barrier Failed

This may indicate a bull trap, failed breakout, or liquidity sweep.

A trader should avoid assuming continuation unless price reclaims the barrier.

Example 5: Bearish Retest Confirmed

Price breaks below the lower barrier, then retests the barrier from below and fails to reclaim it.

The dashboard shows:

• Market State: Bearish Retest Confirmed

This suggests downside breakout structure remains valid.

A trader may use the active barrier as a resistance and invalidation reference.

RISK MANAGEMENT NOTES
━━━━━━━━━━━━━━━━━━━━━━

Breakout strategies can suffer from false signals.

This indicator helps reduce that risk by separating:

• Weak breaches
• Confirmed knock-ins
• Retest confirmations
• Failed breakouts

Practical risk rules:

• Do not chase every knock-in candle
• Treat weak breaches with caution
• Wait for retest confirmation if chasing risk is high
• Use failed breakout signals as risk warnings
• Use the active barrier as an invalidation reference
• Reduce size in high-volatility conditions
• Do not rely on volume filters when the asset has poor volume data
• Combine with expected move and dynamic stop tools

A breakout is not automatically valid because price crossed a line.

The path after the breakout matters.

WHAT THIS INDICATOR IS BEST FOR
━━━━━━━━━━━━━━━━━━━━━━

This indicator is best used for:

• Breakout quality assessment
• Range breakout tracking
• Barrier activation logic
• Retest confirmation
• Failed breakout detection
• Liquidity sweep awareness
• Event-level breakout monitoring
• Support and resistance breakout analysis
• Volatility-adjusted breakout levels
• Trade planning and risk management

It is useful for traders who want more structure than a basic support/resistance breakout signal.

WHAT THIS INDICATOR IS NOT
━━━━━━━━━━━━━━━━━━━━━━

This indicator is not:

• A standalone trading strategy
• A guaranteed breakout system
• A buy or sell signal generator
• A true barrier option pricing model
• A full first-passage probability model
• A replacement for risk management
• A replacement for market structure
• A complete trading system

The indicator identifies breakout states.

It does not guarantee continuation.

IMPORTANT LIMITATIONS
━━━━━━━━━━━━━━━━━━━━━━

The indicator uses price, volatility, range, and volume data.

It does not include:

• Order flow
• Market depth
• Dealer positioning
• Options open interest
• Real barrier option pricing
• News sentiment
• Fundamental data
• Liquidity conditions

The probability estimate is simplified.

It is not a full barrier option first-passage model.

Volume quality may differ across markets.

For example:

• FX broker volume is usually tick volume
• Crypto volume depends on exchange feed
• Equities and futures volume are generally more reliable
• Indices may use synthetic or broker-dependent volume

Breakouts can fail even when quality filters pass.

The indicator should be used as a decision-support tool, not as a standalone system.

FINAL NOTES
━━━━━━━━━━━━━━━━━━━━━━

The Barrier Option-Style Breakout Indicator helps traders think about breakouts as path-dependent events.

Instead of asking only whether price crossed a level, the tool helps answer:

• Did price activate the barrier?
• Was the breakout strong or weak?
• Did volatility and volume support the move?
• Did price retest the barrier?
• Did the barrier hold?
• Did the breakout fail?
• Is the active barrier now the key invalidation level?

The indicator is designed to improve breakout discipline, reduce emotional chasing, and provide a structured way to monitor breakout behaviour.

## Source Code

````pine
//@version=6
indicator("Barrier Option-Style Breakout Indicator [v1]", "Barrier BO", overlay=true, max_lines_count=100, max_labels_count=100)

// ======================================================
// 1. USER INPUTS
// ======================================================

// Barrier mode
barrierMode = input.string("Range High/Low", "Barrier Mode", options=["Range High/Low", "Manual", "Expected Move"])

lookbackBars = input.int(50, "Range Lookback Bars", minval=5, maxval=500)

manualUpperBarrier = input.float(100.0, "Manual Upper Barrier", minval=0.0000001)

manualLowerBarrier = input.float(90.0, "Manual Lower Barrier", minval=0.0000001)

// Expected move barrier settings
anchorMode = input.string("Close", "Expected Move Anchor", options=["Close", "EMA", "VWAP"])

emaLength = input.int(20, "EMA Anchor Length", minval=1, maxval=500)

rvLookback = input.int(30, "Realized Volatility Lookback", minval=5, maxval=500)

atrLookback = input.int(14, "ATR Lookback", minval=2, maxval=500)

volatilityMode = input.string("Composite", "Volatility Model", options=["Realized Volatility", "ATR Proxy", "Composite"])

horizonBars = input.int(20, "Expected Move Horizon Bars", minval=1, maxval=500)

barsPerYear = input.int(252, "Bars Per Year", minval=1)

barrierSigma = input.float(1.0, "Expected Move Barrier Sigma", minval=0.25, maxval=5.0, step=0.25)

// Breakout confirmation
confirmationMode = input.string("Close Beyond Barrier", "Breakout Confirmation", options=["Touch Barrier", "Close Beyond Barrier", "Close + Buffer"])

bufferMode = input.string("ATR", "Breakout Buffer Mode", options=["ATR", "Percent", "Ticks"])

atrBufferMultiplier = input.float(0.25, "ATR Buffer Multiplier", minval=0.0, maxval=5.0, step=0.05)

percentBuffer = input.float(0.10, "Percent Buffer", minval=0.0, maxval=10.0, step=0.05)

tickBuffer = input.int(5, "Tick Buffer", minval=0, maxval=1000)

// Retest logic
enableRetest = input.bool(true, "Enable Retest Logic")

retestWindowBars = input.int(20, "Retest Window Bars", minval=1, maxval=200)

retestToleranceMode = input.string("ATR", "Retest Tolerance Mode", options=["ATR", "Percent", "Ticks"])

retestAtrMultiplier = input.float(0.35, "Retest ATR Multiplier", minval=0.0, maxval=5.0, step=0.05)

retestPercent = input.float(0.15, "Retest Percent", minval=0.0, maxval=10.0, step=0.05)

retestTicks = input.int(10, "Retest Ticks", minval=0, maxval=1000)

// Failure logic
failureWindowBars = input.int(20, "Failure Window Bars", minval=1, maxval=200)

requireFailureCloseBackInside = input.bool(true, "Failure Requires Close Back Inside")

// Quality filter
useVolatilityFilter = input.bool(true, "Use Volatility Filter")

volPercentileLookback = input.int(252, "Volatility Percentile Lookback", minval=20, maxval=1000)

minimumVolPercentile = input.float(50.0, "Minimum Vol Percentile for Quality Breakout", minval=0.0, maxval=100.0)

useVolumeFilter = input.bool(true, "Use Volume Filter")

volumeLookback = input.int(20, "Volume Lookback", minval=5, maxval=500)

minimumVolumeRatio = input.float(1.10, "Minimum Volume Ratio", minval=0.1, maxval=10.0, step=0.05)

// Display
showDashboard = input.bool(true, "Show Dashboard")

showBarrierLines = input.bool(true, "Show Barrier Lines")

showStateLabels = input.bool(true, "Show State Labels")

showBackground = input.bool(true, "Show State Background")

showSignals = input.bool(true, "Show Breakout Signals")

showProbabilityEstimate = input.bool(true, "Show Barrier Probability Estimate")


// ======================================================
// 2. HELPER FUNCTIONS
// ======================================================

f_percent_rank(src, length) =>
    float count = 0.0
    float valid = 0.0

    for i = 1 to length
        if not na(src[i])
            valid += 1.0
            if src > src[i]
                count += 1.0

    valid > 0.0 ? (count / valid) * 100.0 : na

f_buffer(mode, atrValue, atrMult, pctValue, tickValue) =>
    float result = 0.0

    if mode == "ATR"
        result := atrValue * atrMult
    else if mode == "Percent"
        result := close * pctValue / 100.0
    else
        result := syminfo.mintick * tickValue

    result

f_safe_div(num, den) =>
    den != 0.0 and not na(den) ? num / den : na


// ======================================================
// 3. VOLATILITY MODEL
// ======================================================

float logReturn = na

if close[1] > 0.0
    logReturn := math.log(close / close[1])

float rvPerBar = ta.stdev(logReturn, rvLookback)
float rvAnnualized = rvPerBar * math.sqrt(barsPerYear)

float atrValue = ta.atr(atrLookback)
float atrPct = close != 0.0 ? atrValue / close : na
float atrAnnualized = atrPct * math.sqrt(barsPerYear)

float compositeVol = (rvAnnualized * 0.60) + (atrAnnualized * 0.40)

float selectedVol = rvAnnualized

if volatilityMode == "ATR Proxy"
    selectedVol := atrAnnualized
else if volatilityMode == "Composite"
    selectedVol := compositeVol
else
    selectedVol := rvAnnualized

float expectedMovePct = selectedVol * math.sqrt(horizonBars / barsPerYear)

float volPercentile = f_percent_rank(selectedVol, volPercentileLookback)


// ======================================================
// 4. ANCHOR AND BARRIER LEVELS
// ======================================================

float anchorPrice = close

if anchorMode == "EMA"
    anchorPrice := ta.ema(close, emaLength)
else if anchorMode == "VWAP"
    anchorPrice := ta.vwap(hlc3)
else
    anchorPrice := close

float expectedMoveAbs = anchorPrice * expectedMovePct

float rangeUpper = ta.highest(high[1], lookbackBars)
float rangeLower = ta.lowest(low[1], lookbackBars)

float upperBarrier = rangeUpper
float lowerBarrier = rangeLower

if barrierMode == "Manual"
    upperBarrier := manualUpperBarrier
    lowerBarrier := manualLowerBarrier
else if barrierMode == "Expected Move"
    upperBarrier := anchorPrice + expectedMoveAbs * barrierSigma
    lowerBarrier := anchorPrice - expectedMoveAbs * barrierSigma
else
    upperBarrier := rangeUpper
    lowerBarrier := rangeLower


// ======================================================
// 5. BUFFER AND RETEST TOLERANCE
// ======================================================

float breakoutBuffer = f_buffer(bufferMode, atrValue, atrBufferMultiplier, percentBuffer, tickBuffer)

float retestTolerance = f_buffer(retestToleranceMode, atrValue, retestAtrMultiplier, retestPercent, retestTicks)

float upperConfirmLevel = upperBarrier + breakoutBuffer
float lowerConfirmLevel = lowerBarrier - breakoutBuffer


// ======================================================
// 6. BREAKOUT CONDITIONS
// ======================================================

bool upperTouched = high >= upperBarrier
bool lowerTouched = low <= lowerBarrier

bool upperClosedBeyond = close > upperBarrier
bool lowerClosedBeyond = close < lowerBarrier

bool upperClosedWithBuffer = close > upperConfirmLevel
bool lowerClosedWithBuffer = close < lowerConfirmLevel

bool bullishBreakoutRaw = false
bool bearishBreakoutRaw = false

if confirmationMode == "Touch Barrier"
    bullishBreakoutRaw := upperTouched
    bearishBreakoutRaw := lowerTouched
else if confirmationMode == "Close Beyond Barrier"
    bullishBreakoutRaw := upperClosedBeyond
    bearishBreakoutRaw := lowerClosedBeyond
else
    bullishBreakoutRaw := upperClosedWithBuffer
    bearishBreakoutRaw := lowerClosedWithBuffer


// ======================================================
// 7. QUALITY FILTERS
// ======================================================

float avgVolume = ta.sma(volume, volumeLookback)
float volumeRatio = avgVolume > 0.0 ? volume / avgVolume : na

bool volatilityQuality = not useVolatilityFilter or (not na(volPercentile) and volPercentile >= minimumVolPercentile)

bool volumeQuality = not useVolumeFilter or (not na(volumeRatio) and volumeRatio >= minimumVolumeRatio)

bool qualityBreakoutFilter = volatilityQuality and volumeQuality

bool bullishBreakout = bullishBreakoutRaw and qualityBreakoutFilter
bool bearishBreakout = bearishBreakoutRaw and qualityBreakoutFilter

bool bullishWeakBreakout = bullishBreakoutRaw and not qualityBreakoutFilter
bool bearishWeakBreakout = bearishBreakoutRaw and not qualityBreakoutFilter


// ======================================================
// 8. PATH-DEPENDENT STATE MACHINE
// ======================================================

var int breakoutDirection = 0
var int breakoutBarIndex = na
var float activeBarrier = na
var bool retestConfirmed = false
var bool failedBreakout = false

bool newBullishBreakout = bullishBreakout and breakoutDirection != 1
bool newBearishBreakout = bearishBreakout and breakoutDirection != -1

if newBullishBreakout
    breakoutDirection := 1
    breakoutBarIndex := bar_index
    activeBarrier := upperBarrier
    retestConfirmed := false
    failedBreakout := false

if newBearishBreakout
    breakoutDirection := -1
    breakoutBarIndex := bar_index
    activeBarrier := lowerBarrier
    retestConfirmed := false
    failedBreakout := false

int barsSinceBreakout = not na(breakoutBarIndex) ? bar_index - breakoutBarIndex : na

bool withinRetestWindow = enableRetest and not na(barsSinceBreakout) and barsSinceBreakout > 0 and barsSinceBreakout <= retestWindowBars

bool withinFailureWindow = not na(barsSinceBreakout) and barsSinceBreakout > 0 and barsSinceBreakout <= failureWindowBars

bool bullishRetestZone = breakoutDirection == 1 and withinRetestWindow and low <= activeBarrier + retestTolerance and close >= activeBarrier
bool bearishRetestZone = breakoutDirection == -1 and withinRetestWindow and high >= activeBarrier - retestTolerance and close <= activeBarrier

if bullishRetestZone
    retestConfirmed := true

if bearishRetestZone
    retestConfirmed := true

bool bullishFailure = breakoutDirection == 1 and withinFailureWindow and (requireFailureCloseBackInside ? close < activeBarrier : low < activeBarrier)
bool bearishFailure = breakoutDirection == -1 and withinFailureWindow and (requireFailureCloseBackInside ? close > activeBarrier : high > activeBarrier)

if bullishFailure or bearishFailure
    failedBreakout := true

// Reset stale state after failure window expires
if not na(barsSinceBreakout) and barsSinceBreakout > math.max(retestWindowBars, failureWindowBars)
    if failedBreakout or retestConfirmed
        breakoutDirection := 0
        breakoutBarIndex := na
        activeBarrier := na
        retestConfirmed := false
        failedBreakout := false


// ======================================================
// 9. MARKET STATE CLASSIFICATION
// ======================================================

string marketState = "NEUTRAL"
color stateColor = color.new(color.gray, 0)
int stateScore = 0

if failedBreakout and breakoutDirection == 1
    marketState := "BULLISH BARRIER FAILED"
    stateColor := color.new(color.red, 0)
    stateScore := -2
else if failedBreakout and breakoutDirection == -1
    marketState := "BEARISH BARRIER FAILED"
    stateColor := color.new(color.green, 0)
    stateScore := 2
else if retestConfirmed and breakoutDirection == 1
    marketState := "BULLISH RETEST CONFIRMED"
    stateColor := color.new(color.lime, 0)
    stateScore := 3
else if retestConfirmed and breakoutDirection == -1
    marketState := "BEARISH RETEST CONFIRMED"
    stateColor := color.new(color.maroon, 0)
    stateScore := -3
else if breakoutDirection == 1
    marketState := "BULLISH KNOCK-IN"
    stateColor := color.new(color.green, 0)
    stateScore := 2
else if breakoutDirection == -1
    marketState := "BEARISH KNOCK-IN"
    stateColor := color.new(color.red, 0)
    stateScore := -2
else if bullishWeakBreakout
    marketState := "WEAK UPPER BREACH"
    stateColor := color.new(color.orange, 0)
    stateScore := 1
else if bearishWeakBreakout
    marketState := "WEAK LOWER BREACH"
    stateColor := color.new(color.orange, 0)
    stateScore := -1
else
    marketState := "NEUTRAL"
    stateColor := color.new(color.gray, 0)
    stateScore := 0


// ======================================================
// 10. SIMPLE BARRIER HIT PROBABILITY ESTIMATE
// ======================================================

// This is a simple distance-to-barrier / expected-move approximation.
// It is not a full first-passage barrier option model.

float distanceToUpperPct = close > 0.0 ? math.max(upperBarrier - close, 0.0) / close : na
float distanceToLowerPct = close > 0.0 ? math.max(close - lowerBarrier, 0.0) / close : na

float upperHitProbabilityProxy = na
float lowerHitProbabilityProxy = na

if expectedMovePct > 0.0
    upperHitProbabilityProxy := 100.0 * math.max(0.0, math.min(1.0, 1.0 - distanceToUpperPct / (expectedMovePct * barrierSigma)))
    lowerHitProbabilityProxy := 100.0 * math.max(0.0, math.min(1.0, 1.0 - distanceToLowerPct / (expectedMovePct * barrierSigma)))


// ======================================================
// 11. PLOTS
// ======================================================

plot(showBarrierLines ? upperBarrier : na, title="Upper Barrier", color=color.new(color.green, 0), linewidth=2, style=plot.style_linebr)

plot(showBarrierLines ? lowerBarrier : na, title="Lower Barrier", color=color.new(color.red, 0), linewidth=2, style=plot.style_linebr)

plot(showBarrierLines and confirmationMode == "Close + Buffer" ? upperConfirmLevel : na, title="Upper Confirm Level", color=color.new(color.green, 65), linewidth=1, style=plot.style_linebr)

plot(showBarrierLines and confirmationMode == "Close + Buffer" ? lowerConfirmLevel : na, title="Lower Confirm Level", color=color.new(color.red, 65), linewidth=1, style=plot.style_linebr)

plot(showBarrierLines and not na(activeBarrier) ? activeBarrier : na, title="Active Barrier", color=color.new(color.white, 0), linewidth=2, style=plot.style_linebr)


// ======================================================
// 12. SIGNAL MARKERS
// ======================================================

plotshape(showSignals and newBullishBreakout, title="Bullish Barrier Knock-In", style=shape.triangleup, location=location.belowbar, color=color.new(color.green, 0), size=size.small, text="KNOCK-IN")

plotshape(showSignals and newBearishBreakout, title="Bearish Barrier Knock-In", style=shape.triangledown, location=location.abovebar, color=color.new(color.red, 0), size=size.small, text="KNOCK-IN")

plotshape(showSignals and bullishWeakBreakout, title="Weak Upper Breach", style=shape.circle, location=location.abovebar, color=color.new(color.orange, 0), size=size.tiny, text="WEAK")

plotshape(showSignals and bearishWeakBreakout, title="Weak Lower Breach", style=shape.circle, location=location.belowbar, color=color.new(color.orange, 0), size=size.tiny, text="WEAK")

plotshape(showSignals and bullishRetestZone, title="Bullish Retest Confirmed", style=shape.labelup, location=location.belowbar, color=color.new(color.lime, 0), size=size.small, text="RETEST")

plotshape(showSignals and bearishRetestZone, title="Bearish Retest Confirmed", style=shape.labeldown, location=location.abovebar, color=color.new(color.maroon, 0), size=size.small, text="RETEST")

plotshape(showSignals and bullishFailure, title="Bullish Breakout Failed", style=shape.xcross, location=location.abovebar, color=color.new(color.red, 0), size=size.small, text="FAIL")

plotshape(showSignals and bearishFailure, title="Bearish Breakout Failed", style=shape.xcross, location=location.belowbar, color=color.new(color.green, 0), size=size.small, text="FAIL")


// ======================================================
// 13. BACKGROUND STATE
// ======================================================

color bgColor = na

if showBackground
    if failedBreakout
        bgColor := color.new(color.red, 88)
    else if retestConfirmed and breakoutDirection == 1
        bgColor := color.new(color.green, 88)
    else if retestConfirmed and breakoutDirection == -1
        bgColor := color.new(color.red, 88)
    else if breakoutDirection == 1
        bgColor := color.new(color.green, 92)
    else if breakoutDirection == -1
        bgColor := color.new(color.red, 92)
    else if bullishWeakBreakout or bearishWeakBreakout
        bgColor := color.new(color.orange, 90)
    else
        bgColor := na

bgcolor(bgColor)


// ======================================================
// 14. CURRENT LABELS
// ======================================================

var label upperBarrierLabel = na
var label lowerBarrierLabel = na
var label stateLabel = na

if barstate.islast
    if not na(upperBarrierLabel)
        label.delete(upperBarrierLabel)

    if not na(lowerBarrierLabel)
        label.delete(lowerBarrierLabel)

    if not na(stateLabel)
        label.delete(stateLabel)

    if showStateLabels
        upperBarrierLabel := label.new(bar_index, upperBarrier, "Upper Barrier: " + str.tostring(upperBarrier, format.mintick), style=label.style_label_left, textcolor=color.white, color=color.new(color.green, 0))

        lowerBarrierLabel := label.new(bar_index, lowerBarrier, "Lower Barrier: " + str.tostring(lowerBarrier, format.mintick), style=label.style_label_left, textcolor=color.white, color=color.new(color.red, 0))

        stateLabel := label.new(bar_index, close, marketState, style=label.style_label_left, textcolor=color.white, color=stateColor)


// ======================================================
// 15. DASHBOARD
// ======================================================

var table dash = table.new(position.top_right, columns=2, rows=12, border_width=1)

if barstate.islast
    if showDashboard
        table.cell(dash, 0, 0, "Metric", text_color=color.white, bgcolor=color.new(color.black, 0))
        table.cell(dash, 1, 0, "Value", text_color=color.white, bgcolor=color.new(color.black, 0))

        table.cell(dash, 0, 1, "Market State", text_color=color.white, bgcolor=color.new(color.black, 20))
        table.cell(dash, 1, 1, marketState, text_color=color.white, bgcolor=stateColor)

        table.cell(dash, 0, 2, "Barrier Mode", text_color=color.white, bgcolor=color.new(color.black, 20))
        table.cell(dash, 1, 2, barrierMode, text_color=color.white, bgcolor=color.new(color.black, 20))

        table.cell(dash, 0, 3, "Upper Barrier", text_color=color.white, bgcolor=color.new(color.black, 20))
        table.cell(dash, 1, 3, str.tostring(upperBarrier, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 20))

        table.cell(dash, 0, 4, "Lower Barrier", text_color=color.white, bgcolor=color.new(color.black, 20))
        table.cell(dash, 1, 4, str.tostring(lowerBarrier, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 20))

        table.cell(dash, 0, 5, "Active Barrier", text_color=color.white, bgcolor=color.new(color.black, 20))
        table.cell(dash, 1, 5, na(activeBarrier) ? "None" : str.tostring(activeBarrier, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 20))

        table.cell(dash, 0, 6, "Bars Since Breakout", text_color=color.white, bgcolor=color.new(color.black, 20))
        table.cell(dash, 1, 6, na(barsSinceBreakout) ? "None" : str.tostring(barsSinceBreakout), text_color=color.white, bgcolor=color.new(color.black, 20))

        table.cell(dash, 0, 7, "Vol Percentile", text_color=color.white, bgcolor=color.new(color.black, 20))
        table.cell(dash, 1, 7, na(volPercentile) ? "Loading" : str.tostring(volPercentile, "#.##") + "%", text_color=color.white, bgcolor=color.new(color.black, 20))

        table.cell(dash, 0, 8, "Volume Ratio", text_color=color.white, bgcolor=color.new(color.black, 20))
        table.cell(dash, 1, 8, na(volumeRatio) ? "Loading" : str.tostring(volumeRatio, "#.##") + "x", text_color=color.white, bgcolor=color.new(color.black, 20))

        table.cell(dash, 0, 9, "Quality Filter", text_color=color.white, bgcolor=color.new(color.black, 20))
        table.cell(dash, 1, 9, qualityBreakoutFilter ? "PASS" : "FAIL", text_color=color.white, bgcolor=qualityBreakoutFilter ? color.new(color.green, 0) : color.new(color.red, 0))

        table.cell(dash, 0, 10, "P Hit Upper", text_color=color.white, bgcolor=color.new(color.black, 20))
        table.cell(dash, 1, 10, showProbabilityEstimate and not na(upperHitProbabilityProxy) ? str.tostring(upperHitProbabilityProxy, "#.##") + "%" : "Hidden", text_color=color.white, bgcolor=color.new(color.black, 20))

        table.cell(dash, 0, 11, "P Hit Lower", text_color=color.white, bgcolor=color.new(color.black, 20))
        table.cell(dash, 1, 11, showProbabilityEstimate and not na(lowerHitProbabilityProxy) ? str.tostring(lowerHitProbabilityProxy, "#.##") + "%" : "Hidden", text_color=color.white, bgcolor=color.new(color.black, 20))
    else
        table.clear(dash, 0, 0, 1, 11)


// ======================================================
// 16. ALERT CONDITIONS
// ======================================================

alertcondition(newBullishBreakout, title="Bullish Barrier Knock-In", message="Price has triggered a bullish barrier knock-in breakout.")

alertcondition(newBearishBreakout, title="Bearish Barrier Knock-In", message="Price has triggered a bearish barrier knock-in breakout.")

alertcondition(bullishWeakBreakout, title="Weak Upper Barrier Breach", message="Price breached the upper barrier, but quality filters did not pass.")

alertcondition(bearishWeakBreakout, title="Weak Lower Barrier Breach", message="Price breached the lower barrier, but quality filters did not pass.")

alertcondition(bullishRetestZone, title="Bullish Barrier Retest Confirmed", message="Price retested the upper barrier and held above it.")

alertcondition(bearishRetestZone, title="Bearish Barrier Retest Confirmed", message="Price retested the lower barrier and held below it.")

alertcondition(bullishFailure, title="Bullish Barrier Breakout Failed", message="Price failed back below the active bullish barrier.")

alertcondition(bearishFailure, title="Bearish Barrier Breakout Failed", message="Price failed back above the active bearish barrier.")
````
