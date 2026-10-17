# Implied Volatility Proxy Indicator [v1]

- url: https://www.tradingview.com/script/K9ARd45X-Implied-Volatility-Proxy-Indicator-v1/
- type: indicator
- pine_id: PUB;c1e64938cede42459ee2b58728f01787
- version: 1.0

## Description

Implied Volatility Proxy Indicator

The Implied Volatility Proxy Indicator is designed to estimate market uncertainty when true options-chain implied volatility data is not available.

This indicator does not use real implied volatility from listed options. Instead, it creates an IV-style proxy using a composite score built from realized volatility, ATR volatility, range expansion, volatility compression, and percentile ranking.

The goal is to help traders understand whether the market is behaving as if forward uncertainty is rising, falling, compressed, or entering a shock regime.

This is not a buy or sell signal indicator. It is a volatility and uncertainty regime tool.

It can be used across FX, crypto, indices, commodities, futures, and liquid stocks.

WHAT THE INDICATOR MEASURES
━━━━━━━━━━━━━━━━━━━━━━

True implied volatility comes from option prices and reflects the market’s expectation of future volatility.

However, many TradingView instruments do not provide clean or accessible options-chain implied volatility.

This indicator solves that problem by building a practical proxy from price behaviour.

It asks:

“Is the market behaving as if uncertainty is rising or falling?”

To answer that, the script combines three main components:

• Realized volatility
• ATR volatility
• Range expansion

Each component is converted into a percentile rank, then blended into a single IV Proxy Score from 0 to 100.

MAIN COMPONENTS
━━━━━━━━━━━━━━━━━━━━━━

1. Realized Volatility Component

Realized volatility measures how much price has actually moved over a selected lookback period.

The script calculates log returns and then applies a rolling standard deviation.

Higher realized volatility means price has been moving more aggressively.

Lower realized volatility means price has been more compressed.

2. ATR Volatility Component

ATR measures the average trading range of the asset.

The script converts ATR into a percentage of price and annualizes it using the selected Bars Per Year input.

This helps capture broader range-based volatility that may not be fully reflected in close-to-close returns.

3. Range Expansion Component

Range expansion measures whether the current candle range is large relative to its recent average range.

This helps identify sudden bursts in price movement.

A large current candle range compared to recent range may indicate a volatility impulse, stop-run, news repricing, liquidation event, or breakout attempt.

4. Percentile Ranking

Each component is ranked against its own recent history.

The indicator does not simply ask whether volatility is high in absolute terms.

It asks whether volatility is high relative to the instrument’s own recent behaviour.

This makes the indicator more adaptive across different assets.

5. Composite IV Proxy Score

The final IV Proxy Score is a weighted blend of the three component percentiles.

Default weighting:

• Realized Volatility: 40%
• ATR Volatility: 30%
• Range Expansion: 30%

Users can adjust these weights in the settings.

WHAT THE IV PROXY SCORE MEANS
━━━━━━━━━━━━━━━━━━━━━━

The IV Proxy Score ranges from 0 to 100.

General interpretation:

• 0–25: Low IV Proxy
• 25–75: Normal IV Proxy
• 75–90: High IV Proxy
• 90–100: Extreme IV Proxy

A low score suggests compressed uncertainty.

A high score suggests elevated uncertainty.

An extreme score suggests shock-like market conditions.

IMPORTANT NOTE
━━━━━━━━━━━━━━━━━━━━━━

This is not true options implied volatility.

It is a price-derived proxy designed to approximate uncertainty regimes when actual implied volatility data is unavailable.

It should not be used as a substitute for options-chain IV, skew, term structure, dealer gamma, or volatility surface analysis.

It is best used as a practical trading filter for volatility-sensitive decision making.

HOW TO READ THE INDICATOR
━━━━━━━━━━━━━━━━━━━━━━

The main plotted line is the IV Proxy Score.

The line changes colour depending on the regime.

Colour guide:

• Green = Low IV Proxy
• Blue = Normal IV Proxy
• Orange = High IV Proxy
• Red = Extreme IV Proxy

The dashboard shows:

• IV Proxy Regime
• IV Proxy Score
• IV Direction
• Market State
• Realized Volatility Component
• ATR Component
• Range Expansion Component
• Regime Score

Regime Score:

• 1 = Low IV Proxy
• 2 = Normal IV Proxy
• 3 = High IV Proxy
• 4 = Extreme IV Proxy

IV PROXY REGIMES
━━━━━━━━━━━━━━━━━━━━━━

Low IV Proxy

Low IV Proxy means the market is relatively compressed.

This can suggest:

• Lower price movement
• Narrower trading ranges
• Reduced uncertainty
• Potential breakout risk building

Low IV Proxy does not forecast direction. It only indicates that uncertainty is low relative to recent history.

Common use cases:

• Prepare for breakout setups
• Watch key support and resistance
• Avoid over-targeting trades
• Wait for volatility expansion confirmation

Normal IV Proxy

Normal IV Proxy means uncertainty is balanced relative to recent history.

This is usually a cleaner environment for normal trade execution.

Common use cases:

• Standard trade sizing
• Normal technical analysis
• Trend or range trading depending on price structure
• Standard stop and target logic

High IV Proxy

High IV Proxy means uncertainty is elevated.

This can indicate that the market is becoming more active and riskier.

Common use cases:

• Reduce position size
• Use wider stops if trading
• Avoid tight entries
• Favour momentum continuation if the score is rising
• Avoid fading strong moves too early

Extreme IV Proxy

Extreme IV Proxy means the market is in a stress or shock-like uncertainty regime.

This can appear during:

• Economic data releases
• Central bank decisions
• Earnings shocks
• Geopolitical events
• Crypto liquidation cascades
• Major breakouts or breakdowns
• Panic repricing
• Liquidity shocks

Common use cases:

• Reduce exposure
• Avoid over-leverage
• Avoid chasing large candles
• Wait for stabilization
• Watch for cooling before considering reversal trades

Extreme IV Proxy is not automatically a reversal signal. Markets can remain extreme for longer than expected.

MARKET STATE DEFINITIONS
━━━━━━━━━━━━━━━━━━━━━━

IV Compression

IV Compression occurs when the IV Proxy Score is low and still falling.

This may indicate that the market is becoming increasingly quiet.

Compression can be useful for preparing breakout alerts, but it does not predict direction.

Use compression as a preparation signal, not a trade entry signal.

IV Expansion

IV Expansion occurs when the IV Proxy Score is high and rising.

This suggests that uncertainty is increasing.

Expansion may support:

• Breakouts
• Momentum continuation
• Wider expected ranges
• Higher-risk trade conditions

In IV Expansion, traders should be careful about fading strong directional moves too early.

IV Shock

IV Shock occurs when the IV Proxy Score is extreme and still rising.

This is the highest-risk state.

It may indicate:

• News repricing
• Panic movement
• Liquidation pressure
• Stop cascades
• Forced positioning adjustment
• Macro repricing
• Major volatility impulse

During IV Shock conditions, risk management should take priority.

IV Cooling

IV Cooling occurs when the IV Proxy Score is high or extreme but falling.

This suggests that uncertainty remains elevated, but pressure is starting to ease.

Cooling is not a reversal signal by itself.

It may support monitoring for:

• Failed continuation
• Re-entry after an extreme move
• Mean-reversion confirmation
• Break of short-term structure
• Return inside a prior range

Neutral

Neutral means no major uncertainty condition is active.

In this state, traders should rely more heavily on price structure, trend, support/resistance, liquidity levels, and standard trade rules.

HOW TO USE THE INDICATOR
━━━━━━━━━━━━━━━━━━━━━━

Use the indicator as an uncertainty and volatility filter.

The main purpose is to help decide whether current market conditions favour:

• Breakout preparation
• Normal trading
• Momentum continuation
• Defensive risk management
• Cooling or exhaustion monitoring

The indicator should not be used alone for trade entries.

It tells you about the volatility environment, not price direction.

PRACTICAL TRADING WORKFLOW
━━━━━━━━━━━━━━━━━━━━━━

1. Check the IV Proxy Regime.

Determine whether the market is in Low, Normal, High, or Extreme IV Proxy.

2. Check IV Direction.

Is the score rising, falling, or flat?

3. Check Market State.

The dashboard will classify the environment as Compression, Expansion, IV Shock, Cooling, or Neutral.

4. Match the strategy to the regime.

Low and falling IV Proxy may favour breakout preparation.

High and rising IV Proxy may favour momentum continuation.

Extreme and rising IV Proxy may require defensive risk management.

High or extreme but falling IV Proxy may support watching for failed continuation or exhaustion.

5. Adjust risk.

As uncertainty rises, position size should generally fall.

High uncertainty regimes usually require wider stops and smaller size.

6. Use price structure for execution.

Do not enter trades from the IV Proxy alone.

Use trend, support/resistance, liquidity, market structure, expected move levels, or macro context for actual entries.

SUGGESTED SETTINGS
━━━━━━━━━━━━━━━━━━━━━━

FX 1-Hour

• Realized Volatility Lookback: 30 to 50
• ATR Lookback: 14
• Range Lookback: 20
• Percentile Lookback: 252
• Bars Per Year: 6240
• Smooth Proxy Score: True
• Smoothing Length: 5

Daily FX / Indices

• Realized Volatility Lookback: 20 to 30
• ATR Lookback: 14
• Range Lookback: 20
• Percentile Lookback: 252
• Bars Per Year: 252
• Smooth Proxy Score: True
• Smoothing Length: 3 to 5

Crypto 1-Hour

• Realized Volatility Lookback: 50
• ATR Lookback: 14 to 21
• Range Lookback: 20 to 30
• Percentile Lookback: 500
• Bars Per Year: 8760
• Smooth Proxy Score: True
• Smoothing Length: 5 to 10

Daily Crypto

• Realized Volatility Lookback: 20 to 30
• ATR Lookback: 14
• Range Lookback: 20
• Percentile Lookback: 365
• Bars Per Year: 365
• Smooth Proxy Score: True
• Smoothing Length: 3 to 5

COMPONENT WEIGHTING
━━━━━━━━━━━━━━━━━━━━━━

The default weighting is:

• Realized Volatility Weight: 40%
• ATR Volatility Weight: 30%
• Range Expansion Weight: 30%

These can be adjusted.

A trader who wants a smoother proxy can increase the realized volatility weight.

A trader who wants a more reactive proxy can increase the range expansion weight.

A trader who wants a broader range-based volatility measure can increase the ATR weight.

Suggested use:

• More stable markets: increase realized volatility weight
• Intraday breakout trading: increase range expansion weight
• Trend and swing trading: keep balanced weights
• Crypto: consider slightly higher ATR and range weights

HOW THIS DIFFERS FROM REALIZED VOLATILITY
━━━━━━━━━━━━━━━━━━━━━━

A realized volatility indicator only measures how much price has moved based on returns.

The IV Proxy Indicator blends several sources of volatility behaviour:

• Close-to-close realized volatility
• Range-based volatility through ATR
• Current candle range expansion

This makes it more sensitive to market uncertainty and sudden repricing.

It is not better in every case. It is simply broader.

Realized volatility is cleaner and more statistically direct.

The IV Proxy is more practical and responsive for discretionary trading context.

HOW TO COMBINE WITH OTHER INDICATORS
━━━━━━━━━━━━━━━━━━━━━━

This indicator pairs well with:

• Expected Move Bands
• Realized Volatility Regime Indicator
• VWAP
• Moving averages
• Market structure tools
• Support and resistance
• Liquidity levels
• Macro/event calendars

Suggested framework:

Expected Move Bands show where price may reasonably move.

Realized Volatility Regime shows the current volatility environment.

IV Proxy shows whether forward uncertainty appears to be rising or falling.

Together, they help answer:

• How far can price move?
• What volatility regime are we in?
• Is uncertainty rising or cooling?
• Should I trade normally, reduce size, or wait?

TRADING EXAMPLES
━━━━━━━━━━━━━━━━━━━━━━

Example 1: Low IV Proxy Compression

If the dashboard shows:

• IV Proxy Regime: Low IV Proxy
• IV Direction: Falling
• Market State: IV Compression

This means uncertainty is compressed.

A trader may prepare breakout alerts above resistance and below support, but should wait for price confirmation.

Example 2: High IV Proxy Expansion

If the dashboard shows:

• IV Proxy Regime: High IV Proxy
• IV Direction: Rising
• Market State: IV Expansion

This means uncertainty is rising.

A trader may favour momentum continuation, avoid tight stops, and avoid fading strong moves too early.

Example 3: Extreme IV Proxy Shock

If the dashboard shows:

• IV Proxy Regime: Extreme IV Proxy
• IV Direction: Rising
• Market State: IV Shock

This means the market is in a stress or shock environment.

A trader may reduce exposure, avoid leverage, and wait for stabilization before entering new trades.

Example 4: Extreme IV Proxy Cooling

If the dashboard shows:

• IV Proxy Regime: Extreme IV Proxy
• IV Direction: Falling
• Market State: IV Cooling

This means uncertainty remains elevated, but pressure is starting to ease.

A trader may monitor for failed continuation, re-entry after an extreme move, or mean-reversion confirmation.

Cooling is not a buy or sell signal. It is a warning that the uncertainty phase may be changing.

RISK MANAGEMENT NOTES
━━━━━━━━━━━━━━━━━━━━━━

This indicator is especially useful for risk adjustment.

Possible applications:

• Reduce size during High IV and Extreme IV regimes
• Avoid tight stops when the IV Proxy is rising
• Avoid over-targeting trades when the IV Proxy is compressed
• Use wider stops only if position size is reduced
• Avoid fading extreme moves without confirmation
• Use compression to prepare, not predict
• Use cooling to monitor possible exhaustion

A practical rule:

As uncertainty rises, position size should generally fall.

WHAT THIS INDICATOR IS BEST FOR
━━━━━━━━━━━━━━━━━━━━━━

This indicator is best used for:

• Uncertainty regime detection
• Volatility context
• Breakout preparation
• Momentum confirmation
• Shock detection
• Risk management
• Trade sizing context
• Event-risk awareness

It is most useful when combined with price action, market structure, support/resistance, trend filters, and macro or event awareness.

WHAT THIS INDICATOR IS NOT
━━━━━━━━━━━━━━━━━━━━━━

This indicator is not:

• Real options-chain implied volatility
• A volatility surface model
• A skew or term structure model
• A dealer gamma model
• A standalone trading strategy
• A buy or sell signal generator
• A guarantee of future volatility
• A replacement for risk management

The IV Proxy describes uncertainty conditions. It does not tell you direction by itself.

IMPORTANT LIMITATIONS
━━━━━━━━━━━━━━━━━━━━━━

The indicator uses historical price behaviour. It does not know future volatility.

The indicator does not include:

• Options-chain implied volatility
• Options skew
• Options term structure
• Dealer positioning
• Order flow
• Market depth
• Positioning data
• Fundamental data
• News sentiment
• Liquidity conditions

Volatility and uncertainty can change rapidly after:

• Economic data releases
• Central bank decisions
• Earnings reports
• Geopolitical events
• Liquidity shocks
• Crypto liquidation cascades
• Market open or close effects

Use it as a decision-support tool, not as a standalone trading system.

FINAL NOTES
━━━━━━━━━━━━━━━━━━━━━━

The Implied Volatility Proxy Indicator helps traders think in terms of uncertainty, risk, and volatility regime.

Instead of asking only whether price is bullish or bearish, this tool helps answer:

• Is uncertainty compressed or elevated?
• Is uncertainty rising or falling?
• Is the market entering a volatility shock?
• Is volatility pressure starting to cool?
• Should I trade normally, reduce size, or wait?
• Is this environment better for breakout, momentum, range, or defensive trading?

The indicator is designed to improve trade context and risk discipline.

## Source Code

````pine
//@version=6
indicator(
     title="Implied Volatility Proxy Indicator [v1]",
     shorttitle="IV Proxy",
     overlay=false,
     max_labels_count=100
)

// ======================================================
// 1. USER INPUTS
// ======================================================

// --- Core volatility settings
rvLookback = input.int(
     30,
     "Realized Volatility Lookback",
     minval=5,
     maxval=500
)

atrLookback = input.int(
     14,
     "ATR Lookback",
     minval=2,
     maxval=500
)

rangeLookback = input.int(
     20,
     "Range Expansion Lookback",
     minval=5,
     maxval=500
)

percentileLookback = input.int(
     252,
     "Percentile Lookback",
     minval=20,
     maxval=1000
)

barsPerYear = input.int(
     252,
     "Bars Per Year",
     minval=1
)

// --- Weighting settings
rvWeight = input.float(
     0.40,
     "Realized Volatility Weight",
     minval=0.0,
     maxval=1.0,
     step=0.05
)

atrWeight = input.float(
     0.30,
     "ATR Volatility Weight",
     minval=0.0,
     maxval=1.0,
     step=0.05
)

rangeWeight = input.float(
     0.30,
     "Range Expansion Weight",
     minval=0.0,
     maxval=1.0,
     step=0.05
)

// --- Smoothing
smoothProxy = input.bool(
     true,
     "Smooth IV Proxy Score"
)

smoothLength = input.int(
     5,
     "Smoothing Length",
     minval=1,
     maxval=100
)

// --- Regime thresholds
lowIVLevel = input.float(
     25.0,
     "Low IV Proxy Threshold",
     minval=0,
     maxval=100
)

highIVLevel = input.float(
     75.0,
     "High IV Proxy Threshold",
     minval=0,
     maxval=100
)

extremeIVLevel = input.float(
     90.0,
     "Extreme IV Proxy Threshold",
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
     "Show Regime Background"
)

showComponents = input.bool(
     false,
     "Show Component Percentiles"
)

showMarkers = input.bool(
     true,
     "Show Regime Markers"
)


// ======================================================
// 2. HELPER FUNCTION: PERCENTILE RANK
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


// ======================================================
// 3. REALIZED VOLATILITY COMPONENT
// ======================================================

// Log returns
logReturn = math.log(close / close[1])

// Realized volatility per bar
rvPerBar = ta.stdev(logReturn, rvLookback)

// Annualized realized volatility
rvAnnualized = rvPerBar * math.sqrt(barsPerYear)

// Percentile rank of realized volatility
rvPercentile = f_percent_rank(rvAnnualized, percentileLookback)


// ======================================================
// 4. ATR VOLATILITY COMPONENT
// ======================================================

// ATR as percentage of price
atrValue = ta.atr(atrLookback)
atrPct = close != 0.0 ? atrValue / close : na

// Annualized ATR-style volatility proxy
atrAnnualized = atrPct * math.sqrt(barsPerYear)

// Percentile rank of ATR volatility
atrPercentile = f_percent_rank(atrAnnualized, percentileLookback)


// ======================================================
// 5. RANGE EXPANSION COMPONENT
// ======================================================

// Bar range as percentage of price
barRange = high - low
rangePct = close != 0.0 ? barRange / close : na

// Average recent range percentage
avgRangePct = ta.sma(rangePct, rangeLookback)

// Range expansion ratio
rangeExpansionRatio = avgRangePct != 0.0 ? rangePct / avgRangePct : na

// Percentile rank of range expansion
rangePercentile = f_percent_rank(rangeExpansionRatio, percentileLookback)


// ======================================================
// 6. NORMALISED WEIGHTS
// ======================================================

totalWeight = rvWeight + atrWeight + rangeWeight

normRvWeight = totalWeight > 0.0 ? rvWeight / totalWeight : 0.40
normAtrWeight = totalWeight > 0.0 ? atrWeight / totalWeight : 0.30
normRangeWeight = totalWeight > 0.0 ? rangeWeight / totalWeight : 0.30


// ======================================================
// 7. COMPOSITE IV PROXY SCORE
// ======================================================

rawIVProxy =
     not na(rvPercentile) and not na(atrPercentile) and not na(rangePercentile) ?
     (rvPercentile * normRvWeight) + (atrPercentile * normAtrWeight) + (rangePercentile * normRangeWeight) :
     na

ivProxyScore = smoothProxy ? ta.ema(rawIVProxy, smoothLength) : rawIVProxy


// ======================================================
// 8. IV PROXY REGIME CLASSIFICATION
// ======================================================

string ivRegime = "LOADING"
color ivColor = color.new(color.gray, 0)
int ivRegimeScore = 0

if not na(ivProxyScore)
    if ivProxyScore < lowIVLevel
        ivRegime := "LOW IV PROXY"
        ivColor := color.new(color.green, 0)
        ivRegimeScore := 1
    else if ivProxyScore < highIVLevel
        ivRegime := "NORMAL IV PROXY"
        ivColor := color.new(color.blue, 0)
        ivRegimeScore := 2
    else if ivProxyScore < extremeIVLevel
        ivRegime := "HIGH IV PROXY"
        ivColor := color.new(color.orange, 0)
        ivRegimeScore := 3
    else
        ivRegime := "EXTREME IV PROXY"
        ivColor := color.new(color.red, 0)
        ivRegimeScore := 4


// ======================================================
// 9. IV PROXY DIRECTION
// ======================================================

string ivDirection = "FLAT"
color ivDirectionColor = color.new(color.gray, 0)

if ivProxyScore > ivProxyScore[1]
    ivDirection := "RISING"
    ivDirectionColor := color.new(color.orange, 0)
else if ivProxyScore < ivProxyScore[1]
    ivDirection := "FALLING"
    ivDirectionColor := color.new(color.blue, 0)


// ======================================================
// 10. MARKET STATE CLASSIFICATION
// ======================================================

bool ivCompression = ivRegimeScore == 1 and ivProxyScore < ivProxyScore[1]
bool ivExpansion = ivRegimeScore >= 3 and ivProxyScore > ivProxyScore[1]
bool ivShock = ivRegimeScore == 4 and ivProxyScore > ivProxyScore[1]
bool ivCooling = ivRegimeScore >= 3 and ivProxyScore < ivProxyScore[1]

string marketState = "NEUTRAL"
color marketStateColor = color.new(color.gray, 0)

if ivShock
    marketState := "IV SHOCK"
    marketStateColor := color.new(color.red, 0)
else if ivExpansion
    marketState := "IV EXPANSION"
    marketStateColor := color.new(color.orange, 0)
else if ivCompression
    marketState := "IV COMPRESSION"
    marketStateColor := color.new(color.green, 0)
else if ivCooling
    marketState := "IV COOLING"
    marketStateColor := color.new(color.blue, 0)


// ======================================================
// 11. REGIME CHANGE EVENTS
// ======================================================

enteredLowIV = ivRegimeScore == 1 and ivRegimeScore[1] != 1
enteredNormalIV = ivRegimeScore == 2 and ivRegimeScore[1] != 2
enteredHighIV = ivRegimeScore == 3 and ivRegimeScore[1] != 3
enteredExtremeIV = ivRegimeScore == 4 and ivRegimeScore[1] != 4


// ======================================================
// 12. PLOTS
// ======================================================

// Main IV Proxy Score
plot(
     ivProxyScore,
     title="IV Proxy Score",
     color=ivColor,
     linewidth=3
)

// Component percentile plots
plot(
     showComponents ? rvPercentile : na,
     title="RV Percentile Component",
     color=color.new(color.purple, 0),
     linewidth=1
)

plot(
     showComponents ? atrPercentile : na,
     title="ATR Percentile Component",
     color=color.new(color.yellow, 0),
     linewidth=1
)

plot(
     showComponents ? rangePercentile : na,
     title="Range Expansion Percentile Component",
     color=color.new(color.aqua, 0),
     linewidth=1
)

// Threshold lines
hline(
     lowIVLevel,
     title="Low IV Proxy Threshold",
     color=color.new(color.green, 45),
     linestyle=hline.style_dotted,
     display=showThresholds ? display.all : display.none
)

hline(
     highIVLevel,
     title="High IV Proxy Threshold",
     color=color.new(color.orange, 45),
     linestyle=hline.style_dotted,
     display=showThresholds ? display.all : display.none
)

hline(
     extremeIVLevel,
     title="Extreme IV Proxy Threshold",
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

// Background regime shading
color bgColor = na

if showBackground
    if ivRegimeScore == 1
        bgColor := color.new(color.green, 90)
    else if ivRegimeScore == 2
        bgColor := color.new(color.blue, 92)
    else if ivRegimeScore == 3
        bgColor := color.new(color.orange, 90)
    else if ivRegimeScore == 4
        bgColor := color.new(color.red, 88)

bgcolor(bgColor)


// ======================================================
// 13. REGIME MARKERS
// ======================================================

plotshape(
     showMarkers and enteredLowIV,
     title="Entered Low IV Proxy",
     style=shape.circle,
     location=location.bottom,
     color=color.new(color.green, 0),
     size=size.tiny,
     text="LOW"
)

plotshape(
     showMarkers and enteredNormalIV,
     title="Entered Normal IV Proxy",
     style=shape.circle,
     location=location.bottom,
     color=color.new(color.blue, 0),
     size=size.tiny,
     text="NORM"
)

plotshape(
     showMarkers and enteredHighIV,
     title="Entered High IV Proxy",
     style=shape.triangleup,
     location=location.top,
     color=color.new(color.orange, 0),
     size=size.tiny,
     text="HIGH"
)

plotshape(
     showMarkers and enteredExtremeIV,
     title="Entered Extreme IV Proxy",
     style=shape.triangleup,
     location=location.top,
     color=color.new(color.red, 0),
     size=size.small,
     text="EXT"
)


// ======================================================
// 14. DASHBOARD
// ======================================================

var table dash = table.new(
     position.top_right,
     columns=2,
     rows=9,
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
             "IV Proxy Regime",
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )

        table.cell(
             dash,
             1,
             1,
             ivRegime,
             text_color=color.white,
             bgcolor=ivColor
        )

        table.cell(
             dash,
             0,
             2,
             "IV Proxy Score",
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )

        table.cell(
             dash,
             1,
             2,
             na(ivProxyScore) ? "Loading" : str.tostring(ivProxyScore, "#.##"),
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )

        table.cell(
             dash,
             0,
             3,
             "IV Direction",
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )

        table.cell(
             dash,
             1,
             3,
             ivDirection,
             text_color=color.white,
             bgcolor=ivDirectionColor
        )

        table.cell(
             dash,
             0,
             4,
             "Market State",
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )

        table.cell(
             dash,
             1,
             4,
             marketState,
             text_color=color.white,
             bgcolor=marketStateColor
        )

        table.cell(
             dash,
             0,
             5,
             "RV Component",
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )

        table.cell(
             dash,
             1,
             5,
             na(rvPercentile) ? "Loading" : str.tostring(rvPercentile, "#.##"),
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )

        table.cell(
             dash,
             0,
             6,
             "ATR Component",
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )

        table.cell(
             dash,
             1,
             6,
             na(atrPercentile) ? "Loading" : str.tostring(atrPercentile, "#.##"),
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )

        table.cell(
             dash,
             0,
             7,
             "Range Component",
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )

        table.cell(
             dash,
             1,
             7,
             na(rangePercentile) ? "Loading" : str.tostring(rangePercentile, "#.##"),
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )

        table.cell(
             dash,
             0,
             8,
             "Regime Score",
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )

        table.cell(
             dash,
             1,
             8,
             str.tostring(ivRegimeScore),
             text_color=color.white,
             bgcolor=color.new(color.black, 20)
        )
    else
        table.clear(dash, 0, 0, 1, 8)


// ======================================================
// 15. ALERT CONDITIONS
// ======================================================

alertcondition(
     enteredLowIV,
     title="Entered Low IV Proxy Regime",
     message="The IV Proxy has entered a low-volatility regime."
)

alertcondition(
     enteredNormalIV,
     title="Entered Normal IV Proxy Regime",
     message="The IV Proxy has entered a normal-volatility regime."
)

alertcondition(
     enteredHighIV,
     title="Entered High IV Proxy Regime",
     message="The IV Proxy has entered a high-volatility regime."
)

alertcondition(
     enteredExtremeIV,
     title="Entered Extreme IV Proxy Regime",
     message="The IV Proxy has entered an extreme-volatility regime."
)

alertcondition(
     ivCompression,
     title="IV Proxy Compression",
     message="The IV Proxy is low and falling. Compression conditions may be building."
)

alertcondition(
     ivExpansion,
     title="IV Proxy Expansion",
     message="The IV Proxy is high and rising. Forward uncertainty may be expanding."
)

alertcondition(
     ivShock,
     title="IV Proxy Shock",
     message="The IV Proxy is extreme and rising. Volatility shock conditions may be active."
)

alertcondition(
     ivCooling,
     title="IV Proxy Cooling",
     message="The IV Proxy is elevated but falling. Volatility pressure may be cooling."
)
````
