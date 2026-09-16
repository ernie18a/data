<!-- tradingview-pine-id: PUB;f51590098ee847b5867d9cea486a4093 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# MAD Volatility Trail [BackQuant]

Source: https://www.tradingview.com/script/H9JdI5rn-MAD-Volatility-Trail-BackQuant/

## Description

MAD Volatility Trail [BackQuant]

Overview
MAD Volatility Trail is a robust trend-following overlay built from a rolling median and Median Absolute Deviation rather than a conventional moving average and standard deviation.

The indicator estimates a central price using the rolling median, measures how widely recent prices are distributed around that median using MAD, converts that dispersion into adaptive upper and lower bands, and then transforms those bands into one-sided trailing boundaries.

The result is a persistent bullish or bearish trend regime with:

[*]A robust median-based center.
[*]MAD-derived volatility bands.
[*]Optional ATR minimum band width.
[*]One-sided trailing support and resistance.
[*]Optional median-slope confirmation.
[*]Bullish and bearish regime flips.
[*]Strength-reactive gradient and glow.
[*]Post-flip bloom visualization.
[*]Trend-coloured candles.
[*]Signal and alert support.

The main distinction is statistical.

Most volatility trails rely on:

[*]Means.
[*]Standard deviation.
[*]ATR.

MAD Volatility Trail instead uses:

[*]Median.
[*]Median Absolute Deviation.

Median-based statistics are substantially less sensitive to isolated extreme observations, making the framework useful when the user wants a trend structure that is less influenced by individual spikes or outliers.

Core concept
The indicator separates the problem into four stages:

[*]Estimate a robust rolling center using the median.
[*]Measure robust dispersion around that center using MAD.
[*]Build upper and lower adaptive deviation bands.
[*]Convert those raw bands into persistent trailing trend boundaries.

The resulting trail behaves conceptually like a volatility-aware regime filter, but its volatility estimate comes primarily from the empirical distribution of price around its median.

Why median instead of mean?
A conventional arithmetic mean is calculated by summing all observations and dividing by their count.

Every value directly affects the result.

This makes the mean sensitive to outliers.

Consider a simplified sample:

[*]100
[*]101
[*]101
[*]102
[*]150

The extreme value at 150 pulls the arithmetic mean upward substantially.

The median is simply the middle observation after sorting:

[*]Median = 101

The single extreme observation has much less influence.

This property is called robustness.

In markets, isolated large candles, gaps, liquidation events and temporary price spikes can distort mean-based statistics. Median-based calculations intentionally reduce the influence of those individual observations.

Rolling median
For each bar, the indicator collects the selected Source values across the MAD Lookback.

It then calculates the exact median of the available observations.

For an odd number of observations, the median is the middle sorted value.

For an even number, the median lies between the two central observations according to the median implementation.

The resulting value becomes the statistical center of the trail.

Unlike an EMA or RMA, the median is not recursively smoothed.

It is recomputed from the actual distribution of values inside the current rolling window.

Early-history behaviour
At the beginning of the chart, the script ignores unavailable historical values.

This means the first valid median calculations may use fewer observations than the full MAD Lookback until sufficient chart history has accumulated.

Once the complete lookback is available, the calculation uses the full selected window.

Median Absolute Deviation
After calculating the rolling median, the script measures the absolute distance of every observation from that median:

[*]Absolute Deviation = |Value - Median|

It then takes the median of those absolute deviations:

[*]MAD = Median(|Xi - Median(X)|)

This is the Median Absolute Deviation.

MAD measures the typical distance of observations from the median.

It serves a role similar to standard deviation, but the mathematics and statistical behaviour are different.

Why MAD is robust
Standard deviation squares deviations from the mean.

Large deviations therefore receive disproportionately large influence.

A single extreme observation can:

[*]Move the mean.
[*]Create a very large squared deviation.
[*]Increase the final standard deviation substantially.

MAD does not square deviations.

It calculates absolute distance and then takes another median.

Extreme values therefore have limited ability to change the result unless enough of the underlying sample shifts.

This gives MAD a high resistance to outliers.

In practical chart terms, one unusual wick or shock candle is less likely to inflate the statistical width as dramatically as it could under a standard-deviation model.

MAD versus standard deviation
The two measures answer related but different questions.

Standard deviation
Measures squared dispersion around the arithmetic mean.

MAD
Measures median absolute dispersion around the median.

Standard deviation is highly useful when a mean-and-variance framework is desired.

MAD is useful when robustness to unusual observations is more important.

The indicator does not claim one is universally superior.

It intentionally uses MAD because the purpose is to construct a robust trend boundary.

MAD Scale
Raw MAD is not numerically identical to standard deviation.

Under a normal distribution, MAD is usually multiplied by a consistency factor of approximately 1.4826 when the goal is to make it comparable to standard deviation.

The indicator exposes this scaling directly:

[*]Robust Deviation = Raw MAD × MAD Scale

The script default is 1.4655.

The input remains fully adjustable, so users who want the conventional normal-consistency approximation can set the factor near 1.4826.

This scale does not change the median itself.

It changes only the size of the deviation estimate used to build the bands.

Deviation Factor
After scaling MAD, the indicator applies the Deviation Factor:

[*]MAD Width = Scaled MAD × Deviation Factor

This acts as the main sensitivity control.

Lower values:

[*]Create narrower raw bands.
[*]Place the trail closer to price.
[*]Produce more frequent regime changes.

Higher values:

[*]Create wider bands.
[*]Require larger movement for reversals.
[*]Produce more persistent trend states.

The MAD Scale and Deviation Factor both affect width, but they represent different concepts.

MAD Scale calibrates the statistical dispersion estimate.

Deviation Factor determines how much of that estimated dispersion is used for the trend envelope.

Raw MAD bands
The raw bands are:

[*]Upper MAD Band = Median + Band Width
[*]Lower MAD Band = Median - Band Width

Before trailing logic is applied, these bands can move freely upward or downward with:

[*]The rolling median.
[*]MAD dispersion.
[*]Any active ATR floor.

These are statistical envelopes around the median.

They are not yet the final trend trail.

ATR Minimum Width
MAD can become extremely small when recent prices are tightly clustered.

In very low-dispersion conditions, this may place the raw bands extremely close to the median.

That can create excessive sensitivity to minor price fluctuations.

The optional ATR Minimum Width provides a secondary floor.

The script calculates:

[*]ATR Floor = ATR(ATR Length) × ATR Floor Multiplier

When enabled:

[*]Band Width = max(MAD Width, ATR Floor)

This means MAD remains the primary volatility model, but the bands cannot contract below the selected ATR-based threshold.

Why use an ATR floor?
MAD and ATR measure different aspects of market behaviour.

MAD measures:

[*]Dispersion of the selected source around its rolling median.

ATR measures:

[*]Bar-to-bar trading range.
[*]Gaps relative to the previous close.

A market can have:

[*]Low median dispersion.
[*]But still produce meaningful intrabar range.

The ATR floor can prevent the trail from becoming unrealistically tight under those conditions.

ATR floor disabled
With ATR Minimum Width disabled, the entire structural width comes from:

[*]MAD × MAD Scale × Deviation Factor

This produces the purest MAD-based version of the indicator.

ATR Length
ATR Length controls the volatility horizon used only for the optional minimum-width calculation.

It does not affect:

[*]The rolling median.
[*]Raw MAD.
[*]Scaled MAD.

Note that the visual glow and bloom later in the script use a fixed ATR(14), separate from this ATR Length input.

Trailing bands
The raw MAD bands are converted into one-sided trails.

This is the stage that turns a statistical envelope into a persistent trend system.

Two independent trails are maintained:

[*]Lower Trail.
[*]Upper Trail.

Lower Trail
When the previous trigger remains above the previous Lower Trail, the new Lower Trail is:

[*]max(Current Raw Lower Band, Previous Lower Trail)

This means the Lower Trail can:

[*]Move upward.
[*]Remain unchanged.
[*]But cannot move downward while the condition remains active.

This creates a ratcheting support structure.

If the trigger falls below the prior Lower Trail, the trail is allowed to reset to the new raw lower band.

Upper Trail
When the previous trigger remains below the previous Upper Trail, the new Upper Trail is:

[*]min(Current Raw Upper Band, Previous Upper Trail)

This means the Upper Trail can:

[*]Move downward.
[*]Remain unchanged.
[*]But cannot move upward while the condition remains active.

This creates a ratcheting resistance structure.

If the trigger rises above the previous Upper Trail, the band can reset to the current raw upper value.

Why trailing the bands matters
A raw median-deviation envelope moves in both directions.

If those raw bands were used directly for trend changes:

[*]The threshold itself could retreat toward price.
[*]Small changes in median or MAD could produce unstable reversals.

The one-sided trail introduces hysteresis.

Hysteresis means that once a trend regime is established, the threshold required to reverse it remains on the opposing side.

This reduces the tendency to flip repeatedly around the rolling median.

Flip Trigger
The user can choose which series is used when evaluating trail breaks:

[*]Close.
[*]Source.

Close
Uses the candle close regardless of which series is used for the MAD calculation.

This is the conventional option.

Source
Uses the selected Source input.

For example, if HLC3 is selected as the Source:

[*]The median is calculated from HLC3.
[*]MAD is calculated from HLC3.
[*]The trail can also be triggered by HLC3.

This keeps the center, dispersion and reversal trigger based on the same source.

Initial trend state
The trend begins in a neutral state.

Once a valid rolling median is available:

[*]Trigger at or above Median = bullish initialization.
[*]Trigger below Median = bearish initialization.

This initial assignment is not treated as a bullish or bearish flip.

Flip signals occur only after the indicator has already established one regime and later transitions into the opposite regime.

Bullish flip
A bullish regime change requires:

[*]Trigger to move above the Upper Trail.
[*]Current trend not already bullish.
[*]Optional bullish median-slope confirmation to pass.

Once confirmed:

[*]Trend becomes bullish.
[*]The Lower Trail becomes the active trend boundary.
[*]A bullish signal can be displayed.

Bearish flip
A bearish regime change requires:

[*]Trigger to move below the Lower Trail.
[*]Current trend not already bearish.
[*]Optional bearish median-slope confirmation to pass.

Once confirmed:

[*]Trend becomes bearish.
[*]The Upper Trail becomes the active boundary.
[*]A bearish signal can be displayed.

Active trend trail
The final displayed trend boundary depends on the regime:

[*]Bullish = Lower Trail.
[*]Bearish = Upper Trail.

This means the line automatically moves to the opposite side of price when a complete regime change occurs.

Median Slope Confirmation
The optional Median Slope Confirmation adds a directional requirement to trend reversals.

For a bullish flip:

[*]Current Median > Median from Slope Lookback bars ago

For a bearish flip:

[*]Current Median < Median from Slope Lookback bars ago

This requires the robust statistical center itself to move in the direction of the proposed new trend.

Why confirm with median slope?
Price can briefly cross a trail while the underlying median remains flat or continues moving in the opposite direction.

Slope confirmation can reject some of these events.

For example:

A bullish trail break with a still-falling median may represent:

[*]A temporary rebound.
[*]A liquidity sweep.
[*]Noise inside a larger bearish structure.

Requiring the median to rise adds another layer of confirmation.

The trade-off is lag.

A genuine reversal may cross the trail before the rolling median has clearly changed direction.

Slope Lookback
Slope Lookback controls how far back the median is compared.

Lower values:

[*]Respond more quickly.
[*]Require only a very local median turn.

Higher values:

[*]Require a broader directional shift.
[*]Produce stronger confirmation.
[*]Can delay reversals.

This same lookback is also used in the visual slope-strength calculation even when slope confirmation itself is disabled.

Break Trail On Flips
When enabled, the displayed trail is temporarily hidden on the actual regime-flip bar.

This creates a visual break between:

[*]The previous regime’s trail.
[*]The new regime’s trail.

Without the break, the plotting engine can draw a connecting segment from one side of the market to the other.

That connection has no analytical meaning.

Break Trail On Flips affects visualization only.

It does not affect:

[*]Trend state.
[*]Raw bands.
[*]Trail calculations.
[*]Signals.

Robust trend structure
The complete structural model can therefore be summarized as:

[*]Rolling Median determines robust center.
[*]MAD determines robust dispersion.
[*]MAD Scale calibrates the dispersion.
[*]Deviation Factor determines band distance.
[*]Optional ATR floor prevents excessive compression.
[*]Raw bands form the initial envelope.
[*]Ratchet logic creates trailing support and resistance.
[*]Opposite-trail breaks determine regime changes.
[*]Optional median slope confirms those reversals.

This combination is what separates the indicator from simply plotting median ± MAD.

Visual strength model
The script calculates a separate Trend Strength value used only to control the presentation of the gradient and glow.

It does not alter:

[*]Trend direction.
[*]Trail levels.
[*]Flip conditions.

Trend Strength combines:

[*]Price distance from the active trail.
[*]Absolute rolling-median slope.

Distance Strength
The script first measures:

[*]Trail Distance = |Close - Active Trail|

This is normalized by the current band width.

The normalized distance is capped when price reaches twice the active band width away from the trail.

Conceptually:

[*]Close to trail = low distance strength.
[*]Far from trail = high distance strength.

This reflects how separated price is from the current structural boundary.

Slope Strength
The indicator also measures:

[*]|Current Median - Median[Slope Lookback]|

This value is normalized by the current band width and capped at one.

The purpose is to compare median movement against the current statistical width.

A steep median relative to the band width produces stronger visual slope strength.

Combined Trend Strength
The final visual strength is:

[*]70% Distance Strength.
[*]30% Median Slope Strength.

and is capped at one.

The distance component receives greater weight because the visual system places more emphasis on how strongly price is separated from the active trail.

Again, this number is not a probability, forecast or additional signal.

It is a visual intensity measure.

Layered gradient
The area between the active trail and current close is divided into several intermediate levels.

The script creates reference points approximately:

[*]15% of the distance from trail to price.
[*]35%.
[*]60%.
[*]82%.
[*]Then the final segment to price.

These create five layered gradient regions.

The layers become progressively more transparent as they move away from the trail.

This gives the trail visual depth without turning the entire area between price and structure into one solid block.

Gradient direction
The geometry of the gradient is determined by whether close is above or below the active trail.

The colour itself comes from the current bullish or bearish trend regime.

The gradient therefore visualizes:

[*]The active trend colour.
[*]The distance between price and trail.
[*]The relative strength of the trend visualization.

The gradient does not determine the regime.

Trend-strength gradient response
Higher Trend Strength reduces transparency in several layers.

This makes the ribbon more visible when:

[*]Price is strongly separated from the trail.
[*]The rolling median is moving meaningfully.

Lower strength produces a softer appearance.

This allows the visual presentation to communicate more than simple bullish or bearish state.

Flip bloom
The indicator includes a temporary post-flip bloom.

The bloom is derived from the number of bars elapsed since the most recent bullish or bearish transition.

Importantly, in the current implementation the bloom begins after the flip bar:

[*]Flip bar: no bloom boost.
[*]1 bar after flip: maximum bloom.
[*]2 bars after flip: reduced bloom.
[*]3 bars after flip: smaller residual bloom.
[*]Afterward: bloom disappears.

The relative bloom strengths are:

[*]1.00
[*]0.55
[*]0.25

This emphasizes the early bars following a newly confirmed regime change.

Why bloom after the flip?
The flip itself can optionally contain a break in the trail.

Applying the bloom to the following bars emphasizes the newly established active trail rather than drawing a large effect around a temporarily hidden flip point.

The bloom is cosmetic.

It does not modify the underlying calculations.

Trail glow
The active trail can also display a persistent glow.

Glow width is based on:

[*]ATR(14) × a factor that increases with Trend Strength

This ATR(14) is fixed for visualization and is independent of the user-selected ATR Length used by the optional minimum-width floor.

The glow therefore becomes slightly wider as visual trend strength increases.

Two layers are used:

[*]A tighter inner glow.
[*]A broader outer glow.

The inner glow responds more strongly to Trend Strength and post-flip bloom.

Rolling Median display
The rolling median can be displayed independently from the trail.

This is useful for studying the difference between:

[*]The current robust center.
[*]The statistical raw bands.
[*]The ratcheting trend trail.

During a bullish regime, the active Lower Trail can remain below the rolling median.

During a bearish regime, the active Upper Trail can remain above it.

The median is not itself the trend signal.

Raw MAD Bands display
The raw upper and lower MAD bands can also be shown.

These lines make it easier to see how the trailing logic differs from the unrestricted statistical envelope.

Raw bands:

[*]Can move in either direction.

Trailing bands:

[*]Can ratchet in only one direction while their persistence condition remains active.

The gap between raw and trailing levels illustrates the hysteresis introduced by the trend logic.

Trend candles
The script can redraw candles on the main chart using the active trend colour.

Bullish regime:

[*]Uses the selected Bullish colour.

Bearish regime:

[*]Uses the selected Bearish colour.

The candle colour represents the persistent trail regime, not whether each individual candle closed higher or lower.

A bearish candle can therefore remain bullish-coloured while the broader MAD Trail regime remains bullish.

Signal markers
Bullish and bearish markers appear only on complete transitions between established regimes.

A bullish marker requires:

[*]Previous trend = bearish.
[*]Current trend = bullish.

A bearish marker requires:

[*]Previous trend = bullish.
[*]Current trend = bearish.

Initial trend assignment does not generate a flip marker.

How to interpret the indicator

Bullish regime
A bullish state means price has previously broken above the opposing Upper Trail and the Lower Trail is now active.

The Lower Trail can be interpreted as:

[*]Dynamic trend support.
[*]A structural invalidation reference.
[*]A trailing regime boundary.

Bearish regime
A bearish state means price has broken below the opposing Lower Trail and the Upper Trail is active.

The Upper Trail can be interpreted as:

[*]Dynamic resistance.
[*]A bearish invalidation reference.
[*]A trailing regime boundary.

Price close to trail
When price approaches the active trail:

[*]Visual distance strength decreases.
[*]The gradient becomes softer.
[*]The market is closer to the regime boundary.

This does not guarantee a reversal.

A healthy trend can repeatedly retest its active trail.

Price far from trail
When price moves substantially away:

[*]Distance Strength rises.
[*]The visual effect becomes stronger.

This indicates greater separation from the active structural boundary.

It should not automatically be interpreted as a better entry.

A market can be strongly extended and simultaneously close to exhaustion.

Median and trail rising together
During a bullish regime, a rising median combined with a rising Lower Trail indicates:

[*]The robust center is moving upward.
[*]The structural support boundary is also advancing.

This represents cleaner directional alignment.

Median flattening while trail remains bullish
The persistent regime can remain bullish while the median begins flattening.

This indicates:

[*]The trend has not yet been invalidated.
[*]But the robust center is no longer advancing as strongly.

The visual slope-strength component may weaken under this condition.

Raw band expansion
If MAD increases:

[*]Raw bands widen.
[*]Trail reset levels can move farther away.

This means recent source values are becoming more dispersed around the median.

Raw band contraction
If MAD falls:

[*]The raw envelope tightens.

If the ATR floor is disabled, the structure can become substantially narrower.

If the ATR floor is enabled, contraction stops once the selected minimum width is reached.

How to use the indicator

1. Trend regime filter
Use the persistent trail state as directional context:

[*]Bullish trail regime = prioritize long-side setups.
[*]Bearish trail regime = prioritize short-side setups.

The trail does not define a complete trading system by itself.

2. Pullback structure
During a bullish regime, the Lower Trail can provide a dynamic reference for deeper pullbacks.

During a bearish regime, the Upper Trail can provide a reference for rallies.

The farther price moves from the trail, the greater the current structural separation.

3. Regime transitions
Bullish and bearish flips identify moments when price has crossed completely through the opposing robust-deviation trail.

These may be used as:

[*]Trend-change alerts.
[*]Confirmation for another entry method.
[*]Potential exit conditions.

4. Median confirmation
Users who want more selective signals can enable Median Slope Confirmation.

This can be especially useful when:

[*]The market is choppy.
[*]Price frequently sweeps through statistical boundaries.

5. Pure robust-volatility mode
Disable the ATR Minimum Width to make band width depend only on:

[*]Rolling MAD.
[*]MAD Scale.
[*]Deviation Factor.

This produces the purest version of the model.

6. Hybrid robust-volatility mode
Enable ATR Minimum Width when the MAD channel becomes too narrow for the instrument or timeframe.

This preserves MAD as the primary engine while adding a conventional range-based safety floor.

Input guide

Source
Series used for the rolling median and MAD calculation.

MAD Lookback
Controls the number of observations used for the rolling median and dispersion estimate.

Shorter values adapt faster.

Longer values create a broader and more stable distribution.

MAD Scale
Multiplier applied directly to raw MAD.

The commonly cited normal-distribution consistency factor is approximately 1.4826; the script default is 1.4655.

Deviation Factor
Controls the final width of the MAD envelope.

ATR Minimum Width
Prevents the active band width from falling below an ATR-derived floor.

ATR Length
Controls the ATR used by the optional floor.

ATR Floor
Controls the minimum width as a multiple of ATR.

Median Slope Confirmation
Requires the rolling median to move in the direction of a proposed trend flip.

Slope Lookback
Controls how far back the current median is compared.

It also influences the visual slope-strength calculation.

Flip Trigger
Selects Close or Source for trail-break detection.

Break Trail On Flips
Creates a visual discontinuity on transition bars.

How this differs from a standard Supertrend
A conventional Supertrend generally uses:

[*]A price midpoint such as HL2.
[*]ATR as the full band-width model.

MAD Volatility Trail instead uses:

[*]Rolling median as its center.
[*]Median Absolute Deviation as its primary width.
[*]ATR only as an optional minimum floor.

The trail mechanics are conceptually related, but the statistical foundation is different.

How this differs from Bollinger Bands
Bollinger Bands normally use:

[*]A moving average.
[*]Standard deviation.
[*]Symmetrical raw bands.

MAD Volatility Trail uses:

[*]Rolling median.
[*]Median Absolute Deviation.
[*]One-sided trailing bands.
[*]Persistent trend-state logic.

Bollinger Bands are primarily a statistical envelope.

MAD Volatility Trail converts its robust statistical envelope into a trend-regime system.

How this differs from median ± MAD alone
A simple median-MAD indicator would plot:

[*]Median.
[*]Median + MAD width.
[*]Median - MAD width.

Those bands would move freely.

This indicator adds:

[*]Ratchet logic.
[*]Persistent bullish/bearish state.
[*]Opposite-trail break conditions.
[*]Optional median-slope confirmation.
[*]Signals and alerts.

The raw statistical model is therefore only the first stage.

MAD versus ATR
ATR measures the size of trading ranges.

MAD measures dispersion of the selected source around its median.

They can behave very differently.

For example:

[*]A volatile but mean-reverting market can have large ATR with relatively controlled median dispersion.
[*]A persistent directional displacement can produce increasing MAD even if individual candle ranges are moderate.

The optional floor allows both concepts to coexist without replacing the MAD foundation.

Robust statistics and financial markets
Financial return and price distributions frequently contain:

[*]Outliers.
[*]Large jumps.
[*]Skew.
[*]Fat tails.

Mean-and-standard-deviation models remain extremely useful, but robust alternatives can provide different information when unusual observations are present.

Median and MAD belong to a family of robust statistical tools designed to reduce sensitivity to extreme sample values.

This does not make the resulting indicator immune to market shocks.

If enough of the rolling window moves, the median and MAD will also move.

The advantage is primarily that one isolated observation has less influence.

Strengths

[*]Uses an exact rolling median.
[*]Uses exact Median Absolute Deviation rather than an approximation.
[*]More resistant to isolated outliers than mean/standard-deviation envelopes.
[*]Provides a configurable MAD scale.
[*]Supports a pure MAD or MAD-plus-ATR hybrid width.
[*]Converts robust statistics into persistent trend boundaries.
[*]Uses one-sided trail logic to reduce rapid regime switching.
[*]Provides optional median-direction confirmation.
[*]Separates signal logic from visual strength.
[*]Includes dynamic gradient, glow and post-flip visualization.
[*]Exposes raw MAD, scaled MAD, active band width and Trend Strength in the Data Window.

Limitations

[*]The indicator is reactive rather than predictive.
[*]Robust statistics do not eliminate whipsaws.
[*]A very short MAD Lookback can still react sharply.
[*]A very long lookback can delay adaptation to new regimes.
[*]Median calculations can remain unchanged across several bars and then move discretely as the rolling sample changes.
[*]Higher Deviation Factors reduce reversals but increase confirmation lag.
[*]The ATR floor changes the model from pure MAD dispersion to a hybrid MAD/ATR structure.
[*]Median Slope Confirmation can reject false breaks but also delay genuine reversals.
[*]Extreme readings in the visual-strength system are not probabilities of continuation.
[*]Glow and bloom are cosmetic and should not be treated as separate signals.

Computational considerations
Unlike many moving averages, the exact rolling median and MAD calculations require the script to build and process the values inside the selected window.

For each bar:

[*]The rolling source sample is collected.
[*]Its median is calculated.
[*]Absolute deviations from that median are calculated.
[*]A second median is calculated from those deviations.

Larger MAD Lookbacks therefore require more work than a simple recursive EMA or ATR calculation.

This is the cost of calculating the robust statistics directly.

Causality and live-bar behaviour
The indicator uses current and historical values without intentional future-looking references.

On completed historical bars, the model is causal.

On a live unfinished bar:

[*]The Source can change.
[*]The current rolling median can change.
[*]MAD can change.
[*]Raw bands can change.
[*]A trail break can appear or disappear.

Users who require confirmed regime changes should evaluate signals at bar close.

Data Window
The indicator exposes four useful diagnostic values.

Raw MAD
The unscaled median absolute deviation.

Scaled MAD
Raw MAD multiplied by the selected MAD Scale.

Active Band Width
The actual band width after:

[*]MAD scaling.
[*]Deviation Factor.
[*]Optional ATR minimum floor.

Trend Strength
The visual-strength score expressed from approximately 0 to 100.

This is calculated from trail distance and median movement.

It is not part of the trend-flip logic.

Alerts
The indicator includes:

[*]MAD Trail Bullish: established bearish regime changes to bullish.
[*]MAD Trail Bearish: established bullish regime changes to bearish.
[*]MAD Trail Flip: either regime transition occurs.

Summary
MAD Volatility Trail builds a trend-following regime from robust statistics.

The calculation begins with an exact rolling median of the selected Source.

Rather than measuring dispersion with standard deviation, the script calculates the Median Absolute Deviation:

[*]MAD = Median(|X - Median(X)|)

The raw MAD is scaled and multiplied by a configurable Deviation Factor to create the statistical width around the rolling median.

The resulting raw upper and lower bands are:

[*]Median + Band Width.
[*]Median - Band Width.

An optional ATR minimum floor prevents these bands from becoming excessively narrow during low-dispersion conditions.

The raw envelope is then transformed into one-sided trailing boundaries.

The Lower Trail can ratchet upward while price remains above it, while the Upper Trail can ratchet downward while price remains below it.

These trails create hysteresis and form the actual regime-switching structure.

A bearish regime turns bullish only when the selected trigger breaks above the opposing Upper Trail, optionally while the rolling median itself is rising.

A bullish regime turns bearish only when the trigger breaks below the Lower Trail, optionally while the median is falling.

The active Lower Trail is displayed during bullish regimes and the active Upper Trail during bearish regimes.

A separate visual-strength model measures price-to-trail distance and median slope relative to the active band width. That score controls gradient and glow intensity but does not alter signals.

The result is a robust alternative to conventional mean-, standard-deviation- and ATR-centered trend trails.

Rather than allowing individual extreme prices to dominate its statistical center and dispersion estimate, MAD Volatility Trail uses the median twice: once to define the center of the distribution and again to define the typical absolute distance from that center.

This creates a trend framework designed around robust location, robust dispersion and persistent trailing structure.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BackQuant

import TradingView/ta/12 as ta

//@version=6
indicator("MAD Volatility Trail [BackQuant]", overlay = true)

// Groups
const string g1 = "MAD Calculation"
const string g2 = "Trail Settings"
const string g3 = "UI Settings"

const color GREEN = #00ff00
const color RED   = #ff0000

// Inputs
float src = input.source(close, "Source", group = g1)
int madLen = input.int(45, "MAD Lookback", minval = 5, maxval = 300, group = g1, inline = "1")
float madScale = input.float(1.4655, "MAD Scale", minval = 0.1, maxval = 5.0, step = 0.0001, group = g1, inline = "1", tooltip = "1.4826 scales MAD to approximate standard deviation under a normal distribution.")
float factor = input.float(1.15, "Deviation Factor", minval = 0.1, maxval = 10.0, step = 0.05, group = g1)

bool useAtrFloor = input.bool(false, "ATR Minimum Width", group = g2, tooltip = "Prevents the MAD bands becoming excessively narrow during very low dispersion.")
int atrLen = input.int(14, "ATR Length", minval = 1, maxval = 200, group = g2, inline = "2")
float atrFloorMult = input.float(0.2, "ATR Floor", minval = 0.0, maxval = 5.0, step = 0.05, group = g2, inline = "2")
bool useSlopeConfirm = input.bool(false, "Median Slope Confirmation", group = g2)
int slopeLen = input.int(2, "Slope Lookback", minval = 1, maxval = 50, group = g2)
string triggerMode = input.string("Close", "Flip Trigger", options = ["Close", "Source"], group = g2)
bool breakTrailOnFlip = input.bool(true, "Break Trail On Flips", group = g2)

bool showTrail = input.bool(true, "Show MAD Trail", group = g3)
bool showMedian = input.bool(false, "Show Rolling Median", group = g3)
bool showBands = input.bool(false, "Show Raw MAD Bands", group = g3)
bool showFill = input.bool(true, "Gradient Fill", group = g3)
bool showGlow = input.bool(true, "Trail Glow", group = g3)
bool showSig = input.bool(true, "Show Signals", group = g3)
bool paintBar = input.bool(true, "Color Candles", group = g3)
int lineW = input.int(3, "Line Width", minval = 1, maxval = 6, group = g3)
color longCol = input.color(GREEN, "Bullish", inline = "c", group = g3)
color shortCol = input.color(RED, "Bearish", inline = "c", group = g3)
color medianCol = input.color(#ffffff, "Median", inline = "c", group = g3)

// Exact Rolling Median + MAD
madStats(float source, simple int length) =>
    array<float> values = array.new_float()
    for i = 0 to length - 1
        if not na(source[i])
            array.push(values, source[i])
    float median = array.size(values) > 0 ? array.median(values) : na
    array<float> deviations = array.new_float()
    if not na(median)
        for i = 0 to array.size(values) - 1
            array.push(deviations, math.abs(array.get(values, i) - median))
    float mad = array.size(deviations) > 0 ? array.median(deviations) : na
    [median, mad]

// MAD Calculation
[medianValue, rawMad] = madStats(src, madLen)

float robustDeviation = rawMad * madScale
float madWidth = robustDeviation * factor
float atrFloor = ta.atr(atrLen) * atrFloorMult
float bandWidth = useAtrFloor ? math.max(madWidth, atrFloor) : madWidth

float rawUpper = medianValue + bandWidth
float rawLower = medianValue - bandWidth

// Trailing Bands
float trigger = triggerMode == "Close" ? close : src

var float trailUpper = na
var float trailLower = na

trailLower := not na(trailLower[1]) and trigger[1] > trailLower[1] ? math.max(rawLower, trailLower[1]) : rawLower
trailUpper := not na(trailUpper[1]) and trigger[1] < trailUpper[1] ? math.min(rawUpper, trailUpper[1]) : rawUpper

// Trend Logic
bool bullSlopePass = not useSlopeConfirm or medianValue > medianValue[slopeLen]
bool bearSlopePass = not useSlopeConfirm or medianValue < medianValue[slopeLen]

var int trend = 0

if trend == 0 and not na(medianValue)
    trend := trigger >= medianValue ? 1 : -1

bool rawBullFlip = trigger > trailUpper and trend != 1 and bullSlopePass
bool rawBearFlip = trigger < trailLower and trend != -1 and bearSlopePass

if rawBullFlip
    trend := 1
else if rawBearFlip
    trend := -1

bool bullFlip = trend == 1 and trend[1] == -1
bool bearFlip = trend == -1 and trend[1] == 1
bool trendFlip = bullFlip or bearFlip

float trendTrail = trend == 1 ? trailLower : trend == -1 ? trailUpper : na
float plottedTrail = breakTrailOnFlip and trendFlip ? na : trendTrail
color trendCol = trend == 1 ? longCol : trend == -1 ? shortCol : color.gray

// Visual Strength
float trailDistance = not na(trendTrail) ? math.abs(close - trendTrail) : 0.0
float distanceStrength = bandWidth > 0 ? math.min(trailDistance / bandWidth, 2.0) / 2.0 : 0.0
float medianSlope = math.abs(medianValue - medianValue[slopeLen])
float slopeStrength = bandWidth > 0 ? math.min(medianSlope / bandWidth, 1.0) : 0.0
float trendStrength = math.min(distanceStrength * 0.70 + slopeStrength * 0.30, 1.0)

int barsSinceFlip = nz(ta.barssince(trendFlip), 100000)
float bloomStrength = barsSinceFlip == 1 ? 1.0 : barsSinceFlip == 2 ? 0.55 : barsSinceFlip == 3 ? 0.25 : 0.0

int fillBoost = int(math.round(trendStrength * 12.0))
int bloomBoost = int(math.round(bloomStrength * 12.0))
int mediumBoost = int(math.round(fillBoost * 0.65))
int softBoost = int(math.round(fillBoost * 0.35))

// Gradient
bool fillReady = showTrail and showFill and not na(plottedTrail)
bool priceAboveTrail = close >= trendTrail

float grad1 = trendTrail + (close - trendTrail) * 0.15
float grad2 = trendTrail + (close - trendTrail) * 0.35
float grad3 = trendTrail + (close - trendTrail) * 0.60
float grad4 = trendTrail + (close - trendTrail) * 0.82

color gradInner1 = color.new(trendCol, math.max(25, 52 - fillBoost - bloomBoost))
color gradOuter1 = color.new(trendCol, math.max(58, 82 - softBoost))
color gradInner2 = color.new(trendCol, math.max(42, 68 - mediumBoost))
color gradOuter2 = color.new(trendCol, math.max(72, 90 - softBoost))
color gradInner3 = color.new(trendCol, math.max(58, 80 - mediumBoost))
color gradOuter3 = color.new(trendCol, math.max(82, 95 - softBoost))
color gradInner4 = color.new(trendCol, math.max(72, 89 - softBoost))
color gradOuter4 = color.new(trendCol, math.max(90, 98 - softBoost))
color gradInner5 = color.new(trendCol, math.max(84, 96 - softBoost))
color gradOuter5 = color.new(trendCol, 99)

// Plots
pTrail = plot(showTrail ? plottedTrail : na, "MAD Volatility Trail", color = trendCol, linewidth = lineW, style = plot.style_linebr)
pPrice = plot(fillReady ? close : na, "Price Ref", display = display.none, editable = false)
pGrad1 = plot(fillReady ? grad1 : na, "Gradient Ref 1", display = display.none, editable = false)
pGrad2 = plot(fillReady ? grad2 : na, "Gradient Ref 2", display = display.none, editable = false)
pGrad3 = plot(fillReady ? grad3 : na, "Gradient Ref 3", display = display.none, editable = false)
pGrad4 = plot(fillReady ? grad4 : na, "Gradient Ref 4", display = display.none, editable = false)

plot(showMedian ? medianValue : na, "Rolling Median", color = color.new(medianCol, 25), linewidth = 1)
plot(showBands ? rawUpper : na, "Upper MAD Band", color = color.new(trendCol, 75), linewidth = 1)
plot(showBands ? rawLower : na, "Lower MAD Band", color = color.new(trendCol, 75), linewidth = 1)

// Layered Gradient
fill(pTrail, pGrad1, priceAboveTrail ? grad1 : trendTrail, priceAboveTrail ? trendTrail : grad1, fillReady ? (priceAboveTrail ? gradOuter1 : gradInner1) : na, fillReady ? (priceAboveTrail ? gradInner1 : gradOuter1) : na, title = "Gradient Layer 1")
fill(pTrail, pGrad2, priceAboveTrail ? grad2 : trendTrail, priceAboveTrail ? trendTrail : grad2, fillReady ? (priceAboveTrail ? gradOuter2 : gradInner2) : na, fillReady ? (priceAboveTrail ? gradInner2 : gradOuter2) : na, title = "Gradient Layer 2")
fill(pTrail, pGrad3, priceAboveTrail ? grad3 : trendTrail, priceAboveTrail ? trendTrail : grad3, fillReady ? (priceAboveTrail ? gradOuter3 : gradInner3) : na, fillReady ? (priceAboveTrail ? gradInner3 : gradOuter3) : na, title = "Gradient Layer 3")
fill(pTrail, pGrad4, priceAboveTrail ? grad4 : trendTrail, priceAboveTrail ? trendTrail : grad4, fillReady ? (priceAboveTrail ? gradOuter4 : gradInner4) : na, fillReady ? (priceAboveTrail ? gradInner4 : gradOuter4) : na, title = "Gradient Layer 4")
fill(pTrail, pPrice, priceAboveTrail ? close : trendTrail, priceAboveTrail ? trendTrail : close, fillReady ? (priceAboveTrail ? gradOuter5 : gradInner5) : na, fillReady ? (priceAboveTrail ? gradInner5 : gradOuter5) : na, title = "Gradient Layer 5")

// Trail Glow
float glow = ta.atr(14) * (0.045 + trendStrength * 0.025)
float outerGlow = glow * 2.3
bool glowReady = showTrail and showGlow and not na(plottedTrail)

pGlowOuterLower = plot(glowReady ? trendTrail - outerGlow : na, "Outer Glow Lower", display = display.none, editable = false)
pGlowOuterUpper = plot(glowReady ? trendTrail + outerGlow : na, "Outer Glow Upper", display = display.none, editable = false)
pGlowLower = plot(glowReady ? trendTrail - glow : na, "Glow Lower", display = display.none, editable = false)
pGlowUpper = plot(glowReady ? trendTrail + glow : na, "Glow Upper", display = display.none, editable = false)

fill(pGlowOuterLower, pGlowOuterUpper, glowReady ? color.new(trendCol, math.max(84, 96 - softBoost)) : na, title = "Outer Trail Glow")
fill(pGlowLower, pGlowUpper, glowReady ? color.new(trendCol, math.max(60, 84 - fillBoost - bloomBoost)) : na, title = "Inner Trail Glow")

// Flip Bloom
float bloomWidth = ta.atr(14) * (0.12 + bloomStrength * 0.08)
bool bloomReady = showTrail and showGlow and bloomStrength > 0 and not na(trendTrail)

pBloomLower = plot(bloomReady ? trendTrail - bloomWidth : na, "Bloom Lower", display = display.none, editable = false)
pBloomUpper = plot(bloomReady ? trendTrail + bloomWidth : na, "Bloom Upper", display = display.none, editable = false)

fill(pBloomLower, pBloomUpper, bloomReady ? color.new(trendCol, 88 - int(math.round(bloomStrength * 16))) : na, title = "Flip Bloom")

// Candles
plotcandle(open, high, low, close, "Trend Candles", trendCol, trendCol, true, bordercolor = trendCol, display = paintBar ? display.all : display.none)

// Signals
plotshape(showSig and bullFlip ? trendTrail : na, "Bull Flip", shape.labelup, location.absolute, longCol, text = "▲", textcolor = chart.bg_color, size = size.small)
plotshape(showSig and bearFlip ? trendTrail : na, "Bear Flip", shape.labeldown, location.absolute, shortCol, text = "▼", textcolor = chart.bg_color, size = size.small)

// Data Window
plot(rawMad, "Raw MAD", display = display.data_window, editable = false)
plot(robustDeviation, "Scaled MAD", display = display.data_window, editable = false)
plot(bandWidth, "Active Band Width", display = display.data_window, editable = false)
plot(trendStrength * 100.0, "Trend Strength", display = display.data_window, editable = false)

// Alerts
alertcondition(bullFlip, "MAD Trail Bullish", "MAD Volatility Trail turned bullish on {{ticker}}")
alertcondition(bearFlip, "MAD Trail Bearish", "MAD Volatility Trail turned bearish on {{ticker}}")
alertcondition(bullFlip or bearFlip, "MAD Trail Flip", "MAD Volatility Trail changed direction on {{ticker}}")
````
