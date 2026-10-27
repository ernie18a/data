# Bias Matrix Pro X WTK

- url: https://www.tradingview.com/script/IJZzjf37/
- type: indicator
- pine_id: PUB;aa90606fa4cb4b75bd7a72294130d248
- version: 1.0

## Description

# Bias Matrix Pro X — Cinematic Multi-Timeframe Market Bias Engine

## Overview

**Bias Matrix Pro X** is an advanced multi-timeframe market-bias indicator designed to transform complex trend, momentum, volatility, and timeframe-alignment data into one structured and visually intuitive market overview.

Instead of relying on a single moving average, oscillator, or trend signal, the indicator evaluates several independent technical components on up to six customizable timeframes. Each timeframe receives its own directional score, confidence reading, trend-quality assessment, and alignment status.

These individual results are then combined into a weighted aggregate bias ranging from **−100 to +100**.

The goal is not to predict every market movement or generate automatic entries. The indicator is designed to answer a more important contextual question:

**Is the broader market environment currently bullish, bearish, strongly expanding, or balanced?**

Bias Matrix Pro X can be used as a directional filter for discretionary trading systems, price-action setups, liquidity concepts, breakout strategies, pullback entries, trend-following systems, and multi-timeframe analysis.

---

## Core Concept

Every selected timeframe is analyzed through a combination of:

* Fast and slow EMA structure
* Price location relative to the fast EMA
* Fast EMA slope
* RSI regime
* MACD histogram direction
* Supertrend direction
* ADX-based trend-quality adjustment
* Full component-alignment bonus

Each component produces one of three states:

* **+1:** Bullish
* **0:** Neutral
* **−1:** Bearish

The component states are multiplied by their individual importance weights and combined into a raw directional score.

The score is then adjusted by ADX to account for trend quality.

A directional signal occurring in a strong, established market receives more credibility than the same signal occurring in weak or directionless conditions.

The final score is limited to a range between:

* **+100:** Maximum bullish pressure
* **0:** Balanced or conflicting conditions
* **−100:** Maximum bearish pressure

---

# The Bias Engine

## 1. EMA Structure

The indicator compares the fast EMA with the slow EMA.

Default values:

* Fast EMA: 21
* Slow EMA: 55

Interpretation:

* Fast EMA above slow EMA: bullish
* Fast EMA below slow EMA: bearish
* Equal values: neutral

This component represents the underlying trend structure of the selected timeframe.

Its default weight is **25**, making it the most influential individual component in the engine.

---

## 2. Price Location

The current closing price is compared with the fast EMA.

Interpretation:

* Price above the fast EMA: bullish
* Price below the fast EMA: bearish
* Price equal to the fast EMA: neutral

This determines whether price is currently trading on the supportive or opposing side of the local trend average.

Its default weight is **10**.

Price location reacts faster than the EMA structure and can therefore identify short-term pullbacks or early shifts before the slower trend structure changes.

---

## 3. EMA Slope

The indicator measures the difference between the current fast EMA and its value several bars earlier.

Default slope lookback:

* 2 timeframe bars

Unlike a basic rising-or-falling calculation, the slope component uses an ATR-based neutral zone.

A tiny EMA movement is not automatically classified as a meaningful trend.

The default neutral band is:

* 0.04 × ATR

Interpretation:

* EMA rise greater than the neutral band: bullish
* EMA decline greater than the neutral band: bearish
* Movement inside the neutral band: neutral

This reduces unnecessary signal changes during flat or low-volatility conditions.

Its default weight is **15**.

---

## 4. RSI Regime

RSI is used as a directional regime filter rather than as a traditional overbought or oversold signal.

Default settings:

* RSI length: 14
* Bullish threshold: 55
* Bearish threshold: 45

Interpretation:

* RSI above 55: bullish momentum regime
* RSI below 45: bearish momentum regime
* RSI between 45 and 55: neutral momentum regime

The neutral zone helps prevent the indicator from treating every move above or below RSI 50 as a meaningful directional confirmation.

Its default weight is **10**.

---

## 5. MACD Momentum

The MACD histogram is used to measure directional momentum.

Default settings:

* Fast length: 12
* Slow length: 26
* Signal length: 9

Interpretation:

* MACD histogram above zero: bullish
* MACD histogram below zero: bearish
* MACD histogram equal to zero: neutral

This component helps identify whether momentum supports or opposes the broader EMA structure.

Its default weight is **15**.

---

## 6. Supertrend Direction

Supertrend provides an additional volatility-adjusted directional reading.

Default settings:

* ATR length: 10
* Factor: 2.5

Interpretation:

* Bullish Supertrend direction: bullish
* Bearish Supertrend direction: bearish

Its default weight is **15**.

The Supertrend component can help distinguish trending conditions from ordinary price fluctuations around the moving averages.

---

## 7. Full Alignment Bonus

A bonus is added when the following components all point in the same non-neutral direction:

* EMA structure
* Price location
* EMA slope
* MACD momentum
* Supertrend direction

When all five agree, the engine adds an additional directional score.

Default alignment bonus:

* 10 points

This allows fully synchronized conditions to receive a stronger score than markets where only some components agree.

RSI is still included in the main score, but it is not required for the full-alignment bonus.

---

## 8. ADX Quality Adjustment

ADX does not determine bullish or bearish direction.

Instead, it adjusts the strength of the combined directional score.

Default ADX reference:

* 25

The indicator applies an internal multiplier ranging approximately from:

* 0.65 during weak conditions
* Up to 1.10 during stronger conditions

This means:

* Weak trend conditions reduce the final score.
* Strong trend conditions preserve or slightly enhance it.
* Directional signals in low-quality conditions are treated more cautiously.

The final score is capped between −100 and +100.

---

# Multi-Timeframe Weighting

Bias Matrix Pro X supports up to six customizable timeframes.

Default configuration:

* 5-minute: weight 1.0
* 15-minute: weight 1.5
* 1-hour: weight 2.0
* 4-hour: weight 2.5
* Daily: weight 3.0
* Weekly: weight 3.5

Higher timeframes receive more influence by default because they generally represent broader and more persistent market structure.

The aggregate score is calculated as a weighted average:

**Aggregate Score = Sum of timeframe score × timeframe weight ÷ total valid weight**

This prevents a short-term timeframe from automatically carrying the same influence as a daily or weekly timeframe.

All timeframe values and weights can be customized.

A weight of zero effectively removes that timeframe from the aggregate score.

Duplicate timeframes are ignored to prevent accidental double-counting.

---

# Market Regimes

The aggregate score is converted into five possible market regimes.

With the default thresholds:

## Expansion Bull

Displayed when:

**Aggregate score ≥ +55**

This represents strong bullish multi-timeframe alignment.

Typical characteristics may include:

* Bullish EMA structure
* Positive momentum
* Rising EMA slope
* Supportive Supertrend direction
* Stronger ADX conditions
* Agreement across several weighted timeframes

This does not mean price must move upward immediately. It means the broader technical environment strongly favors bullish continuation compared with bearish continuation.

---

## Bullish

Displayed when:

**Aggregate score is between +18 and +54.9**

The market has a bullish directional advantage, but the alignment is less powerful than an Expansion Bull regime.

This condition may appear during:

* Developing bullish trends
* Pullbacks inside larger bullish structures
* Mixed lower-timeframe momentum
* Bullish higher timeframes with temporary short-term weakness

---

## Balanced

Displayed when:

**Aggregate score is between −18 and +18**

Balanced does not necessarily mean that the market is inactive.

It means that the selected timeframes and technical components do not provide a sufficiently strong directional advantage.

Balanced conditions can occur during:

* Consolidation
* Range-bound price action
* Trend transitions
* Conflicting timeframes
* Low-momentum environments
* Pullbacks against a larger trend

Balanced conditions are often where directional systems may experience lower-quality signals.

---

## Bearish

Displayed when:

**Aggregate score is between −18 and −54.9**

The market has a bearish directional advantage, but full bearish expansion is not yet present.

---

## Expansion Bear

Displayed when:

**Aggregate score ≤ −55**

This represents strong bearish multi-timeframe alignment and directional pressure.

---

# How to Read the Dashboard

The dashboard provides one row for every valid selected timeframe.

## TF

Displays the analyzed timeframe.

Examples:

* 5
* 15
* 60
* 240
* D
* W

TradingView timeframe notation is used.

---

## Weight

Shows how much influence the timeframe has on the aggregate score.

A timeframe with a weight of 3.0 contributes three times as much as a timeframe with a weight of 1.0.

The weight affects the final multi-timeframe result, but it does not change the timeframe’s individual score.

---

## Bias

Displays the directional classification of the timeframe.

* **▲ BULLISH:** Score is above the positive bias threshold
* **▼ BEARISH:** Score is below the negative bias threshold
* **◆ NEUTRAL:** Score remains between the two thresholds

The background color provides immediate visual identification:

* Green: bullish
* Red: bearish
* Amber: neutral

---

## Score

Displays the calculated score for that individual timeframe.

The approximate interpretation is:

* +80 to +100: exceptionally strong bullish alignment
* +55 to +79: strong bullish expansion
* +18 to +54: bullish advantage
* −17 to +17: neutral or conflicting
* −18 to −54: bearish advantage
* −55 to −79: strong bearish expansion
* −80 to −100: exceptionally strong bearish alignment

The score should be interpreted as a directional alignment measurement, not as a probability of a winning trade.

For example, a score of +70 does not mean there is a 70% probability that price will rise.

---

## Power

The Power meter visualizes the absolute size of the timeframe score.

Example:

**████████░░**

A fuller meter means the timeframe has a stronger directional score.

The meter measures strength, while its color shows direction:

* Green meter: bullish power
* Red meter: bearish power
* Amber meter: neutral or balanced condition

A score of +70 and a score of −70 display similar meter lengths, but with different directional colors.

---

## RSI

Displays the current RSI value calculated on that timeframe.

This allows the user to see whether the RSI component is:

* Above the bullish threshold
* Below the bearish threshold
* Inside the neutral zone

---

## ADX

Displays the ADX value and a simplified trend-quality classification.

Possible classifications:

* Low
* Medium
* Good
* High

These labels are calculated relative to the selected ADX reference value.

With the default reference of 25:

* Values well below 25 indicate weaker trend quality.
* Values around 25 indicate established directional conditions.
* Values above the reference indicate stronger trend quality.

ADX measures trend strength, not direction.

A high ADX can occur in both bullish and bearish markets.

---

## Alignment

The Alignment column compares several internal directional components.

### Full

Displayed when the following components all agree in the same non-neutral direction:

* EMA structure
* Price location
* EMA slope
* MACD histogram
* Supertrend

Full alignment represents the highest level of internal directional synchronization.

### Partial

Displayed when EMA structure and price location agree, but the remaining components are not fully synchronized.

### Mixed

Displayed when the internal components conflict.

A bullish timeframe with Mixed alignment may still have a positive score, but the move has less internal agreement than a Full bullish timeframe.

---

# Dashboard Summary

The Summary row combines all valid weighted timeframes.

It displays:

* Number of valid timeframes
* Aggregate bullish, bearish, or neutral state
* Aggregate score
* Aggregate Power meter
* Total bullish timeframe weight
* Total bearish timeframe weight
* Total neutral timeframe weight

The Bull W, Bear W, and Neutral W values represent the sum of timeframe weights classified in each category.

Example:

* Bull W: 7.5
* Bear W: 2.0
* Neutral W: 1.0

This provides more context than a simple count because higher-weight timeframes have greater importance.

---

# Dominance

The live regime label displays a Dominance percentage.

Dominance measures the percentage of total valid timeframe weight belonging to the largest bias group:

* Bullish
* Bearish
* Neutral

Example:

If bullish timeframes represent 70% of the total valid weight, Dominance will display approximately 70%.

Dominance is not the same as the aggregate score.

The aggregate score measures the average directional intensity of all timeframes.

Dominance measures how concentrated the timeframe classifications are in one category.

A market can therefore have:

* High bullish dominance but only a moderate bullish score
* Lower dominance but a strong score from a few heavily weighted timeframes
* High neutral dominance during consolidation

---

# Local Market Reading

The Engine section also displays the current chart timeframe separately.

It includes:

* Local bias
* Local score
* Local RSI
* Local ADX
* Local ADX-quality classification

This makes it possible to compare the current execution timeframe with the broader multi-timeframe environment.

Example:

* Aggregate regime: Expansion Bull
* Local timeframe: Neutral

This may indicate that the broader market remains bullish while the execution timeframe is currently consolidating or pulling back.

Another example:

* Aggregate regime: Bearish
* Local timeframe: Bullish

This may represent a short-term countertrend rally against a broader bearish environment.

---

# Chart Visuals

## Trend Ribbon

The chart displays the fast and slow EMAs from the current chart timeframe.

The area between them is filled to create a visual trend ribbon.

The ribbon color is based on the aggregate multi-timeframe regime:

* Green: bullish aggregate environment
* Red: bearish aggregate environment
* Amber: balanced environment

Important distinction:

The EMA values come from the current chart timeframe, while their color reflects the combined multi-timeframe result.

---

## Supertrend Aura

The current chart timeframe’s Supertrend line is displayed as a softer secondary trend layer.

Its color also follows the aggregate market regime.

This creates a visual connection between local price structure and the broader multi-timeframe bias.

---

## Chart Glow

When enabled, the chart background receives a subtle regime color:

* Green glow: bullish
* Red glow: bearish
* Amber glow: balanced

The glow is deliberately transparent so it can provide directional context without hiding price action.

---

## Candle Tint

When enabled, candle colors are tinted according to the aggregate regime.

The tint intensity is influenced by the local timeframe’s score strength.

This creates a combined visual effect:

* Direction comes from the aggregate multi-timeframe bias.
* Tint intensity is influenced by local confidence.

---

## Bias Shift Markers

The indicator marks changes in the aggregate bias classification.

### BIAS+

Appears when the aggregate state changes into bullish territory.

### BIAS−

Appears when the aggregate state changes into bearish territory.

### Neutral Marker

A small amber marker appears when the aggregate state returns to neutral.

These markers identify regime transitions. They are not intended to be used as standalone entry signals.

A bias shift can occur after part of a market move has already developed because the engine requires sufficient technical confirmation.

---

## Live Regime Label

The label near the most recent candle displays:

* Indicator name
* Current market regime
* Aggregate score
* Dominance percentage

This provides a compact real-time overview without requiring the user to inspect the full dashboard.

---

# Dark Mode and Light Mode

Bias Matrix Pro X includes two complete dashboard themes.

## Dark Mode

Designed for dark TradingView charts.

It uses:

* Deep navy backgrounds
* High-contrast text
* Gold title elements
* Soft green, red, amber, and blue status panels

## Light Mode

Designed for white or light TradingView layouts.

It uses:

* Light neutral backgrounds
* Dark readable text
* Softer transparent status colors
* Reduced visual harshness

The selected theme affects the dashboard and live regime label.

Users can also customize:

* Dashboard position
* Dashboard text size
* Dashboard visibility
* Chart glow
* Candle tint
* Trend ribbon
* Live regime label

---

# Confirmed Higher-Timeframe Mode

The setting **Use confirmed higher-TF values only** is enabled by default.

When enabled, higher-timeframe readings use the most recently completed candle from each requested higher timeframe.

This provides stable historical and real-time higher-timeframe values.

Example:

On a 5-minute chart, the 4-hour row will use the last fully completed 4-hour candle rather than the currently developing 4-hour candle.

Advantages:

* More stable multi-timeframe readings
* Reduced higher-timeframe repainting
* More reliable historical comparison
* Better suitability for rule-based filters

Trade-off:

* The higher-timeframe reading updates only after the higher-timeframe candle closes.
* It is intentionally one completed higher-timeframe candle behind the live developing candle.

The current chart timeframe still uses the active chart data and can change until the current chart candle closes.

---

## Unconfirmed Higher-Timeframe Mode

When confirmed higher-timeframe values are disabled, the indicator uses the currently developing higher-timeframe candle.

Advantages:

* Faster response to developing market changes
* Earlier recognition of possible regime shifts

Trade-offs:

* Higher-timeframe values can change before the candle closes.
* Historical readings after a chart reload may differ from what was visible during the live candle.
* Signals are less stable and should be treated as provisional.

For systematic or confirmation-based use, confirmed higher-timeframe mode is generally the more conservative setting.

---

# Lower-Timeframe Protection

The indicator intentionally blocks requested timeframes that are lower than the current chart timeframe.

Example:

* Current chart: 15 minutes
* Requested timeframe: 5 minutes

The 5-minute row will display:

**LTF blocked**

This is intentional.

A simple higher-timeframe request method does not provide a complete and reliable lower-timeframe evaluation when used from a larger chart timeframe.

To analyze the default 5-minute timeframe, the chart should therefore be set to 5 minutes or lower.

Recommended rule:

**Use a chart timeframe that is equal to or lower than the smallest selected dashboard timeframe.**

---

# Suggested Usage

Bias Matrix Pro X is designed primarily as a context and filtering tool.

## Trend-Following Example

A trader may choose to:

* Look for long setups only during Bullish or Expansion Bull regimes.
* Look for short setups only during Bearish or Expansion Bear regimes.
* Reduce activity during Balanced conditions.
* Require the execution timeframe to move back into alignment with the aggregate bias before entering.

---

## Pullback Example

Possible bullish sequence:

1. Aggregate regime is Bullish or Expansion Bull.
2. Higher timeframes remain bullish.
3. Local timeframe becomes Neutral or temporarily Bearish during a pullback.
4. Local momentum begins turning bullish again.
5. The trader applies a separate entry model.

The indicator does not identify the exact pullback entry. It provides the directional environment in which the trader can evaluate the setup.

---

## Breakout Example

Before taking a bullish breakout, a trader may check whether:

* Aggregate score is positive
* Dominance favors bullish timeframes
* Higher-weight timeframes are bullish
* ADX quality is Good or High
* Alignment is Full or Partial
* The local timeframe is not strongly opposing the breakout

---

## Countertrend Warning

If a trader identifies a long setup while the indicator displays:

* Expansion Bear
* Strong negative aggregate score
* High bearish dominance
* Bearish higher-timeframe alignment

The setup is occurring against the broader technical environment.

This does not automatically make the trade invalid, but it identifies the trade as countertrend and potentially higher risk.

---

# Recommended Starting Configuration

For intraday trading, the default configuration provides a broad hierarchy:

* 5-minute: execution context
* 15-minute: short-term structure
* 1-hour: intraday directional structure
* 4-hour: higher-timeframe trend
* Daily: major market regime
* Weekly: long-term context

Users should adjust the selected timeframes and weights to match their trading horizon.

### Scalping Example

* 1-minute chart
* 3-minute
* 5-minute
* 15-minute
* 30-minute
* 1-hour
* 4-hour

Higher weights can be assigned to the 15-minute, 1-hour, and 4-hour timeframes.

### Swing-Trading Example

* 1-hour or 4-hour chart
* 4-hour
* Daily
* Weekly
* Monthly

Lower requested timeframes should not be used below the active chart timeframe.

---

# Important Settings

## Bias Threshold

Controls how much positive or negative score is required before a timeframe is classified as directional.

Default:

* 18

Higher values:

* Produce fewer bullish and bearish classifications
* Increase the neutral range
* Require stronger alignment

Lower values:

* React faster
* Produce more directional classifications
* May create more frequent regime changes

---

## Strong Bias Threshold

Defines when Bullish or Bearish becomes an Expansion regime.

Default:

* 55

This setting affects the regime name and visual classification.

It does not change the basic bullish or bearish threshold.

---

## Component Weights

Every technical component can be weighted independently.

Increasing a component’s weight gives it more influence over each timeframe score.

Examples:

* Increasing EMA Structure favors slower trend confirmation.
* Increasing Price vs Fast EMA makes the system more reactive to local price changes.
* Increasing EMA Slope gives more importance to trend acceleration.
* Increasing RSI emphasizes momentum regime.
* Increasing MACD emphasizes momentum direction.
* Increasing Supertrend emphasizes volatility-adjusted trend direction.
* Increasing Full Alignment Bonus rewards synchronized conditions more strongly.

Weights should be modified carefully.

Extreme weighting can cause one component to dominate the engine and reduce the value of combining several independent measurements.

---

## Timeframe Weights

Timeframe weights determine influence over the final aggregate score.

They do not affect the internal score of the individual timeframe.

A higher weight means the timeframe has greater influence over:

* Aggregate score
* Aggregate bias
* Bullish, bearish, and neutral weight totals
* Dominance

---

# Practical Interpretation Guidelines

## Strongest Bullish Environment

Look for a combination such as:

* Expansion Bull regime
* Positive score above +55
* High bullish dominance
* Higher-weight timeframes bullish
* Good or High ADX quality
* Full alignment on several timeframes
* Local timeframe turning bullish after a pullback

---

## Strongest Bearish Environment

Look for:

* Expansion Bear regime
* Score below −55
* High bearish dominance
* Higher-weight timeframes bearish
* Good or High ADX quality
* Full bearish alignment
* Local timeframe turning bearish after a corrective rally

---

## Caution Environment

Exercise caution when:

* Aggregate regime is Balanced
* Dominance is low
* Higher and lower timeframes conflict
* Most rows display Mixed alignment
* ADX quality is Low
* The aggregate bias changes frequently
* The selected chart timeframe is too high for the configured lower timeframes

---

# Important Limitations

Bias Matrix Pro X is a technical analysis tool, not a complete trading system.

It does not include:

* Automatic entries
* Stop-loss placement
* Take-profit placement
* Position sizing
* Risk management
* Fundamental analysis
* News-event filtering
* Liquidity analysis
* Market-session filtering
* Volume-profile analysis
* Guaranteed non-lagging signals

The indicator combines several lagging and reactive technical measurements.

Because the engine requires confirmation, regime changes may occur after a market move has already started.

Strong bullish conditions can appear close to a temporary top.

Strong bearish conditions can appear close to a temporary bottom.

A high score describes technical alignment, not guaranteed future direction.

The indicator should therefore be combined with:

* A defined entry model
* Clear invalidation logic
* Position sizing
* Maximum-risk rules
* Session awareness
* Economic-news awareness
* Independent testing

---

# Repainting and Real-Time Behavior

With confirmed higher-timeframe mode enabled:

* Completed higher-timeframe readings remain stable.
* Historical higher-timeframe values are based on completed candles.
* The current chart timeframe continues to update while its active candle is open.
* A local score or aggregate score may still change before the current chart candle closes.

With confirmed higher-timeframe mode disabled:

* Developing higher-timeframe values can change during the active higher-timeframe candle.
* Bias states and chart visuals may update before candle confirmation.
* Historical behavior after reloading the chart may differ from what was observed intrabar.

Users who require stable confirmation should evaluate signals after the chart candle closes and keep confirmed higher-timeframe mode enabled.

---

# Final Notes

Bias Matrix Pro X was created to provide a structured visual answer to three questions:

1. **What is the directional condition of each important timeframe?**
2. **How strong and internally aligned is that condition?**
3. **What is the combined weighted market regime?**

The indicator is intentionally information-rich, but the main reading remains simple:

* Green favors bullish conditions.
* Red favors bearish conditions.
* Amber represents balance or conflict.
* Higher absolute scores represent stronger directional alignment.
* Higher dominance represents broader agreement between the selected timeframes.
* Full alignment represents stronger internal synchronization.
* ADX indicates the quality of the directional environment.

Use the indicator as a market-context framework, not as a standalone promise of future performance.

---

## Disclaimer

This indicator is provided for educational and informational purposes only.

It does not constitute financial advice, investment advice, or a recommendation to buy or sell any financial instrument.

Past performance and historical technical alignment do not guarantee future results.

Trading involves substantial risk, including the possible loss of capital. Every user is responsible for conducting independent research, testing the indicator on the relevant market and timeframe, and applying appropriate risk management.

## Source Code

````pine
//@version=6
indicator("Bias Matrix Pro X — Cinematic MTF Bias Engine", shorttitle="Bias Matrix Pro X", overlay=true, max_labels_count=500, dynamic_requests=true)

// ═════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═════════════════════════════════════════════════════════════════════════════
groupTheme = "Theme & Layout"
themeMode = input.string("Dark", "Dashboard Theme", options=["Dark", "Light"], group=groupTheme)
panelY    = input.string("top", "Dashboard Vertical", options=["top","middle","bottom"], group=groupTheme, inline="p")
panelX    = input.string("right", "Horizontal", options=["left","center","right"], group=groupTheme, inline="p")
showDashboard = input.bool(true, "Show Dashboard", group=groupTheme)
showChartGlow = input.bool(true, "Chart Glow", group=groupTheme)
showCandleTint = input.bool(true, "Tint Candles", group=groupTheme)
showRibbon = input.bool(true, "Trend Ribbon", group=groupTheme)
showRegimeLabel = input.bool(true, "Live Regime Label", group=groupTheme)
textSize = input.string("small", "Dashboard Text Size", options=["very small","small","normal","large"], group=groupTheme)

groupEngine = "Bias Engine"
confirmedHTF = input.bool(true, "Use confirmed higher-TF values only", group=groupEngine)
biasThreshold = input.float(18.0, "Bias threshold", step=0.5, minval=1, group=groupEngine)
strongThreshold = input.float(55.0, "Strong bias threshold", step=0.5, minval=1, group=groupEngine)
slopeLookback = input.int(2, "EMA slope lookback", minval=1, group=groupEngine)
slopeNeutralAtr = input.float(0.04, "EMA slope neutral band (ATR multiple)", minval=0.0, step=0.01, group=groupEngine)
rsiBull = input.float(55.0, "RSI bullish threshold", minval=50, maxval=80, step=0.5, group=groupEngine)
rsiBear = input.float(45.0, "RSI bearish threshold", minval=20, maxval=50, step=0.5, group=groupEngine)
adxReference = input.float(25.0, "ADX quality reference", minval=5, step=0.5, group=groupEngine)

groupWeights = "Component Weights"
wTrend = input.float(25, "EMA structure", minval=0, step=0.5, group=groupWeights)
wPrice = input.float(10, "Price vs fast EMA", minval=0, step=0.5, group=groupWeights)
wSlope = input.float(15, "EMA slope", minval=0, step=0.5, group=groupWeights)
wRsi   = input.float(10, "RSI regime", minval=0, step=0.5, group=groupWeights)
wMacd  = input.float(15, "MACD momentum", minval=0, step=0.5, group=groupWeights)
wST    = input.float(15, "Supertrend direction", minval=0, step=0.5, group=groupWeights)
wAlign = input.float(10, "Full alignment bonus", minval=0, step=0.5, group=groupWeights)

groupMA = "MA & Trend Settings"
fastLen = input.int(21, "Fast EMA", minval=1, group=groupMA, inline="ma")
slowLen = input.int(55, "Slow EMA", minval=2, group=groupMA, inline="ma")
atrLen = input.int(14, "ATR", minval=1, group=groupMA, inline="ma")

groupMomentum = "Momentum Settings"
rsiLen = input.int(14, "RSI Length", minval=1, group=groupMomentum, inline="rsi")
macdFast = input.int(12, "MACD Fast", minval=1, group=groupMomentum, inline="macd")
macdSlow = input.int(26, "Slow", minval=1, group=groupMomentum, inline="macd")
macdSignal = input.int(9, "Signal", minval=1, group=groupMomentum, inline="macd")
diLen = input.int(14, "DI Length", minval=1, group=groupMomentum, inline="adx")
adxSmooth = input.int(14, "ADX Smooth", minval=1, group=groupMomentum, inline="adx")

groupST = "Supertrend Settings"
stAtrLen = input.int(10, "ST ATR Length", minval=1, group=groupST, inline="st")
stFactor = input.float(2.5, "ST Factor", minval=0.1, step=0.1, group=groupST, inline="st")

groupTF = "Timeframes & Weights"
tf1 = input.string("5",   "TF 1", group=groupTF, inline="tf1")
wt1 = input.float(1.0,    "W",    group=groupTF, inline="tf1", step=0.25)
tf2 = input.string("15",  "TF 2", group=groupTF, inline="tf2")
wt2 = input.float(1.5,    "W",    group=groupTF, inline="tf2", step=0.25)
tf3 = input.string("60",  "TF 3", group=groupTF, inline="tf3")
wt3 = input.float(2.0,    "W",    group=groupTF, inline="tf3", step=0.25)
tf4 = input.string("240", "TF 4", group=groupTF, inline="tf4")
wt4 = input.float(2.5,    "W",    group=groupTF, inline="tf4", step=0.25)
tf5 = input.string("D",   "TF 5", group=groupTF, inline="tf5")
wt5 = input.float(3.0,    "W",    group=groupTF, inline="tf5", step=0.25)
tf6 = input.string("W",   "TF 6", group=groupTF, inline="tf6")
wt6 = input.float(3.5,    "W",    group=groupTF, inline="tf6", step=0.25)

// ═════════════════════════════════════════════════════════════════════════════
// VALIDATION
// ═════════════════════════════════════════════════════════════════════════════
if barstate.isfirst and fastLen >= slowLen
    runtime.error("Fast EMA must be smaller than Slow EMA.")
if barstate.isfirst and rsiBear >= rsiBull
    runtime.error("RSI bearish threshold must be below RSI bullish threshold.")

// ═════════════════════════════════════════════════════════════════════════════
// THEME SYSTEM
// ═════════════════════════════════════════════════════════════════════════════
string panelPosition = switch
    panelX == "left"   and panelY == "top"    => position.top_left
    panelX == "left"   and panelY == "middle" => position.middle_left
    panelX == "left"   and panelY == "bottom" => position.bottom_left
    panelX == "center" and panelY == "top"    => position.top_center
    panelX == "center" and panelY == "middle" => position.middle_center
    panelX == "center" and panelY == "bottom" => position.bottom_center
    panelX == "right"  and panelY == "top"    => position.top_right
    panelX == "right"  and panelY == "middle" => position.middle_right
    => position.bottom_right

string textSz = switch textSize
    "very small" => size.tiny
    "small"      => size.small
    "normal"     => size.normal
    => size.large

bool isDark = themeMode == "Dark"

color C_BG_MAIN   = isDark ? color.rgb(13, 17, 26)  : color.rgb(244, 247, 252)
color C_BG_HEAD   = isDark ? color.rgb(25, 31, 46)  : color.rgb(226, 233, 244)
color C_BG_CELL   = isDark ? color.rgb(18, 24, 36)  : color.rgb(252, 253, 255)
color C_BG_ALT    = isDark ? color.rgb(22, 29, 43)  : color.rgb(239, 244, 251)
color C_BORDER    = isDark ? color.rgb(55, 68, 92)  : color.rgb(186, 197, 215)
color C_TEXT      = isDark ? color.rgb(234, 239, 247): color.rgb(28, 34, 43)
color C_SUBTEXT   = isDark ? color.rgb(146, 158, 180): color.rgb(86, 98, 116)

color C_BULL      = color.rgb(0, 204, 136)
color C_BULL_SOFT = color.new(C_BULL, isDark ? 78 : 86)
color C_BEAR      = color.rgb(255, 92, 122)
color C_BEAR_SOFT = color.new(C_BEAR, isDark ? 78 : 86)
color C_NEUTRAL   = color.rgb(255, 184, 76)
color C_NEUTRAL_SOFT = color.new(C_NEUTRAL, isDark ? 80 : 86)
color C_INFO      = color.rgb(76, 161, 255)
color C_INFO_SOFT = color.new(C_INFO, isDark ? 80 : 87)
color C_GOLD      = color.rgb(255, 208, 94)

biasBg(int b) =>
    b == 1 ? C_BULL_SOFT : b == -1 ? C_BEAR_SOFT : C_NEUTRAL_SOFT

biasText(int b) =>
    b == 1 ? "BULLISH" : b == -1 ? "BEARISH" : "NEUTRAL"

regimeText(float score) =>
    score >= strongThreshold ? "EXPANSION BULL" :
     score >= biasThreshold ? "BULLISH" :
     score <= -strongThreshold ? "EXPANSION BEAR" :
     score <= -biasThreshold ? "BEARISH" : "BALANCED"

regimeColor(float score) =>
    score >= strongThreshold ? C_BULL :
     score >= biasThreshold ? color.new(C_BULL, 0) :
     score <= -strongThreshold ? C_BEAR :
     score <= -biasThreshold ? color.new(C_BEAR, 0) : C_NEUTRAL

meter(float val) =>
    int steps = int(math.round(math.min(math.abs(val), 100) / 10))
    string out = ""
    for i = 0 to 9
        out += i < steps ? "█" : "░"
    out

stateIcon(int b) =>
    b == 1 ? "▲" : b == -1 ? "▼" : "◆"

qualityIcon(float adxVal) =>
    adxVal >= adxReference * 1.15 ? "High" :
     adxVal >= adxReference ? "Good" :
     adxVal >= adxReference * 0.70 ? "Medium" : "Low"

// ═════════════════════════════════════════════════════════════════════════════
// CORE ENGINE
// ═════════════════════════════════════════════════════════════════════════════
calcCore() =>
    float emaFast = ta.ema(close, fastLen)
    float emaSlow = ta.ema(close, slowLen)
    float atrVal = ta.atr(atrLen)
    float slopeVal = emaFast - emaFast[slopeLookback]
    float slopeBand = atrVal * slopeNeutralAtr

    float rsiVal = ta.rsi(close, rsiLen)
    [_, _, macdHist] = ta.macd(close, macdFast, macdSlow, macdSignal)
    [stLine, stDir] = ta.supertrend(stFactor, stAtrLen)
    [_, _, adxVal] = ta.dmi(diLen, adxSmooth)

    int trendState = emaFast > emaSlow ? 1 : emaFast < emaSlow ? -1 : 0
    int priceState = close > emaFast ? 1 : close < emaFast ? -1 : 0
    int slopeState = slopeVal > slopeBand ? 1 : slopeVal < -slopeBand ? -1 : 0
    int rsiState = rsiVal > rsiBull ? 1 : rsiVal < rsiBear ? -1 : 0
    int macdState = macdHist > 0 ? 1 : macdHist < 0 ? -1 : 0
    int stState = stDir < 0 ? 1 : stDir > 0 ? -1 : 0

    float rawScore = trendState * wTrend + priceState * wPrice + slopeState * wSlope + rsiState * wRsi + macdState * wMacd + stState * wST

    int fullAlign = trendState != 0 and trendState == priceState and trendState == slopeState and trendState == macdState and trendState == stState ? trendState : 0
    rawScore += fullAlign * wAlign

    float qualityMultRaw = 0.65 + (math.min(adxVal, adxReference) / adxReference) * 0.45
    float qualityMult = math.max(math.min(qualityMultRaw, 1.10), 0.65)
    float score = math.max(math.min(rawScore * qualityMult, 100), -100)

    int bias = score >= biasThreshold ? 1 : score <= -biasThreshold ? -1 : 0
    float conf = math.abs(score)

    [score, bias, conf, rsiVal, adxVal, trendState, priceState, slopeState, macdState, stState, emaFast, emaSlow, stLine]

calcCorePrev() =>
    [score, bias, conf, rsiVal, adxVal, trendState, priceState, slopeState, macdState, stState, emaFast, emaSlow, stLine] = calcCore()
    [score[1], bias[1], conf[1], rsiVal[1], adxVal[1], trendState[1], priceState[1], slopeState[1], macdState[1], stState[1], emaFast[1], emaSlow[1], stLine[1]]

getTfData(string tf) =>
    int chartSec = timeframe.in_seconds()
    int tfSec = timeframe.in_seconds(tf)

    if tfSec < chartSec
        [float(na), int(na), float(na), float(na), float(na), int(na), int(na), int(na), int(na), int(na), float(na), float(na), float(na), false, true]
    else if tfSec == chartSec
        [score, bias, conf, rsiVal, adxVal, trendState, priceState, slopeState, macdState, stState, emaFast, emaSlow, stLine] = calcCore()
        [score, bias, conf, rsiVal, adxVal, trendState, priceState, slopeState, macdState, stState, emaFast, emaSlow, stLine, true, false]
    else
        if confirmedHTF
            [score, bias, conf, rsiVal, adxVal, trendState, priceState, slopeState, macdState, stState, emaFast, emaSlow, stLine] =
                 request.security(syminfo.tickerid, tf, calcCorePrev(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
            [score, bias, conf, rsiVal, adxVal, trendState, priceState, slopeState, macdState, stState, emaFast, emaSlow, stLine, true, false]
        else
            [score, bias, conf, rsiVal, adxVal, trendState, priceState, slopeState, macdState, stState, emaFast, emaSlow, stLine] =
                 request.security(syminfo.tickerid, tf, calcCore(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
            [score, bias, conf, rsiVal, adxVal, trendState, priceState, slopeState, macdState, stState, emaFast, emaSlow, stLine, true, false]

// ═════════════════════════════════════════════════════════════════════════════
// TF STORAGE
// ═════════════════════════════════════════════════════════════════════════════
var string[] tfList = array.new_string()
var float[] tfWeightList = array.new_float()

if barstate.isfirst
    array.clear(tfList)
    array.clear(tfWeightList)

    if str.length(tf1) > 0 and not array.includes(tfList, tf1)
        array.push(tfList, tf1)
        array.push(tfWeightList, wt1)
    if str.length(tf2) > 0 and not array.includes(tfList, tf2)
        array.push(tfList, tf2)
        array.push(tfWeightList, wt2)
    if str.length(tf3) > 0 and not array.includes(tfList, tf3)
        array.push(tfList, tf3)
        array.push(tfWeightList, wt3)
    if str.length(tf4) > 0 and not array.includes(tfList, tf4)
        array.push(tfList, tf4)
        array.push(tfWeightList, wt4)
    if str.length(tf5) > 0 and not array.includes(tfList, tf5)
        array.push(tfList, tf5)
        array.push(tfWeightList, wt5)
    if str.length(tf6) > 0 and not array.includes(tfList, tf6)
        array.push(tfList, tf6)
        array.push(tfWeightList, wt6)

// ═════════════════════════════════════════════════════════════════════════════
// AGGREGATION
// ═════════════════════════════════════════════════════════════════════════════
[localScore, localBias, localConf, localRsi, localAdx, localTrendState, localPriceState, localSlopeState, localMacdState, localStState, localFast, localSlow, localStLine] = calcCore()

float weightedScoreSum = 0.0
float weightSum = 0.0
float bullWeight = 0.0
float bearWeight = 0.0
float neutralWeight = 0.0
int validRows = 0
int blockedRows = 0

if array.size(tfList) > 0
    for i = 0 to array.size(tfList) - 1
        string tf = array.get(tfList, i)
        float wtf = array.get(tfWeightList, i)

        [score, bias, conf, rsiVal, adxVal, trendState, priceState, slopeState, macdState, stState, emaFast, emaSlow, stLine, valid, blockedLower] = getTfData(tf)

        if blockedLower
            blockedRows += 1
        if valid and not na(score) and wtf > 0
            validRows += 1
            weightedScoreSum += score * wtf
            weightSum += wtf
            bullWeight += bias == 1 ? wtf : 0
            bearWeight += bias == -1 ? wtf : 0
            neutralWeight += bias == 0 ? wtf : 0

float aggregateScore = weightSum > 0 ? weightedScoreSum / weightSum : 0.0
int aggregateBias = aggregateScore >= biasThreshold ? 1 : aggregateScore <= -biasThreshold ? -1 : 0
float dominance = weightSum > 0 ? math.max(bullWeight, math.max(bearWeight, neutralWeight)) / weightSum * 100 : 0.0
string marketRegime = regimeText(aggregateScore)
color marketColor = regimeColor(aggregateScore)

// ═════════════════════════════════════════════════════════════════════════════
// CHART VISUALS
// ═════════════════════════════════════════════════════════════════════════════
float ribbonTop = math.max(localFast, localSlow)
float ribbonBottom = math.min(localFast, localSlow)

plotFast = plot(showRibbon ? localFast : na, "Fast EMA", color=color.new(marketColor, 0), linewidth=2)
plotSlow = plot(showRibbon ? localSlow : na, "Slow EMA", color=color.new(marketColor, 38), linewidth=3)
fill(plotFast, plotSlow, color=color.new(marketColor, 84), title="Bias Ribbon Fill")

plot(showRibbon ? localStLine : na, "Supertrend Aura", color=color.new(marketColor, 65), linewidth=2, style=plot.style_linebr)

bgcolor(showChartGlow ? color.new(marketColor, 93) : na)

barcolor(showCandleTint ? color.new(marketColor, 65 - int(math.min(localConf, 60))) : na)

bool bullShift = aggregateBias == 1 and aggregateBias[1] != 1
bool bearShift = aggregateBias == -1 and aggregateBias[1] != -1
bool neutralShift = aggregateBias == 0 and aggregateBias[1] != 0

plotshape(bullShift, title="Bull Bias Shift", style=shape.labelup, location=location.belowbar, color=color.new(C_BULL, 0), text="✦ BIAS+", textcolor=color.white, size=size.tiny)
plotshape(bearShift, title="Bear Bias Shift", style=shape.labeldown, location=location.abovebar, color=color.new(C_BEAR, 0), text="✦ BIAS-", textcolor=color.white, size=size.tiny)
plotshape(neutralShift, title="Neutral Bias Shift", style=shape.circle, location=location.bottom, color=color.new(C_NEUTRAL, 0), size=size.tiny)

var label regimeLbl = na
if showRegimeLabel and barstate.islast
    label.delete(regimeLbl)
    string header = "BIAS MATRIX PRO X"
    string body = marketRegime + "  |  Score " + str.tostring(aggregateScore, "#.0") + "  |  Dominance " + str.tostring(dominance, "#") + "%"
    regimeLbl := label.new(bar_index, high + ta.atr(14) * 0.6, header + "\n" + body, style=label.style_label_down, color=color.new(C_BG_HEAD, 0), textcolor=C_TEXT, size=size.small)

// ═════════════════════════════════════════════════════════════════════════════
// DASHBOARD
// ═════════════════════════════════════════════════════════════════════════════
var table dash = table.new(panelPosition, 8, 16, frame_color=C_BORDER, frame_width=1, border_color=C_BORDER, border_width=1)

rowFillColor(int row) =>
    row % 2 == 0 ? C_BG_CELL : C_BG_ALT

if barstate.islast and showDashboard
    // Title
    table.cell(dash, 0, 0, "BIAS MATRIX PRO X", text_color=C_GOLD, text_size=textSz, bgcolor=C_BG_HEAD)
    table.cell(dash, 1, 0, "Cinematic MTF Bias Engine", text_color=C_SUBTEXT, text_size=textSz, bgcolor=C_BG_HEAD)
    table.cell(dash, 2, 0, "Theme", text_color=C_SUBTEXT, text_size=textSz, bgcolor=C_BG_HEAD)
    table.cell(dash, 3, 0, themeMode, text_color=C_TEXT, text_size=textSz, bgcolor=C_BG_HEAD)
    table.cell(dash, 4, 0, "Regime", text_color=C_SUBTEXT, text_size=textSz, bgcolor=C_BG_HEAD)
    table.cell(dash, 5, 0, marketRegime, text_color=C_TEXT, text_size=textSz, bgcolor=color.new(marketColor, 70))
    table.cell(dash, 6, 0, "Score", text_color=C_SUBTEXT, text_size=textSz, bgcolor=C_BG_HEAD)
    table.cell(dash, 7, 0, str.tostring(aggregateScore, "#.0"), text_color=C_TEXT, text_size=textSz, bgcolor=color.new(marketColor, 70))

    // Header
    table.cell(dash, 0, 1, "TF", text_color=C_TEXT, text_size=textSz, bgcolor=C_BG_MAIN)
    table.cell(dash, 1, 1, "Weight", text_color=C_TEXT, text_size=textSz, bgcolor=C_BG_MAIN)
    table.cell(dash, 2, 1, "Bias", text_color=C_TEXT, text_size=textSz, bgcolor=C_BG_MAIN)
    table.cell(dash, 3, 1, "Score", text_color=C_TEXT, text_size=textSz, bgcolor=C_BG_MAIN)
    table.cell(dash, 4, 1, "Power", text_color=C_TEXT, text_size=textSz, bgcolor=C_BG_MAIN)
    table.cell(dash, 5, 1, "RSI", text_color=C_TEXT, text_size=textSz, bgcolor=C_BG_MAIN)
    table.cell(dash, 6, 1, "ADX", text_color=C_TEXT, text_size=textSz, bgcolor=C_BG_MAIN)
    table.cell(dash, 7, 1, "Alignment", text_color=C_TEXT, text_size=textSz, bgcolor=C_BG_MAIN)

    int row = 2
    if array.size(tfList) > 0
        for i = 0 to array.size(tfList) - 1
            string tf = array.get(tfList, i)
            float wtf = array.get(tfWeightList, i)

            [score, bias, conf, rsiVal, adxVal, trendState, priceState, slopeState, macdState, stState, emaFast, emaSlow, stLine, valid, blockedLower] = getTfData(tf)

            string alignTxt = valid ? (trendState == priceState and trendState == slopeState and trendState == stState and trendState == macdState and trendState != 0 ? "Full" : trendState == priceState and trendState != 0 ? "Partial" : "Mixed") : blockedLower ? "Blocked" : "No data"
            string biasTxt = valid ? stateIcon(bias) + " " + biasText(bias) : blockedLower ? "LTF blocked" : "No data"
            color rowBg = rowFillColor(row)
            color biasColor = valid ? biasBg(bias) : C_INFO_SOFT
            color scoreColor = valid ? color.new(regimeColor(score), 75) : C_INFO_SOFT

            table.cell(dash, 0, row, tf, text_color=C_TEXT, text_size=textSz, bgcolor=rowBg)
            table.cell(dash, 1, row, str.tostring(wtf, "#.##"), text_color=C_TEXT, text_size=textSz, bgcolor=rowBg)
            table.cell(dash, 2, row, biasTxt, text_color=C_TEXT, text_size=textSz, bgcolor=biasColor)
            table.cell(dash, 3, row, valid ? str.tostring(score, "#.0") : "—", text_color=C_TEXT, text_size=textSz, bgcolor=scoreColor)
            table.cell(dash, 4, row, valid ? meter(conf) : "░░░░░░░░░░", text_color=valid ? regimeColor(score) : C_SUBTEXT, text_size=textSz, bgcolor=rowBg)
            table.cell(dash, 5, row, valid ? str.tostring(rsiVal, "#.0") : "—", text_color=C_TEXT, text_size=textSz, bgcolor=rowBg)
            table.cell(dash, 6, row, valid ? str.tostring(adxVal, "#.0") + " / " + qualityIcon(adxVal) : "—", text_color=C_TEXT, text_size=textSz, bgcolor=rowBg)
            table.cell(dash, 7, row, alignTxt, text_color=C_TEXT, text_size=textSz, bgcolor=rowBg)
            row += 1

    // Summary rows
    table.cell(dash, 0, row, "Summary", text_color=C_GOLD, text_size=textSz, bgcolor=C_BG_HEAD)
    table.cell(dash, 1, row, "Valid " + str.tostring(validRows), text_color=C_TEXT, text_size=textSz, bgcolor=C_BG_HEAD)
    table.cell(dash, 2, row, biasText(aggregateBias), text_color=C_TEXT, text_size=textSz, bgcolor=biasBg(aggregateBias))
    table.cell(dash, 3, row, str.tostring(aggregateScore, "#.0"), text_color=C_TEXT, text_size=textSz, bgcolor=color.new(marketColor, 72))
    table.cell(dash, 4, row, meter(math.abs(aggregateScore)), text_color=marketColor, text_size=textSz, bgcolor=C_BG_HEAD)
    table.cell(dash, 5, row, "Bull W " + str.tostring(bullWeight, "#.##"), text_color=C_TEXT, text_size=textSz, bgcolor=C_BG_HEAD)
    table.cell(dash, 6, row, "Bear W " + str.tostring(bearWeight, "#.##"), text_color=C_TEXT, text_size=textSz, bgcolor=C_BG_HEAD)
    table.cell(dash, 7, row, "Neutral W " + str.tostring(neutralWeight, "#.##"), text_color=C_TEXT, text_size=textSz, bgcolor=C_BG_HEAD)
    row += 1

    string infoText1 = "Confirmed HTF: " + (confirmedHTF ? "Yes" : "No") + " | Lower-TF Blocked: " + str.tostring(blockedRows)
    string infoText2 = "Engine = EMA structure + price location + slope + RSI + MACD + Supertrend + ADX quality"

    table.cell(dash, 0, row, "Engine", text_color=C_SUBTEXT, text_size=textSz, bgcolor=C_BG_MAIN)
    table.cell(dash, 1, row, infoText1, text_color=C_TEXT, text_size=textSz, bgcolor=C_BG_MAIN)
    table.cell(dash, 2, row, "Local", text_color=C_SUBTEXT, text_size=textSz, bgcolor=C_BG_MAIN)
    table.cell(dash, 3, row, biasText(localBias), text_color=C_TEXT, text_size=textSz, bgcolor=biasBg(localBias))
    table.cell(dash, 4, row, str.tostring(localScore, "#.0"), text_color=C_TEXT, text_size=textSz, bgcolor=color.new(regimeColor(localScore), 72))
    table.cell(dash, 5, row, "RSI " + str.tostring(localRsi, "#.0"), text_color=C_TEXT, text_size=textSz, bgcolor=C_BG_MAIN)
    table.cell(dash, 6, row, "ADX " + str.tostring(localAdx, "#.0"), text_color=C_TEXT, text_size=textSz, bgcolor=C_BG_MAIN)
    table.cell(dash, 7, row, qualityIcon(localAdx), text_color=C_TEXT, text_size=textSz, bgcolor=C_BG_MAIN)

    table.cell(dash, 0, row + 1, "Notes", text_color=C_SUBTEXT, text_size=textSz, bgcolor=C_BG_CELL)
    table.cell(dash, 1, row + 1, infoText2, text_color=C_TEXT, text_size=textSz, bgcolor=C_BG_CELL)
    table.cell(dash, 2, row + 1, "Bull", text_color=C_TEXT, text_size=textSz, bgcolor=C_BULL_SOFT)
    table.cell(dash, 3, row + 1, "Score ≥ " + str.tostring(biasThreshold, "#.0"), text_color=C_TEXT, text_size=textSz, bgcolor=C_BULL_SOFT)
    table.cell(dash, 4, row + 1, "Strong", text_color=C_TEXT, text_size=textSz, bgcolor=C_INFO_SOFT)
    table.cell(dash, 5, row + 1, "≥ " + str.tostring(strongThreshold, "#.0"), text_color=C_TEXT, text_size=textSz, bgcolor=C_INFO_SOFT)
    table.cell(dash, 6, row + 1, "Neutral", text_color=C_TEXT, text_size=textSz, bgcolor=C_NEUTRAL_SOFT)
    table.cell(dash, 7, row + 1, "Between thresholds", text_color=C_TEXT, text_size=textSz, bgcolor=C_NEUTRAL_SOFT)

// If the dashboard is disabled, clear the visible cells by painting them transparent.
if barstate.islast and not showDashboard
    for r = 0 to 15
        for c = 0 to 7
            table.cell(dash, c, r, "", bgcolor=color.new(color.black, 100), text_color=color.new(color.white, 100))
````
