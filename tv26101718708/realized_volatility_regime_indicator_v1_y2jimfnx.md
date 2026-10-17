# Realized Volatility Regime Indicator [v1]

- url: https://www.tradingview.com/script/Y2jiMFnx-Realized-Volatility-Regime-Indicator-v1/
- type: indicator
- pine_id: PUB;e79eaae8dc034d60a1c22062d437db9d
- version: 1.0

## Description

Realised Volatility Regime Indicator

The Realised Volatility Regime Indicator is designed to help traders understand the current volatility environment of a market.

This is not a buy or sell signal indicator. It is a volatility regime filter that helps traders decide whether the market is in a low, normal, high, or extreme volatility state.

The indicator is useful for identifying whether conditions are better suited to breakout preparation, normal trading, momentum continuation, volatility shock management, or post-shock cooling.

It can be used across FX, crypto, indices, commodities, futures, and liquid stocks.

━━━━━━━━━━━━━━━━━━━━━━
WHAT THE INDICATOR MEASURES
━━━━━━━━━━━━━━━━━━━━━━

The indicator calculates realized volatility from recent price changes using log returns.

It then annualizes that volatility and compares the current reading to its own historical range using percentile ranking.

This allows the indicator to classify volatility relative to the asset’s own recent behaviour.

For example, EUR/USD and Bitcoin naturally have different volatility profiles. Instead of comparing raw volatility values, this indicator asks:

“Is current volatility high or low relative to this market’s own recent history?”

That makes the tool more adaptive across different asset classes and timeframes.

━━━━━━━━━━━━━━━━━━━━━━
MAIN COMPONENTS
━━━━━━━━━━━━━━━━━━━━━━

1. Realised Volatility

Realised volatility measures how much the price has actually moved over a selected lookback period.

Higher realised volatility means the price has been moving more aggressively.

Lower realised volatility means the price has been more compressed.

2. Annualised Realised Volatility

The indicator converts per-bar volatility into an annualised volatility value using the Bars Per Year input.

Suggested Bars Per Year settings:

• Daily FX / indices: 252
• Daily crypto: 365
• 1-hour FX: approximately 6240
• 1-hour crypto: approximately 8760

The annualised volatility value is shown in the dashboard.

3. Volatility Percentile

The volatility percentile is the main plotted line.

It shows where current realised volatility ranks compared to recent historical volatility.

General interpretation:

• 0–25%: Low volatility
• 25–75%: Normal volatility
• 75–90%: High volatility
• Above 90%: Extreme volatility

The percentile method is more adaptive than using fixed volatility levels.

4. Volatility Direction

The indicator also shows whether volatility is:

• Expanding
• Contracting
• Flat

This matters because high volatility with expansion is different from high volatility with contraction.

For example:

• High volatility + expanding = momentum conditions may be active
• High volatility + contracting = cooling or exhaustion may be developing
• Low volatility + contracting = compression may be building

5. Market State

The dashboard classifies the market into one of the following states:

• Compression
• Expansion
• Vol Shock
• Cooling
• Neutral

These states are designed to provide a quick summary of the current volatility environment.

━━━━━━━━━━━━━━━━━━━━━━
VOLATILITY REGIMES
━━━━━━━━━━━━━━━━━━━━━━

Low Vol

Low Vol means volatility is compressed relative to recent history.

This can suggest:

• Quiet market conditions
• Narrower price ranges
• Lower realized movement
• Breakout risk may be building

Low volatility does not predict direction. It only tells the trader that the market is compressed.

Common use cases:

• Prepare for breakout setups
• Monitor range boundaries
• Avoid forcing trades inside tight ranges
• Wait for volatility expansion confirmation

Normal Vol

Normal Vol means volatility is within its average historical range.

This is usually the most balanced environment.

Common use cases:

• Standard position sizing
• Normal stop placement
• Trend or range trading depending on price structure
• Standard technical confirmation

High Vol

High Vol means volatility is elevated relative to recent history.

This can indicate:

• Stronger directional movement
• Wider ranges
• Higher uncertainty
• Greater stop-loss risk
• Better momentum conditions

Common use cases:

• Reduce position size
• Use wider stops
• Avoid tight entries
• Look for continuation if volatility is still expanding
• Avoid fading strong moves too early

Extreme Vol

Extreme Vol means volatility is in the upper range of its recent history.

This often appears around:

• Central bank decisions
• CPI / inflation data
• NFP or labour market data
• Earnings shocks
• Geopolitical events
• Crypto liquidation cascades
• Flash crashes
• Major breakouts or breakdowns

Common use cases:

• Reduce exposure
• Avoid excessive leverage
• Avoid chasing large candles
• Wait for structure to stabilize
• Watch for cooling before considering mean reversion

Extreme volatility is not automatically a reversal signal. Markets can remain extreme for longer than expected.

━━━━━━━━━━━━━━━━━━━━━━
MARKET STATE DEFINITIONS
━━━━━━━━━━━━━━━━━━━━━━

Compression

Compression occurs when volatility is low and still falling.

This may indicate that the market is coiling before a larger move, but it does not predict direction.

Use compression to prepare, not to predict.

Expansion

Expansion occurs when volatility is high and rising.

This may support breakout or momentum conditions.

In expansion regimes, traders should be careful about fading strong directional moves too early.

Vol Shock

Vol Shock occurs when volatility is extreme and still rising.

This is a high-risk environment.

It may reflect:

• News repricing
• Panic movement
• Liquidation pressure
• Stop cascades
• Forced positioning adjustment
• Macro repricing

During Vol Shock conditions, risk control is more important than signal chasing.

Cooling

Cooling occurs when volatility is still elevated but has started to contract.

This may suggest the initial shock or momentum burst is slowing.

Cooling is not a reversal signal by itself. It simply means volatility pressure is easing.

Better reversal confirmation may require:

• Failed continuation
• Break of short-term structure
• Return inside a prior range
• Reclaim of a key moving average
• Re-entry after an extreme move

Neutral

Neutral means there is no strong volatility condition.

In this state, traders should rely more heavily on price structure, trend, support/resistance, and normal trade rules.

━━━━━━━━━━━━━━━━━━━━━━
HOW TO READ THE INDICATOR
━━━━━━━━━━━━━━━━━━━━━━

The main line is the volatility percentile.

Colour guide:

• Green = Low Vol
• Blue = Normal Vol
• Orange = High Vol
• Red = Extreme Vol

The dashboard shows:

• Vol Regime
• Annualized Realized Volatility
• Volatility Percentile
• Vol Direction
• Regime Score
• Market State

Regime Score:

• 1 = Low Vol
• 2 = Normal Vol
• 3 = High Vol
• 4 = Extreme Vol

━━━━━━━━━━━━━━━━━━━━━━
HOW TO USE THE INDICATOR
━━━━━━━━━━━━━━━━━━━━━━

Use this indicator as a regime filter.

The main purpose is to help decide what type of trading approach is better suited to current market conditions.

Suggested interpretation:

• Low Vol + Compression: prepare for breakout, but wait for direction
• Normal Vol: use standard technical trading rules
• High Vol + Expansion: momentum continuation may be more likely
• Extreme Vol + Vol Shock: reduce size and avoid chasing
• High / Extreme Vol + Cooling: monitor for exhaustion or mean-reversion confirmation

The indicator should not be used as a standalone signal. Volatility tells you about the trading environment, not direction.

━━━━━━━━━━━━━━━━━━━━━━
PRACTICAL TRADING WORKFLOW
━━━━━━━━━━━━━━━━━━━━━━

1. Identify the current volatility regime.

Check whether the market is in Low Vol, Normal Vol, High Vol, or Extreme Vol.

2. Check volatility direction.

Is volatility expanding, contracting, or flat?

3. Match the strategy to the regime.

Low volatility may favour breakout preparation.

High volatility may favour momentum continuation.

Extreme volatility may require defensive risk management.

Cooling may support watching for failed continuation or exhaustion.

4. Adjust risk.

As volatility rises, position size should generally fall.

High volatility regimes often require wider stops and smaller size.

5. Use price structure for entries.

Do not enter trades based only on volatility.

Use support/resistance, trend, market structure, liquidity zones, or other confirmation.

━━━━━━━━━━━━━━━━━━━━━━
SUGGESTED SETTINGS
━━━━━━━━━━━━━━━━━━━━━━

FX 1-Hour

• Realized Volatility Lookback: 30 to 50
• Bars Per Year: 6240
• Volatility Percentile Lookback: 252
• Smooth Volatility: True
• Smoothing Length: 5

Daily FX / Indices

• Realized Volatility Lookback: 20 to 30
• Bars Per Year: 252
• Volatility Percentile Lookback: 252
• Smooth Volatility: True
• Smoothing Length: 3 to 5

Crypto 1-Hour

• Realized Volatility Lookback: 50
• Bars Per Year: 8760
• Volatility Percentile Lookback: 500
• Smooth Volatility: True
• Smoothing Length: 5 to 10

Daily Crypto

• Realized Volatility Lookback: 20 to 30
• Bars Per Year: 365
• Volatility Percentile Lookback: 365
• Smooth Volatility: True
• Smoothing Length: 3 to 5

━━━━━━━━━━━━━━━━━━━━━━
HOW TO COMBINE WITH EXPECTED MOVE BANDS
━━━━━━━━━━━━━━━━━━━━━━

This indicator pairs well with an expected-move projection indicator.

The Realized Volatility Regime Indicator tells you what volatility environment the market is in.

Expected Move Bands tell you where price may reasonably move over a selected horizon.

Suggested combined framework:

• Low Vol / Compression: expected move bands may be narrow; breakout risk may be building
• Normal Vol: use 1σ and 2σ expected move levels normally
• High Vol / Expansion: momentum continuation may be more likely
• Extreme Vol / Shock: reduce size and avoid chasing into extreme levels
• High or Extreme Vol Cooling: watch for re-entry, exhaustion, or failed continuation

━━━━━━━━━━━━━━━━━━━━━━
EXAMPLES
━━━━━━━━━━━━━━━━━━━━━━

Example 1: Low Volatility Compression

If the dashboard shows:

• Vol Regime: Low Vol
• Vol Direction: Contracting
• Market State: Compression

This means the market is quiet and compressed.

A trader may prepare breakout alerts above resistance and below support, but should wait for price confirmation.

Example 2: High Volatility Expansion

If the dashboard shows:

• Vol Regime: High Vol
• Vol Direction: Expanding
• Market State: Expansion

This means volatility is rising and momentum conditions may be active.

A trader may favour continuation setups, avoid tight stops, and avoid fading strong moves too early.

Example 3: Extreme Volatility Shock

If the dashboard shows:

• Vol Regime: Extreme Vol
• Vol Direction: Expanding
• Market State: Vol Shock

This means the market is in a stress condition.

A trader may reduce exposure, avoid over-leverage, and wait for stabilization before entering new trades.

Example 4: Extreme Volatility Cooling

If the dashboard shows:

• Vol Regime: Extreme Vol
• Vol Direction: Contracting
• Market State: Cooling

This means volatility remains elevated, but the shock is starting to fade.

A trader may monitor for failed continuation or mean-reversion confirmation, but should not assume an automatic reversal.

━━━━━━━━━━━━━━━━━━━━━━
RISK MANAGEMENT NOTES
━━━━━━━━━━━━━━━━━━━━━━

This indicator is especially useful for risk adjustment.

Possible applications:

• Reduce size during High Vol and Extreme Vol regimes
• Avoid tight stops when volatility is expanding
• Avoid over-targeting trades when volatility is compressed
• Use wider stops only if position size is reduced
• Avoid fading extreme moves without confirmation
• Use compression regimes to prepare, not predict
• Use cooling regimes to monitor possible exhaustion

A practical rule:

As volatility rises, position size should generally fall.

━━━━━━━━━━━━━━━━━━━━━━
WHAT THIS INDICATOR IS BEST FOR
━━━━━━━━━━━━━━━━━━━━━━

This indicator is best used for:

• Volatility regime detection
• Market environment filtering
• Risk management
• Breakout preparation
• Momentum confirmation
• Volatility shock detection
• Strategy selection
• Trade sizing context

It is most useful when combined with price action, market structure, support/resistance, trend filters, and macro or event awareness.

━━━━━━━━━━━━━━━━━━━━━━
WHAT THIS INDICATOR IS NOT
━━━━━━━━━━━━━━━━━━━━━━

This indicator is not:

• A standalone trading strategy
• A buy/sell signal generator
• A prediction model
• A guarantee of future volatility
• A replacement for risk management
• A complete trading system

Volatility describes the market environment. It does not tell you direction by itself.

━━━━━━━━━━━━━━━━━━━━━━
IMPORTANT LIMITATIONS
━━━━━━━━━━━━━━━━━━━━━━

The indicator uses historical realized volatility. It does not know future volatility.

Volatility can change rapidly after:

• Economic data releases
• Central bank decisions
• Earnings reports
• Geopolitical events
• Liquidity shocks
• Crypto liquidation cascades
• Market open or close effects

The indicator does not include:

• Options implied volatility
• Order flow
• Market depth
• Positioning data
• Fundamental data
• News sentiment
• Liquidity conditions

Use it as a decision-support tool, not as a standalone trading system.

━━━━━━━━━━━━━━━━━━━━━━
FINAL NOTES
━━━━━━━━━━━━━━━━━━━━━━

The Realized Volatility Regime Indicator helps traders think in terms of volatility, risk, and regime.

Instead of asking only whether price is bullish or bearish, this tool helps answer:

• Is the market quiet or active?
• Is volatility rising or falling?
• Is the market compressed or expanding?
• Is the current move part of a volatility shock?
• Should I use normal size, reduce size, or wait?
• Is this environment better for breakout, momentum, range, or defensive trading?

The indicator is designed to improve trade context and risk discipline.

## Source Code

````pine
//@version=6
indicator(
     title="Realized Volatility Regime Indicator [v1]",
     shorttitle="RV Regime",
     overlay=false,
     max_labels_count=100
)

// ======================================================
// 1. USER INPUTS
// ======================================================

// --- Volatility settings
volLookback = input.int(
     30,
     "Realized Volatility Lookback",
     minval=5,
     maxval=500
)

barsPerYear = input.int(
     252,
     "Bars Per Year",
     minval=1
)

smoothVol = input.bool(
     true,
     "Smooth Realized Volatility"
)

smoothLength = input.int(
     5,
     "Smoothing Length",
     minval=1,
     maxval=100
)

// --- Percentile settings
percentileLength = input.int(
     252,
     "Volatility Percentile Lookback",
     minval=20,
     maxval=1000
)

lowVolLevel = input.float(
     25.0,
     "Low Vol Threshold",
     minval=0,
     maxval=100
)

highVolLevel = input.float(
     75.0,
     "High Vol Threshold",
     minval=0,
     maxval=100
)

extremeVolLevel = input.float(
     90.0,
     "Extreme Vol Threshold",
     minval=0,
     maxval=100
)

// --- Display settings
showDashboard = input.bool(
     true,
     "Show Dashboard"
)

showBackground = input.bool(
     true,
     "Show Regime Background"
)

showRegimeMarkers = input.bool(
     true,
     "Show Regime Change Markers"
)

showThresholds = input.bool(
     true,
     "Show Threshold Lines"
)

showAnnualizedVol = input.bool(
     false,
     "Show Annualized RV Line"
)


// ======================================================
// 2. REALIZED VOLATILITY CALCULATION
// ======================================================

// Log return
logReturn = math.log(close / close[1])

// Raw realized volatility per bar
rvRaw = ta.stdev(logReturn, volLookback)

// Optional smoothing
rvPerBar = smoothVol ? ta.ema(rvRaw, smoothLength) : rvRaw

// Annualized realized volatility
annualizedVol = rvPerBar * math.sqrt(barsPerYear)

// Annualized volatility as percentage
annualizedVolPct = annualizedVol * 100.0


// ======================================================
// 3. PERCENTILE RANK FUNCTION
// ======================================================

f_percent_rank(src, length) =>
    count = 0.0
    valid = 0.0

    for i = 1 to length
        if not na(src[i])
            valid += 1.0
            if src > src[i]
                count += 1.0

    valid > 0.0 ? (count / valid) * 100.0 : na

volPercentile = f_percent_rank(annualizedVol, percentileLength)


// ======================================================
// 4. REGIME CLASSIFICATION
// ======================================================

string volRegime = "LOADING"
color regimeColor = color.new(color.gray, 0)
int regimeScore = 0

if not na(volPercentile)
    if volPercentile < lowVolLevel
        volRegime := "LOW VOL"
        regimeColor := color.new(color.green, 0)
        regimeScore := 1
    else if volPercentile < highVolLevel
        volRegime := "NORMAL VOL"
        regimeColor := color.new(color.blue, 0)
        regimeScore := 2
    else if volPercentile < extremeVolLevel
        volRegime := "HIGH VOL"
        regimeColor := color.new(color.orange, 0)
        regimeScore := 3
    else
        volRegime := "EXTREME VOL"
        regimeColor := color.new(color.red, 0)
        regimeScore := 4


// ======================================================
// 5. VOLATILITY DIRECTION
// ======================================================

string volDirection = "FLAT"
color volDirectionColor = color.new(color.gray, 0)

if annualizedVol > annualizedVol[1]
    volDirection := "EXPANDING"
    volDirectionColor := color.new(color.orange, 0)
else if annualizedVol < annualizedVol[1]
    volDirection := "CONTRACTING"
    volDirectionColor := color.new(color.blue, 0)


// ======================================================
// 6. MARKET STATE CLASSIFICATION
// ======================================================

bool isCompression = regimeScore == 1 and annualizedVol < annualizedVol[1]
bool isExpansion = regimeScore >= 3 and annualizedVol > annualizedVol[1]
bool isVolShock = regimeScore == 4 and annualizedVol > annualizedVol[1]
bool isCooling = regimeScore >= 3 and annualizedVol < annualizedVol[1]

string marketState = "NEUTRAL"
color marketStateColor = color.new(color.gray, 0)

if isVolShock
    marketState := "VOL SHOCK"
    marketStateColor := color.new(color.red, 0)
else if isExpansion
    marketState := "EXPANSION"
    marketStateColor := color.new(color.orange, 0)
else if isCompression
    marketState := "COMPRESSION"
    marketStateColor := color.new(color.green, 0)
else if isCooling
    marketState := "COOLING"
    marketStateColor := color.new(color.blue, 0)


// ======================================================
// 7. REGIME CHANGE EVENTS
// ======================================================

enteredLowVol = regimeScore == 1 and regimeScore[1] != 1
enteredNormalVol = regimeScore == 2 and regimeScore[1] != 2
enteredHighVol = regimeScore == 3 and regimeScore[1] != 3
enteredExtremeVol = regimeScore == 4 and regimeScore[1] != 4


// ======================================================
// 8. PLOTS
// ======================================================

// Main volatility percentile plot
plot(
     volPercentile,
     title="Volatility Percentile",
     color=regimeColor,
     linewidth=3
)

// Optional annualized RV plot
plot(
     showAnnualizedVol ? annualizedVolPct : na,
     title="Annualized Realized Volatility %",
     color=color.new(color.white, 0),
     linewidth=2
)

// Threshold lines
hline(
     lowVolLevel,
     title="Low Vol Threshold",
     color=color.new(color.green, 45),
     linestyle=hline.style_dotted,
     display=showThresholds ? display.all : display.none
)

hline(
     highVolLevel,
     title="High Vol Threshold",
     color=color.new(color.orange, 45),
     linestyle=hline.style_dotted,
     display=showThresholds ? display.all : display.none
)

hline(
     extremeVolLevel,
     title="Extreme Vol Threshold",
     color=color.new(color.red, 45),
     linestyle=hline.style_dotted,
     display=showThresholds ? display.all : display.none
)

hline(
     50,
     title="Midline",
     color=color.new(color.gray, 75),
     linestyle=hline.style_dotted,
     display=showThresholds ? display.all : display.none
)

// Regime background color
color bgColor = na

if showBackground
    if regimeScore == 1
        bgColor := color.new(color.green, 90)
    else if regimeScore == 2
        bgColor := color.new(color.blue, 92)
    else if regimeScore == 3
        bgColor := color.new(color.orange, 90)
    else if regimeScore == 4
        bgColor := color.new(color.red, 88)

bgcolor(bgColor)


// ======================================================
// 9. REGIME MARKERS
// ======================================================

plotshape(
     showRegimeMarkers and enteredLowVol,
     title="Entered Low Vol",
     style=shape.circle,
     location=location.bottom,
     color=color.new(color.green, 0),
     size=size.tiny,
     text="LOW"
)

plotshape(
     showRegimeMarkers and enteredHighVol,
     title="Entered High Vol",
     style=shape.triangleup,
     location=location.top,
     color=color.new(color.orange, 0),
     size=size.tiny,
     text="HIGH"
)

plotshape(
     showRegimeMarkers and enteredExtremeVol,
     title="Entered Extreme Vol",
     style=shape.triangleup,
     location=location.top,
     color=color.new(color.red, 0),
     size=size.small,
     text="EXT"
)

plotshape(
     showRegimeMarkers and enteredNormalVol,
     title="Entered Normal Vol",
     style=shape.circle,
     location=location.bottom,
     color=color.new(color.blue, 0),
     size=size.tiny,
     text="NORM"
)


// ======================================================
// 10. DASHBOARD
// ======================================================

var table dash = table.new(
     position.top_right,
     columns=2,
     rows=7,
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
             "Vol Regime",
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )

        table.cell(
             dash,
             1,
             1,
             volRegime,
             text_color=color.white,
             bgcolor=regimeColor
        )

        table.cell(
             dash,
             0,
             2,
             "RV Annualized",
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )

        table.cell(
             dash,
             1,
             2,
             str.tostring(annualizedVolPct, "#.##") + "%",
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )

        table.cell(
             dash,
             0,
             3,
             "Vol Percentile",
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )

        table.cell(
             dash,
             1,
             3,
             na(volPercentile) ? "Loading" : str.tostring(volPercentile, "#.##") + "%",
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )

        table.cell(
             dash,
             0,
             4,
             "Vol Direction",
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )

        table.cell(
             dash,
             1,
             4,
             volDirection,
             text_color=color.white,
             bgcolor=volDirectionColor
        )

        table.cell(
             dash,
             0,
             5,
             "Regime Score",
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )

        table.cell(
             dash,
             1,
             5,
             str.tostring(regimeScore),
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )

        table.cell(
             dash,
             0,
             6,
             "Market State",
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )

        table.cell(
             dash,
             1,
             6,
             marketState,
             text_color=color.white,
             bgcolor=marketStateColor
        )
    else
        table.clear(dash, 0, 0, 1, 6)


// ======================================================
// 11. ALERT CONDITIONS
// ======================================================

alertcondition(
     enteredLowVol,
     title="Entered Low Volatility Regime",
     message="Realized volatility has entered a low-volatility regime."
)

alertcondition(
     enteredNormalVol,
     title="Entered Normal Volatility Regime",
     message="Realized volatility has entered a normal-volatility regime."
)

alertcondition(
     enteredHighVol,
     title="Entered High Volatility Regime",
     message="Realized volatility has entered a high-volatility regime."
)

alertcondition(
     enteredExtremeVol,
     title="Entered Extreme Volatility Regime",
     message="Realized volatility has entered an extreme-volatility regime."
)

alertcondition(
     isCompression,
     title="Volatility Compression",
     message="Realized volatility is low and contracting. Breakout risk may be building."
)

alertcondition(
     isExpansion,
     title="Volatility Expansion",
     message="Realized volatility is high and expanding. Momentum conditions may be active."
)

alertcondition(
     isVolShock,
     title="Volatility Shock",
     message="Realized volatility is in an extreme percentile and still expanding."
)

alertcondition(
     isCooling,
     title="High Volatility Cooling",
     message="Volatility is elevated but contracting. Exhaustion or normalization may be developing."
)
````
