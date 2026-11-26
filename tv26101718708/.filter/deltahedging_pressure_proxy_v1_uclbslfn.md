# Delta-Hedging Pressure Proxy [v1]

- url: https://www.tradingview.com/script/UClBslFN-Delta-Hedging-Pressure-Proxy-v1/
- type: indicator
- pine_id: PUB;1397a1936a194d2580b8ac699c0277eb
- version: 1.0

## Description

The Delta-Hedging Pressure Proxy is designed to estimate potential directional hedging pressure using price movement, volatility, synthetic option sensitivity, volume pressure, and volatility expansion.

This indicator does not use real dealer positioning, live options-chain data, gamma exposure, open interest, or institutional hedge-book data.

Instead, it builds a practical proxy that attempts to answer:

“Is the market behaving as if buy-side or sell-side hedging pressure is increasing?”

The indicator is intended for traders who want to understand when price action may be moving through a hedging-pressure environment, especially during fast directional moves, breakouts, volatility shocks, or post-shock cooling phases.

It can be used across FX, crypto, indices, commodities, futures, and liquid stocks.

IMPORTANT NOTE
━━━━━━━━━━━━━━━━━━━━━━

This is not real dealer hedging data.

True dealer hedging analysis requires options-chain data, strike-level open interest, implied volatility, gamma exposure, dealer positioning assumptions, expiry profiles, and sometimes intraday flow data.

TradingView does not provide all of that information across most markets.

This script therefore uses a synthetic model based on:

• Black-Scholes-style delta and gamma logic
• Realized volatility
• Synthetic strike reference
• Price movement
• Volume pressure
• Volatility expansion
• Percentile ranking

The result is a directional hedging-pressure proxy.

It should be used as a market-context tool, not as a standalone trading system.

WHAT THE INDICATOR MEASURES
━━━━━━━━━━━━━━━━━━━━━━

The indicator estimates whether recent price movement, synthetic option sensitivity, volume, and volatility expansion are creating conditions that resemble buy-side or sell-side hedging pressure.

The main output is the Delta-Hedging Pressure Score.

The score moves between negative and positive values.

Positive values suggest buy-side hedging pressure.

Negative values suggest sell-side hedging pressure.

The stronger the absolute value, the more elevated the pressure regime.

General interpretation:

• Above +75: High buy-hedging pressure
• Above +90: Extreme buy-hedging pressure
• Between -25 and +25: Low or neutral pressure
• Below -75: High sell-hedging pressure
• Below -90: Extreme sell-hedging pressure

MAIN COMPONENTS
━━━━━━━━━━━━━━━━━━━━━━

1. Synthetic Strike

The script needs a strike reference to estimate synthetic option sensitivity.

Users can select:

• ATM
• Manual
• EMA

ATM uses the current close as the synthetic strike.

Manual allows the user to enter a custom strike.

EMA uses a moving average as the synthetic strike reference.

ATM is generally best for short-term intraday analysis.

EMA can be useful for broader swing-trading context.

Manual can be useful if the trader wants to analyse a specific key price level.

2. Synthetic Option Type

The user can select either Call or Put.

This changes the synthetic delta calculation.

Call mode is usually easier to interpret for directional upside pressure.

Put mode can be useful when analysing downside hedging pressure or bearish risk conditions.

3. Realized Volatility

The script calculates realized volatility from log returns.

This volatility is used as the volatility input for the synthetic Black-Scholes-style delta and gamma calculations.

Higher volatility changes the sensitivity of the synthetic option model.

4. Synthetic Delta

Delta measures how sensitive an option’s value is to price movement.

In this proxy, delta helps estimate the directional exposure of the synthetic option reference.

A higher call delta means the synthetic option is behaving more like the underlying asset.

A lower call delta means the synthetic option is less sensitive to price movement.

5. Gamma Proxy

Gamma measures how quickly delta changes when price moves.

This is important because hedging pressure is often linked to changes in delta.

When gamma is elevated, a small move in price can create a larger change in delta.

This can increase the need for hedging activity in real options markets.

In this script, gamma is used as a pressure amplifier.

6. Price Impulse

The script measures the latest price change.

Price movement is necessary for the pressure model because delta changes when price moves.

A strong upward price impulse can contribute to buy-pressure conditions.

A strong downward price impulse can contribute to sell-pressure conditions.

7. Volume Pressure

The script compares current volume to average volume.

When volume is elevated, the model assumes that pressure conditions may be more meaningful.

If volume is low, the pressure signal is less convincing.

Users can switch volume pressure on or off.

8. Volatility Expansion Pressure

The script checks whether realized volatility is expanding relative to its recent average.

If volatility is expanding, the model increases the importance of the pressure reading.

This is useful because hedging pressure is more relevant during active or fast-moving markets than during quiet ranges.

9. Pressure Percentile

The raw pressure value is converted into a percentile rank.

This makes the output easier to interpret across different assets and timeframes.

The indicator does not only ask whether pressure is high in absolute terms.

It asks whether current pressure is high relative to the instrument’s own recent history.

HOW THE PRESSURE SCORE WORKS
━━━━━━━━━━━━━━━━━━━━━━

The script estimates pressure using the following logic:

Synthetic delta change is approximated using gamma and price movement.

That pressure is then adjusted by volume pressure and volatility expansion pressure.

The result is normalized using percentile ranking.

The final score is directional:

• Positive pressure = buy-side hedging pressure
• Negative pressure = sell-side hedging pressure
• Larger absolute value = stronger pressure regime

The score can also be smoothed to reduce noise.

HOW TO READ THE INDICATOR
━━━━━━━━━━━━━━━━━━━━━━

The main line is the Delta-Hedging Pressure Score.

Positive readings indicate buy-pressure conditions.

Negative readings indicate sell-pressure conditions.

The zero line is the neutral boundary.

Colour guide:

• Grey = Low or neutral pressure
• Blue or purple = Normal pressure
• Green = High buy pressure
• Lime = Extreme buy pressure
• Red = High sell pressure
• Maroon = Extreme sell pressure

The dashboard shows:

• Pressure Regime
• Pressure Score
• Market State
• Direction
• Synthetic Strike
• Synthetic Delta
• Gamma Proxy
• Volume Factor
• Vol Expansion
• Regime Score

Regime Score:

• 1 = Low Pressure
• 2 = Normal Pressure
• 3 = High Pressure
• 4 = Extreme Pressure

PRESSURE REGIMES
━━━━━━━━━━━━━━━━━━━━━━

Low Pressure

Low Pressure means the score is close to zero.

This suggests that the model is not detecting meaningful directional hedging pressure.

Common interpretation:

• Market may be balanced
• Pressure signal is weak
• Price action should take priority
• Avoid over-interpreting small movements

Normal Pressure

Normal Pressure means the indicator is detecting some directional pressure, but not enough to classify it as high or extreme.

Common interpretation:

• Directional pressure may be present
• Confirmation is needed from price structure
• Use with trend, support/resistance, or volatility tools

High Buy Pressure

High Buy Pressure means the score is above the high-pressure threshold.

This suggests the model is detecting strong upside pressure conditions.

Possible interpretation:

• Upside momentum may be active
• Buy-side hedging pressure may be reinforcing the move
• Breakouts may have better continuation potential
• Fading the move too early may be risky

High Sell Pressure

High Sell Pressure means the score is below the negative high-pressure threshold.

This suggests the model is detecting strong downside pressure conditions.

Possible interpretation:

• Downside momentum may be active
• Sell-side hedging pressure may be reinforcing the move
• Breakdowns may have better continuation potential
• Catching the falling knife may be risky

Extreme Buy Pressure

Extreme Buy Pressure means the score is above the extreme-pressure threshold.

This may indicate a buy-side pressure shock.

Possible interpretation:

• Strong upside repricing
• Breakout acceleration
• Stop-run or short squeeze conditions
• Momentum chase risk is elevated
• Risk controls should be tightened

Extreme Sell Pressure

Extreme Sell Pressure means the score is below the negative extreme-pressure threshold.

This may indicate a sell-side pressure shock.

Possible interpretation:

• Strong downside repricing
• Breakdown acceleration
• Long liquidation or stop cascade
• Panic selling conditions may be present
• Risk controls should be tightened

MARKET STATE DEFINITIONS
━━━━━━━━━━━━━━━━━━━━━━

Buy Hedge Expansion

Buy Hedge Expansion occurs when positive pressure is high and increasing.

This suggests upside pressure may be strengthening.

Traders may use this as confirmation that bullish momentum is being supported by pressure conditions.

Sell Hedge Expansion

Sell Hedge Expansion occurs when negative pressure is high and increasing.

This suggests downside pressure may be strengthening.

Traders may use this as confirmation that bearish momentum is being supported by pressure conditions.

Buy Hedge Shock

Buy Hedge Shock occurs when positive pressure is extreme and still increasing.

This is a high-risk upside momentum environment.

It may occur during sharp breakouts, squeeze-like moves, major news repricing, or aggressive upside continuation.

Sell Hedge Shock

Sell Hedge Shock occurs when negative pressure is extreme and still increasing.

This is a high-risk downside momentum environment.

It may occur during sharp breakdowns, liquidation events, major news repricing, or aggressive downside continuation.

Pressure Compression

Pressure Compression occurs when pressure is low and cooling.

This suggests that directional hedging pressure is weak or fading.

It can be useful when identifying quieter conditions before the next expansion phase.

Pressure Cooling

Pressure Cooling occurs when pressure was elevated but is now declining.

This may suggest that a pressure-driven move is losing force.

Cooling is not a reversal signal by itself.

It simply means the pressure phase may be easing.

Neutral

Neutral means no major pressure condition is active.

During neutral conditions, traders should rely more on price structure, trend, support/resistance, liquidity zones, or volatility context.

HOW TO USE THE INDICATOR
━━━━━━━━━━━━━━━━━━━━━━

Use the Delta-Hedging Pressure Proxy as a directional pressure filter.

It is best used to answer:

• Is pressure positive or negative?
• Is the pressure weak, high, or extreme?
• Is pressure increasing or cooling?
• Is the move supported by volume and volatility expansion?
• Should I avoid fading the move too early?
• Is the market entering a pressure shock?

It should not be used alone for entries.

The indicator provides context, not a full trade signal.

PRACTICAL TRADING WORKFLOW
━━━━━━━━━━━━━━━━━━━━━━

1. Check the Pressure Score.

Positive means buy-pressure conditions.

Negative means sell-pressure conditions.

2. Check the Pressure Regime.

Low, Normal, High, or Extreme.

3. Check Market State.

Look for Buy Hedge Expansion, Sell Hedge Expansion, Buy Hedge Shock, Sell Hedge Shock, Pressure Cooling, or Neutral.

4. Compare with price structure.

Pressure is more useful when it aligns with market structure.

For example:

• Buy pressure above resistance can support bullish breakout continuation
• Sell pressure below support can support bearish breakdown continuation
• Pressure cooling after an extended move can support an exhaustion watchlist

5. Adjust risk.

High and extreme pressure conditions are not low-risk environments.

They can offer continuation potential, but stops usually need to account for wider movement.

As pressure and volatility rise, position size should generally fall.

6. Avoid automatic reversals.

Extreme buy pressure does not mean sell.

Extreme sell pressure does not mean buy.

Extreme pressure often means the move is dangerous to fade until there is clear structural confirmation.

SUGGESTED SETTINGS
━━━━━━━━━━━━━━━━━━━━━━

FX 1-Hour

• Synthetic Strike Mode: ATM
• Option Type: Call
• Horizon Bars: 20
• Bars Per Year: 6240
• Vol Lookback: 30 to 50
• Percentile Lookback: 252
• Use Volume Pressure: True
• Use Vol Expansion: True
• Smooth Pressure Score: True
• Smoothing Length: 5

Crypto 1-Hour

• Synthetic Strike Mode: ATM
• Horizon Bars: 24
• Bars Per Year: 8760
• Vol Lookback: 50
• Percentile Lookback: 500
• Use Volume Pressure: True
• Use Vol Expansion: True
• Smooth Pressure Score: True
• Smoothing Length: 5 to 10

Daily Equities / Indices

• Synthetic Strike Mode: EMA
• EMA Strike Length: 50
• Horizon Bars: 20
• Bars Per Year: 252
• Vol Lookback: 20 to 30
• Percentile Lookback: 252
• Use Volume Pressure: True
• Use Vol Expansion: True
• Smooth Pressure Score: True
• Smoothing Length: 3 to 5

Intraday Indices

• Synthetic Strike Mode: ATM or EMA
• EMA Strike Length: 20 to 50
• Horizon Bars: 12 to 48
• Bars Per Year: adjust to timeframe
• Vol Lookback: 30 to 50
• Percentile Lookback: 252
• Use Volume Pressure: True
• Use Vol Expansion: True

SYNTHETIC STRIKE MODE GUIDE
━━━━━━━━━━━━━━━━━━━━━━

ATM

ATM uses the current close as the synthetic strike.

Best for:

• Short-term analysis
• Intraday pressure readings
• Current-market sensitivity
• Fast-moving markets

Manual

Manual allows the user to enter a custom strike.

Best for:

• Analysing a known options strike
• Testing pressure around a major price level
• Event-risk scenarios
• Key round numbers

EMA

EMA uses a moving average as the synthetic strike.

Best for:

• Swing trading
• Trend context
• Broader pressure analysis
• Smoother signals

OPTION TYPE GUIDE
━━━━━━━━━━━━━━━━━━━━━━

Call Mode

Call mode is generally better for analysing upside pressure.

Use it when you want to study bullish momentum, upside breakouts, or buy-side pressure.

Put Mode

Put mode is useful for analysing downside pressure.

Use it when you want to study bearish momentum, downside breaks, or sell-side risk.

For most general use, Call mode with ATM strike is a clean starting point.

HOW TO COMBINE WITH OTHER INDICATORS
━━━━━━━━━━━━━━━━━━━━━━

This indicator works best when combined with a broader volatility and market-structure framework.

Useful combinations:

• Expected Move Bands
• Realized Volatility Regime Indicator
• Implied Volatility Proxy
• VWAP
• Moving averages
• Support and resistance
• Liquidity zones
• Market structure breaks
• Macro and event calendars

Suggested framework:

Expected Move Bands show where price may reasonably move.

Realized Volatility Regime shows whether the market is calm, normal, active, or stressed.

IV Proxy shows whether broader uncertainty is rising or cooling.

Delta-Hedging Pressure Proxy shows whether directional pressure is leaning buy-side or sell-side.

Together, these tools help answer:

• How far can price move?
• What volatility regime are we in?
• Is uncertainty rising or cooling?
• Is directional pressure positive or negative?
• Should I trade, reduce size, wait, or avoid fading?

TRADING EXAMPLES
━━━━━━━━━━━━━━━━━━━━━━

Example 1: Buy Pressure Breakout

If the dashboard shows:

• Pressure Regime: High Buy Pressure
• Pressure Score: above +75
• Market State: Buy Hedge Expansion
• Price is breaking above resistance

This suggests upside pressure may be supporting the breakout.

A trader may look for continuation setups, pullback entries, or confirmation above the breakout level.

Example 2: Sell Pressure Breakdown

If the dashboard shows:

• Pressure Regime: High Sell Pressure
• Pressure Score: below -75
• Market State: Sell Hedge Expansion
• Price is breaking below support

This suggests downside pressure may be supporting the breakdown.

A trader may avoid catching the falling knife and instead wait for continuation or failed-retest setups.

Example 3: Buy Hedge Shock

If the dashboard shows:

• Pressure Regime: Extreme Buy Pressure
• Pressure Score: above +90
• Market State: Buy Hedge Shock

This suggests upside pressure is extreme.

The market may continue squeezing higher, but risk is elevated.

A trader should avoid over-leverage, avoid poor entries after vertical candles, and wait for structure.

Example 4: Sell Hedge Shock

If the dashboard shows:

• Pressure Regime: Extreme Sell Pressure
• Pressure Score: below -90
• Market State: Sell Hedge Shock

This suggests downside pressure is extreme.

The market may be in liquidation, panic, or aggressive repricing mode.

A trader should avoid blind dip-buying until there is evidence of stabilization.

Example 5: Pressure Cooling

If the dashboard shows:

• Pressure Regime: High or Extreme Pressure
• Direction: Falling
• Market State: Pressure Cooling

This means pressure remains elevated but is starting to fade.

A trader may monitor for failed continuation, market-structure shifts, re-entry into a range, or exhaustion setups.

Cooling is not a reversal signal by itself.

RISK MANAGEMENT NOTES
━━━━━━━━━━━━━━━━━━━━━━

This indicator is especially useful for avoiding poor trade location.

Possible applications:

• Avoid fading strong moves during pressure expansion
• Reduce position size during high or extreme pressure
• Avoid tight stops during pressure shocks
• Wait for cooling before considering mean reversion
• Use pressure alignment to confirm breakouts or breakdowns
• Use price structure, not pressure alone, for entries
• Avoid treating extreme readings as automatic reversal signals

A practical rule:

When pressure and volatility rise together, position size should generally fall.

WHAT THIS INDICATOR IS BEST FOR
━━━━━━━━━━━━━━━━━━━━━━

This indicator is best used for:

• Directional pressure context
• Breakout confirmation
• Breakdown confirmation
• Momentum continuation filtering
• Hedging-pressure approximation
• Volatility shock awareness
• Risk management
• Avoiding premature fade trades
• Trade sizing context

It is most useful when combined with price action, market structure, volatility regime, expected move levels, and macro or event awareness.

WHAT THIS INDICATOR IS NOT
━━━━━━━━━━━━━━━━━━━━━━

This indicator is not:

• Real dealer positioning
• Real options open interest analysis
• Real gamma exposure
• A dealer gamma model
• A volatility surface model
• A skew or term structure model
• A standalone trading strategy
• A buy or sell signal generator
• A guarantee of future price direction
• A replacement for risk management

The indicator estimates pressure conditions. It does not predict price direction by itself.

IMPORTANT LIMITATIONS
━━━━━━━━━━━━━━━━━━━━━━

The indicator uses price, volume, realized volatility, and synthetic option sensitivity.

It does not include:

• Real options-chain implied volatility
• Strike-level open interest
• Dealer inventory
• Market maker positioning
• Options expiry effects
• Dealer gamma exposure
• Skew
• Term structure
• Order flow
• Market depth
• News sentiment
• Fundamental data

Volume quality can also differ by asset class.

For example, centralized exchange crypto volume may behave differently from FX tick volume or futures volume.

The indicator should be treated as a pressure proxy, not a source of confirmed institutional positioning.

FINAL NOTES
━━━━━━━━━━━━━━━━━━━━━━

The Delta-Hedging Pressure Proxy helps traders think in terms of directional pressure, volatility, and risk.

Instead of asking only whether price is bullish or bearish, this tool helps answer:

• Is directional pressure positive or negative?
• Is pressure weak, high, or extreme?
• Is pressure increasing or cooling?
• Is price movement supported by volume and volatility expansion?
• Is the market in a pressure shock?
• Should I avoid fading the move too early?
• Should I reduce size or wait for structure?

The indicator is designed to improve market context, risk discipline, and volatility-aware decision making.

## Source Code

````pine
//@version=6
indicator("Delta-Hedging Pressure Proxy [v1]", "DHP", overlay=false, max_labels_count=100)

// ======================================================
// 1. USER INPUTS
// ======================================================

// --- Option proxy settings
strikeMode = input.string(
     "ATM",
     "Synthetic Strike Mode",
     options=["ATM", "Manual", "EMA"]
)

manualStrike = input.float(
     100.0,
     "Manual Strike",
     minval=0.0000001
)

strikeEmaLength = input.int(
     50,
     "EMA Strike Length",
     minval=1,
     maxval=500
)

optionType = input.string(
     "Call",
     "Synthetic Option Type",
     options=["Call", "Put"]
)

riskFreeRate = input.float(
     0.00,
     "Risk-Free Rate",
     step=0.001
)

horizonBars = input.int(
     20,
     "Synthetic Expiry Horizon in Bars",
     minval=1,
     maxval=500
)

barsPerYear = input.int(
     252,
     "Bars Per Year",
     minval=1
)

// --- Volatility settings
volLookback = input.int(
     30,
     "Realized Volatility Lookback",
     minval=5,
     maxval=500
)

percentileLookback = input.int(
     252,
     "Pressure Percentile Lookback",
     minval=20,
     maxval=1000
)

// --- Pressure model settings
useVolumePressure = input.bool(
     true,
     "Use Volume Pressure"
)

volumeLookback = input.int(
     20,
     "Volume Lookback",
     minval=5,
     maxval=500
)

useVolExpansion = input.bool(
     true,
     "Use Volatility Expansion"
)

volExpansionLookback = input.int(
     20,
     "Volatility Expansion Lookback",
     minval=5,
     maxval=500
)

smoothPressure = input.bool(
     true,
     "Smooth Pressure Score"
)

smoothLength = input.int(
     5,
     "Smoothing Length",
     minval=1,
     maxval=100
)

// --- Regime thresholds
lowPressureLevel = input.float(
     25.0,
     "Low Pressure Threshold",
     minval=0,
     maxval=100
)

highPressureLevel = input.float(
     75.0,
     "High Pressure Threshold",
     minval=0,
     maxval=100
)

extremePressureLevel = input.float(
     90.0,
     "Extreme Pressure Threshold",
     minval=0,
     maxval=100
)

// --- Display settings
showDashboard = input.bool(
     true,
     "Show Dashboard"
)

showThresholds = input.bool(
     true,
     "Show Threshold Lines"
)

showBackground = input.bool(
     true,
     "Show Pressure Background"
)

showComponents = input.bool(
     false,
     "Show Delta and Gamma Components"
)

showMarkers = input.bool(
     true,
     "Show Pressure Markers"
)


// ======================================================
// 2. HELPER FUNCTIONS
// ======================================================

f_clamp(x, minValue, maxValue) =>
    math.max(minValue, math.min(x, maxValue))

f_percent_rank(src, length) =>
    count = 0.0
    valid = 0.0

    for i = 1 to length
        if not na(src[i])
            valid += 1.0
            if src > src[i]
                count += 1.0

    valid > 0.0 ? (count / valid) * 100.0 : na

// Standard normal probability density function
f_norm_pdf(x) =>
    0.3989422804014327 * math.exp(-0.5 * x * x)

// Standard normal cumulative distribution approximation
f_norm_cdf(x) =>
    absX = math.abs(x)
    t = 1.0 / (1.0 + 0.2316419 * absX)
    d = f_norm_pdf(absX)
    prob = d * t * (
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


// ======================================================
// 3. SYNTHETIC OPTION INPUTS
// ======================================================

// Synthetic strike reference
syntheticStrike = close

if strikeMode == "Manual"
    syntheticStrike := manualStrike
else if strikeMode == "EMA"
    syntheticStrike := ta.ema(close, strikeEmaLength)
else
    syntheticStrike := close

// Time to synthetic expiry in years
timeToExpiry = math.max(horizonBars / barsPerYear, 0.000001)

// Log returns
logReturn = math.log(close / close[1])

// Realized volatility per bar
rvPerBar = ta.stdev(logReturn, volLookback)

// Annualized realized volatility
annualizedVol = rvPerBar * math.sqrt(barsPerYear)

// Safety floor for volatility
sigma = math.max(annualizedVol, 0.000001)


// ======================================================
// 4. BLACK-SCHOLES STYLE DELTA AND GAMMA PROXY
// ======================================================

d1Numerator = math.log(close / syntheticStrike) + (riskFreeRate + 0.5 * sigma * sigma) * timeToExpiry
d1Denominator = sigma * math.sqrt(timeToExpiry)
d1 = d1Numerator / d1Denominator

callDelta = f_norm_cdf(d1)
putDelta = callDelta - 1.0

syntheticDelta = optionType == "Call" ? callDelta : putDelta

gammaProxy = f_norm_pdf(d1) / (close * sigma * math.sqrt(timeToExpiry))

// Scale gamma for readability
gammaDisplay = gammaProxy * close


// ======================================================
// 5. PRESSURE COMPONENTS
// ======================================================

// Price impulse
priceChange = close - close[1]

// Volume pressure
avgVolume = ta.sma(volume, volumeLookback)
volumeRatio = avgVolume > 0.0 ? volume / avgVolume : 1.0
volumePressure = useVolumePressure ? f_clamp(volumeRatio, 0.50, 2.50) : 1.0

// Volatility expansion pressure
avgRv = ta.sma(rvPerBar, volExpansionLookback)
rvExpansionRatio = avgRv > 0.0 ? rvPerBar / avgRv : 1.0
volExpansionPressure = useVolExpansion ? f_clamp(rvExpansionRatio, 0.50, 2.50) : 1.0

// Delta change proxy
deltaChangeProxy = gammaProxy * priceChange

// Raw hedging pressure
rawPressure = deltaChangeProxy * volumePressure * volExpansionPressure

// Percentile-normalized pressure magnitude
pressureMagnitude = math.abs(rawPressure)
pressurePercentile = f_percent_rank(pressureMagnitude, percentileLookback)

// Directional pressure score from -100 to +100
rawPressureScore = rawPressure > 0.0 ? pressurePercentile : rawPressure < 0.0 ? -pressurePercentile : 0.0

pressureScore = smoothPressure ? ta.ema(rawPressureScore, smoothLength) : rawPressureScore

absPressureScore = math.abs(pressureScore)


// ======================================================
// 6. PRESSURE REGIME CLASSIFICATION
// ======================================================

string pressureRegime = "LOADING"
color pressureColor = color.new(color.gray, 0)
int pressureRegimeScore = 0

if not na(pressureScore)
    if absPressureScore < lowPressureLevel
        pressureRegime := "LOW PRESSURE"
        pressureColor := color.new(color.gray, 0)
        pressureRegimeScore := 1
    else if absPressureScore < highPressureLevel
        pressureRegime := "NORMAL PRESSURE"
        pressureColor := pressureScore >= 0.0 ? color.new(color.blue, 0) : color.new(color.purple, 0)
        pressureRegimeScore := 2
    else if absPressureScore < extremePressureLevel
        pressureRegime := pressureScore >= 0.0 ? "HIGH BUY PRESSURE" : "HIGH SELL PRESSURE"
        pressureColor := pressureScore >= 0.0 ? color.new(color.green, 0) : color.new(color.red, 0)
        pressureRegimeScore := 3
    else
        pressureRegime := pressureScore >= 0.0 ? "EXTREME BUY PRESSURE" : "EXTREME SELL PRESSURE"
        pressureColor := pressureScore >= 0.0 ? color.new(color.lime, 0) : color.new(color.maroon, 0)
        pressureRegimeScore := 4


// ======================================================
// 7. PRESSURE DIRECTION AND MARKET STATE
// ======================================================

string pressureDirection = "FLAT"
color pressureDirectionColor = color.new(color.gray, 0)

if pressureScore > pressureScore[1]
    pressureDirection := "RISING"
    pressureDirectionColor := color.new(color.green, 0)
else if pressureScore < pressureScore[1]
    pressureDirection := "FALLING"
    pressureDirectionColor := color.new(color.red, 0)

buyPressure = pressureScore > 0.0
sellPressure = pressureScore < 0.0

pressureIncreasing = absPressureScore > math.abs(pressureScore[1])
pressureCooling = absPressureScore < math.abs(pressureScore[1])

bool buyExpansion = buyPressure and pressureRegimeScore >= 3 and pressureIncreasing
bool sellExpansion = sellPressure and pressureRegimeScore >= 3 and pressureIncreasing
bool buyShock = buyPressure and pressureRegimeScore == 4 and pressureIncreasing
bool sellShock = sellPressure and pressureRegimeScore == 4 and pressureIncreasing
bool pressureCompression = pressureRegimeScore == 1 and pressureCooling
bool pressureCoolOff = pressureRegimeScore >= 3 and pressureCooling

string marketState = "NEUTRAL"
color marketStateColor = color.new(color.gray, 0)

if buyShock
    marketState := "BUY HEDGE SHOCK"
    marketStateColor := color.new(color.lime, 0)
else if sellShock
    marketState := "SELL HEDGE SHOCK"
    marketStateColor := color.new(color.maroon, 0)
else if buyExpansion
    marketState := "BUY HEDGE EXPANSION"
    marketStateColor := color.new(color.green, 0)
else if sellExpansion
    marketState := "SELL HEDGE EXPANSION"
    marketStateColor := color.new(color.red, 0)
else if pressureCompression
    marketState := "PRESSURE COMPRESSION"
    marketStateColor := color.new(color.gray, 0)
else if pressureCoolOff
    marketState := "PRESSURE COOLING"
    marketStateColor := color.new(color.blue, 0)


// ======================================================
// 8. REGIME CHANGE EVENTS
// ======================================================

enteredHighBuyPressure = pressureScore > 0.0 and pressureRegimeScore == 3 and pressureRegimeScore[1] != 3
enteredHighSellPressure = pressureScore < 0.0 and pressureRegimeScore == 3 and pressureRegimeScore[1] != 3

enteredExtremeBuyPressure = pressureScore > 0.0 and pressureRegimeScore == 4 and pressureRegimeScore[1] != 4
enteredExtremeSellPressure = pressureScore < 0.0 and pressureRegimeScore == 4 and pressureRegimeScore[1] != 4

crossedPositive = pressureScore > 0.0 and pressureScore[1] <= 0.0
crossedNegative = pressureScore < 0.0 and pressureScore[1] >= 0.0


// ======================================================
// 9. PLOTS
// ======================================================

// Main pressure score
plot(
     pressureScore,
     title="Delta-Hedging Pressure Score",
     color=pressureColor,
     linewidth=3
)

// Zero line
hline(
     0,
     title="Zero Line",
     color=color.new(color.white, 65),
     linestyle=hline.style_solid
)

// Positive thresholds
hline(
     lowPressureLevel,
     title="Positive Low Pressure",
     color=color.new(color.gray, 70),
     linestyle=hline.style_dotted,
     display=showThresholds ? display.all : display.none
)

hline(
     highPressureLevel,
     title="Positive High Pressure",
     color=color.new(color.green, 45),
     linestyle=hline.style_dotted,
     display=showThresholds ? display.all : display.none
)

hline(
     extremePressureLevel,
     title="Positive Extreme Pressure",
     color=color.new(color.lime, 35),
     linestyle=hline.style_dotted,
     display=showThresholds ? display.all : display.none
)

// Negative thresholds
hline(
     -lowPressureLevel,
     title="Negative Low Pressure",
     color=color.new(color.gray, 70),
     linestyle=hline.style_dotted,
     display=showThresholds ? display.all : display.none
)

hline(
     -highPressureLevel,
     title="Negative High Pressure",
     color=color.new(color.red, 45),
     linestyle=hline.style_dotted,
     display=showThresholds ? display.all : display.none
)

hline(
     -extremePressureLevel,
     title="Negative Extreme Pressure",
     color=color.new(color.maroon, 35),
     linestyle=hline.style_dotted,
     display=showThresholds ? display.all : display.none
)

// Optional components
plot(
     showComponents ? syntheticDelta * 100.0 : na,
     title="Synthetic Delta x100",
     color=color.new(color.aqua, 0),
     linewidth=1
)

plot(
     showComponents ? gammaDisplay * 100.0 : na,
     title="Gamma Proxy x100",
     color=color.new(color.yellow, 0),
     linewidth=1
)

plot(
     showComponents ? pressurePercentile : na,
     title="Pressure Magnitude Percentile",
     color=color.new(color.orange, 0),
     linewidth=1
)

// Background shading
color bgColor = na

if showBackground
    if buyShock
        bgColor := color.new(color.lime, 85)
    else if sellShock
        bgColor := color.new(color.red, 85)
    else if buyExpansion
        bgColor := color.new(color.green, 90)
    else if sellExpansion
        bgColor := color.new(color.maroon, 88)
    else if pressureCoolOff
        bgColor := color.new(color.blue, 90)
    else if pressureCompression
        bgColor := color.new(color.gray, 92)

bgcolor(bgColor)


// ======================================================
// 10. PRESSURE MARKERS
// ======================================================

plotshape(
     showMarkers and enteredHighBuyPressure,
     title="High Buy Hedging Pressure",
     style=shape.triangleup,
     location=location.top,
     color=color.new(color.green, 0),
     size=size.tiny,
     text="BUY"
)

plotshape(
     showMarkers and enteredHighSellPressure,
     title="High Sell Hedging Pressure",
     style=shape.triangledown,
     location=location.bottom,
     color=color.new(color.red, 0),
     size=size.tiny,
     text="SELL"
)

plotshape(
     showMarkers and enteredExtremeBuyPressure,
     title="Extreme Buy Hedging Pressure",
     style=shape.triangleup,
     location=location.top,
     color=color.new(color.lime, 0),
     size=size.small,
     text="BUY!"
)

plotshape(
     showMarkers and enteredExtremeSellPressure,
     title="Extreme Sell Hedging Pressure",
     style=shape.triangledown,
     location=location.bottom,
     color=color.new(color.maroon, 0),
     size=size.small,
     text="SELL!"
)

plotshape(
     showMarkers and crossedPositive,
     title="Pressure Crossed Positive",
     style=shape.circle,
     location=location.bottom,
     color=color.new(color.green, 0),
     size=size.tiny,
     text="+"
)

plotshape(
     showMarkers and crossedNegative,
     title="Pressure Crossed Negative",
     style=shape.circle,
     location=location.top,
     color=color.new(color.red, 0),
     size=size.tiny,
     text="-"
)


// ======================================================
// 11. DASHBOARD
// ======================================================

var table dash = table.new(
     position.top_right,
     columns=2,
     rows=11,
     border_width=1
)

if barstate.islast
    if showDashboard
        table.cell(
             dash,
             0,
             0,
             "Metric",
             text_color=color.white,
             bgcolor=color.new(color.black, 0)
        )

        table.cell(
             dash,
             1,
             0,
             "Value",
             text_color=color.white,
             bgcolor=color.new(color.black, 0)
        )

        table.cell(
             dash,
             0,
             1,
             "Pressure Regime",
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )

        table.cell(
             dash,
             1,
             1,
             pressureRegime,
             text_color=color.white,
             bgcolor=pressureColor
        )

        table.cell(
             dash,
             0,
             2,
             "Pressure Score",
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )

        table.cell(
             dash,
             1,
             2,
             na(pressureScore) ? "Loading" : str.tostring(pressureScore, "#.##"),
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )

        table.cell(
             dash,
             0,
             3,
             "Market State",
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )

        table.cell(
             dash,
             1,
             3,
             marketState,
             text_color=color.white,
             bgcolor=marketStateColor
        )

        table.cell(
             dash,
             0,
             4,
             "Direction",
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )

        table.cell(
             dash,
             1,
             4,
             pressureDirection,
             text_color=color.white,
             bgcolor=pressureDirectionColor
        )

        table.cell(
             dash,
             0,
             5,
             "Synthetic Strike",
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )

        table.cell(
             dash,
             1,
             5,
             str.tostring(syntheticStrike, format.mintick),
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )

        table.cell(
             dash,
             0,
             6,
             "Synthetic Delta",
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )

        table.cell(
             dash,
             1,
             6,
             str.tostring(syntheticDelta, "#.####"),
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )

        table.cell(
             dash,
             0,
             7,
             "Gamma Proxy",
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )

        table.cell(
             dash,
             1,
             7,
             str.tostring(gammaDisplay, "#.####"),
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )

        table.cell(
             dash,
             0,
             8,
             "Volume Factor",
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )

        table.cell(
             dash,
             1,
             8,
             str.tostring(volumePressure, "#.##"),
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )

        table.cell(
             dash,
             0,
             9,
             "Vol Expansion",
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )

        table.cell(
             dash,
             1,
             9,
             str.tostring(volExpansionPressure, "#.##"),
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )

        table.cell(
             dash,
             0,
             10,
             "Regime Score",
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )

        table.cell(
             dash,
             1,
             10,
             str.tostring(pressureRegimeScore),
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )
    else
        table.clear(dash, 0, 0, 1, 10)


// ======================================================
// 12. ALERT CONDITIONS
// ======================================================

alertcondition(
     enteredHighBuyPressure,
     title="High Buy Hedging Pressure",
     message="Delta-Hedging Pressure Proxy has entered a high buy-pressure regime."
)

alertcondition(
     enteredHighSellPressure,
     title="High Sell Hedging Pressure",
     message="Delta-Hedging Pressure Proxy has entered a high sell-pressure regime."
)

alertcondition(
     enteredExtremeBuyPressure,
     title="Extreme Buy Hedging Pressure",
     message="Delta-Hedging Pressure Proxy has entered an extreme buy-pressure regime."
)

alertcondition(
     enteredExtremeSellPressure,
     title="Extreme Sell Hedging Pressure",
     message="Delta-Hedging Pressure Proxy has entered an extreme sell-pressure regime."
)

alertcondition(
     buyShock,
     title="Buy Hedge Shock",
     message="Delta-Hedging Pressure Proxy shows buy-side hedge shock conditions."
)

alertcondition(
     sellShock,
     title="Sell Hedge Shock",
     message="Delta-Hedging Pressure Proxy shows sell-side hedge shock conditions."
)

alertcondition(
     pressureCompression,
     title="Pressure Compression",
     message="Delta-Hedging Pressure Proxy shows low and cooling pressure conditions."
)

alertcondition(
     pressureCoolOff,
     title="Pressure Cooling",
     message="Delta-Hedging Pressure Proxy shows elevated pressure that is starting to cool."
)

alertcondition(
     crossedPositive,
     title="Pressure Crossed Positive",
     message="Delta-Hedging Pressure Proxy crossed from negative to positive."
)

alertcondition(
     crossedNegative,
     title="Pressure Crossed Negative",
     message="Delta-Hedging Pressure Proxy crossed from positive to negative."
)
````
