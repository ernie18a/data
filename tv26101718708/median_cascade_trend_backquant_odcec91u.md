# Median Cascade Trend [BackQuant]

- url: https://www.tradingview.com/script/ODCec91U-Median-Cascade-Trend-BackQuant/
- type: indicator
- pine_id: PUB;a5a61076a11248579472e40497844dc0
- version: 1.0

## Description

[b]Median Cascade Trend [BackQuant][/b]

[b]Overview[/b]
Median Cascade Trend is a noise-resistant trend-following indicator that combines [b]multiple causal median filters[/b], an [b]Ehlers-style two-pole Super Smoother[/b], and a configurable [b]chop-gating system[/b].

Its purpose is to identify meaningful directional structure while rejecting the types of price movement that frequently cause conventional moving averages to whipsaw:
[list]
[*]Single-bar spikes
[*]Short-lived price shocks
[*]Irregular wicks
[*]Low-efficiency sideways movement
[*]Weak slopes that do not represent genuine directional progress
[/list]

The indicator processes price in three distinct stages:
[list]
[*]A median-filter cascade removes impulsive and short-duration noise.
[*]A two-pole low-pass filter smooths the remaining structural signal.
[*]A chop gate decides whether a change in direction is strong enough to update the active trend state.
[/list]

This creates a trend line that is intentionally more selective than a standard moving average. The line itself can continue evolving, but trend-state changes are only accepted when the underlying movement passes the chosen quality tests.

The result is a system that separates:
[list]
[*]The estimated trend line
[*]The raw direction of that line
[*]The confirmed trend regime
[/list]

That distinction is important. The indicator does not assume that every small turn in a smoothed line represents a valid trend reversal.

[b]Core idea[/b]
Most trend filters are built around linear averaging. They combine historical prices using fixed or exponentially decaying weights.

Examples include:
[list]
[*]SMA
[*]EMA
[*]WMA
[*]HMA
[*]DEMA
[/list]

These filters are effective for general smoothing, but they have a weakness: a single extreme observation can influence the output immediately.

If one bar produces a large wick or temporary price shock, a moving average will usually be pulled toward that value because it includes the magnitude of every observation.

A median filter behaves differently.

Instead of averaging the values inside a window, it sorts them and selects the middle observation. This makes it highly resistant to isolated extremes.

Median Cascade Trend uses this property repeatedly before applying traditional low-pass smoothing.

The central idea is:
[list]
[*]Remove impulsive noise first.
[*]Smooth the cleaned signal second.
[*]Confirm direction only when the movement is efficient or sufficiently steep.
[/list]

This ordering is deliberate. Smoothing a noisy series and filtering noise before smoothing are not the same thing.

[b]Where median filtering comes from[/b]
Median filters are widely used in digital signal processing, image processing, and engineering.

One of their best-known applications is the removal of [b]impulse noise[/b], sometimes called salt-and-pepper noise in image processing.

Impulse noise consists of isolated extreme observations that are not representative of the surrounding signal.

In market data, comparable events include:
[list]
[*]Temporary liquidity gaps
[*]Single-bar stop runs
[*]Erroneous prints
[*]Sharp wick reversals
[*]News spikes that immediately retrace
[/list]

A linear smoother such as an SMA or EMA cannot distinguish between an important sustained move and an isolated outlier. Both are included according to their numerical magnitude.

A median filter is nonlinear. It selects the central-ranked value rather than calculating an arithmetic mean.

For example, consider five observations:

[list]
[*]100
[*]101
[*]102
[*]103
[*]140
[/list]

The average is:

[list]
[*]109.2
[/list]

The median is:

[list]
[*]102
[/list]

The isolated value at 140 significantly distorts the average but has almost no effect on the median.

This is why median filtering is especially useful when the objective is to preserve structural turns while rejecting isolated noise.

[b]What makes a median filter nonlinear[/b]
A normal moving average can be represented as a weighted sum of its inputs.

A median filter cannot.

Its output depends on the ordering of observations, not their arithmetic combination. This makes it a nonlinear filter.

That has several important consequences:
[list]
[*]Outliers have limited influence.
[*]Edges and structural shifts can be preserved more cleanly.
[*]The response is not equivalent to ordinary low-pass averaging.
[*]The filter may hold a value until enough observations confirm a change.
[/list]

In trading terms, the median filter often behaves more like a structural selector than a conventional average.

[b]What “causal” means[/b]
The median stages in this indicator are causal.

A causal filter uses:
[list]
[*]The current bar
[*]Past bars
[/list]

It does not use future observations.

This matters because many visually smooth filtering methods can only produce their best result by centering the calculation around the current point, which requires future data.

This script does not do that.

Every value is calculated from information available at that bar, making the filter suitable for live use.

[b]Why use a cascade of median filters[/b]
A single median filter can remove isolated spikes, but noise does not always occur as one extreme bar.

It can appear as:
[list]
[*]Two-bar shocks
[*]Short bursts of alternating movement
[*]Small clusters of irregular candles
[*]Residual distortion left after the first filtering pass
[/list]

A cascade applies multiple median stages sequentially:
[list]
[*]Stage 1 processes the original source.
[*]Stage 2 processes the output of Stage 1.
[*]Stage 3 processes the output of Stage 2.
[/list]

Each stage removes a different layer of short-duration instability.

The process is similar to progressively cleaning a signal:
[list]
[*]The first stage removes obvious impulse noise.
[*]The second stage removes remaining short-term irregularity.
[*]The third stage produces a more stable structural series before low-pass smoothing.
[/list]

[b]Median Stage 1[/b]
The first median stage is intended to reject isolated one-bar disturbances.

With a short setting such as 3:
[list]
[*]The filter remains responsive.
[*]Single-bar spikes are strongly suppressed.
[*]Most genuine multi-bar movement remains visible.
[/list]

This is the most tactical stage.

[b]Median Stage 2[/b]
The second stage receives an already-cleaned input.

Its role is to remove:
[list]
[*]Short-duration residual noise
[*]Small alternating movements
[*]Irregularity that survived the first stage
[/list]

A slightly longer setting such as 5 creates stronger structural consistency.

[b]Median Stage 3[/b]
The third stage provides the final nonlinear cleaning pass.

With a longer setting such as 7:
[list]
[*]The output becomes more stable.
[*]Short-lived reversals are reduced.
[*]Only more persistent changes are passed into the low-pass stage.
[/list]

This is the most conservative median stage.

[b]Cascade Stages input[/b]
The user can select how many median stages are active:
[list]
[*]1 stage: fastest and most responsive
[*]2 stages: balanced noise rejection
[*]3 stages: strongest impulse-noise suppression
[/list]

The unused stages are still calculated internally, but the selected stage determines which output is sent into the Super Smoother.

[b]Why cascade instead of one very long median[/b]
Applying several shorter filters is not always equivalent to applying one very long median filter.

A long median window can:
[list]
[*]Delay structural changes heavily
[*]Flatten shorter trend legs
[*]Become insensitive to local turns
[/list]

A cascade allows the filtering process to be distributed across stages.

This provides greater control over:
[list]
[*]How aggressively isolated noise is removed
[*]How much short-duration movement survives
[*]How smooth the final structural input becomes
[/list]

It also lets users build a progression such as 3, 5, and 7 rather than applying one blunt window.

[b]The low-pass stage[/b]
After the median cascade, the signal is passed into a [b]two-pole Super Smoother[/b].

The median cascade removes nonlinear impulse noise, but its output can still contain:
[list]
[*]Small step changes
[*]Residual high-frequency movement
[*]Sharp transitions caused by median replacement
[/list]

The Super Smoother converts that cleaned but potentially stepped series into a smoother trend line.

This creates a hybrid filtering system:
[list]
[*]Nonlinear median filtering for outlier rejection
[*]Recursive low-pass filtering for smooth trend extraction
[/list]

These components solve different problems.

[b]Where the Super Smoother comes from[/b]
The Super Smoother is associated with John F. Ehlers’ application of digital signal processing techniques to financial markets.

It is based on the behavior of a two-pole low-pass filter and is designed to suppress high-frequency components more effectively than many conventional moving averages.

Traditional moving averages are simple smoothers, but they are not necessarily optimized as frequency-selective filters.

The Super Smoother uses recursively calculated coefficients derived from:
[list]
[*]Exponential decay
[*]Trigonometric terms
[*]A selected cutoff period
[/list]

The objective is to reduce high-frequency market noise while retaining lower-frequency directional structure.

[b]What a low-pass filter does[/b]
A low-pass filter allows slow-moving components of a signal to pass while reducing fast-moving components.

In market terms:
[list]
[*]Slow components represent broader trend structure.
[*]Fast components represent short-term noise, rapid oscillation, and microstructure disturbance.
[/list]

The Low-Pass Length determines the separation.

Lower values:
[list]
[*]Allow more short-term movement through.
[*]React faster.
[*]Produce more turns.
[/list]

Higher values:
[list]
[*]Reject more high-frequency movement.
[*]Produce a smoother trend line.
[*]Respond later to structural changes.
[/list]

[b]Why use a two-pole filter[/b]
The number of poles broadly describes the order and steepness of a filter.

A two-pole filter generally provides:
[list]
[*]Stronger attenuation of high-frequency noise than a one-pole filter.
[*]A smoother output.
[*]A more defined frequency response.
[/list]

It also uses prior filter outputs recursively, allowing substantial smoothing without requiring an extremely long direct averaging window.

[b]The full signal-processing chain[/b]
The calculation can be understood as:

[list]
[*]Raw price source
[*]Median Stage 1
[*]Optional Median Stage 2
[*]Optional Median Stage 3
[*]Two-pole Super Smoother
[*]Direction measurement
[*]Chop-quality validation
[*]Persistent trend state
[/list]

Each layer has a distinct purpose.

[b]Median cascade[/b]
[list]
[*]Rejects isolated and short-lived noise.
[/list]

[b]Super Smoother[/b]
[list]
[*]Reduces the remaining high-frequency variation.
[/list]

[b]Direction logic[/b]
[list]
[*]Determines whether the final line is rising or falling.
[/list]

[b]Chop gate[/b]
[list]
[*]Determines whether that directional change is trustworthy enough to update the confirmed trend.
[/list]

[b]Trend direction calculation[/b]
The raw direction is determined by comparing the current trend line with its value several bars ago:

[list]
[*]Bullish if trendLine > trendLine[directionLen]
[*]Bearish if trendLine < trendLine[directionLen]
[*]Neutral if equal
[/list]

The Direction Lookback controls how much movement is required before the line is classified as rising or falling.

A one-bar comparison is extremely responsive but can detect tiny slope changes.

A longer comparison:
[list]
[*]Measures movement across a wider interval.
[*]Reduces sensitivity to one-bar flattening.
[*]Produces more stable raw direction.
[/list]

[b]Raw trend versus confirmed trend[/b]
One of the most important design choices is that the script separates:
[list]
[*]Raw trend
[*]Confirmed trend
[/list]

The raw trend reflects the current direction of the filtered line.

The confirmed trend is persistent and changes only when:
[list]
[*]The raw trend points in a new direction.
[*]The chop gate is open.
[/list]

If the line turns but the gate is closed:
[list]
[*]The active trend state remains unchanged.
[*]The attempted flip can optionally be displayed as blocked.
[/list]

This prevents every small line turn from immediately becoming a regime reversal.

[b]Why a chop filter is needed[/b]
Even an advanced smoother can turn repeatedly during sideways markets.

Smoothing reduces noise, but it does not determine whether movement is:
[list]
[*]Directional
[*]Efficient
[*]Large enough relative to volatility
[/list]

A line can move upward and downward in a range while making almost no net progress.

The chop gate addresses this by evaluating two separate properties:
[list]
[*]Directional efficiency
[*]ATR-normalized slope
[/list]

[b]Efficiency Ratio[/b]
The first gate component measures how efficiently the trend line has moved over a selected window.

The calculation compares:
[list]
[*]Net movement
[*]Total movement
[/list]

Net movement is:

[list]
[*]|trendLine - trendLine[efficiencyLen]|
[/list]

Total movement is:

[list]
[*]Sum of |bar-to-bar changes in trendLine|
[/list]

The Efficiency Ratio is:

[list]
[*]Efficiency = Net Movement / Total Movement
[/list]

The result ranges approximately from 0 to 1.

[b]Efficiency near 1[/b]
The line has moved mostly in one direction.

Example:
[list]
[*]It advanced 10 units.
[*]Its total path was approximately 11 units.
[/list]

This indicates a clean directional move.

[b]Efficiency near 0[/b]
The line has moved back and forth without achieving much net progress.

Example:
[list]
[*]It travelled 20 units in total.
[*]But ended only 1 unit from where it started.
[/list]

This indicates chop.

[b]Where the Efficiency Ratio comes from[/b]
The Efficiency Ratio is commonly associated with Perry Kaufman’s work on adaptive market analysis and the Kaufman Adaptive Moving Average.

Its purpose is to distinguish directional movement from noisy movement.

It does not measure the size of a move alone.

It measures the quality of the path.

This makes it highly suitable as a trend gate.

A market can be volatile but inefficient. It can move aggressively in both directions and still make little progress.

The Efficiency Ratio helps identify that distinction.

[b]Minimum Efficiency[/b]
The Minimum Efficiency input determines the directional quality required for the efficiency condition to pass.

Lower values:
[list]
[*]Allow more irregular movement.
[*]Open the gate more frequently.
[*]Produce earlier but noisier trend changes.
[/list]

Higher values:
[list]
[*]Require cleaner directional travel.
[*]Block more sideways flips.
[*]Produce fewer but more selective regime changes.
[/list]

[b]ATR-Normalized Slope[/b]
The second gate component measures how large the trend-line movement is relative to current market volatility.

It calculates:

[list]
[*]|trendLine - trendLine[slopeLen]| / ATR
[/list]

This converts the line’s movement into ATR units.

Without normalization, a slope of 10 points could be:
[list]
[*]Large for one instrument
[*]Negligible for another
[*]Large in a quiet regime
[*]Small during extreme volatility
[/list]

ATR normalization makes the slope more comparable across assets and regimes.

[b]What normalized slope measures[/b]
The Efficiency Ratio asks:
[list]
[*]Was the movement directionally clean?
[/list]

ATR-normalized slope asks:
[list]
[*]Was the movement large enough to matter?
[/list]

These are different questions.

A move can be highly efficient but extremely small.

For example:
[list]
[*]A perfectly smooth drift of only 0.02 ATR may not justify a new trend regime.
[/list]

A move can also be large but inefficient:
[list]
[*]A violent range may travel several ATRs while repeatedly reversing.
[/list]

Using both filters gives a more complete view of trend quality.

[b]Minimum ATR-Normalized Slope[/b]
The Minimum ATR-Normalized Slope defines the movement threshold.

Lower values:
[list]
[*]Accept weaker slopes.
[*]React sooner.
[*]Allow more low-energy flips.
[/list]

Higher values:
[list]
[*]Require stronger displacement.
[*]Reduce weak trend transitions.
[*]Delay signals until movement becomes more meaningful.
[/list]

[b]Gate modes[/b]
The indicator provides four chop-gate modes.

[b]Efficiency Ratio[/b]
Only directional efficiency is required.

Best suited for users who care primarily about whether movement is clean, regardless of its exact magnitude.

[b]ATR-Normalized Slope[/b]
Only slope strength is required.

Best suited for users who want movement to exceed a volatility-adjusted threshold, even if the path is not perfectly efficient.

[b]Both[/b]
Both conditions must pass:
[list]
[*]Efficiency must be high enough.
[*]Slope must be strong enough.
[/list]

This is the strictest mode and generally provides the strongest chop rejection.

[b]Either[/b]
Only one condition must pass.

This is more permissive:
[list]
[*]A very clean slow trend may pass through efficiency.
[*]A powerful but less orderly move may pass through slope.
[/list]

It provides a balance between responsiveness and filtering.

[b]Gate behavior[/b]
When the gate is open:
[list]
[*]A new raw direction can update the trend state.
[*]Bullish and bearish flips can be confirmed.
[/list]

When the gate is closed:
[list]
[*]The previous confirmed trend persists.
[*]Attempted changes are blocked.
[*]The display can dim, turn neutral, or hide.
[/list]

This means the indicator behaves like a regime-holding system during chop.

It does not constantly reset to neutral. It retains the last confirmed direction until sufficient evidence supports a new one.

[b]Blocked flips[/b]
A blocked flip occurs when:
[list]
[*]The filtered line attempts to change direction.
[*]The attempted direction differs from the confirmed trend.
[*]The chop gate is closed.
[*]The raw direction has just changed.
[/list]

These can optionally be displayed as small X markers.

Blocked flips are useful because they show:
[list]
[*]Where a basic slope indicator would have reversed.
[*]Where the chop filter rejected that reversal.
[*]How much signal noise the gate is removing.
[/list]

They are not trade signals. They are diagnostic information.

[b]Trend persistence[/b]
The trend variable is persistent.

Once bullish:
[list]
[*]It remains bullish until a valid bearish change passes the gate.
[/list]

Once bearish:
[list]
[*]It remains bearish until a valid bullish change passes the gate.
[/list]

This persistence is central to the design.

The indicator is not merely coloring every local slope. It is maintaining a confirmed market regime.

[b]Display modes when the gate is closed[/b]
The indicator offers three ways to display gated conditions.

[b]Dim[/b]
The current trend color remains visible but becomes transparent.

This communicates:
[list]
[*]The last confirmed trend is still active.
[*]Current conditions are not strong enough to confirm a new direction.
[/list]

This is useful when you want regime continuity without overstating conviction.

[b]Neutral[/b]
The trend line and candles switch to the selected gate color.

This communicates:
[list]
[*]The directional regime is being withheld.
[*]Current conditions are considered non-trending or uncertain.
[/list]

[b]Hide[/b]
The trend line disappears while the gate is closed.

This is the strictest visual mode.

It communicates:
[list]
[*]No actionable trend state should be displayed during the gated condition.
[/list]

[b]Trend line coloring[/b]
The base color is determined by the confirmed trend:
[list]
[*]Bullish trend uses the long color.
[*]Bearish trend uses the short color.
[*]Uninitialized state uses gray.
[/list]

The gate display can then modify the final presentation.

This allows the chart to show:
[list]
[*]Direction
[*]Confirmation status
[*]Chop-filter activity
[/list]

without needing a separate panel.

[b]Gradient fill[/b]
The indicator fills the area between price and the trend line.

When price is above the trend line:
[list]
[*]A bullish gradient is displayed.
[/list]

When price is below the trend line:
[list]
[*]A bearish gradient is displayed.
[/list]

The fill is stronger near the trend line and fades toward price.

This emphasizes the trend line as the structural reference.

The fill color follows the gate display state:
[list]
[*]Full trend color when active
[*]Dimmed during a closed gate in Dim mode
[*]Neutral when configured
[*]Hidden when the trend line is hidden
[/list]

[b]Trend glow[/b]
A soft glow is created around the filtered line using a small ATR-scaled distance.

The glow width is:

[list]
[*]ATR(14) × 0.06
[/list]

Using ATR ensures the glow remains visually proportional across assets and price scales.

The glow does not affect the calculation. It improves readability and reinforces the line as the central structural output.

[b]Candle coloring[/b]
Candles can be colored using the confirmed trend state.

When the gate is open:
[list]
[*]Bull trend produces bullish candles.
[*]Bear trend produces bearish candles.
[/list]

When the gate is closed:
[list]
[*]Dim mode fades the existing trend color.
[*]Neutral mode uses the gate color.
[*]Hide mode removes the candle override.
[/list]

This gives an immediate full-chart view of both trend and gate status.

[b]Signal logic[/b]
Signals only occur when the confirmed trend changes.

[b]Bullish flip[/b]
A bullish signal requires:
[list]
[*]The active trend becomes bullish.
[*]The previous trend was bearish.
[*]The gate accepted the change.
[/list]

[b]Bearish flip[/b]
A bearish signal requires:
[list]
[*]The active trend becomes bearish.
[*]The previous trend was bullish.
[*]The gate accepted the change.
[/list]

This is more selective than simply detecting a change in line slope.

[b]How to interpret the indicator[/b]

[b]Bullish confirmed regime[/b]
A bullish regime means:
[list]
[*]The median-filtered and low-pass-smoothed trend line is rising.
[*]The move satisfied the selected chop-filter conditions when the regime changed.
[*]The last accepted direction remains bullish.
[/list]

[b]Bearish confirmed regime[/b]
A bearish regime means:
[list]
[*]The final trend line is falling.
[*]The bearish change passed the selected quality gate.
[*]The last accepted direction remains bearish.
[/list]

[b]Gate closed in an existing trend[/b]
This means:
[list]
[*]The market is no longer moving with sufficient efficiency or slope.
[*]A new reversal cannot currently be confirmed.
[*]The previous regime remains stored.
[/list]

This often occurs during:
[list]
[*]Consolidation
[*]Pullbacks
[*]Low-volatility drift
[*]Transition phases
[/list]

[b]Repeated blocked flips[/b]
Repeated blocked changes suggest:
[list]
[*]The filtered line is oscillating.
[*]Directional quality is weak.
[*]A normal trend-following system would likely be whipsawing.
[/list]

This is exactly the environment the gate is designed to avoid.

[b]How to use it in practice[/b]

[b]1. Directional regime filter[/b]
Use the confirmed trend to filter other setups:
[list]
[*]Favor long trades during bullish regimes.
[*]Favor short trades during bearish regimes.
[*]Reduce activity when the gate is closed.
[/list]

[b]2. Trend-following entries[/b]
Bullish and bearish flips can be used as directional entry triggers, especially when confirmed by:
[list]
[*]Price structure
[*]Breakouts
[*]Volume expansion
[*]Higher-timeframe alignment
[/list]

[b]3. Pullback framework[/b]
During an established trend:
[list]
[*]Price returning toward the trend line may represent a pullback.
[*]If the gate remains closed but the trend does not flip, the move may be consolidation rather than reversal.
[*]If the opposite direction eventually passes the gate, the regime has changed more meaningfully.
[/list]

[b]4. Chop avoidance[/b]
The most direct use is avoiding repeated entries during low-quality conditions.

When the display is dim, neutral, or hidden:
[list]
[*]Reduce confidence in new trend signals.
[*]Wait for efficiency or slope to recover.
[/list]

[b]5. Diagnostic comparison[/b]
Enable blocked flips to see how often the raw trend attempts to reverse without confirmation.

This helps tune:
[list]
[*]Efficiency threshold
[*]Slope threshold
[*]Gate mode
[/list]

[b]Input guide[/b]

[b]Source[/b]
Selects the price series used by the median cascade.

Close is the standard choice.

Alternatives such as hl2 or hlc3 may produce a slightly smoother structural input.

[b]Cascade Stages[/b]
Controls how many median filters are used.

[list]
[*]1: responsive
[*]2: balanced
[*]3: strongest noise rejection
[/list]

[b]Median Stage Lengths[/b]
Control the window used at each stage.

Shorter values:
[list]
[*]Preserve responsiveness.
[*]Remove only very short-duration noise.
[/list]

Longer values:
[list]
[*]Produce stronger structural filtering.
[*]Delay shorter turns.
[/list]

[b]Low-Pass Length[/b]
Controls the two-pole Super Smoother.

Lower:
[list]
[*]Faster
[*]More reactive
[/list]

Higher:
[list]
[*]Smoother
[*]More conservative
[/list]

[b]Direction Lookback[/b]
Controls how far back the current line is compared when determining raw direction.

Lower:
[list]
[*]Faster slope changes
[/list]

Higher:
[list]
[*]More stable directional measurement
[/list]

[b]Efficiency Length[/b]
Controls the window used to measure net movement versus total path movement.

Shorter:
[list]
[*]More responsive efficiency reading
[*]More sensitive to recent chop
[/list]

Longer:
[list]
[*]More stable directional-quality assessment
[/list]

[b]Minimum Efficiency[/b]
Controls how clean the directional path must be.

Higher values make the gate stricter.

[b]Slope Length[/b]
Controls the interval across which trend-line movement is measured.

[b]Slope ATR Length[/b]
Controls the ATR baseline used to normalize slope.

[b]Minimum ATR-Normalized Slope[/b]
Controls the minimum volatility-adjusted displacement required.

Higher values require stronger movement.

[b]Tuning examples[/b]

[b]Faster trend configuration[/b]
[list]
[*]1 or 2 median stages
[*]Short median windows
[*]Lower Super Smoother length
[*]Direction Lookback of 1 or 2
[*]Either gate mode
[*]Lower efficiency and slope thresholds
[/list]

[b]Balanced configuration[/b]
[list]
[*]2 or 3 median stages
[*]Progressive windows such as 3, 5, 7
[*]Moderate Super Smoother length
[*]Both gate mode
[*]Moderate thresholds
[/list]

[b]Conservative configuration[/b]
[list]
[*]3 stages
[*]Longer median windows
[*]Higher Super Smoother length
[*]Longer Direction Lookback
[*]Both gate mode
[*]Higher minimum efficiency and slope
[/list]

[b]How this differs from a normal moving average[/b]
A standard moving average:
[list]
[*]Uses linear averaging.
[*]Responds directly to outlier magnitude.
[*]Changes direction whenever its slope changes.
[/list]

Median Cascade Trend:
[list]
[*]Uses nonlinear outlier-resistant preprocessing.
[*]Applies a proper recursive low-pass stage.
[*]Separates raw direction from confirmed regime.
[*]Blocks changes during inefficient or weak movement.
[/list]

[b]How this differs from a normal median filter[/b]
A basic median filter only removes impulse noise.

This indicator extends the idea by adding:
[list]
[*]Multiple median stages
[*]Low-pass smoothing
[*]Direction measurement
[*]Efficiency gating
[*]Volatility-normalized slope gating
[*]Persistent trend states
[*]Signals and alerts
[/list]

It is not simply a median-smoothed line. It is a complete trend-regime system built on median preprocessing.

[b]How this differs from a Supertrend[/b]
A Supertrend uses ATR bands around price and changes state when price crosses the trailing boundary.

Median Cascade Trend does not use a volatility band to define direction.

Instead:
[list]
[*]Direction comes from the slope of the filtered trend line.
[*]ATR is used only to normalize slope and scale visuals.
[*]Trend changes are controlled by movement quality rather than price crossing a stop band.
[/list]

[b]Strengths[/b]
[list]
[*]Strong rejection of isolated price spikes
[*]Preserves broader structural movement
[*]Combines nonlinear and linear filtering
[*]Separates raw turns from confirmed trend changes
[*]Configurable chop rejection
[*]Volatility-normalized slope testing
[*]Persistent directional regimes
[*]Blocked-flip diagnostics
[*]Fully causal calculation
[/list]

[b]Limitations[/b]
[list]
[*]Strong filtering can delay genuine reversals.
[*]Long median windows may suppress shorter trend legs.
[*]Strict gate settings can hold the previous regime too long.
[*]Loose gate settings reduce the benefit of chop filtering.
[*]Median filters can produce stepped transitions before low-pass smoothing.
[*]The indicator remains reactive rather than predictive.
[/list]

[b]Best use cases[/b]
Median Cascade Trend is particularly suited for:
[list]
[*]Trend filtering in noisy markets
[*]Reducing false reversals caused by wicks
[*]Swing-trading regime identification
[*]Filtering entries from faster systems
[*]Dynamic trend-structure visualization
[*]Avoiding sideways-market whipsaws
[/list]

It can be applied across:
[list]
[*]Equities
[*]Indices
[*]Futures
[*]Forex
[*]Cryptocurrency
[*]Commodities
[/list]

[b]Alerts[/b]
The indicator provides alerts for:
[list]
[*]Confirmed bullish trend changes
[*]Confirmed bearish trend changes
[*]Trend changes blocked by the chop filter
[/list]

The blocked-flip alert is especially useful for monitoring when the line attempts to reverse but market quality remains insufficient.

[b]Summary[/b]
Median Cascade Trend is a multi-stage trend extraction system designed to reject impulsive market noise before determining direction. It first applies up to three causal median filters, progressively removing isolated spikes and short-duration disturbances. The cleaned series is then passed through a two-pole Super Smoother to extract a stable low-frequency trend line.

Rather than accepting every change in slope, the indicator evaluates the quality of the movement using directional efficiency and ATR-normalized slope. Depending on the selected gate mode, trend changes can require clean directional travel, sufficient volatility-adjusted displacement, or both.

This produces a persistent trend state that changes only when the filtered line turns and the surrounding movement is strong enough to justify the reversal. The final result is a robust trend-following framework that combines outlier rejection, low-pass smoothing, directional-quality measurement, and chop suppression into a single overlay.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BackQuant

//@version=6
indicator("Median Cascade Trend [BackQuant]", "Median Cascade [BackQuant]", overlay = true)

// Inputs
const string g1 = "Median Cascade"
const string g2 = "Low-Pass Filter"
const string g3 = "Chop Filter"
const string g4 = "UI Settings"

float src = input.source(close, "Source", group = g1)
int stages = input.int(3, "Cascade Stages", minval = 1, maxval = 3, group = g1, tooltip = "Number of causal median filters applied before the low-pass stage.")
int medianLen1 = input.int(3, "Median Stage 1", minval = 2, maxval = 50, group = g1, tooltip = "Removes isolated one-bar spikes.")
int medianLen2 = input.int(5, "Median Stage 2", minval = 2, maxval = 50, group = g1, tooltip = "Removes remaining short-duration noise.")
int medianLen3 = input.int(7, "Median Stage 3", minval = 2, maxval = 50, group = g1, tooltip = "Final median stage before low-pass smoothing.")

int smoothLen = input.int(10, "Low-Pass Length", minval = 2, maxval = 100, group = g2, tooltip = "Two-pole Super Smoother applied after the median cascade.")
int directionLen = input.int(2, "Direction Lookback", minval = 1, maxval = 20, group = g2, tooltip = "Bars used to determine the direction of the final trend line.")

bool useGate = input.bool(true, "Chop Filter", group = g3, tooltip = "Blocks trend changes when movement lacks directional efficiency or sufficient slope.")
string gateMode = input.string("Both", "Gate Mode", options = ["Efficiency Ratio", "ATR-Normalized Slope", "Both", "Either"], group = g3, tooltip = "Both requires efficiency and slope to pass. Either allows a trend when one condition passes.")
int efficiencyLen = input.int(20, "Efficiency Length", minval = 5, maxval = 100, group = g3)
float efficiencyMin = input.float(0.25, "Minimum Efficiency", minval = 0.0, maxval = 1.0, step = 0.05, group = g3)
int slopeLen = input.int(2, "Slope Length", minval = 1, maxval = 20, group = g3)
int slopeAtrLen = input.int(14, "Slope ATR Length", minval = 1, maxval = 100, group = g3)
float slopeMin = input.float(0.08, "Minimum ATR-Normalized Slope", minval = 0.0, maxval = 5.0, step = 0.01, group = g3)

bool showLine = input.bool(true, "Show Trend Line", group = g4)
bool showFill = input.bool(true, "Gradient Fill", group = g4)
bool showGlow = input.bool(true, "Trend Glow", group = g4)
bool showSig = input.bool(true, "Show Signals", group = g4)
bool showBlocked = input.bool(false, "Show Blocked Flips", group = g4)
bool showGate = input.bool(true, "Show Gate Status", group = g4)
string gateDisplay = input.string("Dim", "Closed Gate Display", options = ["Dim", "Neutral", "Hide"], group = g4)
bool paintBar = input.bool(true, "Color Candles", group = g4)
int lineW = input.int(3, "Line Width", minval = 1, maxval = 6, group = g4)
color longCol = input.color(#00ff00, "Bullish", inline = "c", group = g4)
color shortCol = input.color(#ff0000, "Bearish", inline = "c", group = g4)
color gateCol = input.color(#555555, "Gated", inline = "c", group = g4)

// Two-Pole Super Smoother
superSmoother(float source, simple int length) =>
    float a1 = math.exp(-1.414 * math.pi / length)
    float b1 = 2.0 * a1 * math.cos(1.414 * math.pi / length)
    float c2 = b1
    float c3 = -a1 * a1
    float c1 = 1.0 - c2 - c3
    float filt = na
    filt := c1 * (source + nz(source[1], source)) * 0.5 + c2 * nz(filt[1], source) + c3 * nz(filt[2], source)
    filt

// Median Cascade
float median1 = ta.median(src, medianLen1)
float median2 = ta.median(median1, medianLen2)
float median3 = ta.median(median2, medianLen3)
float medianOut = stages == 1 ? median1 : stages == 2 ? median2 : median3

// Low-Pass Stage
float trendLine = superSmoother(medianOut, smoothLen)

// Chop Filter
float netMovement = math.abs(trendLine - trendLine[efficiencyLen])
float totalMovement = math.sum(math.abs(ta.change(trendLine)), efficiencyLen)
float efficiency = totalMovement > 0.0 ? netMovement / totalMovement : 0.0

float slopeAtr = ta.atr(slopeAtrLen)
float normalizedSlope = slopeAtr > 0.0 ? math.abs(trendLine - trendLine[slopeLen]) / slopeAtr : 0.0

bool efficiencyPass = efficiency >= efficiencyMin
bool slopePass = normalizedSlope >= slopeMin
bool gatePass = gateMode == "Efficiency Ratio" ? efficiencyPass : gateMode == "ATR-Normalized Slope" ? slopePass : gateMode == "Either" ? efficiencyPass or slopePass : efficiencyPass and slopePass
bool gateOpen = not useGate or gatePass

// Trend
int rawTrend = trendLine > trendLine[directionLen] ? 1 : trendLine < trendLine[directionLen] ? -1 : 0

var int trend = 0
if gateOpen and rawTrend != 0 and rawTrend != trend
    trend := rawTrend

bool bullFlip = trend == 1 and trend[1] == -1
bool bearFlip = trend == -1 and trend[1] == 1
bool blocked = not gateOpen and rawTrend != 0 and rawTrend != trend and rawTrend != rawTrend[1]

// Plot Colors
color baseTrendCol = trend == 1 ? longCol : trend == -1 ? shortCol : color.gray
color trendCol = not gateOpen and showGate and gateDisplay == "Neutral" ? gateCol : baseTrendCol
int lineAlpha = not gateOpen and showGate and gateDisplay == "Dim" ? 65 : 0
float plottedTrend = not gateOpen and showGate and gateDisplay == "Hide" ? na : trendLine

color candleCol = baseTrendCol
if not gateOpen and showGate
    candleCol := gateDisplay == "Neutral" ? gateCol : gateDisplay == "Hide" ? na : color.new(baseTrendCol, 65)
else
    candleCol := color.new(baseTrendCol, 10)

// Plots
pLine = plot(showLine ? plottedTrend : na, "Median Cascade Trend", color = color.new(trendCol, lineAlpha), linewidth = lineW)
pPrice = plot(close, "Price Ref", display = display.none, editable = false)

// Gradient Fill
fill(pPrice, pLine, close > trendLine ? close : trendLine, close > trendLine ? trendLine : close, showFill and close > trendLine and not na(plottedTrend) ? color.new(trendCol, 20 + lineAlpha) : na, showFill and close > trendLine and not na(plottedTrend) ? color.new(trendCol, 92) : na, title = "Bull Fill")
fill(pPrice, pLine, close < trendLine ? trendLine : close, close < trendLine ? close : trendLine, showFill and close < trendLine and not na(plottedTrend) ? color.new(trendCol, 20 + lineAlpha) : na, showFill and close < trendLine and not na(plottedTrend) ? color.new(trendCol, 92) : na, title = "Bear Fill")

// Trend Glow
float glow = ta.atr(14) * 0.06
pGlowLower = plot(not na(plottedTrend) ? trendLine - glow : na, "Glow Lower Ref", display = display.none, editable = false)
pGlowUpper = plot(not na(plottedTrend) ? trendLine + glow : na, "Glow Upper Ref", display = display.none, editable = false)
fill(pLine, pGlowLower, showGlow and not na(plottedTrend) ? color.new(trendCol, 55 + int(lineAlpha * 0.5)) : na, title = "Glow Lower")
fill(pLine, pGlowUpper, showGlow and not na(plottedTrend) ? color.new(trendCol, 55 + int(lineAlpha * 0.5)) : na, title = "Glow Upper")

// Candles
barcolor(paintBar ? candleCol : na, title = "Trend Candles")

// Signals
plotshape(showSig and bullFlip ? trendLine : na, "Bull Flip", shape.labelup, location.absolute, longCol, text = "▲", textcolor = chart.bg_color, size = size.small)
plotshape(showSig and bearFlip ? trendLine : na, "Bear Flip", shape.labeldown, location.absolute, shortCol, text = "▼", textcolor = chart.bg_color, size = size.small)
plotshape(showBlocked and blocked ? trendLine : na, "Blocked Flip", shape.xcross, location.absolute, gateCol, size = size.tiny)

// Alerts
alertcondition(bullFlip, "Median Cascade Bullish", "Median Cascade Trend turned bullish on {{ticker}}")
alertcondition(bearFlip, "Median Cascade Bearish", "Median Cascade Trend turned bearish on {{ticker}}")
alertcondition(blocked, "Median Cascade Flip Blocked", "Median Cascade trend change blocked by the chop filter on {{ticker}}")
````
