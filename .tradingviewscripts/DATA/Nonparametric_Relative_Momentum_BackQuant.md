<!-- tradingview-pine-id: PUB;b7fa890cc749487eb35952e8b9677792 -->
<!-- tradingviewscripts-format: 1 -->
# Nonparametric Relative Momentum [BackQuant]

Source: https://www.tradingview.com/script/1kFbMhN2-Nonparametric-Relative-Momentum-BackQuant/

## Description

Nonparametric Relative Momentum [BackQuant]

Overview
Nonparametric Relative Momentum is a percentile-rank oscillator that measures where the current price or momentum observation sits relative to its own recent empirical history.

Unlike conventional momentum oscillators that transform price using fixed arithmetic relationships, this indicator uses rank statistics. The current observation is compared directly against the previous values in a rolling window and converted into a percentile score from 0 to 100.

The result answers a simple question:

How extreme is the current observation relative to what this market has actually done recently?

Two calculation modes are available:

[*]Price ranks the selected price source directly.
[*]Momentum first measures price change across a configurable horizon, then ranks that momentum against its own recent history.

The oscillator also includes:

[*]Mid-rank handling for tied observations.
[*]Optional output smoothing.
[*]An EMA signal line.
[*]Configurable overbought and oversold zones.
[*]Stepped intensity colouring as the rank becomes more extreme.
[*]Main-chart candle colouring from the 50 midline regime.
[*]Alerts for midline, extreme-zone and signal-line crossings.

Why “nonparametric”?
In statistics, a parametric method generally assumes that data can be described by a particular distribution or by parameters associated with that distribution.

A nonparametric method does not require the same distributional assumption.

Percentile ranks are a classic example.

The oscillator does not need to assume that recent price changes are:

[*]Normally distributed.
[*]Symmetric.
[*]Constant in volatility.
[*]Characterised by a stable mean and standard deviation.

Instead, it works directly from the ordering of the observed data.

If the current momentum observation is greater than almost every momentum observation in the recent window, it receives a high rank.

If it is lower than almost everything observed recently, it receives a low rank.

This makes the oscillator fundamentally relative to the market’s own recent empirical distribution.

Core calculation
The calculation occurs in three stages:

[*]Select the series to rank.
[*]Calculate its empirical percentile rank.
[*]Optionally smooth that rank and calculate a signal average.

The selected ranking target depends on the Rank Target input.

Price Mode
In Price mode:

[*]Target = Selected Price Source

The current source value is compared with the previous values in the Rank Window.

This answers:

Where is current price positioned within its recent price distribution?

A value near 100 means current price is above almost every observation in the comparison window.

A value near 0 means it is below almost every observation.

A value near 50 means it sits near the middle of its recent distribution.

Because Price mode ranks the price level itself, it behaves somewhat like a stochastic or price-position oscillator, although the calculation is based on empirical ranking rather than highest-lowest range normalisation.

Momentum Mode
Momentum mode first calculates:

[*]Momentum = Source - Source[momentum length]

This measures the absolute price change across the selected Momentum Length.

The resulting momentum series is then percentile-ranked over the Rank Window.

The oscillator therefore answers:

How strong is the current momentum observation compared with recent momentum observations?

This is different from asking whether price itself is historically high or low.

For example, price can be near a recent high while momentum has weakened considerably. In that situation:

[*]Price mode may remain highly ranked.
[*]Momentum mode may fall toward the centre or lower half of the distribution.

Conversely, price does not need to be at a long-term extreme for momentum to rank very highly if the current change is unusually strong relative to recent movements.

Why Momentum mode is different from traditional RSI
The standard Relative Strength Index developed by J. Welles Wilder compares smoothed positive and negative price changes.

Its calculation depends on the relative magnitude of average gains and average losses.

Nonparametric Relative Momentum does not use that formula.

Instead:

[*]A momentum observation is calculated.
[*]That observation is ranked against its own historical sample.

For this reason, Momentum mode can be thought of as a rank-based relative momentum oscillator.

Both traditional RSI and this oscillator are bounded between 0 and 100, but the meaning of those values is different.

For example:

RSI = 90
means the balance of smoothed gains versus losses has produced an RSI reading of 90.

Nonparametric Relative Momentum = 90
means the current momentum observation ranks around the upper end of its recent empirical momentum distribution.

That distinction is important.

Percentile rank calculation
For each bar, the indicator compares the current target with every observation in the preceding Rank Window.

It counts:

[*]How many previous values are below the current value.
[*]How many previous values are exactly equal to it.

The percentile rank is then:

[*]Rank = 100 × (Values Below + 0.5 × Equal Values) / Window Length

This produces an oscillator between 0 and 100.

Why use rank instead of magnitude?
Consider two markets.

Market A may normally move only 0.5% over the selected momentum horizon.

Market B may routinely move 5%.

A raw momentum threshold cannot be interpreted the same way for both.

Ranking changes the question.

Instead of asking:

How many points or percent did this market move?

the oscillator asks:

How unusual is this move relative to this market’s own recent behaviour?

This allows the same 0–100 framework to adapt naturally to different price scales and volatility regimes.

Mid-rank treatment of ties
A simple percentile implementation might count only observations strictly below the current value.

That can distort the result when repeated values occur.

This indicator uses mid-rank treatment.

If historical observations equal the current value, each tie contributes one half rather than being classified entirely above or below.

For example, suppose:

[*]40% of observations are below the current value.
[*]20% are exactly equal.
[*]40% are above.

The mid-rank result is:

[*]40 + 0.5 × 20 = 50

This places the tied observation at the centre of its equal-value group.

Mid-ranks are commonly used in rank-based statistics because they provide a more balanced treatment of ties.

Rank Window
The Rank Window determines how much historical data defines the current empirical distribution.

A shorter Rank Window:

[*]Adapts quickly.
[*]Responds strongly to recent regime changes.
[*]Produces more rapid movement between percentiles.
[*]Can create noisier extreme readings.

A longer Rank Window:

[*]Builds the ranking from a larger sample.
[*]Produces a more stable percentile estimate.
[*]Makes extremes harder to reach.
[*]Responds more slowly when market behaviour changes.

The window therefore controls the memory of the oscillator.

It does not smooth the underlying target directly. It changes the reference distribution against which the target is ranked.

Momentum Length
Momentum Length is used only when Rank Target is set to Momentum.

It controls the horizon over which price change is measured:

[*]Momentum = Current Source - Source from Momentum Length bars ago

Shorter values:

[*]Measure faster momentum.
[*]React to shorter impulses.
[*]Change direction more frequently.

Longer values:

[*]Measure broader displacement.
[*]Focus on more persistent movement.
[*]Ignore more short-term fluctuation.

The Momentum Length and Rank Window perform separate roles.

Momentum Length determines what movement is measured.

Rank Window determines the historical sample against which that movement is judged.

Output Smoothing
The raw percentile rank can optionally be passed through an EMA.

A value of 1 leaves the rank effectively unsmoothed.

Higher values:

[*]Reduce rapid rank fluctuations.
[*]Create a smoother oscillator.
[*]Reduce short-lived extreme readings.
[*]Introduce additional lag.

The smoothing occurs after the percentile calculation.

It does not change how observations are ranked.

The 50 midline
The oscillator is centred around 50.

A value above 50 means the current observation ranks above the midpoint of its recent distribution.

A value below 50 means it ranks below the midpoint.

The interpretation depends on the selected mode.

Price mode above 50
Current price is positioned in the upper half of its recent price distribution.

Price mode below 50
Current price is positioned in the lower half.

Momentum mode above 50
Current momentum is stronger than roughly the middle of its recent momentum observations.

Momentum mode below 50
Current momentum is weaker relative to its recent distribution.

The indicator also uses this midline to colour main-chart candles:

[*]Above or equal to 50 = bullish colour.
[*]Below 50 = bearish colour.

This provides a simple relative-regime view on the price chart.

Percentile extremes
Because the oscillator represents rank rather than an unbounded magnitude, readings near 0 and 100 carry a straightforward interpretation.

Near 100
The current observation is greater than almost every value in the recent comparison window.

Near 0
The current observation is lower than almost every value.

These are empirical extremes.

They do not mean price or momentum cannot become more extreme.

A value near 100 can persist while a strong trend continues because new observations may repeatedly remain near the top of the evolving distribution.

Likewise, readings near 0 can persist during sustained downside momentum.

Overbought and Oversold zones
The default static zones are:

[*]Overbought: 90–100
[*]Oversold: 0–10

These are configurable.

The labels “overbought” and “oversold” describe statistical location, not guaranteed reversal conditions.

An overbought reading means:

[*]The ranked observation is near the top of its recent empirical distribution.

An oversold reading means:

[*]It is near the bottom.

During a range, these areas may help identify local extremes.

During a persistent trend, the oscillator can remain in an extreme zone for extended periods.

The zones should therefore be interpreted together with:

[*]Trend context.
[*]Price structure.
[*]Oscillator direction.
[*]Signal-line behaviour.

Why 90/10 instead of 70/30?
Traditional RSI commonly uses 70 and 30.

That convention does not need to apply to a percentile-rank oscillator.

A rank above 90 means the current observation is in approximately the upper tail of the recent empirical sample, while a reading below 10 represents the lower tail.

Using more extreme default zones makes them intentionally selective.

Users who want broader zones can move the boundaries toward values such as 80 and 20.

Signal line
The white Moving Average line is an EMA of the final oscillator:

[*]Signal = EMA(Percentile Rank Oscillator, Signal Length)

This provides a slower reference against which short-term rank movement can be compared.

Oscillator above signal
The percentile rank is strengthening relative to its own recent smoothed level.

Oscillator below signal
The rank is weakening.

Crossovers can be used to identify changes in short-term momentum within the broader percentile regime.

For example:

[*]A bullish crossover below the oversold zone can indicate rank beginning to recover from an extreme.
[*]A bearish crossover above the overbought zone can indicate deterioration from an upper-tail reading.
[*]A crossover near 50 may represent a more neutral momentum transition.

Signal crosses should not be interpreted independently from oscillator location.

Stepped oscillator colouring
The oscillator uses stepped colour intensity based on its position relative to the 50 midline.

Above 50, colours progressively strengthen as the percentile reaches higher levels.

Below 50, bearish intensity progressively strengthens as the percentile falls.

The main regions are approximately:

[*]50–62.5: modest positive rank.
[*]62.5–75: strengthening positive rank.
[*]75–90: strong positive rank.
[*]90–99: upper-tail extreme.
[*]99–100: exceptional upper-tail rank.

The lower half mirrors this concept:

[*]37.5–50: modest negative rank.
[*]25–37.5: weakening relative state.
[*]10–25: strong negative rank.
[*]1–10: lower-tail extreme.
[*]0–1: exceptional lower-tail rank.

These colours do not introduce additional calculations or signals.

They visually communicate how far the oscillator has moved into its empirical distribution.

Column presentation
The percentile oscillator is plotted as columns around a histogram base of 50.

This means:

[*]Values above 50 extend upward.
[*]Values below 50 extend downward from the midline.

Although the numerical scale remains 0–100, this presentation visually emphasises deviation from the centre of the distribution.

The 50 level therefore functions as the oscillator’s equilibrium reference.

Price mode versus Momentum mode
The two modes answer different questions and should not be treated interchangeably.

Price Mode
Asks:

Where is price relative to its recent distribution?

This makes it useful for:

[*]Range position.
[*]Breakout context.
[*]Relative price extremes.
[*]Stochastic-like analysis.

Momentum Mode
Asks:

Where is current price change relative to the recent distribution of price changes?

This makes it useful for:

[*]Momentum expansion.
[*]Momentum exhaustion.
[*]Relative impulse analysis.
[*]Trend-strength transitions.

Momentum mode can identify weakening momentum before price itself leaves the upper part of its distribution.

Price mode can remain elevated simply because the market is still trading near recent highs.

Example: strong uptrend
Suppose price has been rising steadily.

Price Mode may remain above 90 because current price continually sits near the upper edge of its recent range.

Momentum Mode may behave differently:

[*]It can rise toward 100 during acceleration.
[*]Fall back toward 50 when the trend continues at a more ordinary pace.
[*]Drop below 50 if momentum deteriorates significantly even while price remains relatively high.

This distinction can help separate price location from momentum condition.

Example: volatility regime change
Suppose a market normally changes by only small amounts, then suddenly produces a large directional move.

Raw momentum alone shows a large number.

The percentile rank provides additional context by showing whether that movement is unusual relative to the recent distribution.

If the current momentum is greater than nearly every recent observation, the oscillator moves toward 100.

If the market has already experienced many similarly large moves, the same absolute momentum may receive a much less extreme rank.

The indicator therefore adapts automatically to changing empirical behaviour without requiring fixed momentum thresholds.

Midline crossings
A crossover above 50 indicates the ranked series has moved into the upper half of its recent distribution.

A cross below 50 indicates movement into the lower half.

In Momentum mode, these crossings can be used as a simple relative momentum regime:

[*]Above 50 = comparatively stronger momentum state.
[*]Below 50 = comparatively weaker momentum state.

In Price mode, they indicate whether price is above or below the central portion of its recent rank distribution.

These crossings also control the optional main-chart candle colours.

Extreme-zone crossings
The indicator provides alerts when:

[*]The oscillator crosses upward into the overbought zone.
[*]The oscillator crosses downward into the oversold zone.

These alerts identify entry into an extreme percentile area.

They do not indicate that the extreme has ended.

For reversal-oriented analysis, a trader may instead monitor:

[*]A subsequent exit from the zone.
[*]A signal-line crossover.
[*]Divergence with price.
[*]A break in market structure.

Divergence interpretation
Because Momentum mode ranks momentum rather than price, it can also be useful for examining momentum divergence.

For example:

Price may make a higher high while the oscillator produces a lower percentile peak.

This indicates that the latest momentum observation is less exceptional relative to its recent history than it was during the previous price high.

The reverse can occur at lows.

As with conventional divergence, this is evidence of changing momentum characteristics, not confirmation that price must reverse.

How to use the indicator

1. Relative momentum regime
In Momentum mode, use the 50 midline as a simple regime reference:

[*]Above 50 = positive relative momentum state.
[*]Below 50 = negative relative momentum state.

2. Momentum extremes
Use the configurable zones to identify unusually high or low momentum ranks.

Rather than automatically fading these conditions, determine whether the market is:

[*]Trending.
[*]Exhausting.
[*]Breaking out.
[*]Returning toward equilibrium.

3. Signal-line transitions
Oscillator and signal-line crosses can help identify shorter-term changes in rank direction.

The location of the crossover matters.

A bullish crossover at 5 carries different context from one at 95.

4. Price-distribution analysis
Switch to Price mode when the objective is to measure where the current market sits within its recent price distribution.

This can be useful for:

[*]Breakout analysis.
[*]Range positioning.
[*]Relative high/low detection.

5. Trend confirmation
Momentum remaining consistently above 50 can support an existing bullish trend.

Momentum remaining below 50 can support a bearish trend.

Repeated oscillation around 50 indicates that relative momentum is changing sides frequently.

6. Candle regime colouring
The optional overlay candles make the oscillator’s midline state visible directly on the main price chart.

This can be useful when the oscillator pane is being used primarily for extremes and signal-line analysis.

Input guide

Rank Target
Selects what is percentile-ranked.

[*]Price ranks the source itself.
[*]Momentum ranks its change over the selected Momentum Length.

Rank Window
Controls the empirical comparison sample.

Longer values are smoother and statistically broader. Shorter values adapt more quickly.

Momentum Length
Controls the displacement horizon in Momentum mode.

It has no effect in Price mode.

Output Smoothing
Applies optional EMA smoothing to the percentile rank.

1 produces the raw rank.

Signal Length
Controls the EMA signal line.

Shorter values follow the oscillator more closely. Longer values produce slower crossover signals.

Overbought Zone
Sets the lower boundary of the upper extreme area.

Oversold Zone
Sets the upper boundary of the lower extreme area.

How this differs from RSI
Traditional RSI:

[*]Separates gains and losses.
[*]Smooths their magnitude.
[*]Calculates a relative-strength ratio.
[*]Transforms that ratio onto a 0–100 scale.

Nonparametric Relative Momentum:

[*]Calculates price or momentum directly.
[*]Ranks the current observation against historical observations.
[*]Uses no gain/loss ratio.
[*]Uses no assumed distribution.

The identical 0–100 scale therefore represents a different statistical concept.

How this differs from Stochastic
A conventional stochastic oscillator measures where current price lies between the highest high and lowest low of a window.

Its basic concept is:

[*](Current - Lowest) / (Highest - Lowest)

Nonparametric Price mode instead asks how many historical observations are below the current price.

This distinction matters because the rank considers the entire empirical ordering of the sample, not only its two extreme endpoints.

Two windows can have identical highs, lows and current price but different internal distributions.

A stochastic calculation can return the same value in both cases, while percentile rank can differ because the number of observations above and below the current price is different.

How this differs from a Z-score
A Z-score measures deviation from a mean in standard-deviation units:

[*]Z = (Current Value - Mean) / Standard Deviation

That calculation depends directly on the sample mean and dispersion.

Percentile rank depends only on ordering.

As a result, an extreme outlier can heavily alter a mean and standard deviation but has much less influence on the ordering of the remaining observations.

This is one of the reasons rank statistics can be useful when financial data contains skew, fat tails or isolated extreme moves.

Strengths

[*]Uses a nonparametric empirical ranking process.
[*]Requires no assumption of normality.
[*]Produces an intuitive bounded 0–100 scale.
[*]Adapts naturally to the recent behaviour of each market.
[*]Supports both price-location and momentum-ranking modes.
[*]Uses mid-ranks for tied observations.
[*]Normalises momentum extremes without relying on fixed point or percentage thresholds.
[*]Includes configurable smoothing and signal analysis.
[*]Provides direct midline regime colouring on the main chart.

Limitations

[*]A percentile rank measures relative position, not absolute magnitude.
[*]A reading of 100 does not indicate how much larger the current observation is than the rest of the sample.
[*]Persistent trends can remain at extreme ranks for extended periods.
[*]Short Rank Windows can generate rapid percentile changes.
[*]Long Rank Windows adapt more slowly to regime shifts.
[*]Momentum mode uses absolute source change rather than percentage return, although ranking substantially reduces scale dependence within a single instrument.
[*]Extreme readings are not automatic reversal signals.
[*]Signal-line crosses can whipsaw in noisy conditions.
[*]The oscillator is reactive and does not forecast future price.

Alerts
The indicator provides alerts for:

[*]Cross Up 50: oscillator enters the upper half of its distribution.
[*]Cross Down 50: oscillator enters the lower half.
[*]Overbought: oscillator crosses upward through the selected upper-zone boundary.
[*]Oversold: oscillator crosses downward through the selected lower-zone boundary.
[*]Bull: oscillator crosses above its signal EMA.
[*]Bear: oscillator crosses below its signal EMA.

Summary
Nonparametric Relative Momentum converts either price or momentum into an empirical percentile rank.

Instead of asking how far an observation is from a moving average, how many standard deviations it sits from a mean, or what ratio of gains to losses produced it, the indicator asks where that observation ranks relative to its own recent history.

In Price mode, it measures the relative location of price within its historical distribution.

In Momentum mode, it first calculates price displacement across a chosen horizon and then measures how exceptional that momentum is relative to recent momentum observations.

A mid-rank procedure handles tied values, optional EMA smoothing controls visual responsiveness, and a separate signal average provides crossover analysis. The 50 midline separates the upper and lower halves of the empirical distribution, while configurable overbought and oversold zones highlight the tails.

The result is a distribution-free relative momentum framework that adapts to the observed behaviour of the market rather than relying on fixed magnitude thresholds or an assumed statistical distribution.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BackQuant

//@version=6
indicator("Nonparametric Relative Momentum [BackQuant]",overlay = false)

// Inputs
const string g1 = "Oscillator"
const string g2 = "Signal & Levels"
const string g3 = "UI Settings"

float  src = input.source(close, "Source", group = g1)
string mode = input.string("Momentum", "Rank Target", options = ["Price", "Momentum"], group = g1, tooltip = "Price = rank the source within its recent window (smooth, stochastic-like). Momentum = rank the rate-of-change (truer nonparametric RSI).")
int    len = input.int(50, "Rank Window", minval = 3, maxval = 300, group = g1, tooltip = "How many past bars the current value is ranked against. Longer = smoother.")
int    momLen = input.int(32, "Momentum Length", minval = 1, maxval = 100, group = g1, tooltip = "Rate-of-change lookback used only in Momentum mode.")
int    smooth = input.int(1, "Output Smoothing", minval = 1, maxval = 50, group = g1, tooltip = "Cosmetic EMA on the oscillator. 1 = raw rank.")

int    sigLen = input.int(9, "Signal Length", minval = 1, maxval = 50, group = g2, tooltip = "EMA of the oscillator plotted as the moving-average line.")
float  obLvl = input.float(90, "Overbought Zone", minval = 50, maxval = 100, group = g2, tooltip = "Inner edge of the top zone. Fill runs from here up to 100. Lower it (e.g. 80) for a wider zone.")
float  osLvl = input.float(10, "Oversold Zone", minval = 0, maxval = 50, group = g2, tooltip = "Inner edge of the bottom zone. Fill runs from here down to 0. Raise it (e.g. 20) for a wider zone.")

bool   showosc = input.bool(true, "Show Oscillator", group = g3)
bool   showma = input.bool(true, "Show Moving Average", group = g3)
bool   showstatic = input.bool(true, "Show OB/OS Zones", group = g3)
bool   paintBar = input.bool(true, "Color Bars", group = g3)

// Counts where the current value sits within its own recent window.
// Uses mid-rank (ties = half) so the result is a proper empirical percentile, not a naive count.
prank(float s, int length) =>
    float less = 0.0
    float eq   = 0.0
    for i = 1 to length
        float v = s[i]
        if s > v
            less += 1.0
        else if s == v
            eq += 1.0
    100.0 * (less + 0.5 * eq) / length

// Target series: raw source, or its rate-of-change
float target = mode == "Momentum" ? src - src[momLen] : src

float rank    = prank(target, len)
float plotosc = ta.ema(rank, smooth)
float sig_ma  = ta.ema(plotosc, sigLen)

// Conditional Oscillator Plot Color (stepped, mapped to 0-100 around the 50 midline)
color plotcol = #1dcaff4d
if plotosc > 50 and plotosc < 62.5
    plotcol := #1dcaff4d
if plotosc > 50 and plotosc > 62.5
    plotcol := #1e9b254d
if plotosc > 50 and plotosc > 75
    plotcol := #00ff003d
if plotosc > 50 and plotosc > 90
    plotcol := #00ff0080
if plotosc > 50 and plotosc > 99
    plotcol := #33ff00fc
if plotosc < 50 and plotosc > 37.5
    plotcol := #e651004d
if plotosc < 50 and plotosc < 37.5
    plotcol := #7715154d
if plotosc < 50 and plotosc < 25
    plotcol := #ff00004d
if plotosc < 50 and plotosc < 10
    plotcol := #ff000080
if plotosc < 50 and plotosc < 1
    plotcol := #ff0000

// Colouring
obbgcol          =       #7715154d
osbgcol          =       #1e9b254d
obcol            =       #ff0000fc
oscol            =       #00ff00fc
midcol           =       #ffffff4d

// Trend candle color from oscillator side
trendCol = plotosc >= 50 ? #33ff00fc : #ff0000fc

// Plotting
plot(showosc ? plotosc : na, "Percentile Rank", plotcol, 2, plot.style_columns, histbase = 50)
plot(showma ? sig_ma : na, "Moving Average", color = color.white)
obupper = plot(showstatic ? 100 : na, "+", obcol)
oblower = plot(showstatic ? obLvl : na, "+", obcol)
osupper = plot(showstatic ? osLvl : na, "-", oscol)
oslower = plot(showstatic ? 0 : na, "-", oscol)
fill(obupper, oblower, obbgcol, "OB Fill")
fill(osupper, oslower, osbgcol, "OS Fill")
midline = hline(50, "50 Line", midcol, hline.style_solid)

// Trend candles on the main chart
plotcandle(open, high, low, close, "Trend Candles", trendCol, trendCol, true, bordercolor = trendCol, display = paintBar ? display.all : display.none, force_overlay = true)

// Alerts
alertcondition(ta.crossover(plotosc, 50), "Cross Up 50", "Nonparametric Relative Momentum crossed above midline on {{ticker}}")
alertcondition(ta.crossunder(plotosc, 50), "Cross Down 50", "Nonparametric Relative Momentum crossed below midline on {{ticker}}")
alertcondition(ta.crossover(plotosc, sig_ma),  "Bull", "Nonparametric Relative Momentum crossed above its MA on {{ticker}}")
alertcondition(ta.crossunder(plotosc, sig_ma), "Bear", "Nonparametric Relative Momentum crossed below its MA on {{ticker}}")
````
