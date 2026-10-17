# Derivatives Expected Move Volatility Bands [v2]

- url: https://www.tradingview.com/script/47G4QVNI-Derivatives-Expected-Move-Volatility-Bands-v2/
- type: indicator
- pine_id: PUB;555fead3356a45aaa2b9d36e6a8d0bf7
- version: 1.0

## Description

[b]Derivatives Expected Move Volatility Bands[/b]

[b]Overview[/b]

Derivatives Expected Move Volatility Bands is a volatility-based projection tool designed to estimate the likely upside and downside price range over a selected number of future candles.

The indicator uses recent realised volatility to calculate an expected move from the current market price. It then plots forward-looking volatility levels at **±1σ, ±2σ, and ±3σ** from the selected anchor price.

This is not a traditional moving average, oscillator, or buy/sell indicator. It is a **risk, volatility, and scenario-planning tool**. It helps traders understand whether the current market is trading within a normal expected range, approaching an extended zone, or operating in an extreme-volatility regime.

The logic is inspired by derivatives pricing concepts, where volatility and time are used to estimate the probable distribution of future prices.

What the Indicator Shows

The indicator plots forward expected-move levels from the current price.

Anchor Line

The Anchor is the current price used as the base for the projection. By default, this is the latest closing price.

The projected bands are calculated above and below this anchor.

+1σ and -1σ Levels

The 1 standard deviation bands represent the normal expected move over the selected time horizon.

In practical terms, these levels show where price could reasonably trade if recent volatility conditions persist.

+2σ and -2σ Levels

The 2 standard deviation bands represent a more extended move.

A move toward or beyond these levels suggests that the market is trading outside its normal short-term range and may be entering a stronger momentum or stress condition.

+3σ and -3σ Levels

The 3 standard deviation bands represent extreme move zones.

These are useful for stress testing, event-risk planning, and identifying unusually large moves. They should not be treated as automatic reversal levels.

How the Expected Move Is Calculated

The indicator estimates realised volatility from recent log returns.

The expected move is then calculated as:

Expected Move = Price × Realized Volatility × √Time Horizon

Where:

- Price = selected anchor price
- Realized Volatility = volatility calculated from recent price changes
- Time Horizon = the number of future bars selected by the user

For example, on a 1-hour chart with a horizon of 20 bars, the indicator estimates the expected move over the next 20 hourly candles.

Dashboard Explanation

The indicator includes a dashboard with the following fields:

Vol Regime

Shows the current volatility regime based on the percentile rank of realised volatility.

Possible regimes:

- Low Vol
- Normal Vol
- High Vol
- Extreme Vol

This helps traders understand whether the market is calm, active, volatile, or in a stress regime.

RV Annualized

Shows the current realised volatility annualised using the selected bars-per-year setting.

This is useful for comparing volatility across assets and timeframes.

Vol Percentile

Shows where current volatility ranks compared to its recent history.

For example:

- A percentile near 20% means volatility is low relative to recent history.
- A percentile near 80% means volatility is high.
- A percentile above 90% suggests an extreme volatility regime.

Expected Move

Shows the projected move as a percentage of price over the chosen horizon.

Expected Move Abs

Shows the expected move in absolute price terms.

For FX pairs, this can be interpreted approximately as the number of pips depending on the instrument.

Projection Anchor

Shows the price level used as the base for the forward projection.

Vol Direction

Shows whether realised volatility is currently:

- Expanding
- Contracting
- Flat

This is important because an extended price move with expanding volatility often behaves differently from an extended move with contracting volatility.

How to Use the Indicator

1. Use It for Forward Price Range Planning

The main use of the indicator is to answer:

Based on current volatility, how far could price reasonably move over the next selected number of candles?

For example, if EUR/USD is trading at 1.1520 and the 20-bar expected move is 0.45%, the indicator will project upside and downside levels around that price.

This can help with:

- Trade planning
- Target setting
- Stop placement
- Event-risk preparation
- Volatility regime analysis
- Avoiding unrealistic price expectations

2. Use 1σ Levels for Normal Movement

The ±1σ levels are the most useful for normal trading conditions.

Price moving toward a 1σ level suggests that it is making a meaningful move, but not necessarily an extreme one.

Common uses:

- Identify realistic intraday or swing targets
- Estimate normal retracement zones
- Avoid entering trades with poor reward-to-risk
- Compare current price action to recent volatility

3. Use 2σ Levels for Extension and Stress

The ±2σ levels represent stronger price movement.

When price approaches or breaks a 2σ level, traders should assess whether the move is:

- A genuine momentum expansion
- A news-driven volatility shock
- An exhaustion move
- A liquidity sweep
- A stop-run beyond normal range

A move outside 2σ should not automatically be faded. Strong markets can continue beyond expected ranges, especially when volatility is expanding.

4. Use 3σ Levels for Extreme Risk Planning

The ±3σ levels are not everyday trading targets.

They are better used for:

- Stress scenarios
- Major event planning
- CPI, NFP, FOMC, central bank decisions
- Crypto liquidation events
- Geopolitical volatility
- Large FX repricing events

If the price reaches a 3σ level, the market is moving in an unusually large way relative to recent volatility.

5. Combine Price Location with Volatility Direction

The most important part of the indicator is not just where the price is, but whether volatility is expanding or contracting.

Momentum Expansion

If price is moving outside the 1σ or 2σ range while volatility is expanding, the market may be entering a momentum phase.

This can support breakout or trend-continuation logic.

Exhaustion or Mean-Reversion Risk

If the price is extended beyond the bands while volatility is contracting, the move may be losing energy.

This can suggest exhaustion risk, but confirmation is still required from price action.

Compression

If volatility is low and the bands are narrow, the market may be in a compression regime.

Compression does not predict direction, but it can warn that a larger move may be building.

Trading Interpretations

Momentum Use Case

A bullish momentum condition may develop when:

- Price trades above the anchor
- Price pushes toward or beyond +1σ
- Volatility is expanding
- Market structure supports continuation

A bearish momentum condition may develop when:

- Price trades below the anchor
- Price pushes toward or beyond -1σ
- Volatility is expanding
- Market structure supports continuation

In these conditions, traders may use the bands as forward targets or risk zones.

Mean-Reversion Use Case

Mean-reversion traders should avoid blindly fading every touch of a band.

A better approach is to wait for confirmation, such as:

- Price moves outside ±2σ
- Price then closes back inside the band
- Volatility stops expanding
- A reversal candle or structure shift appears
- The move fails to continue

The re-entry back inside the band is often more important than the initial band touch.

Breakout Use Case

The indicator can also help with breakout analysis.

A breakout has higher quality when:

* Price breaks beyond the 1σ level
* Volatility is expanding
* Price does not immediately return to the anchor
* The move aligns with higher-timeframe structure

A breakout is weaker when:

* Price breaks the band but volatility contracts
* Price immediately returns inside the expected range
* The breakout occurs into a major opposing level
* Liquidity is poor or event risk is unresolved

Event-Risk Use Case

The indicator is useful before major events such as:

* CPI
* NFP
* FOMC
* ECB decisions
* BoE decisions
* Central bank speeches
* Major crypto events
* Earnings for stocks
* Geopolitical shocks

Before an event, traders can use the projected bands to estimate reasonable upside and downside scenarios.

After the event, traders can observe whether price remains inside the expected range or reprices beyond it.


Recommended Settings

FX 1-Hour Chart

Suggested settings:

* Volatility Lookback: **30 to 50**
* Horizon Bars: **20 to 24**
* Bars Per Year: **6240**
* Projection Anchor: **Close**

This works well for pairs such as:

* EUR/USD
* GBP/USD
* USD/JPY
* AUD/USD
* USD/CAD
* USD/ZAR

## Crypto 1-Hour Chart

Suggested settings:

* Volatility Lookback: 50 to 100
* Horizon Bars: 24
* Bars Per Year: 8760
* Projection Anchor: Close

Crypto trades continuously, so a higher bars-per-year input is more appropriate.

Daily Chart

Suggested settings:

* Volatility Lookback: 20 to 30
* Horizon Bars: 5 to 20
* Bars Per Year: 252 for traditional markets
* Bars Per Year: 365 for crypto

Daily settings are useful for swing trading and weekly scenario planning.

Intraday Index Trading

Suggested settings:

* Volatility Lookback: 50 to 100
* Horizon Bars: 12 to 48
* Bars Per Year: depends on the chart timeframe and trading session

For 5-minute charts, users should adjust the bars-per-year setting based on the number of active trading bars in a year.

## Practical Trading Workflow

A simple workflow:

1. Select your market and timeframe.
2. Set the expected move horizon.
3. Check the volatility regime.
4. Check whether volatility is expanding or contracting.
5. Observe whether price is near the anchor, 1σ, 2σ, or 3σ.
6. Use 1σ and 2σ levels for target and risk planning.
7. Avoid blindly fading extreme moves during expanding volatility.
8. Look for re-entry or structure confirmation before mean-reversion trades.
9. Use the bands together with market structure, trend, liquidity, and macro context.

What the Indicator Is Best For

This indicator is best used for:

* Expected move analysis
* Volatility regime detection
* Trade planning
* Risk management
* Scenario analysis
* Event-risk preparation
* Identifying normal vs extended price movement

It is particularly useful for traders who want to understand whether the market is moving within a statistically normal range or entering an abnormal volatility condition.

What the Indicator Is Not

This indicator is not:

* A guaranteed buy/sell system
* A full options-pricing model
* A prediction engine
* A replacement for risk management
* A standalone trading strategy
* A signal that every band touch should be traded

The bands are probability-based reference levels, not guaranteed support or resistance.

Important Limitations

The indicator uses historical realised volatility. It does not know future volatility.

Volatility can change suddenly, especially during:

* News events
* Central bank decisions
* Earnings releases
* Liquidity shocks
* Flash crashes
* Crypto liquidation cascades
* Geopolitical events

The expected move assumes that recent volatility is a reasonable estimate for near-future volatility. In fast-changing markets, this assumption can fail.

The indicator also does not include order flow, positioning, options-chain data, implied volatility, macroeconomic data, or liquidity depth.

For best results, it should be combined with:

* Market structure
* Trend analysis
* Support and resistance
* Liquidity levels
* Fundamental or macro context
* Risk management rules


## Suggested Interpretation Table

| Price Location    | Volatility Direction | Interpretation                       |
| ----------------- | -------------------- | ------------------------------------ |
| Near Anchor       | Flat or Contracting  | Balanced / neutral range             |
| Above +1σ         | Expanding            | Bullish momentum possible            |
| Below -1σ         | Expanding            | Bearish momentum possible            |
| Above +2σ         | Expanding            | Strong upside extension              |
| Below -2σ         | Expanding            | Strong downside extension            |
| Outside ±2σ       | Contracting          | Possible exhaustion risk             |
| Back inside ±2σ   | Contracting          | Mean-reversion confirmation possible |
| Very narrow bands | Low volatility       | Compression / breakout risk          |
| Very wide bands   | High volatility      | Stress regime / reduce size          |


## Risk Management Notes

Traders can use the expected move levels to improve risk planning.

Possible applications:

* Use 1σ levels as realistic near-term targets.
* Use 2σ levels as aggressive targets or extreme-risk zones.
* Avoid placing stops too close during high-volatility regimes.
* Reduce position size when volatility percentile is high.
* Avoid chasing price after a large move into 2σ or 3σ unless momentum is confirmed.
* Wait for re-entry before fading extended moves.

The indicator is most powerful when used to avoid poor trade location.

Example Use Case

Suppose EUR/USD is trading at 1.1520 on the 1-hour chart.

The indicator shows:

* Expected Move: 0.45%
* +1σ: 1.1574
* -1σ: 1.1470
* +2σ: 1.1626
* -2σ: 1.1419
* Vol Regime: Extreme Vol
* Vol Direction: Contracting

This means the market recently experienced a large volatility shock, but volatility is now cooling.

A trader could interpret this as follows:

* A move toward +1σ may be a normal retracement.
* A move toward -1σ may be normal continuation.
* A move beyond ±2σ would represent a more extreme continuation or reversal scenario.
* Since volatility is contracting, chasing the move may be less attractive.
* Mean reversion should still require confirmation from price action.


## Best Markets

The indicator can be used across liquid markets, including:

* FX pairs
* Crypto
* Equity indices
* Commodities
* Futures
* Large-cap stocks

It generally works best on liquid instruments with reliable price history.

## Final Notes

Derivatives Expected Move Volatility Bands is designed to help traders think in terms of probability, volatility, and risk.

Instead of asking only whether price is bullish or bearish, the indicator helps answer:

* Is the move normal or extended?
* How far could price reasonably move?
* Is volatility expanding or contracting?
* Is the market in a low, normal, high, or extreme volatility regime?
* Are my targets and stops realistic for the current environment?

Use it as a decision-support and risk-management tool, not as a standalone trading system.

## Source Code

````pine
//@version=6
indicator(
     title="Derivatives Expected Move Volatility Bands [v2]",
     shorttitle="EM v2",
     overlay=true,
     max_lines_count=100,
     max_labels_count=100
)

// ======================================================
// 1. USER INPUTS
// ======================================================

// --- Volatility settings
volLookback      = input.int(30, "Realized Volatility Lookback", minval=5, maxval=500)
horizonBars      = input.int(20, "Expected Move Horizon in Bars", minval=1, maxval=500)
barsPerYear      = input.int(6240, "Bars Per Year for Annualized Vol", minval=1)

// --- Historical band settings
showHistoricalBands = input.bool(false, "Show Historical Rolling Bands")
basisMode           = input.string("EMA", "Historical Band Basis", options=["Close", "EMA", "SMA"])
basisLength         = input.int(20, "EMA/SMA Basis Length", minval=1, maxval=300)

showOneSigma        = input.bool(true, "Show 1σ Historical Bands")
showTwoSigma        = input.bool(true, "Show 2σ Historical Bands")
showThreeSigma      = input.bool(false, "Show 3σ Historical Bands")

// --- Current projection settings
showCurrentProjection = input.bool(true, "Show Current Price Projection")
projectionAnchor      = input.string("Close", "Projection Anchor", options=["Close", "HL2", "HLC3"])
showProjectionLabels  = input.bool(true, "Show Projection Labels")

// --- Volatility regime settings
percentileLength = input.int(252, "Volatility Percentile Lookback", minval=20, maxval=1000)

lowVolLevel      = input.float(25.0, "Low Vol Percentile Threshold", minval=0, maxval=100)
highVolLevel     = input.float(75.0, "High Vol Percentile Threshold", minval=0, maxval=100)
extremeVolLevel  = input.float(90.0, "Extreme Vol Percentile Threshold", minval=0, maxval=100)

// --- Dashboard settings
showDashboard = input.bool(true, "Show Dashboard")


// ======================================================
// 2. CORE VOLATILITY CALCULATIONS
// ======================================================

logReturn = math.log(close / close[1])

rvPerBar = ta.stdev(logReturn, volLookback)

annualizedVol = rvPerBar * math.sqrt(barsPerYear)

expectedMovePct = rvPerBar * math.sqrt(horizonBars)

projectionPrice = switch projectionAnchor
    "HL2"  => hl2
    "HLC3" => hlc3
    => close

expectedMoveAbs = projectionPrice * expectedMovePct


// ======================================================
// 3. HISTORICAL ROLLING BANDS
// ======================================================

basis = switch basisMode
    "EMA" => ta.ema(close, basisLength)
    "SMA" => ta.sma(close, basisLength)
    => close

histMoveAbs = basis * expectedMovePct

upper1 = basis + histMoveAbs
lower1 = basis - histMoveAbs

upper2 = basis + histMoveAbs * 2.0
lower2 = basis - histMoveAbs * 2.0

upper3 = basis + histMoveAbs * 3.0
lower3 = basis - histMoveAbs * 3.0

plot(showHistoricalBands ? basis : na, title="Historical Basis", color=color.white, linewidth=2)

pUpper1 = plot(showHistoricalBands and showOneSigma ? upper1 : na, title="Historical Upper 1σ", color=color.new(color.green, 10), linewidth=1)
pLower1 = plot(showHistoricalBands and showOneSigma ? lower1 : na, title="Historical Lower 1σ", color=color.new(color.green, 10), linewidth=1)

pUpper2 = plot(showHistoricalBands and showTwoSigma ? upper2 : na, title="Historical Upper 2σ", color=color.new(color.orange, 10), linewidth=1)
pLower2 = plot(showHistoricalBands and showTwoSigma ? lower2 : na, title="Historical Lower 2σ", color=color.new(color.orange, 10), linewidth=1)

pUpper3 = plot(showHistoricalBands and showThreeSigma ? upper3 : na, title="Historical Upper 3σ", color=color.new(color.red, 10), linewidth=1)
pLower3 = plot(showHistoricalBands and showThreeSigma ? lower3 : na, title="Historical Lower 3σ", color=color.new(color.red, 10), linewidth=1)

fill(pUpper1, pLower1, color=showHistoricalBands and showOneSigma ? color.new(color.green, 92) : na, title="Historical 1σ Zone")
fill(pUpper2, pLower2, color=showHistoricalBands and showTwoSigma ? color.new(color.orange, 94) : na, title="Historical 2σ Zone")
fill(pUpper3, pLower3, color=showHistoricalBands and showThreeSigma ? color.new(color.red, 96) : na, title="Historical 3σ Zone")


// ======================================================
// 4. CURRENT PRICE PROJECTION LEVELS
// ======================================================

currentUpper1 = projectionPrice + expectedMoveAbs
currentLower1 = projectionPrice - expectedMoveAbs

currentUpper2 = projectionPrice + expectedMoveAbs * 2.0
currentLower2 = projectionPrice - expectedMoveAbs * 2.0

currentUpper3 = projectionPrice + expectedMoveAbs * 3.0
currentLower3 = projectionPrice - expectedMoveAbs * 3.0

var line anchorLine = na
var line upper1Line = na
var line lower1Line = na
var line upper2Line = na
var line lower2Line = na
var line upper3Line = na
var line lower3Line = na

var label anchorLabel = na
var label upper1Label = na
var label lower1Label = na
var label upper2Label = na
var label lower2Label = na
var label upper3Label = na
var label lower3Label = na

if barstate.islast
    line.delete(anchorLine)
    line.delete(upper1Line)
    line.delete(lower1Line)
    line.delete(upper2Line)
    line.delete(lower2Line)
    line.delete(upper3Line)
    line.delete(lower3Line)

    label.delete(anchorLabel)
    label.delete(upper1Label)
    label.delete(lower1Label)
    label.delete(upper2Label)
    label.delete(lower2Label)
    label.delete(upper3Label)
    label.delete(lower3Label)

    if showCurrentProjection
        x1 = bar_index
        x2 = bar_index + horizonBars

        anchorLine := line.new(x1, projectionPrice, x2, projectionPrice, color=color.new(color.white, 0), width=2)
        upper1Line := line.new(x1, currentUpper1, x2, currentUpper1, color=color.new(color.green, 0), width=2)
        lower1Line := line.new(x1, currentLower1, x2, currentLower1, color=color.new(color.green, 0), width=2)
        upper2Line := line.new(x1, currentUpper2, x2, currentUpper2, color=color.new(color.orange, 0), width=2)
        lower2Line := line.new(x1, currentLower2, x2, currentLower2, color=color.new(color.orange, 0), width=2)
        upper3Line := line.new(x1, currentUpper3, x2, currentUpper3, color=color.new(color.red, 0), width=1)
        lower3Line := line.new(x1, currentLower3, x2, currentLower3, color=color.new(color.red, 0), width=1)

        if showProjectionLabels
            anchorLabel := label.new(x2, projectionPrice, "Anchor: " + str.tostring(projectionPrice, format.mintick), style=label.style_label_left, textcolor=color.white, color=color.new(color.black, 0))
            upper1Label := label.new(x2, currentUpper1, "+1σ: " + str.tostring(currentUpper1, format.mintick), style=label.style_label_left, textcolor=color.white, color=color.new(color.green, 0))
            lower1Label := label.new(x2, currentLower1, "-1σ: " + str.tostring(currentLower1, format.mintick), style=label.style_label_left, textcolor=color.white, color=color.new(color.green, 0))
            upper2Label := label.new(x2, currentUpper2, "+2σ: " + str.tostring(currentUpper2, format.mintick), style=label.style_label_left, textcolor=color.white, color=color.new(color.orange, 0))
            lower2Label := label.new(x2, currentLower2, "-2σ: " + str.tostring(currentLower2, format.mintick), style=label.style_label_left, textcolor=color.white, color=color.new(color.orange, 0))
            upper3Label := label.new(x2, currentUpper3, "+3σ: " + str.tostring(currentUpper3, format.mintick), style=label.style_label_left, textcolor=color.white, color=color.new(color.red, 0))
            lower3Label := label.new(x2, currentLower3, "-3σ: " + str.tostring(currentLower3, format.mintick), style=label.style_label_left, textcolor=color.white, color=color.new(color.red, 0))


// ======================================================
// 5. VOLATILITY PERCENTILE FUNCTION
// ======================================================

f_percent_rank(src, length) =>
    count = 0.0
    valid = 0.0

    for i = 1 to length
        if not na(src[i])
            valid += 1.0
            if src > src[i]
                count += 1.0

    valid > 0 ? (count / valid) * 100.0 : na

volPercentile = f_percent_rank(annualizedVol, percentileLength)


// ======================================================
// 6. REGIME CLASSIFICATION
// ======================================================

string volRegime = "LOADING"
color regimeColor = color.new(color.gray, 0)

if not na(volPercentile)
    if volPercentile < lowVolLevel
        volRegime := "LOW VOL"
        regimeColor := color.new(color.green, 0)
    else if volPercentile < highVolLevel
        volRegime := "NORMAL VOL"
        regimeColor := color.new(color.blue, 0)
    else if volPercentile < extremeVolLevel
        volRegime := "HIGH VOL"
        regimeColor := color.new(color.orange, 0)
    else
        volRegime := "EXTREME VOL"
        regimeColor := color.new(color.red, 0)

string volDirection = "FLAT"
color volDirectionColor = color.new(color.gray, 0)

if annualizedVol > annualizedVol[1]
    volDirection := "EXPANDING"
    volDirectionColor := color.new(color.orange, 0)
else if annualizedVol < annualizedVol[1]
    volDirection := "CONTRACTING"
    volDirectionColor := color.new(color.blue, 0)


// ======================================================
// 7. DASHBOARD
// ======================================================

var table dash = table.new(
     position.top_right,
     columns=2,
     rows=8,
     border_width=1
)

if barstate.islast
    if showDashboard
        table.cell(dash, 0, 0, "Metric", text_color=color.white, bgcolor=color.new(color.black, 0))
        table.cell(dash, 1, 0, "Value", text_color=color.white, bgcolor=color.new(color.black, 0))

        table.cell(dash, 0, 1, "Vol Regime", text_color=color.white, bgcolor=color.new(color.black, 20))
        table.cell(dash, 1, 1, volRegime, text_color=color.white, bgcolor=regimeColor)

        table.cell(dash, 0, 2, "RV Annualized", text_color=color.white, bgcolor=color.new(color.black, 20))
        table.cell(dash, 1, 2, str.tostring(annualizedVol * 100.0, "#.##") + "%", text_color=color.white, bgcolor=color.new(color.black, 20))

        table.cell(dash, 0, 3, "Vol Percentile", text_color=color.white, bgcolor=color.new(color.black, 20))
        table.cell(dash, 1, 3, na(volPercentile) ? "Loading" : str.tostring(volPercentile, "#.##") + "%", text_color=color.white, bgcolor=color.new(color.black, 20))

        table.cell(dash, 0, 4, "Expected Move", text_color=color.white, bgcolor=color.new(color.black, 20))
        table.cell(dash, 1, 4, str.tostring(expectedMovePct * 100.0, "#.##") + "%", text_color=color.white, bgcolor=color.new(color.black, 20))

        table.cell(dash, 0, 5, "Expected Move Abs", text_color=color.white, bgcolor=color.new(color.black, 20))
        table.cell(dash, 1, 5, str.tostring(expectedMoveAbs, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 20))

        table.cell(dash, 0, 6, "Projection Anchor", text_color=color.white, bgcolor=color.new(color.black, 20))
        table.cell(dash, 1, 6, str.tostring(projectionPrice, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 20))

        table.cell(dash, 0, 7, "Vol Direction", text_color=color.white, bgcolor=color.new(color.black, 20))
        table.cell(dash, 1, 7, volDirection, text_color=color.white, bgcolor=volDirectionColor)
    else
        table.clear(dash, 0, 0, 1, 7)


// ======================================================
// 8. ALERT CONDITIONS
// ======================================================

alertcondition(close > currentUpper1, title="Price Above Current +1σ", message="Price is above the current projected +1σ expected move level.")
alertcondition(close < currentLower1, title="Price Below Current -1σ", message="Price is below the current projected -1σ expected move level.")
alertcondition(close > currentUpper2, title="Price Above Current +2σ", message="Price is above the current projected +2σ expected move level.")
alertcondition(close < currentLower2, title="Price Below Current -2σ", message="Price is below the current projected -2σ expected move level.")
alertcondition(not na(volPercentile) and volPercentile >= extremeVolLevel, title="Extreme Volatility Regime", message="Volatility percentile has entered the extreme volatility regime.")
````
