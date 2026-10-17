# Innovation-Gated Hull Supertrend [BackQuant]

- url: https://www.tradingview.com/script/tq9f0qwr-Innovation-Gated-Hull-Supertrend-BackQuant/
- type: indicator
- pine_id: PUB;4b18470097494e1d8c3d8422e9f54597
- version: 1.0

## Description

[b]Innovation-Gated Hull Supertrend [BackQuant][/b]

[b]Overview[/b]

Innovation-Gated Hull Supertrend is an adaptive trend-following overlay that combines three distinct signal-processing components:

[list]
[*]A Hull Moving Average projection for responsive trend estimation.
[*]An innovation-gated recursive filter for adaptive noise reduction.
[*]A volatility-based Supertrend applied to the filtered Hull estimate.
[/list]

The indicator is designed to behave differently during quiet and active market conditions.

When the Hull estimate changes only slightly relative to recent volatility, the innovation gate restricts how much of that movement is admitted into the filtered trend estimate. The Supertrend bands can also expand during these quieter conditions, reducing sensitivity to minor fluctuations.

When a larger and statistically more meaningful change occurs, the gate opens. The recursive filter becomes more responsive, the Supertrend bands return closer to their base width, and the model is allowed to react more quickly.

The result is a trend framework that attempts to balance two competing requirements:

[list]
[*]Remain stable when price movement is small and noisy.
[*]Respond more quickly when new information produces a meaningful displacement.
[/list]

The indicator does not predict future prices. It is a causal trend model that adapts its response according to the size of newly arriving information relative to the current volatility environment.

[b]Core calculation chain[/b]

The complete calculation can be summarised as:

[list=1]
[*]Calculate a Hull Moving Average projection from the selected price source.
[*]Estimate current volatility using ATR, standard deviation, or a blend of both.
[*]Compare the Hull projection with the recursive filter’s previous estimate.
[*]Normalise that difference by volatility to calculate an innovation score.
[*]Pass the score through a smooth logistic gate.
[*]Use the gate to adapt the recursive filter’s measurement and process uncertainty.
[*]Generate the innovation-filtered Hull estimate.
[*]Optionally adapt the Supertrend band multiplier using the same gate.
[*]Apply Supertrend logic around the filtered Hull estimate.
[*]Generate bullish and bearish regime changes when the Supertrend changes sides.
[/list]

Each stage solves a different problem.

The Hull projection provides a responsive directional input. The innovation filter decides how much of that input should be trusted. The Supertrend then converts the filtered estimate into a persistent trailing regime.

[b]Historical background[/b]

The indicator combines ideas from several areas of technical analysis and signal processing.

[b]Hull Moving Average[/b]

The Hull Moving Average was developed by Alan Hull as a method of reducing lag while preserving a smooth output.

Traditional moving averages face a basic trade-off:

[list]
[*]Short averages respond quickly but contain more noise.
[*]Long averages are smoother but react later.
[/list]

The Hull Moving Average attempts to improve this balance by combining weighted moving averages of different lengths.

Its general construction is:

[list]
[*]Fast WMA = WMA of price over approximately half the main length.
[*]Slow WMA = WMA of price over the full length.
[*]Raw Hull = 2 × Fast WMA - Slow WMA.
[*]Final Hull = WMA of the Raw Hull over the square root of the main length.
[/list]

The subtraction stage compensates for some of the delay introduced by the longer average. The final square-root smoothing stage reduces noise in the compensated series.

[b]Recursive estimation and the Kalman-filter principle[/b]

The innovation filter is based on the general recursive-estimation framework associated with Kalman filtering.

The Kalman filter was developed by Rudolf E. Kálmán and became widely used in engineering, navigation, aerospace, robotics and control systems.

A recursive estimator typically follows two stages:

[list]
[*]Predict the current state from the previous state.
[*]Correct that prediction using the newest observation.
[/list]

The correction depends on how uncertain the model is and how reliable the new observation is believed to be.

The difference between the observation and prediction is called the:

[b]Innovation[/b]

In this indicator:

[list]
[*]The observation is the current Hull projection.
[*]The prediction is the previous filtered estimate.
[*]The innovation is the difference between them.
[/list]

A large innovation means the Hull projection has moved significantly away from the model’s prior estimate.

A small innovation means the new observation is close to what the model already expected.

[b]Supertrend[/b]

Supertrend is a volatility-trailing concept built from an underlying price reference and ATR-based bands.

Its basic structure consists of:

[list]
[*]An upper band above the reference.
[*]A lower band below the reference.
[*]One-sided trailing behaviour.
[*]A regime switch when price crosses the opposing band.
[/list]

In a bullish regime, the lower band acts as the active trail.

In a bearish regime, the upper band acts as the active trail.

This indicator modifies the conventional approach in two important ways:

[list]
[*]The central reference is the innovation-filtered Hull estimate rather than a normal price midpoint.
[*]The band multiplier can adapt according to the innovation gate.
[/list]

[b]Stage 1: Hull projection[/b]

The first stage calculates the Hull projection from the selected price source.

The script determines:

[list]
[*]The full Hull length.
[*]A half-length rounded to a valid integer.
[*]A square-root length rounded to a valid integer.
[/list]

It then calculates:

[list]
[*]Fast WMA = WMA(source, half length)
[*]Slow WMA = WMA(source, full length)
[*]Raw Hull = 2 × Fast WMA - Slow WMA
[*]Hull Projection = WMA(Raw Hull, square-root length)
[/list]

The Hull projection is more responsive than many conventional moving averages of a similar nominal length.

However, responsiveness also means it can react to short-lived movements. For that reason, the Hull projection is not used directly as the final trend line. It becomes the observation supplied to the innovation filter.

[b]Hull Length[/b]

The Hull Length controls the underlying trend horizon.

Lower values:

[list]
[*]React more quickly.
[*]Follow shorter trend legs.
[*]Produce more local changes.
[*]Admit more short-term noise into the next stage.
[/list]

Higher values:

[list]
[*]Produce a smoother projection.
[*]Focus on broader trend structure.
[*]Respond later to sudden reversals.
[/list]

The Hull Length therefore controls the basic timescale of the model before any adaptive filtering or Supertrend logic is applied.

[b]Stage 2: Volatility model[/b]

The innovation must be interpreted relative to current market conditions.

A movement of 10 points may be large in a quiet market but insignificant in a highly volatile market.

The indicator therefore normalises the innovation using a selectable volatility estimate.

Three modes are available:

[list]
[*]ATR
[*]Standard Deviation
[*]Blend
[/list]

[b]ATR mode[/b]

Average True Range measures recent trading range while accounting for gaps from the previous close.

True Range is based on the greatest of:

[list]
[*]Current high minus current low.
[*]Absolute current high minus previous close.
[*]Absolute current low minus previous close.
[/list]

ATR then smooths True Range across the selected Volatility Length.

ATR is useful because it measures the realised movement range of the instrument.

It is sensitive to:

[list]
[*]Wide candles.
[*]Price gaps.
[*]Range expansion.
[/list]

[b]Standard Deviation mode[/b]

Standard deviation measures how widely the Hull projection has varied around its recent mean.

It is a dispersion measure rather than a range measure.

Standard deviation responds to:

[list]
[*]Variation in the selected series.
[*]Directional displacement.
[*]Changes in the distribution of the filtered input.
[/list]

While ATR focuses on bar range, standard deviation focuses on dispersion of the Hull series itself.

[b]Blend mode[/b]

Blend mode calculates the average of ATR and standard deviation.

Conceptually:

[list]
[*]Blended Volatility = (ATR + Standard Deviation) / 2
[/list]

This provides a combined estimate incorporating:

[list]
[*]Observed range behaviour.
[*]Statistical dispersion of the Hull projection.
[/list]

Neither measure is universally superior. The blend attempts to reduce dependence on only one definition of volatility.

[b]Volatility Length[/b]

The Volatility Length controls how quickly the normalisation baseline changes.

Lower values:

[list]
[*]React faster to recent volatility changes.
[*]Cause the innovation score to adjust more quickly.
[*]May make the gate less stable.
[/list]

Higher values:

[list]
[*]Produce a slower volatility baseline.
[*]Create more consistent normalisation.
[*]May respond later when volatility changes abruptly.
[/list]

The volatility estimate is prevented from falling below the instrument’s minimum tick size, avoiding unstable division during extremely quiet periods.

[b]Stage 3: Innovation calculation[/b]

The filter begins each bar with a prediction.

In this implementation, the prediction is the previous filtered estimate.

The innovation is:

[list]
[*]Innovation = Hull Projection - Previous Filter Estimate
[/list]

The innovation may be positive or negative.

A positive value means the Hull projection is above the prior estimate.

A negative value means it is below the prior estimate.

The absolute innovation measures the size of the disagreement regardless of direction.

[b]Innovation score[/b]

The raw innovation is normalised by current volatility:

[list]
[*]Innovation Score = |Innovation| / Volatility
[/list]

This expresses the new movement in volatility units.

For example:

[list]
[*]A score of 0.25 means the innovation is approximately one quarter of the selected volatility measure.
[*]A score of 1.00 means it is approximately equal to that volatility measure.
[*]A score above 1.00 means the change is larger than the current volatility baseline.
[/list]

The score is dimensionless, making it more comparable across instruments and price scales.

This is the key quantity used to determine whether the filter should remain cautious or become more responsive.

[b]Stage 4: Logistic innovation gate[/b]

The innovation score is passed through a logistic function.

The logistic function has the form:

[list]
[*]Gate = 1 / (1 + exp(-x))
[/list]

Its output remains between zero and one.

In the indicator, the gate input depends on:

[list]
[*]Innovation Score
[*]Innovation Threshold
[*]Gate Sharpness
[/list]

Conceptually:

[list]
[*]Gate Input = Sharpness × (Score - Threshold)
[/list]

When the score is below the threshold:

[list]
[*]The gate approaches zero.
[*]The filter treats the new Hull movement cautiously.
[/list]

When the score rises above the threshold:

[list]
[*]The gate moves toward one.
[*]The filter becomes more willing to admit the new movement.
[/list]

The logistic function creates a smooth transition rather than a hard on/off switch.

This is important because a binary threshold could cause abrupt changes whenever the score moves slightly above or below one exact value.

[b]Innovation Threshold[/b]

The Innovation Threshold determines where the gate begins moving from a quiet state toward an active state.

Higher values:

[list]
[*]Require a larger volatility-normalised innovation.
[*]Keep the filter conservative for longer.
[*]Reject more moderate changes.
[/list]

Lower values:

[list]
[*]Open the gate sooner.
[*]Increase responsiveness.
[*]Allow smaller movements to influence the estimate.
[/list]

The threshold should be interpreted in relation to the selected volatility model.

[b]Gate Sharpness[/b]

Gate Sharpness controls how rapidly the logistic gate transitions around the threshold.

Lower sharpness:

[list]
[*]Creates a gradual transition.
[*]Produces a wider intermediate region.
[*]Changes responsiveness smoothly.
[/list]

Higher sharpness:

[list]
[*]Makes the gate behave more like a hard switch.
[*]Creates a faster transition near the threshold.
[*]Produces stronger separation between quiet and active states.
[/list]

An extremely high value can make the adaptive behaviour abrupt, while a low value may reduce the distinction between quiet and active conditions.

[b]Admission Floor[/b]

The gate is converted into an admission value.

The Admission Floor ensures that the filter never completely ignores the Hull projection.

The admission calculation is:

[list]
[*]Admission = Floor + (1 - Floor) × Gate
[/list]

When the gate is near zero:

[list]
[*]Admission remains near the selected floor.
[/list]

When the gate is near one:

[list]
[*]Admission approaches one.
[/list]

A lower floor creates stronger filtering during quiet conditions.

A higher floor keeps the model more responsive even when innovation is small.

This setting prevents the estimator from becoming fully frozen.

[b]Stage 5: Adaptive recursive update[/b]

The admission and gate values modify two uncertainty terms:

[list]
[*]Measurement noise.
[*]Process noise.
[/list]

These terms control how the recursive filter balances its existing estimate against the new Hull observation.

[b]Measurement Noise[/b]

Measurement Noise represents uncertainty in the incoming Hull projection.

Higher measurement noise tells the filter:

[list]
[*]Trust the new observation less.
[*]Remain closer to the previous estimate.
[*]Produce more smoothing.
[/list]

Lower measurement noise tells the filter:

[list]
[*]Trust the Hull projection more.
[*]Correct the estimate more aggressively.
[*]Become more responsive.
[/list]

The script adapts measurement noise using the admission value:

[list]
[*]Adaptive Measurement Noise = Base Measurement Noise / Admission
[/list]

When admission is low:

[list]
[*]Measurement noise increases.
[*]The new Hull movement receives less weight.
[/list]

When admission is high:

[list]
[*]Measurement noise moves closer to its base value.
[*]The filter becomes more receptive.
[/list]

[b]Process Noise[/b]

Process Noise represents uncertainty in the filter’s current state model.

Higher process noise tells the estimator:

[list]
[*]The underlying trend may be changing.
[*]The previous estimate may no longer be reliable.
[*]Allow faster adaptation.
[/list]

Lower process noise tells it:

[list]
[*]Assume the existing state remains relatively stable.
[*]Change the estimate more cautiously.
[/list]

The script increases process noise as the gate opens:

[list]
[*]Adaptive Process Noise = Base Process Noise × (1 + Process Boost × Gate)
[/list]

This creates a two-sided adaptive response.

During quiet conditions:

[list]
[*]Measurement noise increases.
[*]Process noise remains closer to its base level.
[*]The filter resists small changes.
[/list]

During high-innovation conditions:

[list]
[*]Measurement noise decreases toward its normal value.
[*]Process noise increases.
[*]The filter becomes substantially more responsive.
[/list]

[b]Process Boost[/b]

Process Boost controls how strongly the process uncertainty expands when the gate opens.

Higher values:

[list]
[*]Allow faster response to large innovations.
[*]Increase the filter gain during active movement.
[*]Can make the model more sensitive after shocks.
[/list]

Lower values:

[list]
[*]Keep behaviour closer to the base recursive filter.
[*]Produce more controlled adaptation.
[*]May respond more slowly to genuine regime changes.
[/list]

[b]Covariance and filter gain[/b]

The recursive filter maintains an internal covariance representing uncertainty in its estimate.

Before the new observation is processed:

[list]
[*]Predicted Covariance = Previous Covariance + Adaptive Process Noise
[/list]

The filter gain is then:

[list]
[*]Gain = Predicted Covariance / (Predicted Covariance + Adaptive Measurement Noise)
[/list]

The gain remains between zero and one.

A low gain means:

[list]
[*]The previous estimate receives more influence.
[*]The Hull observation receives less influence.
[/list]

A high gain means:

[list]
[*]The filter moves more strongly toward the current Hull projection.
[/list]

The new estimate is:

[list]
[*]Filtered Hull = Prediction + Gain × Innovation
[/list]

The covariance is then updated for the next bar.

[b]Why the filter is innovation-gated[/b]

A normal recursive filter may use constant process and measurement noise settings.

That means its responsiveness is broadly fixed.

This indicator changes those terms according to the size of the innovation.

The model therefore behaves differently under two broad conditions.

[b]Quiet condition[/b]

When the Hull projection remains close to the prior estimate relative to volatility:

[list]
[*]Innovation score is low.
[*]Gate remains mostly closed.
[*]Admission is limited.
[*]Adaptive measurement noise rises.
[*]Process noise remains lower.
[*]Filter gain falls.
[*]The filtered Hull changes more slowly.
[/list]

[b]Active condition[/b]

When the Hull projection moves meaningfully away from the prior estimate:

[list]
[*]Innovation score rises.
[*]Gate opens.
[*]Admission approaches one.
[*]Measurement noise decreases.
[*]Process noise increases.
[*]Filter gain rises.
[*]The estimate adapts more quickly.
[/list]

This allows the model to filter small movement without applying the same degree of resistance to every large move.

[b]Stage 6: Innovation-adaptive Supertrend bands[/b]

The filtered Hull becomes the centre of the Supertrend calculation.

The initial raw bands are:

[list]
[*]Upper Band = Filtered Hull + Factor × ATR
[*]Lower Band = Filtered Hull - Factor × ATR
[/list]

The Supertrend uses its own ATR Period, which is independent of the volatility length used by the innovation score.

This distinction is important:

[list]
[*]Innovation volatility determines whether the filter should admit new information.
[*]Supertrend ATR determines the distance of the trailing regime bands.
[/list]

[b]Adaptive band factor[/b]

When Adapt Bands With Innovation is enabled, the Supertrend factor changes according to the gate.

The adaptive factor is:

[list]
[*]Adaptive Factor = Base Factor × [1 + Quiet Expansion × (1 - Gate)]
[/list]

When the gate is near one:

[list]
[*]The adaptive factor approaches the base factor.
[*]Bands become relatively tighter.
[*]The Supertrend can respond more readily.
[/list]

When the gate is near zero:

[list]
[*]The factor expands above its base value.
[*]Bands become wider.
[*]Minor price fluctuations are less likely to cause a reversal.
[/list]

This creates coordinated adaptation:

[list]
[*]Quiet conditions produce stronger filtering and wider bands.
[*]Active conditions produce faster filtering and narrower bands.
[/list]

The same innovation state therefore influences both the centre estimate and the trailing threshold.

[b]Quiet Band Expansion[/b]

Quiet Band Expansion controls how much wider the Supertrend factor becomes when the innovation gate is closed.

A value of zero disables the expansion effect even if band adaptation is enabled.

Higher values:

[list]
[*]Create wider bands during low-innovation conditions.
[*]Reduce quiet-market reversals.
[*]Delay new signals until price moves further.
[/list]

Lower values:

[list]
[*]Keep the adaptive factor closer to its base setting.
[*]Allow more responsive regime changes.
[/list]

The expansion is greatest when the gate is near zero and fades as the gate opens.

[b]Supertrend trailing logic[/b]

The raw upper and lower bands are converted into one-sided trailing bands.

The lower band is prevented from moving downward while price remains above its previous value.

The upper band is prevented from moving upward while price remains below its previous value.

This ratcheting behaviour creates:

[list]
[*]A rising lower trail during bullish conditions.
[*]A falling upper trail during bearish conditions.
[/list]

A trend change occurs when price crosses the active opposing boundary.

In a bullish regime:

[list]
[*]The lower band is the active Supertrend.
[/list]

In a bearish regime:

[list]
[*]The upper band is the active Supertrend.
[/list]

[b]ATR Period and Factor[/b]

[b]ATR Period[/b]

Controls the volatility horizon used to construct the Supertrend bands.

Lower values:

[list]
[*]React faster to current range changes.
[*]Produce more variable band widths.
[/list]

Higher values:

[list]
[*]Produce a steadier range estimate.
[*]Respond more slowly to sudden volatility changes.
[/list]

[b]Factor[/b]

Controls the base distance between the filtered Hull and the Supertrend bands.

Lower factors:

[list]
[*]Create tighter bands.
[*]Produce earlier regime changes.
[*]Increase sensitivity to noise.
[/list]

Higher factors:

[list]
[*]Create wider bands.
[*]Produce fewer regime changes.
[*]Increase confirmation delay.
[/list]

When adaptation is enabled, the selected factor acts as the minimum or active-condition factor. Quiet conditions may expand it further.

[b]Trend signals[/b]

The indicator generates a long signal when the Supertrend changes into its bullish state.

It generates a short signal when the Supertrend changes into its bearish state.

The signal requires the completed calculation chain:

[list]
[*]Hull projection.
[*]Innovation filtering.
[*]Adaptive band factor.
[*]Supertrend regime change.
[/list]

The plotted symbols are:

[list]
[*][b]𝕃[/b] for a bullish transition.
[*][b]𝕊[/b] for a bearish transition.
[/list]

These markers identify regime changes. They are not complete trading systems and do not define stop placement, position size or profit targets.

[b]Innovation impulse alert[/b]

The script also includes an Innovation Impulse alert.

This occurs when the innovation score crosses above the selected Innovation Threshold.

It indicates that:

[list]
[*]The difference between the Hull projection and the recursive estimate has become large relative to volatility.
[*]The gate is entering a more active state.
[*]The filter is beginning to admit new information more aggressively.
[/list]

An innovation impulse does not necessarily produce an immediate Supertrend reversal.

It can occur:

[list]
[*]During acceleration within an existing trend.
[*]At the beginning of a possible regime change.
[*]During a temporary volatility shock.
[/list]

It is therefore best interpreted as an information-arrival event rather than an automatic long or short signal.

[b]Visual components[/b]

[b]Hull Projection[/b]

Displays the unfiltered Hull Moving Average input.

This is useful for comparing:

[list]
[*]The responsive raw projection.
[*]The innovation-filtered result.
[*]The final Supertrend.
[/list]

The Hull projection will generally react first.

[b]Filtered Hull[/b]

Displays the recursive innovation-gated estimate.

The distance between the Hull projection and filtered Hull helps illustrate the filter’s current behaviour.

During quiet conditions:

[list]
[*]The filtered Hull may lag behind small changes.
[/list]

During meaningful innovations:

[list]
[*]It can move more rapidly toward the Hull projection.
[/list]

[b]IGH Supertrend[/b]

Displays the final volatility trail around the filtered Hull.

It is the primary regime output.

The line is coloured according to the persistent bullish or bearish trend state.

[b]Candle colouring[/b]

Candles may be coloured according to the active Supertrend regime:

[list]
[*]Bullish colour during the long regime.
[*]Bearish colour during the short regime.
[/list]

This provides immediate chart-wide directional context.

[b]How to interpret the indicator[/b]

[b]Bullish regime[/b]

A bullish regime indicates that price has crossed into the bullish side of the adaptive Supertrend structure.

The active trail is positioned below the market and can be interpreted as:

[list]
[*]A dynamic trend boundary.
[*]A possible pullback reference.
[*]A regime invalidation guide.
[/list]

[b]Bearish regime[/b]

A bearish regime indicates that price has crossed into the bearish side of the adaptive structure.

The active trail is positioned above the market and may act as:

[list]
[*]Dynamic resistance.
[*]A rally reference.
[*]A bearish regime invalidation guide.
[/list]

[b]Low innovation score[/b]

A low score means the current Hull movement is small relative to volatility.

The model responds by:

[list]
[*]Filtering more strongly.
[*]Reducing admission.
[*]Using a lower recursive gain.
[*]Potentially expanding the Supertrend bands.
[/list]

This is intended to reduce reactions to small fluctuations.

[b]High innovation score[/b]

A high score means the Hull projection has changed substantially relative to volatility.

The model responds by:

[list]
[*]Opening the gate.
[*]Increasing admission.
[*]Increasing process uncertainty.
[*]Raising the filter gain.
[*]Reducing quiet-condition band expansion.
[/list]

This allows a faster response when the incoming information is more significant.

[b]Rising Hull without a trend flip[/b]

The Hull projection may turn before the filtered Hull or Supertrend.

This means:

[list]
[*]The fast input has changed.
[*]The adaptive filter has not yet admitted enough of that change.
[*]The Supertrend boundary has not yet been crossed.
[/list]

This is not an error. It demonstrates the staged confirmation design.

[b]Innovation impulse without trend reversal[/b]

An innovation impulse can occur without a long or short signal.

This may indicate:

[list]
[*]Acceleration in the existing trend.
[*]A volatility shock.
[*]An attempted reversal that has not crossed the Supertrend.
[/list]

The Supertrend remains the final regime layer.

[b]How to use the indicator[/b]

[b]1. Trend regime filter[/b]

Use the active Supertrend state to filter another entry method:

[list]
[*]Prioritise long setups during bullish regimes.
[*]Prioritise short setups during bearish regimes.
[/list]

[b]2. Pullback framework[/b]

In a bullish regime, pullbacks toward the Supertrend may represent tests of the active trend boundary.

In a bearish regime, rallies toward the Supertrend may represent resistance tests.

A touch alone does not guarantee continuation.

[b]3. Innovation monitoring[/b]

The innovation alert can be used to identify when the model detects a meaningful change in its input.

This may help direct attention to:

[list]
[*]Fresh acceleration.
[*]Breakout attempts.
[*]Possible trend transitions.
[/list]

[b]4. Confirmation framework[/b]

The three optional lines can be read as a progression:

[list]
[*]Hull projection changes first.
[*]Filtered Hull adapts according to innovation.
[*]Supertrend confirms the final regime.
[/list]

This allows users to study the difference between early movement and confirmed structure.

[b]5. Trailing risk reference[/b]

The final Supertrend may be used as a visual trailing reference.

However, it does not account for:

[list]
[*]Account size.
[*]Position size.
[*]Slippage.
[*]Liquidity.
[*]Maximum acceptable loss.
[/list]

It should not replace a complete risk-management process.

[b]Parameter interaction[/b]

The settings should not be tuned independently without considering how they interact.

[b]More responsive configuration[/b]

A more responsive setup may use:

[list]
[*]Lower Hull Length.
[*]Lower Innovation Threshold.
[*]Higher Admission Floor.
[*]Lower Measurement Noise.
[*]Higher Process Noise or Process Boost.
[*]Lower Supertrend Factor.
[*]Lower Quiet Band Expansion.
[/list]

This will generally produce earlier changes but more noise.

[b]More conservative configuration[/b]

A more conservative setup may use:

[list]
[*]Higher Hull Length.
[*]Higher Innovation Threshold.
[*]Lower Admission Floor.
[*]Higher Measurement Noise.
[*]Lower Process Boost.
[*]Higher Supertrend Factor.
[*]Higher Quiet Band Expansion.
[/list]

This will generally create fewer transitions but greater delay.

[b]Balanced interpretation[/b]

Changing several settings in the same direction can produce an extreme result.

For example:

[list]
[*]A very low threshold, high admission floor, large process boost and tight Supertrend factor may overreact.
[*]A very high threshold, low admission floor, high measurement noise and wide Supertrend factor may respond excessively slowly.
[/list]

The appropriate balance depends on the instrument, timeframe and intended holding period.

[b]How this differs from a standard Hull trend indicator[/b]

A standard Hull trend indicator normally uses:

[list]
[*]Hull slope.
[*]Price crossing the Hull.
[*]A fast and slow Hull comparison.
[/list]

This indicator instead:

[list]
[*]Uses the Hull as an observation.
[*]Measures its disagreement with a recursive estimate.
[*]Normalises that disagreement by volatility.
[*]Adapts the filter gain according to the innovation.
[*]Applies a final Supertrend regime around the filtered result.
[/list]

The Hull is therefore the beginning of the model, not the final signal.

[b]How this differs from a fixed Kalman-style filter[/b]

A fixed recursive filter uses constant uncertainty settings.

Innovation-Gated Hull Supertrend adapts both measurement and process uncertainty according to the normalised innovation.

This means:

[list]
[*]Small innovations are filtered more heavily.
[*]Large innovations receive greater admission.
[/list]

The response speed is therefore state dependent.

[b]How this differs from a standard Supertrend[/b]

A standard Supertrend is commonly centred around a raw price reference such as HL2.

This indicator uses:

[list]
[*]A responsive Hull projection.
[*]An innovation-gated recursive estimate of that projection.
[*]An optionally adaptive band multiplier.
[/list]

The Supertrend is therefore built around a filtered trend estimate rather than raw price alone.

[b]Strengths[/b]

[list]
[*]Combines responsive and stable trend-processing stages.
[*]Normalises new movement by current volatility.
[*]Uses a smooth gate rather than a binary threshold.
[*]Adapts measurement and process uncertainty.
[*]Can widen trend bands during quiet conditions.
[*]Can respond more rapidly to meaningful innovations.
[*]Separates early movement from final regime confirmation.
[*]Supports ATR, standard deviation and blended volatility models.
[*]Provides trend, impulse and visual comparison outputs.
[/list]

[b]Limitations[/b]

[list]
[*]The indicator is reactive rather than predictive.
[*]Strong filtering can delay genuine reversals.
[*]Responsive settings can increase whipsaws.
[*]A large innovation may represent a temporary shock rather than a lasting trend.
[*]Supertrend signals still depend on ATR and price crossing behaviour.
[*]Parameter combinations can materially change the model’s behaviour.
[*]The indicator may require different settings across assets and timeframes.
[*]The recursive state develops from the available chart history.
[*]Values can update while the current real-time candle is still forming.
[/list]

[b]Causality and real-time behaviour[/b]

The calculation uses current and historical observations without future-looking references.

However, like most indicators calculated on live candles, the current bar’s values can change before the candle closes.

This means:

[list]
[*]The Hull projection may move intrabar.
[*]The innovation score and gate may change intrabar.
[*]A Supertrend transition may appear and disappear before confirmation.
[/list]

Users requiring confirmed signals should evaluate the indicator at bar close or configure alerts accordingly.

[b]Alerts[/b]

The indicator provides three alert conditions:

[list]
[*][b]IGH ST Long:[/b] the adaptive Supertrend changes into a bullish regime.
[*][b]IGH ST Short:[/b] the adaptive Supertrend changes into a bearish regime.
[*][b]IGH Impulse:[/b] the normalised innovation score crosses above the selected threshold.
[/list]

The impulse alert identifies increased information flow into the filter. It does not specify direction by itself because the innovation score uses the absolute size of the prediction error.

[b]Summary[/b]

Innovation-Gated Hull Supertrend combines a responsive Hull Moving Average, a volatility-normalised innovation gate, an adaptive recursive filter and a volatility-trailing Supertrend.

The Hull projection provides an early estimate of directional movement. The recursive filter compares that projection with its prior state and measures the resulting innovation relative to ATR, standard deviation or a blend of both.

A logistic gate then determines how strongly the new movement should be admitted. During quiet conditions, the filter becomes more conservative and the Supertrend bands can expand. During meaningful displacement, the filter becomes more responsive and the bands move closer to their base width.

The final Supertrend converts the adaptive estimate into a persistent bullish or bearish regime.

The indicator is designed to make responsiveness conditional rather than fixed: small movements receive stronger filtering, while larger volatility-adjusted innovations are allowed to influence the model more quickly.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BackQuant

//@version=6
indicator(
 title="Innovation-Gated Hull Supertrend [BackQuant]",
 shorttitle="IGH ST [BackQuant]",
 overlay=true,
 timeframe="",
 timeframe_gaps=true
 )

const string calc = "Calculation Settings"
const string filter = "Innovation Filter"
const string st = "Supertrend"
const string ui = "UI Settings"

series float price_source = input.source(close, "Price Source", group=calc)
simple int hull_length = input.int(55, "Hull Length", group=calc)

simple int volatility_length = input.int(21, "Volatility Length", group=filter)
simple string volatility_mode = input.string("Blend", "Volatility Model", options=["ATR", "StdDev", "Blend"], group=filter)
simple float measurement_noise = input.float(4.0, "Measurement Noise", group=filter, inline="1"), simple float process_noise = input.float(0.03, "Process Noise", group=filter, inline="1")
simple float innovation_threshold = input.float(0.80, "Innovation Threshold", group=filter), simple float gate_sharpness = input.float(4.00, "Gate Sharpness", group=filter,inline="2")
simple float admission_floor = input.float(0.12, "Admission Floor", group=filter,inline="3"), simple float process_boost = input.float(4.00, "Process Boost", group=filter, inline="3")

simple int atr_period = input.int(12, "ATR Period", group=st, inline="ST")
simple float factor = input.float(1.70, "Factor", group=st, inline="ST")
simple bool adapt_bands = input.bool(true, "Adapt Bands With Innovation", group=st)
simple float quiet_band_expansion = input.float(0.35, "Quiet Band Expansion", group=st)

simple bool show_supertrend = input.bool(true, "Show Supertrend", group=ui)
simple bool show_filtered_hull = input.bool(false, "Show Filtered Hull", group=ui)
simple bool show_hull_projection = input.bool(false, "Show Hull Projection", group=ui)
simple bool paint_candles = input.bool(true, "Paint Candles According To Trend?", group=ui)
simple bool show_long_short = input.bool(true, "Show Long and Short Signals {𝕃 + 𝕊}", group=ui)

color long_color = input.color(#00ff00, "Long Color", group=ui, inline="Col")
color short_color = input.color(#ff0000, "Short Color", group=ui, inline="Col")

// State holders
type vnif_state
    float estimate = na
    float covariance = na
    float innovation = na
    float score = na
    float gate = na
    float admission = na
    float gain = na

type trend_state
    int value = 0

// Helpers
clamp(float value, float low, float high) =>
    math.min(math.max(value, low), high)

method hull_projection(series float source, simple int length) =>
    safe_length = math.max(length, 1)
    half_length = math.max(int(math.round(safe_length * 0.5)), 1)
    root_length = math.max(int(math.round(math.sqrt(safe_length))), 1)
    fast_wma = ta.wma(source, half_length)
    slow_wma = ta.wma(source, safe_length)
    raw_hull = 2.0 * fast_wma - slow_wma
    ta.wma(raw_hull, root_length)

method volatility_base(series float source, simple int length, simple string mode) =>
    safe_length = math.max(length, 1)
    atr_volatility = nz(ta.atr(safe_length), 0.0)
    stdev_volatility = nz(ta.stdev(source, safe_length), 0.0)
    volatility = switch mode
        "ATR" => atr_volatility
        "StdDev" => stdev_volatility
        => (atr_volatility + stdev_volatility) * 0.5
    math.max(volatility, syminfo.mintick)

// Innovation gate + Kalman update
method update_filter(vnif_state this, series float source, series float volatility, simple float raw_measurement_noise, simple float raw_process_noise, simple float threshold, simple float sharpness, simple float floor, simple float boost) =>
    safe_volatility = math.max(volatility, syminfo.mintick)
    safe_measurement_noise = math.max(raw_measurement_noise, syminfo.mintick)
    safe_process_noise = math.max(raw_process_noise, syminfo.mintick)
    safe_threshold = math.max(threshold, syminfo.mintick)
    safe_sharpness = math.max(sharpness, syminfo.mintick)
    safe_floor = clamp(floor, syminfo.mintick, 1.0)
    safe_boost = math.max(boost, 0.0)

    prediction = na(this.estimate) ? source : this.estimate
    prior_covariance = na(this.covariance) ? 1.0 : this.covariance

    this.innovation := na(source) or na(prediction) ? 0.0 : source - prediction
    this.score := math.abs(this.innovation) / safe_volatility

    gate_input = clamp(safe_sharpness * (this.score - safe_threshold), -60.0, 60.0)
    this.gate := 1.0 / (1.0 + math.exp(-gate_input))
    this.admission := safe_floor + (1.0 - safe_floor) * this.gate

    adaptive_measurement_noise = safe_measurement_noise / this.admission
    adaptive_process_noise = safe_process_noise * (1.0 + safe_boost * this.gate)
    predicted_covariance = prior_covariance + adaptive_process_noise

    this.gain := predicted_covariance / (predicted_covariance + adaptive_measurement_noise)

    if not na(source)
        this.estimate := prediction + this.gain * this.innovation
        this.covariance := (1.0 - this.gain) * predicted_covariance

    this.estimate

method band_factor(vnif_state this, simple float base_factor, simple bool use_adaptation, simple float expansion) =>
    safe_factor = math.max(base_factor, syminfo.mintick)
    safe_expansion = math.max(expansion, 0.0)
    gate = na(this.gate) ? 0.0 : this.gate
    use_adaptation ? safe_factor * (1.0 + safe_expansion * (1.0 - gate)) : safe_factor

method supertrend(series float source, series float st_factor, simple int st_atr_period) =>
    safe_atr_period = math.max(st_atr_period, 1)
    atr = ta.atr(safe_atr_period)
    upper_band = source + st_factor * atr
    lower_band = source - st_factor * atr
    prev_lower_band = nz(lower_band[1], lower_band)
    prev_upper_band = nz(upper_band[1], upper_band)

    lower_band := lower_band > prev_lower_band or close[1] < prev_lower_band ? lower_band : prev_lower_band
    upper_band := upper_band < prev_upper_band or close[1] > prev_upper_band ? upper_band : prev_upper_band

    int direction = na
    float super_trend = na
    prev_super_trend = super_trend[1]

    if na(atr[1]) or na(source[1])
        direction := 1
    else if prev_super_trend == prev_upper_band
        direction := close > upper_band ? -1 : 1
    else
        direction := close < lower_band ? 1 : -1

    super_trend := direction == -1 ? lower_band : upper_band
    [super_trend, direction]

method update_trend(trend_state this, bool long_signal, bool short_signal) =>
    if long_signal and not short_signal
        this.value := 1
    if short_signal
        this.value := -1
    this.value

method trend_colour(trend_state this, color bull, color bear) =>
    this.value == 1 ? bull : this.value == -1 ? bear : color.gray

// Core
hull = price_source.hull_projection(hull_length)
volatility = hull.volatility_base(volatility_length, volatility_mode)

var vnif_state vnif = vnif_state.new()
filtered_hull = vnif.update_filter(hull, volatility, measurement_noise, process_noise, innovation_threshold, gate_sharpness, admission_floor, process_boost)
adaptive_factor = vnif.band_factor(factor, adapt_bands, quiet_band_expansion)

[super_trend, direction] = filtered_hull.supertrend(adaptive_factor, atr_period)

// Signals
long_signal = ta.crossunder(direction, 0)
short_signal = ta.crossover(direction, 0)

var trend_state trend = trend_state.new()
trend.update_trend(long_signal, short_signal)
bar_colour = trend.trend_colour(long_color, short_color)

// Plotting
plot(show_hull_projection ? hull : na, "Hull Projection", color=color.new(color.gray, 65), linewidth=1)
plot(show_filtered_hull ? filtered_hull : na, "IGH", color=color.new(color.white, 0), linewidth=2)
plot(show_supertrend ? super_trend : na, "IGH Supertrend", color=color.new(bar_colour, 35), linewidth=4)

barcolor(paint_candles ? bar_colour : na)

plotshape(long_signal and show_long_short, title="Long", text="𝕃", style=shape.triangleup, location=location.belowbar, color=bar_colour, textcolor=bar_colour, size=size.tiny)
plotshape(short_signal and show_long_short, title="Short", text="𝕊", style=shape.triangledown, location=location.abovebar, color=bar_colour, textcolor=bar_colour, size=size.tiny)

// Alerts
innovation_impulse = ta.crossover(vnif.score, math.max(innovation_threshold, syminfo.mintick))
alertcondition(long_signal, title="IGH ST Long", message="IGH ST Long {{exchange}}:{{ticker}}")
alertcondition(short_signal, title="IGH ST Short", message="IGH ST Short {{exchange}}:{{ticker}}")
alertcondition(innovation_impulse, title="IGH Impulse", message="IGH Impulse {{exchange}}:{{ticker}}")
````
